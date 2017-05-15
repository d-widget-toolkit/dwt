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
module org.eclipse.swt.internal.image.PngChunk;


import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.image.LEDataInputStream;
import org.eclipse.swt.internal.image.PngFileReadState;
import org.eclipse.swt.internal.image.PngIhdrChunk;
import org.eclipse.swt.internal.image.PngPlteChunk;
import org.eclipse.swt.internal.image.PngIdatChunk;
import org.eclipse.swt.internal.image.PngIendChunk;
import org.eclipse.swt.internal.image.PngTrnsChunk;
import java.lang.all;


class PngChunk {
    byte[] reference;

    static const int LENGTH_OFFSET = 0;
    static const int TYPE_OFFSET = 4;
    static const int DATA_OFFSET = 8;

    static const int TYPE_FIELD_LENGTH = 4;
    static const int LENGTH_FIELD_LENGTH = 4;
    static const int MIN_LENGTH = 12;

    static const int CHUNK_UNKNOWN = -1;
    // Critical chunks.
    static const int CHUNK_IHDR = 0;
    static const int CHUNK_PLTE = 1;
    static const int CHUNK_IDAT = 2;
    static const int CHUNK_IEND = 3;
    // Non-critical chunks.
    static const int CHUNK_tRNS = 5;

    static const byte[] TYPE_IHDR = cast(byte[])"IHDR";//{(byte) 'I', (byte) 'H', (byte) 'D', (byte) 'R'};
    static const byte[] TYPE_PLTE = cast(byte[])"PLTE";//{(byte) 'P', (byte) 'L', (byte) 'T', (byte) 'E'};
    static const byte[] TYPE_IDAT = cast(byte[])"IDAT";//{(byte) 'I', (byte) 'D', (byte) 'A', (byte) 'T'};
    static const byte[] TYPE_IEND = cast(byte[])"IEND";//{(byte) 'I', (byte) 'E', (byte) 'N', (byte) 'D'};
    static const byte[] TYPE_tRNS = cast(byte[])"tRNS";//{(byte) 't', (byte) 'R', (byte) 'N', (byte) 'S'};

    mixin(gshared!(`private static int[] _CRC_TABLE = null;`));
    static int[] CRC_TABLE() {
        if (!_CRC_TABLE) static_this();
        return _CRC_TABLE;
    }
    private static void static_this() {
        _CRC_TABLE = new int[256];
        for (int i = 0; i < 256; i++) {
            _CRC_TABLE[i] = i;
            for (int j = 0; j < 8; j++) {
                if ((_CRC_TABLE[i] & 0x1) is 0) {
                    _CRC_TABLE[i] = (_CRC_TABLE[i] >> 1) & 0x7FFFFFFF;
                } else {
                    _CRC_TABLE[i] = 0xEDB88320 ^ ((_CRC_TABLE[i] >> 1) & 0x7FFFFFFF);
                }
            }
        }
    }

