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
module org.eclipse.swt.widgets.Display;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.DeviceData;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Resource;
import org.eclipse.swt.internal.Compatibility;
import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.Lock;
import org.eclipse.swt.internal.LONG;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Caret;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Dialog;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.EventTable;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.Monitor;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Synchronizer;
import org.eclipse.swt.widgets.Tray;
import org.eclipse.swt.widgets.Widget;

import java.lang.all;

import java.lang.Thread;
version(Tango){
import tango.stdc.string;
} else { // Phobos
}

/**
 * Instances of this class are responsible for managing the
 * connection between SWT and the underlying operating
 * system. Their most important function is to implement
 * the SWT event loop in terms of the platform event model.
 * They also provide various methods for accessing information
 * about the operating system, and have overall control over
 * the operating system resources which SWT allocates.
 * <p>
 * Applications which are built with SWT will <em>almost always</em>
 * require only a single display. In particular, some platforms
 * which SWT supports will not allow more than one <em>active</em>
 * display. In other words, some platforms do not support
 * creating a new display if one already exists that has not been
 * sent the <code>dispose()</code> message.
 * <p>
 * In SWT, the thread which creates a <code>Display</code>
 * instance is distinguished as the <em>user-interface thread</em>
 * for that display.
 * </p>
 * The user-interface thread for a particular display has the
 * following special attributes:
 * <ul>
 * <li>
 * The event loop for that display must be run from the thread.
 * </li>
 * <li>
 * Some SWT API methods (notably, most of the public methods in
 * <code>Widget</code> and its subclasses), may only be called
 * from the thread. (To support multi-threaded user-interface
 * applications, class <code>Display</code> provides inter-thread
 * communication methods which allow threads other than the
 * user-interface thread to request that it perform operations
 * on their behalf.)
 * </li>
 * <li>
 * The thread is not allowed to construct other
 * <code>Display</code>s until that display has been disposed.
 * (Note that, this is in addition to the restriction mentioned
 * above concerning platform support for multiple displays. Thus,
 * the only way to have multiple simultaneously active displays,
 * even on platforms which support it, is to have multiple threads.)
 * </li>
 * </ul>
 * Enforcing these attributes allows SWT to be implemented directly
 * on the underlying operating system's event model. This has
 * numerous benefits including smaller footprint, better use of
 * resources, safer memory management, clearer program logic,
 * better performance, and fewer overall operating system threads
 * required. The down side however, is that care must be taken
 * (only) when constructing multi-threaded applications to use the
 * inter-thread communication mechanisms which this class provides
 * when required.
 * </p><p>
 * All SWT API methods which may only be called from the user-interface
 * thread are distinguished in their documentation by indicating that
 * they throw the "<code>ERROR_THREAD_INVALID_ACCESS</code>"
 * SWT exception.
 * </p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Close, Dispose, Settings</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 * @see #syncExec
 * @see #asyncExec
 * @see #wake
 * @see #readAndDispatch
 * @see #sleep
 * @see Device#dispose
 * @see <a href="http://www.eclipse.org/swt/snippets/#display">Display snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Display : Device {

    /* Events Dispatching and Callback */
    int gdkEventCount;
    GdkEvent* [] gdkEvents;
    Widget [] gdkEventWidgets;
    int [] dispatchEvents;
    Event [] eventQueue;
    GPollFD[] fds;
    int allocated_nfds;
    bool wake_state;
    int max_priority, timeout;
    void*/*Callback*/ eventCallback, filterCallback;

    CallbackData*[int] windowProcCallbackDatas; // to prevent GC from collect

    CallbackData  filterProcCallbackData;
    EventTable eventTable, filterTable;
    static String APP_NAME = "SWT"; //$NON-NLS-1$
    static const String DISPATCH_EVENT_KEY = "org.eclipse.swt.internal.gtk.dispatchEvent";
    static const String ADD_WIDGET_KEY = "org.eclipse.swt.internal.addWidget";
    GClosure*[] closures;
    int [] signalIds;

    /* Widget Table */
    ptrdiff_t [] indexTable;
    ptrdiff_t freeSlot;
    GtkWidget* lastHandle;
    Widget lastWidget;
    Widget [] widgetTable;
    const static int GROW_SIZE = 1024;
    static int SWT_OBJECT_INDEX;
    static int SWT_OBJECT_INDEX1;
    static int SWT_OBJECT_INDEX2;

    /* Modality */
    Shell [] modalShells;
    Dialog modalDialog;
    static const String GET_MODAL_DIALOG = "org.eclipse.swt.internal.gtk.getModalDialog"; //$NON-NLS-1$
    static const String SET_MODAL_DIALOG = "org.eclipse.swt.internal.gtk.setModalDialog"; //$NON-NLS-1$

    /* Focus */
    int focusEvent;
    Control focusControl;
    Shell activeShell;
    bool activePending;
    bool ignoreActivate, ignoreFocus;

    /* Input method resources */
    Control imControl;
    GtkWindow* preeditWindow;
    GtkLabel* preeditLabel;

    /* Sync/Async Widget Communication */
    Synchronizer synchronizer;
    Thread thread;

    /* Display Shutdown */
    Runnable [] disposeList;

    /* System Tray */
    Tray tray;

    /* Timers */
    int [] timerIds;
    Runnable [] timerList;
    CallbackData timerProcCallbackData;

    /* Caret */
    Caret currentCaret;
    int caretId;
    CallbackData caretProcCallbackData;

    /* Mnemonics */
    Control mnemonicControl;

    /* Mouse hover */
    int mouseHoverId;
    GtkWidget* mouseHoverHandle;
    CallbackData mouseHoverProcCallbackData;

    /* Menu position callback */

    /* Tooltip size allocate callback */

    /* Shell map callback */
    CallbackData shellMapProcCallbackData;
    GClosure* shellMapProcClosure;

    /* Idle proc callback */
    CallbackData idleProcCallbackData;
    uint idleHandle;
    static const String ADD_IDLE_PROC_KEY = "org.eclipse.swt.internal.gtk.addIdleProc";
    static const String REMOVE_IDLE_PROC_KEY = "org.eclipse.swt.internal.gtk.removeIdleProc";
    Object idleLock;
    bool idleNeeded;

    /* GtkTreeView callbacks */
    int[] treeSelection;
    int treeSelectionLength;

    /* Set direction callback */
    CallbackData setDirectionProcCallbackData;
    static const String GET_DIRECTION_PROC_KEY = "org.eclipse.swt.internal.gtk.getDirectionProc"; //$NON-NLS-1$

    /* Set emissionProc callback */
    CallbackData emissionProcCallbackData;
    static const String GET_EMISSION_PROC_KEY = "org.eclipse.swt.internal.gtk.getEmissionProc"; //$NON-NLS-1$

    /* Get all children callback */
    CallbackData allChildrenProcCallbackData;
    GList* allChildren;

    CallbackData cellDataProcCallbackData;

    /* Settings callbacks */
    GtkWidget* shellHandle;
    bool settingsChanged, runSettingsFld;
    CallbackData styleSetProcCallbackData;

    /* Entry focus behaviour */
    bool entrySelectOnFocus;

    /* Enter/Exit events */
    Control currentControl;

    /* Flush exposes */
    int checkIfEventProc;
    void*/*Callback*/ checkIfEventCallback;
    GdkWindow* flushWindow;
    bool flushAll;
    GdkRectangle* flushRect;
    XExposeEvent* exposeEvent;
    XVisibilityEvent* visibilityEvent;
    //int [] flushData = new int [1];

    /* System Resources */
    Font systemFont;
    Image errorImage, infoImage, questionImage, warningImage;
    Cursor [] cursors;
    Resource [] resources;
    static const int RESOURCE_SIZE = 1 + 4 + SWT.CURSOR_HAND + 1;

    /* Colors */
    GdkColor* COLOR_WIDGET_DARK_SHADOW, COLOR_WIDGET_NORMAL_SHADOW, COLOR_WIDGET_LIGHT_SHADOW;
    GdkColor* COLOR_WIDGET_HIGHLIGHT_SHADOW, COLOR_WIDGET_BACKGROUND, COLOR_WIDGET_FOREGROUND, COLOR_WIDGET_BORDER;
    GdkColor* COLOR_LIST_FOREGROUND, COLOR_LIST_BACKGROUND, COLOR_LIST_SELECTION, COLOR_LIST_SELECTION_TEXT;
    GdkColor* COLOR_INFO_BACKGROUND, COLOR_INFO_FOREGROUND;
    GdkColor* COLOR_TITLE_FOREGROUND, COLOR_TITLE_BACKGROUND, COLOR_TITLE_BACKGROUND_GRADIENT;
    GdkColor* COLOR_TITLE_INACTIVE_FOREGROUND, COLOR_TITLE_INACTIVE_BACKGROUND, COLOR_TITLE_INACTIVE_BACKGROUND_GRADIENT;

    /* Popup Menus */
    Menu [] popups;

    /* Click count*/
    int clickCount = 1;

    /* Timestamp of the Last Received Events */
    int lastEventTime, lastUserEventTime;

    /* Fixed Subclass */
    static ptrdiff_t fixed_type;
    static ptrdiff_t fixed_info_ptr;
    static extern(C) void function(GtkWidget* handle, GtkAllocation* allocation) oldFixedSizeAllocateProc;


    /* Renderer Subclass */
    static ptrdiff_t text_renderer_type, pixbuf_renderer_type, toggle_renderer_type;
    static ptrdiff_t text_renderer_info_ptr, pixbuf_renderer_info_ptr, toggle_renderer_info_ptr;

    /* Key Mappings */
    static const int [] [] KeyTable = [

        /* Keyboard and Mouse Masks */
        [OS.GDK_Alt_L,      SWT.ALT],
        [OS.GDK_Alt_R,      SWT.ALT],
        [OS.GDK_Meta_L, SWT.ALT],
        [OS.GDK_Meta_R, SWT.ALT],
        [OS.GDK_Shift_L,        SWT.SHIFT],
        [OS.GDK_Shift_R,        SWT.SHIFT],
        [OS.GDK_Control_L,  SWT.CONTROL],
        [OS.GDK_Control_R,  SWT.CONTROL],
//      [OS.GDK_????,       SWT.COMMAND],
//      [OS.GDK_????,       SWT.COMMAND],

        /* Non-Numeric Keypad Keys */
        [OS.GDK_Up,                     SWT.ARROW_UP],
        [OS.GDK_KP_Up,                  SWT.ARROW_UP],
        [OS.GDK_Down,                   SWT.ARROW_DOWN],
        [OS.GDK_KP_Down,            SWT.ARROW_DOWN],
        [OS.GDK_Left,                       SWT.ARROW_LEFT],
        [OS.GDK_KP_Left,                SWT.ARROW_LEFT],
        [OS.GDK_Right,                  SWT.ARROW_RIGHT],
        [OS.GDK_KP_Right,               SWT.ARROW_RIGHT],
        [OS.GDK_Page_Up,                SWT.PAGE_UP],
        [OS.GDK_KP_Page_Up,     SWT.PAGE_UP],
        [OS.GDK_Page_Down,          SWT.PAGE_DOWN],
        [OS.GDK_KP_Page_Down,   SWT.PAGE_DOWN],
        [OS.GDK_Home,                   SWT.HOME],
        [OS.GDK_KP_Home,            SWT.HOME],
        [OS.GDK_End,                        SWT.END],
        [OS.GDK_KP_End,             SWT.END],
        [OS.GDK_Insert,                 SWT.INSERT],
        [OS.GDK_KP_Insert,          SWT.INSERT],

        /* Virtual and Ascii Keys */
        [OS.GDK_BackSpace,      SWT.BS],
        [OS.GDK_Return,             SWT.CR],
        [OS.GDK_Delete,             SWT.DEL],
        [OS.GDK_KP_Delete,      SWT.DEL],
        [OS.GDK_Escape,         SWT.ESC],
        [OS.GDK_Linefeed,           SWT.LF],
        [OS.GDK_Tab,                    SWT.TAB],
        [OS.GDK_ISO_Left_Tab,   SWT.TAB],

        /* Functions Keys */
        [OS.GDK_F1,     SWT.F1],
        [OS.GDK_F2,     SWT.F2],
        [OS.GDK_F3,     SWT.F3],
        [OS.GDK_F4,     SWT.F4],
        [OS.GDK_F5,     SWT.F5],
        [OS.GDK_F6,     SWT.F6],
        [OS.GDK_F7,     SWT.F7],
        [OS.GDK_F8,     SWT.F8],
        [OS.GDK_F9,     SWT.F9],
        [OS.GDK_F10,        SWT.F10],
        [OS.GDK_F11,        SWT.F11],
        [OS.GDK_F12,        SWT.F12],
        [OS.GDK_F13,        SWT.F13],
        [OS.GDK_F14,        SWT.F14],
        [OS.GDK_F15,        SWT.F15],

        /* Numeric Keypad Keys */
        [OS.GDK_KP_Multiply,        SWT.KEYPAD_MULTIPLY],
        [OS.GDK_KP_Add,         SWT.KEYPAD_ADD],
        [OS.GDK_KP_Enter,           SWT.KEYPAD_CR],
        [OS.GDK_KP_Subtract,    SWT.KEYPAD_SUBTRACT],
        [OS.GDK_KP_Decimal, SWT.KEYPAD_DECIMAL],
        [OS.GDK_KP_Divide,      SWT.KEYPAD_DIVIDE],
        [OS.GDK_KP_0,           SWT.KEYPAD_0],
        [OS.GDK_KP_1,           SWT.KEYPAD_1],
        [OS.GDK_KP_2,           SWT.KEYPAD_2],
        [OS.GDK_KP_3,           SWT.KEYPAD_3],
        [OS.GDK_KP_4,           SWT.KEYPAD_4],
        [OS.GDK_KP_5,           SWT.KEYPAD_5],
        [OS.GDK_KP_6,           SWT.KEYPAD_6],
        [OS.GDK_KP_7,           SWT.KEYPAD_7],
        [OS.GDK_KP_8,           SWT.KEYPAD_8],
        [OS.GDK_KP_9,           SWT.KEYPAD_9],
        [OS.GDK_KP_Equal,   SWT.KEYPAD_EQUAL],

        /* Other keys */
        [OS.GDK_Caps_Lock,      SWT.CAPS_LOCK],
        [OS.GDK_Num_Lock,       SWT.NUM_LOCK],
        [OS.GDK_Scroll_Lock,        SWT.SCROLL_LOCK],
        [OS.GDK_Pause,              SWT.PAUSE],
        [OS.GDK_Break,              SWT.BREAK],
        [OS.GDK_Print,                  SWT.PRINT_SCREEN],
        [OS.GDK_Help,                   SWT.HELP],

    ];

    /* Multiple Displays. */
    static Display Default;
    static Display [] Displays;

    /* Package name */
    static const String PACKAGE_PREFIX = "org.eclipse.swt.widgets.";
    /* This code is intentionally commented.
     * ".class" can not be used on CLDC.
     */
//  static {
//      String name = Display.class.getName ();
//      int index = name.lastIndexOf ('.');
//      PACKAGE_NAME = name.substring (0, index + 1);
//  }

    static this() {
        Displays = new Display [4];
        initDeviceFinder();
        SWT_OBJECT_INDEX = OS.g_quark_from_string ("SWT_OBJECT_INDEX");
        SWT_OBJECT_INDEX1 = OS.g_quark_from_string ("SWT_OBJECT_INDEX1");
        SWT_OBJECT_INDEX2 = OS.g_quark_from_string ("SWT_OBJECT_INDEX2");
    }

    /* GTK Version */
    static const int MAJOR = 2;
    static const int MINOR = 0;
    static const int MICRO = 6;

    /* Display Data */
    Object data;
    String [] keys;
    Object [] values;

    /* Initial Guesses for Shell Trimmings. */
    int borderTrimWidth = 4, borderTrimHeight = 4;
    int resizeTrimWidth = 6, resizeTrimHeight = 6;
    int titleBorderTrimWidth = 5, titleBorderTrimHeight = 28;
    int titleResizeTrimWidth = 6, titleResizeTrimHeight = 29;
    int titleTrimWidth = 0, titleTrimHeight = 23;
    bool ignoreTrim;

    /* Window Manager */
    String windowManager;

    /*
    * TEMPORARY CODE.  Install the runnable that
    * gets the current display. This code will
    * be removed in the future.
    */
    private static void initDeviceFinder(){
        DeviceFinder = new class() Runnable {
            public void run () {
                Device device = getCurrent ();
                if (device is null) {
                    device = getDefault ();
                }
                setDevice (device);
            }
        };
    }

/*
* TEMPORARY CODE.
*/
static void setDevice (Device device) {
    CurrentDevice = device;
}

/**
 * Constructs a new instance of this class.
 * <p>
 * Note: The resulting display is marked as the <em>current</em>
 * display. If this is the first display which has been
 * constructed since the application started, it is also
 * marked as the <em>default</em> display.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if called from a thread that already created an existing display</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see #getCurrent
 * @see #getDefault
 * @see Widget#checkSubclass
 * @see Shell
 */
public this () {
    this (null);
}

/**
 * Constructs a new instance of this class using the parameter.
 *
 * @param data the device data
 */
