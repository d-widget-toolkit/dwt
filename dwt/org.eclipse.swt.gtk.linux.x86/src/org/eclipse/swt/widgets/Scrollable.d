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
module org.eclipse.swt.widgets.Scrollable;

import java.lang.all;

import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.ScrollBar;
import org.eclipse.swt.widgets.Widget;

version(Tango){
import tango.stdc.string;
} else { // Phobos
}

/**
 * This class is the abstract superclass of all classes which
 * represent controls that have standard scroll bars.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>H_SCROLL, V_SCROLL</dd>
 * <dt><b>Events:</b>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public abstract class Scrollable : Control {
    GtkWidget* scrolledHandle;
    ScrollBar horizontalBar, verticalBar;

/**
 * Prevents uninitialized instances from being created outside the package.
 */
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
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#H_SCROLL
 * @see SWT#V_SCROLL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, style);
}

GtkWidget* clientHandle () {
    return handle;
}

/**
 * Given a desired <em>client area</em> for the receiver
 * (as described by the arguments), returns the bounding
 * rectangle which would be required to produce that client
 * area.
 * <p>
 * In other words, it returns a rectangle such that, if the
 * receiver's bounds were set to that rectangle, the area
 * of the receiver which is capable of displaying data
 * (that is, not covered by the "trimmings") would be the
 * rectangle described by the arguments (relative to the
 * receiver's parent).
 * </p>
 *
 * @param x the desired x coordinate of the client area
 * @param y the desired y coordinate of the client area
 * @param width the desired width of the client area
 * @param height the desired height of the client area
 * @return the required bounds to produce the given client area
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getClientArea
 */
public Rectangle computeTrim (int x, int y, int width, int height) {
    checkWidget();
    int border = 0;
    if (fixedHandle !is null) border += OS.gtk_container_get_border_width (cast(GtkContainer*)fixedHandle);
    if (scrolledHandle !is null) border += OS.gtk_container_get_border_width (cast(GtkContainer*)scrolledHandle);
    int trimX = x - border, trimY = y - border;
    int trimWidth = width + (border * 2), trimHeight = height + (border * 2);
    trimHeight += hScrollBarWidth ();
    trimWidth  += vScrollBarWidth ();
    if (scrolledHandle !is null) {
        if (OS.gtk_scrolled_window_get_shadow_type (cast(GtkScrolledWindow*)scrolledHandle) !is OS.GTK_SHADOW_NONE) {
            auto style = OS.gtk_widget_get_style (cast(GtkWidget*)scrolledHandle);
            int xthickness = OS.gtk_style_get_xthickness (style);
            int ythickness = OS.gtk_style_get_ythickness (style);
            trimX -= xthickness;
            trimY -= ythickness;
            trimWidth += xthickness * 2;
            trimHeight += ythickness * 2;
        }
    }
    return new Rectangle (trimX, trimY, trimWidth, trimHeight);
}

ScrollBar createScrollBar (int style) {
    if (scrolledHandle is null) return null;
    ScrollBar bar = new ScrollBar ();
    bar.parent = this;
    bar.style = style;
    bar.display = display;
    bar.state |= HANDLE;
    if ((style & SWT.H_SCROLL) !is 0) {
        bar.handle = OS.GTK_SCROLLED_WINDOW_HSCROLLBAR (cast(GtkScrolledWindow*)scrolledHandle);
        bar.adjustmentHandle = OS.gtk_scrolled_window_get_hadjustment (cast(GtkScrolledWindow*)scrolledHandle);
    } else {
        bar.handle = OS.GTK_SCROLLED_WINDOW_VSCROLLBAR (cast(GtkScrolledWindow*)scrolledHandle);
        bar.adjustmentHandle = OS.gtk_scrolled_window_get_vadjustment (cast(GtkScrolledWindow*)scrolledHandle);
    }
    bar.setOrientation();
    bar.hookEvents ();
    bar.register ();
    return bar;
}

override void createWidget (int index) {
    super.createWidget (index);
    if ((style & SWT.H_SCROLL) !is 0) horizontalBar = createScrollBar (SWT.H_SCROLL);
    if ((style & SWT.V_SCROLL) !is 0) verticalBar = createScrollBar (SWT.V_SCROLL);
}

override void deregister () {
    super.deregister ();
    if (scrolledHandle !is null) display.removeWidget (cast(GtkWidget*)scrolledHandle);
}

