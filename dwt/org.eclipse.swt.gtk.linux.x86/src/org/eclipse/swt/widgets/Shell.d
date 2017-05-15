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
module org.eclipse.swt.widgets.Shell;

import java.lang.all;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
//import org.eclipse.swt.internal.c.gtk;

import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.events.ShellListener;
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Region;
import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.SWTEventListener;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Decorations;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.EventTable;
import org.eclipse.swt.widgets.Layout;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.Monitor;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Widget;

version(Tango){
import Unicode = tango.text.Unicode;
} else { // Phobos
}

/**
 * Instances of this class represent the "windows"
 * which the desktop or "window manager" is managing.
 * Instances that do not have a parent (that is, they
 * are built using the constructor, which takes a
 * <code>Display</code> as the argument) are described
 * as <em>top level</em> shells. Instances that do have
 * a parent are described as <em>secondary</em> or
 * <em>dialog</em> shells.
 * <p>
 * Instances are always displayed in one of the maximized,
 * minimized or normal states:
 * <ul>
 * <li>
 * When an instance is marked as <em>maximized</em>, the
 * window manager will typically resize it to fill the
 * entire visible area of the display, and the instance
 * is usually put in a state where it can not be resized
 * (even if it has style <code>RESIZE</code>) until it is
 * no longer maximized.
 * </li><li>
 * When an instance is in the <em>normal</em> state (neither
 * maximized or minimized), its appearance is controlled by
 * the style constants which were specified when it was created
 * and the restrictions of the window manager (see below).
 * </li><li>
 * When an instance has been marked as <em>minimized</em>,
 * its contents (client area) will usually not be visible,
 * and depending on the window manager, it may be
 * "iconified" (that is, replaced on the desktop by a small
 * simplified representation of itself), relocated to a
 * distinguished area of the screen, or hidden. Combinations
 * of these changes are also possible.
 * </li>
 * </ul>
 * </p><p>
 * The <em>modality</em> of an instance may be specified using
 * style bits. The modality style bits are used to determine
 * whether input is blocked for other shells on the display.
 * The <code>PRIMARY_MODAL</code> style allows an instance to block
 * input to its parent. The <code>APPLICATION_MODAL</code> style
 * allows an instance to block input to every other shell in the
 * display. The <code>SYSTEM_MODAL</code> style allows an instance
 * to block input to all shells, including shells belonging to
 * different applications.
 * </p><p>
 * Note: The styles supported by this class are treated
 * as <em>HINT</em>s, since the window manager for the
 * desktop on which the instance is visible has ultimate
 * control over the appearance and behavior of decorations
 * and modality. For example, some window managers only
 * support resizable windows and will always assume the
 * RESIZE style, even if it is not set. In addition, if a
 * modality style is not supported, it is "upgraded" to a
 * more restrictive modality style that is supported. For
 * example, if <code>PRIMARY_MODAL</code> is not supported,
 * it would be upgraded to <code>APPLICATION_MODAL</code>.
 * A modality style may also be "downgraded" to a less
 * restrictive style. For example, most operating systems
 * no longer support <code>SYSTEM_MODAL</code> because
 * it can freeze up the desktop, so this is typically
 * downgraded to <code>APPLICATION_MODAL</code>.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>BORDER, CLOSE, MIN, MAX, NO_TRIM, RESIZE, TITLE, ON_TOP, TOOL</dd>
 * <dd>APPLICATION_MODAL, MODELESS, PRIMARY_MODAL, SYSTEM_MODAL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Activate, Close, Deactivate, Deiconify, Iconify</dd>
 * </dl>
 * Class <code>SWT</code> provides two "convenience constants"
 * for the most commonly required style combinations:
 * <dl>
 * <dt><code>SHELL_TRIM</code></dt>
 * <dd>
 * the result of combining the constants which are required
 * to produce a typical application top level shell: (that
 * is, <code>CLOSE | TITLE | MIN | MAX | RESIZE</code>)
 * </dd>
 * <dt><code>DIALOG_TRIM</code></dt>
 * <dd>
 * the result of combining the constants which are required
 * to produce a typical application dialog shell: (that
 * is, <code>TITLE | CLOSE | BORDER</code>)
 * </dd>
 * </dl>
 * </p>
 * <p>
 * Note: Only one of the styles APPLICATION_MODAL, MODELESS,
 * PRIMARY_MODAL and SYSTEM_MODAL may be specified.
 * </p><p>
 * IMPORTANT: This class is not intended to be subclassed.
 * </p>
 *
 * @see Decorations
 * @see SWT
 * @see <a href="http://www.eclipse.org/swt/snippets/#shell">Shell snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Shell : Decorations {

    alias Decorations.createHandle createHandle;
    alias Decorations.fixStyle fixStyle;
    alias Decorations.setBounds setBounds;
    alias Decorations.setCursor setCursor;
    alias Decorations.setToolTipText setToolTipText;
    alias Decorations.setZOrder setZOrder;

    GtkWidget* shellHandle, tooltipsHandle, tooltipWindow, group, modalGroup;
    bool mapped, moved, resized, opened, fullScreen, showWithParent;

    int oldX, oldY, oldWidth, oldHeight;
    int minWidth, minHeight;
    Control lastActive;
    CallbackData filterProcCallbackData;
    CallbackData sizeAllocateProcCallbackData;
    CallbackData sizeRequestProcCallbackData;

    static const int MAXIMUM_TRIM = 128;

/**
 * Constructs a new instance of this class. This is equivalent
 * to calling <code>Shell((Display) null)</code>.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
public this () {
    this (cast(Display) null);
}
/**
 * Constructs a new instance of this class given only the style
 * value describing its behavior and appearance. This is equivalent
 * to calling <code>Shell((Display) null, style)</code>.
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
 * @param style the style of control to construct
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#BORDER
 * @see SWT#CLOSE
 * @see SWT#MIN
 * @see SWT#MAX
 * @see SWT#RESIZE
 * @see SWT#TITLE
 * @see SWT#NO_TRIM
 * @see SWT#SHELL_TRIM
 * @see SWT#DIALOG_TRIM
 * @see SWT#MODELESS
 * @see SWT#PRIMARY_MODAL
 * @see SWT#APPLICATION_MODAL
 * @see SWT#SYSTEM_MODAL
 */
public this (int style) {
    this (cast(Display) null, style);
}

/**
 * Constructs a new instance of this class given only the display
 * to create it on. It is created with style <code>SWT.SHELL_TRIM</code>.
 * <p>
 * Note: Currently, null can be passed in for the display argument.
 * This has the effect of creating the shell on the currently active
 * display if there is one. If there is no current display, the
 * shell is created on a "default" display. <b>Passing in null as
 * the display argument is not considered to be good coding style,
 * and may not be supported in a future release of SWT.</b>
 * </p>
 *
 * @param display the display to create the shell on
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
public this (Display display) {
    this (display, SWT.SHELL_TRIM);
}
/**
 * Constructs a new instance of this class given the display
 * to create it on and a style value describing its behavior
 * and appearance.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>SWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>SWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 * </p><p>
 * Note: Currently, null can be passed in for the display argument.
 * This has the effect of creating the shell on the currently active
 * display if there is one. If there is no current display, the
 * shell is created on a "default" display. <b>Passing in null as
 * the display argument is not considered to be good coding style,
 * and may not be supported in a future release of SWT.</b>
 * </p>
 *
 * @param display the display to create the shell on
 * @param style the style of control to construct
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#BORDER
 * @see SWT#CLOSE
 * @see SWT#MIN
 * @see SWT#MAX
 * @see SWT#RESIZE
 * @see SWT#TITLE
 * @see SWT#NO_TRIM
 * @see SWT#SHELL_TRIM
 * @see SWT#DIALOG_TRIM
 * @see SWT#MODELESS
 * @see SWT#PRIMARY_MODAL
 * @see SWT#APPLICATION_MODAL
 * @see SWT#SYSTEM_MODAL
 */
public this (Display display, int style) {
    this (display, null, style, null, false);
}

this (Display display, Shell parent, int style, GtkWidget* handle, bool embedded) {
    super ();
    checkSubclass ();
    if (display is null) display = Display.getCurrent ();
    if (display is null) display = Display.getDefault ();
    if (!display.isValidThread ()) {
        error (SWT.ERROR_THREAD_INVALID_ACCESS);
    }
    if (parent !is null && parent.isDisposed ()) {
        error (SWT.ERROR_INVALID_ARGUMENT);
    }
    this.style = checkStyle (style);
    this.parent = parent;
    this.display = display;
    if (handle !is null) {
        if (embedded) {
            this.handle = handle;
        } else {
            shellHandle = handle;
            state |= FOREIGN_HANDLE;
        }
    }
    createWidget (0);
}