public this (DeviceData data) {
    super (data);
    synchronizer = new Synchronizer (this);
    idleLock = new Object();
    flushRect = new GdkRectangle ();
    exposeEvent = new XExposeEvent ();
    visibilityEvent = new XVisibilityEvent ();
    cursors = new Cursor [SWT.CURSOR_HAND + 1];
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when an event of the given type occurs anywhere
 * in a widget. The event type is one of the event constants
 * defined in class <code>SWT</code>. When the event does occur,
 * the listener is notified by sending it the <code>handleEvent()</code>
 * message.
 * <p>
 * Setting the type of an event to <code>SWT.None</code> from
 * within the <code>handleEvent()</code> method can be used to
 * change the event type and stop subsequent Java listeners
 * from running. Because event filters run before other listeners,
 * event filters can both block other listeners and set arbitrary
 * fields within an event. For this reason, event filters are both
 * powerful and dangerous. They should generally be avoided for
 * performance, debugging and code maintenance reasons.
 * </p>
 *
 * @param eventType the type of event to listen for
 * @param listener the listener which should be notified when the event occurs
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Listener
 * @see SWT
 * @see #removeFilter
 * @see #removeListener
 *
 * @since 3.0
 */
public void addFilter (int eventType, Listener listener) {
    checkDevice ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (filterTable is null) filterTable = new EventTable ();
    filterTable.hook (eventType, listener);
}

void addGdkEvent (GdkEvent* event) {
    if (gdkEvents is null) {
        int length = GROW_SIZE;
        gdkEvents.length = length;
        gdkEventWidgets.length = length;
        gdkEventCount = 0;
    }
    if (gdkEventCount is gdkEvents.length) {
        int length = gdkEventCount + GROW_SIZE;
        GdkEvent* [] newEvents = new GdkEvent* [length];
        SimpleType!(GdkEvent*).arraycopy (gdkEvents, 0, newEvents, 0, gdkEventCount);
        gdkEvents = newEvents;
        Widget [] newWidgets = new Widget [length];
        System.arraycopy (gdkEventWidgets, 0, newWidgets, 0, gdkEventCount);
        gdkEventWidgets = newWidgets;
    }
    Widget widget = null;
    GtkWidget* handle = OS.gtk_get_event_widget (event);
    if (handle !is null) {
        do {
            widget = getWidget (handle);
        } while (widget is null && (handle = OS.gtk_widget_get_parent (handle)) !is null);
    }
    gdkEvents [gdkEventCount] = event;
    gdkEventWidgets [gdkEventCount] = widget;
    gdkEventCount++;
}

void addIdleProc() {
    synchronized (idleLock){
        this.idleNeeded = true;
        if (idleHandle is 0) {
            idleProcCallbackData.display = this;
            idleProcCallbackData.data = null;
            idleHandle = OS.g_idle_add ( &idleProcFunc, &idleProcCallbackData );
        }
    }
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when an event of the given type occurs. The event
 * type is one of the event constants defined in class <code>SWT</code>.
 * When the event does occur in the display, the listener is notified by
 * sending it the <code>handleEvent()</code> message.
 *
 * @param eventType the type of event to listen for
 * @param listener the listener which should be notified when the event occurs
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Listener
 * @see SWT
 * @see #removeListener
 *
 * @since 2.0
 */
public void addListener (int eventType, Listener listener) {
    checkDevice ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) eventTable = new EventTable ();
    eventTable.hook (eventType, listener);
}

void allChildrenCollect( GtkWidget* widget, int recurse ){
    allChildrenProcCallbackData.display = this;
    allChildrenProcCallbackData.data = cast(void*)recurse;
    OS.gtk_container_forall (cast(GtkContainer*)widget, cast(GtkCallback)&allChildrenProcFunc, &allChildrenProcCallbackData);
}
private static extern(C) ptrdiff_t allChildrenProcFunc (GtkWidget* handle, void* user_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    CallbackData* cbdata = cast(CallbackData*)user_data;
    return cbdata.display.allChildrenProc( cast(GtkWidget*)handle, cast(int)cbdata.data );
}
ptrdiff_t allChildrenProc (GtkWidget* widget, ptrdiff_t recurse) {
    allChildren = OS.g_list_append (allChildren, widget);
    if (recurse !is 0 && OS.GTK_IS_CONTAINER (cast(GTypeInstance*)widget)) {
        allChildrenProcCallbackData.display = this;
        allChildrenProcCallbackData.data = cast(void*)recurse;
        OS.gtk_container_forall (cast(GtkContainer*)widget, cast(GtkCallback)&allChildrenProcFunc, &allChildrenProcCallbackData);
    }
    return 0;
}

void addMouseHoverTimeout (GtkWidget* handle) {
    if (mouseHoverId !is 0) OS.gtk_timeout_remove (mouseHoverId);
    mouseHoverProcCallbackData.display = this;
    mouseHoverProcCallbackData.data = cast(void*)handle;
    mouseHoverId = OS.gtk_timeout_add (400, &mouseHoverProcFunc, &mouseHoverProcCallbackData);
    mouseHoverHandle = handle;
}

void addPopup (Menu menu) {
    if (popups is null) popups = new Menu [4];
    ptrdiff_t length = popups.length;
    for (int i=0; i<length; i++) {
        if (popups [i] is menu) return;
    }
    int index = 0;
    while (index < length) {
        if (popups [index] is null) break;
        index++;
    }
    if (index is length) {
        Menu [] newPopups = new Menu [length + 4];
        System.arraycopy (popups, 0, newPopups, 0, length);
        popups = newPopups;
    }
    popups [index] = menu;
}

void addWidget (GtkWidget* handle, Widget widget) {
    if (handle is null) return;
    if (freeSlot is -1) {
        ptrdiff_t len = freeSlot = indexTable.length + GROW_SIZE;
        ptrdiff_t[] newIndexTable = new ptrdiff_t[len];
        Widget[] newWidgetTable = new Widget [len];
        System.arraycopy (indexTable, 0, newIndexTable, 0, freeSlot);
        System.arraycopy (widgetTable, 0, newWidgetTable, 0, freeSlot);
        for (ptrdiff_t i = freeSlot; i < len - 1; i++) {
            newIndexTable[i] = i + 1;
        }
        newIndexTable[len - 1] = -1;
        indexTable = newIndexTable;
        widgetTable = newWidgetTable;
    }
    ptrdiff_t index = freeSlot + 1;
    OS.g_object_set_qdata (cast(GObject*)handle, SWT_OBJECT_INDEX, cast(void*)index);
    ptrdiff_t oldSlot = freeSlot;
    freeSlot = indexTable[oldSlot];
    indexTable [oldSlot] = -2;
    widgetTable [oldSlot] = widget;
}

/**
 * Causes the <code>run()</code> method of the runnable to
 * be invoked by the user-interface thread at the next
 * reasonable opportunity. The caller of this method continues
 * to run in parallel, and is not notified when the
 * runnable has completed.  Specifying <code>null</code> as the
 * runnable simply wakes the user-interface thread when run.
 * <p>
 * Note that at the time the runnable is invoked, widgets
 * that have the receiver as their display may have been
 * disposed. Therefore, it is necessary to check for this
 * case inside the runnable before accessing the widget.
 * </p>
 *
 * @param runnable code to run on the user-interface thread or <code>null</code>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #syncExec
 */
public void asyncExec (Runnable runnable) {
    synchronized (Device.classinfo) {
        if (isDisposed ()) error (SWT.ERROR_DEVICE_DISPOSED);
        synchronized (idleLock) {
            if (idleNeeded && idleHandle is 0) {
                //NOTE: calling unlocked function in OS
                idleHandle = OS.g_idle_add (&idleProcFunc, cast(void*) this);
            }
        }
        synchronizer.asyncExec (runnable);
    }
}

/**
 * Causes the system hardware to emit a short sound
 * (if it supports this capability).
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void beep () {
    if (!isValidThread ()) error (SWT.ERROR_THREAD_INVALID_ACCESS);
    OS.gdk_beep();
    if (!OS.GDK_WINDOWING_X11 ()) {
        OS.gdk_flush ();
    } else {
        void* xDisplay = OS.GDK_DISPLAY ();
        OS.XFlush (xDisplay);
    }
}

void doCellDataProc( GtkWidget* widget, GtkTreeViewColumn *tree_column, GtkCellRenderer *cell_renderer ){
    cellDataProcCallbackData.display = this;
    cellDataProcCallbackData.data = widget;
    OS.gtk_tree_view_column_set_cell_data_func ( tree_column, cell_renderer, &cellDataProcFunc, &cellDataProcCallbackData, null );
}

private static extern(C) void cellDataProcFunc (
    GtkTreeViewColumn *tree_column,
    GtkCellRenderer *cell,
    GtkTreeModel *tree_model,
    GtkTreeIter *iter,
    void* data)
{
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    CallbackData* cbdata = cast(CallbackData*)data;
    return cbdata.display.cellDataProc( tree_column, cell, tree_model, iter, cbdata.data );
}

void cellDataProc(
    GtkTreeViewColumn *tree_column,
    GtkCellRenderer *cell,
    GtkTreeModel *tree_model,
    GtkTreeIter *iter,
    void* data)
{
    Widget widget = getWidget (cast(GtkWidget*)data);
    if (widget is null) return;
    widget.cellDataProc (tree_column, cell, tree_model, iter, data);
}

protected override void checkDevice () {
    if (thread is null) error (SWT.ERROR_WIDGET_DISPOSED);
    if (thread !is Thread.currentThread ()) error (SWT.ERROR_THREAD_INVALID_ACCESS);
    if (isDisposed ()) error (SWT.ERROR_DEVICE_DISPOSED);
}

static void checkDisplay (Thread thread, bool multiple) {
    synchronized (Device.classinfo) {
        for (int i=0; i<Displays.length; i++) {
            if (Displays [i] !is null) {
                if (!multiple) SWT.error (SWT.ERROR_NOT_IMPLEMENTED, null, " [multiple displays]"); //$NON-NLS-1$
                if (Displays [i].thread is thread) SWT.error (SWT.ERROR_THREAD_INVALID_ACCESS);
            }
        }
    }
}

private static extern(C) int checkIfEventProcFunc (void* display, XEvent* xEvent, char* userData) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    auto disp = cast(Display)userData;
    return disp.checkIfEventProcMeth( display, xEvent );
}

int checkIfEventProcMeth (void* display, XEvent* xEvent) {
    ptrdiff_t type = xEvent.type;
    switch (type) {
        case OS.VisibilityNotify:
        case OS.Expose:
        case OS.GraphicsExpose:
            break;
        default:
            return 0;
    }
    GdkWindow* window = OS.gdk_window_lookup ( cast(void*)xEvent.xany.window );
    if (window is null) return 0;
    if (flushWindow !is null) {
        if (flushAll) {
            auto tempWindow = window;
            do {
                if (tempWindow is flushWindow) break;
            } while ((tempWindow = OS.gdk_window_get_parent (tempWindow)) !is null);
            if (tempWindow !is flushWindow) return 0;
        } else {
            if (window !is flushWindow) return 0;
        }
    }
    *exposeEvent = *cast(XExposeEvent*)xEvent;
    Widget widget = null;
    GtkWidget* handle = null;
    switch (type) {
        case OS.Expose:
        case OS.GraphicsExpose: {
            flushRect.x = exposeEvent.x;
            flushRect.y = exposeEvent.y;
            flushRect.width = exposeEvent.width;
            flushRect.height = exposeEvent.height;
            OS.gdk_window_invalidate_rect (window, flushRect, true);
            exposeEvent.type = -1;
            OS.memmove (xEvent, exposeEvent, XExposeEvent.sizeof);
            break;
        }
        case OS.VisibilityNotify: {
            OS.memmove (visibilityEvent, xEvent, XVisibilityEvent.sizeof);
            OS.gdk_window_get_user_data (window, cast(void**) & handle);
            widget = handle !is null ? getWidget (handle) : null;
            if (auto control = cast(Control)widget ) {
                if (window is control.paintWindow ()) {
                    if (visibilityEvent.state is OS.VisibilityFullyObscured) {
                        control.state |= Widget.OBSCURED;
                    } else {
                        control.state &= ~Widget.OBSCURED;
                    }
                }
            }
            break;
        default:
        }
    }
    return 0;
}

/**
 * Checks that this class can be subclassed.
 * <p>
 * IMPORTANT: See the comment in <code>Widget.checkSubclass()</code>.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see Widget#checkSubclass
 */
protected void checkSubclass () {
//PORTING_TODO  if (!isValidClass (getClass ())) error (SWT.ERROR_INVALID_SUBCLASS);
}

void clearModal (Shell shell) {
    if (modalShells is null) return;
    ptrdiff_t index = 0, length_ = modalShells.length;
    while (index < length_) {
        if (modalShells [index] is shell) break;
        if (modalShells [index] is null) return;
        index++;
    }
    if (index is length_) return;
    System.arraycopy (modalShells, index + 1, modalShells, index, --length_ - index);
    modalShells [length_] = null;
    if (index is 0 && modalShells [0] is null) modalShells = null;
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) shells [i].updateModal ();
}

/**
 * Requests that the connection between SWT and the underlying
 * operating system be closed.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Device#dispose
 *
 * @since 2.0
 */
public void close () {
    checkDevice ();
    Event event = new Event ();
    sendEvent (SWT.Close, event);
    if (event.doit) dispose ();
}

/**
 * Creates the device in the operating system.  If the device
 * does not have a handle, this method may do nothing depending
 * on the device.
 * <p>
 * This method is called before <code>init</code>.
 * </p>
 *
 * @param data the DeviceData which describes the receiver
 *
 * @see #init
 */
protected override void create (DeviceData data) {
    checkSubclass ();
    checkDisplay(thread = Thread.currentThread (), false);
    createDisplay (data);
    register (this);
    if (Default is null) Default = this;
}

private static extern(C) int XErrorHandler( void*, XErrorEvent* ){
    getDwtLogger().error ( __FILE__, __LINE__, "*** XError" );
    byte* p;
    *p = 3;
    return 0;
}

void createDisplay (DeviceData data) {
    /* Required for g_main_context_wakeup */
    if (!OS.g_thread_supported ()) {
        OS.g_thread_init (null);
    }
    OS.gtk_set_locale();
    int cnt = 2;
    auto args = [ "name".ptr, "--sync".ptr, "".ptr ];
    auto a = args.ptr;
    if (!OS.gtk_init_check (&cnt, &a )) {
    }
    assert( cnt is 1 );
    if (OS.GDK_WINDOWING_X11 ()) xDisplay = cast(void*) OS.GDK_DISPLAY ();

    OS.XSetErrorHandler( &Display.XErrorHandler );
    char* ptr = OS.gtk_check_version (MAJOR, MINOR, MICRO);
    if (ptr !is null) {
        char [] buffer = fromStringz(ptr);
        getDwtLogger().warn (__FILE__, __LINE__,"***WARNING: {}", buffer );
        getDwtLogger().warn (__FILE__, __LINE__,"***WARNING: SWT requires GTK {}.{}.{}", MAJOR, MINOR, MICRO );
        ptrdiff_t major = OS.gtk_major_version (), minor = OS.gtk_minor_version (), micro = OS.gtk_micro_version ();
        getDwtLogger().warn (__FILE__, __LINE__,"***WARNING: Detected: {}.{}.{}", major, minor, micro);
    }
    if (fixed_type is 0) {
        GTypeInfo* fixed_info = new GTypeInfo ();
        fixed_info.class_size = GtkFixedClass.sizeof;
        fixed_info.class_init = & fixedClassInitProcFunc;
        fixed_info.instance_size = GtkFixed.sizeof;
        fixed_type = OS.g_type_register_static (OS.GTK_TYPE_FIXED (), "SwtFixed".ptr, fixed_info, 0);
    }
    if (text_renderer_type is 0) {
        GTypeInfo* renderer_info = new GTypeInfo ();
        renderer_info.class_size = GtkCellRendererTextClass.sizeof;
        renderer_info.class_init = & rendererClassInitProcFunc;
        renderer_info.instance_size = GtkCellRendererText.sizeof;
        text_renderer_type = OS.g_type_register_static (OS.GTK_TYPE_CELL_RENDERER_TEXT (), "SwtTextRenderer".ptr, renderer_info, 0);
    }
    if (pixbuf_renderer_type is 0) {
        GTypeInfo* renderer_info = new GTypeInfo ();
        renderer_info.class_size = GtkCellRendererPixbufClass.sizeof;
        renderer_info.class_init = & rendererClassInitProcFunc;
        renderer_info.instance_size = GtkCellRendererPixbuf.sizeof;
        pixbuf_renderer_type = OS.g_type_register_static (OS.GTK_TYPE_CELL_RENDERER_PIXBUF (), "SwtPixbufRenderer".ptr, renderer_info, 0);
    }
    if (toggle_renderer_type is 0) {
        GTypeInfo* renderer_info = new GTypeInfo ();
        renderer_info.class_size = GtkCellRendererToggleClass.sizeof;
        renderer_info.class_init = & rendererClassInitProcFunc;
        renderer_info.instance_size = GtkCellRendererToggle.sizeof;
        toggle_renderer_type = OS.g_type_register_static (OS.GTK_TYPE_CELL_RENDERER_TOGGLE (), "SwtToggleRenderer".ptr, renderer_info, 0);
    }

    OS.gtk_widget_set_default_direction (OS.GTK_TEXT_DIR_LTR);
    OS.gdk_rgb_init ();
    char* p = toStringz(APP_NAME);
    OS.g_set_prgname (p);
    OS.gdk_set_program_class (p);
    OS.gtk_rc_parse_string ("style \"swt-flat\" { GtkToolbar::shadow-type = none } widget \"*.swt-toolbar-flat\" style : highest \"swt-flat\"".ptr);

    /* Initialize the hidden shell */
    shellHandle = OS.gtk_window_new (OS.GTK_WINDOW_TOPLEVEL);
    if (shellHandle is null) SWT.error (SWT.ERROR_NO_HANDLES);
    OS.gtk_widget_realize (shellHandle);

    /* Initialize the filter and event callback */
    OS.gdk_event_handler_set (&eventProcFunc, cast(void*)this, null);
    //filterProcCallbackData.display = this;
    //filterProcCallbackData.data = null;
    //OS.gdk_window_add_filter  (null, &filterProcFunc, cast(void*)&filterProcCallbackData );
    doWindowAddFilter( &filterProcCallbackData, null, null );
}

/*
 * Used by Shell
 */
package void doWindowAddFilter( CallbackData* cbdata, GdkWindow* window, GtkWidget* widget ){
    cbdata.display = this;
    cbdata.data = widget;
    OS.gdk_window_add_filter (window, &filterProcFunc, cbdata );
}

package void doWindowRemoveFilter( CallbackData* cbdata, GdkWindow* window, GtkWidget* widget ){
    cbdata.display = this;
    cbdata.data = widget;
    OS.gdk_window_remove_filter(window, &filterProcFunc, cbdata );
}

