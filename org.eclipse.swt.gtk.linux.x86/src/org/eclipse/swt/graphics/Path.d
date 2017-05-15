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
module org.eclipse.swt.graphics.Path;

import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.Compatibility;
import org.eclipse.swt.internal.cairo.Cairo : Cairo;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.Resource;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.PathData;
import java.lang.all;

version(Tango){
    import tango.stdc.string;
} else {
    import core.stdc.string;
}

/**
 * Instances of this class represent paths through the two-dimensional
 * coordinate system. Paths do not have to be continuous, and can be
 * described using lines, rectangles, arcs, cubic or quadratic bezier curves,
 * glyphs, or other paths.
 * <p>
 * Application code must explicitly invoke the <code>Path.dispose()</code>
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
public class Path : Resource {
    alias Resource.init_ init_;
    /**
     * the OS resource for the Path
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public org.eclipse.swt.internal.gtk.OS.cairo_t* handle;

    bool moved, closed = true;

/**
 * Constructs a new empty Path.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 *
 * @param device the device on which to allocate the path
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the device is null and there is no current device</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle for the path could not be obtained</li>
 * </ul>
 *
 * @see #dispose()
 */
public this (Device device) {
    super(device);
    this.device.checkCairo();
    auto surface = Cairo.cairo_image_surface_create(Cairo.CAIRO_FORMAT_ARGB32, 1, 1);
    if (surface is null) SWT.error(SWT.ERROR_NO_HANDLES);
    handle = Cairo.cairo_create(surface);
    Cairo.cairo_surface_destroy(surface);
    if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
    init_();
}

/**
 * Constructs a new Path that is a copy of <code>path</code>. If
 * <code>flatness</code> is less than or equal to zero, an unflatten
 * copy of the path is created. Otherwise, it specifies the maximum
 * error between the path and its flatten copy. Smaller numbers give
 * better approximation.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 * 
 * @param device the device on which to allocate the path
 * @param path the path to make a copy
 * @param flatness the flatness value
 * 
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the path is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the path has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle for the path could not be obtained</li>
 * </ul>
 * 
 * @see #dispose()
 * @since 3.4
 */
