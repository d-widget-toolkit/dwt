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
module org.eclipse.swt.graphics.Cursor;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.graphics.Resource;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.Image;

import java.lang.all;

/**
 * Instances of this class manage operating system resources that
 * specify the appearance of the on-screen pointer. To create a
 * cursor you specify the device and either a simple cursor style
 * describing one of the standard operating system provided cursors
 * or the image and mask data for the desired appearance.
 * <p>
 * Application code must explicitly invoke the <code>Cursor.dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required.
 * </p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>
 *   CURSOR_ARROW, CURSOR_WAIT, CURSOR_CROSS, CURSOR_APPSTARTING, CURSOR_HELP,
 *   CURSOR_SIZEALL, CURSOR_SIZENESW, CURSOR_SIZENS, CURSOR_SIZENWSE, CURSOR_SIZEWE,
 *   CURSOR_SIZEN, CURSOR_SIZES, CURSOR_SIZEE, CURSOR_SIZEW, CURSOR_SIZENE, CURSOR_SIZESE,
 *   CURSOR_SIZESW, CURSOR_SIZENW, CURSOR_UPARROW, CURSOR_IBEAM, CURSOR_NO, CURSOR_HAND
 * </dd>
 * </dl>
 * <p>
 * Note: Only one of the above styles may be specified.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#cursor">Cursor snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public final class Cursor : Resource {

    alias Resource.init_ init_;

    /**
     * the handle to the OS cursor resource
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public HCURSOR handle;

    bool isIcon;

    /**
     * data used to create a HAND cursor.
     */
    static /+const+/ byte[] HAND_SOURCE = [
        cast(byte)0xf9,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xf0,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xf0,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xf0,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xf0,cast(byte)0x3f,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xf0,cast(byte)0x07,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xf0,cast(byte)0x03,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xf0,cast(byte)0x00,cast(byte)0xff,cast(byte)0xff,

        cast(byte)0x10,cast(byte)0x00,cast(byte)0x7f,cast(byte)0xff,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x7f,cast(byte)0xff,
        cast(byte)0x80,cast(byte)0x00,cast(byte)0x7f,cast(byte)0xff,
        cast(byte)0xc0,cast(byte)0x00,cast(byte)0x7f,cast(byte)0xff,
        cast(byte)0xe0,cast(byte)0x00,cast(byte)0x7f,cast(byte)0xff,
        cast(byte)0xf0,cast(byte)0x00,cast(byte)0x7f,cast(byte)0xff,
        cast(byte)0xf8,cast(byte)0x00,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xfc,cast(byte)0x01,cast(byte)0xff,cast(byte)0xff,

        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,

        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,
        cast(byte)0xff,cast(byte)0xff,cast(byte)0xff,cast(byte)0xff
    ];
    static /+const+/ byte[] HAND_MASK = [
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x06,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x06,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x06,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x06,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x06,cast(byte)0xc0,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x06,cast(byte)0xd8,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x06,cast(byte)0xd8,cast(byte)0x00,cast(byte)0x00,

        cast(byte)0x07,cast(byte)0xdb,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x67,cast(byte)0xfb,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x3f,cast(byte)0xff,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x1f,cast(byte)0xff,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x0f,cast(byte)0xff,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x07,cast(byte)0xff,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x03,cast(byte)0xfe,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,

        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,

        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,
        cast(byte)0x00,cast(byte)0x00,cast(byte)0x00,cast(byte)0x00
    ];

/**
 * Prevents uninitialized instances from being created outside the package.
 */
this(Device device) {
    super(device);
}

/**
 * Constructs a new cursor given a device and a style
 * constant describing the desired cursor appearance.
 * <p>
 * You must dispose the cursor when it is no longer required.
 * </p>
 *
 * @param device the device on which to allocate the cursor
 * @param style the style of cursor to allocate
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_INVALID_ARGUMENT - when an unknown style is specified</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES - if a handle could not be obtained for cursor creation</li>
 * </ul>
 *
 * @see SWT#CURSOR_ARROW
 * @see SWT#CURSOR_WAIT
 * @see SWT#CURSOR_CROSS
 * @see SWT#CURSOR_APPSTARTING
 * @see SWT#CURSOR_HELP
 * @see SWT#CURSOR_SIZEALL
 * @see SWT#CURSOR_SIZENESW
 * @see SWT#CURSOR_SIZENS
 * @see SWT#CURSOR_SIZENWSE
 * @see SWT#CURSOR_SIZEWE
 * @see SWT#CURSOR_SIZEN
 * @see SWT#CURSOR_SIZES
 * @see SWT#CURSOR_SIZEE
 * @see SWT#CURSOR_SIZEW
 * @see SWT#CURSOR_SIZENE
 * @see SWT#CURSOR_SIZESE
 * @see SWT#CURSOR_SIZESW
 * @see SWT#CURSOR_SIZENW
 * @see SWT#CURSOR_UPARROW
 * @see SWT#CURSOR_IBEAM
 * @see SWT#CURSOR_NO
 * @see SWT#CURSOR_HAND
 */
