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
module org.eclipse.swt.widgets.Caret;

import java.lang.all;

import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.Canvas;

/**
 * Instances of this class provide an i-beam that is typically used
 * as the insertion point for text.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 * 
 * @see <a href="http://www.eclipse.org/swt/snippets/#caret">Caret snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample, Canvas tab</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Caret : Widget {
    Canvas parent;
    int x, y, width, height;
    bool isVisible_, isShowing;
    int blinkRate;
    Image image;
    Font font;

    static const int DEFAULT_WIDTH = 1;

/**
 * Constructs a new instance of this class given its parent
 * and a style value describing its behavior and appearance.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>SWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>SWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 * </p>
 *
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Canvas parent, int style) {
    super (parent, style);
    this.parent = parent;
    createWidget (0);
}

bool blinkCaret () {
    if (!isVisible_) return true;
    if (!isShowing) return showCaret ();
    if (blinkRate is 0) return true;
    return hideCaret ();
}

override void createWidget (int index) {
    super.createWidget (index);
    blinkRate = display.getCaretBlinkTime ();
    isVisible_ = true;
    if (parent.getCaret () is null) {
        parent.setCaret (this);
    }
}

bool drawCaret () {
    if (parent is null) return false;
    if (parent.isDisposed ()) return false;
    auto window = parent.paintWindow ();
    auto gc = OS.gdk_gc_new (window);
    GdkColor* color = new GdkColor ();
    color.red = 0xffff;
    color.green = 0xffff;
    color.blue = 0xffff;
    auto colormap = OS.gdk_colormap_get_system ();
    OS.gdk_colormap_alloc_color (colormap, color, true, true);
    OS.gdk_gc_set_foreground (gc, color);
    OS.gdk_gc_set_function (gc, OS.GDK_XOR);
    if (image !is null && !image.isDisposed() && image.mask is null) {
        int width; int height;
        OS.gdk_drawable_get_size(image.pixmap, &width, &height);
        int nX = x;
        if ((parent.style & SWT.MIRRORED) !is 0) nX = parent.getClientWidth () - width - nX;
        OS.gdk_draw_drawable(window, gc, image.pixmap, 0, 0, x, y, width, height);
    } else {
        int nWidth = width, nHeight = height;
        if (nWidth <= 0) nWidth = DEFAULT_WIDTH;
        int nX = x;
        if ((parent.style & SWT.MIRRORED) !is 0) nX = parent.getClientWidth () - nWidth - nX;
        OS.gdk_draw_rectangle (window, gc, 1, nX, y, nWidth, nHeight);
    }
    OS.g_object_unref (gc);
    OS.gdk_colormap_free_colors (colormap, color, 1);
    return true;
}

/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent (or its display if its parent is null).
 *
 * @return the receiver's bounding rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Rectangle getBounds () {
    checkWidget();
    if (image !is null) {
        Rectangle rect = image.getBounds ();
        return new Rectangle (x, y, rect.width, rect.height);
    } else {
        if (width is 0) {
            return new Rectangle (x, y, DEFAULT_WIDTH, height);
        }
    }
    return new Rectangle (x, y, width, height);
}

/**
 * Returns the font that the receiver will use to paint textual information.
 *
 * @return the receiver's font
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Font getFont () {
    checkWidget();
    if (font !is null) return font;
    return parent.getFont ();
}

/**
 * Returns the image that the receiver will use to paint the caret.
 *
 * @return the receiver's image
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Image getImage () {
    checkWidget();
    return image;
}

/**
 * Returns a point describing the receiver's location relative
 * to its parent (or its display if its parent is null).
 *
 * @return the receiver's location
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getLocation () {
    checkWidget();
    return new Point (x, y);
}

/**
 * Returns the receiver's parent, which must be a <code>Canvas</code>.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Canvas getParent () {
    checkWidget();
    return parent;
}

/**
 * Returns a point describing the receiver's size.
 *
 * @return the receiver's size
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getSize () {
    checkWidget();
    if (image !is null) {
        Rectangle rect = image.getBounds ();
        return new Point (rect.width, rect.height);
    } else {
        if (width is 0) {
            return new Point (DEFAULT_WIDTH, height);
        }
    }
    return new Point (width, height);
}

/**
 * Returns <code>true</code> if the receiver is visible, and
 * <code>false</code> otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, this method
 * may still indicate that it is considered visible even though
 * it may not actually be showing.
 * </p>
 *
 * @return the receiver's visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getVisible () {
    checkWidget();
    return isVisible_;
}

bool hideCaret () {
    if (!isShowing) return true;
    isShowing = false;
    return drawCaret ();
}

/**
 * Returns <code>true</code> if the receiver is visible and all
 * of the receiver's ancestors are visible and <code>false</code>
 * otherwise.
 *
 * @return the receiver's visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getVisible
 */
