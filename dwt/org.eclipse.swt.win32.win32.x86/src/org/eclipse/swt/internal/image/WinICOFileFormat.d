/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module org.eclipse.swt.internal.image.WinICOFileFormat;

import org.eclipse.swt.internal.image.FileFormat;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.internal.image.WinBMPFileFormat;
import org.eclipse.swt.SWT;
import java.lang.all;


public final class WinICOFileFormat : FileFormat {

byte[] bitInvertData(byte[] data, int startIndex, int endIndex) {
    // Destructively bit invert data in the given byte array.
    for (int i = startIndex; i < endIndex; i++) {
        data[i] = cast(byte)(255 - data[i - startIndex]);
    }
    return data;
}

static final byte[] convertPad(byte[] data, int width, int height, int depth, int pad, int newPad) {
    if (pad is newPad) return data;
    int stride = (width * depth + 7) / 8;
    int bpl = (stride + (pad - 1)) / pad * pad;
    int newBpl = (stride + (newPad - 1)) / newPad * newPad;
    byte[] newData = new byte[height * newBpl];
    int srcIndex = 0, destIndex = 0;
    for (int y = 0; y < height; y++) {
        System.arraycopy(data, srcIndex, newData, destIndex, newBpl);
        srcIndex += bpl;
        destIndex += newBpl;
    }
    return newData;
}
/**
 * Answer the size in bytes of the file representation of the given
 * icon
 */
int iconSize(ImageData i) {
    int shapeDataStride = (i.width * i.depth + 31) / 32 * 4;
    int maskDataStride = (i.width + 31) / 32 * 4;
    int dataSize = (shapeDataStride + maskDataStride) * i.height;
    int paletteSize = i.palette.colors !is null ? cast(int)/*64bit*/i.palette.colors.length * 4 : 0;
    return WinBMPFileFormat.BMPHeaderFixedSize + paletteSize + dataSize;
}
override bool isFileFormat(LEDataInputStream stream) {
    try {
        byte[] header = new byte[4];
        stream.read(header);
        stream.unread(header);
        return header[0] is 0 && header[1] is 0 && header[2] is 1 && header[3] is 0;
    } catch (Exception e) {
        return false;
    }
}
bool isValidIcon(ImageData i) {
    switch (i.depth) {
        case 1:
        case 4:
        case 8:
            if (i.palette.isDirect) return false;
            int size = cast(int)/*64bit*/i.palette.colors.length;
            return size is 2 || size is 16 || size is 32 || size is 256;
        case 24:
        case 32:
            return i.palette.isDirect;
        default:
    }
    return false;
}
int loadFileHeader(LEDataInputStream byteStream) {
    int[] fileHeader = new int[3];
    try {
        fileHeader[0] = byteStream.readShort();
        fileHeader[1] = byteStream.readShort();
        fileHeader[2] = byteStream.readShort();
    } catch (IOException e) {
        SWT.error(SWT.ERROR_IO, e);
    }
    if ((fileHeader[0] !is 0) || (fileHeader[1] !is 1))
        SWT.error(SWT.ERROR_INVALID_IMAGE);
    int numIcons = fileHeader[2];
    if (numIcons <= 0)
        SWT.error(SWT.ERROR_INVALID_IMAGE);
    return numIcons;
}
int loadFileHeader(LEDataInputStream byteStream, bool hasHeader) {
    int[] fileHeader = new int[3];
    try {
        if (hasHeader) {
            fileHeader[0] = byteStream.readShort();
            fileHeader[1] = byteStream.readShort();
        } else {
            fileHeader[0] = 0;
            fileHeader[1] = 1;
        }
        fileHeader[2] = byteStream.readShort();
    } catch (IOException e) {
        SWT.error(SWT.ERROR_IO, e);
    }
    if ((fileHeader[0] !is 0) || (fileHeader[1] !is 1))
        SWT.error(SWT.ERROR_INVALID_IMAGE);
    int numIcons = fileHeader[2];
    if (numIcons <= 0)
        SWT.error(SWT.ERROR_INVALID_IMAGE);
    return numIcons;
}
override ImageData[] loadFromByteStream() {
    int numIcons = loadFileHeader(inputStream);
    int[][] headers = loadIconHeaders(numIcons);
    ImageData[] icons = new ImageData[headers.length];
    for (int i = 0; i < icons.length; i++) {
        icons[i] = loadIcon(headers[i]);
    }
    return icons;
}
/**
 * Load one icon from the byte stream.
 */
ImageData loadIcon(int[] iconHeader) {
    byte[] infoHeader = loadInfoHeader(iconHeader);
    WinBMPFileFormat bmpFormat = new WinBMPFileFormat();
    bmpFormat.inputStream = inputStream;
    PaletteData palette = bmpFormat.loadPalette(infoHeader);
    byte[] shapeData = bmpFormat.loadData(infoHeader);
    int width = (infoHeader[4] & 0xFF) | ((infoHeader[5] & 0xFF) << 8) | ((infoHeader[6] & 0xFF) << 16) | ((infoHeader[7] & 0xFF) << 24);
    int height = (infoHeader[8] & 0xFF) | ((infoHeader[9] & 0xFF) << 8) | ((infoHeader[10] & 0xFF) << 16) | ((infoHeader[11] & 0xFF) << 24);
    if (height < 0) height = -height;
    int depth = (infoHeader[14] & 0xFF) | ((infoHeader[15] & 0xFF) << 8);
    infoHeader[14] = 1;
    infoHeader[15] = 0;
    byte[] maskData = bmpFormat.loadData(infoHeader);
    maskData = convertPad(maskData, width, height, 1, 4, 2);
    bitInvertData(maskData, 0, cast(int)/*64bit*/maskData.length);
    return ImageData.internal_new(
        width,
        height,
        depth,
        palette,
        4,
        shapeData,
        2,
        maskData,
        null,
        -1,
        -1,
        SWT.IMAGE_ICO,
        0,
        0,
        0,
        0);
}
int[][] loadIconHeaders(int numIcons) {
    int[][] headers = new int[][]( numIcons, 7 );
    try {
        for (int i = 0; i < numIcons; i++) {
            headers[i][0] = inputStream.read();
            headers[i][1] = inputStream.read();
            headers[i][2] = inputStream.readShort();
            headers[i][3] = inputStream.readShort();
            headers[i][4] = inputStream.readShort();
            headers[i][5] = inputStream.readInt();
            headers[i][6] = inputStream.readInt();
        }
    } catch (IOException e) {
        SWT.error(SWT.ERROR_IO, e);
    }
    return headers;
}
byte[] loadInfoHeader(int[] iconHeader) {
    int width = iconHeader[0];
    int height = iconHeader[1];
    int numColors = iconHeader[2]; // the number of colors is in the low byte, but the high byte must be 0
    if (numColors is 0) numColors = 256; // this is specified: '00' represents '256' (0x100) colors
    if ((numColors !is 2) && (numColors !is 8) && (numColors !is 16) &&
        (numColors !is 32) && (numColors !is 256))
        SWT.error(SWT.ERROR_INVALID_IMAGE);
    if (inputStream.getPosition() < iconHeader[6]) {
        // Seek to the specified offset
        try {
            inputStream.skip(iconHeader[6] - inputStream.getPosition());
        } catch (IOException e) {
            SWT.error(SWT.ERROR_IO, e);
            return null;
        }
    }
    byte[] infoHeader = new byte[WinBMPFileFormat.BMPHeaderFixedSize];
    try {
        inputStream.read(infoHeader);
    } catch (IOException e) {
        SWT.error(SWT.ERROR_IO, e);
    }
    if (((infoHeader[12] & 0xFF) | ((infoHeader[13] & 0xFF) << 8)) !is 1)
        SWT.error(SWT.ERROR_INVALID_IMAGE);
    int infoWidth = (infoHeader[4] & 0xFF) | ((infoHeader[5] & 0xFF) << 8) | ((infoHeader[6] & 0xFF) << 16) | ((infoHeader[7] & 0xFF) << 24);
    int infoHeight = (infoHeader[8] & 0xFF) | ((infoHeader[9] & 0xFF) << 8) | ((infoHeader[10] & 0xFF) << 16) | ((infoHeader[11] & 0xFF) << 24);
    int bitCount = (infoHeader[14] & 0xFF) | ((infoHeader[15] & 0xFF) << 8);
    if (height is infoHeight && bitCount is 1) height /= 2;
    if (!((width is infoWidth) && (height * 2 is infoHeight) &&
        (bitCount is 1 || bitCount is 4 || bitCount is 8 || bitCount is 24 || bitCount is 32)))
            SWT.error(SWT.ERROR_INVALID_IMAGE);
    infoHeader[8] = cast(byte)(height & 0xFF);
    infoHeader[9] = cast(byte)((height >> 8) & 0xFF);
    infoHeader[10] = cast(byte)((height >> 16) & 0xFF);
    infoHeader[11] = cast(byte)((height >> 24) & 0xFF);
    return infoHeader;
}
/**
 * Unload a single icon
 */
void unloadIcon(ImageData icon) {
    int sizeImage = (((icon.width * icon.depth + 31) / 32 * 4) +
        ((icon.width + 31) / 32 * 4)) * icon.height;
    try {
        outputStream.writeInt(WinBMPFileFormat.BMPHeaderFixedSize);
        outputStream.writeInt(icon.width);
        outputStream.writeInt(icon.height * 2);
        outputStream.writeShort(1);
        outputStream.writeShort(cast(short)icon.depth);
        outputStream.writeInt(0);
        outputStream.writeInt(sizeImage);
        outputStream.writeInt(0);
        outputStream.writeInt(0);
        outputStream.writeInt(icon.palette.colors !is null ? cast(int)/*64bit*/icon.palette.colors.length : 0);
        outputStream.writeInt(0);
    } catch (IOException e) {
        SWT.error(SWT.ERROR_IO, e);
    }

    byte[] rgbs = WinBMPFileFormat.paletteToBytes(icon.palette);
    try {
        outputStream.write(rgbs);
    } catch (IOException e) {
        SWT.error(SWT.ERROR_IO, e);
    }
    unloadShapeData(icon);
    unloadMaskData(icon);
}
/**
 * Unload the icon header for the given icon, calculating the offset.
 */
void unloadIconHeader(ImageData i) {
    int headerSize = 16;
    int offset = headerSize + 6;
    int iconSize = iconSize(i);
    try {
        outputStream.write(i.width);
        outputStream.write(i.height);
        outputStream.writeShort(i.palette.colors !is null ? cast(int)/*64bit*/i.palette.colors.length : 0);
        outputStream.writeShort(0);
        outputStream.writeShort(0);
        outputStream.writeInt(iconSize);
        outputStream.writeInt(offset);
    } catch (IOException e) {
        SWT.error(SWT.ERROR_IO, e);
    }
}
override void unloadIntoByteStream(ImageLoader loader) {
    /* We do not currently support writing multi-image ico,
     * so we use the first image data in the loader's array. */
    ImageData image = loader.data[0];
    if (!isValidIcon(image))
        SWT.error(SWT.ERROR_INVALID_IMAGE);
    try {
        outputStream.writeShort(0);
        outputStream.writeShort(1);
        outputStream.writeShort(1);
    } catch (IOException e) {
        SWT.error(SWT.ERROR_IO, e);
    }
    unloadIconHeader(image);
    unloadIcon(image);
}
/**
 * Unload the mask data for an icon. The data is flipped vertically
 * and inverted.
 */
void unloadMaskData(ImageData icon) {
    ImageData mask = icon.getTransparencyMask();
    int bpl = (icon.width + 7) / 8;
    int pad = mask.scanlinePad;
    int srcBpl = (bpl + pad - 1) / pad * pad;
    int destBpl = (bpl + 3) / 4 * 4;
    byte[] buf = new byte[destBpl];
    int offset = (icon.height - 1) * srcBpl;
    byte[] data = mask.data;
    try {
        for (int i = 0; i < icon.height; i++) {
            System.arraycopy(data, offset, buf, 0, bpl);
            bitInvertData(buf, 0, bpl);
            outputStream.write(buf, 0, destBpl);
            offset -= srcBpl;
        }
    } catch (IOException e) {
        SWT.error(SWT.ERROR_IO, e);
    }
}
/**
 * Unload the shape data for an icon. The data is flipped vertically.
 */
void unloadShapeData(ImageData icon) {
    int bpl = (icon.width * icon.depth + 7) / 8;
    int pad = icon.scanlinePad;
    int srcBpl = (bpl + pad - 1) / pad * pad;
    int destBpl = (bpl + 3) / 4 * 4;
    byte[] buf = new byte[destBpl];
    int offset = (icon.height - 1) * srcBpl;
    byte[] data = icon.data;
    try {
        for (int i = 0; i < icon.height; i++) {
            System.arraycopy(data, offset, buf, 0, bpl);
            outputStream.write(buf, 0, destBpl);
            offset -= srcBpl;
        }
    } catch (IOException e) {
        SWT.error(SWT.ERROR_IO, e);
    }
}
}
