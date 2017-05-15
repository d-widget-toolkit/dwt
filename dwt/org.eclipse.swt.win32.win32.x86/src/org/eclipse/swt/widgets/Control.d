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



import org.eclipse.swt.SWT;

import org.eclipse.swt.SWTException;

import org.eclipse.swt.accessibility.Accessible;

import org.eclipse.swt.events.ControlListener;

import org.eclipse.swt.events.DragDetectListener;

import org.eclipse.swt.events.FocusListener;

import org.eclipse.swt.events.HelpListener;

import org.eclipse.swt.events.KeyListener;

import org.eclipse.swt.events.MenuDetectListener;

import org.eclipse.swt.events.MouseEvent;

import org.eclipse.swt.events.MouseListener;

import org.eclipse.swt.events.MouseMoveListener;

import org.eclipse.swt.events.MouseTrackListener;

import org.eclipse.swt.events.MouseWheelListener;

import org.eclipse.swt.events.PaintListener;

import org.eclipse.swt.events.TraverseListener;

import org.eclipse.swt.graphics.Color;

import org.eclipse.swt.graphics.Cursor;

import org.eclipse.swt.graphics.Drawable;

import org.eclipse.swt.graphics.Font;

import org.eclipse.swt.graphics.GC;

import org.eclipse.swt.graphics.GCData;

import org.eclipse.swt.graphics.Image;

import org.eclipse.swt.graphics.Point;

import org.eclipse.swt.graphics.Rectangle;

import org.eclipse.swt.graphics.Region;

import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Widget;

import org.eclipse.swt.widgets.Composite;

import org.eclipse.swt.widgets.Dialog;

import org.eclipse.swt.widgets.Event;

import org.eclipse.swt.widgets.Shell;

import org.eclipse.swt.widgets.Menu;

import org.eclipse.swt.widgets.MenuItem;

import org.eclipse.swt.widgets.Decorations;

import org.eclipse.swt.widgets.TypedListener;

import org.eclipse.swt.widgets.Listener;

import org.eclipse.swt.widgets.Display;

import org.eclipse.swt.widgets.Monitor;



import java.lang.all;

import java.lang.System;



version(Tango){

    //static import tango.sys.Common;

} else { // Phobos

}



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



    alias Widget.dragDetect dragDetect;

    alias Widget.callWindowProc callWindowProc;



    /**

     * the handle to the OS resource

     * (Warning: This field is platform dependent)

     * <p>

     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT

     * public API. It is marked public only so that it can be shared

     * within the packages provided by SWT. It is not available on all

     * platforms and should never be accessed from application code.

     * </p>

     */

    public HANDLE handle;

    Composite parent;

    Cursor cursor;

    Menu menu;

    String toolTipText_;

    Object layoutData;

    Accessible accessible;

    Image backgroundImage;

    Region region;

    Font font;

    int drawCount, foreground, background;



/**

 * Prevents uninitialized instances from being created outside the package.

 */

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

    createWidget ();

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

    checkWidget ();

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

public void addFocusListener (FocusListener listener) {

    checkWidget ();

    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);

    TypedListener typedListener = new TypedListener (listener);

    addListener (SWT.FocusIn,typedListener);

    addListener (SWT.FocusOut,typedListener);

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

    checkWidget ();

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

public void addKeyListener (KeyListener listener) {

    checkWidget ();

    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);

    TypedListener typedListener = new TypedListener (listener);

    addListener (SWT.KeyUp,typedListener);

    addListener (SWT.KeyDown,typedListener);

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

public void addMouseListener (MouseListener listener) {

    checkWidget ();

    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);

    TypedListener typedListener = new TypedListener (listener);

    addListener (SWT.MouseDown,typedListener);

    addListener (SWT.MouseUp,typedListener);

    addListener (SWT.MouseDoubleClick,typedListener);

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

    checkWidget ();

    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);

    TypedListener typedListener = new TypedListener (listener);

    addListener (SWT.MouseEnter,typedListener);

    addListener (SWT.MouseExit,typedListener);

    addListener (SWT.MouseHover,typedListener);

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

public void addMouseMoveListener (MouseMoveListener listener) {

    checkWidget ();

    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);

    TypedListener typedListener = new TypedListener (listener);

    addListener (SWT.MouseMove,typedListener);

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

public void addPaintListener (PaintListener listener) {

    checkWidget ();

    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);

    TypedListener typedListener = new TypedListener (listener);

    addListener (SWT.Paint,typedListener);

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

    checkWidget ();

    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);

    TypedListener typedListener = new TypedListener (listener);

    addListener (SWT.Traverse,typedListener);

}



HANDLE borderHandle () {

    return handle;

}



