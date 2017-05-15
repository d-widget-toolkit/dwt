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
module org.eclipse.swt.widgets.ToolTip;

import java.lang.all;

import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.TrayItem;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.SWT;
//import org.eclipse.swt.internal.*;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Display;

/**
 * Instances of this class represent popup windows that are used
 * to inform or warn the user.
 * <p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>BALLOON, ICON_ERROR, ICON_INFORMATION, ICON_WARNING</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * </p><p>
 * Note: Only one of the styles ICON_ERROR, ICON_INFORMATION,
 * and ICON_WARNING may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#tooltips">Tool Tips snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.2
 */
public class ToolTip : Widget {
    Shell parent;
    String text, message;
    TrayItem item;
    int x, y;
    int timerId;
    void* layoutText, layoutMessage;
    int [] borderPolygon;
    bool spikeAbove, autohide;
    CallbackData timerProcCallbackData;

    static const int BORDER = 5;
    static const int PADDING = 5;
    static const int INSET = 4;
    static const int TIP_HEIGHT = 20;
    static const int IMAGE_SIZE = 16;
    static const int DELAY = 8000;

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
 * @see SWT#ICON_ERROR
 * @see SWT#ICON_INFORMATION
 * @see SWT#ICON_WARNING
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Shell parent, int style) {
    super (parent, checkStyle (style));
    this.parent = parent;
    createWidget (0);
}

