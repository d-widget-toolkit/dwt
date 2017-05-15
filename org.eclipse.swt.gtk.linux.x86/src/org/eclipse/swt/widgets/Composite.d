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
module org.eclipse.swt.widgets.Composite;

import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Scrollable;
import org.eclipse.swt.widgets.Layout;
import org.eclipse.swt.widgets.Decorations;
import org.eclipse.swt.widgets.ScrollBar;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.graphics.GCData;

import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Region;
import org.eclipse.swt.internal.cairo.Cairo : Cairo;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.Rectangle;
import java.lang.all;

/**
 * Instances of this class are controls which are capable
 * of containing other controls.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>NO_BACKGROUND, NO_FOCUS, NO_MERGE_PAINTS, NO_REDRAW_RESIZE, NO_RADIO_GROUP, EMBEDDED, DOUBLE_BUFFERED</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: The <code>NO_BACKGROUND</code>, <code>NO_FOCUS</code>, <code>NO_MERGE_PAINTS</code>,
 * and <code>NO_REDRAW_RESIZE</code> styles are intended for use with <code>Canvas</code>.
 * They can be used with <code>Composite</code> if you are drawing your own, but their
 * behavior is undefined if they are used with subclasses of <code>Composite</code> other
 * than <code>Canvas</code>.
 * </p><p>
 * Note: The <code>CENTER</code> style, although undefined for composites, has the
 * same value as <code>EMBEDDED</code> (which is used to embed widgets from other
 * widget toolkits into SWT).  On some operating systems (GTK, Motif), this may cause
 * the children of this composite to be obscured.  The <code>EMBEDDED</code> style
 * is for use by other widget toolkits and should normally never be used.
 * </p><p>
 * This class may be subclassed by custom control implementors
 * who are building controls that are constructed from aggregates
 * of other controls.
 * </p>
 *
 * @see Canvas
 * @see <a href="http://www.eclipse.org/swt/snippets/#composite">Composite snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Composite : Scrollable {

    alias Scrollable.computeSize computeSize;
    alias Scrollable.fixStyle fixStyle;
    alias Scrollable.forceFocus forceFocus;
    alias Scrollable.gtk_button_press_event gtk_button_press_event;
    alias Scrollable.moveAbove moveAbove;
    alias Scrollable.moveBelow moveBelow;
    alias Scrollable.setBounds setBounds;
    alias Scrollable.translateMnemonic translateMnemonic;
    alias Scrollable.translateTraversal translateTraversal;

    public size_t  embeddedHandle;
    GtkIMContext* imHandle_;
    GtkWidget* socketHandle;
    Layout layout_;
    Control[] tabList;
    int layoutCount, backgroundMode;

    static const String NO_INPUT_METHOD = "org.eclipse.swt.internal.gtk.noInputMethod"; //$NON-NLS-1$

this () {
    /* Do nothing */
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
 * @param parent a widget which will be the parent of the new instance (cannot be null)
 * @param style the style of widget to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 *
 * @see SWT#NO_BACKGROUND
 * @see SWT#NO_FOCUS
 * @see SWT#NO_MERGE_PAINTS
 * @see SWT#NO_REDRAW_RESIZE
 * @see SWT#NO_RADIO_GROUP
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

static int checkStyle (int style) {
    style &= ~SWT.TRANSPARENT;
    return style;
}

Control [] _getChildren () {
    auto parentHandle = parentingHandle ();
    auto list = OS.gtk_container_get_children (cast(GtkContainer*)parentHandle);
    if (list is null) return new Control [0];
    int count = OS.g_list_length (list);
    Control [] children = new Control [count];
    int i = 0;
    auto temp = list;
    while (temp !is null) {
        auto handle = cast(GtkWidget*)OS.g_list_data (temp);
        if (handle !is null) {
            Widget widget = display.getWidget (handle);
            if (widget !is null && widget !is this) {
                if (auto c = cast(Control)widget) {
                    children [i++] = c;
                }
            }
        }
        temp = cast(GList*)OS.g_list_next (temp);
    }
    OS.g_list_free (list);
    if (i is count) return children;
    Control [] newChildren = new Control [i];
    System.arraycopy (children, 0, newChildren, 0, i);
    return newChildren;
}

Control [] _getTabList () {
    if (tabList is null) return tabList;
    int count = 0;
    for (int i=0; i<tabList.length; i++) {
        if (!tabList [i].isDisposed ()) count++;
    }
    if (count is tabList.length) return tabList;
    Control [] newList = new Control [count];
    int index = 0;
    for (int i=0; i<tabList.length; i++) {
        if (!tabList [i].isDisposed ()) {
            newList [index++] = tabList [i];
        }
    }
    tabList = newList;
    return tabList;
}

/**
 * Clears any data that has been cached by a Layout for all widgets that
 * are in the parent hierarchy of the changed control up to and including the
 * receiver.  If an ancestor does not have a layout, it is skipped.
 *
 * @param changed an array of controls that changed state and require a recalculation of size
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the changed array is null any of its controls are null or have been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if any control in changed is not in the widget tree of the receiver</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void changed (Control[] changed) {
    checkWidget ();
    if (changed is null) error (SWT.ERROR_INVALID_ARGUMENT);
    for (int i=0; i<changed.length; i++) {
        Control control = changed [i];
        if (control is null) error (SWT.ERROR_INVALID_ARGUMENT);
        if (control.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
        bool ancestor = false;
        Composite composite = control.parent;
        while (composite !is null) {
            ancestor = composite is this;
            if (ancestor) break;
            composite = composite.parent;
        }
        if (!ancestor) error (SWT.ERROR_INVALID_PARENT);
    }
    for (int i=0; i<changed.length; i++) {
        Control child = changed [i];
        Composite composite = child.parent;
        while (child !is this) {
            if (composite.layout_ is null || !composite.layout_.flushCache (child)) {
                composite.state |= LAYOUT_CHANGED;
            }
            child = composite;
            composite = child.parent;
        }
    }
}

override void checkBuffered () {
    if ((style & SWT.DOUBLE_BUFFERED) is 0 && (style & SWT.NO_BACKGROUND) !is 0) {
        return;
    }
    super.checkBuffered();
}

override protected void checkSubclass () {
    /* Do nothing - Subclassing is allowed */
}