void checkBackground () {

    Shell shell = getShell ();

    if (this is shell) return;

    state &= ~PARENT_BACKGROUND;

    Composite composite = parent;

    do {

        auto mode = composite.backgroundMode;

        if (mode !is 0) {

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



void checkBuffered () {

    style &= ~SWT.DOUBLE_BUFFERED;

}



void checkComposited () {

    /* Do nothing */

}



bool checkHandle (HWND hwnd) {

    return hwnd is handle;

}



void checkMirrored () {

    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {

        int bits = OS.GetWindowLong (handle, OS.GWL_EXSTYLE);

        if ((bits & OS.WS_EX_LAYOUTRTL) !is 0) style |= SWT.MIRRORED;

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

    checkWidget ();

    int width = DEFAULT_WIDTH;

    int height = DEFAULT_HEIGHT;

    if (wHint !is SWT.DEFAULT) width = wHint;

    if (hHint !is SWT.DEFAULT) height = hHint;

    int border = getBorderWidth ();

    width += border * 2;

    height += border * 2;

    return new Point (width, height);

}



Control computeTabGroup () {

    if (isTabGroup ()) return this;

    return parent.computeTabGroup ();

}



Control computeTabRoot () {

    Control [] tabList = parent._getTabList ();

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



Control [] computeTabList () {

    if (isTabGroup ()) {

        if (getVisible () && getEnabled ()) {

            return [this];

        }

    }

    return new Control [0];

}



void createHandle () {

    auto hwndParent = widgetParent ();

    handle = OS.CreateWindowEx (

        widgetExtStyle (),

        StrToTCHARz( windowClass () ),

        null,

        widgetStyle (),

        OS.CW_USEDEFAULT, 0, OS.CW_USEDEFAULT, 0,

        hwndParent,

        null,

        OS.GetModuleHandle (null),

        widgetCreateStruct ());

    if (handle is null) error (SWT.ERROR_NO_HANDLES);

    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);

    if ((bits & OS.WS_CHILD) !is 0) {

        OS.SetWindowLongPtr (handle, OS.GWLP_ID, cast(LONG_PTR)handle);

    }

    if (OS.IsDBLocale && hwndParent !is null) {

        auto hIMC = OS.ImmGetContext (hwndParent);

        OS.ImmAssociateContext (handle, hIMC);

        OS.ImmReleaseContext (hwndParent, hIMC);

    }

}



void createWidget () {

    state |= DRAG_DETECT;

    foreground = background = -1;

    checkOrientation (parent);

    createHandle ();

    checkBackground ();

    checkBuffered ();

    checkComposited ();

    register ();

    subclass ();

    setDefaultFont ();

    checkMirrored ();

    checkBorder ();

    if ((state & PARENT_BACKGROUND) !is 0) {

        setBackground ();

    }

}



int defaultBackground () {

    static if (OS.IsWinCE) return OS.GetSysColor (OS.COLOR_WINDOW);

    return OS.GetSysColor (OS.COLOR_BTNFACE);

}



HFONT defaultFont () {

    return display.getSystemFont ().handle;

}



int defaultForeground () {

    return OS.GetSysColor (OS.COLOR_WINDOWTEXT);

}



void deregister () {

    display.removeControl (handle);

}



override void destroyWidget () {

    auto hwnd = topHandle ();

    releaseHandle ();

    if (hwnd !is null) {

        OS.DestroyWindow (hwnd);

    }

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

    bool dragging = dragDetect (handle, x, y, false, null, null);

    if (OS.GetKeyState (OS.VK_LBUTTON) < 0) {

        if (OS.GetCapture () !is handle) OS.SetCapture (handle);

    }

    if (!dragging) {

        /*

        * Feature in Windows.  DragDetect() captures the mouse

        * and tracks its movement until the user releases the

        * left mouse button, presses the ESC key, or moves the

        * mouse outside the drag rectangle.  If the user moves

        * the mouse outside of the drag rectangle, DragDetect()

        * returns true and a drag and drop operation can be

        * started.  When the left mouse button is released or

        * the ESC key is pressed, these events are consumed by

        * DragDetect() so that application code that matches

        * mouse down/up pairs or looks for the ESC key will not

        * function properly.  The fix is to send the missing

        * events when the drag has not started.

        *

        * NOTE: For now, don't send a fake WM_KEYDOWN/WM_KEYUP

        * events for the ESC key.  This would require computing

        * wParam (the key) and lParam (the repeat count, scan code,

        * extended-key flag, context code, previous key-state flag,

        * and transition-state flag) which is non-trivial.

        */

        if (button is 1 && OS.GetKeyState (OS.VK_ESCAPE) >= 0) {

            WPARAM wParam = 0;

            if ((stateMask & SWT.CTRL) !is 0) wParam |= OS.MK_CONTROL;

            if ((stateMask & SWT.SHIFT) !is 0) wParam |= OS.MK_SHIFT;

            if ((stateMask & SWT.ALT) !is 0) wParam |= OS.MK_ALT;

            if ((stateMask & SWT.BUTTON1) !is 0) wParam |= OS.MK_LBUTTON;

            if ((stateMask & SWT.BUTTON2) !is 0) wParam |= OS.MK_MBUTTON;

            if ((stateMask & SWT.BUTTON3) !is 0) wParam |= OS.MK_RBUTTON;

            if ((stateMask & SWT.BUTTON4) !is 0) wParam |= OS.MK_XBUTTON1;

            if ((stateMask & SWT.BUTTON5) !is 0) wParam |= OS.MK_XBUTTON2;

            LPARAM lParam = OS.MAKELPARAM (x, y);

            OS.SendMessage (handle, OS.WM_LBUTTONUP, wParam, lParam);

        }

        return false;

    }

    return sendDragEvent (button, stateMask, x, y);

}



void drawBackground (HDC hDC) {

    RECT rect;

    OS.GetClientRect (handle, &rect);

    drawBackground (hDC, &rect);

}



void drawBackground (HDC hDC, RECT* rect) {

    drawBackground (hDC, rect, -1);

}



void drawBackground (HDC hDC, RECT* rect, int pixel) {

    Control control = findBackgroundControl ();

    if (control !is null) {

        if (control.backgroundImage !is null) {

            fillImageBackground (hDC, control, rect);

            return;

        }

        pixel = control.getBackgroundPixel ();

    }

    if (pixel is -1) {

        if ((state & THEME_BACKGROUND) !is 0) {

            if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {

                control = findThemeControl ();

                if (control !is null) {

                    fillThemeBackground (hDC, control, rect);

                    return;

                }

            }

        }

    }

    if (pixel is -1) pixel = getBackgroundPixel ();

    fillBackground (hDC, pixel, rect);

}



void drawImageBackground (HDC hDC, HWND hwnd, HBITMAP hBitmap, RECT* rect) {

    RECT rect2;

    OS.GetClientRect (hwnd, &rect2);

    OS.MapWindowPoints (hwnd, handle, cast(POINT*)&rect2, 2);

    auto hBrush = findBrush (cast(ptrdiff_t)hBitmap, OS.BS_PATTERN);

    POINT lpPoint;

    OS.GetWindowOrgEx (hDC, &lpPoint);

    OS.SetBrushOrgEx (hDC, -rect2.left - lpPoint.x, -rect2.top - lpPoint.y, &lpPoint);

    auto hOldBrush = OS.SelectObject (hDC, hBrush);

    OS.PatBlt (hDC, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, OS.PATCOPY);

    OS.SetBrushOrgEx (hDC, lpPoint.x, lpPoint.y, null);

    OS.SelectObject (hDC, hOldBrush);

}



void drawThemeBackground (HDC hDC, HWND hwnd, RECT* rect) {

    /* Do nothing */

}



void enableDrag (bool enabled) {

    /* Do nothing */

}



void enableWidget (bool enabled) {

    OS.EnableWindow (handle, enabled);

}



void fillBackground (HDC hDC, COLORREF pixel, RECT* rect) {

    if (rect.left > rect.right || rect.top > rect.bottom) return;

    auto hPalette = display.hPalette;

    if (hPalette !is null) {

        OS.SelectPalette (hDC, hPalette, false);

        OS.RealizePalette (hDC);

    }

    OS.FillRect (hDC, rect, findBrush (pixel, OS.BS_SOLID));

}



void fillImageBackground (HDC hDC, Control control, RECT* rect) {

    if (rect.left > rect.right || rect.top > rect.bottom) return;

    if (control !is null) {

        Image image = control.backgroundImage;

        if (image !is null) {

            control.drawImageBackground (hDC, handle, image.handle, rect);

        }

    }

}



void fillThemeBackground (HDC hDC, Control control, RECT* rect) {

    if (rect.left > rect.right || rect.top > rect.bottom) return;

    if (control !is null) {

        control.drawThemeBackground (hDC, handle, rect);

    }

}



Control findBackgroundControl () {

    if (background !is -1 || backgroundImage !is null) return this;

    return (state & PARENT_BACKGROUND) !is 0 ? parent.findBackgroundControl () : null;

}



HBRUSH findBrush (ptrdiff_t value, int lbStyle) {

    return parent.findBrush (value, lbStyle);

}



Cursor findCursor () {

    if (cursor !is null) return cursor;

    return parent.findCursor ();

}



Control findImageControl () {

    Control control = findBackgroundControl ();

    return control !is null && control.backgroundImage !is null ? control : null;

}



Control findThemeControl () {

    return background is -1 && backgroundImage is null ? parent.findThemeControl () : null;

}



Menu [] findMenus (Control control) {

    if (menu !is null && this !is control) return [menu];

    return new Menu [0];

}



char findMnemonic (String string) {

    int index = 0;

    int length_ = cast(int)/*64bit*/string.length;

    do {

        while (index < length_ && string.charAt (index) !is '&') index++;

        if (++index >= length_) return '\0';

        if (string.charAt (index) !is '&') return string.charAt (index);

        index++;

    } while (index < length_);

    return '\0';

}



void fixChildren (Shell newShell, Shell oldShell, Decorations newDecorations, Decorations oldDecorations, Menu [] menus) {

    oldShell.fixShell (newShell, this);

    oldDecorations.fixDecorations (newDecorations, this, menus);

}



void fixFocus (Control focusControl) {

    Shell shell = getShell ();

    Control control = this;

    while (control !is shell && (control = control.parent) !is null) {

        if (control.setFixedFocus ()) return;

    }

    shell.setSavedFocus (focusControl);

    OS.SetFocus (null);

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

    checkWidget ();

    if (display.focusEvent is SWT.FocusOut) return false;

    Decorations shell = menuShell ();

    shell.setSavedFocus (this);

    if (!isEnabled () || !isVisible () || !isActive ()) return false;

    if (isFocusControl ()) return true;

    shell.setSavedFocus (null);

    /*

    * This code is intentionally commented.

    *

    * When setting focus to a control, it is

    * possible that application code can set

    * the focus to another control inside of

    * WM_SETFOCUS.  In this case, the original

    * control will no longer have the focus

    * and the call to setFocus() will return

    * false indicating failure.

    *

    * We are still working on a solution at

    * this time.

    */

//  if (OS.GetFocus () !is OS.SetFocus (handle)) return false;

    OS.SetFocus (handle);

    if (isDisposed ()) return false;

    shell.setSavedFocus (this);

    return isFocusControl ();

}



void forceResize () {

    if (parent is null) return;

    WINDOWPOS*[] lpwp = parent.lpwp;

    if (lpwp is null) return;

    for (int i=0; i<lpwp.length; i++) {

        WINDOWPOS* wp = lpwp [i];

        if (wp !is null && wp._hwnd is handle) {

            /*

            * This code is intentionally commented.  All widgets that

            * are created by SWT have WS_CLIPSIBLINGS to ensure that

            * application code does not draw outside of the control.

            */

//          int count = parent.getChildrenCount ();

//          if (count > 1) {

//              int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);

//              if ((bits & OS.WS_CLIPSIBLINGS) is 0) wp.flags |= OS.SWP_NOCOPYBITS;

//          }

            SetWindowPos (wp._hwnd, null, wp.x, wp.y, wp.cx, wp.cy, wp.flags);

            lpwp [i] = null;

            return;

        }

    }

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

    if (accessible is null) accessible = new_Accessible (this);

    return accessible;

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

    checkWidget ();

    Control control = findBackgroundControl ();

    if (control is null) control = this;

    return Color.win32_new (display, control.getBackgroundPixel ());

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



int getBackgroundPixel () {

    return background !is -1 ? background :  defaultBackground ();

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

    checkWidget ();

    auto borderHandle = borderHandle ();

    int bits1 = OS.GetWindowLong (borderHandle, OS.GWL_EXSTYLE);

    if ((bits1 & OS.WS_EX_CLIENTEDGE) !is 0) return OS.GetSystemMetrics (OS.SM_CXEDGE);

    if ((bits1 & OS.WS_EX_STATICEDGE) !is 0) return OS.GetSystemMetrics (OS.SM_CXBORDER);

    int bits2 = OS.GetWindowLong (borderHandle, OS.GWL_STYLE);

    if ((bits2 & OS.WS_BORDER) !is 0) return OS.GetSystemMetrics (OS.SM_CXBORDER);

    return 0;

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

    checkWidget ();

    forceResize ();

    RECT rect;

    OS.GetWindowRect (topHandle (), &rect);

    auto hwndParent = parent is null ? null : parent.handle;

    OS.MapWindowPoints (null, hwndParent, cast(POINT*)&rect, 2);

    int width = rect.right - rect.left;

    int height =  rect.bottom - rect.top;

    return new Rectangle (rect.left, rect.top, width, height);

}



int getCodePage () {

    if (OS.IsUnicode) return OS.CP_ACP;

    auto hFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);

    LOGFONT logFont;

    OS.GetObject (hFont, LOGFONT.sizeof, &logFont);

    int cs = logFont.lfCharSet & 0xFF;

    int [] lpCs = new int [8];

    if (OS.TranslateCharsetInfo (cast(uint*)cs, cast(CHARSETINFO*)lpCs.ptr, OS.TCI_SRCCHARSET)) {

        return lpCs [1];

    }

    return OS.GetACP ();

}



String getClipboardText () {

    String string = "";

    if (OS.OpenClipboard (null)) {

        auto hMem = OS.GetClipboardData (OS.IsUnicode ? OS.CF_UNICODETEXT : OS.CF_TEXT);

        if (hMem !is null) {

            /* Ensure byteCount is a multiple of 2 bytes on UNICODE platforms */

            auto byteCount = OS.GlobalSize (hMem) / TCHAR.sizeof * TCHAR.sizeof;

            auto ptr = OS.GlobalLock (hMem);

            if (ptr !is null) {

                /* Use the character encoding for the default locale */

                string = TCHARzToStr( cast(TCHAR*)ptr );

                OS.GlobalUnlock (hMem);

            }

        }

        OS.CloseClipboard ();

    }

    return string;

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

    return cast(bool)OS.IsWindowEnabled (handle);

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

    checkWidget ();

    if (font !is null) return font;

    auto hFont = cast(HFONT)OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);

    if (hFont is null) hFont = defaultFont ();

    return Font.win32_new (display, hFont);

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

    checkWidget ();

    return Color.win32_new (display, getForegroundPixel ());

}



int getForegroundPixel () {

    return foreground !is -1 ? foreground : defaultForeground ();

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

    checkWidget ();

    return layoutData;

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

    checkWidget ();

    forceResize ();

    RECT rect;

    OS.GetWindowRect (topHandle (), &rect);

    auto hwndParent = parent is null ? null : parent.handle;

    OS.MapWindowPoints (null, hwndParent, cast(POINT*)&rect, 2);

    return new Point (rect.left, rect.top);

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

override public Menu getMenu () {

    checkWidget ();

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

    checkWidget ();

    if (OS.IsWinCE || OS.WIN32_VERSION < OS.VERSION (4, 10)) {

        return display.getPrimaryMonitor ();

    }

    auto hmonitor = OS.MonitorFromWindow (handle, OS.MONITOR_DEFAULTTONEAREST);

    MONITORINFO lpmi;

    lpmi.cbSize = MONITORINFO.sizeof;

    OS.GetMonitorInfo (hmonitor, &lpmi);

    org.eclipse.swt.widgets.Monitor.Monitor monitor = new org.eclipse.swt.widgets.Monitor.Monitor ();

    monitor.handle = hmonitor;

    monitor.x = lpmi.rcMonitor.left;

    monitor.y = lpmi.rcMonitor.top;

    monitor.width = lpmi.rcMonitor.right - lpmi.rcMonitor.left;

    monitor.height = lpmi.rcMonitor.bottom - lpmi.rcMonitor.top;

    monitor.clientX = lpmi.rcWork.left;

    monitor.clientY = lpmi.rcWork.top;

    monitor.clientWidth = lpmi.rcWork.right - lpmi.rcWork.left;

    monitor.clientHeight = lpmi.rcWork.bottom - lpmi.rcWork.top;

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

    checkWidget ();

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

public Shell getShell () {

    checkWidget ();

    return parent.getShell ();

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

    checkWidget ();

    forceResize ();

    RECT rect;

    OS.GetWindowRect (topHandle (), &rect);

    int width = rect.right - rect.left;

    int height = rect.bottom - rect.top;

    return new Point (width, height);

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

    checkWidget ();

    return toolTipText_;

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

    if (drawCount !is 0) return (state & HIDDEN) is 0;

    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);

    return (bits & OS.WS_VISIBLE) !is 0;

}



bool hasCursor () {

    RECT rect;

    if (!OS.GetClientRect (handle, &rect)) return false;

    OS.MapWindowPoints (handle, null, cast(POINT*)&rect, 2);

    POINT pt;

    return OS.GetCursorPos (&pt) && OS.PtInRect (&rect, pt);

}



bool hasFocus () {

    /*

    * If a non-SWT child of the control has focus,

    * then this control is considered to have focus

    * even though it does not have focus in Windows.

    */

    auto hwndFocus = OS.GetFocus ();

    while (hwndFocus !is null) {

        if (hwndFocus is handle) return true;

        if (display.getControl (hwndFocus) !is null) {

            return false;

        }

        hwndFocus = OS.GetParent (hwndFocus);

    }

    return false;

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

public HDC internal_new_GC (GCData data) {

    checkWidget();

    auto hwnd = handle;

    if (data !is null && data.hwnd !is null) hwnd = data.hwnd;

    if (data !is null) data.hwnd = hwnd;

    HDC hDC;

    if (data is null || data.ps is null) {

        hDC = OS.GetDC (hwnd);

    } else {

        hDC = OS.BeginPaint (hwnd, data.ps);

    }

    if (hDC is null) SWT.error(SWT.ERROR_NO_HANDLES);

    if (data !is null) {

        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (4, 10)) {

            int mask = SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT;

            if ((data.style & mask) !is 0) {

                data.layout = (data.style & SWT.RIGHT_TO_LEFT) !is 0 ? OS.LAYOUT_RTL : 0;

            } else {

                int flags = OS.GetLayout (hDC);

                if ((flags & OS.LAYOUT_RTL) !is 0) {

                    data.style |= SWT.RIGHT_TO_LEFT | SWT.MIRRORED;

                } else {

                    data.style |= SWT.LEFT_TO_RIGHT;

                }

            }

        } else {

            data.style |= SWT.LEFT_TO_RIGHT;

        }

        data.device = display;

        auto foreground = getForegroundPixel ();

        if (foreground !is OS.GetTextColor (hDC)) data.foreground = foreground;

        Control control = findBackgroundControl ();

        if (control is null) control = this;

        auto background = control.getBackgroundPixel ();

        if (background !is OS.GetBkColor (hDC)) data.background = background;

        data.font = font !is null ? font : Font.win32_new (display, cast(HFONT)OS.SendMessage (hwnd, OS.WM_GETFONT, 0, 0));

        data.uiState = cast(int)/*64bit*/OS.SendMessage (hwnd, OS.WM_QUERYUISTATE, 0, 0);

    }

    return hDC;

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

public void internal_dispose_GC (HDC hDC, GCData data) {

    checkWidget ();

    auto hwnd = handle;

    if (data !is null && data.hwnd !is null) {

        hwnd = data.hwnd;

    }

    if (data is null || data.ps is null) {

        OS.ReleaseDC (hwnd, hDC);

    } else {

        OS.EndPaint (hwnd, data.ps);

    }

}



bool isActive () {

    Dialog dialog = display.getModalDialog ();

    if (dialog !is null) {

        Shell dialogShell = dialog.parent;

        if (dialogShell !is null && !dialogShell.isDisposed ()) {

            if (dialogShell !is getShell ()) return false;

        }

    }

    Shell shell = null;

    Shell [] modalShells = display.modalShells;

    if (modalShells !is null) {

        int bits = SWT.APPLICATION_MODAL | SWT.SYSTEM_MODAL;

        int index = cast(int)/*64bit*/modalShells.length;

        while (--index >= 0) {

            Shell modal = modalShells [index];

            if (modal !is null) {

                if ((modal.style & bits) !is 0) {

                    Control control = this;

                    while (control !is null) {

                        if (control is modal) break;

                        control = control.parent;

                    }

                    if (control !is modal) return false;

                    break;

                }

                if ((modal.style & SWT.PRIMARY_MODAL) !is 0) {

                    if (shell is null) shell = getShell ();

                    if (modal.parent is shell) return false;

                }

            }

        }

    }

    if (shell is null) shell = getShell ();

    return shell.getEnabled ();

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

    checkWidget ();

    Control focusControl = display.focusControl;

    if (focusControl !is null && !focusControl.isDisposed ()) {

        return this is focusControl;

    }

    return hasFocus ();

}



bool isFocusAncestor (Control control) {

    while (control !is null && control !is this && !(cast(Shell)control )) {

        control = control.parent;

    }

    return control is this;

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

    checkWidget ();

    return true;

}



bool isShowing () {

    /*

    * This is not complete.  Need to check if the

    * widget is obscured by a parent or sibling.

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

    /*

    * Check to see if current damage is included.

    */

//  if (!OS.IsWindowVisible (handle)) return false;

//  int flags = OS.DCX_CACHE | OS.DCX_CLIPCHILDREN | OS.DCX_CLIPSIBLINGS;

//  auto hDC = OS.GetDCEx (handle, 0, flags);

//  int result = OS.GetClipBox (hDC, new RECT ());

//  OS.ReleaseDC (handle, hDC);

//  return result !is OS.NULLREGION;

}



bool isTabGroup () {

    Control [] tabList = parent._getTabList ();

    if (tabList !is null) {

        for (int i=0; i<tabList.length; i++) {

            if (tabList [i] is this) return true;

        }

    }

    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);

    return (bits & OS.WS_TABSTOP) !is 0;

}



bool isTabItem () {

    Control [] tabList = parent._getTabList ();

    if (tabList !is null) {

        for (int i=0; i<tabList.length; i++) {

            if (tabList [i] is this) return false;

        }

    }

    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);

    if ((bits & OS.WS_TABSTOP) !is 0) return false;

    auto code = OS.SendMessage (handle, OS.WM_GETDLGCODE, 0, 0);

    if ((code & OS.DLGC_STATIC) !is 0) return false;

    if ((code & OS.DLGC_WANTALLKEYS) !is 0) return false;

    if ((code & OS.DLGC_WANTARROWS) !is 0) return false;

    if ((code & OS.DLGC_WANTTAB) !is 0) return false;

    return true;

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

    checkWidget ();

    if (OS.IsWindowVisible (handle)) return true;

    return getVisible () && parent.isVisible ();

}



override void mapEvent (HWND hwnd, Event event) {

    if (hwnd !is handle) {

        POINT point;

        point.x = event.x;

        point.y = event.y;

        OS.MapWindowPoints (hwnd, handle, &point, 1);

        event.x = point.x;

        event.y = point.y;

    }

}



void markLayout (bool changed, bool all) {

    /* Do nothing */

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

    checkWidget ();

    auto topHandle_ = topHandle ();

    HWND hwndAbove = cast(HWND) OS.HWND_TOP;

    if (control !is null) {

        if (control.isDisposed ()) error(SWT.ERROR_INVALID_ARGUMENT);

        if (parent !is control.parent) return;

        auto hwnd = control.topHandle ();

        if (hwnd is null || hwnd is topHandle_) return;

        hwndAbove = OS.GetWindow (hwnd, OS.GW_HWNDPREV);

        /*

        * Bug in Windows.  For some reason, when GetWindow ()

        * with GW_HWNDPREV is used to query the previous window

        * in the z-order with the first child, Windows returns

        * the first child instead of NULL.  The fix is to detect

        * this case and move the control to the top.

        */

        if (hwndAbove is null || hwndAbove is hwnd) {

            hwndAbove = cast(HWND) OS.HWND_TOP;

        }

    }

    int flags = OS.SWP_NOSIZE | OS.SWP_NOMOVE | OS.SWP_NOACTIVATE;

    SetWindowPos (topHandle_, hwndAbove, 0, 0, 0, 0, flags);

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

    checkWidget ();

    auto topHandle_ = topHandle ();

    HWND hwndAbove = cast(HWND)OS.HWND_BOTTOM;

    if (control !is null) {

        if (control.isDisposed ()) error(SWT.ERROR_INVALID_ARGUMENT);

        if (parent !is control.parent) return;

        hwndAbove = control.topHandle ();

    } else {

        /*

        * Bug in Windows.  When SetWindowPos() is called

        * with HWND_BOTTOM on a dialog shell, the dialog

        * and the parent are moved to the bottom of the

        * desktop stack.  The fix is to move the dialog

        * to the bottom of the dialog window stack by

        * moving behind the first dialog child.

        */

        Shell shell = getShell ();

        if (this is shell && parent !is null) {

            /*

            * Bug in Windows.  For some reason, when GetWindow ()

            * with GW_HWNDPREV is used to query the previous window

            * in the z-order with the first child, Windows returns

            * the first child instead of NULL.  The fix is to detect

            * this case and do nothing because the control is already

            * at the bottom.

            */

            auto hwndParent = parent.handle;

            auto hwnd = hwndParent;

            hwndAbove = OS.GetWindow (hwnd, OS.GW_HWNDPREV);

            while (hwndAbove !is null && hwndAbove !is hwnd) {

                if (OS.GetWindow (hwndAbove, OS.GW_OWNER) is hwndParent) break;

                hwndAbove = OS.GetWindow (hwnd = hwndAbove, OS.GW_HWNDPREV);

            }

            if (hwndAbove is hwnd) return;

        }

    }

    if (hwndAbove is null || hwndAbove is topHandle_) return;

    int flags = OS.SWP_NOSIZE | OS.SWP_NOMOVE | OS.SWP_NOACTIVATE;

    SetWindowPos (topHandle_, hwndAbove, 0, 0, 0, 0, flags);

}



Accessible new_Accessible (Control control) {

    return Accessible.internal_new_Accessible (this);

}



override GC new_GC (GCData data) {

    return GC.win32_new (this, data);

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

    checkWidget ();

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

    checkWidget ();

    setSize (computeSize (SWT.DEFAULT, SWT.DEFAULT, changed));

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

    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (5, 1)) {

        auto topHandle = topHandle ();

        int bits = OS.GetWindowLong (topHandle, OS.GWL_STYLE);

        if ((bits & OS.WS_VISIBLE) is 0) {

            OS.DefWindowProc (topHandle, OS.WM_SETREDRAW, 1, 0);

        }

        printWidget (topHandle, gc);

        if ((bits & OS.WS_VISIBLE) is 0) {

            OS.DefWindowProc (topHandle, OS.WM_SETREDRAW, 0, 0);

        }

        return true;

    }

    return false;

}



void printWidget (HWND hwnd, GC gc) {

    OS.PrintWindow (hwnd, gc.handle, 0);

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

    checkWidget ();

    redraw (false);

}



void redraw (bool all) {

//  checkWidget ();

    if (!OS.IsWindowVisible (handle)) return;

    static if (OS.IsWinCE) {

        OS.InvalidateRect (handle, null, true);

    } else {

        int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE;

        if (all) flags |= OS.RDW_ALLCHILDREN;

        OS.RedrawWindow (handle, null, null, flags);

    }

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

    checkWidget ();

    if (width <= 0 || height <= 0) return;

    if (!OS.IsWindowVisible (handle)) return;

    RECT rect;

    OS.SetRect (&rect, x, y, x + width, y + height);

    static if (OS.IsWinCE) {

        OS.InvalidateRect (handle, &rect, true);

    } else {

        int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE;

        if (all) flags |= OS.RDW_ALLCHILDREN;

        OS.RedrawWindow (handle, &rect, null, flags);

    }

}



bool redrawChildren () {

    if (!OS.IsWindowVisible (handle)) return false;

    Control control = findBackgroundControl ();

    if (control is null) {

        if ((state & THEME_BACKGROUND) !is 0) {

            if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {

                OS.InvalidateRect (handle, null, true);

                return true;

            }

        }

    } else {

        if (control.backgroundImage !is null) {

            OS.InvalidateRect (handle, null, true);

            return true;

        }

    }

    return false;

}



void register () {

    display.addControl (handle, this);

}



override void releaseHandle () {

    super.releaseHandle ();

    handle = null;

    parent = null;

}



override void releaseParent () {

    parent.removeControl (this);

}



override void releaseWidget () {

    super.releaseWidget ();

    if (OS.IsDBLocale) {

        OS.ImmAssociateContext (handle, null);

    }

    if (toolTipText_ !is null) {

        setToolTipText (getShell (), null);

    }

    toolTipText_ = null;

    if (menu !is null && !menu.isDisposed ()) {

        menu.dispose ();

    }

    backgroundImage = null;

    menu = null;

    cursor = null;

    unsubclass ();

    deregister ();

    layoutData = null;

    if (accessible !is null) {

        accessible.internal_dispose_Accessible ();

    }

    accessible = null;

    region = null;

    font = null;

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

    checkWidget ();

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

    checkWidget ();

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

    checkWidget ();

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

    checkWidget ();

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

    checkWidget ();

    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);

    if (eventTable is null) return;

    eventTable.unhook (SWT.MouseEnter, listener);

    eventTable.unhook (SWT.MouseExit, listener);

    eventTable.unhook (SWT.MouseHover, listener);

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

    checkWidget ();

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

    checkWidget ();

    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);

    if (eventTable is null) return;

    eventTable.unhook (SWT.MouseMove, listener);

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

    checkWidget ();

    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);

    if (eventTable is null) return;

    eventTable.unhook(SWT.Paint, listener);

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