static int checkStyle (int style) {
    int mask = SWT.ICON_ERROR | SWT.ICON_INFORMATION | SWT.ICON_WARNING;
    if ((style & mask) is 0) return style;
    return checkBits (style, SWT.ICON_INFORMATION, SWT.ICON_WARNING, SWT.ICON_ERROR, 0, 0, 0);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the receiver is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the receiver is selected.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
 *
 * @param listener the listener which should be notified when the receiver is selected by the user
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

void configure () {
    auto screen = OS.gdk_screen_get_default ();
    OS.gtk_widget_realize (handle);
    int monitorNumber = OS.gdk_screen_get_monitor_at_window (screen, OS.GTK_WIDGET_WINDOW (handle));
    GdkRectangle* dest = new GdkRectangle ();
    OS.gdk_screen_get_monitor_geometry (screen, monitorNumber, dest);
    Point point = getSize (dest.width / 4);
    int w = point.x;
    int h = point.y;
    point = getLocation ();
    int x = point.x;
    int y = point.y;
    OS.gtk_window_resize (cast(GtkWindow*)handle, w, h + TIP_HEIGHT);
    int[] polyline;
    spikeAbove = dest.height >= y + h + TIP_HEIGHT;
    if (dest.width >= x + w) {
        if (dest.height >= y + h + TIP_HEIGHT) {
            int t = TIP_HEIGHT;
            polyline = [
                0, 5+t, 1, 5+t, 1, 3+t, 3, 1+t,  5, 1+t, 5, t,
                16, t, 16, 0, 35, t,
                w-5, t, w-5, 1+t, w-3, 1+t, w-1, 3+t, w-1, 5+t, w, 5+t,
                w, h-5+t, w-1, h-5+t, w-1, h-3+t, w-2, h-3+t, w-2, h-2+t, w-3, h-2+t, w-3, h-1+t, w-5, h-1+t, w-5, h+t,
                5, h+t, 5, h-1+t, 3, h-1+t, 3, h-2+t, 2, h-2+t, 2, h-3+t, 1, h-3+t, 1, h-5+t, 0, h-5+t,
                0, 5+t];
            borderPolygon = [
                0, 5+t, 1, 4+t, 1, 3+t, 3, 1+t,  4, 1+t, 5, t,
                16, t, 16, 1, 35, t,
                w-6, 0+t, w-5, 1+t, w-4, 1+t, w-2, 3+t, w-2, 4+t, w-1, 5+t,
                w-1, h-6+t, w-2, h-5+t, w-2, h-4+t, w-4, h-2+t, w-5, h-2+t, w-6, h-1+t,
                5, h-1+t, 4, h-2+t, 3, h-2+t, 1, h-4+t, 1, h-5+t, 0, h-6+t,
                0, 5+t];
            if ((parent.style & SWT.MIRRORED) !is 0) {
                x -= w - 36;
                polyline[12] = w-36;
                polyline[14] = w-16;
                polyline[16] = w-15;
                borderPolygon[12] = w-35;
                borderPolygon[14] = borderPolygon[16]  = w-16;
            }
            OS.gtk_window_move (cast(GtkWindow*)handle, Math.max(0, x - 17), y);
        } else {
            polyline = [
                0, 5, 1, 5, 1, 3, 3, 1,  5, 1, 5, 0,
                w-5, 0, w-5, 1, w-3, 1, w-1, 3, w-1, 5, w, 5,
                w, h-5, w-1, h-5, w-1, h-3, w-2, h-3, w-2, h-2, w-3, h-2, w-3, h-1, w-5, h-1, w-5, h,
                35, h, 16, h+TIP_HEIGHT, 16, h,
                5, h, 5, h-1, 3, h-1, 3, h-2, 2, h-2, 2, h-3, 1, h-3, 1, h-5, 0, h-5,
                0, 5];
            borderPolygon = [
                0, 5, 1, 4, 1, 3, 3, 1,  4, 1, 5, 0,
                w-6, 0, w-5, 1, w-4, 1, w-2, 3, w-2, 4, w-1, 5,
                w-1, h-6, w-2, h-5, w-2, h-4, w-4, h-2, w-5, h-2, w-6, h-1,
                35, h-1, 17, h+TIP_HEIGHT-2, 17, h-1,
                5, h-1, 4, h-2, 3, h-2, 1, h-4, 1, h-5, 0, h-6,
                0, 5];
            if ((parent.style & SWT.MIRRORED) !is 0) {
                x -= w - 36;
                polyline [42] =  polyline [44] =  w-16;
                polyline [46] = w-35;
                borderPolygon[36] = borderPolygon[38] = w-17;
                borderPolygon [40] = w-35;
            }
            OS.gtk_window_move (cast(GtkWindow*)handle, Math.max(0, x - 17), y - h - TIP_HEIGHT);
        }
    } else {
        if (dest.height >= y + h + TIP_HEIGHT) {
            int t = TIP_HEIGHT;
            polyline = [
                0, 5+t, 1, 5+t, 1, 3+t, 3, 1+t,  5, 1+t, 5, t,
                w-35, t, w-16, 0, w-16, t,
                w-5, t, w-5, 1+t, w-3, 1+t, w-1, 3+t, w-1, 5+t, w, 5+t,
                w, h-5+t, w-1, h-5+t, w-1, h-3+t, w-2, h-3+t, w-2, h-2+t, w-3, h-2+t, w-3, h-1+t, w-5, h-1+t, w-5, h+t,
                5, h+t, 5, h-1+t, 3, h-1+t, 3, h-2+t, 2, h-2+t, 2, h-3+t, 1, h-3+t, 1, h-5+t, 0, h-5+t,
                0, 5+t];
            borderPolygon = [
                0, 5+t, 1, 4+t, 1, 3+t, 3, 1+t,  4, 1+t, 5, t,
                w-35, t, w-17, 2, w-17, t,
                w-6, t, w-5, 1+t, w-4, 1+t, w-2, 3+t, w-2, 4+t, w-1, 5+t,
                w-1, h-6+t, w-2, h-5+t, w-2, h-4+t, w-4, h-2+t, w-5, h-2+t, w-6, h-1+t,
                5, h-1+t, 4, h-2+t, 3, h-2+t, 1, h-4+t, 1, h-5+t, 0, h-6+t,
                0, 5+t];
            if ((parent.style & SWT.MIRRORED) !is 0) {
                x += w - 35;
                polyline [12] = polyline [14] = 16;
                polyline [16] = 35;
                borderPolygon[12] =  borderPolygon[14] = 16;
                borderPolygon [16] = 35;
            }
            OS.gtk_window_move (cast(GtkWindow*)handle, Math.min(dest.width - w, x - w + 17), y);
        } else {
            polyline = [
                0, 5, 1, 5, 1, 3, 3, 1,  5, 1, 5, 0,
                w-5, 0, w-5, 1, w-3, 1, w-1, 3, w-1, 5, w, 5,
                w, h-5, w-1, h-5, w-1, h-3, w-2, h-3, w-2, h-2, w-3, h-2, w-3, h-1, w-5, h-1, w-5, h,
                w-16, h, w-16, h+TIP_HEIGHT, w-35, h,
                5, h, 5, h-1, 3, h-1, 3, h-2, 2, h-2, 2, h-3, 1, h-3, 1, h-5, 0, h-5,
                0, 5];
            borderPolygon = [
                0, 5, 1, 4, 1, 3, 3, 1,  4, 1, 5, 0,
                w-6, 0, w-5, 1, w-4, 1, w-2, 3, w-2, 4, w-1, 5,
                w-1, h-6, w-2, h-5, w-2, h-4, w-4, h-2, w-5, h-2, w-6, h-1,
                w-17, h-1, w-17, h+TIP_HEIGHT-2, w-36, h-1,
                5, h-1, 4, h-2, 3, h-2, 1, h-4, 1, h-5, 0, h-6,
                0, 5];
            if ((parent.style & SWT.MIRRORED) !is 0) {
                x += w - 35;
                polyline [42] =  35;
                polyline [44] = polyline [46] = 16;
                borderPolygon[36] = 35;
                borderPolygon[38] = borderPolygon [40] = 17;
            }
            OS.gtk_window_move (cast(GtkWindow*)handle, Math.min(dest.width - w, x - w + 17), y - h - TIP_HEIGHT);
        }
    }
    auto rgn = OS.gdk_region_polygon ( cast(GdkPoint*)polyline.ptr, cast(int)/*64bit*/polyline.length / 2, OS.GDK_EVEN_ODD_RULE);
    OS.gtk_widget_realize (handle);
    auto window = OS.GTK_WIDGET_WINDOW (handle);
    OS.gdk_window_shape_combine_region (window, rgn, 0, 0);
    OS.gdk_region_destroy (rgn);
}

override void createHandle (int index) {
    state |= HANDLE;
    if ((style & SWT.BALLOON) !is 0) {
        handle = OS.gtk_window_new (OS.GTK_WINDOW_POPUP);
        Color background = display.getSystemColor (SWT.COLOR_INFO_BACKGROUND);
        OS.gtk_widget_modify_bg (handle, OS.GTK_STATE_NORMAL, background.handle);
        OS.gtk_widget_set_app_paintable (handle, true);
    } else {
        handle = cast(GtkWidget*)OS.gtk_tooltips_new ();
        if (handle is null) SWT.error (SWT.ERROR_NO_HANDLES);
        /*
        * Bug in Solaris-GTK.  Invoking gtk_tooltips_force_window()
        * can cause a crash in older versions of GTK.  The fix is
        * to avoid this call if the GTK version is older than 2.2.x.
        */
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 2, 1)) {
            OS.gtk_tooltips_force_window (cast(GtkTooltips*)handle);
        }
        OS.g_object_ref (handle);
        OS.gtk_object_sink (cast(GtkObject*)handle);
    }
}

