/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module org.eclipse.swt.internal.image.PngEncoder;

import java.lang.all;

import org.eclipse.swt.internal.image.LEDataOutputStream;
import org.eclipse.swt.internal.image.PngDeflater;
import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.ImageLoader;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.internal.Compatibility;
import org.eclipse.swt.internal.image.PngChunk;

final class PngEncoder {

    static const byte[] SIGNATURE = [cast(byte) '\211', cast(byte) 'P', cast(byte) 'N', cast(byte) 'G', cast(byte) '\r', cast(byte) '\n', cast(byte) '\032', cast(byte) '\n'];
    static const byte[] TAG_IHDR = [cast(byte) 'I', cast(byte) 'H', cast(byte) 'D', cast(byte) 'R'];
    static const byte[] TAG_PLTE = [cast(byte) 'P', cast(byte) 'L', cast(byte) 'T', cast(byte) 'E'];
    static const byte[] TAG_TRNS = [cast(byte) 't', cast(byte) 'R', cast(byte) 'N', cast(byte) 'S'];
    static const byte[] TAG_IDAT = [cast(byte) 'I', cast(byte) 'D', cast(byte) 'A', cast(byte) 'T'];
    static const byte[] TAG_IEND = [cast(byte) 'I', cast(byte) 'E', cast(byte) 'N', cast(byte) 'D'];

    ByteArrayOutputStream bytes;
    PngChunk chunk;

    ImageLoader loader;
    ImageData data;
    int transparencyType;

    int width, height, bitDepth, colorType;