void showWidget (bool visible) {

    auto topHandle_ = topHandle ();

    OS.ShowWindow (topHandle_, visible ? OS.SW_SHOW : OS.SW_HIDE);

    if (handle !is topHandle_) OS.ShowWindow (handle, visible ? OS.SW_SHOW : OS.SW_HIDE);

}



override bool sendFocusEvent (int type) {

    Shell shell = getShell ();



    /*

    * Feature in Windows.  During the processing of WM_KILLFOCUS,

    * when the focus window is queried using GetFocus(), it has

    * already been assigned to the new window.  The fix is to

    * remember the control that is losing or gaining focus and

    * answer it during WM_KILLFOCUS.  If a WM_SETFOCUS occurs

    * during WM_KILLFOCUS, the focus control needs to be updated

    * to the current control.  At any other time, the focus

    * control matches Windows.

    */

    Display display = this.display;

    display.focusEvent = type;

    display.focusControl = this;

    sendEvent (type);

    // widget could be disposed at this point

    display.focusEvent = SWT.None;

    display.focusControl = null;



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

                if (shell !is display.getActiveShell ()) {

                    shell.setActiveControl (null);

                }

                break;

            default:

        }

    }

    return true;

}



void sendMove () {

    sendEvent (SWT.Move);

}



void sendResize () {

    sendEvent (SWT.Resize);

}