Image createImage (String name) {
    auto style = OS.gtk_widget_get_default_style ();
    String buffer = name;
    auto pixbuf = OS.gtk_icon_set_render_icon (
        OS.gtk_icon_factory_lookup_default (buffer.ptr), style,
        OS.GTK_TEXT_DIR_NONE,
        OS.GTK_STATE_NORMAL,
        OS.GTK_ICON_SIZE_DIALOG, null, null );
    if (pixbuf is null) return null;
    int width = OS.gdk_pixbuf_get_width (pixbuf);
    int height = OS.gdk_pixbuf_get_height (pixbuf);
    int stride = OS.gdk_pixbuf_get_rowstride (pixbuf);
    bool hasAlpha = cast(bool)OS.gdk_pixbuf_get_has_alpha (pixbuf);
    char* pixels = OS.gdk_pixbuf_get_pixels (pixbuf);
    byte [] data = new byte [stride * height];
    OS.memmove (data.ptr, pixels, data.length);
    OS.g_object_unref (pixbuf);
    ImageData imageData = null;
    if (hasAlpha) {
        PaletteData palette = new PaletteData (0xFF000000, 0xFF0000, 0xFF00);
        imageData = new ImageData (width, height, 32, palette);
        byte [] alpha = new byte [stride * height];
        for (int y=0; y<height; y++) {
            for (int x=0; x<width; x++) {
                alpha [y*width+x] = data [y*stride+x*4+3];
                data [y*stride+x*4+3] = 0;
            }
        }
        imageData.setAlphas (0, 0, width * height, alpha, 0);
    } else {
        PaletteData palette = new PaletteData (0xFF0000, 0xFF00, 0xFF);
        imageData = new ImageData (width, height, 24, palette);
    }
    imageData.data = data;
    imageData.bytesPerLine = stride;
    return new Image (this, imageData);
}

static GdkPixbuf* createPixbuf(Image image) {
    int w, h;
    OS.gdk_drawable_get_size (image.pixmap, &w, &h);
    auto colormap = OS.gdk_colormap_get_system ();
    GdkPixbuf* pixbuf;
    bool hasMask = image.mask !is null && OS.gdk_drawable_get_depth (image.mask) is 1;
    if (hasMask) {
        pixbuf = OS.gdk_pixbuf_new (OS.GDK_COLORSPACE_RGB, true, 8, w, h );
        if (pixbuf is null) SWT.error (SWT.ERROR_NO_HANDLES);
        OS.gdk_pixbuf_get_from_drawable (pixbuf, image.pixmap, colormap, 0, 0, 0, 0, w, h);
        auto maskPixbuf = OS.gdk_pixbuf_new(OS.GDK_COLORSPACE_RGB, false, 8, w, h);
        if (maskPixbuf is null) SWT.error (SWT.ERROR_NO_HANDLES);
        OS.gdk_pixbuf_get_from_drawable(maskPixbuf, image.mask, null, 0, 0, 0, 0, w, h);
        int stride = OS.gdk_pixbuf_get_rowstride(pixbuf);
        auto pixels = OS.gdk_pixbuf_get_pixels(pixbuf);
        byte[] line = new byte[stride];
        int maskStride = OS.gdk_pixbuf_get_rowstride(maskPixbuf);
        auto maskPixels = OS.gdk_pixbuf_get_pixels(maskPixbuf);
        byte[] maskLine = new byte[maskStride];
        for (int y=0; y<h; y++) {
            auto offset = pixels + (y * stride);
            OS.memmove(line.ptr, offset, stride);
            auto maskOffset = maskPixels + (y * maskStride);
            OS.memmove(maskLine.ptr, maskOffset, maskStride);
            for (int x=0; x<w; x++) {
                if (maskLine[x * 3] is 0) {
                    line[x * 4 + 3] = 0;
                }
            }
            OS.memmove(offset, line.ptr, stride);
        }
        OS.g_object_unref(maskPixbuf);
    } else {
        ImageData data = image.getImageData ();
        bool hasAlpha = data.getTransparencyType () is SWT.TRANSPARENCY_ALPHA;
        pixbuf = OS.gdk_pixbuf_new (OS.GDK_COLORSPACE_RGB, hasAlpha, 8, w, h);
        if (pixbuf is null) SWT.error (SWT.ERROR_NO_HANDLES);
        OS.gdk_pixbuf_get_from_drawable (pixbuf, image.pixmap, colormap, 0, 0, 0, 0, w, h);
        if (hasAlpha) {
            byte [] alpha = data.alphaData;
            int stride = OS.gdk_pixbuf_get_rowstride (pixbuf);
            auto pixels = OS.gdk_pixbuf_get_pixels (pixbuf);
            byte [] line = new byte [stride];
            for (int y = 0; y < h; y++) {
                auto offset = pixels + (y * stride);
                OS.memmove (line.ptr, offset, stride);
                for (int x = 0; x < w; x++) {
                    line [x*4+3] = alpha [y*w+x];
                }
                OS.memmove (offset, line.ptr, stride);
            }
        }
    }
    return pixbuf;
}

static void deregister (Display display) {
    synchronized (Device.classinfo) {
        for (int i=0; i<Displays.length; i++) {
            if (display is Displays [i]) Displays [i] = null;
        }
    }
}

/**
 * Destroys the device in the operating system and releases
 * the device's handle.  If the device does not have a handle,
 * this method may do nothing depending on the device.
 * <p>
 * This method is called after <code>release</code>.
 * </p>
 * @see Device#dispose
 * @see #release
 */
protected override void destroy () {
    if (this is Default) Default = null;
    deregister (this);
    destroyDisplay ();
}

void destroyDisplay () {
}

static extern(C) int emissionFunc (GSignalInvocationHint* ihint, uint n_param_values, GValue* param_values, void* data) {
    auto cb = cast(CallbackData*)data;
    return cb.display.emissionProc( ihint, n_param_values, param_values, cb.data );
}

int emissionProc (GSignalInvocationHint* ihint, size_t n_param_values, GValue* param_values, void* data) {
    if (OS.gtk_widget_get_toplevel (OS.g_value_peek_pointer(param_values)) is data) {
        OS.gtk_widget_set_direction (OS.g_value_peek_pointer(param_values), OS.GTK_TEXT_DIR_RTL);
    }
    return 1;
}

/**
 * Returns the display which the given thread is the
 * user-interface thread for, or null if the given thread
 * is not a user-interface thread for any display.  Specifying
 * <code>null</code> as the thread will return <code>null</code>
 * for the display.
 *
 * @param thread the user-interface thread
 * @return the display for the given thread
 */
public static Display findDisplay (Thread thread) {
    synchronized (Device.classinfo) {
        for (int i=0; i<Displays.length; i++) {
            Display display = Displays [i];
            if (display !is null && display.thread is thread) {
                return display;
            }
        }
        return null;
    }
}

/**
 * Causes the <code>run()</code> method of the runnable to
 * be invoked by the user-interface thread just before the
 * receiver is disposed.  Specifying a <code>null</code> runnable
 * is ignored.
 *
 * @param runnable code to run at dispose time.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void disposeExec (Runnable runnable) {
    checkDevice ();
    if (disposeList is null) disposeList = new Runnable [4];
    for (int i=0; i<disposeList.length; i++) {
        if (disposeList [i] is null) {
            disposeList [i] = runnable;
            return;
        }
    }
    Runnable [] newDisposeList = new Runnable [disposeList.length + 4];
    SimpleType!(Runnable).arraycopy (disposeList, 0, newDisposeList, 0, disposeList.length);
    newDisposeList [disposeList.length] = runnable;
    disposeList = newDisposeList;
}

/**
 * Does whatever display specific cleanup is required, and then
 * uses the code in <code>SWTError.error</code> to handle the error.
 *
 * @param code the descriptive error code
 *
 * @see SWTError#error
 */
void error (int code) {
    SWT.error (code);
}

private static extern(C) void eventProcFunc (GdkEvent* event, void* data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    Display disp = cast(Display)data;
    disp.eventProcMeth(event);
}
void eventProcMeth (GdkEvent* event) {
    /*
    * Use gdk_event_get_time() rather than event.time or
    * gtk_get_current_event_time().  If the event does not
    * have a time stamp, then the field will contain garbage.
    * Note that calling gtk_get_current_event_time() from
    * outside of gtk_main_do_event() seems to always
    * return zero.
    */
    int time = OS.gdk_event_get_time (event);
    if (time !is 0) lastEventTime = time;

    int eventType = OS.GDK_EVENT_TYPE (event);
    switch (eventType) {
        case OS.GDK_BUTTON_PRESS:
        case OS.GDK_KEY_PRESS:
            lastUserEventTime = time;
            break;
        default:
            break;
    }
    bool dispatch = true;
    if (dispatchEvents !is null) {
        dispatch = false;
        for (int i = 0; i < dispatchEvents.length; i++) {
            if (eventType is dispatchEvents [i]) {
                dispatch = true;
                break;
            }
        }
    }
    if (!dispatch) {
        addGdkEvent (OS.gdk_event_copy (event));
        return;
    }
    OS.gtk_main_do_event (event);
    if (dispatchEvents is null) putGdkEvents ();
}

/**
 * Given the operating system handle for a widget, returns
 * the instance of the <code>Widget</code> subclass which
 * represents it in the currently running application, if
 * such exists, or null if no matching widget can be found.
 * <p>
 * <b>IMPORTANT:</b> This method should not be called from
 * application code. The arguments are platform-specific.
 * </p>
 *
 * @param handle the handle for the widget
 * @return the SWT widget that the handle represents
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Widget findWidget (GtkWidget* handle) {
    checkDevice ();
    return getWidget (handle);
}

/**
 * Given the operating system handle for a widget,
 * and widget-specific id, returns the instance of
 * the <code>Widget</code> subclass which represents
 * the handle/id pair in the currently running application,
 * if such exists, or null if no matching widget can be found.
 * <p>
 * <b>IMPORTANT:</b> This method should not be called from
 * application code. The arguments are platform-specific.
 * </p>
 *
 * @param handle the handle for the widget
 * @param id the id for the subwidget (usually an item)
 * @return the SWT widget that the handle/id pair represents
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public Widget findWidget (GtkWidget* handle, int id) {
    checkDevice ();
    return null;
}

/**
 * Given a widget and a widget-specific id, returns the
 * instance of the <code>Widget</code> subclass which represents
 * the widget/id pair in the currently running application,
 * if such exists, or null if no matching widget can be found.
 *
 * @param widget the widget
 * @param id the id for the subwidget (usually an item)
 * @return the SWT subwidget (usually an item) that the widget/id pair represents
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.3
 */
public Widget findWidget (Widget widget, ptrdiff_t id) {
    checkDevice ();
    return null;
}

private static extern(C) void fixedClassInitProcFunc (void* g_class, void* class_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    GtkWidgetClass* klass = cast(GtkWidgetClass*)g_class;
    klass.map = &fixedMapProcFunc;
    oldFixedSizeAllocateProc = klass.size_allocate;
    klass.size_allocate = &fixedSizeAllocateProc;
}

private static extern(C) void fixedMapProcFunc (GtkWidget * handle) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    Display display = getCurrent ();
    Widget widget = display.getWidget (handle);
    if (widget !is null) widget.fixedMapProc (handle);
}

private static extern(C) void fixedSizeAllocateProc (GtkWidget* handle, GtkAllocation* allocation) {
    Display display = getCurrent ();
    Widget widget = display.getWidget (handle);
    if (widget !is null) return widget.fixedSizeAllocateProc (handle, allocation);
    return oldFixedSizeAllocateProc(handle, allocation);
}

private static extern(C) void rendererClassInitProcFunc (void* g_class, void* class_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    GtkCellRendererClass* klass = cast(GtkCellRendererClass*)g_class;
    klass.render = &rendererRenderProcFunc;
    klass.get_size = &rendererGetSizeProcFunc;

}
private static extern(C) void rendererGetSizeProcFunc(
    GtkCellRenderer      *cell,
    GtkWidget            *handle,
    GdkRectangle         *cell_area,
    int                  *x_offset,
    int                  *y_offset,
    int                  *width,
    int                  *height)
{
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    Display display = getCurrent ();
    Widget widget = display.getWidget (handle);
    if (widget !is null) widget.rendererGetSizeProc (cell, handle, cell_area, x_offset, y_offset, width, height);
}
private static extern(C) void rendererRenderProcFunc(GtkCellRenderer * cell, GdkDrawable * window, GtkWidget * handle, GdkRectangle *background_area, GdkRectangle *cell_area, GdkRectangle *expose_area, int flags){
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    Display display = getCurrent ();
    Widget widget = display.getWidget (handle);
    if (widget !is null) widget.rendererRenderProc (cell, window, handle, background_area, cell_area, expose_area, flags);
}

void flushExposes (GdkWindow* window, bool all) {
    OS.gdk_flush ();
    OS.gdk_flush ();
    if (OS.GDK_WINDOWING_X11 ()) {
        this.flushWindow = window;
        this.flushAll = all;
        auto xDisplay = OS.GDK_DISPLAY ();
        auto xEvent = cast(XEvent*)OS.g_malloc (XEvent.sizeof);
        OS.XCheckIfEvent (xDisplay, xEvent, &checkIfEventProcFunc, cast(char*)this );
        OS.g_free (xEvent);
        this.flushWindow = null;
    }
}

/**
 * Returns the currently active <code>Shell</code>, or null
 * if no shell belonging to the currently running application
 * is active.
 *
 * @return the active shell or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Shell getActiveShell () {
    checkDevice ();
    return activeShell;
}

/**
 * Returns a rectangle describing the receiver's size and location. Note that
 * on multi-monitor systems the origin can be negative.
 *
 * @return the bounding rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public override Rectangle getBounds () {
    checkDevice ();
    return new Rectangle (0, 0, OS.gdk_screen_width (), OS.gdk_screen_height ());
}

/**
 * Returns the display which the currently running thread is
 * the user-interface thread for, or null if the currently
 * running thread is not a user-interface thread for any display.
 *
 * @return the current display
 */
public static Display getCurrent () {
    return findDisplay (Thread.currentThread ());
}

int getCaretBlinkTime () {
//  checkDevice ();
    auto settings = OS.gtk_settings_get_default ();
    if (settings is null) return 500;
    int  buffer;
    OS.g_object_get1 (settings, OS.gtk_cursor_blink.ptr, &buffer );
    if (buffer  is 0) return 0;
    OS.g_object_get1 (settings, OS.gtk_cursor_blink_time.ptr, &buffer);
    if (buffer  is 0) return 500;
    /*
    * By experimentation, GTK application don't use the whole
    * blink cycle time.  Instead, they divide up the time, using
    * an effective blink rate of about 1/2 the total time.
    */
    return buffer / 2;
}

/**
 * Returns the control which the on-screen pointer is currently
 * over top of, or null if it is not currently over one of the
 * controls built by the currently running application.
 *
 * @return the control under the cursor
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Control getCursorControl () {
    checkDevice();
    int x, y;
    GtkWidget* handle;
    GtkWidget* user_data;
    auto window = OS.gdk_window_at_pointer (&x, &y);
    if (window !is null) {
        OS.gdk_window_get_user_data (window, cast(void**)&user_data);
        handle = user_data;
    } else {
        /*
        * Feature in GTK. gdk_window_at_pointer() will not return a window
        * if the pointer is over a foreign embedded window. The fix is to use
        * XQueryPointer to find the containing GDK window.
        */
        if (!OS.GDK_WINDOWING_X11 ()) return null;
        OS.gdk_error_trap_push ();
        int unusedInt;
        uint unusedUInt;
        size_t unusedPtr;
        size_t buffer;
        size_t xWindow, xParent = OS.XDefaultRootWindow (xDisplay);
        do {
            if (OS.XQueryPointer (xDisplay, xParent, &unusedPtr, &buffer, &unusedInt, &unusedInt, &unusedInt, &unusedInt, &unusedUInt) is 0) {
                handle = null;
                break;
            }
            if ((xWindow = buffer) !is 0) {
                xParent = xWindow;
                auto gdkWindow = OS.gdk_window_lookup (cast(void*)xWindow);
                if (gdkWindow !is null) {
                    OS.gdk_window_get_user_data (gdkWindow, cast(void**)&user_data);
                    if (user_data !is null) handle = user_data;
                }
            }
        } while (xWindow !is 0);
        OS.gdk_error_trap_pop ();
    }
    if (handle is null) return null;
    do {
        Widget widget = getWidget (handle);
        if (widget !is null && (null !is cast(Control)widget)) {
            Control control = cast(Control) widget;
            if (control.isEnabled ()) return control;
        }
    } while ((handle = OS.gtk_widget_get_parent (handle)) !is null);
    return null;
}

bool filterEvent (Event event) {
    if (filterTable !is null) filterTable.sendEvent (event);
    return false;
}

bool filters (int eventType) {
    if (filterTable is null) return false;
    return filterTable.hooks (eventType);
}

private static extern(C) int filterProcFunc (GdkXEvent* xEvent, GdkEvent* gdkEvent, void* data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    auto callbackdata = cast(CallbackData*)data;
    auto disp = callbackdata.display;
    if( disp is null ) return 0;
    auto res =  disp.filterProcMeth(xEvent,gdkEvent,callbackdata);
    return res;
}

int filterProcMeth (GdkXEvent* xEvent, GdkEvent* gdkEvent, CallbackData* callbackData) {
    if( callbackData.data is null ){
        /*
         * Feature in GTK.  When button 4, 5, 6, or 7 is released, GTK
         * does not deliver a corresponding GTK event.  Button 6 and 7
         * are mapped to buttons 4 and 5 in SWT.  The fix is to change
         * the button number of the event to a negative number so that
         * it gets dispatched by GTK.  SWT has been modified to look
         * for negative button numbers.
         */
        XButtonEvent* mouseEvent = cast(XButtonEvent*) xEvent;
        if (mouseEvent.type is OS.ButtonRelease) {
            switch (mouseEvent.button) {
                case 6:
                case 7:
                    mouseEvent.button = -mouseEvent.button;
                    break;
                default:
            }
        }
    }
    Widget widget = getWidget (cast(GtkWidget*)callbackData.data);
    if (widget is null) return 0;
    return widget.filterProc (cast(XEvent*)xEvent, gdkEvent, callbackData.data);
}

/**
 * Returns the location of the on-screen pointer relative
 * to the top left corner of the screen.
 *
 * @return the cursor location
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Point getCursorLocation () {
    checkDevice ();
    int x, y;
    OS.gdk_window_get_pointer (null, &x, &y, null);
    return new Point (x, y);
}

/**
 * Returns an array containing the recommended cursor sizes.
 *
 * @return the array of cursor sizes
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public Point [] getCursorSizes () {
    checkDevice ();
    return [new Point (16, 16), new Point (32, 32)];
}

/**
 * Returns the application defined property of the receiver
 * with the specified name, or null if it has not been set.
 * <p>
 * Applications may have associated arbitrary objects with the
 * receiver in this fashion. If the objects stored in the
 * properties need to be notified when the display is disposed
 * of, it is the application's responsibility to provide a
 * <code>disposeExec()</code> handler which does so.
 * </p>
 *
 * @param key the name of the property
 * @return the value of the property or null if it has not been set
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setData(String, Object)
 * @see #disposeExec(Runnable)
 */