/**
 * Constructs a new instance of this class given only its
 * parent. It is created with style <code>SWT.DIALOG_TRIM</code>.
 * <p>
 * Note: Currently, null can be passed in for the parent.
 * This has the effect of creating the shell on the currently active
 * display if there is one. If there is no current display, the
 * shell is created on a "default" display. <b>Passing in null as
 * the parent is not considered to be good coding style,
 * and may not be supported in a future release of SWT.</b>
 * </p>
 *
 * @param parent a shell which will be the parent of the new instance
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the parent is disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
public this (Shell parent) {
    this (parent, SWT.DIALOG_TRIM);
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
 * </p><p>
 * Note: Currently, null can be passed in for the parent.
 * This has the effect of creating the shell on the currently active
 * display if there is one. If there is no current display, the
 * shell is created on a "default" display. <b>Passing in null as
 * the parent is not considered to be good coding style,
 * and may not be supported in a future release of SWT.</b>
 * </p>
 *
 * @param parent a shell which will be the parent of the new instance
 * @param style the style of control to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the parent is disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#BORDER
 * @see SWT#CLOSE
 * @see SWT#MIN
 * @see SWT#MAX
 * @see SWT#RESIZE
 * @see SWT#TITLE
 * @see SWT#NO_TRIM
 * @see SWT#SHELL_TRIM
 * @see SWT#DIALOG_TRIM
 * @see SWT#ON_TOP
 * @see SWT#TOOL
 * @see SWT#MODELESS
 * @see SWT#PRIMARY_MODAL
 * @see SWT#APPLICATION_MODAL
 * @see SWT#SYSTEM_MODAL
 */
public this (Shell parent, int style) {
    this (parent !is null ? parent.display : null, parent, style, null, false);
}

public static Shell gtk_new (Display display, GtkWidget* handle) {
    return new Shell (display, null, SWT.NO_TRIM, handle, true);
}

/**  
 * Invokes platform specific functionality to allocate a new shell
 * that is not embedded.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Shell</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param display the display for the shell
 * @param handle the handle for the shell
 * @return a new shell object containing the specified display and handle
 * 
 * @since 3.3
 */
public static Shell internal_new (Display display, GtkWidget* handle) {
    return new Shell (display, null, SWT.NO_TRIM, handle, false);
}

static int checkStyle (int style) {
    style = Decorations.checkStyle (style);
    style &= ~SWT.TRANSPARENT;
    if ((style & SWT.ON_TOP) !is 0) style &= ~SWT.SHELL_TRIM;
    int mask = SWT.SYSTEM_MODAL | SWT.APPLICATION_MODAL | SWT.PRIMARY_MODAL;
    int bits = style & ~mask;
    if ((style & SWT.SYSTEM_MODAL) !is 0) return bits | SWT.SYSTEM_MODAL;
    if ((style & SWT.APPLICATION_MODAL) !is 0) return bits | SWT.APPLICATION_MODAL;
    if ((style & SWT.PRIMARY_MODAL) !is 0) return bits | SWT.PRIMARY_MODAL;
    return bits;
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when operations are performed on the receiver,
 * by sending the listener one of the messages defined in the
 * <code>ShellListener</code> interface.
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
 * @see ShellListener
 * @see #removeShellListener
 */
public void addShellListener (ShellListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Close,typedListener);
    addListener (SWT.Iconify,typedListener);
    addListener (SWT.Deiconify,typedListener);
    addListener (SWT.Activate, typedListener);
    addListener (SWT.Deactivate, typedListener);
}

void adjustTrim () {
    if (display.ignoreTrim) return;
    int width = OS.GTK_WIDGET_WIDTH (shellHandle);
    int height = OS.GTK_WIDGET_HEIGHT (shellHandle);
    auto window = OS.GTK_WIDGET_WINDOW (shellHandle);
    GdkRectangle* rect = new GdkRectangle ();
    OS.gdk_window_get_frame_extents (window, rect);
    int trimWidth = Math.max (0, rect.width - width);
    int trimHeight = Math.max (0, rect.height - height);
    /*
    * Bug in GTK.  gdk_window_get_frame_extents() fails for various window
    * managers, causing a large incorrect value to be returned as the trim.
    * The fix is to ignore the returned trim values if they are too large.
    */
    if (trimWidth > MAXIMUM_TRIM || trimHeight > MAXIMUM_TRIM) {
        display.ignoreTrim = true;
        return;
    }
    bool hasTitle = false, hasResize = false, hasBorder = false;
    if ((style & SWT.NO_TRIM) is 0) {
        hasTitle = (style & (SWT.MIN | SWT.MAX | SWT.TITLE | SWT.MENU)) !is 0;
        hasResize = (style & SWT.RESIZE) !is 0;
        hasBorder = (style & SWT.BORDER) !is 0;
    }
    if (hasTitle) {
        if (hasResize)  {
            display.titleResizeTrimWidth = trimWidth;
            display.titleResizeTrimHeight = trimHeight;
            return;
        }
        if (hasBorder) {
            display.titleBorderTrimWidth = trimWidth;
            display.titleBorderTrimHeight = trimHeight;
            return;
        }
        display.titleTrimWidth = trimWidth;
        display.titleTrimHeight = trimHeight;
        return;
    }
    if (hasResize) {
        display.resizeTrimWidth = trimWidth;
        display.resizeTrimHeight = trimHeight;
        return;
    }
    if (hasBorder) {
        display.borderTrimWidth = trimWidth;
        display.borderTrimHeight = trimHeight;
        return;
    }
}

void bringToTop (bool force) {
    if (!OS.GTK_WIDGET_VISIBLE (shellHandle)) return;
    Display display = this.display;
    Shell activeShell = display.activeShell;
    if (activeShell is this) return;
    if (!force) {
        if (activeShell is null) return;
        if (!display.activePending) {
            auto focusHandle = OS.gtk_window_get_focus (cast(GtkWindow*)activeShell.shellHandle);
            if (focusHandle !is null && !OS.GTK_WIDGET_HAS_FOCUS (focusHandle)) return;
        }
    }
    /*
    * Bug in GTK.  When a shell that is not managed by the window
    * manage is given focus, GTK gets stuck in "focus follows pointer"
    * mode when the pointer is within the shell and its parent when
    * the shell is hidden or disposed. The fix is to use XSetInputFocus()
    * to assign focus when ever the active shell has not managed by
    * the window manager.
    *
    * NOTE: This bug is fixed in GTK+ 2.6.8 and above.
    */
    bool xFocus = false;
    if (activeShell !is null) {
        if (OS.GTK_VERSION < OS.buildVERSION (2, 6, 8)) {
            xFocus = activeShell.isUndecorated ();
        }
        display.activeShell = null;
        display.activePending = true;
    }
    /*
    * Feature in GTK.  When the shell is an override redirect
    * window, gdk_window_focus() does not give focus to the
    * window.  The fix is to use XSetInputFocus() to force
    * the focus.
    */
    auto window = OS.GTK_WIDGET_WINDOW (shellHandle);
    if ((xFocus || (style & SWT.ON_TOP) !is 0) && OS.GDK_WINDOWING_X11 ()) {
        auto xDisplay = OS.gdk_x11_drawable_get_xdisplay (window);
        auto xWindow = OS.gdk_x11_drawable_get_xid (window);
        OS.gdk_error_trap_push ();
        /* Use CurrentTime instead of the last event time to ensure that the shell becomes active */
        OS.XSetInputFocus (xDisplay, xWindow, OS.RevertToParent, OS.CurrentTime);
        OS.gdk_error_trap_pop ();
    } else {
        /*
        * Bug in metacity.  Calling gdk_window_focus() with a timestamp more
        * recent than the last user interaction time can cause windows not
        * to come forward in versions > 2.10.0.  The fix is to use the last
        * user event time.
        */
        if ( display.windowManager.toLowerCase() ==/*eq*/ "metacity") {
            OS.gdk_window_focus (window, display.lastUserEventTime);
        } else {
            OS.gdk_window_focus (window, OS.GDK_CURRENT_TIME);
        }
    }
    display.activeShell = this;
    display.activePending = true;
}

override void checkBorder () {
    /* Do nothing */
}

override void checkOpen () {
    if (!opened) resized = false;
}

override GtkStyle* childStyle () {
    return null;
}

