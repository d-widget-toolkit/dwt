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
module org.eclipse.swt.widgets.Control;

import java.lang.all;


import org.eclipse.swt.SWT;
//import org.eclipse.swt.accessibility.Accessible;
import org.eclipse.swt.events.ControlListener;
import org.eclipse.swt.events.FocusListener;
import org.eclipse.swt.events.HelpListener;
import org.eclipse.swt.events.KeyListener;
import org.eclipse.swt.events.MouseListener;
import org.eclipse.swt.events.MouseMoveListener;
import org.eclipse.swt.events.MouseTrackListener;
import org.eclipse.swt.events.PaintListener;
import org.eclipse.swt.events.TraverseListener;
import org.eclipse.swt.events.DragDetectListener;
import org.eclipse.swt.events.MenuDetectListener;
import org.eclipse.swt.events.MouseWheelListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.Drawable;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Region;
import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.SWTEventListener;
import org.eclipse.swt.internal.accessibility.gtk.ATK;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Decorations;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.Monitor;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.accessibility.Accessible;

import java.lang.Thread;


/**
 * Control is the abstract superclass of all windowed user interface classes.
 * <p>
 * <dl>
 * <dt><b>Styles:</b>
 * <dd>BORDER</dd>
 * <dd>LEFT_TO_RIGHT, RIGHT_TO_LEFT</dd>
 * <dt><b>Events:</b>
 * <dd>DragDetect, FocusIn, FocusOut, Help, KeyDown, KeyUp, MenuDetect, MouseDoubleClick, MouseDown, MouseEnter,
 *     MouseExit, MouseHover, MouseUp, MouseMove, Move, Paint, Resize, Traverse</dd>
 * </dl>
 * </p><p>
 * Only one of LEFT_TO_RIGHT or RIGHT_TO_LEFT may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#control">Control snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public abstract class Control : Widget, Drawable {

    alias Widget.mnemonicHit mnemonicHit;
    alias Widget.mnemonicMatch mnemonicMatch;
    alias Widget.setForegroundColor setForegroundColor;
    alias Widget.translateTraversal translateTraversal;
    alias Widget.windowProc windowProc;

    GtkWidget* fixedHandle;
    GdkWindow* redrawWindow;
    GdkWindow* enableWindow;
    int drawCount;
    Composite parent;
    Cursor cursor;
    Menu menu;
    Image backgroundImage;
    Font font;
    Region region;
    String toolTipText;
    Object layoutData;
    Accessible accessible;

this () {
}

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
 * @see SWT#BORDER
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, style);
    this.parent = parent;
    createWidget (0);
}

Font defaultFont () {
    return display.getSystemFont ();
}

override void deregister () {
    super.deregister ();
    if (fixedHandle !is null) display.removeWidget (fixedHandle);
    auto imHandle = imHandle ();
    if (imHandle !is null) display.removeWidget (cast(GtkWidget*)imHandle);
}

bool drawGripper (int x, int y, int width, int height, bool vertical) {
    auto paintHandle = paintHandle ();
    auto window = OS.GTK_WIDGET_WINDOW (paintHandle);
    if (window is null) return false;
    int orientation = vertical ? OS.GTK_ORIENTATION_HORIZONTAL : OS.GTK_ORIENTATION_VERTICAL;
    if ((style & SWT.MIRRORED) !is 0) x = getClientWidth () - width - x;
    char dummy;
    OS.gtk_paint_handle (OS.gtk_widget_get_style (paintHandle), window, OS.GTK_STATE_NORMAL, OS.GTK_SHADOW_OUT, null, paintHandle, &dummy, x, y, width, height, orientation);
    return true;
}

void enableWidget (bool enabled) {
    OS.gtk_widget_set_sensitive (handle, enabled);
}

GtkWidget* enterExitHandle () {
    return eventHandle ();
}

GtkWidget* eventHandle () {
    return handle;
}

GdkWindow* eventWindow () {
    auto eventHandle = eventHandle ();
    OS.gtk_widget_realize (eventHandle);
    return OS.GTK_WIDGET_WINDOW (eventHandle);
}

void fixFocus (Control focusControl) {
    Shell shell = getShell ();
    Control control = this;
    while (control !is shell && (control = control.parent) !is null) {
        if (control.setFocus ()) return;
    }
    shell.setSavedFocus (focusControl);
    auto focusHandle_ = shell.vboxHandle;
    OS.GTK_WIDGET_SET_FLAGS (focusHandle_, OS.GTK_CAN_FOCUS);
    OS.gtk_widget_grab_focus (focusHandle_);
    OS.GTK_WIDGET_UNSET_FLAGS (focusHandle_, OS.GTK_CAN_FOCUS);
}

public void fixStyle () {
    if (fixedHandle !is null) fixStyle (fixedHandle);
}

void fixStyle (GtkWidget* handle) {
    /*
    * Feature in GTK.  Some GTK themes apply a different background to
    * the contents of a GtkNotebook.  However, in an SWT TabFolder, the
    * children are not parented below the GtkNotebook widget, and usually
    * have their own GtkFixed.  The fix is to look up the correct style
    * for a child of a GtkNotebook and apply its background to any GtkFixed
    * widgets that are direct children of an SWT TabFolder.
    *
    * Note that this has to be when the theme settings changes and that it
    * should not override the application background.
    */
    if ((state & BACKGROUND) !is 0) return;
    auto childStyle = parent.childStyle ();
    if (childStyle !is null) {
        GdkColor color;
        OS.gtk_style_get_bg (childStyle, 0, &color);
        OS.gtk_widget_modify_bg (handle, 0, &color);
    }
}

GtkWidget* focusHandle () {
    return handle;
}

GtkWidget* fontHandle () {
    return handle;
}

bool hasFocus () {
    return this is display.getFocusControl();
}

override void hookEvents () {
    /* Connect the keyboard signals */
    auto focusHandle_ = focusHandle ();
    int focusMask = OS.GDK_KEY_PRESS_MASK | OS.GDK_KEY_RELEASE_MASK | OS.GDK_FOCUS_CHANGE_MASK;
    OS.gtk_widget_add_events (focusHandle_, focusMask);
    OS.g_signal_connect_closure_by_id (focusHandle_, display.signalIds [POPUP_MENU], 0, display.closures [POPUP_MENU], false);
    OS.g_signal_connect_closure_by_id (focusHandle_, display.signalIds [SHOW_HELP], 0, display.closures [SHOW_HELP], false);
    OS.g_signal_connect_closure_by_id (focusHandle_, display.signalIds [KEY_PRESS_EVENT], 0, display.closures [KEY_PRESS_EVENT], false);
    OS.g_signal_connect_closure_by_id (focusHandle_, display.signalIds [KEY_RELEASE_EVENT], 0, display.closures [KEY_RELEASE_EVENT], false);
    OS.g_signal_connect_closure_by_id (focusHandle_, display.signalIds [FOCUS], 0, display.closures [FOCUS], false);
    OS.g_signal_connect_closure_by_id (focusHandle_, display.signalIds [FOCUS_IN_EVENT], 0, display.closures [FOCUS_IN_EVENT], false);
    OS.g_signal_connect_closure_by_id (focusHandle_, display.signalIds [FOCUS_OUT_EVENT], 0, display.closures [FOCUS_OUT_EVENT], false);

    /* Connect the mouse signals */
    auto eventHandle = eventHandle ();
    int eventMask = OS.GDK_POINTER_MOTION_MASK | OS.GDK_BUTTON_PRESS_MASK | OS.GDK_BUTTON_RELEASE_MASK;
    OS.gtk_widget_add_events (eventHandle, eventMask);
    OS.g_signal_connect_closure_by_id (eventHandle, display.signalIds [BUTTON_PRESS_EVENT], 0, display.closures [BUTTON_PRESS_EVENT], false);
    OS.g_signal_connect_closure_by_id (eventHandle, display.signalIds [BUTTON_RELEASE_EVENT], 0, display.closures [BUTTON_RELEASE_EVENT], false);
    OS.g_signal_connect_closure_by_id (eventHandle, display.signalIds [MOTION_NOTIFY_EVENT], 0, display.closures [MOTION_NOTIFY_EVENT], false);
    OS.g_signal_connect_closure_by_id (eventHandle, display.signalIds [SCROLL_EVENT], 0, display.closures [SCROLL_EVENT], false);

    /* Connect enter/exit signals */
    auto enterExitHandle = enterExitHandle ();
    int enterExitMask = OS.GDK_ENTER_NOTIFY_MASK | OS.GDK_LEAVE_NOTIFY_MASK;
    OS.gtk_widget_add_events (enterExitHandle, enterExitMask);
    OS.g_signal_connect_closure_by_id (enterExitHandle, display.signalIds [ENTER_NOTIFY_EVENT], 0, display.closures [ENTER_NOTIFY_EVENT], false);
    OS.g_signal_connect_closure_by_id (enterExitHandle, display.signalIds [LEAVE_NOTIFY_EVENT], 0, display.closures [LEAVE_NOTIFY_EVENT], false);

    /*
    * Feature in GTK.  Events such as mouse move are propagate up
    * the widget hierarchy and are seen by the parent.  This is the
    * correct GTK behavior but not correct for SWT.  The fix is to
    * hook a signal after and stop the propagation using a negative
    * event number to distinguish this case.
    *
    * The signal is hooked to the fixedHandle to catch events sent to
    * lightweight widgets.
    */
    auto blockHandle = fixedHandle !is null ? fixedHandle : eventHandle;
    OS.g_signal_connect_closure_by_id (blockHandle, display.signalIds [BUTTON_PRESS_EVENT], 0, display.closures [BUTTON_PRESS_EVENT_INVERSE], true);
    OS.g_signal_connect_closure_by_id (blockHandle, display.signalIds [BUTTON_RELEASE_EVENT], 0, display.closures [BUTTON_RELEASE_EVENT_INVERSE], true);
    OS.g_signal_connect_closure_by_id (blockHandle, display.signalIds [MOTION_NOTIFY_EVENT], 0, display.closures [MOTION_NOTIFY_EVENT_INVERSE], true);

    /* Connect the event_after signal for both key and mouse */
    OS.g_signal_connect_closure_by_id (eventHandle, display.signalIds [EVENT_AFTER], 0, display.closures [EVENT_AFTER], false);
    if (focusHandle_ !is eventHandle) {
        OS.g_signal_connect_closure_by_id (focusHandle_, display.signalIds [EVENT_AFTER], 0, display.closures [EVENT_AFTER], false);
    }

    /* Connect the paint signal */
    auto paintHandle = paintHandle ();
    int paintMask = OS.GDK_EXPOSURE_MASK | OS.GDK_VISIBILITY_NOTIFY_MASK;
    OS.gtk_widget_add_events (paintHandle, paintMask);
    OS.g_signal_connect_closure_by_id (paintHandle, display.signalIds [EXPOSE_EVENT], 0, display.closures [EXPOSE_EVENT_INVERSE], false);
    OS.g_signal_connect_closure_by_id (paintHandle, display.signalIds [VISIBILITY_NOTIFY_EVENT], 0, display.closures [VISIBILITY_NOTIFY_EVENT], false);
    OS.g_signal_connect_closure_by_id (paintHandle, display.signalIds [EXPOSE_EVENT], 0, display.closures [EXPOSE_EVENT], true);

    /* Connect the Input Method signals */
    OS.g_signal_connect_closure_by_id (handle, display.signalIds [REALIZE], 0, display.closures [REALIZE], true);
    OS.g_signal_connect_closure_by_id (handle, display.signalIds [UNREALIZE], 0, display.closures [UNREALIZE], false);
    auto imHandle = imHandle ();
    if (imHandle !is null) {
        OS.g_signal_connect_closure (imHandle, OS.commit.ptr, display.closures [COMMIT], false);
        OS.g_signal_connect_closure (imHandle, OS.preedit_changed.ptr, display.closures [PREEDIT_CHANGED], false);
    }

    OS.g_signal_connect_closure_by_id (paintHandle, display.signalIds [STYLE_SET], 0, display.closures [STYLE_SET], false);

    auto topHandle_ = topHandle ();
    OS.g_signal_connect_closure_by_id (topHandle_, display.signalIds [MAP], 0, display.closures [MAP], true);
}

override int hoverProc (GtkWidget* widget) {
    int x, y;
    int mask;
    OS.gdk_window_get_pointer (null, &x, &y, &mask);
    sendMouseEvent (SWT.MouseHover, 0, /*time*/0, x , y , false, mask );
    /* Always return zero in order to cancel the hover timer */
    return 0;
}

override GtkWidget* topHandle() {
    if (fixedHandle !is null) return fixedHandle;
    return super.topHandle ();
}

GtkWidget* paintHandle () {
    auto topHandle_ = topHandle ();
    auto paintHandle = handle;
    while (paintHandle !is topHandle_) {
        if ((OS.GTK_WIDGET_FLAGS (paintHandle) & OS.GTK_NO_WINDOW) is 0) break;
        paintHandle = OS.gtk_widget_get_parent (paintHandle);
    }
    return paintHandle;
}

override GdkWindow* paintWindow () {
    auto paintHandle = paintHandle ();
    OS.gtk_widget_realize (paintHandle);
    return OS.GTK_WIDGET_WINDOW (paintHandle);
}

/**
 * Prints the receiver and all children.
 *
 * @param gc the gc where the drawing occurs
 * @return <code>true</code> if the operation was successful and <code>false</code> otherwise
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
 * @since 3.4
 */