override void createWidget (int index) {
    super.createWidget (index);
    text = "";
    message = "";
    x = y = -1;
    autohide = true;
}

override void deregister () {
    super.deregister ();
    if ((style & SWT.BALLOON) is 0) {
        auto tipWindow = OS.GTK_TOOLTIPS_TIP_WINDOW (cast(GtkTooltips*)handle);
        if (tipWindow !is null) display.removeWidget (tipWindow);
    }
}

override void destroyWidget () {
    auto topHandle = topHandle ();
    releaseHandle ();
    if (topHandle !is null && (state & HANDLE) !is 0) {
        if ((style & SWT.BALLOON) !is 0) {
            OS.gtk_widget_destroy (topHandle);
        } else {
            OS.g_object_unref (topHandle);
        }
    }
}

/**
 * Returns <code>true</code> if the receiver is automatically
 * hidden by the platform, and <code>false</code> otherwise.
 *
 * @return the receiver's auto hide state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 */
public bool getAutoHide () {
    checkWidget ();
    return autohide;
}

Point getLocation () {
    int x = this.x;
    int y = this.y;
    if (item !is null) {
        auto itemHandle = item.handle;
        OS.gtk_widget_realize (itemHandle);
        auto window = OS.GTK_WIDGET_WINDOW (itemHandle);
        int px, py;
        OS.gdk_window_get_origin (cast(GdkWindow*)window, &px, &py);
        x = px + OS.GTK_WIDGET_WIDTH (itemHandle) / 2;
        y = py + OS.GTK_WIDGET_HEIGHT (itemHandle) / 2;
    }
    if (x is -1 || y is -1) {
        int px, py;
        OS.gdk_window_get_pointer (null, &px, &py, null);
        x = px;
        y = py;
    }
    return new Point(x, y);
}

