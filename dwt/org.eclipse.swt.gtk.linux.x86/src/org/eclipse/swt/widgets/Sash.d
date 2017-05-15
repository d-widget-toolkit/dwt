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
module org.eclipse.swt.widgets.Sash;

import java.lang.all;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.internal.gtk.OS;

import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;

/**
 * Instances of the receiver represent a selectable user interface object
 * that allows the user to drag a rubber banded outline of the sash within
 * the parent control.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>HORIZONTAL, VERTICAL, SMOOTH</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles HORIZONTAL and VERTICAL may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#sash">Sash snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Sash : Control {

    alias Control.computeSize computeSize;
    alias Control.setCursor setCursor;

    bool dragging;
    int startX, startY, lastX, lastY;
    GtkWidget* defaultCursor;

    private const static int INCREMENT = 1;
    private const static int PAGE_INCREMENT = 9;

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
 * @see SWT#HORIZONTAL
 * @see SWT#VERTICAL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * When <code>widgetSelected</code> is called, the x, y, width, and height fields of the event object are valid.
 * If the receiver is being dragged, the event object detail field contains the value <code>SWT.DRAG</code>.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
 *
 * @param listener the listener which should be notified when the control is selected by the user
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
public void addSelectionListener (SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
}

static int checkStyle (int style) {
    return checkBits (style, SWT.HORIZONTAL, SWT.VERTICAL, 0, 0, 0, 0);
}

public override Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    if (wHint !is SWT.DEFAULT && wHint < 0) wHint = 0;
    if (hHint !is SWT.DEFAULT && hHint < 0) hHint = 0;
    int border = getBorderWidth ();
    int width = border * 2, height = border * 2;
    if ((style & SWT.HORIZONTAL) !is 0) {
        width += DEFAULT_WIDTH;  height += 3;
    } else {
        width += 3; height += DEFAULT_HEIGHT;
    }
    if (wHint !is SWT.DEFAULT) width = wHint + (border * 2);
    if (hHint !is SWT.DEFAULT) height = hHint + (border * 2);
    return new Point (width, height);
}

override void createHandle (int index) {
    state |= HANDLE | THEME_BACKGROUND;
    handle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (handle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_fixed_set_has_window (handle, true);
    OS.GTK_WIDGET_SET_FLAGS (handle, OS.GTK_CAN_FOCUS);
    int type = (style & SWT.VERTICAL) !is 0 ? OS.GDK_SB_H_DOUBLE_ARROW : OS.GDK_SB_V_DOUBLE_ARROW;
    defaultCursor = cast(GtkWidget*)OS.gdk_cursor_new (type);
}

void drawBand (int x, int y, int width, int height) {
    if ((style & SWT.SMOOTH) !is 0) return;
    auto window = OS.GTK_WIDGET_WINDOW (parent.paintHandle());
    if (window is null) return;
    char [] bits = cast(String)[ cast(byte)-86, 85, -86, 85, -86, 85, -86, 85 ];
    auto stipplePixmap = OS.gdk_bitmap_create_from_data (cast(GdkDrawable*)window, bits.ptr, 8, 8);
    auto gc = OS.gdk_gc_new (window);
    auto colormap = OS.gdk_colormap_get_system();
    GdkColor color;
    OS.gdk_color_white (colormap, &color);
    OS.gdk_gc_set_foreground (gc, &color);
    OS.gdk_gc_set_stipple (gc, stipplePixmap);
    OS.gdk_gc_set_subwindow (gc, OS.GDK_INCLUDE_INFERIORS);
    OS.gdk_gc_set_fill (gc, OS.GDK_STIPPLED);
    OS.gdk_gc_set_function (gc, OS.GDK_XOR);
    OS.gdk_draw_rectangle (window, gc, 1, x, y, width, height);
    OS.g_object_unref (stipplePixmap);
    OS.g_object_unref (gc);
}

override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* gdkEvent) {
    auto result = super.gtk_button_press_event (widget, gdkEvent);
    if (result !is 0) return result;
    int button = gdkEvent.button;
    if (button !is 1) return 0;
    if (gdkEvent.type is OS.GDK_2BUTTON_PRESS) return 0;
    if (gdkEvent.type is OS.GDK_3BUTTON_PRESS) return 0;
    auto window = OS.GTK_WIDGET_WINDOW (widget);
    int origin_x, origin_y;
    OS.gdk_window_get_origin (window, &origin_x, &origin_y);
    startX = cast(int) (gdkEvent.x_root - origin_x );
    startY = cast(int) (gdkEvent.y_root - origin_y );
    int x = OS.GTK_WIDGET_X (handle);
    int y = OS.GTK_WIDGET_Y (handle);
    int width = OS.GTK_WIDGET_WIDTH (handle);
    int height = OS.GTK_WIDGET_HEIGHT (handle);
    lastX = x;
    lastY = y;
    Event event = new Event ();
    event.time = gdkEvent.time;
    event.x = lastX;
    event.y = lastY;
    event.width = width;
    event.height = height;
    if ((style & SWT.SMOOTH) is 0) {
        event.detail = SWT.DRAG;
    }
    if ((parent.style & SWT.MIRRORED) !is 0) event.x = parent.getClientWidth () - width  - event.x;
    sendEvent (SWT.Selection, event);
    if (isDisposed ()) return 0;
    if (event.doit) {
        dragging = true;
        lastX = event.x;
        lastY = event.y;
        if ((parent.style & SWT.MIRRORED) !is 0) lastX = parent.getClientWidth () - width  - lastX;
        parent.update (true, (style & SWT.SMOOTH) is 0);
        drawBand (lastX, event.y, width, height);
        if ((style & SWT.SMOOTH) !is 0) {
            setBounds (event.x, event.y, width, height);
            // widget could be disposed at this point
        }
    }
    return result;
}

override int gtk_button_release_event (GtkWidget* widget, GdkEventButton* gdkEvent) {
    auto result = super.gtk_button_release_event (widget, gdkEvent);
    if (result !is 0) return result;
    int button = gdkEvent.button;
    if (button !is 1) return 0;
    if (!dragging) return 0;
    dragging = false;
    int width = OS.GTK_WIDGET_WIDTH (handle);
    int height = OS.GTK_WIDGET_HEIGHT (handle);
    Event event = new Event ();
    event.time = gdkEvent.time;
    event.x = lastX;
    event.y = lastY;
    event.width = width;
    event.height = height;
    drawBand (lastX, lastY, width, height);
    if ((parent.style & SWT.MIRRORED) !is 0) event.x = parent.getClientWidth () - width  - event.x;
    sendEvent (SWT.Selection, event);
    if (isDisposed ()) return result;
    if (event.doit) {
        if ((style & SWT.SMOOTH) !is 0) {
            setBounds (event.x, event.y, width, height);
            // widget could be disposed at this point
        }
    }
    return result;
}

override int gtk_focus_in_event (GtkWidget* widget, GdkEventFocus* event) {
    auto result = super.gtk_focus_in_event (widget, event);
    if (result !is 0) return result;
    // widget could be disposed at this point
    if (handle !is null) {
            lastX = OS.GTK_WIDGET_X (handle);
            lastY = OS.GTK_WIDGET_Y (handle);
    }
    return 0;
}

override int gtk_key_press_event (GtkWidget* widget, GdkEventKey* gdkEvent) {
    auto result = super.gtk_key_press_event (widget, gdkEvent);
    if (result !is 0) return result;
    int keyval = gdkEvent.keyval;
    switch (keyval) {
        case OS.GDK_Left:
        case OS.GDK_Right:
        case OS.GDK_Up:
        case OS.GDK_Down:
            int xChange = 0, yChange = 0;
            int stepSize = PAGE_INCREMENT;
            if ((gdkEvent.state & OS.GDK_CONTROL_MASK) !is 0) stepSize = INCREMENT;
            if ((style & SWT.VERTICAL) !is 0) {
                if (keyval is OS.GDK_Up || keyval is OS.GDK_Down) break;
                xChange = keyval is OS.GDK_Left ? -stepSize : stepSize;
            } else {
                if (keyval is OS.GDK_Left ||keyval is OS.GDK_Right) break;
                yChange = keyval is OS.GDK_Up ? -stepSize : stepSize;
            }

            int width = OS.GTK_WIDGET_WIDTH (handle);
            int height = OS.GTK_WIDGET_HEIGHT (handle);
            int parentBorder = 0;
            int parentWidth = OS.GTK_WIDGET_WIDTH (parent.handle);
            int parentHeight = OS.GTK_WIDGET_HEIGHT (parent.handle);
            int newX = lastX, newY = lastY;
            if ((style & SWT.VERTICAL) !is 0) {
                newX = Math.min (Math.max (0, lastX + xChange - parentBorder - startX), parentWidth - width);
            } else {
                newY = Math.min (Math.max (0, lastY + yChange - parentBorder - startY), parentHeight - height);
            }
            if (newX is lastX && newY is lastY) return result;

            /* Ensure that the pointer image does not change */
            auto window = OS.GTK_WIDGET_WINDOW (handle);
            int grabMask = OS.GDK_POINTER_MOTION_MASK | OS.GDK_BUTTON_RELEASE_MASK;
            auto gdkCursor = cursor !is null ? cursor.handle : cast(GdkCursor*)defaultCursor;
            int ptrGrabResult = OS.gdk_pointer_grab (window, false, grabMask, window, gdkCursor, OS.GDK_CURRENT_TIME);

            /* The event must be sent because its doit flag is used. */
            Event event = new Event ();
            event.time = gdkEvent.time;
            event.x = newX;
            event.y = newY;
            event.width = width;
            event.height = height;
            if ((parent.style & SWT.MIRRORED) !is 0) event.x = parent.getClientWidth () - width  - event.x;
            sendEvent (SWT.Selection, event);
            if (ptrGrabResult is OS.GDK_GRAB_SUCCESS) OS.gdk_pointer_ungrab (OS.GDK_CURRENT_TIME);
            if (isDisposed ()) break;

            if (event.doit) {
                lastX = event.x;
                lastY = event.y;
                if ((parent.style & SWT.MIRRORED) !is 0) lastX = parent.getClientWidth () - width  - lastX;
                if ((style & SWT.SMOOTH) !is 0) {
                    setBounds (event.x, event.y, width, height);
                    if (isDisposed ()) break;
                }
                int cursorX = event.x, cursorY = event.y;
                if ((style & SWT.VERTICAL) !is 0) {
                    cursorY += height / 2;
                } else {
                    cursorX += width / 2;
                }
                display.setCursorLocation (parent.toDisplay (cursorX, cursorY));
            }
            break;
        default:
    }

    return result;
}