/**
 * Requests that the window manager close the receiver in
 * the same way it would be closed when the user clicks on
 * the "close box" or performs some other platform specific
 * key or mouse combination that indicates the window
 * should be removed.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SWT#Close
 * @see #dispose
 */
public void close () {
    checkWidget ();
    closeWidget ();
}

void closeWidget () {
    Event event = new Event ();
    sendEvent (SWT.Close, event);
    if (event.doit && !isDisposed ()) dispose ();
}

override public Rectangle computeTrim (int x, int y, int width, int height) {
    checkWidget();
    Rectangle trim = super.computeTrim (x, y, width, height);
    int border = 0;
    if ((style & (SWT.NO_TRIM | SWT.BORDER | SWT.SHELL_TRIM)) is 0) {
        border = OS.gtk_container_get_border_width (cast(GtkContainer*)shellHandle);
    }
    int trimWidth = trimWidth (), trimHeight = trimHeight ();
    trim.x -= (trimWidth / 2) + border;
    trim.y -= trimHeight - (trimWidth / 2) + border;
    trim.width += trimWidth + border * 2;
    trim.height += trimHeight + border * 2;
    if (menuBar !is null) {
        forceResize ();
        int menuBarHeight = OS.GTK_WIDGET_HEIGHT (menuBar.handle);
        trim.y -= menuBarHeight;
        trim.height += menuBarHeight;
    }
    return trim;
}

override void createHandle (int index) {
    state |= HANDLE | CANVAS;
    if (shellHandle is null) {
        if (handle is null) {
            int type = OS.GTK_WINDOW_TOPLEVEL;
            if ((style & SWT.ON_TOP) !is 0) type = OS.GTK_WINDOW_POPUP;
            shellHandle = cast(GtkWidget*)OS.gtk_window_new (type);
        } else {
            shellHandle = cast(GtkWidget*) OS.gtk_plug_new (handle);
        }
        if (shellHandle is null) error (SWT.ERROR_NO_HANDLES);
        if (parent !is null) {
            OS.gtk_window_set_transient_for (cast(GtkWindow*)shellHandle, cast(GtkWindow*)parent.topHandle ());
            OS.gtk_window_set_destroy_with_parent (cast(GtkWindow*)shellHandle, true);
            if (!isUndecorated ()) {
                OS.gtk_window_set_type_hint (cast(GtkWindow*)shellHandle, OS.GDK_WINDOW_TYPE_HINT_DIALOG);
            } else {
                if (OS.GTK_VERSION >= OS.buildVERSION (2, 2, 0)) {
                    OS.gtk_window_set_skip_taskbar_hint (cast(GtkWindow*)shellHandle, true);
                }
            }
        }
        /*
        * Feature in GTK.  The window size must be set when the window
        * is created or it will not be allowed to be resized smaller that the
        * initial size by the user.  The fix is to set the size to zero.
        */
        if ((style & SWT.RESIZE) !is 0) {
            OS.gtk_widget_set_size_request (shellHandle, 0, 0);
            OS.gtk_window_set_resizable (cast(GtkWindow*)shellHandle, true);
        } else {
            OS.gtk_window_set_resizable (cast(GtkWindow*)shellHandle, false);
        }
        vboxHandle = OS.gtk_vbox_new (false, 0);
        if (vboxHandle is null) error (SWT.ERROR_NO_HANDLES);
        createHandle (index, false, true);
        OS.gtk_container_add (cast(GtkContainer*)vboxHandle, scrolledHandle);
        OS.gtk_box_set_child_packing (cast(GtkBox*)vboxHandle, scrolledHandle, true, true, 0, OS.GTK_PACK_END);
        String dummy = "a";
        OS.gtk_window_set_title (cast(GtkWindow*)shellHandle, dummy.ptr );
        if ((style & (SWT.NO_TRIM | SWT.BORDER | SWT.SHELL_TRIM)) is 0) {
            OS.gtk_container_set_border_width (cast(GtkContainer*)shellHandle, 1);
            GdkColor* color = new GdkColor ();
            OS.gtk_style_get_black (OS.gtk_widget_get_style (shellHandle), color);
            OS.gtk_widget_modify_bg (shellHandle,  OS.GTK_STATE_NORMAL, color);
        }
    } else {
        vboxHandle = OS.gtk_bin_get_child (cast(GtkBin*)shellHandle);
        if (vboxHandle is null) error (SWT.ERROR_NO_HANDLES);
        auto children = OS.gtk_container_get_children (cast(GtkContainer*)vboxHandle);
        if (OS.g_list_length (children) > 0) {
            scrolledHandle = cast(GtkWidget*)OS.g_list_data (children);
        }
        OS.g_list_free (children);
        if (scrolledHandle is null) error (SWT.ERROR_NO_HANDLES);
        handle = OS.gtk_bin_get_child (cast(GtkBin*)scrolledHandle);
        if (handle is null) error (SWT.ERROR_NO_HANDLES);
    }
    group = cast(GtkWidget*) OS.gtk_window_group_new ();
    if (group is null) error (SWT.ERROR_NO_HANDLES);
    /*
    * Feature in GTK.  Realizing the shell triggers a size allocate event,
    * which may be confused for a resize event from the window manager if
    * received too late.  The fix is to realize the window during creation
    * to avoid confusion.
    */
    OS.gtk_widget_realize (shellHandle);
}

override int filterProc ( XEvent* xEvent, GdkEvent* gdkEvent, void* data2) {
    int eventType = OS.X_EVENT_TYPE (xEvent);
    if (eventType !is OS.FocusOut && eventType !is OS.FocusIn) return 0;
    XFocusChangeEvent* xFocusEvent = cast(XFocusChangeEvent*)xEvent;
    switch (eventType) {
        case OS.FocusIn:
            if (xFocusEvent.mode is OS.NotifyNormal || xFocusEvent.mode is OS.NotifyWhileGrabbed) {
                switch (xFocusEvent.detail) {
                    case OS.NotifyNonlinear:
                    case OS.NotifyNonlinearVirtual:
                    case OS.NotifyAncestor:
                        if (tooltipsHandle !is null) OS.gtk_tooltips_enable (cast(GtkTooltips*)tooltipsHandle);
                        display.activeShell = this;
                        display.activePending = false;
                        sendEvent (SWT.Activate);
                        break;
                    default:
                }
            }
            break;
        case OS.FocusOut:
            if (xFocusEvent.mode is OS.NotifyNormal || xFocusEvent.mode is OS.NotifyWhileGrabbed) {
                switch (xFocusEvent.detail) {
                    case OS.NotifyNonlinear:
                    case OS.NotifyNonlinearVirtual:
                    case OS.NotifyVirtual:
                        if (tooltipsHandle !is null) OS.gtk_tooltips_disable (cast(GtkTooltips*)tooltipsHandle);
                        Display display = this.display;
                        sendEvent (SWT.Deactivate);
                        setActiveControl (null);
                        if (display.activeShell is this) {
                            display.activeShell = null;
                            display.activePending = false;
                        }
                        break;
                    default:
                }
            }
            break;
        default:
    }
    return 0;
}

override Control findBackgroundControl () {
    return (state & BACKGROUND) !is 0 || backgroundImage !is null ? this : null;
}

override Composite findDeferredControl () {
    return layoutCount > 0 ? this : null;
}

override bool hasBorder () {
    return false;
}

override void hookEvents () {
    super.hookEvents ();
    OS.g_signal_connect_closure_by_id (shellHandle, display.signalIds [KEY_PRESS_EVENT], 0, display.closures [KEY_PRESS_EVENT], false);
    OS.g_signal_connect_closure_by_id (shellHandle, display.signalIds [WINDOW_STATE_EVENT], 0, display.closures [WINDOW_STATE_EVENT], false);
    OS.g_signal_connect_closure_by_id (shellHandle, display.signalIds [SIZE_ALLOCATE], 0, display.closures [SIZE_ALLOCATE], false);
    OS.g_signal_connect_closure_by_id (shellHandle, display.signalIds [CONFIGURE_EVENT], 0, display.closures [CONFIGURE_EVENT], false);
    OS.g_signal_connect_closure_by_id (shellHandle, display.signalIds [DELETE_EVENT], 0, display.closures [DELETE_EVENT], false);
    OS.g_signal_connect_closure_by_id (shellHandle, display.signalIds [MAP_EVENT], 0, display.shellMapProcClosure, false);
    OS.g_signal_connect_closure_by_id (shellHandle, display.signalIds [ENTER_NOTIFY_EVENT], 0, display.closures [ENTER_NOTIFY_EVENT], false);
    OS.g_signal_connect_closure (shellHandle, OS.move_focus.ptr, display.closures [MOVE_FOCUS], false);
    auto window = OS.GTK_WIDGET_WINDOW (shellHandle);
    display.doWindowAddFilter( &filterProcCallbackData, window, shellHandle );
    //OS.gdk_window_add_filter  (window, display.filterProc, shellHandle);
}

