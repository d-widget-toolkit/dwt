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

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.graphics.Resource;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Device;

import java.lang.all;

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
    public COLORREF handle;

/**
 * Prevents uninitialized instances from being created outside the package.
 */
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
public this (Device device, int red, int green, int blue) {
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
public this (Device device, constRGB rgb) {
    super(device);
    if (rgb is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    init_(rgb.red, rgb.green, rgb.blue);
    init_();
}

override
void destroy() {
    /*
     * If this is a palette-based device,
     * Decrease the reference count for this color.
     * If the reference count reaches 0, the slot may
     * be reused when another color is allocated.
     */
    auto hPal = device.hPalette;
    if (hPal !is null) {
        int index = OS.GetNearestPaletteIndex(hPal, handle);
        int[] colorRefCount = device.colorRefCount;
        if (colorRefCount[index] > 0) {
            colorRefCount[index]--;
        }
    }
    handle = -1;
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
public override equals_t opEquals (Object object) {
    if (object is this) return true;
    if (!(cast(Color)object)) return false;
    Color color = cast(Color) object;
    return device is color.device && (handle & 0xFFFFFF) is (color.handle & 0xFFFFFF);
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
public int getBlue () {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return (handle & 0xFF0000) >> 16;
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
public int getGreen () {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return (handle & 0xFF00) >> 8 ;
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
public int getRed () {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return handle & 0xFF;
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
    return new RGB(cast(int)handle & 0xFF,cast(int) (handle & 0xFF00) >> 8,cast(int) (handle & 0xFF0000) >> 16);
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
public int hashCode () {
    return handle;
}

/**
 * Allocates the operating system resources associated
 * with the receiver.
 *
 * @param device the device on which to allocate the color
 * @param red the amount of red in the color
 * @param green the amount of green in the color
 * @param blue the amount of blue in the color
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the red, green or blue argument is not between 0 and 255</li>
 * </ul>
 *
 * @see #dispose
 */
void init_(int red, int green, int blue) {
    if (red > 255 || red < 0 || green > 255 || green < 0 || blue > 255 || blue < 0) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    handle = (red & 0xFF) | ((green & 0xFF) << 8) | ((blue & 0xFF) << 16);

    /* If this is not a palette-based device, return */
    auto hPal = device.hPalette;
    if (hPal is null) return;

    int[] colorRefCount = device.colorRefCount;
    /* Add this color to the default palette now */
    /* First find out if the color already exists */
    int index = OS.GetNearestPaletteIndex(hPal, handle);
    /* See if the nearest color actually is the color */
    PALETTEENTRY entry;
    OS.GetPaletteEntries(hPal, index, 1, &entry);
    if ((entry.peRed is cast(byte)red) && (entry.peGreen is cast(byte)green) &&
        (entry.peBlue is cast(byte)blue)) {
            /* Found the color. Increment the ref count and return */
            colorRefCount[index]++;
            return;
    }
    /* Didn't find the color, allocate it now. Find the first free entry */
    int i = 0;
    while (i < colorRefCount.length) {
        if (colorRefCount[i] is 0) {
            index = i;
            break;
        }
        i++;
    }
    if (i is colorRefCount.length) {
        /* No free entries, use the closest one */
        /* Remake the handle from the actual rgbs */
        handle = (entry.peRed & 0xFF) | ((entry.peGreen & 0xFF) << 8) |
                 ((entry.peBlue & 0xFF) << 16);
    } else {
        /* Found a free entry */
        entry.peRed = cast(BYTE)(red & 0xFF);
        entry.peGreen = cast(BYTE)(green & 0xFF);
        entry.peBlue = cast(BYTE)(blue & 0xFF);
        entry.peFlags = 0;
        OS.SetPaletteEntries(hPal, index, 1, &entry);
    }
    colorRefCount[index]++;
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
override public bool isDisposed() {
    return handle is -1;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
override public String toString () {
    if (isDisposed()) return "Color {*DISPOSED*}"; //$NON-NLS-1$
    return Format( "Color {{{}, {}, {}}", getRed(), getGreen(), getBlue()); //$NON-NLS-1$//$NON-NLS-2$ //$NON-NLS-3$ //$NON-NLS-4$
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
 * @return a new color object containing the specified device and handle
 */
public static Color win32_new(Device device, int handle) {
    Color color = new Color(device);
    color.disposeChecking = false;
    color.handle = handle;
    return color;
}

}