void setBackground () {

    Control control = findBackgroundControl ();

    if (control is null) control = this;

    if (control.backgroundImage !is null) {

        Shell shell = getShell ();

        shell.releaseBrushes ();

        setBackgroundImage (control.backgroundImage.handle);

    } else {

        setBackgroundPixel (control.background is -1 ? control.defaultBackground() : control.background);

    }

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

    checkWidget ();

    int pixel = -1;

    if (color !is null) {

        if (color.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);

        pixel = color.handle;

    }

    if (pixel is background) return;

    background = pixel;

    updateBackgroundColor ();

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

    if (image !is null) {

        if (image.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);

        if (image.type !is SWT.BITMAP) error (SWT.ERROR_INVALID_ARGUMENT);

    }

    if (backgroundImage is image) return;

    backgroundImage = image;

    Shell shell = getShell ();

    shell.releaseBrushes ();

    updateBackgroundImage ();

}



void setBackgroundImage (HBITMAP hBitmap) {

    static if (OS.IsWinCE) {

        OS.InvalidateRect (handle, null, true);

    } else {

        int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE;

        OS.RedrawWindow (handle, null, null, flags);

    }

}



void setBackgroundPixel (int pixel) {

    static if (OS.IsWinCE) {

        OS.InvalidateRect (handle, null, true);

    } else {

        int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE;

        OS.RedrawWindow (handle, null, null, flags);

    }

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

    checkWidget ();

    int flags = OS.SWP_NOZORDER | OS.SWP_DRAWFRAME | OS.SWP_NOACTIVATE;

    setBounds (x, y, Math.max (0, width), Math.max (0, height), flags);

}



void setBounds (int x, int y, int width, int height, int flags) {

    setBounds (x, y, width, height, flags, true);

}



void setBounds (int x, int y, int width, int height, int flags, bool defer) {

    if (findImageControl () !is null) {

        if (backgroundImage is null) flags |= OS.SWP_NOCOPYBITS;

    } else {

        if (OS.GetWindow (handle, OS.GW_CHILD) is null) {

            if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {

                if (findThemeControl () !is null) flags |= OS.SWP_NOCOPYBITS;

            }

        }

    }

    auto topHandle_ = topHandle ();

    if (defer && parent !is null) {

        forceResize ();

        if (parent.lpwp !is null) {

            int index = 0;

            auto lpwp = parent.lpwp;

            while (index < lpwp.length) {

                if (lpwp [index] is null) break;

                index ++;

            }

            if (index is lpwp.length) {

                WINDOWPOS* [] newLpwp = new WINDOWPOS* [lpwp.length + 4];

                SimpleType!(WINDOWPOS*).arraycopy (lpwp, 0, newLpwp, 0, lpwp.length);

                parent.lpwp = lpwp = newLpwp;

            }

            WINDOWPOS* wp = new WINDOWPOS;

            wp._hwnd = topHandle_;

            wp.x = x;

            wp.y = y;

            wp.cx = width;

            wp.cy = height;

            wp.flags = flags;

            lpwp [index] = wp;

            return;

        }

    }

    SetWindowPos (topHandle_, null, x, y, width, height, flags);

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

    setBounds (rect.x, rect.y, rect.width, rect.height);

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

    checkWidget ();

    if (capture) {

        OS.SetCapture (handle);

    } else {

        if (OS.GetCapture () is handle) {

            OS.ReleaseCapture ();

        }

    }

}



void setCursor () {

    LPARAM lParam = OS.MAKELPARAM (OS.HTCLIENT, OS.WM_MOUSEMOVE);

    OS.SendMessage (handle, OS.WM_SETCURSOR, handle, lParam);

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

    checkWidget ();

    if (cursor !is null && cursor.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);

    this.cursor = cursor;

    static if (OS.IsWinCE) {

        auto hCursor = cursor !is null ? cursor.handle : 0;

        OS.SetCursor (hCursor);

        return;

    }

    auto hwndCursor = OS.GetCapture ();

    if (hwndCursor is null) {

        POINT pt;

        if (!OS.GetCursorPos (&pt)) return;

        auto hwnd = hwndCursor = OS.WindowFromPoint (pt);

        while (hwnd !is null && hwnd !is handle) {

            hwnd = OS.GetParent (hwnd);

        }

        if (hwnd is null) return;

    }

    Control control = display.getControl (hwndCursor);

    if (control is null) control = this;

    control.setCursor ();

}



void setDefaultFont () {

    auto hFont = display.getSystemFont ().handle;

    OS.SendMessage (handle, OS.WM_SETFONT, hFont, 0);

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

    enableDrag (dragDetect);

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

    checkWidget ();

    /*

    * Feature in Windows.  If the receiver has focus, disabling

    * the receiver causes no window to have focus.  The fix is

    * to assign focus to the first ancestor window that takes

    * focus.  If no window will take focus, set focus to the

    * desktop.

    */

    Control control = null;

    bool fixFocus_ = false;

    if (!enabled) {

        if (display.focusEvent !is SWT.FocusOut) {

            control = display.getFocusControl ();

            fixFocus_ = isFocusAncestor (control);

        }

    }

    enableWidget (enabled);

    if (fixFocus_) fixFocus (control);

}



bool setFixedFocus () {

    if ((style & SWT.NO_FOCUS) !is 0) return false;

    return forceFocus ();

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

    checkWidget ();

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

    checkWidget ();

    HFONT hFont;

    if (font !is null) {

        if (font.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);

        hFont = font.handle;

    }

    this.font = font;

    if (hFont is null) hFont = defaultFont ();

    OS.SendMessage (handle, OS.WM_SETFONT, hFont, 1);

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

    checkWidget ();

    int pixel = -1;

    if (color !is null) {

        if (color.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);

        pixel = color.handle;

    }

    if (pixel is foreground) return;

    foreground = pixel;

    setForegroundPixel (pixel);

}



void setForegroundPixel (int pixel) {

    OS.InvalidateRect (handle, null, true);

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

    checkWidget ();

    this.layoutData = layoutData;

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

public void setLocation (int x, int y) {

    checkWidget ();

    int flags = OS.SWP_NOSIZE | OS.SWP_NOZORDER | OS.SWP_NOACTIVATE;

    /*

    * Feature in WinCE.  The SWP_DRAWFRAME flag for SetWindowPos()

    * causes a WM_SIZE message to be sent even when the SWP_NOSIZE

    * flag is specified.  The fix is to set SWP_DRAWFRAME only when

    * not running on WinCE.

    */

    static if (!OS.IsWinCE) flags |= OS.SWP_DRAWFRAME;

    setBounds (x, y, 0, 0, flags);

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

    setLocation (location.x, location.y);

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

    checkWidget ();

    if (menu !is null) {

        if (menu.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);

        if ((menu.style & SWT.POP_UP) is 0) {

            error (SWT.ERROR_MENU_NOT_POP_UP);

        }

        if (menu.parent !is menuShell ()) {

            error (SWT.ERROR_INVALID_PARENT);

        }

    }

    this.menu = menu;

}



bool setRadioFocus () {

    return false;

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

    checkWidget ();

    /*

     * Feature in Windows.  When WM_SETREDRAW is used to turn

     * off drawing in a widget, it clears the WS_VISIBLE bits

     * and then sets them when redraw is turned back on.  This

     * means that WM_SETREDRAW will make a widget unexpectedly

     * visible.  The fix is to track the visibility state while

     * drawing is turned off and restore it when drawing is

     * turned back on.

     */

    if (drawCount is 0) {

        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);

        if ((bits & OS.WS_VISIBLE) is 0) state |= HIDDEN;

    }

    if (redraw) {

        if (--drawCount is 0) {

            auto topHandle_ = topHandle ();

            OS.SendMessage (topHandle_, OS.WM_SETREDRAW, 1, 0);

            if (handle !is topHandle_) OS.SendMessage (handle, OS.WM_SETREDRAW, 1, 0);

            if ((state & HIDDEN) !is 0) {

                state &= ~HIDDEN;

                OS.ShowWindow (topHandle_, OS.SW_HIDE);

                if (handle !is topHandle_) OS.ShowWindow (handle, OS.SW_HIDE);

            } else {

                static if (OS.IsWinCE) {

                    OS.InvalidateRect (topHandle_, null, true);

                    if (handle !is topHandle_) OS.InvalidateRect (handle, null, true);

                } else {

                    int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE | OS.RDW_ALLCHILDREN;

                    OS.RedrawWindow (topHandle_, null, null, flags);

                }

            }

        }

    } else {

        if (drawCount++ is 0) {

            auto topHandle_ = topHandle ();

            OS.SendMessage (topHandle_, OS.WM_SETREDRAW, 0, 0);

            if (handle !is topHandle_) OS.SendMessage (handle, OS.WM_SETREDRAW, 0, 0);

        }

    }

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

    HRGN hRegion;

    if (region !is null) {

        hRegion = OS.CreateRectRgn (0, 0, 0, 0);

        OS.CombineRgn (hRegion, region.handle, hRegion, OS.RGN_OR);

    }

    OS.SetWindowRgn (handle, hRegion, true);

    this.region = region;

}



bool setSavedFocus () {

    return forceFocus ();

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

    checkWidget ();

    int flags = OS.SWP_NOMOVE | OS.SWP_NOZORDER | OS.SWP_DRAWFRAME | OS.SWP_NOACTIVATE;

    setBounds (0, 0, Math.max (0, width), Math.max (0, height), flags);

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

    setSize (size.x, size.y);

}



bool setTabGroupFocus () {

    return setTabItemFocus ();

}



bool setTabItemFocus () {

    if (!isShowing ()) return false;

    return forceFocus ();

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

    checkWidget ();

    toolTipText_ = string;

    setToolTipText (getShell (), string);

}



void setToolTipText (Shell shell, String string) {

    shell.setToolTipText (handle, string);

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

    checkWidget ();

    if (drawCount !is 0) {

        if (((state & HIDDEN) is 0) is visible) return;

    } else {

        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);

        if (((bits & OS.WS_VISIBLE) !is 0) is visible) return;

    }

    if (visible) {

        sendEvent (SWT.Show);

        if (isDisposed ()) return;

    }



    /*

    * Feature in Windows.  If the receiver has focus, hiding

    * the receiver causes no window to have focus.  The fix is

    * to assign focus to the first ancestor window that takes

    * focus.  If no window will take focus, set focus to the

    * desktop.

    */

    Control control = null;

    bool fixFocus_ = false;

    if (!visible) {

        if (display.focusEvent !is SWT.FocusOut) {

            control = display.getFocusControl ();

            fixFocus_ = isFocusAncestor (control);

        }

    }

    if (drawCount !is 0) {

        state = visible ? state & ~HIDDEN : state | HIDDEN;

    } else {

        showWidget (visible);

        if (isDisposed ()) return;

    }

    if (!visible) {

        sendEvent (SWT.Hide);

        if (isDisposed ()) return;

    }

    if (fixFocus_) fixFocus (control);

}



void sort (int [] items) {

    /* Shell Sort from K&R, pg 108 */

    int length = cast(int)/*64bit*/items.length;

    for (int gap=length/2; gap>0; gap/=2) {

        for (int i=gap; i<length; i++) {

            for (int j=i-gap; j>=0; j-=gap) {

                if (items [j] <= items [j + gap]) {

                    int swap = items [j];

                    items [j] = items [j + gap];

                    items [j + gap] = swap;

                }

            }

        }

    }

}



void subclass () {

    auto oldProc = windowProc ();

    auto newProc = display.windowProc();

    if (oldProc is newProc) return;

    OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, newProc);

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

    POINT pt;

    pt.x = x;  pt.y = y;

    OS.ScreenToClient (handle, &pt);

    return new Point (pt.x, pt.y);

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

    checkWidget ();

    POINT pt;

    pt.x = x;  pt.y = y;

    OS.ClientToScreen (handle, &pt);

    return new Point (pt.x, pt.y);

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

    checkWidget ();

    if (point is null) error (SWT.ERROR_NULL_ARGUMENT);

    return toDisplay (point.x, point.y);

}



HANDLE topHandle () {

    return handle;

}



bool translateAccelerator (MSG* msg) {

    return menuShell ().translateAccelerator (msg);

}



bool translateMnemonic (Event event, Control control) {

    if (control is this) return false;

    if (!isVisible () || !isEnabled ()) return false;

    event.doit = mnemonicMatch (event.character);

    return traverse (event);

}



