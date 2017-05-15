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
module org.eclipse.swt.internal.image.PngPlteChunk;

import java.lang.all;


import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.internal.image.PngChunk;
import org.eclipse.swt.internal.image.PngFileReadState;
import org.eclipse.swt.internal.image.PngIhdrChunk;


class PngPlteChunk : PngChunk {

    int paletteSize;

this(PaletteData palette) {
    super(cast(int)/*64bit*/palette.getRGBs().length * 3);
    paletteSize = length / 3;
    setType(TYPE_PLTE);
    setPaletteData(palette);
    setCRC(computeCRC());
}

this(byte[] reference){
    super(reference);
    paletteSize = length / 3;
}

override int getChunkType() {
    return CHUNK_PLTE;
}

/**
 * Get the number of colors in this palette.
 */
int getPaletteSize() {
    return paletteSize;
}

/**
 * Get a PaletteData object representing the colors
 * stored in this PLTE chunk.
 * The result should be cached as the PLTE chunk
 * does not store the palette data created.
 */
PaletteData getPaletteData() {
    RGB[] rgbs = new RGB[paletteSize];
//  int start = DATA_OFFSET;
//  int end = DATA_OFFSET + length;
    for (int i = 0; i < rgbs.length; i++) {
        int offset = DATA_OFFSET + (i * 3);
        int red = reference[offset] & 0xFF;
        int green = reference[offset + 1] & 0xFF;
        int blue = reference[offset + 2] & 0xFF;
        rgbs[i] = new RGB(red, green, blue);
    }
    return new PaletteData(rgbs);
}

/**
 * Set the data of a PLTE chunk to the colors
 * stored in the specified PaletteData object.
 */
void setPaletteData(PaletteData palette) {
    RGB[] rgbs = palette.getRGBs();
    for (int i = 0; i < rgbs.length; i++) {
        int offset = DATA_OFFSET + (i * 3);
        reference[offset] = cast(byte) rgbs[i].red;
        reference[offset + 1] = cast(byte) rgbs[i].green;
        reference[offset + 2] = cast(byte) rgbs[i].blue;
    }
}

/**
 * Answer whether the chunk is a valid PLTE chunk.
 */
override void validate(PngFileReadState readState, PngIhdrChunk headerChunk) {
    // A PLTE chunk is invalid if no IHDR has been read or if any PLTE,
    // IDAT, or IEND chunk has been read.
    if (!readState.readIHDR
        || readState.readPLTE
        || readState.readTRNS
        || readState.readIDAT
        || readState.readIEND)
    {
        SWT.error(SWT.ERROR_INVALID_IMAGE);
    } else {
        readState.readPLTE = true;
    }

    super.validate(readState, headerChunk);

    // Palettes cannot be included in grayscale images.
    //
    // Note: just ignore the palette.
//  if (!headerChunk.getCanHavePalette()) SWT.error(SWT.ERROR_INVALID_IMAGE);

    // Palette chunks' data fields must be event multiples
    // of 3. Each 3-byte group represents an RGB value.
    if (getLength() % 3 !is 0) SWT.error(SWT.ERROR_INVALID_IMAGE);   

    // Palettes cannot have more entries than 2^bitDepth
    // where bitDepth is the bit depth of the image given
    // in the IHDR chunk.
    if (1 << headerChunk.getBitDepth() < paletteSize) {
        SWT.error(SWT.ERROR_INVALID_IMAGE);
    }

    // Palettes cannot have more than 256 entries.
    if (256 < paletteSize) SWT.error(SWT.ERROR_INVALID_IMAGE);
}

override String contributeToString() {
    return Format("\n\tPalette size:{}", paletteSize );
}

}
