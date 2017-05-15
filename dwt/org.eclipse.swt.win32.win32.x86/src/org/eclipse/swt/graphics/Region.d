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
module org.eclipse.swt.graphics.Region;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.graphics.Resource;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Device;

import java.lang.all;

/**
 * Instances of this class represent areas of an x-y coordinate
 * system that are aggregates of the areas covered by a number
 * of polygons.
 * <p>
 * Application code must explicitly invoke the <code>Region.dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required.
 * </p>
 * 
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: GraphicsExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public final class Region : Resource {
    alias Resource.init_ init_;

    /**
     * the OS resource for the region
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public HRGN handle;

/**
 * Constructs a new empty region.
 *
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for region creation</li>
 * </ul>
 */
public this () {
    this(null);
}

/**
 * Constructs a new empty region.
 * <p>
 * You must dispose the region when it is no longer required.
 * </p>
 *
 * @param device the device on which to allocate the region
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for region creation</li>
 * </ul>
 *
 * @see #dispose
 *
 * @since 3.0
 */
public this (Device device) {
    super(device);
    handle = OS.CreateRectRgn (0, 0, 0, 0);
    if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
    init_();
}

/**
 * Constructs a new region given a handle to the operating
 * system resources that it should represent.
 *
 * @param handle the handle for the result
 */
this(Device device, HRGN handle) {
    super(device);
    this.handle = handle;
}

/**
 * Adds the given polygon to the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param pointArray points that describe the polygon to merge with the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
*
 */
public void add (int[] pointArray) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (pointArray is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
    auto polyRgn = OS.CreatePolygonRgn(cast(POINT*)pointArray.ptr, cast(int)/*64bit*/pointArray.length / 2, OS.ALTERNATE);
    OS.CombineRgn (handle, handle, polyRgn, OS.RGN_OR);
    OS.DeleteObject (polyRgn);
}

/**
 * Adds the given rectangle to the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param rect the rectangle to merge with the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the rectangle's width or height is negative</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void add (Rectangle rect) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (rect is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    add (rect.x, rect.y, rect.width, rect.height);
}

/**
 * Adds the given rectangle to the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param x the x coordinate of the rectangle
 * @param y the y coordinate of the rectangle
 * @param width the width coordinate of the rectangle
 * @param height the height coordinate of the rectangle
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the rectangle's width or height is negative</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void add (int x, int y, int width, int height) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (width < 0 || height < 0) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    auto rectRgn = OS.CreateRectRgn (x, y, x + width, y + height);
    OS.CombineRgn (handle, handle, rectRgn, OS.RGN_OR);
    OS.DeleteObject (rectRgn);
}

/**
 * Adds all of the polygons which make up the area covered
 * by the argument to the collection of polygons the receiver
 * maintains to describe its area.
 *
 * @param region the region to merge
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void add (Region region) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (region is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (region.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    OS.CombineRgn (handle, handle, region.handle, OS.RGN_OR);
}

/**
 * Returns <code>true</code> if the point specified by the
 * arguments is inside the area specified by the receiver,
 * and <code>false</code> otherwise.
 *
 * @param x the x coordinate of the point to test for containment
 * @param y the y coordinate of the point to test for containment
 * @return <code>true</code> if the region contains the point and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public bool contains (int x, int y) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    return cast(bool) OS.PtInRegion (handle, x, y);
}

/**
 * Returns <code>true</code> if the given point is inside the
 * area specified by the receiver, and <code>false</code>
 * otherwise.
 *
 * @param pt the point to test for containment
 * @return <code>true</code> if the region contains the point and <code>false</code> otherwise
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public bool contains (Point pt) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (pt is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    return contains(pt.x, pt.y);
}

override
void destroy () {
    OS.DeleteObject(handle);
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
override public equals_t opEquals (Object object) {
    if (this is object) return true;
    if (!(cast(Region)object)) return false;
    Region rgn = cast(Region)object;
    return handle is rgn.handle;
}

/**
 * Returns a rectangle which represents the rectangular
 * union of the collection of polygons the receiver
 * maintains to describe its area.
 *
 * @return a bounding rectangle for the region
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Rectangle#union
 */
