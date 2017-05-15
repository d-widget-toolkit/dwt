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
module org.eclipse.swt.internal.image.PngInputStream;

import java.io.InputStream;
import org.eclipse.swt.internal.image.PngIdatChunk;
import org.eclipse.swt.internal.image.PngChunkReader;
import org.eclipse.swt.internal.image.PngChunk;

import java.lang.all;

public class PngInputStream : InputStream {

    alias InputStream.read read;

    PngChunkReader reader;
    PngChunk chunk;
    int offset, length;

    const static int DATA_OFFSET = 8;

public this(PngIdatChunk chunk, PngChunkReader reader) {
    this.chunk = chunk;
    this.reader = reader;
    length = chunk.getLength();
    offset = 0;
}

private bool checkChunk()  {
    while (offset is length) {
        chunk = reader.readNextChunk();
        if (chunk is null) throw new IOException("no data");
        if (chunk.getChunkType() is PngChunk.CHUNK_IEND) return false;
        if (chunk.getChunkType() !is PngChunk.CHUNK_IDAT) throw new IOException("");
        length = chunk.getLength();
        offset = 0;
    }
    return true;
}

public override void close()  {
    chunk = null;
}

public override int read()  {
    if (chunk is null) throw new IOException("");
    if (offset is length && !checkChunk()) return -1;
    int b = chunk.reference[DATA_OFFSET + offset] & 0xFF;
    offset++;
    return b;
}

public override ptrdiff_t read(byte[] b, ptrdiff_t off, ptrdiff_t len)  {
    if (chunk is null) throw new IOException("");
    if (offset is length && !checkChunk()) return -1;
    len = Math.min(len, length - offset);
    System.arraycopy(chunk.reference, DATA_OFFSET + offset, b, off, len);
    offset += len;
    return len;
}
}