override GtkStyle* childStyle () {
    if (scrolledHandle !is null) return null;
    return super.childStyle ();
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    if (wHint !is SWT.DEFAULT && wHint < 0) wHint = 0;
    if (hHint !is SWT.DEFAULT && hHint < 0) hHint = 0;
    Point size;
    if (layout_ !is null) {
        if (wHint is SWT.DEFAULT || hHint is SWT.DEFAULT) {
            changed |= (state & LAYOUT_CHANGED) !is 0;
            size = layout_.computeSize (this, wHint, hHint, changed);
            state &= ~LAYOUT_CHANGED;
        } else {
            size = new Point (wHint, hHint);
        }
    } else {
        size = minimumSize (wHint, hHint, changed);
    }
    if (size.x is 0) size.x = DEFAULT_WIDTH;
    if (size.y is 0) size.y = DEFAULT_HEIGHT;
    if (wHint !is SWT.DEFAULT) size.x = wHint;
    if (hHint !is SWT.DEFAULT) size.y = hHint;
    Rectangle trim = computeTrim (0, 0, size.x, size.y);
    return new Point (trim.width, trim.height);
}

override Control [] computeTabList () {
    Control[] result = super.computeTabList ();
    if (result.length is 0) return result;
    Control [] list = tabList !is null ? _getTabList () : _getChildren ();
    for (int i=0; i<list.length; i++) {
        Control child = list [i];
        Control [] childList = child.computeTabList ();
        if (childList.length !is 0) {
            Control [] newResult = new Control [result.length + childList.length];
            System.arraycopy (result, 0, newResult, 0, result.length);
            System.arraycopy (childList, 0, newResult, result.length, childList.length);
            result = newResult;
        }
    }
    return result;
}

override void createHandle (int index) {
    state |= HANDLE | CANVAS;
    bool scrolled = (style & (SWT.H_SCROLL | SWT.V_SCROLL)) !is 0;
    if (!scrolled) state |= THEME_BACKGROUND;
    createHandle (index, true, scrolled || (style & SWT.BORDER) !is 0);
}

void createHandle (int index, bool fixed, bool scrolled) {
    if (scrolled) {
        if (fixed) {
            fixedHandle = cast(GtkWidget*) OS.g_object_new (display.gtk_fixed_get_type (), null);
            if (fixedHandle is null) error (SWT.ERROR_NO_HANDLES);
            OS.gtk_fixed_set_has_window (cast(GtkFixed*)fixedHandle, true);
        }
        auto vadj = cast(GtkAdjustment*)OS.gtk_adjustment_new (0, 0, 100, 1, 10, 10);
        if (vadj is null) error (SWT.ERROR_NO_HANDLES);
        auto hadj = cast(GtkAdjustment*)OS.gtk_adjustment_new (0, 0, 100, 1, 10, 10);
        if (hadj is null) error (SWT.ERROR_NO_HANDLES);
        scrolledHandle = cast(GtkWidget*) OS.gtk_scrolled_window_new (hadj, vadj);
        if (scrolledHandle is null) SWT.error (SWT.ERROR_NO_HANDLES);
    }
    handle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (handle is null) SWT.error (SWT.ERROR_NO_HANDLES);
    OS.gtk_fixed_set_has_window (cast(GtkFixed*)handle, true);
    OS.GTK_WIDGET_SET_FLAGS(handle, OS.GTK_CAN_FOCUS);
    if ((style & SWT.EMBEDDED) is 0) {
        if ((state & CANVAS) !is 0) {
            /* Prevent an input method context from being created for the Browser widget */
            if (display.getData (NO_INPUT_METHOD) is null) {
                imHandle_ = OS.gtk_im_multicontext_new ();
                if (imHandle_ is null) error (SWT.ERROR_NO_HANDLES);
            }
        }
    }
    if (scrolled) {
        if (fixed) OS.gtk_container_add (cast(GtkContainer*)fixedHandle, scrolledHandle);
        /*
        * Force the scrolledWindow to have a single child that is
        * not scrolled automatically.  Calling gtk_container_add()
        * seems to add the child correctly but cause a warning.
        */
        bool warnings = display.getWarnings ();
        display.setWarnings (false);
        OS.gtk_container_add (cast(GtkContainer*)scrolledHandle, handle);
        display.setWarnings (warnings);

        int hsp = (style & SWT.H_SCROLL) !is 0 ? OS.GTK_POLICY_ALWAYS : OS.GTK_POLICY_NEVER;
        int vsp = (style & SWT.V_SCROLL) !is 0 ? OS.GTK_POLICY_ALWAYS : OS.GTK_POLICY_NEVER;
        OS.gtk_scrolled_window_set_policy (cast(GtkScrolledWindow*)scrolledHandle, hsp, vsp);
        if (hasBorder ()) {
            OS.gtk_scrolled_window_set_shadow_type (cast(GtkScrolledWindow*)scrolledHandle, OS.GTK_SHADOW_ETCHED_IN);
        }
    }
    if ((style & SWT.EMBEDDED) !is 0) {
        socketHandle = OS.gtk_socket_new ();
        if (socketHandle is null) SWT.error (SWT.ERROR_NO_HANDLES);
        OS.gtk_container_add (cast(GtkContainer*)handle, cast(GtkWidget*)socketHandle);
    }
    if ((style & SWT.NO_REDRAW_RESIZE) !is 0 && (style & SWT.RIGHT_TO_LEFT) is 0) {
        OS.gtk_widget_set_redraw_on_allocate (handle, false);
    }
    /*
    * Bug in GTK.  When a widget is double buffered and the back
    * pixmap is null, the double buffer pixmap is filled with the
    * background of the widget rather than the current contents of
    * the screen.  If nothing is drawn during an expose event,
    * the pixels are altered.  The fix is to clear double buffering
    * when NO_BACKGROUND is set and DOUBLE_BUFFERED
    * is not explicitly set.
    */
    if ((style & SWT.DOUBLE_BUFFERED) is 0 && (style & SWT.NO_BACKGROUND) !is 0) {
        OS.gtk_widget_set_double_buffered (handle, false);
    }
}

