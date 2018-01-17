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
module org.eclipse.swt.graphics.GC;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.Compatibility;
import org.eclipse.swt.internal.gdip.Gdip;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Drawable;
import org.eclipse.swt.graphics.Resource;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.FontMetrics;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.Path;
import org.eclipse.swt.graphics.Pattern;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Region;
import org.eclipse.swt.graphics.Resource;
import org.eclipse.swt.graphics.Transform;
import org.eclipse.swt.graphics.LineAttributes;

import java.lang.all;

/**
 * Class <code>GC</code> is where all of the drawing capabilities that are
 * supported by SWT are located. Instances are used to draw on either an
 * <code>Image</code>, a <code>Control</code>, or directly on a <code>Display</code>.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>LEFT_TO_RIGHT, RIGHT_TO_LEFT</dd>
 * </dl>
 *
 * <p>
 * The SWT drawing coordinate system is the two-dimensional space with the origin
 * (0,0) at the top left corner of the drawing area and with (x,y) values increasing
 * to the right and downward respectively.
 * </p>
 *
 * <p>
 * Application code must explicitly invoke the <code>GC.dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required. This is <em>particularly</em>
 * important on Windows95 and Windows98 where the operating system has a limited
 * number of device contexts available.
 * </p>
 *
 * <p>
 * Note: Only one of LEFT_TO_RIGHT and RIGHT_TO_LEFT may be specified.
 * </p>
 *
 * @see org.eclipse.swt.events.PaintEvent
 * @see <a href="http://www.eclipse.org/swt/snippets/#gc">GC snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Examples: GraphicsExample, PaintExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public final class GC : Resource {

    alias Resource.init_ init_;

    /**
     * the handle to the OS device context
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public HDC handle;

    Drawable drawable;
    GCData data;

    static const int FOREGROUND = 1 << 0;
    static const int BACKGROUND = 1 << 1;
    static const int FONT = 1 << 2;
    static const int LINE_STYLE = 1 << 3;
    static const int LINE_WIDTH = 1 << 4;
    static const int LINE_CAP = 1 << 5;
    static const int LINE_JOIN = 1 << 6;
    static const int LINE_MITERLIMIT = 1 << 7;
    static const int FOREGROUND_TEXT = 1 << 8;
    static const int BACKGROUND_TEXT = 1 << 9;
    static const int BRUSH = 1 << 10;
    static const int PEN = 1 << 11;
    static const int NULL_BRUSH = 1 << 12;
    static const int NULL_PEN = 1 << 13;
    static const int DRAW_OFFSET = 1 << 14;

    static const int DRAW = FOREGROUND | LINE_STYLE | LINE_WIDTH | LINE_CAP | LINE_JOIN | LINE_MITERLIMIT | PEN | NULL_BRUSH | DRAW_OFFSET;
    static const int FILL = BACKGROUND | BRUSH | NULL_PEN;

    static const float[] LINE_DOT_ZERO = [3, 3];
    static const float[] LINE_DASH_ZERO = [18, 6];
    static const float[] LINE_DASHDOT_ZERO = [9, 6, 3, 6];
    static const float[] LINE_DASHDOTDOT_ZERO = [9, 3, 3, 3, 3, 3];

/**
 * Prevents uninitialized instances from being created outside the package.
 */
this() {
}

/**
 * Constructs a new instance of this class which has been
 * configured to draw on the specified drawable. Sets the
 * foreground color, background color and font in the GC
 * to match those in the drawable.
 * <p>
 * You must dispose the graphics context when it is no longer required.
 * </p>
 * @param drawable the drawable to draw on
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the drawable is null</li>
 *    <li>ERROR_NULL_ARGUMENT - if there is no current device</li>
 *    <li>ERROR_INVALID_ARGUMENT
 *          - if the drawable is an image that is not a bitmap or an icon
 *          - if the drawable is an image or printer that is already selected
 *            into another graphics context</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for GC creation</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS if not called from the thread that created the drawable</li>
 * </ul>
 */
public this(Drawable drawable) {
    this(drawable, SWT.NONE);
}

/**
 * Constructs a new instance of this class which has been
 * configured to draw on the specified drawable. Sets the
 * foreground color, background color and font in the GC
 * to match those in the drawable.
 * <p>
 * You must dispose the graphics context when it is no longer required.
 * </p>
 *
 * @param drawable the drawable to draw on
 * @param style the style of GC to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the drawable is null</li>
 *    <li>ERROR_NULL_ARGUMENT - if there is no current device</li>
 *    <li>ERROR_INVALID_ARGUMENT
 *          - if the drawable is an image that is not a bitmap or an icon
 *          - if the drawable is an image or printer that is already selected
 *            into another graphics context</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for GC creation</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS if not called from the thread that created the drawable</li>
 * </ul>
 *
 * @since 2.1.2
 */
public this(Drawable drawable, int style) {
    if (drawable is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    GCData data = new GCData ();
    data.style = checkStyle(style);
    auto hDC = drawable.internal_new_GC(data);
    Device device = data.device;
    if (device is null) device = Device.getDevice();
    if (device is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    this.device = data.device = device;
    init_ (drawable, data, hDC);
    init_();
}

static int checkStyle(int style) {
    if ((style & SWT.LEFT_TO_RIGHT) !is 0) style &= ~SWT.RIGHT_TO_LEFT;
    return style & (SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT);
}

void checkGC(int mask) {
    int state = data.state;
    if ((state & mask) is mask) return;
    state = (state ^ mask) & mask;
    data.state |= mask;
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        auto pen = data.gdipPen;
        float width = data.lineWidth;
        if ((state & FOREGROUND) !is 0 || (pen is null && (state & (LINE_WIDTH | LINE_STYLE | LINE_MITERLIMIT | LINE_JOIN | LINE_CAP)) !is 0)) {
            if (data.gdipFgBrush !is null) Gdip.SolidBrush_delete(data.gdipFgBrush);
            data.gdipFgBrush = null;
            Gdip.Brush brush;
            Pattern pattern = data.foregroundPattern;
            if (pattern !is null) {
                brush = pattern.handle;
                if ((data.style & SWT.MIRRORED) !is 0) {
                    switch (Gdip.Brush_GetType(brush)) {
                        case Gdip.BrushTypeTextureFill:
                            brush = Gdip.Brush_Clone(brush);
                            if (brush is null) SWT.error(SWT.ERROR_NO_HANDLES);
                            Gdip.TextureBrush_ScaleTransform( cast(Gdip.TextureBrush) brush, -1, 1, Gdip.MatrixOrderPrepend);
                            data.gdipFgBrush = cast(Gdip.SolidBrush)brush;
                            break;
                        default:
                            break;
                    }
                }
            } else {
                auto foreground = data.foreground;
                int rgb = ((foreground >> 16) & 0xFF) | (foreground & 0xFF00) | ((foreground & 0xFF) << 16);
                auto color = Gdip.Color_new(data.alpha << 24 | rgb);
                if (color is 0) SWT.error(SWT.ERROR_NO_HANDLES);
                brush = cast(Gdip.Brush) Gdip.SolidBrush_new(color);
                if (brush is null) SWT.error(SWT.ERROR_NO_HANDLES);
                Gdip.Color_delete(color);
                data.gdipFgBrush = cast(Gdip.SolidBrush)brush;
            }
            if (pen !is null) {
                Gdip.Pen_SetBrush(pen, brush);
            } else {
                pen = data.gdipPen = Gdip.Pen_new(brush, width);
            }
        }
        if ((state & LINE_WIDTH) !is 0) {
            Gdip.Pen_SetWidth(pen, width);
            switch (data.lineStyle) {
                case SWT.LINE_CUSTOM:
                    state |= LINE_STYLE;
                    break;
                default:
                    break;
            }
        }
        if ((state & LINE_STYLE) !is 0) {
            TryConst!(float)[] dashes = null;
            float dashOffset = 0;
            int dashStyle = Gdip.DashStyleSolid;
            switch (data.lineStyle) {
                case SWT.LINE_SOLID: break;
                case SWT.LINE_DOT: dashStyle = Gdip.DashStyleDot; if (width is 0) dashes = LINE_DOT_ZERO; break;
                case SWT.LINE_DASH: dashStyle = Gdip.DashStyleDash; if (width is 0) dashes = LINE_DASH_ZERO; break;
                case SWT.LINE_DASHDOT: dashStyle = Gdip.DashStyleDashDot; if (width is 0) dashes = LINE_DASHDOT_ZERO; break;
                case SWT.LINE_DASHDOTDOT: dashStyle = Gdip.DashStyleDashDotDot; if (width is 0) dashes = LINE_DASHDOTDOT_ZERO; break;
                case SWT.LINE_CUSTOM: {
                    if (data.lineDashes !is null) {
                        dashOffset = data.lineDashesOffset / Math.max (1.0f, width);
                        float[] dashes_ = new float[data.lineDashes.length * 2];
                        for (int i = 0; i < data.lineDashes.length; i++) {
                            float dash = data.lineDashes[i] / Math.max (1.0f, width);
                            dashes_[i] = dash;
                            dashes_[i + data.lineDashes.length] = dash;
                        }
                        dashes = dashes_;
                    }
                    break;
                }
                default:
                    break;
            }
            if (dashes !is null) {
                Gdip.Pen_SetDashPattern(pen, dashes.ptr, cast(int)/*64bit*/dashes.length);
                Gdip.Pen_SetDashStyle(pen, Gdip.DashStyleCustom);
                Gdip.Pen_SetDashOffset(pen, dashOffset);
            } else {
                Gdip.Pen_SetDashStyle(pen, dashStyle);
            }
        }
        if ((state & LINE_MITERLIMIT) !is 0) {
            Gdip.Pen_SetMiterLimit(pen, data.lineMiterLimit);
        }
        if ((state & LINE_JOIN) !is 0) {
            int joinStyle = 0;
            switch (data.lineJoin) {
                case SWT.JOIN_MITER: joinStyle = Gdip.LineJoinMiter; break;
                case SWT.JOIN_BEVEL: joinStyle = Gdip.LineJoinBevel; break;
                case SWT.JOIN_ROUND: joinStyle = Gdip.LineJoinRound; break;
                default:
            }
            Gdip.Pen_SetLineJoin(pen, joinStyle);
        }
        if ((state & LINE_CAP) !is 0) {
            int dashCap = Gdip.DashCapFlat, capStyle = 0;
            switch (data.lineCap) {
                case SWT.CAP_FLAT: capStyle = Gdip.LineCapFlat; break;
                case SWT.CAP_ROUND: capStyle = Gdip.LineCapRound; dashCap = Gdip.DashCapRound; break;
                case SWT.CAP_SQUARE: capStyle = Gdip.LineCapSquare; break;
                default:
            }
            Gdip.Pen_SetLineCap(pen, capStyle, capStyle, dashCap);
        }
        if ((state & BACKGROUND) !is 0) {
            if (data.gdipBgBrush !is null) Gdip.SolidBrush_delete(data.gdipBgBrush);
            data.gdipBgBrush = null;
            Pattern pattern = data.backgroundPattern;
            if (pattern !is null) {
                data.gdipBrush = pattern.handle;
                if ((data.style & SWT.MIRRORED) !is 0) {
                    switch (Gdip.Brush_GetType(data.gdipBrush)) {
                        case Gdip.BrushTypeTextureFill:
                            auto brush = Gdip.Brush_Clone(data.gdipBrush);
                            if (brush is null) SWT.error(SWT.ERROR_NO_HANDLES);
                            Gdip.TextureBrush_ScaleTransform( cast(Gdip.TextureBrush)brush, -1, 1, Gdip.MatrixOrderPrepend);
                            data.gdipBrush = brush;
                            data.gdipBgBrush = cast(Gdip.SolidBrush) brush;
                            break;
                        default:
                            break;
                    }
                }
            } else {
                auto background = data.background;
                int rgb = ((background >> 16) & 0xFF) | (background & 0xFF00) | ((background & 0xFF) << 16);
                auto color = Gdip.Color_new(data.alpha << 24 | rgb);
                // if (color is null) SWT.error(SWT.ERROR_NO_HANDLES);
                auto brush = Gdip.SolidBrush_new(color);
                if (brush is null) SWT.error(SWT.ERROR_NO_HANDLES);
                Gdip.Color_delete(color);
                data.gdipBrush = cast(Gdip.Brush)brush;
                data.gdipBgBrush = brush;
            }
        }
        if ((state & FONT) !is 0) {
            Font font = data.font;
            OS.SelectObject(handle, font.handle);
            auto gdipFont = createGdipFont(handle, font.handle);
            if (data.gdipFont !is null) Gdip.Font_delete(data.gdipFont);
            data.gdipFont = gdipFont;
        }
        if ((state & DRAW_OFFSET) !is 0) {
            data.gdipXOffset = data.gdipYOffset = 0;
            auto matrix = Gdip.Matrix_new(1, 0, 0, 1, 0, 0);
            float[2] point; point[0]=1.0; point[1]=1.0;
            Gdip.Graphics_GetTransform(gdipGraphics, matrix);
            Gdip.Matrix_TransformPoints(matrix, cast(Gdip.PointF*)point.ptr, 1);
            Gdip.Matrix_delete(matrix);
            float scaling = point[0];
            if (scaling < 0) scaling = -scaling;
            float penWidth = data.lineWidth * scaling;
            if (penWidth is 0 || (cast(int)penWidth % 2) is 1) {
                data.gdipXOffset = 0.5f / scaling;
            }
            scaling = point[1];
            if (scaling < 0) scaling = -scaling;
            penWidth = data.lineWidth * scaling;
            if (penWidth is 0 || (cast(int)penWidth % 2) is 1) {
                data.gdipYOffset = 0.5f / scaling;
            }
        }
        return;
    }
    if ((state & (FOREGROUND | LINE_CAP | LINE_JOIN | LINE_STYLE | LINE_WIDTH)) !is 0) {
        int color = data.foreground;
        int width = cast(int)data.lineWidth;
        uint[] dashes = null;
        int lineStyle = OS.PS_SOLID;
        switch (data.lineStyle) {
            case SWT.LINE_SOLID: break;
            case SWT.LINE_DASH: lineStyle = OS.PS_DASH; break;
            case SWT.LINE_DOT: lineStyle = OS.PS_DOT; break;
            case SWT.LINE_DASHDOT: lineStyle = OS.PS_DASHDOT; break;
            case SWT.LINE_DASHDOTDOT: lineStyle = OS.PS_DASHDOTDOT; break;
            case SWT.LINE_CUSTOM: {
                if (data.lineDashes !is null) {
                    lineStyle = OS.PS_USERSTYLE;
                    dashes = new uint[data.lineDashes.length];
                    for (int i = 0; i < dashes.length; i++) {
                        dashes[i] = cast(int)data.lineDashes[i];
                    }
                }
                break;
            }
            default:
        }
        if ((state & LINE_STYLE) !is 0) {
            OS.SetBkMode(handle, data.lineStyle is SWT.LINE_SOLID ? OS.OPAQUE : OS.TRANSPARENT);
        }
        int joinStyle = 0;
        switch (data.lineJoin) {
            case SWT.JOIN_MITER: joinStyle = OS.PS_JOIN_MITER; break;
            case SWT.JOIN_ROUND: joinStyle = OS.PS_JOIN_ROUND; break;
            case SWT.JOIN_BEVEL: joinStyle = OS.PS_JOIN_BEVEL; break;
            default:
        }
        int capStyle = 0;
        switch (data.lineCap) {
            case SWT.CAP_ROUND: capStyle = OS.PS_ENDCAP_ROUND; break;
            case SWT.CAP_FLAT: capStyle = OS.PS_ENDCAP_FLAT; break;
            case SWT.CAP_SQUARE: capStyle = OS.PS_ENDCAP_SQUARE;break;
            default:
        }
        int style = lineStyle | joinStyle | capStyle;
        /*
        * Feature in Windows.  Windows does not honour line styles other then
        * PS_SOLID for pens wider than 1 pixel created with CreatePen().  The fix
        * is to use ExtCreatePen() instead.
        */
        HPEN newPen;
        if (OS.IsWinCE || (width is 0 && lineStyle !is OS.PS_USERSTYLE) || style is 0) {
            newPen = OS.CreatePen(style & OS.PS_STYLE_MASK, width, color);
        } else {
            LOGBRUSH logBrush;
            logBrush.lbStyle = OS.BS_SOLID;
            logBrush.lbColor = color;
            /* Feature in Windows. PS_GEOMETRIC pens cannot have zero width. */
            newPen = OS.ExtCreatePen (style | OS.PS_GEOMETRIC, Math.max(1, width), &logBrush, dashes !is null ? cast(int)/*64bit*/dashes.length : 0, dashes.ptr);
        }
        OS.SelectObject(handle, newPen);
        data.state |= PEN;
        data.state &= ~NULL_PEN;
        if (data.hPen !is null) OS.DeleteObject(data.hPen);
        data.hPen = data.hOldPen = newPen;
    } else if ((state & PEN) !is 0) {
        OS.SelectObject(handle, data.hOldPen);
        data.state &= ~NULL_PEN;
    } else if ((state & NULL_PEN) !is 0) {
        data.hOldPen = OS.SelectObject(handle, OS.GetStockObject(OS.NULL_PEN));
        data.state &= ~PEN;
    }
    if ((state & BACKGROUND) !is 0) {
        auto newBrush = OS.CreateSolidBrush(data.background);
        OS.SelectObject(handle, newBrush);
        data.state |= BRUSH;
        data.state &= ~NULL_BRUSH;
        if (data.hBrush !is null) OS.DeleteObject(data.hBrush);
        data.hOldBrush = data.hBrush = newBrush;
    } else if ((state & BRUSH) !is 0) {
        OS.SelectObject(handle, data.hOldBrush);
        data.state &= ~NULL_BRUSH;
    } else if ((state & NULL_BRUSH) !is 0) {
        data.hOldBrush = OS.SelectObject(handle, OS.GetStockObject(OS.NULL_BRUSH));
        data.state &= ~BRUSH;
    }
    if ((state & BACKGROUND_TEXT) !is 0) {
        OS.SetBkColor(handle, data.background);
    }
    if ((state & FOREGROUND_TEXT) !is 0) {
        OS.SetTextColor(handle, data.foreground);
    }
    if ((state & FONT) !is 0) {
        Font font = data.font;
        OS.SelectObject(handle, font.handle);
    }
}

/**
 * Copies a rectangular area of the receiver at the specified
 * position into the image, which must be of type <code>SWT.BITMAP</code>.
 *
 * @param image the image to copy into
 * @param x the x coordinate in the receiver of the area to be copied
 * @param y the y coordinate in the receiver of the area to be copied
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the image is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the image is not a bitmap or has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void copyArea(Image image, int x, int y) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (image is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (image.type !is SWT.BITMAP || image.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);

    /* Copy the bitmap area */
    Rectangle rect = image.getBounds();
    auto memHdc = OS.CreateCompatibleDC(handle);
    auto hOldBitmap = OS.SelectObject(memHdc, image.handle);
    OS.BitBlt(memHdc, 0, 0, rect.width, rect.height, handle, x, y, OS.SRCCOPY);
    OS.SelectObject(memHdc, hOldBitmap);
    OS.DeleteDC(memHdc);
}

/**
 * Copies a rectangular area of the receiver at the source
 * position onto the receiver at the destination position.
 *
 * @param srcX the x coordinate in the receiver of the area to be copied
 * @param srcY the y coordinate in the receiver of the area to be copied
 * @param width the width of the area to copy
 * @param height the height of the area to copy
 * @param destX the x coordinate in the receiver of the area to copy to
 * @param destY the y coordinate in the receiver of the area to copy to
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void copyArea(int srcX, int srcY, int width, int height, int destX, int destY) {
    copyArea(srcX, srcY, width, height, destX, destY, true);
}

/**
 * Copies a rectangular area of the receiver at the source
 * position onto the receiver at the destination position.
 *
 * @param srcX the x coordinate in the receiver of the area to be copied
 * @param srcY the y coordinate in the receiver of the area to be copied
 * @param width the width of the area to copy
 * @param height the height of the area to copy
 * @param destX the x coordinate in the receiver of the area to copy to
 * @param destY the y coordinate in the receiver of the area to copy to
 * @param paint if <code>true</code> paint events will be generated for old and obscured areas
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void copyArea(int srcX, int srcY, int width, int height, int destX, int destY, bool paint) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);

    /*
    * Feature in WinCE.  The function WindowFromDC is not part of the
    * WinCE SDK.  The fix is to remember the HWND.
    */
    auto hwnd = data.hwnd;
    if (hwnd is null) {
        OS.BitBlt(handle, destX, destY, width, height, handle, srcX, srcY, OS.SRCCOPY);
    } else {
        RECT lprcClip;
        auto hrgn = OS.CreateRectRgn(0, 0, 0, 0);
        if (OS.GetClipRgn(handle, hrgn) is 1) {
            OS.GetRgnBox(hrgn, &lprcClip);
        }
        OS.DeleteObject(hrgn);
        RECT lprcScroll;
        OS.SetRect(&lprcScroll, srcX, srcY, srcX + width, srcY + height);
        int flags = paint ? OS.SW_INVALIDATE | OS.SW_ERASE : 0;
        int res = OS.ScrollWindowEx(hwnd, destX - srcX, destY - srcY, &lprcScroll, &lprcClip, null, null, flags);

        /*
        * Feature in WinCE.  ScrollWindowEx does not accept combined
        * vertical and horizontal scrolling.  The fix is to do a
        * BitBlt and invalidate the appropriate source area.
        */
        static if (OS.IsWinCE) {
            if (res is 0) {
                OS.BitBlt(handle, destX, destY, width, height, handle, srcX, srcY, OS.SRCCOPY);
                if (paint) {
                    int deltaX = destX - srcX, deltaY = destY - srcY;
                    bool disjoint = (destX + width < srcX) || (srcX + width < destX) || (destY + height < srcY) || (srcY + height < destY);
                    if (disjoint) {
                        OS.InvalidateRect(hwnd, &lprcScroll, true);
                    } else {
                        if (deltaX !is 0) {
                            int newX = destX - deltaX;
                            if (deltaX < 0) newX = destX + width;
                            OS.SetRect(&lprcScroll, newX, srcY, newX + Math.abs(deltaX), srcY + height);
                            OS.InvalidateRect(hwnd, &lprcScroll, true);
                        }
                        if (deltaY !is 0) {
                            int newY = destY - deltaY;
                            if (deltaY < 0) newY = destY + height;
                            OS.SetRect(&lprcScroll, srcX, newY, srcX + width, newY + Math.abs(deltaY));
                            OS.InvalidateRect(hwnd, &lprcScroll, true);
                        }
                    }
                }
            }
        }
    }
}