public Rectangle getBounds() {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    RECT rect;
    OS.GetRgnBox(handle, &rect);
    return new Rectangle(rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top);
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
override public hash_t toHash () {
    return cast(hash_t)handle;
}

/**
 * Intersects the given rectangle to the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param rect the rectangle to intersect with the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the rectangle's width or height is negative</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void intersect (Rectangle rect) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (rect is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    intersect (rect.x, rect.y, rect.width, rect.height);
}

/**
 * Intersects the given rectangle to the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param x the x coordinate of the rectangle
 * @param y the y coordinate of the rectangle
 * @param width the width coordinate of the rectangle
 * @param height the height coordinate of the rectangle
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the rectangle's width or height is negative</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void intersect (int x, int y, int width, int height) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (width < 0 || height < 0) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    auto rectRgn = OS.CreateRectRgn (x, y, x + width, y + height);
    OS.CombineRgn (handle, handle, rectRgn, OS.RGN_AND);
    OS.DeleteObject (rectRgn);
}

/**
 * Intersects all of the polygons which make up the area covered
 * by the argument to the collection of polygons the receiver
 * maintains to describe its area.
 *
 * @param region the region to intersect
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void intersect (Region region) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (region is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (region.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    OS.CombineRgn (handle, handle, region.handle, OS.RGN_AND);
}

/**
 * Returns <code>true</code> if the rectangle described by the
 * arguments intersects with any of the polygons the receiver
 * maintains to describe its area, and <code>false</code> otherwise.
 *
 * @param x the x coordinate of the origin of the rectangle
 * @param y the y coordinate of the origin of the rectangle
 * @param width the width of the rectangle
 * @param height the height of the rectangle
 * @return <code>true</code> if the rectangle intersects with the receiver, and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Rectangle#intersects(Rectangle)
 */
public bool intersects (int x, int y, int width, int height) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    RECT r;
    OS.SetRect (&r, x, y, x + width, y + height);
    return cast(bool) OS.RectInRegion (handle, &r);
}

/**
 * Returns <code>true</code> if the given rectangle intersects
 * with any of the polygons the receiver maintains to describe
 * its area and <code>false</code> otherwise.
 *
 * @param rect the rectangle to test for intersection
 * @return <code>true</code> if the rectangle intersects with the receiver, and <code>false</code> otherwise
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Rectangle#intersects(Rectangle)
 */
public bool intersects (Rectangle rect) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (rect is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    return intersects(rect.x, rect.y, rect.width, rect.height);
}

/**
 * Returns <code>true</code> if the region has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the region.
 * When a region has been disposed, it is an error to
 * invoke any other method using the region.
 *
 * @return <code>true</code> when the region is disposed, and <code>false</code> otherwise
 */
override public bool isDisposed() {
    return handle is null;
}

/**
 * Returns <code>true</code> if the receiver does not cover any
 * area in the (x, y) coordinate plane, and <code>false</code> if
 * the receiver does cover some area in the plane.
 *
 * @return <code>true</code> if the receiver is empty, and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public bool isEmpty () {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    RECT rect;
    auto result = OS.GetRgnBox (handle, &rect);
    if (result is OS.NULLREGION) return true;
    return ((rect.right - rect.left) <= 0) || ((rect.bottom - rect.top) <= 0);
}

/**
 * Subtracts the given polygon from the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param pointArray points that describe the polygon to merge with the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void subtract (int[] pointArray) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (pointArray is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
    auto polyRgn = OS.CreatePolygonRgn(cast(POINT*)pointArray.ptr, cast(int)/*64bit*/pointArray.length / 2, OS.ALTERNATE);
    OS.CombineRgn (handle, handle, polyRgn, OS.RGN_DIFF);
    OS.DeleteObject (polyRgn);
}

/**
 * Subtracts the given rectangle from the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param rect the rectangle to subtract from the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the rectangle's width or height is negative</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void subtract (Rectangle rect) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (rect is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    subtract (rect.x, rect.y, rect.width, rect.height);
}

/**
 * Subtracts the given rectangle from the collection of polygons
 * the receiver maintains to describe its area.
 *
 * @param x the x coordinate of the rectangle
 * @param y the y coordinate of the rectangle
 * @param width the width coordinate of the rectangle
 * @param height the height coordinate of the rectangle
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the rectangle's width or height is negative</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void subtract (int x, int y, int width, int height) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (width < 0 || height < 0) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    auto rectRgn = OS.CreateRectRgn (x, y, x + width, y + height);
    OS.CombineRgn (handle, handle, rectRgn, OS.RGN_DIFF);
    OS.DeleteObject (rectRgn);
}

/**
 * Subtracts all of the polygons which make up the area covered
 * by the argument from the collection of polygons the receiver
 * maintains to describe its area.
 *
 * @param region the region to subtract
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void subtract (Region region) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (region is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (region.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    OS.CombineRgn (handle, handle, region.handle, OS.RGN_DIFF);
}

/**
 * Translate all of the polygons the receiver maintains to describe
 * its area by the specified point.
 *
 * @param x the x coordinate of the point to translate
 * @param y the y coordinate of the point to translate
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void translate (int x, int y) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    OS.OffsetRgn (handle, x, y);
}

/**
 * Translate all of the polygons the receiver maintains to describe
 * its area by the specified point.
 *
 * @param pt the point to translate
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the argument is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public void translate (Point pt) {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (pt is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    translate (pt.x, pt.y);
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
override public String toString () {
    if (isDisposed()) return "Region {*DISPOSED*}";
    return Format( "Region {{{}}", handle );
}

/**
 * Invokes platform specific functionality to allocate a new region.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Region</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param device the device on which to allocate the region
 * @param handle the handle for the region
 * @return a new region object containing the specified device and handle
 */
public static Region win32_new(Device device, HRGN handle) {
    auto region = new Region(device, handle);
    region.disposeChecking = false;
    return region;
}

}