public Object getData (String key) {
    checkDevice ();
    // SWT extension: allow null for zero length string
    //if (key is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (key.equals (DISPATCH_EVENT_KEY)) {
        return new ArrayWrapperInt(dispatchEvents);
    }
    if (key.equals (GET_MODAL_DIALOG)) {
        return modalDialog;
    }
    if (key.equals (GET_DIRECTION_PROC_KEY)) {
        return new LONG (cast(int) &setDirectionProcFunc);
    }
    if (key.equals (GET_EMISSION_PROC_KEY)) {
        return new LONG (cast(int) &emissionFunc);
    }
    if (keys is null) return null;
    for (int i=0; i<keys.length; i++) {
        if (keys [i].equals(key)) return values [i];
    }
    return null;
}

/**
 * Returns the application defined, display specific data
 * associated with the receiver, or null if it has not been
 * set. The <em>display specific data</em> is a single,
 * unnamed field that is stored with every display.
 * <p>
 * Applications may put arbitrary objects in this field. If
 * the object stored in the display specific data needs to
 * be notified when the display is disposed of, it is the
 * application's responsibility to provide a
 * <code>disposeExec()</code> handler which does so.
 * </p>
 *
 * @return the display specific data
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #setData(Object)
 * @see #disposeExec(Runnable)
 */
public Object getData () {
    checkDevice ();
    return data;
}

/**
 * Returns a point whose x coordinate is the horizontal
 * dots per inch of the display, and whose y coordinate
 * is the vertical dots per inch of the display.
 *
 * @return the horizontal and vertical DPI
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public override Point getDPI () {
    checkDevice ();
    int widthMM = OS.gdk_screen_width_mm ();
    int width = OS.gdk_screen_width ();
    int dpi = Compatibility.round (254 * width, widthMM * 10);
    return new Point (dpi, dpi);
}

ptrdiff_t gtk_fixed_get_type () {
    return fixed_type;
}

ptrdiff_t gtk_cell_renderer_text_get_type () {
    return text_renderer_type;
}

ptrdiff_t gtk_cell_renderer_pixbuf_get_type () {
    return pixbuf_renderer_type;
}

ptrdiff_t gtk_cell_renderer_toggle_get_type () {
    return toggle_renderer_type;
}

/**
 * Returns the default display. One is created (making the
 * thread that invokes this method its user-interface thread)
 * if it did not already exist.
 *
 * @return the default display
 */
public static Display getDefault () {
    synchronized (Device.classinfo) {
        if (Default is null) Default = new Display ();
        return Default;
    }
}

// /+static bool isValidClass (Class clazz) {
// //PORTING_TODO   String name = clazz.getName ();
// //PORTING_TODO   int index = name.lastIndexOf ('.');
// //PORTING_TODO   return name.substring (0, index + 1)==/*eq*/ PACKAGE_PREFIX;
//     return true;
// }+/

/**
 * Returns the button dismissal alignment, one of <code>LEFT</code> or <code>RIGHT</code>.
 * The button dismissal alignment is the ordering that should be used when positioning the
 * default dismissal button for a dialog.  For example, in a dialog that contains an OK and
 * CANCEL button, on platforms where the button dismissal alignment is <code>LEFT</code>, the
 * button ordering should be OK/CANCEL.  When button dismissal alignment is <code>RIGHT</code>,
 * the button ordering should be CANCEL/OK.
 *
 * @return the button dismissal order
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.1
 */
public int getDismissalAlignment () {
    checkDevice ();
    return SWT.RIGHT;
}

/**
 * Returns the longest duration, in milliseconds, between
 * two mouse button clicks that will be considered a
 * <em>double click</em> by the underlying operating system.
 *
 * @return the double click time
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public int getDoubleClickTime () {
    checkDevice ();
    auto settings = OS.gtk_settings_get_default ();
    int buffer;
    OS.g_object_get1 (settings, OS.gtk_double_click_time.ptr, &buffer);
    return buffer;
}

/**
 * Returns the control which currently has keyboard focus,
 * or null if keyboard events are not currently going to
 * any of the controls built by the currently running
 * application.
 *
 * @return the control under the cursor
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Control getFocusControl () {
    checkDevice ();
    if (focusControl !is null && !focusControl.isDisposed ()) {
        return focusControl;
    }
    if (activeShell is null) return null;
    auto shellHandle = activeShell.shellHandle;
    auto handle = OS.gtk_window_get_focus (cast(GtkWindow*)shellHandle);
    if (handle is null) return null;
    do {
        Widget widget = getWidget (handle);
        if (widget !is null && (null !is cast(Control)widget)) {
            Control control = cast(Control) widget;
            return control.isEnabled () ? control : null;
        }
    } while ((handle = OS.gtk_widget_get_parent (handle)) !is null);
    return null;
}

/**
 * Returns true when the high contrast mode is enabled.
 * Otherwise, false is returned.
 * <p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept.
 * </p>
 *
 * @return the high contrast mode
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public bool getHighContrast () {
    checkDevice ();
    return false;
}

public override int getDepth () {
    checkDevice ();
    auto visual = OS.gdk_visual_get_system();
    return visual.depth;
}

/**
 * Returns the maximum allowed depth of icons on this display, in bits per pixel.
 * On some platforms, this may be different than the actual depth of the display.
 *
 * @return the maximum icon depth
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Device#getDepth
 */
public int getIconDepth () {
    checkDevice ();
    return getDepth ();
}

/**
 * Returns an array containing the recommended icon sizes.
 *
 * @return the array of icon sizes
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Decorations#setImages(Image[])
 *
 * @since 3.0
 */
public Point [] getIconSizes () {
    checkDevice ();
    return [new Point (16, 16), new Point (32, 32)];
}

int getLastEventTime () {
    return lastEventTime;
}

int getMessageCount () {
    return synchronizer.getMessageCount ();
}

Dialog getModalDialog () {
    return modalDialog;
}

/**
 * Returns the work area, an EWMH property to store the size
 * and position of the screen not covered by dock and panel
 * windows.  See http://freedesktop.org/Standards/wm-spec.
 */
Rectangle getWorkArea() {
    auto atom = OS.gdk_atom_intern ("_NET_WORKAREA".ptr, true);
    if (atom is null/*OS.GDK_NONE*/) return null;
    void* actualType;
    int actualFormat;
    int actualLength;
    char* data;
    if (!OS.gdk_property_get (cast(GdkDrawable*)OS.GDK_ROOT_PARENT (), atom, null/*OS.GDK_NONE*/, 0, 16, 0, &actualType, &actualFormat, &actualLength, &data)) {
        return null;
    }
    Rectangle result = null;
    if (data !is null) {
        if (actualLength is 16) {
            int[] values = (cast(int*)data)[0..4];
            result = new Rectangle (values [0],values [1],values [2],values [3]);
        } else if (actualLength is 32) {
            long[] values = (cast(long*)data)[0..4];
            result = new Rectangle (cast(int)values [0],cast(int)values [1],cast(int)values [2],cast(int)values [3]);
        }
        OS.g_free (data);
    }
    return result;
}

/**
 * Returns an array of monitors attached to the device.
 *
 * @return the array of monitors
 *
 * @since 3.0
 */
