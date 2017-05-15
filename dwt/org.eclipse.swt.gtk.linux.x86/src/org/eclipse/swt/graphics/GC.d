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

import org.eclipse.swt.graphics.Image;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.SWTError;
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

import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.internal.cairo.Cairo : Cairo;
import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.Compatibility;
import java.lang.all;

version(Tango){
    import tango.stdc.string;
} else {
    import core.stdc.string;
}


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
    public GdkGC* handle;

    Drawable drawable;
    GCData data;

    const static int FOREGROUND = 1 << 0;
    const static int BACKGROUND = 1 << 1;
    const static int FONT = 1 << 2;
    const static int LINE_STYLE = 1 << 3;
    const static int LINE_CAP = 1 << 4;
    const static int LINE_JOIN = 1 << 5;
    const static int LINE_WIDTH = 1 << 6;
    const static int LINE_MITERLIMIT = 1 << 7;
    const static int BACKGROUND_BG = 1 << 8;
    const static int DRAW_OFFSET = 1 << 9;
    const static int DRAW = FOREGROUND | LINE_WIDTH | LINE_STYLE  | LINE_CAP  | LINE_JOIN | LINE_MITERLIMIT | DRAW_OFFSET;
    const static int FILL = BACKGROUND;

    static const float[] LINE_DOT = [1, 1];
    static const float[] LINE_DASH = [3, 1];
    static const float[] LINE_DASHDOT = [3, 1, 1, 1];
    static const float[] LINE_DASHDOTDOT = [3, 1, 1, 1, 1, 1];
    static const float[] LINE_DOT_ZERO = [3, 3];
    static const float[] LINE_DASH_ZERO = [18, 6];
    static const float[] LINE_DASHDOT_ZERO = [9, 6, 3, 6];
    static const float[] LINE_DASHDOTDOT_ZERO = [9, 3, 3, 3, 3, 3];

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
    this(drawable, 0);
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
    GCData data = new GCData();
    data.style = checkStyle(style);
    auto gdkGC = drawable.internal_new_GC(data);
    Device device = data.device;
    if (device is null) device = Device.getDevice();
    if (device is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    this.device = data.device = device;
    init_(drawable, data, gdkGC);
    init_();
}

static void addCairoString(org.eclipse.swt.internal.gtk.OS.cairo_t* cairo, String str, float x, float y, Font font) {
    char* buffer = toStringz( str );
    if (OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
        auto layout = OS.pango_cairo_create_layout(cairo);
        if (layout is null) SWT.error(SWT.ERROR_NO_HANDLES);
        OS.pango_layout_set_text(layout, buffer, -1);
        OS.pango_layout_set_font_description(layout, font.handle);
        double currentX = 0, currentY = 0;
        Cairo.cairo_get_current_point(cairo, &currentX, &currentY);
        if (currentX !is x || currentY !is y) {
            Cairo.cairo_move_to(cairo, x, y);
        }
        OS.pango_cairo_layout_path(cairo, layout);
        OS.g_object_unref(layout);
    } else {
        GC.setCairoFont(cairo, font);
        cairo_font_extents_t* extents = new cairo_font_extents_t();
        Cairo.cairo_font_extents(cairo, extents);
        double baseline = y + extents.ascent;
        Cairo.cairo_move_to(cairo, x, baseline);
        Cairo.cairo_text_path(cairo, buffer);
    }
}

static int checkStyle (int style) {
    if ((style & SWT.LEFT_TO_RIGHT) !is 0) style &= ~SWT.RIGHT_TO_LEFT;
    return style & (SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT);
}

public static GC gtk_new(GdkGC* handle, GCData data) {
    GC gc = new GC();
    gc.device = data.device;
    gc.init_(null, data, handle);
    return gc;
}

public static GC gtk_new(Drawable drawable, GCData data) {
    GC gc = new GC();
    auto gdkGC = drawable.internal_new_GC(data);
    gc.device = data.device;
    gc.init_(drawable, data, gdkGC);
    return gc;
}

void checkGC (int mask) {
    int state = data.state;
    if ((state & mask) is mask) return;
    state = (state ^ mask) & mask;
    data.state |= mask;
    auto cairo = data.cairo;
    if (cairo !is null) {
        if ((state & (BACKGROUND | FOREGROUND)) !is 0) {
            GdkColor* color;
            Pattern pattern;
            if ((state & FOREGROUND) !is 0) {
                color = data.foreground;
                pattern = data.foregroundPattern;
                data.state &= ~BACKGROUND;
            } else {
                color = data.background;
                pattern = data.backgroundPattern;
                data.state &= ~FOREGROUND;
            }
            if  (pattern !is null) {
                if ((data.style & SWT.MIRRORED) !is 0 && pattern.surface !is null) {
                    auto newPattern = Cairo.cairo_pattern_create_for_surface(pattern.surface);
                    if (newPattern is null) SWT.error(SWT.ERROR_NO_HANDLES);
                    Cairo.cairo_pattern_set_extend(newPattern, Cairo.CAIRO_EXTEND_REPEAT);
                    double[6] matrix; matrix[0] = -1; matrix[1] = 0; matrix[2] = 0; matrix[3] = 1; matrix[4] = 0; matrix[5] = 0;
                    Cairo.cairo_pattern_set_matrix(newPattern, cast(cairo_matrix_t*) matrix.ptr);
                    Cairo.cairo_set_source(cairo, newPattern);
                    Cairo.cairo_pattern_destroy(newPattern);
                } else {
                    Cairo.cairo_set_source(cairo, pattern.handle);
                }
            } else {
                Cairo.cairo_set_source_rgba(cairo, (color.red & 0xFFFF) / cast(float)0xFFFF, (color.green & 0xFFFF) / cast(float)0xFFFF, (color.blue & 0xFFFF) / cast(float)0xFFFF, data.alpha / cast(float)0xFF);
            }
        }
        if ((state & FONT) !is 0) {
            if (data.layout !is null) {
                Font font = data.font;
                OS.pango_layout_set_font_description(data.layout, font.handle);
            }
            if (OS.GTK_VERSION < OS.buildVERSION(2, 8, 0)) {
                setCairoFont(cairo, data.font);
            }
        }
        if ((state & LINE_CAP) !is 0) {
            int cap_style = 0;
            switch (data.lineCap) {
                case SWT.CAP_ROUND: cap_style = Cairo.CAIRO_LINE_CAP_ROUND; break;
                case SWT.CAP_FLAT: cap_style = Cairo.CAIRO_LINE_CAP_BUTT; break;
                case SWT.CAP_SQUARE: cap_style = Cairo.CAIRO_LINE_CAP_SQUARE; break;
                default:
            }
            Cairo.cairo_set_line_cap(cairo, cap_style);
        }
        if ((state & LINE_JOIN) !is 0) {
            int join_style = 0;
            switch (data.lineJoin) {
                case SWT.JOIN_MITER: join_style = Cairo.CAIRO_LINE_JOIN_MITER; break;
                case SWT.JOIN_ROUND:  join_style = Cairo.CAIRO_LINE_JOIN_ROUND; break;
                case SWT.JOIN_BEVEL: join_style = Cairo.CAIRO_LINE_JOIN_BEVEL; break;
                default:
            }
            Cairo.cairo_set_line_join(cairo, join_style);
        }
        if ((state & LINE_WIDTH) !is 0) {
            Cairo.cairo_set_line_width(cairo, data.lineWidth is 0 ? 1 : data.lineWidth);
            switch (data.lineStyle) {
                case SWT.LINE_DOT:
                case SWT.LINE_DASH:
                case SWT.LINE_DASHDOT:
                case SWT.LINE_DASHDOTDOT:
                    state |= LINE_STYLE;
                    break;
                default:
                    break;
            }
        }
        if ((state & LINE_STYLE) !is 0) {
            float dashesOffset = 0;
            TryConst!(float)[] dashes = null;
            float width = data.lineWidth;
            switch (data.lineStyle) {
                case SWT.LINE_SOLID: break;
                case SWT.LINE_DASH: dashes = width !is 0 ? LINE_DASH : LINE_DASH_ZERO; break;
                case SWT.LINE_DOT: dashes = width !is 0 ? LINE_DOT : LINE_DOT_ZERO; break;
                case SWT.LINE_DASHDOT: dashes = width !is 0 ? LINE_DASHDOT : LINE_DASHDOT_ZERO; break;
                case SWT.LINE_DASHDOTDOT: dashes = width !is 0 ? LINE_DASHDOTDOT : LINE_DASHDOTDOT_ZERO; break;
                case SWT.LINE_CUSTOM: dashes = data.lineDashes; break;
                default:
            }
            if (dashes !is null) {
                dashesOffset = data.lineDashesOffset;
                double[] cairoDashes = new double[dashes.length];
                for (int i = 0; i < cairoDashes.length; i++) {
                    cairoDashes[i] = width is 0 || data.lineStyle is SWT.LINE_CUSTOM ? dashes[i] : dashes[i] * width;
                }
                Cairo.cairo_set_dash(cairo, cairoDashes.ptr, cast(int)/*64bit*/cairoDashes.length, dashesOffset);
            } else {
                Cairo.cairo_set_dash(cairo, null, 0, 0);
            }
        }
        if ((state & LINE_MITERLIMIT) !is 0) {
            Cairo.cairo_set_miter_limit(cairo, data.lineMiterLimit);
        }
        if ((state & DRAW_OFFSET) !is 0) {
            data.cairoXoffset = data.cairoYoffset = 0;
            double[] matrix = new double[6];
            Cairo.cairo_get_matrix(cairo,cast(cairo_matrix_t*) matrix.ptr);
            double dx = 1;
            double dy = 1;
            Cairo.cairo_user_to_device_distance(cairo, &dx, &dy);
            double scaling = dx;
            if (scaling < 0) scaling = -scaling;
            double strokeWidth = data.lineWidth * scaling;
            if (strokeWidth is 0 || (cast(int)strokeWidth % 2) is 1) {
                data.cairoXoffset = 0.5 / scaling;
            }
            scaling = dy;
            if (scaling < 0) scaling = -scaling;
            strokeWidth = data.lineWidth * scaling;
            if (strokeWidth is 0 || (cast(int)strokeWidth % 2) is 1) {
                data.cairoYoffset = 0.5 / scaling;
            }
        }
        return;
    }
    if ((state & (BACKGROUND | FOREGROUND)) !is 0) {
        GdkColor* foreground;
        if ((state & FOREGROUND) !is 0) {
            foreground = data.foreground;
            data.state &= ~BACKGROUND;
        } else {
            foreground = data.background;
            data.state &= ~FOREGROUND;
        }
        OS.gdk_gc_set_foreground(handle, foreground);
    }
    if ((state & BACKGROUND_BG) !is 0) {
        GdkColor* background = data.background;
        OS.gdk_gc_set_background(handle, background);
    }
    if ((state & FONT) !is 0) {
        if (data.layout !is null) {
            Font font = data.font;
            OS.pango_layout_set_font_description(data.layout, font.handle);
        }
    }
    if ((state & (LINE_CAP | LINE_JOIN | LINE_STYLE | LINE_WIDTH)) !is 0) {
        int cap_style = 0;
        int join_style = 0;
        int width = cast(int)data.lineWidth;
        int line_style = 0;
        TryConst!(float)[] dashes = null;
        switch (data.lineCap) {
            case SWT.CAP_ROUND: cap_style = OS.GDK_CAP_ROUND; break;
            case SWT.CAP_FLAT: cap_style = OS.GDK_CAP_BUTT; break;
            case SWT.CAP_SQUARE: cap_style = OS.GDK_CAP_PROJECTING; break;
                default:
        }
        switch (data.lineJoin) {
            case SWT.JOIN_ROUND: join_style = OS.GDK_JOIN_ROUND; break;
            case SWT.JOIN_MITER: join_style = OS.GDK_JOIN_MITER; break;
            case SWT.JOIN_BEVEL: join_style = OS.GDK_JOIN_BEVEL; break;
                default:
        }
        switch (data.lineStyle) {
            case SWT.LINE_SOLID: break;
            case SWT.LINE_DASH: dashes = width !is 0 ? LINE_DASH : LINE_DASH_ZERO; break;
            case SWT.LINE_DOT: dashes = width !is 0 ? LINE_DOT : LINE_DOT_ZERO; break;
            case SWT.LINE_DASHDOT: dashes = width !is 0 ? LINE_DASHDOT : LINE_DASHDOT_ZERO; break;
            case SWT.LINE_DASHDOTDOT: dashes = width !is 0 ? LINE_DASHDOTDOT : LINE_DASHDOTDOT_ZERO; break;
            case SWT.LINE_CUSTOM: dashes = data.lineDashes; break;
                default:
        }
        if (dashes !is null) {
            if ((state & LINE_STYLE) !is 0) {
                auto dash_list = new char[dashes.length];
                for (int i = 0; i < dash_list.length; i++) {
                    dash_list[i] = cast(char)(width is 0 || data.lineStyle is SWT.LINE_CUSTOM ? dashes[i] : dashes[i] * width);
                }
                OS.gdk_gc_set_dashes(handle, 0, dash_list.ptr, cast(int)/*64bit*/dash_list.length);
            }
            line_style = OS.GDK_LINE_ON_OFF_DASH;
        } else {
            line_style = OS.GDK_LINE_SOLID;
        }
        OS.gdk_gc_set_line_attributes(handle, width, line_style, cap_style, join_style);
    }
}