void destroyScrollBar (ScrollBar bar) {
    setScrollBarVisible (bar, false);
    //This code is intentionally commented
    //bar.destroyHandle ();
}

public override int getBorderWidth () {
    checkWidget();
    int border = 0;
    if (fixedHandle !is null) border += OS.gtk_container_get_border_width (cast(GtkContainer*)fixedHandle);
    if (scrolledHandle !is null) {
        border += OS.gtk_container_get_border_width (cast(GtkContainer*)scrolledHandle);
        if (OS.gtk_scrolled_window_get_shadow_type (cast(GtkScrolledWindow*)scrolledHandle) !is OS.GTK_SHADOW_NONE) {
            border += OS.gtk_style_get_xthickness (OS.gtk_widget_get_style (cast(GtkWidget*)scrolledHandle));
        }
    }
    return border;
}

/**
 * Returns a rectangle which describes the area of the
 * receiver which is capable of displaying data (that is,
 * not covered by the "trimmings").
 *
 * @return the client area
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #computeTrim
 */
public Rectangle getClientArea () {
    checkWidget ();
    forceResize ();
    auto clientHandle = clientHandle ();
    int x = OS.GTK_WIDGET_X (clientHandle);
    int y = OS.GTK_WIDGET_Y (clientHandle);
    int width = (state & ZERO_WIDTH) !is 0 ? 0 : OS.GTK_WIDGET_WIDTH (clientHandle);
    int height = (state & ZERO_HEIGHT) !is 0 ? 0 : OS.GTK_WIDGET_HEIGHT (clientHandle);
    return new Rectangle (x, y, width, height);
}
/**
 * Returns the receiver's horizontal scroll bar if it has
 * one, and null if it does not.
 *
 * @return the horizontal scroll bar (or null)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public ScrollBar getHorizontalBar () {
    checkWidget ();
    return horizontalBar;
}
/**
 * Returns the receiver's vertical scroll bar if it has
 * one, and null if it does not.
 *
 * @return the vertical scroll bar (or null)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public ScrollBar getVerticalBar () {
    checkWidget ();
    return verticalBar;
}

override int gtk_scroll_event (GtkWidget* widget, GdkEventScroll* eventPtr) {
    auto result = super.gtk_scroll_event (widget, eventPtr);

    /*
    * Feature in GTK.  Scrolled windows do not scroll if the scrollbars
    * are hidden.  This is not a bug, but is inconsistent with other platforms.
    * The fix is to set the adjustment values directly.
    */
    if ((state & CANVAS) !is 0) {
        ScrollBar scrollBar;
        GdkEventScroll* gdkEvent = new GdkEventScroll ();
        OS.memmove (gdkEvent, eventPtr, GdkEventScroll.sizeof);
        if (gdkEvent.direction is OS.GDK_SCROLL_UP || gdkEvent.direction is OS.GDK_SCROLL_DOWN) {
            scrollBar = verticalBar;
        } else {
            scrollBar = horizontalBar;
        }
        if (scrollBar !is null && !OS.GTK_WIDGET_VISIBLE (scrollBar.handle) && scrollBar.getEnabled()) {
            GtkAdjustment* adjustment = scrollBar.adjustmentHandle;
            /* Calculate wheel delta to match GTK+ 2.4 and higher */
            int wheel_delta = cast(int) Math.pow(adjustment.page_size, 2.0 / 3.0);
            if (gdkEvent.direction is OS.GDK_SCROLL_UP || gdkEvent.direction is OS.GDK_SCROLL_LEFT)
                wheel_delta = -wheel_delta;
            int value = cast(int) Math.max(adjustment.lower,
                    Math.min(adjustment.upper - adjustment.page_size, adjustment.value + wheel_delta));
            OS.gtk_adjustment_set_value (scrollBar.adjustmentHandle, value);
            return 1;
        }
    }
    return result;
}

int hScrollBarWidth() {
    if (horizontalBar is null) return 0;
    auto hBarHandle = OS.GTK_SCROLLED_WINDOW_HSCROLLBAR(cast(GtkScrolledWindow*)scrolledHandle);
    if (hBarHandle is null) return 0;
    GtkRequisition requisition;
    OS.gtk_widget_size_request(cast(GtkWidget*)hBarHandle, &requisition);
    int spacing = OS.GTK_SCROLLED_WINDOW_SCROLLBAR_SPACING(cast(GtkScrolledWindow*)scrolledHandle);
    return requisition.height + spacing;
}