public bool isVisible () {
    checkWidget();
    return isVisible_ && parent.isVisible () && parent.hasFocus ();
}

bool isFocusCaret () {
    return this is display.currentCaret;
}

void killFocus () {
    if (display.currentCaret !is this) return;
    display.setCurrentCaret (null);
    if (isVisible_) hideCaret ();
}

override void releaseParent () {
    super.releaseParent ();
    if (this is parent.getCaret ()) parent.setCaret (null);
}

override void releaseWidget () {
    super.releaseWidget ();
    if (display.currentCaret is this) {
        hideCaret ();
        display.setCurrentCaret (null);
    }
    parent = null;
    image = null;
}

/**
 * Sets the receiver's size and location to the rectangular
 * area specified by the arguments. The <code>x</code> and
 * <code>y</code> arguments are relative to the receiver's
 * parent (or its display if its parent is null).
 *
 * @param x the new x coordinate for the receiver
 * @param y the new y coordinate for the receiver
 * @param width the new width for the receiver
 * @param height the new height for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setBounds (int x, int y, int width, int height) {
    checkWidget();
    if (this.x is x && this.y is y && this.width is width && this.height is height) return;
    bool isFocus = isFocusCaret ();
    if (isFocus && isVisible_) hideCaret ();
    this.x = x; this.y = y;
    this.width = width; this.height = height;
    parent.updateCaret ();
    if (isFocus && isVisible_) showCaret ();
}

/**
 * Sets the receiver's size and location to the rectangular
 * area specified by the argument. The <code>x</code> and
 * <code>y</code> fields of the rectangle are relative to
 * the receiver's parent (or its display if its parent is null).
 *
 * @param rect the new bounds for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setBounds (Rectangle rect) {
    checkWidget();
    if (rect is null) error (SWT.ERROR_NULL_ARGUMENT);
    setBounds (rect.x, rect.y, rect.width, rect.height);
}

void setFocus () {
    if (display.currentCaret is this) return;
    display.setCurrentCaret (this);
    if (isVisible_) showCaret ();
}

/**
 * Sets the font that the receiver will use to paint textual information
 * to the font specified by the argument, or to the default font for that
 * kind of control if the argument is null.
 *
 * @param font the new font (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the font has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setFont (Font font) {
    checkWidget();
    if (font !is null && font.isDisposed ()) {
        error (SWT.ERROR_INVALID_ARGUMENT);
    }
    this.font = font;
}

/**
 * Sets the image that the receiver will use to paint the caret
 * to the image specified by the argument, or to the default
 * which is a filled rectangle if the argument is null
 *
 * @param image the new image (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setImage (Image image) {
    checkWidget();
    if (image !is null && image.isDisposed ()) {
        error (SWT.ERROR_INVALID_ARGUMENT);
    }
    bool isFocus = isFocusCaret ();
    if (isFocus && isVisible_) hideCaret ();
    this.image = image;
    if (isFocus && isVisible_) showCaret ();
}

/**
 * Sets the receiver's location to the point specified by
 * the arguments which are relative to the receiver's
 * parent (or its display if its parent is null).
 *
 * @param x the new x coordinate for the receiver
 * @param y the new y coordinate for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLocation (int x, int y) {
    checkWidget();
    setBounds (x, y, width, height);
}

/**
 * Sets the receiver's location to the point specified by
 * the argument which is relative to the receiver's
 * parent (or its display if its parent is null).
 *
 * @param location the new location for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLocation (Point location) {
    checkWidget();
    if (location is null) error (SWT.ERROR_NULL_ARGUMENT);
    setLocation (location.x, location.y);
}

/**
 * Sets the receiver's size to the point specified by the arguments.
 *
 * @param width the new width for the receiver
 * @param height the new height for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSize (int width, int height) {
    checkWidget();
    setBounds (x, y, width, height);
}

/**
 * Sets the receiver's size to the point specified by the argument.
 *
 * @param size the new extent for the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSize (Point size) {
    checkWidget();
    if (size is null) error (SWT.ERROR_NULL_ARGUMENT);
    setSize (size.x, size.y);
}

/**
 * Marks the receiver as visible if the argument is <code>true</code>,
 * and marks it invisible otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, marking
 * it visible may not actually cause it to be displayed.
 * </p>
 *
 * @param visible the new visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setVisible (bool visible) {
    checkWidget();
    if (visible is isVisible_) return;
    isVisible_ = visible;
    if (!isFocusCaret ()) return;
    if (isVisible_) {
        showCaret ();
    } else {
        hideCaret ();
    }
}

bool showCaret () {
    if (isShowing) return true;
    isShowing = true;
    return drawCaret ();
}

}