GdkRegion* convertRgn(GdkRegion* rgn, double[] matrix) {
    auto newRgn = OS.gdk_region_new();
    int nRects;
    GdkRectangle* rects;
    OS.gdk_region_get_rectangles(rgn, &rects, &nRects);
    GdkRectangle* rect;
    int[8] pointArray;
    double x = 0, y = 0;
    for (int i=0; i<nRects; i++) {
        rect = rects +i;
        x = rect.x;
        y = rect.y;
        Cairo.cairo_matrix_transform_point(cast(cairo_matrix_t*)matrix.ptr, &x, &y);
        pointArray[0] = cast(int)x;
        pointArray[1] = cast(int)y;
        x = rect.x + rect.width;
        y = rect.y;
        Cairo.cairo_matrix_transform_point(cast(cairo_matrix_t*)matrix.ptr, &x, &y);
        pointArray[2] = cast(int)Math.round(x);
        pointArray[3] = cast(int)y;
        x = rect.x + rect.width;
        y = rect.y + rect.height;
        Cairo.cairo_matrix_transform_point(cast(cairo_matrix_t*)matrix.ptr, &x, &y);
        pointArray[4] = cast(int)Math.round(x);
        pointArray[5] = cast(int)Math.round(y);
        x = rect.x;
        y = rect.y + rect.height;
        Cairo.cairo_matrix_transform_point(cast(cairo_matrix_t*)matrix.ptr, &x, &y);
        pointArray[6] = cast(int)x;
        pointArray[7] = cast(int)Math.round(y);
        auto polyRgn = OS.gdk_region_polygon(cast(GdkPoint*)pointArray.ptr, pointArray.length / 2, OS.GDK_EVEN_ODD_RULE);
        OS.gdk_region_union(newRgn, polyRgn);
        OS.gdk_region_destroy(polyRgn);
    }
    if (rects !is null) OS.g_free(rects);
    return newRgn;
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
    Rectangle rect = image.getBounds();
    auto gdkGC = OS.gdk_gc_new(image.pixmap);
    if (gdkGC is null) SWT.error(SWT.ERROR_NO_HANDLES);
    OS.gdk_gc_set_subwindow(gdkGC, OS.GDK_INCLUDE_INFERIORS);
    OS.gdk_draw_drawable(image.pixmap, gdkGC, data.drawable, x, y, 0, 0, rect.width, rect.height);
    OS.g_object_unref(gdkGC);
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
    if (width <= 0 || height <= 0) return;
    int deltaX = destX - srcX, deltaY = destY - srcY;
    if (deltaX is 0 && deltaY is 0) return;
    auto drawable = data.drawable;
    if (data.image is null && paint) OS.gdk_gc_set_exposures(handle, true);
    OS.gdk_draw_drawable(drawable, handle, drawable, srcX, srcY, destX, destY, width, height);
    if ((data.image is null) & paint) {
        OS.gdk_gc_set_exposures(handle, false);
        bool disjoint = (destX + width < srcX) || (srcX + width < destX) || (destY + height < srcY) || (srcY + height < destY);
        GdkRectangle rect;
        if (disjoint) {
            rect.x = srcX;
            rect.y = srcY;
            rect.width = width;
            rect.height = height;
            OS.gdk_window_invalidate_rect (cast(GdkWindow*)drawable, &rect, false);
//          OS.gdk_window_clear_area_e(drawable, srcX, srcY, width, height);
        } else {
            if (deltaX !is 0) {
                int newX = destX - deltaX;
                if (deltaX < 0) newX = destX + width;
                rect.x = newX;
                rect.y = srcY;
                rect.width = Math.abs(deltaX);
                rect.height = height;
                OS.gdk_window_invalidate_rect (cast(GdkWindow*)drawable, &rect, false);
//              OS.gdk_window_clear_area_e(drawable, newX, srcY, Math.abs(deltaX), height);
            }
            if (deltaY !is 0) {
                int newY = destY - deltaY;
                if (deltaY < 0) newY = destY + height;
                rect.x = srcX;
                rect.y = newY;
                rect.width = width;
                rect.height = Math.abs(deltaY);
                OS.gdk_window_invalidate_rect (cast(GdkWindow*)drawable, &rect, false);
//              OS.gdk_window_clear_area_e(drawable, srcX, newY, width, Math.abs(deltaY));
            }
        }
    }
}

void createLayout() {
    auto context = OS.gdk_pango_context_get();
    if (context is null) SWT.error(SWT.ERROR_NO_HANDLES);
    data.context = context;
    auto layout = OS.pango_layout_new(context);
    if (layout is null) SWT.error(SWT.ERROR_NO_HANDLES);
    data.layout = layout;
    OS.pango_context_set_language(context, OS.gtk_get_default_language());
    OS.pango_context_set_base_dir(context, (data.style & SWT.MIRRORED) !is 0 ? OS.PANGO_DIRECTION_RTL : OS.PANGO_DIRECTION_LTR);
    OS.gdk_pango_context_set_colormap(context, OS.gdk_colormap_get_system());
    if (OS.GTK_VERSION >= OS.buildVERSION(2, 4, 0)) {
        OS.pango_layout_set_auto_dir(layout, false);
    }
}

void disposeLayout() {
    data.str = null;
    if (data.context !is null) OS.g_object_unref(data.context);
    if (data.layout !is null) OS.g_object_unref(data.layout);
    data.layout = null;
    data.context = null;
}

