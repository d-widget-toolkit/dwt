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
module org.eclipse.swt.internal.image.PngChunkReader;


import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.image.LEDataInputStream;
import org.eclipse.swt.internal.image.PngFileReadState;
import org.eclipse.swt.internal.image.PngIhdrChunk;
import org.eclipse.swt.internal.image.PngPlteChunk;
import org.eclipse.swt.internal.image.PngTrnsChunk;
import org.eclipse.swt.internal.image.PngChunk;

public class PngChunkReader {
    LEDataInputStream inputStream;
    PngFileReadState readState;
    PngIhdrChunk headerChunk;
    PngPlteChunk paletteChunk;

this(LEDataInputStream inputStream) {
    this.inputStream = inputStream;
    readState = new PngFileReadState();
    headerChunk = null;
}

PngIhdrChunk getIhdrChunk() {
    if (headerChunk is null) {
        PngChunk chunk = PngChunk.readNextFromStream(inputStream);
        if (chunk is null) SWT.error(SWT.ERROR_INVALID_IMAGE);
        if(( headerChunk = cast(PngIhdrChunk) chunk ) !is null ){
            headerChunk.validate(readState, null);
        }
        else{
            SWT.error(SWT.ERROR_INVALID_IMAGE);
        }
    }
    return headerChunk;
}

PngChunk readNextChunk() {
    if (headerChunk is null) return getIhdrChunk();

    PngChunk chunk = PngChunk.readNextFromStream(inputStream);
    if (chunk is null) SWT.error(SWT.ERROR_INVALID_IMAGE);
    switch (chunk.getChunkType()) {
        case PngChunk.CHUNK_tRNS:
            (cast(PngTrnsChunk) chunk).validate(readState, headerChunk, paletteChunk);
            break;
        case PngChunk.CHUNK_PLTE:
            chunk.validate(readState, headerChunk);
            paletteChunk = cast(PngPlteChunk) chunk;
            break;
        default:
            chunk.validate(readState, headerChunk);
    }
    if (readState.readIDAT && !(chunk.getChunkType() is PngChunk.CHUNK_IDAT)) {
        readState.readPixelData = true;
    }
    return chunk;
}

bool readPixelData() {
    return readState.readPixelData;
}

bool hasMoreChunks() {
    return !readState.readIEND;
}

}
