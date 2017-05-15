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
module org.eclipse.swt.internal.image.PngIdatChunk;


import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.image.PngFileReadState;
import org.eclipse.swt.internal.image.PngIhdrChunk;
import org.eclipse.swt.internal.image.PngChunk;
import java.lang.all;

class PngIdatChunk : PngChunk {

    static const int HEADER_BYTES_LENGTH = 2;
    static const int ADLER_FIELD_LENGTH = 4;
    static const int HEADER_BYTE1_DATA_OFFSET = DATA_OFFSET + 0;
    static const int HEADER_BYTE2_DATA_OFFSET = DATA_OFFSET + 1;
    static const int ADLER_DATA_OFFSET = DATA_OFFSET + 2; // plus variable compressed data length

this(byte headerByte1, byte headerByte2, byte[] data, int adler) {
    super(cast(int)/*64bit*/data.length + HEADER_BYTES_LENGTH + ADLER_FIELD_LENGTH);
    setType(TYPE_IDAT);
    reference[HEADER_BYTE1_DATA_OFFSET] = headerByte1;
    reference[HEADER_BYTE2_DATA_OFFSET] = headerByte2;
    System.arraycopy(data, 0, reference, DATA_OFFSET, data.length);
    setInt32(ADLER_DATA_OFFSET, adler);
    setCRC(computeCRC());
}

this(byte[] reference) {
    super(reference);
}

override int getChunkType() {
    return CHUNK_IDAT;
}

/**
 * Answer whether the chunk is a valid IDAT chunk.
 */
override void validate(PngFileReadState readState, PngIhdrChunk headerChunk) {
    if (!readState.readIHDR
        || (headerChunk.getMustHavePalette() && !readState.readPLTE)
        || readState.readIEND)
    {
        SWT.error(SWT.ERROR_INVALID_IMAGE);
    } else {
        readState.readIDAT = true;
    }

    super.validate(readState, headerChunk);
}

byte getDataByteAtOffset(int offset) {
    return reference[DATA_OFFSET + offset];
}

}