public this (Device device, Path path, float flatness) {
    super(device);
    if (path is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (path.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    auto surface = Cairo.cairo_image_surface_create(Cairo.CAIRO_FORMAT_ARGB32, 1, 1);
    if (surface is null) SWT.error(SWT.ERROR_NO_HANDLES);
    handle = Cairo.cairo_create(surface);
    Cairo.cairo_surface_destroy(surface);
    if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
    cairo_path_t* copy;
    flatness = Math.max(0, flatness);
    if (flatness is 0) {
        copy = Cairo.cairo_copy_path(path.handle);
    } else {
        double tolerance = Cairo.cairo_get_tolerance(path.handle);
        Cairo.cairo_set_tolerance(path.handle, flatness);
        copy = Cairo.cairo_copy_path_flat(path.handle);
        Cairo.cairo_set_tolerance(path.handle, tolerance);
    }
    if (copy is null) {
        Cairo.cairo_destroy(handle);
        SWT.error(SWT.ERROR_NO_HANDLES);
    }
    Cairo.cairo_append_path(handle, copy);
    Cairo.cairo_path_destroy(copy);
    init_();
}

/**
 * Constructs a new Path with the specifed PathData.
 * <p>
 * This operation requires the operating system's advanced
 * graphics subsystem which may not be available on some
 * platforms.
 * </p>
 * 
 * @param device the device on which to allocate the path
 * @param data the data for the path
 * 
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the data is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_NO_GRAPHICS_LIBRARY - if advanced graphics are not available</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle for the path could not be obtained</li>
 * </ul>
 * 
 * @see #dispose()
 * @since 3.4
 */
public this (Device device, PathData data) {
    this(device);
    if (data is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    init_(data);
}

/**
 * Adds to the receiver a circular or elliptical arc that lies within
 * the specified rectangular area.
 * <p>
 * The resulting arc begins at <code>startAngle</code> and extends
 * for <code>arcAngle</code> degrees.
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
 * @param x the x coordinate of the upper-left corner of the arc
 * @param y the y coordinate of the upper-left corner of the arc
 * @param width the width of the arc
 * @param height the height of the arc
 * @param startAngle the beginning angle
 * @param arcAngle the angular extent of the arc, relative to the start angle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void addArc(float x, float y, float width, float height, float startAngle, float arcAngle) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    moved = true;
    if (width is height) {
        float angle = -startAngle * cast(float)Compatibility.PI / 180;
        if (closed) Cairo.cairo_move_to(handle, (x + width / 2f) + width / 2f * Math.cos(angle), (y + height / 2f) + height / 2f * Math.sin(angle));
        if (arcAngle >= 0) {
            Cairo.cairo_arc_negative(handle, x + width / 2f, y + height / 2f, width / 2f, angle, -(startAngle + arcAngle) * cast(float)Compatibility.PI / 180);
        } else {
            Cairo.cairo_arc(handle, x + width / 2f, y + height / 2f, width / 2f, angle, -(startAngle + arcAngle) * cast(float)Compatibility.PI / 180);
        }
    } else {
        Cairo.cairo_save(handle);
        Cairo.cairo_translate(handle, x + width / 2f, y + height / 2f);
        Cairo.cairo_scale(handle, width / 2f, height / 2f);
        float angle = -startAngle * cast(float)Compatibility.PI / 180;
        if (closed) Cairo.cairo_move_to(handle, Math.cos(angle), Math.sin(angle));
        if (arcAngle >= 0) {
            Cairo.cairo_arc_negative(handle, 0, 0, 1, angle, -(startAngle + arcAngle) * cast(float)Compatibility.PI / 180);
        } else {
            Cairo.cairo_arc(handle, 0, 0, 1, angle, -(startAngle + arcAngle) * cast(float)Compatibility.PI / 180);
        }
        Cairo.cairo_restore(handle);
    }
    closed = false;
    if (Math.abs(arcAngle) >= 360) close();
}

/**
 * Adds to the receiver the path described by the parameter.
 *
 * @param path the path to add to the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parameter is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void addPath(Path path) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (path is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (path.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    moved = false;
    auto copy = Cairo.cairo_copy_path(path.handle);
    if (copy is null) SWT.error(SWT.ERROR_NO_HANDLES);
    Cairo.cairo_append_path(handle, copy);
    Cairo.cairo_path_destroy(copy);
    closed = path.closed;
}

/**
 * Adds to the receiver the rectangle specified by x, y, width and height.
 *
 * @param x the x coordinate of the rectangle to add
 * @param y the y coordinate of the rectangle to add
 * @param width the width of the rectangle to add
 * @param height the height of the rectangle to add
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void addRectangle(float x, float y, float width, float height) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    moved = false;
    Cairo.cairo_rectangle(handle, x, y, width, height);
    closed = true;
}

/**
 * Adds to the receiver the pattern of glyphs generated by drawing
 * the given string using the given font starting at the point (x, y).
 *
 * @param string the text to use
 * @param x the x coordinate of the starting point
 * @param y the y coordinate of the starting point
 * @param font the font to use
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the font is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the font has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void addString(String str, float x, float y, Font font) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (font is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (font.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    moved = false;
    GC.addCairoString(handle, str, x, y, font);
    closed = true;
}

/**
 * Closes the current sub path by adding to the receiver a line
 * from the current point of the path back to the starting point
 * of the sub path.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void close() {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    Cairo.cairo_close_path(handle);
    moved = false;
    closed = true;
}

/**
 * Returns <code>true</code> if the specified point is contained by
 * the receiver and false otherwise.
 * <p>
 * If outline is <code>true</code>, the point (x, y) checked for containment in
 * the receiver's outline. If outline is <code>false</code>, the point is
 * checked to see if it is contained within the bounds of the (closed) area
 * covered by the receiver.
 *
 * @param x the x coordinate of the point to test for containment
 * @param y the y coordinate of the point to test for containment
 * @param gc the GC to use when testing for containment
 * @param outline controls whether to check the outline or contained area of the path
 * @return <code>true</code> if the path contains the point and <code>false</code> otherwise
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the gc is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the gc has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public bool contains(float x, float y, GC gc, bool outline) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (gc is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    //TODO - see Windows
    gc.initCairo();
    gc.checkGC(GC.LINE_CAP | GC.LINE_JOIN | GC.LINE_STYLE | GC.LINE_WIDTH);
    bool result = false;
    auto cairo = gc.data.cairo;
    auto copy = Cairo.cairo_copy_path(handle);
    if (copy is null) SWT.error(SWT.ERROR_NO_HANDLES);
    Cairo.cairo_append_path(cairo, copy);
    Cairo.cairo_path_destroy(copy);
    if (outline) {
        result = Cairo.cairo_in_stroke(cairo, x, y) !is 0;
    } else {
        result = Cairo.cairo_in_fill(cairo, x, y) !is 0;
    }
    Cairo.cairo_new_path(cairo);
    return result;
}

/**
 * Adds to the receiver a cubic bezier curve based on the parameters.
 *
 * @param cx1 the x coordinate of the first control point of the spline
 * @param cy1 the y coordinate of the first control of the spline
 * @param cx2 the x coordinate of the second control of the spline
 * @param cy2 the y coordinate of the second control of the spline
 * @param x the x coordinate of the end point of the spline
 * @param y the y coordinate of the end point of the spline
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void cubicTo(float cx1, float cy1, float cx2, float cy2, float x, float y) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (!moved) {
        double currentX = 0, currentY = 0;
        Cairo.cairo_get_current_point(handle, &currentX, &currentY);
        Cairo.cairo_move_to(handle, currentX, currentY);
        moved = true;
    }
    Cairo.cairo_curve_to(handle, cx1, cy1, cx2, cy2, x, y);
    closed = false;
}

/**
 * Replaces the first four elements in the parameter with values that
 * describe the smallest rectangle that will completely contain the
 * receiver (i.e. the bounding box).
 *
 * @param bounds the array to hold the result
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parameter is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter is too small to hold the bounding box</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void getBounds(float[] bounds) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (bounds is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (bounds.length < 4) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    auto copy = Cairo.cairo_copy_path(handle);
    if (copy is null) SWT.error(SWT.ERROR_NO_HANDLES);
    cairo_path_t* path = new cairo_path_t();
    memmove(path, copy, cairo_path_t.sizeof);
    double minX = 0, minY = 0, maxX = 0, maxY = 0;
    if (path.num_data > 0) {
        minX = minY = double.max;
        maxX = maxY = -double.max;
        int i = 0;
        cairo_path_data_t* data = new cairo_path_data_t();
        while (i < path.num_data) {
            *data = path.data[i];
            switch (data.header.type) {
                case Cairo.CAIRO_PATH_MOVE_TO:
                    minX = Math.min(minX, path.data[i+1].point.x);
                    minY = Math.min(minY, path.data[i+1].point.y);
                    maxX = Math.max(maxX, path.data[i+1].point.x);
                    maxY = Math.max(maxY, path.data[i+1].point.y);
                    break;
                case Cairo.CAIRO_PATH_LINE_TO:
                    minX = Math.min(minX, path.data[i+1].point.x);
                    minY = Math.min(minY, path.data[i+1].point.y);
                    maxX = Math.max(maxX, path.data[i+1].point.x);
                    maxY = Math.max(maxY, path.data[i+1].point.y);
                    break;
                case Cairo.CAIRO_PATH_CURVE_TO:
                    minX = Math.min(minX, path.data[i+1].point.x);
                    minY = Math.min(minY, path.data[i+1].point.y);
                    maxX = Math.max(maxX, path.data[i+1].point.x);
                    maxY = Math.max(maxY, path.data[i+1].point.y);
                    minX = Math.min(minX, path.data[i+2].point.x);
                    minY = Math.min(minY, path.data[i+2].point.y);
                    maxX = Math.max(maxX, path.data[i+2].point.x);
                    maxY = Math.max(maxY, path.data[i+2].point.y);
                    minX = Math.min(minX, path.data[i+3].point.x);
                    minY = Math.min(minY, path.data[i+3].point.y);
                    maxX = Math.max(maxX, path.data[i+3].point.x);
                    maxY = Math.max(maxY, path.data[i+3].point.y);
                    break;
                case Cairo.CAIRO_PATH_CLOSE_PATH: break;
                default:
            }
            i += data.header.length;
        }
    }
    bounds[0] = cast(float)minX;
    bounds[1] = cast(float)minY;
    bounds[2] = cast(float)(maxX - minX);
    bounds[3] = cast(float)(maxY - minY);
    Cairo.cairo_path_destroy(copy);
}

/**
 * Replaces the first two elements in the parameter with values that
 * describe the current point of the path.
 *
 * @param point the array to hold the result
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parameter is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parameter is too small to hold the end point</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void getCurrentPoint(float[] point) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (point is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (point.length < 2) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    double x = 0, y = 0;
    Cairo.cairo_get_current_point(handle, &x, &y);
    point[0] = cast(float)x;
    point[1] = cast(float)y;
}

/**
 * Returns a device independent representation of the receiver.
 *
 * @return the PathData for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see PathData
 */
public PathData getPathData() {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    auto copy = Cairo.cairo_copy_path(handle);
    if (copy is null) SWT.error(SWT.ERROR_NO_HANDLES);
    cairo_path_t* path = new cairo_path_t();
    *path = *copy;
    byte[] types = new byte[path.num_data];
    float[] pts = new float[path.num_data * 6];
    int typeIndex = 0, ptsIndex = 0;
    if (path.num_data > 0) {
        int i = 0;
        double[] points = new double[6];
        cairo_path_data_t* data = new cairo_path_data_t();
        while (i < path.num_data) {
            switch (data.header.type) {
                case Cairo.CAIRO_PATH_MOVE_TO:
                    types[typeIndex++] = SWT.PATH_MOVE_TO;
                    pts[ptsIndex++] = cast(float)path.data[i+1].point.x;
                    pts[ptsIndex++] = cast(float)path.data[i+1].point.y;
                    break;
                case Cairo.CAIRO_PATH_LINE_TO:
                    types[typeIndex++] = SWT.PATH_LINE_TO;
                    pts[ptsIndex++] = cast(float)path.data[i+1].point.x;
                    pts[ptsIndex++] = cast(float)path.data[i+1].point.y;
                    break;
                case Cairo.CAIRO_PATH_CURVE_TO:
                    types[typeIndex++] = SWT.PATH_CUBIC_TO;
                    pts[ptsIndex++] = cast(float)path.data[i+1].point.x;
                    pts[ptsIndex++] = cast(float)path.data[i+1].point.y;
                    pts[ptsIndex++] = cast(float)path.data[i+2].point.x;
                    pts[ptsIndex++] = cast(float)path.data[i+2].point.y;
                    pts[ptsIndex++] = cast(float)path.data[i+3].point.x;
                    pts[ptsIndex++] = cast(float)path.data[i+3].point.y;
                    break;
                case Cairo.CAIRO_PATH_CLOSE_PATH:
                    types[typeIndex++] = SWT.PATH_CLOSE;
                    break;
                default:
            }
            i += data.header.length;
        }
    }
    if (typeIndex !is types.length) {
        byte[] newTypes = new byte[typeIndex];
        System.arraycopy(types, 0, newTypes, 0, typeIndex);
        types = newTypes;
    }
    if (ptsIndex !is pts.length) {
        float[] newPts = new float[ptsIndex];
        System.arraycopy(pts, 0, newPts, 0, ptsIndex);
        pts = newPts;
    }
    Cairo.cairo_path_destroy(copy);
    PathData result = new PathData();
    result.types = types;
    result.points = pts;
    return result;
}

/**
 * Adds to the receiver a line from the current point to
 * the point specified by (x, y).
 *
 * @param x the x coordinate of the end of the line to add
 * @param y the y coordinate of the end of the line to add
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void lineTo(float x, float y) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (!moved) {
        double currentX = 0, currentY = 0;
        Cairo.cairo_get_current_point(handle, &currentX, &currentY);
        Cairo.cairo_move_to(handle, currentX, currentY);
        moved = true;
    }
    Cairo.cairo_line_to(handle, x, y);
    closed = false;
}

/**
 * Sets the current point of the receiver to the point
 * specified by (x, y). Note that this starts a new
 * sub path.
 *
 * @param x the x coordinate of the new end point
 * @param y the y coordinate of the new end point
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void moveTo(float x, float y) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    /*
    * Bug in Cairo.  If cairo_move_to() is not called at the
    * begining of a subpath, the first cairo_line_to() or
    * cairo_curve_to() segment do not output anything.  The fix
    * is to detect that the app did not call cairo_move_to()
    * before those calls and call it explicitly.
    */
    moved = true;
    Cairo.cairo_move_to(handle, x, y);
    closed = true;
}

/**
 * Adds to the receiver a quadratic curve based on the parameters.
 *
 * @param cx the x coordinate of the control point of the spline
 * @param cy the y coordinate of the control point of the spline
 * @param x the x coordinate of the end point of the spline
 * @param y the y coordinate of the end point of the spline
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void quadTo(float cx, float cy, float x, float y) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    double currentX = 0, currentY = 0;
    Cairo.cairo_get_current_point(handle, &currentX, &currentY);
    if (!moved) {
        Cairo.cairo_move_to(handle, currentX, currentY);
        moved = true;
    }
    float x0 = cast(float)currentX;
    float y0 = cast(float)currentY;
    float cx1 = x0 + 2 * (cx - x0) / 3;
    float cy1 = y0 + 2 * (cy - y0) / 3;
    float cx2 = cx1 + (x - x0) / 3;
    float cy2 = cy1 + (y - y0) / 3;
    Cairo.cairo_curve_to(handle, cx1, cy1, cx2, cy2, x, y);
    closed = false;
}

override
void destroy() {
    Cairo.cairo_destroy(handle);
    handle = null;
}

void init_(PathData data) {
    byte[] types = data.types;
    float[] points = data.points;
    for (int i = 0, j = 0; i < types.length; i++) {
        switch (types[i]) {
            case SWT.PATH_MOVE_TO:
                moveTo(points[j++], points[j++]);
                break;
            case SWT.PATH_LINE_TO:
                lineTo(points[j++], points[j++]);
                break;
            case SWT.PATH_CUBIC_TO:
                cubicTo(points[j++], points[j++], points[j++], points[j++], points[j++], points[j++]);
                break;
            case SWT.PATH_QUAD_TO:
                quadTo(points[j++], points[j++], points[j++], points[j++]);
                break;
            case SWT.PATH_CLOSE:
                close();
                break;
            default:
                dispose();
                SWT.error(SWT.ERROR_INVALID_ARGUMENT);
        }
    }
}

/**
 * Returns <code>true</code> if the Path has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the Path.
 * When a Path has been disposed, it is an error to
 * invoke any other method using the Path.
 *
 * @return <code>true</code> when the Path is disposed, and <code>false</code> otherwise
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
public override String toString() {
    if (isDisposed()) return "Path {*DISPOSED*}";
    return Format( "Path {{{}}", handle );
}

}