/**
 * Returns the receiver's message, which will be an empty
 * string if it has never been set.
 *
 * @return the receiver's message
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getMessage () {
    checkWidget ();
    return message;
}

override String getNameText () {
    return getText ();
}

/**
 * Returns the receiver's parent, which must be a <code>Shell</code>.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Shell getParent () {
    checkWidget ();
    return parent;
}

Point getSize (int maxWidth) {
    int textWidth = 0, messageWidth = 0;
    int w, h;
    if (layoutText !is null) {
        OS.pango_layout_set_width (layoutText, -1);
        OS.pango_layout_get_size (layoutText, &w, &h);
        textWidth = OS.PANGO_PIXELS (w );
    }
    if (layoutMessage !is null) {
        OS.pango_layout_set_width (layoutMessage, -1);
        OS.pango_layout_get_size (layoutMessage, &w, &h);
        messageWidth = OS.PANGO_PIXELS (w );
    }
    int messageTrim = 2 * INSET + 2 * BORDER + 2 * PADDING;
    bool hasImage = layoutText !is null && (style & (SWT.ICON_ERROR | SWT.ICON_INFORMATION | SWT.ICON_WARNING)) !is 0;
    int textTrim = messageTrim + (hasImage ? IMAGE_SIZE : 0);
    int width = Math.min (maxWidth, Math.max (textWidth + textTrim, messageWidth + messageTrim));
    int textHeight = 0, messageHeight = 0;
    if (layoutText !is null) {
        OS.pango_layout_set_width (layoutText, (maxWidth - textTrim) * OS.PANGO_SCALE);
        OS.pango_layout_get_size (layoutText, &w, &h);
        textHeight = OS.PANGO_PIXELS (h );
    }
    if (layoutMessage !is null) {
        OS.pango_layout_set_width (layoutMessage, (maxWidth - messageTrim) * OS.PANGO_SCALE);
        OS.pango_layout_get_size (layoutMessage, &w, &h);
        messageHeight = OS.PANGO_PIXELS (h);
    }
    int height = 2 * BORDER + 2 * PADDING + messageHeight;
    if (layoutText !is null) height += Math.max (IMAGE_SIZE, textHeight) + 2 * PADDING;
    return new Point(width, height);
}

/**
 * Returns the receiver's text, which will be an empty
 * string if it has never been set.
 *
 * @return the receiver's text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText () {
    checkWidget ();
    return text;
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
    checkWidget ();
    if ((style & SWT.BALLOON) !is 0) return OS.GTK_WIDGET_VISIBLE (handle);
    auto tipWindow = OS.GTK_TOOLTIPS_TIP_WINDOW (cast(GtkTooltips*)handle);
    return OS.GTK_WIDGET_VISIBLE (tipWindow);
}

override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* event) {
    notifyListeners (SWT.Selection, new Event ());
    setVisible (false);
    return 0;
}

override int gtk_expose_event (GtkWidget* widget, GdkEventExpose* event) {
    auto window = OS.GTK_WIDGET_WINDOW (handle);
    auto gdkGC = cast(GdkGC*)OS.gdk_gc_new (window);
    OS.gdk_draw_polygon (window, gdkGC, 0, cast(GdkPoint*)borderPolygon.ptr, cast(int)/*64bit*/borderPolygon.length / 2);
    int x = BORDER + PADDING;
    int y = BORDER + PADDING;
    if (spikeAbove) y += TIP_HEIGHT;
    if (layoutText !is null) {
        String buffer = null;
        int id = style & (SWT.ICON_ERROR | SWT.ICON_INFORMATION | SWT.ICON_WARNING);
        switch (id) {
            case SWT.ICON_ERROR: buffer = "gtk-dialog-error"; break;
            case SWT.ICON_INFORMATION: buffer = "gtk-dialog-info"; break;
            case SWT.ICON_WARNING: buffer = "gtk-dialog-warning"; break;
            default:
        }
        if (buffer !is null) {
            auto style = OS.gtk_widget_get_default_style ();
            auto pixbuf = OS.gtk_icon_set_render_icon (
                OS.gtk_icon_factory_lookup_default (buffer.ptr),
                style,
                OS.GTK_TEXT_DIR_NONE,
                OS.GTK_STATE_NORMAL,
                OS.GTK_ICON_SIZE_MENU,
                null,
                null);
            OS.gdk_draw_pixbuf (window, gdkGC, pixbuf, 0, 0, x, y, IMAGE_SIZE, IMAGE_SIZE, OS.GDK_RGB_DITHER_NORMAL, 0, 0);
            OS.g_object_unref (pixbuf);
            x += IMAGE_SIZE;
        }
        x += INSET;
        OS.gdk_draw_layout (window, gdkGC, x, y, layoutText);
        int w, h;
        OS.pango_layout_get_size (layoutText, &w, &h);
        y += 2 * PADDING + Math.max (IMAGE_SIZE, OS.PANGO_PIXELS (h ));
    }
    if (layoutMessage !is null) {
        x = BORDER + PADDING + INSET;
        OS.gdk_draw_layout (window, gdkGC, x, y, layoutMessage);
    }
    OS.g_object_unref (gdkGC);
    return 0;
}