static Gdip.Font createGdipFont(HDC hDC, HFONT hFont) {
    auto font = Gdip.Font_new(hDC, hFont);
    if (font is null) SWT.error(SWT.ERROR_NO_HANDLES);
    if (!Gdip.Font_IsAvailable(font)) {
        Gdip.Font_delete(font);
        LOGFONT logFont;
        OS.GetObject(hFont, LOGFONT.sizeof, &logFont);
        int size = Math.abs(logFont.lfHeight);
        int style = Gdip.FontStyleRegular;
        if (logFont.lfWeight is 700) style |= Gdip.FontStyleBold;
        if (logFont.lfItalic !is 0) style |= Gdip.FontStyleItalic;
        wchar[] chars;
        static if (OS.IsUnicode) {
            chars = logFont.lfFaceName;
        } else {
            chars = new wchar[OS.LF_FACESIZE];
            String bytes = logFont.lfFaceName;
            OS.MultiByteToWideChar (OS.CP_ACP, OS.MB_PRECOMPOSED, bytes.ptr, bytes.length, chars, chars.length);
        }
        int index = 0;
        while (index < chars.length) {
            if (chars [index] is 0) break;
            index++;
        }
        String name = WCHARsToStr( chars[ 0 .. index ] );
        if (Compatibility.equalsIgnoreCase(name, "Courier")) { //$NON-NLS-1$
            name = "Courier New"; //$NON-NLS-1$
        }
        font = Gdip.Font_new( StrToWCHARz(name), size, style, Gdip.UnitPixel, null);
    }
    if (font is null) SWT.error(SWT.ERROR_NO_HANDLES);
    return font;
}

static void destroyGdipBrush(Gdip.Brush brush) {
    int type = Gdip.Brush_GetType(brush);
    switch (type) {
        case Gdip.BrushTypeSolidColor:
            Gdip.SolidBrush_delete( cast(Gdip.SolidBrush)brush);
            break;
        case Gdip.BrushTypeHatchFill:
            Gdip.HatchBrush_delete(cast(Gdip.HatchBrush)brush);
            break;
        case Gdip.BrushTypeLinearGradient:
            Gdip.LinearGradientBrush_delete(cast(Gdip.LinearGradientBrush)brush);
            break;
        case Gdip.BrushTypeTextureFill:
            Gdip.TextureBrush_delete(cast(Gdip.TextureBrush)brush);
            break;
        default:
    }
}

/**
 * Disposes of the operating system resources associated with
 * the graphics context. Applications must dispose of all GCs
 * which they allocate.
 *
 * @exception SWTError <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS if not called from the thread that created the drawable</li>
 * </ul>
 */
override
void destroy() {
    bool gdip = data.gdipGraphics !is null;
    disposeGdip();
    if (gdip && (data.style & SWT.MIRRORED) !is 0) {
        OS.SetLayout(handle, OS.GetLayout(handle) | OS.LAYOUT_RTL);
    }

    /* Select stock pen and brush objects and free resources */
    if (data.hPen !is null) {
        OS.SelectObject(handle, OS.GetStockObject(OS.NULL_PEN));
        OS.DeleteObject(data.hPen);
        data.hPen = null;
    }
    if (data.hBrush !is null) {
        OS.SelectObject(handle, OS.GetStockObject(OS.NULL_BRUSH));
        OS.DeleteObject(data.hBrush);
        data.hBrush = null;
    }

    /*
    * Put back the original bitmap into the device context.
    * This will ensure that we have not left a bitmap
    * selected in it when we delete the HDC.
    */
    auto hNullBitmap = data.hNullBitmap;
    if (hNullBitmap !is null) {
        OS.SelectObject(handle, hNullBitmap);
        data.hNullBitmap = null;
    }
    Image image = data.image;
    if (image !is null) image.memGC = null;

    /*
    * Dispose the HDC.
    */
    if (drawable !is null) drawable.internal_dispose_GC(handle, data);
    drawable = null;
    handle = null;
    data.image = null;
    data.ps = null;
    data = null;
}

void disposeGdip() {
    if (data.gdipPen !is null) Gdip.Pen_delete(data.gdipPen);
    if (data.gdipBgBrush !is null) destroyGdipBrush(cast(Gdip.Brush)data.gdipBgBrush);
    if (data.gdipFgBrush !is null) destroyGdipBrush(cast(Gdip.Brush)data.gdipFgBrush);
    if (data.gdipFont !is null) Gdip.Font_delete(data.gdipFont);
    if (data.gdipGraphics !is null) Gdip.Graphics_delete(data.gdipGraphics);
    data.gdipGraphics = null;
    data.gdipBrush = null;
    data.gdipBgBrush = null;
    data.gdipFgBrush = null;
    data.gdipFont = null;
    data.gdipPen = null;
}

/**
 * Draws the outline of a circular or elliptical arc
 * within the specified rectangular area.
 * <p>
 * The resulting arc begins at <code>startAngle</code> and extends
 * for <code>arcAngle</code> degrees, using the current color.
 * Angles are interpreted such that 0 degrees is at the 3 o'clock
 * position. A positive value indicates a counter-clockwise rotation
 * while a negative value indicates a clockwise rotation.
 * </p><p>
 * The center of the arc is the center of the rectangle whose origin
 * is (<code>x</code>, <code>y</code>) and whose size is specified by the
 * <code>width</code> and <code>height</code> arguments.
 * </p><p>
 * The resulting arc covers an area <code>width + 1</code> pixels wide
 * by <code>height + 1</code> pixels tall.
 * </p>
 *
 * @param x the x coordinate of the upper-left corner of the arc to be drawn
 * @param y the y coordinate of the upper-left corner of the arc to be drawn
 * @param width the width of the arc to be drawn
 * @param height the height of the arc to be drawn
 * @param startAngle the beginning angle
 * @param arcAngle the angular extent of the arc, relative to the start angle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawArc (int x, int y, int width, int height, int startAngle, int arcAngle) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(DRAW);
    if (width < 0) {
        x = x + width;
        width = -width;
    }
    if (height < 0) {
        y = y + height;
        height = -height;
    }
    if (width is 0 || height is 0 || arcAngle is 0) return;
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        Gdip.Graphics_TranslateTransform(gdipGraphics, data.gdipXOffset, data.gdipYOffset, Gdip.MatrixOrderPrepend);
        if (width is height) {
            Gdip.Graphics_DrawArc(gdipGraphics, data.gdipPen, x, y, width, height, -startAngle, -arcAngle);
        } else {
            auto path = Gdip.GraphicsPath_new(Gdip.FillModeAlternate);
            if (path is null) SWT.error(SWT.ERROR_NO_HANDLES);
            auto matrix = Gdip.Matrix_new(width, 0, 0, height, x, y);
            if (matrix is null) SWT.error(SWT.ERROR_NO_HANDLES);
            Gdip.GraphicsPath_AddArc(path, 0, 0, 1, 1, -startAngle, -arcAngle);
            Gdip.GraphicsPath_Transform(path, matrix);
            Gdip.Graphics_DrawPath(gdipGraphics, data.gdipPen, path);
            Gdip.Matrix_delete(matrix);
            Gdip.GraphicsPath_delete(path);
        }
        Gdip.Graphics_TranslateTransform(gdipGraphics, -data.gdipXOffset, -data.gdipYOffset, Gdip.MatrixOrderPrepend);
        return;
    }
    if ((data.style & SWT.MIRRORED) !is 0) {
        if (data.lineWidth !is 0 && data.lineWidth % 2 is 0) x--;
    }
    /*
    * Feature in WinCE.  The function Arc is not present in the
    * WinCE SDK.  The fix is to emulate arc drawing by using
    * Polyline.
    */
    static if (OS.IsWinCE) {
        /* compute arc with a simple linear interpolation */
        if (arcAngle < 0) {
            startAngle += arcAngle;
            arcAngle = -arcAngle;
        }
        if (arcAngle > 360) arcAngle = 360;
        int[] points = new int[(arcAngle + 1) * 2];
        int cteX = 2 * x + width;
        int cteY = 2 * y + height;
        int index = 0;
        for (int i = 0; i <= arcAngle; i++) {
            points[index++] = (Compatibility.cos(startAngle + i, width) + cteX) >> 1;
            points[index++] = (cteY - Compatibility.sin(startAngle + i, height)) >> 1;
        }
        OS.Polyline(handle, cast(POINT*)points.ptr, points.length / 2);
    } else {
        int x1, y1, x2, y2,tmp;
        bool isNegative;
        if (arcAngle >= 360 || arcAngle <= -360) {
            x1 = x2 = x + width;
            y1 = y2 = y + height / 2;
        } else {
            isNegative = arcAngle < 0;

            arcAngle = arcAngle + startAngle;
            if (isNegative) {
                // swap angles
                tmp = startAngle;
                startAngle = arcAngle;
                arcAngle = tmp;
            }
            x1 = Compatibility.cos(startAngle, width) + x + width/2;
            y1 = -1 * Compatibility.sin(startAngle, height) + y + height/2;

            x2 = Compatibility.cos(arcAngle, width) + x + width/2;
            y2 = -1 * Compatibility.sin(arcAngle, height) + y + height/2;
        }
        OS.Arc(handle, x, y, x + width + 1, y + height + 1, x1, y1, x2, y2);
    }
}

/**
 * Draws a rectangle, based on the specified arguments, which has
 * the appearance of the platform's <em>focus rectangle</em> if the
 * platform supports such a notion, and otherwise draws a simple
 * rectangle in the receiver's foreground color.
 *
 * @param x the x coordinate of the rectangle
 * @param y the y coordinate of the rectangle
 * @param width the width of the rectangle
 * @param height the height of the rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawRectangle(int, int, int, int)
 */
public void drawFocus (int x, int y, int width, int height) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if ((data.uiState & OS.UISF_HIDEFOCUS) !is 0) return;
    data.focusDrawn = true;
    HDC hdc = handle;
    int state = 0;
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        HRGN clipRgn;
        Gdip.Graphics_SetPixelOffsetMode(gdipGraphics, Gdip.PixelOffsetModeNone);
        auto rgn = Gdip.Region_new();
        if (rgn is null) SWT.error(SWT.ERROR_NO_HANDLES);
        Gdip.Graphics_GetClip(gdipGraphics, rgn);
        if (!Gdip.Region_IsInfinite(rgn, gdipGraphics)) {
            clipRgn = Gdip.Region_GetHRGN(rgn, gdipGraphics);
        }
        Gdip.Region_delete(rgn);
        Gdip.Graphics_SetPixelOffsetMode(gdipGraphics, Gdip.PixelOffsetModeHalf);
        float[6] lpXform;
        bool gotElements = false;
        auto matrix = Gdip.Matrix_new(1, 0, 0, 1, 0, 0);
        if (matrix is null) SWT.error(SWT.ERROR_NO_HANDLES);
        Gdip.Graphics_GetTransform(gdipGraphics, matrix);
        if (!Gdip.Matrix_IsIdentity(matrix)) {
            gotElements = true;
            Gdip.Matrix_GetElements(matrix, lpXform.ptr);
        }
        Gdip.Matrix_delete(matrix);
        hdc = Gdip.Graphics_GetHDC(gdipGraphics);
        state = OS.SaveDC(hdc);
        if (gotElements) {
            OS.SetGraphicsMode(hdc, OS.GM_ADVANCED);
            OS.SetWorldTransform(hdc, cast(XFORM*)lpXform.ptr);
        }
        if (clipRgn !is null) {
            OS.SelectClipRgn(hdc, clipRgn);
            OS.DeleteObject(clipRgn);
        }
    }
    OS.SetBkColor(hdc, 0xFFFFFF);
    OS.SetTextColor(hdc, 0x000000);
    RECT rect;
    OS.SetRect(&rect, x, y, x + width, y + height);
    OS.DrawFocusRect(hdc, &rect);
    if (gdipGraphics !is null) {
        OS.RestoreDC(hdc, state);
        Gdip.Graphics_ReleaseHDC(gdipGraphics, hdc);
    } else {
        data.state &= ~(BACKGROUND_TEXT | FOREGROUND_TEXT);
    }
}

/**
 * Draws the given image in the receiver at the specified
 * coordinates.
 *
 * @param image the image to draw
 * @param x the x coordinate of where to draw
 * @param y the y coordinate of where to draw
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the image is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the given coordinates are outside the bounds of the image</li>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES - if no handles are available to perform the operation</li>
 * </ul>
 */
