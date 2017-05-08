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
module org.eclipse.swt.widgets.ToolItem;

import java.lang.all;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.ImageList;

/**
 * Instances of this class represent a selectable user interface object
 * that represents a button in a tool bar.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>PUSH, CHECK, RADIO, SEPARATOR, DROP_DOWN</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles CHECK, PUSH, RADIO, SEPARATOR and DROP_DOWN
 * may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#toolbar">ToolBar, ToolItem snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class ToolItem : Item {

    alias Item.setForegroundColor setForegroundColor;

    GtkWidget* boxHandle, arrowHandle, arrowBoxHandle, separatorHandle, labelHandle, imageHandle;
    ToolBar parent;
    Control control;
    Image hotImage, disabledImage;
    String toolTipText;
    bool drawHotImage;

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>ToolBar</code>) and a style value
 * describing its behavior and appearance. The item is added
 * to the end of the items maintained by its parent.
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
 * @see SWT#PUSH
 * @see SWT#CHECK
 * @see SWT#RADIO
 * @see SWT#SEPARATOR
 * @see SWT#DROP_DOWN
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (ToolBar parent, int style) {
    super (parent, checkStyle (style));
    this.parent = parent;
    createWidget (parent.getItemCount ());
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>ToolBar</code>), a style value
 * describing its behavior and appearance, and the index
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
 * @see SWT#PUSH
 * @see SWT#CHECK
 * @see SWT#RADIO
 * @see SWT#SEPARATOR
 * @see SWT#DROP_DOWN
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (ToolBar parent, int style, int index) {
    super (parent, checkStyle (style));
    this.parent = parent;
    int count = parent.getItemCount ();
    if (!(0 <= index && index <= count)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    createWidget (index);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * When <code>widgetSelected</code> is called when the mouse is over the arrow portion of a drop-down tool,
 * the event object detail field contains the value <code>SWT.ARROW</code>.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
 *
 * @param listener the listener which should be notified when the control is selected by the user,
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SelectionListener
 * @see #removeSelectionListener
 * @see SelectionEvent
 */
public void addSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
}

static int checkStyle (int style) {
    return checkBits (style, SWT.PUSH, SWT.CHECK, SWT.RADIO, SWT.SEPARATOR, SWT.DROP_DOWN, 0);
}

protected override void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

