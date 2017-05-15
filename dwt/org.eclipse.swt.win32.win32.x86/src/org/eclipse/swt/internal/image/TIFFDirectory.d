/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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
module org.eclipse.swt.internal.image.TIFFDirectory;

import org.eclipse.swt.internal.image.TIFFRandomFileAccess;
import org.eclipse.swt.internal.image.TIFFModifiedHuffmanCodec;
import org.eclipse.swt.internal.image.LEDataOutputStream;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.ImageLoaderEvent;
import org.eclipse.swt.graphics.ImageLoader;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.SWT;
import java.lang.all;

final class TIFFDirectory {

    TIFFRandomFileAccess file;
    bool isLittleEndian;
    ImageLoader loader;
    int depth;

    /* Directory fields */
    int imageWidth;
    int imageLength;
    int[] bitsPerSample;
    int compression;
    int photometricInterpretation;
    int[] stripOffsets;
    int samplesPerPixel;
    int rowsPerStrip;
    int[] stripByteCounts;
    int t4Options;
    int colorMapOffset;

    /* Encoder fields */
    ImageData image;
    LEDataOutputStream ostr;

    static const int NO_VALUE = -1;

    static const short TAG_ImageWidth = 256;
    static const short TAG_ImageLength = 257;
    static const short TAG_BitsPerSample = 258;
    static const short TAG_Compression = 259;
    static const short TAG_PhotometricInterpretation = 262;
    static const short TAG_StripOffsets = 273;
    static const short TAG_SamplesPerPixel = 277;
    static const short TAG_RowsPerStrip = 278;
    static const short TAG_StripByteCounts = 279;
    static const short TAG_XResolution = 282;
    static const short TAG_YResolution = 283;
    static const short TAG_T4Options = 292;
    static const short TAG_ResolutionUnit = 296;
    static const short TAG_ColorMap = 320;

    static const int TYPE_BYTE = 1;
    static const int TYPE_ASCII = 2;
    static const int TYPE_SHORT = 3;
    static const int TYPE_LONG = 4;
    static const int TYPE_RATIONAL = 5;

    /* Different compression schemes */
    static const int COMPRESSION_NONE = 1;
    static const int COMPRESSION_CCITT_3_1 = 2;
    static const int COMPRESSION_PACKBITS = 32773;

