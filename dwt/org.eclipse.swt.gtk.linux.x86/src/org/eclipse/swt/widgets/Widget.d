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
module org.eclipse.swt.widgets.Widget;

import org.eclipse.swt.SWT;
import java.lang.all;
import java.nonstandard.UnsafeUtf;

import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.SWTEventListener;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.EventTable;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.TypedListener;

import java.lang.Thread;

/**
 * This class is the abstract superclass of all user interface objects.
 * Widgets are created, disposed and issue notification to listeners
 * when events occur which affect them.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Dispose</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation. However, it has not been marked
 * final to allow those outside of the SWT development team to implement
 * patched versions of the class in order to get around specific
 * limitations in advance of when those limitations can be addressed
 * by the team.  Any class built using subclassing to access the internals
 * of this class will likely fail to compile or run between releases and
 * may be strongly platform specific. Subclassing should not be attempted
 * without an intimate and detailed understanding of the workings of the
 * hierarchy. No support is provided for user-written classes which are
 * implemented as subclasses of this class.
 * </p>
 *
 * @see #checkSubclass
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public abstract class Widget {
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
    public GtkWidget* handle;
    int style, state;
    Display display;
    EventTable eventTable;
    Object data;

    /* Global state flags */
    static const int DISPOSED = 1<<0;
    static const int CANVAS = 1<<1;
    static const int KEYED_DATA = 1<<2;
    static const int HANDLE = 1<<3;
    static const int DISABLED = 1<<4;
    static const int MENU = 1<<5;
    static const int OBSCURED = 1<<6;
    static const int MOVED = 1<<7;
    static const int RESIZED = 1<<8;
    static const int ZERO_WIDTH = 1<<9;
    static const int ZERO_HEIGHT = 1<<10;
    static const int HIDDEN = 1<<11;
    static const int FOREGROUND = 1<<12;
    static const int BACKGROUND = 1<<13;
    static const int FONT = 1<<14;
    static const int PARENT_BACKGROUND = 1<<15;
    static const int THEME_BACKGROUND = 1<<16;

    /* A layout was requested on this widget */
    static const int LAYOUT_NEEDED  = 1<<17;

    /* The preferred size of a child has changed */
    static const int LAYOUT_CHANGED = 1<<18;

    /* A layout was requested in this widget hierachy */
    static const int LAYOUT_CHILD = 1<<19;

    /* More global state flags */
    static const int RELEASED = 1<<20;
    static const int DISPOSE_SENT = 1<<21;
    static const int FOREIGN_HANDLE = 1<<22;
    static const int DRAG_DETECT = 1<<23;

    /* Default size for widgets */
    static const int DEFAULT_WIDTH  = 64;
    static const int DEFAULT_HEIGHT = 64;

    /* GTK signals data */
    static const int ACTIVATE = 1;
    static const int BUTTON_PRESS_EVENT = 2;
    static const int BUTTON_PRESS_EVENT_INVERSE = 3;
    static const int BUTTON_RELEASE_EVENT = 4;
    static const int BUTTON_RELEASE_EVENT_INVERSE = 5;
    static const int CHANGED = 6;
    static const int CHANGE_VALUE = 7;
    static const int CLICKED = 8;
    static const int COMMIT = 9;
    static const int CONFIGURE_EVENT = 10;
    static const int DELETE_EVENT = 11;
    static const int DELETE_RANGE = 12;
    static const int DELETE_TEXT = 13;
    static const int ENTER_NOTIFY_EVENT = 14;
    static const int EVENT = 15;
    static const int EVENT_AFTER = 16;
    static const int EXPAND_COLLAPSE_CURSOR_ROW = 17;
    static const int EXPOSE_EVENT = 18;
    static const int EXPOSE_EVENT_INVERSE = 19;
    static const int FOCUS = 20;
    static const int FOCUS_IN_EVENT = 21;
    static const int FOCUS_OUT_EVENT = 22;
    static const int GRAB_FOCUS = 23;
    static const int HIDE = 24;
    static const int INPUT = 25;
    static const int INSERT_TEXT = 26;
    static const int KEY_PRESS_EVENT = 27;
    static const int KEY_RELEASE_EVENT = 28;
    static const int LEAVE_NOTIFY_EVENT = 29;
    static const int MAP = 30;
    static const int MAP_EVENT = 31;
    static const int MNEMONIC_ACTIVATE = 32;
    static const int MOTION_NOTIFY_EVENT = 33;
    static const int MOTION_NOTIFY_EVENT_INVERSE = 34;
    static const int MOVE_FOCUS = 35;
    static const int OUTPUT = 36;
    static const int POPULATE_POPUP = 37;
    static const int POPUP_MENU = 38;
    static const int PREEDIT_CHANGED = 39;
    static const int REALIZE = 40;
    static const int ROW_ACTIVATED = 41;
    static const int SCROLL_CHILD = 42;
    static const int SCROLL_EVENT = 43;
    static const int SELECT = 44;
    static const int SHOW = 45;
    static const int SHOW_HELP = 46;
    static const int SIZE_ALLOCATE = 47;
    static const int STYLE_SET = 48;
    static const int SWITCH_PAGE = 49;
    static const int TEST_COLLAPSE_ROW = 50;
    static const int TEST_EXPAND_ROW = 51;
    static const int TEXT_BUFFER_INSERT_TEXT = 52;
    static const int TOGGLED = 53;
    static const int UNMAP = 54;
    static const int UNMAP_EVENT = 55;
    static const int UNREALIZE = 56;
    static const int VALUE_CHANGED = 57;
    static const int VISIBILITY_NOTIFY_EVENT = 58;
    static const int WINDOW_STATE_EVENT = 59;
    static const int ACTIVATE_INVERSE = 60;
    static const int DAY_SELECTED = 61;
    static const int MONTH_CHANGED = 62;
    static const int LAST_SIGNAL = 63;

    static String UD_Getter(String name) (){
        return "void* ud"~name~"(){ return getDisplay().getWindowProcUserData( "~name~"); }\n";
    }

    mixin ( UD_Getter!( "ACTIVATE" )() );
    mixin ( UD_Getter!( "BUTTON_PRESS_EVENT" )() );
    mixin ( UD_Getter!( "BUTTON_PRESS_EVENT_INVERSE" )() );
    mixin ( UD_Getter!( "BUTTON_RELEASE_EVENT" )() );
    mixin ( UD_Getter!( "BUTTON_RELEASE_EVENT_INVERSE" )() );
    mixin ( UD_Getter!( "CHANGED" )() );
    mixin ( UD_Getter!( "CHANGE_VALUE" )() );
    mixin ( UD_Getter!( "CLICKED" )() );
    mixin ( UD_Getter!( "COMMIT" )() );
    mixin ( UD_Getter!( "CONFIGURE_EVENT" )() );
    mixin ( UD_Getter!( "DELETE_EVENT" )() );
    mixin ( UD_Getter!( "DELETE_RANGE" )() );
    mixin ( UD_Getter!( "DELETE_TEXT" )() );
    mixin ( UD_Getter!( "ENTER_NOTIFY_EVENT" )() );
    mixin ( UD_Getter!( "EVENT" )() );
    mixin ( UD_Getter!( "EVENT_AFTER" )() );
    mixin ( UD_Getter!( "EXPAND_COLLAPSE_CURSOR_ROW" )() );
    mixin ( UD_Getter!( "EXPOSE_EVENT" )() );
    mixin ( UD_Getter!( "EXPOSE_EVENT_INVERSE" )() );
    mixin ( UD_Getter!( "FOCUS" )() );
    mixin ( UD_Getter!( "FOCUS_IN_EVENT" )() );
    mixin ( UD_Getter!( "FOCUS_OUT_EVENT" )() );
    mixin ( UD_Getter!( "GRAB_FOCUS" )() );
    mixin ( UD_Getter!( "HIDE" )() );
    mixin ( UD_Getter!( "INPUT" )() );
    mixin ( UD_Getter!( "INSERT_TEXT" )() );
    mixin ( UD_Getter!( "KEY_PRESS_EVENT" )() );
    mixin ( UD_Getter!( "KEY_RELEASE_EVENT" )() );
    mixin ( UD_Getter!( "LEAVE_NOTIFY_EVENT" )() );
    mixin ( UD_Getter!( "MAP" )() );
    mixin ( UD_Getter!( "MAP_EVENT" )() );
    mixin ( UD_Getter!( "MNEMONIC_ACTIVATE" )() );
    mixin ( UD_Getter!( "MOTION_NOTIFY_EVENT" )() );
    mixin ( UD_Getter!( "MOTION_NOTIFY_EVENT_INVERSE" )() );
    mixin ( UD_Getter!( "MOVE_FOCUS" )() );
    mixin ( UD_Getter!( "OUTPUT" )() );
    mixin ( UD_Getter!( "POPULATE_POPUP" )() );
    mixin ( UD_Getter!( "POPUP_MENU" )() );
    mixin ( UD_Getter!( "PREEDIT_CHANGED" )() );
    mixin ( UD_Getter!( "REALIZE" )() );
    mixin ( UD_Getter!( "ROW_ACTIVATED" )() );
    mixin ( UD_Getter!( "SCROLL_CHILD" )() );
    mixin ( UD_Getter!( "SCROLL_EVENT" )() );
    mixin ( UD_Getter!( "SELECT" )() );
    mixin ( UD_Getter!( "SHOW" )() );
    mixin ( UD_Getter!( "SHOW_HELP" )() );
    mixin ( UD_Getter!( "SIZE_ALLOCATE" )() );
    mixin ( UD_Getter!( "STYLE_SET" )() );
    mixin ( UD_Getter!( "SWITCH_PAGE" )() );
    mixin ( UD_Getter!( "TEST_COLLAPSE_ROW" )() );
    mixin ( UD_Getter!( "TEST_EXPAND_ROW" )() );
    mixin ( UD_Getter!( "TEXT_BUFFER_INSERT_TEXT" )() );
    mixin ( UD_Getter!( "TOGGLED" )() );
    mixin ( UD_Getter!( "UNMAP" )() );
    mixin ( UD_Getter!( "UNMAP_EVENT" )() );
    mixin ( UD_Getter!( "UNREALIZE" )() );
    mixin ( UD_Getter!( "VALUE_CHANGED" )() );
    mixin ( UD_Getter!( "VISIBILITY_NOTIFY_EVENT" )() );
    mixin ( UD_Getter!( "WINDOW_STATE_EVENT" )() );
    mixin ( UD_Getter!( "ACTIVATE_INVERSE" )() );
    mixin ( UD_Getter!( "DAY_SELECTED" )() );
    mixin ( UD_Getter!( "MONTH_CHANGED" )() );
    mixin ( UD_Getter!( "LAST_SIGNAL" )() );

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
 * @param parent a widget which will be the parent of the new instance (cannot be null)
 * @param style the style of widget to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parent is disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT
 * @see #checkSubclass
 * @see #getStyle
 */