public org.eclipse.swt.widgets.Monitor.Monitor [] getMonitors () {
    checkDevice ();
    org.eclipse.swt.widgets.Monitor.Monitor [] monitors = null;
    Rectangle workArea = getWorkArea();
    auto screen = OS.gdk_screen_get_default ();
    if (screen !is null) {
        int monitorCount = OS.gdk_screen_get_n_monitors (screen);
        if (monitorCount > 0) {
            monitors = new org.eclipse.swt.widgets.Monitor.Monitor [monitorCount];
            GdkRectangle* dest = new GdkRectangle ();
            for (int i = 0; i < monitorCount; i++) {
                OS.gdk_screen_get_monitor_geometry (screen, i, dest);
                auto monitor = new org.eclipse.swt.widgets.Monitor.Monitor ();
                monitor.handle = i;
                monitor.x = dest.x;
                monitor.y = dest.y;
                monitor.width = dest.width;
                monitor.height = dest.height;
                if (i is 0 && workArea !is null) {
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
                monitors [i] = monitor;
            }
        }
    }
    if (monitors is null) {
        /* No multimonitor support detected, default to one monitor */
        auto monitor = new org.eclipse.swt.widgets.Monitor.Monitor ();
        Rectangle bounds = getBounds ();
        monitor.x = bounds.x;
        monitor.y = bounds.y;
        monitor.width = bounds.width;
        monitor.height = bounds.height;
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
        monitors = [ monitor ];
    }
    return monitors;
}

/**
 * Returns the primary monitor for that device.
 *
 * @return the primary monitor
 *
 * @since 3.0
 */
public org.eclipse.swt.widgets.Monitor.Monitor getPrimaryMonitor () {
    checkDevice ();
    auto monitors = getMonitors ();
    return monitors [0];
}

/**
 * Returns a (possibly empty) array containing all shells which have
 * not been disposed and have the receiver as their display.
 *
 * @return the receiver's shells
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Shell [] getShells () {
    checkDevice ();
    int index = 0;
    Shell [] result = new Shell [16];
    for (int i = 0; i < widgetTable.length; i++) {
        Widget widget = widgetTable [i];
        if (widget !is null && (null !is cast(Shell)widget)) {
            int j = 0;
            while (j < index) {
                if (result [j] is widget) break;
                j++;
            }
            if (j is index) {
                if (index is result.length) {
                    Shell [] newResult = new Shell [index + 16];
                    System.arraycopy (result, 0, newResult, 0, index);
                    result = newResult;
                }
                result [index++] = cast(Shell) widget;
            }
        }
    }
    if (index is result.length) return result;
    Shell [] newResult = new Shell [index];
    System.arraycopy (result, 0, newResult, 0, index);
    return newResult;
}

/**
 * Gets the synchronizer used by the display.
 *
 * @return the receiver's synchronizer
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.4
 */
public Synchronizer getSynchronizer () {
    checkDevice ();
    return synchronizer;
}

/**
 * Returns the thread that has invoked <code>syncExec</code>
 * or null if no such runnable is currently being invoked by
 * the user-interface thread.
 * <p>
 * Note: If a runnable invoked by asyncExec is currently
 * running, this method will return null.
 * </p>
 *
 * @return the receiver's sync-interface thread
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Thread getSyncThread () {
    synchronized (Device.classinfo) {
        if (isDisposed ()) error (SWT.ERROR_DEVICE_DISPOSED);
        return synchronizer.syncThread;
    }
}

/**
 * Returns the matching standard color for the given
 * constant, which should be one of the color constants
 * specified in class <code>SWT</code>. Any value other
 * than one of the SWT color constants which is passed
 * in will result in the color black. This color should
 * not be free'd because it was allocated by the system,
 * not the application.
 *
 * @param id the color constant
 * @return the matching color
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see SWT
 */
public override Color getSystemColor (int id) {
    checkDevice ();
    GdkColor* gdkColor = null;
    switch (id) {
        case SWT.COLOR_INFO_FOREGROUND:                     gdkColor = COLOR_INFO_FOREGROUND; break;
        case SWT.COLOR_INFO_BACKGROUND:                     gdkColor = COLOR_INFO_BACKGROUND; break;
        case SWT.COLOR_TITLE_FOREGROUND:                    gdkColor = COLOR_TITLE_FOREGROUND; break;
        case SWT.COLOR_TITLE_BACKGROUND:                    gdkColor = COLOR_TITLE_BACKGROUND; break;
        case SWT.COLOR_TITLE_BACKGROUND_GRADIENT:           gdkColor = COLOR_TITLE_BACKGROUND_GRADIENT; break;
        case SWT.COLOR_TITLE_INACTIVE_FOREGROUND:           gdkColor = COLOR_TITLE_INACTIVE_FOREGROUND; break;
        case SWT.COLOR_TITLE_INACTIVE_BACKGROUND:           gdkColor = COLOR_TITLE_INACTIVE_BACKGROUND; break;
        case SWT.COLOR_TITLE_INACTIVE_BACKGROUND_GRADIENT:  gdkColor = COLOR_TITLE_INACTIVE_BACKGROUND_GRADIENT; break;
        case SWT.COLOR_WIDGET_DARK_SHADOW:                  gdkColor = COLOR_WIDGET_DARK_SHADOW; break;
        case SWT.COLOR_WIDGET_NORMAL_SHADOW:                gdkColor = COLOR_WIDGET_NORMAL_SHADOW; break;
        case SWT.COLOR_WIDGET_LIGHT_SHADOW:                 gdkColor = COLOR_WIDGET_LIGHT_SHADOW; break;
        case SWT.COLOR_WIDGET_HIGHLIGHT_SHADOW:             gdkColor = COLOR_WIDGET_HIGHLIGHT_SHADOW; break;
        case SWT.COLOR_WIDGET_BACKGROUND:                   gdkColor = COLOR_WIDGET_BACKGROUND; break;
        case SWT.COLOR_WIDGET_FOREGROUND:                   gdkColor = COLOR_WIDGET_FOREGROUND; break;
        case SWT.COLOR_WIDGET_BORDER:                       gdkColor = COLOR_WIDGET_BORDER; break;
        case SWT.COLOR_LIST_FOREGROUND:                     gdkColor = COLOR_LIST_FOREGROUND; break;
        case SWT.COLOR_LIST_BACKGROUND:                     gdkColor = COLOR_LIST_BACKGROUND; break;
        case SWT.COLOR_LIST_SELECTION:                      gdkColor = COLOR_LIST_SELECTION; break;
        case SWT.COLOR_LIST_SELECTION_TEXT:                 gdkColor = COLOR_LIST_SELECTION_TEXT; break;
        default:
            return super.getSystemColor (id);
    }
    if (gdkColor is null) return super.getSystemColor (SWT.COLOR_BLACK);
    return Color.gtk_new (this, gdkColor);
}

/**
 * Returns the matching standard platform cursor for the given
 * constant, which should be one of the cursor constants
 * specified in class <code>SWT</code>. This cursor should
 * not be free'd because it was allocated by the system,
 * not the application.  A value of <code>null</code> will
 * be returned if the supplied constant is not an SWT cursor
 * constant.
 *
 * @param id the SWT cursor constant
 * @return the corresponding cursor or <code>null</code>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see SWT#CURSOR_ARROW
 * @see SWT#CURSOR_WAIT
 * @see SWT#CURSOR_CROSS
 * @see SWT#CURSOR_APPSTARTING
 * @see SWT#CURSOR_HELP
 * @see SWT#CURSOR_SIZEALL
 * @see SWT#CURSOR_SIZENESW
 * @see SWT#CURSOR_SIZENS
 * @see SWT#CURSOR_SIZENWSE
 * @see SWT#CURSOR_SIZEWE
 * @see SWT#CURSOR_SIZEN
 * @see SWT#CURSOR_SIZES
 * @see SWT#CURSOR_SIZEE
 * @see SWT#CURSOR_SIZEW
 * @see SWT#CURSOR_SIZENE
 * @see SWT#CURSOR_SIZESE
 * @see SWT#CURSOR_SIZESW
 * @see SWT#CURSOR_SIZENW
 * @see SWT#CURSOR_UPARROW
 * @see SWT#CURSOR_IBEAM
 * @see SWT#CURSOR_NO
 * @see SWT#CURSOR_HAND
 *
 * @since 3.0
 */
public Cursor getSystemCursor (int id) {
    checkDevice ();
    if (!(0 <= id && id < cursors.length)) return null;
    if (cursors [id] is null) {
        cursors [id] = new Cursor (this, id);
    }
    return cursors [id];
}

/**
 * Returns the matching standard platform image for the given
 * constant, which should be one of the icon constants
 * specified in class <code>SWT</code>. This image should
 * not be free'd because it was allocated by the system,
 * not the application.  A value of <code>null</code> will
 * be returned either if the supplied constant is not an
 * SWT icon constant or if the platform does not define an
 * image that corresponds to the constant.
 *
 * @param id the SWT icon constant
 * @return the corresponding image or <code>null</code>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see SWT#ICON_ERROR
 * @see SWT#ICON_INFORMATION
 * @see SWT#ICON_QUESTION
 * @see SWT#ICON_WARNING
 * @see SWT#ICON_WORKING
 *
 * @since 3.0
 */
public Image getSystemImage (int id) {
    checkDevice ();
    switch (id) {
        case SWT.ICON_ERROR:
            if (errorImage is null) {
                errorImage = createImage ("gtk-dialog-error"); //$NON-NLS-1$
            }
            return errorImage;
        case SWT.ICON_INFORMATION:
        case SWT.ICON_WORKING:
            if (infoImage is null) {
                infoImage = createImage ("gtk-dialog-info"); //$NON-NLS-1$
            }
            return infoImage;
        case SWT.ICON_QUESTION:
            if (questionImage is null) {
                questionImage = createImage ("gtk-dialog-question"); //$NON-NLS-1$
            }
            return questionImage;
        case SWT.ICON_WARNING:
            if (warningImage is null) {
                warningImage = createImage ("gtk-dialog-warning"); //$NON-NLS-1$
            }
            return warningImage;
        default:
    }
    return null;
}

void initializeSystemColors () {
    GdkColor* gdkColor;

    /* Get Tooltip resources */
    auto tooltipShellHandle = OS.gtk_window_new (OS.GTK_WINDOW_POPUP);
    if (tooltipShellHandle is null) SWT.error (SWT.ERROR_NO_HANDLES);
//  byte[] gtk_tooltips = Converter.wcsToMbcs (null, "gtk-tooltips", true);
    OS.gtk_widget_set_name (tooltipShellHandle, "gtk-tooltips".ptr );
    OS.gtk_widget_realize (tooltipShellHandle);
    auto tooltipStyle = OS.gtk_widget_get_style (tooltipShellHandle);
    gdkColor = new GdkColor();
    OS.gtk_style_get_fg (tooltipStyle, OS.GTK_STATE_NORMAL, gdkColor);
    COLOR_INFO_FOREGROUND = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_bg (tooltipStyle, OS.GTK_STATE_NORMAL, gdkColor);
    COLOR_INFO_BACKGROUND = gdkColor;
    OS.gtk_widget_destroy (tooltipShellHandle);

    /* Get Shell resources */
    auto style = OS.gtk_widget_get_style (shellHandle);
    gdkColor = new GdkColor();
    OS.gtk_style_get_black (style, gdkColor);
    COLOR_WIDGET_DARK_SHADOW = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_dark (style, OS.GTK_STATE_NORMAL, gdkColor);
    COLOR_WIDGET_NORMAL_SHADOW = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_bg (style, OS.GTK_STATE_NORMAL, gdkColor);
    COLOR_WIDGET_LIGHT_SHADOW = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_light (style, OS.GTK_STATE_NORMAL, gdkColor);
    COLOR_WIDGET_HIGHLIGHT_SHADOW = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_fg (style, OS.GTK_STATE_NORMAL, gdkColor);
    COLOR_WIDGET_FOREGROUND = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_bg (style, OS.GTK_STATE_NORMAL, gdkColor);
    COLOR_WIDGET_BACKGROUND = gdkColor;
    //gdkColor = new GdkColor();
    //OS.gtk_style_get_text (style, OS.GTK_STATE_NORMAL, gdkColor);
    //COLOR_TEXT_FOREGROUND = gdkColor;
    //gdkColor = new GdkColor();
    //OS.gtk_style_get_base (style, OS.GTK_STATE_NORMAL, gdkColor);
    //COLOR_TEXT_BACKGROUND = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_text (style, OS.GTK_STATE_NORMAL, gdkColor);
    COLOR_LIST_FOREGROUND = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_base (style, OS.GTK_STATE_NORMAL, gdkColor);
    COLOR_LIST_BACKGROUND = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_text (style, OS.GTK_STATE_SELECTED, gdkColor);
    COLOR_LIST_SELECTION_TEXT = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_base (style, OS.GTK_STATE_SELECTED, gdkColor);
    COLOR_LIST_SELECTION = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_bg (style, OS.GTK_STATE_SELECTED, gdkColor);
    COLOR_TITLE_BACKGROUND = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_fg (style, OS.GTK_STATE_SELECTED, gdkColor);
    COLOR_TITLE_FOREGROUND = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_light (style, OS.GTK_STATE_SELECTED, gdkColor);
    COLOR_TITLE_BACKGROUND_GRADIENT = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_bg (style, OS.GTK_STATE_INSENSITIVE, gdkColor);
    COLOR_TITLE_INACTIVE_BACKGROUND = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_fg (style, OS.GTK_STATE_INSENSITIVE, gdkColor);
    COLOR_TITLE_INACTIVE_FOREGROUND = gdkColor;
    gdkColor = new GdkColor();
    OS.gtk_style_get_light (style, OS.GTK_STATE_INSENSITIVE, gdkColor);
    COLOR_TITLE_INACTIVE_BACKGROUND_GRADIENT = gdkColor;
}

/**
 * Returns a reasonable font for applications to use.
 * On some platforms, this will match the "default font"
 * or "system font" if such can be found.  This font
 * should not be free'd because it was allocated by the
 * system, not the application.
 * <p>
 * Typically, applications which want the default look
 * should simply not set the font on the widgets they
 * create. Widgets are always created with the correct
 * default font for the class of user-interface component
 * they represent.
 * </p>
 *
 * @return a font
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public override Font getSystemFont () {
    checkDevice ();
    if (systemFont !is null) return systemFont;
    auto style = OS.gtk_widget_get_style (shellHandle);
    auto defaultFont = OS.pango_font_description_copy (OS.gtk_style_get_font_desc (style));
    return systemFont = Font.gtk_new (this, defaultFont);
}

/**
 * Returns the single instance of the system tray or null
 * when there is no system tray available for the platform.
 *
 * @return the system tray or <code>null</code>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public Tray getSystemTray () {
    checkDevice ();
    if (tray !is null) return tray;
    return tray = new Tray (this, SWT.NONE);
}

/**
 * Returns the user-interface thread for the receiver.
 *
 * @return the receiver's user-interface thread
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Thread getThread () {
    synchronized (Device.classinfo) {
        if (isDisposed ()) error (SWT.ERROR_DEVICE_DISPOSED);
        return thread;
    }
}

Widget getWidget (GtkWidget* handle) {
    if (handle is null) return null;
    if (lastWidget !is null && lastHandle is handle) return lastWidget;
    auto index = cast(ptrdiff_t)OS.g_object_get_qdata ( cast(GObject*)handle, SWT_OBJECT_INDEX) - 1;
    if (0 <= index && index < widgetTable.length) {
        lastHandle = handle;
        return lastWidget = widgetTable [index];
    }
    return null;
}

private static extern(C) int idleProcFunc (void* data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    auto dbdata = cast(CallbackData*)data;
    return dbdata.display.idleProc();
}
private int idleProc () {
    bool result = runAsyncMessages (false);
    if (!result) {
        synchronized (idleLock) {
            idleHandle = 0;
        }
    }
    return result ? 1 : 0;
    return 0;
}

/**
 * Initializes any internal resources needed by the
 * device.
 * <p>
 * This method is called after <code>create</code>.
 * </p>
 *
 * @see #create
 */
protected override void init_ () {
    super.init_ ();
    initializeCallbacks ();
    initializeSystemColors ();
    initializeSystemSettings ();
    initializeWidgetTable ();
    initializeWindowManager ();
}

void initializeCallbacks () {
    closures = new GClosure* [Widget.LAST_SIGNAL];
    signalIds = new int [Widget.LAST_SIGNAL];

    /* Cache signals for GtkWidget */
    signalIds [Widget.BUTTON_PRESS_EVENT] = OS.g_signal_lookup (OS.button_press_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.BUTTON_RELEASE_EVENT] = OS.g_signal_lookup (OS.button_release_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.CONFIGURE_EVENT] = OS.g_signal_lookup (OS.configure_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.DELETE_EVENT] = OS.g_signal_lookup (OS.delete_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.ENTER_NOTIFY_EVENT] = OS.g_signal_lookup (OS.enter_notify_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.EVENT] = OS.g_signal_lookup (OS.event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.EVENT_AFTER] = OS.g_signal_lookup (OS.event_after.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.EXPOSE_EVENT] = OS.g_signal_lookup (OS.expose_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.FOCUS] = OS.g_signal_lookup (OS.focus.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.FOCUS_IN_EVENT] = OS.g_signal_lookup (OS.focus_in_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.FOCUS_OUT_EVENT] = OS.g_signal_lookup (OS.focus_out_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.GRAB_FOCUS] = OS.g_signal_lookup (OS.grab_focus.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.HIDE] = OS.g_signal_lookup (OS.hide.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.KEY_PRESS_EVENT] = OS.g_signal_lookup (OS.key_press_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.KEY_RELEASE_EVENT] = OS.g_signal_lookup (OS.key_release_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.LEAVE_NOTIFY_EVENT] = OS.g_signal_lookup (OS.leave_notify_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.MAP] = OS.g_signal_lookup (OS.map.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.MAP_EVENT] = OS.g_signal_lookup (OS.map_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.MNEMONIC_ACTIVATE] = OS.g_signal_lookup (OS.mnemonic_activate.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.MOTION_NOTIFY_EVENT] = OS.g_signal_lookup (OS.motion_notify_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.POPUP_MENU] = OS.g_signal_lookup (OS.popup_menu.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.REALIZE] = OS.g_signal_lookup (OS.realize.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.SCROLL_EVENT] = OS.g_signal_lookup (OS.scroll_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.SHOW] = OS.g_signal_lookup (OS.show.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.SHOW_HELP] = OS.g_signal_lookup (OS.show_help.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.SIZE_ALLOCATE] = OS.g_signal_lookup (OS.size_allocate.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.STYLE_SET] = OS.g_signal_lookup (OS.style_set.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.UNMAP] = OS.g_signal_lookup (OS.unmap.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.UNMAP_EVENT] = OS.g_signal_lookup (OS.unmap_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.UNREALIZE] = OS.g_signal_lookup (OS.realize.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.VISIBILITY_NOTIFY_EVENT] = OS.g_signal_lookup (OS.visibility_notify_event.ptr, OS.GTK_TYPE_WIDGET ());
    signalIds [Widget.WINDOW_STATE_EVENT] = OS.g_signal_lookup (OS.window_state_event.ptr, OS.GTK_TYPE_WIDGET ());

    GClosure* do_cclosure_new( GCallback cb, int value, ptrdiff_t notify ){
        CallbackData* res= new CallbackData;
        res.display = this;
        res.data = cast(void*)value;
        windowProcCallbackDatas[ value ] = res;
        return OS.g_cclosure_new( cb, cast(void*)res, cast(GClosureNotify)notify );
    }

    GCallback windowProc2 = cast(GCallback)&windowProcFunc2;
    closures [Widget.ACTIVATE] = do_cclosure_new (windowProc2, Widget.ACTIVATE, 0);
    closures [Widget.ACTIVATE_INVERSE] = do_cclosure_new (windowProc2, Widget.ACTIVATE_INVERSE, 0);
    closures [Widget.CHANGED] = do_cclosure_new (windowProc2, Widget.CHANGED, 0);
    closures [Widget.CLICKED] = do_cclosure_new (windowProc2, Widget.CLICKED, 0);
    closures [Widget.DAY_SELECTED] = do_cclosure_new (windowProc2, Widget.DAY_SELECTED, 0);
    closures [Widget.HIDE] = do_cclosure_new (windowProc2, Widget.HIDE, 0);
    closures [Widget.GRAB_FOCUS] = do_cclosure_new (windowProc2, Widget.GRAB_FOCUS, 0);
    closures [Widget.MAP] = do_cclosure_new (windowProc2, Widget.MAP, 0);
    closures [Widget.MONTH_CHANGED] = do_cclosure_new (windowProc2, Widget.MONTH_CHANGED, 0);
    closures [Widget.OUTPUT] = do_cclosure_new (windowProc2, Widget.OUTPUT, 0);
    closures [Widget.POPUP_MENU] = do_cclosure_new (windowProc2, Widget.POPUP_MENU, 0);
    closures [Widget.PREEDIT_CHANGED] = do_cclosure_new (windowProc2, Widget.PREEDIT_CHANGED, 0);
    closures [Widget.REALIZE] = do_cclosure_new (windowProc2, Widget.REALIZE, 0);
    closures [Widget.SELECT] = do_cclosure_new (windowProc2, Widget.SELECT, 0);
    closures [Widget.SHOW] = do_cclosure_new (windowProc2, Widget.SHOW, 0);
    closures [Widget.VALUE_CHANGED] = do_cclosure_new (windowProc2, Widget.VALUE_CHANGED, 0);
    closures [Widget.UNMAP] = do_cclosure_new (windowProc2, Widget.UNMAP, 0);
    closures [Widget.UNREALIZE] = do_cclosure_new (windowProc2, Widget.UNREALIZE, 0);

    GCallback windowProc3 = cast(GCallback)&windowProcFunc3;
    closures [Widget.BUTTON_PRESS_EVENT] = do_cclosure_new (windowProc3, Widget.BUTTON_PRESS_EVENT, 0);
    closures [Widget.BUTTON_PRESS_EVENT_INVERSE] = do_cclosure_new (windowProc3, Widget.BUTTON_PRESS_EVENT_INVERSE, 0);
    closures [Widget.BUTTON_RELEASE_EVENT] = do_cclosure_new (windowProc3, Widget.BUTTON_RELEASE_EVENT, 0);
    closures [Widget.BUTTON_RELEASE_EVENT_INVERSE] = do_cclosure_new (windowProc3, Widget.BUTTON_RELEASE_EVENT_INVERSE, 0);
    closures [Widget.COMMIT] = do_cclosure_new (windowProc3, Widget.COMMIT, 0);
    closures [Widget.CONFIGURE_EVENT] = do_cclosure_new (windowProc3, Widget.CONFIGURE_EVENT, 0);
    closures [Widget.DELETE_EVENT] = do_cclosure_new (windowProc3, Widget.DELETE_EVENT, 0);
    closures [Widget.ENTER_NOTIFY_EVENT] = do_cclosure_new (windowProc3, Widget.ENTER_NOTIFY_EVENT, 0);
    closures [Widget.EVENT] = do_cclosure_new (windowProc3, Widget.EVENT, 0);
    closures [Widget.EVENT_AFTER] = do_cclosure_new (windowProc3, Widget.EVENT_AFTER, 0);
    closures [Widget.EXPOSE_EVENT] = do_cclosure_new (windowProc3, Widget.EXPOSE_EVENT, 0);
    closures [Widget.EXPOSE_EVENT_INVERSE] = do_cclosure_new (windowProc3, Widget.EXPOSE_EVENT_INVERSE, 0);
    closures [Widget.FOCUS] = do_cclosure_new (windowProc3, Widget.FOCUS, 0);
    closures [Widget.FOCUS_IN_EVENT] = do_cclosure_new (windowProc3, Widget.FOCUS_IN_EVENT, 0);
    closures [Widget.FOCUS_OUT_EVENT] = do_cclosure_new (windowProc3, Widget.FOCUS_OUT_EVENT, 0);
    closures [Widget.KEY_PRESS_EVENT] = do_cclosure_new (windowProc3, Widget.KEY_PRESS_EVENT, 0);
    closures [Widget.KEY_RELEASE_EVENT] = do_cclosure_new (windowProc3, Widget.KEY_RELEASE_EVENT, 0);
    closures [Widget.INPUT] = do_cclosure_new (windowProc3, Widget.INPUT, 0);
    closures [Widget.LEAVE_NOTIFY_EVENT] = do_cclosure_new (windowProc3, Widget.LEAVE_NOTIFY_EVENT, 0);
    closures [Widget.MAP_EVENT] = do_cclosure_new (windowProc3, Widget.MAP_EVENT, 0);
    closures [Widget.MNEMONIC_ACTIVATE] = do_cclosure_new (windowProc3, Widget.MNEMONIC_ACTIVATE, 0);
    closures [Widget.MOTION_NOTIFY_EVENT] = do_cclosure_new (windowProc3, Widget.MOTION_NOTIFY_EVENT, 0);
    closures [Widget.MOTION_NOTIFY_EVENT_INVERSE] = do_cclosure_new (windowProc3, Widget.MOTION_NOTIFY_EVENT_INVERSE, 0);
    closures [Widget.MOVE_FOCUS] = do_cclosure_new (windowProc3, Widget.MOVE_FOCUS, 0);
    closures [Widget.POPULATE_POPUP] = do_cclosure_new (windowProc3, Widget.POPULATE_POPUP, 0);
    closures [Widget.SCROLL_EVENT] = do_cclosure_new (windowProc3, Widget.SCROLL_EVENT, 0);
    closures [Widget.SHOW_HELP] = do_cclosure_new (windowProc3, Widget.SHOW_HELP, 0);
    closures [Widget.SIZE_ALLOCATE] = do_cclosure_new (windowProc3, Widget.SIZE_ALLOCATE, 0);
    closures [Widget.STYLE_SET] = do_cclosure_new (windowProc3, Widget.STYLE_SET, 0);
    closures [Widget.TOGGLED] = do_cclosure_new (windowProc3, Widget.TOGGLED, 0);
    closures [Widget.UNMAP_EVENT] = do_cclosure_new (windowProc3, Widget.UNMAP_EVENT, 0);
    closures [Widget.VISIBILITY_NOTIFY_EVENT] = do_cclosure_new (windowProc3, Widget.VISIBILITY_NOTIFY_EVENT, 0);
    closures [Widget.WINDOW_STATE_EVENT] = do_cclosure_new (windowProc3, Widget.WINDOW_STATE_EVENT, 0);

    GCallback windowProc4 = cast(GCallback)&windowProcFunc4;
    closures [Widget.DELETE_RANGE] = do_cclosure_new (windowProc4, Widget.DELETE_RANGE, 0);
    closures [Widget.DELETE_TEXT] = do_cclosure_new (windowProc4, Widget.DELETE_TEXT, 0);
    closures [Widget.ROW_ACTIVATED] = do_cclosure_new (windowProc4, Widget.ROW_ACTIVATED, 0);
    closures [Widget.SCROLL_CHILD] = do_cclosure_new (windowProc4, Widget.SCROLL_CHILD, 0);
    closures [Widget.SWITCH_PAGE] = do_cclosure_new (windowProc4, Widget.SWITCH_PAGE, 0);
    closures [Widget.TEST_COLLAPSE_ROW] = do_cclosure_new (windowProc4, Widget.TEST_COLLAPSE_ROW, 0);
    closures [Widget.TEST_EXPAND_ROW] = do_cclosure_new (windowProc4, Widget.TEST_EXPAND_ROW, 0);

    GCallback windowProc5 = cast(GCallback)&windowProcFunc5;
    closures [Widget.EXPAND_COLLAPSE_CURSOR_ROW] = do_cclosure_new (windowProc5, Widget.EXPAND_COLLAPSE_CURSOR_ROW, 0);
    closures [Widget.INSERT_TEXT] = do_cclosure_new (windowProc5, Widget.INSERT_TEXT, 0);
    closures [Widget.TEXT_BUFFER_INSERT_TEXT] = do_cclosure_new (windowProc5, Widget.TEXT_BUFFER_INSERT_TEXT, 0);

    GCallback windowChangeValueProc = cast(GCallback)&windowProcChangeValueFunc;
    closures [Widget.CHANGE_VALUE] = do_cclosure_new (windowChangeValueProc, Widget.CHANGE_VALUE, 0);

    for (int i = 0; i < Widget.LAST_SIGNAL; i++) {
        if (closures [i] !is null) OS.g_closure_ref (closures [i]);
    }
    shellMapProcCallbackData.display = this;
    shellMapProcCallbackData.data = null;
    shellMapProcClosure = OS.g_cclosure_new (cast(GCallback)&shellMapProcFunc, &shellMapProcCallbackData, cast(GClosureNotify)0);
    OS.g_closure_ref (shellMapProcClosure);
}

void* getWindowProcUserData( int value ){
    return windowProcCallbackDatas[ value ];

}

void initializeSystemSettings () {
    styleSetProcCallbackData.display = this;
    styleSetProcCallbackData.data = null;
    OS.g_signal_connect (shellHandle, OS.style_set.ptr, cast(GCallback)&styleSetProcFunc, &styleSetProcCallbackData);

    /*
    * Feature in GTK.  Despite the fact that the
    * gtk-entry-select-on-focus property is a global
    * setting, it is initialized when the GtkEntry
    * is initialized.  This means that it cannot be
    * accessed before a GtkEntry is created.  The
    * fix is to for the initializaion by creating
    * a temporary GtkEntry.
    */
    auto entry = OS.gtk_entry_new ();
    OS.gtk_widget_destroy (entry);
    int buffer2;
    auto settings = OS.gtk_settings_get_default ();
    OS.g_object_get1 (settings, OS.gtk_entry_select_on_focus.ptr, &buffer2);
    entrySelectOnFocus = buffer2 !is 0;
}

void initializeWidgetTable () {
    indexTable = new ptrdiff_t [GROW_SIZE];
    widgetTable = new Widget [GROW_SIZE];
    for (int i=0; i<GROW_SIZE-1; i++) indexTable [i] = i + 1;
    indexTable [GROW_SIZE - 1] = -1;
}

void initializeWindowManager () {
    /* Get the window manager name */
    windowManager = ""; //$NON-NLS-1$
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 2, 0)) {
        auto screen = OS.gdk_screen_get_default ();
        if (screen !is null) {
            auto ptr2 = OS.gdk_x11_screen_get_window_manager_name (screen);
            windowManager = fromStringz( ptr2 )._idup();
        }
    }
}