public void drawImage(Image image, int x, int y) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (image is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    if (image.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    drawImage(image, 0, 0, -1, -1, x, y, -1, -1, true);
}

/**
 * Copies a rectangular area from the source image into a (potentially
 * different sized) rectangular area in the receiver. If the source
 * and destination areas are of differing sizes, then the source
 * area will be stretched or shrunk to fit the destination area
 * as it is copied. The copy fails if any part of the source rectangle
 * lies outside the bounds of the source image, or if any of the width
 * or height arguments are negative.
 *
 * @param image the source image
 * @param srcX the x coordinate in the source image to copy from
 * @param srcY the y coordinate in the source image to copy from
 * @param srcWidth the width in pixels to copy from the source
 * @param srcHeight the height in pixels to copy from the source
 * @param destX the x coordinate in the destination to copy to
 * @param destY the y coordinate in the destination to copy to
 * @param destWidth the width in pixels of the destination rectangle
 * @param destHeight the height in pixels of the destination rectangle
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the image is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 *    <li>ERROR_INVALID_ARGUMENT - if any of the width or height arguments are negative.
 *    <li>ERROR_INVALID_ARGUMENT - if the source rectangle is not contained within the bounds of the source image</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES - if no handles are available to perform the operation</li>
 * </ul>
 */
public void drawImage(Image image, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (srcWidth is 0 || srcHeight is 0 || destWidth is 0 || destHeight is 0) return;
    if (srcX < 0 || srcY < 0 || srcWidth < 0 || srcHeight < 0 || destWidth < 0 || destHeight < 0) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    if (image is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    if (image.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    drawImage(image, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, false);
}

void drawImage(Image srcImage, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight, bool simple) {
    if (data.gdipGraphics !is null) {
        //TODO - cache bitmap
        ptrdiff_t [] gdipImage = srcImage.createGdipImage();
        auto img = cast(Gdip.Image) gdipImage[0];
        int imgWidth = Gdip.Image_GetWidth(img);
        int imgHeight = Gdip.Image_GetHeight(img);
        if (simple) {
            srcWidth = destWidth = imgWidth;
            srcHeight = destHeight = imgHeight;
        } else {
            if (srcX + srcWidth > imgWidth || srcY + srcHeight > imgHeight) {
                SWT.error (SWT.ERROR_INVALID_ARGUMENT);
            }
            simple = srcX is 0 && srcY is 0 &&
                srcWidth is destWidth && destWidth is imgWidth &&
                srcHeight is destHeight && destHeight is imgHeight;
        }
        Gdip.Rect rect;
        rect.X = destX;
        rect.Y = destY;
        rect.Width = destWidth;
        rect.Height = destHeight;
        /*
        * Note that if the wrap mode is not WrapModeTileFlipXY, the scaled image
        * is translucent around the borders.
        */
        auto attrib = Gdip.ImageAttributes_new();
        Gdip.ImageAttributes_SetWrapMode(attrib, Gdip.WrapModeTileFlipXY);
        if (data.alpha != 0xFF) {

            Gdip.ColorMatrix matrix =
            { [ [1,0,0,0,0],
                [0,1,0,0,0],
                [0,0,1,0,0],
                [0,0,0,data.alpha / cast(float)0xFF,0,],
                [0,0,0,0,1] ] };
            /*
            float[] matrix = [ cast(float)
                1,0,0,0,0,
                0,1,0,0,0,
                0,0,1,0,0,
                0,0,0,data.alpha / cast(float)0xFF,0,
                0,0,0,0,1,
            ];*/
            Gdip.ImageAttributes_SetColorMatrix(attrib, matrix, Gdip.ColorMatrixFlagsDefault, Gdip.ColorAdjustTypeBitmap);
        }
        int gstate = 0;
        if ((data.style & SWT.MIRRORED) != 0) {
            gstate = Gdip.Graphics_Save(data.gdipGraphics);
            Gdip.Graphics_ScaleTransform(data.gdipGraphics, -1, 1, Gdip.MatrixOrderPrepend);
            Gdip.Graphics_TranslateTransform(data.gdipGraphics, - 2 * destX - destWidth, 0, Gdip.MatrixOrderPrepend);
        }
        Gdip.Graphics_DrawImage(data.gdipGraphics, img, rect, srcX, srcY, srcWidth, srcHeight, Gdip.UnitPixel, attrib, null, null);
        if ((data.style & SWT.MIRRORED) != 0) {
            Gdip.Graphics_Restore(data.gdipGraphics, gstate);
        }
        Gdip.ImageAttributes_delete(attrib);
        Gdip.Bitmap_delete( cast(Gdip.Bitmap) img);
        if (gdipImage[1] != 0) {
            auto hHeap = OS.GetProcessHeap ();
            OS.HeapFree(hHeap, 0, cast(void*)gdipImage[1]);
        }
        return;
    }
    switch (srcImage.type) {
        case SWT.BITMAP:
            drawBitmap(srcImage, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple);
            break;
        case SWT.ICON:
            drawIcon(srcImage, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple);
            break;
        default:
    }
}

void drawIcon(Image srcImage, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight, bool simple) {
    int technology = OS.GetDeviceCaps(handle, OS.TECHNOLOGY);

    bool drawIcon = true;
    int flags = OS.DI_NORMAL;
    int offsetX = 0, offsetY = 0;
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION(5, 1)) {
        if ((OS.GetLayout(handle) & OS.LAYOUT_RTL) !is 0) {
            flags |= OS.DI_NOMIRROR;
            /*
            * Bug in Windows.  For some reason, DrawIconEx() does not take
            * into account the window origin when the DI_NOMIRROR and
            * LAYOUT_RTL are set.  The fix is to set the window origin to
            * (0, 0) and offset the drawing ourselves.
            */
            POINT pt;
            OS.GetWindowOrgEx(handle, &pt);
            offsetX = pt.x;
            offsetY = pt.y;
        }
    } else {
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION(4, 10)) {
            drawIcon = (OS.GetLayout(handle) & OS.LAYOUT_RTL) is 0;
        }
    }

    /* Simple case: no stretching, entire icon */
    if (simple && technology !is OS.DT_RASPRINTER && drawIcon) {
        if (offsetX !is 0 || offsetY !is 0) OS.SetWindowOrgEx(handle, 0, 0, null);
        OS.DrawIconEx(handle, destX - offsetX, destY - offsetY, srcImage.handle, 0, 0, 0, null, flags);
        if (offsetX !is 0 || offsetY !is 0) OS.SetWindowOrgEx(handle, offsetX, offsetY, null);
        return;
    }

    /* Get the icon info */
    ICONINFO srcIconInfo;
    static if (OS.IsWinCE) {
        Image.GetIconInfo(srcImage, &srcIconInfo);
    } else {
        OS.GetIconInfo(srcImage.handle, &srcIconInfo);
    }

    /* Get the icon width and height */
    auto hBitmap = srcIconInfo.hbmColor;
    if (hBitmap is null) hBitmap = srcIconInfo.hbmMask;
    BITMAP bm;
    OS.GetObject(hBitmap, BITMAP.sizeof, &bm);
    int iconWidth = bm.bmWidth, iconHeight = bm.bmHeight;
    if (hBitmap is srcIconInfo.hbmMask) iconHeight /= 2;

    if (simple) {
        srcWidth = destWidth = iconWidth;
        srcHeight = destHeight = iconHeight;
    }

    /* Draw the icon */
    bool failed = srcX + srcWidth > iconWidth || srcY + srcHeight > iconHeight;
    if (!failed) {
        simple = srcX is 0 && srcY is 0 &&
            srcWidth is destWidth && srcHeight is destHeight &&
            srcWidth is iconWidth && srcHeight is iconHeight;
        if (!drawIcon) {
            drawBitmapMask(srcImage, srcIconInfo.hbmColor, srcIconInfo.hbmMask, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple, iconWidth, iconHeight, false);
        } else if (simple && technology !is OS.DT_RASPRINTER) {
            /* Simple case: no stretching, entire icon */
            if (offsetX !is 0 || offsetY !is 0) OS.SetWindowOrgEx(handle, 0, 0, null);
            OS.DrawIconEx(handle, destX - offsetX, destY - offsetY, srcImage.handle, 0, 0, 0, null, flags);
            if (offsetX !is 0 || offsetY !is 0) OS.SetWindowOrgEx(handle, offsetX, offsetY, null);
        } else {
            /* Create the icon info and HDC's */
            ICONINFO newIconInfo;
            newIconInfo.fIcon = true;
            auto srcHdc = OS.CreateCompatibleDC(handle);
            auto dstHdc = OS.CreateCompatibleDC(handle);

            /* Blt the color bitmap */
            int srcColorY = srcY;
            auto srcColor = srcIconInfo.hbmColor;
            if (srcColor is null) {
                srcColor = srcIconInfo.hbmMask;
                srcColorY += iconHeight;
            }
            auto oldSrcBitmap = OS.SelectObject(srcHdc, srcColor);
            newIconInfo.hbmColor = OS.CreateCompatibleBitmap(srcHdc, destWidth, destHeight);
            if (newIconInfo.hbmColor is null) SWT.error(SWT.ERROR_NO_HANDLES);
            auto oldDestBitmap = OS.SelectObject(dstHdc, newIconInfo.hbmColor);
            bool stretch = !simple && (srcWidth !is destWidth || srcHeight !is destHeight);
            if (stretch) {
                static if (!OS.IsWinCE) OS.SetStretchBltMode(dstHdc, OS.COLORONCOLOR);
                OS.StretchBlt(dstHdc, 0, 0, destWidth, destHeight, srcHdc, srcX, srcColorY, srcWidth, srcHeight, OS.SRCCOPY);
            } else {
                OS.BitBlt(dstHdc, 0, 0, destWidth, destHeight, srcHdc, srcX, srcColorY, OS.SRCCOPY);
            }

            /* Blt the mask bitmap */
            OS.SelectObject(srcHdc, srcIconInfo.hbmMask);
            newIconInfo.hbmMask = OS.CreateBitmap(destWidth, destHeight, 1, 1, null);
            if (newIconInfo.hbmMask is null) SWT.error(SWT.ERROR_NO_HANDLES);
            OS.SelectObject(dstHdc, newIconInfo.hbmMask);
            if (stretch) {
                OS.StretchBlt(dstHdc, 0, 0, destWidth, destHeight, srcHdc, srcX, srcY, srcWidth, srcHeight, OS.SRCCOPY);
            } else {
                OS.BitBlt(dstHdc, 0, 0, destWidth, destHeight, srcHdc, srcX, srcY, OS.SRCCOPY);
            }

            if (technology is OS.DT_RASPRINTER) {
                OS.SelectObject(srcHdc, newIconInfo.hbmColor);
                OS.SelectObject(dstHdc, newIconInfo.hbmMask);
                drawBitmapTransparentByClipping(srcHdc, dstHdc, 0, 0, destWidth, destHeight, destX, destY, destWidth, destHeight, true, destWidth, destHeight);
                OS.SelectObject(srcHdc, oldSrcBitmap);
                OS.SelectObject(dstHdc, oldDestBitmap);
            } else {
                OS.SelectObject(srcHdc, oldSrcBitmap);
                OS.SelectObject(dstHdc, oldDestBitmap);
                auto hIcon = OS.CreateIconIndirect(&newIconInfo);
                if (hIcon is null) SWT.error(SWT.ERROR_NO_HANDLES);
                if (offsetX !is 0 || offsetY !is 0) OS.SetWindowOrgEx(handle, 0, 0, null);
                OS.DrawIconEx(handle, destX - offsetX, destY - offsetY, hIcon, destWidth, destHeight, 0, null, flags);
                if (offsetX !is 0 || offsetY !is 0) OS.SetWindowOrgEx(handle, offsetX, offsetY, null);
                OS.DestroyIcon(hIcon);
            }

            /* Destroy the new icon src and mask and hdc's*/
            OS.DeleteObject(newIconInfo.hbmMask);
            OS.DeleteObject(newIconInfo.hbmColor);
            OS.DeleteDC(dstHdc);
            OS.DeleteDC(srcHdc);
        }
    }

    /* Free icon info */
    OS.DeleteObject(srcIconInfo.hbmMask);
    if (srcIconInfo.hbmColor !is null) {
        OS.DeleteObject(srcIconInfo.hbmColor);
    }

    if (failed) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
}

void drawBitmap(Image srcImage, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight, bool simple) {
    BITMAP bm;
    OS.GetObject(srcImage.handle, BITMAP.sizeof, &bm);
    int imgWidth = bm.bmWidth;
    int imgHeight = bm.bmHeight;
    if (simple) {
        srcWidth = destWidth = imgWidth;
        srcHeight = destHeight = imgHeight;
    } else {
        if (srcX + srcWidth > imgWidth || srcY + srcHeight > imgHeight) {
            SWT.error (SWT.ERROR_INVALID_ARGUMENT);
        }
        simple = srcX is 0 && srcY is 0 &&
            srcWidth is destWidth && destWidth is imgWidth &&
            srcHeight is destHeight && destHeight is imgHeight;
    }
    bool mustRestore = false;
    GC memGC = srcImage.memGC;
    if (memGC !is null && !memGC.isDisposed()) {
        memGC.flush();
        mustRestore = true;
        GCData data = memGC.data;
        if (data.hNullBitmap !is null) {
            OS.SelectObject(memGC.handle, data.hNullBitmap);
            data.hNullBitmap = null;
        }
    }
    if (srcImage.alpha !is -1 || srcImage.alphaData !is null) {
        drawBitmapAlpha(srcImage, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple, bm, imgWidth, imgHeight);
    } else if (srcImage.transparentPixel !is -1) {
        drawBitmapTransparent(srcImage, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple, bm, imgWidth, imgHeight);
    } else {
        drawBitmap(srcImage, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple, bm, imgWidth, imgHeight);
    }
    if (mustRestore) {
        auto hOldBitmap = OS.SelectObject(memGC.handle, srcImage.handle);
        memGC.data.hNullBitmap = hOldBitmap;
    }
}

void drawBitmapAlpha(Image srcImage, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight, bool simple, BITMAP bm, int imgWidth, int imgHeight) {
    /* Simple cases */
    if (srcImage.alpha is 0) return;
    if (srcImage.alpha is 255) {
        drawBitmap(srcImage, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple, bm, imgWidth, imgHeight);
        return;
    }

    if (OS.IsWinNT && OS.WIN32_VERSION >= OS.VERSION(4, 10)) {
        BLENDFUNCTION blend;
        blend.BlendOp = OS.AC_SRC_OVER;
        auto srcHdc = OS.CreateCompatibleDC(handle);
        auto oldSrcBitmap = OS.SelectObject(srcHdc, srcImage.handle);
        if (srcImage.alpha !is -1) {
            blend.SourceConstantAlpha = cast(byte)srcImage.alpha;
            OS.AlphaBlend(handle, destX, destY, destWidth, destHeight, srcHdc, srcX, srcY, srcWidth, srcHeight, blend);
        } else {
            auto memDib = Image.createDIB(srcWidth, srcHeight, 32);
            if (memDib is null) SWT.error(SWT.ERROR_NO_HANDLES);
            auto memHdc = OS.CreateCompatibleDC(handle);
            auto oldMemBitmap = OS.SelectObject(memHdc, memDib);
            BITMAP dibBM;
            OS.GetObject(memDib, BITMAP.sizeof, &dibBM);
            OS.BitBlt(memHdc, 0, 0, srcWidth, srcHeight, srcHdc, srcX, srcY, OS.SRCCOPY);
            byte[] srcData = new byte[dibBM.bmWidthBytes * dibBM.bmHeight];
            srcData[] = (cast(byte*)dibBM.bmBits)[ 0 .. srcData.length ];
            int apinc = imgWidth - srcWidth;
            int ap = srcY * imgWidth + srcX, sp = 0;
            byte[] alphaData = srcImage.alphaData;
            for (int y = 0; y < srcHeight; ++y) {
                for (int x = 0; x < srcWidth; ++x) {
                    int alpha = alphaData[ap++] & 0xff;
                    int r = ((srcData[sp + 0] & 0xFF) * alpha) + 128;
                    r = (r + (r >> 8)) >> 8;
                    int g = ((srcData[sp + 1] & 0xFF) * alpha) + 128;
                    g = (g + (g >> 8)) >> 8;
                    int b = ((srcData[sp + 2] & 0xFF) * alpha) + 128;
                    b = (b + (b >> 8)) >> 8;
                    srcData[sp+0] = cast(byte)r;
                    srcData[sp+1] = cast(byte)g;
                    srcData[sp+2] = cast(byte)b;
                    srcData[sp+3] = cast(byte)alpha;
                    sp += 4;
                }
                ap += apinc;
            }
            (cast(byte*)dibBM.bmBits)[ 0 .. srcData.length ] = srcData[];
            blend.SourceConstantAlpha = 0xff;
            blend.AlphaFormat = OS.AC_SRC_ALPHA;
            OS.AlphaBlend(handle, destX, destY, destWidth, destHeight, memHdc, 0, 0, srcWidth, srcHeight, blend);
            OS.SelectObject(memHdc, oldMemBitmap);
            OS.DeleteDC(memHdc);
            OS.DeleteObject(memDib);
        }
        OS.SelectObject(srcHdc, oldSrcBitmap);
        OS.DeleteDC(srcHdc);
        return;
    }

    /* Check clipping */
    Rectangle rect = getClipping();
    rect = rect.intersection(new Rectangle(destX, destY, destWidth, destHeight));
    if (rect.isEmpty()) return;

    /*
    * Optimization.  Recalculate src and dest rectangles so that
    * only the clipping area is drawn.
    */
    int sx1 = srcX + (((rect.x - destX) * srcWidth) / destWidth);
    int sx2 = srcX + ((((rect.x + rect.width) - destX) * srcWidth) / destWidth);
    int sy1 = srcY + (((rect.y - destY) * srcHeight) / destHeight);
    int sy2 = srcY + ((((rect.y + rect.height) - destY) * srcHeight) / destHeight);
    destX = rect.x;
    destY = rect.y;
    destWidth = rect.width;
    destHeight = rect.height;
    srcX = sx1;
    srcY = sy1;
    srcWidth = Math.max(1, sx2 - sx1);
    srcHeight = Math.max(1, sy2 - sy1);

    /* Create resources */
    auto srcHdc = OS.CreateCompatibleDC(handle);
    auto oldSrcBitmap = OS.SelectObject(srcHdc, srcImage.handle);
    auto memHdc = OS.CreateCompatibleDC(handle);
    auto memDib = Image.createDIB(Math.max(srcWidth, destWidth), Math.max(srcHeight, destHeight), 32);
    if (memDib is null) SWT.error(SWT.ERROR_NO_HANDLES);
    auto oldMemBitmap = OS.SelectObject(memHdc, memDib);

    BITMAP dibBM;
    OS.GetObject(memDib, BITMAP.sizeof, &dibBM);
    int sizeInBytes = dibBM.bmWidthBytes * dibBM.bmHeight;

    /* Get the background pixels */
    OS.BitBlt(memHdc, 0, 0, destWidth, destHeight, handle, destX, destY, OS.SRCCOPY);
    byte[] destData = new byte[sizeInBytes];
    destData[] = (cast(byte*)dibBM.bmBits)[ 0 .. sizeInBytes ];

    /* Get the foreground pixels */
    OS.BitBlt(memHdc, 0, 0, srcWidth, srcHeight, srcHdc, srcX, srcY, OS.SRCCOPY);
    byte[] srcData = new byte[sizeInBytes];
    srcData[] = (cast(byte*)dibBM.bmBits)[ 0 .. sizeInBytes ];

    /* Merge the alpha channel in place */
    int alpha = srcImage.alpha;
    bool hasAlphaChannel = (srcImage.alpha is -1);
    if (hasAlphaChannel) {
        int apinc = imgWidth - srcWidth;
        int spinc = dibBM.bmWidthBytes - srcWidth * 4;
        int ap = srcY * imgWidth + srcX, sp = 3;
        byte[] alphaData = srcImage.alphaData;
        for (int y = 0; y < srcHeight; ++y) {
            for (int x = 0; x < srcWidth; ++x) {
                srcData[sp] = alphaData[ap++];
                sp += 4;
            }
            ap += apinc;
            sp += spinc;
        }
    }

    /* Scale the foreground pixels with alpha */
     (cast(byte*)dibBM.bmBits)[ 0 .. sizeInBytes ] = srcData[];
    /*
    * Bug in WinCE and Win98.  StretchBlt does not correctly stretch when
    * the source and destination HDCs are the same.  The workaround is to
    * stretch to a temporary HDC and blit back into the original HDC.
    * Note that on WinCE StretchBlt correctly compresses the image when the
    * source and destination HDCs are the same.
    */
    if ((OS.IsWinCE && (destWidth > srcWidth || destHeight > srcHeight)) || (!OS.IsWinNT && !OS.IsWinCE)) {
        auto tempHdc = OS.CreateCompatibleDC(handle);
        auto tempDib = Image.createDIB(destWidth, destHeight, 32);
        if (tempDib is null) SWT.error(SWT.ERROR_NO_HANDLES);
        auto oldTempBitmap = OS.SelectObject(tempHdc, tempDib);
        if (!simple && (srcWidth !is destWidth || srcHeight !is destHeight)) {
            static if (!OS.IsWinCE) OS.SetStretchBltMode(memHdc, OS.COLORONCOLOR);
            OS.StretchBlt(tempHdc, 0, 0, destWidth, destHeight, memHdc, 0, 0, srcWidth, srcHeight, OS.SRCCOPY);
        } else {
            OS.BitBlt(tempHdc, 0, 0, destWidth, destHeight, memHdc, 0, 0, OS.SRCCOPY);
        }
        OS.BitBlt(memHdc, 0, 0, destWidth, destHeight, tempHdc, 0, 0, OS.SRCCOPY);
        OS.SelectObject(tempHdc, oldTempBitmap);
        OS.DeleteObject(tempDib);
        OS.DeleteDC(tempHdc);
    } else {
        if (!simple && (srcWidth !is destWidth || srcHeight !is destHeight)) {
            static if (!OS.IsWinCE) OS.SetStretchBltMode(memHdc, OS.COLORONCOLOR);
            OS.StretchBlt(memHdc, 0, 0, destWidth, destHeight, memHdc, 0, 0, srcWidth, srcHeight, OS.SRCCOPY);
        } else {
            OS.BitBlt(memHdc, 0, 0, destWidth, destHeight, memHdc, 0, 0, OS.SRCCOPY);
        }
    }
    srcData[] = (cast(byte*)dibBM.bmBits)[ 0 .. sizeInBytes ];

    /* Compose the pixels */
    int dpinc = dibBM.bmWidthBytes - destWidth * 4;
    int dp = 0;
    for (int y = 0; y < destHeight; ++y) {
        for (int x = 0; x < destWidth; ++x) {
            if (hasAlphaChannel) alpha = srcData[dp + 3] & 0xff;
            destData[dp] += ((srcData[dp] & 0xff) - (destData[dp] & 0xff)) * alpha / 255;
            destData[dp + 1] += ((srcData[dp + 1] & 0xff) - (destData[dp + 1] & 0xff)) * alpha / 255;
            destData[dp + 2] += ((srcData[dp + 2] & 0xff) - (destData[dp + 2] & 0xff)) * alpha / 255;
            dp += 4;
        }
        dp += dpinc;
    }

    /* Draw the composed pixels */
    (cast(byte*)dibBM.bmBits)[ 0 .. sizeInBytes ] = destData[];
    OS.BitBlt(handle, destX, destY, destWidth, destHeight, memHdc, 0, 0, OS.SRCCOPY);

    /* Free resources */
    OS.SelectObject(memHdc, oldMemBitmap);
    OS.DeleteDC(memHdc);
    OS.DeleteObject(memDib);
    OS.SelectObject(srcHdc, oldSrcBitmap);
    OS.DeleteDC(srcHdc);
}

void drawBitmapTransparentByClipping(HDC srcHdc, HDC maskHdc, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight, bool simple, int imgWidth, int imgHeight) {
    /* Create a clipping region from the mask */
    auto rgn = OS.CreateRectRgn(0, 0, 0, 0);
    for (int y=0; y<imgHeight; y++) {
        for (int x=0; x<imgWidth; x++) {
            if (OS.GetPixel(maskHdc, x, y) is 0) {
                auto tempRgn = OS.CreateRectRgn(x, y, x+1, y+1);
                OS.CombineRgn(rgn, rgn, tempRgn, OS.RGN_OR);
                OS.DeleteObject(tempRgn);
            }
        }
    }
    /* Stretch the clipping mask if needed */
    if (destWidth !is srcWidth || destHeight !is srcHeight) {
        int nBytes = OS.GetRegionData (rgn, 0, null);
        int[] lpRgnData = new int[nBytes / 4];
        OS.GetRegionData (rgn, nBytes, cast(RGNDATA*)lpRgnData.ptr);
        float[6] lpXform;
        lpXform[] = 0.0f;
        lpXform[0] = cast(float)destWidth/srcWidth;
        lpXform[3] = cast(float)destHeight/srcHeight;
        auto tmpRgn = OS.ExtCreateRegion(cast(XFORM*)lpXform.ptr, nBytes, cast(RGNDATA*)lpRgnData.ptr);
        OS.DeleteObject(rgn);
        rgn = tmpRgn;
    }
    OS.OffsetRgn(rgn, destX, destY);
    auto clip = OS.CreateRectRgn(0, 0, 0, 0);
    int result = OS.GetClipRgn(handle, clip);
    if (result is 1) OS.CombineRgn(rgn, rgn, clip, OS.RGN_AND);
    OS.SelectClipRgn(handle, rgn);
    int rop2 = 0;
    static if (!OS.IsWinCE) {
        rop2 = OS.GetROP2(handle);
    } else {
        rop2 = OS.SetROP2 (handle, OS.R2_COPYPEN);
        OS.SetROP2 (handle, rop2);
    }
    int dwRop = rop2 is OS.R2_XORPEN ? OS.SRCINVERT : OS.SRCCOPY;
    if (!simple && (srcWidth !is destWidth || srcHeight !is destHeight)) {
        int mode = 0;
        static if (!OS.IsWinCE) mode = OS.SetStretchBltMode(handle, OS.COLORONCOLOR);
        OS.StretchBlt(handle, destX, destY, destWidth, destHeight, srcHdc, srcX, srcY, srcWidth, srcHeight, dwRop);
        static if (!OS.IsWinCE) OS.SetStretchBltMode(handle, mode);
    } else {
        OS.BitBlt(handle, destX, destY, destWidth, destHeight, srcHdc, srcX, srcY, dwRop);
    }
    OS.SelectClipRgn(handle, result is 1 ? clip : null);
    OS.DeleteObject(clip);
    OS.DeleteObject(rgn);
}

void drawBitmapMask(Image srcImage, HBITMAP srcColor, HBITMAP srcMask, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight, bool simple, int imgWidth, int imgHeight, bool offscreen) {
    int srcColorY = srcY;
    if (srcColor is null) {
        srcColor = srcMask;
        srcColorY += imgHeight;
    }
    auto srcHdc = OS.CreateCompatibleDC(handle);
    auto oldSrcBitmap = OS.SelectObject(srcHdc, srcColor);
    auto destHdc = handle;
    int x = destX, y = destY;
    HDC tempHdc;
    HBITMAP tempBitmap;
    HBITMAP oldTempBitmap;
    int oldBkColor = 0, oldTextColor = 0;
    if (offscreen) {
        tempHdc = OS.CreateCompatibleDC(handle);
        tempBitmap = OS.CreateCompatibleBitmap(handle, destWidth, destHeight);
        oldTempBitmap = OS.SelectObject(tempHdc, tempBitmap);
        OS.BitBlt(tempHdc, 0, 0, destWidth, destHeight, handle, destX, destY, OS.SRCCOPY);
        destHdc = tempHdc;
        x = y = 0;
    } else {
        oldBkColor = OS.SetBkColor(handle, 0xFFFFFF);
        oldTextColor = OS.SetTextColor(handle, 0);
    }
    if (!simple && (srcWidth !is destWidth || srcHeight !is destHeight)) {
        int mode = 0;
        static if (!OS.IsWinCE) mode = OS.SetStretchBltMode(handle, OS.COLORONCOLOR);
        OS.StretchBlt(destHdc, x, y, destWidth, destHeight, srcHdc, srcX, srcColorY, srcWidth, srcHeight, OS.SRCINVERT);
        OS.SelectObject(srcHdc, srcMask);
        OS.StretchBlt(destHdc, x, y, destWidth, destHeight, srcHdc, srcX, srcY, srcWidth, srcHeight, OS.SRCAND);
        OS.SelectObject(srcHdc, srcColor);
        OS.StretchBlt(destHdc, x, y, destWidth, destHeight, srcHdc, srcX, srcColorY, srcWidth, srcHeight, OS.SRCINVERT);
        static if (!OS.IsWinCE) OS.SetStretchBltMode(handle, mode);
    } else {
        OS.BitBlt(destHdc, x, y, destWidth, destHeight, srcHdc, srcX, srcColorY, OS.SRCINVERT);
        OS.SetTextColor(destHdc, 0);
        OS.SelectObject(srcHdc, srcMask);
        OS.BitBlt(destHdc, x, y, destWidth, destHeight, srcHdc, srcX, srcY, OS.SRCAND);
        OS.SelectObject(srcHdc, srcColor);
        OS.BitBlt(destHdc, x, y, destWidth, destHeight, srcHdc, srcX, srcColorY, OS.SRCINVERT);
    }
    if (offscreen) {
        OS.BitBlt(handle, destX, destY, destWidth, destHeight, tempHdc, 0, 0, OS.SRCCOPY);
        OS.SelectObject(tempHdc, oldTempBitmap);
        OS.DeleteDC(tempHdc);
        OS.DeleteObject(tempBitmap);
    } else {
        OS.SetBkColor(handle, oldBkColor);
        OS.SetTextColor(handle, oldTextColor);
    }
    OS.SelectObject(srcHdc, oldSrcBitmap);
    OS.DeleteDC(srcHdc);
}

void drawBitmapTransparent(Image srcImage, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight, bool simple, BITMAP bm, int imgWidth, int imgHeight) {

    /* Find the RGB values for the transparent pixel. */
    bool isDib = bm.bmBits !is null;
    auto hBitmap = srcImage.handle;
    auto srcHdc = OS.CreateCompatibleDC(handle);
    auto oldSrcBitmap = OS.SelectObject(srcHdc, hBitmap);
    byte[] originalColors = null;
    int transparentColor = srcImage.transparentColor;
    if (transparentColor is -1) {
        int transBlue = 0, transGreen = 0, transRed = 0;        
        bool fixPalette = false;
        if (bm.bmBitsPixel <= 8) {
            if (isDib) {
                /* Palette-based DIBSECTION */
                static if (OS.IsWinCE) {
                    byte* pBits = cast(byte*)bm.bmBits;
                    //OS.MoveMemory(pBits, bm.bmBits, 1);
                    byte oldValue = pBits[0];
                    int mask = (0xFF << (8 - bm.bmBitsPixel)) & 0x00FF;
                    pBits[0] = cast(byte)((srcImage.transparentPixel << (8 - bm.bmBitsPixel)) | (pBits[0] & ~mask));
                    //OS.MoveMemory(bm.bmBits, pBits, 1);
                    int color = OS.GetPixel(srcHdc, 0, 0);
                    pBits[0] = oldValue;
                    //OS.MoveMemory(bm.bmBits, pBits, 1);
                    transBlue = (color & 0xFF0000) >> 16;
                    transGreen = (color & 0xFF00) >> 8;
                    transRed = color & 0xFF;
                } else {
                    int maxColors = 1 << bm.bmBitsPixel;
                    byte[] oldColors = new byte[maxColors * 4];
                    OS.GetDIBColorTable(srcHdc, 0, maxColors, cast(RGBQUAD*)oldColors.ptr);
                    int offset = srcImage.transparentPixel * 4;
                    for (int i = 0; i < oldColors.length; i += 4) {
                        if (i !is offset) {
                            if (oldColors[offset] is oldColors[i] && oldColors[offset+1] is oldColors[i+1] && oldColors[offset+2] is oldColors[i+2]) {
                                fixPalette = true;
                                break;
                            }
                        }
                    }
                    if (fixPalette) {
                        byte[] newColors = new byte[oldColors.length];
                        transRed = transGreen = transBlue = 0xff;
                        newColors[offset] = cast(byte)transBlue;
                        newColors[offset+1] = cast(byte)transGreen;
                        newColors[offset+2] = cast(byte)transRed;
                        OS.SetDIBColorTable(srcHdc, 0, maxColors, cast(RGBQUAD*)newColors.ptr);
                        originalColors = oldColors;
                    } else {
                        transBlue = oldColors[offset] & 0xFF;
                        transGreen = oldColors[offset+1] & 0xFF;
                        transRed = oldColors[offset+2] & 0xFF;
                    }
                }
            } else {
                /* Palette-based bitmap */
                int numColors = 1 << bm.bmBitsPixel;
                /* Set the few fields necessary to get the RGB data out */
                BITMAPINFOHEADER bmiHeader;
                bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
                bmiHeader.biPlanes = bm.bmPlanes;
                bmiHeader.biBitCount = bm.bmBitsPixel;
                byte[] bmi = new byte[BITMAPINFOHEADER.sizeof + numColors * 4];
                bmi[] = (cast(byte*)&bmiHeader)[ 0 .. BITMAPINFOHEADER.sizeof ];
                static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
                OS.GetDIBits(srcHdc, srcImage.handle, 0, 0, null, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS);
                int offset = cast(int)/*64bit*/BITMAPINFOHEADER.sizeof + 4 * srcImage.transparentPixel;
                transRed = bmi[offset + 2] & 0xFF;
                transGreen = bmi[offset + 1] & 0xFF;
                transBlue = bmi[offset] & 0xFF;
            }
        } else {
            /* Direct color image */
            int pixel = srcImage.transparentPixel;
            switch (bm.bmBitsPixel) {
                case 16:
                    transBlue = (pixel & 0x1F) << 3;
                    transGreen = (pixel & 0x3E0) >> 2;
                    transRed = (pixel & 0x7C00) >> 7;
                    break;
                case 24:
                    transBlue = (pixel & 0xFF0000) >> 16;
                    transGreen = (pixel & 0xFF00) >> 8;
                    transRed = pixel & 0xFF;
                    break;
                case 32:
                    transBlue = (pixel & 0xFF000000) >>> 24;
                    transGreen = (pixel & 0xFF0000) >> 16;
                    transRed = (pixel & 0xFF00) >> 8;
                    break;
            default:
            }
        }
        transparentColor = transBlue << 16 | transGreen << 8 | transRed;
        if (!fixPalette) srcImage.transparentColor = transparentColor;
    }

    static if (OS.IsWinCE) {
        /*
        * Note in WinCE. TransparentImage uses the first entry of a palette
        * based image when there are multiple entries that have the same
        * transparent color.
        */
        OS.TransparentImage(handle, destX, destY, destWidth, destHeight, srcHdc, srcX, srcY, srcWidth, srcHeight, transparentColor);
    } else if (originalColors is null && OS.IsWinNT && OS.WIN32_VERSION >= OS.VERSION(4, 10)) {
        int mode = OS.SetStretchBltMode(handle, OS.COLORONCOLOR);
        OS.TransparentBlt(handle, destX, destY, destWidth, destHeight, srcHdc, srcX, srcY, srcWidth, srcHeight, transparentColor);
        OS.SetStretchBltMode(handle, mode);
    } else {
        /* Create the mask for the source image */
        auto maskHdc = OS.CreateCompatibleDC(handle);
        auto maskBitmap = OS.CreateBitmap(imgWidth, imgHeight, 1, 1, null);
        auto oldMaskBitmap = OS.SelectObject(maskHdc, maskBitmap);
        OS.SetBkColor(srcHdc, transparentColor);
        OS.BitBlt(maskHdc, 0, 0, imgWidth, imgHeight, srcHdc, 0, 0, OS.SRCCOPY);
        if (originalColors !is null) OS.SetDIBColorTable(srcHdc, 0, 1 << bm.bmBitsPixel, cast(RGBQUAD*)originalColors.ptr);

        if (OS.GetDeviceCaps(handle, OS.TECHNOLOGY) is OS.DT_RASPRINTER) {
            /* Most printers do not support BitBlt(), draw the source bitmap transparently using clipping */
            drawBitmapTransparentByClipping(srcHdc, maskHdc, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple, imgWidth, imgHeight);
        } else {
            /* Draw the source bitmap transparently using invert/and mask/invert */
            auto tempHdc = OS.CreateCompatibleDC(handle);
            auto tempBitmap = OS.CreateCompatibleBitmap(handle, destWidth, destHeight);
            auto oldTempBitmap = OS.SelectObject(tempHdc, tempBitmap);
            OS.BitBlt(tempHdc, 0, 0, destWidth, destHeight, handle, destX, destY, OS.SRCCOPY);
            if (!simple && (srcWidth !is destWidth || srcHeight !is destHeight)) {
                static if (!OS.IsWinCE) OS.SetStretchBltMode(tempHdc, OS.COLORONCOLOR);
                OS.StretchBlt(tempHdc, 0, 0, destWidth, destHeight, srcHdc, srcX, srcY, srcWidth, srcHeight, OS.SRCINVERT);
                OS.StretchBlt(tempHdc, 0, 0, destWidth, destHeight, maskHdc, srcX, srcY, srcWidth, srcHeight, OS.SRCAND);
                OS.StretchBlt(tempHdc, 0, 0, destWidth, destHeight, srcHdc, srcX, srcY, srcWidth, srcHeight, OS.SRCINVERT);
            } else {
                OS.BitBlt(tempHdc, 0, 0, destWidth, destHeight, srcHdc, srcX, srcY, OS.SRCINVERT);
                OS.BitBlt(tempHdc, 0, 0, destWidth, destHeight, maskHdc, srcX, srcY, OS.SRCAND);
                OS.BitBlt(tempHdc, 0, 0, destWidth, destHeight, srcHdc, srcX, srcY, OS.SRCINVERT);
            }
            OS.BitBlt(handle, destX, destY, destWidth, destHeight, tempHdc, 0, 0, OS.SRCCOPY);
            OS.SelectObject(tempHdc, oldTempBitmap);
            OS.DeleteDC(tempHdc);
            OS.DeleteObject(tempBitmap);
        }
        OS.SelectObject(maskHdc, oldMaskBitmap);
        OS.DeleteDC(maskHdc);
        OS.DeleteObject(maskBitmap);
    }
    OS.SelectObject(srcHdc, oldSrcBitmap);
    if (hBitmap !is srcImage.handle) OS.DeleteObject(hBitmap);
    OS.DeleteDC(srcHdc);
}

void drawBitmap(Image srcImage, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight, bool simple, BITMAP bm, int imgWidth, int imgHeight) {
    auto srcHdc = OS.CreateCompatibleDC(handle);
    auto oldSrcBitmap = OS.SelectObject(srcHdc, srcImage.handle);
    int rop2 = 0;
    static if (!OS.IsWinCE) {
        rop2 = OS.GetROP2(handle);
    } else {
        rop2 = OS.SetROP2 (handle, OS.R2_COPYPEN);
        OS.SetROP2 (handle, rop2);
    }
    int dwRop = rop2 is OS.R2_XORPEN ? OS.SRCINVERT : OS.SRCCOPY;
    if (!simple && (srcWidth !is destWidth || srcHeight !is destHeight)) {
        int mode = 0;
        static if (!OS.IsWinCE) mode = OS.SetStretchBltMode(handle, OS.COLORONCOLOR);
        OS.StretchBlt(handle, destX, destY, destWidth, destHeight, srcHdc, srcX, srcY, srcWidth, srcHeight, dwRop);
        static if (!OS.IsWinCE) OS.SetStretchBltMode(handle, mode);
    } else {
        OS.BitBlt(handle, destX, destY, destWidth, destHeight, srcHdc, srcX, srcY, dwRop);
    }
    OS.SelectObject(srcHdc, oldSrcBitmap);
    OS.DeleteDC(srcHdc);
}

/**
 * Draws a line, using the foreground color, between the points
 * (<code>x1</code>, <code>y1</code>) and (<code>x2</code>, <code>y2</code>).
 *
 * @param x1 the first point's x coordinate
 * @param y1 the first point's y coordinate
 * @param x2 the second point's x coordinate
 * @param y2 the second point's y coordinate
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawLine (int x1, int y1, int x2, int y2) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(DRAW);
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        Gdip.Graphics_TranslateTransform(gdipGraphics, data.gdipXOffset, data.gdipYOffset, Gdip.MatrixOrderPrepend);
        Gdip.Graphics_DrawLine(gdipGraphics, data.gdipPen, x1, y1, x2, y2);
        Gdip.Graphics_TranslateTransform(gdipGraphics, -data.gdipXOffset, -data.gdipYOffset, Gdip.MatrixOrderPrepend);
        return;
    }
    if ((data.style & SWT.MIRRORED) !is 0) {
        if (data.lineWidth !is 0 && data.lineWidth % 2 is 0) {
            x1--;
            x2--;
        }
    }
    static if (OS.IsWinCE) {
        int [4] points; points[0] = x1; points[1] = y1; points[2] = x2; points[3] = y2;
        OS.Polyline (handle, cast(POINT*)points.ptr, points.length / 2);
    } else {
        OS.MoveToEx (handle, x1, y1, null);
        OS.LineTo (handle, x2, y2);
    }
    if (data.lineWidth <= 1) {
        OS.SetPixel (handle, x2, y2, data.foreground);
    }
}

/**
 * Draws the outline of an oval, using the foreground color,
 * within the specified rectangular area.
 * <p>
 * The result is a circle or ellipse that fits within the
 * rectangle specified by the <code>x</code>, <code>y</code>,
 * <code>width</code>, and <code>height</code> arguments.
 * </p><p>
 * The oval covers an area that is <code>width + 1</code>
 * pixels wide and <code>height + 1</code> pixels tall.
 * </p>
 *
 * @param x the x coordinate of the upper left corner of the oval to be drawn
 * @param y the y coordinate of the upper left corner of the oval to be drawn
 * @param width the width of the oval to be drawn
 * @param height the height of the oval to be drawn
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawOval (int x, int y, int width, int height) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(DRAW);
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        Gdip.Graphics_TranslateTransform(gdipGraphics, data.gdipXOffset, data.gdipYOffset, Gdip.MatrixOrderPrepend);
        Gdip.Graphics_DrawEllipse(gdipGraphics, data.gdipPen, x, y, width, height);
        Gdip.Graphics_TranslateTransform(gdipGraphics, -data.gdipXOffset, -data.gdipYOffset, Gdip.MatrixOrderPrepend);
        return;
    }
    if ((data.style & SWT.MIRRORED) !is 0) {
        if (data.lineWidth !is 0 && data.lineWidth % 2 is 0) x--;
    }
    OS.Ellipse(handle, x, y, x + width + 1, y + height + 1);
}

/**
 * Draws the path described by the parameter.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param path the path to draw
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parameter is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see Path
 *
 * @since 3.1
 */
public void drawPath (Path path) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (path is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (path.handle is null) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    initGdip();
    checkGC(DRAW);
    auto gdipGraphics = data.gdipGraphics;
    Gdip.Graphics_TranslateTransform(gdipGraphics, data.gdipXOffset, data.gdipYOffset, Gdip.MatrixOrderPrepend);
    Gdip.Graphics_DrawPath(gdipGraphics, data.gdipPen, path.handle);
    Gdip.Graphics_TranslateTransform(gdipGraphics, -data.gdipXOffset, -data.gdipYOffset, Gdip.MatrixOrderPrepend);
}

/**
 * Draws a pixel, using the foreground color, at the specified
 * point (<code>x</code>, <code>y</code>).
 * <p>
 * Note that the receiver's line attributes do not affect this
 * operation.
 * </p>
 *
 * @param x the point's x coordinate
 * @param y the point's y coordinate
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void drawPoint (int x, int y) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (data.gdipGraphics !is null) {
        checkGC(DRAW);
        Gdip.Graphics_FillRectangle(data.gdipGraphics, getFgBrush(), x, y, 1, 1);
        return;
    }
    OS.SetPixel (handle, x, y, data.foreground);
}

/**
 * Draws the closed polygon which is defined by the specified array
 * of integer coordinates, using the receiver's foreground color. The array
 * contains alternating x and y values which are considered to represent
 * points which are the vertices of the polygon. Lines are drawn between
 * each consecutive pair, and between the first pair and last pair in the
 * array.
 *
 * @param pointArray an array of alternating x and y values which are the vertices of the polygon
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawPolygon( int[] pointArray) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    // SWT extension: allow null array
    //if (pointArray is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    checkGC(DRAW);
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        Gdip.Graphics_TranslateTransform(gdipGraphics, data.gdipXOffset, data.gdipYOffset, Gdip.MatrixOrderPrepend);
        Gdip.Graphics_DrawPolygon(gdipGraphics, data.gdipPen, cast(Gdip.Point*)pointArray.ptr, cast(int)/*64bit*/pointArray.length/2);
        Gdip.Graphics_TranslateTransform(gdipGraphics, -data.gdipXOffset, -data.gdipYOffset, Gdip.MatrixOrderPrepend);
        return;
    }
    if ((data.style & SWT.MIRRORED) !is 0) {
        if (data.lineWidth !is 0 && data.lineWidth % 2 is 0) {
            for (int i = 0; i < pointArray.length; i+=2) {
                pointArray[i]--;
            }
        }
    }
    OS.Polygon(handle, cast(POINT*)pointArray.ptr, cast(int)/*64bit*/pointArray.length/2);
    if ((data.style & SWT.MIRRORED) !is 0) {
        if (data.lineWidth !is 0 && data.lineWidth % 2 is 0) {
            for (int i = 0; i < pointArray.length; i+=2) {
                pointArray[i]++;
            }
        }
    }
}