override void deregister () {
    super.deregister ();
    if (socketHandle !is null) display.removeWidget (cast(GtkWidget*)socketHandle);
}

void drawBackground (GC gc, int x, int y, int width, int height) {
    Control control = findBackgroundControl ();
    if (control !is null) {
        GCData data = gc.getGCData ();
        auto cairo = data.cairo;
        if (cairo !is null) {
            Cairo.cairo_save (cairo);
            if (control.backgroundImage !is null) {
                Point pt = display.map (this, control, 0, 0);
                Cairo.cairo_translate (cairo, -pt.x, -pt.y);
                x += pt.x;
                y += pt.y;
                auto xDisplay = OS.GDK_DISPLAY ();
                auto xVisual = OS.gdk_x11_visual_get_xvisual (OS.gdk_visual_get_system());
                auto drawable = control.backgroundImage.pixmap;
                auto xDrawable = OS.GDK_PIXMAP_XID (drawable);
                int w, h;
                OS.gdk_drawable_get_size (cast(GdkDrawable*)drawable, &w, &h);
                auto surface = Cairo.cairo_xlib_surface_create (xDisplay, xDrawable, xVisual, w, h);
                if (surface is null) error (SWT.ERROR_NO_HANDLES);
                auto pattern = Cairo.cairo_pattern_create_for_surface (surface);
                if (pattern is null) error (SWT.ERROR_NO_HANDLES);
                Cairo.cairo_pattern_set_extend (pattern, Cairo.CAIRO_EXTEND_REPEAT);
                if ((data.style & SWT.MIRRORED) !is 0) {
                    double[] matrix = [-1.0, 0, 0, 1, 0, 0 ];
                    Cairo.cairo_pattern_set_matrix(pattern, cast(cairo_matrix_t*)matrix.ptr);
                }
                Cairo.cairo_set_source (cairo, pattern);
                Cairo.cairo_surface_destroy (surface);
                Cairo.cairo_pattern_destroy (pattern);
            } else {
                GdkColor* color = control.getBackgroundColor ();
                Cairo.cairo_set_source_rgba (cairo, (color.red & 0xFFFF) / cast(float)0xFFFF, (color.green & 0xFFFF) / cast(float)0xFFFF, (color.blue & 0xFFFF) / cast(float)0xFFFF, data.alpha / cast(float)0xFF);
            }
            Cairo.cairo_rectangle (cairo, x, y, width, height);
            Cairo.cairo_fill (cairo);
            Cairo.cairo_restore (cairo);
        } else {
            auto gdkGC = gc.handle;
            GdkGCValues* values = new GdkGCValues ();
            OS.gdk_gc_get_values (gdkGC, values);
            if (control.backgroundImage !is null) {
                Point pt = display.map (this, control, 0, 0);
                OS.gdk_gc_set_fill (gdkGC, OS.GDK_TILED);
                OS.gdk_gc_set_ts_origin (gdkGC, -pt.x, -pt.y);
                OS.gdk_gc_set_tile (gdkGC, control.backgroundImage.pixmap);
                OS.gdk_draw_rectangle (data.drawable, gdkGC, 1, x, y, width, height);
                OS.gdk_gc_set_fill (gdkGC, values.fill);
                OS.gdk_gc_set_ts_origin (gdkGC, values.ts_x_origin, values.ts_y_origin);
            } else {
                GdkColor* color = control.getBackgroundColor ();
                OS.gdk_gc_set_foreground (gdkGC, color);
                OS.gdk_draw_rectangle (data.drawable, gdkGC, 1, x, y, width, height);
                color.pixel = values.foreground.pixel;
                OS.gdk_gc_set_foreground (gdkGC, color);
            }
        }
    } else {
        gc.fillRectangle (x, y, width, height);
    }
}

override void enableWidget (bool enabled) {
    if ((state & CANVAS) !is 0) return;
    super.enableWidget (enabled);
}

Composite findDeferredControl () {
    return layoutCount > 0 ? this : parent.findDeferredControl ();
}

override Menu [] findMenus (Control control) {
    if (control is this) return new Menu [0];
    Menu[] result = super.findMenus (control);
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        Menu [] menuList = child.findMenus (control);
        if (menuList.length !is 0) {
            Menu [] newResult = new Menu [result.length + menuList.length];
            System.arraycopy (result, 0, newResult, 0, result.length);
            System.arraycopy (menuList, 0, newResult, result.length, menuList.length);
            result = newResult;
        }
    }
    return result;
}

override void fixChildren (Shell newShell, Shell oldShell, Decorations newDecorations, Decorations oldDecorations, Menu [] menus) {
    super.fixChildren (newShell, oldShell, newDecorations, oldDecorations, menus);
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        children [i].fixChildren (newShell, oldShell, newDecorations, oldDecorations, menus);
    }
}

override
void fixModal(GtkWidget* group, GtkWidget* modalGroup)  {
    Control[] controls = _getChildren ();
    for (int i = 0; i < controls.length; i++) {
        controls[i].fixModal (group, modalGroup);
    }
}

override void fixStyle () {
    super.fixStyle ();
    if (scrolledHandle is null) fixStyle (handle);
    Control[] children = _getChildren ();
    for (int i = 0; i < children.length; i++) {
        children [i].fixStyle ();
    }
}

void fixTabList (Control control) {
    if (tabList is null) return;
    int count = 0;
    for (int i=0; i<tabList.length; i++) {
        if (tabList [i] is control) count++;
    }
    if (count is 0) return;
    Control [] newList = null;
    ptrdiff_t length = tabList.length - count;
    if (length !is 0) {
        newList = new Control [length];
        int index = 0;
        for (int i=0; i<tabList.length; i++) {
            if (tabList [i] !is control) {
                newList [index++] = tabList [i];
            }
        }
    }
    tabList = newList;
}