override public bool isEnabled () {
    checkWidget ();
    return getEnabled ();
}

bool isUndecorated () {
    return
        (style & (SWT.SHELL_TRIM | SWT.BORDER)) is SWT.NONE ||
        (style & (SWT.NO_TRIM | SWT.ON_TOP)) !is 0;
}

override public bool isVisible () {
    checkWidget();
    return getVisible ();
}

override void register () {
    super.register ();
    display.addWidget (shellHandle, this);
}

override void releaseParent () {
    /* Do nothing */
}

override GtkWidget* topHandle () {
    return shellHandle;
}

void fixActiveShell () {
    if (display.activeShell is this) {
        Shell shell = null;
        if (parent !is null && parent.isVisible ()) shell = parent.getShell ();
        if (shell is null && isUndecorated ()) {
            Shell [] shells = display.getShells ();
            for (int i = 0; i < shells.length; i++) {
                if (shells [i] !is null && shells [i].isVisible ()) {
                    shell = shells [i];
                    break;
                }
            }
        }
        if (shell !is null) shell.bringToTop (false);
    }
}

void fixShell (Shell newShell, Control control) {
    if (this is newShell) return;
    if (control is lastActive) setActiveControl (null);
    String toolTipText = control.toolTipText;
    if (toolTipText !is null) {
        control.setToolTipText (this, null);
        control.setToolTipText (newShell, toolTipText);
    }
}

override void fixedSizeAllocateProc(GtkWidget* widget, GtkAllocation* allocationPtr) {
    int clientWidth = 0;
    if ((style & SWT.MIRRORED) !is 0) clientWidth = getClientWidth ();
    super.fixedSizeAllocateProc (widget, allocationPtr);
    if ((style & SWT.MIRRORED) !is 0) moveChildren (clientWidth);
}

override void fixStyle (GtkWidget* handle) {
}

override void forceResize () {
    forceResize (OS.GTK_WIDGET_WIDTH (vboxHandle), OS.GTK_WIDGET_HEIGHT (vboxHandle));
}

void forceResize (int width, int height) {
    GtkRequisition requisition;
    OS.gtk_widget_size_request (vboxHandle, &requisition);
    GtkAllocation allocation;
    int border = OS.gtk_container_get_border_width (cast(GtkContainer*)shellHandle);
    allocation.x = border;
    allocation.y = border;
    allocation.width = width;
    allocation.height = height;
    OS.gtk_widget_size_allocate (cast(GtkWidget*)vboxHandle, &allocation);
}

/**
 * Returns the receiver's alpha value. The alpha value
 * is between 0 (transparent) and 255 (opaque).
 *
 * @return the alpha value
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.4
 */
public int getAlpha () {
    checkWidget ();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 12, 0)) {
        if (OS.gtk_widget_is_composited (shellHandle)) {
            return cast(int) (OS.gtk_window_get_opacity (shellHandle) * 255);
        }
    }
    return 255;
}

/**
 * Returns <code>true</code> if the receiver is currently
 * in fullscreen state, and false otherwise. 
 * <p>
 *
 * @return the fullscreen state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public bool getFullScreen () {
    checkWidget();
    return fullScreen;
}

override public Point getLocation () {
    checkWidget ();
    int x, y;
    OS.gtk_window_get_position (cast(GtkWindow*)shellHandle, &x,&y);
    return new Point (x, y);
}

override
public bool getMaximized () {
    checkWidget();
    return !fullScreen && super.getMaximized ();
}

/**
 * Returns a point describing the minimum receiver's size. The
 * x coordinate of the result is the minimum width of the receiver.
 * The y coordinate of the result is the minimum height of the
 * receiver.
 *
 * @return the receiver's size
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public Point getMinimumSize () {
    checkWidget ();
    int width = Math.max (1, minWidth + trimWidth ());
    int height = Math.max (1, minHeight + trimHeight ());
    return new Point (width, height);
}

Shell getModalShell () {
    Shell shell = null;
    Shell [] modalShells = display.modalShells;
    if (modalShells !is null) {
        int bits = SWT.APPLICATION_MODAL | SWT.SYSTEM_MODAL;
        ptrdiff_t index = modalShells.length;
        while (--index >= 0) {
            Shell modal = modalShells [index];
            if (modal !is null) {
                if ((modal.style & bits) !is 0) {
                    Control control = this;
                    while (control !is null) {
                        if (control is modal) break;
                        control = control.parent;
                    }
                    if (control !is modal) return modal;
                    break;
                }
                if ((modal.style & SWT.PRIMARY_MODAL) !is 0) {
                    if (shell is null) shell = getShell ();
                    if (modal.parent is shell) return modal;
                }
            }
        }
    }
    return null;
}

override public Point getSize () {
    checkWidget ();
    int width = OS.GTK_WIDGET_WIDTH (vboxHandle);
    int height = OS.GTK_WIDGET_HEIGHT (vboxHandle);
    int border = 0;
    if ((style & (SWT.NO_TRIM | SWT.BORDER | SWT.SHELL_TRIM)) is 0) {
        border = OS.gtk_container_get_border_width (cast(GtkContainer*)shellHandle);
    }
    return new Point (width + trimWidth () + 2*border, height + trimHeight () + 2*border);
}

override public bool getVisible () {
    checkWidget();
    return OS.GTK_WIDGET_VISIBLE (shellHandle);
}

/**
 * Returns the region that defines the shape of the shell,
 * or null if the shell has the default shape.
 *
 * @return the region that defines the shape of the shell (or null)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 *
 */
override
public Region getRegion () {
    /* This method is needed for @since 3.0 Javadoc */
    checkWidget ();
    return region;
}

/**
 * Returns the receiver's input method editor mode. This
 * will be the result of bitwise OR'ing together one or
 * more of the following constants defined in class
 * <code>SWT</code>:
 * <code>NONE</code>, <code>ROMAN</code>, <code>DBCS</code>,
 * <code>PHONETIC</code>, <code>NATIVE</code>, <code>ALPHA</code>.
 *
 * @return the IME mode
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SWT
 */
public int getImeInputMode () {
    checkWidget();
    return SWT.NONE;
}

override Shell _getShell () {
    return this;
}
/**
 * Returns an array containing all shells which are
 * descendants of the receiver.
 * <p>
 * @return the dialog shells
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Shell [] getShells () {
    checkWidget();
    int count = 0;
    Shell [] shells = display.getShells ();
    for (int i=0; i<shells.length; i++) {
        Control shell = shells [i];
        do {
            shell = shell.getParent ();
        } while (shell !is null && shell !is this);
        if (shell is this) count++;
    }
    int index = 0;
    Shell [] result = new Shell [count];
    for (int i=0; i<shells.length; i++) {
        Control shell = shells [i];
        do {
            shell = shell.getParent ();
        } while (shell !is null && shell !is this);
        if (shell is this) {
            result [index++] = shells [i];
        }
    }
    return result;
}

override int gtk_configure_event (GtkWidget* widget, ptrdiff_t event) {
    int x, y;
    OS.gtk_window_get_position (cast(GtkWindow*)shellHandle, &x, &y);
    if (!moved || oldX !is x || oldY !is y) {
        moved = true;
        oldX = x;
        oldY = y;
        sendEvent (SWT.Move);
        // widget could be disposed at this point
    }
    return 0;
}

override int gtk_delete_event (GtkWidget* widget, ptrdiff_t event) {
    if (isEnabled()) closeWidget ();
    return 1;
}

override int gtk_enter_notify_event (GtkWidget* widget, GdkEventCrossing* event) {
    if (widget !is shellHandle) {
        return super.gtk_enter_notify_event (widget, event);
    }
    return 0;
}

override int gtk_focus (GtkWidget* widget, ptrdiff_t directionType) {
    switch (directionType) {
        case OS.GTK_DIR_TAB_FORWARD:
        case OS.GTK_DIR_TAB_BACKWARD:
            Control control = display.getFocusControl ();
            if (control !is null) {
                if ((control.state & CANVAS) !is 0 && (control.style & SWT.EMBEDDED) !is 0) {
                    int traversal = directionType is OS.GTK_DIR_TAB_FORWARD ? SWT.TRAVERSE_TAB_NEXT : SWT.TRAVERSE_TAB_PREVIOUS;
                    control.traverse (traversal);
                    return 1;
                }
            }
            break;
        default:
    }
    return super.gtk_focus (widget, directionType);
}

override int gtk_move_focus (GtkWidget* widget, ptrdiff_t directionType) {
    Control control = display.getFocusControl ();
    if (control !is null) {
        auto focusHandle = control.focusHandle ();
        OS.gtk_widget_child_focus (focusHandle, cast(int)/*64bit*/directionType);
    }
    OS.g_signal_stop_emission_by_name (shellHandle, OS.move_focus.ptr );
    return 1;
}

