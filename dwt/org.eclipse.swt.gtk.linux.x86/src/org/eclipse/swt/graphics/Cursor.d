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

import java.lang.all;


import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Resource;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.PaletteData;

import org.eclipse.swt.internal.gtk.OS;

version(Tango){
    import tango.stdc.string;
} else {
    import core.stdc.string;
}

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
    public GdkCursor* handle;

    static const byte[] APPSTARTING_SRC = [ cast(byte)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00,
        0x0c, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x3c, 0x00, 0x00, 0x00,
        0x7c, 0x00, 0x00, 0x00, cast(byte)0xfc, 0x00, 0x00, 0x00, cast(byte)0xfc, 0x01, 0x00, 0x00,
        cast(byte)0xfc, 0x3b, 0x00, 0x00, 0x7c, 0x38, 0x00, 0x00, 0x6c, 0x54, 0x00, 0x00,
        cast(byte)0xc4, cast(byte)0xdc, 0x00, 0x00, cast(byte)0xc0, 0x44, 0x00, 0x00, cast(byte)0x80, 0x39, 0x00, 0x00,
        cast(byte)0x80, 0x39, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];

    static const byte[] APPSTARTING_MASK = [ cast(byte)
        0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00,
        0x1e, 0x00, 0x00, 0x00, 0x3e, 0x00, 0x00, 0x00, 0x7e, 0x00, 0x00, 0x00,
        cast(byte)0xfe, 0x00, 0x00, 0x00, cast(byte)0xfe, 0x01, 0x00, 0x00, cast(byte)0xfe, 0x3b, 0x00, 0x00,
        cast(byte)0xfe, 0x7f, 0x00, 0x00, cast(byte)0xfe, 0x7f, 0x00, 0x00, cast(byte)0xfe, cast(byte)0xfe, 0x00, 0x00,
        cast(byte)0xee, cast(byte)0xff, 0x01, 0x00, cast(byte)0xe4, cast(byte)0xff, 0x00, 0x00, cast(byte)0xc0, 0x7f, 0x00, 0x00,
        cast(byte)0xc0, 0x7f, 0x00, 0x00, cast(byte)0x80, 0x39, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];