void fixZOrder () {
    if ((state & CANVAS) !is 0) return;
    auto parentHandle = parentingHandle ();
    auto parentWindow = OS.GTK_WIDGET_WINDOW (cast(GtkWidget*)parentHandle);
    if (parentWindow is null) return;
    GObject* userData;
    auto windowList = OS.gdk_window_get_children (parentWindow);
    if (windowList !is null) {
        auto windows = windowList;
        while (windows !is null) {
            auto window = cast(GdkDrawable*)OS.g_list_data (windows);
            if (window !is redrawWindow) {
                OS.gdk_window_get_user_data (window, cast(void**)&userData);
                if (userData is null || OS.G_OBJECT_TYPE (cast(GTypeInstance*)userData) !is display.gtk_fixed_get_type ()) {
                    OS.gdk_window_lower (window);
                }
            }
            windows = cast(GList*)OS.g_list_next (windows);
        }
        OS.g_list_free (windowList);
    }
}

override GtkWidget* focusHandle () {
    if (socketHandle !is null) return socketHandle;
    return super.focusHandle ();
}

override bool forceFocus (GtkWidget* focusHandle) {
    if (socketHandle !is null) OS.GTK_WIDGET_SET_FLAGS (focusHandle, OS.GTK_CAN_FOCUS);
    bool result = super.forceFocus (focusHandle);
    if (socketHandle !is null) OS.GTK_WIDGET_UNSET_FLAGS (focusHandle, OS.GTK_CAN_FOCUS);
    return result;
}

/**
 * Returns the receiver's background drawing mode. This
 * will be one of the following constants defined in class
 * <code>SWT</code>:
 * <code>INHERIT_NONE</code>, <code>INHERIT_DEFAULT</code>,
 * <code>INHERTIT_FORCE</code>.
 *
 * @return the background mode
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SWT
 *
 * @since 3.2
 */
public int getBackgroundMode () {
    checkWidget ();
    return backgroundMode;
}

/**
 * Returns a (possibly empty) array containing the receiver's children.
 * Children are returned in the order that they are drawn.  The topmost
 * control appears at the beginning of the array.  Subsequent controls
 * draw beneath this control and appear later in the array.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of children, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return an array of children
 *
 * @see Control#moveAbove
 * @see Control#moveBelow
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Control [] getChildren () {
    checkWidget();
    return _getChildren ();
}

int getChildrenCount () {
    /*
    * NOTE: The current implementation will count
    * non-registered children.
    */
    auto list = OS.gtk_container_get_children (cast(GtkContainer*)handle);
    if (list is null) return 0;
    int count = OS.g_list_length (list);
    OS.g_list_free (list);
    return count;
}

override public Rectangle getClientArea () {
    checkWidget();
    if ((state & CANVAS) !is 0) {
        if ((state & ZERO_WIDTH) !is 0 && (state & ZERO_HEIGHT) !is 0) {
            return new Rectangle (0, 0, 0, 0);
        }
        forceResize ();
        auto clientHandle = clientHandle ();
        int width = (state & ZERO_WIDTH) !is 0 ? 0 : OS.GTK_WIDGET_WIDTH (clientHandle);
        int height = (state & ZERO_HEIGHT) !is 0 ? 0 : OS.GTK_WIDGET_HEIGHT (clientHandle);
        return new Rectangle (0, 0, width, height);
    }
    return super.getClientArea();
}

override
int getClientWidth() {
    return (state & ZERO_WIDTH) !is 0 ? 0 : OS.GTK_WIDGET_WIDTH (clientHandle ());
}

/**
 * Returns layout which is associated with the receiver, or
 * null if one has not been set.
 *
 * @return the receiver's layout or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Layout getLayout () {
    checkWidget();
    return layout_;
}

/**
 * Returns <code>true</code> if the receiver has deferred
 * the performing of layout, and <code>false</code> otherwise.
 *
 * @return the receiver's deferred layout state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setLayoutDeferred(bool)
 * @see #isLayoutDeferred()
 *
 * @since 3.1
 */
public bool getLayoutDeferred () {
    checkWidget ();
    return layoutCount > 0 ;
}

/**
 * Gets the (possibly empty) tabbing order for the control.
 *
 * @return tabList the ordered list of controls representing the tab order
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setTabList
 */
public Control [] getTabList () {
    checkWidget ();
    Control [] tabList = _getTabList ();
    if (tabList is null) {
        int count = 0;
        Control [] list =_getChildren ();
        for (int i=0; i<list.length; i++) {
            if (list [i].isTabGroup ()) count++;
        }
        tabList = new Control [count];
        int index = 0;
        for (int i=0; i<list.length; i++) {
            if (list [i].isTabGroup ()) {
                tabList [index++] = list [i];
            }
        }
    }
    return tabList;
}

override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* event) {
    auto result = super.gtk_button_press_event (widget, event);
    if (result !is 0) return result;
    if ((state & CANVAS) !is 0) {
        if ((style & SWT.NO_FOCUS) is 0 && hooksKeys ()) {
            if (event.button is 1) {
                if (getChildrenCount () is 0) setFocus ();
            }
        }
    }
    return result;
}