override int gtk_key_press_event (GtkWidget* widget, GdkEventKey* event) {
    /* Stop menu mnemonics when the shell is disabled */
    if (widget is shellHandle) {
        return (state & DISABLED) !is 0 ? 1 : 0;
    }
    return super.gtk_key_press_event (widget, event);
}

override int gtk_size_allocate (GtkWidget* widget, ptrdiff_t allocation) {
    int width = OS.GTK_WIDGET_WIDTH (shellHandle);
    int height = OS.GTK_WIDGET_HEIGHT (shellHandle);
    if (!resized || oldWidth !is width || oldHeight !is height) {
        oldWidth = width;
        oldHeight = height;
        resizeBounds (width, height, true);
    }
    return 0;
}

override int gtk_realize (GtkWidget* widget) {
    auto result = super.gtk_realize (widget);
    auto window = OS.GTK_WIDGET_WINDOW (shellHandle);
    if ((style & SWT.SHELL_TRIM) !is SWT.SHELL_TRIM) {
        int decorations = 0;
        if ((style & SWT.NO_TRIM) is 0) {
            if ((style & SWT.MIN) !is 0) decorations |= OS.GDK_DECOR_MINIMIZE;
            if ((style & SWT.MAX) !is 0) decorations |= OS.GDK_DECOR_MAXIMIZE;
            if ((style & SWT.RESIZE) !is 0) decorations |= OS.GDK_DECOR_RESIZEH;
            if ((style & SWT.BORDER) !is 0) decorations |= OS.GDK_DECOR_BORDER;
            if ((style & SWT.MENU) !is 0) decorations |= OS.GDK_DECOR_MENU;
            if ((style & SWT.TITLE) !is 0) decorations |= OS.GDK_DECOR_TITLE;
            /*
            * Feature in GTK.  Under some Window Managers (Sawmill), in order
            * to get any border at all from the window manager it is necessary to
            * set GDK_DECOR_BORDER.  The fix is to force these bits when any
            * kind of border is requested.
            */
            if ((style & SWT.RESIZE) !is 0) decorations |= OS.GDK_DECOR_BORDER;
        }
        OS.gdk_window_set_decorations (window, decorations);
    }
    if ((style & SWT.ON_TOP) !is 0) {
        OS.gdk_window_set_override_redirect (window, true);
    }
    return result;
}

override int gtk_window_state_event (GtkWidget* widget, GdkEventWindowState* event) {
    minimized = (event.new_window_state & OS.GDK_WINDOW_STATE_ICONIFIED) !is 0;
    maximized = (event.new_window_state & OS.GDK_WINDOW_STATE_MAXIMIZED) !is 0;
    fullScreen = (event.new_window_state & OS.GDK_WINDOW_STATE_FULLSCREEN) !is 0;
    if ((event.changed_mask & OS.GDK_WINDOW_STATE_ICONIFIED) !is 0) {
        if (minimized) {
            sendEvent (SWT.Iconify);
        } else {
            sendEvent (SWT.Deiconify);
        }
        updateMinimized (minimized);
    }
    return 0;
}

/**
 * Moves the receiver to the top of the drawing order for
 * the display on which it was created (so that all other
 * shells on that display, which are not the receiver's
 * children will be drawn behind it), marks it visible,
 * sets the focus and asks the window manager to make the
 * shell active.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Control#moveAbove
 * @see Control#setFocus
 * @see Control#setVisible
 * @see Display#getActiveShell
 * @see Decorations#setDefaultButton(Button)
 * @see Shell#setActive
 * @see Shell#forceActive
 */
public void open () {
    checkWidget ();
    bringToTop (false);
    setVisible (true);
    if (isDisposed ()) return;
    if (!restoreFocus () && !traverseGroup (true)) setFocus ();
}

override
public bool print (GC gc) {
    checkWidget ();
    if (gc is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
    return false;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when operations are performed on the receiver.
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
 * @see ShellListener
 * @see #addShellListener
 */
public void removeShellListener (ShellListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Close, listener);
    eventTable.unhook (SWT.Iconify,listener);
    eventTable.unhook (SWT.Deiconify,listener);
    eventTable.unhook (SWT.Activate, listener);
    eventTable.unhook (SWT.Deactivate, listener);
}

/**
 * If the receiver is visible, moves it to the top of the
 * drawing order for the display on which it was created
 * (so that all other shells on that display, which are not
 * the receiver's children will be drawn behind it) and asks
 * the window manager to make the shell active
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 * @see Control#moveAbove
 * @see Control#setFocus
 * @see Control#setVisible
 * @see Display#getActiveShell
 * @see Decorations#setDefaultButton(Button)
 * @see Shell#open
 * @see Shell#setActive
 */
public void setActive () {
    checkWidget ();
    bringToTop (false);
}

void setActiveControl (Control control) {
    if (control !is null && control.isDisposed ()) control = null;
    if (lastActive !is null && lastActive.isDisposed ()) lastActive = null;
    if (lastActive is control) return;

    /*
    * Compute the list of controls to be activated and
    * deactivated by finding the first common parent
    * control.
    */
    Control [] activate = (control is null) ? new Control[0] : control.getPath ();
    Control [] deactivate = (lastActive is null) ? new Control[0] : lastActive.getPath ();
    lastActive = control;
    ptrdiff_t index = 0, length = Math.min (activate.length, deactivate.length);
    while (index < length) {
        if (activate [index] !is deactivate [index]) break;
        index++;
    }

    /*
    * It is possible (but unlikely), that application
    * code could have destroyed some of the widgets. If
    * this happens, keep processing those widgets that
    * are not disposed.
    */
    for (ptrdiff_t i=deactivate.length-1; i>=index; --i) {
        if (!deactivate [i].isDisposed ()) {
            deactivate [i].sendEvent (SWT.Deactivate);
        }
    }
    for (ptrdiff_t i=activate.length-1; i>=index; --i) {
        if (!activate [i].isDisposed ()) {
            activate [i].sendEvent (SWT.Activate);
        }
    }
}

/**
 * Sets the receiver's alpha value which must be
 * between 0 (transparent) and 255 (opaque).
 * <p>
 * This operation requires the operating system's advanced
 * widgets subsystem which may not be available on some
 * platforms.
 * </p>
 * @param alpha the alpha value
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.4
 */
public void setAlpha (int alpha) {
    checkWidget ();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 12, 0)) {
        if (OS.gtk_widget_is_composited (shellHandle)) {
            alpha &= 0xFF;
            OS.gtk_window_set_opacity (shellHandle, alpha / 255f);
        }
    }
}

void resizeBounds (int width, int height, bool notify) {
    if (redrawWindow !is null) {
        OS.gdk_window_resize (redrawWindow, width, height);
    }
    if (enableWindow !is null) {
        OS.gdk_window_resize (enableWindow, width, height);
    }
    int border = OS.gtk_container_get_border_width (cast(GtkContainer*)shellHandle);
    int boxWidth = width - 2*border;
    int boxHeight = height - 2*border;
    OS.gtk_widget_set_size_request (vboxHandle, boxWidth, boxHeight);
    forceResize (boxWidth, boxHeight);
    if (notify) {
        resized = true;
        sendEvent (SWT.Resize);
        if (isDisposed ()) return;
        if (layout_ !is null) {
            markLayout (false, false);
            updateLayout (false);
        }
    }
}