/**
 * Draws the polyline which is defined by the specified array
 * of integer coordinates, using the receiver's foreground color. The array
 * contains alternating x and y values which are considered to represent
 * points which are the corners of the polyline. Lines are drawn between
 * each consecutive pair, but not between the first pair and last pair in
 * the array.
 *
 * @param pointArray an array of alternating x and y values which are the corners of the polyline
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawPolyline(int[] pointArray) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    // SWT externsion: allow null array
    //if (pointArray is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    checkGC(DRAW);
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        Gdip.Graphics_TranslateTransform(gdipGraphics, data.gdipXOffset, data.gdipYOffset, Gdip.MatrixOrderPrepend);
        Gdip.Graphics_DrawLines(gdipGraphics, data.gdipPen, cast(Gdip.Point*)pointArray.ptr, cast(int)/*64bit*/pointArray.length / 2);
        Gdip.Graphics_TranslateTransform(gdipGraphics, -data.gdipXOffset, -data.gdipYOffset, Gdip.MatrixOrderPrepend);
        return;
    }
    if ((data.style & SWT.MIRRORED) !is 0) {
        if (data.lineWidth !is 0 && data.lineWidth % 2 is 0) {
            for (int i = 0; i < pointArray.length; i+=2) {
                pointArray[i]--;
            }
        }
    }
    OS.Polyline(handle, cast(POINT*)pointArray.ptr, cast(int)/*64bit*/pointArray.length / 2);
    int length_ = cast(int)/*64bit*/pointArray.length;
    if (length_ >= 2) {
        if (data.lineWidth <= 1) {
            OS.SetPixel (handle, pointArray[length_ - 2], pointArray[length_ - 1], data.foreground);
        }
    }
    if ((data.style & SWT.MIRRORED) !is 0) {
        if (data.lineWidth !is 0 && data.lineWidth % 2 is 0) {
            for (int i = 0; i < pointArray.length; i+=2) {
                pointArray[i]++;
            }
        }
    }
}

/**
 * Draws the outline of the rectangle specified by the arguments,
 * using the receiver's foreground color. The left and right edges
 * of the rectangle are at <code>x</code> and <code>x + width</code>.
 * The top and bottom edges are at <code>y</code> and <code>y + height</code>.
 *
 * @param x the x coordinate of the rectangle to be drawn
 * @param y the y coordinate of the rectangle to be drawn
 * @param width the width of the rectangle to be drawn
 * @param height the height of the rectangle to be drawn
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawRectangle (int x, int y, int width, int height) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(DRAW);
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        if (width < 0) {
            x = x + width;
            width = -width;
        }
        if (height < 0) {
            y = y + height;
            height = -height;
        }
        Gdip.Graphics_TranslateTransform(gdipGraphics, data.gdipXOffset, data.gdipYOffset, Gdip.MatrixOrderPrepend);
        Gdip.Graphics_DrawRectangle(gdipGraphics, data.gdipPen, x, y, width, height);
        Gdip.Graphics_TranslateTransform(gdipGraphics, -data.gdipXOffset, -data.gdipYOffset, Gdip.MatrixOrderPrepend);
        return;
    }
    if ((data.style & SWT.MIRRORED) !is 0) {
        /*
        * Note that Rectangle() subtracts one pixel in MIRRORED mode when
        * the pen was created with CreatePen() and its width is 0 or 1.
        */
        if (data.lineWidth > 1) {
            if ((data.lineWidth % 2) is 1) x++;
        } else {
            if (data.hPen !is null && OS.GetObject(data.hPen, 0, null) !is LOGPEN.sizeof) {
                x++;
            }
        }
    }
    OS.Rectangle (handle, x, y, x + width + 1, y + height + 1);
}

/**
 * Draws the outline of the specified rectangle, using the receiver's
 * foreground color. The left and right edges of the rectangle are at
 * <code>rect.x</code> and <code>rect.x + rect.width</code>. The top
 * and bottom edges are at <code>rect.y</code> and
 * <code>rect.y + rect.height</code>.
 *
 * @param rect the rectangle to draw
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the rectangle is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawRectangle (Rectangle rect) {
    if (rect is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    drawRectangle (rect.x, rect.y, rect.width, rect.height);
}

/**
 * Draws the outline of the round-cornered rectangle specified by
 * the arguments, using the receiver's foreground color. The left and
 * right edges of the rectangle are at <code>x</code> and <code>x + width</code>.
 * The top and bottom edges are at <code>y</code> and <code>y + height</code>.
 * The <em>roundness</em> of the corners is specified by the
 * <code>arcWidth</code> and <code>arcHeight</code> arguments, which
 * are respectively the width and height of the ellipse used to draw
 * the corners.
 *
 * @param x the x coordinate of the rectangle to be drawn
 * @param y the y coordinate of the rectangle to be drawn
 * @param width the width of the rectangle to be drawn
 * @param height the height of the rectangle to be drawn
 * @param arcWidth the width of the arc
 * @param arcHeight the height of the arc
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawRoundRectangle (int x, int y, int width, int height, int arcWidth, int arcHeight) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(DRAW);
    if (data.gdipGraphics !is null) {
        drawRoundRectangleGdip(data.gdipGraphics, data.gdipPen, x, y, width, height, arcWidth, arcHeight);
        return;
    }
    if ((data.style & SWT.MIRRORED) !is 0) {
        if (data.lineWidth !is 0 && data.lineWidth % 2 is 0) x--;
    }
    static if (OS.IsWinCE) {
        /*
        * Bug in WinCE PPC.  On certain devices, RoundRect does not draw
        * all the pixels.  The workaround is to draw a round rectangle
        * using lines and arcs.
        */
        if (width is 0 || height is 0) return;
        if (arcWidth is 0 || arcHeight is 0) {
            drawRectangle(x, y, width, height);
            return;
        }
        if (width < 0) {
            x += width;
            width = -width;
        }
        if (height < 0) {
            y += height;
            height = -height;
        }
        if (arcWidth < 0) arcWidth = -arcWidth;
        if (arcHeight < 0) arcHeight = -arcHeight;
        if (arcWidth > width) arcWidth = width;
        if (arcHeight > height) arcHeight = height;

        if (arcWidth < width) {
            drawLine(x+arcWidth/2, y, x+width-arcWidth/2, y);
            drawLine(x+arcWidth/2, y+height, x+width-arcWidth/2, y+height);
        }
        if (arcHeight < height) {
            drawLine(x, y+arcHeight/2, x, y+height-arcHeight/2);
            drawLine(x+width, y+arcHeight/2, x+width, y+height-arcHeight/2);
        }
        if (arcWidth !is 0 && arcHeight !is 0) {
            drawArc(x, y, arcWidth, arcHeight, 90, 90);
            drawArc(x+width-arcWidth, y, arcWidth, arcHeight, 0, 90);
            drawArc(x+width-arcWidth, y+height-arcHeight, arcWidth, arcHeight, 0, -90);
            drawArc(x, y+height-arcHeight, arcWidth, arcHeight, 180, 90);
        }
    } else {
        OS.RoundRect(handle, x,y,x+width+1,y+height+1, arcWidth, arcHeight);
    }
}