    static const int IFD_ENTRY_SIZE = 12;

public this(TIFFRandomFileAccess file, bool isLittleEndian, ImageLoader loader) {
    this.file = file;
    this.isLittleEndian = isLittleEndian;
    this.loader = loader;
}

public this(ImageData image) {
    this.image = image;
}

/* PackBits decoder */
int decodePackBits(byte[] src, byte[] dest, int offsetDest) {
    int destIndex = offsetDest;
    int srcIndex = 0;
    while (srcIndex < src.length) {
        byte n = src[srcIndex];
        if (0 <= n && n <= 127) {
            /* Copy next n+1 bytes literally */
            System.arraycopy(src, ++srcIndex, dest, destIndex, n + 1);
            srcIndex += n + 1;
            destIndex += n + 1;
        } else if (-127 <= n && n <= -1) {
            /* Copy next byte -n+1 times */
            byte value = src[++srcIndex];
            for (int j = 0; j < -n + 1; j++) {
                dest[destIndex++] = value;
            }
            srcIndex++;
        } else {
            /* Noop when n is -128 */
            srcIndex++;
        }
    }
    /* Number of bytes copied */
    return destIndex - offsetDest;
}

int getEntryValue(int type, byte[] buffer, int index) {
    return toInt(buffer, index + 8, type);
}

void getEntryValue(int type, byte[] buffer, int index, int[] values)  {
    int start = index + 8;
    int size;
    int offset = toInt(buffer, start, TYPE_LONG);
    switch (type) {
        case TYPE_SHORT: size = 2; break;
        case TYPE_LONG: size = 4; break;
        case TYPE_RATIONAL: size = 8; break;
        case TYPE_ASCII:
        case TYPE_BYTE: size = 1; break;
        default: SWT.error(SWT.ERROR_UNSUPPORTED_FORMAT); return;
    }
    if (values.length * size > 4) {
        buffer = new byte[values.length * size];
        file.seek(offset);
        file.read(buffer);
        start = 0;
    }
    for (int i = 0; i < values.length; i++) {
        values[i] = toInt(buffer, start + i * size, type);
    }
}

void decodePixels(ImageData image)  {
    /* Each row is byte aligned */
    byte[] imageData = new byte[(imageWidth * depth + 7) / 8 * imageLength];
    image.data = imageData;
    int destIndex = 0;
    int length = cast(int)/*64bit*/stripOffsets.length;
    for (int i = 0; i < length; i++) {
        /* Read a strip */
        byte[] data = new byte[](stripByteCounts[i]);
        file.seek(stripOffsets[i]);
        file.read(data);
        if (compression is COMPRESSION_NONE) {
            System.arraycopy(data, 0, imageData, destIndex, data.length);
            destIndex += data.length;
        } else if (compression is COMPRESSION_PACKBITS) {
            destIndex += decodePackBits(data, imageData, destIndex);
        } else if (compression is COMPRESSION_CCITT_3_1 || compression is 3) {
            TIFFModifiedHuffmanCodec codec = new TIFFModifiedHuffmanCodec();
            int nRows = rowsPerStrip;
            if (i is length -1) {
                int n = imageLength % rowsPerStrip;
                if (n !is 0) nRows = n;
            }
            destIndex += codec.decode(data, imageData, destIndex, imageWidth, nRows);
        }
        if (loader.hasListeners()) {
            loader.notifyListeners(new ImageLoaderEvent(loader, image, i, i is length - 1));
        }
    }
}

PaletteData getColorMap()  {
    int numColors = 1 << bitsPerSample[0];
    /* R, G, B entries are 16 bit wide (2 bytes) */
    int numBytes = 3 * 2 * numColors;
    byte[] buffer = new byte[numBytes];
    file.seek(colorMapOffset);
    file.read(buffer);
    RGB[] colors = new RGB[numColors];
    /**
     * SWT does not support 16-bit depth color formats.
     * Convert the 16-bit data to 8-bit data.
     * The correct way to do this is to multiply each
     * 16 bit value by the value:
     * (2^8 - 1) / (2^16 - 1).
     * The fast way to do this is just to drop the low
     * byte of the 16-bit value.
     */
    int offset = isLittleEndian ? 1 : 0;
    int startG = 2 * numColors;
    int startB = startG + 2 * numColors;
    for (int i = 0; i < numColors; i++) {
        int r = buffer[offset] & 0xFF;
        int g = buffer[startG + offset] & 0xFF;
        int b = buffer[startB + offset] & 0xFF;
        colors[i] = new RGB(r, g, b);
        offset += 2;
    }
    return new PaletteData(colors);
}

PaletteData getGrayPalette() {
    int numColors = 1 << bitsPerSample[0];
    RGB[] rgbs = new RGB[numColors];
    for (int i = 0; i < numColors; i++) {
        int value = i * 0xFF / (numColors - 1);
        if (photometricInterpretation is 0) value = 0xFF - value;
        rgbs[i] = new RGB(value, value, value);
    }
    return new PaletteData(rgbs);
}

PaletteData getRGBPalette(int bitsR, int bitsG, int bitsB) {
    int blueMask = 0;
    for (int i = 0; i < bitsB; i++) {
        blueMask |= 1 << i;
    }
    int greenMask = 0;
    for (int i = bitsB; i < bitsB + bitsG; i++) {
        greenMask |= 1 << i;
    }
    int redMask = 0;
    for (int i = bitsB + bitsG; i < bitsB + bitsG + bitsR; i++) {
        redMask |= 1 << i;
    }
    return new PaletteData(redMask, greenMask, blueMask);
}

int formatStrips(int rowByteSize, int nbrRows, byte[] data, int maxStripByteSize, int offsetPostIFD, int extraBytes, int[][] strips) {
    /*
    * Calculate the nbr of required strips given the following requirements:
    * - each strip should, if possible, not be greater than maxStripByteSize
    * - each strip should contain 1 or more entire rows
    *
    * Format the strip fields arrays so that the image data is stored in one
    * contiguous block. This block is stored after the IFD and after any tag
    * info described in the IFD.
    */
    int n, nbrRowsPerStrip;
    if (rowByteSize > maxStripByteSize) {
        /* Each strip contains 1 row */
        n = cast(int)/*64bit*/data.length / rowByteSize;
        nbrRowsPerStrip = 1;
    } else {
        int nbr = (cast(int)/*64bit*/data.length + maxStripByteSize - 1) / maxStripByteSize;
        nbrRowsPerStrip = nbrRows / nbr;
        n = (nbrRows + nbrRowsPerStrip - 1) / nbrRowsPerStrip;
    }
    int stripByteSize = rowByteSize * nbrRowsPerStrip;

    int[] offsets = new int[n];
    int[] counts = new int[n];
    /*
    * Nbr of bytes between the end of the IFD directory and the start of
    * the image data. Keep space for at least the offsets and counts
    * data, each field being TYPE_LONG (4 bytes). If other tags require
    * space between the IFD and the image block, use the extraBytes
    * parameter.
    * If there is only one strip, the offsets and counts data is stored
    * directly in the IFD and we need not reserve space for it.
    */
    int postIFDData = n is 1 ? 0 : n * 2 * 4;
    int startOffset = offsetPostIFD + extraBytes + postIFDData; /* offset of image data */

    int offset = startOffset;
    for (int i = 0; i < n; i++) {
        /*
        * Store all strips sequentially to allow us
        * to copy all pixels in one contiguous area.
        */
        offsets[i] = offset;
        counts[i] = stripByteSize;
        offset += stripByteSize;
    }
    /* The last strip may contain fewer rows */
    int mod = cast(int)/*64bit*/data.length % stripByteSize;
    if (mod !is 0) counts[counts.length - 1] = mod;

    strips[0] = offsets;
    strips[1] = counts;
    return nbrRowsPerStrip;
}

int[] formatColorMap(RGB[] rgbs) {
    /*
    * In a TIFF ColorMap, all red come first, followed by
    * green and blue. All values must be converted from
    * 8 bit to 16 bit.
    */
    int[] colorMap = new int[rgbs.length * 3];
    int offsetGreen = cast(int)/*64bit*/rgbs.length;
    int offsetBlue = cast(int)/*64bit*/rgbs.length * 2;
    for (int i = 0; i < rgbs.length; i++) {
        colorMap[i] = rgbs[i].red << 8 | rgbs[i].red;
        colorMap[i + offsetGreen] = rgbs[i].green << 8 | rgbs[i].green;
        colorMap[i + offsetBlue] = rgbs[i].blue << 8 | rgbs[i].blue;
    }
    return colorMap;
}

void parseEntries(byte[] buffer)  {
    for (int offset = 0; offset < buffer.length; offset += IFD_ENTRY_SIZE) {
        int tag = toInt(buffer, offset, TYPE_SHORT);
        int type = toInt(buffer, offset + 2, TYPE_SHORT);
        int count = toInt(buffer, offset + 4, TYPE_LONG);
        switch (tag) {
            case TAG_ImageWidth: {
                imageWidth = getEntryValue(type, buffer, offset);
                break;
            }
            case TAG_ImageLength: {
                imageLength = getEntryValue(type, buffer, offset);
                break;
            }
            case TAG_BitsPerSample: {
                if (type !is TYPE_SHORT) SWT.error(SWT.ERROR_INVALID_IMAGE);
                bitsPerSample = new int[count];
                getEntryValue(type, buffer, offset, bitsPerSample);
                break;
            }
            case TAG_Compression: {
                compression = getEntryValue(type, buffer, offset);
                break;
            }
            case TAG_PhotometricInterpretation: {
                photometricInterpretation = getEntryValue(type, buffer, offset);
                break;
            }
            case TAG_StripOffsets: {
                if (type !is TYPE_LONG && type !is TYPE_SHORT) SWT.error(SWT.ERROR_INVALID_IMAGE);
                stripOffsets = new int[count];
                getEntryValue(type, buffer, offset, stripOffsets);
                break;
            }
            case TAG_SamplesPerPixel: {
                if (type !is TYPE_SHORT) SWT.error(SWT.ERROR_INVALID_IMAGE);
                samplesPerPixel = getEntryValue(type, buffer, offset);
                /* Only the basic 1 and 3 values are supported */
                if (samplesPerPixel !is 1 && samplesPerPixel !is 3) SWT.error(SWT.ERROR_UNSUPPORTED_DEPTH);
                break;
            }
            case TAG_RowsPerStrip: {
                rowsPerStrip = getEntryValue(type, buffer, offset);
                break;
            }
            case TAG_StripByteCounts: {
                stripByteCounts = new int[count];
                getEntryValue(type, buffer, offset, stripByteCounts);
                break;
            }
            case TAG_XResolution: {
                /* Ignored */
                break;
            }
            case TAG_YResolution: {
                /* Ignored */
                break;
            }
            case TAG_T4Options: {
                if (type !is TYPE_LONG) SWT.error(SWT.ERROR_INVALID_IMAGE);
                t4Options = getEntryValue(type, buffer, offset);
                if ((t4Options & 0x1) is 1) {
                    /* 2-dimensional coding is not supported */
                    SWT.error(SWT.ERROR_UNSUPPORTED_FORMAT);
                }
                break;
            }
            case TAG_ResolutionUnit: {
                /* Ignored */
                break;
            }
            case TAG_ColorMap: {
                if (type !is TYPE_SHORT) SWT.error(SWT.ERROR_INVALID_IMAGE);
                /* Get the offset of the colorMap (use TYPE_LONG) */
                colorMapOffset = getEntryValue(TYPE_LONG, buffer, offset);
                break;
            }
            default:
        }
    }
}

public ImageData read()  {
    /* Set TIFF default values */
    bitsPerSample = [1];
    colorMapOffset = NO_VALUE;
    compression = 1;
    imageLength = NO_VALUE;
    imageWidth = NO_VALUE;
    photometricInterpretation = NO_VALUE;
    rowsPerStrip = Integer.MAX_VALUE;
    samplesPerPixel = 1;
    stripByteCounts = null;
    stripOffsets = null;

    byte[] buffer = new byte[2];
    file.read(buffer);
    int numberEntries = toInt(buffer, 0, TYPE_SHORT);
    buffer = new byte[IFD_ENTRY_SIZE * numberEntries];
    file.read(buffer);
    parseEntries(buffer);

    PaletteData palette = null;
    depth = 0;
    switch (photometricInterpretation) {
        case 0:
        case 1: {
            /* Bilevel or Grayscale image */
            palette = getGrayPalette();
            depth = bitsPerSample[0];
            break;
        }
        case 2: {
            /* RGB image */
            if (colorMapOffset !is NO_VALUE) SWT.error(SWT.ERROR_INVALID_IMAGE);
            /* SamplesPerPixel 3 is the only value supported */
            palette = getRGBPalette(bitsPerSample[0], bitsPerSample[1], bitsPerSample[2]);
            depth = bitsPerSample[0] + bitsPerSample[1] + bitsPerSample[2];
            break;
        }
        case 3: {
            /* Palette Color image */
            if (colorMapOffset is NO_VALUE) SWT.error(SWT.ERROR_INVALID_IMAGE);
            palette = getColorMap();
            depth = bitsPerSample[0];
            break;
        }
        default: {
            SWT.error(SWT.ERROR_INVALID_IMAGE);
        }
    }

    ImageData image = ImageData.internal_new(
            imageWidth,
            imageLength,
            depth,
            palette,
            1,
            null,
            0,
            null,
            null,
            -1,
            -1,
            SWT.IMAGE_TIFF,
            0,
            0,
            0,
            0);
    decodePixels(image);
    return image;
}

int toInt(byte[] buffer, int i, int type) {
    if (type is TYPE_LONG) {
        return isLittleEndian ?
        (buffer[i] & 0xFF) | ((buffer[i + 1] & 0xFF) << 8) | ((buffer[i + 2] & 0xFF) << 16) | ((buffer[i + 3] & 0xFF) << 24) :
        (buffer[i + 3] & 0xFF) | ((buffer[i + 2] & 0xFF) << 8) | ((buffer[i + 1] & 0xFF) << 16) | ((buffer[i] & 0xFF) << 24);
    }
    if (type is TYPE_SHORT) {
        return isLittleEndian ?
        (buffer[i] & 0xFF) | ((buffer[i + 1] & 0xFF) << 8) :
        (buffer[i + 1] & 0xFF) | ((buffer[i] & 0xFF) << 8);
    }
    /* Invalid type */
    SWT.error(SWT.ERROR_INVALID_IMAGE);
    return -1;
}

void write(int photometricInterpretation)  {
    bool isRGB = photometricInterpretation is 2;
    bool isColorMap = photometricInterpretation is 3;
    bool isBiLevel = photometricInterpretation is 0 || photometricInterpretation is 1;

    int imageWidth = image.width;
    int imageLength = image.height;
    int rowByteSize = image.bytesPerLine;

    int numberEntries = isBiLevel ? 9 : 11;
    int lengthDirectory = 2 + 12 * numberEntries + 4;
    /* Offset following the header and the directory */
    int nextOffset = 8 + lengthDirectory;

    /* Extra space used by XResolution and YResolution values */
    int extraBytes = 16;

    int[] colorMap = null;
    if (isColorMap) {
        PaletteData palette = image.palette;
        RGB[] rgbs = palette.getRGBs();
        colorMap = formatColorMap(rgbs);
        /* The number of entries of the Color Map must match the bitsPerSample field */
        if (colorMap.length !is 3 * 1 << image.depth) SWT.error(SWT.ERROR_UNSUPPORTED_FORMAT);
        /* Extra space used by ColorMap values */
        extraBytes += colorMap.length * 2;
    }
    if (isRGB) {
        /* Extra space used by BitsPerSample values */
        extraBytes += 6;
    }
    /* TIFF recommends storing the data in strips of no more than 8 Ko */
    byte[] data = image.data;
    int[][] strips = new int[][](2);
    int nbrRowsPerStrip = formatStrips(rowByteSize, imageLength, data, 8192, nextOffset, extraBytes, strips);
    int[] stripOffsets = strips[0];
    int[] stripByteCounts = strips[1];

    int bitsPerSampleOffset = NO_VALUE;
    if (isRGB) {
        bitsPerSampleOffset = nextOffset;
        nextOffset += 6;
    }
    int stripOffsetsOffset = NO_VALUE, stripByteCountsOffset = NO_VALUE;
    int xResolutionOffset, yResolutionOffset, colorMapOffset = NO_VALUE;
    int cnt = cast(int)/*64bit*/stripOffsets.length;
    if (cnt > 1) {
        stripOffsetsOffset = nextOffset;
        nextOffset += 4 * cnt;
        stripByteCountsOffset = nextOffset;
        nextOffset += 4 * cnt;
    }
    xResolutionOffset = nextOffset;
    nextOffset += 8;
    yResolutionOffset = nextOffset;
    nextOffset += 8;
    if (isColorMap) {
        colorMapOffset = nextOffset;
        nextOffset += colorMap.length * 2;
    }
    /* TIFF header */
    writeHeader();

    /* Image File Directory */
    ostr.writeShort(numberEntries);
    writeEntry(TAG_ImageWidth, TYPE_LONG, 1, imageWidth);
    writeEntry(TAG_ImageLength, TYPE_LONG, 1, imageLength);
    if (isColorMap) writeEntry(TAG_BitsPerSample, TYPE_SHORT, 1, image.depth);
    if (isRGB) writeEntry(TAG_BitsPerSample, TYPE_SHORT, 3, bitsPerSampleOffset);
    writeEntry(TAG_Compression, TYPE_SHORT, 1, COMPRESSION_NONE);
    writeEntry(TAG_PhotometricInterpretation, TYPE_SHORT, 1, photometricInterpretation);
    writeEntry(TAG_StripOffsets, TYPE_LONG, cnt, cnt > 1 ? stripOffsetsOffset : stripOffsets[0]);
    if (isRGB) writeEntry(TAG_SamplesPerPixel, TYPE_SHORT, 1, 3);
    writeEntry(TAG_RowsPerStrip, TYPE_LONG, 1, nbrRowsPerStrip);
    writeEntry(TAG_StripByteCounts, TYPE_LONG, cnt, cnt > 1 ? stripByteCountsOffset : stripByteCounts[0]);
    writeEntry(TAG_XResolution, TYPE_RATIONAL, 1, xResolutionOffset);
    writeEntry(TAG_YResolution, TYPE_RATIONAL, 1, yResolutionOffset);
    if (isColorMap) writeEntry(TAG_ColorMap, TYPE_SHORT, cast(int)/*64bit*/colorMap.length, colorMapOffset);
    /* Offset of next IFD (0 for last IFD) */
    ostr.writeInt(0);

    /* Values longer than 4 bytes Section */

    /* BitsPerSample 8,8,8 */
    if (isRGB) for (int i = 0; i < 3; i++) ostr.writeShort(8);
    if (cnt > 1) {
        for (int i = 0; i < cnt; i++) ostr.writeInt(stripOffsets[i]);
        for (int i = 0; i < cnt; i++) ostr.writeInt(stripByteCounts[i]);
    }
    /* XResolution and YResolution set to 300 dpi */
    for (int i = 0; i < 2; i++) {
        ostr.writeInt(300);
        ostr.writeInt(1);
    }
    /* ColorMap */
    if (isColorMap) for (int i = 0; i < colorMap.length; i++) ostr.writeShort(colorMap[i]);

    /* Image Data */
    ostr.write(data);
}

void writeEntry(short tag, int type, int count, int value) {
    ostr.writeShort(tag);
    ostr.writeShort(type);
    ostr.writeInt(count);
    ostr.writeInt(value);
}

void writeHeader() {
    /* little endian */
    ostr.write(0x49);
    ostr.write(0x49);

    /* TIFF identifier */
    ostr.writeShort(42);
    /*
    * Offset of the first IFD is chosen to be 8.
    * It is word aligned and immediately after this header.
    */
    ostr.writeInt(8);
}

void writeToStream(LEDataOutputStream byteStream) {
    ostr = byteStream;
    int photometricInterpretation = -1;

    /* Scanline pad must be 1 */
    if (image.scanlinePad !is 1) SWT.error(SWT.ERROR_UNSUPPORTED_FORMAT);
    switch (image.depth) {
        case 1: {
            /* Palette must be black and white or white and black */
            PaletteData palette = image.palette;
            RGB[] rgbs = palette.colors;
            if (palette.isDirect || rgbs is null || rgbs.length !is 2) SWT.error(SWT.ERROR_UNSUPPORTED_FORMAT);
            RGB rgb0 = rgbs[0];
            RGB rgb1 = rgbs[1];
            if (!(rgb0.red is rgb0.green && rgb0.green is rgb0.blue &&
                rgb1.red is rgb1.green && rgb1.green is rgb1.blue &&
                ((rgb0.red is 0x0 && rgb1.red is 0xFF) || (rgb0.red is 0xFF && rgb1.red is 0x0)))) {
                SWT.error(SWT.ERROR_UNSUPPORTED_FORMAT);
            }
            /* 0 means a color index of 0 is imaged as white */
            photometricInterpretation = image.palette.colors[0].red is 0xFF ? 0 : 1;
            break;
        }
        case 4:
        case 8: {
            photometricInterpretation = 3;
            break;
        }
        case 24: {
            photometricInterpretation = 2;
            break;
        }
        default: {
            SWT.error(SWT.ERROR_UNSUPPORTED_FORMAT);
        }
    }
    write(photometricInterpretation);
}

}
