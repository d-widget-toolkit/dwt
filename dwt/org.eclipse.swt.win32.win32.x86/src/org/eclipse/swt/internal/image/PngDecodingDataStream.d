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
module org.eclipse.swt.internal.image.PngDecodingDataStream;


import java.io.InputStream;

import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.image.PngLzBlockReader;

public class PngDecodingDataStream : InputStream {

    alias InputStream.read read;

    InputStream stream;
    byte currentByte;
    int nextBitIndex;

    PngLzBlockReader lzBlockReader;
    int adlerValue;

    static const int PRIME = 65521;
    static const int MAX_BIT = 7;

this(InputStream stream) {
    super();
    this.stream = stream;
    nextBitIndex = MAX_BIT + 1;
    adlerValue = 1;
    lzBlockReader = new PngLzBlockReader(this);
    readCompressedDataHeader();
    lzBlockReader.readNextBlockHeader();
}

/**
 * This method should be called when the image decoder thinks
 * that all of the compressed image data has been read. This
 * method will ensure that the next data value is an end of
 * block marker. If there are more blocks after this one,
 * the method will read them and ensure that they are empty.
 */
void assertImageDataAtEnd() {
    lzBlockReader.assertCompressedDataAtEnd();
}

public override void close() {
    assertImageDataAtEnd();
    checkAdler();
}

int getNextIdatBits(int length) {
    int value = 0;
    for (int i = 0; i < length; i++) {
        value |= (getNextIdatBit() << i);
    }
    return value;
}

int getNextIdatBit() {
    if (nextBitIndex > MAX_BIT) {
        currentByte = getNextIdatByte();
        nextBitIndex = 0;
    }
    return (currentByte & (1 << nextBitIndex)) >> nextBitIndex++;
}

byte getNextIdatByte() {
    byte nextByte = cast(byte)stream.read();
    nextBitIndex = MAX_BIT + 1;
    return nextByte;
}

void updateAdler(byte value) {
    int low = adlerValue & 0xFFFF;
    int high = (adlerValue >> 16) & 0xFFFF;
    int valueInt = value & 0xFF;
    low = (low + valueInt) % PRIME;
    high = (low + high) % PRIME;
    adlerValue = (high << 16) | low;
}

public override int read() {
    byte nextDecodedByte = lzBlockReader.getNextByte();
    updateAdler(nextDecodedByte);
    return nextDecodedByte & 0xFF;
}

public override ptrdiff_t read(byte[] buffer, ptrdiff_t off, ptrdiff_t len) {
    for (int i = 0; i < len; i++) {
        int b = read();
        if (b is -1) return i;
        buffer[off + i] = cast(byte)b;
    }
    return len;
}

void error() {
    SWT.error(SWT.ERROR_INVALID_IMAGE);
}

private void readCompressedDataHeader() {
    byte headerByte1 = getNextIdatByte();
    byte headerByte2 = getNextIdatByte();

    int number = ((headerByte1 & 0xFF) << 8) | (headerByte2 & 0xFF);
    if (number % 31 !is 0) error();

    int compressionMethod = headerByte1 & 0x0F;
    if (compressionMethod !is 8) error();

    int windowSizeHint = (headerByte1 & 0xF0) >> 4;
    if (windowSizeHint > 7) error();
    int windowSize = (1 << (windowSizeHint + 8));
    lzBlockReader.setWindowSize(windowSize);

    int dictionary = (headerByte2 & (1 << 5));
    if (dictionary !is 0) error();

//  int compressionLevel = (headerByte2 & 0xC0) >> 6;
}

void checkAdler() {
    int storedAdler = 0;
    storedAdler |= ((getNextIdatByte() & 0xFF) << 24);
    storedAdler |= ((getNextIdatByte() & 0xFF) << 16);
    storedAdler |= ((getNextIdatByte() & 0xFF) << 8);
    storedAdler |=  (getNextIdatByte() & 0xFF);
    if (storedAdler !is adlerValue) error();
}

}