public bool print (GC gc) {
    checkWidget ();
    if (gc is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
    auto topHandle_ = topHandle ();
    OS.gtk_widget_realize (topHandle_);
    auto window = OS.GTK_WIDGET_WINDOW (topHandle_);
    GCData data = gc.getGCData ();
    OS.gdk_window_process_updates (window, cast(int)true);
    printWidget (gc, data.drawable, OS.gdk_drawable_get_depth (data.drawable), 0, 0);
    return true;
}

void printWidget (GC gc, GdkDrawable* drawable, int depth, int x, int y) {
    bool obscured = (state & OBSCURED) !is 0;
    state &= ~OBSCURED;
    auto topHandle_ = topHandle ();
    auto window = OS.GTK_WIDGET_WINDOW (topHandle_);
    printWindow (true, this, gc.handle, drawable, depth, window, x, y);
    if (obscured) state |= OBSCURED;
}

void printWindow (bool first, Control control, GdkGC* gc, GdkDrawable* drawable, int depth, GdkDrawable* window, int x, int y) {
    if (OS.gdk_drawable_get_depth (window) !is depth) return;
    GdkRectangle rect;
    int width, height;
    OS.gdk_drawable_get_size (window, &width, &height);
    rect.width = width;
    rect.height = height;
    OS.gdk_window_begin_paint_rect (window, &rect);
    GdkDrawable* real_drawable;
    int x_offset, y_offset;
    OS.gdk_window_get_internal_paint_info (window, &real_drawable, &x_offset, &y_offset);
    void* userData;
    OS.gdk_window_get_user_data (window, &userData);
    if (userData !is null) {
        GdkEventExpose* event = cast(GdkEventExpose*) OS.gdk_event_new (OS.GDK_EXPOSE);
        event.type = OS.GDK_EXPOSE;
        event.window = cast(GdkDrawable*)OS.g_object_ref (window);
        event.area.width = rect.width;
        event.area.height = rect.height;
        event.region = OS.gdk_region_rectangle (&rect);
        OS.gtk_widget_send_expose (userData, cast(GdkEvent*)event);
        OS.gdk_event_free (cast(GdkEvent*)event);
    }
    int srcX = x_offset, srcY = y_offset;
    int destX = x, destY = y, destWidth = width, destHeight = height;
    if (!first) {
        int cX, cY;
        OS.gdk_window_get_position (window, &cX, &cY);
        auto parentWindow = OS.gdk_window_get_parent (window);
        int pW, pH;
        OS.gdk_drawable_get_size (parentWindow, &pW, &pH);
        srcX = x_offset - cX;
        srcY = y_offset - cY;
        destX = x - cX;
        destY = y - cY;
        destWidth = Math.min (cX + width, pW);
        destHeight = Math.min (cY + height, pH);
    }
    OS.gdk_draw_drawable (drawable, gc, real_drawable, srcX, srcY, destX, destY, destWidth, destHeight);
    OS.gdk_window_end_paint (window);
    auto children = OS.gdk_window_get_children (window);
    if (children !is null) {
        auto windows = children;
        while (windows !is null) {
            auto child = cast(GdkDrawable*) OS.g_list_data (windows);
            if (OS.gdk_window_is_visible (child)) {
                void* data;
                OS.gdk_window_get_user_data (child, &data);
                if (data !is null) {
                    Widget widget = display.findWidget ( cast(GtkWidget*) data);
                    if (widget is null || widget is control) {
                        int x_pos, y_pos;
                        OS.gdk_window_get_position (child, &x_pos, &y_pos);
                        printWindow (false, control, gc, drawable, depth, child, x + x_pos, y + y_pos);
                    }
                }
            }
            windows = OS.g_list_next (windows);
        }
        OS.g_list_free (children);
    }
}

/**
 * Returns the preferred size of the receiver.
 * <p>
 * The <em>preferred size</em> of a control is the size that it would
 * best be displayed at. The width hint and height hint arguments
 * allow the caller to ask a control questions such as "Given a particular
 * width, how high does the control need to be to show all of the contents?"
 * To indicate that the caller does not wish to constrain a particular
 * dimension, the constant <code>SWT.DEFAULT</code> is passed for the hint.
 * </p>
 *
 * @param wHint the width hint (can be <code>SWT.DEFAULT</code>)
 * @param hHint the height hint (can be <code>SWT.DEFAULT</code>)
 * @return the preferred size of the control
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Layout
 * @see #getBorderWidth
 * @see #getBounds
 * @see #getSize
 * @see #pack(bool)
 * @see "computeTrim, getClientArea for controls that implement them"
 */
public Point computeSize (int wHint, int hHint) {
    return computeSize (wHint, hHint, true);
}

Control computeTabGroup () {
    if (isTabGroup()) return this;
    return parent.computeTabGroup ();
}

Control[] computeTabList() {
    if (isTabGroup()) {
        if (getVisible() && getEnabled()) {
            return [this];
        }
    }
    return new Control[0];
}

Control computeTabRoot () {
    Control[] tabList = parent._getTabList();
    if (tabList !is null) {
        int index = 0;
        while (index < tabList.length) {
            if (tabList [index] is this) break;
            index++;
        }
        if (index is tabList.length) {
            if (isTabGroup ()) return this;
        }
    }
    return parent.computeTabRoot ();
}

void checkBuffered () {
    style |= SWT.DOUBLE_BUFFERED;
}

void checkBackground () {
    Shell shell = getShell ();
    if (this is shell) return;
    state &= ~PARENT_BACKGROUND;
    Composite composite = parent;
    do {
        int mode = composite.backgroundMode;
        if (mode !is SWT.INHERIT_NONE) {
            if (mode is SWT.INHERIT_DEFAULT) {
                Control control = this;
                do {
                    if ((control.state & THEME_BACKGROUND) is 0) {
                        return;
                    }
                    control = control.parent;
                } while (control !is composite);
            }
            state |= PARENT_BACKGROUND;
            return;
        }
        if (composite is shell) break;
        composite = composite.parent;
    } while (true);
}

void checkBorder () {
    if (getBorderWidth () is 0) style &= ~SWT.BORDER;
}

void checkMirrored () {
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) style |= SWT.MIRRORED;
}

GtkStyle* childStyle () {
    return parent.childStyle ();
}

override void createWidget (int index) {
    state |= DRAG_DETECT;
    checkOrientation (parent);
    super.createWidget (index);
    checkBackground ();
    if ((state & PARENT_BACKGROUND) !is 0) setBackground ();
    checkBuffered ();
    showWidget ();
    setInitialBounds ();
    setZOrder (null, false, false);
    setRelations ();
    checkMirrored ();
    checkBorder ();
}

/**
 * Returns the preferred size of the receiver.
 * <p>
 * The <em>preferred size</em> of a control is the size that it would
 * best be displayed at. The width hint and height hint arguments
 * allow the caller to ask a control questions such as "Given a particular
 * width, how high does the control need to be to show all of the contents?"
 * To indicate that the caller does not wish to constrain a particular
 * dimension, the constant <code>SWT.DEFAULT</code> is passed for the hint.
 * </p><p>
 * If the changed flag is <code>true</code>, it indicates that the receiver's
 * <em>contents</em> have changed, therefore any caches that a layout manager
 * containing the control may have been keeping need to be flushed. When the
 * control is resized, the changed flag will be <code>false</code>, so layout
 * manager caches can be retained.
 * </p>
 *
 * @param wHint the width hint (can be <code>SWT.DEFAULT</code>)
 * @param hHint the height hint (can be <code>SWT.DEFAULT</code>)
 * @param changed <code>true</code> if the control's contents have changed, and <code>false</code> otherwise
 * @return the preferred size of the control.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Layout
 * @see #getBorderWidth
 * @see #getBounds
 * @see #getSize
 * @see #pack(bool)
 * @see "computeTrim, getClientArea for controls that implement them"
 */
public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget();
    if (wHint !is SWT.DEFAULT && wHint < 0) wHint = 0;
    if (hHint !is SWT.DEFAULT && hHint < 0) hHint = 0;
    return computeNativeSize (handle, wHint, hHint, changed);
}

Point computeNativeSize (GtkWidget* h, int wHint, int hHint, bool changed) {
    int width = wHint, height = hHint;
    if (wHint is SWT.DEFAULT && hHint is SWT.DEFAULT) {
        GtkRequisition requisition;
        gtk_widget_size_request (h, &requisition);
        width = OS.GTK_WIDGET_REQUISITION_WIDTH (h);
        height = OS.GTK_WIDGET_REQUISITION_HEIGHT (h);
    } else if (wHint is SWT.DEFAULT || hHint is SWT.DEFAULT) {
        int reqWidth, reqHeight;
        OS.gtk_widget_get_size_request (h, &reqWidth, &reqHeight);
        OS.gtk_widget_set_size_request (h, wHint, hHint);
        GtkRequisition requisition;
        gtk_widget_size_request (h, &requisition);
        OS.gtk_widget_set_size_request (h, reqWidth, reqHeight);
        width = wHint is SWT.DEFAULT ? requisition.width : wHint;
        height = hHint is SWT.DEFAULT ? requisition.height : hHint;
    }
    return new Point (width, height);
}

void forceResize () {
    /*
    * Force size allocation on all children of this widget's
    * topHandle.  Note that all calls to gtk_widget_size_allocate()
    * must be preceded by a call to gtk_widget_size_request().
    */
    auto topHandle_ = topHandle ();
    GtkRequisition requisition;
    gtk_widget_size_request (topHandle_, &requisition);
    GtkAllocation allocation;
    allocation.x = OS.GTK_WIDGET_X (topHandle_);
    allocation.y = OS.GTK_WIDGET_Y (topHandle_);
    allocation.width = OS.GTK_WIDGET_WIDTH (topHandle_);
    allocation.height = OS.GTK_WIDGET_HEIGHT (topHandle_);
    OS.gtk_widget_size_allocate (topHandle_, &allocation);
}

/**
 * Returns the accessible object for the receiver.
 * If this is the first time this object is requested,
 * then the object is created and returned.
 *
 * @return the accessible object
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Accessible#addAccessibleListener
 * @see Accessible#addAccessibleControlListener
 *
 * @since 2.0
 */
public Accessible getAccessible () {
    checkWidget ();
    if (accessible is null) {
        accessible = Accessible.internal_new_Accessible (this);
    }
    return accessible;
}

/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent (or its display if its parent is null),
 * unless the receiver is a shell. In this case, the location is
 * relative to the display.
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
    auto topHandle_ = topHandle ();
    int x = OS.GTK_WIDGET_X (topHandle_);
    int y = OS.GTK_WIDGET_Y (topHandle_);
    int width = (state & ZERO_WIDTH) !is 0 ? 0 : OS.GTK_WIDGET_WIDTH (topHandle_);
    int height = (state & ZERO_HEIGHT) !is 0 ? 0 : OS.GTK_WIDGET_HEIGHT (topHandle_);
    if ((parent.style & SWT.MIRRORED) !is 0) x = parent.getClientWidth () - width - x;
    return new Rectangle (x, y, width, height);
}

/**
 * Sets the receiver's size and location to the rectangular
 * area specified by the argument. The <code>x</code> and
 * <code>y</code> fields of the rectangle are relative to
 * the receiver's parent (or its display if its parent is null).
 * <p>
 * Note: Attempting to set the width or height of the
 * receiver to a negative number will cause that
 * value to be set to zero instead.
 * </p>
 *
 * @param rect the new bounds for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setBounds (Rectangle rect) {
    checkWidget ();
    if (rect is null) error (SWT.ERROR_NULL_ARGUMENT);
    setBounds (rect.x, rect.y, Math.max (0, rect.width), Math.max (0, rect.height), true, true);
}

/**
 * Sets the receiver's size and location to the rectangular
 * area specified by the arguments. The <code>x</code> and
 * <code>y</code> arguments are relative to the receiver's
 * parent (or its display if its parent is null), unless
 * the receiver is a shell. In this case, the <code>x</code>
 * and <code>y</code> arguments are relative to the display.
 * <p>
 * Note: Attempting to set the width or height of the
 * receiver to a negative number will cause that
 * value to be set to zero instead.
 * </p>
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
    setBounds (x, y, Math.max (0, width), Math.max (0, height), true, true);
}

void markLayout (bool changed, bool all) {
    /* Do nothing */
}

override void modifyStyle (GtkWidget* handle, GtkRcStyle* style) {
    super.modifyStyle(handle, style);
    /*
    * Bug in GTK.  When changing the style of a control that
    * has had a region set on it, the region is lost.  The
    * fix is to set the region again.
    */
    if (region !is null) OS.gdk_window_shape_combine_region (OS.GTK_WIDGET_WINDOW (topHandle ()), region.handle, 0, 0);
}

void moveHandle (int x, int y) {
    auto topHandle_ = topHandle ();
    auto parentHandle = parent.parentingHandle ();
    /*
    * Feature in GTK.  Calling gtk_fixed_move() to move a child causes
    * the whole parent to redraw.  This is a performance problem. The
    * fix is temporarily make the parent not visible during the move.
    *
    * NOTE: Because every widget in SWT has an X window, the new and
    * old bounds of the child are correctly redrawn.
    */
    int flags = OS.GTK_WIDGET_FLAGS (parentHandle);
    OS.GTK_WIDGET_UNSET_FLAGS (parentHandle, OS.GTK_VISIBLE);
    OS.gtk_fixed_move (cast(GtkFixed*)parentHandle, topHandle_, x, y);
    if ((flags & OS.GTK_VISIBLE) !is 0) {
        OS.GTK_WIDGET_SET_FLAGS (parentHandle, OS.GTK_VISIBLE);
    }
}

void resizeHandle (int width, int height) {
    auto topHandle_ = topHandle ();
    OS.gtk_widget_set_size_request (topHandle_, width, height);
    if (topHandle_ !is handle) OS.gtk_widget_set_size_request (handle, width, height);
}

int setBounds (int x, int y, int width, int height, bool move, bool resize) {
    auto topHandle_ = topHandle ();
    bool sendMove = move;
    if ((parent.style & SWT.MIRRORED) !is 0) {
        int clientWidth = parent.getClientWidth ();
        int oldWidth = (state & ZERO_WIDTH) !is 0 ? 0 : OS.GTK_WIDGET_WIDTH (topHandle_);
        int oldX = clientWidth - oldWidth - OS.GTK_WIDGET_X (topHandle_);
        if (move) {
            sendMove &= x !is oldX;
            x = clientWidth - (resize ? width : oldWidth) - x;
        } else {
            move = true;
            x = clientWidth - (resize ? width : oldWidth) - oldX;
            y = OS.GTK_WIDGET_Y (topHandle_);
        }
    }
    bool sameOrigin = true, sameExtent = true;
    if (move) {
        int oldX = OS.GTK_WIDGET_X (topHandle_);
        int oldY = OS.GTK_WIDGET_Y (topHandle_);
        sameOrigin = x is oldX && y is oldY;
        if (!sameOrigin) {
            if (enableWindow !is null) {
                OS.gdk_window_move (enableWindow, x, y);
            }
            moveHandle (x, y);
        }
    }
    int clientWidth = 0;
    if (resize) {
        int oldWidth = (state & ZERO_WIDTH) !is 0 ? 0 : OS.GTK_WIDGET_WIDTH (topHandle_);
        int oldHeight = (state & ZERO_HEIGHT) !is 0 ? 0 : OS.GTK_WIDGET_HEIGHT (topHandle_);
        sameExtent = width is oldWidth && height is oldHeight;
        if (!sameExtent && (style & SWT.MIRRORED) !is 0) clientWidth = getClientWidth ();
        if (!sameExtent && !(width is 0 && height is 0)) {
            int newWidth = Math.max (1, width);
            int newHeight = Math.max (1, height);
            if (redrawWindow !is null) {
                OS.gdk_window_resize (redrawWindow, newWidth, newHeight);
            }
            if (enableWindow !is null) {
                OS.gdk_window_resize (enableWindow, newWidth, newHeight);
            }
            resizeHandle (newWidth, newHeight);
        }
    }
    if (!sameOrigin || !sameExtent) {
        /*
        * Cause a size allocation this widget's topHandle.  Note that
        * all calls to gtk_widget_size_allocate() must be preceded by
        * a call to gtk_widget_size_request().
        */
        GtkRequisition requisition;
        gtk_widget_size_request (topHandle_, &requisition);
        GtkAllocation allocation;
        if (move) {
            allocation.x = x;
            allocation.y = y;
        } else {
            allocation.x = OS.GTK_WIDGET_X (topHandle_);
            allocation.y = OS.GTK_WIDGET_Y (topHandle_);
        }
        if (resize) {
            allocation.width = width;
            allocation.height = height;
        } else {
            allocation.width = OS.GTK_WIDGET_WIDTH (topHandle_);
            allocation.height = OS.GTK_WIDGET_HEIGHT (topHandle_);
        }
        OS.gtk_widget_size_allocate (topHandle_, &allocation);
    }
    /*
    * Bug in GTK.  Widgets cannot be sized smaller than 1x1.
    * The fix is to hide zero-sized widgets and show them again
    * when they are resized larger.
    */
    if (!sameExtent) {
        state = (width is 0) ? state | ZERO_WIDTH : state & ~ZERO_WIDTH;
        state = (height is 0) ? state | ZERO_HEIGHT : state & ~ZERO_HEIGHT;
        if ((state & (ZERO_WIDTH | ZERO_HEIGHT)) !is 0) {
            if (enableWindow !is null) {
                OS.gdk_window_hide (enableWindow);
            }
            OS.gtk_widget_hide (topHandle_);
        } else {
            if ((state & HIDDEN) is 0) {
                if (enableWindow !is null) {
                    OS.gdk_window_show_unraised (enableWindow);
                }
                OS.gtk_widget_show (topHandle_);
            }
        }
        if ((style & SWT.MIRRORED) !is 0) moveChildren (clientWidth);
    }
    int result = 0;
    if (move && !sameOrigin) {
        Control control = findBackgroundControl ();
        if (control !is null && control.backgroundImage !is null) {
            if (isVisible ()) redrawWidget (0, 0, 0, 0, true, true, true);
        }
        if (sendMove) sendEvent (SWT.Move);
        result |= MOVED;
    }
    if (resize && !sameExtent) {
        sendEvent (SWT.Resize);
        result |= RESIZED;
    }
    return result;
}

