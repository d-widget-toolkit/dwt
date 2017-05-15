/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
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
module org.eclipse.swt.internal.image.PngFileReadState;


class PngFileReadState {
    bool readIHDR;
    bool readPLTE;
    bool readIDAT;
    bool readIEND;

    // Non - critical chunks
    bool readTRNS;

    // Set to true after IDATs have been read.
    bool readPixelData;
}
