/*******************************************************************************
 * Copyright (c) 2000, 2006 IBM Corporation and others.
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
module org.eclipse.swt.internal.image.PngLzBlockReader;

import org.eclipse.swt.internal.image.PngDecodingDataStream;
import org.eclipse.swt.internal.image.PngHuffmanTables;

public class PngLzBlockReader {
    bool isLastBlock;
    byte compressionType;
    int uncompressedBytesRemaining;
    PngDecodingDataStream stream;
    PngHuffmanTables huffmanTables;

    byte[] window;
    int windowIndex;
    int copyIndex;
    int copyBytesRemaining;

    static const int UNCOMPRESSED = 0;
    static const int COMPRESSED_FIXED = 1;
    static const int COMPRESSED_DYNAMIC = 2;

    static const int END_OF_COMPRESSED_BLOCK = 256;
    static const int FIRST_LENGTH_CODE = 257;
    static const int LAST_LENGTH_CODE = 285;
    static const int FIRST_DISTANCE_CODE = 1;
    static const int LAST_DISTANCE_CODE = 29;
    static const int FIRST_CODE_LENGTH_CODE = 4;
    static const int LAST_CODE_LENGTH_CODE = 19;

    static const int[] lengthBases = [
        3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27,
        31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258
    ];
    static const int[] extraLengthBits = [
        0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2,
        3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0,
    ];
    static const int[] distanceBases = [
        1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129,
        193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097,
        6145, 8193, 12289, 16385, 24577,
    ];
    static const int[] extraDistanceBits = [
        0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7,  7,
        8,  8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13,
    ];


this(PngDecodingDataStream stream) {
    this.stream = stream;
    isLastBlock = false;
}

void setWindowSize(int windowSize) {
    window = new byte[windowSize];
}

void readNextBlockHeader()  {
    isLastBlock = stream.getNextIdatBit() !is 0;
    compressionType = cast(byte)(stream.getNextIdatBits(2) & 0xFF);
    if (compressionType > 2) stream.error();

    if (compressionType is UNCOMPRESSED) {
        byte b1 = stream.getNextIdatByte();
        byte b2 = stream.getNextIdatByte();
        byte b3 = stream.getNextIdatByte();
        byte b4 = stream.getNextIdatByte();
        if (b1 !is ~b3 || b2 !is ~b4) stream.error();
        uncompressedBytesRemaining = (b1 & 0xFF) | ((b2 & 0xFF) << 8);
    } else if (compressionType is COMPRESSED_DYNAMIC) {
        huffmanTables = PngHuffmanTables.getDynamicTables(stream);
    } else {
        huffmanTables = PngHuffmanTables.getFixedTables();
    }
}

byte getNextByte()  {
    if (compressionType is UNCOMPRESSED) {
        if (uncompressedBytesRemaining is 0) {
            readNextBlockHeader();
            return getNextByte();
        }
        uncompressedBytesRemaining--;
        return stream.getNextIdatByte();
    } else {
        byte value = getNextCompressedByte();
        if (value is END_OF_COMPRESSED_BLOCK) {
            if (isLastBlock) stream.error();
            readNextBlockHeader();
            return getNextByte();
        } else {
            return value;
        }
    }
}

private void assertBlockAtEnd()  {
    if (compressionType is UNCOMPRESSED) {
        if (uncompressedBytesRemaining > 0) stream.error();
    } else if (copyBytesRemaining > 0 ||
        (huffmanTables.getNextLiteralValue(stream) !is END_OF_COMPRESSED_BLOCK))
    {
        stream.error();
    }
}
void assertCompressedDataAtEnd()  {
    assertBlockAtEnd();
    while (!isLastBlock) {
        readNextBlockHeader();
        assertBlockAtEnd();
    }
}

private byte getNextCompressedByte()  {
    if (copyBytesRemaining > 0) {
        byte value = window[copyIndex];
        window[windowIndex] = value;
        copyBytesRemaining--;

        copyIndex++;
        windowIndex++;
        if (copyIndex is window.length) copyIndex = 0;
        if (windowIndex is window.length) windowIndex = 0;

        return value;
    }

    int value = huffmanTables.getNextLiteralValue(stream);
    if (value < END_OF_COMPRESSED_BLOCK) {
        window[windowIndex] = cast(byte) (value & 0xFF);
        windowIndex++;
        if (windowIndex >= window.length) windowIndex = 0;
        return cast(byte) (value & 0xFF);
    } else if (value is END_OF_COMPRESSED_BLOCK) {
        readNextBlockHeader();
        return getNextByte();
    } else if (value <= LAST_LENGTH_CODE) {
        int extraBits = extraLengthBits[value - FIRST_LENGTH_CODE];
        int length = lengthBases[value - FIRST_LENGTH_CODE];
        if (extraBits > 0) {
            length += stream.getNextIdatBits(extraBits);
        }

        value = huffmanTables.getNextDistanceValue(stream);
        if (value > LAST_DISTANCE_CODE) stream.error();
        extraBits = extraDistanceBits[value];
        int distance = distanceBases[value];
        if (extraBits > 0) {
            distance += stream.getNextIdatBits(extraBits);
        }

        copyIndex = windowIndex - distance;
        if (copyIndex < 0) copyIndex += window.length;

        copyBytesRemaining = length;
        return getNextCompressedByte();
    } else {
        stream.error();
        return 0;
    }
}

}
