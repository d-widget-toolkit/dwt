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
module org.eclipse.swt.graphics.Font;

import java.lang.all;


import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Resource;
import org.eclipse.swt.graphics.FontData;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.gtk.OS;


/**
 * Instances of this class manage operating system resources that
 * define how text looks when it is displayed. Fonts may be constructed
 * by providing a device and either name, size and style information
 * or a <code>FontData</code> object which encapsulates this data.
 * <p>
 * Application code must explicitly invoke the <code>Font.dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required.
 * </p>
 *
 * @see FontData
 * @see <a href="http://www.eclipse.org/swt/snippets/#font">Font snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Examples: GraphicsExample, PaintExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class Font : Resource {

    alias Resource.init_ init_;
    /**
     * the handle to the OS font resource
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public PangoFontDescription* handle;

this(Device device) {
    super(device);
}

/**
 * Constructs a new font given a device and font data
 * which describes the desired font's appearance.
 * <p>
 * You must dispose the font when it is no longer required.
 * </p>
 *
 * @param device the device to create the font on
 * @param fd the FontData that describes the desired font (must not be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the fd argument is null</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES - if a font could not be created from the given font data</li>
 * </ul>
 */
public this(Device device, FontData fd) {
    super(device);
    if (fd is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    init_(fd.getName(), fd.getHeightF(), fd.getStyle(), fd.str);
    init_();
}

/**
 * Constructs a new font given a device and an array
 * of font data which describes the desired font's
 * appearance.
 * <p>
 * You must dispose the font when it is no longer required.
 * </p>
 *
 * @param device the device to create the font on
 * @param fds the array of FontData that describes the desired font (must not be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the fds argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the length of fds is zero</li>
 *    <li>ERROR_NULL_ARGUMENT - if any fd in the array is null</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES - if a font could not be created from the given font data</li>
 * </ul>
 *
 * @since 2.1
 */
public this(Device device, FontData[] fds) {
    super(device);
    if (fds is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (fds.length is 0) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    for (int i=0; i<fds.length; i++) {
        if (fds[i] is null) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    FontData fd = fds[0];
    init_(fd.getName(), fd.getHeightF(), fd.getStyle(), fd.str);
    init_();
}

/**
 * Constructs a new font given a device, a font name,
 * the height of the desired font in points, and a font
 * style.
 * <p>
 * You must dispose the font when it is no longer required.
 * </p>
 *
 * @param device the device to create the font on
 * @param name the name of the font (must not be null)
 * @param height the font height in points
 * @param style a bit or combination of NORMAL, BOLD, ITALIC
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the name argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the height is negative</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES - if a font could not be created from the given arguments</li>
 * </ul>
 */
public this(Device device, String name, int height, int style) {
    super(device);
    init_(name, height, style, null);
    init_();
}

/*public*/ this(Device device, String name, float height, int style) {
    super(device);
    init_(name, height, style, null);
    init_();
}

override
void destroy() {
    OS.pango_font_description_free(handle);
    handle = null;
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
public override equals_t opEquals(Object object) {
    if (object is this) return true;
    if ( auto font = cast(Font)object ){
       return handle is font.handle;
    }
    return false;
}


/**
 * Returns an array of <code>FontData</code>s representing the receiver.
 * On Windows, only one FontData will be returned per font. On X however,
 * a <code>Font</code> object <em>may</em> be composed of multiple X
 * fonts. To support this case, we return an array of font data objects.
 *
 * @return an array of font data objects describing the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public FontData[] getFontData() {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);

    auto family = OS.pango_font_description_get_family(handle);
    String name = fromStringz( family )._idup();
    float height = cast(float)OS.pango_font_description_get_size(handle) / OS.PANGO_SCALE;
    ptrdiff_t pangoStyle = OS.pango_font_description_get_style(handle);
    ptrdiff_t pangoWeight = OS.pango_font_description_get_weight(handle);
    int style = SWT.NORMAL;
    if (pangoStyle is OS.PANGO_STYLE_ITALIC) style |= SWT.ITALIC;
    if (pangoStyle is OS.PANGO_STYLE_OBLIQUE) style |= SWT.ROMAN;
    if (pangoWeight >= OS.PANGO_WEIGHT_BOLD) style |= SWT.BOLD;
    auto fontString = OS.pango_font_description_to_string (handle);
    auto buffer = fromStringz( fontString )._idup();
    FontData data = new FontData( buffer , height, style);
    OS.g_free (fontString);
    data.str = buffer;
    return [data];
}

/**
 * Invokes platform specific functionality to allocate a new font.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Font</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param device the device on which to allocate the color
 * @param handle the handle for the font
 *
 * @private
 */
public static Font gtk_new(Device device, PangoFontDescription* handle) {
    Font font = new Font(device);
    font.handle = handle;
    return font;
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
public override hash_t toHash() {
    return cast(hash_t)handle;
}

void init_( String name, float height, int style, String fontString) {
    if (name is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (height < 0) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (fontString !is null) {
        handle = OS.pango_font_description_from_string (toStringz(fontString));
        if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
    } else {
        handle = OS.pango_font_description_new();
        if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
        //byte[] buffer = Converter.wcsToMbcs(null, name, true);
        OS.pango_font_description_set_family(handle, toStringz(name) );
        if (height > 0) {
            OS.pango_font_description_set_size(handle, cast(int)(0.5f + height * OS.PANGO_SCALE));
        }
        OS.pango_font_description_set_stretch(handle, OS.PANGO_STRETCH_NORMAL);
        int pangoStyle = OS.PANGO_STYLE_NORMAL;
        int pangoWeight = OS.PANGO_WEIGHT_NORMAL;
        if ((style & SWT.ITALIC) !is 0) pangoStyle = OS.PANGO_STYLE_ITALIC;
        if ((style & SWT.ROMAN) !is 0) pangoStyle = OS.PANGO_STYLE_OBLIQUE;
        if ((style & SWT.BOLD) !is 0) pangoWeight = OS.PANGO_WEIGHT_BOLD;
        OS.pango_font_description_set_style(handle, pangoStyle);
        OS.pango_font_description_set_weight(handle, pangoWeight);
    }
}

/**
 * Returns <code>true</code> if the font has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the font.
 * When a font has been disposed, it is an error to
 * invoke any other method using the font.
 *
 * @return <code>true</code> when the font is disposed and <code>false</code> otherwise
 */
public override bool isDisposed() {
    return handle is null;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
override
public String toString () {
    if (isDisposed()) return "Font {*DISPOSED*}";
    return Format( "Font {{{}}", handle );
}

}