/**
 * Returns a point describing the receiver's location relative
 * to its parent (or its display if its parent is null), unless
 * the receiver is a shell. In this case, the point is
 * relative to the display.
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
    auto topHandle_ = topHandle ();
    int x = OS.GTK_WIDGET_X (topHandle_);
    int y = OS.GTK_WIDGET_Y (topHandle_);
    if ((parent.style & SWT.MIRRORED) !is 0) {
        int width = (state & ZERO_WIDTH) !is 0 ? 0 : OS.GTK_WIDGET_WIDTH (topHandle_);
        x = parent.getClientWidth () - width - x;
    }
    return new Point (x, y);
}

/**
 * Sets the receiver's location to the point specified by
 * the arguments which are relative to the receiver's
 * parent (or its display if its parent is null), unless
 * the receiver is a shell. In this case, the point is
 * relative to the display.
 *
 * @param location the new location for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLocation (Point location) {
    checkWidget ();
    if (location is null) error (SWT.ERROR_NULL_ARGUMENT);
    setBounds (location.x, location.y, 0, 0, true, false);
}

/**
 * Sets the receiver's location to the point specified by
 * the arguments which are relative to the receiver's
 * parent (or its display if its parent is null), unless
 * the receiver is a shell. In this case, the point is
 * relative to the display.
 *
 * @param x the new x coordinate for the receiver
 * @param y the new y coordinate for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLocation(int x, int y) {
    checkWidget();
    setBounds (x, y, 0, 0, true, false);
}

/**
 * Returns a point describing the receiver's size. The
 * x coordinate of the result is the width of the receiver.
 * The y coordinate of the result is the height of the
 * receiver.
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
    auto topHandle_ = topHandle ();
    int width = (state & ZERO_WIDTH) !is 0 ? 0 : OS.GTK_WIDGET_WIDTH (topHandle_);
    int height = (state & ZERO_HEIGHT) !is 0 ? 0 : OS.GTK_WIDGET_HEIGHT (topHandle_);
    return new Point (width, height);
}

/**
 * Sets the receiver's size to the point specified by the argument.
 * <p>
 * Note: Attempting to set the width or height of the
 * receiver to a negative number will cause them to be
 * set to zero instead.
 * </p>
 *
 * @param size the new size for the receiver
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
    checkWidget ();
    if (size is null) error (SWT.ERROR_NULL_ARGUMENT);
    setBounds (0, 0, Math.max (0, size.x), Math.max (0, size.y), false, true);
}

/**
 * Sets the shape of the control to the region specified
 * by the argument.  When the argument is null, the
 * default shape of the control is restored.
 *
 * @param region the region that defines the shape of the control (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the region has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setRegion (Region region) {
    checkWidget ();
    if (region !is null && region.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);
    auto window = OS.GTK_WIDGET_WINDOW (topHandle ());
    auto shape_region = (region is null) ? null : region.handle;
    OS.gdk_window_shape_combine_region (window, shape_region, 0, 0);
    this.region = region;
}

void setRelations () {
    auto parentHandle = parent.parentingHandle ();
    auto list = OS.gtk_container_get_children (cast(GtkContainer*)parentHandle);
    if (list is null) return;
    int count = OS.g_list_length (list);
    if (count > 1) {
        /*
         * the receiver is the last item in the list, so its predecessor will
         * be the second-last item in the list
         */
        auto handle = cast(GtkWidget*) OS.g_list_nth_data (list, count - 2);
        if (handle !is null) {
            Widget widget = display.getWidget (handle);
            if (widget !is null && widget !is this) {
                if (auto sibling = cast(Control)widget ) {
                    sibling.addRelation (this);
                }
            }
        }
    }
    OS.g_list_free (list);
}

/**
 * Sets the receiver's size to the point specified by the arguments.
 * <p>
 * Note: Attempting to set the width or height of the
 * receiver to a negative number will cause that
 * value to be set to zero instead.
 * </p>
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
    setBounds (0, 0, Math.max (0, width), Math.max (0, height), false, true);
}

/*
 * Answers a bool indicating whether a Label that precedes the receiver in
 * a layout should be read by screen readers as the recevier's label.
 */
bool isDescribedByLabel () {
    return true;
}

bool isFocusHandle (GtkWidget* widget) {
    return widget is focusHandle ();
}

/**
 * Moves the receiver above the specified control in the
 * drawing order. If the argument is null, then the receiver
 * is moved to the top of the drawing order. The control at
 * the top of the drawing order will not be covered by other
 * controls even if they occupy intersecting areas.
 *
 * @param control the sibling control (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the control has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Control#moveBelow
 * @see Composite#getChildren
 */