override int setBounds (int x, int y, int width, int height, bool move, bool resize) {
    if (fullScreen) setFullScreen (false);
    /*
    * Bug in GTK.  When either of the location or size of
    * a shell is changed while the shell is maximized, the
    * shell is moved to (0, 0).  The fix is to explicitly
    * unmaximize the shell before setting the bounds to
    * anything different from the current bounds.
    */
    if (getMaximized ()) {
        Rectangle rect = getBounds ();
        bool sameOrigin = !move || (rect.x is x && rect.y is y);
        bool sameExtent = !resize || (rect.width is width && rect.height is height);
        if (sameOrigin && sameExtent) return 0;
        setMaximized (false);
    }
    int result = 0;
    if (move) {
        int x_pos, y_pos;
        OS.gtk_window_get_position (cast(GtkWindow*)shellHandle, &x_pos, &y_pos);
        OS.gtk_window_move (cast(GtkWindow*)shellHandle, x, y);
        if (x_pos !is x || y_pos !is y) {
            moved = true;
            oldX = x;
            oldY = y;
            sendEvent (SWT.Move);
            if (isDisposed ()) return 0;
            result |= MOVED;
        }
    }
    if (resize) {
        width = Math.max (1, Math.max (minWidth, width - trimWidth ()));
        height = Math.max (1, Math.max (minHeight, height - trimHeight ()));
        if ((style & SWT.RESIZE) !is 0) OS.gtk_window_resize (cast(GtkWindow*)shellHandle, width, height);
        bool changed = width !is oldWidth || height !is oldHeight;
        if (changed) {
            oldWidth = width;
            oldHeight = height;
            result |= RESIZED;
        }
        resizeBounds (width, height, changed);
    }
    return result;
}

override void gtk_setCursor (GdkCursor* cursor) {
    if (enableWindow !is null) {
        OS.gdk_window_set_cursor (cast(GdkDrawable*)enableWindow, cursor);
        if (!OS.GDK_WINDOWING_X11 ()) {
            OS.gdk_flush ();
        } else {
            auto xDisplay = OS.GDK_DISPLAY ();
            OS.XFlush (xDisplay);
        }
    }
    super.gtk_setCursor (cursor);
}

public override void setEnabled (bool enabled) {
    checkWidget();
    if (((state & DISABLED) is 0) is enabled) return;
    Display display = this.display;
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
        auto parentHandle = shellHandle;
        OS.gtk_widget_realize (parentHandle);
        auto window = OS.GTK_WIDGET_WINDOW (parentHandle);
        Rectangle rect = getBounds ();
        GdkWindowAttr* attributes = new GdkWindowAttr ();
        attributes.width = rect.width;
        attributes.height = rect.height;
        attributes.event_mask = (0xFFFFFFFF & ~OS.ExposureMask);
        attributes.wclass = OS.GDK_INPUT_ONLY;
        attributes.window_type = OS.GDK_WINDOW_CHILD;
        enableWindow = OS.gdk_window_new (window, attributes, 0);
        if (enableWindow !is null) {
            if (cursor !is null) {
                OS.gdk_window_set_cursor (enableWindow, cursor.handle);
                if (!OS.GDK_WINDOWING_X11 ()) {
                    OS.gdk_flush ();
                } else {
                    auto xDisplay = OS.GDK_DISPLAY ();
                    OS.XFlush (xDisplay);
                }
            }
            OS.gdk_window_set_user_data (enableWindow, parentHandle);
            OS.gdk_window_show (enableWindow);
        }
    }
    if (fixFocus_) fixFocus (control);
    if (enabled && display.activeShell is this) {
        if (!restoreFocus ()) traverseGroup (false);
    }
}

/**
 * Sets the full screen state of the receiver.
 * If the argument is <code>true</code> causes the receiver
 * to switch to the full screen state, and if the argument is
 * <code>false</code> and the receiver was previously switched
 * into full screen state, causes the receiver to switch back
 * to either the maximmized or normal states.
 * <p>
 * Note: The result of intermixing calls to <code>setFullScreen(true)</code>, 
 * <code>setMaximized(true)</code> and <code>setMinimized(true)</code> will 
 * vary by platform. Typically, the behavior will match the platform user's 
 * expectations, but not always. This should be avoided if possible.
 * </p>
 * 
 * @param fullScreen the new fullscreen state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setFullScreen (bool fullScreen) {
    checkWidget();
    if (fullScreen) {
        OS.gtk_window_fullscreen (shellHandle);
    } else {
        OS.gtk_window_unfullscreen (shellHandle);
        if (maximized) {
            setMaximized (true);
        }
    }
    this.fullScreen = fullScreen;
}

/**
 * Sets the input method editor mode to the argument which
 * should be the result of bitwise OR'ing together one or more
 * of the following constants defined in class <code>SWT</code>:
 * <code>NONE</code>, <code>ROMAN</code>, <code>DBCS</code>,
 * <code>PHONETIC</code>, <code>NATIVE</code>, <code>ALPHA</code>.
 *
 * @param mode the new IME mode
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SWT
 */
public void setImeInputMode (int mode) {
    checkWidget();
}

override void setInitialBounds () {
    if ((state & FOREIGN_HANDLE) !is 0) return;
    org.eclipse.swt.widgets.Monitor.Monitor monitor = getMonitor ();
    Rectangle rect = monitor.getClientArea ();
    int width = rect.width * 5 / 8;
    int height = rect.height * 5 / 8;
    if ((style & SWT.RESIZE) !is 0) {
        OS.gtk_window_resize (cast(GtkWindow*)shellHandle, width, height);
    }
    resizeBounds (width, height, false);
}

public override void setMaximized (bool maximized) {
    checkWidget();
    super.setMaximized (maximized);
    if (maximized) {
        OS.gtk_window_maximize (cast(GtkWindow*)shellHandle);
    } else {
        OS.gtk_window_unmaximize (cast(GtkWindow*)shellHandle);
    }
}

public override void setMenuBar (Menu menu) {
    checkWidget();
    if (menuBar is menu) return;
    bool both = menu !is null && menuBar !is null;
    if (menu !is null) {
        if ((menu.style & SWT.BAR) is 0) error (SWT.ERROR_MENU_NOT_BAR);
        if (menu.parent !is this) error (SWT.ERROR_INVALID_PARENT);
    }
    if (menuBar !is null) {
        auto menuHandle = menuBar.handle;
        OS.gtk_widget_hide (menuHandle);
        destroyAccelGroup ();
    }
    menuBar = menu;
    if (menuBar !is null) {
        auto menuHandle = menu.handle;
        OS.gtk_widget_show (menuHandle);
        createAccelGroup ();
        menuBar.addAccelerators (accelGroup);
    }
    int width = OS.GTK_WIDGET_WIDTH (vboxHandle);
    int height = OS.GTK_WIDGET_HEIGHT (vboxHandle);
    resizeBounds (width, height, !both);
}

public override void setMinimized (bool minimized) {
    checkWidget();
    if (this.minimized is minimized) return;
    super.setMinimized (minimized);
    if (minimized) {
        OS.gtk_window_iconify (cast(GtkWindow*)shellHandle);
    } else {
        OS.gtk_window_deiconify (cast(GtkWindow*)shellHandle);
        bringToTop (false);
    }
}

/**
 * Sets the receiver's minimum size to the size specified by the arguments.
 * If the new minimum size is larger than the current size of the receiver,
 * the receiver is resized to the new minimum size.
 *
 * @param width the new minimum width for the receiver
 * @param height the new minimum height for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void setMinimumSize (int width, int height) {
    checkWidget ();
    GdkGeometry* geometry = new GdkGeometry ();
    minWidth = geometry.min_width = Math.max (width, trimWidth ()) - trimWidth ();
    minHeight = geometry.min_height = Math.max (height, trimHeight ()) - trimHeight ();
    OS.gtk_window_set_geometry_hints (cast(GtkWindow*)shellHandle, null, geometry, OS.GDK_HINT_MIN_SIZE);
}

/**
 * Sets the receiver's minimum size to the size specified by the argument.
 * If the new minimum size is larger than the current size of the receiver,
 * the receiver is resized to the new minimum size.
 *
 * @param size the new minimum size for the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void setMinimumSize (Point size) {
    checkWidget ();
    if (size is null) error (SWT.ERROR_NULL_ARGUMENT);
    setMinimumSize (size.x, size.y);
}

/**
 * Sets the shape of the shell to the region specified
 * by the argument.  When the argument is null, the
 * default shape of the shell is restored.  The shell
 * must be created with the style SWT.NO_TRIM in order
 * to specify a region.
 *
 * @param region the region that defines the shape of the shell (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the region has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 *
 */
override
public void setRegion (Region region) {
    checkWidget ();
    if ((style & SWT.NO_TRIM) is 0) return;
    super.setRegion (region);
}

/*
 * Shells are never labelled by other widgets, so no initialization is needed.
 */
override void setRelations() {
}