bool translateMnemonic (MSG* msg) {

    if (msg.wParam < 0x20) return false;

    auto hwnd = msg.hwnd;

    if (OS.GetKeyState (OS.VK_MENU) >= 0) {

        auto code = OS.SendMessage (hwnd, OS.WM_GETDLGCODE, 0, 0);

        if ((code & OS.DLGC_WANTALLKEYS) !is 0) return false;

        if ((code & OS.DLGC_BUTTON) is 0) return false;

    }

    Decorations shell = menuShell ();

    if (shell.isVisible () && shell.isEnabled ()) {

        display.lastAscii = cast(int)/*64bit*/msg.wParam;

        display.lastNull = display.lastDead = false;

        Event event = new Event ();

        event.detail = SWT.TRAVERSE_MNEMONIC;

        if (setKeyState (event, SWT.Traverse, msg.wParam, msg.lParam)) {

            return translateMnemonic (event, null) || shell.translateMnemonic (event, this);

        }

    }

    return false;

}



bool translateTraversal (MSG* msg) {

    auto hwnd = msg.hwnd;

    auto key = msg.wParam;

    if (key is OS.VK_MENU) {

        OS.SendMessage (hwnd, OS.WM_CHANGEUISTATE, OS.UIS_INITIALIZE, 0);

        return false;

    }

    int detail = SWT.TRAVERSE_NONE;

    bool doit = true, all = false;

    bool lastVirtual = false;

    int lastKey = cast(int)/*64bit*/key, lastAscii = 0;

    switch (key) {

        case OS.VK_ESCAPE: {

            all = true;

            lastAscii = 27;

            auto code = OS.SendMessage (hwnd, OS.WM_GETDLGCODE, 0, 0);

            if ((code & OS.DLGC_WANTALLKEYS) !is 0) {

                /*

                * Use DLGC_HASSETSEL to determine that the control

                * is a text widget.  A text widget normally wants

                * all keys except VK_ESCAPE.  If this bit is not

                * set, then assume the control wants all keys,

                * including VK_ESCAPE.

                */

                if ((code & OS.DLGC_HASSETSEL) is 0) doit = false;

            }

            detail = SWT.TRAVERSE_ESCAPE;

            break;

        }

        case OS.VK_RETURN: {

            all = true;

            lastAscii = '\r';

            auto code = OS.SendMessage (hwnd, OS.WM_GETDLGCODE, 0, 0);

            if ((code & OS.DLGC_WANTALLKEYS) !is 0) doit = false;

            detail = SWT.TRAVERSE_RETURN;

            break;

        }

        case OS.VK_TAB: {

            lastAscii = '\t';

            bool next = OS.GetKeyState (OS.VK_SHIFT) >= 0;

            auto code = OS.SendMessage (hwnd, OS.WM_GETDLGCODE, 0, 0);

            if ((code & (OS.DLGC_WANTTAB | OS.DLGC_WANTALLKEYS)) !is 0) {

                /*

                * Use DLGC_HASSETSEL to determine that the control is a

                * text widget.  If the control is a text widget, then

                * Ctrl+Tab and Shift+Tab should traverse out of the widget.

                * If the control is not a text widget, the correct behavior

                * is to give every character, including Tab, Ctrl+Tab and

                * Shift+Tab to the control.

                */

                if ((code & OS.DLGC_HASSETSEL) !is 0) {

                    if (next && OS.GetKeyState (OS.VK_CONTROL) >= 0) {

                        doit = false;

                    }

                } else {

                    doit = false;

                }

            }

            detail = next ? SWT.TRAVERSE_TAB_NEXT : SWT.TRAVERSE_TAB_PREVIOUS;

            break;

        }

        case OS.VK_UP:

        case OS.VK_LEFT:

        case OS.VK_DOWN:

        case OS.VK_RIGHT: {

            /*

            * On WinCE SP there is no tab key.  Focus is assigned

            * using the VK_UP and VK_DOWN keys, not with VK_LEFT

            * or VK_RIGHT.

            */

            if (OS.IsSP) {

                if (key is OS.VK_LEFT || key is OS.VK_RIGHT) return false;

            }

            lastVirtual = true;

            auto code = OS.SendMessage (hwnd, OS.WM_GETDLGCODE, 0, 0);

            if ((code & (OS.DLGC_WANTARROWS /*| OS.DLGC_WANTALLKEYS*/)) !is 0) doit = false;

            bool next = key is OS.VK_DOWN || key is OS.VK_RIGHT;

            if (parent !is null && (parent.style & SWT.MIRRORED) !is 0) {

                if (key is OS.VK_LEFT || key is OS.VK_RIGHT) next = !next;

            }

            detail = next ? SWT.TRAVERSE_ARROW_NEXT : SWT.TRAVERSE_ARROW_PREVIOUS;

            break;

        }

        case OS.VK_PRIOR:

        case OS.VK_NEXT: {

            all = true;

            lastVirtual = true;

            if (OS.GetKeyState (OS.VK_CONTROL) >= 0) return false;

            auto code = OS.SendMessage (hwnd, OS.WM_GETDLGCODE, 0, 0);

            if ((code & OS.DLGC_WANTALLKEYS) !is 0) {

                /*

                * Use DLGC_HASSETSEL to determine that the control is a

                * text widget.  If the control is a text widget, then

                * Ctrl+PgUp and Ctrl+PgDn should traverse out of the widget.

                */

                if ((code & OS.DLGC_HASSETSEL) is 0) doit = false;

            }

            detail = key is OS.VK_PRIOR ? SWT.TRAVERSE_PAGE_PREVIOUS : SWT.TRAVERSE_PAGE_NEXT;

            break;

        }

        default:

            return false;

    }

    Event event = new Event ();

    event.doit = doit;

    event.detail = detail;

    display.lastKey = lastKey;

    display.lastAscii = lastAscii;

    display.lastVirtual = lastVirtual;

    display.lastNull = display.lastDead = false;

    if (!setKeyState (event, SWT.Traverse, msg.wParam, msg.lParam)) return false;

    Shell shell = getShell ();

    Control control = this;

    do {

        if (control.traverse (event)) {

            OS.SendMessage (hwnd, OS.WM_CHANGEUISTATE, OS.UIS_INITIALIZE, 0);

            return true;

        }

        if (!event.doit && control.hooks (SWT.Traverse)) return false;

        if (control is shell) return false;

        control = control.parent;

    } while (all && control !is null);

    return false;

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



bool traverseEscape () {

    return false;

}



bool traverseGroup (bool next) {

    Control root = computeTabRoot ();

    Control group = computeTabGroup ();

    Control [] list = root.computeTabList ();

    int length = cast(int)/*64bit*/list.length;

    int index = 0;

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

    int start = index, offset = (next) ? 1 : -1;

    while ((index = ((index + offset + length) % length)) !is start) {

        Control control = list [index];

        if (!control.isDisposed () && control.setTabGroupFocus ()) {

            return true;

        }

    }

    if (group.isDisposed ()) return false;

    return group.setTabGroupFocus ();

}



bool traverseItem (bool next) {

    Control [] children = parent._getChildren ();

    int length = cast(int)/*64bit*/children.length;

    int index = 0;

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

    int start = index, offset = (next) ? 1 : -1;

    while ((index = (index + offset + length) % length) !is start) {

        Control child = children [index];

        if (!child.isDisposed () && child.isTabItem ()) {

            if (child.setTabItemFocus ()) return true;

        }

    }

    return false;

}



bool traverseMnemonic (char key) {

    if (mnemonicHit (key)) {

        OS.SendMessage (handle, OS.WM_CHANGEUISTATE, OS.UIS_INITIALIZE, 0);

        return true;

    }

    return false;

}



bool traversePage (bool next) {

    return false;

}



bool traverseReturn () {

    return false;

}



void unsubclass () {

    auto newProc = windowProc ();

    auto oldProc = display.windowProc;

    if (oldProc is newProc) return;

    OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, newProc);

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

    update (false);

}



void update (bool all) {

//  checkWidget ();

    static if (OS.IsWinCE) {

        OS.UpdateWindow (handle);

    } else {

        int flags = OS.RDW_UPDATENOW;

        if (all) flags |= OS.RDW_ALLCHILDREN;

        OS.RedrawWindow (handle, null, null, flags);

    }

}



void updateBackgroundColor () {

    Control control = findBackgroundControl ();

    if (control is null) control = this;

    setBackgroundPixel (control.background);

}



void updateBackgroundImage () {

    Control control = findBackgroundControl ();

    Image image = control !is null ? control.backgroundImage : backgroundImage;

    setBackgroundImage (image !is null ? image.handle : null);

}



void updateBackgroundMode () {

    int oldState = state & PARENT_BACKGROUND;

    checkBackground ();

    if (oldState !is (state & PARENT_BACKGROUND)) {

        setBackground ();

    }

}



void updateFont (Font oldFont, Font newFont) {

    if (getFont () ==/*eq*/oldFont ) setFont (newFont);

}



void updateImages () {

    /* Do nothing */

}



void updateLayout (bool resize, bool all) {

    /* Do nothing */

}



CREATESTRUCT* widgetCreateStruct () {

    return null;

}



int widgetExtStyle () {

    int bits = 0;

    if (!OS.IsPPC) {

        if ((style & SWT.BORDER) !is 0) bits |= OS.WS_EX_CLIENTEDGE;

    }

//  if ((style & SWT.BORDER) !is 0) {

//      if ((style & SWT.FLAT) is 0) bits |= OS.WS_EX_CLIENTEDGE;

//  }

    /*

    * Feature in Windows NT.  When CreateWindowEx() is called with

    * WS_EX_LAYOUTRTL or WS_EX_NOINHERITLAYOUT, CreateWindowEx()

    * fails to create the HWND. The fix is to not use these bits.

    */

    if (OS.WIN32_VERSION < OS.VERSION (4, 10)) {

        return bits;

    }

    bits |= OS.WS_EX_NOINHERITLAYOUT;

    if ((style & SWT.RIGHT_TO_LEFT) !is 0) bits |= OS.WS_EX_LAYOUTRTL;

    return bits;

}



HWND widgetParent () {

    return parent.handle;

}



int widgetStyle () {

    /* Force clipping of siblings by setting WS_CLIPSIBLINGS */

    int bits = OS.WS_CHILD | OS.WS_VISIBLE | OS.WS_CLIPSIBLINGS;

//  if ((style & SWT.BORDER) !is 0) {

//      if ((style & SWT.FLAT) !is 0) bits |= OS.WS_BORDER;

//  }

    if (OS.IsPPC) {

        if ((style & SWT.BORDER) !is 0) bits |= OS.WS_BORDER;

    }

    return bits;



    /*

    * This code is intentionally commented.  When clipping

    * of both siblings and children is not enforced, it is

    * possible for application code to draw outside of the

    * control.

    */

//  int bits = OS.WS_CHILD | OS.WS_VISIBLE;

//  if ((style & SWT.CLIP_SIBLINGS) !is 0) bits |= OS.WS_CLIPSIBLINGS;

//  if ((style & SWT.CLIP_CHILDREN) !is 0) bits |= OS.WS_CLIPCHILDREN;

//  return bits;

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

    if (parent is null) error (SWT.ERROR_NULL_ARGUMENT);

    if (parent.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);

    if (this.parent is parent) return true;

    if (!isReparentable ()) return false;

    releaseParent ();

    Shell newShell = parent.getShell (), oldShell = getShell ();

    Decorations newDecorations = parent.menuShell (), oldDecorations = menuShell ();

    if (oldShell !is newShell || oldDecorations !is newDecorations) {

        Menu [] menus = oldShell.findMenus (this);

        fixChildren (newShell, oldShell, newDecorations, oldDecorations, menus);

    }

    auto topHandle_ = topHandle ();

    if (OS.SetParent (topHandle_, parent.handle) is null) return false;

    this.parent = parent;

    int flags = OS.SWP_NOSIZE | OS.SWP_NOMOVE | OS.SWP_NOACTIVATE;

    SetWindowPos (topHandle_, cast(HWND)OS.HWND_BOTTOM, 0, 0, 0, 0, flags);

    return true;

}



abstract String windowClass ();



abstract ptrdiff_t windowProc ();



