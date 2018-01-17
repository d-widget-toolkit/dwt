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
module org.eclipse.swt.graphics.Pattern;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.gdip.Gdip;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.graphics.Resource;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.Image;

import java.lang.all;

/**
 * Instances of this class represent patterns to use while drawing. Patterns
 * can be specified either as bitmaps or gradients.
 * <p>
 * Application code must explicitly invoke the <code>Pattern.dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required.
 * </p>
 * <p>
 * This class requires the operating system's advanced graphics subsystem
 * which may not be available on some platforms.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#path">Path, Pattern snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: GraphicsExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.1
 */
public class Pattern : Resource {
    alias Resource.init_ init_;
    /**
     * the OS resource for the Pattern
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public Gdip.Brush handle;

/**
 * Constructs a new Pattern given an image. Drawing with the resulting
 * pattern will cause the image to be tiled over the resulting area.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param device the device on which to allocate the pattern
 * @param image the image that the pattern will draw
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the device is null and there is no current device, or the image is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle for the pattern could not be obtained</li>
 * </ul>
 *
 * @see #dispose()
 */
public this(Device device, Image image) {
    super(device);
    if (image is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (image.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    this.device.checkGDIP();
    ptrdiff_t [] gdipImage = image.createGdipImage();
    auto img = cast(Gdip.Image) gdipImage[0];
    int width = Gdip.Image_GetWidth(img);
    int height = Gdip.Image_GetHeight(img);
    handle = cast(Gdip.Brush)Gdip.TextureBrush_new(img, Gdip.WrapModeTile, 0, 0, width, height);
    Gdip.Bitmap_delete( cast(Gdip.Bitmap)img);
    if (gdipImage[1] !is 0) {
        auto hHeap = OS.GetProcessHeap ();
        OS.HeapFree(hHeap, 0, cast(void*)gdipImage[1]);
    }
    if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
    init_();
}

/**
 * Constructs a new Pattern that represents a linear, two color
 * gradient. Drawing with the pattern will cause the resulting area to be
 * tiled with the gradient specified by the arguments.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param device the device on which to allocate the pattern
 * @param x1 the x coordinate of the starting corner of the gradient
 * @param y1 the y coordinate of the starting corner of the gradient
 * @param x2 the x coordinate of the ending corner of the gradient
 * @param y2 the y coordinate of the ending corner of the gradient
 * @param color1 the starting color of the gradient
 * @param color2 the ending color of the gradient
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the device is null and there is no current device,
 *                              or if either color1 or color2 is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if either color1 or color2 has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle for the pattern could not be obtained</li>
 * </ul>
 *
 * @see #dispose()
 */
public this(Device device, float x1, float y1, float x2, float y2, Color color1, Color color2) {
    this(device, x1, y1, x2, y2, color1, 0xFF, color2, 0xFF);
}

/**
 * Constructs a new Pattern that represents a linear, two color
 * gradient. Drawing with the pattern will cause the resulting area to be
 * tiled with the gradient specified by the arguments.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param device the device on which to allocate the pattern
 * @param x1 the x coordinate of the starting corner of the gradient
 * @param y1 the y coordinate of the starting corner of the gradient
 * @param x2 the x coordinate of the ending corner of the gradient
 * @param y2 the y coordinate of the ending corner of the gradient
 * @param color1 the starting color of the gradient
 * @param alpha1 the starting alpha value of the gradient
 * @param color2 the ending color of the gradient
 * @param alpha2 the ending alpha value of the gradient
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the device is null and there is no current device,
 *                              or if either color1 or color2 is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if either color1 or color2 has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle for the pattern could not be obtained</li>
 * </ul>
 *
 * @see #dispose()
 *
 * @since 3.2
 */
public this(Device device, float x1, float y1, float x2, float y2, Color color1, int alpha1, Color color2, int alpha2) {
    super(device);
    if (color1 is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (color1.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (color2 is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (color2.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    this.device.checkGDIP();
    auto colorRef1 = color1.handle;
    int rgb = ((colorRef1 >> 16) & 0xFF) | (colorRef1 & 0xFF00) | ((colorRef1 & 0xFF) << 16);
    auto foreColor = Gdip.Color_new((alpha1 & 0xFF) << 24 | rgb);
    if (x1 is x2 && y1 is y2) {
        handle = cast(Gdip.Brush)Gdip.SolidBrush_new(foreColor);
        if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
    } else {
        auto colorRef2 = color2.handle;
        rgb = ((colorRef2 >> 16) & 0xFF) | (colorRef2 & 0xFF00) | ((colorRef2 & 0xFF) << 16);
        auto backColor = Gdip.Color_new((alpha2 & 0xFF) << 24 | rgb);
        Gdip.PointF p1;
        p1.X = x1;
        p1.Y = y1;
        Gdip.PointF p2;
        p2.X = x2;
        p2.Y = y2;
        handle = cast(Gdip.Brush)Gdip.LinearGradientBrush_new(p1, p2, foreColor, backColor);
        if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
        if (alpha1 != 0xFF || alpha2 !is 0xFF) {
            int a = cast(int)((alpha1 & 0xFF) * 0.5f + (alpha2 & 0xFF) * 0.5f);
            int r = cast(int)(((colorRef1 & 0xFF) >> 0) * 0.5f + ((colorRef2 & 0xFF) >> 0) * 0.5f);
            int g = cast(int)(((colorRef1 & 0xFF00) >> 8) * 0.5f + ((colorRef2 & 0xFF00) >> 8) * 0.5f);
            int b = cast(int)(((colorRef1 & 0xFF0000) >> 16) * 0.5f + ((colorRef2 & 0xFF0000) >> 16) * 0.5f);
            auto midColor = Gdip.Color_new(a << 24 | r << 16 | g << 8 | b);
            Gdip.ARGB[3] c;
            c[0] = foreColor;
            c[1] = midColor;
            c[2] = backColor;
            float[3] f;
            f[0] = 0;
            f[1] = 0.5f;
            f[2] = 1;
            Gdip.LinearGradientBrush_SetInterpolationColors( cast(Gdip.LinearGradientBrush)handle, c.ptr, f.ptr, 3);
            Gdip.Color_delete(midColor);
        }
        Gdip.Color_delete(backColor);
    }
    Gdip.Color_delete(foreColor);
    init_();
}

override
void destroy() {
    int type = Gdip.Brush_GetType(handle);
    switch (type) {
        case Gdip.BrushTypeSolidColor:
            Gdip.SolidBrush_delete(cast(Gdip.SolidBrush)handle);
            break;
        case Gdip.BrushTypeHatchFill:
            Gdip.HatchBrush_delete(cast(Gdip.HatchBrush)handle);
            break;
        case Gdip.BrushTypeLinearGradient:
            Gdip.LinearGradientBrush_delete(cast(Gdip.LinearGradientBrush)handle);
            break;
        case Gdip.BrushTypeTextureFill:
            Gdip.TextureBrush_delete(cast(Gdip.TextureBrush)handle);
            break;
        default:
    }
    handle = null;
}

/**
 * Returns <code>true</code> if the Pattern has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the Pattern.
 * When a Pattern has been disposed, it is an error to
 * invoke any other method using the Pattern.
 *
 * @return <code>true</code> when the Pattern is disposed, and <code>false</code> otherwise
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
override public String toString() {
    if (isDisposed()) return "Pattern {*DISPOSED*}";
    return Format( "Pattern {{{}}", handle );
}

}