public override void setText (String string) {
    super.setText (string);

    /*
    * GTK bug 82013.  For some reason, if the title string
    * is less than 7 bytes long and is not terminated by
    * a space, some window managers occasionally draw
    * garbage after the last character in  the title.
    * The fix is to pad the title.
    */
    ptrdiff_t length_ = string.length;
    char [] chars = new char [Math.max (6, length_) + 1];
    chars[ 0 .. length_ ] = string[ 0 .. length_];
    for (ptrdiff_t i=length_; i<chars.length; i++)  chars [i] = ' ';
    OS.gtk_window_set_title (cast(GtkWindow*)shellHandle, toStringz( chars ) );
}

public override void setVisible (bool visible) {
    checkWidget();
    int mask = SWT.PRIMARY_MODAL | SWT.APPLICATION_MODAL | SWT.SYSTEM_MODAL;
    if ((style & mask) !is 0) {
        if (visible) {
            display.setModalShell (this);
            OS.gtk_window_set_modal (shellHandle, true);
        } else {
            display.clearModal (this);
            OS.gtk_window_set_modal (shellHandle, false);
        }
    } else {
        updateModal ();
    }
    showWithParent = visible;
    if ((OS.GTK_WIDGET_MAPPED (shellHandle) is visible)) return;
    if (visible) {
        sendEvent (SWT.Show);
        if (isDisposed ()) return;

        /*
        * In order to ensure that the shell is visible
        * and fully painted, dispatch events such as
        * GDK_MAP and GDK_CONFIGURE, until the GDK_MAP
        * event for the shell is received.
        *
        * Note that if the parent is minimized or withdrawn
        * from the desktop, this should not be done since
        * the shell not will be mapped until the parent is
        * unminimized or shown on the desktop.
        */
        OS.gtk_widget_show (shellHandle);
        if (enableWindow !is null) OS.gdk_window_raise (enableWindow);
        if (!OS.GTK_IS_PLUG (cast(GTypeInstance*)shellHandle)) {
            mapped = false;
            if (isDisposed ()) return;
            display.dispatchEvents = [
                OS.GDK_EXPOSE,
                OS.GDK_FOCUS_CHANGE,
                OS.GDK_CONFIGURE,
                OS.GDK_MAP,
                OS.GDK_UNMAP,
                OS.GDK_NO_EXPOSE
            ];
            Display display = this.display;
            display.putGdkEvents();
            bool iconic = false;
            Shell shell = parent !is null ? parent.getShell() : null;
            do {
                OS.g_main_context_iteration (null, false);
                if (isDisposed ()) break;
                iconic = minimized || (shell !is null && shell.minimized);
            } while (!mapped && !iconic);
            display.dispatchEvents = null;
            if (isDisposed ()) return;
            if (!iconic) {
                update (true, true);
                if (isDisposed ()) return;
                adjustTrim ();
            }
        }
        mapped = true;

        if ((style & mask) !is 0) {
            OS.gdk_pointer_ungrab (OS.GDK_CURRENT_TIME);
        }
        opened = true;
        if (!moved) {
            moved = true;
            Point location = getLocation();
            oldX = location.x;
            oldY = location.y;
            sendEvent (SWT.Move);
            if (isDisposed ()) return;
        }
        if (!resized) {
            resized = true;
            Point size = getSize ();
            oldWidth = size.x - trimWidth ();
            oldHeight = size.y - trimHeight ();
            sendEvent (SWT.Resize);
            if (isDisposed ()) return;
            if (layout_ !is null) {
                markLayout (false, false);
                updateLayout (false);
            }
        }
    } else {
        fixActiveShell ();
        OS.gtk_widget_hide (shellHandle);
        sendEvent (SWT.Hide);
    }
}

override void setZOrder (Control sibling, bool above, bool fixRelations) {
    /*
    * Bug in GTK+.  Changing the toplevel window Z-order causes
    * X to send a resize event.  Before the shell is mapped, these
    * resize events always have a size of 200x200, causing extra
    * layout work to occur.  The fix is to modify the Z-order only
    * if the shell has already been mapped at least once.
    */
    /* Shells are never included in labelled-by relations */
    if (mapped) setZOrder (sibling, above, false, false);
}

override int shellMapProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    mapped = true;
    display.dispatchEvents = null;
    return 0;
}

override
void showWidget () {
    if ((state & FOREIGN_HANDLE) !is 0) return;
    OS.gtk_container_add (cast(GtkContainer*)shellHandle, vboxHandle);
    if (scrolledHandle !is null) OS.gtk_widget_show (scrolledHandle);
    if (handle !is null) OS.gtk_widget_show (handle);
    if (vboxHandle !is null) OS.gtk_widget_show (vboxHandle);
}

override int sizeAllocateProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    int offset = 16;
    int x, y;
    OS.gdk_window_get_pointer (null, &x, &y, null);
    y += offset;
    auto screen = OS.gdk_screen_get_default ();
    if (screen !is null) {
        int monitorNumber = OS.gdk_screen_get_monitor_at_point (screen, x, y);
        GdkRectangle* dest = new GdkRectangle ();
        OS.gdk_screen_get_monitor_geometry (screen, monitorNumber, dest);
        int width = OS.GTK_WIDGET_WIDTH (handle);
        int height = OS.GTK_WIDGET_HEIGHT (handle);
        if (x + width > dest.x + dest.width) {
            x = (dest.x + dest.width) - width;
        }
        if (y + height > dest.y + dest.height) {
            y = (dest.y + dest.height) - height;
        }
    }
    OS.gtk_window_move (cast(GtkWindow*)handle, x, y);
    return 0;
}

override int sizeRequestProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    OS.gtk_widget_hide (handle);
    return 0;
}

override bool traverseEscape () {
    if (parent is null) return false;
    if (!isVisible () || !isEnabled ()) return false;
    close ();
    return true;
}
int trimHeight () {
    if ((style & SWT.NO_TRIM) !is 0) return 0;
    if (fullScreen) return 0;
    bool hasTitle = false, hasResize = false, hasBorder = false;
    hasTitle = (style & (SWT.MIN | SWT.MAX | SWT.TITLE | SWT.MENU)) !is 0;
    hasResize = (style & SWT.RESIZE) !is 0;
    hasBorder = (style & SWT.BORDER) !is 0;
    if (hasTitle) {
        if (hasResize) return display.titleResizeTrimHeight;
        if (hasBorder) return display.titleBorderTrimHeight;
        return display.titleTrimHeight;
    }
    if (hasResize) return display.resizeTrimHeight;
    if (hasBorder) return display.borderTrimHeight;
    return 0;
}

int trimWidth () {
    if ((style & SWT.NO_TRIM) !is 0) return 0;
    if (fullScreen) return 0;
    bool hasTitle = false, hasResize = false, hasBorder = false;
    hasTitle = (style & (SWT.MIN | SWT.MAX | SWT.TITLE | SWT.MENU)) !is 0;
    hasResize = (style & SWT.RESIZE) !is 0;
    hasBorder = (style & SWT.BORDER) !is 0;
    if (hasTitle) {
        if (hasResize) return display.titleResizeTrimWidth;
        if (hasBorder) return display.titleBorderTrimWidth;
        return display.titleTrimWidth;
    }
    if (hasResize) return display.resizeTrimWidth;
    if (hasBorder) return display.borderTrimWidth;
    return 0;
}

void updateModal () {
    GtkWidget* group = null;
    if (display.getModalDialog () is null) {
        Shell modal = getModalShell ();
        int mask = SWT.PRIMARY_MODAL | SWT.APPLICATION_MODAL | SWT.SYSTEM_MODAL;
        Composite shell = null;
        if (modal is null) {
            if ((style & mask) !is 0) shell = this;
        } else {
            shell = modal;
        }
        while (shell !is null) {
            if ((shell.style & mask) is 0) {
                group = shell.getShell ().group;
                break;
            }
            shell = shell.parent;
        }
    }
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 10, 0) && group is null) {
        /*
        * Feature in GTK. Starting with GTK version 2.10, GTK
        * doesn't assign windows to a default group. The fix is to
        * get the handle of the default group and add windows to the
        * group.
        */
        group = cast(GtkWidget*)OS.gtk_window_get_group(null);
    }
    if (group !is null) {
        OS.gtk_window_group_add_window (group, shellHandle);
    } else {
        if (modalGroup !is null) {
            OS.gtk_window_group_remove_window (modalGroup, shellHandle);
        }
    }
    if (OS.GTK_VERSION < OS.buildVERSION (2, 4, 0)) {
        fixModal (group, modalGroup);
    }
    modalGroup = group;
}