.LRESULT windowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {

    LRESULT result = null;

    switch (msg) {

        case OS.WM_ACTIVATE:            result = WM_ACTIVATE (wParam, lParam); break;

        case OS.WM_CAPTURECHANGED:      result = WM_CAPTURECHANGED (wParam, lParam); break;

        case OS.WM_CHANGEUISTATE:       result = WM_CHANGEUISTATE (wParam, lParam); break;

        case OS.WM_CHAR:                result = WM_CHAR (wParam, lParam); break;

        case OS.WM_CLEAR:               result = WM_CLEAR (wParam, lParam); break;

        case OS.WM_CLOSE:               result = WM_CLOSE (wParam, lParam); break;

        case OS.WM_COMMAND:             result = WM_COMMAND (wParam, lParam); break;

        case OS.WM_CONTEXTMENU:         result = WM_CONTEXTMENU (wParam, lParam); break;

        case OS.WM_CTLCOLORBTN:

        case OS.WM_CTLCOLORDLG:

        case OS.WM_CTLCOLOREDIT:

        case OS.WM_CTLCOLORLISTBOX:

        case OS.WM_CTLCOLORMSGBOX:

        case OS.WM_CTLCOLORSCROLLBAR:

        case OS.WM_CTLCOLORSTATIC:      result = WM_CTLCOLOR (wParam, lParam); break;

        case OS.WM_CUT:                 result = WM_CUT (wParam, lParam); break;

        case OS.WM_DESTROY:             result = WM_DESTROY (wParam, lParam); break;

        case OS.WM_DRAWITEM:            result = WM_DRAWITEM (wParam, lParam); break;

        case OS.WM_ENDSESSION:          result = WM_ENDSESSION (wParam, lParam); break;

        case OS.WM_ENTERIDLE:           result = WM_ENTERIDLE (wParam, lParam); break;

        case OS.WM_ERASEBKGND:          result = WM_ERASEBKGND (wParam, lParam); break;

        case OS.WM_GETDLGCODE:          result = WM_GETDLGCODE (wParam, lParam); break;

        case OS.WM_GETFONT:             result = WM_GETFONT (wParam, lParam); break;

        case OS.WM_GETOBJECT:           result = WM_GETOBJECT (wParam, lParam); break;

        case OS.WM_GETMINMAXINFO:       result = WM_GETMINMAXINFO (wParam, lParam); break;

        case OS.WM_HELP:                result = WM_HELP (wParam, lParam); break;

        case OS.WM_HSCROLL:             result = WM_HSCROLL (wParam, lParam); break;

        case OS.WM_IME_CHAR:            result = WM_IME_CHAR (wParam, lParam); break;

        case OS.WM_IME_COMPOSITION:     result = WM_IME_COMPOSITION (wParam, lParam); break;

        case OS.WM_IME_COMPOSITION_START:   result = WM_IME_COMPOSITION_START (wParam, lParam); break;

        case OS.WM_IME_ENDCOMPOSITION:  result = WM_IME_ENDCOMPOSITION (wParam, lParam); break;

        case OS.WM_INITMENUPOPUP:       result = WM_INITMENUPOPUP (wParam, lParam); break;

        case OS.WM_INPUTLANGCHANGE:     result = WM_INPUTLANGCHANGE (wParam, lParam); break;

        case OS.WM_HOTKEY:              result = WM_HOTKEY (wParam, lParam); break;

        case OS.WM_KEYDOWN:             result = WM_KEYDOWN (wParam, lParam); break;

        case OS.WM_KEYUP:               result = WM_KEYUP (wParam, lParam); break;

        case OS.WM_KILLFOCUS:           result = WM_KILLFOCUS (wParam, lParam); break;

        case OS.WM_LBUTTONDBLCLK:       result = WM_LBUTTONDBLCLK (wParam, lParam); break;

        case OS.WM_LBUTTONDOWN:         result = WM_LBUTTONDOWN (wParam, lParam); break;

        case OS.WM_LBUTTONUP:           result = WM_LBUTTONUP (wParam, lParam); break;

        case OS.WM_MBUTTONDBLCLK:       result = WM_MBUTTONDBLCLK (wParam, lParam); break;

        case OS.WM_MBUTTONDOWN:         result = WM_MBUTTONDOWN (wParam, lParam); break;

        case OS.WM_MBUTTONUP:           result = WM_MBUTTONUP (wParam, lParam); break;

        case OS.WM_MEASUREITEM:         result = WM_MEASUREITEM (wParam, lParam); break;

        case OS.WM_MENUCHAR:            result = WM_MENUCHAR (wParam, lParam); break;

        case OS.WM_MENUSELECT:          result = WM_MENUSELECT (wParam, lParam); break;

        case OS.WM_MOUSEACTIVATE:       result = WM_MOUSEACTIVATE (wParam, lParam); break;

        case OS.WM_MOUSEHOVER:          result = WM_MOUSEHOVER (wParam, lParam); break;

        case OS.WM_MOUSELEAVE:          result = WM_MOUSELEAVE (wParam, lParam); break;

        case OS.WM_MOUSEMOVE:           result = WM_MOUSEMOVE (wParam, lParam); break;

        case OS.WM_MOUSEWHEEL:          result = WM_MOUSEWHEEL (wParam, lParam); break;

        case OS.WM_MOVE:                result = WM_MOVE (wParam, lParam); break;

        case OS.WM_NCACTIVATE:          result = WM_NCACTIVATE (wParam, lParam); break;

        case OS.WM_NCCALCSIZE:          result = WM_NCCALCSIZE (wParam, lParam); break;

        case OS.WM_NCHITTEST:           result = WM_NCHITTEST (wParam, lParam); break;

        case OS.WM_NCLBUTTONDOWN:       result = WM_NCLBUTTONDOWN (wParam, lParam); break;

        case OS.WM_NCPAINT:             result = WM_NCPAINT (wParam, lParam); break;

        case OS.WM_NOTIFY:              result = WM_NOTIFY (wParam, lParam); break;

        case OS.WM_PAINT:               result = WM_PAINT (wParam, lParam); break;

        case OS.WM_PALETTECHANGED:      result = WM_PALETTECHANGED (wParam, lParam); break;

        case OS.WM_PARENTNOTIFY:        result = WM_PARENTNOTIFY (wParam, lParam); break;

        case OS.WM_PASTE:               result = WM_PASTE (wParam, lParam); break;

        case OS.WM_PRINT:               result = WM_PRINT (wParam, lParam); break;

        case OS.WM_PRINTCLIENT:         result = WM_PRINTCLIENT (wParam, lParam); break;

        case OS.WM_QUERYENDSESSION:     result = WM_QUERYENDSESSION (wParam, lParam); break;

        case OS.WM_QUERYNEWPALETTE:     result = WM_QUERYNEWPALETTE (wParam, lParam); break;

        case OS.WM_QUERYOPEN:           result = WM_QUERYOPEN (wParam, lParam); break;

        case OS.WM_RBUTTONDBLCLK:       result = WM_RBUTTONDBLCLK (wParam, lParam); break;

        case OS.WM_RBUTTONDOWN:         result = WM_RBUTTONDOWN (wParam, lParam); break;

        case OS.WM_RBUTTONUP:           result = WM_RBUTTONUP (wParam, lParam); break;

        case OS.WM_SETCURSOR:           result = WM_SETCURSOR (wParam, lParam); break;

        case OS.WM_SETFOCUS:            result = WM_SETFOCUS (wParam, lParam); break;

        case OS.WM_SETFONT:             result = WM_SETFONT (wParam, lParam); break;

        case OS.WM_SETTINGCHANGE:       result = WM_SETTINGCHANGE (wParam, lParam); break;

        case OS.WM_SETREDRAW:           result = WM_SETREDRAW (wParam, lParam); break;

        case OS.WM_SHOWWINDOW:          result = WM_SHOWWINDOW (wParam, lParam); break;

        case OS.WM_SIZE:                result = WM_SIZE (wParam, lParam); break;

        case OS.WM_SYSCHAR:             result = WM_SYSCHAR (wParam, lParam); break;

        case OS.WM_SYSCOLORCHANGE:      result = WM_SYSCOLORCHANGE (wParam, lParam); break;

        case OS.WM_SYSCOMMAND:          result = WM_SYSCOMMAND (wParam, lParam); break;

        case OS.WM_SYSKEYDOWN:          result = WM_SYSKEYDOWN (wParam, lParam); break;

        case OS.WM_SYSKEYUP:            result = WM_SYSKEYUP (wParam, lParam); break;

        case OS.WM_TIMER:               result = WM_TIMER (wParam, lParam); break;

        case OS.WM_UNDO:                result = WM_UNDO (wParam, lParam); break;

        case OS.WM_UPDATEUISTATE:       result = WM_UPDATEUISTATE (wParam, lParam); break;

        case OS.WM_VSCROLL:             result = WM_VSCROLL (wParam, lParam); break;

        case OS.WM_WINDOWPOSCHANGED:    result = WM_WINDOWPOSCHANGED (wParam, lParam); break;

        case OS.WM_WINDOWPOSCHANGING:   result = WM_WINDOWPOSCHANGING (wParam, lParam); break;

        case OS.WM_XBUTTONDBLCLK:       result = WM_XBUTTONDBLCLK (wParam, lParam); break;

        case OS.WM_XBUTTONDOWN:         result = WM_XBUTTONDOWN (wParam, lParam); break;

        case OS.WM_XBUTTONUP:           result = WM_XBUTTONUP (wParam, lParam); break;

        default:

    }

    if (result !is null) return result.value;

    return callWindowProc (hwnd, msg, wParam, lParam);

}