void drawRoundRectangleGdip (Gdip.Graphics gdipGraphics, Gdip.Pen pen, int x, int y, int width, int height, int arcWidth, int arcHeight) {
    int nx = x;
    int ny = y;
    int nw = width;
    int nh = height;
    int naw = arcWidth;
    int nah = arcHeight;

    if (nw < 0) {
        nw = 0 - nw;
        nx = nx - nw;
    }
    if (nh < 0) {
        nh = 0 - nh;
        ny = ny - nh;
    }
    if (naw < 0)
        naw = 0 - naw;
    if (nah < 0)
        nah = 0 - nah;

    Gdip.Graphics_TranslateTransform(gdipGraphics, data.gdipXOffset, data.gdipYOffset, Gdip.MatrixOrderPrepend);
    if (naw is 0 || nah is 0) {
        Gdip.Graphics_DrawRectangle(gdipGraphics, data.gdipPen, x, y, width, height);
    } else {
        auto path = Gdip.GraphicsPath_new(Gdip.FillModeAlternate);
        if (path is null) SWT.error(SWT.ERROR_NO_HANDLES);
        if (nw > naw) {
            if (nh > nah) {
                Gdip.GraphicsPath_AddArc(path, nx + nw - naw, ny, naw, nah, 0, -90);
                Gdip.GraphicsPath_AddArc(path, nx, ny, naw, nah, -90, -90);
                Gdip.GraphicsPath_AddArc(path, nx, ny + nh - nah, naw, nah, -180, -90);
                Gdip.GraphicsPath_AddArc(path, nx + nw - naw, ny + nh - nah, naw, nah, -270, -90);
            } else {
                Gdip.GraphicsPath_AddArc(path, nx + nw - naw, ny, naw, nh, -270, -180);
                Gdip.GraphicsPath_AddArc(path, nx, ny, naw, nh, -90, -180);
            }
        } else {
            if (nh > nah) {
                Gdip.GraphicsPath_AddArc(path, nx, ny, nw, nah, 0, -180);
                Gdip.GraphicsPath_AddArc(path, nx, ny + nh - nah, nw, nah, -180, -180);
            } else {
                Gdip.GraphicsPath_AddArc(path, nx, ny, nw, nh, 0, 360);
            }
        }
        Gdip.GraphicsPath_CloseFigure(path);
        Gdip.Graphics_DrawPath(gdipGraphics, pen, path);
        Gdip.GraphicsPath_delete(path);
    }
    Gdip.Graphics_TranslateTransform(gdipGraphics, -data.gdipXOffset, -data.gdipYOffset, Gdip.MatrixOrderPrepend);
}

/**
 * Draws the given string, using the receiver's current font and
 * foreground color. No tab expansion or carriage return processing
 * will be performed. The background of the rectangular area where
 * the string is being drawn will be filled with the receiver's
 * background color.
 *
 * @param string the string to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the string is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the string is to be drawn
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawString (String string, int x, int y) {
    drawString(string, x, y, false);
}

/**
 * Draws the given string, using the receiver's current font and
 * foreground color. No tab expansion or carriage return processing
 * will be performed. If <code>isTransparent</code> is <code>true</code>,
 * then the background of the rectangular area where the string is being
 * drawn will not be modified, otherwise it will be filled with the
 * receiver's background color.
 *
 * @param string the string to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the string is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the string is to be drawn
 * @param isTransparent if <code>true</code> the background will be transparent, otherwise it will be opaque
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawString (String string, int x, int y, bool isTransparent) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    // SWT extension: allow null string
    //if (string is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
//  TCHAR buffer = new TCHAR (getCodePage(), string, false);
    String16 wstr = StrToWCHARs( string );
    int length_ = cast(int)/*64bit*/wstr.length;
    if (length_ is 0) return;
    auto buffer = wstr.ptr;
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        checkGC(FONT | FOREGROUND | (isTransparent ? 0 : BACKGROUND));
        Gdip.PointF pt;
        auto format = Gdip.StringFormat_Clone(Gdip.StringFormat_GenericTypographic());
        int formatFlags = Gdip.StringFormat_GetFormatFlags(format) | Gdip.StringFormatFlagsMeasureTrailingSpaces;
        if ((data.style & SWT.MIRRORED) !is 0) formatFlags |= Gdip.StringFormatFlagsDirectionRightToLeft;
        Gdip.StringFormat_SetFormatFlags(format, formatFlags);
        if (!isTransparent) {
            Gdip.RectF bounds;
            Gdip.Graphics_MeasureString(gdipGraphics, buffer, length_, data.gdipFont, pt, format, bounds);
            Gdip.Graphics_FillRectangle(gdipGraphics, data.gdipBrush, x, y, Math.round(bounds.Width), Math.round(bounds.Height));
        }
        int gstate = 0;
        auto brush = getFgBrush();
        if ((data.style & SWT.MIRRORED) !is 0) {
            switch (Gdip.Brush_GetType(brush)) {
                case Gdip.BrushTypeLinearGradient:
                    Gdip.LinearGradientBrush_ScaleTransform(cast(Gdip.LinearGradientBrush)brush, -1, 1, Gdip.MatrixOrderPrepend);
                    Gdip.LinearGradientBrush_TranslateTransform(cast(Gdip.LinearGradientBrush)brush, - 2 * x, 0, Gdip.MatrixOrderPrepend);
                    break;
                case Gdip.BrushTypeTextureFill:
                    Gdip.TextureBrush_ScaleTransform(cast(Gdip.TextureBrush)brush, -1, 1, Gdip.MatrixOrderPrepend);
                    Gdip.TextureBrush_TranslateTransform(cast(Gdip.TextureBrush)brush, - 2 * x, 0, Gdip.MatrixOrderPrepend);
                    break;
                default:
            }
            gstate = Gdip.Graphics_Save(gdipGraphics);
            Gdip.Graphics_ScaleTransform(gdipGraphics, -1, 1, Gdip.MatrixOrderPrepend);
            Gdip.Graphics_TranslateTransform(gdipGraphics, - 2 * x, 0, Gdip.MatrixOrderPrepend);
        }
        pt.X = x;
        pt.Y = y;
        Gdip.Graphics_DrawString(gdipGraphics, buffer, length_, data.gdipFont, pt, format, brush);
        if ((data.style & SWT.MIRRORED) !is 0) {
            switch (Gdip.Brush_GetType(brush)) {
                case Gdip.BrushTypeLinearGradient:
                    Gdip.LinearGradientBrush_ResetTransform(cast(Gdip.LinearGradientBrush)brush);
                    break;
                case Gdip.BrushTypeTextureFill:
                    Gdip.TextureBrush_ResetTransform(cast(Gdip.TextureBrush)brush);
                    break;
                default:
            }
            Gdip.Graphics_Restore(gdipGraphics, gstate);
        }
        Gdip.StringFormat_delete(format);
        return;
    }
    int rop2 = 0;
    static if (OS.IsWinCE) {
        rop2 = OS.SetROP2(handle, OS.R2_COPYPEN);
        OS.SetROP2(handle, rop2);
    } else {
        rop2 = OS.GetROP2(handle);
    }
    checkGC(FONT | FOREGROUND_TEXT | BACKGROUND_TEXT);
    int oldBkMode = OS.SetBkMode(handle, isTransparent ? OS.TRANSPARENT : OS.OPAQUE);
    RECT rect;
    SIZE size;
    bool sizeValid = false;
    int flags = 0;
    if ((data.style & SWT.MIRRORED) !is 0) {
        if (!isTransparent) {
            sizeValid = true;
            OS.GetTextExtentPoint32W(handle, buffer, length_, &size);
            rect.left = x;
            rect.right = x + size.cx;
            rect.top = y;
            rect.bottom = y + size.cy;
            flags = OS.ETO_CLIPPED;
        }
        x--;
    }
    if (rop2 !is OS.R2_XORPEN) {
        OS.ExtTextOutW(handle, x, y, flags, &rect, buffer, length_, null);
    } else {
        int foreground = OS.GetTextColor(handle);
        if (isTransparent) {
            if (!sizeValid) {
                OS.GetTextExtentPoint32W(handle, buffer, length_, &size);
            }
            int width = size.cx, height = size.cy;
            auto hBitmap = OS.CreateCompatibleBitmap(handle, width, height);
            if (hBitmap is null) SWT.error(SWT.ERROR_NO_HANDLES);
            auto memDC = OS.CreateCompatibleDC(handle);
            auto hOldBitmap = OS.SelectObject(memDC, hBitmap);
            OS.PatBlt(memDC, 0, 0, width, height, OS.BLACKNESS);
            OS.SetBkMode(memDC, OS.TRANSPARENT);
            OS.SetTextColor(memDC, foreground);
            OS.SelectObject(memDC, OS.GetCurrentObject(handle, OS.OBJ_FONT));
            OS.ExtTextOutW(memDC, 0, 0, 0, null, buffer, length_, null);
            OS.BitBlt(handle, x, y, width, height, memDC, 0, 0, OS.SRCINVERT);
            OS.SelectObject(memDC, hOldBitmap);
            OS.DeleteDC(memDC);
            OS.DeleteObject(hBitmap);
        } else {
            auto background = OS.GetBkColor(handle);
            OS.SetTextColor(handle, foreground ^ background);
            OS.ExtTextOutW(handle, x, y, flags, &rect, buffer, length_, null);
            OS.SetTextColor(handle, foreground);
        }
    }
    OS.SetBkMode(handle, oldBkMode);
}

/**
 * Draws the given string, using the receiver's current font and
 * foreground color. Tab expansion and carriage return processing
 * are performed. The background of the rectangular area where
 * the text is being drawn will be filled with the receiver's
 * background color.
 *
 * @param string the string to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawText (String string, int x, int y) {
    drawText(string, x, y, SWT.DRAW_DELIMITER | SWT.DRAW_TAB);
}

/**
 * Draws the given string, using the receiver's current font and
 * foreground color. Tab expansion and carriage return processing
 * are performed. If <code>isTransparent</code> is <code>true</code>,
 * then the background of the rectangular area where the text is being
 * drawn will not be modified, otherwise it will be filled with the
 * receiver's background color.
 *
 * @param string the string to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param isTransparent if <code>true</code> the background will be transparent, otherwise it will be opaque
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawText (String string, int x, int y, bool isTransparent) {
    int flags = SWT.DRAW_DELIMITER | SWT.DRAW_TAB;
    if (isTransparent) flags |= SWT.DRAW_TRANSPARENT;
    drawText(string, x, y, flags);
}

/**
 * Draws the given string, using the receiver's current font and
 * foreground color. Tab expansion, line delimiter and mnemonic
 * processing are performed according to the specified flags. If
 * <code>flags</code> includes <code>DRAW_TRANSPARENT</code>,
 * then the background of the rectangular area where the text is being
 * drawn will not be modified, otherwise it will be filled with the
 * receiver's background color.
 * <p>
 * The parameter <code>flags</code> may be a combination of:
 * <dl>
 * <dt><b>DRAW_DELIMITER</b></dt>
 * <dd>draw multiple lines</dd>
 * <dt><b>DRAW_TAB</b></dt>
 * <dd>expand tabs</dd>
 * <dt><b>DRAW_MNEMONIC</b></dt>
 * <dd>underline the mnemonic character</dd>
 * <dt><b>DRAW_TRANSPARENT</b></dt>
 * <dd>transparent background</dd>
 * </dl>
 * </p>
 *
 * @param string the string to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param flags the flags specifying how to process the text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawText (String string, int x, int y, int flags) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    // SWT extension: allow null string
    //if (string is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (string.length is 0) return;
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        checkGC(FONT | FOREGROUND | ((flags & SWT.DRAW_TRANSPARENT) !is 0 ? 0 : BACKGROUND));
        String16 wstr = StrToWCHARs( string );
        int length_ = cast(int)/*64bit*/wstr.length;
        auto buffer = wstr.ptr;
        Gdip.PointF pt;
        auto format = Gdip.StringFormat_Clone(Gdip.StringFormat_GenericTypographic());
        int formatFlags = Gdip.StringFormat_GetFormatFlags(format) | Gdip.StringFormatFlagsMeasureTrailingSpaces;
        if ((data.style & SWT.MIRRORED) !is 0) formatFlags |= Gdip.StringFormatFlagsDirectionRightToLeft;
        Gdip.StringFormat_SetFormatFlags(format, formatFlags);
        float[] tabs = (flags & SWT.DRAW_TAB) !is 0 ? [ cast(float) measureSpace(data.gdipFont, format) * 8] : new float[1];
        Gdip.StringFormat_SetTabStops(format, 0, cast(int)/*64bit*/tabs.length, tabs.ptr);
        int hotkeyPrefix = (flags & SWT.DRAW_MNEMONIC) !is 0 ? Gdip.HotkeyPrefixShow : Gdip.HotkeyPrefixNone;
        if ((flags & SWT.DRAW_MNEMONIC) !is 0 && (data.uiState & OS.UISF_HIDEACCEL) !is 0) hotkeyPrefix = Gdip.HotkeyPrefixHide;
        Gdip.StringFormat_SetHotkeyPrefix(format, hotkeyPrefix);
        if ((flags & SWT.DRAW_TRANSPARENT) is 0) {
            Gdip.RectF bounds;
            Gdip.Graphics_MeasureString(gdipGraphics, buffer, length_, data.gdipFont, pt, format, bounds);
            Gdip.Graphics_FillRectangle(gdipGraphics, data.gdipBrush, x, y, Math.round(bounds.Width), Math.round(bounds.Height));
        }
        int gstate = 0;
        auto brush = getFgBrush();
        if ((data.style & SWT.MIRRORED) !is 0) {
            switch (Gdip.Brush_GetType(brush)) {
                case Gdip.BrushTypeLinearGradient:
                    Gdip.LinearGradientBrush_ScaleTransform(cast(Gdip.LinearGradientBrush)brush, -1, 1, Gdip.MatrixOrderPrepend);
                    Gdip.LinearGradientBrush_TranslateTransform(cast(Gdip.LinearGradientBrush)brush, - 2 * x, 0, Gdip.MatrixOrderPrepend);
                    break;
                case Gdip.BrushTypeTextureFill:
                    Gdip.TextureBrush_ScaleTransform(cast(Gdip.TextureBrush)brush, -1, 1, Gdip.MatrixOrderPrepend);
                    Gdip.TextureBrush_TranslateTransform(cast(Gdip.TextureBrush)brush, - 2 * x, 0, Gdip.MatrixOrderPrepend);
                    break;
                default:
            }
            gstate = Gdip.Graphics_Save(gdipGraphics);
            Gdip.Graphics_ScaleTransform(gdipGraphics, -1, 1, Gdip.MatrixOrderPrepend);
            Gdip.Graphics_TranslateTransform(gdipGraphics, - 2 * x, 0, Gdip.MatrixOrderPrepend);
        }
        pt.X = x;
        pt.Y = y;
        Gdip.Graphics_DrawString(gdipGraphics, buffer, length_, data.gdipFont, pt, format, brush);
        if ((data.style & SWT.MIRRORED) !is 0) {
            switch (Gdip.Brush_GetType(brush)) {
                case Gdip.BrushTypeLinearGradient:
                    Gdip.LinearGradientBrush_ResetTransform(cast(Gdip.LinearGradientBrush)brush);
                    break;
                case Gdip.BrushTypeTextureFill:
                    Gdip.TextureBrush_ResetTransform(cast(Gdip.TextureBrush)brush);
                    break;
                default:
            }
            Gdip.Graphics_Restore(gdipGraphics, gstate);
        }
        Gdip.StringFormat_delete(format);
        return;
    }
    StringT wstr = StrToTCHARs( string );
    auto buffer = wstr.ptr;
    int length_ = cast(int)/*64bit*/wstr.length;
    if (length_ is 0) return;
    RECT rect;
    /*
    * Feature in Windows.  For some reason DrawText(), the maximum
    * value for the bottom and right coordinates for the RECT that
    * is used to position the text is different on between Windows
    * versions.  If this value is larger than the maximum, nothing
    * is drawn.  On Windows 98, the limit is 0x7FFF.  On Windows CE,
    * NT, and 2000 it is 0x6FFFFFF. And on XP, it is 0x7FFFFFFF.
    * The fix is to use the the smaller limit for Windows 98 and the
    * larger limit on the other Windows platforms.
    */
    int limit = OS.IsWin95 ? 0x7FFF : 0x6FFFFFF;
    OS.SetRect(&rect, x, y, limit, limit);
    int uFormat = OS.DT_LEFT;
    if ((flags & SWT.DRAW_DELIMITER) is 0) uFormat |= OS.DT_SINGLELINE;
    if ((flags & SWT.DRAW_TAB) !is 0) uFormat |= OS.DT_EXPANDTABS;
    if ((flags & SWT.DRAW_MNEMONIC) is 0) uFormat |= OS.DT_NOPREFIX;
    if ((flags & SWT.DRAW_MNEMONIC) !is 0 && (data.uiState & OS.UISF_HIDEACCEL) !is 0) {
        uFormat |= OS.DT_HIDEPREFIX;
    }
    int rop2 = 0;
    static if (OS.IsWinCE) {
        rop2 = OS.SetROP2(handle, OS.R2_COPYPEN);
        OS.SetROP2(handle, rop2);
    } else {
        rop2 = OS.GetROP2(handle);
    }
    checkGC(FONT | FOREGROUND_TEXT | BACKGROUND_TEXT);
    int oldBkMode = OS.SetBkMode(handle, (flags & SWT.DRAW_TRANSPARENT) !is 0 ? OS.TRANSPARENT : OS.OPAQUE);
    if (rop2 !is OS.R2_XORPEN) {
        OS.DrawText(handle, buffer, length_, &rect, uFormat);
    } else {
        int foreground = OS.GetTextColor(handle);
        if ((flags & SWT.DRAW_TRANSPARENT) !is 0) {
            OS.DrawText(handle, buffer, length_, &rect, uFormat | OS.DT_CALCRECT);
            int width = rect.right - rect.left;
            int height = rect.bottom - rect.top;
            auto hBitmap = OS.CreateCompatibleBitmap(handle, width, height);
            if (hBitmap is null) SWT.error(SWT.ERROR_NO_HANDLES);
            auto memDC = OS.CreateCompatibleDC(handle);
            auto hOldBitmap = OS.SelectObject(memDC, hBitmap);
            OS.PatBlt(memDC, 0, 0, width, height, OS.BLACKNESS);
            OS.SetBkMode(memDC, OS.TRANSPARENT);
            OS.SetTextColor(memDC, foreground);
            OS.SelectObject(memDC, OS.GetCurrentObject(handle, OS.OBJ_FONT));
            OS.SetRect(&rect, 0, 0, 0x7FFF, 0x7FFF);
            OS.DrawText(memDC, buffer, length_, &rect, uFormat);
            OS.BitBlt(handle, x, y, width, height, memDC, 0, 0, OS.SRCINVERT);
            OS.SelectObject(memDC, hOldBitmap);
            OS.DeleteDC(memDC);
            OS.DeleteObject(hBitmap);
        } else {
            int background = OS.GetBkColor(handle);
            OS.SetTextColor(handle, foreground ^ background);
            OS.DrawText(handle, buffer, length_, &rect, uFormat);
            OS.SetTextColor(handle, foreground);
        }
    }
    OS.SetBkMode(handle, oldBkMode);
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
    return (object is this) || (null !is (cast(GC)object) && (handle is (cast(GC)object).handle));
}

/**
 * Fills the interior of a circular or elliptical arc within
 * the specified rectangular area, with the receiver's background
 * color.
 * <p>
 * The resulting arc begins at <code>startAngle</code> and extends
 * for <code>arcAngle</code> degrees, using the current color.
 * Angles are interpreted such that 0 degrees is at the 3 o'clock
 * position. A positive value indicates a counter-clockwise rotation
 * while a negative value indicates a clockwise rotation.
 * </p><p>
 * The center of the arc is the center of the rectangle whose origin
 * is (<code>x</code>, <code>y</code>) and whose size is specified by the
 * <code>width</code> and <code>height</code> arguments.
 * </p><p>
 * The resulting arc covers an area <code>width + 1</code> pixels wide
 * by <code>height + 1</code> pixels tall.
 * </p>
 *
 * @param x the x coordinate of the upper-left corner of the arc to be filled
 * @param y the y coordinate of the upper-left corner of the arc to be filled
 * @param width the width of the arc to be filled
 * @param height the height of the arc to be filled
 * @param startAngle the beginning angle
 * @param arcAngle the angular extent of the arc, relative to the start angle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawArc
 */
public void fillArc (int x, int y, int width, int height, int startAngle, int arcAngle) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(FILL);
    if (width < 0) {
        x = x + width;
        width = -width;
    }
    if (height < 0) {
        y = y + height;
        height = -height;
    }
    if (width is 0 || height is 0 || arcAngle is 0) return;
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        if (width is height) {
            Gdip.Graphics_FillPie(gdipGraphics, data.gdipBrush, x, y, width, height, -startAngle, -arcAngle);
        } else {
            int state = Gdip.Graphics_Save(gdipGraphics);
            Gdip.Graphics_TranslateTransform(gdipGraphics, x, y, Gdip.MatrixOrderPrepend);
            Gdip.Graphics_ScaleTransform(gdipGraphics, width, height, Gdip.MatrixOrderPrepend);
            Gdip.Graphics_FillPie(gdipGraphics, data.gdipBrush, 0, 0, 1, 1, -startAngle, -arcAngle);
            Gdip.Graphics_Restore(gdipGraphics, state);
        }
        return;
    }

    if ((data.style & SWT.MIRRORED) !is 0) x--;
    /*
    * Feature in WinCE.  The function Pie is not present in the
    * WinCE SDK.  The fix is to emulate it by using Polygon.
    */
    static if (OS.IsWinCE) {
        /* compute arc with a simple linear interpolation */
        if (arcAngle < 0) {
            startAngle += arcAngle;
            arcAngle = -arcAngle;
        }
        bool drawSegments = true;
        if (arcAngle >= 360) {
            arcAngle = 360;
            drawSegments = false;
        }
        int[] points = new int[(arcAngle + 1) * 2 + (drawSegments ? 4 : 0)];
        int cteX = 2 * x + width;
        int cteY = 2 * y + height;
        int index = (drawSegments ? 2 : 0);
        for (int i = 0; i <= arcAngle; i++) {
            points[index++] = (Compatibility.cos(startAngle + i, width) + cteX) >> 1;
            points[index++] = (cteY - Compatibility.sin(startAngle + i, height)) >> 1;
        }
        if (drawSegments) {
            points[0] = points[points.length - 2] = cteX >> 1;
            points[1] = points[points.length - 1] = cteY >> 1;
        }
        OS.Polygon(handle, cast(POINT*)points.ptr, points.length / 2);
    } else {
        int x1, y1, x2, y2,tmp;
        bool isNegative;
        if (arcAngle >= 360 || arcAngle <= -360) {
            x1 = x2 = x + width;
            y1 = y2 = y + height / 2;
        } else {
            isNegative = arcAngle < 0;

            arcAngle = arcAngle + startAngle;
            if (isNegative) {
                // swap angles
                tmp = startAngle;
                startAngle = arcAngle;
                arcAngle = tmp;
            }
            x1 = Compatibility.cos(startAngle, width) + x + width/2;
            y1 = -1 * Compatibility.sin(startAngle, height) + y + height/2;

            x2 = Compatibility.cos(arcAngle, width) + x + width/2;
            y2 = -1 * Compatibility.sin(arcAngle, height) + y + height/2;
        }
        OS.Pie(handle, x, y, x + width + 1, y + height + 1, x1, y1, x2, y2);
    }
}