void updateMinimized (bool minimized) {
    Shell[] shells = getShells ();
    for (int i = 0; i < shells.length; i++) {
        bool update = false;
        Shell shell = shells[i];
        while (shell !is null && shell !is this && !shell.isUndecorated ()) {
            shell = cast(Shell) shell.getParent ();
        }
        if (shell !is null && shell !is this) update = true;
        if (update) {
            if (minimized) {
                if (shells[i].isVisible ()) {
                    shells[i].showWithParent = true;
                    OS.gtk_widget_hide(shells[i].shellHandle);
                }
            } else {
                if (shells[i].showWithParent) {
                    shells[i].showWithParent = false;
                    OS.gtk_widget_show(shells[i].shellHandle);
                }
            }
        }
    }
}

override void deregister () {
    super.deregister ();
    display.removeWidget (shellHandle);
}

override public void dispose () {
    /*
    * Note:  It is valid to attempt to dispose a widget
    * more than once.  If this happens, fail silently.
    */
    if (isDisposed()) return;
    fixActiveShell ();
    OS.gtk_widget_hide (shellHandle);
    super.dispose ();
}

/**
 * If the receiver is visible, moves it to the top of the
 * drawing order for the display on which it was created
 * (so that all other shells on that display, which are not
 * the receiver's children will be drawn behind it) and forces
 * the window manager to make the shell active.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 * @see Control#moveAbove
 * @see Control#setFocus
 * @see Control#setVisible
 * @see Display#getActiveShell
 * @see Decorations#setDefaultButton(Button)
 * @see Shell#open
 * @see Shell#setActive
 */
public void forceActive () {
    checkWidget ();
    bringToTop (true);
}

override public Rectangle getBounds () {
    checkWidget ();
    int x, y ;
    OS.gtk_window_get_position (cast(GtkWindow*)shellHandle, &x, &y);
    int width = OS.GTK_WIDGET_WIDTH (vboxHandle);
    int height = OS.GTK_WIDGET_HEIGHT (vboxHandle);
    int border = 0;
    if ((style & (SWT.NO_TRIM | SWT.BORDER | SWT.SHELL_TRIM)) is 0) {
        border = OS.gtk_container_get_border_width (cast(GtkContainer*)shellHandle);
    }
    return new Rectangle (x, y, width + trimWidth () + 2*border, height + trimHeight () + 2*border);
}

override void releaseHandle () {
    super.releaseHandle ();
    shellHandle = null;
}

override void releaseChildren (bool destroy) {
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) {
        Shell shell = shells [i];
        if (shell !is null && !shell.isDisposed ()) {
            shell.release (false);
        }
    }
    super.releaseChildren (destroy);
}

override void releaseWidget () {
    super.releaseWidget ();
    destroyAccelGroup ();
    display.clearModal (this);
    if (display.activeShell is this) display.activeShell = null;
    if (tooltipsHandle !is null) OS.g_object_unref (tooltipsHandle);
    tooltipsHandle = null;
    if (group !is null) OS.g_object_unref (group);
    group = modalGroup = null;
    auto window = OS.GTK_WIDGET_WINDOW (shellHandle);
    display.doWindowRemoveFilter( &filterProcCallbackData, window, shellHandle );

    lastActive = null;
}

void setToolTipText (GtkWidget* tipWidget, String string) {
    setToolTipText (tipWidget, tipWidget, string);
}

void setToolTipText (GtkWidget* rootWidget, GtkWidget* tipWidget, String string) {
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 12, 0)) {
        char * buffer = null;
        if (string !is null && string.length > 0) {
            char [] chars = fixMnemonic (string, false);
            buffer = toStringz( chars );
        }
        OS.gtk_widget_set_tooltip_text (rootWidget, null);
        /*
        * Bug in GTK. In GTK 2.12, due to a miscalculation of window
        * coordinates, using gtk_tooltip_trigger_tooltip_query ()
        * to update an existing a tooltip will result in the tooltip
        * being displayed at a wrong position. The fix is to send out
        * 2 fake GDK_MOTION_NOTIFY events (to mimic the GTK call) which
        * contain the proper x and y coordinates.
        */
        GdkEvent* eventPtr = null;
        auto tipWindow = OS.GTK_WIDGET_WINDOW (rootWidget);
        if (tipWindow !is null) {
            int x, y;
            auto window = OS.gdk_window_at_pointer (&x, &y);
            void* user_data;
            if( window !is null ) OS.gdk_window_get_user_data (window, &user_data);
            if (tipWidget is user_data ) {
                eventPtr = OS.gdk_event_new (OS.GDK_MOTION_NOTIFY);
                eventPtr.type = OS.GDK_MOTION_NOTIFY;
                eventPtr.motion.window = cast(GdkDrawable*)OS.g_object_ref (tipWindow);
                eventPtr.motion.x = x;
                eventPtr.motion.y = y;
                OS.gdk_window_get_origin (window, &x, &y);
                eventPtr.motion.x_root = eventPtr.motion.x + x;
                eventPtr.motion.y_root = eventPtr.motion.y + y;
                OS.gtk_main_do_event (eventPtr);
            }
        }
        OS.gtk_widget_set_tooltip_text (rootWidget, buffer);
        if (eventPtr !is null) {
            OS.gtk_main_do_event (eventPtr);
            OS.gdk_event_free (eventPtr);
        }
    } else {
        char* buffer = null;
        if (string !is null && string.length > 0) {
            char [] chars = fixMnemonic (string, false);
            buffer = toStringz( chars );
        }
        if (tooltipsHandle is null) {
            tooltipsHandle = cast(GtkWidget*)OS.gtk_tooltips_new ();
            if (tooltipsHandle is null) error (SWT.ERROR_NO_HANDLES);
            OS.g_object_ref (tooltipsHandle);
            OS.gtk_object_sink (cast(GtkObject*)tooltipsHandle);
        }

        /*
        * Feature in GTK.  There is no API to position a tooltip.
        * The fix is to connect to the size_allocate signal for
        * the tooltip window and position it before it is mapped.
        *
        * Bug in Solaris-GTK.  Invoking gtk_tooltips_force_window()
        * can cause a crash in older versions of GTK.  The fix is
        * to avoid this call if the GTK version is older than 2.2.x.
        */
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 2, 1)) {
            OS.gtk_tooltips_force_window (cast(GtkTooltips*)tooltipsHandle);
        }
        auto tipWindow = OS.GTK_TOOLTIPS_TIP_WINDOW (cast(GtkTooltips*)tooltipsHandle);
        if (tipWindow !is null && tipWindow !is tooltipWindow) {
            display.doSizeAllocateConnect( &sizeAllocateProcCallbackData, tipWindow, shellHandle );
            tooltipWindow = tipWindow;
        }

        /*
        * Bug in GTK.  If the cursor is inside the window when a new
        * tooltip is set and the old tooltip is hidden, the new tooltip
        * is not displayed until the mouse re-enters the window.  The
        * fix is force the new tooltip to be active.
        */
        bool set = true;
        if (tipWindow !is null) {
            if ((OS.GTK_WIDGET_FLAGS (tipWidget) & (OS.GTK_REALIZED | OS.GTK_VISIBLE)) !is 0) {
                int  x, y;
                auto window = OS.gdk_window_at_pointer (&x, &y);
                if (window !is null) {
                    GtkWidget* user_data;
                    OS.gdk_window_get_user_data (window, cast(void**)&user_data);
                    if (tipWidget is user_data) {
                        /*
                        * Feature in GTK.  Calling gtk_tooltips_set_tip() positions and
                        * shows the tooltip.  If the tooltip is already visible, moving
                        * it to a new location in the size_allocate signal causes flashing.
                        * The fix is to hide the tip window in the size_request signal
                        * and before the new tooltip is forced to be active.
                        */
                        set = false;
                        auto handler_id = display.doSizeRequestConnect( &sizeRequestProcCallbackData, tipWindow, shellHandle );
                        OS.gtk_tooltips_set_tip (cast(GtkTooltips*)tooltipsHandle, tipWidget, buffer, null);
                        OS.gtk_widget_hide (tipWindow);
                        auto data = OS.gtk_tooltips_data_get (tipWidget);
                        OS.GTK_TOOLTIPS_SET_ACTIVE (cast(GtkTooltips*)tooltipsHandle, cast(GtkTooltipsData*)data);
                        OS.gtk_tooltips_set_tip (cast(GtkTooltips*)tooltipsHandle, tipWidget, buffer, null);
                        if (handler_id !is 0) OS.g_signal_handler_disconnect (tipWindow, handler_id);
                    }
                }
            }
        }
        if (set) OS.gtk_tooltips_set_tip (cast(GtkTooltips*)tooltipsHandle, tipWidget, buffer, null);
    }

}
}