LRESULT WM_ACTIVATE (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_CAPTURECHANGED (WPARAM wParam, LPARAM lParam) {

    return wmCaptureChanged (handle, wParam, lParam);

}



LRESULT WM_CHANGEUISTATE (WPARAM wParam, LPARAM lParam) {

    if ((state & IGNORE_WM_CHANGEUISTATE) !is 0) return LRESULT.ZERO;

    return null;

}



LRESULT WM_CHAR (WPARAM wParam, LPARAM lParam) {

    return wmChar (handle, wParam, lParam);

}



LRESULT WM_CLEAR (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_CLOSE (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_COMMAND (WPARAM wParam, LPARAM lParam) {

    /*

    * When the WM_COMMAND message is sent from a

    * menu, the HWND parameter in LPARAM is zero.

    */

    if (lParam is 0) {

        Decorations shell = menuShell ();

        if (shell.isEnabled ()) {

            int id = OS.LOWORD (wParam);

            MenuItem item = display.getMenuItem (id);

            if (item !is null && item.isEnabled ()) {

                return item.wmCommandChild (wParam, lParam);

            }

        }

        return null;

    }

    Control control = display.getControl (cast(HANDLE)lParam);

    if (control is null) return null;

    return control.wmCommandChild (wParam, lParam);

}



LRESULT WM_CONTEXTMENU (WPARAM wParam, LPARAM lParam) {

    return wmContextMenu (handle, wParam, lParam);

}



LRESULT WM_CTLCOLOR (WPARAM wParam, LPARAM lParam) {

    auto hPalette = display.hPalette;

    if (hPalette !is null) {

        OS.SelectPalette ( cast(HPALETTE)wParam, hPalette, false);

        OS.RealizePalette (cast(HPALETTE)wParam);

    }

    Control control = display.getControl (cast(HANDLE)lParam);

    if (control is null) return null;

    return control.wmColorChild (wParam, lParam);

}



LRESULT WM_CUT (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_DESTROY (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_DRAWITEM (WPARAM wParam, LPARAM lParam) {

    DRAWITEMSTRUCT* struct_ = cast(DRAWITEMSTRUCT*)lParam;

    if (struct_.CtlType is OS.ODT_MENU) {

        MenuItem item = display.getMenuItem (struct_.itemID);

        if (item is null) return null;

        return item.wmDrawChild (wParam, lParam);

    }

    Control control = display.getControl (struct_.hwndItem);

    if (control is null) return null;

    return control.wmDrawChild (wParam, lParam);

}



LRESULT WM_ENDSESSION (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_ENTERIDLE (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_ERASEBKGND (WPARAM wParam, LPARAM lParam) {

    if ((state & DRAW_BACKGROUND) !is 0) {

        if (findImageControl () !is null) return LRESULT.ONE;

    }

    if ((state & THEME_BACKGROUND) !is 0) {

        if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {

            if (findThemeControl () !is null) return LRESULT.ONE;

        }

    }

    return null;

}



LRESULT WM_GETDLGCODE (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_GETFONT (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_GETOBJECT (WPARAM wParam, LPARAM lParam) {

    if (accessible !is null) {

        auto result = accessible.internal_WM_GETOBJECT (wParam, lParam);

        if (result !is 0) return new LRESULT (result);

    }

    return null;

}



LRESULT WM_GETMINMAXINFO (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_HOTKEY (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_HELP (WPARAM wParam, LPARAM lParam) {

    static if (OS.IsWinCE) return null;

    HELPINFO* lphi = cast(HELPINFO*)lParam;

    Decorations shell = menuShell ();

    if (!shell.isEnabled ()) return null;

    if (lphi.iContextType is OS.HELPINFO_MENUITEM) {

        MenuItem item = display.getMenuItem (lphi.iCtrlId);

        if (item !is null && item.isEnabled ()) {

            Widget widget = null;

            if (item.hooks (SWT.Help)) {

                widget = item;

            } else {

                Menu menu = item.parent;

                if (menu.hooks (SWT.Help)) widget = menu;

            }

            if (widget !is null) {

                auto hwndShell = shell.handle;

                OS.SendMessage (hwndShell, OS.WM_CANCELMODE, 0, 0);

                widget.postEvent (SWT.Help);

                return LRESULT.ONE;

            }

        }

        return null;

    }

    if (hooks (SWT.Help)) {

        postEvent (SWT.Help);

        return LRESULT.ONE;

    }

    return null;

}



LRESULT WM_HSCROLL (WPARAM wParam, LPARAM lParam) {

    Control control = display.getControl (cast(HANDLE)lParam);

    if (control is null) return null;

    return control.wmScrollChild (wParam, lParam);

}



LRESULT WM_IME_CHAR (WPARAM wParam, LPARAM lParam) {

    return wmIMEChar (handle, wParam, lParam);

}



LRESULT WM_IME_COMPOSITION (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_IME_COMPOSITION_START (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_IME_ENDCOMPOSITION (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_INITMENUPOPUP (WPARAM wParam, LPARAM lParam) {



    /* Ignore WM_INITMENUPOPUP for an accelerator */

    if (display.accelKeyHit) return null;



    /*

    * If the high order word of LPARAM is non-zero,

    * the menu is the system menu and we can ignore

    * WPARAM.  Otherwise, use WPARAM to find the menu.

    */

    Shell shell = getShell ();

    Menu oldMenu = shell.activeMenu, newMenu = null;

    if (OS.HIWORD (lParam) is 0) {

        newMenu = menuShell ().findMenu (cast(HANDLE)wParam);

        if (newMenu !is null) newMenu.update ();

    }

    Menu menu = newMenu;

    while (menu !is null && menu !is oldMenu) {

        menu = menu.getParentMenu ();

    }

    if (menu is null) {

        menu = shell.activeMenu;

        while (menu !is null) {

            /*

            * It is possible (but unlikely), that application

            * code could have disposed the widget in the hide

            * event.  If this happens, stop searching up the

            * ancestor list because there is no longer a link

            * to follow.

            */

            menu.sendEvent (SWT.Hide);

            if (menu.isDisposed ()) break;

            menu = menu.getParentMenu ();

            Menu ancestor = newMenu;

            while (ancestor !is null && ancestor !is menu) {

                ancestor = ancestor.getParentMenu ();

            }

            if (ancestor !is null) break;

        }

    }



    /*

    * The shell and the new menu may be disposed because of

    * sending the hide event to the ancestor menus but setting

    * a field to null in a disposed shell is not harmful.

    */

    if (newMenu !is null && newMenu.isDisposed ()) newMenu = null;

    shell.activeMenu = newMenu;



    /* Send the show event */

    if (newMenu !is null && newMenu !is oldMenu) {

        newMenu.sendEvent (SWT.Show);

        // widget could be disposed at this point

    }

    return null;

}



LRESULT WM_INPUTLANGCHANGE (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_KEYDOWN (WPARAM wParam, LPARAM lParam) {

    return wmKeyDown (handle, wParam, lParam);

}



LRESULT WM_KEYUP (WPARAM wParam, LPARAM lParam) {

    return wmKeyUp (handle, wParam, lParam);

}



LRESULT WM_KILLFOCUS (WPARAM wParam, LPARAM lParam) {

    return wmKillFocus (handle, wParam, lParam);

}



LRESULT WM_LBUTTONDBLCLK (WPARAM wParam, LPARAM lParam) {

    return wmLButtonDblClk (handle, wParam, lParam);

}



LRESULT WM_LBUTTONDOWN (WPARAM wParam, LPARAM lParam) {

    return wmLButtonDown (handle, wParam, lParam);

}



LRESULT WM_LBUTTONUP (WPARAM wParam, LPARAM lParam) {

    return wmLButtonUp (handle, wParam, lParam);

}



LRESULT WM_MBUTTONDBLCLK (WPARAM wParam, LPARAM lParam) {

    return wmMButtonDblClk (handle, wParam, lParam);

}



LRESULT WM_MBUTTONDOWN (WPARAM wParam, LPARAM lParam) {

    return wmMButtonDown (handle, wParam, lParam);

}



LRESULT WM_MBUTTONUP (WPARAM wParam, LPARAM lParam) {

    return wmMButtonUp (handle, wParam, lParam);

}



LRESULT WM_MEASUREITEM (WPARAM wParam, LPARAM lParam) {

    MEASUREITEMSTRUCT* struct_ = cast(MEASUREITEMSTRUCT*)lParam;

    if (struct_.CtlType is OS.ODT_MENU) {

        MenuItem item = display.getMenuItem (struct_.itemID);

        if (item is null) return null;

        return item.wmMeasureChild (wParam, lParam);

    }

    auto hwnd = OS.GetDlgItem (handle, struct_.CtlID);

    Control control = display.getControl (hwnd);

    if (control is null) return null;

    return control.wmMeasureChild (wParam, lParam);

}



LRESULT WM_MENUCHAR (WPARAM wParam, LPARAM lParam) {

    /*

    * Feature in Windows.  When the user types Alt+<key>

    * and <key> does not match a mnemonic in the System

    * menu or the menu bar, Windows beeps.  This beep is

    * unexpected and unwanted by applications that look

    * for Alt+<key>.  The fix is to detect the case and

    * stop Windows from beeping by closing the menu.

    */

    int type = OS.HIWORD (wParam);

    if (type is 0 || type is OS.MF_SYSMENU) {

        display.mnemonicKeyHit = false;

        return new LRESULT (OS.MAKELRESULT (0, OS.MNC_CLOSE));

    }

    return null;

}



LRESULT WM_MENUSELECT (WPARAM wParam, LPARAM lParam) {

    int code = OS.HIWORD (wParam);

    Shell shell = getShell ();

    if (code is 0xFFFF && lParam is 0) {

        Menu menu = shell.activeMenu;

        while (menu !is null) {

            /*

            * When the user cancels any menu that is not the

            * menu bar, assume a mnemonic key was pressed to open

            * the menu from WM_SYSCHAR.  When the menu was invoked

            * using the mouse, this assumption is wrong but not

            * harmful.  This variable is only used in WM_SYSCHAR

            * and WM_SYSCHAR is only sent after the user has pressed

            * a mnemonic.

            */

            display.mnemonicKeyHit = true;

            /*

            * It is possible (but unlikely), that application

            * code could have disposed the widget in the hide

            * event.  If this happens, stop searching up the

            * parent list because there is no longer a link

            * to follow.

            */

            menu.sendEvent (SWT.Hide);

            if (menu.isDisposed ()) break;

            menu = menu.getParentMenu ();

        }

        /*

        * The shell may be disposed because of sending the hide

        * event to the last active menu menu but setting a field

        * to null in a destroyed widget is not harmful.

        */

        shell.activeMenu = null;

        return null;

    }

    if ((code & OS.MF_SYSMENU) !is 0) return null;

    if ((code & OS.MF_HILITE) !is 0) {

        MenuItem item = null;

        Decorations menuShell = menuShell ();

        if ((code & OS.MF_POPUP) !is 0) {

            int index = OS.LOWORD (wParam);

            MENUITEMINFO info;

            info.cbSize = OS.MENUITEMINFO_sizeof;

            info.fMask = OS.MIIM_SUBMENU;

            if (OS.GetMenuItemInfo (cast(HANDLE)lParam, index, true, &info)) {

                Menu newMenu = menuShell.findMenu (info.hSubMenu);

                if (newMenu !is null) item = newMenu.cascade;

            }

        } else {

            Menu newMenu = menuShell.findMenu (cast(HANDLE)lParam);

            if (newMenu !is null) {

                int id = OS.LOWORD (wParam);

                item = display.getMenuItem (id);

            }

            Menu oldMenu = shell.activeMenu;

            if (oldMenu !is null) {

                Menu ancestor = oldMenu;

                while (ancestor !is null && ancestor !is newMenu) {

                    ancestor = ancestor.getParentMenu ();

                }

                if (ancestor is newMenu) {

                    ancestor = oldMenu;

                    while (ancestor !is newMenu) {

                        /*

                        * It is possible (but unlikely), that application

                        * code could have disposed the widget in the hide

                        * event or the item about to be armed.  If this

                        * happens, stop searching up the ancestor list

                        * because there is no longer a link to follow.

                        */

                        ancestor.sendEvent (SWT.Hide);

                        if (ancestor.isDisposed ()) break;

                        ancestor = ancestor.getParentMenu ();

                        if (ancestor is null) break;

                    }

                    /*

                    * The shell and/or the item could be disposed when

                    * processing hide events from above.  If this happens,

                    * ensure that the shell is not accessed and that no

                    * arm event is sent to the item.

                    */

                    if (!shell.isDisposed ()) {

                        if (newMenu !is null && newMenu.isDisposed ()) {

                            newMenu = null;

                        }

                        shell.activeMenu = newMenu;

                    }

                    if (item !is null && item.isDisposed ()) item = null;

                }

            }

        }

        if (item !is null) item.sendEvent (SWT.Arm);

    }

    return null;

}



LRESULT WM_MOUSEACTIVATE (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_MOUSEHOVER (WPARAM wParam, LPARAM lParam) {

    return wmMouseHover (handle, wParam, lParam);

}



LRESULT WM_MOUSELEAVE (WPARAM wParam, LPARAM lParam) {

    if (OS.COMCTL32_MAJOR >= 6) getShell ().fixToolTip ();

    return wmMouseLeave (handle, wParam, lParam);

}



LRESULT WM_MOUSEMOVE (WPARAM wParam, LPARAM lParam) {

    return wmMouseMove (handle, wParam, lParam);

}



LRESULT WM_MOUSEWHEEL (WPARAM wParam, LPARAM lParam) {

    return wmMouseWheel (handle, wParam, lParam);

}



LRESULT WM_MOVE (WPARAM wParam, LPARAM lParam) {

    state |= MOVE_OCCURRED;

    if (findImageControl () !is null) {

        if (this !is getShell ()) redrawChildren ();

    } else {

        if ((state & THEME_BACKGROUND) !is 0) {

            if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {

                if (OS.IsWindowVisible (handle)) {

                    if (findThemeControl () !is null) redrawChildren ();

                }

            }

        }

    }

    if ((state & MOVE_DEFERRED) is 0) sendEvent (SWT.Move);

    // widget could be disposed at this point

    return null;

}



LRESULT WM_NCACTIVATE (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_NCCALCSIZE (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_NCHITTEST (WPARAM wParam, LPARAM lParam) {

    if (!OS.IsWindowEnabled (handle)) return null;

    if (!isActive ()) return new LRESULT (OS.HTTRANSPARENT);

    return null;

}



LRESULT WM_NCLBUTTONDOWN (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_NCPAINT (WPARAM wParam, LPARAM lParam) {

    return wmNCPaint (handle, wParam, lParam);

}



LRESULT WM_NOTIFY (WPARAM wParam, LPARAM lParam) {

    NMHDR* hdr = cast(NMHDR*)lParam;

    return wmNotify (hdr, wParam, lParam);

}



LRESULT WM_PAINT (WPARAM wParam, LPARAM lParam) {

    return wmPaint (handle, wParam, lParam);

}



LRESULT WM_PALETTECHANGED (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_PARENTNOTIFY (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_PASTE (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_PRINT (WPARAM wParam, LPARAM lParam) {

    return wmPrint (handle, wParam, lParam);

}



LRESULT WM_PRINTCLIENT (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_QUERYENDSESSION (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_QUERYNEWPALETTE (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_QUERYOPEN (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_RBUTTONDBLCLK (WPARAM wParam, LPARAM lParam) {

    return wmRButtonDblClk (handle, wParam, lParam);

}



LRESULT WM_RBUTTONDOWN (WPARAM wParam, LPARAM lParam) {

    return wmRButtonDown (handle, wParam, lParam);

}



LRESULT WM_RBUTTONUP (WPARAM wParam, LPARAM lParam) {

    return wmRButtonUp (handle, wParam, lParam);

}



LRESULT WM_SETCURSOR (WPARAM wParam, LPARAM lParam) {

    int hitTest = cast(short) OS.LOWORD (lParam);

    if (hitTest is OS.HTCLIENT) {

        Control control = display.getControl (cast(HANDLE)wParam);

        if (control is null) return null;

        Cursor cursor = control.findCursor ();

        if (cursor !is null) {

            OS.SetCursor (cursor.handle);

            return LRESULT.ONE;

        }

    }

    return null;

}



LRESULT WM_SETFOCUS (WPARAM wParam, LPARAM lParam) {

    return wmSetFocus (handle, wParam, lParam);

}



LRESULT WM_SETTINGCHANGE (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_SETFONT (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_SETREDRAW (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_SHOWWINDOW (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {

    state |= RESIZE_OCCURRED;

    if ((state & RESIZE_DEFERRED) is 0) sendEvent (SWT.Resize);

    // widget could be disposed at this point

    return null;

}



LRESULT WM_SYSCHAR (WPARAM wParam, LPARAM lParam) {

    return wmSysChar (handle, wParam, lParam);

}



LRESULT WM_SYSCOLORCHANGE (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_SYSCOMMAND (WPARAM wParam, LPARAM lParam) {

    /*

    * Check to see if the command is a system command or

    * a user menu item that was added to the System menu.

    * When a user item is added to the System menu,

    * WM_SYSCOMMAND must always return zero.

    *

    * NOTE: This is undocumented.

    */

    if ((wParam & 0xF000) is 0) {

        Decorations shell = menuShell ();

        if (shell.isEnabled ()) {

            MenuItem item = display.getMenuItem (OS.LOWORD (wParam));

            if (item !is null) item.wmCommandChild (wParam, lParam);

        }

        return LRESULT.ZERO;

    }



    /* Process the System Command */

    int cmd = wParam & 0xFFF0;

    switch (cmd) {

        case OS.SC_CLOSE:

            auto hwndShell = menuShell ().handle;

            int bits = OS.GetWindowLong (hwndShell, OS.GWL_STYLE);

            if ((bits & OS.WS_SYSMENU) is 0) return LRESULT.ZERO;

            break;

        case OS.SC_KEYMENU:

            /*

            * When lParam is zero, one of F10, Shift+F10, Ctrl+F10 or

            * Ctrl+Shift+F10 was pressed.  If there is no menu bar and

            * the focus control is interested in keystrokes, give the

            * key to the focus control.  Normally, F10 with no menu bar

            * moves focus to the System menu but this can be achieved

            * using Alt+Space.  To allow the application to see F10,

            * avoid running the default window proc.

            *

            * NOTE:  When F10 is pressed, WM_SYSCOMMAND is sent to the

            * shell, not the focus control.  This is undocumented Windows

            * behavior.

            */

            if (lParam is 0) {

                Decorations shell = menuShell ();

                Menu menu = shell.getMenuBar ();

                if (menu is null) {

                    Control control = display._getFocusControl ();

                    if (control !is null) {

                        if (control.hooks (SWT.KeyDown) || control.hooks (SWT.KeyUp)) {

                            display.mnemonicKeyHit = false;

                            return LRESULT.ZERO;

                        }

                    }

                }

            } else {

                /*

                * When lParam is not zero, Alt+<key> was pressed.  If the

                * application is interested in keystrokes and there is a

                * menu bar, check to see whether the key that was pressed

                * matches a mnemonic on the menu bar.  Normally, Windows

                * matches the first character of a menu item as well as

                * matching the mnemonic character.  To allow the application

                * to see the keystrokes in this case, avoid running the default

                * window proc.

                *

                * NOTE: When the user types Alt+Space, the System menu is

                * activated.  In this case the application should not see

                * the keystroke.

                */

                if (hooks (SWT.KeyDown) || hooks (SWT.KeyUp)) {

                    if (lParam !is ' ') {

                        Decorations shell = menuShell ();

                        Menu menu = shell.getMenuBar ();

                        if (menu !is null) {

                            char key = cast(char) Display.mbcsToWcs (cast(int)/*64bit*/lParam, 0);

                            if (key !is 0) {

                                key = cast(char) CharacterToLower (key);

                                MenuItem [] items = menu.getItems ();

                                for (int i=0; i<items.length; i++) {

                                    MenuItem item = items [i];

                                    String text = item.getText ();

                                    char mnemonic = findMnemonic (text);

                                    if (text.length > 0 && mnemonic is 0) {

                                        char ch = text.charAt (0);

                                        if (CharacterToLower (ch) is key) {

                                            display.mnemonicKeyHit = false;

                                            return LRESULT.ZERO;

                                        }

                                    }

                                }

                            }

                        } else {

                            display.mnemonicKeyHit = false;

                        }

                    }

                }

            }

            goto case OS.SC_HSCROLL;

        case OS.SC_HSCROLL:

        case OS.SC_VSCROLL:

            /*

            * Do not allow keyboard traversal of the menu bar

            * or scrolling when the shell is not enabled.

            */

            Decorations shell = menuShell ();

            if (!shell.isEnabled () || !shell.isActive ()) {

                return LRESULT.ZERO;

            }

            break;

        case OS.SC_MINIMIZE:

            /* Save the focus widget when the shell is minimized */

            menuShell ().saveFocus ();

            break;

        default:

    }

    return null;

}



LRESULT WM_SYSKEYDOWN (WPARAM wParam, LPARAM lParam) {

    return wmSysKeyDown (handle, wParam, lParam);

}



LRESULT WM_SYSKEYUP (WPARAM wParam, LPARAM lParam) {

    return wmSysKeyUp (handle, wParam, lParam);

}



LRESULT WM_TIMER (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_UNDO (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_UPDATEUISTATE (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT WM_VSCROLL (WPARAM wParam, LPARAM lParam) {

    Control control = display.getControl (cast(HANDLE)lParam);

    if (control is null) return null;

    return control.wmScrollChild (wParam, lParam);

}



LRESULT WM_WINDOWPOSCHANGED (WPARAM wParam, LPARAM lParam) {

    try {

        display.resizeCount++;

        auto code = callWindowProc (handle, OS.WM_WINDOWPOSCHANGED, wParam, lParam);

        return code is 0 ? LRESULT.ZERO : new LRESULT (code);

    } finally {

        --display.resizeCount;

    }

}



LRESULT WM_WINDOWPOSCHANGING (WPARAM wParam, LPARAM lParam) {

    /*

    * Bug in Windows.  When WM_SETREDRAW is used to turn off drawing

    * for a control and the control is moved or resized, Windows does

    * not redraw the area where the control once was in the parent.

    * The fix is to detect this case and redraw the area.

    */

    if (drawCount !is 0) {

        Shell shell = getShell ();

        if (shell !is this) {

            WINDOWPOS* lpwp = cast(WINDOWPOS*)lParam;

            if ((lpwp.flags & OS.SWP_NOMOVE) is 0 || (lpwp.flags & OS.SWP_NOSIZE) is 0) {

                RECT rect;

                OS.GetWindowRect (topHandle (), &rect);

                int width = rect.right - rect.left;

                int height = rect.bottom - rect.top;

                if (width !is 0 && height !is 0) {

                    auto hwndParent = parent is null ? null : parent.handle;

                    OS.MapWindowPoints (null, hwndParent, cast(POINT*)&rect, 2);

                    static if (OS.IsWinCE) {

                        OS.InvalidateRect (hwndParent, &rect, true);

                    } else {

                        auto rgn1 = OS.CreateRectRgn (rect.left, rect.top, rect.right, rect.bottom);

                        auto rgn2 = OS.CreateRectRgn (lpwp.x, lpwp.y, lpwp.x + lpwp.cx, lpwp.y + lpwp.cy);

                        OS.CombineRgn (rgn1, rgn1, rgn2, OS.RGN_DIFF);

                        int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE | OS.RDW_ALLCHILDREN;

                        OS.RedrawWindow (hwndParent, null, rgn1, flags);

                        OS.DeleteObject (rgn1);

                        OS.DeleteObject (rgn2);

                    }

                }

            }

        }

    }

    return null;

}



LRESULT WM_XBUTTONDBLCLK (WPARAM wParam, LPARAM lParam) {

    return wmXButtonDblClk (handle, wParam, lParam);

}



LRESULT WM_XBUTTONDOWN (WPARAM wParam, LPARAM lParam) {

    return wmXButtonDown (handle, wParam, lParam);

}



LRESULT WM_XBUTTONUP (WPARAM wParam, LPARAM lParam) {

    return wmXButtonUp (handle, wParam, lParam);

}



LRESULT wmColorChild (WPARAM wParam, LPARAM lParam) {

    Control control = findBackgroundControl ();

    if (control is null) {

        if ((state & THEME_BACKGROUND) !is 0) {

            if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {

                control = findThemeControl ();

                if (control !is null) {

                    RECT rect;

                    OS.GetClientRect (handle, &rect);

                    OS.SetTextColor (cast(HANDLE)wParam, getForegroundPixel ());

                    OS.SetBkColor (cast(HANDLE)wParam, getBackgroundPixel ());

                    fillThemeBackground (cast(HANDLE)wParam, control, &rect);

                    OS.SetBkMode (cast(HANDLE)wParam, OS.TRANSPARENT);

                    return new LRESULT (OS.GetStockObject (OS.NULL_BRUSH));

                }

            }

        }

        if (foreground is -1) return null;

    }

    if (control is null) control = this;

    int forePixel = getForegroundPixel ();

    int backPixel = control.getBackgroundPixel ();

    OS.SetTextColor (cast(HANDLE)wParam, forePixel);

    OS.SetBkColor (cast(HANDLE)wParam, backPixel);

    if (control.backgroundImage !is null) {

        RECT rect;

        OS.GetClientRect (handle, &rect);

        auto hwnd = control.handle;

        auto hBitmap = control.backgroundImage.handle;

        OS.MapWindowPoints (handle, hwnd, cast(POINT*)&rect, 2);

        POINT lpPoint;

        OS.GetWindowOrgEx (cast(HANDLE)wParam, &lpPoint);

        OS.SetBrushOrgEx (cast(HANDLE)wParam, -rect.left - lpPoint.x, -rect.top - lpPoint.y, &lpPoint);

        auto hBrush = findBrush (cast(ptrdiff_t)hBitmap, OS.BS_PATTERN);

        if ((state & DRAW_BACKGROUND) !is 0) {

            auto hOldBrush = OS.SelectObject (cast(HANDLE)wParam, hBrush);

            OS.MapWindowPoints (hwnd, handle, cast(POINT*)&rect, 2);

            OS.PatBlt (cast(HANDLE)wParam, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, OS.PATCOPY);

            OS.SelectObject (cast(HANDLE)wParam, hOldBrush);

        }

        OS.SetBkMode (cast(HANDLE)wParam, OS.TRANSPARENT);

        return new LRESULT (hBrush);

    }

    auto hBrush = findBrush (backPixel, OS.BS_SOLID);

    if ((state & DRAW_BACKGROUND) !is 0) {

        RECT rect;

        OS.GetClientRect (handle, &rect);

        auto hOldBrush = OS.SelectObject (cast(HANDLE)wParam, hBrush);

        OS.PatBlt (cast(HANDLE)wParam, rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, OS.PATCOPY);

        OS.SelectObject (cast(HANDLE)wParam, hOldBrush);

    }

    return new LRESULT (hBrush);

}



LRESULT wmCommandChild (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT wmDrawChild (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT wmMeasureChild (WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT wmNotify (NMHDR* hdr, WPARAM wParam, LPARAM lParam) {

    Control control = display.getControl (hdr.hwndFrom);

    if (control is null) return null;

    return control.wmNotifyChild (hdr, wParam, lParam);

}



LRESULT wmNotifyChild (NMHDR* hdr, WPARAM wParam, LPARAM lParam) {

    return null;

}



LRESULT wmScrollChild (WPARAM wParam, LPARAM lParam) {

    return null;

}



}