public this (Widget parent, int style) {
    checkSubclass ();
    checkParent (parent);
    this.style = style;
    display = parent.display;
}

void _addListener (int eventType, Listener listener) {
    if (eventTable is null) eventTable = new EventTable ();
    eventTable.hook (eventType, listener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when an event of the given type occurs. When the
 * event does occur in the widget, the listener is notified by
 * sending it the <code>handleEvent()</code> message. The event
 * type is one of the event constants defined in class <code>SWT</code>.
 *
 * @param eventType the type of event to listen for
 * @param listener the listener which should be notified when the event occurs
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Listener
 * @see SWT
 * @see #getListeners(int)
 * @see #removeListener(int, Listener)
 * @see #notifyListeners
 */
public void addListener (int eventType, Listener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    _addListener (eventType, listener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the widget is disposed. When the widget is
 * disposed, the listener is notified by sending it the
 * <code>widgetDisposed()</code> message.
 *
 * @param listener the listener which should be notified when the receiver is disposed
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DisposeListener
 * @see #removeDisposeListener
 */
public void addDisposeListener (DisposeListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Dispose, typedListener);
}

GdkWindow* paintWindow () {
    return null;
}

static int checkBits (int style, int int0, int int1, int int2, int int3, int int4, int int5) {
    int mask = int0 | int1 | int2 | int3 | int4 | int5;
    if ((style & mask) is 0) style |= int0;
    if ((style & int0) !is 0) style = (style & ~mask) | int0;
    if ((style & int1) !is 0) style = (style & ~mask) | int1;
    if ((style & int2) !is 0) style = (style & ~mask) | int2;
    if ((style & int3) !is 0) style = (style & ~mask) | int3;
    if ((style & int4) !is 0) style = (style & ~mask) | int4;
    if ((style & int5) !is 0) style = (style & ~mask) | int5;
    return style;
}

void cellDataProc (
    GtkTreeViewColumn *tree_column,
    GtkCellRenderer *cell,
    GtkTreeModel *tree_model,
    GtkTreeIter *iter,
    void* data)
{
}

void checkOpen () {
    /* Do nothing */
}

void checkOrientation (Widget parent) {
    style &= ~SWT.MIRRORED;
    if ((style & (SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT)) is 0) {
        if (parent !is null) {
            if ((parent.style & SWT.LEFT_TO_RIGHT) !is 0) style |= SWT.LEFT_TO_RIGHT;
            if ((parent.style & SWT.RIGHT_TO_LEFT) !is 0) style |= SWT.RIGHT_TO_LEFT;
        }
    }
    style = checkBits (style, SWT.LEFT_TO_RIGHT, SWT.RIGHT_TO_LEFT, 0, 0, 0, 0);
    /* Versions of GTK prior to 2.8 do not render RTL text properly */
    if (OS.GTK_VERSION < OS.buildVERSION (2, 8, 0)) {
        style &= ~SWT.RIGHT_TO_LEFT;
        style |= SWT.LEFT_TO_RIGHT;
    }
}

/**
 * Throws an exception if the specified widget can not be
 * used as a parent for the receiver.
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the parent is disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 */
void checkParent (Widget parent) {
    if (parent is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (parent.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
    parent.checkWidget ();
    parent.checkOpen ();
}

/**
 * Checks that this class can be subclassed.
 * <p>
 * The SWT class library is intended to be subclassed
 * only at specific, controlled points (most notably,
 * <code>Composite</code> and <code>Canvas</code> when
 * implementing new widgets). This method enforces this
 * rule unless it is overridden.
 * </p><p>
 * <em>IMPORTANT:</em> By providing an implementation of this
 * method that allows a subclass of a class which does not
 * normally allow subclassing to be created, the implementer
 * agrees to be fully responsible for the fact that any such
 * subclass will likely fail between SWT releases and will be
 * strongly platform specific. No support is provided for
 * user-written classes which are implemented in this fashion.
 * </p><p>
 * The ability to subclass outside of the allowed SWT classes
 * is intended purely to enable those not on the SWT development
 * team to implement patches in order to get around specific
 * limitations in advance of when those limitations can be
 * addressed by the team. Subclassing should not be attempted
 * without an intimate and detailed understanding of the hierarchy.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
protected void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

/**
 * Throws an <code>SWTException</code> if the receiver can not
 * be accessed by the caller. This may include both checks on
 * the state of the receiver and more generally on the entire
 * execution context. This method <em>should</em> be called by
 * widget implementors to enforce the standard SWT invariants.
 * <p>
 * Currently, it is an error to invoke any method (other than
 * <code>isDisposed()</code>) on a widget that has had its
 * <code>dispose()</code> method called. It is also an error
 * to call widget methods from any thread that is different
 * from the thread that created the widget.
 * </p><p>
 * In future releases of SWT, there may be more or fewer error
 * checks and exceptions may be thrown for different reasons.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void checkWidget () {
    Display display = this.display;
    if (display is null) error (SWT.ERROR_WIDGET_DISPOSED);
    if (display.thread !is Thread.currentThread ()) error (SWT.ERROR_THREAD_INVALID_ACCESS);
    if ((state & DISPOSED) !is 0) error (SWT.ERROR_WIDGET_DISPOSED);
}

void createHandle (int index) {
}

void createWidget (int index) {
    createHandle (index);
    setOrientation ();
    hookEvents ();
    register ();
}

void deregister () {
    if (handle is null) return;
    if ((state & HANDLE) !is 0) display.removeWidget (handle);
}

void destroyWidget () {
    GtkWidget* h = topHandle ();
    releaseHandle ();
    if (h !is null && (state & HANDLE) !is 0) {
        OS.gtk_widget_destroy (h);
    }
}

/**
 * Disposes of the operating system resources associated with
 * the receiver and all its descendants. After this method has
 * been invoked, the receiver and all descendants will answer
 * <code>true</code> when sent the message <code>isDisposed()</code>.
 * Any internal connections between the widgets in the tree will
 * have been removed to facilitate garbage collection.
 * <p>
 * NOTE: This method is not called recursively on the descendants
 * of the receiver. This means that, widget implementers can not
 * detect when a widget is being disposed of by re-implementing
 * this method, but should instead listen for the <code>Dispose</code>
 * event.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #addDisposeListener
 * @see #removeDisposeListener
 * @see #checkWidget
 */
public void dispose () {
    /*
    * Note:  It is valid to attempt to dispose a widget
    * more than once.  If this happens, fail silently.
    */
    if (isDisposed ()) return;
    if (!isValidThread ()) error (SWT.ERROR_THREAD_INVALID_ACCESS);
    release (true);
}

void error (int code) {
    SWT.error (code);
}

/**
 * Returns the application defined widget data associated
 * with the receiver, or null if it has not been set. The
 * <em>widget data</em> is a single, unnamed field that is
 * stored with every widget.
 * <p>
 * Applications may put arbitrary objects in this field. If
 * the object stored in the widget data needs to be notified
 * when the widget is disposed of, it is the application's
 * responsibility to hook the Dispose event on the widget and
 * do so.
 * </p>
 *
 * @return the widget data
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - when the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - when called from the wrong thread</li>
 * </ul>
 *
 * @see #setData(Object)
 */
public Object getData () {
    checkWidget();
    return (state & KEYED_DATA) !is 0 ? (cast(ArrayWrapperObject)data).array[0] : data;
}
public String getDataStr () {
    return stringcast( getData() );
}

/**
 * Returns the application defined property of the receiver
 * with the specified name, or null if it has not been set.
 * <p>
 * Applications may have associated arbitrary objects with the
 * receiver in this fashion. If the objects stored in the
 * properties need to be notified when the widget is disposed
 * of, it is the application's responsibility to hook the
 * Dispose event on the widget and do so.
 * </p>
 *
 * @param   key the name of the property
 * @return the value of the property or null if it has not been set
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setData(String, Object)
 */
public Object getData (String key) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (key is null) error (SWT.ERROR_NULL_ARGUMENT);
    if ((state & KEYED_DATA) !is 0) {
        Object[] table = (cast(ArrayWrapperObject) data).array;
        for (int i=1; i<table.length; i+=2) {
            String tablekey = stringcast(table[i]);
            if (key.equals( tablekey) ) return table [i+1];
        }
    }
    return null;
}
public String getDataStr (String key) {
    return stringcast( getData(key) );
}

/**
 * Returns the <code>Display</code> that is associated with
 * the receiver.
 * <p>
 * A widget's display is either provided when it is created
 * (for example, top level <code>Shell</code>s) or is the
 * same as its parent's display.
 * </p>
 *
 * @return the receiver's display
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Display getDisplay () {
    Display display = this.display;
    if (display is null) error (SWT.ERROR_WIDGET_DISPOSED);
    return display;
}

/**
 * Returns an array of listeners who will be notified when an event
 * of the given type occurs. The event type is one of the event constants
 * defined in class <code>SWT</code>.
 *
 * @param eventType the type of event to listen for
 * @return an array of listeners that will be notified when the event occurs
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Listener
 * @see SWT
 * @see #addListener(int, Listener)
 * @see #removeListener(int, Listener)
 * @see #notifyListeners
 *
 * @since 3.4
 */
public Listener[] getListeners (int eventType) {
    checkWidget();
    if (eventTable is null) return new Listener[0];
    return eventTable.getListeners(eventType);
}

String getName () {
//  String str = getClass ().getName ();
//  int index = str.lastIndexOf ('.');
//  if (index is -1) return str;
    String str = this.classinfo.name;
    auto index = str.length;
    while ((--index > 0) && (str[index] !is '.')) {}
    return str[index + 1 .. $ ];
}

String getNameText () {
    return "";
}

/**
 * Returns the receiver's style information.
 * <p>
 * Note that the value which is returned by this method <em>may
 * not match</em> the value which was provided to the constructor
 * when the receiver was created. This can occur when the underlying
 * operating system does not support a particular combination of
 * requested styles. For example, if the platform widget used to
 * implement a particular SWT widget always has scroll bars, the
 * result of calling this method would always have the
 * <code>SWT.H_SCROLL</code> and <code>SWT.V_SCROLL</code> bits set.
 * </p>
 *
 * @return the style bits
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getStyle () {
    checkWidget ();
    return style;
}


int gtk_activate (GtkWidget* widget) {
    return 0;
}

int gtk_button_press_event (GtkWidget* widget, GdkEventButton* event) {
    return 0;
}

int gtk_button_release_event (GtkWidget* widget, GdkEventButton* event) {
    return 0;
}

int gtk_changed (GtkWidget* widget) {
    return 0;
}

int gtk_change_value (GtkWidget* widget, int scroll, double value1, void* user_data) {
    return 0;
}

int gtk_clicked (GtkWidget* widget) {
    return 0;
}

int gtk_commit (GtkIMContext* imcontext, char* text) {
    return 0;
}

int gtk_configure_event (GtkWidget* widget, ptrdiff_t event) {
    return 0;
}

int gtk_day_selected (GtkWidget* widget) {
    return 0;
}

int gtk_delete_event (GtkWidget* widget, ptrdiff_t event) {
    return 0;
}

int gtk_delete_range (GtkWidget* widget, ptrdiff_t iter1, ptrdiff_t iter2) {
    return 0;
}

int gtk_delete_text (GtkWidget* widget, ptrdiff_t start_pos, ptrdiff_t end_pos) {
    return 0;
}

int gtk_enter_notify_event (GtkWidget* widget, GdkEventCrossing* event) {
    return 0;
}

int gtk_event (GtkWidget* widget, GdkEvent* event) {
    return 0;
}

int gtk_event_after (GtkWidget* widget, GdkEvent* event) {
    return 0;
}

int gtk_expand_collapse_cursor_row (GtkWidget* widget, ptrdiff_t logical, ptrdiff_t expand, ptrdiff_t open_all) {
    return 0;
}

int gtk_expose_event (GtkWidget* widget, GdkEventExpose* event) {
    return 0;
}

int gtk_focus (GtkWidget* widget, ptrdiff_t directionType) {
    return 0;
}

int gtk_focus_in_event (GtkWidget* widget, GdkEventFocus* event) {
    return 0;
}

int gtk_focus_out_event (GtkWidget* widget, GdkEventFocus* event) {
    return 0;
}

int gtk_grab_focus (GtkWidget* widget) {
    return 0;
}

int gtk_hide (GtkWidget* widget) {
    return 0;
}

int gtk_input (GtkWidget* widget, ptrdiff_t arg1) {
    return 0;
}

int gtk_insert_text (GtkEditable* widget, char* new_text, ptrdiff_t new_text_length, ptrdiff_t position) {
    return 0;
}

int gtk_key_press_event (GtkWidget* widget, GdkEventKey* event) {
    return sendKeyEvent (SWT.KeyDown, event) ? 0 : 1;
}

int gtk_key_release_event (GtkWidget* widget, GdkEventKey* event) {
    return sendKeyEvent (SWT.KeyUp, event) ? 0 : 1;
}

int gtk_leave_notify_event (GtkWidget* widget, GdkEventCrossing* event) {
    return 0;
}

int gtk_map (GtkWidget* widget) {
    return 0;
}

int gtk_map_event (GtkWidget* widget, ptrdiff_t event) {
    return 0;
}

int gtk_mnemonic_activate (GtkWidget* widget, ptrdiff_t arg1) {
    return 0;
}

int gtk_month_changed (GtkWidget* widget) {
    return 0;
}

int gtk_motion_notify_event (GtkWidget* widget, GdkEventMotion* event) {
    return 0;
}

int gtk_move_focus (GtkWidget* widget, ptrdiff_t directionType) {
    return 0;
}

int gtk_output (GtkWidget* widget) {
    return 0;
}

int gtk_populate_popup (GtkWidget* widget, GtkWidget* menu) {
    return 0;
}

int gtk_popup_menu (GtkWidget* widget) {
    return 0;
}

int gtk_preedit_changed (GtkIMContext* imcontext) {
    return 0;
}

int gtk_realize (GtkWidget* widget) {
    return 0;
}

void gtk_row_activated (GtkTreeView* tree, GtkTreePath* path, GtkTreeViewColumn* column) {
}

int gtk_scroll_child (GtkWidget* widget, ptrdiff_t scrollType, ptrdiff_t horizontal) {
    return 0;
}

int gtk_scroll_event (GtkWidget* widget, GdkEventScroll*  event) {
    return 0;
}

int gtk_select (int item) {
    return 0;
}

int gtk_show (GtkWidget* widget) {
    return 0;
}

int gtk_show_help (GtkWidget* widget, ptrdiff_t helpType) {
    return 0;
}

int gtk_size_allocate (GtkWidget* widget, ptrdiff_t allocation) {
    return 0;
}

int gtk_style_set (GtkWidget* widget, ptrdiff_t previousStyle) {
    return 0;
}

int gtk_switch_page (GtkWidget* widget, ptrdiff_t page, ptrdiff_t page_num) {
    return 0;
}

int gtk_test_collapse_row (
    GtkTreeView *tree_view,
    GtkTreeIter *iter,
    GtkTreePath *path)
{
    return 0;
}

int gtk_test_expand_row (
    GtkTreeView *tree_view,
    GtkTreeIter *iter,
    GtkTreePath *path)
{
    return 0;
}

int gtk_text_buffer_insert_text (GtkTextBuffer *buffer, GtkTextIter *iter, char *text, ptrdiff_t len) {
    return 0;
}

int gtk_timer () {
    return 0;
}

int gtk_toggled (int renderer, char* pathStr) {
    return 0;
}

int gtk_unmap (GtkWidget* widget) {
    return 0;
}

int gtk_unmap_event (GtkWidget* widget, ptrdiff_t event) {
    return 0;
}

int gtk_unrealize (GtkWidget* widget) {
    return 0;
}

int gtk_value_changed (int adjustment) {
    return 0;
}

int gtk_visibility_notify_event (GtkWidget* widget, GdkEventVisibility* event) {
    return 0;
}

int gtk_window_state_event (GtkWidget* widget, GdkEventWindowState* event) {
    return 0;
}

int fontHeight ( PangoFontDescription* font, GtkWidget* widgetHandle ) {
    auto context = OS.gtk_widget_get_pango_context (widgetHandle);
    auto lang = OS.pango_context_get_language (context);
    auto metrics = OS.pango_context_get_metrics (context, font, lang);
    int ascent = OS.pango_font_metrics_get_ascent (metrics);
    int descent = OS.pango_font_metrics_get_descent (metrics);
    OS.pango_font_metrics_unref (metrics);
    return OS.PANGO_PIXELS (ascent + descent);
}

int filterProc (XEvent* xEvent, GdkEvent* gdkEvent, void* data) {
    return 0;
}

bool filters (int eventType) {
    return display.filters (eventType);
}

int fixedMapProc (GtkWidget* widget) {
    return 0;
}

void fixedSizeAllocateProc(GtkWidget* widget, GtkAllocation* allocationPtr) {
    return Display.oldFixedSizeAllocateProc(widget, allocationPtr);
}

char [] fixMnemonic (String str) {
    return fixMnemonic (str, true);
}

char [] fixMnemonic (String str, bool replace) {
    char[] text = str.dup;
    int i = 0, j = 0;
    char [] result = new char [str.length * 2];
    while (i < str.length) {
        switch (text [i]) {
            case '&':
                if (i + 1 < str.length && text [i + 1] == '&') {
                    result [j++] = text [i++];
                } else {
                    if (replace) result [j++] = '_';
                }
                i++;
                break;
            case '_':
                if (replace) result [j++] = '_';
                goto default;
            default:
                result [j++] = text [i++];
        }
    }
    if (j < result.length) result [j++] = 0;
    return result[0 .. j];
}

/**
 * Returns <code>true</code> if the widget has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the widget.
 * When a widget has been disposed, it is an error to
 * invoke any other method using the widget.
 * </p>
 *
 * @return <code>true</code> when the widget is disposed and <code>false</code> otherwise
 */
public bool isDisposed () {
    return (state & DISPOSED) !is 0;
}

/**
 * Returns <code>true</code> if there are any listeners
 * for the specified event type associated with the receiver,
 * and <code>false</code> otherwise. The event type is one of
 * the event constants defined in class <code>SWT</code>.
 *
 * @param eventType the type of event
 * @return true if the event is hooked
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SWT
 */
public bool isListening (int eventType) {
    checkWidget ();
    return hooks (eventType);
}

bool isValidThread () {
    return getDisplay ().isValidThread ();
}

bool isValidSubclass() {
    return true;//Display.isValidClass(getClass());
}

void hookEvents () {
}

/*
 * Returns <code>true</code> if the specified eventType is
 * hooked, and <code>false</code> otherwise. Implementations
 * of SWT can avoid creating objects and sending events
 * when an event happens in the operating system but
 * there are no listeners hooked for the event.
 *
 * @param eventType the event to be checked
 *
 * @return <code>true</code> when the eventType is hooked and <code>false</code> otherwise
 *
 * @see #isListening
 */
bool hooks (int eventType) {
    if (eventTable is null) return false;
    return eventTable.hooks (eventType);
}

int hoverProc (GtkWidget* widget) {
    return 0;
}

void menuPositionProc (GtkMenu* menu, int* x, int* y, int* push_in, void* user_data) {
}

bool mnemonicHit (GtkWidget* mnemonicHandle, wchar key) {
    if (!mnemonicMatch (mnemonicHandle, key)) return false;
    OS.g_signal_handlers_block_matched ( cast(void*)mnemonicHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udMNEMONIC_ACTIVATE);
    bool result = cast(bool)OS.gtk_widget_mnemonic_activate (cast(GtkWidget*)mnemonicHandle, false);
    OS.g_signal_handlers_unblock_matched (cast(void*)mnemonicHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udMNEMONIC_ACTIVATE);
    return result;
}

bool mnemonicMatch (GtkWidget* mnemonicHandle, wchar key) {
    int keyval1 = OS.gdk_keyval_to_lower (OS.gdk_unicode_to_keyval (key));
    int keyval2 = OS.gdk_keyval_to_lower (OS.gtk_label_get_mnemonic_keyval (cast(GtkLabel*)mnemonicHandle));
    return keyval1 is keyval2;
}

void modifyStyle (GtkWidget* handle, GtkRcStyle* style) {
    OS.gtk_widget_modify_style (handle, style);
}

/**
 * Notifies all of the receiver's listeners for events
 * of the given type that one such event has occurred by
 * invoking their <code>handleEvent()</code> method.  The
 * event type is one of the event constants defined in class
 * <code>SWT</code>.
 *
 * @param eventType the type of event which has occurred
 * @param event the event data
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SWT
 * @see #addListener
 * @see #getListeners(int)
 * @see #removeListener(int, Listener)
 */
public void notifyListeners (int eventType, Event event) {
    checkWidget();
    if (event is null) event = new Event ();
    sendEvent (eventType, event);
}

void postEvent (int eventType) {
    sendEvent (eventType, null, false);
}

void postEvent (int eventType, Event event) {
    sendEvent (eventType, event, false);
}

void register () {
    if (handle is null) return;
    if ((state & HANDLE) !is 0) display.addWidget (handle, this);
}

void release (bool destroy) {
    if ((state & DISPOSE_SENT) is 0) {
        state |= DISPOSE_SENT;
        sendEvent (SWT.Dispose);
    }
    if ((state & DISPOSED) is 0) {
        releaseChildren (destroy);
    }
    if ((state & RELEASED) is 0) {
        state |= RELEASED;
        if (destroy) {
            releaseParent ();
            releaseWidget ();
            destroyWidget ();
        } else {
            releaseWidget ();
            releaseHandle ();
        }
    }
}

void releaseChildren (bool destroy) {
}

void releaseHandle () {
    handle = null;
    state |= DISPOSED;
    display = null;
}

void releaseParent () {
    /* Do nothing */
}

void releaseWidget () {
    deregister ();
    eventTable = null;
    data = null;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when an event of the given type occurs. The event
 * type is one of the event constants defined in class <code>SWT</code>.
 *
 * @param eventType the type of event to listen for
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
 * @see Listener
 * @see SWT
 * @see #addListener
 * @see #getListeners(int)
 * @see #notifyListeners
 */
public void removeListener (int eventType, Listener handler) {
    checkWidget ();
    if (handler is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (eventType, handler);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when an event of the given type occurs.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the SWT
 * public API. It is marked public only so that it can be shared
 * within the packages provided by SWT. It should never be
 * referenced from application code.
 * </p>
 *
 * @param eventType the type of event to listen for
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
 * @see Listener
 * @see #addListener
 */
protected void removeListener (int eventType, SWTEventListener handler) {
    checkWidget ();
    if (handler is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (eventType, handler);
}

void rendererGetSizeProc (
    GtkCellRenderer      *cell,
    GtkWidget            *widget,
    GdkRectangle         *cell_area,
    int                  *x_offset,
    int                  *y_offset,
    int                  *width,
    int                  *height)
{
}

void rendererRenderProc (
    GtkCellRenderer * cell,
    GdkDrawable * window,
    GtkWidget * widget,
    GdkRectangle *background_area,
    GdkRectangle *cell_area,
    GdkRectangle *expose_area,
    int flags)
{
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the widget is disposed.
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
 * @see DisposeListener
 * @see #addDisposeListener
 */
public void removeDisposeListener (DisposeListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Dispose, listener);
}


void sendEvent (Event event) {
    Display display = event.display;
    if (!display.filterEvent (event)) {
        if (eventTable !is null) eventTable.sendEvent (event);
    }
}

void sendEvent (int eventType) {
    sendEvent (eventType, null, true);
}

void sendEvent (int eventType, Event event) {
    sendEvent (eventType, event, true);
}

void sendEvent (int eventType, Event event, bool send) {
    if (eventTable is null && !display.filters (eventType)) {
        return;
    }
    if (event is null) event = new Event ();
    event.type = eventType;
    event.display = display;
    event.widget = this;
    if (event.time is 0) {
        event.time = display.getLastEventTime ();
    }
    if (send) {
        sendEvent (event);
    } else {
        display.postEvent (event);
    }
}

bool sendKeyEvent (int type, GdkEventKey* keyEvent) {
    size_t len = keyEvent.length;
    if (keyEvent.string is null || OS.g_utf8_strlen (keyEvent.string, len) <= 1) {
        Event event = new Event ();
        event.time = keyEvent.time;
        if (!setKeyState (event, keyEvent)) return true;
        sendEvent (type, event);
        // widget could be disposed at this point

        /*
        * It is possible (but unlikely), that application
        * code could have disposed the widget in the key
        * events.  If this happens, end the processing of
        * the key by returning false.
        */
        if (isDisposed ()) return false;
        return event.doit;
    }
    char [] chars = fromStringz( keyEvent.string );
    return sendIMKeyEvent (type, keyEvent, chars) !is null;
}

char [] sendIMKeyEvent (int type, GdkEventKey* keyEvent, char [] chars) {
    int index = 0, count = 0, state = 0;
    GdkEvent*  ptr = null;
    if (keyEvent is null) {
        ptr = OS.gtk_get_current_event ();
        if (ptr !is null) {
            keyEvent = cast(GdkEventKey*)ptr;
            switch (keyEvent.type) {
                case OS.GDK_KEY_PRESS:
                case OS.GDK_KEY_RELEASE:
                    state = keyEvent.state;
                    break;
                default:
                    keyEvent = null;
                    break;
            }
        }
    }
    if (keyEvent is null) {
        int buffer;
        OS.gtk_get_current_event_state (&buffer);
        state = buffer;
    }
    while (index < chars.length) {
        Event event = new Event ();
        //PORTING take care of utf8
        if (keyEvent !is null && chars.UCScount() <= 1) {
            setKeyState (event, keyEvent);
        } else {
            setInputState (event, state);
        }
        //PORTING take care of utf8
        ptrdiff_t incr;
        event.character = cast(wchar) chars.dcharAt(index, incr);
        sendEvent (type, event);

        /*
        * It is possible (but unlikely), that application
        * code could have disposed the widget in the key
        * events.  If this happens, end the processing of
        * the key by returning null.
        */
        if (isDisposed ()) {
            if (ptr !is null) OS.gdk_event_free (ptr);
            return null;
        }

        //PORTING take care of utf8
        if (event.doit) {
            for( int i = 0; i < incr; i++ ){
                chars [count+i] = chars [index+i];
            }
            count+=incr;
        }
        index+=incr;
    }
    if (ptr !is null) OS.gdk_event_free (ptr);
    if (count is 0) return null;
    if (index !is count) {
        char [] result = new char [count];
        System.arraycopy (chars, 0, result, 0, count);
        return result;
    }
    return chars;
}

/**
 * Sets the application defined widget data associated
 * with the receiver to be the argument. The <em>widget
 * data</em> is a single, unnamed field that is stored
 * with every widget.
 * <p>
 * Applications may put arbitrary objects in this field. If
 * the object stored in the widget data needs to be notified
 * when the widget is disposed of, it is the application's
 * responsibility to hook the Dispose event on the widget and
 * do so.
 * </p>
 *
 * @param data the widget data
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - when the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - when called from the wrong thread</li>
 * </ul>
 *
 * @see #getData()
 */
public void setData (Object data) {
    checkWidget();
    if ((state & KEYED_DATA) !is 0) {
        (cast(ArrayWrapperObject) this.data).array[0] = data;
    } else {
        this.data = data;
    }
}
public void setDataStr (String data) {
    setData( stringcast(data));
}

/**
 * Sets the application defined property of the receiver
 * with the specified name to the given value.
 * <p>
 * Applications may associate arbitrary objects with the
 * receiver in this fashion. If the objects stored in the
 * properties need to be notified when the widget is disposed
 * of, it is the application's responsibility to hook the
 * Dispose event on the widget and do so.
 * </p>
 *
 * @param key the name of the property
 * @param value the new value for the property
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getData(String)
 */
public void setData (String key, Object value) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (key is null) error (SWT.ERROR_NULL_ARGUMENT);
    int index = 1;
    Object [] table = null;
    if ((state & KEYED_DATA) !is 0) {
        table = (cast(ArrayWrapperObject) data).array;
        while (index < table.length) {
            String tablekey = stringcast(table[index]);
            if (key.equals (tablekey) ) break;
            index += 2;
        }
    }
    if (value !is null) {
        if ((state & KEYED_DATA) !is 0) {
            if (index is table.length) {
                Object [] newTable = new Object [table.length + 2];
                System.arraycopy (table, 0, newTable, 0, table.length);
                table = newTable;
                data = new ArrayWrapperObject( table );
            }
        } else {
            table = new Object [3];
            table [0] = data;
            data = new ArrayWrapperObject( table );
            state |= KEYED_DATA;
        }
        table [index] = new ArrayWrapperString( key );
        table [index + 1] = value;
    } else {
        if ((state & KEYED_DATA) !is 0) {
            if (index !is table.length) {
                ptrdiff_t len = table.length - 2;
                if (len is 1) {
                    data = table [0];
                    state &= ~KEYED_DATA;
                } else {
                    Object [] newTable = new Object [len];
                    System.arraycopy (table, 0, newTable, 0, index);
                    System.arraycopy (table, index + 2, newTable, index, len - index);
                    data = new ArrayWrapperObject( newTable );
                }
            }
        }
    }
}
public void setDataStr (String key, String value) {
    setData(key, stringcast(value));
}

void setForegroundColor (GtkWidget* handle, GdkColor* color) {
    auto style = OS.gtk_widget_get_modifier_style (handle);
    OS.gtk_rc_style_set_fg (style, OS.GTK_STATE_NORMAL, color);
    OS.gtk_rc_style_set_fg (style, OS.GTK_STATE_ACTIVE, color);
    OS.gtk_rc_style_set_fg (style, OS.GTK_STATE_PRELIGHT, color);
    int flags = OS.gtk_rc_style_get_color_flags (style, OS.GTK_STATE_NORMAL);
    flags = (color is null) ? flags & ~OS.GTK_RC_FG: flags | OS.GTK_RC_FG;
    OS.gtk_rc_style_set_color_flags (style, OS.GTK_STATE_NORMAL, flags);
    flags = OS.gtk_rc_style_get_color_flags (style, OS.GTK_STATE_ACTIVE);
    flags = (color is null) ? flags & ~OS.GTK_RC_FG: flags | OS.GTK_RC_FG;
    OS.gtk_rc_style_set_color_flags (style, OS.GTK_STATE_ACTIVE, flags);
    flags = OS.gtk_rc_style_get_color_flags (style, OS.GTK_STATE_PRELIGHT);
    flags = (color is null) ? flags & ~OS.GTK_RC_FG: flags | OS.GTK_RC_FG;
    OS.gtk_rc_style_set_color_flags (style, OS.GTK_STATE_PRELIGHT, flags);

    OS.gtk_rc_style_set_text (style, OS.GTK_STATE_NORMAL, color);
    OS.gtk_rc_style_set_text (style, OS.GTK_STATE_ACTIVE, color);
    OS.gtk_rc_style_set_text (style, OS.GTK_STATE_PRELIGHT, color);
    flags = OS.gtk_rc_style_get_color_flags (style, OS.GTK_STATE_NORMAL);
    flags = (color is null) ? flags & ~OS.GTK_RC_TEXT: flags | OS.GTK_RC_TEXT;
    OS.gtk_rc_style_set_color_flags (style, OS.GTK_STATE_NORMAL, flags);
    flags = OS.gtk_rc_style_get_color_flags (style, OS.GTK_STATE_PRELIGHT);
    flags = (color is null) ? flags & ~OS.GTK_RC_TEXT: flags | OS.GTK_RC_TEXT;
    OS.gtk_rc_style_set_color_flags (style, OS.GTK_STATE_PRELIGHT, flags);
    flags = OS.gtk_rc_style_get_color_flags (style, OS.GTK_STATE_ACTIVE);
    flags = (color is null) ? flags & ~OS.GTK_RC_TEXT: flags | OS.GTK_RC_TEXT;
    OS.gtk_rc_style_set_color_flags (style, OS.GTK_STATE_ACTIVE, flags);
    modifyStyle (handle, style);
}

bool setInputState (Event event, int state) {
    if ((state & OS.GDK_MOD1_MASK) !is 0) event.stateMask |= SWT.ALT;
    if ((state & OS.GDK_SHIFT_MASK) !is 0) event.stateMask |= SWT.SHIFT;
    if ((state & OS.GDK_CONTROL_MASK) !is 0) event.stateMask |= SWT.CONTROL;
    if ((state & OS.GDK_BUTTON1_MASK) !is 0) event.stateMask |= SWT.BUTTON1;
    if ((state & OS.GDK_BUTTON2_MASK) !is 0) event.stateMask |= SWT.BUTTON2;
    if ((state & OS.GDK_BUTTON3_MASK) !is 0) event.stateMask |= SWT.BUTTON3;
    return true;
}

bool setKeyState (Event event, GdkEventKey* keyEvent) {
    if (keyEvent.string !is null && OS.g_utf8_strlen (keyEvent.string, keyEvent.length) > 1) return false;
    bool isNull = false;
    event.keyCode = Display.translateKey (keyEvent.keyval);
    switch (keyEvent.keyval) {
        case OS.GDK_BackSpace:      event.character = SWT.BS; break;
        case OS.GDK_Linefeed:       event.character = SWT.LF; break;
        case OS.GDK_KP_Enter:
        case OS.GDK_Return:         event.character = SWT.CR; break;
        case OS.GDK_KP_Delete:
        case OS.GDK_Delete:         event.character = SWT.DEL; break;
        case OS.GDK_Escape:         event.character = SWT.ESC; break;
        case OS.GDK_Tab:
        case OS.GDK_ISO_Left_Tab:   event.character = SWT.TAB; break;
        default: {
            if (event.keyCode is 0) {
                uint keyval;
                int effective_group, level;
                int consumed_modifiers;
                if (OS.gdk_keymap_translate_keyboard_state(OS.gdk_keymap_get_default (), keyEvent.hardware_keycode, 0, keyEvent.group, &keyval, &effective_group, &level, &consumed_modifiers)) {
                    event.keyCode = OS.gdk_keyval_to_unicode (keyval );
                }
            }
            int key = keyEvent.keyval;
            if ((keyEvent.state & OS.GDK_CONTROL_MASK) !is 0 && (0 <= key && key <= 0x7F)) {
                if ('a'  <= key && key <= 'z') key -= 'a' - 'A';
                if (64 <= key && key <= 95) key -= 64;
                event.character = cast(char) key;
                isNull = keyEvent.keyval is '@' && key is 0;
            } else {
                event.character = cast(char) OS.gdk_keyval_to_unicode (key);
            }
        }
    }
    if (event.keyCode is 0 && event.character is 0) {
        if (!isNull) return false;
    }
    return setInputState (event, keyEvent.state);
}

void setOrientation () {
}

int shellMapProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    return 0;
}

int sizeAllocateProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    return 0;
}

int sizeRequestProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    return 0;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
public override String toString () {
    String str = "*Disposed*";
    if (!isDisposed ()) {
        str = "*Wrong Thread*";
        if (isValidThread ()) str = getNameText ();
    }
    return getName () ~ " {" ~ str ~ "}";
}

GtkWidget* topHandle () {
    return handle;
}

int timerProc (GtkWidget* widget) {
    return 0;
}

void treeSelectionProc (
    GtkTreeModel *model,
    GtkTreePath *path,
    GtkTreeIter *iter,
    int[] selection,
    int length)
{
}

bool translateTraversal (int event) {
    return false;
}

int windowProc (GtkWidget* handle, ptrdiff_t user_data) {
    void trace( String str ){
        version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Widget windowProc {}", str ).flush;
    }

    switch (user_data) {
        case ACTIVATE:
            trace( "ACTIVATE" );
            return gtk_activate (handle);
        case CHANGED:
            trace( "CHANGED" );
            return gtk_changed (handle);
        case CLICKED:
            trace( "CLICKED" );
            return gtk_clicked (handle);
        case DAY_SELECTED:
            trace( "DAY_SELECTED" );
            return gtk_day_selected (handle);
        case HIDE:
            trace( "HIDE" );
            return gtk_hide (handle);
        case GRAB_FOCUS:
            trace( "GRAB_FOCUS" );
            return gtk_grab_focus (handle);
        case MAP:
            trace( "MAP" );
            return gtk_map (handle);
        case MONTH_CHANGED:
            trace( "MONTH_CHANGED" );
            return gtk_month_changed (handle);
        case OUTPUT:
            trace( "OUTPUT" );
            return gtk_output (handle);
        case POPUP_MENU:
            trace( "POPUP_MENU" );
            return gtk_popup_menu (handle);
        case PREEDIT_CHANGED:
            trace( "PREEDIT_CHANGED" );
            return gtk_preedit_changed (cast(GtkIMContext*)handle);
        case REALIZE:
            trace( "REALIZE" );
            return gtk_realize (handle);
        case SELECT:
            trace( "SELECT" );
            return gtk_select (cast(int)handle);
        case SHOW:
            trace( "SHOW" );
            return gtk_show (handle);
        case VALUE_CHANGED:
            trace( "VALUE_CHANGED" );
            return gtk_value_changed (cast(int)handle);
        case UNMAP:
            trace( "UNMAP" );
            return gtk_unmap (handle);
        case UNREALIZE:
            trace( "UNREALIZE" );
            return gtk_unrealize (handle);
        default:
            trace( "default" );
            return 0;
    }
}

int windowProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    void trace( String str ){
        version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Widget windowProc1 {}", str ).flush;
    }

    switch (user_data) {
        case EXPOSE_EVENT_INVERSE: {
            trace( "EXPOSE_EVENT_INVERSE" );
            GdkEventExpose* gdkEvent = cast(GdkEventExpose*) arg0;
            auto paintWindow = paintWindow();
            auto window = gdkEvent.window;
            if (window !is paintWindow) return 0;
            return (state & OBSCURED) !is 0 ? 1 : 0;
        }
        case BUTTON_PRESS_EVENT_INVERSE:
        case BUTTON_RELEASE_EVENT_INVERSE:
        case MOTION_NOTIFY_EVENT_INVERSE: {
            trace( "BUTTON_PRESS_EVENT_INVERSE BUTTON_RELEASE_EVENT_INVERSE MOTION_NOTIFY_EVENT_INVERSE" );
            return 1;
        }
        case BUTTON_PRESS_EVENT:
            trace( "BUTTON_PRESS_EVENT" );
            return gtk_button_press_event (handle, cast(GdkEventButton*)arg0);
        case BUTTON_RELEASE_EVENT:
            trace( "BUTTON_RELEASE_EVENT" );
            return gtk_button_release_event (handle, cast(GdkEventButton*)arg0);
        case COMMIT:
            trace( "COMMIT" );
            return gtk_commit (cast(GtkIMContext*)handle, cast(char*)arg0);
        case CONFIGURE_EVENT:
            trace( "CONFIGURE_EVENT" );
            return gtk_configure_event (handle, arg0);
        case DELETE_EVENT:
            trace( "DELETE_EVENT" );
            return gtk_delete_event (handle, arg0);
        case ENTER_NOTIFY_EVENT:
            trace( "ENTER_NOTIFY_EVENT" );
            return gtk_enter_notify_event (handle, cast(GdkEventCrossing*)arg0);
        case EVENT:
            trace( "EVENT" );
            return gtk_event (handle, cast(GdkEvent*)arg0);
        case POPULATE_POPUP:
            trace( "POPULATE_POPUP" );
            return gtk_populate_popup (handle, cast(GtkWidget*)arg0);
        case EVENT_AFTER:
            trace( "EVENT_AFTER" );
            return gtk_event_after (handle, cast(GdkEvent*)arg0);
        case EXPOSE_EVENT:
            trace( "EXPOSE_EVENT" );
            return gtk_expose_event (handle, cast(GdkEventExpose*)arg0);
        case FOCUS:
            trace( "FOCUS" );
            return gtk_focus (handle, arg0);
        case FOCUS_IN_EVENT:
            trace( "FOCUS_IN_EVENT" );
            return gtk_focus_in_event (handle, cast(GdkEventFocus*)arg0);
        case FOCUS_OUT_EVENT:
            trace( "FOCUS_OUT_EVENT" );
            return gtk_focus_out_event (handle, cast(GdkEventFocus*)arg0);
        case KEY_PRESS_EVENT:
            trace( "KEY_PRESS_EVENT" );
            return gtk_key_press_event (handle, cast(GdkEventKey*)arg0);
        case KEY_RELEASE_EVENT:
            trace( "KEY_RELEASE_EVENT" );
            return gtk_key_release_event (handle, cast(GdkEventKey*)arg0);
        case INPUT:
            trace( "INPUT" );
            return gtk_input (handle, arg0);
        case LEAVE_NOTIFY_EVENT:
            trace( "LEAVE_NOTIFY_EVENT" );
            return gtk_leave_notify_event (handle, cast(GdkEventCrossing*)arg0);
        case MAP_EVENT:
            trace( "MAP_EVENT" );
            return gtk_map_event (handle, arg0);
        case MNEMONIC_ACTIVATE:
            trace( "MNEMONIC_ACTIVATE" );
            return gtk_mnemonic_activate (handle, arg0);
        case MOTION_NOTIFY_EVENT:
            trace( "MOTION_NOTIFY_EVENT" );
            return gtk_motion_notify_event (handle, cast(GdkEventMotion*)arg0);
        case MOVE_FOCUS:
            trace( "MOVE_FOCUS" );
            return gtk_move_focus (handle, arg0);
        case SCROLL_EVENT:
            trace( "SCROLL_EVENT" );
            return gtk_scroll_event (handle, cast(GdkEventScroll*)arg0);
        case SHOW_HELP:
            trace( "SHOW_HELP" );
            return gtk_show_help (handle, arg0);
        case SIZE_ALLOCATE:
            trace( "SIZE_ALLOCATE" );
            return gtk_size_allocate (handle, arg0);
        case STYLE_SET:
            trace( "STYLE_SET" );
            return gtk_style_set (handle, arg0);
        case TOGGLED:
            trace( "TOGGLED" );
            return gtk_toggled (cast(int)handle, cast(char*)arg0);
        case UNMAP_EVENT:
            trace( "UNMAP_EVENT" );
            return gtk_unmap_event (handle, arg0);
        case VISIBILITY_NOTIFY_EVENT:
            trace( "VISIBILITY_NOTIFY_EVENT" );
            return gtk_visibility_notify_event (handle, cast(GdkEventVisibility*)arg0);
        case WINDOW_STATE_EVENT:
            trace( "WINDOW_STATE_EVENT" );
            return gtk_window_state_event (handle, cast(GdkEventWindowState*)arg0);
        default:
            trace( "default" );
            return 0;
    }
}

int windowProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t arg1, ptrdiff_t user_data) {
    void trace( String str ){
        version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Widget windowProc2 {}", str ).flush;
    }

    switch (user_data) {
        case DELETE_RANGE:
            trace( "DELETE_RANGE" );
            return gtk_delete_range (handle, arg0, arg1);
        case DELETE_TEXT:
            trace( "DELETE_TEXT" );
            return gtk_delete_text (handle, arg0, arg1);
        case ROW_ACTIVATED:
            trace( "ROW_ACTIVATED" );
            gtk_row_activated (cast(GtkTreeView*)handle, cast(GtkTreePath*)arg0, cast(GtkTreeViewColumn*)arg1);
            return 0;
        case SCROLL_CHILD:
            trace( "SCROLL_CHILD" );
            return gtk_scroll_child (handle, arg0, arg1);
        case SWITCH_PAGE:
            trace( "SWITCH_PAGE" );
            return gtk_switch_page (handle, arg0, arg1);
        case TEST_COLLAPSE_ROW:
            trace( "TEST_COLLAPSE_ROW" );
            return gtk_test_collapse_row (cast(GtkTreeView*)handle, cast(GtkTreeIter*)arg0, cast(GtkTreePath*)arg1);
        case TEST_EXPAND_ROW:
            trace( "TEST_EXPAND_ROW" );
            return gtk_test_expand_row(cast(GtkTreeView*)handle, cast(GtkTreeIter*)arg0, cast(GtkTreePath*)arg1);
        default:
            trace( "default" );
            return 0;
    }
}

int windowProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t arg1, ptrdiff_t arg2, ptrdiff_t user_data) {
    void trace( String str ){
        version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Widget windowProc3 {}", str ).flush;
    }

    switch (user_data) {
        case EXPAND_COLLAPSE_CURSOR_ROW:
            trace( "EXPAND_COLLAPSE_CURSOR_ROW" );
            return gtk_expand_collapse_cursor_row (handle, arg0, arg1, arg2);
        case INSERT_TEXT:
            trace( "INSERT_TEXT" );
            return gtk_insert_text (cast(GtkEditable*)handle, cast(char*)arg0, arg1, arg2);
        case TEXT_BUFFER_INSERT_TEXT:
            trace( "TEXT_BUFFER_INSERT_TEXT" );
            return gtk_text_buffer_insert_text (cast(GtkTextBuffer*)handle, cast(GtkTextIter*)arg0, cast(char*)arg1, arg2);
        default:
            trace( "default" );
            return 0;
    }
}

}
