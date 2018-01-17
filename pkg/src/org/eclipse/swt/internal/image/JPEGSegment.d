/*******************************************************************************
 * Copyright (c) 2000, 2003 IBM Corporation and others.
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
module org.eclipse.swt.internal.image.JPEGSegment;

import org.eclipse.swt.internal.image.LEDataOutputStream;


class JPEGSegment {
    public byte[] reference;

    this() {
    }

    public this(byte[] reference) {
        this.reference = reference;
    }

    public int signature() {
        return 0;
    }

    public bool verify() {
        return getSegmentMarker() is signature();
    }

    public int getSegmentMarker() {
        return ((reference[0] & 0xFF) << 8 | (reference[1] & 0xFF));
    }

    public void setSegmentMarker(int marker) {
        reference[0] = cast(byte)((marker & 0xFF00) >> 8);
        reference[1] = cast(byte)(marker & 0xFF);
    }

    public int getSegmentLength() {
        return ((reference[2] & 0xFF) << 8 | (reference[3] & 0xFF));
    }

    public void setSegmentLength(int length) {
        reference[2] = cast(byte)((length & 0xFF00) >> 8);
        reference[3] = cast(byte)(length & 0xFF);
    }

    public bool writeToStream(LEDataOutputStream byteStream) {
        try {
            byteStream.write(reference);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