override int gtk_motion_notify_event (GtkWidget* widget, GdkEventMotion* gdkEvent) {
    auto result = super.gtk_motion_notify_event (widget, gdkEvent);
    if (result !is 0) return result;
    if (!dragging) return 0;
    int eventX, eventY, eventState;
    if (gdkEvent.is_hint !is 0) {
        int pointer_x, pointer_y, mask;
        OS.gdk_window_get_pointer (gdkEvent.window, &pointer_x, &pointer_y, &mask);
        eventX = pointer_x ;
        eventY = pointer_y ;
        eventState = mask ;
    } else {
        int origin_x, origin_y;
        OS.gdk_window_get_origin (gdkEvent.window, &origin_x, &origin_y);
        eventX = cast(int)(gdkEvent.x_root - origin_x);
        eventY = cast(int)(gdkEvent.y_root - origin_y);
        eventState = gdkEvent.state;
    }
    if ((eventState & OS.GDK_BUTTON1_MASK) is 0) return 0;
    int x = OS.GTK_WIDGET_X (handle);
    int y = OS.GTK_WIDGET_Y (handle);
    int width = OS.GTK_WIDGET_WIDTH (handle);
    int height = OS.GTK_WIDGET_HEIGHT (handle);
    int parentBorder = 0;
    int parentWidth = OS.GTK_WIDGET_WIDTH (parent.handle);
    int parentHeight = OS.GTK_WIDGET_HEIGHT (parent.handle);
    int newX = lastX, newY = lastY;
    if ((style & SWT.VERTICAL) !is 0) {
        newX = Math.min (Math.max (0, eventX + x - startX - parentBorder), parentWidth - width);
    } else {
        newY = Math.min (Math.max (0, eventY + y - startY - parentBorder), parentHeight - height);
    }
    if (newX is lastX && newY is lastY) return 0;
    drawBand (lastX, lastY, width, height);

    Event event = new Event ();
    event.time = gdkEvent.time;
    event.x = newX;
    event.y = newY;
    event.width = width;
    event.height = height;
    if ((style & SWT.SMOOTH) is 0) {
        event.detail = SWT.DRAG;
    }
    if ((parent.style & SWT.MIRRORED) !is 0) event.x = parent.getClientWidth() - width  - event.x;
    sendEvent (SWT.Selection, event);
    if (isDisposed ()) return 0;
    if (event.doit) {
        lastX = event.x;
        lastY = event.y;
        if ((parent.style & SWT.MIRRORED) !is 0) lastX = parent.getClientWidth () - width  - lastX;
    }
    parent.update (true, (style & SWT.SMOOTH) is 0);
    drawBand (lastX, lastY, width, height);
    if ((style & SWT.SMOOTH) !is 0) {
        setBounds (event.x, lastY, width, height);
        // widget could be disposed at this point
    }
    return result;
}

override int gtk_realize (GtkWidget* widget) {
    gtk_setCursor (cursor !is null ? cursor.handle : null);
    return super.gtk_realize (widget);
}

override void hookEvents () {
    super.hookEvents ();
    OS.gtk_widget_add_events (handle, OS.GDK_POINTER_MOTION_HINT_MASK);
}

override void releaseWidget () {
    super.releaseWidget ();
    if (defaultCursor !is null) OS.gdk_cursor_destroy (cast(GdkCursor*)defaultCursor);
    defaultCursor = null;
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

override void gtk_setCursor (GdkCursor* cursor) {
    super.gtk_setCursor (cursor !is null ? cursor : cast(GdkCursor*)defaultCursor);
}

override int traversalCode (int key, GdkEventKey* event) {
    return 0;
}

}