/**
 * Invokes platform specific functionality to dispose a GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Display</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param hDC the platform specific GC handle
 * @param data the platform specific GC data
 */
public override void internal_dispose_GC (GdkGC* gdkGC, GCData data) {
    OS.g_object_unref (gdkGC);
}

/**
 * Invokes platform specific functionality to allocate a new GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Display</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param data the platform specific GC data
 * @return the platform specific GC handle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for gc creation</li>
 * </ul>
 */
public override GdkGC* internal_new_GC (GCData data) {
    if (isDisposed()) SWT.error(SWT.ERROR_DEVICE_DISPOSED);
    auto root = cast(GdkDrawable *) OS.GDK_ROOT_PARENT ();
    auto gdkGC = OS.gdk_gc_new (root);
    if (gdkGC is null) SWT.error (SWT.ERROR_NO_HANDLES);
    OS.gdk_gc_set_subwindow (gdkGC, OS.GDK_INCLUDE_INFERIORS);
    if (data !is null) {
        int mask = SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT;
        if ((data.style & mask) is 0) {
            data.style |= SWT.LEFT_TO_RIGHT;
        }
        data.device = this;
        data.drawable = root;
        data.background = getSystemColor (SWT.COLOR_WHITE).handle;
        data.foreground = getSystemColor (SWT.COLOR_BLACK).handle;
        data.font = getSystemFont ();
    }
    return gdkGC;
    return null;
}

bool isValidThread () {
    return thread is Thread.currentThread ();
}

/**
 * Maps a point from one coordinate system to another.
 * When the control is null, coordinates are mapped to
 * the display.
 * <p>
 * NOTE: On right-to-left platforms where the coordinate
 * systems are mirrored, special care needs to be taken
 * when mapping coordinates from one control to another
 * to ensure the result is correctly mirrored.
 *
 * Mapping a point that is the origin of a rectangle and
 * then adding the width and height is not equivalent to
 * mapping the rectangle.  When one control is mirrored
 * and the other is not, adding the width and height to a
 * point that was mapped causes the rectangle to extend
 * in the wrong direction.  Mapping the entire rectangle
 * instead of just one point causes both the origin and
 * the corner of the rectangle to be mapped.
 * </p>
 *
 * @param from the source <code>Control</code> or <code>null</code>
 * @param to the destination <code>Control</code> or <code>null</code>
 * @param point to be mapped
 * @return point with mapped coordinates
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the Control from or the Control to have been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.1.2
 */
public Point map (Control from, Control to, Point point) {
    checkDevice ();
    if (point is null) error (SWT.ERROR_NULL_ARGUMENT);
    return map (from, to, point.x, point.y);
}

/**
 * Maps a point from one coordinate system to another.
 * When the control is null, coordinates are mapped to
 * the display.
 * <p>
 * NOTE: On right-to-left platforms where the coordinate
 * systems are mirrored, special care needs to be taken
 * when mapping coordinates from one control to another
 * to ensure the result is correctly mirrored.
 *
 * Mapping a point that is the origin of a rectangle and
 * then adding the width and height is not equivalent to
 * mapping the rectangle.  When one control is mirrored
 * and the other is not, adding the width and height to a
 * point that was mapped causes the rectangle to extend
 * in the wrong direction.  Mapping the entire rectangle
 * instead of just one point causes both the origin and
 * the corner of the rectangle to be mapped.
 * </p>
 *
 * @param from the source <code>Control</code> or <code>null</code>
 * @param to the destination <code>Control</code> or <code>null</code>
 * @param x coordinates to be mapped
 * @param y coordinates to be mapped
 * @return point with mapped coordinates
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the Control from or the Control to have been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.1.2
 */
public Point map (Control from, Control to, int x, int y) {
    checkDevice ();
    if (from !is null && from.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);
    if (to !is null && to.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);
    Point point = new Point (x, y);
    if (from is to) return point;
    if (from !is null) {
        auto window = from.eventWindow ();
        int origin_x, origin_y;
        OS.gdk_window_get_origin (window, &origin_x, &origin_y);
        if ((from.style & SWT.MIRRORED) !is 0) point.x = from.getClientWidth () - point.x;
        point.x += origin_x;
        point.y += origin_y;
    }
    if (to !is null) {
        auto window = to.eventWindow ();
        int origin_x, origin_y;
        OS.gdk_window_get_origin (window, &origin_x, &origin_y);
        point.x -= origin_x;
        point.y -= origin_y;
        if ((to.style & SWT.MIRRORED) !is 0) point.x = to.getClientWidth () - point.x;
    }
    return point;
}

/**
 * Maps a point from one coordinate system to another.
 * When the control is null, coordinates are mapped to
 * the display.
 * <p>
 * NOTE: On right-to-left platforms where the coordinate
 * systems are mirrored, special care needs to be taken
 * when mapping coordinates from one control to another
 * to ensure the result is correctly mirrored.
 *
 * Mapping a point that is the origin of a rectangle and
 * then adding the width and height is not equivalent to
 * mapping the rectangle.  When one control is mirrored
 * and the other is not, adding the width and height to a
 * point that was mapped causes the rectangle to extend
 * in the wrong direction.  Mapping the entire rectangle
 * instead of just one point causes both the origin and
 * the corner of the rectangle to be mapped.
 * </p>
 *
 * @param from the source <code>Control</code> or <code>null</code>
 * @param to the destination <code>Control</code> or <code>null</code>
 * @param rectangle to be mapped
 * @return rectangle with mapped coordinates
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the rectangle is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the Control from or the Control to have been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.1.2
 */
public Rectangle map (Control from, Control to, Rectangle rectangle) {
    checkDevice();
    if (rectangle is null) error (SWT.ERROR_NULL_ARGUMENT);
    return map (from, to, rectangle.x, rectangle.y, rectangle.width, rectangle.height);
}

static wchar mbcsToWcs (wchar ch) {
    int key = ch & 0xFFFF;
    if (key <= 0x7F) return ch;
    char [] buffer;
    if (key <= 0xFF) {
        buffer = new char [1];
        buffer [0] = cast(char) key;
    } else {
        buffer = new char [2];
        buffer [0] = cast(char) ((key >> 8) & 0xFF);
        buffer [1] = cast(char) (key & 0xFF);
    }
    wchar [] result = Converter.mbcsToWcs (null, buffer);
    if (result.length is 0) return 0;
    return result [0];
}


package void doMenuPositionProc( GtkMenu* window, bool hasLocation ){
    /*
    * Bug in GTK.  The timestamp passed into gtk_menu_popup is used
    * to perform an X pointer grab.  It cannot be zero, else the grab
    * will fail.  The fix is to ensure that the timestamp of the last
    * event processed is used.
    */
    OS.gtk_menu_popup (window, null, null,
        hasLocation ? &menuPositionProcFunc : null,
        cast(void*)this, 0, getLastEventTime() );
}

private static extern(C) void menuPositionProcFunc (GtkMenu* menu, int* x, int* y, int* push_in, void* user_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    auto display = cast(Display)user_data;
    display.menuPositionProc( menu, x, y, push_in, null );
}

void menuPositionProc (GtkMenu* menu, int* x, int* y, int* push_in, void* user_data) {
    Widget widget = getWidget (cast(GtkWidget*)menu);
    if (widget is null) return;
    widget.menuPositionProc (menu, x, y, push_in, user_data);
}

/**
 * Maps a point from one coordinate system to another.
 * When the control is null, coordinates are mapped to
 * the display.
 * <p>
 * NOTE: On right-to-left platforms where the coordinate
 * systems are mirrored, special care needs to be taken
 * when mapping coordinates from one control to another
 * to ensure the result is correctly mirrored.
 *
 * Mapping a point that is the origin of a rectangle and
 * then adding the width and height is not equivalent to
 * mapping the rectangle.  When one control is mirrored
 * and the other is not, adding the width and height to a
 * point that was mapped causes the rectangle to extend
 * in the wrong direction.  Mapping the entire rectangle
 * instead of just one point causes both the origin and
 * the corner of the rectangle to be mapped.
 * </p>
 *
 * @param from the source <code>Control</code> or <code>null</code>
 * @param to the destination <code>Control</code> or <code>null</code>
 * @param x coordinates to be mapped
 * @param y coordinates to be mapped
 * @param width coordinates to be mapped
 * @param height coordinates to be mapped
 * @return rectangle with mapped coordinates
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the Control from or the Control to have been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.1.2
 */
public Rectangle map (Control from, Control to, int x, int y, int width, int height) {
    checkDevice();
    if (from !is null && from.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);
    if (to !is null && to.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);
    Rectangle rect = new Rectangle (x, y, width, height);
    if (from is to) return rect;
    bool fromRTL = false, toRTL = false;
    if (from !is null) {
        auto window = from.eventWindow ();
        int origin_x, origin_y;
        OS.gdk_window_get_origin (window, &origin_x, &origin_y);
        fromRTL = (from.style & SWT.MIRRORED) !is 0;
        if (fromRTL) rect.x = from.getClientWidth() - rect.x;
        rect.x += origin_x;
        rect.y += origin_y;
    }
    if (to !is null) {
        auto window = to.eventWindow ();
        int origin_x, origin_y;
        OS.gdk_window_get_origin (window, &origin_x, &origin_y);
        rect.x -= origin_x;
        rect.y -= origin_y;
        toRTL = (to.style & SWT.MIRRORED) !is 0;
        if (toRTL) rect.x = to.getClientWidth () - rect.x;
    }
    if (fromRTL !is toRTL) rect.x -= rect.width;
    return rect;
}

private static extern(C) int mouseHoverProcFunc ( void* user_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    CallbackData* cbdata = cast(CallbackData*)user_data;
    return cbdata.display.mouseHoverProc( cast(GtkWidget*)cbdata.data );
}
int mouseHoverProc (GtkWidget* handle) {
    Widget widget = getWidget (handle);
    if (widget is null) return 0;
    return widget.hoverProc (handle);
}

/**
 * Generate a low level system event.
 *
 * <code>post</code> is used to generate low level keyboard
 * and mouse events. The intent is to enable automated UI
 * testing by simulating the input from the user.  Most
 * SWT applications should never need to call this method.
 * <p>
 * Note that this operation can fail when the operating system
 * fails to generate the event for any reason.  For example,
 * this can happen when there is no such key or mouse button
 * or when the system event queue is full.
 * </p>
 * <p>
 * <b>Event Types:</b>
 * <p>KeyDown, KeyUp
 * <p>The following fields in the <code>Event</code> apply:
 * <ul>
 * <li>(in) type KeyDown or KeyUp</li>
 * <p> Either one of:
 * <li>(in) character a character that corresponds to a keyboard key</li>
 * <li>(in) keyCode the key code of the key that was typed,
 *          as defined by the key code constants in class <code>SWT</code></li>
 * </ul>
 * <p>MouseDown, MouseUp</p>
 * <p>The following fields in the <code>Event</code> apply:
 * <ul>
 * <li>(in) type MouseDown or MouseUp
 * <li>(in) button the button that is pressed or released
 * </ul>
 * <p>MouseMove</p>
 * <p>The following fields in the <code>Event</code> apply:
 * <ul>
 * <li>(in) type MouseMove
 * <li>(in) x the x coordinate to move the mouse pointer to in screen coordinates
 * <li>(in) y the y coordinate to move the mouse pointer to in screen coordinates
 * </ul>
 * </dl>
 *
 * @param event the event to be generated
 *
 * @return true if the event was generated or false otherwise
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the event is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 3.0
 *
 */
public bool post (Event event) {
    synchronized (Device.classinfo) {
        if (isDisposed ()) error (SWT.ERROR_DEVICE_DISPOSED);
        if (event is null) error (SWT.ERROR_NULL_ARGUMENT);
        if (!OS.GDK_WINDOWING_X11()) return false;
        auto xDisplay = OS.GDK_DISPLAY ();
        int type = event.type;
        switch (type) {
            case SWT.KeyDown:
            case SWT.KeyUp: {
                int keyCode = 0;
                auto keysym = untranslateKey (event.keyCode);
                if (keysym !is 0) keyCode = OS.XKeysymToKeycode (xDisplay, keysym);
                if (keyCode is 0) {
                    char key = cast(char) event.character;
                    switch (key) {
                        case SWT.BS: keysym = OS.GDK_BackSpace; break;
                        case SWT.CR: keysym = OS.GDK_Return; break;
                        case SWT.DEL: keysym = OS.GDK_Delete; break;
                        case SWT.ESC: keysym = OS.GDK_Escape; break;
                        case SWT.TAB: keysym = OS.GDK_Tab; break;
                        case SWT.LF: keysym = OS.GDK_Linefeed; break;
                        default:
                            keysym = key;
                    }
                    keyCode = OS.XKeysymToKeycode (xDisplay, keysym);
                    if (keyCode is 0) return false;
                }
                OS.XTestFakeKeyEvent (xDisplay, keyCode, type is SWT.KeyDown, 0);
                return true;
            }
            case SWT.MouseDown:
            case SWT.MouseMove:
            case SWT.MouseUp: {
                if (type is SWT.MouseMove) {
                    OS.XTestFakeMotionEvent (xDisplay, -1, event.x, event.y, 0);
                } else {
                    int button = event.button;
                    switch (button) {
                        case 1:
                        case 2:
                        case 3: break;
                        case 4: button = 6; break;
                        case 5: button = 7; break;
                        default: return false;
                    }
                    OS.XTestFakeButtonEvent (xDisplay, button, type is SWT.MouseDown, 0);
                }
                return true;
        default:
            }
            /*
            * This code is intentionally commented. After posting a
            * mouse wheel event the system may respond unpredictably
            * to subsequent mouse actions.
            */
//          case SWT.MouseWheel: {
//              if (event.count is 0) return false;
//              int button = event.count < 0 ? 5 : 4;
//              OS.XTestFakeButtonEvent (xDisplay, button, type is SWT.MouseWheel, 0);
//          }
        }
        return false;
    }
}

void postEvent (Event event) {
    /*
    * Place the event at the end of the event queue.
    * This code is always called in the Display's
    * thread so it must be re-enterant but does not
    * need to be synchronized.
    */
    if (eventQueue is null) eventQueue = new Event [4];
    ptrdiff_t index = 0;
    ptrdiff_t length = eventQueue.length;
    while (index < length) {
        if (eventQueue [index] is null) break;
        index++;
    }
    if (index is length) {
        Event [] newQueue = new Event [length + 4];
        System.arraycopy (eventQueue, 0, newQueue, 0, length);
        eventQueue = newQueue;
    }
    eventQueue [index] = event;
}

void putGdkEvents () {
    if (gdkEventCount !is 0) {
        for (int i = 0; i < gdkEventCount; i++) {
            auto event = gdkEvents [i];
            Widget widget = gdkEventWidgets [i];
            if (widget is null || !widget.isDisposed ()) {
                OS.gdk_event_put (event);
            }
            OS.gdk_event_free (event);
            gdkEvents [i] = null;
            gdkEventWidgets [i] = null;
        }
        gdkEventCount = 0;
    }
}

/**
 * Reads an event from the operating system's event queue,
 * dispatches it appropriately, and returns <code>true</code>
 * if there is potentially more work to do, or <code>false</code>
 * if the caller can sleep until another event is placed on
 * the event queue.
 * <p>
 * In addition to checking the system event queue, this method also
 * checks if any inter-thread messages (created by <code>syncExec()</code>
 * or <code>asyncExec()</code>) are waiting to be processed, and if
 * so handles them before returning.
 * </p>
 *
 * @return <code>false</code> if the caller can sleep upon return from this method
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_FAILED_EXEC - if an exception occurred while running an inter-thread message</li>
 * </ul>
 *
 * @see #sleep
 * @see #wake
 */
public bool readAndDispatch () {
    checkDevice ();
    bool events = false;
    events |= runSettings ();
    events |= runPopups ();
    events |= cast(bool)OS.g_main_context_iteration (null, false);
    if (events) {
        runDeferredEvents ();
        return true;
    }
    return runAsyncMessages (false);
}

static void register (Display display) {
    synchronized (Device.classinfo) {
        for (int i=0; i<Displays.length; i++) {
            if (Displays [i] is null) {
                Displays [i] = display;
                return;
            }
        }
        Display [] newDisplays = new Display [Displays.length + 4];
        System.arraycopy (Displays, 0, newDisplays, 0, Displays.length);
        newDisplays [Displays.length] = display;
        Displays = newDisplays;
    }
}

/**
 * Releases any internal resources back to the operating
 * system and clears all fields except the device handle.
 * <p>
 * Disposes all shells which are currently open on the display.
 * After this method has been invoked, all related related shells
 * will answer <code>true</code> when sent the message
 * <code>isDisposed()</code>.
 * </p><p>
 * When a device is destroyed, resources that were acquired
 * on behalf of the programmer need to be returned to the
 * operating system.  For example, if the device allocated a
 * font to be used as the system font, this font would be
 * freed in <code>release</code>.  Also,to assist the garbage
 * collector and minimize the amount of memory that is not
 * reclaimed when the programmer keeps a reference to a
 * disposed device, all fields except the handle are zero'd.
 * The handle is needed by <code>destroy</code>.
 * </p>
 * This method is called before <code>destroy</code>.
 *
 * @see Device#dispose
 * @see #destroy
 */