override void createHandle (int index) {
    state |= HANDLE;
    if ((style & SWT.SEPARATOR) is 0) {
        boxHandle = cast(GtkWidget*)((parent.style & SWT.RIGHT) !is 0 ? OS.gtk_hbox_new (false, 0) : OS.gtk_vbox_new (false, 0));
        if (boxHandle is null) error (SWT.ERROR_NO_HANDLES);
        labelHandle = OS.gtk_label_new_with_mnemonic (null);
        if (labelHandle is null) error (SWT.ERROR_NO_HANDLES);
        imageHandle = OS.gtk_image_new ();
        if (imageHandle is null) error (SWT.ERROR_NO_HANDLES);
        OS.gtk_container_add (boxHandle, imageHandle);
        OS.gtk_container_add (boxHandle, labelHandle);
        if ((parent.style & SWT.VERTICAL) !is 0) {
            // Align text and images to the left
            OS.gtk_box_set_child_packing (boxHandle, imageHandle, false, false, 0, OS.GTK_PACK_START);
            OS.gtk_box_set_child_packing (boxHandle, labelHandle, false, false, 2, OS.GTK_PACK_START);
        }
    }
    int bits = SWT.SEPARATOR | SWT.RADIO | SWT.CHECK | SWT.PUSH | SWT.DROP_DOWN;
    switch (style & bits) {
        case SWT.SEPARATOR:
            handle = cast(GtkWidget*)OS.gtk_hbox_new (false, 0);
            if (handle is null) error (SWT.ERROR_NO_HANDLES);
            bool isVertical = (parent.style & SWT.VERTICAL) !is 0;
            separatorHandle = isVertical ? OS.gtk_hseparator_new() : OS.gtk_vseparator_new();
            if (separatorHandle is null) error (SWT.ERROR_NO_HANDLES);
            OS.gtk_widget_set_size_request (separatorHandle, isVertical ? 15 : 6, isVertical ? 6 : 15);
            OS.gtk_widget_set_size_request (handle, isVertical ? 15 : 6, isVertical ? 6 : 15);
            OS.gtk_container_add (handle, separatorHandle);
            break;
        case SWT.DROP_DOWN:
            handle = OS.gtk_button_new ();
            if (handle is null) error (SWT.ERROR_NO_HANDLES);
            arrowBoxHandle = cast(GtkWidget*)OS.gtk_hbox_new (false, 0);
            if (arrowBoxHandle is null) error(SWT.ERROR_NO_HANDLES);
            arrowHandle = OS.gtk_arrow_new (OS.GTK_ARROW_DOWN, OS.GTK_SHADOW_NONE);
            if (arrowHandle is null) error (SWT.ERROR_NO_HANDLES);
            OS.gtk_widget_set_size_request (arrowHandle, 8, 6);
            OS.gtk_container_add (handle, arrowBoxHandle);
            OS.gtk_container_add (arrowBoxHandle, boxHandle);
            OS.gtk_container_add (arrowBoxHandle, arrowHandle);
            break;
        case SWT.RADIO:
            /*
            * This code is intentionally commented.  Because GTK
            * enforces radio behavior in a button group a radio group
            * is not created for each set of contiguous buttons, each
            * radio button will not draw unpressed.  The fix is to use
            * toggle buttons instead.
            */
//          handle = OS.gtk_radio_button_new (0);
//          if (handle is 0) error (SWT.ERROR_NO_HANDLES);
//          OS.gtk_toggle_button_set_mode (handle, false);
//          OS.gtk_container_add (handle, boxHandle);
//          break;
        case SWT.CHECK:
            handle = OS.gtk_toggle_button_new ();
            if (handle is null) error (SWT.ERROR_NO_HANDLES);
            OS.gtk_toggle_button_set_mode (handle, false);
            OS.gtk_container_add (handle, boxHandle);
            break;
        case SWT.PUSH:
        default:
            handle = OS.gtk_button_new ();
            if (handle is null) error (SWT.ERROR_NO_HANDLES);
            OS.gtk_container_add (handle, boxHandle);
            break;
    }
    if ((style & SWT.SEPARATOR) is 0) {
        int relief;
        OS.gtk_widget_style_get1 (parent.handle, OS.button_relief.ptr, &relief);
        OS.gtk_button_set_relief (handle, relief );
    }
    OS.GTK_WIDGET_UNSET_FLAGS (handle, OS.GTK_CAN_FOCUS);
//  This code is intentionally commented.
//  int fontHandle = parent.fontHandle ();
//  GdkColor color = new GdkColor ();
//  int style = OS.gtk_widget_get_style (fontHandle);
//  OS.gtk_style_get_fg (style, OS.GTK_STATE_NORMAL, color);
//  int font = OS.gtk_style_get_font_desc (style);
//  setForegroundColor (color);
//  setFontDescription (font);
    if ((parent.state & FOREGROUND) !is 0) {
        setForegroundColor (parent.getForegroundColor());
    }
    if ((parent.state & FONT) !is 0) {
        setFontDescription (parent.getFontDescription());
    }
}

override void createWidget (int index) {
    super.createWidget (index);
    showWidget (index);
    parent.relayout ();
}

override void deregister() {
    super.deregister ();
    if (labelHandle !is null) display.removeWidget (labelHandle);
}

public override void dispose () {
    if (isDisposed ()) return;
    ToolBar parent = this.parent;
    super.dispose ();
    parent.relayout ();
}