this (Device device) {
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
    int shape = 0;
    switch (style) {
        case SWT.CURSOR_APPSTARTING:    break;
        case SWT.CURSOR_ARROW:          shape = OS.GDK_LEFT_PTR; break;
        case SWT.CURSOR_WAIT:           shape = OS.GDK_WATCH; break;
        case SWT.CURSOR_CROSS:          shape = OS.GDK_CROSS; break;
        case SWT.CURSOR_HAND:           shape = OS.GDK_HAND2; break;
        case SWT.CURSOR_HELP:           shape = OS.GDK_QUESTION_ARROW; break;
        case SWT.CURSOR_SIZEALL:        shape = OS.GDK_FLEUR; break;
        case SWT.CURSOR_SIZENESW:       shape = OS.GDK_SIZING; break;
        case SWT.CURSOR_SIZENS:         shape = OS.GDK_DOUBLE_ARROW; break;
        case SWT.CURSOR_SIZENWSE:       shape = OS.GDK_SIZING; break;
        case SWT.CURSOR_SIZEWE:         shape = OS.GDK_SB_H_DOUBLE_ARROW; break;
        case SWT.CURSOR_SIZEN:          shape = OS.GDK_TOP_SIDE; break;
        case SWT.CURSOR_SIZES:          shape = OS.GDK_BOTTOM_SIDE; break;
        case SWT.CURSOR_SIZEE:          shape = OS.GDK_RIGHT_SIDE; break;
        case SWT.CURSOR_SIZEW:          shape = OS.GDK_LEFT_SIDE; break;
        case SWT.CURSOR_SIZENE:         shape = OS.GDK_TOP_RIGHT_CORNER; break;
        case SWT.CURSOR_SIZESE:         shape = OS.GDK_BOTTOM_RIGHT_CORNER; break;
        case SWT.CURSOR_SIZESW:         shape = OS.GDK_BOTTOM_LEFT_CORNER; break;
        case SWT.CURSOR_SIZENW:         shape = OS.GDK_TOP_LEFT_CORNER; break;
        case SWT.CURSOR_UPARROW:        shape = OS.GDK_SB_UP_ARROW; break;
        case SWT.CURSOR_IBEAM:          shape = OS.GDK_XTERM; break;
        case SWT.CURSOR_NO:             shape = OS.GDK_X_CURSOR; break;
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    if (shape is 0 && style is SWT.CURSOR_APPSTARTING) {
        handle = createCursor(APPSTARTING_SRC, APPSTARTING_MASK, 32, 32, 2, 2, true);
    } else {
        handle = OS.gdk_cursor_new(shape);
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
        if (!(source.getTransparencyType() is SWT.TRANSPARENCY_MASK)) SWT.error(SWT.ERROR_NULL_ARGUMENT);
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
    source = ImageData.convertMask(source);
    mask = ImageData.convertMask(mask);

    /* Swap the bits in each byte and convert to appropriate scanline pad */
    byte[] sourceData = new byte[source.data.length];
    byte[] maskData = new byte[mask.data.length];
    byte[] data = source.data;
    for (int i = 0; i < data.length; i++) {
        byte s = data[i];
        sourceData[i] = cast(byte)(((s & 0x80) >> 7) |
            ((s & 0x40) >> 5) |
            ((s & 0x20) >> 3) |
            ((s & 0x10) >> 1) |
            ((s & 0x08) << 1) |
            ((s & 0x04) << 3) |
            ((s & 0x02) << 5) |
            ((s & 0x01) << 7));
        sourceData[i] = cast(byte) ~sourceData[i];
    }
    sourceData = ImageData.convertPad(sourceData, source.width, source.height, source.depth, source.scanlinePad, 1);
    data = mask.data;
    for (int i = 0; i < data.length; i++) {
        byte s = data[i];
        maskData[i] = cast(byte)(((s & 0x80) >> 7) |
            ((s & 0x40) >> 5) |
            ((s & 0x20) >> 3) |
            ((s & 0x10) >> 1) |
            ((s & 0x08) << 1) |
            ((s & 0x04) << 3) |
            ((s & 0x02) << 5) |
            ((s & 0x01) << 7));
        maskData[i] = cast(byte) ~maskData[i];
    }
    maskData = ImageData.convertPad(maskData, mask.width, mask.height, mask.depth, mask.scanlinePad, 1);
    handle = createCursor(maskData, sourceData, source.width, source.height, hotspotX, hotspotY, true);
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
    if (hotspotX >= source.width || hotspotX < 0 ||
        hotspotY >= source.height || hotspotY < 0) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    GdkDisplay* display;
    if (OS.GTK_VERSION >= OS.buildVERSION(2, 4, 0) && OS.gdk_display_supports_cursor_color(display = OS.gdk_display_get_default ())) {
        int width = source.width;
        int height = source.height;
        PaletteData palette = source.palette;
        auto pixbuf = OS.gdk_pixbuf_new(OS.GDK_COLORSPACE_RGB, true, 8, width, height);
        if (pixbuf is null) SWT.error(SWT.ERROR_NO_HANDLES);
        int stride = OS.gdk_pixbuf_get_rowstride(pixbuf);
        auto data = OS.gdk_pixbuf_get_pixels(pixbuf);
        byte[] buffer = source.data;
        if (!palette.isDirect || source.depth !is 24 || stride !is source.bytesPerLine || palette.redMask !is 0xFF000000 || palette.greenMask !is 0xFF0000 || palette.blueMask !is 0xFF00) {
            buffer = new byte[source.width * source.height * 4];
            if (palette.isDirect) {
                ImageData.blit(ImageData.BLIT_SRC,
                    source.data, source.depth, source.bytesPerLine, source.getByteOrder(), 0, 0, source.width, source.height, palette.redMask, palette.greenMask, palette.blueMask,
                    ImageData.ALPHA_OPAQUE, null, 0, 0, 0,
                    buffer, 32, source.width * 4, ImageData.MSB_FIRST, 0, 0, source.width, source.height, 0xFF000000, 0xFF0000, 0xFF00,
                    false, false);
            } else {
                RGB[] rgbs = palette.getRGBs();
                auto length = rgbs.length;
                byte[] srcReds = new byte[length];
                byte[] srcGreens = new byte[length];
                byte[] srcBlues = new byte[length];
                for (int i = 0; i < rgbs.length; i++) {
                    RGB rgb = rgbs[i];
                    if (rgb is null) continue;
                    srcReds[i] = cast(byte)rgb.red;
                    srcGreens[i] = cast(byte)rgb.green;
                    srcBlues[i] = cast(byte)rgb.blue;
                }
                ImageData.blit(ImageData.BLIT_SRC,
                    source.data, source.depth, source.bytesPerLine, source.getByteOrder(), 0, 0, source.width, source.height, srcReds, srcGreens, srcBlues,
                    ImageData.ALPHA_OPAQUE, null, 0, 0, 0,
                    buffer, 32, source.width * 4, ImageData.MSB_FIRST, 0, 0, source.width, source.height, 0xFF000000, 0xFF0000, 0xFF00,
                    false, false);
            }
            if (source.maskData !is null || source.transparentPixel !is -1) {
                ImageData mask = source.getTransparencyMask();
                byte[] maskData = mask.data;
                int maskBpl = mask.bytesPerLine;
                int offset = 3, maskOffset = 0;
                for (int y = 0; y<source.height; y++) {
                    for (int x = 0; x<source.width; x++) {
                        buffer[offset] = ((maskData[maskOffset + (x >> 3)]) & (1 << (7 - (x & 0x7)))) !is 0 ? cast(byte)0xff : 0;
                        offset += 4;
                    }
                    maskOffset += maskBpl;
                }
            } else if (source.alpha !is -1) {
                byte alpha = cast(byte)source.alpha;
                for (int i=3; i<buffer.length; i+=4) {
                    buffer[i] = alpha;
                }
            } else if (source.alphaData !is null) {
                byte[] alphaData = source.alphaData;
                for (int i=3; i<buffer.length; i+=4) {
                    buffer[i] = alphaData[i/4];
                }
            }
        }
        memmove(data, buffer.ptr, stride * height);
        handle = OS.gdk_cursor_new_from_pixbuf(display, pixbuf, hotspotX, hotspotY);
        OS.g_object_unref(pixbuf);
    } else {

        ImageData mask = source.getTransparencyMask();

        /* Ensure depth is equal to 1 */
        if (source.depth > 1) {
            /* Create a destination image with no data */
            ImageData newSource = new ImageData(
                source.width, source.height, 1, ImageData.bwPalette(),
                1, null, 0, null, null, -1, -1, 0, 0, 0, 0, 0);

            byte[] newReds = [ cast(byte)0, cast(byte)255 ], newGreens = newReds, newBlues = newReds;

            /* Convert the source to a black and white image of depth 1 */
            PaletteData palette = source.palette;
            if (palette.isDirect) {
                ImageData.blit(ImageData.BLIT_SRC,
                        source.data, source.depth, source.bytesPerLine, source.getByteOrder(), 0, 0, source.width, source.height, palette.redMask, palette.greenMask, palette.blueMask,
                        ImageData.ALPHA_OPAQUE, null, 0, 0, 0,
                        newSource.data, newSource.depth, newSource.bytesPerLine, newSource.getByteOrder(), 0, 0, newSource.width, newSource.height, newReds, newGreens, newBlues,
                        false, false);
            } else {
                RGB[] rgbs = palette.getRGBs();
                auto length = rgbs.length;
                byte[] srcReds = new byte[length];
                byte[] srcGreens = new byte[length];
                byte[] srcBlues = new byte[length];
                for (int i = 0; i < rgbs.length; i++) {
                    RGB rgb = rgbs[i];
                    if (rgb is null) continue;
                    srcReds[i] = cast(byte)rgb.red;
                    srcGreens[i] = cast(byte)rgb.green;
                    srcBlues[i] = cast(byte)rgb.blue;
                }
                ImageData.blit(ImageData.BLIT_SRC,
                        source.data, source.depth, source.bytesPerLine, source.getByteOrder(), 0, 0, source.width, source.height, srcReds, srcGreens, srcBlues,
                        ImageData.ALPHA_OPAQUE, null, 0, 0, 0,
                        newSource.data, newSource.depth, newSource.bytesPerLine, newSource.getByteOrder(), 0, 0, newSource.width, newSource.height, newReds, newGreens, newBlues,
                        false, false);
            }
            source = newSource;
        }

        /* Swap the bits in each byte and convert to appropriate scanline pad */
        byte[] sourceData = new byte[source.data.length];
        byte[] maskData = new byte[mask.data.length];
        byte[] data = source.data;
        for (int i = 0; i < data.length; i++) {
            byte s = data[i];
            sourceData[i] = cast(byte)(((s & 0x80) >> 7) |
                ((s & 0x40) >> 5) |
                ((s & 0x20) >> 3) |
                ((s & 0x10) >> 1) |
                ((s & 0x08) << 1) |
                ((s & 0x04) << 3) |
                ((s & 0x02) << 5) |
                ((s & 0x01) << 7));
        }
        sourceData = ImageData.convertPad(sourceData, source.width, source.height, source.depth, source.scanlinePad, 1);
        data = mask.data;
        for (int i = 0; i < data.length; i++) {
            byte s = data[i];
            maskData[i] = cast(byte)(((s & 0x80) >> 7) |
                ((s & 0x40) >> 5) |
                ((s & 0x20) >> 3) |
                ((s & 0x10) >> 1) |
                ((s & 0x08) << 1) |
                ((s & 0x04) << 3) |
                ((s & 0x02) << 5) |
                ((s & 0x01) << 7));
        }
        maskData = ImageData.convertPad(maskData, mask.width, mask.height, mask.depth, mask.scanlinePad, 1);
        handle = createCursor(sourceData, maskData, source.width, source.height, hotspotX, hotspotY, false);
    }
    if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
    init_();
}

GdkCursor* createCursor(in byte[] sourceData, in byte[] maskData, int width, int height, int hotspotX, int hotspotY, bool reverse) {
    auto sourcePixmap = OS.gdk_bitmap_create_from_data(null, cast(char*)sourceData.ptr, width, height);
    auto maskPixmap = OS.gdk_bitmap_create_from_data(null, cast(char*)maskData.ptr, width, height);
    GdkCursor* cursor = null;
    if (sourcePixmap !is null && maskPixmap !is null) {
        GdkColor* foreground = new GdkColor();
        if (!reverse) foreground.red = foreground.green = foreground.blue = 0xFFFF;
        GdkColor* background = new GdkColor();
        if (reverse) background.red = background.green = background.blue = 0xFFFF;
        cursor = OS.gdk_cursor_new_from_pixmap (cast(GdkPixmap*)sourcePixmap, cast(GdkPixmap*)maskPixmap, foreground, background, hotspotX, hotspotY);
    }
    if (sourcePixmap !is null) OS.g_object_unref (sourcePixmap);
    if (maskPixmap !is null) OS.g_object_unref (maskPixmap);
    return cursor;
}

override
void destroy() {
    OS.gdk_cursor_destroy(handle);
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
    if ( auto cursor = cast(Cursor)object ){
        return device is cursor.device && handle is cursor.handle;
    }
    return false;
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
 *
 * @private
 */
public static Cursor gtk_new(Device device, GdkCursor* handle) {
    Cursor cursor = new Cursor(device);
    cursor.handle = handle;
    return cursor;
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
    if (isDisposed()) return "Cursor {*DISPOSED*}";
    return Format( "Cursor {{{}}", handle );
}

}
