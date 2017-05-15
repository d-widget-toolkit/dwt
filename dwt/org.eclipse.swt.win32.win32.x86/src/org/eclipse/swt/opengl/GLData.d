/*******************************************************************************
 * Copyright (c) 2005, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D Programming Language:
 *     John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module org.eclipse.swt.opengl.GLData;

import java.lang.all;

/**
 * The GLData class is a device-independent description
 * of the pixel format attributes of a GL drawable.
 *
 * @see GLCanvas
 * @see <a href="http://www.eclipse.org/swt/snippets/#opengl">OpenGL snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.2
 */

public class GLData {
    /**
     * Specifies a double-buffered surface.  During context
     * creation, only double-buffered formats are considered
     * when set to true.
     */
    public bool doubleBuffer;

    /**
     * Specifies a stereo surface.  During context creation,
     * only stereo formats are considered when set to true.
     */
    public bool stereo;

    /**
     * The size in bits of the color buffer's red channel.
     * During context creation, this specifies the minimum
     * required red bits.
     */
    public int redSize;

    /**
     * The size in bits of the color buffer's green channel.
     * During context creation, this specifies the minimum
     * required green bits.
     */
    public int greenSize;

    /**
     * The size in bits of the color buffer's blue channel.
     * During context creation, this specifies the minimum
     * required blue bits.
     */
    public int blueSize;

    /**
     * The size in bits of the color buffer's alpha channel.
     * During context creation, this specifies the minimum
     * required alpha bits.
     */
    public int alphaSize;

    /**
     * The size in bits of the depth buffer.  During context
     * creation, the smallest depth buffer of at least the
     * specified value is preferred, or zero for no depth
     * buffer.
     */
    public int depthSize;

    /**
     * The desired number of stencil bitplanes.  During
     * context creation, the smallest stencil buffer of at
     * least the specified value is preferred, or zero for
     * no stencil buffer.
     */
    public int stencilSize;

    /**
     * The size in bits of the accumulation buffer's red
     * channel. During context creation, this specifies the
     * minimum required red bits.
     */
    public int accumRedSize;

    /**
     * The size in bits of the accumulation buffer's green
     * channel. During context creation, this specifies the
     * minimum required green bits.
     */
    public int accumGreenSize;

    /**
     * The size in bits of the accumulation buffer's blue
     * channel. During context creation, this specifies the
     * minimum required blue bits.
     */
    public int accumBlueSize;

    /**
     * The size in bits of the accumulation buffer's alpha
     * channel. During context creation, this specifies the
     * minimum required alpha bits.
     */
    public int accumAlphaSize;

    /**
     * The number of multisample buffers used by this context.
     * During context creation, this specifies the minimum
     * number of multisample buffers requested.
     */
    public int sampleBuffers;

    /**
     * The number of samples accepted in the multisample buffer.
     * During creation, pixel formats with the smallest number of
     * samples that meets or exceeds the specified minimum number
     * are preferred.
     */
    public int samples;

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the data
 */
override public String toString() {
    String string = doubleBuffer ? "doubleBuffer," : "";
    string ~= stereo ? "stereo," : "";
    string ~= "r:" ~     String_valueOf(redSize)  ~ " g:" ~ String_valueOf(greenSize) ~
              " b:" ~    String_valueOf(blueSize) ~ " a:" ~ String_valueOf(alphaSize) ~ "," ~
              "depth:" ~ String_valueOf(depthSize) ~ ",stencil:" ~ String_valueOf(stencilSize) ~
              ",accum r:" ~ String_valueOf(accumRedSize) ~ "g:" ~ String_valueOf(accumGreenSize) ~
              "b:" ~ String_valueOf(accumBlueSize) ~ "a:" ~ String_valueOf(accumAlphaSize) ~
              ",sampleBuffers:" ~ String_valueOf(sampleBuffers) ~ ",samples:" ~ String_valueOf(samples);
    return string;
}
}