/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent.
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
    parent.forceResize ();
    auto topHandle = topHandle ();
    int x, y, width, height;
    /*
    * Bug in GTK.  Toolbar items are only allocated their minimum size
    * in versions before 2.4.0.  The fix is to use the total size
    * available minus any borders.
    */
    if (OS.GTK_VERSION < OS.buildVERSION (2, 4, 0) && control !is null && !control.isDisposed ()) {
        int border = OS.gtk_container_get_border_width (parent.handle);
        int shadow;
        OS.gtk_widget_style_get1 (parent.handle, "shadow_type".ptr, &shadow);
        if (shadow !is OS.GTK_SHADOW_NONE) {
            border += OS.gtk_style_get_xthickness (OS.gtk_widget_get_style (parent.handle));
        }
        if ((parent.style & SWT.VERTICAL) !is 0) {
            x = border;
            y = OS.GTK_WIDGET_Y (topHandle) + border;
            width = OS.GTK_WIDGET_WIDTH (parent.handle) - border*2;
            height = OS.GTK_WIDGET_HEIGHT (topHandle);
        } else {
            x = OS.GTK_WIDGET_X (topHandle) + border;
            y = border;
            width = OS.GTK_WIDGET_WIDTH (topHandle);
            height = OS.GTK_WIDGET_HEIGHT (parent.handle) - border*2;
        }
    } else {
        x = OS.GTK_WIDGET_X (topHandle);
        y = OS.GTK_WIDGET_Y (topHandle);
        width = OS.GTK_WIDGET_WIDTH (topHandle);
        height = OS.GTK_WIDGET_HEIGHT (topHandle);
    }
    if ((parent.style & SWT.MIRRORED) !is 0) x = parent.getClientWidth () - width - x;
    if ((style & SWT.SEPARATOR) !is 0 && control !is null) height = Math.max (height, 23);
    return new Rectangle (x, y, width, height);
}

/**
 * Returns the control that is used to fill the bounds of
 * the item when the item is a <code>SEPARATOR</code>.
 *
 * @return the control
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Control getControl () {
    checkWidget();
    return control;
}

/**
 * Returns the receiver's disabled image if it has one, or null
 * if it does not.
 * <p>
 * The disabled image is displayed when the receiver is disabled.
 * </p>
 *
 * @return the receiver's disabled image
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Image getDisabledImage () {
    checkWidget();
    return disabledImage;
}

/**
 * Returns <code>true</code> if the receiver is enabled, and
 * <code>false</code> otherwise. A disabled control is typically
 * not selectable from the user interface and draws with an
 * inactive or "grayed" look.
 *
 * @return the receiver's enabled state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #isEnabled
 */
public bool getEnabled () {
    checkWidget();
    auto topHandle = topHandle ();
    return OS.GTK_WIDGET_SENSITIVE (topHandle);
}