public void moveAbove (Control control) {
    checkWidget();
    if (control !is null) {
        if (control.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
        if (parent !is control.parent) return;
    }
    setZOrder (control, true, true);
}

/**
 * Moves the receiver below the specified control in the
 * drawing order. If the argument is null, then the receiver
 * is moved to the bottom of the drawing order. The control at
 * the bottom of the drawing order will be covered by all other
 * controls which occupy intersecting areas.
 *
 * @param control the sibling control (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the control has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Control#moveAbove
 * @see Composite#getChildren
 */
public void moveBelow (Control control) {
    checkWidget();
    if (control !is null) {
        if (control.isDisposed ()) error(SWT.ERROR_INVALID_ARGUMENT);
        if (parent !is control.parent) return;
    }
    setZOrder (control, false, true);
}

void moveChildren (int oldWidth) {
}

/**
 * Causes the receiver to be resized to its preferred size.
 * For a composite, this involves computing the preferred size
 * from its layout, if there is one.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #computeSize(int, int, bool)
 */
public void pack () {
    pack (true);
}

/**
 * Causes the receiver to be resized to its preferred size.
 * For a composite, this involves computing the preferred size
 * from its layout, if there is one.
 * <p>
 * If the changed flag is <code>true</code>, it indicates that the receiver's
 * <em>contents</em> have changed, therefore any caches that a layout manager
 * containing the control may have been keeping need to be flushed. When the
 * control is resized, the changed flag will be <code>false</code>, so layout
 * manager caches can be retained.
 * </p>
 *
 * @param changed whether or not the receiver's contents have changed
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #computeSize(int, int, bool)
 */
public void pack (bool changed) {
    setSize (computeSize (SWT.DEFAULT, SWT.DEFAULT, changed));
}

/**
 * Sets the layout data associated with the receiver to the argument.
 *
 * @param layoutData the new layout data for the receiver.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLayoutData (Object layoutData) {
    checkWidget();
    this.layoutData = layoutData;
}

/**
 * Returns a point which is the result of converting the
 * argument, which is specified in display relative coordinates,
 * to coordinates relative to the receiver.
 * <p>
 * @param x the x coordinate to be translated
 * @param y the y coordinate to be translated
 * @return the translated coordinates
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1
 */
public Point toControl (int x, int y) {
    checkWidget ();
    auto window = eventWindow ();
    int origin_x, origin_y;
    OS.gdk_window_get_origin (window, &origin_x, &origin_y);
    x -= origin_x ;
    y -= origin_y ;
    if ((style & SWT.MIRRORED) !is 0) x = getClientWidth () - x;
    return new Point (x, y);
}

/**
 * Returns a point which is the result of converting the
 * argument, which is specified in display relative coordinates,
 * to coordinates relative to the receiver.
 * <p>
 * @param point the point to be translated (must not be null)
 * @return the translated coordinates
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point toControl (Point point) {
    checkWidget ();
    if (point is null) error (SWT.ERROR_NULL_ARGUMENT);
    return toControl (point.x, point.y);
}

/**
 * Returns a point which is the result of converting the
 * argument, which is specified in coordinates relative to
 * the receiver, to display relative coordinates.
 * <p>
 * @param x the x coordinate to be translated
 * @param y the y coordinate to be translated
 * @return the translated coordinates
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1
 */
public Point toDisplay (int x, int y) {
    checkWidget();
    auto window = eventWindow ();
    int origin_x, origin_y;
    OS.gdk_window_get_origin (window, &origin_x, &origin_y);
    if ((style & SWT.MIRRORED) !is 0) x = getClientWidth () - x;
    x += origin_x ;
    y += origin_y ;
    return new Point (x, y);
}

/**
 * Returns a point which is the result of converting the
 * argument, which is specified in coordinates relative to
 * the receiver, to display relative coordinates.
 * <p>
 * @param point the point to be translated (must not be null)
 * @return the translated coordinates
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point toDisplay (Point point) {
    checkWidget();
    if (point is null) error (SWT.ERROR_NULL_ARGUMENT);
    return toDisplay (point.x, point.y);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is moved or resized, by sending
 * it one of the messages defined in the <code>ControlListener</code>
 * interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see ControlListener
 * @see #removeControlListener
 */
public void addControlListener(ControlListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Resize,typedListener);
    addListener (SWT.Move,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when a drag gesture occurs, by sending it
 * one of the messages defined in the <code>DragDetectListener</code>
 * interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DragDetectListener
 * @see #removeDragDetectListener
 *
 * @since 3.3
 */
public void addDragDetectListener (DragDetectListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.DragDetect,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control gains or loses focus, by sending
 * it one of the messages defined in the <code>FocusListener</code>
 * interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see FocusListener
 * @see #removeFocusListener
 */
public void addFocusListener(FocusListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener(SWT.FocusIn,typedListener);
    addListener(SWT.FocusOut,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when help events are generated for the control,
 * by sending it one of the messages defined in the
 * <code>HelpListener</code> interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see HelpListener
 * @see #removeHelpListener
 */
public void addHelpListener (HelpListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Help, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when keys are pressed and released on the system keyboard, by sending
 * it one of the messages defined in the <code>KeyListener</code>
 * interface.
 * <p>
 * When a key listener is added to a control, the control
 * will take part in widget traversal.  By default, all
 * traversal keys (such as the tab key and so on) are
 * delivered to the control.  In order for a control to take
 * part in traversal, it should listen for traversal events.
 * Otherwise, the user can traverse into a control but not
 * out.  Note that native controls such as table and tree
 * implement key traversal in the operating system.  It is
 * not necessary to add traversal listeners for these controls,
 * unless you want to override the default traversal.
 * </p>
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see KeyListener
 * @see #removeKeyListener
 */
public void addKeyListener(KeyListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener(SWT.KeyUp,typedListener);
    addListener(SWT.KeyDown,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the platform-specific context menu trigger
 * has occurred, by sending it one of the messages defined in
 * the <code>MenuDetectListener</code> interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see MenuDetectListener
 * @see #removeMenuDetectListener
 *
 * @since 3.3
 */
public void addMenuDetectListener (MenuDetectListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.MenuDetect, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when mouse buttons are pressed and released, by sending
 * it one of the messages defined in the <code>MouseListener</code>
 * interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see MouseListener
 * @see #removeMouseListener
 */
public void addMouseListener(MouseListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener(SWT.MouseDown,typedListener);
    addListener(SWT.MouseUp,typedListener);
    addListener(SWT.MouseDoubleClick,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the mouse moves, by sending it one of the
 * messages defined in the <code>MouseMoveListener</code>
 * interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see MouseMoveListener
 * @see #removeMouseMoveListener
 */
public void addMouseMoveListener(MouseMoveListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener(SWT.MouseMove,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the mouse passes or hovers over controls, by sending
 * it one of the messages defined in the <code>MouseTrackListener</code>
 * interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see MouseTrackListener
 * @see #removeMouseTrackListener
 */
public void addMouseTrackListener (MouseTrackListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.MouseEnter,typedListener);
    addListener (SWT.MouseExit,typedListener);
    addListener (SWT.MouseHover,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the mouse wheel is scrolled, by sending
 * it one of the messages defined in the
 * <code>MouseWheelListener</code> interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see MouseWheelListener
 * @see #removeMouseWheelListener
 *
 * @since 3.3
 */
public void addMouseWheelListener (MouseWheelListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.MouseWheel, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the receiver needs to be painted, by sending it
 * one of the messages defined in the <code>PaintListener</code>
 * interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see PaintListener
 * @see #removePaintListener
 */
public void addPaintListener(PaintListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener(SWT.Paint,typedListener);
}

void addRelation (Control control) {
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when traversal events occur, by sending it
 * one of the messages defined in the <code>TraverseListener</code>
 * interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see TraverseListener
 * @see #removeTraverseListener
 */
public void addTraverseListener (TraverseListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Traverse,typedListener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control is moved or resized.
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
 * @see ControlListener
 * @see #addControlListener
 */
public void removeControlListener (ControlListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Move, listener);
    eventTable.unhook (SWT.Resize, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when a drag gesture occurs.
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
 * @see DragDetectListener
 * @see #addDragDetectListener
 *
 * @since 3.3
 */
public void removeDragDetectListener(DragDetectListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.DragDetect, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control gains or loses focus.
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
 * @see FocusListener
 * @see #addFocusListener
 */
public void removeFocusListener(FocusListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.FocusIn, listener);
    eventTable.unhook (SWT.FocusOut, listener);
}
/**
 * Removes the listener from the collection of listeners who will
 * be notified when the help events are generated for the control.
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
 * @see HelpListener
 * @see #addHelpListener
 */
public void removeHelpListener (HelpListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Help, listener);
}
/**
 * Removes the listener from the collection of listeners who will
 * be notified when keys are pressed and released on the system keyboard.
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
 * @see KeyListener
 * @see #addKeyListener
 */
public void removeKeyListener(KeyListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.KeyUp, listener);
    eventTable.unhook (SWT.KeyDown, listener);
}
/**
 * Removes the listener from the collection of listeners who will
 * be notified when the platform-specific context menu trigger has
 * occurred.
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
 * @see MenuDetectListener
 * @see #addMenuDetectListener
 *
 * @since 3.3
 */
public void removeMenuDetectListener (MenuDetectListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.MenuDetect, listener);
}
/**
 * Removes the listener from the collection of listeners who will
 * be notified when mouse buttons are pressed and released.
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
 * @see MouseListener
 * @see #addMouseListener
 */
public void removeMouseListener (MouseListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.MouseDown, listener);
    eventTable.unhook (SWT.MouseUp, listener);
    eventTable.unhook (SWT.MouseDoubleClick, listener);
}
/**
 * Removes the listener from the collection of listeners who will
 * be notified when the mouse moves.
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
 * @see MouseMoveListener
 * @see #addMouseMoveListener
 */
public void removeMouseMoveListener(MouseMoveListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.MouseMove, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the mouse passes or hovers over controls.
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
 * @see MouseTrackListener
 * @see #addMouseTrackListener
 */
public void removeMouseTrackListener(MouseTrackListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.MouseEnter, listener);
    eventTable.unhook (SWT.MouseExit, listener);
    eventTable.unhook (SWT.MouseHover, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the mouse wheel is scrolled.
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
 * @see MouseWheelListener
 * @see #addMouseWheelListener
 *
 * @since 3.3
 */
public void removeMouseWheelListener (MouseWheelListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.MouseWheel, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the receiver needs to be painted.
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
 * @see PaintListener
 * @see #addPaintListener
 */
public void removePaintListener(PaintListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook(SWT.Paint, listener);
}

/*
 * Remove "Labelled by" relations from the receiver.
 */
void removeRelation () {
    if (!isDescribedByLabel ()) return;     /* there will not be any */
    auto accessible = OS.gtk_widget_get_accessible (handle);
    if (accessible is null) return;
    auto set = ATK.atk_object_ref_relation_set (accessible);
    int count = ATK.atk_relation_set_get_n_relations (set);
    for (int i = 0; i < count; i++) {
        auto relation = ATK.atk_relation_set_get_relation (set, 0);
        ATK.atk_relation_set_remove (set, relation);
    }
    OS.g_object_unref (set);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when traversal events occur.
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
 * @see TraverseListener
 * @see #addTraverseListener
 */
public void removeTraverseListener(TraverseListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Traverse, listener);
}

/**
 * Detects a drag and drop gesture.  This method is used
 * to detect a drag gesture when called from within a mouse
 * down listener.
 *
 * <p>By default, a drag is detected when the gesture
 * occurs anywhere within the client area of a control.
 * Some controls, such as tables and trees, override this
 * behavior.  In addition to the operating system specific
 * drag gesture, they require the mouse to be inside an
 * item.  Custom widget writers can use <code>setDragDetect</code>
 * to disable the default detection, listen for mouse down,
 * and then call <code>dragDetect()</code> from within the
 * listener to conditionally detect a drag.
 * </p>
 *
 * @param event the mouse down event
 *
 * @return <code>true</code> if the gesture occurred, and <code>false</code> otherwise.
 *
 * @exception IllegalArgumentException <ul>
 *   <li>ERROR_NULL_ARGUMENT when the event is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DragDetectListener
 * @see #addDragDetectListener
 *
 * @see #getDragDetect
 * @see #setDragDetect
 *
 * @since 3.3
 */
public bool dragDetect (Event event) {
    checkWidget ();
    if (event is null) error (SWT.ERROR_NULL_ARGUMENT);
    return dragDetect (event.button, event.count, event.stateMask, event.x, event.y);
}

/**
 * Detects a drag and drop gesture.  This method is used
 * to detect a drag gesture when called from within a mouse
 * down listener.
 *
 * <p>By default, a drag is detected when the gesture
 * occurs anywhere within the client area of a control.
 * Some controls, such as tables and trees, override this
 * behavior.  In addition to the operating system specific
 * drag gesture, they require the mouse to be inside an
 * item.  Custom widget writers can use <code>setDragDetect</code>
 * to disable the default detection, listen for mouse down,
 * and then call <code>dragDetect()</code> from within the
 * listener to conditionally detect a drag.
 * </p>
 *
 * @param event the mouse down event
 *
 * @return <code>true</code> if the gesture occurred, and <code>false</code> otherwise.
 *
 * @exception IllegalArgumentException <ul>
 *   <li>ERROR_NULL_ARGUMENT when the event is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DragDetectListener
 * @see #addDragDetectListener
 *
 * @see #getDragDetect
 * @see #setDragDetect
 *
 * @since 3.3
 */
public bool dragDetect (MouseEvent event) {
    checkWidget ();
    if (event is null) error (SWT.ERROR_NULL_ARGUMENT);
    return dragDetect (event.button, event.count, event.stateMask, event.x, event.y);
}

bool dragDetect (int button, int count, int stateMask, int x, int y) {
    if (button !is 1 || count !is 1) return false;
    if (!dragDetect (x, y, false, null)) return false;
    return sendDragEvent (button, stateMask, x, y, true);
}

bool dragDetect (int x, int y, bool filter, bool* consume) {
    bool quit = false, dragging = false;
    while (!quit) {
        GdkEvent* eventPtr;
        while (true) {
            eventPtr = OS.gdk_event_get ();
            if (eventPtr !is null) {
                break;
            } else {
                try {Thread.sleep(50);} catch (Exception ex) {}
            }
        }
        switch (cast(int)OS.GDK_EVENT_TYPE (eventPtr)) {
            case OS.GDK_MOTION_NOTIFY: {
                GdkEventMotion* gdkMotionEvent = cast(GdkEventMotion*)eventPtr;
                if ((gdkMotionEvent.state & OS.GDK_BUTTON1_MASK) !is 0) {
                    if (OS.gtk_drag_check_threshold (handle, x, y, cast(int) gdkMotionEvent.x, cast(int) gdkMotionEvent.y)) {
                        dragging = true;
                        quit = true;
                    }
                } else {
                    quit = true;
                }
                int newX, newY;
                OS.gdk_window_get_pointer (gdkMotionEvent.window, &newX, &newY, null);
                break;
            }
            case OS.GDK_KEY_PRESS:
            case OS.GDK_KEY_RELEASE: {
                GdkEventKey* gdkEvent = cast(GdkEventKey*)eventPtr;
                if (gdkEvent.keyval is OS.GDK_Escape) quit = true;
                break;
            }
            case OS.GDK_BUTTON_RELEASE:
            case OS.GDK_BUTTON_PRESS:
            case OS.GDK_2BUTTON_PRESS:
            case OS.GDK_3BUTTON_PRESS: {
                OS.gdk_event_put (eventPtr);
                quit = true;
                break;
            }
            default:
                OS.gtk_main_do_event (eventPtr);
        }
        OS.gdk_event_free (eventPtr);
    }
    return dragging;
}

bool filterKey (int keyval, GdkEventKey* event) {
    auto imHandle = imHandle ();
    if (imHandle !is null) {
        return cast(bool)OS.gtk_im_context_filter_keypress (imHandle, event);
    }
    return false;
}

Control findBackgroundControl () {
    if ((state & BACKGROUND) !is 0 || backgroundImage !is null) return this;
    return (state & PARENT_BACKGROUND) !is 0 ? parent.findBackgroundControl () : null;
}

Menu [] findMenus (Control control) {
    if (menu !is null && this !is control) return [menu];
    return new Menu [0];
}

void fixChildren (Shell newShell, Shell oldShell, Decorations newDecorations, Decorations oldDecorations, Menu [] menus) {
    oldShell.fixShell (newShell, this);
    oldDecorations.fixDecorations (newDecorations, this, menus);
}

override int fixedMapProc (GtkWidget* widget) {
    OS.GTK_WIDGET_SET_FLAGS (widget, OS.GTK_MAPPED);
    auto widgetList = OS.gtk_container_get_children (cast(GtkContainer*)widget);
    if (widgetList !is null) {
        auto widgets = widgetList;
        while (widgets !is null) {
            auto child = cast(GtkWidget*)OS.g_list_data (widgets);
            if (OS.GTK_WIDGET_VISIBLE (child) && OS.gtk_widget_get_child_visible (child) && !OS.GTK_WIDGET_MAPPED (child)) {
                OS.gtk_widget_map (child);
            }
            widgets = cast(GList*)OS.g_list_next (widgets);
        }
        OS.g_list_free (widgetList);
    }
    if ((OS.GTK_WIDGET_FLAGS (widget) & OS.GTK_NO_WINDOW) is 0) {
        OS.gdk_window_show_unraised (OS.GTK_WIDGET_WINDOW (widget));
    }
    return 0;
}

void fixModal(GtkWidget* group, GtkWidget* modalGroup) {
}

/**
 * Forces the receiver to have the <em>keyboard focus</em>, causing
 * all keyboard events to be delivered to it.
 *
 * @return <code>true</code> if the control got focus, and <code>false</code> if it was unable to.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setFocus
 */
public bool forceFocus () {
    checkWidget();
    if (display.focusEvent is SWT.FocusOut) return false;
    Shell shell = getShell ();
    shell.setSavedFocus (this);
    if (!isEnabled () || !isVisible ()) return false;
    shell.bringToTop (false);
    return forceFocus (focusHandle ());
}

bool forceFocus (GtkWidget* focusHandle_) {
    /* When the control is zero sized it must be realized */
    OS.gtk_widget_realize (focusHandle_);
    OS.gtk_widget_grab_focus (focusHandle_);
    Shell shell = getShell ();
    auto shellHandle = shell.shellHandle;
    auto handle = OS.gtk_window_get_focus (cast(GtkWindow*)shellHandle);
    while (handle !is null) {
        if (handle is focusHandle_) return true;
        Widget widget = display.getWidget (handle);
        if (widget !is null && (null !is cast(Control)widget)) {
            return widget is this;
        }
        handle = OS.gtk_widget_get_parent (handle);
    }
    return false;
}

/**
 * Returns the receiver's background color.
 *
 * @return the background color
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Color getBackground () {
    checkWidget();
    Control control = findBackgroundControl ();
    if (control is null) control = this;
    return Color.gtk_new (display, control.getBackgroundColor ());
}

GdkColor* getBackgroundColor () {
    return getBgColor ();
}

/**
 * Returns the receiver's background image.
 *
 * @return the background image
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public Image getBackgroundImage () {
    checkWidget ();
    Control control = findBackgroundControl ();
    if (control is null) control = this;
    return control.backgroundImage;
}

GdkColor* getBgColor () {
    auto fontHandle_ = fontHandle ();
    OS.gtk_widget_realize (fontHandle_);
    GdkColor* color = new GdkColor ();
    OS.gtk_style_get_bg (OS.gtk_widget_get_style (fontHandle_), OS.GTK_STATE_NORMAL, color);
    return color;
}

GdkColor* getBaseColor () {
    auto fontHandle_ = fontHandle ();
    OS.gtk_widget_realize (fontHandle_);
    GdkColor* color = new GdkColor ();
    OS.gtk_style_get_base (OS.gtk_widget_get_style (fontHandle_), OS.GTK_STATE_NORMAL, color);
    return color;
}

/**
 * Returns the receiver's border width.
 *
 * @return the border width
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getBorderWidth () {
    checkWidget();
    return 0;
}

int getClientWidth () {
    return 0;
}

/**
 * Returns the receiver's cursor, or null if it has not been set.
 * <p>
 * When the mouse pointer passes over a control its appearance
 * is changed to match the control's cursor.
 * </p>
 *
 * @return the receiver's cursor or <code>null</code>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.3
 */
public Cursor getCursor () {
    checkWidget ();
    return cursor;
}

/**
 * Returns <code>true</code> if the receiver is detecting
 * drag gestures, and  <code>false</code> otherwise.
 *
 * @return the receiver's drag detect state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.3
 */
public bool getDragDetect () {
    checkWidget ();
    return (state & DRAG_DETECT) !is 0;
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
    checkWidget ();
    return (state & DISABLED) is 0;
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
    return font !is null ? font : defaultFont ();
}

PangoFontDescription* getFontDescription () {
    auto fontHandle_ = fontHandle ();
    OS.gtk_widget_realize (fontHandle_);
    return OS.gtk_style_get_font_desc (OS.gtk_widget_get_style (fontHandle_));
}

/**
 * Returns the foreground color that the receiver will use to draw.
 *
 * @return the receiver's foreground color
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Color getForeground () {
    checkWidget();
    return Color.gtk_new (display, getForegroundColor ());
}

GdkColor* getForegroundColor () {
    return getFgColor ();
}

GdkColor* getFgColor () {
    auto fontHandle_ = fontHandle ();
    OS.gtk_widget_realize (fontHandle_);
    GdkColor* color = new GdkColor ();
    OS.gtk_style_get_fg (OS.gtk_widget_get_style (fontHandle_), OS.GTK_STATE_NORMAL, color);
    return color;
}

Point getIMCaretPos () {
    return new Point (0, 0);
}

GdkColor* getTextColor () {
    auto fontHandle_ = fontHandle ();
    OS.gtk_widget_realize (fontHandle_);
    GdkColor* color = new GdkColor ();
    OS.gtk_style_get_text (OS.gtk_widget_get_style (fontHandle_), OS.GTK_STATE_NORMAL, color);
    return color;
}

/**
 * Returns layout data which is associated with the receiver.
 *
 * @return the receiver's layout data
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Object getLayoutData () {
    checkWidget();
    return layoutData;
}

/**
 * Returns the receiver's pop up menu if it has one, or null
 * if it does not. All controls may optionally have a pop up
 * menu that is displayed when the user requests one for
 * the control. The sequence of key strokes, button presses
 * and/or button releases that are used to request a pop up
 * menu is platform specific.
 *
 * @return the receiver's menu
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Menu getMenu () {
    checkWidget();
    return menu;
}

/**
 * Returns the receiver's monitor.
 *
 * @return the receiver's monitor
 *
 * @since 3.0
 */
public org.eclipse.swt.widgets.Monitor.Monitor getMonitor () {
    checkWidget();
    org.eclipse.swt.widgets.Monitor.Monitor monitor = null;
    auto screen = OS.gdk_screen_get_default ();
    if (screen !is null) {
        int monitorNumber = OS.gdk_screen_get_monitor_at_window (screen, paintWindow ());
        GdkRectangle dest;
        OS.gdk_screen_get_monitor_geometry (screen, monitorNumber, &dest);
        monitor = new org.eclipse.swt.widgets.Monitor.Monitor ();
        monitor.handle = monitorNumber;
        monitor.x = dest.x;
        monitor.y = dest.y;
        monitor.width = dest.width;
        monitor.height = dest.height;
        Rectangle workArea = null;
        if (monitorNumber is 0) workArea = display.getWorkArea ();
        if (workArea !is null) {
            monitor.clientX = workArea.x;
            monitor.clientY = workArea.y;
            monitor.clientWidth = workArea.width;
            monitor.clientHeight = workArea.height;
        } else {
            monitor.clientX = monitor.x;
            monitor.clientY = monitor.y;
            monitor.clientWidth = monitor.width;
            monitor.clientHeight = monitor.height;
        }
    } else {
        monitor = display.getPrimaryMonitor ();
    }
    return monitor;
}

/**
 * Returns the receiver's parent, which must be a <code>Composite</code>
 * or null when the receiver is a shell that was created with null or
 * a display for a parent.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Composite getParent () {
    checkWidget();
    return parent;
}

Control [] getPath () {
    int count = 0;
    Shell shell = getShell ();
    Control control = this;
    while (control !is shell) {
        count++;
        control = control.parent;
    }
    control = this;
    Control [] result = new Control [count];
    while (control !is shell) {
        result [--count] = control;
        control = control.parent;
    }
    return result;
}

/**
 * Returns the region that defines the shape of the control,
 * or null if the control has the default shape.
 *
 * @return the region that defines the shape of the shell (or null)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public Region getRegion () {
    checkWidget ();
    return region;
}

/**
 * Returns the receiver's shell. For all controls other than
 * shells, this simply returns the control's nearest ancestor
 * shell. Shells return themselves, even if they are children
 * of other shells.
 *
 * @return the receiver's shell
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getParent
 */
public Shell getShell() {
    checkWidget();
    return _getShell();
}

Shell _getShell() {
    return parent._getShell();
}

/**
 * Returns the receiver's tool tip text, or null if it has
 * not been set.
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
    return (state & HIDDEN) is 0;
}

override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* event) {
    return gtk_button_press_event (widget, event, true);
}

int gtk_button_press_event (GtkWidget* widget, GdkEventButton* gdkEvent, bool sendMouseDown) {
    if (gdkEvent.type is OS.GDK_3BUTTON_PRESS) return 0;

    /*
    * When a shell is created with SWT.ON_TOP and SWT.NO_FOCUS,
    * do not activate the shell when the user clicks on the
    * the client area or on the border or a control within the
    * shell that does not take focus.
    */
    Shell shell = _getShell ();
    if (((shell.style & SWT.ON_TOP) !is 0) && (((shell.style & SWT.NO_FOCUS) is 0) || ((style & SWT.NO_FOCUS) is 0))) {
        shell.forceActive();
    }
    int result = 0;
    if (gdkEvent.type is OS.GDK_BUTTON_PRESS) {
        display.clickCount = 1;
        auto nextEvent = OS.gdk_event_peek ();
        if (nextEvent !is null) {
            int eventType = OS.GDK_EVENT_TYPE (nextEvent);
            if (eventType is OS.GDK_2BUTTON_PRESS) display.clickCount = 2;
            if (eventType is OS.GDK_3BUTTON_PRESS) display.clickCount = 3;
            OS.gdk_event_free (nextEvent);
        }
        bool dragging = false;
        if ((state & DRAG_DETECT) !is 0 && hooks (SWT.DragDetect)) {
            if (gdkEvent.button is 1) {
                bool consume = false;
                if (dragDetect (cast(int) gdkEvent.x, cast(int) gdkEvent.y, true, &consume)) {
                    dragging = true;
                    if (consume ) result = 1;
                }
                if (isDisposed ()) return 1;
            }
        }
        if (sendMouseDown && !sendMouseEvent (SWT.MouseDown, gdkEvent.button, display.clickCount, 0, false, gdkEvent.time, gdkEvent.x_root, gdkEvent.y_root, false, gdkEvent.state)) {
            result = 1;
        }
        if (isDisposed ()) return 1;
        if (dragging) {
            sendDragEvent (gdkEvent.button, gdkEvent.state, cast(int)gdkEvent.x, cast(int)gdkEvent.y, false);
            if (isDisposed ()) return 1;
        }
        /*
        * Pop up the context menu in the button press event for widgets
        * that have default operating system menus in order to stop the
        * operating system from displaying the menu if necessary.
        */
        if ((state & MENU) !is 0) {
            if (gdkEvent.button is 3) {
                if (showMenu (cast(int)gdkEvent.x_root, cast(int)gdkEvent.y_root)) {
                    result = 1;
                }
            }
        }
    } else {
        display.clickCount = 2;
        result = sendMouseEvent (SWT.MouseDoubleClick, gdkEvent.button, display.clickCount, 0, false, gdkEvent.time, gdkEvent.x_root, gdkEvent.y_root, false, gdkEvent.state) ? 0 : 1;
        if (isDisposed ()) return 1;
    }
    if (!shell.isDisposed ()) shell.setActiveControl (this);
    return result;
}

override int gtk_button_release_event (GtkWidget* widget, GdkEventButton* gdkEvent) {
    /*
    * Feature in GTK.  When button 4, 5, 6, or 7 is released, GTK
    * does not deliver a corresponding GTK event.  Button 6 and 7
    * are mapped to buttons 4 and 5 in SWT.  The fix is to change
    * the button number of the event to a negative number so that
    * it gets dispatched by GTK.  SWT has been modified to look
    * for negative button numbers.
    */
    int button = gdkEvent.button;
    switch (button) {
        case -6: button = 4; break;
        case -7: button = 5; break;
        default:
    }
    return sendMouseEvent (SWT.MouseUp, button, display.clickCount, 0, false, gdkEvent.time, gdkEvent.x_root, gdkEvent.y_root, false, gdkEvent.state) ? 0 : 1;
}

override int gtk_commit (GtkIMContext* imcontext, char* text) {
    char [] chars = fromStringz( text );
    if (chars.length is 0) return 0;
    sendIMKeyEvent (SWT.KeyDown, null, chars);
    return 0;
}

override int gtk_enter_notify_event (GtkWidget*  widget, GdkEventCrossing* gdkEvent) {
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 12, 0)) {
        /*
         * Feature in GTK. Children of a shell will inherit and display the shell's
         * tooltip if they do not have a tooltip of their own. The fix is to use the
         * new tooltip API in GTK 2.12 to null the shell's tooltip when the control
         * being entered does not have any tooltip text set.
         */
        char* buffer = null;
        if (toolTipText !is null && toolTipText.length !is 0) {
            char [] chars = fixMnemonic (toolTipText, false);
            buffer = toStringz(chars);
        }
        auto toolHandle = getShell().handle;
        OS.gtk_widget_set_tooltip_text (toolHandle, buffer);
    }
    if (display.currentControl is this) return 0;
    if (gdkEvent.mode !is OS.GDK_CROSSING_NORMAL && gdkEvent.mode !is OS.GDK_CROSSING_UNGRAB) return 0;
    if ((gdkEvent.state & (OS.GDK_BUTTON1_MASK | OS.GDK_BUTTON2_MASK | OS.GDK_BUTTON3_MASK)) !is 0) return 0;
    if (display.currentControl !is null && !display.currentControl.isDisposed ()) {
        display.removeMouseHoverTimeout (display.currentControl.handle);
        display.currentControl.sendMouseEvent (SWT.MouseExit,  0, gdkEvent.time, gdkEvent.x_root, gdkEvent.y_root, false, gdkEvent.state);
    }
    if (!isDisposed ()) {
        display.currentControl = this;
        return sendMouseEvent (SWT.MouseEnter, 0, gdkEvent.time, gdkEvent.x_root, gdkEvent.y_root, false, gdkEvent.state) ? 0 : 1;
    }
    return 0;
}

override int gtk_event_after (GtkWidget*  widget, GdkEvent* gdkEvent) {
    GdkEventButton* gdkEventButton = null;
    GdkEventFocus* gdkEventFocus = null;
    Display display = null;
    switch (cast(int)gdkEvent.type) {
        case OS.GDK_BUTTON_PRESS: {
            if (widget !is eventHandle ()) break;
            /*
            * Pop up the context menu in the event_after signal to allow
            * the widget to process the button press.  This allows widgets
            * such as GtkTreeView to select items before a menu is shown.
            */
            if ((state & MENU) is 0) {
                gdkEventButton = cast(GdkEventButton*)gdkEvent;
                if (gdkEventButton.button is 3) {
                    showMenu (cast(int) gdkEventButton.x_root, cast(int) gdkEventButton.y_root);
                }
            }
            break;
        }
        case OS.GDK_FOCUS_CHANGE: {
            if (!isFocusHandle (widget)) break;
            gdkEventFocus = cast(GdkEventFocus*)gdkEvent;

            /*
             * Feature in GTK. The GTK combo box popup under some window managers
             * is implemented as a GTK_MENU.  When it pops up, it causes the combo
             * box to lose focus when focus is received for the menu.  The
             * fix is to check the current grab handle and see if it is a GTK_MENU
             * and ignore the focus event when the menu is both shown and hidden.
             */
            display = this.display;
            if (gdkEventFocus.in_ !is 0) {
                if (display.ignoreFocus) {
                    display.ignoreFocus = false;
                    break;
                }
            } else {
                display.ignoreFocus = false;
                auto grabHandle = OS.gtk_grab_get_current ();
                if (grabHandle !is null) {
                    if (OS.G_OBJECT_TYPE ( cast(GTypeInstance*)grabHandle) is OS.GTK_TYPE_MENU ()) {
                        display.ignoreFocus = true;
                        break;
                    }
                }
            }

            sendFocusEvent (gdkEventFocus.in_ !is 0 ? SWT.FocusIn : SWT.FocusOut);
            break;
        default:
        }
    }
    return 0;
}

override int gtk_expose_event (GtkWidget*  widget, GdkEventExpose* gdkEvent) {
    if ((state & OBSCURED) !is 0) return 0;
    if (!hooks (SWT.Paint) && !filters (SWT.Paint)) return 0;
    Event event = new Event ();
    event.count = gdkEvent.count;
    event.x = gdkEvent.area.x;
    event.y = gdkEvent.area.y;
    event.width = gdkEvent.area.width;
    event.height = gdkEvent.area.height;
    if ((style & SWT.MIRRORED) !is 0) event.x = getClientWidth () - event.width - event.x;
    GCData data = new GCData ();
    data.damageRgn = gdkEvent.region;
    GC gc = event.gc = GC.gtk_new (this, data);
    OS.gdk_gc_set_clip_region (gc.handle, gdkEvent.region);
    sendEvent (SWT.Paint, event);
    gc.dispose ();
    event.gc = null;
    return 0;
}

override int gtk_focus (GtkWidget* widget, ptrdiff_t directionType) {
    /* Stop GTK traversal for every widget */
    return 1;
}

override int gtk_focus_in_event (GtkWidget*  widget, GdkEventFocus* event) {
    // widget could be disposed at this point
    if (handle !is null) {
        Control oldControl = display.imControl;
        if (oldControl !is this)  {
            if (oldControl !is null && !oldControl.isDisposed ()) {
                auto oldIMHandle = oldControl.imHandle ();
                if (oldIMHandle !is null) OS.gtk_im_context_reset (oldIMHandle);
            }
        }
        if (hooks (SWT.KeyDown) || hooks (SWT.KeyUp)) {
            auto imHandle = imHandle ();
            if (imHandle !is null) OS.gtk_im_context_focus_in (imHandle);
        }
    }
    return 0;
}

override int gtk_focus_out_event (GtkWidget* widget, GdkEventFocus* event) {
    // widget could be disposed at this point
    if (handle !is null) {
        if (hooks (SWT.KeyDown) || hooks (SWT.KeyUp)) {
            auto imHandle = imHandle ();
            if (imHandle !is null) {
                OS.gtk_im_context_focus_out (imHandle);
            }
        }
    }
    return 0;
}

override int gtk_key_press_event (GtkWidget*  widget, GdkEventKey* gdkEvent) {
    if (!hasFocus ()) return 0;

    if (translateMnemonic (gdkEvent.keyval, gdkEvent)) return 1;
    // widget could be disposed at this point
    if (isDisposed ()) return 0;

    if (filterKey (gdkEvent.keyval, gdkEvent)) return 1;
    // widget could be disposed at this point
    if (isDisposed ()) return 0;

    if (translateTraversal (gdkEvent)) return 1;
    // widget could be disposed at this point
    if (isDisposed ()) return 0;
    return super.gtk_key_press_event (widget, gdkEvent);
}

override int gtk_key_release_event (GtkWidget*  widget, GdkEventKey* event) {
    if (!hasFocus ()) return 0;
    auto imHandle = imHandle ();
    if (imHandle !is null) {
        if (OS.gtk_im_context_filter_keypress (imHandle, event)) return 1;
    }
    return super.gtk_key_release_event (widget, event);
}

override int gtk_leave_notify_event (GtkWidget* widget, GdkEventCrossing* gdkEvent) {
    if (display.currentControl !is this) return 0;
    display.removeMouseHoverTimeout (handle);
    int result = 0;
    if (sendLeaveNotify () || display.getCursorControl () is null) {
        if (gdkEvent.mode !is OS.GDK_CROSSING_NORMAL && gdkEvent.mode !is OS.GDK_CROSSING_UNGRAB) return 0;
        if ((gdkEvent.state & (OS.GDK_BUTTON1_MASK | OS.GDK_BUTTON2_MASK | OS.GDK_BUTTON3_MASK)) !is 0) return 0;
        result = sendMouseEvent (SWT.MouseExit, 0, gdkEvent.time, gdkEvent.x_root, gdkEvent.y_root, false, gdkEvent.state) ? 0 : 1;
        display.currentControl = null;
    }
    return result;
}

override int gtk_mnemonic_activate (GtkWidget* widget, ptrdiff_t arg1) {
    int result = 0;
    auto eventPtr = OS.gtk_get_current_event ();
    if (eventPtr !is null) {
        GdkEventKey* keyEvent = cast(GdkEventKey*)eventPtr;
        if (keyEvent.type is OS.GDK_KEY_PRESS) {
            Control focusControl = display.getFocusControl ();
            auto focusHandle_ = focusControl !is null ? focusControl.focusHandle () : null;
            if (focusHandle_ !is null) {
                display.mnemonicControl = this;
                OS.gtk_widget_event (focusHandle_, eventPtr);
                display.mnemonicControl = null;
            }
            result = 1;
        }
        OS.gdk_event_free (eventPtr);
    }
    return result;
}

override int gtk_motion_notify_event (GtkWidget* widget, GdkEventMotion* gdkEvent) {
    if (this is display.currentControl && (hooks (SWT.MouseHover) || filters (SWT.MouseHover))) {
        display.addMouseHoverTimeout (handle);
    }
    double x = gdkEvent.x_root, y = gdkEvent.y_root;
    int state = gdkEvent.state;
    if (gdkEvent.is_hint !is 0) {
        int pointer_x, pointer_y;
        int mask;
        auto window = eventWindow ();
        OS.gdk_window_get_pointer (window, &pointer_x, &pointer_y, &mask);
        x = pointer_x;
        y = pointer_y;
        state = mask;
    }
    int result = sendMouseEvent (SWT.MouseMove, 0, gdkEvent.time, x, y, gdkEvent.is_hint !is 0, state) ? 0 : 1;
    return result;
}

override int gtk_popup_menu (GtkWidget* widget) {
    if (!hasFocus()) return 0;
    int x, y ;
    OS.gdk_window_get_pointer (null, &x, &y, null);
    return showMenu (x, y) ? 1 : 0;
}

override int gtk_preedit_changed (GtkIMContext* imcontext) {
    display.showIMWindow (this);
    return 0;
}

override int gtk_realize (GtkWidget* widget) {
    auto imHandle = imHandle ();
    if (imHandle !is null) {
        auto window = OS.GTK_WIDGET_WINDOW (paintHandle ());
        OS.gtk_im_context_set_client_window (imHandle, window);
    }
    if (backgroundImage !is null) {
        auto window = OS.GTK_WIDGET_WINDOW (paintHandle ());
        if (window !is null) OS.gdk_window_set_back_pixmap (window, cast(GdkPixmap*)backgroundImage.pixmap, false);
    }
    return 0;
}

override int gtk_scroll_event (GtkWidget* widget, GdkEventScroll* gdkEvent) {
    switch (gdkEvent.direction) {
        case OS.GDK_SCROLL_UP:
            return sendMouseEvent (SWT.MouseWheel, 0, 3, SWT.SCROLL_LINE, true, gdkEvent.time, gdkEvent.x_root, gdkEvent.y_root, false, gdkEvent.state) ? 0 : 1;
        case OS.GDK_SCROLL_DOWN:
            return sendMouseEvent (SWT.MouseWheel, 0, -3, SWT.SCROLL_LINE, true, gdkEvent.time, gdkEvent.x_root, gdkEvent.y_root, false, gdkEvent.state) ? 0 : 1;
        case OS.GDK_SCROLL_LEFT:
            return sendMouseEvent (SWT.MouseDown, 4, gdkEvent.time, gdkEvent.x_root, gdkEvent.y_root, false, gdkEvent.state) ? 0 : 1;
        case OS.GDK_SCROLL_RIGHT:
            return sendMouseEvent (SWT.MouseDown, 5, gdkEvent.time, gdkEvent.x_root, gdkEvent.y_root, false, gdkEvent.state) ? 0 : 1;
        default:
    }
    return 0;
}

override int gtk_show_help (GtkWidget* widget, ptrdiff_t helpType) {
    if (!hasFocus ()) return 0;
    return sendHelpEvent (helpType) ? 1 : 0;
}

override int gtk_style_set (GtkWidget* widget, ptrdiff_t previousStyle) {
    if (backgroundImage !is null) {
        setBackgroundPixmap (backgroundImage.pixmap);
    }
    return 0;
}

override int gtk_unrealize (GtkWidget* widget) {
    auto imHandle = imHandle ();
    if (imHandle !is null) OS.gtk_im_context_set_client_window (imHandle, null);
    return 0;
}

override int gtk_visibility_notify_event (GtkWidget* widget, GdkEventVisibility* gdkEvent) {
    auto paintWindow = paintWindow();
    auto window = gdkEvent.window;
    if (window is paintWindow) {
        if (gdkEvent.state is OS.GDK_VISIBILITY_FULLY_OBSCURED) {
            state |= OBSCURED;
        } else {
            if ((state & OBSCURED) !is 0) {
                int width, height;
                OS.gdk_drawable_get_size (cast(GdkDrawable*)window, &width, &height);
                GdkRectangle rect;
                rect.width = width;
                rect.height = height;
                OS.gdk_window_invalidate_rect (window, &rect, false);
            }
            state &= ~OBSCURED;
        }
    }
    return 0;
}

/*no override*/ void gtk_widget_size_request (GtkWidget* widget, GtkRequisition* requisition) {
    OS.gtk_widget_size_request (widget, requisition);
}

/**
 * Invokes platform specific functionality to allocate a new GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Control</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param data the platform specific GC data
 * @return the platform specific GC handle
 */
public GdkGC* internal_new_GC (GCData data) {
    checkWidget ();
    auto window = paintWindow ();
    if (window is null) SWT.error (SWT.ERROR_NO_HANDLES);
    auto gdkGC = OS.gdk_gc_new (cast(GdkDrawable*)window);
    if (gdkGC is null) error (SWT.ERROR_NO_HANDLES);
    if (data !is null) {
        int mask = SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT;
        if ((data.style & mask) is 0) {
            data.style |= style & (mask | SWT.MIRRORED);
        } else {
            if ((data.style & SWT.RIGHT_TO_LEFT) !is 0) {
                data.style |= SWT.MIRRORED;
            }
        }
        data.drawable = cast(GdkDrawable*)window;
        data.device = display;
        data.foreground = getForegroundColor ();
        Control control = findBackgroundControl ();
        if (control is null) control = this;
        data.background = control.getBackgroundColor ();
        data.font = font !is null ? font : defaultFont ();
    }
    return gdkGC;
}

GtkIMContext* imHandle () {
    return null;
}

/**
 * Invokes platform specific functionality to dispose a GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Control</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param hDC the platform specific GC handle
 * @param data the platform specific GC data
 */
public void internal_dispose_GC (GdkGC* gdkGC, GCData data) {
    checkWidget ();
    OS.g_object_unref (gdkGC);
}

/**
 * Returns <code>true</code> if the underlying operating
 * system supports this reparenting, otherwise <code>false</code>
 *
 * @return <code>true</code> if the widget can be reparented, otherwise <code>false</code>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool isReparentable () {
    checkWidget();
    return true;
}
bool isShowing () {
    /*
    * This is not complete.  Need to check if the
    * widget is obscurred by a parent or sibling.
    */
    if (!isVisible ()) return false;
    Control control = this;
    while (control !is null) {
        Point size = control.getSize ();
        if (size.x is 0 || size.y is 0) {
            return false;
        }
        control = control.parent;
    }
    return true;
}
bool isTabGroup () {
    Control [] tabList = parent._getTabList ();
    if (tabList !is null) {
        for (int i=0; i<tabList.length; i++) {
            if (tabList [i] is this) return true;
        }
    }
    int code = traversalCode (0, null);
    if ((code & (SWT.TRAVERSE_ARROW_PREVIOUS | SWT.TRAVERSE_ARROW_NEXT)) !is 0) return false;
    return (code & (SWT.TRAVERSE_TAB_PREVIOUS | SWT.TRAVERSE_TAB_NEXT)) !is 0;
}
bool isTabItem () {
    Control [] tabList = parent._getTabList ();
    if (tabList !is null) {
        for (int i=0; i<tabList.length; i++) {
            if (tabList [i] is this) return false;
        }
    }
    int code = traversalCode (0, null);
    return (code & (SWT.TRAVERSE_ARROW_PREVIOUS | SWT.TRAVERSE_ARROW_NEXT)) !is 0;
}

/**
 * Returns <code>true</code> if the receiver is enabled and all
 * ancestors up to and including the receiver's nearest ancestor
 * shell are enabled.  Otherwise, <code>false</code> is returned.
 * A disabled control is typically not selectable from the user
 * interface and draws with an inactive or "grayed" look.
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
    checkWidget ();
    return getEnabled () && parent.isEnabled ();
}

bool isFocusAncestor (Control control) {
    while (control !is null && control !is this && !( null !is cast(Shell)control )) {
        control = control.parent;
    }
    return control is this;
}

/**
 * Returns <code>true</code> if the receiver has the user-interface
 * focus, and <code>false</code> otherwise.
 *
 * @return the receiver's focus state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool isFocusControl () {
    checkWidget();
    Control focusControl = display.focusControl;
    if (focusControl !is null && !focusControl.isDisposed ()) {
        return this is focusControl;
    }
    return hasFocus ();
}

/**
 * Returns <code>true</code> if the receiver is visible and all
 * ancestors up to and including the receiver's nearest ancestor
 * shell are visible. Otherwise, <code>false</code> is returned.
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
    return getVisible () && parent.isVisible ();
}

Decorations menuShell () {
    return parent.menuShell ();
}

bool mnemonicHit (wchar key) {
    return false;
}

bool mnemonicMatch (wchar key) {
    return false;
}

override void register () {
    super.register ();
    if (fixedHandle !is null) display.addWidget (fixedHandle, this);
    auto imHandle = imHandle ();
    if (imHandle !is null) display.addWidget (cast(GtkWidget*)imHandle, this);
}

/**
 * Causes the entire bounds of the receiver to be marked
 * as needing to be redrawn. The next time a paint request
 * is processed, the control will be completely painted,
 * including the background.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #update()
 * @see PaintListener
 * @see SWT#Paint
 * @see SWT#NO_BACKGROUND
 * @see SWT#NO_REDRAW_RESIZE
 * @see SWT#NO_MERGE_PAINTS
 * @see SWT#DOUBLE_BUFFERED
 */
public void redraw () {
    checkWidget();
    redraw (false);
}

void redraw (bool all) {
//  checkWidget();
    if (!OS.GTK_WIDGET_VISIBLE (topHandle ())) return;
    redrawWidget (0, 0, 0, 0, true, all, false);
}

/**
 * Causes the rectangular area of the receiver specified by
 * the arguments to be marked as needing to be redrawn.
 * The next time a paint request is processed, that area of
 * the receiver will be painted, including the background.
 * If the <code>all</code> flag is <code>true</code>, any
 * children of the receiver which intersect with the specified
 * area will also paint their intersecting areas. If the
 * <code>all</code> flag is <code>false</code>, the children
 * will not be painted.
 *
 * @param x the x coordinate of the area to draw
 * @param y the y coordinate of the area to draw
 * @param width the width of the area to draw
 * @param height the height of the area to draw
 * @param all <code>true</code> if children should redraw, and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #update()
 * @see PaintListener
 * @see SWT#Paint
 * @see SWT#NO_BACKGROUND
 * @see SWT#NO_REDRAW_RESIZE
 * @see SWT#NO_MERGE_PAINTS
 * @see SWT#DOUBLE_BUFFERED
 */
public void redraw (int x, int y, int width, int height, bool all) {
    checkWidget();
    if (!OS.GTK_WIDGET_VISIBLE (topHandle ())) return;
    if ((style & SWT.MIRRORED) !is 0) x = getClientWidth () - width - x;
    redrawWidget (x, y, width, height, false, all, false);
}

void redrawChildren () {
}

void redrawWidget (int x, int y, int width, int height, bool redrawAll, bool all, bool trim) {
    if ((OS.GTK_WIDGET_FLAGS (handle) & OS.GTK_REALIZED) is 0) return;
    auto window = paintWindow ();
    GdkRectangle rect;
    if (redrawAll) {
        int w, h;
        OS.gdk_drawable_get_size (cast(GdkDrawable*)window, &w, &h);
        rect.width = w;
        rect.height = h;
    } else {
        rect.x = x;
        rect.y = y;
        rect.width = width;
        rect.height = height;
    }
    OS.gdk_window_invalidate_rect (window, &rect, all);
}

override void release (bool destroy) {
    Control next = null, previous = null;
    if (destroy && parent !is null) {
        Control[] children = parent._getChildren ();
        int index = 0;
        while (index < children.length) {
            if (children [index] is this) break;
            index++;
        }
        if (0 < index && (index + 1) < children.length) {
            next = children [index + 1];
            previous = children [index - 1];
        }
    }
    super.release (destroy);
    if (destroy) {
        if (previous !is null) previous.addRelation (next);
    }
}

override void releaseHandle () {
    super.releaseHandle ();
    fixedHandle = null;
    parent = null;
}

override void releaseParent () {
    parent.removeControl (this);
}

override void releaseWidget () {
    super.releaseWidget ();
    if (display.currentControl is this) display.currentControl = null;
    display.removeMouseHoverTimeout (handle);
    auto imHandle = imHandle ();
    if (imHandle !is null) {
        OS.gtk_im_context_reset (imHandle);
        OS.gtk_im_context_set_client_window (imHandle, null);
    }
    if (enableWindow !is null) {
        OS.gdk_window_set_user_data (enableWindow, null);
        OS.gdk_window_destroy (enableWindow);
        enableWindow = null;
    }
    redrawWindow = null;
    if (menu !is null && !menu.isDisposed ()) {
        menu.dispose ();
    }
    menu = null;
    cursor = null;
    toolTipText = null;
    layoutData = null;
    accessible = null;
    region = null;
}

bool sendDragEvent (int button, int stateMask, int x, int y, bool isStateMask) {
    Event event = new Event ();
    event.button = button;
    event.x = x;
    event.y = y;
    if ((style & SWT.MIRRORED) !is 0) event.x = getClientWidth () - event.x;
    if (isStateMask) {
        event.stateMask = stateMask;
    } else {
        setInputState (event, stateMask);
    }
    postEvent (SWT.DragDetect, event);
    if (isDisposed ()) return false;
    return event.doit;
}

void sendFocusEvent (int type) {
    Shell shell = _getShell ();
    Display display = this.display;
    display.focusControl = this;
    display.focusEvent = type;
    sendEvent (type);
    display.focusControl = null;
    display.focusEvent = SWT.None;
    /*
    * It is possible that the shell may be
    * disposed at this point.  If this happens
    * don't send the activate and deactivate
    * events.
    */
    if (!shell.isDisposed ()) {
        switch (type) {
            case SWT.FocusIn:
                shell.setActiveControl (this);
                break;
            case SWT.FocusOut:
                if (shell !is display.activeShell) {
                    shell.setActiveControl (null);
                }
                break;
            default:
        }
    }
}

bool sendHelpEvent (ptrdiff_t helpType) {
    Control control = this;
    while (control !is null) {
        if (control.hooks (SWT.Help)) {
            control.postEvent (SWT.Help);
            return true;
        }
        control = control.parent;
    }
    return false;
}

bool sendLeaveNotify() {
    return false;
}

bool sendMouseEvent (int type, int button, int time, double x, double y, bool is_hint, int state) {
    return sendMouseEvent (type, button, 0, 0, false, time, x, y, is_hint, state);
}

bool sendMouseEvent (int type, int button, int count, int detail, bool send, int time, double x, double y, bool is_hint, int state) {
    if (!hooks (type) && !filters (type)) return true;
    Event event = new Event ();
    event.time = time;
    event.button = button;
    event.detail = detail;
    event.count = count;
    if (is_hint) {
        event.x = cast(int)x;
        event.y = cast(int)y;
    } else {
        auto window = eventWindow ();
        int origin_x, origin_y;
        OS.gdk_window_get_origin (window, &origin_x, &origin_y);
        event.x = cast(int)(x - origin_x);
        event.y = cast(int)(y - origin_y);
    }
    if ((style & SWT.MIRRORED) !is 0) event.x = getClientWidth () - event.x;
    setInputState (event, state);
    if (send) {
        sendEvent (type, event);
        if (isDisposed ()) return false;
    } else {
        postEvent (type, event);
    }
    return event.doit;
}

void setBackground () {
    if ((state & PARENT_BACKGROUND) !is 0 && (state & BACKGROUND) is 0 && backgroundImage is null) {
        setParentBackground ();
    } else {
        setWidgetBackground ();
    }
    redrawWidget (0, 0, 0, 0, true, false, false);
}

/**
 * Sets the receiver's background color to the color specified
 * by the argument, or to the default system color for the control
 * if the argument is null.
 * <p>
 * Note: This operation is a hint and may be overridden by the platform.
 * For example, on Windows the background of a Button cannot be changed.
 * </p>
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setBackground (Color color) {
    checkWidget();
    if (((state & BACKGROUND) is 0) && color is null) return;
    GdkColor* gdkColor = null;
    if (color !is null) {
        if (color.isDisposed ()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
        gdkColor = color.handle;
    }
    bool set = false;
    if (gdkColor is null) {
        auto style = OS.gtk_widget_get_modifier_style (handle);
        set = (OS.gtk_rc_style_get_color_flags (style, OS.GTK_STATE_NORMAL) & OS.GTK_RC_BG) !is 0;
    } else {
        GdkColor* oldColor = getBackgroundColor ();
        set = oldColor.pixel !is gdkColor.pixel;
    }
    if (set) {
        if (color is null) {
            state &= ~BACKGROUND;
        } else {
            state |= BACKGROUND;
        }
        setBackgroundColor (gdkColor);
        redrawChildren ();
    }
}

void setBackgroundColor (GtkWidget* handle, GdkColor* color) {
    int index = OS.GTK_STATE_NORMAL;
    auto style = OS.gtk_widget_get_modifier_style (handle);
    auto ptr = OS.gtk_rc_style_get_bg_pixmap_name (style, index);
    if (ptr !is null) OS.g_free (ptr);
    String name = color is null ? "<parent>" : "<none>" ;
    ptr = cast(char*)OS.g_malloc (name.length+1);
    ptr[ 0 .. name.length ] = name;
    ptr[ name.length ] = '\0';
    OS.gtk_rc_style_set_bg_pixmap_name (style, index, ptr);
    OS.gtk_rc_style_set_bg (style, index, color);
    int flags = OS.gtk_rc_style_get_color_flags (style, index);
    flags = (color is null) ? flags & ~OS.GTK_RC_BG : flags | OS.GTK_RC_BG;
    OS.gtk_rc_style_set_color_flags (style, index, flags);
    modifyStyle (handle, style);
}

void setBackgroundColor (GdkColor* color) {
    setBackgroundColor (handle, color);
}

/**
 * Sets the receiver's background image to the image specified
 * by the argument, or to the default system color for the control
 * if the argument is null.  The background image is tiled to fill
 * the available space.
 * <p>
 * Note: This operation is a hint and may be overridden by the platform.
 * For example, on Windows the background of a Button cannot be changed.
 * </p>
 * @param image the new image (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument is not a bitmap</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setBackgroundImage (Image image) {
    checkWidget ();
    if (image !is null && image.isDisposed ()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (image is backgroundImage) return;
    this.backgroundImage = image;
    if (backgroundImage !is null) {
        setBackgroundPixmap (backgroundImage.pixmap);
        redrawWidget (0, 0, 0, 0, true, false, false);
    } else {
        setWidgetBackground ();
    }
    redrawChildren ();
}

void setBackgroundPixmap (GdkDrawable* pixmap) {
    auto window = OS.GTK_WIDGET_WINDOW (paintHandle ());
    if (window !is null) OS.gdk_window_set_back_pixmap (window, cast(GdkPixmap*)backgroundImage.pixmap, false);
}

/**
 * If the argument is <code>true</code>, causes the receiver to have
 * all mouse events delivered to it until the method is called with
 * <code>false</code> as the argument.  Note that on some platforms,
 * a mouse button must currently be down for capture to be assigned.
 *
 * @param capture <code>true</code> to capture the mouse, and <code>false</code> to release it
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setCapture (bool capture) {
    checkWidget();
    /* FIXME !!!!! */
    /*
    if (capture) {
        OS.gtk_widget_grab_focus (handle);
    } else {
        OS.gtk_widget_grab_default (handle);
    }
    */
}
/**
 * Sets the receiver's cursor to the cursor specified by the
 * argument, or to the default cursor for that kind of control
 * if the argument is null.
 * <p>
 * When the mouse pointer passes over a control its appearance
 * is changed to match the control's cursor.
 * </p>
 *
 * @param cursor the new cursor (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setCursor (Cursor cursor) {
    checkWidget();
    if (cursor !is null && cursor.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
    this.cursor = cursor;
    gtk_setCursor (cursor !is null ? cursor.handle : null);
}

void gtk_setCursor (GdkCursor* cursor) {
    auto window = eventWindow ();
    if (window !is null) {
        OS.gdk_window_set_cursor (window, cursor);
        if (!OS.GDK_WINDOWING_X11 ()) {
            OS.gdk_flush ();
        } else {
            auto xDisplay = OS.GDK_DISPLAY ();
            OS.XFlush (xDisplay);
        }
    }
}

/**
 * Sets the receiver's drag detect state. If the argument is
 * <code>true</code>, the receiver will detect drag gestures,
 * otherwise these gestures will be ignored.
 *
 * @param dragDetect the new drag detect state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.3
 */
public void setDragDetect (bool dragDetect) {
    checkWidget ();
    if (dragDetect) {
        state |= DRAG_DETECT;
    } else {
        state &= ~DRAG_DETECT;
    }
}

/**
 * Enables the receiver if the argument is <code>true</code>,
 * and disables it otherwise. A disabled control is typically
 * not selectable from the user interface and draws with an
 * inactive or "grayed" look.
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
    if (((state & DISABLED) is 0) is enabled) return;
    Control control = null;
    bool fixFocus_ = false;
    if (!enabled) {
        if (display.focusEvent !is SWT.FocusOut) {
            control = display.getFocusControl ();
            fixFocus_ = isFocusAncestor (control);
        }
    }
    if (enabled) {
        state &= ~DISABLED;
    } else {
        state |= DISABLED;
    }
    enableWidget (enabled);
    if (isDisposed ()) return;
    if (enabled) {
        if (enableWindow !is null) {
            OS.gdk_window_set_user_data (enableWindow, null);
            OS.gdk_window_destroy (enableWindow);
            enableWindow = null;
        }
    } else {
        OS.gtk_widget_realize (handle);
        auto parentHandle = parent.eventHandle ();
        auto window = parent.eventWindow();
        auto topHandle_ = topHandle ();
        GdkWindowAttr attributes;
        attributes.x = OS.GTK_WIDGET_X (topHandle_);
        attributes.y = OS.GTK_WIDGET_Y (topHandle_);
        attributes.width = (state & ZERO_WIDTH) !is 0 ? 0 : OS.GTK_WIDGET_WIDTH (topHandle_);
        attributes.height = (state & ZERO_HEIGHT) !is 0 ? 0 : OS.GTK_WIDGET_HEIGHT (topHandle_);
        attributes.event_mask = (0xFFFFFFFF & ~OS.ExposureMask);
        attributes.wclass = OS.GDK_INPUT_ONLY;
        attributes.window_type = OS.GDK_WINDOW_CHILD;
        enableWindow = OS.gdk_window_new (window, &attributes, OS.GDK_WA_X | OS.GDK_WA_Y);
        if (enableWindow !is null) {
            OS.gdk_window_set_user_data (enableWindow, parentHandle);
            if (!OS.GDK_WINDOWING_X11 ()) {
                OS.gdk_window_raise (enableWindow);
            } else {
                auto topWindow = OS.GTK_WIDGET_WINDOW (topHandle_);
                auto xDisplay = OS.gdk_x11_drawable_get_xdisplay (cast(GdkDrawable*)topWindow);
                auto xWindow = OS.gdk_x11_drawable_get_xid (cast(GdkDrawable*)enableWindow);
                int xScreen = OS.XDefaultScreen (xDisplay);
                int flags = OS.CWStackMode | OS.CWSibling;
                XWindowChanges changes;
                changes.sibling = OS.gdk_x11_drawable_get_xid (cast(GdkDrawable*)topWindow);
                changes.stack_mode = OS.Above;
                OS.XReconfigureWMWindow (xDisplay, xWindow, xScreen, flags, &changes);
            }
            if (OS.GTK_WIDGET_VISIBLE (topHandle_)) OS.gdk_window_show_unraised (enableWindow);
        }
    }
    if (fixFocus_) fixFocus (control);
}

/**
 * Causes the receiver to have the <em>keyboard focus</em>,
 * such that all keyboard events will be delivered to it.  Focus
 * reassignment will respect applicable platform constraints.
 *
 * @return <code>true</code> if the control got focus, and <code>false</code> if it was unable to.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #forceFocus
 */
public bool setFocus () {
    checkWidget();
    if ((style & SWT.NO_FOCUS) !is 0) return false;
    return forceFocus ();
}

/**
 * Sets the font that the receiver will use to paint textual information
 * to the font specified by the argument, or to the default font for that
 * kind of control if the argument is null.
 *
 * @param font the new font (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setFont (Font font) {
    checkWidget();
    if (((state & FONT) is 0) && font is null) return;
    this.font = font;
    PangoFontDescription* fontDesc;
    if (font is null) {
        fontDesc = defaultFont ().handle;
    } else {
        if (font.isDisposed ()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
        fontDesc = font.handle;
    }
    if (font is null) {
        state &= ~FONT;
    } else {
        state |= FONT;
    }
    setFontDescription (fontDesc);
}

void setFontDescription (PangoFontDescription* font) {
    OS.gtk_widget_modify_font (handle, font);
}

/**
 * Sets the receiver's foreground color to the color specified
 * by the argument, or to the default system color for the control
 * if the argument is null.
 * <p>
 * Note: This operation is a hint and may be overridden by the platform.
 * </p>
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setForeground (Color color) {
    checkWidget();
    if (((state & FOREGROUND) is 0) && color is null) return;
    GdkColor* gdkColor = null;
    if (color !is null) {
        if (color.isDisposed ()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
        gdkColor = color.handle;
    }
    bool set = false;
    if (gdkColor is null) {
        auto style = OS.gtk_widget_get_modifier_style (handle);
        set = (OS.gtk_rc_style_get_color_flags (style, OS.GTK_STATE_NORMAL) & OS.GTK_RC_FG) !is 0;
    } else {
        GdkColor* oldColor = getForegroundColor ();
        set = oldColor.pixel !is gdkColor.pixel;
    }
    if (set) {
        if (color is null) {
            state &= ~FOREGROUND;
        } else {
            state |= FOREGROUND;
        }
        setForegroundColor (gdkColor);
    }
}

void setForegroundColor (GdkColor* color) {
    setForegroundColor (handle, color);
}

void setInitialBounds () {
    if ((state & ZERO_WIDTH) !is 0 && (state & ZERO_HEIGHT) !is 0) {
        /*
        * Feature in GTK.  On creation, each widget's allocation is
        * initialized to a position of (-1, -1) until the widget is
        * first sized.  The fix is to set the value to (0, 0) as
        * expected by SWT.
        */
        auto topHandle_ = topHandle ();
        if ((parent.style & SWT.MIRRORED) !is 0) {
            OS.GTK_WIDGET_SET_X (topHandle_, parent.getClientWidth ());
        } else {
            OS.GTK_WIDGET_SET_X (topHandle_, 0);
        }
        OS.GTK_WIDGET_SET_Y (topHandle_, 0);
    } else {
        resizeHandle (1, 1);
        forceResize ();
    }
}

/**
 * Sets the receiver's pop up menu to the argument.
 * All controls may optionally have a pop up
 * menu that is displayed when the user requests one for
 * the control. The sequence of key strokes, button presses
 * and/or button releases that are used to request a pop up
 * menu is platform specific.
 * <p>
 * Note: Disposing of a control that has a pop up menu will
 * dispose of the menu.  To avoid this behavior, set the
 * menu to null before the control is disposed.
 * </p>
 *
 * @param menu the new pop up menu
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_MENU_NOT_POP_UP - the menu is not a pop up menu</li>
 *    <li>ERROR_INVALID_PARENT - if the menu is not in the same widget tree</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the menu has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMenu (Menu menu) {
    checkWidget();
    if (menu !is null) {
        if ((menu.style & SWT.POP_UP) is 0) {
            error (SWT.ERROR_MENU_NOT_POP_UP);
        }
        if (menu.parent !is menuShell ()) {
            error (SWT.ERROR_INVALID_PARENT);
        }
    }
    this.menu = menu;
}

override void setOrientation () {
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        if (handle !is null) OS.gtk_widget_set_direction (handle, OS.GTK_TEXT_DIR_RTL);
        if (fixedHandle !is null) OS.gtk_widget_set_direction (fixedHandle, OS.GTK_TEXT_DIR_RTL);
    }
}

/**
 * Changes the parent of the widget to be the one provided if
 * the underlying operating system supports this feature.
 * Returns <code>true</code> if the parent is successfully changed.
 *
 * @param parent the new parent for the control.
 * @return <code>true</code> if the parent is changed and <code>false</code> otherwise.
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is <code>null</code></li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *  </ul>
 */
public bool setParent (Composite parent) {
    checkWidget ();
    if (parent is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    if (parent.isDisposed()) SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    if (this.parent is parent) return true;
    if (!isReparentable ()) return false;
    auto topHandle_ = topHandle ();
    int x = OS.GTK_WIDGET_X (topHandle_);
    int width = (state & ZERO_WIDTH) !is 0 ? 0 : OS.GTK_WIDGET_WIDTH (topHandle_);
    if ((this.parent.style & SWT.MIRRORED) !is 0) {
        x =  this.parent.getClientWidth () - width - x;
    }
    if ((parent.style & SWT.MIRRORED) !is 0) {
        x = parent.getClientWidth () - width - x;
    }
    int y = OS.GTK_WIDGET_Y (topHandle_);
    releaseParent ();
    Shell newShell = parent.getShell (), oldShell = getShell ();
    Decorations newDecorations = parent.menuShell (), oldDecorations = menuShell ();
    Menu [] menus = oldShell.findMenus (this);
    if (oldShell !is newShell || oldDecorations !is newDecorations) {
        fixChildren (newShell, oldShell, newDecorations, oldDecorations, menus);
        newDecorations.fixAccelGroup ();
        oldDecorations.fixAccelGroup ();
    }
    auto newParent = parent.parentingHandle();
    OS.gtk_widget_reparent (topHandle_, newParent);
    OS.gtk_fixed_move (cast(GtkFixed*)newParent, topHandle_, x, y);
    this.parent = parent;
    setZOrder (null, false, true);
    return true;
}

void setParentBackground () {
    setBackgroundColor (handle, null);
    if (fixedHandle !is null) setBackgroundColor (fixedHandle, null);
}

void setParentWindow (GtkWidget* widget) {
}

bool setRadioSelection (bool value) {
    return false;
}

/**
 * If the argument is <code>false</code>, causes subsequent drawing
 * operations in the receiver to be ignored. No drawing of any kind
 * can occur in the receiver until the flag is set to true.
 * Graphics operations that occurred while the flag was
 * <code>false</code> are lost. When the flag is set to <code>true</code>,
 * the entire widget is marked as needing to be redrawn.  Nested calls
 * to this method are stacked.
 * <p>
 * Note: This operation is a hint and may not be supported on some
 * platforms or for some widgets.
 * </p>
 *
 * @param redraw the new redraw state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #redraw(int, int, int, int, bool)
 * @see #update()
 */
public void setRedraw (bool redraw) {
    checkWidget();
    if (redraw) {
        if (--drawCount is 0) {
            if (redrawWindow !is null) {
                auto window = paintWindow ();
                /* Explicitly hiding the window avoids flicker on GTK+ >= 2.6 */
                OS.gdk_window_hide (redrawWindow);
                OS.gdk_window_destroy (redrawWindow);
                OS.gdk_window_set_events (window, OS.gtk_widget_get_events (paintHandle ()));
                redrawWindow = null;
            }
        }
    } else {
        if (drawCount++ is 0) {
            if ((OS.GTK_WIDGET_FLAGS (handle) & OS.GTK_REALIZED) !is 0) {
                auto window = paintWindow ();
                Rectangle rect = getBounds ();
                GdkWindowAttr attributes;
                attributes.width = rect.width;
                attributes.height = rect.height;
                attributes.event_mask = OS.GDK_EXPOSURE_MASK;
                attributes.window_type = OS.GDK_WINDOW_CHILD;
                redrawWindow = OS.gdk_window_new (window, &attributes, 0);
                if (redrawWindow !is null) {
                    int mouseMask = OS.GDK_BUTTON_PRESS_MASK | OS.GDK_BUTTON_RELEASE_MASK |
                        OS.GDK_ENTER_NOTIFY_MASK | OS.GDK_LEAVE_NOTIFY_MASK |
                        OS.GDK_POINTER_MOTION_MASK | OS.GDK_POINTER_MOTION_HINT_MASK |
                        OS.GDK_BUTTON_MOTION_MASK | OS.GDK_BUTTON1_MOTION_MASK |
                        OS.GDK_BUTTON2_MOTION_MASK | OS.GDK_BUTTON3_MOTION_MASK;
                    OS.gdk_window_set_events (window, OS.gdk_window_get_events (window) & ~mouseMask);
                    OS.gdk_window_set_back_pixmap (redrawWindow, null, false);
                    OS.gdk_window_show (redrawWindow);
                }
            }
        }
    }
}

bool setTabGroupFocus (bool next) {
    return setTabItemFocus (next);
}
bool setTabItemFocus (bool next) {
    if (!isShowing ()) return false;
    return forceFocus ();
}

/**
 * Sets the receiver's tool tip text to the argument, which
 * may be null indicating that no tool tip text should be shown.
 *
 * @param str the new tool tip text (or null)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setToolTipText (String str) {
    checkWidget();
    setToolTipText (_getShell (), str);
    toolTipText = str;
}

void setToolTipText (Shell shell, String newString) {
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 12, 0)) {
        /*
        * Feature in GTK.  In order to prevent children widgets
        * from inheriting their parent's tooltip, the tooltip is
        * a set on a shell only. In order to force the shell tooltip
        * to update when a new tip string is set, the existing string
        * in the tooltip is set to null, followed by running a query.
        * The real tip text can then be set.
        *
        * Note that this will only run if the control for which the
        * tooltip is being set is the current control (i.e. the control
        * under the pointer).
        */
        if (display.currentControl is this) {
            shell.setToolTipText (shell.handle, eventHandle (), newString);
        }
    } else {
        shell.setToolTipText (eventHandle (), newString);
    }
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
    if (((state & HIDDEN) is 0) is visible) return;
    auto topHandle_ = topHandle();
    if (visible) {
        /*
        * It is possible (but unlikely), that application
        * code could have disposed the widget in the show
        * event.  If this happens, just return.
        */
        sendEvent (SWT.Show);
        if (isDisposed ()) return;
        state &= ~HIDDEN;
        if ((state & (ZERO_WIDTH | ZERO_HEIGHT)) is 0) {
            if (enableWindow !is null) OS.gdk_window_show_unraised (enableWindow);
            OS.gtk_widget_show (topHandle_);
        }
    } else {
        /*
        * Bug in GTK.  Invoking gtk_widget_hide() on a widget that has
        * focus causes a focus_out_event to be sent. If the client disposes
        * the widget inside the event, GTK GP's.  The fix is to reassign focus
        * before hiding the widget.
        *
        * NOTE: In order to stop the same widget from taking focus,
        * temporarily clear and set the GTK_VISIBLE flag.
        */
        Control control = null;
        bool fixFocus_ = false;
        if (display.focusEvent !is SWT.FocusOut) {
            control = display.getFocusControl ();
            fixFocus_ = isFocusAncestor (control);
        }
        state |= HIDDEN;
        if (fixFocus_) {
            OS.GTK_WIDGET_UNSET_FLAGS (topHandle_, OS.GTK_VISIBLE);
            fixFocus (control);
            if (isDisposed ()) return;
            OS.GTK_WIDGET_SET_FLAGS (topHandle_, OS.GTK_VISIBLE);
        }
        OS.gtk_widget_hide (topHandle_);
        if (isDisposed ()) return;
        if (enableWindow !is null) OS.gdk_window_hide (enableWindow);
        sendEvent (SWT.Hide);
    }
}

void setZOrder (Control sibling, bool above, bool fixRelations) {
     setZOrder (sibling, above, fixRelations, true);
}

void setZOrder (Control sibling, bool above, bool fixRelations, bool fixChildren) {
    int index = 0, siblingIndex = 0, oldNextIndex = -1;
    Control[] children = null;
    if (fixRelations) {
        /* determine the receiver's and sibling's indexes in the parent */
        children = parent._getChildren ();
        while (index < children.length) {
            if (children [index] is this) break;
            index++;
        }
        if (sibling !is null) {
            while (siblingIndex < children.length) {
                if (children [siblingIndex] is sibling) break;
                siblingIndex++;
            }
        }
        /* remove "Labelled by" relationships that will no longer be valid */
        removeRelation ();
        if (index + 1 < children.length) {
            oldNextIndex = index + 1;
            children [oldNextIndex].removeRelation ();
        }
        if (sibling !is null) {
            if (above) {
                sibling.removeRelation ();
            } else {
                if (siblingIndex + 1 < children.length) {
                    children [siblingIndex + 1].removeRelation ();
                }
            }
        }
    }

    auto topHandle_ = topHandle ();
    auto siblingHandle = sibling !is null ? sibling.topHandle () : null;
    auto window = OS.GTK_WIDGET_WINDOW (topHandle_);
    if (window !is null) {
        GdkWindow* siblingWindow;
        if (sibling !is null) {
            if (above && sibling.enableWindow !is null) {
                siblingWindow = enableWindow;
            } else {
                siblingWindow = OS.GTK_WIDGET_WINDOW (siblingHandle);
            }
        }
        auto redrawWindow = fixChildren ? parent.redrawWindow : null;
        if (!OS.GDK_WINDOWING_X11 () || (siblingWindow is null && (!above || redrawWindow is null))) {
            if (above) {
                OS.gdk_window_raise (window);
                if (redrawWindow !is null) OS.gdk_window_raise (redrawWindow);
                if (enableWindow !is null) OS.gdk_window_raise (enableWindow);
            } else {
                if (enableWindow !is null) OS.gdk_window_lower (enableWindow);
                OS.gdk_window_lower (window);
            }
        } else {
            XWindowChanges changes;
            changes.sibling = OS.gdk_x11_drawable_get_xid (cast(GdkDrawable*)(siblingWindow !is null ? siblingWindow : redrawWindow));
            changes.stack_mode = above ? OS.Above : OS.Below;
            if (redrawWindow !is null && siblingWindow is null) changes.stack_mode = OS.Below;
            auto xDisplay = OS.gdk_x11_drawable_get_xdisplay (cast(GdkDrawable*)window);
            auto xWindow = OS.gdk_x11_drawable_get_xid (cast(GdkDrawable*)window);
            int xScreen = OS.XDefaultScreen (xDisplay);
            int flags = OS.CWStackMode | OS.CWSibling;
            /*
            * Feature in X. If the receiver is a top level, XConfigureWindow ()
            * will fail (with a BadMatch error) for top level shells because top
            * level shells are reparented by the window manager and do not share
            * the same X window parent.  This is the correct behavior but it is
            * unexpected.  The fix is to use XReconfigureWMWindow () instead.
            * When the receiver is not a top level shell, XReconfigureWMWindow ()
            * behaves the same as XConfigureWindow ().
            */
            OS.XReconfigureWMWindow (xDisplay, xWindow, xScreen, flags, &changes);
            if (enableWindow !is null) {
                changes.sibling = OS.gdk_x11_drawable_get_xid (cast(GdkDrawable*)window);
                changes.stack_mode = OS.Above;
                xWindow = OS.gdk_x11_drawable_get_xid (cast(GdkDrawable*)enableWindow);
                OS.XReconfigureWMWindow (xDisplay, xWindow, xScreen, flags, &changes);
            }
        }
    }
    if (fixChildren) {
        if (above) {
            parent.moveAbove (topHandle_, siblingHandle);
        } else {
            parent.moveBelow (topHandle_, siblingHandle);
        }
    }
    /*  Make sure that the parent internal windows are on the bottom of the stack   */
    if (!above && fixChildren)  parent.fixZOrder ();

    if (fixRelations) {
        /* determine the receiver's new index in the parent */
        if (sibling !is null) {
            if (above) {
                index = siblingIndex - (index < siblingIndex ? 1 : 0);
            } else {
                index = siblingIndex + (siblingIndex < index ? 1 : 0);
            }
        } else {
            if (above) {
                index = 0;
            } else {
                index = cast(int)/*64bit*/children.length - 1;
            }
        }

        /* add new "Labelled by" relations as needed */
        children = parent._getChildren ();
        if (0 < index) {
            children [index - 1].addRelation (this);
        }
        if (index + 1 < children.length) {
            addRelation (children [index + 1]);
        }
        if (oldNextIndex !is -1) {
            if (oldNextIndex <= index) oldNextIndex--;
            /* the last two conditions below ensure that duplicate relations are not hooked */
            if (0 < oldNextIndex && oldNextIndex !is index && oldNextIndex !is index + 1) {
                children [oldNextIndex - 1].addRelation (children [oldNextIndex]);
            }
        }
    }
}

void setWidgetBackground  () {
    if (fixedHandle !is null) {
        auto style = OS.gtk_widget_get_modifier_style (fixedHandle);
        modifyStyle (fixedHandle, style);
    }
    auto style = OS.gtk_widget_get_modifier_style (handle);
    modifyStyle (handle, style);
}

bool showMenu (int x, int y) {
    Event event = new Event ();
    event.x = x;
    event.y = y;
    sendEvent (SWT.MenuDetect, event);
    if (event.doit) {
        if (menu !is null && !menu.isDisposed ()) {
            bool hooksKeys = hooks (SWT.KeyDown) || hooks (SWT.KeyUp);
            menu.createIMMenu (hooksKeys ? imHandle() : null);
            if (event.x !is x || event.y !is y) {
                menu.setLocation (event.x, event.y);
            }
            menu.setVisible (true);
            return true;
        }
    }
    return false;
}

void showWidget () {
    // Comment this line to disable zero-sized widgets
    state |= ZERO_WIDTH | ZERO_HEIGHT;
    auto topHandle_ = topHandle ();
    auto parentHandle = parent.parentingHandle ();
    parent.setParentWindow (topHandle_);
    OS.gtk_container_add (cast(GtkContainer*)parentHandle, topHandle_);
    if (handle !is null && handle !is topHandle_) OS.gtk_widget_show (handle);
    if ((state & (ZERO_WIDTH | ZERO_HEIGHT)) is 0) {
        if (fixedHandle !is null) OS.gtk_widget_show (fixedHandle);
    }
    if (fixedHandle !is null) fixStyle (fixedHandle);
}

void sort (int [] items) {
    /* Shell Sort from K&R, pg 108 */
    ptrdiff_t length = items.length;
    for (ptrdiff_t gap=length/2; gap>0; gap/=2) {
        for (ptrdiff_t i=gap; i<length; i++) {
            for (ptrdiff_t j=i-gap; j>=0; j-=gap) {
                if (items [j] <= items [j + gap]) {
                    int swap = items [j];
                    items [j] = items [j + gap];
                    items [j + gap] = swap;
                }
            }
        }
    }
}

/**
 * Based on the argument, perform one of the expected platform
 * traversal action. The argument should be one of the constants:
 * <code>SWT.TRAVERSE_ESCAPE</code>, <code>SWT.TRAVERSE_RETURN</code>,
 * <code>SWT.TRAVERSE_TAB_NEXT</code>, <code>SWT.TRAVERSE_TAB_PREVIOUS</code>,
 * <code>SWT.TRAVERSE_ARROW_NEXT</code> and <code>SWT.TRAVERSE_ARROW_PREVIOUS</code>.
 *
 * @param traversal the type of traversal
 * @return true if the traversal succeeded
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool traverse (int traversal) {
    checkWidget ();
    Event event = new Event ();
    event.doit = true;
    event.detail = traversal;
    return traverse (event);
}

bool translateMnemonic (Event event, Control control) {
    if (control is this) return false;
    if (!isVisible () || !isEnabled ()) return false;
    event.doit = this is display.mnemonicControl || mnemonicMatch (event.character);
    return traverse (event);
}

bool translateMnemonic (int keyval, GdkEventKey* gdkEvent) {
    int key = OS.gdk_keyval_to_unicode (keyval);
    if (key < 0x20) return false;
    if (gdkEvent.state is 0) {
        int code = traversalCode (keyval, gdkEvent);
        if ((code & SWT.TRAVERSE_MNEMONIC) is 0) return false;
    } else {
        Shell shell = _getShell ();
        int mask = OS.GDK_CONTROL_MASK | OS.GDK_SHIFT_MASK | OS.GDK_MOD1_MASK;
        if ((gdkEvent.state & mask) !is OS.gtk_window_get_mnemonic_modifier (cast(GtkWindow*)shell.shellHandle)) return false;
    }
    Decorations shell = menuShell ();
    if (shell.isVisible () && shell.isEnabled ()) {
        Event event = new Event ();
        event.detail = SWT.TRAVERSE_MNEMONIC;
        if (setKeyState (event, gdkEvent)) {
            return translateMnemonic (event, null) || shell.translateMnemonic (event, this);
        }
    }
    return false;
}

bool translateTraversal (GdkEventKey* keyEvent) {
    int detail = SWT.TRAVERSE_NONE;
    int key = keyEvent.keyval;
    int code = traversalCode (key, keyEvent);
    bool all = false;
    switch (key) {
        case OS.GDK_Escape: {
            all = true;
            detail = SWT.TRAVERSE_ESCAPE;
            break;
        }
        case OS.GDK_KP_Enter:
        case OS.GDK_Return: {
            all = true;
            detail = SWT.TRAVERSE_RETURN;
            break;
        }
        case OS.GDK_ISO_Left_Tab:
        case OS.GDK_Tab: {
            bool next = (keyEvent.state & OS.GDK_SHIFT_MASK) is 0;
            detail = next ? SWT.TRAVERSE_TAB_NEXT : SWT.TRAVERSE_TAB_PREVIOUS;
            break;
        }
        case OS.GDK_Up:
        case OS.GDK_Left:
        case OS.GDK_Down:
        case OS.GDK_Right: {
            bool next = key is OS.GDK_Down || key is OS.GDK_Right;
            if (parent !is null && (parent.style & SWT.MIRRORED) !is 0) {
                if (key is OS.GDK_Left || key is OS.GDK_Right) next = !next;
            }
            detail = next ? SWT.TRAVERSE_ARROW_NEXT : SWT.TRAVERSE_ARROW_PREVIOUS;
            break;
        }
        case OS.GDK_Page_Up:
        case OS.GDK_Page_Down: {
            all = true;
            if ((keyEvent.state & OS.GDK_CONTROL_MASK) is 0) return false;
            detail = key is OS.GDK_Page_Down ? SWT.TRAVERSE_PAGE_NEXT : SWT.TRAVERSE_PAGE_PREVIOUS;
            break;
        }
        default:
            return false;
    }
    Event event = new Event ();
    event.doit = (code & detail) !is 0;
    event.detail = detail;
    event.time = keyEvent.time;
    if (!setKeyState (event, keyEvent)) return false;
    Shell shell = getShell ();
    Control control = this;
    do {
        if (control.traverse (event)) return true;
        if (!event.doit && control.hooks (SWT.Traverse)) return false;
        if (control is shell) return false;
        control = control.parent;
    } while (all && control !is null);
    return false;
}

int traversalCode (int key, GdkEventKey* event) {
    int code = SWT.TRAVERSE_RETURN | SWT.TRAVERSE_TAB_NEXT |  SWT.TRAVERSE_TAB_PREVIOUS | SWT.TRAVERSE_PAGE_NEXT | SWT.TRAVERSE_PAGE_PREVIOUS;
    Shell shell = getShell ();
    if (shell.parent !is null) code |= SWT.TRAVERSE_ESCAPE;
    return code;
}

bool traverse (Event event) {
    /*
    * It is possible (but unlikely), that application
    * code could have disposed the widget in the traverse
    * event.  If this happens, return true to stop further
    * event processing.
    */
    sendEvent (SWT.Traverse, event);
    if (isDisposed ()) return true;
    if (!event.doit) return false;
    switch (event.detail) {
        case SWT.TRAVERSE_NONE:         return true;
        case SWT.TRAVERSE_ESCAPE:           return traverseEscape ();
        case SWT.TRAVERSE_RETURN:           return traverseReturn ();
        case SWT.TRAVERSE_TAB_NEXT:     return traverseGroup (true);
        case SWT.TRAVERSE_TAB_PREVIOUS: return traverseGroup (false);
        case SWT.TRAVERSE_ARROW_NEXT:       return traverseItem (true);
        case SWT.TRAVERSE_ARROW_PREVIOUS:   return traverseItem (false);
        case SWT.TRAVERSE_MNEMONIC:     return traverseMnemonic (cast(char) event.character);
        case SWT.TRAVERSE_PAGE_NEXT:        return traversePage (true);
        case SWT.TRAVERSE_PAGE_PREVIOUS:    return traversePage (false);
        default:
    }
    return false;
}

bool traverseEscape () {
    return false;
}

bool traverseGroup (bool next) {
    Control root = computeTabRoot ();
    Control group = computeTabGroup ();
    Control [] list = root.computeTabList ();
    ptrdiff_t length = list.length;
    ptrdiff_t index = 0;
    while (index < length) {
        if (list [index] is group) break;
        index++;
    }
    /*
    * It is possible (but unlikely), that application
    * code could have disposed the widget in focus in
    * or out events.  Ensure that a disposed widget is
    * not accessed.
    */
    if (index is length) return false;
    ptrdiff_t start = index, offset = (next) ? 1 : -1;
    while ((index = ((index + offset + length) % length)) !is start) {
        Control control = list [index];
        if (!control.isDisposed () && control.setTabGroupFocus (next)) {
            return true;
        }
    }
    if (group.isDisposed ()) return false;
    return group.setTabGroupFocus (next);
}

bool traverseItem (bool next) {
    Control [] children = parent._getChildren ();
    ptrdiff_t length = children.length;
    ptrdiff_t index = 0;
    while (index < length) {
        if (children [index] is this) break;
        index++;
    }
    /*
    * It is possible (but unlikely), that application
    * code could have disposed the widget in focus in
    * or out events.  Ensure that a disposed widget is
    * not accessed.
    */
    if (index is length) return false;
    ptrdiff_t start = index, offset = (next) ? 1 : -1;
    while ((index = (index + offset + length) % length) !is start) {
        Control child = children [index];
        if (!child.isDisposed () && child.isTabItem ()) {
            if (child.setTabItemFocus (next)) return true;
        }
    }
    return false;
}

bool traverseReturn () {
    return false;
}

bool traversePage (bool next) {
    return false;
}

bool traverseMnemonic (char key) {
    return mnemonicHit (key);
}

/**
 * Forces all outstanding paint requests for the widget
 * to be processed before this method returns. If there
 * are no outstanding paint request, this method does
 * nothing.
 * <p>
 * Note: This method does not cause a redraw.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #redraw()
 * @see #redraw(int, int, int, int, bool)
 * @see PaintListener
 * @see SWT#Paint
 */
public void update () {
    checkWidget ();
    update (false, true);
}

void update (bool all, bool flush) {
//  checkWidget();
    if (!OS.GTK_WIDGET_VISIBLE (topHandle ())) return;
    if ((OS.GTK_WIDGET_FLAGS (handle) & OS.GTK_REALIZED) is 0) return;
    auto window = paintWindow ();
    if (flush) display.flushExposes (window, all);
    OS.gdk_window_process_updates (window, all);
    OS.gdk_flush ();
}

void updateBackgroundMode () {
    int oldState = state & PARENT_BACKGROUND;
    checkBackground ();
    if (oldState !is (state & PARENT_BACKGROUND)) {
        setBackground ();
    }
}

void updateLayout (bool all) {
    /* Do nothing */
}

override int windowProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    switch (user_data) {
        case EXPOSE_EVENT_INVERSE: {
            if ((OS.GTK_VERSION <  OS.buildVERSION (2, 8, 0)) && ((state & OBSCURED) is 0)) {
                Control control = findBackgroundControl ();
                if (control !is null && control.backgroundImage !is null) {
                    GdkEventExpose* gdkEvent = cast(GdkEventExpose*)arg0;
                    auto paintWindow = paintWindow();
                    auto window = gdkEvent.window;
                    if (window !is paintWindow) break;
                    auto gdkGC = OS.gdk_gc_new (cast(GdkDrawable*)window);
                    OS.gdk_gc_set_clip_region (gdkGC, gdkEvent.region);
                    int dest_x, dest_y;
                    OS.gtk_widget_translate_coordinates (paintHandle (), control.paintHandle (), 0, 0, &dest_x, &dest_y);
                    OS.gdk_gc_set_fill (gdkGC, OS.GDK_TILED);
                    OS.gdk_gc_set_ts_origin (gdkGC, -dest_x, -dest_y);
                    OS.gdk_gc_set_tile (gdkGC, cast(GdkPixmap*)control.backgroundImage.pixmap);
                    OS.gdk_draw_rectangle (cast(GdkDrawable*)window, gdkGC, 1, gdkEvent.area.x, gdkEvent.area.y, gdkEvent.area.width, gdkEvent.area.height);
                    OS.g_object_unref (gdkGC);
                }
            }
            break;
        default:
        }
    }
    return super.windowProc (handle, arg0, user_data);
}
}