override bool sendLeaveNotify () {
    return scrolledHandle !is null;
}

override void setOrientation () {
    super.setOrientation ();
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        if (scrolledHandle !is null) {
            OS.gtk_widget_set_direction (cast(GtkWidget*)scrolledHandle, OS.GTK_TEXT_DIR_RTL);
        }
    }
}

bool setScrollBarVisible (ScrollBar bar, bool visible) {
    if (scrolledHandle is null) return false;
    int hsp, vsp;
    OS.gtk_scrolled_window_get_policy (cast(GtkScrolledWindow*)scrolledHandle, &hsp, &vsp);
    int policy = visible ? OS.GTK_POLICY_ALWAYS : OS.GTK_POLICY_NEVER;
    if ((bar.style & SWT.HORIZONTAL) !is 0) {
        if (hsp is policy) return false;
        hsp = policy;
    } else {
        if (vsp is policy) return false;
        vsp = policy;
    }
    OS.gtk_scrolled_window_set_policy (cast(GtkScrolledWindow*)scrolledHandle, hsp, vsp);
    return true;
}

void redrawBackgroundImage () {
}

override void redrawWidget (int x, int y, int width, int height, bool redrawAll, bool all, bool trim) {
    super.redrawWidget (x, y, width, height, redrawAll, all, trim);
    if ((OS.GTK_WIDGET_FLAGS (handle) & OS.GTK_REALIZED) is 0) return;
    if (!trim) return;
    auto topHandle_ = topHandle (), paintHandle_ = paintHandle ();
    if (topHandle_ is paintHandle_) return;
    auto window = OS.GTK_WIDGET_WINDOW (topHandle_);
    GdkRectangle* rect = new GdkRectangle ();
    if (redrawAll) {
        rect.width = OS.GTK_WIDGET_WIDTH (topHandle_);
        rect.height = OS.GTK_WIDGET_HEIGHT (topHandle_);
    } else {
        int destX, destY;
        OS.gtk_widget_translate_coordinates (cast(GtkWidget*)paintHandle_, topHandle_, x, y, &destX, &destY);
        rect.x = destX;
        rect.y = destY;
        rect.width = width;
        rect.height = height;
    }
    OS.gdk_window_invalidate_rect (window, rect, all);
}

override void register () {
    super.register ();
    if (scrolledHandle !is null) display.addWidget (cast(GtkWidget*)scrolledHandle, this);
}

override void releaseHandle () {
    super.releaseHandle ();
    scrolledHandle = null;
}

override void releaseChildren (bool destroy) {
    if (horizontalBar !is null) {
        horizontalBar.release (false);
        horizontalBar = null;
    }
    if (verticalBar !is null) {
        verticalBar.release (false);
        verticalBar = null;
    }
    super.releaseChildren (destroy);
}

override void resizeHandle (int width, int height) {
    if (fixedHandle !is null) OS.gtk_widget_set_size_request (cast(GtkWidget*)fixedHandle, width, height);
    OS.gtk_widget_set_size_request (scrolledHandle !is null ? cast(GtkWidget*)scrolledHandle : handle, width, height);
}

override void showWidget () {
    super.showWidget ();
    if (scrolledHandle !is null) OS.gtk_widget_show (cast(GtkWidget*)scrolledHandle);
}

override GtkWidget* topHandle () {
    if (fixedHandle !is null) return fixedHandle;
    if (scrolledHandle !is null) return scrolledHandle;
    return super.topHandle ();
}

void updateScrollBarValue (ScrollBar bar) {
    redrawBackgroundImage ();
}

int vScrollBarWidth() {
    if (verticalBar is null) return 0;
    auto vBarHandle = OS.GTK_SCROLLED_WINDOW_VSCROLLBAR(cast(GtkScrolledWindow*)scrolledHandle);
    if (vBarHandle is null) return 0;
    GtkRequisition requisition;
    OS.gtk_widget_size_request (cast(GtkWidget*)vBarHandle, &requisition);
    int spacing = OS.GTK_SCROLLED_WINDOW_SCROLLBAR_SPACING(cast(GtkScrolledWindow*)scrolledHandle);
    return requisition.width + spacing;
}
}