override int gtk_size_allocate (GtkWidget* widget, ptrdiff_t allocation) {
    Point point = getLocation ();
    int x = point.x;
    int y = point.y;
    auto screen = OS.gdk_screen_get_default ();
    OS.gtk_widget_realize (widget);
    int monitorNumber = OS.gdk_screen_get_monitor_at_window (screen, OS.GTK_WIDGET_WINDOW (widget));
    GdkRectangle* dest = new GdkRectangle ();
    OS.gdk_screen_get_monitor_geometry (screen, monitorNumber, dest);
    int w = OS.GTK_WIDGET_WIDTH (widget);
    int h = OS.GTK_WIDGET_HEIGHT (widget);
    if (dest.height < y + h) y -= h;
    if (dest.width < x + w) x -= w;
    OS.gtk_window_move (cast(GtkWindow*)widget, x, y);
    return 0;
}

override void hookEvents () {
    if ((style & SWT.BALLOON) !is 0) {
        OS.g_signal_connect_closure (handle, OS.expose_event.ptr, display.closures [EXPOSE_EVENT], false);
        OS.gtk_widget_add_events (handle, OS.GDK_BUTTON_PRESS_MASK);
        OS.g_signal_connect_closure (handle, OS.button_press_event.ptr, display.closures [BUTTON_PRESS_EVENT], false);
    } else {
        auto tipWindow = OS.GTK_TOOLTIPS_TIP_WINDOW (cast(GtkTooltips*)handle);
        if (tipWindow !is null) {
            OS.g_signal_connect_closure (tipWindow, OS.size_allocate.ptr, display.closures [SIZE_ALLOCATE], false);
            OS.gtk_widget_add_events (tipWindow, OS.GDK_BUTTON_PRESS_MASK);
            OS.g_signal_connect_closure (tipWindow, OS.button_press_event.ptr, display.closures [BUTTON_PRESS_EVENT], false);
        }
    }
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
    checkWidget ();
    return getVisible ();
}

override void register () {
    super.register ();
    if ((style & SWT.BALLOON) is 0) {
        auto tipWindow = OS.GTK_TOOLTIPS_TIP_WINDOW (cast(GtkTooltips*)handle);
        if (tipWindow !is null) display.addWidget (tipWindow, this);
    }
}

override void releaseWidget () {
    super.releaseWidget ();
    if (layoutText !is null) OS.g_object_unref (layoutText);
    layoutText = null;
    if (layoutMessage !is null) OS.g_object_unref (layoutMessage);
    layoutMessage = null;
    if (timerId !is 0) OS.gtk_timeout_remove(timerId);
    timerId = 0;
    text = null;
    message = null;
    borderPolygon = null;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the receiver is selected by the user.
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
public void removeSelectionListener (SelectionListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Selection, listener);
    eventTable.unhook (SWT.DefaultSelection, listener);
}

/**
 * Makes the receiver hide automatically when <code>true</code>,
 * and remain visible when <code>false</code>.
 *
 * @param autoHide the auto hide state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getVisible
 * @see #setVisible
 */
public void setAutoHide (bool autohide) {
    checkWidget ();
    this.autohide = autohide;
    //TODO - update when visible
}

