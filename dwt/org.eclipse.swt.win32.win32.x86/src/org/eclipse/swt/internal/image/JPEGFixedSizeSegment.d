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
module org.eclipse.swt.internal.image.JPEGFixedSizeSegment;


import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.image.JPEGSegment;
import org.eclipse.swt.internal.image.LEDataInputStream;



abstract class JPEGFixedSizeSegment : JPEGSegment {

    public this() {
        reference = new byte[fixedSize()];
        setSegmentMarker(signature());
    }

    public this(byte[] reference) {
        super(reference);
    }

    public this(LEDataInputStream byteStream) {
        reference = new byte[fixedSize()];
        try {
            byteStream.read(reference);
        } catch (Exception e) {
            SWT.error(SWT.ERROR_IO, e);
        }
    }

    abstract public int fixedSize();

    public override int getSegmentLength() {
        return fixedSize() - 2;
    }

    public override void setSegmentLength(int length) {
    }
}