override int gtk_expose_event (GtkWidget* widget, GdkEventExpose* eventPtr) {
    if ((state & OBSCURED) !is 0) return 0;
    if ((state & CANVAS) is 0) {
        return super.gtk_expose_event (widget, eventPtr);
    }
    if ((style & SWT.NO_MERGE_PAINTS) is 0) {
        return super.gtk_expose_event (widget, eventPtr);
    }
    if (!hooks (SWT.Paint) && !filters (SWT.Paint)) return 0;
    GdkEventExpose* gdkEvent = eventPtr;
    GdkRectangle* rectangles;
    int n_rectangles;
    OS.gdk_region_get_rectangles (gdkEvent.region, &rectangles, &n_rectangles);
    for (int i=0; i<n_rectangles; i++) {
        Event event = new Event ();
        event.x = rectangles[i].x;
        event.y = rectangles[i].y;
        event.width = rectangles[i].width;
        event.height = rectangles[i].height;
        if ((style & SWT.MIRRORED) !is 0) event.x = getClientWidth () - event.width - event.x;
        auto damageRgn = OS.gdk_region_new ();
        OS.gdk_region_union_with_rect (damageRgn, rectangles + i );
        GCData data = new GCData ();
        data.damageRgn = damageRgn;
        GC gc = event.gc = GC.gtk_new (this, data);
        OS.gdk_gc_set_clip_region (gc.handle, damageRgn);
        sendEvent (SWT.Paint, event);
        gc.dispose ();
        OS.gdk_region_destroy (damageRgn);
        event.gc = null;
    }
    OS.g_free (rectangles);
    return 0;
}

override int gtk_key_press_event (GtkWidget* widget, GdkEventKey* event) {
    auto result = super.gtk_key_press_event (widget, event);
    if (result !is 0) return result;
    /*
    * Feature in GTK.  The default behavior when the return key
    * is pressed is to select the default button.  This is not the
    * expected behavior for Composite and its subclasses.  The
    * fix is to avoid calling the default handler.
    */
    if ((state & CANVAS) !is 0 && socketHandle is null) {
        GdkEventKey* keyEvent = event;
        int key = keyEvent.keyval;
        switch (key) {
            case OS.GDK_Return:
            case OS.GDK_KP_Enter: return 1;
            default:
        }
    }
    return result;
}

override int gtk_focus (GtkWidget* widget, ptrdiff_t directionType) {
    if (widget is socketHandle) return 0;
    return super.gtk_focus (widget, directionType);
}

override int gtk_focus_in_event (GtkWidget* widget, GdkEventFocus* event) {
    int result = super.gtk_focus_in_event (widget, event);
    return (state & CANVAS) !is 0 ? 1 : result;
}

override int gtk_focus_out_event (GtkWidget* widget, GdkEventFocus* event) {
    auto result = super.gtk_focus_out_event (widget, event);
    return (state & CANVAS) !is 0 ? 1 : result;
}

override int gtk_map (GtkWidget* widget) {
    fixZOrder ();
    return 0;
}

override int gtk_realize (GtkWidget* widget) {
    auto result = super.gtk_realize (widget);
    if ((style & SWT.NO_BACKGROUND) !is 0) {
        auto window = OS.GTK_WIDGET_WINDOW (paintHandle ());
        if (window !is null) OS.gdk_window_set_back_pixmap (window, null, false);
    }
    if (socketHandle !is null) {
        embeddedHandle = OS.gtk_socket_get_id (cast(GtkSocket*)socketHandle);
    }
    return result;
}

override int gtk_scroll_child (GtkWidget* widget, ptrdiff_t scrollType, ptrdiff_t horizontal) {
    /* Stop GTK scroll child signal for canvas */
    OS.g_signal_stop_emission_by_name (widget, OS.scroll_child.ptr);
    return 1;
}

override int gtk_style_set (GtkWidget* widget, ptrdiff_t previousStyle) {
    auto result = super.gtk_style_set (widget, previousStyle);
    if ((style & SWT.NO_BACKGROUND) !is 0) {
        auto window = OS.GTK_WIDGET_WINDOW (paintHandle ());
        if (window !is null) OS.gdk_window_set_back_pixmap (window, null, false);
    }
    return result;
}

bool hasBorder () {
    return (style & SWT.BORDER) !is 0;
}

override void hookEvents () {
    super.hookEvents ();
    if ((state & CANVAS) !is 0) {
        OS.gtk_widget_add_events (handle, OS.GDK_POINTER_MOTION_HINT_MASK);
        if (scrolledHandle !is null) {
            OS.g_signal_connect_closure (scrolledHandle, OS.scroll_child.ptr, display.closures [SCROLL_CHILD], false);
        }
    }
}

bool hooksKeys () {
    return hooks (SWT.KeyDown) || hooks (SWT.KeyUp);
}

override GtkIMContext* imHandle () {
    return imHandle_;
}

/**
 * Returns <code>true</code> if the receiver or any ancestor
 * up to and including the receiver's nearest ancestor shell
 * has deferred the performing of layouts.  Otherwise, <code>false</code>
 * is returned.
 *
 * @return the receiver's deferred layout state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setLayoutDeferred(bool)
 * @see #getLayoutDeferred()
 *
 * @since 3.1
 */
public bool isLayoutDeferred () {
    checkWidget ();
    return findDeferredControl () !is null;
}

override bool isTabGroup() {
    if ((state & CANVAS) !is 0) return true;
    return super.isTabGroup();
}

