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
module org.eclipse.swt.internal.image.JPEGScanHeader;

import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.image.JPEGVariableSizeSegment;
import org.eclipse.swt.internal.image.LEDataInputStream;
import org.eclipse.swt.internal.image.JPEGFileFormat;
import java.lang.all;

final class JPEGScanHeader : JPEGVariableSizeSegment {
    public int[][] componentParameters;

public this(byte[] reference) {
    super(reference);
}

public this(LEDataInputStream byteStream) {
    super(byteStream);
    initializeComponentParameters();
}

public int getApproxBitPositionHigh() {
    return reference[(2 * getNumberOfImageComponents()) + 7] >> 4;
}

public int getApproxBitPositionLow() {
    return reference[(2 * getNumberOfImageComponents()) + 7] & 0xF;
}

public int getEndOfSpectralSelection() {
    return reference[(2 * getNumberOfImageComponents()) + 6];
}

public int getNumberOfImageComponents() {
    return reference[4];
}

public int getStartOfSpectralSelection() {
    return reference[(2 * getNumberOfImageComponents()) + 5];
}

/* Used when decoding. */
void initializeComponentParameters() {
    int compCount = getNumberOfImageComponents();
    componentParameters = null;
    for (int i = 0; i < compCount; i++) {
        int ofs = 5 + i * 2;
        int cid = reference[ofs] & 0xFF;
        int dc = (reference[ofs + 1] & 0xFF) >> 4;
        int ac = reference[ofs + 1] & 0xF;
        if (componentParameters.length <= cid) {
            int[][] newParams = new int[][](cid + 1);
            System.arraycopy(componentParameters, 0, newParams, 0, componentParameters.length);
            componentParameters = newParams;
        }
        componentParameters[cid] = [ dc, ac ];
    }
}

/* Used when encoding. */
public void initializeContents() {
    int compCount = getNumberOfImageComponents();
    int[][] compSpecParams = componentParameters;
    if (compCount is 0 || compCount !is compSpecParams.length) {
        SWT.error(SWT.ERROR_INVALID_IMAGE);
    }
    for (int i = 0; i < compCount; i++) {
        int ofs = i * 2 + 5;
        int[] compParams = compSpecParams[i];
        reference[ofs] = cast(byte)(i + 1);
        reference[ofs + 1] = cast(byte)(compParams[0] * 16 + compParams[1]);
    }
}

public void setEndOfSpectralSelection(int anInteger) {
    reference[(2 * getNumberOfImageComponents()) + 6] = cast(byte)anInteger;
}

public void setNumberOfImageComponents(int anInteger) {
    reference[4] = cast(byte)(anInteger & 0xFF);
}

public void setStartOfSpectralSelection(int anInteger) {
    reference[(2 * getNumberOfImageComponents()) + 5] = cast(byte)anInteger;
}

public override int signature() {
    return JPEGFileFormat.SOS;
}

public bool verifyProgressiveScan() {
    int start = getStartOfSpectralSelection();
    int end = getEndOfSpectralSelection();
    int low = getApproxBitPositionLow();
    int high = getApproxBitPositionHigh();
    int count = getNumberOfImageComponents();
    if ((start is 0 && end is 00) || (start <= end && end <= 63)) {
        if (low <= 13 && high <= 13 && (high is 0 || high is low + 1)) {
            return start is 0 || (start > 0 && count is 1);
        }
    }
    return false;
}

public bool isACProgressiveScan() {
    return getStartOfSpectralSelection() !is 0 && getEndOfSpectralSelection() !is 0;
}

public bool isDCProgressiveScan() {
    return getStartOfSpectralSelection() is 0 && getEndOfSpectralSelection() is 0;
}

public bool isFirstScan() {
    return getApproxBitPositionHigh() is 0;
}

}
