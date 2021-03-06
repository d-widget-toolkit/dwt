/*******************************************************************************
 * Copyright (c) 2000, 2013 IBM Corporation and others.
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
module org.eclipse.swt.graphics.RGB;

public import org.eclipse.swt.internal.SerializableCompatibility;

import org.eclipse.swt.SWT;
import java.lang.all;

/**
 * Instances of this class are descriptions of colors in
 * terms of the primary additive color model (red, green and
 * blue). A color may be described in terms of the relative
 * intensities of these three primary colors. The brightness
 * of each color is specified by a value in the range 0 to 255,
 * where 0 indicates no color (blackness) and 255 indicates
 * maximum intensity.
 * <p>
 * The hashCode() method in this class uses the values of the public
 * fields to compute the hash value. When storing instances of the
 * class in hashed collections, do not modify these fields after the
 * object has been inserted.
 * </p>
 * <p>
 * Application code does <em>not</em> need to explicitly release the
 * resources managed by each instance when those instances are no longer
 * required, and thus no <code>dispose()</code> method is provided.
 * </p>
 *
 * @see Color
 * @see <a href="http://www.eclipse.org/swt/snippets/#color">Color and RGB snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public final class RGB : SerializableCompatibility {
  package:
    /**
     * the red component of the RGB
     */
    public int red;

    /**
     * the green component of the RGB
     */
    public int green;

    /**
     * the blue component of the RGB
     */
    public int blue;

    //static final long serialVersionUID = 3258415023461249074L;

/**
 * Constructs an instance of this class with the given
 * red, green and blue values.
 *
 * @param red the red component of the new instance
 * @param green the green component of the new instance
 * @param blue the blue component of the new instance
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the red, green or blue argument is not between 0 and 255</li>
 * </ul>
 */
public this (int red, int green, int blue) {
    if ((red > 255) || (red < 0) ||
        (green > 255) || (green < 0) ||
        (blue > 255) || (blue < 0))
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    this.red = red;
    this.green = green;
    this.blue = blue;
}

/**
* Constructs an instance of this class with the given
* hue, saturation, and brightness.
*
* @param hue the hue value for the HSB color (from 0 to 360)
* @param saturation the saturation value for the HSB color (from 0 to 1)
* @param brightness the brightness value for the HSB color (from 0 to 1)
*
* @exception IllegalArgumentException <ul>
*    <li>ERROR_INVALID_ARGUMENT - if the hue is not between 0 and 360 or
*    the saturation or brightness is not between 0 and 1</li>
* </ul>
*
* @since 3.2
*/
public this (float hue, float saturation, float brightness) {
    if (hue < 0 || hue > 360 || saturation < 0 || saturation > 1 ||
        brightness < 0 || brightness > 1) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    float r = 0, g = 0, b = 0;
    if (saturation is 0) {
        r = g = b = brightness;
    } else {
        if (hue is 360) hue = 0;
        hue /= 60;
        int i = cast(int)hue;
        float f = hue - i;
        float p = brightness * (1 - saturation);
        float q = brightness * (1 - saturation * f);
        float t = brightness * (1 - saturation * (1 - f));
        switch(i) {
            case 0:
                r = brightness;
                g = t;
                b = p;
                break;
            case 1:
                r = q;
                g = brightness;
                b = p;
                break;
            case 2:
                r = p;
                g = brightness;
                b = t;
                break;
            case 3:
                r = p;
                g = q;
                b = brightness;
                break;
            case 4:
                r = t;
                g = p;
                b = brightness;
                break;
            case 5:
            default:
                r = brightness;
                g = p;
                b = q;
                break;
        }
    }
    red = cast(int)(r * 255 + 0.5);
    green = cast(int)(g * 255 + 0.5);
    blue = cast(int)(b * 255 + 0.5);
}

/**
 * Returns the hue, saturation, and brightness of the color.
 *
 * @return color space values in float format:<ul>
 *             <li>hue (from 0 to 360)</li>
 *             <li>saturation (from 0 to 1)</li>
 *             <li>brightness (from 0 to 1)</li>
 *             </ul>
 * @see #RGB(float, float, float)
 *
 * @since 3.2
 */
public float[] getHSB() const {
    float r = red / 255f;
    float g = green / 255f;
    float b = blue / 255f;
    float max = Math.max(Math.max(r, g), b);
    float min = Math.min(Math.min(r, g), b);
    float delta = max - min;
    float hue = 0;
    float brightness = max;
    float saturation = max is 0 ? 0 : (max - min) / max;
    if (delta !is 0) {
        if (r is max) {
            hue = (g  - b) / delta;
        } else {
            if (g is max) {
                hue = 2 + (b - r) / delta;
            } else {
                hue = 4 + (r - g) / delta;
            }
        }
        hue *= 60;
        if (hue < 0) hue += 360;
    }
    return [ hue, saturation, brightness ];
}

/**
 * Compares the argument to the receiver, and returns true
 * if they represent the <em>same</em> object using a class
 * specific comparison.
 *
 * @param object the object to compare with this object
 * @return <code>true</code> if the object is the same as this object and <code>false</code> otherwise
 *
 * @see #hashCode()
 */
public override bool opEquals(Object object) const {
    if (object is this) return true;
    if( auto rgb = cast(RGB) object ){
        return (rgb.red is this.red) && (rgb.green is this.green) && (rgb.blue is this.blue);
    }
    return false;
}

/**
 * Returns an integer hash code for the receiver. Any two
 * objects that return <code>true</code> when passed to
 * <code>equals</code> must return the same value for this
 * method.
 *
 * @return the receiver's hash
 *
 * @see #equals(Object)
 */
override public size_t toHash() const @safe pure nothrow {
    return (blue << 16) | (green << 8) | red;
}

/**
 * Returns a String containing a concise, human-readable
 * description of the receiver.
 *
 * @return a String representation of the <code>RGB</code>
 */
public override String toString() const {
    return Format( "RGB {{{}, {}, {}}", red, green, blue ); //$NON-NLS-1$//$NON-NLS-2$ //$NON-NLS-3$ //$NON-NLS-4$
}

}

alias TryConst!(RGB) constRGB;