/**
 * Returns the receiver's hot image if it has one, or null
 * if it does not.
 * <p>
 * The hot image is displayed when the mouse enters the receiver.
 * </p>
 *
 * @return the receiver's hot image
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Image getHotImage () {
    checkWidget();
    return hotImage;
}

/**
 * Returns the receiver's parent, which must be a <code>ToolBar</code>.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public ToolBar getParent () {
    checkWidget();
    if (parent is null) error (SWT.ERROR_WIDGET_DISPOSED);
    return parent;
}

/**
 * Returns <code>true</code> if the receiver is selected,
 * and false otherwise.
 * <p>
 * When the receiver is of type <code>CHECK</code> or <code>RADIO</code>,
 * it is selected when it is checked (which some platforms draw as a
 * pushed in button). If the receiver is of any other type, this method
 * returns false.
 * </p>
 *
 * @return the selection state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getSelection () {
    checkWidget();
    if ((style & (SWT.CHECK | SWT.RADIO)) is 0) return false;
    return cast(bool)OS.gtk_toggle_button_get_active (handle);
}

/**
 * Returns the receiver's tool tip text, or null if it has not been set.
 *
 * @return the receiver's tool tip text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getToolTipText () {
    checkWidget();
    return toolTipText;
}

/**
 * Gets the width of the receiver.
 *
 * @return the width
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getWidth () {
    checkWidget();
    parent.forceResize ();
    auto topHandle = topHandle ();
    return OS.GTK_WIDGET_WIDTH (topHandle);
}

override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* gdkEvent) {
    double x = gdkEvent.x;
    gdkEvent.x += OS.GTK_WIDGET_X (handle);
    double y = gdkEvent.y;
    gdkEvent.y += OS.GTK_WIDGET_Y (handle);
    auto result = parent.gtk_button_press_event (widget, gdkEvent);
    gdkEvent.x = x;
    gdkEvent.y = y;
    return result;
}

override int gtk_button_release_event (GtkWidget* widget, GdkEventButton* gdkEvent) {
    double x = gdkEvent.x;
    gdkEvent.x += OS.GTK_WIDGET_X (handle);
    double y = gdkEvent.y;
    gdkEvent.y += OS.GTK_WIDGET_Y (handle);
    auto result = parent.gtk_button_release_event (widget, gdkEvent);
    gdkEvent.x = x;
    gdkEvent.y = y;
    return result;
}

override int gtk_clicked (GtkWidget* widget) {
    Event event = new Event ();
    if ((style & SWT.DROP_DOWN) !is 0) {
        auto eventPtr = OS.gtk_get_current_event ();
        if (eventPtr !is null) {
            GdkEvent* gdkEvent = cast(GdkEvent*)eventPtr;
            switch (gdkEvent.type) {
                case OS.GDK_BUTTON_PRESS:
                case OS.GDK_2BUTTON_PRESS:
                case OS.GDK_BUTTON_RELEASE: {
                    double x_win = 0;
                    double y_win = 0;
                    OS.gdk_event_get_coords (eventPtr, &x_win, &y_win);
                    int x = OS.GTK_WIDGET_X (arrowHandle) - OS.GTK_WIDGET_X (handle);
                    int width = OS.GTK_WIDGET_WIDTH (arrowHandle);
                    if ((((parent.style & SWT.RIGHT_TO_LEFT) is 0) && x <= cast(int)x_win)
                        || (((parent.style & SWT.RIGHT_TO_LEFT) !is 0) && cast(int)x_win <= x + width)) {
                        event.detail = SWT.ARROW;
                        auto topHandle = topHandle ();
                        event.x = OS.GTK_WIDGET_X (topHandle);
                        if ((parent.style & SWT.MIRRORED) !is 0) event.x = parent.getClientWidth () - OS.GTK_WIDGET_WIDTH (topHandle) - event.x;
                        event.y = OS.GTK_WIDGET_Y (topHandle) + OS.GTK_WIDGET_HEIGHT (topHandle);
                    }
                    break;
                }
                default:
            }
            OS.gdk_event_free (eventPtr);
        }
    }
    if ((style & SWT.RADIO) !is 0) {
        if ((parent.getStyle () & SWT.NO_RADIO_GROUP) is 0) {
            selectRadio ();
        }
    }
    postEvent (SWT.Selection, event);
    return 0;
}

override int gtk_enter_notify_event (GtkWidget* widget, GdkEventCrossing* event) {
    parent.gtk_enter_notify_event (widget, event);
    drawHotImage = (parent.style & SWT.FLAT) !is 0 && hotImage !is null;
    if (drawHotImage && imageHandle !is null) {
        ImageList imageList = parent.imageList;
        if (imageList !is null) {
            int index = imageList.indexOf (hotImage);
            if (index !is -1) {
                auto pixbuf = imageList.getPixbuf (index);
                OS.gtk_image_set_from_pixbuf (imageHandle, pixbuf);
            }
        }
    }
    return 0;
}

override int gtk_event_after (GtkWidget* widget, GdkEvent* gdkEvent) {
    GdkEventButton* gdkEventButton = null;
    switch (gdkEvent.type) {
        case OS.GDK_BUTTON_PRESS: {
            gdkEventButton = cast(GdkEventButton*)gdkEvent;
            if (gdkEventButton.button is 3) {
                parent.showMenu (cast(int) gdkEventButton.x_root, cast(int) gdkEventButton.y_root);
            }
            break;
        default:
        }
    }
    return 0;
}

override int gtk_focus_out_event (GtkWidget* widget, GdkEventFocus* event) {
    OS.GTK_WIDGET_UNSET_FLAGS (handle, OS.GTK_CAN_FOCUS);
    parent.lastFocus = this;
    return 0;
}

override int gtk_leave_notify_event (GtkWidget* widget, GdkEventCrossing* event) {
    parent.gtk_leave_notify_event (widget, event);
    if (drawHotImage) {
        drawHotImage = false;
        if (imageHandle !is null && image !is null) {
            ImageList imageList = parent.imageList;
            if (imageList !is null) {
                int index = imageList.indexOf (image);
                if (index !is -1) {
                    auto pixbuf = imageList.getPixbuf (index);
                    OS.gtk_image_set_from_pixbuf (imageHandle, pixbuf);
                }
            }
        }
    }
    return 0;
}

override int gtk_map (GtkWidget* widget) {
    parent.fixZOrder ();
    return 0;
}

override int gtk_mnemonic_activate (GtkWidget* widget, ptrdiff_t arg1) {
    return parent.gtk_mnemonic_activate (widget, arg1);
}

bool hasFocus () {
    return OS.GTK_WIDGET_HAS_FOCUS (handle);
}

override void hookEvents () {
    super.hookEvents ();
    if ((style & SWT.SEPARATOR) !is 0) return;
    OS.g_signal_connect_closure (handle, OS.clicked.ptr, display.closures [CLICKED], false);
    OS.g_signal_connect_closure_by_id (handle, display.signalIds [ENTER_NOTIFY_EVENT], 0, display.closures [ENTER_NOTIFY_EVENT], false);
    OS.g_signal_connect_closure_by_id (handle, display.signalIds [LEAVE_NOTIFY_EVENT], 0, display.closures [LEAVE_NOTIFY_EVENT], false);
    if (labelHandle !is null) OS.g_signal_connect_closure_by_id (labelHandle, display.signalIds [MNEMONIC_ACTIVATE], 0, display.closures [MNEMONIC_ACTIVATE], false);

    OS.g_signal_connect_closure_by_id (handle, display.signalIds [FOCUS_OUT_EVENT], 0, display.closures [FOCUS_OUT_EVENT], false);

    /*
    * Feature in GTK.  Usually, GTK widgets propagate all events to their
    * parent when they are done their own processing.  However, in contrast
    * to other widgets, the buttons that make up the tool items, do not propagate
    * the mouse up/down events. It is interesting to note that they DO propagate
    * mouse motion events.  The fix is to explicitly forward mouse up/down events
    * to the parent.
    */
    int mask =
        OS.GDK_EXPOSURE_MASK | OS.GDK_POINTER_MOTION_MASK |
        OS.GDK_BUTTON_PRESS_MASK | OS.GDK_BUTTON_RELEASE_MASK |
        OS.GDK_ENTER_NOTIFY_MASK | OS.GDK_LEAVE_NOTIFY_MASK |
        OS.GDK_KEY_PRESS_MASK | OS.GDK_KEY_RELEASE_MASK |
        OS.GDK_FOCUS_CHANGE_MASK;
    OS.gtk_widget_add_events (handle, mask);
    OS.g_signal_connect_closure_by_id (handle, display.signalIds [BUTTON_PRESS_EVENT], 0, display.closures [BUTTON_PRESS_EVENT], false);
    OS.g_signal_connect_closure_by_id (handle, display.signalIds [BUTTON_RELEASE_EVENT], 0, display.closures [BUTTON_RELEASE_EVENT], false);
    OS.g_signal_connect_closure_by_id (handle, display.signalIds [EVENT_AFTER], 0, display.closures[EVENT_AFTER], false);

    auto topHandle = topHandle ();
    OS.g_signal_connect_closure_by_id (topHandle, display.signalIds [MAP], 0, display.closures [MAP], true);
}