/**
 * Fills the interior of the specified rectangle with a gradient
 * sweeping from left to right or top to bottom progressing
 * from the receiver's foreground color to its background color.
 *
 * @param x the x coordinate of the rectangle to be filled
 * @param y the y coordinate of the rectangle to be filled
 * @param width the width of the rectangle to be filled, may be negative
 *        (inverts direction of gradient if horizontal)
 * @param height the height of the rectangle to be filled, may be negative
 *        (inverts direction of gradient if vertical)
 * @param vertical if true sweeps from top to bottom, else
 *        sweeps from left to right
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawRectangle(int, int, int, int)
 */
public void fillGradientRectangle(int x, int y, int width, int height, bool vertical) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (width is 0 || height is 0) return;

    RGB backgroundRGB, foregroundRGB;
    backgroundRGB = getBackground().getRGB();
    foregroundRGB = getForeground().getRGB();

    RGB fromRGB, toRGB;
    fromRGB = foregroundRGB;
    toRGB   = backgroundRGB;

    bool swapColors = false;
    if (width < 0) {
        x += width; width = -width;
        if (! vertical) swapColors = true;
    }
    if (height < 0) {
        y += height; height = -height;
        if (vertical) swapColors = true;
    }
    if (swapColors) {
        fromRGB = backgroundRGB;
        toRGB   = foregroundRGB;
    }
    if (fromRGB ==/*eq*/ toRGB) {
        fillRectangle(x, y, width, height);
        return;
    }
    if (data.gdipGraphics !is null) {
        initGdip();
        Gdip.PointF p1, p2;
        p1.X = x;
        p1.Y = y;
        if (vertical) {
            p2.X = p1.X;
            p2.Y = p1.Y + height;
        } else {
            p2.X = p1.X + width;
            p2.Y = p1.Y;
        }
        int rgb = ((fromRGB.red & 0xFF) << 16) | ((fromRGB.green & 0xFF) << 8) | (fromRGB.blue & 0xFF);
        auto fromGpColor = Gdip.Color_new(data.alpha << 24 | rgb);
        //if (fromGpColor is null) SWT.error(SWT.ERROR_NO_HANDLES);
        rgb = ((toRGB.red & 0xFF) << 16) | ((toRGB.green & 0xFF) << 8) | (toRGB.blue & 0xFF);
        auto toGpColor = Gdip.Color_new(data.alpha << 24 | rgb);
        //if (toGpColor is null) SWT.error(SWT.ERROR_NO_HANDLES);
        auto brush = Gdip.LinearGradientBrush_new(p1, p2, fromGpColor, toGpColor);
        Gdip.Graphics_FillRectangle(data.gdipGraphics, cast(Gdip.Brush)brush, x, y, width, height);
        Gdip.LinearGradientBrush_delete(brush);
        Gdip.Color_delete(fromGpColor);
        Gdip.Color_delete(toGpColor);
        return;
    }
    /* Use GradientFill if supported, only on Windows 98, 2000 and newer. */
    /*
    * Bug in Windows: On Windows 2000 when the device is a printer,
    * GradientFill swaps red and blue color components, causing the
    * gradient to be printed in the wrong color. On Windows 98 when
    * the device is a printer, GradientFill does not fill completely
    * to the right edge of the rectangle. The fix is not to use
    * GradientFill for printer devices.
    */
    int rop2 = 0;
    static if (OS.IsWinCE) {
        rop2 = OS.SetROP2(handle, OS.R2_COPYPEN);
        OS.SetROP2(handle, rop2);
    } else {
        rop2 = OS.GetROP2(handle);
    }
    if (OS.IsWinNT && rop2 !is OS.R2_XORPEN && OS.GetDeviceCaps(handle, OS.TECHNOLOGY) !is OS.DT_RASPRINTER) {
        auto hHeap = OS.GetProcessHeap();
        auto pMesh = OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, GRADIENT_RECT.sizeof + TRIVERTEX.sizeof * 2);
        if (pMesh is null) SWT.error(SWT.ERROR_NO_HANDLES);
        auto pVertex = cast(TRIVERTEX*)( pMesh + GRADIENT_RECT.sizeof );

        GRADIENT_RECT gradientRect;
        gradientRect.UpperLeft = 0;
        gradientRect.LowerRight = 1;
        *cast(GRADIENT_RECT*)pMesh = gradientRect;

        TRIVERTEX* trivertex = pVertex;
        trivertex.x = x;
        trivertex.y = y;
        trivertex.Red = cast(short)((fromRGB.red << 8) | fromRGB.red);
        trivertex.Green = cast(short)((fromRGB.green << 8) | fromRGB.green);
        trivertex.Blue = cast(short)((fromRGB.blue << 8) | fromRGB.blue);
        trivertex.Alpha = ushort.max;

        trivertex = pVertex+1;
        trivertex.x = x + width;
        trivertex.y = y + height;
        trivertex.Red = cast(short)((toRGB.red << 8) | toRGB.red);
        trivertex.Green = cast(short)((toRGB.green << 8) | toRGB.green);
        trivertex.Blue = cast(short)((toRGB.blue << 8) | toRGB.blue);
        trivertex.Alpha = ushort.max;

        bool success = cast(bool)OS.GradientFill(handle, pVertex, 2, pMesh, 1, vertical ? OS.GRADIENT_FILL_RECT_V : OS.GRADIENT_FILL_RECT_H);
        OS.HeapFree(hHeap, 0, pMesh);
        if (success) return;
    }

    int depth = OS.GetDeviceCaps(handle, OS.BITSPIXEL);
    int bitResolution = (depth >= 24) ? 8 : (depth >= 15) ? 5 : 0;
    ImageData.fillGradientRectangle(this, data.device,
        x, y, width, height, vertical, fromRGB, toRGB,
        bitResolution, bitResolution, bitResolution);
}

/**
 * Fills the interior of an oval, within the specified
 * rectangular area, with the receiver's background
 * color.
 *
 * @param x the x coordinate of the upper left corner of the oval to be filled
 * @param y the y coordinate of the upper left corner of the oval to be filled
 * @param width the width of the oval to be filled
 * @param height the height of the oval to be filled
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawOval
 */
public void fillOval (int x, int y, int width, int height) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(FILL);
    if (data.gdipGraphics !is null) {
        Gdip.Graphics_FillEllipse(data.gdipGraphics, data.gdipBrush, x, y, width, height);
        return;
    }
    if ((data.style & SWT.MIRRORED) !is 0) x--;
    OS.Ellipse(handle, x, y, x + width + 1, y + height + 1);
}

/**
 * Fills the path described by the parameter.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param path the path to fill
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parameter is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see Path
 *
 * @since 3.1
 */
public void fillPath (Path path) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (path is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (path.handle is null) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    initGdip();
    checkGC(FILL);
    int mode = OS.GetPolyFillMode(handle) is OS.WINDING ? Gdip.FillModeWinding : Gdip.FillModeAlternate;
    Gdip.GraphicsPath_SetFillMode(path.handle, mode);
    Gdip.Graphics_FillPath(data.gdipGraphics, data.gdipBrush, path.handle);
}

/**
 * Fills the interior of the closed polygon which is defined by the
 * specified array of integer coordinates, using the receiver's
 * background color. The array contains alternating x and y values
 * which are considered to represent points which are the vertices of
 * the polygon. Lines are drawn between each consecutive pair, and
 * between the first pair and last pair in the array.
 *
 * @param pointArray an array of alternating x and y values which are the vertices of the polygon
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawPolygon
 */
public void fillPolygon(int[] pointArray) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    // SWT externsion: allow null array
    //if (pointArray is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    checkGC(FILL);
    if (data.gdipGraphics !is null) {
        int mode = OS.GetPolyFillMode(handle) is OS.WINDING ? Gdip.FillModeWinding : Gdip.FillModeAlternate;
        Gdip.Graphics_FillPolygon(data.gdipGraphics, data.gdipBrush, cast(Gdip.Point*)pointArray.ptr, cast(int)/*64bit*/pointArray.length / 2, mode);
        return;
    }
    if ((data.style & SWT.MIRRORED) !is 0) {
        for (int i = 0; i < pointArray.length; i+=2) {
            pointArray[i]--;
        }
    }
    OS.Polygon(handle, cast(POINT*)pointArray.ptr, cast(int)/*64bit*/pointArray.length / 2);
    if ((data.style & SWT.MIRRORED) !is 0) {
        for (int i = 0; i < pointArray.length; i+=2) {
            pointArray[i]++;
        }
    }
}

/**
 * Fills the interior of the rectangle specified by the arguments,
 * using the receiver's background color.
 *
 * @param x the x coordinate of the rectangle to be filled
 * @param y the y coordinate of the rectangle to be filled
 * @param width the width of the rectangle to be filled
 * @param height the height of the rectangle to be filled
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawRectangle(int, int, int, int)
 */
public void fillRectangle (int x, int y, int width, int height) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(FILL);
    if (data.gdipGraphics !is null) {
        if (width < 0) {
            x = x + width;
            width = -width;
        }
        if (height < 0) {
            y = y + height;
            height = -height;
        }
        Gdip.Graphics_FillRectangle(data.gdipGraphics, data.gdipBrush, x, y, width, height);
        return;
    }
    int rop2 = 0;
    static if (OS.IsWinCE) {
        rop2 = OS.SetROP2(handle, OS.R2_COPYPEN);
        OS.SetROP2(handle, rop2);
    } else {
        rop2 = OS.GetROP2(handle);
    }
    int dwRop = rop2 is OS.R2_XORPEN ? OS.PATINVERT : OS.PATCOPY;
    OS.PatBlt(handle, x, y, width, height, dwRop);
}

/**
 * Fills the interior of the specified rectangle, using the receiver's
 * background color.
 *
 * @param rect the rectangle to be filled
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the rectangle is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawRectangle(int, int, int, int)
 */
public void fillRectangle (Rectangle rect) {
    if (rect is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    fillRectangle (rect.x, rect.y, rect.width, rect.height);
}

/**
 * Fills the interior of the round-cornered rectangle specified by
 * the arguments, using the receiver's background color.
 *
 * @param x the x coordinate of the rectangle to be filled
 * @param y the y coordinate of the rectangle to be filled
 * @param width the width of the rectangle to be filled
 * @param height the height of the rectangle to be filled
 * @param arcWidth the width of the arc
 * @param arcHeight the height of the arc
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #drawRoundRectangle
 */
public void fillRoundRectangle (int x, int y, int width, int height, int arcWidth, int arcHeight) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(FILL);
    if (data.gdipGraphics !is null) {
        fillRoundRectangleGdip(data.gdipGraphics, data.gdipBrush, x, y, width, height, arcWidth, arcHeight);
        return;
    }
    if ((data.style & SWT.MIRRORED) !is 0) x--;
    OS.RoundRect(handle, x,y,x+width+1,y+height+1,arcWidth, arcHeight);
}

void fillRoundRectangleGdip (Gdip.Graphics gdipGraphics, Gdip.Brush brush, int x, int y, int width, int height, int arcWidth, int arcHeight) {
    int nx = x;
    int ny = y;
    int nw = width;
    int nh = height;
    int naw = arcWidth;
    int nah = arcHeight;

    if (nw < 0) {
        nw = 0 - nw;
        nx = nx - nw;
    }
    if (nh < 0) {
        nh = 0 - nh;
        ny = ny -nh;
    }
    if (naw < 0)
        naw = 0 - naw;
    if (nah < 0)
        nah = 0 - nah;

    if (naw is 0 || nah is 0) {
        Gdip.Graphics_FillRectangle(data.gdipGraphics, data.gdipBrush, x, y, width, height);
    } else {
        auto path = Gdip.GraphicsPath_new(Gdip.FillModeAlternate);
        if (path is null) SWT.error(SWT.ERROR_NO_HANDLES);
        if (nw > naw) {
            if (nh > nah) {
                Gdip.GraphicsPath_AddArc(path, nx + nw - naw, ny, naw, nah, 0, -90);
                Gdip.GraphicsPath_AddArc(path, nx, ny, naw, nah, -90, -90);
                Gdip.GraphicsPath_AddArc(path, nx, ny + nh - nah, naw, nah, -180, -90);
                Gdip.GraphicsPath_AddArc(path, nx + nw - naw, ny + nh - nah, naw, nah, -270, -90);
            } else {
                Gdip.GraphicsPath_AddArc(path, nx + nw - naw, ny, naw, nh, -270, -180);
                Gdip.GraphicsPath_AddArc(path, nx, ny, naw, nh, -90, -180);
            }
        } else {
            if (nh > nah) {
                Gdip.GraphicsPath_AddArc(path, nx, ny, nw, nah, 0, -180);
                Gdip.GraphicsPath_AddArc(path, nx, ny + nh - nah, nw, nah, -180, -180);
            } else {
                Gdip.GraphicsPath_AddArc(path, nx, ny, nw, nh, 0, 360);
            }
        }
        Gdip.GraphicsPath_CloseFigure(path);
        Gdip.Graphics_FillPath(gdipGraphics, brush, path);
        Gdip.GraphicsPath_delete(path);
    }
}

void flush () {
    if (data.gdipGraphics !is null) {
        Gdip.Graphics_Flush(data.gdipGraphics, 0);
        /*
        * Note Flush() does not flush the output to the
        * underline HDC. This is done by calling GetHDC()
        * followed by ReleaseHDC().
        */
        auto hdc = Gdip.Graphics_GetHDC(data.gdipGraphics);
        Gdip.Graphics_ReleaseHDC(data.gdipGraphics, hdc);
    }
}

/**
 * Returns the <em>advance width</em> of the specified character in
 * the font which is currently selected into the receiver.
 * <p>
 * The advance width is defined as the horizontal distance the cursor
 * should move after printing the character in the selected font.
 * </p>
 *
 * @param ch the character to measure
 * @return the distance in the x direction to move past the character before painting the next
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getAdvanceWidth(char ch) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(FONT);
    static if (OS.IsWinCE) {
        SIZE size;
        OS.GetTextExtentPoint32W(handle, [ch], 1, &size);
        return size.cx;
    }
    int tch = ch;
    if (ch > 0x7F) {
        TryImmutable!(char)[1] str = ch;
        StringT buffer = StrToTCHARs( str );
        tch = buffer[0];
    }
    int width;
    OS.GetCharWidth(handle, tch, tch, &width);
    return width;
}

/**
 * Returns <code>true</code> if receiver is using the operating system's
 * advanced graphics subsystem.  Otherwise, <code>false</code> is returned
 * to indicate that normal graphics are in use.
 * <p>
 * Advanced graphics may not be installed for the operating system.  In this
 * case, <code>false</code> is always returned.  Some operating system have
 * only one graphics subsystem.  If this subsystem supports advanced graphics,
 * then <code>true</code> is always returned.  If any graphics operation such
 * as alpha, antialias, patterns, interpolation, paths, clipping or transformation
 * has caused the receiver to switch from regular to advanced graphics mode,
 * <code>true</code> is returned.  If the receiver has been explicitly switched
 * to advanced mode and this mode is supported, <code>true</code> is returned.
 * </p>
 *
 * @return the advanced value
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setAdvanced
 *
 * @since 3.1
 */
public bool getAdvanced() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return data.gdipGraphics !is null;
}

/**
 * Returns the receiver's alpha value. The alpha value
 * is between 0 (transparent) and 255 (opaque).
 *
 * @return the alpha value
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public int getAlpha() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return data.alpha;
}

/**
 * Returns the receiver's anti-aliasing setting value, which will be
 * one of <code>SWT.DEFAULT</code>, <code>SWT.OFF</code> or
 * <code>SWT.ON</code>. Note that this controls anti-aliasing for all
 * <em>non-text drawing</em> operations.
 *
 * @return the anti-aliasing setting
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getTextAntialias
 *
 * @since 3.1
 */
public int getAntialias() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (data.gdipGraphics is null) return SWT.DEFAULT;
    int mode = Gdip.Graphics_GetSmoothingMode(data.gdipGraphics);
    switch (mode) {
        case Gdip.SmoothingModeDefault: return SWT.DEFAULT;
        case Gdip.SmoothingModeHighSpeed:
        case Gdip.SmoothingModeNone: return SWT.OFF;
        case Gdip.SmoothingModeAntiAlias:
        case Gdip.SmoothingModeAntiAlias8x8:
        case Gdip.SmoothingModeHighQuality: return SWT.ON;
        default:
    }
    return SWT.DEFAULT;
}

/**
 * Returns the background color.
 *
 * @return the receiver's background color
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Color getBackground() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return Color.win32_new(data.device, data.background);
}

/**
 * Returns the background pattern. The default value is
 * <code>null</code>.
 *
 * @return the receiver's background pattern
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Pattern
 *
 * @since 3.1
 */
public Pattern getBackgroundPattern() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return data.backgroundPattern;
}

/**
 * Returns the width of the specified character in the font
 * selected into the receiver.
 * <p>
 * The width is defined as the space taken up by the actual
 * character, not including the leading and tailing whitespace
 * or overhang.
 * </p>
 *
 * @param ch the character to measure
 * @return the width of the character
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getCharWidth(char ch) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(FONT);

    /* GetCharABCWidths only succeeds on truetype fonts */
    static if (!OS.IsWinCE) {
        int tch = ch;
        if (ch > 0x7F) {
            TryImmutable!(char)[1] str = ch;
            StringT buffer = StrToTCHARs( str );
            tch = buffer[0];
        }
        ABC abc;
        if (OS.GetCharABCWidths(handle, tch, tch, &abc)) {
            return abc.abcA;
        }
    }

    /* It wasn't a truetype font */
    TEXTMETRIC lptm;
    OS.GetTextMetrics(handle, &lptm);
    SIZE size;
    TryImmutable!(char)[1] str = ch;
    OS.GetTextExtentPoint32W(handle, StrToWCHARz( str ), 1, &size);
    return size.cx - lptm.tmOverhang;
}

/**
 * Returns the bounding rectangle of the receiver's clipping
 * region. If no clipping region is set, the return value
 * will be a rectangle which covers the entire bounds of the
 * object the receiver is drawing on.
 *
 * @return the bounding rectangle of the clipping region
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Rectangle getClipping() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        Gdip.Rect rect;
        Gdip.Graphics_SetPixelOffsetMode(gdipGraphics, Gdip.PixelOffsetModeNone);
        Gdip.Graphics_GetVisibleClipBounds(gdipGraphics, rect);
        Gdip.Graphics_SetPixelOffsetMode(gdipGraphics, Gdip.PixelOffsetModeHalf);
        return new Rectangle(rect.X, rect.Y, rect.Width, rect.Height);
    }
    RECT rect;
    OS.GetClipBox(handle, &rect);
    return new Rectangle(rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top);
}

/**
 * Sets the region managed by the argument to the current
 * clipping region of the receiver.
 *
 * @param region the region to fill with the clipping region
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the region is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the region is disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void getClipping (Region region) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (region is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    if (region.isDisposed()) SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        auto rgn = Gdip.Region_new();
        Gdip.Graphics_GetClip(data.gdipGraphics, rgn);
        if (Gdip.Region_IsInfinite(rgn, gdipGraphics)) {
            Gdip.Rect rect;
            Gdip.Graphics_SetPixelOffsetMode(gdipGraphics, Gdip.PixelOffsetModeNone);
            Gdip.Graphics_GetVisibleClipBounds(gdipGraphics, rect);
            Gdip.Graphics_SetPixelOffsetMode(gdipGraphics, Gdip.PixelOffsetModeHalf);
            OS.SetRectRgn(region.handle, rect.X, rect.Y, rect.X + rect.Width, rect.Y + rect.Height);
        } else {
            auto matrix = Gdip.Matrix_new(1, 0, 0, 1, 0, 0);
            auto identity_ = Gdip.Matrix_new(1, 0, 0, 1, 0, 0);
            Gdip.Graphics_GetTransform(gdipGraphics, matrix);
            Gdip.Graphics_SetTransform(gdipGraphics, identity_);
            auto hRgn = Gdip.Region_GetHRGN(rgn, data.gdipGraphics);
            Gdip.Graphics_SetTransform(gdipGraphics, matrix);
            Gdip.Matrix_delete(identity_);
            Gdip.Matrix_delete(matrix);
            OS.CombineRgn(region.handle, hRgn, null, OS.RGN_COPY);
            OS.DeleteObject(hRgn);
        }
        Gdip.Region_delete(rgn);
        return;
    }
    POINT pt;
    static if (!OS.IsWinCE) OS.GetWindowOrgEx (handle, &pt);
    int result = OS.GetClipRgn (handle, region.handle);
    if (result !is 1) {
        RECT rect;
        OS.GetClipBox(handle, &rect);
        OS.SetRectRgn(region.handle, rect.left, rect.top, rect.right, rect.bottom);
    } else {
        OS.OffsetRgn (region.handle, pt.x, pt.y);
    }
    static if (!OS.IsWinCE) {
        auto metaRgn = OS.CreateRectRgn (0, 0, 0, 0);
        if (OS.GetMetaRgn (handle, metaRgn) !is 0) {
            OS.OffsetRgn (metaRgn, pt.x, pt.y);
            OS.CombineRgn (region.handle, metaRgn, region.handle, OS.RGN_AND);
        }
        OS.DeleteObject(metaRgn);
        auto hwnd = data.hwnd;
        if (hwnd !is null && data.ps !is null) {
            auto sysRgn = OS.CreateRectRgn (0, 0, 0, 0);
            if (OS.GetRandomRgn (handle, sysRgn, OS.SYSRGN) is 1) {
                if (OS.WIN32_VERSION >= OS.VERSION(4, 10)) {
                    if ((OS.GetLayout(handle) & OS.LAYOUT_RTL) !is 0) {
                        int nBytes = OS.GetRegionData (sysRgn, 0, null);
                        int [] lpRgnData = new int [nBytes / 4];
                        OS.GetRegionData (sysRgn, nBytes, cast(RGNDATA*)lpRgnData.ptr);
                        auto newSysRgn = OS.ExtCreateRegion( cast(XFORM*) [-1, 0, 0, 1, 0, 0].ptr, nBytes, cast(RGNDATA*)lpRgnData.ptr);
                        OS.DeleteObject(sysRgn);
                        sysRgn = newSysRgn;
                    }
                }
                if (OS.IsWinNT) {
                    OS.MapWindowPoints(null, hwnd, &pt, 1);
                    OS.OffsetRgn(sysRgn, pt.x, pt.y);
                }
                OS.CombineRgn (region.handle, sysRgn, region.handle, OS.RGN_AND);
            }
            OS.DeleteObject(sysRgn);
        }
    }
}

int getCodePage () {
    if (OS.IsUnicode) return OS.CP_ACP;
    CHARSETINFO csi;
    auto cs = OS.GetTextCharset(handle);
    OS.TranslateCharsetInfo( cast(DWORD*)cs, &csi, OS.TCI_SRCCHARSET);
    return csi.ciACP;
}

Gdip.Brush getFgBrush() {
    return data.foregroundPattern !is null ? data.foregroundPattern.handle : cast(Gdip.Brush)data.gdipFgBrush;
}

/**
 * Returns the receiver's fill rule, which will be one of
 * <code>SWT.FILL_EVEN_ODD</code> or <code>SWT.FILL_WINDING</code>.
 *
 * @return the receiver's fill rule
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public int getFillRule() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    static if (OS.IsWinCE) return SWT.FILL_EVEN_ODD;
    return OS.GetPolyFillMode(handle) is OS.WINDING ? SWT.FILL_WINDING : SWT.FILL_EVEN_ODD;
}

/**
 * Returns the font currently being used by the receiver
 * to draw and measure text.
 *
 * @return the receiver's font
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Font getFont () {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return data.font;
}

/**
 * Returns a FontMetrics which contains information
 * about the font currently being used by the receiver
 * to draw and measure text.
 *
 * @return font metrics for the receiver's font
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public FontMetrics getFontMetrics() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(FONT);
    TEXTMETRIC lptm;
    OS.GetTextMetrics(handle, &lptm);
    return FontMetrics.win32_new(&lptm);
}

/**
 * Returns the receiver's foreground color.
 *
 * @return the color used for drawing foreground things
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Color getForeground() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return Color.win32_new(data.device, data.foreground);
}

/**
 * Returns the foreground pattern. The default value is
 * <code>null</code>.
 *
 * @return the receiver's foreground pattern
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Pattern
 *
 * @since 3.1
 */