/**
 * If the receiver has a layout, asks the layout to <em>lay out</em>
 * (that is, set the size and location of) the receiver's children.
 * If the receiver does not have a layout, do nothing.
 * <p>
 * This is equivalent to calling <code>layout(true)</code>.
 * </p>
 * <p>
 * Note: Layout is different from painting. If a child is
 * moved or resized such that an area in the parent is
 * exposed, then the parent will paint. If no child is
 * affected, the parent will not paint.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void layout () {
    checkWidget ();
    layout (true);
}

/**
 * If the receiver has a layout, asks the layout to <em>lay out</em>
 * (that is, set the size and location of) the receiver's children.
 * If the argument is <code>true</code> the layout must not rely
 * on any information it has cached about the immediate children. If it
 * is <code>false</code> the layout may (potentially) optimize the
 * work it is doing by assuming that none of the receiver's
 * children has changed state since the last layout.
 * If the receiver does not have a layout, do nothing.
 * <p>
 * If a child is resized as a result of a call to layout, the
 * resize event will invoke the layout of the child.  The layout
 * will cascade down through all child widgets in the receiver's widget
 * tree until a child is encountered that does not resize.  Note that
 * a layout due to a resize will not flush any cached information
 * (same as <code>layout(false)</code>).
 * </p>
 * <p>
 * Note: Layout is different from painting. If a child is
 * moved or resized such that an area in the parent is
 * exposed, then the parent will paint. If no child is
 * affected, the parent will not paint.
 * </p>
 *
 * @param changed <code>true</code> if the layout must flush its caches, and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void layout (bool changed) {
    checkWidget ();
    if (layout_ is null) return;
    layout (changed, false);
}

/**
 * If the receiver has a layout, asks the layout to <em>lay out</em>
 * (that is, set the size and location of) the receiver's children.
 * If the changed argument is <code>true</code> the layout must not rely
 * on any information it has cached about its children. If it
 * is <code>false</code> the layout may (potentially) optimize the
 * work it is doing by assuming that none of the receiver's
 * children has changed state since the last layout.
 * If the all argument is <code>true</code> the layout will cascade down
 * through all child widgets in the receiver's widget tree, regardless of
 * whether the child has changed size.  The changed argument is applied to
 * all layouts.  If the all argument is <code>false</code>, the layout will
 * <em>not</em> cascade down through all child widgets in the receiver's widget
 * tree.  However, if a child is resized as a result of a call to layout, the
 * resize event will invoke the layout of the child.  Note that
 * a layout due to a resize will not flush any cached information
 * (same as <code>layout(false)</code>).
 * </p>
 * <p>
 * Note: Layout is different from painting. If a child is
 * moved or resized such that an area in the parent is
 * exposed, then the parent will paint. If no child is
 * affected, the parent will not paint.
 * </p>
 *
 * @param changed <code>true</code> if the layout must flush its caches, and <code>false</code> otherwise
 * @param all <code>true</code> if all children in the receiver's widget tree should be laid out, and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void layout (bool changed, bool all) {
    checkWidget ();
    if (layout_ is null && !all) return;
    markLayout (changed, all);
    updateLayout (all);
}

/**
 * Forces a lay out (that is, sets the size and location) of all widgets that
 * are in the parent hierarchy of the changed control up to and including the
 * receiver.  The layouts in the hierarchy must not rely on any information
 * cached about the changed control or any of its ancestors.  The layout may
 * (potentially) optimize the work it is doing by assuming that none of the
 * peers of the changed control have changed state since the last layout.
 * If an ancestor does not have a layout, skip it.
 * <p>
 * Note: Layout is different from painting. If a child is
 * moved or resized such that an area in the parent is
 * exposed, then the parent will paint. If no child is
 * affected, the parent will not paint.
 * </p>
 *
 * @param changed a control that has had a state change which requires a recalculation of its size
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the changed array is null any of its controls are null or have been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if any control in changed is not in the widget tree of the receiver</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void layout (Control [] changed) {
    checkWidget ();
    if (changed is null) error (SWT.ERROR_INVALID_ARGUMENT);
    for (int i=0; i<changed.length; i++) {
        Control control = changed [i];
        if (control is null) error (SWT.ERROR_INVALID_ARGUMENT);
        if (control.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
        bool ancestor = false;
        Composite composite = control.parent;
        while (composite !is null) {
            ancestor = composite is this;
            if (ancestor) break;
            composite = composite.parent;
        }
        if (!ancestor) error (SWT.ERROR_INVALID_PARENT);
    }
    int updateCount = 0;
    Composite [] update = new Composite [16];
    for (int i=0; i<changed.length; i++) {
        Control child = changed [i];
        Composite composite = child.parent;
        while (child !is this) {
            if (composite.layout_ !is null) {
                composite.state |= LAYOUT_NEEDED;
                if (!composite.layout_.flushCache (child)) {
                    composite.state |= LAYOUT_CHANGED;
                }
            }
            if (updateCount is update.length) {
                Composite [] newUpdate = new Composite [update.length + 16];
                System.arraycopy (update, 0, newUpdate, 0, update.length);
                update = newUpdate;
            }
            child = update [updateCount++] = composite;
            composite = child.parent;
        }
    }
    for (int i=updateCount-1; i>=0; i--) {
        update [i].updateLayout (false);
    }
}

override void markLayout (bool changed, bool all) {
    if (layout_ !is null) {
        state |= LAYOUT_NEEDED;
        if (changed) state |= LAYOUT_CHANGED;
    }
    if (all) {
        Control [] children = _getChildren ();
        for (int i=0; i<children.length; i++) {
            children [i].markLayout (changed, all);
        }
    }
}

void moveAbove (GtkWidget* child, GtkWidget* sibling) {
    if (child is sibling) return;
    auto parentHandle = parentingHandle ();
    auto fixed = cast(GtkFixed*)parentHandle;
    GList* children = fixed.children;
    if (children is null) return;
    void* data;
    GtkWidget* widget;
    void* childData;
    GList* childLink, siblingLink;
    GList* temp = children;
    while (temp !is null) {
        data = temp.data;
        widget = *cast(GtkWidget**) data;
        if (child is widget) {
            childLink = temp;
            childData = data;
        } else if (sibling is widget) {
            siblingLink = temp;
        }
        if (childData !is null && (sibling is null || siblingLink !is null)) break;
        temp = cast(GList*)OS.g_list_next (temp);
    }
    children = OS.g_list_remove_link (children, childLink);
    if (siblingLink is null || siblingLink.prev is null) {
        OS.g_list_free_1 (childLink);
        children = OS.g_list_prepend (children, childData);
    } else {
        temp = siblingLink.prev;
        childLink.prev =  temp;
        temp.next = childLink;
        childLink.next = siblingLink;
        siblingLink.prev = childLink;
    }
    fixed.children = children;
    parentHandle = cast(GtkWidget*)fixed;
}

alias Scrollable.moveBelow moveBelow;
void moveBelow (GtkWidget* child, GtkWidget* sibling) {
    if (child is sibling) return;
    auto parentHandle = parentingHandle ();
    if (sibling is null && cast(GtkWidget*)parentHandle is cast(GtkWidget*)fixedHandle) {
        moveAbove (child, scrolledHandle !is null  ? cast(GtkWidget*)scrolledHandle : handle);
        return;
    }
    auto fixed = cast(GtkFixed*)parentHandle;
    GList* children = fixed.children;
    if (children is null) return;
    void* data;
    GtkWidget* widget;
    void* childData;
    GList* childLink;
    GList* siblingLink;
    GList* temp = children;
    while (temp !is null) {
        data = temp.data;
        widget = *cast(GtkWidget**) temp.data;
        if (child is widget) {
            childLink = temp;
            childData = data;
        } else if (sibling is widget) {
            siblingLink = temp;
        }
        if (childData !is null && (sibling is null || siblingLink !is null)) break;
        temp = OS.g_list_next(temp);
    }
    children = OS.g_list_remove_link (children, childLink);
    if (siblingLink is null || OS.g_list_next(siblingLink) is null) {
        OS.g_list_free_1 (childLink);
        children = OS.g_list_append (children, childData);
    } else {
        temp = OS.g_list_next( siblingLink );
        OS.g_list_set_next (childLink, temp);
        OS.g_list_set_previous (temp, childLink);
        OS.g_list_set_previous (childLink, siblingLink);
        OS.g_list_set_next (siblingLink, childLink);
    }
    fixed.children = children;
    parentHandle = cast(GtkWidget*)fixed;
}

override
void moveChildren(int oldWidth) {
    Control[] children = _getChildren ();
    for (int i = 0; i < children.length; i++) {
        Control child = children[i];
        auto topHandle = child.topHandle ();
        int x = OS.GTK_WIDGET_X (topHandle);
        int y = OS.GTK_WIDGET_Y (topHandle);
        int controlWidth = (child.state & ZERO_WIDTH) !is 0 ? 0 : OS.GTK_WIDGET_WIDTH (topHandle);
        x = oldWidth - controlWidth - x;
        int clientWidth = getClientWidth ();
        x = clientWidth - controlWidth - x;
        if (child.enableWindow !is null) {
            OS.gdk_window_move (child.enableWindow, x, y);
        }
        child.moveHandle (x, y);
        /*
        * Cause a size allocation this widget's topHandle.  Note that
        * all calls to gtk_widget_size_allocate() must be preceded by
        * a call to gtk_widget_size_request().
        */
        GtkRequisition requisition;
        gtk_widget_size_request (topHandle, &requisition);
        GtkAllocation allocation;
        allocation.x = x;
        allocation.y = y;
        allocation.width = OS.GTK_WIDGET_WIDTH (topHandle);
        allocation.height = OS.GTK_WIDGET_HEIGHT (topHandle);
        OS.gtk_widget_size_allocate (topHandle, &allocation);
        Control control = child.findBackgroundControl ();
        if (control !is null && control.backgroundImage !is null) {
            if (child.isVisible ()) child.redrawWidget (0, 0, 0, 0, true, true, true);
        }
    }
}

