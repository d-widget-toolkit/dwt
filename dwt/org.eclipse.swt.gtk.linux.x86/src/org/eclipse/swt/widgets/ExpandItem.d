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
module org.eclipse.swt.widgets.ExpandItem;

import java.lang.all;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.ExpandBar;
import org.eclipse.swt.widgets.ImageList;
import org.eclipse.swt.widgets.Event;


/**
 * Instances of this class represent a selectable user interface object
 * that represents a expandable item in a expand bar.
 * <p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see ExpandBar
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.2
 */
public class ExpandItem : Item {

    alias Item.setForegroundColor setForegroundColor;
    alias Item.windowProc windowProc;

    ExpandBar parent;
    Control control;
    ImageList imageList;
    GtkWidget* clientHandle, boxHandle, labelHandle, imageHandle;
    bool expanded;
    int x, y, width, height;
    int imageHeight, imageWidth;
    static const int TEXT_INSET = 6;
    static const int BORDER = 1;
    static const int CHEVRON_SIZE = 24;

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
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (ExpandBar parent, int style) {
    super (parent, style);
    this.parent = parent;
    createWidget (parent.getItemCount ());
}

/**
 * Constructs a new instance of this class given its parent, a
 * style value describing its behavior and appearance, and the index
 * at which to place it in the items maintained by its parent.
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
 * @param index the zero-relative index to store the receiver in its parent
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the parent (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (ExpandBar parent, int style, int index) {
    super (parent, style);
    this.parent = parent;
    createWidget (index);
}

protected override void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

override void createHandle (int index) {
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        state |= HANDLE;
        handle = OS.gtk_expander_new (null);
        if (handle is null) error (SWT.ERROR_NO_HANDLES);
        clientHandle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
        if (clientHandle is null) error (SWT.ERROR_NO_HANDLES);
        OS.gtk_container_add (handle, clientHandle);
        boxHandle = cast(GtkWidget*)OS.gtk_hbox_new (false, 4);
        if (boxHandle is null) error (SWT.ERROR_NO_HANDLES);
        labelHandle = cast(GtkWidget*)OS.gtk_label_new (null);
        if (labelHandle is null) error (SWT.ERROR_NO_HANDLES);
        imageHandle = cast(GtkWidget*)OS.gtk_image_new ();
        if (imageHandle is null) error (SWT.ERROR_NO_HANDLES);
        OS.gtk_container_add (boxHandle, imageHandle);
        OS.gtk_container_add (boxHandle, labelHandle);
        OS.gtk_expander_set_label_widget (handle, boxHandle);
        OS.GTK_WIDGET_SET_FLAGS (handle, OS.GTK_CAN_FOCUS);
    }
}

override void createWidget (int index) {
    super.createWidget (index);
    showWidget (index);
    parent.createItem (this, style, index);
}

override void deregister() {
    super.deregister();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        display.removeWidget (clientHandle);
        display.removeWidget (boxHandle);
        display.removeWidget (labelHandle);
        display.removeWidget (imageHandle);
    }
}

override void destroyWidget () {
    parent.destroyItem (this);
    super.destroyWidget ();
}

void drawChevron (GC gc, int x, int y) {
    int [] polyline1, polyline2;
    if (expanded) {
        int px = x + 4 + 5;
        int py = y + 4 + 7;
        polyline1 = [
                px,py, px+1,py, px+1,py-1, px+2,py-1, px+2,py-2, px+3,py-2, px+3,py-3,
                px+3,py-2, px+4,py-2, px+4,py-1, px+5,py-1, px+5,py, px+6,py];
        py += 4;
        polyline2 = [
                px,py, px+1,py, px+1,py-1, px+2,py-1, px+2,py-2, px+3,py-2, px+3,py-3,
                px+3,py-2, px+4,py-2, px+4,py-1,  px+5,py-1, px+5,py, px+6,py];
    } else {
        int px = x + 4 + 5;
        int py = y + 4 + 4;
        polyline1 = [
                px,py, px+1,py, px+1,py+1, px+2,py+1, px+2,py+2, px+3,py+2, px+3,py+3,
                px+3,py+2, px+4,py+2, px+4,py+1,  px+5,py+1, px+5,py, px+6,py];
        py += 4;
        polyline2 = [
                px,py, px+1,py, px+1,py+1, px+2,py+1, px+2,py+2, px+3,py+2, px+3,py+3,
                px+3,py+2, px+4,py+2, px+4,py+1,  px+5,py+1, px+5,py, px+6,py];
    }
    gc.setForeground (display.getSystemColor (SWT.COLOR_TITLE_FOREGROUND));
    gc.drawPolyline (polyline1);
    gc.drawPolyline (polyline2);
}

void drawItem (GC gc, bool drawFocus) {
    int headerHeight = parent.getBandHeight ();
    Display display = getDisplay ();
    gc.setForeground (display.getSystemColor (SWT.COLOR_TITLE_BACKGROUND));
    gc.setBackground (display.getSystemColor (SWT.COLOR_TITLE_BACKGROUND_GRADIENT));
    gc.fillGradientRectangle (x, y, width, headerHeight, true);
    if (expanded) {
        gc.setForeground (display.getSystemColor (SWT.COLOR_TITLE_BACKGROUND_GRADIENT));
        gc.drawLine (x, y + headerHeight, x, y + headerHeight + height - 1);
        gc.drawLine (x, y + headerHeight + height - 1, x + width - 1, y + headerHeight + height - 1);
        gc.drawLine (x + width - 1, y + headerHeight + height - 1, x + width - 1, y + headerHeight);
    }
    int drawX = x;
    if (image !is null) {
        drawX += ExpandItem.TEXT_INSET;
        if (imageHeight > headerHeight) {
            gc.drawImage (image, drawX, y + headerHeight - imageHeight);
        } else {
            gc.drawImage (image, drawX, y + (headerHeight - imageHeight) / 2);
        }
        drawX += imageWidth;
    }
    if (text.length > 0) {
        drawX += ExpandItem.TEXT_INSET;
        Point size = gc.stringExtent (text);
        gc.setForeground (parent.getForeground ());
        gc.drawString (text, drawX, y + (headerHeight - size.y) / 2, true);
    }
    int chevronSize = ExpandItem.CHEVRON_SIZE;
    drawChevron (gc, x + width - chevronSize, y + (headerHeight - chevronSize) / 2);
    if (drawFocus) {
        gc.drawFocus (x + 1, y + 1, width - 2, headerHeight - 2);
    }
}

/**
 * Returns the control that is shown when the item is expanded.
 * If no control has been set, return <code>null</code>.
 *
 * @return the control
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Control getControl () {
    checkWidget ();
    return control;
}

/**
 * Returns <code>true</code> if the receiver is expanded,
 * and false otherwise.
 *
 * @return the expanded state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getExpanded () {
    checkWidget ();
    return expanded;
}

/**
 * Returns the height of the receiver's header
 *
 * @return the height of the header
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getHeaderHeight () {
    checkWidget ();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        return OS.GTK_WIDGET_HEIGHT (handle) - (expanded ? height : 0);
    }
    return Math.max (parent.getBandHeight (), imageHeight);
}

/**
 * Gets the height of the receiver.
 *
 * @return the height
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getHeight () {
    checkWidget ();
    return height;
}

/**
 * Returns the receiver's parent, which must be a <code>ExpandBar</code>.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public ExpandBar getParent () {
    checkWidget();
    return parent;
}

int getPreferredWidth (GC gc) {
    int width = ExpandItem.TEXT_INSET * 2 + ExpandItem.CHEVRON_SIZE;
    if (image !is null) {
        width += ExpandItem.TEXT_INSET + imageWidth;
    }
    if (text.length > 0) {
        width += gc.stringExtent (text).x;
    }
    return width;
}

override int gtk_activate (GtkWidget* widget) {
    Event event = new Event ();
    event.item = this;
    int type = OS.gtk_expander_get_expanded (handle) ? SWT.Collapse : SWT.Expand;
    parent.sendEvent (type, event);
    return 0;
}

override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* event) {
    setFocus ();
    return 0;
}

override int gtk_focus_out_event (GtkWidget* widget, GdkEventFocus* event) {
    OS.GTK_WIDGET_UNSET_FLAGS (handle, OS.GTK_CAN_FOCUS);
    parent.lastFocus = this;
    return 0;
}

override int gtk_size_allocate (GtkWidget* widget, ptrdiff_t allocation) {
    parent.layoutItems (0, false);
    return 0;
}

override int gtk_enter_notify_event (GtkWidget* widget, GdkEventCrossing* event) {
    parent.gtk_enter_notify_event(widget, event);
    return 0;
}

bool hasFocus () {
    return OS.GTK_WIDGET_HAS_FOCUS (handle);
}

override void hookEvents () {
    super.hookEvents ();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        OS.g_signal_connect_closure (handle, OS.activate.ptr, display.closures [ACTIVATE], false);
        OS.g_signal_connect_closure (handle, OS.activate.ptr, display.closures [ACTIVATE_INVERSE], true);
        OS.g_signal_connect_closure_by_id (handle, display.signalIds [BUTTON_PRESS_EVENT], 0, display.closures [BUTTON_PRESS_EVENT], false);
        OS.g_signal_connect_closure_by_id (handle, display.signalIds [FOCUS_OUT_EVENT], 0, display.closures [FOCUS_OUT_EVENT], false);
        OS.g_signal_connect_closure (clientHandle, OS.size_allocate.ptr, display.closures [SIZE_ALLOCATE], true);
        OS.g_signal_connect_closure_by_id (handle, display.signalIds [ENTER_NOTIFY_EVENT], 0, display.closures [ENTER_NOTIFY_EVENT], false);
    }
}

void redraw () {
    if (OS.GTK_VERSION < OS.buildVERSION (2, 4, 0)) {
        int headerHeight = parent.getBandHeight ();
        if (imageHeight > headerHeight) {
            parent.redraw (x + ExpandItem.TEXT_INSET, y + headerHeight - imageHeight, imageWidth, imageHeight, false);
        }
        parent.redraw (x, y, width, headerHeight + height, false);
    }
}

override void register () {
    super.register ();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        display.addWidget (clientHandle, this);
        display.addWidget (boxHandle, this);
        display.addWidget (labelHandle, this);
        display.addWidget (imageHandle, this);
    }
}

override void releaseHandle () {
    super.releaseHandle ();
    clientHandle = boxHandle = labelHandle = imageHandle = null;
    parent = null;
}

override void releaseWidget () {
    super.releaseWidget ();
    if (imageList !is null) imageList.dispose ();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        if (parent.lastFocus is this) parent.lastFocus = null;
    }
    imageList = null;
    control = null;
}

void resizeControl (int yScroll) {
    if (control !is null && !control.isDisposed ()) {
        bool visible =cast(bool) OS.gtk_expander_get_expanded (handle);
        if (visible) {
            int x = OS.GTK_WIDGET_X (clientHandle);
            int y = OS.GTK_WIDGET_Y (clientHandle);
            if (x !is -1 && y !is -1) {
                int width = OS.GTK_WIDGET_WIDTH (clientHandle);
                int height = OS.GTK_WIDGET_HEIGHT (clientHandle);
                int property;
                OS.gtk_widget_style_get1 (handle, OS.focus_line_width.ptr, &property);
                y += property * 2;
                height -= property * 2;
                control.setBounds (x, y - yScroll, width, Math.max (0, height), true, true);
            }
        }
        control.setVisible (visible);
    }
}

void setBounds (int x, int y, int width, int height, bool move, bool size) {
    redraw ();
    int headerHeight = parent.getBandHeight ();
    if (move) {
        if (imageHeight > headerHeight) {
            y += (imageHeight - headerHeight);
        }
        this.x = x;
        this.y = y;
        redraw ();
    }
    if (size) {
        this.width = width;
        this.height = height;
        redraw ();
    }
    if (control !is null && !control.isDisposed ()) {
        if (move) control.setLocation (x + BORDER, y + headerHeight);
        if (size) control.setSize (Math.max (0, width - 2 * BORDER), Math.max (0, height - BORDER));
    }
}

/**
 * Sets the control that is shown when the item is expanded.
 *
 * @param control the new control (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the control has been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if the control is not in the same widget tree</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setControl (Control control) {
    checkWidget ();
    if (control !is null) {
        if (control.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
        if (control.parent !is parent) error (SWT.ERROR_INVALID_PARENT);
    }
    if (this.control is control) return;
    this.control = control;
    if (control !is null) {
        control.setVisible (expanded);
        if (OS.GTK_VERSION < OS.buildVERSION (2, 4, 0)) {
            int headerHeight = parent.getBandHeight ();
            control.setBounds (x + BORDER, y + headerHeight, Math.max (0, width - 2 * BORDER), Math.max (0, height - BORDER));
        }
    }
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        parent.layoutItems (0, true);
    }
}

/**
 * Sets the expanded state of the receiver.
 *
 * @param expanded the new expanded state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setExpanded (bool expanded) {
    checkWidget ();
    this.expanded = expanded;
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        OS.gtk_expander_set_expanded (handle, expanded);
        parent.layoutItems (0, true);
    } else {
        parent.showItem (this);
    }
}

bool setFocus () {
    if (!OS.gtk_widget_get_child_visible (handle)) return false;
    OS.GTK_WIDGET_SET_FLAGS (handle, OS.GTK_CAN_FOCUS);
    OS.gtk_widget_grab_focus (handle);
    bool result = cast(bool)OS.gtk_widget_is_focus (handle);
    if (!result) OS.GTK_WIDGET_UNSET_FLAGS (handle, OS.GTK_CAN_FOCUS);
    return result;
}

void setFontDescription (PangoFontDescription* font) {
    OS.gtk_widget_modify_font (handle, font);
    if (labelHandle !is null) OS.gtk_widget_modify_font (labelHandle, font);
    if (imageHandle !is null) OS.gtk_widget_modify_font (imageHandle, font);
}

alias Item.setForegroundColor setForegroundColor;
void setForegroundColor (GdkColor* color) {
    setForegroundColor (handle, color);
    if (labelHandle !is null) setForegroundColor (labelHandle, color);
    if (imageHandle !is null) setForegroundColor (imageHandle, color);
}

/**
 * Sets the height of the receiver. This is height of the item when it is expanded,
 * excluding the height of the header.
 *
 * @param height the new height
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setHeight (int height) {
    checkWidget ();
    if (height < 0) return;
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        this.height = height;
        OS.gtk_widget_set_size_request (clientHandle, -1, height);
        parent.layoutItems (0, false);
    } else {
        setBounds (0, 0, width, height, false, true);
        if (expanded) parent.layoutItems (parent.indexOf (this) + 1, true);
    }
}

public override void setImage (Image image) {
    super.setImage (image);
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        if (imageList !is null) imageList.dispose ();
        imageList = null;
        if (image !is null) {
            if (image.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
            imageList = new ImageList ();
            int imageIndex = imageList.add (image);
            auto pixbuf = imageList.getPixbuf (imageIndex);
            OS.gtk_image_set_from_pixbuf (imageHandle, pixbuf);
            if (text.length is 0) OS.gtk_widget_hide (labelHandle);
            OS.gtk_widget_show (imageHandle);
        } else {
            OS.gtk_image_set_from_pixbuf (imageHandle, null);
            OS.gtk_widget_show (labelHandle);
            OS.gtk_widget_hide (imageHandle);
        }
    } else {
        int oldImageHeight = imageHeight;
        if (image !is null) {
            Rectangle bounds = image.getBounds ();
            imageHeight = bounds.height;
            imageWidth = bounds.width;
        } else {
            imageHeight = imageWidth = 0;
        }
        if (oldImageHeight !is imageHeight) {
            parent.layoutItems (parent.indexOf (this), true);
        } else {
            redraw ();
        }
    }
}

override
void setOrientation() {
    super.setOrientation ();
    if ((parent.style & SWT.RIGHT_TO_LEFT) !is 0) {
        OS.gtk_widget_set_direction (handle, OS.GTK_TEXT_DIR_RTL);
        display.doSetDirectionProc(handle, OS.GTK_TEXT_DIR_RTL);
    }
}

public override void setText (String string) {
    super.setText (string);
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        OS.gtk_label_set_text (labelHandle, toStringz(string));
    } else {
        redraw ();
    }
}

void showWidget (int index) {
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        OS.gtk_widget_show (handle);
        OS.gtk_widget_show (clientHandle);
        OS.gtk_container_add (parent.handle, handle);
        OS.gtk_box_set_child_packing (parent.handle, handle, false, false, 0, OS.GTK_PACK_START);
        if (boxHandle !is null) OS.gtk_widget_show (boxHandle);
        if (labelHandle !is null) OS.gtk_widget_show (labelHandle);
    }
}

override int windowProc (GtkWidget* handle, ptrdiff_t user_data) {
    switch (user_data) {
        case ACTIVATE_INVERSE: {
            expanded = cast(bool)OS.gtk_expander_get_expanded (handle);
            parent.layoutItems (0, false);
            return 0;
        }
        default:
    }
    return super.windowProc (handle, user_data);
}
}