    int compressionMethod = 0;
    int filterMethod = 0;
    int interlaceMethod = 0;

public this(ImageLoader loader) {
    this.bytes = new ByteArrayOutputStream(1024);
    this.loader = loader;
    this.data = loader.data[0];
    this.transparencyType = data.getTransparencyType();

    this.width = data.width;
    this.height = data.height;

    this.bitDepth = 8;

    this.colorType = 2;

    if (data.palette.isDirect) {
        if (transparencyType is SWT.TRANSPARENCY_ALPHA) {
            this.colorType = 6;
        }
    }
    else {
        this.colorType = 3;
    }

    if (!(colorType is 2 || colorType is 3 || colorType is 6)) SWT.error(SWT.ERROR_INVALID_IMAGE);

}

void writeShort(ByteArrayOutputStream baos, int theShort) {

    byte byte1 = cast(byte) ((theShort >> 8) & 0xff);
    byte byte2 = cast(byte) (theShort & 0xff);
    byte[2] temp = [byte1, byte2];
    baos.write(temp, 0, 2);

}

void writeInt(ByteArrayOutputStream baos, int theInt) {

    byte byte1 = cast(byte) ((theInt >> 24) & 0xff);
    byte byte2 = cast(byte) ((theInt >> 16) & 0xff);
    byte byte3 = cast(byte) ((theInt >> 8) & 0xff);
    byte byte4 = cast(byte) (theInt & 0xff);
    byte[4] temp = [byte1, byte2, byte3, byte4];
    baos.write(temp, 0, 4);

}

void writeChunk(in byte[] tag, in byte[] buffer) {

    int bufferLength = (buffer !is null) ? cast(int)/*64bit*/buffer.length : 0;

    chunk = new PngChunk(bufferLength);

    writeInt(bytes, bufferLength);
    bytes.write(tag, 0, 4);
    chunk.setType(tag);
    if (bufferLength !is 0) {
        bytes.write(buffer, 0, bufferLength);
        chunk.setData(buffer);
    }
    else {
        chunk.setCRC(chunk.computeCRC());
    }
    writeInt(bytes, chunk.getCRC());

}

void writeSignature() {

    bytes.write(SIGNATURE, 0, 8);

}

void writeHeader() {

    ByteArrayOutputStream baos = new ByteArrayOutputStream(13);

    writeInt(baos, width);
    writeInt(baos, height);
    baos.write(bitDepth);
    baos.write(colorType);
    baos.write(compressionMethod);
    baos.write(filterMethod);
    baos.write(interlaceMethod);

    writeChunk(TAG_IHDR, baos.toByteArray());

}

void writePalette() {

    RGB[] RGBs = data.palette.getRGBs();

    if (RGBs.length > 256) SWT.error(SWT.ERROR_INVALID_IMAGE);

    ByteArrayOutputStream baos = new ByteArrayOutputStream(cast(int)/*64bit*/RGBs.length);

    for (int i = 0; i < RGBs.length; i++) {

        baos.write(cast(byte) RGBs[i].red);
        baos.write(cast(byte) RGBs[i].green);
        baos.write(cast(byte) RGBs[i].blue);

    }

    writeChunk(TAG_PLTE, baos.toByteArray());

}

void writeTransparency() {

    ByteArrayOutputStream baos = new ByteArrayOutputStream();

    switch (transparencyType) {

        case SWT.TRANSPARENCY_ALPHA:

            int pixelValue, alphaValue;

            byte[] alphas = new byte[data.palette.getRGBs().length];

            for (int y = 0; y < height; y++) {

                for (int x = 0; x < width; x++) {

                    pixelValue = data.getPixel(x, y);
                    alphaValue = data.getAlpha(x, y);

                    alphas[pixelValue] = cast(byte) alphaValue;

                }

            }

            baos.write(alphas, 0, alphas.length);

            break;

        case SWT.TRANSPARENCY_PIXEL:

            int pixel = data.transparentPixel;

            if (colorType is 2) {

                int redMask = data.palette.redMask;
                int redShift = data.palette.redShift;
                int greenMask = data.palette.greenMask;
                int greenShift = data.palette.greenShift;
                int blueShift = data.palette.blueShift;
                int blueMask = data.palette.blueMask;

                int r = pixel & redMask;
                r = (redShift < 0) ? r >>> -redShift : r << redShift;
                int g = pixel & greenMask;
                g = (greenShift < 0) ? g >>> -greenShift : g << greenShift;
                int b = pixel & blueMask;
                b = (blueShift < 0) ? b >>> -blueShift : b << blueShift;

                writeShort(baos, r);
                writeShort(baos, g);
                writeShort(baos, b);

            }

            if (colorType is 3) {

                byte[] padding = new byte[pixel + 1];

                for (int i = 0; i < pixel; i++) {

                    padding[i] = cast(byte) 255;

                }

                padding[pixel] = cast(byte) 0;

                baos.write(padding, 0, padding.length);

            }

            break;
        default:

    }

    writeChunk(TAG_TRNS, baos.toByteArray());

}

void writeImageData() {

    ByteArrayOutputStream baos = new ByteArrayOutputStream(1024);
    OutputStream os = Compatibility.newDeflaterOutputStream(baos);
    if (os is null) os = baos;

    if (colorType is 3) {

        byte[] lineData = new byte[width];

        for (int y = 0; y < height; y++) {

            int filter = 0;
            os.write(filter);

            data.getPixels(0, y, width, lineData, 0);

            for (int x = 0; x < lineData.length; x++) {

                os.write(lineData[x]);

            }

        }

    }

    else {

        int[] lineData = new int[width];
        byte[] alphaData = null;
        if (colorType is 6) {
            alphaData = new byte[width];
        }

        int redMask = data.palette.redMask;
        int redShift = data.palette.redShift;
        int greenMask = data.palette.greenMask;
        int greenShift = data.palette.greenShift;
        int blueShift = data.palette.blueShift;
        int blueMask = data.palette.blueMask;

        for (int y = 0; y < height; y++) {

            int filter = 0;
            os.write(filter);

            data.getPixels(0, y, width, lineData, 0);

            if (colorType is 6) {
                data.getAlphas(0, y, width, alphaData, 0);
            }

            for (int x = 0; x < lineData.length; x++) {

                int pixel = lineData[x];

                int r = pixel & redMask;
                r = (redShift < 0) ? r >>> -redShift : r << redShift;
                int g = pixel & greenMask;
                g = (greenShift < 0) ? g >>> -greenShift : g << greenShift;
                int b = pixel & blueMask;
                b = (blueShift < 0) ? b >>> -blueShift : b << blueShift;

                os.write(r);
                os.write(g);
                os.write(b);

                if (colorType is 6) {
                    os.write(alphaData[x]);
                }

            }

        }

    }

    os.flush();
    os.close();

    byte[] compressed = baos.toByteArray();
    if (os is baos) {
        PngDeflater deflater = new PngDeflater();
        compressed = deflater.deflate(compressed);
    }

    writeChunk(TAG_IDAT, compressed);

}

void writeEnd() {

    writeChunk(TAG_IEND, null);

}

public void encode(LEDataOutputStream outputStream) {

    try {

        writeSignature();
        writeHeader();

        if (colorType is 3) {
            writePalette();
        }

        bool transparencyAlpha = (transparencyType is SWT.TRANSPARENCY_ALPHA);
        bool transparencyPixel = (transparencyType is SWT.TRANSPARENCY_PIXEL);
        bool type2Transparency = (colorType is 2 && transparencyPixel);
        bool type3Transparency = (colorType is 3 && (transparencyAlpha || transparencyPixel));

        if (type2Transparency || type3Transparency) {
            writeTransparency();
        }

        writeImageData();
        writeEnd();

        outputStream.write(bytes.toByteArray());

    }

    catch (IOException e) {

        SWT.error(SWT.ERROR_IO, e);

    }

}

}