Point minimumSize (int wHint, int hHint, bool changed) {
    Control [] children = _getChildren ();
    int width = 0, height = 0;
    for (int i=0; i<children.length; i++) {
        Rectangle rect = children [i].getBounds ();
        width = Math.max (width, rect.x + rect.width);
        height = Math.max (height, rect.y + rect.height);
    }
    return new Point (width, height);
}

GtkWidget* parentingHandle () {
    if ((state & CANVAS) !is 0) return handle;
    return fixedHandle !is null ? fixedHandle : handle;
}

override void printWidget (GC gc, GdkDrawable* drawable, int depth, int x, int y) {
    Region oldClip = new Region (gc.getDevice ());
    Region newClip = new Region (gc.getDevice ());
    gc.getClipping (oldClip);
    Rectangle rect = getBounds ();
    newClip.add (oldClip);
    newClip.intersect (x, y, rect.width, rect.height);
    gc.setClipping (newClip);
    super.printWidget (gc, drawable, depth, x, y);
    Rectangle clientRect = getClientArea ();
    Point pt = display.map (this, parent, clientRect.x, clientRect.y);
    clientRect.x = x + pt.x - rect.x;
    clientRect.y = y + pt.y - rect.y;
    newClip.intersect (clientRect);
    gc.setClipping (newClip);
    Control [] children = _getChildren ();
    for (ptrdiff_t i=cast(ptrdiff_t) (children.length)-1; i>=0; --i) {
        Control child = children [i];
        if (child.getVisible ()) {
            Point location = child.getLocation ();
            child.printWidget (gc, drawable, depth, x + location.x, y + location.y);
        }
    }
    gc.setClipping (oldClip);
    oldClip.dispose ();
    newClip.dispose ();
}

override void redrawChildren () {
    super.redrawChildren ();
    Control [] children = _getChildren ();
    for (int i = 0; i < children.length; i++) {
        Control child = children [i];
        if ((child.state & PARENT_BACKGROUND) !is 0) {
            child.redrawWidget (0, 0, 0, 0, true, false, true);
            child.redrawChildren ();
        }
    }
}

override void register () {
    super.register ();
    if (socketHandle !is null) display.addWidget (socketHandle, this);
}

override void releaseChildren (bool destroy) {
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        if (child !is null && !child.isDisposed ()) {
            child.release (false);
        }
    }
    super.releaseChildren (destroy);
}

override void releaseHandle () {
    super.releaseHandle ();
    socketHandle = null;
    embeddedHandle = 0;
}

override void releaseWidget () {
    super.releaseWidget ();
    if (imHandle_ !is null) OS.g_object_unref (imHandle_);
    imHandle_ = null;
    layout_ = null;
    tabList = null;
}

void removeControl (Control control) {
    fixTabList (control);
}

override void resizeHandle (int width, int height) {
    super.resizeHandle (width, height);
    if (socketHandle !is null) OS.gtk_widget_set_size_request (socketHandle, width, height);
}