public Pattern getForegroundPattern() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return data.foregroundPattern;
}

/**
 * Returns the GCData.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>GC</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @return the receiver's GCData
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see GCData
 *
 * @since 3.2
 */
public GCData getGCData() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return data;
}

/**
 * Returns the receiver's interpolation setting, which will be one of
 * <code>SWT.DEFAULT</code>, <code>SWT.NONE</code>,
 * <code>SWT.LOW</code> or <code>SWT.HIGH</code>.
 *
 * @return the receiver's interpolation setting
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public int getInterpolation() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (data.gdipGraphics is null) return SWT.DEFAULT;
    int mode = Gdip.Graphics_GetInterpolationMode(data.gdipGraphics);
    switch (mode) {
        case Gdip.InterpolationModeDefault: return SWT.DEFAULT;
        case Gdip.InterpolationModeNearestNeighbor: return SWT.NONE;
        case Gdip.InterpolationModeBilinear:
        case Gdip.InterpolationModeLowQuality: return SWT.LOW;
        case Gdip.InterpolationModeBicubic:
        case Gdip.InterpolationModeHighQualityBilinear:
        case Gdip.InterpolationModeHighQualityBicubic:
        case Gdip.InterpolationModeHighQuality: return SWT.HIGH;
        default:
    }
    return SWT.DEFAULT;
}

/**
 * Returns the receiver's line attributes.
 *
 * @return the line attributes used for drawing lines
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.3
 */
public LineAttributes getLineAttributes() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    float[] dashes = null;
    if (data.lineDashes !is null) {
        dashes = new float[data.lineDashes.length];
        System.arraycopy(data.lineDashes, 0, dashes, 0, dashes.length);
    }
    return new LineAttributes(data.lineWidth, data.lineCap, data.lineJoin, data.lineStyle, dashes, data.lineDashesOffset, data.lineMiterLimit);
}

/**
 * Returns the receiver's line cap style, which will be one
 * of the constants <code>SWT.CAP_FLAT</code>, <code>SWT.CAP_ROUND</code>,
 * or <code>SWT.CAP_SQUARE</code>.
 *
 * @return the cap style used for drawing lines
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public int getLineCap() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return data.lineCap;
}

/**
 * Returns the receiver's line dash style. The default value is
 * <code>null</code>.
 *
 * @return the line dash style used for drawing lines
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public int[] getLineDash() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (data.lineDashes is null) return null;
    int[] lineDashes = new int[data.lineDashes.length];
    for (int i = 0; i < lineDashes.length; i++) {
        lineDashes[i] = cast(int)data.lineDashes[i];
    }
    return lineDashes;
}

/**
 * Returns the receiver's line join style, which will be one
 * of the constants <code>SWT.JOIN_MITER</code>, <code>SWT.JOIN_ROUND</code>,
 * or <code>SWT.JOIN_BEVEL</code>.
 *
 * @return the join style used for drawing lines
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public int getLineJoin() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return data.lineJoin;
}

/**
 * Returns the receiver's line style, which will be one
 * of the constants <code>SWT.LINE_SOLID</code>, <code>SWT.LINE_DASH</code>,
 * <code>SWT.LINE_DOT</code>, <code>SWT.LINE_DASHDOT</code> or
 * <code>SWT.LINE_DASHDOTDOT</code>.
 *
 * @return the style used for drawing lines
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getLineStyle() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return data.lineStyle;
}

/**
 * Returns the width that will be used when drawing lines
 * for all of the figure drawing operations (that is,
 * <code>drawLine</code>, <code>drawRectangle</code>,
 * <code>drawPolyline</code>, and so forth.
 *
 * @return the receiver's line width
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getLineWidth() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return cast(int)data.lineWidth;
}

/**
 * Returns the receiver's style information.
 * <p>
 * Note that the value which is returned by this method <em>may
 * not match</em> the value which was provided to the constructor
 * when the receiver was created. This can occur when the underlying
 * operating system does not support a particular combination of
 * requested styles.
 * </p>
 *
 * @return the style bits
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.1.2
 */
public int getStyle () {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return data.style;
}

/**
 * Returns the receiver's text drawing anti-aliasing setting value,
 * which will be one of <code>SWT.DEFAULT</code>, <code>SWT.OFF</code> or
 * <code>SWT.ON</code>. Note that this controls anti-aliasing
 * <em>only</em> for text drawing operations.
 *
 * @return the anti-aliasing setting
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getAntialias
 *
 * @since 3.1
 */
public int getTextAntialias() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (data.gdipGraphics is null) return SWT.DEFAULT;
    int mode = Gdip.Graphics_GetTextRenderingHint(data.gdipGraphics);
    switch (mode) {
        case Gdip.TextRenderingHintSystemDefault: return SWT.DEFAULT;
        case Gdip.TextRenderingHintSingleBitPerPixel:
        case Gdip.TextRenderingHintSingleBitPerPixelGridFit: return SWT.OFF;
        case Gdip.TextRenderingHintAntiAlias:
        case Gdip.TextRenderingHintAntiAliasGridFit:
        case Gdip.TextRenderingHintClearTypeGridFit: return SWT.ON;
        default:
    }
    return SWT.DEFAULT;
}

/**
 * Sets the parameter to the transform that is currently being
 * used by the receiver.
 *
 * @param transform the destination to copy the transform into
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parameter is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Transform
 *
 * @since 3.1
 */
public void getTransform(Transform transform) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (transform is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (transform.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        Gdip.Graphics_GetTransform(gdipGraphics, transform.handle);
        auto identity_ = identity();
        Gdip.Matrix_Invert(identity_);
        Gdip.Matrix_Multiply(transform.handle, identity_, Gdip.MatrixOrderAppend);
        Gdip.Matrix_delete(identity_);
    } else {
        transform.setElements(1, 0, 0, 1, 0, 0);
    }
}

/**
 * Returns <code>true</code> if this GC is drawing in the mode
 * where the resulting color in the destination is the
 * <em>exclusive or</em> of the color values in the source
 * and the destination, and <code>false</code> if it is
 * drawing in the mode where the destination color is being
 * replaced with the source color value.
 *
 * @return <code>true</code> true if the receiver is in XOR mode, and false otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public bool getXORMode() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    int rop2 = 0;
    static if (OS.IsWinCE) {
        rop2 = OS.SetROP2 (handle, OS.R2_COPYPEN);
        OS.SetROP2 (handle, rop2);
    } else {
        rop2 = OS.GetROP2(handle);
    }
    return rop2 is OS.R2_XORPEN;
}

void initGdip() {
    data.device.checkGDIP();
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) return;
    /*
    * Feature in GDI+. The GDI+ clipping set with Graphics->SetClip()
    * is always intersected with the GDI clipping at the time the
    * GDI+ graphics is created.  This means that the clipping
    * cannot be reset.  The fix is to clear the clipping before
    * the GDI+ graphics is created and reset it afterwards.
    */
    auto hRgn = OS.CreateRectRgn(0, 0, 0, 0);
    auto result = OS.GetClipRgn(handle, hRgn);
    static if (!OS.IsWinCE) {
        POINT pt;
        OS.GetWindowOrgEx (handle, &pt);
        OS.OffsetRgn (hRgn, pt.x, pt.y);
    }
    OS.SelectClipRgn(handle, null);

    /*
    * Bug in GDI+.  GDI+ does not work when the HDC layout is RTL.  There
    * are many issues like pixel corruption, but the most visible problem
    * is that it does not have an effect when drawing to an bitmap.  The
    * fix is to clear the bit before creating the GDI+ graphics and install
    * a mirroring matrix ourselves.
    */
    if ((data.style & SWT.MIRRORED) !is 0) {
        OS.SetLayout(handle, OS.GetLayout(handle) & ~OS.LAYOUT_RTL);
    }

    gdipGraphics = data.gdipGraphics = Gdip.Graphics_new(handle);
    if (gdipGraphics is null) SWT.error(SWT.ERROR_NO_HANDLES);
    Gdip.Graphics_SetPageUnit(gdipGraphics, Gdip.UnitPixel);
    Gdip.Graphics_SetPixelOffsetMode(gdipGraphics, Gdip.PixelOffsetModeHalf);
    if ((data.style & SWT.MIRRORED) !is 0) {
        auto matrix = identity();
        Gdip.Graphics_SetTransform(gdipGraphics, matrix);
        Gdip.Matrix_delete(matrix);
    }
    if (result is 1) setClipping(hRgn);
    OS.DeleteObject(hRgn);
    data.state = 0;
    if (data.hPen !is null) {
        OS.SelectObject(handle, OS.GetStockObject(OS.NULL_PEN));
        OS.DeleteObject(data.hPen);
        data.hPen = null;
    }
    if (data.hBrush !is null) {
        OS.SelectObject(handle, OS.GetStockObject(OS.NULL_BRUSH));
        OS.DeleteObject(data.hBrush);
        data.hBrush = null;
    }
}

Gdip.Matrix identity() {
    if ((data.style & SWT.MIRRORED) !is 0) {
        int width = 0;
        int technology = OS.GetDeviceCaps(handle, OS.TECHNOLOGY);
        if (technology is OS.DT_RASPRINTER) {
            width = OS.GetDeviceCaps(handle, OS.PHYSICALWIDTH);
        } else {
            Image image = data.image;
            if (image !is null) {
            BITMAP bm;
            OS.GetObject(image.handle, BITMAP.sizeof, &bm);
                width = bm.bmWidth;
            } else {
                HWND hwnd;
                static if( OS.IsWinCE ){
                    hwnd = data.hwnd;
                }
                else{
                    hwnd = OS.WindowFromDC(handle);
                }
                if (hwnd !is null) {
                    RECT rect;
                    OS.GetClientRect(hwnd, &rect);
                    width = rect.right - rect.left;
                } else {
                    auto hBitmap = OS.GetCurrentObject(handle, OS.OBJ_BITMAP);
                    BITMAP bm;
                    OS.GetObject(hBitmap, BITMAP.sizeof, &bm);
                    width = bm.bmWidth;
                }
            }
        }
        POINT pt;
        static if (!OS.IsWinCE) OS.GetWindowOrgEx (handle, &pt);
        return Gdip.Matrix_new(-1, 0, 0, 1, width + 2 * pt.x, 0);
    }
    return Gdip.Matrix_new(1, 0, 0, 1, 0, 0);
}

void init_(Drawable drawable, GCData data, HDC hDC) {
    auto foreground = data.foreground;
    if (foreground !is -1) {
        data.state &= ~(FOREGROUND | FOREGROUND_TEXT | PEN);
    } else {
        data.foreground = OS.GetTextColor(hDC);
    }
    auto background = data.background;
    if (background !is -1) {
        data.state &= ~(BACKGROUND | BACKGROUND_TEXT | BRUSH);
    } else {
        data.background = OS.GetBkColor(hDC);
    }
    data.state &= ~(NULL_BRUSH | NULL_PEN);
    Font font = data.font;
    if (font !is null) {
        data.state &= ~FONT;
    } else {
        data.font = Font.win32_new(device, OS.GetCurrentObject(hDC, OS.OBJ_FONT));
    }
    auto hPalette = data.device.hPalette;
    if (hPalette !is null) {
        OS.SelectPalette(hDC, hPalette, true);
        OS.RealizePalette(hDC);
    }
    Image image = data.image;
    if (image !is null) {
        data.hNullBitmap = OS.SelectObject(hDC, image.handle);
        image.memGC = this;
    }
    auto layout = data.layout;
    if (layout !is -1) {
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION(4, 10)) {
            int flags = OS.GetLayout(hDC);
            if ((flags & OS.LAYOUT_RTL) !is (layout & OS.LAYOUT_RTL)) {
                flags &= ~OS.LAYOUT_RTL;
                OS.SetLayout(hDC, flags | layout);
            }
            if ((data.style & SWT.RIGHT_TO_LEFT) !is 0) data.style |= SWT.MIRRORED;
        }
    }
    this.drawable = drawable;
    this.data = data;
    handle = hDC;
}

/**
 * Returns an integer hash code for the receiver. Any two
 * objects that return <code>true</code> when passed to
 * <code>equals</code> must return the same value for this
 * method.
 *
 * @return the receiver's hash
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #equals
 */
public override hash_t toHash () {
    return cast(hash_t)handle;
}

/**
 * Returns <code>true</code> if the receiver has a clipping
 * region set into it, and <code>false</code> otherwise.
 * If this method returns false, the receiver will draw on all
 * available space in the destination. If it returns true,
 * it will draw only in the area that is covered by the region
 * that can be accessed with <code>getClipping(region)</code>.
 *
 * @return <code>true</code> if the GC has a clipping region, and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public bool isClipped() {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        auto rgn = Gdip.Region_new();
        Gdip.Graphics_GetClip(data.gdipGraphics, rgn);
        bool isInfinite = Gdip.Region_IsInfinite(rgn, gdipGraphics) !is 0;
        Gdip.Region_delete(rgn);
        return !isInfinite;
    }
    auto region = OS.CreateRectRgn(0, 0, 0, 0);
    int result = OS.GetClipRgn(handle, region);
    OS.DeleteObject(region);
    return result > 0;
}

/**
 * Returns <code>true</code> if the GC has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the GC.
 * When a GC has been disposed, it is an error to
 * invoke any other method using the GC.
 *
 * @return <code>true</code> when the GC is disposed and <code>false</code> otherwise
 */
override public bool isDisposed() {
    return handle is null;
}

float measureSpace(Gdip.Font font, Gdip.StringFormat format) {
    Gdip.PointF pt;
    Gdip.RectF bounds;
    Gdip.Graphics_MeasureString(data.gdipGraphics, (" "w).ptr, 1, font, pt, format, bounds);
    return bounds.Width;
}

/**
 * Sets the receiver to always use the operating system's advanced graphics
 * subsystem for all graphics operations if the argument is <code>true</code>.
 * If the argument is <code>false</code>, the advanced graphics subsystem is
 * no longer used, advanced graphics state is cleared and the normal graphics
 * subsystem is used from now on.
 * <p>
 * Normally, the advanced graphics subsystem is invoked automatically when
 * any one of the alpha, antialias, patterns, interpolation, paths, clipping
 * or transformation operations in the receiver is requested.  When the receiver
 * is switched into advanced mode, the advanced graphics subsystem performs both
 * advanced and normal graphics operations.  Because the two subsystems are
 * different, their output may differ.  Switching to advanced graphics before
 * any graphics operations are performed ensures that the output is consistent.
 * </p><p>
 * Advanced graphics may not be installed for the operating system.  In this
 * case, this operation does nothing.  Some operating system have only one
 * graphics subsystem, so switching from normal to advanced graphics does
 * nothing.  However, switching from advanced to normal graphics will always
 * clear the advanced graphics state, even for operating systems that have
 * only one graphics subsystem.
 * </p>
 *
 * @param advanced the new advanced graphics state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setAlpha
 * @see #setAntialias
 * @see #setBackgroundPattern
 * @see #setClipping(Path)
 * @see #setForegroundPattern
 * @see #setLineAttributes
 * @see #setInterpolation
 * @see #setTextAntialias
 * @see #setTransform
 * @see #getAdvanced
 *
 * @since 3.1
 */
public void setAdvanced(bool advanced) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (advanced && data.gdipGraphics !is null) return;
    if (advanced) {
        try {
            initGdip();
        } catch (SWTException e) {}
    } else {
        disposeGdip();
        data.alpha = 0xFF;
        data.backgroundPattern = data.foregroundPattern = null;
        data.state = 0;
        setClipping( cast(HRGN) null);
        if ((data.style & SWT.MIRRORED) !is 0) {
            OS.SetLayout(handle, OS.GetLayout(handle) | OS.LAYOUT_RTL);
        }
    }
}

/**
 * Sets the receiver's anti-aliasing value to the parameter,
 * which must be one of <code>SWT.DEFAULT</code>, <code>SWT.OFF</code>
 * or <code>SWT.ON</code>. Note that this controls anti-aliasing for all
 * <em>non-text drawing</em> operations.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param antialias the anti-aliasing setting
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter is not one of <code>SWT.DEFAULT</code>,
 *                                 <code>SWT.OFF</code> or <code>SWT.ON</code></li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see #getAdvanced
 * @see #setAdvanced
 * @see #setTextAntialias
 *
 * @since 3.1
 */
public void setAntialias(int antialias) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (data.gdipGraphics is null && antialias is SWT.DEFAULT) return;
    int mode = 0;
    switch (antialias) {
        case SWT.DEFAULT:
            mode = Gdip.SmoothingModeDefault;
            break;
        case SWT.OFF:
            mode = Gdip.SmoothingModeNone;
            break;
        case SWT.ON:
            mode = Gdip.SmoothingModeAntiAlias;
            break;
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    initGdip();
    Gdip.Graphics_SetSmoothingMode(data.gdipGraphics, mode);
}

/**
 * Sets the receiver's alpha value which must be
 * between 0 (transparent) and 255 (opaque).
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 * @param alpha the alpha value
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see #getAdvanced
 * @see #setAdvanced
 *
 * @since 3.1
 */
public void setAlpha(int alpha) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (data.gdipGraphics is null && (alpha & 0xFF) is 0xFF) return;
    initGdip();
    data.alpha = alpha & 0xFF;
    data.state &= ~(BACKGROUND | FOREGROUND);
}

/**
 * Sets the background color. The background color is used
 * for fill operations and as the background color when text
 * is drawn.
 *
 * @param color the new background color for the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the color is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the color has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setBackground (Color color) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (color is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (color.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (data.backgroundPattern is null && data.background is color.handle) return;
    data.backgroundPattern = null;
    data.background = color.handle;
    data.state &= ~(BACKGROUND | BACKGROUND_TEXT);
}

/**
 * Sets the background pattern. The default value is <code>null</code>.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param pattern the new background pattern
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see Pattern
 * @see #getAdvanced
 * @see #setAdvanced
 *
 * @since 3.1
 */
public void setBackgroundPattern (Pattern pattern) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (pattern !is null && pattern.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (data.gdipGraphics is null && pattern is null) return;
    initGdip();
    if (data.backgroundPattern is pattern) return;
    data.backgroundPattern = pattern;
    data.state &= ~BACKGROUND;
}

void setClipping(HRGN clipRgn) {
    auto hRgn = clipRgn;
    auto gdipGraphics = data.gdipGraphics;
    if (gdipGraphics !is null) {
        if (hRgn !is null) {
            auto region = Gdip.Region_new(hRgn);
            Gdip.Graphics_SetClip(gdipGraphics, region, Gdip.CombineModeReplace);
            Gdip.Region_delete(region);
        } else {
            Gdip.Graphics_ResetClip(gdipGraphics);
        }
    } else {
        POINT pt;
        if (hRgn !is null && !OS.IsWinCE) {
            OS.GetWindowOrgEx(handle, &pt);
            OS.OffsetRgn(hRgn, -pt.x, -pt.y);
        }
        OS.SelectClipRgn(handle, hRgn);
        if (hRgn !is null && !OS.IsWinCE) {
            OS.OffsetRgn(hRgn, pt.x, pt.y);
        }
    }
    if (hRgn !is null && hRgn !is clipRgn) {
        OS.DeleteObject(hRgn);
    }
}

/**
 * Sets the area of the receiver which can be changed
 * by drawing operations to the rectangular area specified
 * by the arguments.
 *
 * @param x the x coordinate of the clipping rectangle
 * @param y the y coordinate of the clipping rectangle
 * @param width the width of the clipping rectangle
 * @param height the height of the clipping rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setClipping (int x, int y, int width, int height) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    auto hRgn = OS.CreateRectRgn(x, y, x + width, y + height);
    setClipping(hRgn);
    OS.DeleteObject(hRgn);
}

/**
 * Sets the area of the receiver which can be changed
 * by drawing operations to the path specified
 * by the argument.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param path the clipping path.
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the path has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see Path
 * @see #getAdvanced
 * @see #setAdvanced
 *
 * @since 3.1
 */
public void setClipping (Path path) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (path !is null && path.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    setClipping(cast(HRGN)null);
    if (path !is null) {
        initGdip();
        int mode = OS.GetPolyFillMode(handle) is OS.WINDING ? Gdip.FillModeWinding : Gdip.FillModeAlternate;
        Gdip.GraphicsPath_SetFillMode(path.handle, mode);
        Gdip.Graphics_SetClipPath(data.gdipGraphics, path.handle);
    }
}