public this(Device device, int style) {
    super(device);
    ptrdiff_t lpCursorName = 0;
    switch (style) {
        case SWT.CURSOR_HAND:       lpCursorName = OS.IDC_HAND; break;
        case SWT.CURSOR_ARROW:      lpCursorName = OS.IDC_ARROW; break;
        case SWT.CURSOR_WAIT:       lpCursorName = OS.IDC_WAIT; break;
        case SWT.CURSOR_CROSS:      lpCursorName = OS.IDC_CROSS; break;
        case SWT.CURSOR_APPSTARTING:    lpCursorName = OS.IDC_APPSTARTING; break;
        case SWT.CURSOR_HELP:       lpCursorName = OS.IDC_HELP; break;
        case SWT.CURSOR_SIZEALL:    lpCursorName = OS.IDC_SIZEALL; break;
        case SWT.CURSOR_SIZENESW:   lpCursorName = OS.IDC_SIZENESW; break;
        case SWT.CURSOR_SIZENS:     lpCursorName = OS.IDC_SIZENS; break;
        case SWT.CURSOR_SIZENWSE:   lpCursorName = OS.IDC_SIZENWSE; break;
        case SWT.CURSOR_SIZEWE:     lpCursorName = OS.IDC_SIZEWE; break;
        case SWT.CURSOR_SIZEN:      lpCursorName = OS.IDC_SIZENS; break;
        case SWT.CURSOR_SIZES:      lpCursorName = OS.IDC_SIZENS; break;
        case SWT.CURSOR_SIZEE:      lpCursorName = OS.IDC_SIZEWE; break;
        case SWT.CURSOR_SIZEW:      lpCursorName = OS.IDC_SIZEWE; break;
        case SWT.CURSOR_SIZENE:     lpCursorName = OS.IDC_SIZENESW; break;
        case SWT.CURSOR_SIZESE:     lpCursorName = OS.IDC_SIZENWSE; break;
        case SWT.CURSOR_SIZESW:     lpCursorName = OS.IDC_SIZENESW; break;
        case SWT.CURSOR_SIZENW:     lpCursorName = OS.IDC_SIZENWSE; break;
        case SWT.CURSOR_UPARROW:    lpCursorName = OS.IDC_UPARROW; break;
        case SWT.CURSOR_IBEAM:      lpCursorName = OS.IDC_IBEAM; break;
        case SWT.CURSOR_NO:         lpCursorName = OS.IDC_NO; break;
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    handle = OS.LoadCursor(null, cast(wchar*)lpCursorName);
    /*
    * IDC_HAND is supported only on Windows 2000 and Windows 98.
    * Create a hand cursor if running in other Windows platforms.
    */
    if (handle is null && style is SWT.CURSOR_HAND) {
        int width = OS.GetSystemMetrics(OS.SM_CXCURSOR);
        int height = OS.GetSystemMetrics(OS.SM_CYCURSOR);
        if (width is 32 && height is 32) {
            auto hInst = OS.GetModuleHandle(null);
            static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
            handle = OS.CreateCursor(hInst, 5, 0, 32, 32, HAND_SOURCE.ptr, HAND_MASK.ptr);

        }
    }
    if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
    init_();
}

/**
 * Constructs a new cursor given a device, image and mask
 * data describing the desired cursor appearance, and the x
 * and y coordinates of the <em>hotspot</em> (that is, the point
 * within the area covered by the cursor which is considered
 * to be where the on-screen pointer is "pointing").
 * <p>
 * The mask data is allowed to be null, but in this case the source
 * must be an ImageData representing an icon that specifies both
 * color data and mask data.
 * <p>
 * You must dispose the cursor when it is no longer required.
 * </p>
 *
 * @param device the device on which to allocate the cursor
 * @param source the color data for the cursor
 * @param mask the mask data for the cursor (or null)
 * @param hotspotX the x coordinate of the cursor's hotspot
 * @param hotspotY the y coordinate of the cursor's hotspot
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the source is null</li>
 *    <li>ERROR_NULL_ARGUMENT - if the mask is null and the source does not have a mask</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the source and the mask are not the same
 *          size, or if the hotspot is outside the bounds of the image</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES - if a handle could not be obtained for cursor creation</li>
 * </ul>
 */
public this(Device device, ImageData source, ImageData mask, int hotspotX, int hotspotY) {
    super(device);
    if (source is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (mask is null) {
        if (source.getTransparencyType() !is SWT.TRANSPARENCY_MASK) {
            SWT.error(SWT.ERROR_NULL_ARGUMENT);
        }
        mask = source.getTransparencyMask();
    }
    /* Check the bounds. Mask must be the same size as source */
    if (mask.width !is source.width || mask.height !is source.height) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    /* Check the hotspots */
    if (hotspotX >= source.width || hotspotX < 0 ||
        hotspotY >= source.height || hotspotY < 0) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    /* Convert depth to 1 */
    mask = ImageData.convertMask(mask);
    source = ImageData.convertMask(source);

    /* Make sure source and mask scanline pad is 2 */
    byte[] sourceData = ImageData.convertPad(source.data, source.width, source.height, source.depth, source.scanlinePad, 2);
    byte[] maskData = ImageData.convertPad(mask.data, mask.width, mask.height, mask.depth, mask.scanlinePad, 2);

    /* Create the cursor */
    auto hInst = OS.GetModuleHandle(null);
    static if (OS.IsWinCE) SWT.error (SWT.ERROR_NOT_IMPLEMENTED);
    handle = OS.CreateCursor(hInst, hotspotX, hotspotY, source.width, source.height, sourceData.ptr, maskData.ptr);
    if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
    init_();
}

/**
 * Constructs a new cursor given a device, image data describing
 * the desired cursor appearance, and the x and y coordinates of
 * the <em>hotspot</em> (that is, the point within the area
 * covered by the cursor which is considered to be where the
 * on-screen pointer is "pointing").
 * <p>
 * You must dispose the cursor when it is no longer required.
 * </p>
 *
 * @param device the device on which to allocate the cursor
 * @param source the image data for the cursor
 * @param hotspotX the x coordinate of the cursor's hotspot
 * @param hotspotY the y coordinate of the cursor's hotspot
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the image is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the hotspot is outside the bounds of the
 *       image</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES - if a handle could not be obtained for cursor creation</li>
 * </ul>
 *
 * @since 3.0
 */
public this(Device device, ImageData source, int hotspotX, int hotspotY) {
    super(device);
    if (source is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    /* Check the hotspots */
    if (hotspotX >= source.width || hotspotX < 0 ||
        hotspotY >= source.height || hotspotY < 0) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    ImageData mask = source.getTransparencyMask();
    ptrdiff_t[] result = Image.init__(this.device, null, source, mask);
    auto hBitmap = cast(HBITMAP)result[0];
    auto hMask = cast(HBITMAP)result[1];
    /* Create the icon */
    ICONINFO info;
    info.fIcon = false;
    info.hbmColor = hBitmap;
    info.hbmMask = hMask;
    info.xHotspot = hotspotX;
    info.yHotspot = hotspotY;
    handle = OS.CreateIconIndirect(&info);
    if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
    OS.DeleteObject(hBitmap);
    OS.DeleteObject(hMask);
    isIcon = true;
    init_();
}

override
void destroy () {
    /*
    * It is an error in Windows to destroy the current
    * cursor.  Check that the cursor that is about to
    * be destroyed is the current cursor.  If so, set
    * the current cursor to be IDC_ARROW.  Note that
    * Windows shares predefined cursors so the call to
    * LoadCursor() does not leak.
    */
    // TEMPORARY CODE
//  if (OS.GetCursor() is handle) {
//      OS.SetCursor(OS.LoadCursor(0, OS.IDC_ARROW));
//  }

    if (isIcon) {
        OS.DestroyIcon(handle);
    } else {
        /*
        * The MSDN states that one should not destroy a shared
        * cursor, that is, one obtained from LoadCursor.
        * However, it does not appear to do any harm, so rather
        * than keep track of how a cursor was created, we just
        * destroy them all. If this causes problems in the future,
        * put the flag back in.
        */
        static if (!OS.IsWinCE) OS.DestroyCursor(handle);
    }
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
public override equals_t opEquals (Object object) {
    if (object is this) return true;
    if (!(cast(Cursor)object)) return false;
    Cursor cursor = cast(Cursor) object;
    return device is cursor.device && handle is cursor.handle;
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
public override hash_t toHash () {
    return cast(hash_t)handle;
}

/**
 * Returns <code>true</code> if the cursor has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the cursor.
 * When a cursor has been disposed, it is an error to
 * invoke any other method using the cursor.
 *
 * @return <code>true</code> when the cursor is disposed and <code>false</code> otherwise
 */
override public bool isDisposed() {
    return handle is null;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
override public String toString () {
    if (isDisposed()) return "Cursor {*DISPOSED*}";
    return Format( "Cursor {{{}}", handle );
}

/**
 * Invokes platform specific functionality to allocate a new cursor.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Cursor</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param device the device on which to allocate the color
 * @param handle the handle for the cursor
 * @return a new cursor object containing the specified device and handle
 */
public static Cursor win32_new(Device device, HCURSOR handle) {
    Cursor cursor = new Cursor(device);
    cursor.disposeChecking = false;
    cursor.handle = handle;
    return cursor;
}

}