/**
 * Sets the background drawing mode to the argument which should
 * be one of the following constants defined in class <code>SWT</code>:
 * <code>INHERIT_NONE</code>, <code>INHERIT_DEFAULT</code>,
 * <code>INHERIT_FORCE</code>.
 *
 * @param mode the new background mode
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SWT
 *
 * @since 3.2
 */
public void setBackgroundMode (int mode) {
    checkWidget ();
    backgroundMode = mode;
    Control[] children = _getChildren ();
    for (int i = 0; i < children.length; i++) {
        children [i].updateBackgroundMode ();
    }
}

override int setBounds (int x, int y, int width, int height, bool move, bool resize) {
    int result = super.setBounds (x, y, width, height, move, resize);
    if ((result & RESIZED) !is 0 && layout_ !is null) {
        markLayout (false, false);
        updateLayout (false);
    }
    return result;
}

override public bool setFocus () {
    checkWidget();
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        if (child.getVisible () && child.setFocus ()) return true;
    }
    return super.setFocus ();
}

/**
 * Sets the layout which is associated with the receiver to be
 * the argument which may be null.
 *
 * @param layout the receiver's new layout or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLayout (Layout layout) {
    checkWidget();
    this.layout_ = layout;
}

/**
 * If the argument is <code>true</code>, causes subsequent layout
 * operations in the receiver or any of its children to be ignored.
 * No layout of any kind can occur in the receiver or any of its
 * children until the flag is set to false.
 * Layout operations that occurred while the flag was
 * <code>true</code> are remembered and when the flag is set to
 * <code>false</code>, the layout operations are performed in an
 * optimized manner.  Nested calls to this method are stacked.
 *
 * @param defer the new defer state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #layout(bool)
 * @see #layout(Control[])
 *
 * @since 3.1
 */
public void setLayoutDeferred (bool defer) {
    if (!defer) {
        if (--layoutCount is 0) {
            if ((state & LAYOUT_CHILD) !is 0 || (state & LAYOUT_NEEDED) !is 0) {
                updateLayout (true);
            }
        }
    } else {
        layoutCount++;
    }
}

override bool setScrollBarVisible (ScrollBar bar, bool visible) {
    bool changed = super.setScrollBarVisible (bar, visible);
    if (changed && layout_ !is null) {
        markLayout (false, false);
        updateLayout (false);
    }
    return changed;
}

override bool setTabGroupFocus (bool next) {
    if (isTabItem ()) return setTabItemFocus (next);
    bool takeFocus = (style & SWT.NO_FOCUS) is 0;
    if ((state & CANVAS) !is 0) takeFocus = hooksKeys ();
    if (socketHandle !is null) takeFocus = true;
    if (takeFocus  && setTabItemFocus (next)) return true;
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        if (child.isTabItem () && child.setTabItemFocus (next)) return true;
    }
    return false;
}

override bool setTabItemFocus (bool next) {
    if (!super.setTabItemFocus (next)) return false;
    if (socketHandle !is null) {
        int direction = next ? OS.GTK_DIR_TAB_FORWARD : OS.GTK_DIR_TAB_BACKWARD;
        OS.GTK_WIDGET_UNSET_FLAGS (socketHandle, OS.GTK_HAS_FOCUS);
        OS.gtk_widget_child_focus (socketHandle, direction);
        OS.GTK_WIDGET_SET_FLAGS (socketHandle, OS.GTK_HAS_FOCUS);
    }
    return true;
}

/**
 * Sets the tabbing order for the specified controls to
 * match the order that they occur in the argument list.
 *
 * @param tabList the ordered list of controls representing the tab order or null
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if a widget in the tabList is null or has been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if widget in the tabList is not in the same widget tree</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setTabList (Control [] tabList) {
    checkWidget ();
    if (tabList !is null) {
        for (int i=0; i<tabList.length; i++) {
            Control control = tabList [i];
            if (control is null) error (SWT.ERROR_INVALID_ARGUMENT);
            if (control.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
            if (control.parent !is this) error (SWT.ERROR_INVALID_PARENT);
        }
        Control [] newList = new Control [tabList.length];
        System.arraycopy (tabList, 0, newList, 0, tabList.length);
        tabList = newList;
    }
    this.tabList = tabList;
}

override void showWidget () {
    super.showWidget ();
    if (socketHandle !is null) {
        OS.gtk_widget_show (socketHandle);
        embeddedHandle = OS.gtk_socket_get_id (cast(GtkSocket*)socketHandle);
    }
    if (scrolledHandle is null) fixStyle (handle);
}

override bool translateMnemonic (Event event, Control control) {
    if (super.translateMnemonic (event, control)) return true;
    if (control !is null) {
        Control [] children = _getChildren ();
        for (int i=0; i<children.length; i++) {
            Control child = children [i];
            if (child.translateMnemonic (event, control)) return true;
        }
    }
    return false;
}

override int traversalCode(int key, GdkEventKey* event) {
    if ((state & CANVAS) !is 0) {
        if ((style & SWT.NO_FOCUS) !is 0) return 0;
        if (hooksKeys ()) return 0;
    }
    return super.traversalCode (key, event);
}

override bool translateTraversal (GdkEventKey* keyEvent) {
    if (socketHandle !is null) return false;
    return super.translateTraversal (keyEvent);
}

override void updateBackgroundMode () {
    super.updateBackgroundMode ();
    Control [] children = _getChildren ();
    for (int i = 0; i < children.length; i++) {
        children [i].updateBackgroundMode ();
    }
}

override void updateLayout (bool all) {
    Composite parent = findDeferredControl ();
    if (parent !is null) {
        parent.state |= LAYOUT_CHILD;
        return;
    }
    if ((state & LAYOUT_NEEDED) !is 0) {
        bool changed = (state & LAYOUT_CHANGED) !is 0;
        state &= ~(LAYOUT_NEEDED | LAYOUT_CHANGED);
        layout_.layout (this, changed);
    }
    if (all) {
        state &= ~LAYOUT_CHILD;
        Control [] children = _getChildren ();
        for (int i=0; i<children.length; i++) {
            children [i].updateLayout (all);
        }
    }
}
}
