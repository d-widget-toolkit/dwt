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
module org.eclipse.swt.graphics.Color;

import java.lang.all;


import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.Resource;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Device;



/**
 * Instances of this class manage the operating system resources that
 * implement SWT's RGB color model. To create a color you can either
 * specify the individual color components as integers in the range
 * 0 to 255 or provide an instance of an <code>RGB</code>.
 * <p>
 * Application code must explicitly invoke the <code>Color.dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required.
 * </p>
 *
 * @see RGB
 * @see Device#getSystemColor
 * @see <a href="http://www.eclipse.org/swt/snippets/#color">Color and RGB snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: PaintExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class Color : Resource {
    alias Resource.init_ init_;
    /**
     * the handle to the OS color resource
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public GdkColor* handle;

this(Device device) {
    super(device);
}

/**
 * Constructs a new instance of this class given a device and the
 * desired red, green and blue values expressed as ints in the range
 * 0 to 255 (where 0 is black and 255 is full brightness). On limited
 * color devices, the color instance created by this call may not have
 * the same RGB values as the ones specified by the arguments. The
 * RGB values on the returned instance will be the color values of
 * the operating system color.
 * <p>
 * You must dispose the color when it is no longer required.
 * </p>
 *
 * @param device the device on which to allocate the color
 * @param red the amount of red in the color
 * @param green the amount of green in the color
 * @param blue the amount of blue in the color
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the red, green or blue argument is not between 0 and 255</li>
 * </ul>
 *
 * @see #dispose
 */
public this(Device device, int red, int green, int blue) {
    super(device);
    init_(red, green, blue);
    init_();
}

/**
 * Constructs a new instance of this class given a device and an
 * <code>RGB</code> describing the desired red, green and blue values.
 * On limited color devices, the color instance created by this call
 * may not have the same RGB values as the ones specified by the
 * argument. The RGB values on the returned instance will be the color
 * values of the operating system color.
 * <p>
 * You must dispose the color when it is no longer required.
 * </p>
 *
 * @param device the device on which to allocate the color
 * @param rgb the RGB values of the desired color
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the rgb argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the red, green or blue components of the argument are not between 0 and 255</li>
 * </ul>
 *
 * @see #dispose
 */
public this(Device device, in RGB rgb) {
    super(device);
    if (rgb is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    init_(rgb.red, rgb.green, rgb.blue);
    init_();
}

override
void destroy() {
    int pixel = handle.pixel;
    if (device.colorRefCount !is null) {
        /* If this was the last reference, remove the color from the list */
        if (--device.colorRefCount[pixel] is 0) {
            device.gdkColors[pixel] = null;
        }
    }
    auto colormap = OS.gdk_colormap_get_system();
    OS.gdk_colormap_free_colors(colormap, handle, 1);
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
    if ( auto color = cast(Color)object ){
        GdkColor* gdkColor = color.handle;
        if (handle is gdkColor) return true;
        return device is color.device && handle.red is gdkColor.red &&
            handle.green is gdkColor.green && handle.blue is gdkColor.blue;
    }
    return false;
}

/**
 * Returns the amount of blue in the color, from 0 to 255.
 *
 * @return the blue component of the color
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getBlue() {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return (handle.blue >> 8) & 0xFF;
}

/**
 * Returns the amount of green in the color, from 0 to 255.
 *
 * @return the green component of the color
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getGreen() {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return (handle.green >> 8) & 0xFF;
}

/**
 * Returns the amount of red in the color, from 0 to 255.
 *
 * @return the red component of the color
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getRed() {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return (handle.red >> 8) & 0xFF;
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
    if (handle is null) return 0;
    return handle.red ^ handle.green ^ handle.blue;
}

/**
 * Returns an <code>RGB</code> representing the receiver.
 *
 * @return the RGB for the color
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public RGB getRGB () {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return new RGB(getRed(), getGreen(), getBlue());
}

/**
 * Invokes platform specific functionality to allocate a new color.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Color</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param device the device on which to allocate the color
 * @param handle the handle for the color
 *
 * @private
 */
public static Color gtk_new(Device device, GdkColor* gdkColor) {
    Color color = new Color(device);
    color.handle = gdkColor;
    return color;
}

void init_(int red, int green, int blue) {
    if ((red > 255) || (red < 0) ||
        (green > 255) || (green < 0) ||
        (blue > 255) || (blue < 0)) {
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    GdkColor* gdkColor = new GdkColor();
    gdkColor.red = cast(short)((red & 0xFF) | ((red & 0xFF) << 8));
    gdkColor.green = cast(short)((green & 0xFF) | ((green & 0xFF) << 8));
    gdkColor.blue = cast(short)((blue & 0xFF) | ((blue & 0xFF) << 8));
    auto colormap = OS.gdk_colormap_get_system();
    if (!OS.gdk_colormap_alloc_color(colormap, gdkColor, true, true)) {
        /* Allocate black. */
        gdkColor = new GdkColor();
        OS.gdk_colormap_alloc_color(colormap, gdkColor, true, true);
    }
    handle = gdkColor;
    if (device.colorRefCount !is null) {
        /* Make a copy of the color to put in the colors array */
        GdkColor* colorCopy = new GdkColor();
        colorCopy.red = handle.red;
        colorCopy.green = handle.green;
        colorCopy.blue = handle.blue;
        colorCopy.pixel = handle.pixel;
        device.gdkColors[colorCopy.pixel] = colorCopy;
        device.colorRefCount[colorCopy.pixel]++;
    }
}

/**
 * Returns <code>true</code> if the color has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the color.
 * When a color has been disposed, it is an error to
 * invoke any other method using the color.
 *
 * @return <code>true</code> when the color is disposed and <code>false</code> otherwise
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
public override String toString () {
    if (isDisposed()) return "Color {*DISPOSED*}";
    return Format( "Color {{{}, {}, {}}", getRed(), getGreen(), getBlue());
}

}
