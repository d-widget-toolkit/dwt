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
module org.eclipse.swt.graphics.TextStyle;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.GlyphMetrics;

import java.lang.all;

/**
 * <code>TextStyle</code> defines a set of styles that can be applied
 * to a range of text.
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
 * @see TextLayout
 * @see Font
 * @see Color
 * @see <a href="http://www.eclipse.org/swt/snippets/#textlayout">TextLayout, TextStyle snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.0
 */
public class TextStyle {

    /**
     * the font of the style
     */
    public Font font;

    /**
     * the foreground of the style
     */
    public Color foreground;

    /**
     * the background of the style
     */
    public Color background;

    /**
     * the underline flag of the style. The default underline
     * style is <code>SWT.UNDERLINE_SINGLE</code>.
     *
     *
     * @since 3.1
     */
    public bool underline;

    /**
     * the underline color of the style
     *
     * @since 3.4
     */
    public Color underlineColor;

    /**
     * the underline style. This style is ignored when
     * <code>underline</code> is false.
     * <p>
     * This value should be one of <code>SWT.UNDERLINE_SINGLE</code>,
     * <code>SWT.UNDERLINE_DOUBLE</code>, <code>SWT.UNDERLINE_ERROR</code>,
     * or <code>SWT.UNDERLINE_SQUIGGLE</code>.
     * </p>
     *
     * @see SWT#UNDERLINE_SINGLE
     * @see SWT#UNDERLINE_DOUBLE
     * @see SWT#UNDERLINE_ERROR
     * @see SWT#UNDERLINE_SQUIGGLE
     *
     * @since 3.4
     */
    public int underlineStyle;

    /**
     * the strikeout flag of the style
     *
     * @since 3.1
     */
    public bool strikeout;

    /**
     * the strikeout color of the style
     *
     * @since 3.4
     */
    public Color strikeoutColor;

    /**
     * the border style. The default border style is <code>SWT.NONE</code>.
     * <p>
     * This value should be one of <code>SWT.BORDER_SOLID</code>,
     * <code>SWT.BORDER_DASH</code>,<code>SWT.BORDER_DOT</code> or
     * <code>SWT.NONE</code>.
     * </p>
     *
     * @see SWT#BORDER_SOLID
     * @see SWT#BORDER_DASH
     * @see SWT#BORDER_DOT
     * @see SWT#NONE
     *
     * @since 3.4
     */
    public int borderStyle;

    /**
     * the border color of the style
     *
     * @since 3.4
     */
    public Color borderColor;

    /**
     * the GlyphMetrics of the style
     *
     * @since 3.2
     */
    public GlyphMetrics metrics;

