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
module org.eclipse.swt.custom.StyleRange;

import java.lang.all;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.TextStyle;
import org.eclipse.swt.internal.CloneableCompatibility;
import org.eclipse.swt.custom.StyleRange;
import org.eclipse.swt.custom.TextChangedEvent;
import org.eclipse.swt.custom.TextChangingEvent;

/**
 * <code>StyleRange</code> defines a set of styles for a specified
 * range of text.
 * <p>
 * The hashCode() method in this class uses the values of the public
 * fields to compute the hash value. When storing instances of the
 * class in hashed collections, do not modify these fields after the
 * object has been inserted.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class StyleRange : TextStyle, CloneableCompatibility {

    /**
     * the start offset of the range, zero-based from the document start
     */
    public int start;

    /**
     * the length of the range
     */
    public int length;

    /**
     * the font style of the range. It may be a combination of
     * SWT.NORMAL, SWT.ITALIC or SWT.BOLD
     *
     * Note: the font style is not used if the <code>font</code> attribute
     * is set
     */
    public int fontStyle = SWT.NORMAL;

/**
 * Create a new style range with no styles
 *
 * @since 3.2
 */
public this() {
}
/++
 + SWT extension for clone implementation
 +/
protected this( StyleRange other ){
    super( other );
    start = other.start;
    length = other.length;
    fontStyle = other.fontStyle;
}

/**
 * Create a new style range from an existing text style.
 *
 * @param style the text style to copy
 *
 * @since 3.4
 */
public this(TextStyle style) {
    super(style);
}

/**
 * Create a new style range.
 *
 * @param start start offset of the style
 * @param length length of the style
 * @param foreground foreground color of the style, null if none
 * @param background background color of the style, null if none
 */
public this(int start, int length, Color foreground, Color background) {
    super(null, foreground, background);
    this.start = start;
    this.length = length;
}

/**
 * Create a new style range.
 *
 * @param start start offset of the style
 * @param length length of the style
 * @param foreground foreground color of the style, null if none
 * @param background background color of the style, null if none
 * @param fontStyle font style of the style, may be SWT.NORMAL, SWT.ITALIC or SWT.BOLD
 */
public this(int start, int length, Color foreground, Color background, int fontStyle) {
    this(start, length, foreground, background);
    this.fontStyle = fontStyle;
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
    if (auto style = cast(StyleRange) object ) {
        if (start !is style.start) return false;
        if (length !is style.length) return false;
        return similarTo(style);
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
public override hash_t toHash() {
    return super.toHash() ^ fontStyle;
}
bool isVariableHeight() {
    return font !is null || metrics !is null || rise !is 0;
}
/**
 * Returns whether or not the receiver is unstyled (i.e., does not have any
 * style attributes specified).
 *
 * @return true if the receiver is unstyled, false otherwise.
 */
public bool isUnstyled() {
    if (font !is null) return false;
    if (rise !is 0) return false;
    if (metrics !is null) return false;
    if (foreground !is null) return false;
    if (background !is null) return false;
    if (fontStyle !is SWT.NORMAL) return false;
    if (underline) return false;
    if (strikeout) return false;
    if (borderStyle !is SWT.NONE) return false;
    return true;
}

/**
 * Compares the specified object to this StyleRange and answer if the two
 * are similar. The object must be an instance of StyleRange and have the
 * same field values for except for start and length.
 *
 * @param style the object to compare with this object
 * @return true if the objects are similar, false otherwise
 */
public bool similarTo(StyleRange style) {
    if (!super.opEquals(style)) return false;
    if (fontStyle !is style.fontStyle) return false;
    return true;
}

/**
 * Returns a new StyleRange with the same values as this StyleRange.
 *
 * @return a shallow copy of this StyleRange
 */
public /+override+/ Object clone() {
    return new StyleRange( this );
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the StyleRange
 */
public override String toString() {
    StringBuffer buffer = new StringBuffer();
    buffer.append("StyleRange {");
    buffer.append(start);
    buffer.append(", ");
    buffer.append(length);
    buffer.append(", fontStyle=");
    switch (fontStyle) {
        case SWT.BOLD:
            buffer.append("bold");
            break;
        case SWT.ITALIC:
            buffer.append("italic");
            break;
        case SWT.BOLD | SWT.ITALIC:
            buffer.append("bold-italic");
            break;
        default:
            buffer.append("normal");
    }
    String str = super.toString();
    int index = str.indexOf( '{');
    str = str.substring( index + 1 );
    if (str.length > 1) buffer.append(", ");
    buffer.append(str);
    return buffer.toString();
}
}
