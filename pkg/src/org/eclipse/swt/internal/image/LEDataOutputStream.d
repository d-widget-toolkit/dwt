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
module org.eclipse.swt.internal.image.LEDataOutputStream;


import java.io.OutputStream;

final class LEDataOutputStream : OutputStream {

    alias OutputStream.write write;

    OutputStream ostr;

public this(OutputStream output) {
    this.ostr = output;
}
/**
 * Write the specified number of bytes of the given byte array,
 * starting at the specified offset, to the output stream.
 */
public override void write(in byte[] b, ptrdiff_t off, ptrdiff_t len) {
    ostr.write(b, off, len);
}
/**
 * Write the given byte to the output stream.
 */
public override void write(int b)  {
    ostr.write(b);
}
/**
 * Write the given byte to the output stream.
 */
public void writeByte(byte b) {
    ostr.write(b);
}
/**
 * Write the four bytes of the given integer
 * to the output stream.
 */
public void writeInt(int theInt) {
    ostr.write(theInt & 0xFF);
    ostr.write((theInt >> 8) & 0xFF);
    ostr.write((theInt >> 16) & 0xFF);
    ostr.write((theInt >> 24) & 0xFF);
}
/**
 * Write the two bytes of the given short
 * to the output stream.
 */
public void writeShort(int theShort) {
    ostr.write(theShort & 0xFF);
    ostr.write((theShort >> 8) & 0xFF);
}
}