/**
 * Sets the location of the receiver, which must be a tooltip,
 * to the point specified by the arguments which are relative
 * to the display.
 * <p>
 * Note that this is different from most widgets where the
 * location of the widget is relative to the parent.
 * </p>
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
    checkWidget ();
    this.x = x;
    this.y = y;
    if ((style & SWT.BALLOON) !is 0) {
        if (OS.GTK_WIDGET_VISIBLE (handle)) configure ();
    } else {
        auto tipWindow = OS.GTK_TOOLTIPS_TIP_WINDOW (cast(GtkTooltips*)handle);
        if (OS.GTK_WIDGET_VISIBLE (tipWindow)) {
            OS.gtk_window_move (cast(GtkWindow*)tipWindow, x, y);
        }
    }
}

/**
 * Sets the location of the receiver, which must be a tooltip,
 * to the point specified by the argument which is relative
 * to the display.
 * <p>
 * Note that this is different from most widgets where the
 * location of the widget is relative to the parent.
 * </p><p>
 * Note that the platform window manager ultimately has control
 * over the location of tooltips.
 * </p>
 *
 * @param location the new location for the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLocation (Point location) {
    checkWidget ();
    if (location is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    setLocation (location.x, location.y);
}

/**
 * Sets the receiver's message.
 *
 * @param string the new message
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMessage (String string) {
    checkWidget ();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    message = string;
    if ((style & SWT.BALLOON) is 0) return;
    if (layoutMessage !is null) OS.g_object_unref (layoutMessage);
    layoutMessage = null;
    if (message.length !is 0) {
        layoutMessage = OS.gtk_widget_create_pango_layout (handle, message.toStringzValidPtr());
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
            OS.pango_layout_set_auto_dir (layoutMessage, false);
        }
        OS.pango_layout_set_wrap (layoutMessage, OS.PANGO_WRAP_WORD_CHAR);
    }
    if (OS.GTK_WIDGET_VISIBLE (handle)) configure ();
}

/**
 * Sets the receiver's text.
 *
 * @param string the new text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setText (String string) {
    checkWidget ();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    text = string;
    if ((style & SWT.BALLOON) is 0) return;
    if (layoutText !is null) OS.g_object_unref (layoutText);
    layoutText = null;
    if (text.length !is 0) {
        layoutText = OS.gtk_widget_create_pango_layout (handle, text.toStringzValidPtr());
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
            OS.pango_layout_set_auto_dir (layoutText, false);
        }
        auto boldAttr = OS.pango_attr_weight_new (OS.PANGO_WEIGHT_BOLD);
        boldAttr.start_index = 0;
        boldAttr.end_index = cast(int)/*64bit*/text.length+1;
        auto attrList = OS.pango_attr_list_new ();
        OS.pango_attr_list_insert (attrList, boldAttr);
        OS.pango_layout_set_attributes (layoutText, attrList);
        OS.pango_attr_list_unref (attrList);
        OS.pango_layout_set_wrap (layoutText, OS.PANGO_WRAP_WORD_CHAR);
    }
    if (OS.GTK_WIDGET_VISIBLE (handle)) configure ();
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
    if (timerId !is 0) OS.gtk_timeout_remove(timerId);
    timerId = 0;
    if (visible) {
        if ((style & SWT.BALLOON) !is 0) {
            configure ();
            OS.gtk_widget_show (handle);
        } else {
            auto vboxHandle = parent.vboxHandle;
            String string = text;
            if (text.length > 0) string ~= "\n\n";
            string ~= message;
            char* buffer = toStringz( string );
            OS.gtk_tooltips_set_tip (cast(GtkTooltips*)handle, vboxHandle, buffer, null);
            auto data = OS.gtk_tooltips_data_get (vboxHandle);
            OS.GTK_TOOLTIPS_SET_ACTIVE (cast(GtkTooltips*)handle, data);
            OS.gtk_tooltips_set_tip (cast(GtkTooltips*)handle, vboxHandle, buffer, null);
        }
        if (autohide) timerId = display.doWindowTimerAdd( &timerProcCallbackData, DELAY, handle);
    } else {
        if ((style & SWT.BALLOON) !is 0) {
            OS.gtk_widget_hide (handle);
        } else {
            auto tipWindow = OS.GTK_TOOLTIPS_TIP_WINDOW (cast(GtkTooltips*)handle);
            OS.gtk_widget_hide (tipWindow);
        }
    }
}

override int timerProc (GtkWidget* widget) {
    if ((style & SWT.BALLOON) !is 0) {
        OS.gtk_widget_hide (handle);
    } else {
        auto tipWindow = OS.GTK_TOOLTIPS_TIP_WINDOW (cast(GtkTooltips*)handle);
        OS.gtk_widget_hide (tipWindow);
    }
    return 0;
}

}