/**
 * Returns <code>true</code> if the receiver is enabled and all
 * of the receiver's ancestors are enabled, and <code>false</code>
 * otherwise. A disabled control is typically not selectable from the
 * user interface and draws with an inactive or "grayed" look.
 *
 * @return the receiver's enabled state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getEnabled
 */
public bool isEnabled () {
    checkWidget();
    return getEnabled () && parent.isEnabled ();
}

override void register () {
    super.register ();
    if (labelHandle !is null) display.addWidget (labelHandle, this);
}

override void releaseHandle () {
    super.releaseHandle ();
    boxHandle = arrowHandle = separatorHandle = labelHandle = imageHandle = null;
}

override void releaseWidget () {
    super.releaseWidget ();
    if (parent.lastFocus is this) parent.lastFocus = null;
    parent = null;
    control = null;
    hotImage = disabledImage = null;
    toolTipText = null;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control is selected by the user.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SelectionListener
 * @see #addSelectionListener
 */
public void removeSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Selection, listener);
    eventTable.unhook (SWT.DefaultSelection,listener);
}

void resizeControl () {
    if (control !is null && !control.isDisposed ()) {
        if (separatorHandle !is null) OS.gtk_widget_hide (separatorHandle);
        /*
        * Set the size and location of the control
        * separately to minimize flashing in the
        * case where the control does not resize
        * to the size that was requested.  This
        * case can occur when the control is a
        * combo box.
        */
        Rectangle itemRect = getBounds ();
        control.setSize (itemRect.width, itemRect.height);
        OS.gtk_widget_set_size_request (handle, itemRect.width, itemRect.height);
        Rectangle rect = control.getBounds ();
        rect.x = itemRect.x + (itemRect.width - rect.width) / 2;
        rect.y = itemRect.y + (itemRect.height - rect.height) / 2;
        control.setLocation (rect.x, rect.y);
    } else {
        if (separatorHandle !is null) OS.gtk_widget_show (separatorHandle);
    }
}