    int length;

/**
 * Construct a PngChunk using the reference bytes
 * given.
 */
this(byte[] reference) {
    setReference(reference);
    if (reference.length < LENGTH_OFFSET + LENGTH_FIELD_LENGTH) SWT.error(SWT.ERROR_INVALID_IMAGE);
    length = getInt32(LENGTH_OFFSET);
}

/**
 * Construct a PngChunk with the specified number of
 * data bytes.
 */
this(int dataLength) {
    this(new byte[MIN_LENGTH + dataLength]);
    setLength(dataLength);
}

/**
 * Get the PngChunk's reference byteArray;
 */
byte[] getReference() {
    return reference;
}

/**
 * Set the PngChunk's reference byteArray;
 */
void setReference(byte[] reference) {
    this.reference = reference;
}

/**
 * Get the 16-bit integer from the reference byte
 * array at the given offset.
 */
int getInt16(int offset) {
    int answer = 0;
    answer |= (reference[offset] & 0xFF) << 8;
    answer |= (reference[offset + 1] & 0xFF);
    return answer;
}

/**
 * Set the 16-bit integer in the reference byte
 * array at the given offset.
 */
void setInt16(int offset, int value) {
    reference[offset] = cast(byte) ((value >> 8) & 0xFF);
    reference[offset + 1] = cast(byte) (value & 0xFF);
}

/**
 * Get the 32-bit integer from the reference byte
 * array at the given offset.
 */
int getInt32(int offset) {
    int answer = 0;
    answer |= (reference[offset] & 0xFF) << 24;
    answer |= (reference[offset + 1] & 0xFF) << 16;
    answer |= (reference[offset + 2] & 0xFF) << 8;
    answer |= (reference[offset + 3] & 0xFF);
    return answer;
}

/**
 * Set the 32-bit integer in the reference byte
 * array at the given offset.
 */
void setInt32(int offset, int value) {
    reference[offset] = cast(byte) ((value >> 24) & 0xFF);
    reference[offset + 1] = cast(byte) ((value >> 16) & 0xFF);
    reference[offset + 2] = cast(byte) ((value >> 8) & 0xFF);
    reference[offset + 3] = cast(byte) (value & 0xFF);
}

/**
 * Get the length of the data component of this chunk.
 * This is not the length of the entire chunk.
 */
int getLength() {
    return length;
}

/**
 * Set the length of the data component of this chunk.
 * This is not the length of the entire chunk.
 */
void setLength(int value) {
    setInt32(LENGTH_OFFSET, value);
    length = value;
}

/**
 * Get the chunk type. This is a four byte value.
 * Each byte should be an ASCII character.
 * The first byte is upper case if the chunk is critical.
 * The second byte is upper case if the chunk is publicly defined.
 * The third byte must be upper case.
 * The fourth byte is upper case if the chunk is unsafe to copy.
 * Public chunk types are defined by the PNG Development Group.
 */
byte[] getTypeBytes() {
    byte[] type = new byte[4];
    System.arraycopy(reference, TYPE_OFFSET, type, 0, TYPE_FIELD_LENGTH);
    return type;
}

/**
 * Set the chunk type. This is a four byte value.
 * Each byte should be an ASCII character.
 * The first byte is upper case if the chunk is critical.
 * The second byte is upper case if the chunk is publicly defined.
 * The third byte must be upper case.
 * The fourth byte is upper case if the chunk is unsafe to copy.
 * Public chunk types are defined by the PNG Development Group.
 */
void setType(in byte[] value) {
    if (value.length !is TYPE_FIELD_LENGTH) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    System.arraycopy!(byte)(value, 0, reference, TYPE_OFFSET, TYPE_FIELD_LENGTH);
}

/**
 * Get the chunk's data.
 */
byte[] getData() {
    int dataLength = getLength();
    if (reference.length < MIN_LENGTH + dataLength) {
        SWT.error (SWT.ERROR_INVALID_RANGE);
    }
    byte[] data = new byte[dataLength];
    System.arraycopy(reference, DATA_OFFSET, data, 0, dataLength);
    return data;
}

/**
 * Set the chunk's data.
 * This method has two side-effects.
 * 1. It will set the length field to be the length
 *    of the data array given.
 * 2. It will set the CRC field to the computed CRC
 *    value of the data array given.
 */
void setData(in byte[] data) {
    setLength(cast(int)/*64bit*/data.length);
    System.arraycopy!(byte)(data, 0, reference, DATA_OFFSET, data.length);
    setCRC(computeCRC());
}

/**
 * Get the CRC value for the chunk's data.
 * Ensure that the length field has a good
 * value before making this call.
 */
int getCRC() {
    int crcOffset = DATA_OFFSET + getLength();
    return getInt32(crcOffset);
}

/**
 * Set the CRC value for the chunk's data.
 * Ensure that the length field has a good
 * value before making this call.
 */
void setCRC(int value) {
    int crcOffset = DATA_OFFSET + getLength();
    setInt32(crcOffset, value);
}

/**
 * Get the chunk's total size including the length, type, and crc fields.
 */
int getSize() {
    return MIN_LENGTH + getLength();
}

/**
 * Compute the CRC value for the chunk's data. Answer
 * whether this value matches the value stored in the
 * chunk.
 */
bool checkCRC() {
    int crc = computeCRC();
    int storedCRC = getCRC();
    return crc is storedCRC;
}

/**
 * Answer the CRC value of chunk's data.
 */
int computeCRC() {
    int crc = 0xFFFFFFFF;
    int start = TYPE_OFFSET;
    int stop = DATA_OFFSET + getLength();
    for (int i = start; i < stop; i++) {
        int index = (crc ^ reference[i]) & 0xFF;
        crc =  CRC_TABLE[index] ^ ((crc >> 8) & 0x00FFFFFF);
    }
    return ~crc;
}

bool typeMatchesArray(in byte[] array) {
    for (int i = 0; i < TYPE_FIELD_LENGTH; i++) {
        if (reference[TYPE_OFFSET + i] !is array[i]){
            return false;
        }
    }
    return true;
}

bool isCritical() {
    char c = cast(char) getTypeBytes()[0];
    return 'A' <= c && c <= 'Z';
}

int getChunkType() {
    if (typeMatchesArray(TYPE_IHDR)) return CHUNK_IHDR;
    if (typeMatchesArray(TYPE_PLTE)) return CHUNK_PLTE;
    if (typeMatchesArray(TYPE_IDAT)) return CHUNK_IDAT;
    if (typeMatchesArray(TYPE_IEND)) return CHUNK_IEND;
    if (typeMatchesArray(TYPE_tRNS)) return CHUNK_tRNS;
    return CHUNK_UNKNOWN;
}

/**
 * Read the next PNG chunk from the input stream given.
 * If unable to read a chunk, return null.
 */
static PngChunk readNextFromStream(LEDataInputStream stream) {
    try {
        int headerLength = LENGTH_FIELD_LENGTH + TYPE_FIELD_LENGTH;
        byte[] headerBytes = new byte[headerLength];
        int result = cast(int)/*64bit*/stream.read(headerBytes, 0, headerLength);
        stream.unread(headerBytes);
        if (result !is headerLength) return null;

        PngChunk tempChunk = new PngChunk(headerBytes);

        int chunkLength = tempChunk.getSize();
        byte[] chunk = new byte[chunkLength];

        result = cast(int)/*64bit*/stream.read(chunk, 0, chunkLength);
        if (result !is chunkLength) return null;

        switch (tempChunk.getChunkType()) {
            case CHUNK_IHDR:
                return new PngIhdrChunk(chunk);
            case CHUNK_PLTE:
                return new PngPlteChunk(chunk);
            case CHUNK_IDAT:
                return new PngIdatChunk(chunk);
            case CHUNK_IEND:
                return new PngIendChunk(chunk);
            case CHUNK_tRNS:
                return new PngTrnsChunk(chunk);
            default:
                return new PngChunk(chunk);
        }
    } catch (IOException e) {
        return null;
    }
}

/**
 * Answer whether the chunk is a valid PNG chunk.
 */
void validate(PngFileReadState readState, PngIhdrChunk headerChunk) {
    if (reference.length < MIN_LENGTH) SWT.error(SWT.ERROR_INVALID_IMAGE);

    byte[] type = getTypeBytes();

    // The third character MUST be upper case.
    char c = cast(char) type[2];
    if (!('A' <= c && c <= 'Z')) SWT.error(SWT.ERROR_INVALID_IMAGE);

    // All characters must be letters.
    for (int i = 0; i < TYPE_FIELD_LENGTH; i++) {
        c = cast(char) type[i];
        if (!(('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z'))) {
            SWT.error(SWT.ERROR_INVALID_IMAGE);
        }
    }

    // The stored CRC must match the data's computed CRC.
    if (!checkCRC()) SWT.error(SWT.ERROR_INVALID_IMAGE);
}

/**
 * Provided so that subclasses can override and add
 * data to the toString() call.
 */
String contributeToString() {
    return "";
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the event
 */
public override String toString() {
    String buffer = Format( "{\n\tLength: {}\n\tType: {}{}\n\tCRC: {:X}\n}",
        getLength(),
        cast(String) getTypeBytes(),
        contributeToString(),
        getCRC());
    return buffer;
}

}
