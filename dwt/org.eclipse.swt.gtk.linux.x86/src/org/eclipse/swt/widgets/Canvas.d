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
module org.eclipse.swt.widgets.Canvas;

import java.lang.all;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Caret;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.IME;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Font;

/**
 * Instances of this class provide a surface for drawing
 * arbitrary graphics.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * This class may be subclassed by custom control implementors
 * who are building controls that are <em>not</em> constructed
 * from aggregates of other controls. That is, they are either
 * painted using SWT graphics calls or are handled by native
 * methods.
 * </p>
 *
 * @see Composite
 * @see <a href="http://www.eclipse.org/swt/snippets/#canvas">Canvas snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Canvas : Composite {

    alias Composite.setBounds setBounds;

    Caret caret;
    IME ime;

this () {}

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
 * </ul>
 *
 * @see SWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

/**
 * Fills the interior of the rectangle specified by the arguments,
 * with the receiver's background.
 *
 * @param gc the gc where the rectangle is to be filled
 * @param x the x coordinate of the rectangle to be filled
 * @param y the y coordinate of the rectangle to be filled
 * @param width the width of the rectangle to be filled
 * @param height the height of the rectangle to be filled
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the gc is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the gc has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
override public void drawBackground (GC gc, int x, int y, int width, int height) {
    checkWidget ();
    if (gc is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
    super.drawBackground (gc, x, y, width, height);
}

/**
 * Returns the caret.
 * <p>
 * The caret for the control is automatically hidden
 * and shown when the control is painted or resized,
 * when focus is gained or lost and when an the control
 * is scrolled.  To avoid drawing on top of the caret,
 * the programmer must hide and show the caret when
 * drawing in the window any other time.
 * </p>
 *
 * @return the caret for the receiver, may be null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Caret getCaret () {
    checkWidget();
    return caret;
}

override Point getIMCaretPos () {
    if (caret is null) return super.getIMCaretPos ();
    return new Point (caret.x, caret.y);
}

/**
 * Returns the IME.
 *
 * @return the IME
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.4
 */
public IME getIME () {
    checkWidget ();
    return ime;
}

override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* event) {
    if (ime !is null) {
        auto result = ime.gtk_button_press_event (widget, event);
        if (result !is 0) return result;
    }
    return  super.gtk_button_press_event (widget, event);
}

override int gtk_commit (GtkIMContext* imcontext, char* text) {
    if (ime !is null) {
        auto result = ime.gtk_commit (imcontext, text);
        if (result !is 0) return result;
    }
    return super.gtk_commit (imcontext, text);
}

override int gtk_expose_event (GtkWidget* widget, GdkEventExpose* event) {
    if ((state & OBSCURED) !is 0) return 0;
    bool isFocus = caret !is null && caret.isFocusCaret ();
    if (isFocus) caret.killFocus ();
    auto result = super.gtk_expose_event (widget, event);
    if (isFocus) caret.setFocus ();
    return result;
}

override int gtk_focus_in_event (GtkWidget* widget, GdkEventFocus* event) {
    auto result = super.gtk_focus_in_event (widget, event);
    if (caret !is null) caret.setFocus ();
    return result;
}

override int gtk_focus_out_event (GtkWidget* widget, GdkEventFocus* event) {
    auto result = super.gtk_focus_out_event (widget, event);
    if (caret !is null) caret.killFocus ();
    return result;
}

override int gtk_preedit_changed (GtkIMContext* imcontext) {
    if (ime !is null) {
        auto result = ime.gtk_preedit_changed (imcontext);
        if (result !is 0) return result;
    }
    return super.gtk_preedit_changed (imcontext);
}

override void redrawWidget (int x, int y, int width, int height, bool redrawAll, bool all, bool trim) {
    bool isFocus = caret !is null && caret.isFocusCaret ();
    if (isFocus) caret.killFocus ();
    super.redrawWidget (x, y, width, height, redrawAll, all, trim);
    if (isFocus) caret.setFocus ();
}

override void releaseChildren (bool destroy) {
    if (caret !is null) {
        caret.release (false);
        caret = null;
    }
    if (ime !is null) {
        ime.release (false);
        ime = null;
    }
    super.releaseChildren (destroy);
}