void selectRadio () {
    int index = 0;
    ToolItem [] items = parent.getItems ();
    while (index < items.length && items [index] !is this) index++;
    int i = index - 1;
    while (i >= 0 && items [i].setRadioSelection (false)) --i;
    int j = index + 1;
    while (j < items.length && items [j].setRadioSelection (false)) j++;
    setSelection (true);
}

/**
 * Sets the control that is used to fill the bounds of
 * the item when the item is a <code>SEPARATOR</code>.
 *
 * @param control the new control
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
        if (control.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);
        if (control.parent !is parent) error (SWT.ERROR_INVALID_PARENT);
    }
    if ((style & SWT.SEPARATOR) is 0) return;
    if (this.control is control) return;
    this.control = control;
    parent.relayout ();
}

/**
 * Sets the receiver's disabled image to the argument, which may be
 * null indicating that no disabled image should be displayed.
 * <p>
 * The disabled image is displayed when the receiver is disabled.
 * </p>
 *
 * @param image the disabled image to display on the receiver (may be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setDisabledImage (Image image) {
    checkWidget();
    if ((style & SWT.SEPARATOR) !is 0) return;
    disabledImage = image;
}

/**
 * Enables the receiver if the argument is <code>true</code>,
 * and disables it otherwise.
 * <p>
 * A disabled control is typically
 * not selectable from the user interface and draws with an
 * inactive or "grayed" look.
 * </p>
 *
 * @param enabled the new enabled state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setEnabled (bool enabled) {
    checkWidget();
    auto topHandle = topHandle ();
    OS.gtk_widget_set_sensitive (topHandle, enabled);
    if (enabled) {
        /*
        * Bug in GTK.  GtkButton requires an enter notify before it
        * allows the button to be pressed, but events are dropped when
        * widgets are insensitive.  The fix is to hide and show the
        * button if the pointer is within its bounds.
        */
        int x, y;
        OS.gdk_window_get_pointer (parent.paintWindow (), &x, &y, null);
        if (getBounds ().contains (x, y)) {
            OS.gtk_widget_hide (handle);
            OS.gtk_widget_show (handle);
        }
    }
}