    /**
     * the baseline rise of the style.
     *
     * @since 3.2
     */
    public int rise;

/**
 * Create an empty text style.
 *
 * @since 3.4
 */
public this () {
}

/**
 * Create a new text style with the specified font, foreground
 * and background.
 *
 * @param font the font of the style, <code>null</code> if none
 * @param foreground the foreground color of the style, <code>null</code> if none
 * @param background the background color of the style, <code>null</code> if none
 */
public this (Font font, Color foreground, Color background) {
    if (font !is null && font.isDisposed()) SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    if (foreground !is null && foreground.isDisposed()) SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    if (background !is null && background.isDisposed()) SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    this.font = font;
    this.foreground = foreground;
    this.background = background;
}


/**
 * Create a new text style from an existing text style.
 *
 * @param style the style to copy 
 *
 * @since 3.4
 */
public this (TextStyle style) {
    if (style is null) SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    font = style.font;
    foreground = style.foreground;
    background = style.background;
    underline = style.underline;
    underlineColor = style.underlineColor;
    underlineStyle = style.underlineStyle;
    strikeout = style.strikeout;
    strikeoutColor = style.strikeoutColor;
    borderStyle = style.borderStyle;
    borderColor = style.borderColor;
    metrics = style.metrics;
    rise = style.rise;
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
public override equals_t opEquals(Object object) {
    if (object is this) return true;
    if (object is null) return false;
    if (!(cast(TextStyle)object)) return false;
    TextStyle style = cast(TextStyle)object;
    if (foreground !is null) {
        if ( foreground !is style.foreground ) return false;
    } else if (style.foreground !is null) return false;
    if (background !is null) {
        if ( background !is style.background ) return false;
    } else if (style.background !is null) return false;
    if (font !is null) {
        if (font !is style.font) return false;
    } else if (style.font !is null) return false;
    if (metrics !is null || style.metrics !is null) return false;
    if (underline !is style.underline) return false;
    if (underlineStyle !is style.underlineStyle) return false;
    if (borderStyle !is style.borderStyle) return false;
    if (strikeout !is style.strikeout) return false;
    if (rise !is style.rise) return false;
    if (underlineColor !is null) {
        if (underlineColor != (style.underlineColor)) return false;
    } else if (style.underlineColor !is null) return false;
    if (strikeoutColor !is null) {
        if (strikeoutColor != (style.strikeoutColor)) return false;
    } else if (style.strikeoutColor !is null) return false;
    if (underlineStyle !is style.underlineStyle) return false;
    if (borderColor !is null) {
        if (borderColor != (style.borderColor)) return false;
    } else if (style.borderColor !is null) return false;
    return true;
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
public override hash_t toHash() {
    int hash = 0;
    if (foreground !is null) hash ^= foreground.toHash();
    if (background !is null) hash ^= background.toHash();
    if (font !is null) hash ^= font.toHash();
    if (metrics !is null) hash ^= metrics.toHash();
    if (underline) hash ^= hash;
    if (strikeout) hash ^= hash;
    hash ^= rise;
    if (underlineColor !is null) hash ^= underlineColor.toHash();
    if (strikeoutColor !is null) hash ^= strikeoutColor.toHash();
    if (borderColor !is null) hash ^= borderColor.toHash();
    hash ^= underlineStyle;
    return hash;
}

bool isAdherentBorder(TextStyle style) {
    if (this is style) return true;
    if (style is null) return false;
    if (borderStyle !is style.borderStyle) return false;
    if (borderColor !is null) {
        if (borderColor != (style.borderColor)) return false;
    } else if (style.borderColor !is null) return false;
    return true;
}

bool isAdherentUnderline(TextStyle style) {
    if (this is style) return true;
    if (style is null) return false;
    if (underline !is style.underline) return false;
    if (underlineStyle !is style.underlineStyle) return false;
    if (underlineColor !is null) {
        if (underlineColor != (style.underlineColor)) return false;
    } else if (style.underlineColor !is null) return false;
    return true;
}

bool isAdherentStrikeout(TextStyle style) {
    if (this is style) return true;
    if (style is null) return false;
    if (strikeout !is style.strikeout) return false;
    if (strikeoutColor !is null) {
        if (strikeoutColor != (style.strikeoutColor)) return false;
    } else if (style.strikeoutColor !is null) return false;
    return true;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the <code>TextStyle</code>
 */
override public String toString () {
    String buffer = "TextStyle {";
    int startLength = cast(int)/*64bit*/buffer.length;
    if (font !is null) {
        if (buffer.length > startLength) buffer ~= ", ";
        buffer ~= "font=";
        buffer ~= font.toString;
    }
    if (foreground !is null) {
        if (buffer.length > startLength) buffer ~= ", ";
        buffer ~= "foreground=";
        buffer ~= foreground.toString;
    }
    if (background !is null) {
        if (buffer.length > startLength) buffer ~= ", ";
        buffer ~= "background=";
        buffer ~= background.toString;
    }
    if (underline) {
        if (buffer.length > startLength) buffer ~= ", ";
        buffer ~= "underlined";
    }
    if (strikeout) {
        if (buffer.length > startLength) buffer ~= ", ";
        buffer ~= "striked out";
    }
    if (rise !is 0) {
        if (buffer.length > startLength) buffer ~= ", ";
        buffer ~= "rise=";
        buffer ~= String_valueOf(rise);
    }
    if (metrics !is null) {
        if (buffer.length > startLength) buffer ~= ", ";
        buffer ~= "metrics=";
        buffer ~= metrics.toString;
    }
    buffer ~= "}";
    return buffer;
}

}