/**
 * Sets the area of the receiver which can be changed
 * by drawing operations to the rectangular area specified
 * by the argument.  Specifying <code>null</code> for the
 * rectangle reverts the receiver's clipping area to its
 * original value.
 *
 * @param rect the clipping rectangle or <code>null</code>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setClipping (Rectangle rect) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (rect is null) {
        setClipping(cast(HRGN)null);
    } else {
        setClipping(rect.x, rect.y, rect.width, rect.height);
    }
}

/**
 * Sets the area of the receiver which can be changed
 * by drawing operations to the region specified
 * by the argument.  Specifying <code>null</code> for the
 * region reverts the receiver's clipping area to its
 * original value.
 *
 * @param region the clipping region or <code>null</code>
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the region has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setClipping (Region region) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (region !is null && region.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    setClipping(region !is null ? region.handle : cast(HRGN)null);
}

/**
 * Sets the receiver's fill rule to the parameter, which must be one of
 * <code>SWT.FILL_EVEN_ODD</code> or <code>SWT.FILL_WINDING</code>.
 *
 * @param rule the new fill rule
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the rule is not one of <code>SWT.FILL_EVEN_ODD</code>
 *                                 or <code>SWT.FILL_WINDING</code></li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void setFillRule(int rule) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    static if (OS.IsWinCE) return;
    int mode = OS.ALTERNATE;
    switch (rule) {
        case SWT.FILL_WINDING: mode = OS.WINDING; break;
        case SWT.FILL_EVEN_ODD: mode = OS.ALTERNATE; break;
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    OS.SetPolyFillMode(handle, mode);
}

/**
 * Sets the font which will be used by the receiver
 * to draw and measure text to the argument. If the
 * argument is null, then a default font appropriate
 * for the platform will be used instead.
 *
 * @param font the new font for the receiver, or null to indicate a default font
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the font has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setFont (Font font) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (font !is null && font.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    data.font = font !is null ? font : data.device.systemFont;
    data.state &= ~FONT;
}

/**
 * Sets the foreground color. The foreground color is used
 * for drawing operations including when text is drawn.
 *
 * @param color the new foreground color for the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the color is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the color has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setForeground (Color color) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (color is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (color.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (data.foregroundPattern is null && color.handle is data.foreground) return;
    data.foregroundPattern = null;
    data.foreground = color.handle;
    data.state &= ~(FOREGROUND | FOREGROUND_TEXT);
}

/**
 * Sets the foreground pattern. The default value is <code>null</code>.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 * @param pattern the new foreground pattern
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see Pattern
 * @see #getAdvanced
 * @see #setAdvanced
 *
 * @since 3.1
 */
public void setForegroundPattern (Pattern pattern) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (pattern !is null && pattern.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (data.gdipGraphics is null && pattern is null) return;
    initGdip();
    if (data.foregroundPattern is pattern) return;
    data.foregroundPattern = pattern;
    data.state &= ~FOREGROUND;
}

/**
 * Sets the receiver's interpolation setting to the parameter, which
 * must be one of <code>SWT.DEFAULT</code>, <code>SWT.NONE</code>,
 * <code>SWT.LOW</code> or <code>SWT.HIGH</code>.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param interpolation the new interpolation setting
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the rule is not one of <code>SWT.DEFAULT</code>,
 *                                 <code>SWT.NONE</code>, <code>SWT.LOW</code> or <code>SWT.HIGH</code>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see #getAdvanced
 * @see #setAdvanced
 *
 * @since 3.1
 */
public void setInterpolation(int interpolation) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (data.gdipGraphics is null && interpolation is SWT.DEFAULT) return;
    int mode = 0;
    switch (interpolation) {
        case SWT.DEFAULT: mode = Gdip.InterpolationModeDefault; break;
        case SWT.NONE: mode = Gdip.InterpolationModeNearestNeighbor; break;
        case SWT.LOW: mode = Gdip.InterpolationModeLowQuality; break;
        case SWT.HIGH: mode = Gdip.InterpolationModeHighQuality; break;
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    initGdip();
    Gdip.Graphics_SetInterpolationMode(data.gdipGraphics, mode);
}

/**
 * Sets the receiver's line attributes.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 * @param attributes the line attributes
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the attributes is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if any of the line attributes is not valid</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see LineAttributes
 * @see #getAdvanced
 * @see #setAdvanced
 *
 * @since 3.3
 */
public void setLineAttributes(LineAttributes attributes) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (attributes is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    int mask = 0;
    float lineWidth = attributes.width;
    if (lineWidth !is data.lineWidth) {
        mask |= LINE_WIDTH | DRAW_OFFSET;
    }
    int lineStyle = attributes.style;
    if (lineStyle !is data.lineStyle) {
        mask |= LINE_STYLE;
        switch (lineStyle) {
            case SWT.LINE_SOLID:
            case SWT.LINE_DASH:
            case SWT.LINE_DOT:
            case SWT.LINE_DASHDOT:
            case SWT.LINE_DASHDOTDOT:
                break;
            case SWT.LINE_CUSTOM:
                if (attributes.dash is null) lineStyle = SWT.LINE_SOLID;
                break;
            default:
                SWT.error(SWT.ERROR_INVALID_ARGUMENT);
        }
    }
    int join = attributes.join;
    if (join !is data.lineJoin) {
        mask |= LINE_JOIN;
        switch (join) {
            case SWT.CAP_ROUND:
            case SWT.CAP_FLAT:
            case SWT.CAP_SQUARE:
                break;
            default:
                SWT.error(SWT.ERROR_INVALID_ARGUMENT);
        }
    }
    int cap = attributes.cap;
    if (cap !is data.lineCap) {
        mask |= LINE_CAP;
        switch (cap) {
            case SWT.JOIN_MITER:
            case SWT.JOIN_ROUND:
            case SWT.JOIN_BEVEL:
                break;
            default:
                SWT.error(SWT.ERROR_INVALID_ARGUMENT);
        }
    }
    float[] dashes = attributes.dash;
    float[] lineDashes = data.lineDashes;
    if (dashes !is null && dashes.length > 0) {
        bool changed = lineDashes is null || lineDashes.length !is dashes.length;
        for (int i = 0; i < dashes.length; i++) {
            float dash = dashes[i];
            if (dash <= 0) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
            if (!changed && lineDashes[i] !is dash) changed = true;
        }
        if (changed) {
            float[] newDashes = new float[dashes.length];
            System.arraycopy(dashes, 0, newDashes, 0, dashes.length);
            dashes = newDashes;
            mask |= LINE_STYLE;
        } else {
            dashes = lineDashes;
        }
    } else {
        if (lineDashes !is null && lineDashes.length > 0) {
            mask |= LINE_STYLE;
        } else {
            dashes = lineDashes;
        }
    }
    float dashOffset = attributes.dashOffset;
    if (dashOffset !is data.lineDashesOffset) {
        mask |= LINE_STYLE;
    }
    float miterLimit = attributes.miterLimit;
    if (miterLimit !is data.lineMiterLimit) {
        mask |= LINE_MITERLIMIT;
    }
    initGdip();
    if (mask is 0) return;
    data.lineWidth = lineWidth;
    data.lineStyle = lineStyle;
    data.lineCap = cap;
    data.lineJoin = join;
    data.lineDashes = dashes;
    data.lineDashesOffset = dashOffset;
    data.lineMiterLimit = miterLimit;
    data.state &= ~mask;
}

/**
 * Sets the receiver's line cap style to the argument, which must be one
 * of the constants <code>SWT.CAP_FLAT</code>, <code>SWT.CAP_ROUND</code>,
 * or <code>SWT.CAP_SQUARE</code>.
 *
 * @param cap the cap style to be used for drawing lines
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the style is not valid</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void setLineCap(int cap) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (data.lineCap is cap) return;
    switch (cap) {
        case SWT.CAP_ROUND:
        case SWT.CAP_FLAT:
        case SWT.CAP_SQUARE:
            break;
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    data.lineCap = cap;
    data.state &= ~LINE_CAP;
}

/**
 * Sets the receiver's line dash style to the argument. The default
 * value is <code>null</code>. If the argument is not <code>null</code>,
 * the receiver's line style is set to <code>SWT.LINE_CUSTOM</code>, otherwise
 * it is set to <code>SWT.LINE_SOLID</code>.
 *
 * @param dashes the dash style to be used for drawing lines
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if any of the values in the array is less than or equal 0</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void setLineDash(int[] dashes) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    float[] lineDashes = data.lineDashes;
    if (dashes !is null && dashes.length > 0) {
        bool changed = data.lineStyle !is SWT.LINE_CUSTOM || lineDashes is null || lineDashes.length !is dashes.length;
        for (int i = 0; i < dashes.length; i++) {
            int dash = dashes[i];
            if (dash <= 0) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
            if (!changed && lineDashes[i] !is dash) changed = true;
        }
        if (!changed) return;
        data.lineDashes = new float[dashes.length];
        for (int i = 0; i < dashes.length; i++) {
            data.lineDashes[i] = dashes[i];
        }
        data.lineStyle = SWT.LINE_CUSTOM;
    } else {
        if (data.lineStyle is SWT.LINE_SOLID && (lineDashes is null || lineDashes.length is 0)) return;
        data.lineDashes = null;
        data.lineStyle = SWT.LINE_SOLID;
    }
    data.state &= ~LINE_STYLE;
}

/**
 * Sets the receiver's line join style to the argument, which must be one
 * of the constants <code>SWT.JOIN_MITER</code>, <code>SWT.JOIN_ROUND</code>,
 * or <code>SWT.JOIN_BEVEL</code>.
 *
 * @param join the join style to be used for drawing lines
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the style is not valid</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void setLineJoin(int join) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (data.lineJoin is join) return;
    switch (join) {
        case SWT.JOIN_MITER:
        case SWT.JOIN_ROUND:
        case SWT.JOIN_BEVEL:
            break;
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    data.lineJoin = join;
    data.state &= ~LINE_JOIN;
}

/**
 * Sets the receiver's line style to the argument, which must be one
 * of the constants <code>SWT.LINE_SOLID</code>, <code>SWT.LINE_DASH</code>,
 * <code>SWT.LINE_DOT</code>, <code>SWT.LINE_DASHDOT</code> or
 * <code>SWT.LINE_DASHDOTDOT</code>.
 *
 * @param lineStyle the style to be used for drawing lines
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the style is not valid</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setLineStyle(int lineStyle) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (data.lineStyle is lineStyle) return;
    switch (lineStyle) {
        case SWT.LINE_SOLID:
        case SWT.LINE_DASH:
        case SWT.LINE_DOT:
        case SWT.LINE_DASHDOT:
        case SWT.LINE_DASHDOTDOT:
            break;
        case SWT.LINE_CUSTOM:
            if (data.lineDashes is null) lineStyle = SWT.LINE_SOLID;
            break;
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    data.lineStyle = lineStyle;
    data.state &= ~LINE_STYLE;
}

/**
 * Sets the width that will be used when drawing lines
 * for all of the figure drawing operations (that is,
 * <code>drawLine</code>, <code>drawRectangle</code>,
 * <code>drawPolyline</code>, and so forth.
 * <p>
 * Note that line width of zero is used as a hint to
 * indicate that the fastest possible line drawing
 * algorithms should be used. This means that the
 * output may be different from line width one.
 * </p>
 *
 * @param lineWidth the width of a line
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setLineWidth(int lineWidth) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (data.lineWidth is lineWidth) return;
    data.lineWidth = lineWidth;
    data.state &= ~(LINE_WIDTH | DRAW_OFFSET);
}

/**
 * If the argument is <code>true</code>, puts the receiver
 * in a drawing mode where the resulting color in the destination
 * is the <em>exclusive or</em> of the color values in the source
 * and the destination, and if the argument is <code>false</code>,
 * puts the receiver in a drawing mode where the destination color
 * is replaced with the source color value.
 * <p>
 * Note that this mode in fundamentally unsupportable on certain
 * platforms, notably Carbon (Mac OS X). Clients that want their
 * code to run on all platforms need to avoid this method.
 * </p>
 *
 * @param xor if <code>true</code>, then <em>xor</em> mode is used, otherwise <em>source copy</em> mode is used
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @deprecated this functionality is not supported on some platforms
 */
public void setXORMode(bool xor) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    OS.SetROP2(handle, xor ? OS.R2_XORPEN : OS.R2_COPYPEN);
}

/**
 * Sets the receiver's text anti-aliasing value to the parameter,
 * which must be one of <code>SWT.DEFAULT</code>, <code>SWT.OFF</code>
 * or <code>SWT.ON</code>. Note that this controls anti-aliasing only
 * for all <em>text drawing</em> operations.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param antialias the anti-aliasing setting
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter is not one of <code>SWT.DEFAULT</code>,
 *                                 <code>SWT.OFF</code> or <code>SWT.ON</code></li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see #getAdvanced
 * @see #setAdvanced
 * @see #setAntialias
 *
 * @since 3.1
 */
public void setTextAntialias(int antialias) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (data.gdipGraphics is null && antialias is SWT.DEFAULT) return;
    int textMode = 0;
    switch (antialias) {
        case SWT.DEFAULT:
            textMode = Gdip.TextRenderingHintSystemDefault;
            break;
        case SWT.OFF:
            textMode = Gdip.TextRenderingHintSingleBitPerPixelGridFit;
            break;
        case SWT.ON:
            int type;
            OS.SystemParametersInfo(OS.SPI_GETFONTSMOOTHINGTYPE, 0, &type, 0);
            if (type is OS.FE_FONTSMOOTHINGCLEARTYPE) {
                textMode = Gdip.TextRenderingHintClearTypeGridFit;
            } else {
                textMode = Gdip.TextRenderingHintAntiAliasGridFit;
            }
            break;
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    initGdip();
    Gdip.Graphics_SetTextRenderingHint(data.gdipGraphics, textMode);
}

/**
 * Sets the transform that is currently being used by the receiver. If
 * the argument is <code>null</code>, the current transform is set to
 * the identity transform.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param transform the transform to set
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 *
 * @see Transform
 * @see #getAdvanced
 * @see #setAdvanced
 *
 * @since 3.1
 */
public void setTransform(Transform transform) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (transform !is null && transform.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (data.gdipGraphics is null && transform is null) return;
    initGdip();
    auto identity_ = identity();
    if (transform !is null) {
         Gdip.Matrix_Multiply(identity_, transform.handle, Gdip.MatrixOrderPrepend);
    }
    Gdip.Graphics_SetTransform(data.gdipGraphics, identity_);
    Gdip.Matrix_delete(identity_);
    data.state &= ~DRAW_OFFSET;
}

/**
 * Returns the extent of the given string. No tab
 * expansion or carriage return processing will be performed.
 * <p>
 * The <em>extent</em> of a string is the width and height of
 * the rectangular area it would cover if drawn in a particular
 * font (in this case, the current font in the receiver).
 * </p>
 *
 * @param string the string to measure
 * @return a point containing the extent of the string
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Point stringExtent(String string) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    // SWT externsion: allow null string
    //if (string is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    checkGC(FONT);
    int length_ = cast(int)/*64bit*/string.length;
    if (data.gdipGraphics !is null) {
        Gdip.PointF pt;
        Gdip.RectF bounds;
        LPCWSTR buffer;
        if (length_ !is 0) {
            String16 wstr = StrToWCHARs( string );
            buffer = wstr.ptr;
            length_ = cast(int)/*64bit*/wstr.length;
        } else {
            buffer = (" "w).ptr;
        }
        auto format = Gdip.StringFormat_Clone(Gdip.StringFormat_GenericTypographic());
        int formatFlags = Gdip.StringFormat_GetFormatFlags(format) | Gdip.StringFormatFlagsMeasureTrailingSpaces;
        if ((data.style & SWT.MIRRORED) !is 0) formatFlags |= Gdip.StringFormatFlagsDirectionRightToLeft;
        Gdip.StringFormat_SetFormatFlags(format, formatFlags);
        Gdip.Graphics_MeasureString(data.gdipGraphics, buffer, length_, data.gdipFont, pt, format, bounds);
        Gdip.StringFormat_delete(format);
        return new Point(length_ is 0 ? 0 : Math.round(bounds.Width), Math.round(bounds.Height));
    }
    SIZE size;
    if (length_ is 0) {
//      OS.GetTextExtentPoint32(handle, SPACE, SPACE.length(), size);
        OS.GetTextExtentPoint32W(handle, (" "w).ptr, 1, &size);
        return new Point(0, size.cy);
    } else {
//      TCHAR buffer = new TCHAR (getCodePage(), string, false);
        String16 wstr = StrToWCHARs( string );
        LPCWSTR buffer = wstr.ptr;
        length_ = cast(int)/*64bit*/wstr.length;
        OS.GetTextExtentPoint32W(handle, buffer, length_, &size);
        return new Point(size.cx, size.cy);
    }
}

/**
 * Returns the extent of the given string. Tab expansion and
 * carriage return processing are performed.
 * <p>
 * The <em>extent</em> of a string is the width and height of
 * the rectangular area it would cover if drawn in a particular
 * font (in this case, the current font in the receiver).
 * </p>
 *
 * @param string the string to measure
 * @return a point containing the extent of the string
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Point textExtent(String string) {
    return textExtent(string, SWT.DRAW_DELIMITER | SWT.DRAW_TAB);
}

/**
 * Returns the extent of the given string. Tab expansion, line
 * delimiter and mnemonic processing are performed according to
 * the specified flags, which can be a combination of:
 * <dl>
 * <dt><b>DRAW_DELIMITER</b></dt>
 * <dd>draw multiple lines</dd>
 * <dt><b>DRAW_TAB</b></dt>
 * <dd>expand tabs</dd>
 * <dt><b>DRAW_MNEMONIC</b></dt>
 * <dd>underline the mnemonic character</dd>
 * <dt><b>DRAW_TRANSPARENT</b></dt>
 * <dd>transparent background</dd>
 * </dl>
 * <p>
 * The <em>extent</em> of a string is the width and height of
 * the rectangular area it would cover if drawn in a particular
 * font (in this case, the current font in the receiver).
 * </p>
 *
 * @param string the string to measure
 * @param flags the flags specifying how to process the text
 * @return a point containing the extent of the string
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Point textExtent(String string, int flags) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    //DWT_CHANGE: allow null string
    //if (string is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    checkGC(FONT);
    if (data.gdipGraphics !is null) {
        Gdip.PointF pt;
        Gdip.RectF bounds;
        LPCWSTR buffer;
        int length_ = cast(int)/*64bit*/string.length;
        if (length_ !is 0) {
            String16 wstr = StrToWCHARs( string );
            buffer = wstr.ptr;
            length_ = cast(int)/*64bit*/wstr.length;
        } else {
            buffer = (" "w).ptr;
        }
        auto format = Gdip.StringFormat_Clone(Gdip.StringFormat_GenericTypographic());
        int formatFlags = Gdip.StringFormat_GetFormatFlags(format) | Gdip.StringFormatFlagsMeasureTrailingSpaces;
        if ((data.style & SWT.MIRRORED) !is 0) formatFlags |= Gdip.StringFormatFlagsDirectionRightToLeft;
        Gdip.StringFormat_SetFormatFlags(format, formatFlags);
        float[] tabs = (flags & SWT.DRAW_TAB) !is 0 ? [measureSpace(data.gdipFont, format) * 8] : new float[1];
        Gdip.StringFormat_SetTabStops(format, 0, cast(int)/*64bit*/tabs.length, tabs.ptr);
        Gdip.StringFormat_SetHotkeyPrefix(format, (flags & SWT.DRAW_MNEMONIC) !is 0 ? Gdip.HotkeyPrefixShow : Gdip.HotkeyPrefixNone);
        Gdip.Graphics_MeasureString(data.gdipGraphics, buffer, length_, data.gdipFont, pt, format, bounds);
        Gdip.StringFormat_delete(format);
        return new Point(length_ is 0 ? 0 : cast(int)Math.rint(bounds.Width), cast(int)Math.rint(bounds.Height));
    }
    if (string.length is 0) {
        SIZE size;
//      OS.GetTextExtentPoint32(handle, SPACE, SPACE.length(), size);
        OS.GetTextExtentPoint32W(handle, (" "w).ptr, 1, &size);
        return new Point(0, size.cy);
    }
    RECT rect;
    auto wstr = StrToTCHARs( string );
    LPCWSTR buffer = wstr.ptr;
    int length_ = cast(int)/*64bit*/wstr.length;
    int uFormat = OS.DT_LEFT | OS.DT_CALCRECT;
    if ((flags & SWT.DRAW_DELIMITER) is 0) uFormat |= OS.DT_SINGLELINE;
    if ((flags & SWT.DRAW_TAB) !is 0) uFormat |= OS.DT_EXPANDTABS;
    if ((flags & SWT.DRAW_MNEMONIC) is 0) uFormat |= OS.DT_NOPREFIX;
    OS.DrawText(handle, buffer, length_, &rect, uFormat);
    return new Point(rect.right, rect.bottom);
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
override public String toString () {
    if (isDisposed()) return "GC {*DISPOSED*}";
    return Format( "GC {{{}}", handle );
}

/**
 * Invokes platform specific functionality to allocate a new graphics context.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>GC</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param drawable the Drawable for the receiver.
 * @param data the data for the receiver.
 *
 * @return a new <code>GC</code>
 */
public static GC win32_new(Drawable drawable, GCData data) {
    GC gc = new GC();
    auto hDC = drawable.internal_new_GC(data);
    gc.disposeChecking = false;
    gc.device = data.device;
    gc.init_(drawable, data, hDC);
    return gc;
}

/**
 * Invokes platform specific functionality to wrap a graphics context.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>GC</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param hDC the Windows HDC.
 * @param data the data for the receiver.
 *
 * @return a new <code>GC</code>
 */
public static GC win32_new(HDC hDC, GCData data) {
    GC gc = new GC();
    gc.disposeChecking = false;
    gc.device = data.device;
    data.style |= SWT.LEFT_TO_RIGHT;
    if (OS.WIN32_VERSION >= OS.VERSION (4, 10)) {
        int flags = OS.GetLayout (hDC);
        if ((flags & OS.LAYOUT_RTL) !is 0) {
            data.style |= SWT.RIGHT_TO_LEFT | SWT.MIRRORED;
        }
    }
    gc.init_(null, data, hDC);
    return gc;
}

}