override
void destroy() {
    if (data.disposeCairo) {
        auto cairo = data.cairo;
        if (cairo !is null) Cairo.cairo_destroy(cairo);
        data.cairo = null;
    }

    /* Free resources */
    auto clipRgn = data.clipRgn;
    if (clipRgn !is null) OS.gdk_region_destroy(clipRgn);
    Image image = data.image;
    if (image !is null) {
        image.memGC = null;
        if (image.transparentPixel !is -1) image.createMask();
    }

    disposeLayout();

    /* Dispose the GC */
    if (drawable !is null) {
        drawable.internal_dispose_GC(handle, data);
    }
    data.drawable = null;
    data.clipRgn = null;
    drawable = null;
    handle = null;
    data.image = null;
    data.str = null;
    data = null;
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
public void drawArc(int x, int y, int width, int height, int startAngle, int arcAngle) {
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
    auto cairo = data.cairo;
    if (cairo !is null) {
        double xOffset = data.cairoXoffset, yOffset = data.cairoYoffset;
        if (width is height) {
            if (arcAngle >= 0) {
                Cairo.cairo_arc_negative(cairo, x + xOffset + width / 2f, y + yOffset + height / 2f, width / 2f, -startAngle * cast(float)Compatibility.PI / 180, -(startAngle + arcAngle) * cast(float)Compatibility.PI / 180);
            } else {
                Cairo.cairo_arc(cairo, x + xOffset + width / 2f, y + yOffset + height / 2f, width / 2f, -startAngle * cast(float)Compatibility.PI / 180, -(startAngle + arcAngle) * cast(float)Compatibility.PI / 180);
            }
        } else {
            Cairo.cairo_save(cairo);
            Cairo.cairo_translate(cairo, x + xOffset + width / 2f, y + yOffset + height / 2f);
            Cairo.cairo_scale(cairo, width / 2f, height / 2f);
            if (arcAngle >= 0) {
                Cairo.cairo_arc_negative(cairo, 0, 0, 1, -startAngle * cast(float)Compatibility.PI / 180, -(startAngle + arcAngle) * cast(float)Compatibility.PI / 180);
            } else {
                Cairo.cairo_arc(cairo, 0, 0, 1, -startAngle * cast(float)Compatibility.PI / 180, -(startAngle + arcAngle) * cast(float)Compatibility.PI / 180);
            }
            Cairo.cairo_restore(cairo);
        }
        Cairo.cairo_stroke(cairo);
        return;
    }
    OS.gdk_draw_arc(data.drawable, handle, 0, x, y, width, height, startAngle * 64, arcAngle * 64);
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
public void drawFocus(int x, int y, int width, int height) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    /*
    * Feature in GTK.  The function gtk_widget_get_default_style()
    * can't be used here because gtk_paint_focus() uses GCs, which
    * are not valid in the default style. The fix is to use a style
    * from a widget.
    */
    auto style = OS.gtk_widget_get_style(data.device.shellHandle);
    auto cairo = data.cairo;
    if (cairo !is null) {
        checkGC(FOREGROUND);
        int lineWidth;
        OS.gtk_widget_style_get1(data.device.shellHandle, OS.focus_line_width.ptr, &lineWidth );
        Cairo.cairo_save(cairo);
        Cairo.cairo_set_line_width(cairo, lineWidth);
        double[2] dashes = 1;
        double dash_offset = -lineWidth / 2f;
        while (dash_offset < 0) dash_offset += 2;
        Cairo.cairo_set_dash(cairo, dashes.ptr, dashes.length, dash_offset);
        Cairo.cairo_rectangle(cairo, x + lineWidth / 2f, y + lineWidth / 2f, width, height);
        Cairo.cairo_stroke(cairo);
        Cairo.cairo_restore(cairo);
        return;
    }
    char dummy;
    OS.gtk_paint_focus(style,cast(GdkWindow *) data.drawable, OS.GTK_STATE_NORMAL, null, data.device.shellHandle, &dummy, x, y, width, height);
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
    if (image is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
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
    if (image is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (image.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    drawImage(image, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, false);
}

void drawImage(Image srcImage, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight, bool simple) {
    int width;
    int height;
    OS.gdk_drawable_get_size(srcImage.pixmap, &width, &height);
    int imgWidth = width;
    int imgHeight = height;
    if (simple) {
        srcWidth = destWidth = imgWidth;
        srcHeight = destHeight = imgHeight;
    } else {
        simple = srcX is 0 && srcY is 0 &&
            srcWidth is destWidth && destWidth is imgWidth &&
            srcHeight is destHeight && destHeight is imgHeight;
        if (srcX + srcWidth > imgWidth || srcY + srcHeight > imgHeight) {
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
        }
    }
    auto cairo = data.cairo;
    if (cairo !is null) {
        if (data.alpha !is 0) {
            srcImage.createSurface();
            Cairo.cairo_save(cairo);
            if ((data.style & SWT.MIRRORED) !is 0) {
                Cairo.cairo_scale(cairo, -1f,  1);
                Cairo.cairo_translate(cairo, - 2 * destX - destWidth, 0);
            }
            Cairo.cairo_rectangle(cairo, destX , destY, destWidth, destHeight);
            Cairo.cairo_clip(cairo);
            Cairo.cairo_translate(cairo, destX - srcX, destY - srcY);
            if (srcWidth !is destWidth || srcHeight !is destHeight) {
                Cairo.cairo_scale(cairo, destWidth / cast(float)srcWidth,  destHeight / cast(float)srcHeight);
            }
            int filter = Cairo.CAIRO_FILTER_GOOD;
            switch (data.interpolation) {
                case SWT.DEFAULT: filter = Cairo.CAIRO_FILTER_GOOD; break;
                case SWT.NONE: filter = Cairo.CAIRO_FILTER_NEAREST; break;
                case SWT.LOW: filter = Cairo.CAIRO_FILTER_FAST; break;
                case SWT.HIGH: filter = Cairo.CAIRO_FILTER_BEST; break;
                default:
            }
            auto pattern = Cairo.cairo_pattern_create_for_surface(srcImage.surface);
            if (pattern is null) SWT.error(SWT.ERROR_NO_HANDLES);
            if (srcWidth !is destWidth || srcHeight !is destHeight) {
                /*
                * Bug in Cairo.  When drawing the image streched with an interpolation
                * alghorithm, the edges of the image are faded.  This is not a bug, but
                * it is not desired.  To avoid the faded edges, it should be possible to
                * use cairo_pattern_set_extend() to set the pattern extend to either
                * CAIRO_EXTEND_REFLECT or CAIRO_EXTEND_PAD, but these are not implemented
                * in some versions of cairo (1.2.x) and have bugs in others (in 1.4.2 it
                * draws with black edges).  The fix is to implement CAIRO_EXTEND_REFLECT
                * by creating an image that is 3 times bigger than the original, drawing
                * the original image in every quadrant (with an appropriate transform) and
                * use this image as the pattern.
                *
                * NOTE: For some reaons, it is necessary to use CAIRO_EXTEND_PAD with
                * the image that was created or the edges are still faded.
                */
                if (Cairo.cairo_version () >= Cairo.CAIRO_VERSION_ENCODE(1, 4, 0)) {
                    auto surface = Cairo.cairo_image_surface_create(Cairo.CAIRO_FORMAT_ARGB32, imgWidth * 3, imgHeight * 3);
                    auto cr = Cairo.cairo_create(surface);
                    Cairo.cairo_set_source_surface(cr, srcImage.surface, imgWidth, imgHeight);
                    Cairo.cairo_paint(cr);
                    Cairo.cairo_scale(cr, -1, -1);
                    Cairo.cairo_set_source_surface(cr, srcImage.surface, -imgWidth, -imgHeight);
                    Cairo.cairo_paint(cr);
                    Cairo.cairo_set_source_surface(cr, srcImage.surface, -imgWidth * 3, -imgHeight);
                    Cairo.cairo_paint(cr);
                    Cairo.cairo_set_source_surface(cr, srcImage.surface, -imgWidth, -imgHeight * 3);
                    Cairo.cairo_paint(cr);
                    Cairo.cairo_set_source_surface(cr, srcImage.surface, -imgWidth * 3, -imgHeight * 3);
                    Cairo.cairo_paint(cr);
                    Cairo.cairo_scale(cr, 1, -1);
                    Cairo.cairo_set_source_surface(cr, srcImage.surface, -imgWidth, imgHeight);
                    Cairo.cairo_paint(cr);
                    Cairo.cairo_set_source_surface(cr, srcImage.surface, -imgWidth * 3, imgHeight);
                    Cairo.cairo_paint(cr);
                    Cairo.cairo_scale(cr, -1, -1);
                    Cairo.cairo_set_source_surface(cr, srcImage.surface, imgWidth, -imgHeight);
                    Cairo.cairo_paint(cr);
                    Cairo.cairo_set_source_surface(cr, srcImage.surface, imgWidth, -imgHeight * 3);
                    Cairo.cairo_paint(cr);
                    Cairo.cairo_destroy(cr);
                    auto newPattern = Cairo.cairo_pattern_create_for_surface(surface);
                    Cairo.cairo_surface_destroy(surface);
                    if (newPattern is null) SWT.error(SWT.ERROR_NO_HANDLES);
                    Cairo.cairo_pattern_destroy(pattern);
                    pattern = newPattern;
                    Cairo.cairo_pattern_set_extend(pattern, Cairo.CAIRO_EXTEND_PAD);
                    double[] matrix = new double[6];
                    Cairo.cairo_matrix_init_translate(cast(cairo_matrix_t*)matrix.ptr, imgWidth, imgHeight);
                    Cairo.cairo_pattern_set_matrix(pattern, cast(cairo_matrix_t*)matrix.ptr);
                }
//              Cairo.cairo_pattern_set_extend(pattern, Cairo.CAIRO_EXTEND_REFLECT);
            }
            Cairo.cairo_pattern_set_filter(pattern, filter);
            Cairo.cairo_set_source(cairo, pattern);
            if (data.alpha !is 0xFF) {
                Cairo.cairo_paint_with_alpha(cairo, data.alpha / cast(float)0xFF);
            } else {
                Cairo.cairo_paint(cairo);
            }
            Cairo.cairo_restore(cairo);
            Cairo.cairo_pattern_destroy(pattern);
        }
        return;
    }
    if (srcImage.alpha !is -1 || srcImage.alphaData !is null) {
        drawImageAlpha(srcImage, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple, imgWidth, imgHeight);
    } else if (srcImage.transparentPixel !is -1 || srcImage.mask !is null) {
        drawImageMask(srcImage, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple, imgWidth, imgHeight);
    } else {
        drawImage(srcImage, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple, imgWidth, imgHeight);
    }
}
void drawImage(Image srcImage, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight, bool simple, int imgWidth, int imgHeight) {
    if (srcWidth is destWidth && srcHeight is destHeight) {
        OS.gdk_draw_drawable(data.drawable, handle, srcImage.pixmap, srcX, srcY, destX, destY, destWidth, destHeight);
    } else {
        if (device.useXRender) {
            drawImageXRender(srcImage, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple, imgWidth, imgHeight, null, -1);
            return;
        }
        auto pixbuf = scale(srcImage.pixmap, srcX, srcY, srcWidth, srcHeight, destWidth, destHeight);
        if (pixbuf !is null) {
            OS.gdk_pixbuf_render_to_drawable(pixbuf, data.drawable, handle, 0, 0, destX, destY, destWidth, destHeight, OS.GDK_RGB_DITHER_NORMAL, 0, 0);
            OS.g_object_unref(pixbuf);
        }
    }
}
void drawImageAlpha(Image srcImage, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight, bool simple, int imgWidth, int imgHeight) {
    if (srcImage.alpha is 0) return;
    if (srcImage.alpha is 255) {
        drawImage(srcImage, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple, imgWidth, imgHeight);
        return;
    }
    if (device.useXRender) {
        drawImageXRender(srcImage, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple, imgWidth, imgHeight, srcImage.mask, OS.PictStandardA8);
        return;
    }
    auto pixbuf = OS.gdk_pixbuf_new(OS.GDK_COLORSPACE_RGB, true, 8, srcWidth, srcHeight);
    if (pixbuf is null) return;
    auto colormap = OS.gdk_colormap_get_system();
    OS.gdk_pixbuf_get_from_drawable(pixbuf, srcImage.pixmap, colormap, srcX, srcY, 0, 0, srcWidth, srcHeight);
    int stride = OS.gdk_pixbuf_get_rowstride(pixbuf);
    auto pixels = OS.gdk_pixbuf_get_pixels(pixbuf);
    byte[] line = new byte[stride];
    byte alpha = cast(byte)srcImage.alpha;
    byte[] alphaData = srcImage.alphaData;
    for (int y=0; y<srcHeight; y++) {
        int alphaIndex = (y + srcY) * imgWidth + srcX;
        OS.memmove(line.ptr, pixels + (y * stride), stride);
        for (int x=3; x<stride; x+=4) {
            line[x] = alphaData is null ? alpha : alphaData[alphaIndex++];
        }
        OS.memmove(pixels + (y * stride), line.ptr, stride);
    }
    if (srcWidth !is destWidth || srcHeight !is destHeight) {
        auto scaledPixbuf = OS.gdk_pixbuf_scale_simple(pixbuf, destWidth, destHeight, OS.GDK_INTERP_BILINEAR);
        OS.g_object_unref(pixbuf);
        if (scaledPixbuf is null) return;
        pixbuf = scaledPixbuf;
    }
    /*
    * Feature in GTK.  gdk_draw_pixbuf was introduced in GTK+ 2.2.0 and
    * supports clipping.
    */
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 2, 0)) {
        OS.gdk_draw_pixbuf(data.drawable, handle, pixbuf, 0, 0, destX, destY, destWidth, destHeight, OS.GDK_RGB_DITHER_NORMAL, 0, 0);
    } else {
        OS.gdk_pixbuf_render_to_drawable_alpha(pixbuf, data.drawable, 0, 0, destX, destY, destWidth, destHeight, OS.GDK_PIXBUF_ALPHA_BILEVEL, 128, OS.GDK_RGB_DITHER_NORMAL, 0, 0);
    }
    OS.g_object_unref(pixbuf);
}
void drawImageMask(Image srcImage, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight, bool simple, int imgWidth, int imgHeight) {
    auto drawable = data.drawable;
    auto colorPixmap = srcImage.pixmap;
    /* Generate the mask if necessary. */
    if (srcImage.transparentPixel !is -1) srcImage.createMask();
    auto maskPixmap = srcImage.mask;

    if (device.useXRender) {
        drawImageXRender(srcImage, srcX, srcY, srcWidth, srcHeight, destX, destY, destWidth, destHeight, simple, imgWidth, imgHeight, maskPixmap, OS.PictStandardA1);
    } else {
        if (srcWidth !is destWidth || srcHeight !is destHeight) {
            auto pixbuf = OS.gdk_pixbuf_new(OS.GDK_COLORSPACE_RGB, true, 8, srcWidth, srcHeight);
            if (pixbuf !is null) {
                auto colormap = OS.gdk_colormap_get_system();
                OS.gdk_pixbuf_get_from_drawable(pixbuf, colorPixmap, colormap, srcX, srcY, 0, 0, srcWidth, srcHeight);
                auto maskPixbuf = OS.gdk_pixbuf_new(OS.GDK_COLORSPACE_RGB, false, 8, srcWidth, srcHeight);
                if (maskPixbuf !is null) {
                    OS.gdk_pixbuf_get_from_drawable(maskPixbuf, maskPixmap, null, srcX, srcY, 0, 0, srcWidth, srcHeight);
                    int stride = OS.gdk_pixbuf_get_rowstride(pixbuf);
                    auto pixels = OS.gdk_pixbuf_get_pixels(pixbuf);
                    byte[] line = new byte[stride];
                    int maskStride = OS.gdk_pixbuf_get_rowstride(maskPixbuf);
                    auto maskPixels = OS.gdk_pixbuf_get_pixels(maskPixbuf);
                    byte[] maskLine = new byte[maskStride];
                    for (int y=0; y<srcHeight; y++) {
                        auto offset = pixels + (y * stride);
                        OS.memmove(line.ptr, offset, stride);
                        auto maskOffset = maskPixels + (y * maskStride);
                        OS.memmove(maskLine.ptr, maskOffset, maskStride);
                        for (int x=0; x<srcWidth; x++) {
                            if (maskLine[x * 3] is 0) {
                                line[x*4+3] = 0;
                            }
                        }
                        OS.memmove(offset, line.ptr, stride);
                    }
                    OS.g_object_unref(maskPixbuf);
                    auto scaledPixbuf = OS.gdk_pixbuf_scale_simple(pixbuf, destWidth, destHeight, OS.GDK_INTERP_BILINEAR);
                    if (scaledPixbuf !is null) {
                        GdkPixmap * colorBuffer;
                        GdkBitmap * maskBuffer;
                        OS.gdk_pixbuf_render_pixmap_and_mask(scaledPixbuf, &colorBuffer, &maskBuffer, 128);
                        colorPixmap = cast(GdkDrawable *)colorBuffer;
                        maskPixmap = cast(GdkDrawable *)maskBuffer;
                        OS.g_object_unref(scaledPixbuf);
                    }
                }
                OS.g_object_unref(pixbuf);
            }
            srcX = 0;
            srcY = 0;
            srcWidth = destWidth;
            srcHeight = destHeight;
        }

        /* Merge clipping with mask if necessary */
        if (data.clipRgn !is null) {
            int newWidth =  srcX + srcWidth;
            int newHeight = srcY + srcHeight;
            int bytesPerLine = (newWidth + 7) / 8;
            auto maskData = new char[bytesPerLine * newHeight];
            auto mask = cast(GdkDrawable *) OS.gdk_bitmap_create_from_data(null, maskData.ptr, newWidth, newHeight);
            if (mask !is null) {
                auto gc = OS.gdk_gc_new(mask);
                OS.gdk_region_offset(data.clipRgn, -destX + srcX, -destY + srcY);
                OS.gdk_gc_set_clip_region(gc, data.clipRgn);
                OS.gdk_region_offset(data.clipRgn, destX - srcX, destY - srcY);
                GdkColor* color = new GdkColor();
                color.pixel = 1;
                OS.gdk_gc_set_foreground(gc, color);
                OS.gdk_draw_rectangle(mask, gc, 1, 0, 0, newWidth, newHeight);
                OS.gdk_gc_set_function(gc, OS.GDK_AND);
                OS.gdk_draw_drawable(mask, gc, maskPixmap, 0, 0, 0, 0, newWidth, newHeight);
                OS.g_object_unref(gc);
                if (maskPixmap !is null && srcImage.mask !is maskPixmap) OS.g_object_unref(maskPixmap);
                maskPixmap = mask;
            }
        }

        /* Blit cliping the mask */
        GdkGCValues* values = new GdkGCValues();
        OS.gdk_gc_get_values(handle, values);
        OS.gdk_gc_set_clip_mask(handle, cast(GdkBitmap *)maskPixmap);
        OS.gdk_gc_set_clip_origin(handle, destX - srcX, destY - srcY);
        OS.gdk_draw_drawable(drawable, handle, colorPixmap, srcX, srcY, destX, destY, srcWidth, srcHeight);
        OS.gdk_gc_set_values(handle, values, OS.GDK_GC_CLIP_MASK | OS.GDK_GC_CLIP_X_ORIGIN | OS.GDK_GC_CLIP_Y_ORIGIN);
        if (data.clipRgn !is null) OS.gdk_gc_set_clip_region(handle, data.clipRgn);
    }

    /* Destroy scaled pixmaps */
    if (colorPixmap !is null && srcImage.pixmap !is colorPixmap) OS.g_object_unref(colorPixmap);
    if (maskPixmap !is null && srcImage.mask !is maskPixmap) OS.g_object_unref(maskPixmap);
    /* Destroy the image mask if the there is a GC created on the image */
    if (srcImage.transparentPixel !is -1 && srcImage.memGC !is null) srcImage.destroyMask();
}
void drawImageXRender(Image srcImage, int srcX, int srcY, int srcWidth, int srcHeight, int destX, int destY, int destWidth, int destHeight, bool simple, int imgWidth, int imgHeight, GdkDrawable* maskPixmap, int maskType) {
    int translateX = 0, translateY = 0;
    auto drawable = data.drawable;
    if (data.image is null && !data.realDrawable) {
        int x, y;
        GdkDrawable* real_drawable;
        OS.gdk_window_get_internal_paint_info(cast(GdkWindow*)drawable, &real_drawable, &x, &y);
        drawable = real_drawable;
        translateX = -x;
        translateY = -y;
    }
    auto xDisplay = OS.GDK_DISPLAY();
    size_t maskPict = 0;
    if (maskPixmap !is null) {
        int attribCount = 0;
        XRenderPictureAttributes* attrib;
        if (srcImage.alpha !is -1) {
            attribCount = 1;
            attrib = new XRenderPictureAttributes();
            attrib.repeat = true;
        }
        maskPict = OS.XRenderCreatePicture(cast(void*)xDisplay, OS.gdk_x11_drawable_get_xid(maskPixmap), OS.XRenderFindStandardFormat(cast(void*)xDisplay, maskType), attribCount, attrib);
        if (maskPict is 0) SWT.error(SWT.ERROR_NO_HANDLES);
    }
    auto format = OS.XRenderFindVisualFormat(cast(void*)xDisplay, OS.gdk_x11_visual_get_xvisual(OS.gdk_visual_get_system()));
    auto destPict = OS.XRenderCreatePicture(cast(void*)xDisplay, OS.gdk_x11_drawable_get_xid(drawable), format, 0, null);
    if (destPict is 0) SWT.error(SWT.ERROR_NO_HANDLES);
    size_t srcPict = OS.XRenderCreatePicture(xDisplay, OS.gdk_x11_drawable_get_xid(srcImage.pixmap), format, 0, null);
    if (srcPict is 0) SWT.error(SWT.ERROR_NO_HANDLES);
    if (srcWidth !is destWidth || srcHeight !is destHeight) {
        int[] transform = [cast(int)((cast(float)srcWidth / destWidth) * 65536), 0, 0, 0, cast(int)((cast(float)srcHeight / destHeight) * 65536), 0, 0, 0, 65536];
        OS.XRenderSetPictureTransform(xDisplay, srcPict, cast(XTransform*)transform.ptr);
        if (maskPict !is 0) OS.XRenderSetPictureTransform(xDisplay, maskPict, cast(XTransform*)transform.ptr);
        srcX *= destWidth / cast(float)srcWidth;
        srcY *= destHeight / cast(float)srcHeight;
    }
    auto clipping = data.clipRgn;
    if (data.damageRgn !is null) {
        if (clipping is null) {
            clipping = data.damageRgn;
        } else {
            clipping = OS.gdk_region_new();
            OS.gdk_region_union(clipping, data.clipRgn);
            OS.gdk_region_intersect(clipping, data.damageRgn);
        }
    }
    if (clipping !is null) {
        int nRects;
        GdkRectangle* rects;
        OS.gdk_region_get_rectangles(clipping, &rects, &nRects);
        GdkRectangle* rect;
        short[] xRects = new short[nRects * 4];
        for (int i=0, j=0; i<nRects; i++, j+=4) {
            rect = rects +i;
            xRects[j  ] = cast(short)rect.x;
            xRects[j+1] = cast(short)rect.y;
            xRects[j+2] = cast(short)rect.width;
            xRects[j+3] = cast(short)rect.height;
        }
        OS.XRenderSetPictureClipRectangles(xDisplay, destPict, translateX, translateY,cast(XRectangle*) xRects.ptr, nRects);
        if (clipping !is data.clipRgn && clipping !is data.damageRgn) {
            OS.gdk_region_destroy(clipping);
        }
        if (rects !is null) OS.g_free(rects);
    }
    OS.XRenderComposite(xDisplay, maskPict !is 0 ? OS.PictOpOver : OS.PictOpSrc, srcPict, maskPict, destPict, srcX, srcY, srcX, srcY, destX + translateX, destY + translateY, destWidth, destHeight);
    OS.XRenderFreePicture(xDisplay, destPict);
    OS.XRenderFreePicture(xDisplay, srcPict);
    if (maskPict !is 0) OS.XRenderFreePicture(xDisplay, maskPict);
}

GdkPixbuf* scale(GdkDrawable* src, int srcX, int srcY, int srcWidth, int srcHeight, int destWidth, int destHeight) {
    auto pixbuf = OS.gdk_pixbuf_new(OS.GDK_COLORSPACE_RGB, false, 8, srcWidth, srcHeight);
    if (pixbuf is null) return null;
    auto colormap = OS.gdk_colormap_get_system();
    OS.gdk_pixbuf_get_from_drawable(pixbuf, src, colormap, srcX, srcY, 0, 0, srcWidth, srcHeight);
    auto scaledPixbuf = OS.gdk_pixbuf_scale_simple(pixbuf, destWidth, destHeight, OS.GDK_INTERP_BILINEAR);
    OS.g_object_unref(pixbuf);
    return scaledPixbuf;
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
public void drawLine(int x1, int y1, int x2, int y2) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(DRAW);
    auto cairo = data.cairo;
    if (cairo !is null) {
        double xOffset = data.cairoXoffset, yOffset = data.cairoYoffset;
        Cairo.cairo_move_to(cairo, x1 + xOffset, y1 + yOffset);
        Cairo.cairo_line_to(cairo, x2 + xOffset, y2 + yOffset);
        Cairo.cairo_stroke(cairo);
        return;
    }
    OS.gdk_draw_line (data.drawable, handle, x1, y1, x2, y2);
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
public void drawOval(int x, int y, int width, int height) {
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
    auto cairo = data.cairo;
    if (cairo !is null) {
        double xOffset = data.cairoXoffset, yOffset = data.cairoYoffset;
        if (width is height) {
            Cairo.cairo_arc_negative(cairo, x + xOffset + width / 2f, y + yOffset + height / 2f, width / 2f, 0, -2 * cast(float)Compatibility.PI);
        } else {
            Cairo.cairo_save(cairo);
            Cairo.cairo_translate(cairo, x + xOffset + width / 2f, y + yOffset + height / 2f);
            Cairo.cairo_scale(cairo, width / 2f, height / 2f);
            Cairo.cairo_arc_negative(cairo, 0, 0, 1, 0, -2 * cast(float)Compatibility.PI);
            Cairo.cairo_restore(cairo);
        }
        Cairo.cairo_stroke(cairo);
        return;
    }
    OS.gdk_draw_arc(data.drawable, handle, 0, x, y, width, height, 0, 23040);
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
public void drawPath(Path path) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (path is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (path.handle is null) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    initCairo();
    checkGC(DRAW);
    auto cairo = data.cairo;
    Cairo.cairo_save(cairo);
    double xOffset = data.cairoXoffset, yOffset = data.cairoYoffset;
    Cairo.cairo_translate(cairo, xOffset, yOffset);
    auto copy = Cairo.cairo_copy_path(path.handle);
    if (copy is null) SWT.error(SWT.ERROR_NO_HANDLES);
    Cairo.cairo_append_path(cairo, copy);
    Cairo.cairo_path_destroy(copy);
    Cairo.cairo_stroke(cairo);
    Cairo.cairo_restore(cairo);
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
    checkGC(DRAW);
    auto cairo = data.cairo;
    if (cairo !is null) {
        Cairo.cairo_rectangle(cairo, x, y, 1, 1);
        Cairo.cairo_fill(cairo);
        return;
    }
    OS.gdk_draw_point(data.drawable, handle, x, y);
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
public void drawPolygon(int[] pointArray) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    // SWT externsion: allow null array
    //if (pointArray is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    checkGC(DRAW);
    auto cairo = data.cairo;
    if (cairo !is null) {
        drawPolyline(cairo, pointArray, true);
        Cairo.cairo_stroke(cairo);
        return;
    }
    OS.gdk_draw_polygon(data.drawable, handle, 0, cast(GdkPoint*)pointArray.ptr, cast(int)/*64bit*/pointArray.length / 2);
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
    auto cairo = data.cairo;
    if (cairo !is null) {
        drawPolyline(cairo, pointArray, false);
        Cairo.cairo_stroke(cairo);
        return;
    }
    OS.gdk_draw_lines(data.drawable, handle, cast(GdkPoint*)pointArray.ptr, cast(int)/*64bit*/pointArray.length / 2);
}

void drawPolyline(org.eclipse.swt.internal.gtk.OS.cairo_t* cairo, int[] pointArray, bool close) {
    auto count = pointArray.length / 2;
    if (count is 0) return;
    double xOffset = data.cairoXoffset, yOffset = data.cairoYoffset;
    Cairo.cairo_move_to(cairo, pointArray[0] + xOffset, pointArray[1] + yOffset);
    for (int i = 1, j=2; i < count; i++, j += 2) {
        Cairo.cairo_line_to(cairo, pointArray[j] + xOffset, pointArray[j + 1] + yOffset);
    }
    if (close) Cairo.cairo_close_path(cairo);
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
public void drawRectangle(int x, int y, int width, int height) {
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
    auto cairo = data.cairo;
    if (cairo !is null) {
        double xOffset = data.cairoXoffset, yOffset = data.cairoYoffset;
        Cairo.cairo_rectangle(cairo, x + xOffset, y + yOffset, width, height);
        Cairo.cairo_stroke(cairo);
        return;
    }
    OS.gdk_draw_rectangle(data.drawable, handle, 0, x, y, width, height);
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
public void drawRectangle(Rectangle rect) {
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
public void drawRoundRectangle(int x, int y, int width, int height, int arcWidth, int arcHeight) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(DRAW);
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
    if (naw < 0) naw = 0 - naw;
    if (nah < 0) nah = 0 - nah;
    auto cairo = data.cairo;
    if (cairo !is null) {
        double xOffset = data.cairoXoffset, yOffset = data.cairoYoffset;
        if (naw is 0 || nah is 0) {
            Cairo.cairo_rectangle(cairo, x + xOffset, y + yOffset, width, height);
        } else {
            float naw2 = naw / 2f;
            float nah2 = nah / 2f;
            float fw = nw / naw2;
            float fh = nh / nah2;
            Cairo.cairo_save(cairo);
            Cairo.cairo_translate(cairo, nx + xOffset, ny + yOffset);
            Cairo.cairo_scale(cairo, naw2, nah2);
            Cairo.cairo_move_to(cairo, fw - 1, 0);
            Cairo.cairo_arc(cairo, fw - 1, 1, 1, Compatibility.PI + Compatibility.PI/2.0, Compatibility.PI*2.0);
            Cairo.cairo_arc(cairo, fw - 1, fh - 1, 1, 0, Compatibility.PI/2.0);
            Cairo.cairo_arc(cairo, 1, fh - 1, 1, Compatibility.PI/2, Compatibility.PI);
            Cairo.cairo_arc(cairo, 1, 1, 1, Compatibility.PI, 270.0*Compatibility.PI/180.0);
            Cairo.cairo_close_path(cairo);
            Cairo.cairo_restore(cairo);
        }
        Cairo.cairo_stroke(cairo);
        return;
    }
    int naw2 = naw / 2;
    int nah2 = nah / 2;
    auto drawable = data.drawable;
    if (nw > naw) {
        if (nh > nah) {
            OS.gdk_draw_arc(drawable, handle, 0, nx, ny, naw, nah, 5760, 5760);
            OS.gdk_draw_line(drawable, handle, nx + naw2, ny, nx + nw - naw2, ny);
            OS.gdk_draw_arc(drawable, handle, 0, nx + nw - naw, ny, naw, nah, 0, 5760);
            OS.gdk_draw_line(drawable, handle, nx + nw, ny + nah2, nx + nw, ny + nh - nah2);
            OS.gdk_draw_arc(drawable, handle, 0, nx + nw - naw, ny + nh - nah, naw, nah, 17280, 5760);
            OS.gdk_draw_line(drawable,handle, nx + naw2, ny + nh, nx + nw - naw2, ny + nh);
            OS.gdk_draw_arc(drawable, handle, 0, nx, ny + nh - nah, naw, nah, 11520, 5760);
            OS.gdk_draw_line(drawable, handle,  nx, ny + nah2, nx, ny + nh - nah2);
        } else {
            OS.gdk_draw_arc(drawable, handle, 0, nx, ny, naw, nh, 5760, 11520);
            OS.gdk_draw_line(drawable, handle, nx + naw2, ny, nx + nw - naw2, ny);
            OS.gdk_draw_arc(drawable, handle, 0, nx + nw - naw, ny, naw, nh, 17280, 11520);
            OS.gdk_draw_line(drawable,handle, nx + naw2, ny + nh, nx + nw - naw2, ny + nh);
        }
    } else {
        if (nh > nah) {
            OS.gdk_draw_arc(drawable, handle, 0, nx, ny, nw, nah, 0, 11520);
            OS.gdk_draw_line(drawable, handle, nx + nw, ny + nah2, nx + nw, ny + nh - nah2);
            OS.gdk_draw_arc(drawable, handle, 0, nx, ny + nh - nah, nw, nah, 11520, 11520);
            OS.gdk_draw_line(drawable,handle, nx, ny + nah2, nx, ny + nh - nah2);
        } else {
            OS.gdk_draw_arc(drawable, handle, 0, nx, ny, nw, nh, 0, 23040);
        }
    }
}

/**
 * Draws the given str, using the receiver's current font and
 * foreground color. No tab expansion or carriage return processing
 * will be performed. The background of the rectangular area where
 * the str is being drawn will be filled with the receiver's
 * background color.
 *
 * @param str the str to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the str is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the str is to be drawn
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawString (String str, int x, int y) {
    drawString(str, x, y, false);
}
/**
 * Draws the given str, using the receiver's current font and
 * foreground color. No tab expansion or carriage return processing
 * will be performed. If <code>isTransparent</code> is <code>true</code>,
 * then the background of the rectangular area where the str is being
 * drawn will not be modified, otherwise it will be filled with the
 * receiver's background color.
 *
 * @param str the str to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the str is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the str is to be drawn
 * @param isTransparent if <code>true</code> the background will be transparent, otherwise it will be opaque
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawString(String str, int x, int y, bool isTransparent) {
    drawText(str, x, y, isTransparent ? SWT.DRAW_TRANSPARENT : 0);
}

/**
 * Draws the given str, using the receiver's current font and
 * foreground color. Tab expansion and carriage return processing
 * are performed. The background of the rectangular area where
 * the text is being drawn will be filled with the receiver's
 * background color.
 *
 * @param str the str to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawText(String str, int x, int y) {
    drawText(str, x, y, SWT.DRAW_DELIMITER | SWT.DRAW_TAB);
}

/**
 * Draws the given str, using the receiver's current font and
 * foreground color. Tab expansion and carriage return processing
 * are performed. If <code>isTransparent</code> is <code>true</code>,
 * then the background of the rectangular area where the text is being
 * drawn will not be modified, otherwise it will be filled with the
 * receiver's background color.
 *
 * @param str the str to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param isTransparent if <code>true</code> the background will be transparent, otherwise it will be opaque
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawText(String str, int x, int y, bool isTransparent) {
    int flags = SWT.DRAW_DELIMITER | SWT.DRAW_TAB;
    if (isTransparent) flags |= SWT.DRAW_TRANSPARENT;
    drawText(str, x, y, flags);
}

/**
 * Draws the given str, using the receiver's current font and
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
 * @param str the str to be drawn
 * @param x the x coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param y the y coordinate of the top left corner of the rectangular area where the text is to be drawn
 * @param flags the flags specifying how to process the text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void drawText (String str, int x, int y, int flags) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    // SWT extension: allow null string
    //if (str is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (str.length is 0) return;
    auto cairo = data.cairo;
    if (cairo !is null) {
        if (OS.GTK_VERSION < OS.buildVERSION(2, 8, 0)) {
            //TODO - honor flags
            checkGC(FOREGROUND | FONT);
            cairo_font_extents_t* extents = new cairo_font_extents_t();
            Cairo.cairo_font_extents(cairo, extents);
            double baseline = y + extents.ascent;
            Cairo.cairo_move_to(cairo, x, baseline);
            char* buffer = toStringz( str );
            Cairo.cairo_show_text(cairo, buffer);
            Cairo.cairo_new_path(cairo);
            return;
        }
    }
    setString(str, flags);
    if (cairo !is null) {
        if ((flags & SWT.DRAW_TRANSPARENT) is 0) {
            checkGC(BACKGROUND);
            int width, height;
            OS.pango_layout_get_size(data.layout, &width, &height);
            Cairo.cairo_rectangle(cairo, x, y, OS.PANGO_PIXELS(width), OS.PANGO_PIXELS(height));
            Cairo.cairo_fill(cairo);
        }
        checkGC(FOREGROUND | FONT);
        if ((data.style & SWT.MIRRORED) !is 0) {
            Cairo.cairo_save(cairo);
            int width, height;
            OS.pango_layout_get_size(data.layout, &width, &height);
            Cairo.cairo_scale(cairo, -1f,  1);
            Cairo.cairo_translate(cairo, -2 * x - OS.PANGO_PIXELS(width), 0);
        }
        Cairo.cairo_move_to(cairo, x, y);
        OS.pango_cairo_show_layout(cairo, data.layout);
        if ((data.style & SWT.MIRRORED) !is 0) {
            Cairo.cairo_restore(cairo);
        }
        Cairo.cairo_new_path(cairo);
        return;
    }
    checkGC(FOREGROUND | FONT | BACKGROUND_BG);
    GdkColor* background = null;
    if ((flags & SWT.DRAW_TRANSPARENT) is 0) background = data.background;
    if (!data.xorMode) {
        OS.gdk_draw_layout_with_colors(data.drawable, handle, x, y, data.layout, null, background);
    } else {
        auto layout = data.layout;
        int w, h;
        OS.pango_layout_get_size(layout, &w, &h);
        int width = OS.PANGO_PIXELS(w);
        int height = OS.PANGO_PIXELS(h);
        auto pixmap = OS.gdk_pixmap_new(cast(GdkDrawable*)OS.GDK_ROOT_PARENT(), width, height, -1);
        if (pixmap is null) SWT.error(SWT.ERROR_NO_HANDLES);
        auto gdkGC = OS.gdk_gc_new(cast(GdkDrawable*)pixmap);
        if (gdkGC is null) SWT.error(SWT.ERROR_NO_HANDLES);
        GdkColor* black = new GdkColor();
        OS.gdk_gc_set_foreground(gdkGC, black);
        OS.gdk_draw_rectangle(cast(GdkDrawable*)pixmap, gdkGC, 1, 0, 0, width, height);
        OS.gdk_gc_set_foreground(gdkGC, data.foreground);
        OS.gdk_draw_layout_with_colors(cast(GdkDrawable*)pixmap, gdkGC, 0, 0, layout, null, background);
        OS.g_object_unref(gdkGC);
        OS.gdk_draw_drawable(data.drawable, handle, cast(GdkDrawable*)pixmap, 0, 0, x, y, width, height);
        OS.g_object_unref(pixmap);
    }
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
    if ( auto gc = cast(GC)object){
       return handle is gc.handle;
    }
    return false;
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
public void fillArc(int x, int y, int width, int height, int startAngle, int arcAngle) {
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
    auto cairo = data.cairo;
    if (cairo !is null) {
        if (width is height) {
            if (arcAngle >= 0) {
                Cairo.cairo_arc_negative(cairo, x + width / 2f, y + height / 2f, width / 2f, -startAngle * cast(float)Compatibility.PI / 180,  -(startAngle + arcAngle) * cast(float)Compatibility.PI / 180);
            } else {
                Cairo.cairo_arc(cairo, x + width / 2f, y + height / 2f, width / 2f, -startAngle * cast(float)Compatibility.PI / 180,  -(startAngle + arcAngle) * cast(float)Compatibility.PI / 180);
            }
            Cairo.cairo_line_to(cairo, x + width / 2f, y + height / 2f);
        } else {
            Cairo.cairo_save(cairo);
            Cairo.cairo_translate(cairo, x + width / 2f, y + height / 2f);
            Cairo.cairo_scale(cairo, width / 2f, height / 2f);
            if (arcAngle >= 0) {
                Cairo.cairo_arc_negative(cairo, 0, 0, 1, -startAngle * cast(float)Compatibility.PI / 180,  -(startAngle + arcAngle) * cast(float)Compatibility.PI / 180);
            } else {
                Cairo.cairo_arc(cairo, 0, 0, 1, -startAngle * cast(float)Compatibility.PI / 180,  -(startAngle + arcAngle) * cast(float)Compatibility.PI / 180);
            }
            Cairo.cairo_line_to(cairo, 0, 0);
            Cairo.cairo_restore(cairo);
        }
        Cairo.cairo_fill(cairo);
        return;
    }
    OS.gdk_draw_arc(data.drawable, handle, 1, x, y, width, height, startAngle * 64, arcAngle * 64);
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
    if ((width is 0) || (height is 0)) return;

    /* Rewrite this to use GdkPixbuf */

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
    if (fromRGB.opEquals(toRGB)) {
        fillRectangle(x, y, width, height);
        return;
    }
    auto cairo = data.cairo;
    if (cairo !is null) {
        org.eclipse.swt.internal.gtk.OS.cairo_pattern_t* pattern;
        if (vertical) {
            pattern = Cairo.cairo_pattern_create_linear (0.0, 0.0, 0.0, 1.0);
        } else {
            pattern = Cairo.cairo_pattern_create_linear (0.0, 0.0, 1.0, 0.0);
        }
        Cairo.cairo_pattern_add_color_stop_rgba (pattern, 0, fromRGB.red / 255f, fromRGB.green / 255f, fromRGB.blue / 255f, data.alpha / 255f);
        Cairo.cairo_pattern_add_color_stop_rgba (pattern, 1, toRGB.red / 255f, toRGB.green / 255f, toRGB.blue / 255f, data.alpha / 255f);
        Cairo.cairo_save(cairo);
        Cairo.cairo_translate(cairo, x, y);
        Cairo.cairo_scale(cairo, width, height);
        Cairo.cairo_rectangle(cairo, 0, 0, 1, 1);
        Cairo.cairo_set_source(cairo, pattern);
        Cairo.cairo_fill(cairo);
        Cairo.cairo_restore(cairo);
        Cairo.cairo_pattern_destroy(pattern);
        return;
    }
    ImageData.fillGradientRectangle(this, data.device,
        x, y, width, height, vertical, fromRGB, toRGB,
        8, 8, 8);
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
public void fillOval(int x, int y, int width, int height) {
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
    auto cairo = data.cairo;
    if (cairo !is null) {
        if (width is height) {
            Cairo.cairo_arc_negative(cairo, x + width / 2f, y + height / 2f, width / 2f, 0, 2 * cast(float)Compatibility.PI);
        } else {
            Cairo.cairo_save(cairo);
            Cairo.cairo_translate(cairo, x + width / 2f, y + height / 2f);
            Cairo.cairo_scale(cairo, width / 2f, height / 2f);
            Cairo.cairo_arc_negative(cairo, 0, 0, 1, 0, 2 * cast(float)Compatibility.PI);
            Cairo.cairo_restore(cairo);
        }
        Cairo.cairo_fill(cairo);
        return;
    }
    OS.gdk_draw_arc(data.drawable, handle, 1, x, y, width, height, 0, 23040);
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
    initCairo();
    checkGC(FILL);
    auto cairo = data.cairo;
    auto copy = Cairo.cairo_copy_path(path.handle);
    if (copy is null) SWT.error(SWT.ERROR_NO_HANDLES);
    Cairo.cairo_append_path(cairo, copy);
    Cairo.cairo_path_destroy(copy);
    Cairo.cairo_fill(cairo);
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
    // SWT extension: allow null array
    //if (pointArray is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    checkGC(FILL);
    auto cairo = data.cairo;
    if (cairo !is null) {
        drawPolyline(cairo, pointArray, true);
        Cairo.cairo_fill(cairo);
        return;
    }
    OS.gdk_draw_polygon(data.drawable, handle, 1, cast(GdkPoint*)pointArray.ptr, cast(int)/*64bit*/pointArray.length / 2);
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
public void fillRectangle(int x, int y, int width, int height) {
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
    auto cairo = data.cairo;
    if (cairo !is null) {
        Cairo.cairo_rectangle(cairo, x, y, width, height);
        Cairo.cairo_fill(cairo);
        return;
    }
    OS.gdk_draw_rectangle(data.drawable, handle, 1, x, y, width, height);
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
public void fillRectangle(Rectangle rect) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (rect is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    fillRectangle(rect.x, rect.y, rect.width, rect.height);
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
public void fillRoundRectangle(int x, int y, int width, int height, int arcWidth, int arcHeight) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    checkGC(FILL);
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
    if (naw < 0) naw = 0 - naw;
    if (nah < 0) nah = 0 - nah;
    auto cairo = data.cairo;
    if (cairo !is null) {
        if (naw is 0 || nah is 0) {
            Cairo.cairo_rectangle(cairo, x, y, width, height);
        } else {
            float naw2 = naw / 2f;
            float nah2 = nah / 2f;
            float fw = nw / naw2;
            float fh = nh / nah2;
            Cairo.cairo_save(cairo);
            Cairo.cairo_translate(cairo, nx, ny);
            Cairo.cairo_scale(cairo, naw2, nah2);
            Cairo.cairo_move_to(cairo, fw - 1, 0);
            Cairo.cairo_arc(cairo, fw - 1, 1, 1, Compatibility.PI + Compatibility.PI/2.0, Compatibility.PI*2.0);
            Cairo.cairo_arc(cairo, fw - 1, fh - 1, 1, 0, Compatibility.PI/2.0);
            Cairo.cairo_arc(cairo, 1, fh - 1, 1, Compatibility.PI/2, Compatibility.PI);
            Cairo.cairo_arc(cairo, 1, 1, 1, Compatibility.PI, 270.0*Compatibility.PI/180.0);
            Cairo.cairo_close_path(cairo);
            Cairo.cairo_restore(cairo);
        }
        Cairo.cairo_fill(cairo);
        return;
    }
    int naw2 = naw / 2;
    int nah2 = nah / 2;
    auto drawable = data.drawable;
    if (nw > naw) {
        if (nh > nah) {
            OS.gdk_draw_arc(drawable, handle, 1, nx, ny, naw, nah, 5760, 5760);
            OS.gdk_draw_rectangle(drawable, handle, 1, nx + naw2, ny, nw - naw2 * 2, nh);
            OS.gdk_draw_arc(drawable, handle, 1, nx + nw - naw, ny, naw, nah, 0, 5760);
            OS.gdk_draw_rectangle(drawable, handle, 1, nx, ny + nah2, naw2, nh - nah2 * 2);
            OS.gdk_draw_arc(drawable, handle, 1, nx + nw - naw, ny + nh - nah, naw, nah, 17280, 5760);
            OS.gdk_draw_rectangle(drawable, handle, 1, nx + nw - naw2, ny + nah2, naw2, nh - nah2 * 2);
            OS.gdk_draw_arc(drawable, handle, 1, nx, ny + nh - nah, naw, nah, 11520, 5760);
        } else {
            OS.gdk_draw_arc(drawable, handle, 1, nx, ny, naw, nh, 5760, 11520);
            OS.gdk_draw_rectangle(drawable, handle, 1, nx + naw2, ny, nw - naw2 * 2, nh);
            OS.gdk_draw_arc(drawable, handle, 1, nx + nw - naw, ny, naw, nh, 17280, 11520);
        }
    } else {
        if (nh > nah) {
            OS.gdk_draw_arc(drawable, handle, 1, nx, ny, nw, nah, 0, 11520);
            OS.gdk_draw_rectangle(drawable, handle, 1, nx, ny + nah2, nw, nh - nah2 * 2);
            OS.gdk_draw_arc(drawable, handle, 1, nx, ny + nh - nah, nw, nah, 11520, 11520);
        } else {
            OS.gdk_draw_arc(drawable, handle, 1, nx, ny, nw, nh, 0, 23040);
        }
    }
}

int fixMnemonic (char [] buffer) {
    int i=0, j=0;
    int mnemonic=-1;
    while (i < buffer.length) {
        if ((buffer [j++] = buffer [i++]) is '&') {
            if (i is buffer.length) {continue;}
            if (buffer [i] is '&') {i++; continue;}
            if (mnemonic is -1) mnemonic = j;
            j--;
        }
    }
    while (j < buffer.length) buffer [j++] = 0;
    return mnemonic;
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
    //BOGUS
    return stringExtent([ch]).x;
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
    return data.cairo !is null;
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
    if (data.cairo is null) return SWT.DEFAULT;
    ptrdiff_t antialias = Cairo.cairo_get_antialias(data.cairo);
    switch (antialias) {
        case Cairo.CAIRO_ANTIALIAS_DEFAULT: return SWT.DEFAULT;
        case Cairo.CAIRO_ANTIALIAS_NONE: return SWT.OFF;
        case Cairo.CAIRO_ANTIALIAS_GRAY:
        case Cairo.CAIRO_ANTIALIAS_SUBPIXEL: return SWT.ON;
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
    return Color.gtk_new(data.device, data.background);
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
    //BOGUS
    return stringExtent([ch]).x;
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
    /* Calculate visible bounds in device space */
    int x = 0, y = 0, width = 0, height = 0;
    if (data.width !is -1 && data.height !is -1) {
        width = data.width;
        height = data.height;
    } else {
        int w, h;
        OS.gdk_drawable_get_size(data.drawable, &w, &h);
        width = w;
        height = h;
    }
    /* Intersect visible bounds with clipping in device space and then convert then to user space */
    auto cairo = data.cairo;
    auto clipRgn = data.clipRgn;
    auto damageRgn = data.damageRgn;
    if (clipRgn !is null || damageRgn !is null || cairo !is null) {
        auto rgn = OS.gdk_region_new();
        GdkRectangle rect;
        rect.width = width;
        rect.height = height;
        OS.gdk_region_union_with_rect(rgn, &rect);
        if (damageRgn !is null) {
            OS.gdk_region_intersect (rgn, damageRgn);
        }
        /* Intersect visible bounds with clipping */
        if (clipRgn !is null) {
            /* Convert clipping to device space if needed */
            if (data.clippingTransform !is null) {
                clipRgn = convertRgn(clipRgn, data.clippingTransform);
                OS.gdk_region_intersect(rgn, clipRgn);
                OS.gdk_region_destroy(clipRgn);
            } else {
                OS.gdk_region_intersect(rgn, clipRgn);
            }
        }
        /* Convert to user space */
        if (cairo !is null) {
            double[] matrix = new double[6];
            Cairo.cairo_get_matrix(cairo, cast(cairo_matrix_t*)matrix.ptr);
            Cairo.cairo_matrix_invert(cast(cairo_matrix_t*)matrix.ptr);
            clipRgn = convertRgn(rgn, matrix);
            OS.gdk_region_destroy(rgn);
            rgn = clipRgn;
        }
        OS.gdk_region_get_clipbox(rgn, &rect);
        OS.gdk_region_destroy(rgn);
        x = rect.x;
        y = rect.y;
        width = rect.width;
        height = rect.height;
    }
    return new Rectangle(x, y, width, height);
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
public void getClipping(Region region) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (region is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (region.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    auto clipping = region.handle;
    OS.gdk_region_subtract(clipping, clipping);
    auto cairo = data.cairo;
    auto clipRgn = data.clipRgn;
    if (clipRgn is null) {
        GdkRectangle rect;
        if (data.width !is -1 && data.height !is -1) {
            rect.width = data.width;
            rect.height = data.height;
        } else {
            int width, height;
            OS.gdk_drawable_get_size(data.drawable, &width, &height);
            rect.width = width;
            rect.height = height;
        }
        OS.gdk_region_union_with_rect(clipping, &rect);
    } else {
        /* Convert clipping to device space if needed */
        if (data.clippingTransform !is null) {
            auto rgn = convertRgn(clipRgn, data.clippingTransform);
            OS.gdk_region_union(clipping, rgn);
            OS.gdk_region_destroy(rgn);
        } else {
            OS.gdk_region_union(clipping, clipRgn);
        }
    }
    if (data.damageRgn !is null) {
        OS.gdk_region_intersect(clipping, data.damageRgn);
    }
    /* Convert to user space */
    if (cairo !is null) {
        double[] matrix = new double[6];
        Cairo.cairo_get_matrix(cairo, cast(cairo_matrix_t*)matrix.ptr);
        Cairo.cairo_matrix_invert(cast(cairo_matrix_t*)matrix.ptr);
        auto rgn = convertRgn(clipping, matrix);
        OS.gdk_region_subtract(clipping, clipping);
        OS.gdk_region_union(clipping, rgn);
        OS.gdk_region_destroy(rgn);
    }
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
    auto cairo = data.cairo;
    if (cairo is null) return SWT.FILL_EVEN_ODD;
    return Cairo.cairo_get_fill_rule(cairo) is Cairo.CAIRO_FILL_RULE_WINDING ? SWT.FILL_WINDING : SWT.FILL_EVEN_ODD;
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
public Font getFont() {
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
    if (data.context is null) createLayout();
    checkGC(FONT);
    Font font = data.font;
    auto context = data.context;
    auto lang = OS.pango_context_get_language(context);
    auto metrics = OS.pango_context_get_metrics(context, font.handle, lang);
    FontMetrics fm = new FontMetrics();
    fm.ascent = OS.PANGO_PIXELS(OS.pango_font_metrics_get_ascent(metrics));
    fm.descent = OS.PANGO_PIXELS(OS.pango_font_metrics_get_descent(metrics));
    fm.averageCharWidth = OS.PANGO_PIXELS(OS.pango_font_metrics_get_approximate_char_width(metrics));
    fm.height = fm.ascent + fm.descent;
    OS.pango_font_metrics_unref(metrics);
    return fm;
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
    if (handle is null) SWT.error(SWT.ERROR_WIDGET_DISPOSED);
    return Color.gtk_new(data.device, data.foreground);
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
    return data.interpolation;
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
    if (data.cairo is null) return SWT.DEFAULT;
    ptrdiff_t antialias = Cairo.CAIRO_ANTIALIAS_DEFAULT;
    if (OS.GTK_VERSION < OS.buildVERSION(2, 8, 0)) {
        auto options = Cairo.cairo_font_options_create();
        Cairo.cairo_get_font_options(data.cairo, options);
        antialias = Cairo.cairo_font_options_get_antialias(options);
        Cairo.cairo_font_options_destroy(options);
    } else {
        if (data.context !is null) {
            auto options = OS.pango_cairo_context_get_font_options(data.context);
            if (options !is null) antialias = Cairo.cairo_font_options_get_antialias(options);
        }
    }
    switch (antialias) {
        case Cairo.CAIRO_ANTIALIAS_DEFAULT: return SWT.DEFAULT;
        case Cairo.CAIRO_ANTIALIAS_NONE: return SWT.OFF;
        case Cairo.CAIRO_ANTIALIAS_GRAY:
        case Cairo.CAIRO_ANTIALIAS_SUBPIXEL: return SWT.ON;
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
    auto cairo = data.cairo;
    if (cairo !is null) {
        Cairo.cairo_get_matrix(cairo, cast(cairo_matrix_t*)transform.handle.ptr);
        double[] identity = identity();
        Cairo.cairo_matrix_invert(cast(cairo_matrix_t*)identity.ptr);
        Cairo.cairo_matrix_multiply(cast(cairo_matrix_t*)transform.handle.ptr, cast(cairo_matrix_t*)transform.handle.ptr, cast(cairo_matrix_t*)identity.ptr);
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
    return data.xorMode;
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
public override hash_t toHash() {
    return cast(hash_t)handle;
}

double[] identity() {
    double[] identity = new double[6];
    if ((data.style & SWT.MIRRORED) !is 0) {
        int w, h;
        OS.gdk_drawable_get_size(data.drawable, &w, &h);
        Cairo.cairo_matrix_init(cast(cairo_matrix_t*)identity.ptr, -1, 0, 0, 1, w, 0);
    } else {
        Cairo.cairo_matrix_init_identity(cast(cairo_matrix_t*)identity.ptr);
    }
    return identity;
}

void init_(Drawable drawable, GCData data, GdkGC* gdkGC) {
    if (data.foreground !is null) data.state &= ~FOREGROUND;
    if (data.background !is null) data.state &= ~(BACKGROUND | BACKGROUND_BG);
    if (data.font !is null) data.state &= ~FONT;

    Image image = data.image;
    if (image !is null) {
        image.memGC = this;
        /*
         * The transparent pixel mask might change when drawing on
         * the image.  Destroy it so that it is regenerated when
         * necessary.
         */
        if (image.transparentPixel !is -1) image.destroyMask();
    }
    this.drawable = drawable;
    this.data = data;
    handle = gdkGC;
    if ((data.style & SWT.MIRRORED) !is 0) {
      initCairo();
      auto cairo = data.cairo;
      Cairo.cairo_set_matrix(cairo, cast(cairo_matrix_t*) identity().ptr);
    }
}

void initCairo() {
    data.device.checkCairo();
    auto cairo = data.cairo;
    if (cairo !is null) return;
    auto xDisplay = OS.GDK_DISPLAY();
    auto xVisual = OS.gdk_x11_visual_get_xvisual(OS.gdk_visual_get_system());
    size_t xDrawable;
    int translateX = 0, translateY = 0;
    auto drawable = data.drawable;
    if (data.image !is null) {
        xDrawable = OS.GDK_PIXMAP_XID(drawable);
    } else {
        if (!data.realDrawable) {
            int x, y;
            GdkDrawable* real_drawable;
            OS.gdk_window_get_internal_paint_info(cast(GdkWindow*)drawable, &real_drawable, &x, &y);
            xDrawable = OS.gdk_x11_drawable_get_xid(real_drawable);
            translateX = -x;
            translateY = -y;
        }
    }
    int w, h;
    OS.gdk_drawable_get_size(drawable, &w, &h);
    int width = w, height = h;
    auto surface = Cairo.cairo_xlib_surface_create(cast(void*)xDisplay, xDrawable, xVisual, width, height);
    if (surface is null) SWT.error(SWT.ERROR_NO_HANDLES);
    Cairo.cairo_surface_set_device_offset(surface, translateX, translateY);
    data.cairo = cairo = Cairo.cairo_create(surface);
    Cairo.cairo_surface_destroy(surface);
    if (cairo is null) SWT.error(SWT.ERROR_NO_HANDLES);
    data.disposeCairo = true;
    Cairo.cairo_set_fill_rule(cairo, Cairo.CAIRO_FILL_RULE_EVEN_ODD);
    data.state &= ~(BACKGROUND | FOREGROUND | FONT | LINE_WIDTH | LINE_CAP | LINE_JOIN | LINE_STYLE | DRAW_OFFSET);
    setCairoClip(cairo, data.clipRgn);
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
    return data.clipRgn !is null;
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
public override bool isDisposed() {
    return handle is null;
}

bool isIdentity(double[] matrix) {
    if (matrix is null) return true;
    return matrix[0] is 1 && matrix[1] is 0 && matrix[2] is 0 && matrix[3] is 1 && matrix[4] is 0 && matrix[5] is 0;
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
    if ((data.style & SWT.MIRRORED) !is 0) {
        if (!advanced) {
            setAlpha(0xFF);
            setAntialias(SWT.DEFAULT);
            setBackgroundPattern(null);
            setClipping(cast(GdkRegion*)null);
            setForegroundPattern(null);
            setInterpolation(SWT.DEFAULT);
            setTextAntialias(SWT.DEFAULT);
            setTransform(null);
        }
        return;
    }
    if (advanced && data.cairo !is null) return;
    if (advanced) {
        try {
            initCairo();
        } catch (SWTException e) {}
    } else {
        if (!data.disposeCairo) return;
        auto cairo = data.cairo;
        if (cairo !is null) Cairo.cairo_destroy(cairo);
        data.cairo = null;
        data.interpolation = SWT.DEFAULT;
        data.backgroundPattern = data.foregroundPattern = null;
        data.state = 0;
        setClipping(cast(GdkRegion*)null);
    }
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
    if (data.cairo is null && (alpha & 0xff) is 0xff) return;
    initCairo();
    data.alpha = alpha & 0xff;
    data.state &= ~(BACKGROUND | FOREGROUND | BACKGROUND_BG);
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
    if (data.cairo is null && antialias is SWT.DEFAULT) return;
    int mode = 0;
    switch (antialias) {
        case SWT.DEFAULT: mode = Cairo.CAIRO_ANTIALIAS_DEFAULT; break;
        case SWT.OFF: mode = Cairo.CAIRO_ANTIALIAS_NONE; break;
        case SWT.ON: mode = Cairo.CAIRO_ANTIALIAS_GRAY;
            break;
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    initCairo();
    auto cairo = data.cairo;
    Cairo.cairo_set_antialias(cairo, mode);
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
public void setBackground(Color color) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (color is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (color.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    data.background = color.handle;
    data.backgroundPattern = null;
    data.state &= ~(BACKGROUND | BACKGROUND_BG);
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
public void setBackgroundPattern(Pattern pattern) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (pattern !is null && pattern.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (data.cairo is null && pattern is null) return;
    initCairo();
    if (data.backgroundPattern is pattern) return;
    data.backgroundPattern = pattern;
    data.state &= ~BACKGROUND;
}

static void setCairoFont(org.eclipse.swt.internal.gtk.OS.cairo_t* cairo, Font font) {
    setCairoFont(cairo, font.handle);
}

static void setCairoFont(org.eclipse.swt.internal.gtk.OS.cairo_t* cairo, PangoFontDescription* font) {
    auto family = OS.pango_font_description_get_family(font);
    auto len = /*OS.*/strlen(family);
    auto buffer = new char[len + 1];
    OS.memmove(buffer.ptr, family, len);
    //TODO - convert font height from pango to cairo
    double height = OS.PANGO_PIXELS(OS.pango_font_description_get_size(font)) * 96 / 72;
    int pangoStyle = OS.pango_font_description_get_style(font);
    int pangoWeight = OS.pango_font_description_get_weight(font);
    int slant = Cairo.CAIRO_FONT_SLANT_NORMAL;
    if (pangoStyle is OS.PANGO_STYLE_ITALIC) slant = Cairo.CAIRO_FONT_SLANT_ITALIC;
    if (pangoStyle is OS.PANGO_STYLE_OBLIQUE) slant = Cairo.CAIRO_FONT_SLANT_OBLIQUE;
    int weight = Cairo.CAIRO_FONT_WEIGHT_NORMAL;
    if (pangoWeight is OS.PANGO_WEIGHT_BOLD) weight = Cairo.CAIRO_FONT_WEIGHT_BOLD;
    Cairo.cairo_select_font_face(cairo, buffer.ptr, slant, weight);
    Cairo.cairo_set_font_size(cairo, height);
}

static void setCairoClip(org.eclipse.swt.internal.gtk.OS.cairo_t* cairo, GdkRegion* clipRgn) {
    Cairo.cairo_reset_clip(cairo);
    if (clipRgn is null) return;
    if (OS.GTK_VERSION >= OS.buildVERSION(2, 8, 0)) {
        OS.gdk_cairo_region(cairo, clipRgn);
    } else {
        int nRects;
        GdkRectangle * rects;
        OS.gdk_region_get_rectangles(clipRgn, &rects, &nRects);
        //GdkRectangle* rect = new GdkRectangle();
        for (int i=0; i<nRects; i++) {
            Cairo.cairo_rectangle(cairo, rects[i].x, rects[i].y, rects[i].width, rects[i].height);
        }
        if (rects !is null) OS.g_free(rects);
    }
    Cairo.cairo_clip(cairo);
}

static void setCairoPatternColor( org.eclipse.swt.internal.gtk.OS.cairo_pattern_t* pattern, int offset, Color c, int alpha) {
    GdkColor* color = c.handle;
    double aa = (alpha & 0xFF) / cast(double)0xFF;
    double red = ((color.red & 0xFFFF) / cast(double)0xFFFF);
    double green = ((color.green & 0xFFFF) / cast(double)0xFFFF);
    double blue = ((color.blue & 0xFFFF) / cast(double)0xFFFF);
    Cairo.cairo_pattern_add_color_stop_rgba(pattern, offset, red, green, blue, aa);
}

void setClipping(GdkRegion* clipRgn) {
    auto cairo = data.cairo;
    if (clipRgn is null) {
        if (data.clipRgn !is null) {
            OS.gdk_region_destroy(data.clipRgn);
            data.clipRgn = null;
        }
        if (cairo !is null) {
            data.clippingTransform = null;
            setCairoClip(cairo, clipRgn);
        } else {
            auto clipping = data.damageRgn !is null ? data.damageRgn : null;
            OS.gdk_gc_set_clip_region(handle, clipping);
        }
    } else {
        if (data.clipRgn is null) data.clipRgn = OS.gdk_region_new();
        OS.gdk_region_subtract(data.clipRgn, data.clipRgn);
        OS.gdk_region_union(data.clipRgn, clipRgn);
        if (cairo !is null) {
            if (data.clippingTransform is null) data.clippingTransform = new double[6];
            Cairo.cairo_get_matrix(cairo,cast(cairo_matrix_t *) data.clippingTransform.ptr);
            setCairoClip(cairo, clipRgn);
        } else {
            auto clipping = clipRgn;
            if (data.damageRgn !is null) {
                clipping = OS.gdk_region_new();
                OS.gdk_region_union(clipping, clipRgn);
                OS.gdk_region_intersect(clipping, data.damageRgn);
            }
            OS.gdk_gc_set_clip_region(handle, clipping);
            if (clipping !is clipRgn) OS.gdk_region_destroy(clipping);
        }
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
public void setClipping(int x, int y, int width, int height) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (width < 0) {
        x = x + width;
        width = -width;
    }
    if (height < 0) {
        y = y + height;
        height = -height;
    }
    GdkRectangle rect;
    rect.x = x;
    rect.y = y;
    rect.width = width;
    rect.height = height;
    auto clipRgn = OS.gdk_region_new();
    OS.gdk_region_union_with_rect(clipRgn, &rect);
    setClipping(clipRgn);
    OS.gdk_region_destroy(clipRgn);
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
public void setClipping(Path path) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (path !is null && path.isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    setClipping(cast(GdkRegion*)null);
    if (path !is null) {
        initCairo();
        auto cairo = data.cairo;
        auto copy = Cairo.cairo_copy_path(path.handle);
        if (copy is null) SWT.error(SWT.ERROR_NO_HANDLES);
        Cairo.cairo_append_path(cairo, copy);
        Cairo.cairo_path_destroy(copy);
        Cairo.cairo_clip(cairo);
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
public void setClipping(Rectangle rect) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (rect is null) {
        setClipping(cast(GdkRegion*)null);
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
public void setClipping(Region region) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (region !is null && region.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    setClipping(region !is null ? region.handle : cast(GdkRegion*)null);
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
public void setFont(Font font) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (font !is null && font.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    data.font = font !is null ? font : data.device.systemFont;
    data.state &= ~FONT;
    data.stringWidth = data.stringHeight = -1;
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
    int cairo_mode = Cairo.CAIRO_FILL_RULE_EVEN_ODD;
    switch (rule) {
        case SWT.FILL_WINDING:
            cairo_mode = Cairo.CAIRO_FILL_RULE_WINDING; break;
        case SWT.FILL_EVEN_ODD:
            cairo_mode = Cairo.CAIRO_FILL_RULE_EVEN_ODD; break;
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    //TODO - need fill rule in X, GDK has no API
    initCairo();
    auto cairo = data.cairo;
    if (cairo !is null) {
        Cairo.cairo_set_fill_rule(cairo, cairo_mode);
    }
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
public void setForeground(Color color) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (color is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (color.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    data.foreground = color.handle;
    data.foregroundPattern = null;
    data.state &= ~FOREGROUND;
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
public void setForegroundPattern(Pattern pattern) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (pattern !is null && pattern.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (data.cairo is null && pattern is null) return;
    initCairo();
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
    if (data.cairo is null && interpolation is SWT.DEFAULT) return;
    switch (interpolation) {
        case SWT.DEFAULT:
        case SWT.NONE:
        case SWT.LOW:
        case SWT.HIGH:
            break;
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    initCairo();
    data.interpolation = interpolation;
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
    initCairo();
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

void setString(String str, int flags) {
    if (data.layout is null) createLayout();
    if (str is data.str && (flags & ~SWT.DRAW_TRANSPARENT) is (data.drawFlags  & ~SWT.DRAW_TRANSPARENT)) {
        return;
    }
    char[] buffer;
    size_t mnemonic, len = str.length ;
    auto layout = data.layout;
    char[] text = str.dup;
    if ((flags & SWT.DRAW_MNEMONIC) !is 0 && (mnemonic = fixMnemonic(text)) !is -1) {
        char[] text1 = new char[mnemonic - 1];
        System.arraycopy(text, 0, text1, 0, text1.length);
        char[] buffer1 = text1.dup;
        char[] text2 = new char[text.length - mnemonic];
        System.arraycopy(text, mnemonic - 1, text2, 0, text2.length);
        char[] buffer2 = text2.dup;
        buffer = new char[buffer1.length + buffer2.length];
        System.arraycopy(buffer1, 0, buffer, 0, buffer1.length);
        System.arraycopy(buffer2, 0, buffer, buffer1.length, buffer2.length);
        auto attr_list = OS.pango_attr_list_new();
        auto attr = OS.pango_attr_underline_new(OS.PANGO_UNDERLINE_LOW);
        attr.start_index = cast(int)/*64bit*/buffer1.length;
        attr.end_index = cast(int)/*64bit*/buffer1.length + 1;
        OS.pango_attr_list_insert(attr_list, attr);
        OS.pango_layout_set_attributes(layout, attr_list);
        OS.pango_attr_list_unref(attr_list);
    } else {
        buffer = text.dup;
        OS.pango_layout_set_attributes(layout, null);
    }
    OS.pango_layout_set_text(layout, buffer.ptr, cast(int)/*64bit*/buffer.length);
    OS.pango_layout_set_single_paragraph_mode(layout, (flags & SWT.DRAW_DELIMITER) is 0);
    OS.pango_layout_set_tabs(layout, (flags & SWT.DRAW_TAB) !is 0 ? null : data.device.emptyTab);
    data.str = str;
    data.stringWidth = data.stringHeight = -1;
    data.drawFlags = flags;
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
    if (data.cairo is null && antialias is SWT.DEFAULT) return;
    int mode = 0;
    switch (antialias) {
        case SWT.DEFAULT: mode = Cairo.CAIRO_ANTIALIAS_DEFAULT; break;
        case SWT.OFF: mode = Cairo.CAIRO_ANTIALIAS_NONE; break;
        case SWT.ON: mode = Cairo.CAIRO_ANTIALIAS_GRAY;
            break;
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    initCairo();
    auto options = Cairo.cairo_font_options_create();
    Cairo.cairo_font_options_set_antialias(options, mode);
    if (OS.GTK_VERSION < OS.buildVERSION(2, 8, 0)) {
        Cairo.cairo_set_font_options(data.cairo, options);
    } else {
        if (data.context is null) createLayout();
        OS.pango_cairo_context_set_font_options(data.context, options);
    }
    Cairo.cairo_font_options_destroy(options);
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
    if (data.cairo is null && transform is null) return;
    initCairo();
    auto cairo = data.cairo;
    double[] identity = identity();
    if (transform !is null) {
        Cairo.cairo_matrix_multiply(cast(cairo_matrix_t*)identity.ptr, cast(cairo_matrix_t*)transform.handle.ptr, cast(cairo_matrix_t*)identity.ptr);
    }
    Cairo.cairo_set_matrix(cairo, cast(cairo_matrix_t*)identity.ptr);
    data.state &= ~DRAW_OFFSET;
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
    OS.gdk_gc_set_function(handle, xor ? OS.GDK_XOR : OS.GDK_COPY);
    data.xorMode = xor;
}

/**
 * Returns the extent of the given str. No tab
 * expansion or carriage return processing will be performed.
 * <p>
 * The <em>extent</em> of a str is the width and height of
 * the rectangular area it would cover if drawn in a particular
 * font (in this case, the current font in the receiver).
 * </p>
 *
 * @param str the str to measure
 * @return a point containing the extent of the str
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Point stringExtent(String str) {
    return textExtent(str, 0);
}

/**
 * Returns the extent of the given str. Tab expansion and
 * carriage return processing are performed.
 * <p>
 * The <em>extent</em> of a str is the width and height of
 * the rectangular area it would cover if drawn in a particular
 * font (in this case, the current font in the receiver).
 * </p>
 *
 * @param str the str to measure
 * @return a point containing the extent of the str
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Point textExtent(String str) {
    return textExtent(str, SWT.DRAW_DELIMITER | SWT.DRAW_TAB);
}

/**
 * Returns the extent of the given str. Tab expansion, line
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
 * The <em>extent</em> of a str is the width and height of
 * the rectangular area it would cover if drawn in a particular
 * font (in this case, the current font in the receiver).
 * </p>
 *
 * @param str the str to measure
 * @param flags the flags specifying how to process the text
 * @return a point containing the extent of the str
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Point textExtent(String str, int flags) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    //DWT_CHANGE: allow null for string
    //if (str is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    auto cairo = data.cairo;
    if (cairo !is null) {
        if (OS.GTK_VERSION < OS.buildVERSION(2, 8, 0)) {
            //TODO - honor flags
            checkGC(FONT);
            char* buffer = toStringz(str);
            cairo_font_extents_t* font_extents = new cairo_font_extents_t();
            Cairo.cairo_font_extents(cairo, font_extents);
            cairo_text_extents_t* extents = new cairo_text_extents_t();
            Cairo.cairo_text_extents(cairo, buffer, extents);
            return new Point(cast(int)extents.width, cast(int)font_extents.height);
        }
    }
    setString(str, flags);
    checkGC(FONT);
    if (data.stringWidth !is -1) return new Point(data.stringWidth, data.stringHeight);
    int width, height;
    OS.pango_layout_get_size(data.layout, &width, &height);
    return new Point(data.stringWidth = OS.PANGO_PIXELS(width), data.stringHeight = OS.PANGO_PIXELS(height));
}

/**
 * Returns a str containing a concise, human-readable
 * description of the receiver.
 *
 * @return a str representation of the receiver
 */
public override String toString () {
    if (isDisposed()) return "GC {*DISPOSED*}";
    return Format( "GC {{{}}", handle );
}

}