/**
 * Scrolls a rectangular area of the receiver by first copying
 * the source area to the destination and then causing the area
 * of the source which is not covered by the destination to
 * be repainted. Children that intersect the rectangle are
 * optionally moved during the operation. In addition, outstanding
 * paint events are flushed before the source area is copied to
 * ensure that the contents of the canvas are drawn correctly.
 *
 * @param destX the x coordinate of the destination
 * @param destY the y coordinate of the destination
 * @param x the x coordinate of the source
 * @param y the y coordinate of the source
 * @param width the width of the area
 * @param height the height of the area
 * @param all <code>true</code>if children should be scrolled, and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void scroll (int destX, int destY, int x, int y, int width, int height, bool all) {
    checkWidget();
    if (width <= 0 || height <= 0) return;
    if ((style & SWT.MIRRORED) !is 0) {
        int clientWidth = getClientWidth ();
        x = clientWidth - width - x;
        destX = clientWidth - width - destX;
    }
    int deltaX = destX - x, deltaY = destY - y;
    if (deltaX is 0 && deltaY is 0) return;
    if (!isVisible ()) return;
    bool isFocus = caret !is null && caret.isFocusCaret ();
    if (isFocus) caret.killFocus ();
    auto window = paintWindow ();
    auto visibleRegion = OS.gdk_drawable_get_visible_region (window);
    GdkRectangle* srcRect = new GdkRectangle ();
    srcRect.x = x;
    srcRect.y = y;
    srcRect.width = width;
    srcRect.height = height;
    auto copyRegion = OS.gdk_region_rectangle (srcRect);
    OS.gdk_region_intersect(copyRegion, visibleRegion);
    auto invalidateRegion = OS.gdk_region_rectangle (srcRect);
    OS.gdk_region_subtract (invalidateRegion, visibleRegion);
    OS.gdk_region_offset (invalidateRegion, deltaX, deltaY);
    GdkRectangle* copyRect = new GdkRectangle();
    OS.gdk_region_get_clipbox (copyRegion, copyRect);
    if (copyRect.width !is 0 && copyRect.height !is 0) {
        update ();
    }
    Control control = findBackgroundControl ();
    if (control is null) control = this;
    if (control.backgroundImage !is null) {
        redrawWidget (x, y, width, height, false, false, false);
        redrawWidget (destX, destY, width, height, false, false, false);
    } else {
//      GC gc = new GC (this);
//      gc.copyArea (x, y, width, height, destX, destY);
//      gc.dispose ();
        auto gdkGC = OS.gdk_gc_new (window);
        OS.gdk_gc_set_exposures (gdkGC, true);
        OS.gdk_draw_drawable (window, gdkGC, window, copyRect.x, copyRect.y, copyRect.x + deltaX, copyRect.y + deltaY, copyRect.width, copyRect.height);
        OS.g_object_unref (gdkGC);
        bool disjoint = (destX + width < x) || (x + width < destX) || (destY + height < y) || (y + height < destY);
        if (disjoint) {
            GdkRectangle* rect = new GdkRectangle ();
            rect.x = x;
            rect.y = y;
            rect.width = width;
            rect.height = height;
            OS.gdk_region_union_with_rect (invalidateRegion, rect);
        } else {
            GdkRectangle* rect = new GdkRectangle ();
            if (deltaX !is 0) {
                int newX = destX - deltaX;
                if (deltaX < 0) newX = destX + width;
                rect.x = newX;
                rect.y = y;
                rect.width = Math.abs(deltaX);
                rect.height = height;
                OS.gdk_region_union_with_rect (invalidateRegion, rect);
            }
            if (deltaY !is 0) {
                int newY = destY - deltaY;
                if (deltaY < 0) newY = destY + height;
                rect.x = x;
                rect.y = newY;
                rect.width = width;
                rect.height = Math.abs(deltaY);
                OS.gdk_region_union_with_rect (invalidateRegion, rect);
            }
        }
        OS.gdk_window_invalidate_region(window, invalidateRegion, all);
        OS.gdk_region_destroy (visibleRegion);
        OS.gdk_region_destroy (copyRegion);
        OS.gdk_region_destroy (invalidateRegion);
    }
    if (all) {
        Control [] children = _getChildren ();
        for (int i=0; i<children.length; i++) {
            Control child = children [i];
            Rectangle rect = child.getBounds ();
            if (Math.min(x + width, rect.x + rect.width) >= Math.max (x, rect.x) &&
                Math.min(y + height, rect.y + rect.height) >= Math.max (y, rect.y)) {
                    child.setLocation (rect.x + deltaX, rect.y + deltaY);
            }
        }
    }
    if (isFocus) caret.setFocus ();
}

override int setBounds (int x, int y, int width, int height, bool move, bool resize) {
    bool isFocus = caret !is null && caret.isFocusCaret ();
    if (isFocus) caret.killFocus ();
    int result = super.setBounds (x, y, width, height, move, resize);
    if (isFocus) caret.setFocus ();
    return result;
}

/**
 * Sets the receiver's caret.
 * <p>
 * The caret for the control is automatically hidden
 * and shown when the control is painted or resized,
 * when focus is gained or lost and when an the control
 * is scrolled.  To avoid drawing on top of the caret,
 * the programmer must hide and show the caret when
 * drawing in the window any other time.
 * </p>
 * @param caret the new caret for the receiver, may be null
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the caret has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setCaret (Caret caret) {
    checkWidget();
    Caret newCaret = caret;
    Caret oldCaret = this.caret;
    this.caret = newCaret;
    if (hasFocus ()) {
        if (oldCaret !is null) oldCaret.killFocus ();
        if (newCaret !is null) {
            if (newCaret.isDisposed()) error(SWT.ERROR_INVALID_ARGUMENT);
            newCaret.setFocus ();
        }
    }
}

override public void setFont (Font font) {
    checkWidget();
    if (caret !is null) caret.setFont (font);
    super.setFont (font);
}

/**
 * Sets the receiver's IME.
 * 
 * @param ime the new IME for the receiver, may be null
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the IME has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.4
 */
public void setIME (IME ime) {
    checkWidget ();
    if (ime !is null && ime.isDisposed()) error(SWT.ERROR_INVALID_ARGUMENT);
    this.ime = ime;
}

void updateCaret () {
    auto imHandle = imHandle ();
    if (imHandle is null) return;
    GdkRectangle* rect = new GdkRectangle ();
    rect.x = caret.x;
    rect.y = caret.y;
    rect.width = caret.width;
    rect.height = caret.height;
    OS.gtk_im_context_set_cursor_location (imHandle, rect);
}

}