protected override void release () {
    sendEvent (SWT.Dispose, new Event ());
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) {
        Shell shell = shells [i];
        if (!shell.isDisposed ())  shell.dispose ();
    }
    if (tray !is null) tray.dispose ();
    tray = null;
    while (readAndDispatch ()) {}
    if (disposeList !is null) {
        for (int i=0; i<disposeList.length; i++) {
            if (disposeList [i] !is null) disposeList [i].run ();
        }
    }
    disposeList = null;
    synchronizer.releaseSynchronizer ();
    synchronizer = null;
    releaseDisplay ();
    super.release ();
}

void releaseDisplay () {

    /* Dispose xfilter callback */
    OS.gdk_window_remove_filter(null, &filterProcFunc, null);

    /* Dispose checkIfEvent callback */

    /* Dispose preedit window */
    if (preeditWindow !is null) OS.gtk_widget_destroy ( &preeditWindow.bin.container.widget);
    imControl = null;

    /* Dispose the menu callback */

    /* Dispose the tooltip map callback */

    /* Dispose the shell map callback */

    /* Dispose the run async messages callback */
    if (idleHandle !is 0) OS.g_source_remove (idleHandle);
    idleHandle = 0;

    /* Dispose GtkTreeView callbacks */

    /* Dispose the set direction callback */

    /* Dispose the emission proc callback */

    /* Dispose the set direction callback */

    /* Dispose the caret callback */
    if (caretId !is 0) OS.gtk_timeout_remove (caretId);
    caretId = 0;

    /* Release closures */
    for (int i = 0; i < Widget.LAST_SIGNAL; i++) {
        if (closures [i] !is null) OS.g_closure_unref (closures [i]);
    }
    if (shellMapProcClosure !is null) OS.g_closure_unref (shellMapProcClosure);

    /* Dispose the timer callback */
    if (timerIds !is null) {
        for (int i=0; i<timerIds.length; i++) {
            if (timerIds [i] !is 0) OS.gtk_timeout_remove (timerIds [i]);
        }
    }
    timerIds = null;
    timerList = null;

    /* Dispose mouse hover callback */
    if (mouseHoverId !is 0) OS.gtk_timeout_remove (mouseHoverId);
    mouseHoverId = 0;
    mouseHoverHandle = null;

    /* Dispose the default font */
    if (systemFont !is null) systemFont.dispose ();
    systemFont = null;

    /* Dispose the System Images */
    if (errorImage !is null) errorImage.dispose();
    if (infoImage !is null) infoImage.dispose();
    if (questionImage !is null) questionImage.dispose();
    if (warningImage !is null) warningImage.dispose();
    errorImage = infoImage = questionImage = warningImage = null;

    /* Release the System Cursors */
    for (int i = 0; i < cursors.length; i++) {
        if (cursors [i] !is null) cursors [i].dispose ();
    }
    cursors = null;

    /* Release Acquired Resources */
    if (resources !is null) {
        for (int i=0; i<resources.length; i++) {
            if (resources [i] !is null) resources [i].dispose ();
        }
        resources = null;
    }

    /* Release the System Colors */
    COLOR_WIDGET_DARK_SHADOW = COLOR_WIDGET_NORMAL_SHADOW = COLOR_WIDGET_LIGHT_SHADOW =
    COLOR_WIDGET_HIGHLIGHT_SHADOW = COLOR_WIDGET_BACKGROUND = COLOR_WIDGET_BORDER =
    COLOR_LIST_FOREGROUND = COLOR_LIST_BACKGROUND = COLOR_LIST_SELECTION = COLOR_LIST_SELECTION_TEXT =
    COLOR_WIDGET_FOREGROUND = COLOR_TITLE_FOREGROUND = COLOR_TITLE_BACKGROUND = COLOR_TITLE_BACKGROUND_GRADIENT =
    COLOR_TITLE_INACTIVE_FOREGROUND = COLOR_TITLE_INACTIVE_BACKGROUND = COLOR_TITLE_INACTIVE_BACKGROUND_GRADIENT =
    COLOR_INFO_BACKGROUND = COLOR_INFO_FOREGROUND = null;

    /* Dispose the event callback */
    OS.gdk_event_handler_set (null, null, null);

    /* Dispose the hidden shell */
    if (shellHandle !is null) OS.gtk_widget_destroy (shellHandle);
    shellHandle = null;

    /* Dispose the settings callback */

    /* Release the sleep resources */
    max_priority = 0;
    timeout = 0;
    if (fds !is null) OS.g_free (fds.ptr);
    fds = null;

    /* Release references */
    popups = null;
    thread = null;
    lastWidget = activeShell = null;
    //flushData = null;
    closures = null;
    indexTable = null;
    signalIds = null;
    treeSelection = null;
    widgetTable = null;
    modalShells = null;
    data = null;
    values = null;
    keys = null;
    windowManager = null;
    eventTable = filterTable = null;
    modalDialog = null;
    flushRect = null;
    exposeEvent = null;
    visibilityEvent = null;
    idleLock = null;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when an event of the given type occurs anywhere in
 * a widget. The event type is one of the event constants defined
 * in class <code>SWT</code>.
 *
 * @param eventType the type of event to listen for
 * @param listener the listener which should no longer be notified when the event occurs
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Listener
 * @see SWT
 * @see #addFilter
 * @see #addListener
 *
 * @since 3.0
 */
public void removeFilter (int eventType, Listener listener) {
    checkDevice ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (filterTable is null) return;
    filterTable.unhook (eventType, listener);
    if (filterTable.size () is 0) filterTable = null;
}

GdkEvent* removeGdkEvent () {
    if (gdkEventCount is 0) return null;
    auto event = gdkEvents [0];
    --gdkEventCount;
    SimpleType!(GdkEvent*).arraycopy (gdkEvents, 1, gdkEvents, 0, gdkEventCount);
    System.arraycopy (gdkEventWidgets, 1, gdkEventWidgets, 0, gdkEventCount);
    gdkEvents [gdkEventCount] = null;
    gdkEventWidgets [gdkEventCount] = null;
    if (gdkEventCount is 0) {
        gdkEvents = null;
        gdkEventWidgets = null;
    }
    return event;
}

void removeIdleProc () {
    synchronized (idleLock) {
        if (idleHandle !is 0) OS.g_source_remove (idleHandle);
        idleNeeded = false;
        idleHandle = 0;
    }
}
/**
 * Removes the listener from the collection of listeners who will
 * be notified when an event of the given type occurs. The event type
 * is one of the event constants defined in class <code>SWT</code>.
 *
 * @param eventType the type of event to listen for
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Listener
 * @see SWT
 * @see #addListener
 *
 * @since 2.0
 */
public void removeListener (int eventType, Listener listener) {
    checkDevice ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (eventType, listener);
}

void removeMouseHoverTimeout (void* handle) {
    if (handle !is mouseHoverHandle) return;
    if (mouseHoverId !is 0) OS.gtk_timeout_remove (mouseHoverId);
    mouseHoverId = 0;
    mouseHoverHandle = null;
}

void removePopup (Menu menu) {
    if (popups is null) return;
    for (int i=0; i<popups.length; i++) {
        if (popups [i] is menu) {
            popups [i] = null;
            return;
        }
    }
}

Widget removeWidget (GtkWidget* handle) {
    if (handle is null) return null;
    lastWidget = null;
    Widget widget = null;
    auto index = cast(ptrdiff_t)OS.g_object_get_qdata (cast(GObject*)handle, SWT_OBJECT_INDEX) - 1;
    if (0 <= index && index < widgetTable.length) {
        widget = widgetTable [index];
        widgetTable [index] = null;
        indexTable [index] = freeSlot;
        freeSlot = index;
        OS.g_object_set_qdata (cast(GObject*)handle, SWT_OBJECT_INDEX, null);
    }
    return widget;
}

bool runAsyncMessages (bool all) {
    return synchronizer.runAsyncMessages (all);
}

bool runDeferredEvents () {
    /*
    * Run deferred events.  This code is always
    * called in the Display's thread so it must
    * be re-enterant but need not be synchronized.
    */
    while (eventQueue !is null) {

        /* Take an event off the queue */
        Event event = eventQueue [0];
        if (event is null) break;
        ptrdiff_t len = eventQueue.length;
        System.arraycopy (eventQueue, 1, eventQueue, 0, --len);
        eventQueue [len] = null;

        /* Run the event */
        Widget widget = event.widget;
        if (widget !is null && !widget.isDisposed ()) {
            Widget item = event.item;
            if (item is null || !item.isDisposed ()) {
                widget.sendEvent (event);
            }
        }

        /*
        * At this point, the event queue could
        * be null due to a recursive invokation
        * when running the event.
        */
    }

    /* Clear the queue */
    eventQueue = null;
    return true;
}

bool runPopups () {
    if (popups is null) return false;
    bool result = false;
    while (popups !is null) {
        Menu menu = popups [0];
        if (menu is null) break;
        ptrdiff_t len = popups.length;
        System.arraycopy (popups, 1, popups, 0, --len);
        popups [len] = null;
        runDeferredEvents ();
        if (!menu.isDisposed ()) menu._setVisible (true);
        result = true;
    }
    popups = null;
    return result;
}

bool runSettings () {
    if (!runSettingsFld) return false;
    runSettingsFld = false;
    saveResources ();
    initializeSystemColors ();
    sendEvent (SWT.Settings, null);
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) {
        Shell shell = shells [i];
        if (!shell.isDisposed ()) {
            shell.fixStyle ();
            shell.redraw (true);
            shell.layout (true, true);
        }
    }
    return true;
}

/**
 * On platforms which support it, sets the application name
 * to be the argument. On Motif, for example, this can be used
 * to set the name used for resource lookup.  Specifying
 * <code>null</code> for the name clears it.
 *
 * @param name the new app name or <code>null</code>
 */
public static void setAppName (String name) {
    APP_NAME = name;
}

/**
 * Sets the location of the on-screen pointer relative to the top left corner
 * of the screen.  <b>Note: It is typically considered bad practice for a
 * program to move the on-screen pointer location.</b>
 *
 * @param x the new x coordinate for the cursor
 * @param y the new y coordinate for the cursor
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.1
 */
public void setCursorLocation (int x, int y) {
    checkDevice ();
    if (OS.GDK_WINDOWING_X11 ()) {
        auto xDisplay = OS.GDK_DISPLAY ();
        auto xWindow = OS.XDefaultRootWindow (xDisplay);
        OS.XWarpPointer (xDisplay, OS.None, xWindow, 0, 0, 0, 0, x, y);
    }
}

/**
 * Sets the location of the on-screen pointer relative to the top left corner
 * of the screen.  <b>Note: It is typically considered bad practice for a
 * program to move the on-screen pointer location.</b>
 *
 * @param point new position
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @since 2.0
 */
public void setCursorLocation (Point point) {
    checkDevice ();
    if (point is null) error (SWT.ERROR_NULL_ARGUMENT);
    setCursorLocation (point.x, point.y);
}

/**
 * Sets the application defined property of the receiver
 * with the specified name to the given argument.
 * <p>
 * Applications may have associated arbitrary objects with the
 * receiver in this fashion. If the objects stored in the
 * properties need to be notified when the display is disposed
 * of, it is the application's responsibility provide a
 * <code>disposeExec()</code> handler which does so.
 * </p>
 *
 * @param key the name of the property
 * @param value the new value for the property
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getData(String)
 * @see #disposeExec(Runnable)
 */
public void setData (String key, Object value) {
    checkDevice ();
    // SWT extension: allow null for zero length string
    //if (key is null) error (SWT.ERROR_NULL_ARGUMENT);

    if (key.equals (DISPATCH_EVENT_KEY)) {
        ArrayWrapperInt wrappedValue;
        if (value is null || (null !is (wrappedValue=cast(ArrayWrapperInt)value))) {
            if (wrappedValue is null) {
                dispatchEvents = [];
            } else {
                dispatchEvents = wrappedValue.array;
            }
            if (value is null) putGdkEvents ();
            return;
        }
    }
    if (key.equals (SET_MODAL_DIALOG)) {
        setModalDialog (cast(Dialog) data);
        return;
    }

    if (key.equals (ADD_WIDGET_KEY)) {
        auto wrap = cast(ArrayWrapperObject) value;
        if( wrap is null ) SWT.error(SWT.ERROR_INVALID_ARGUMENT, null, " []");
        Object [] data = wrap.array;
        auto handle = (cast(LONG) data [0]).intValue;
        Widget widget = cast(Widget) data [1];
        if (widget !is null) {
            addWidget (cast(GtkWidget*)handle, widget);
        } else {
            removeWidget (cast(GtkWidget*)handle);
        }
    }

    if (key==/*eq*/ ADD_IDLE_PROC_KEY) {
        addIdleProc ();
        return;
    }
    if (key==/*eq*/ REMOVE_IDLE_PROC_KEY) {
        removeIdleProc ();
        return;
    }

    /* Remove the key/value pair */
    if (value is null) {
        if (keys is null) return;
        int index = 0;
        while (index < keys.length && keys [index]!=/*!eq*/ key) index++;
        if (index is keys.length) return;
        if (keys.length is 1) {
            keys = null;
            values = null;
        } else {
            String [] newKeys = new String [keys.length - 1];
            Object [] newValues = new Object [values.length - 1];
            System.arraycopy (keys, 0, newKeys, 0, index);
            System.arraycopy (keys, index + 1, newKeys, index, newKeys.length - index);
            System.arraycopy (values, 0, newValues, 0, index);
            System.arraycopy (values, index + 1, newValues, index, newValues.length - index);
            keys = newKeys;
            values = newValues;
        }
        return;
    }

    /* Add the key/value pair */
    if (keys is null) {
        keys = [key];
        values = [value];
        return;
    }
    for (int i=0; i<keys.length; i++) {
        if (keys [i]==/*eq*/ key) {
            values [i] = value;
            return;
        }
    }
    String [] newKeys = new String [keys.length + 1];
    Object [] newValues = new Object [values.length + 1];
    System.arraycopy (keys, 0, newKeys, 0, keys.length);
    System.arraycopy (values, 0, newValues, 0, values.length);
    newKeys [keys.length] = key;
    newValues [values.length] = value;
    keys = newKeys;
    values = newValues;
}

/**
 * Sets the application defined, display specific data
 * associated with the receiver, to the argument.
 * The <em>display specific data</em> is a single,
 * unnamed field that is stored with every display.
 * <p>
 * Applications may put arbitrary objects in this field. If
 * the object stored in the display specific data needs to
 * be notified when the display is disposed of, it is the
 * application's responsibility provide a
 * <code>disposeExec()</code> handler which does so.
 * </p>
 *
 * @param data the new display specific data
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getData()
 * @see #disposeExec(Runnable)
 */
public void setData (Object data) {
    checkDevice ();
    this.data = data;
}


void doSetDirectionProc( GtkWidget* widget, int direction ){
    setDirectionProcCallbackData.display = this;
    setDirectionProcCallbackData.data = cast(void*)direction;
    OS.gtk_container_forall (cast(GtkContainer*)widget, cast(GtkCallback)&setDirectionProcFunc, &setDirectionProcCallbackData);
}

package static extern(C) ptrdiff_t setDirectionProcFunc (GtkWidget* widget, void* data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    CallbackData* cbdata = cast(CallbackData*)data;
    return cbdata.display.setDirectionProc( widget, cast(int)cbdata.data );
}
ptrdiff_t setDirectionProc (GtkWidget* widget, int direction) {
    OS.gtk_widget_set_direction (widget,  direction);
    if (OS.GTK_IS_MENU_ITEM (widget)) {
        auto submenu = OS.gtk_menu_item_get_submenu (widget);
        if (submenu !is null) {
            OS.gtk_widget_set_direction (submenu, direction);
            OS.gtk_container_forall (cast(GtkContainer*)submenu, cast(GtkCallback)&setDirectionProcFunc, cast(void*)direction);
        }
    }
    if (OS.GTK_IS_CONTAINER (cast(GTypeInstance*)widget)) {
        OS.gtk_container_forall (cast(GtkContainer*)widget, cast(GtkCallback)&setDirectionProcFunc, cast(void*)direction);
    }
    return 0;
}

void setModalDialog (Dialog modalDailog) {
    this.modalDialog = modalDailog;
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) shells [i].updateModal ();
}

void setModalShell (Shell shell) {
    if (modalShells is null) modalShells = new Shell [4];
    ptrdiff_t index = 0, length = modalShells.length;
    while (index < length) {
        if (modalShells [index] is shell) return;
        if (modalShells [index] is null) break;
        index++;
    }
    if (index is length) {
        Shell [] newModalShells = new Shell [length + 4];
        System.arraycopy (modalShells, 0, newModalShells, 0, length);
        modalShells = newModalShells;
    }
    modalShells [index] = shell;
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) shells [i].updateModal ();
}

/**
 * Sets the synchronizer used by the display to be
 * the argument, which can not be null.
 *
 * @param synchronizer the new synchronizer for the display (must not be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the synchronizer is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_FAILED_EXEC - if an exception occurred while running an inter-thread message</li>
 * </ul>
 */