bool setFocus () {
    if ((style & SWT.SEPARATOR) !is 0) return false;
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
 * Sets the receiver's hot image to the argument, which may be
 * null indicating that no hot image should be displayed.
 * <p>
 * The hot image is displayed when the mouse enters the receiver.
 * </p>
 *
 * @param image the hot image to display on the receiver (may be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setHotImage (Image image) {
    checkWidget();
    if ((style & SWT.SEPARATOR) !is 0) return;
    hotImage = image;
    if (image !is null) {
        ImageList imageList = parent.imageList;
        if (imageList is null) imageList = parent.imageList = new ImageList ();
        int imageIndex = imageList.indexOf (image);
        if (imageIndex is -1) {
            imageIndex = imageList.add (image);
        } else {
            imageList.put (imageIndex, image);
        }
    }
}

public override void setImage (Image image) {
    checkWidget();
    if ((style & SWT.SEPARATOR) !is 0) return;
    super.setImage (image);
    if (imageHandle is null) return;
    if (image !is null) {
        ImageList imageList = parent.imageList;
        if (imageList is null) imageList = parent.imageList = new ImageList ();
        int imageIndex = imageList.indexOf (image);
        if (imageIndex is -1) {
            imageIndex = imageList.add (image);
        } else {
            imageList.put (imageIndex, image);
        }
        auto pixbuf = imageList.getPixbuf (imageIndex);
        OS.gtk_image_set_from_pixbuf (imageHandle, pixbuf);
        OS.gtk_widget_show (imageHandle);
    } else {
        OS.gtk_image_set_from_pixbuf (imageHandle, null);
        OS.gtk_widget_hide (imageHandle);
    }
    parent.relayout ();
}

override
void setOrientation () {
    if ((parent.style & SWT.RIGHT_TO_LEFT) !is 0) {
        if (handle !is null) OS.gtk_widget_set_direction (handle, OS.GTK_TEXT_DIR_RTL);
        if (labelHandle !is null) OS.gtk_widget_set_direction (labelHandle, OS.GTK_TEXT_DIR_RTL);
        if (imageHandle !is null) OS.gtk_widget_set_direction (imageHandle, OS.GTK_TEXT_DIR_RTL);
        if (separatorHandle !is null) OS.gtk_widget_set_direction (separatorHandle, OS.GTK_TEXT_DIR_RTL);
        if (arrowHandle !is null) OS.gtk_widget_set_direction (arrowHandle, OS.GTK_TEXT_DIR_RTL);
        if (boxHandle !is null) OS.gtk_widget_set_direction (boxHandle, OS.GTK_TEXT_DIR_RTL);
        if (arrowBoxHandle !is null) OS.gtk_widget_set_direction (arrowBoxHandle, OS.GTK_TEXT_DIR_RTL);
    }
}

bool setRadioSelection (bool value) {
    if ((style & SWT.RADIO) is 0) return false;
    if (getSelection () !is value) {
        setSelection (value);
        postEvent (SWT.Selection);
    }
    return true;
}

/**
 * Sets the selection state of the receiver.
 * <p>
 * When the receiver is of type <code>CHECK</code> or <code>RADIO</code>,
 * it is selected when it is checked (which some platforms draw as a
 * pushed in button).
 * </p>
 *
 * @param selected the new selection state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (bool selected) {
    checkWidget ();
    if ((style & (SWT.CHECK | SWT.RADIO)) is 0) return;
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCLICKED);
    OS.gtk_toggle_button_set_active (handle, selected);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCLICKED);
}

/**
 * Sets the receiver's text. The string may include
 * the mnemonic character.
 * </p>
 * <p>
 * Mnemonics are indicated by an '&amp;' that causes the next
 * character to be the mnemonic.  When the user presses a
 * key sequence that matches the mnemonic, a selection
 * event occurs. On most platforms, the mnemonic appears
 * underlined but may be emphasised in a platform specific
 * manner.  The mnemonic indicator character '&amp;' can be
 * escaped by doubling it in the string, causing a single
 * '&amp;' to be displayed.
 * </p>
 *
 * @param string the new text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public override void setText (String string) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if ((style & SWT.SEPARATOR) !is 0) return;
    super.setText (string);
    if (labelHandle is null) return;
    char [] chars = fixMnemonic (string);
    OS.gtk_label_set_text_with_mnemonic (labelHandle, chars.toStringzValidPtr());
    if (string.length !is 0) {
        OS.gtk_widget_show (labelHandle);
    } else {
        OS.gtk_widget_hide (labelHandle);
    }
    parent.relayout ();
}

/**
 * Sets the receiver's tool tip text to the argument, which
 * may be null indicating that no tool tip text should be shown.
 *
 * @param string the new tool tip text (or null)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setToolTipText (String string) {
    checkWidget();
    if (parent.toolTipText is null) {
        Shell shell = parent._getShell ();
        setToolTipText (shell, string);
    }
    toolTipText = string;
}

void setToolTipText (Shell shell, String newString) {
    shell.setToolTipText (handle, newString);
}

/**
 * Sets the width of the receiver, for <code>SEPARATOR</code> ToolItems.
 *
 * @param width the new width
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setWidth (int width) {
    checkWidget();
    if ((style & SWT.SEPARATOR) is 0) return;
    if (width < 0) return;
    bool isVertical = (parent.style & SWT.VERTICAL) !is 0;
    OS.gtk_widget_set_size_request (separatorHandle, width, isVertical ? 6 : 15);
    OS.gtk_widget_set_size_request (handle, width, isVertical ? 6 : 15);
    parent.relayout ();
}

void showWidget (int index) {
    if (handle !is null) OS.gtk_widget_show (handle);
    if (boxHandle !is null) OS.gtk_widget_show (boxHandle);
    if (separatorHandle !is null) OS.gtk_widget_show (separatorHandle);
    if (arrowBoxHandle !is null) OS.gtk_widget_show (arrowBoxHandle);
    if (arrowHandle !is null) OS.gtk_widget_show (arrowHandle);
    OS.gtk_toolbar_insert_widget (parent.handle, handle, null, null, index);
}
}
