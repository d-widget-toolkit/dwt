/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module org.eclipse.swt.graphics.FontMetrics;


import org.eclipse.swt.internal.win32.WINTYPES;

/**
 * Instances of this class provide measurement information
 * about fonts including ascent, descent, height, leading
 * space between rows, and average character width.
 * <code>FontMetrics</code> are obtained from <code>GC</code>s
 * using the <code>getFontMetrics()</code> method.
 *
 * @see GC#getFontMetrics
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public final class FontMetrics {

    /**
     * On Windows, handle is a Win32 TEXTMETRIC struct
     * On Photon, handle is a Photon FontQueryInfo struct
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public TEXTMETRIC handle;

/**
 * Prevents instances from being created outside the package.
 */
this() {
}

/**
 * Compares the argument to the receiver, and returns true
 * if they represent the <em>same</em> object using a class
 * specific comparison.
 *
 * @param object the object to compare with this object
 * @return <code>true</code> if the object is the same as this object and <code>false</code> otherwise
 *
 * @see #hashCode
 */
override public equals_t opEquals (Object object) {
    if (object is this) return true;
    if( auto metricObj = cast(FontMetrics)object ){
        auto metric = metricObj.handle;
        return handle.tmHeight is metric.tmHeight &&
            handle.tmAscent is metric.tmAscent &&
            handle.tmDescent is metric.tmDescent &&
            handle.tmInternalLeading is metric.tmInternalLeading &&
            handle.tmExternalLeading is metric.tmExternalLeading &&
            handle.tmAveCharWidth is metric.tmAveCharWidth &&
            handle.tmMaxCharWidth is metric.tmMaxCharWidth &&
            handle.tmWeight is metric.tmWeight &&
            handle.tmOverhang is metric.tmOverhang &&
            handle.tmDigitizedAspectX is metric.tmDigitizedAspectX &&
            handle.tmDigitizedAspectY is metric.tmDigitizedAspectY &&
    //      handle.tmFirstChar is metric.tmFirstChar &&
    //      handle.tmLastChar is metric.tmLastChar &&
    //      handle.tmDefaultChar is metric.tmDefaultChar &&
    //      handle.tmBreakChar is metric.tmBreakChar &&
            handle.tmItalic is metric.tmItalic &&
            handle.tmUnderlined is metric.tmUnderlined &&
            handle.tmStruckOut is metric.tmStruckOut &&
            handle.tmPitchAndFamily is metric.tmPitchAndFamily &&
            handle.tmCharSet is metric.tmCharSet;
    }
    return false;
}

/**
 * Returns the ascent of the font described by the receiver. A
 * font's <em>ascent</em> is the distance from the baseline to the
 * top of actual characters, not including any of the leading area,
 * measured in pixels.
 *
 * @return the ascent of the font
 */
public int getAscent() {
    return handle.tmAscent - handle.tmInternalLeading;
}

/**
 * Returns the average character width, measured in pixels,
 * of the font described by the receiver.
 *
 * @return the average character width of the font
 */
public int getAverageCharWidth() {
    return handle.tmAveCharWidth;
}

/**
 * Returns the descent of the font described by the receiver. A
 * font's <em>descent</em> is the distance from the baseline to the
 * bottom of actual characters, not including any of the leading area,
 * measured in pixels.
 *
 * @return the descent of the font
 */
public int getDescent() {
    return handle.tmDescent;
}

/**
 * Returns the height of the font described by the receiver,
 * measured in pixels. A font's <em>height</em> is the sum of
 * its ascent, descent and leading area.
 *
 * @return the height of the font
 *
 * @see #getAscent
 * @see #getDescent
 * @see #getLeading
 */
public int getHeight() {
    return handle.tmHeight;
}

/**
 * Returns the leading area of the font described by the
 * receiver. A font's <em>leading area</em> is the space
 * above its ascent which may include accents or other marks.
 *
 * @return the leading space of the font
 */
public int getLeading() {
    return handle.tmInternalLeading;
}

/**
 * Returns an integer hash code for the receiver. Any two
 * objects that return <code>true</code> when passed to
 * <code>equals</code> must return the same value for this
 * method.
 *
 * @return the receiver's hash
 *
 * @see #equals
 */
override public hash_t toHash() {
    return handle.tmHeight ^ handle.tmAscent ^ handle.tmDescent ^
        handle.tmInternalLeading ^ handle.tmExternalLeading ^
        handle.tmAveCharWidth ^ handle.tmMaxCharWidth ^ handle.tmWeight ^
        handle.tmOverhang ^ handle.tmDigitizedAspectX ^ handle.tmDigitizedAspectY ^
//      handle.tmFirstChar ^ handle.tmLastChar ^ handle.tmDefaultChar ^ handle.tmBreakChar ^
        handle.tmItalic ^ handle.tmUnderlined ^ handle.tmStruckOut ^
        handle.tmPitchAndFamily ^ handle.tmCharSet;
}

/**
 * Invokes platform specific functionality to allocate a new font metrics.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>FontMetrics</code>. It is marked public only so that
 * it can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param handle the <code>TEXTMETRIC</code> containing information about a font
 * @return a new font metrics object containing the specified <code>TEXTMETRIC</code>
 */
public static FontMetrics win32_new(TEXTMETRIC* handle) {
    FontMetrics fontMetrics = new FontMetrics();
    fontMetrics.handle = *handle;
    return fontMetrics;
}

}