public void setSynchronizer (Synchronizer synchronizer) {
    checkDevice ();
    if (synchronizer is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (synchronizer is this.synchronizer) return;
    Synchronizer oldSynchronizer;
    synchronized (Device.classinfo) {
        oldSynchronizer = this.synchronizer;
        this.synchronizer = synchronizer;
    }
    if (oldSynchronizer !is null) {
        oldSynchronizer.runAsyncMessages(true);
    }
}

void showIMWindow (Control control) {
    imControl = control;
    if (preeditWindow is null) {
        preeditWindow = cast(GtkWindow*)OS.gtk_window_new (OS.GTK_WINDOW_POPUP);
        if (preeditWindow is null) error (SWT.ERROR_NO_HANDLES);
        preeditLabel = cast(GtkLabel*) OS.gtk_label_new (null);
        if (preeditLabel is null) error (SWT.ERROR_NO_HANDLES);
        OS.gtk_container_add (cast(GtkContainer*)preeditWindow, cast(GtkWidget*) preeditLabel);
        OS.gtk_widget_show (cast(GtkWidget*)preeditLabel);
    }
    char* preeditString;
    PangoAttrList* pangoAttrs;
    auto imHandle = control.imHandle ();
    OS.gtk_im_context_get_preedit_string (imHandle, &preeditString, &pangoAttrs, null);
    if (preeditString !is null && OS.strlen (preeditString) > 0) {
        Control widget = control.findBackgroundControl ();
        if (widget is null) widget = control;
        OS.gtk_widget_modify_bg (cast(GtkWidget*)preeditWindow, OS.GTK_STATE_NORMAL, widget.getBackgroundColor ());
        widget.setForegroundColor (cast(GtkWidget*)preeditLabel, control.getForegroundColor());
        OS.gtk_widget_modify_font (cast(GtkWidget*)preeditLabel, control.getFontDescription ());
        if (pangoAttrs !is null) OS.gtk_label_set_attributes (preeditLabel, pangoAttrs);
        OS.gtk_label_set_text (preeditLabel, preeditString);
        Point point = control.toDisplay (control.getIMCaretPos ());
        OS.gtk_window_move (preeditWindow, point.x, point.y);
        GtkRequisition requisition;
        OS.gtk_widget_size_request (cast(GtkWidget*)preeditLabel, &requisition);
        OS.gtk_window_resize (preeditWindow, requisition.width, requisition.height);
        OS.gtk_widget_show (cast(GtkWidget*)preeditWindow);
    } else {
        OS.gtk_widget_hide (cast(GtkWidget*)preeditWindow);
    }
    if (preeditString !is null) OS.g_free (preeditString);
    if (pangoAttrs !is null) OS.pango_attr_list_unref (pangoAttrs);
}

/**
 * Causes the user-interface thread to <em>sleep</em> (that is,
 * to be put in a state where it does not consume CPU cycles)
 * until an event is received or it is otherwise awakened.
 *
 * @return <code>true</code> if an event requiring dispatching was placed on the queue.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #wake
 */
public bool sleep () {
    checkDevice ();
    if (gdkEventCount is 0) {
        gdkEvents = null;
        gdkEventWidgets = null;
    }
    if (settingsChanged) {
        settingsChanged = false;
        runSettingsFld = true;
        return false;
    }
    if (getMessageCount () !is 0) return true;
    if (fds is null) {
        allocated_nfds = 2;
        GPollFD* ptr = cast(GPollFD*) OS.g_malloc( GPollFD.sizeof * allocated_nfds );
        fds = ptr[ 0 .. allocated_nfds ];
    }
    max_priority = timeout = 0;
    auto context = OS.g_main_context_default ();
    bool result = false;
    do {
        if (OS.g_main_context_acquire (context)) {
            result = cast(bool)OS.g_main_context_prepare (context, &max_priority);
            int nfds;
            while ((nfds = OS.g_main_context_query (context, max_priority, &timeout, fds.ptr, allocated_nfds)) > allocated_nfds) {
                OS.g_free (fds.ptr);
                allocated_nfds = nfds;
                GPollFD* ptr = cast(GPollFD*) OS.g_malloc( GPollFD.sizeof * allocated_nfds );
                fds = ptr[ 0 .. allocated_nfds ];
            }
            GPollFunc poll = OS.g_main_context_get_poll_func (context);
            if (poll !is null) {
                if (nfds > 0 || timeout !is 0) {
                    /*
                    * Bug in GTK. For some reason, g_main_context_wakeup() may
                    * fail to wake up the UI thread from the polling function.
                    * The fix is to sleep for a maximum of 50 milliseconds.
                    */
                    if (timeout < 0) timeout = 50;

                    /* Exit the OS lock to allow other threads to enter GTK */
                    Lock lock = OS.lock;
                    int count = lock.lock ();
                    for (int i = 0; i < count; i++) lock.unlock ();
                    try {
                        wake_state = false;
                        poll( fds.ptr, nfds, timeout);
                    } finally {
                        for (int i = 0; i < count; i++) lock.lock ();
                        lock.unlock ();
                    }
                }
            }
            OS.g_main_context_check (context, max_priority, fds.ptr, nfds);
            OS.g_main_context_release (context);
        }
    } while (!result && getMessageCount () is 0 && !wake_state);
    wake_state = false;
    return true;
}

/**
 * Causes the <code>run()</code> method of the runnable to
 * be invoked by the user-interface thread after the specified
 * number of milliseconds have elapsed. If milliseconds is less
 * than zero, the runnable is not executed.
 * <p>
 * Note that at the time the runnable is invoked, widgets
 * that have the receiver as their display may have been
 * disposed. Therefore, it is necessary to check for this
 * case inside the runnable before accessing the widget.
 * </p>
 *
 * @param milliseconds the delay before running the runnable
 * @param runnable code to run on the user-interface thread
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the runnable is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #asyncExec
 */
public void timerExec (int milliseconds, Runnable runnable) {
    checkDevice ();
    if (runnable is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (timerList is null) timerList = new Runnable [4];
    if (timerIds is null) timerIds = new int [4];
    int index = 0;
    while (index < timerList.length) {
        if (timerList [index] is runnable) break;
        index++;
    }
    if (index !is timerList.length) {
        OS.gtk_timeout_remove (timerIds [index]);
        timerList [index] = null;
        timerIds [index] = 0;
        if (milliseconds < 0) return;
    } else {
        if (milliseconds < 0) return;
        index = 0;
        while (index < timerList.length) {
            if (timerList [index] is null) break;
            index++;
        }
        if (index is timerList.length) {
            Runnable [] newTimerList = new Runnable [timerList.length + 4];
            SimpleType!(Runnable).arraycopy (timerList, 0, newTimerList, 0, timerList.length);
            timerList = newTimerList;
            int [] newTimerIds = new int [timerIds.length + 4];
            System.arraycopy (timerIds, 0, newTimerIds, 0, timerIds.length);
            timerIds = newTimerIds;
        }
    }
    timerProcCallbackData.display = this;
    timerProcCallbackData.data = cast(void*)index;
    int timerId = OS.gtk_timeout_add (milliseconds, &timerProcFunc, &timerProcCallbackData);
    if (timerId !is 0) {
        timerIds [index] = timerId;
        timerList [index] = runnable;
    }
}


private static extern(C) int timerProcFunc ( void * data ) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    CallbackData* cbdata = cast( CallbackData* ) data;
    return cbdata.display.timerProc( cast(int) cbdata.data );
}

int timerProc (int i) {
    if (timerList is null) return 0;
    int index = i;
    if (0 <= index && index < timerList.length) {
        Runnable runnable = timerList [index];
        timerList [index] = null;
        timerIds [index] = 0;
        if (runnable !is null) runnable.run ();
    }
    return 0;
}

private static extern(C) int caretProcFunc ( void * data ) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    CallbackData* cbdata = cast( CallbackData* ) data;
    return cbdata.display.caretProc( cast(int) cbdata.data );
}
int caretProc (ptrdiff_t clientData) {
    caretId = 0;
    if (currentCaret is null) {
        return 0;
    }
    if (currentCaret.blinkCaret()) {
        int blinkRate = currentCaret.blinkRate;
        if (blinkRate is 0) return 0;
        caretProcCallbackData.display = this;
        caretProcCallbackData.data = cast(void*)0;
        caretId = OS.gtk_timeout_add (blinkRate, &caretProcFunc, &caretProcCallbackData);
    } else {
        currentCaret = null;
    }
    return 0;
}


package ptrdiff_t doSizeAllocateConnect( CallbackData* cbdata, GtkWidget* window, GtkWidget* widget ){
    cbdata.display = this;
    cbdata.data = cast(void*)widget;
    return OS.g_signal_connect (cast(void*)window, OS.size_allocate.ptr, cast(GCallback)&sizeAllocateProcFunc, cast(void*)&cbdata);
}

private static extern(C) void sizeAllocateProcFunc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    auto cbdata = cast(CallbackData*)user_data;
    cbdata.display.sizeAllocateProc( cast(GtkWidget*)handle, arg0, cast(int)cbdata.data );
}

void sizeAllocateProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    Widget widget = getWidget ( cast(GtkWidget*)user_data);
    if (widget is null) return;
    widget.sizeAllocateProc (handle, arg0, user_data);
}


package ptrdiff_t doSizeRequestConnect( CallbackData* cbdata, GtkWidget* window, GtkWidget* widget ){
    cbdata.display = this;
    cbdata.data = cast(void*)widget;
    return OS.g_signal_connect (cast(void*)window, OS.size_request.ptr, cast(GCallback)&sizeRequestProcFunc, cast(void*)&cbdata );
}

private static extern(C) void  sizeRequestProcFunc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    auto cbdata = cast(CallbackData*)user_data;
    cbdata.display.sizeRequestProcMeth( cast(GtkWidget*)handle, arg0, cast(int)cbdata.data );
}

ptrdiff_t sizeRequestProcMeth (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    Widget widget = getWidget (cast(GtkWidget*)user_data);
    if (widget is null) return 0;
    return widget.sizeRequestProc (handle, arg0, user_data);
}

package void doTreeSelectionProcConnect( CallbackData* cbdata, GtkWidget* widget, GtkTreeSelection* selection ){
    cbdata.display = this;
    cbdata.data = cast(void*)widget;
    OS.gtk_tree_selection_selected_foreach (selection, &treeSelectionProcFunc, widget);
}

private static extern(C) void  treeSelectionProcFunc (GtkTreeModel *model, GtkTreePath *path, GtkTreeIter *iter, void* data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    auto cbdata = cast(CallbackData*)data;
    cbdata.display.treeSelectionProcMeth( model, path, iter, cbdata.data );
}

void treeSelectionProcMeth (GtkTreeModel *model, GtkTreePath *path, GtkTreeIter *iter, void* data) {
    Widget widget = getWidget (cast(GtkWidget*)data);
    if (widget is null) return;
    widget.treeSelectionProc (model, path, iter, treeSelection, treeSelectionLength++);
}

void saveResources () {
    ptrdiff_t resourceCount = 0;
    if (resources is null) {
        resources = new Resource [RESOURCE_SIZE];
    } else {
        resourceCount = resources.length;
        Resource [] newResources = new Resource [resourceCount + RESOURCE_SIZE];
        System.arraycopy (resources, 0, newResources, 0, resourceCount);
        resources = newResources;
    }
    if (systemFont !is null) {
        resources [resourceCount++] = systemFont;
        systemFont = null;
    }
    if (errorImage !is null) resources [resourceCount++] = errorImage;
    if (infoImage !is null) resources [resourceCount++] = infoImage;
    if (questionImage !is null) resources [resourceCount++] = questionImage;
    if (warningImage !is null) resources [resourceCount++] = warningImage;
    errorImage = infoImage = questionImage = warningImage = null;
    for (int i=0; i<cursors.length; i++) {
        if (cursors [i] !is null) resources [resourceCount++] = cursors [i];
        cursors [i] = null;
    }
    if (resourceCount < RESOURCE_SIZE) {
        Resource [] newResources = new Resource [resourceCount];
        System.arraycopy (resources, 0, newResources, 0, resourceCount);
        resources = newResources;
    }
}

void sendEvent (int eventType, Event event) {
    if (eventTable is null && filterTable is null) {
        return;
    }
    if (event is null) event = new Event ();
    event.display = this;
    event.type = eventType;
    if (event.time is 0) event.time = getLastEventTime ();
    if (!filterEvent (event)) {
        if (eventTable !is null) eventTable.sendEvent (event);
    }
}

void setCurrentCaret (Caret caret) {
    if (caretId !is 0) OS.gtk_timeout_remove(caretId);
    caretId = 0;
    currentCaret = caret;
    if (caret is null) return;
    int blinkRate = currentCaret.blinkRate;
    caretProcCallbackData.display = this;
    caretProcCallbackData.data = cast(void*)0;
    caretId = OS.gtk_timeout_add (blinkRate, &caretProcFunc, &caretProcCallbackData);
}

private static extern(C) int shellMapProcFunc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    auto cbdata = cast(CallbackData*)user_data;
    return cbdata.display.shellMapProc( cast(GtkWidget*)handle, arg0, cast(int)cbdata.data );
}

int shellMapProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    Widget widget = getWidget (cast(GtkWidget*)handle);
    if (widget is null) return 0;
    return widget.shellMapProc (handle, arg0, user_data);
}

private static extern(C) int styleSetProcFunc (ptrdiff_t gobject, ptrdiff_t arg1, ptrdiff_t user_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    auto cbdata = cast(CallbackData*)user_data;
    return cbdata.display.styleSetProcMeth( gobject, arg1, cast(int)cbdata.data );
}
int styleSetProcMeth (ptrdiff_t gobject, ptrdiff_t arg1, ptrdiff_t user_data) {
    settingsChanged = true;
    return 0;
}

/**
 * Causes the <code>run()</code> method of the runnable to
 * be invoked by the user-interface thread at the next
 * reasonable opportunity. The thread which calls this method
 * is suspended until the runnable completes.  Specifying <code>null</code>
 * as the runnable simply wakes the user-interface thread.
 * <p>
 * Note that at the time the runnable is invoked, widgets
 * that have the receiver as their display may have been
 * disposed. Therefore, it is necessary to check for this
 * case inside the runnable before accessing the widget.
 * </p>
 *
 * @param runnable code to run on the user-interface thread or <code>null</code>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_FAILED_EXEC - if an exception occurred when executing the runnable</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #asyncExec
 */
public void syncExec (Runnable runnable) {
    Synchronizer synchronizer;
    synchronized (Device.classinfo) {
        if (isDisposed ()) error (SWT.ERROR_DEVICE_DISPOSED);
        synchronizer = this.synchronizer;
        synchronized (idleLock) {
            if (idleNeeded && idleHandle is 0) {
                //NOTE: calling unlocked function in OS
            idleProcCallbackData.display = this;
            idleProcCallbackData.data = cast(void*)0;
            //PORTING_TODO: was _g_idle_add, calling directly
            idleHandle = OS.g_idle_add (&idleProcFunc, &idleProcCallbackData);
            }
        }
    }
    synchronizer.syncExec (runnable);
}

static int translateKey (int key) {
    for (int i=0; i<KeyTable.length; i++) {
        if (KeyTable [i] [0] is key) return KeyTable [i] [1];
    }
    return 0;
}

static int untranslateKey (int key) {
    for (int i=0; i<KeyTable.length; i++) {
        if (KeyTable [i] [1] is key) return KeyTable [i] [0];
    }
    return 0;
}

/**
 * Forces all outstanding paint requests for the display
 * to be processed before this method returns.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see Control#update()
 */
public void update () {
    checkDevice ();
    flushExposes (null, true);
    OS.gdk_window_process_all_updates ();
}

/**
 * If the receiver's user-interface thread was <code>sleep</code>ing,
 * causes it to be awakened and start running again. Note that this
 * method may be called from any thread.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #sleep
 */
public void wake () {
    synchronized (Device.classinfo) {
        if (isDisposed ()) error (SWT.ERROR_DEVICE_DISPOSED);
        if (thread is Thread.currentThread ()) return;
        wakeThread ();
    }
}

void wakeThread () {
    OS.g_main_context_wakeup (null);
    wake_state = true;
}

static dchar wcsToMbcs (char ch) {
    //PORTING_TODO not sure about this
    int key = ch & 0xFFFF;
    if (key <= 0x7F) return ch;
    char [] buffer = Converter.wcsToMbcs (null,[ch], false);
    if (buffer.length is 1) return '\0';
    if (buffer.length is 2) {
        return cast(char) (((buffer [0] & 0xFF) << 8) | (buffer [1] & 0xFF));
    }
    return '\0';
}

private static extern(C) int windowProcFunc2 (GtkWidget* handle, ptrdiff_t user_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    CallbackData* cbdata = cast(CallbackData*)user_data;
    return cbdata.display.windowProc( handle, cast(ptrdiff_t)cbdata.data );
}
int windowProc (GtkWidget* handle, ptrdiff_t user_data) {
    Widget widget = getWidget (handle);
    if (widget is null) return 0;
    return widget.windowProc (handle, user_data);
}

private static extern(C) int windowProcFunc3 (ptrdiff_t handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    CallbackData* cbdata = cast(CallbackData*)user_data;
    return cbdata.display.windowProc( cast(GtkWidget*)handle, arg0, cast(ptrdiff_t)cbdata.data );
}
int windowProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t user_data) {
    Widget widget = getWidget (handle);
    if (widget is null) return 0;
    return widget.windowProc (handle, arg0, user_data);
}

private static extern(C) int windowProcFunc4 (ptrdiff_t handle, ptrdiff_t arg0, ptrdiff_t arg1, ptrdiff_t user_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    CallbackData* cbdata = cast(CallbackData*)user_data;
    return cbdata.display.windowProc( cast(GtkWidget*)handle, arg0, arg1, cast(ptrdiff_t)cbdata.data );
}
int windowProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t arg1, ptrdiff_t user_data) {
    Widget widget = getWidget (handle);
    if (widget is null) return 0;
    return widget.windowProc (handle, arg0, arg1, user_data);
}

private static extern(C) int windowProcFunc5 (ptrdiff_t handle, ptrdiff_t arg0, ptrdiff_t arg1, ptrdiff_t arg2, ptrdiff_t user_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    CallbackData* cbdata = cast(CallbackData*)user_data;
    return cbdata.display.windowProc( cast(GtkWidget*)handle, arg0, arg1, arg2, cast(ptrdiff_t)cbdata.data );
}
int windowProc (GtkWidget* handle, ptrdiff_t arg0, ptrdiff_t arg1, ptrdiff_t arg2, ptrdiff_t user_data) {
    Widget widget = getWidget (handle);
    if (widget is null) return 0;
    return widget.windowProc (handle, arg0, arg1, arg2, user_data);
}

private static extern(C) int windowProcChangeValueFunc(GtkWidget* handle, int scroll, double value1, void* user_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    CallbackData* cbdata = cast(CallbackData*)user_data;
    Widget widget = cbdata.display.getWidget (handle);
    if (widget is null) return 0;
    return widget.gtk_change_value(handle, scroll, value1, user_data);
}

package int doWindowTimerAdd( CallbackData* cbdata, int delay, GtkWidget* widget ){
    OS.g_object_set_data(cast(GObject*)widget, Display.classinfo.name.ptr, cast(void*)this);
    return OS.gtk_timeout_add (delay, &windowTimerProcFunc, widget);
}
private static extern(C) int windowTimerProcFunc (void* user_data) {
    version(LOG) getDwtLogger().error( __FILE__, __LINE__,  "Display {}:", __LINE__ ).flush;
    Display d = cast(Display) OS.g_object_get_data(cast(GObject*)user_data, Display.classinfo.name.ptr );
    return d.windowTimerProc( cast(GtkWidget*)user_data );
}

int windowTimerProc (GtkWidget* handle) {
    Widget widget = getWidget (handle);
    if (widget is null) return 0;
    return widget.timerProc (handle);
}

}

package struct CallbackData {
    Display display;
    void* data;
}

