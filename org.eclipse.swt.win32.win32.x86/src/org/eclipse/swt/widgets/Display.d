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
import org.eclipse.swt.SWTError;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.DeviceData;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Resource;
import org.eclipse.swt.internal.ImageList;
import org.eclipse.swt.internal.Library;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Dialog;
import org.eclipse.swt.widgets.Tray;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.EventTable;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.swt.widgets.Synchronizer;
import org.eclipse.swt.widgets.Monitor;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.TrayItem;

import java.lang.all;
import java.lang.Thread;

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

    /**
     * the handle to the OS message queue
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public MSG* msg;

    /* Windows and Events */
    Event [] eventQueue;
    //Callback windowCallback;
    //ptrdiff_t windowProc_;
    int threadId;
    StringT windowClass_, windowShadowClass;
    mixin(gshared!(`static int WindowClassCount;`));
    static const String WindowName = "SWT_Window"; //$NON-NLS-1$
    static const String WindowShadowName = "SWT_WindowShadow"; //$NON-NLS-1$
    EventTable eventTable, filterTable;

    /* Widget Table */
    ptrdiff_t freeSlot;
    ptrdiff_t [] indexTable;
    Control lastControl, lastGetControl;
    HANDLE lastHwnd;
    HWND lastGetHwnd;
    Control [] controlTable;
    static const int GROW_SIZE = 1024;
    mixin(gshared!(`private static /+const+/ int SWT_OBJECT_INDEX;`));
    mixin(gshared!(`static const bool USE_PROPERTY = !OS.IsWinCE;`));

    mixin(gshared!(`private static bool static_this_completed = false;`));
    private static void static_this() {
        if( static_this_completed ){
            return;
        }
        synchronized {
            if( static_this_completed ){
                return;
            }
            static if (USE_PROPERTY) {
                SWT_OBJECT_INDEX = OS.GlobalAddAtom (StrToTCHARz("SWT_OBJECT_INDEX")); //$NON-NLS-1$
            } else {
                SWT_OBJECT_INDEX = 0;
            }
            static_this_StartupInfo ();
            static_this_DeviceFinder ();
            static_this_completed = true;
        }
    }

    /* Startup info */
    mixin(gshared!(`static STARTUPINFO* lpStartupInfo;`));
    private static void static_this_StartupInfo (){
        static if (!OS.IsWinCE) {
            lpStartupInfo = new STARTUPINFO ();
            lpStartupInfo.cb = STARTUPINFO.sizeof;
            OS.GetStartupInfo (lpStartupInfo);
        }
    }
    /* XP Themes */
    HTHEME hButtonTheme_, hEditTheme_, hExplorerBarTheme_, hScrollBarTheme_, hTabTheme_;
    static const wchar [] BUTTON = "BUTTON\0"w;
    static const wchar [] EDIT = "EDIT\0"w;
    static const wchar [] EXPLORER = "EXPLORER\0"w;
    static const wchar [] EXPLORERBAR = "EXPLORERBAR\0"w;
    static const wchar [] SCROLLBAR = "SCROLLBAR\0"w;
    static const wchar [] LISTVIEW = "LISTVIEW\0"w;
    static const wchar [] TAB = "TAB\0"w;
    static const wchar [] TREEVIEW = "TREEVIEW\0"w;

    /* Focus */
    int focusEvent;
    Control focusControl;

    /* Menus */
    Menu [] bars, popups;
    MenuItem [] items;

    /*
    * The start value for WM_COMMAND id's.
    * Windows reserves the values 0..100.
    *
    * The SmartPhone SWT resource file reserves
    * the values 101..107.
    */
    static const int ID_START = 108;

    /* Filter Hook */
    //Callback msgFilterCallback;
    //int msgFilterProc_,
    HHOOK filterHook;
    bool runDragDrop = true, dragCancelled = false;
    MSG* hookMsg;

    /* Idle Hook */
    //Callback foregroundIdleCallback;
    //int foregroundIdleProc_;
    HHOOK idleHook;

    /* Message Hook and Embedding */
    bool ignoreNextKey;
    //Callback getMsgCallback, embeddedCallback;
    int getMsgProc_;
    HHOOK msgHook;
    HWND embeddedHwnd;
    int embeddedProc_;
    static const String AWT_WINDOW_CLASS = "SunAwtWindow";
    static const short [] ACCENTS = [ cast(short) '~', '`', '\'', '^', '"'];

    /* Sync/Async Widget Communication */
    Synchronizer synchronizer;
    bool runMessages = true, runMessagesInIdle = false, runMessagesInMessageProc = true;
    static const String RUN_MESSAGES_IN_IDLE_KEY = "org.eclipse.swt.internal.win32.runMessagesInIdle"; //$NON-NLS-1$
    static const String RUN_MESSAGES_IN_MESSAGE_PROC_KEY = "org.eclipse.swt.internal.win32.runMessagesInMessageProc"; //$NON-NLS-1$
    Thread thread;

    /* Display Shutdown */
    Runnable [] disposeList;

    /* System Tray */
    Tray tray;
    int nextTrayId;

    /* Timers */
    UINT_PTR [] timerIds;
    Runnable [] timerList;
    UINT_PTR nextTimerId = SETTINGS_ID + 1;
    static const int SETTINGS_ID = 100;
    static const int SETTINGS_DELAY = 2000;

    /* Keyboard and Mouse */
    RECT* clickRect;
    int clickCount, lastTime, lastButton;
    HWND lastClickHwnd;
    int scrollRemainder;
    int lastKey, lastAscii, lastMouse;
    bool lastVirtual, lastNull, lastDead;
    ubyte [256] keyboard;
    bool accelKeyHit, mnemonicKeyHit;
    bool lockActiveWindow, captureChanged, xMouse;

    /* Tool Tips */
    int nextToolTipId;

    /* MDI */
    bool ignoreRestoreFocus;
    Control lastHittestControl;
    int lastHittest;

    /* Message Only Window */
    HWND hwndMessage;

    /* System Resources */
    LOGFONT* lfSystemFont;
    Font systemFont;
    Image errorImage, infoImage, questionImage, warningIcon;
    Cursor [] cursors;
    Resource [] resources;
    static const int RESOURCE_SIZE = 1 + 4 + SWT.CURSOR_HAND + 1;

    /* ImageList Cache */
    ImageList[] imageList, toolImageList, toolHotImageList, toolDisabledImageList;

    /* Custom Colors for ChooseColor */
    COLORREF* lpCustColors;

    /* Sort Indicators */
    Image upArrow, downArrow;

    /* Table */
    char [] tableBuffer;
    NMHDR* hdr;
    NMLVDISPINFO* plvfi;
    HWND hwndParent;
    int columnCount;
    bool [] columnVisible;

    /* Resize and move recursion */
    int resizeCount;
    static const int RESIZE_LIMIT = 4;

    /* Display Data */
    Object data;
    String [] keys;
    Object [] values;

    /* Key Mappings */
    mixin(gshared!(`static const int [] [] KeyTable = [

        /* Keyboard and Mouse Masks */
        [OS.VK_MENU,    SWT.ALT],
        [OS.VK_SHIFT,   SWT.SHIFT],
        [OS.VK_CONTROL, SWT.CONTROL],
//      [OS.VK_????,    SWT.COMMAND],

        /* NOT CURRENTLY USED */
//      [OS.VK_LBUTTON, SWT.BUTTON1],
//      [OS.VK_MBUTTON, SWT.BUTTON3],
//      [OS.VK_RBUTTON, SWT.BUTTON2],

        /* Non-Numeric Keypad Keys */
        [OS.VK_UP,      SWT.ARROW_UP],
        [OS.VK_DOWN,    SWT.ARROW_DOWN],
        [OS.VK_LEFT,    SWT.ARROW_LEFT],
        [OS.VK_RIGHT,   SWT.ARROW_RIGHT],
        [OS.VK_PRIOR,   SWT.PAGE_UP],
        [OS.VK_NEXT,    SWT.PAGE_DOWN],
        [OS.VK_HOME,    SWT.HOME],
        [OS.VK_END,     SWT.END],
        [OS.VK_INSERT,  SWT.INSERT],

        /* Virtual and Ascii Keys */
        [OS.VK_BACK,    SWT.BS],
        [OS.VK_RETURN,  SWT.CR],
        [OS.VK_DELETE,  SWT.DEL],
        [OS.VK_ESCAPE,  SWT.ESC],
        [OS.VK_RETURN,  SWT.LF],
        [OS.VK_TAB,     SWT.TAB],

        /* Functions Keys */
        [OS.VK_F1,  SWT.F1],
        [OS.VK_F2,  SWT.F2],
        [OS.VK_F3,  SWT.F3],
        [OS.VK_F4,  SWT.F4],
        [OS.VK_F5,  SWT.F5],
        [OS.VK_F6,  SWT.F6],
        [OS.VK_F7,  SWT.F7],
        [OS.VK_F8,  SWT.F8],
        [OS.VK_F9,  SWT.F9],
        [OS.VK_F10, SWT.F10],
        [OS.VK_F11, SWT.F11],
        [OS.VK_F12, SWT.F12],
        [OS.VK_F13, SWT.F13],
        [OS.VK_F14, SWT.F14],
        [OS.VK_F15, SWT.F15],

        /* Numeric Keypad Keys */
        [OS.VK_MULTIPLY,    SWT.KEYPAD_MULTIPLY],
        [OS.VK_ADD,         SWT.KEYPAD_ADD],
        [OS.VK_RETURN,      SWT.KEYPAD_CR],
        [OS.VK_SUBTRACT,    SWT.KEYPAD_SUBTRACT],
        [OS.VK_DECIMAL,     SWT.KEYPAD_DECIMAL],
        [OS.VK_DIVIDE,      SWT.KEYPAD_DIVIDE],
        [OS.VK_NUMPAD0,     SWT.KEYPAD_0],
        [OS.VK_NUMPAD1,     SWT.KEYPAD_1],
        [OS.VK_NUMPAD2,     SWT.KEYPAD_2],
        [OS.VK_NUMPAD3,     SWT.KEYPAD_3],
        [OS.VK_NUMPAD4,     SWT.KEYPAD_4],
        [OS.VK_NUMPAD5,     SWT.KEYPAD_5],
        [OS.VK_NUMPAD6,     SWT.KEYPAD_6],
        [OS.VK_NUMPAD7,     SWT.KEYPAD_7],
        [OS.VK_NUMPAD8,     SWT.KEYPAD_8],
        [OS.VK_NUMPAD9,     SWT.KEYPAD_9],
//      [OS.VK_????,        SWT.KEYPAD_EQUAL],

        /* Other keys */
        [OS.VK_CAPITAL,     SWT.CAPS_LOCK],
        [OS.VK_NUMLOCK,     SWT.NUM_LOCK],
        [OS.VK_SCROLL,      SWT.SCROLL_LOCK],
        [OS.VK_PAUSE,       SWT.PAUSE],
        [OS.VK_CANCEL,      SWT.BREAK],
        [OS.VK_SNAPSHOT,    SWT.PRINT_SCREEN],
//      [OS.VK_????,        SWT.HELP],

    ];`));

    /* Multiple Displays */
    mixin(gshared!(`static Display Default;`));
    mixin(gshared!(`static Display [] Displays;`));

    /* Multiple Monitors */
    org.eclipse.swt.widgets.Monitor.Monitor[] monitors = null;
    int monitorCount = 0;

    /* Modality */
    Shell [] modalShells;
    Dialog modalDialog;
    static bool TrimEnabled = false;

    /* Private SWT Window Messages */
    mixin(gshared!(`static const int SWT_GETACCELCOUNT  = OS.WM_APP;`));
    mixin(gshared!(`static const int SWT_GETACCEL       = OS.WM_APP + 1;`));
    mixin(gshared!(`static const int SWT_KEYMSG         = OS.WM_APP + 2;`));
    mixin(gshared!(`static const int SWT_DESTROY        = OS.WM_APP + 3;`));
    mixin(gshared!(`static const int SWT_TRAYICONMSG    = OS.WM_APP + 4;`));
    mixin(gshared!(`static const int SWT_NULL           = OS.WM_APP + 5;`));
    mixin(gshared!(`static const int SWT_RUNASYNC       = OS.WM_APP + 6;`));
    mixin(gshared!(`static int SWT_TASKBARCREATED;`));
    mixin(gshared!(`static int SWT_RESTORECARET;`));
    mixin(gshared!(`static int DI_GETDRAGIMAGE;`));

    /* Workaround for Adobe Reader 7.0 */
    int hitCount;

    /* Package Name */
    static const String PACKAGE_PREFIX = "org.eclipse.swt.widgets."; //$NON-NLS-1$
    /*
    * This code is intentionally commented.  In order
    * to support CLDC, .class cannot be used because
    * it does not compile on some Java compilers when
    * they are targeted for CLDC.
    */
//  static {
//      String name = Display.class.getName ();
//      int index = name.lastIndexOf ('.');
//      PACKAGE_PREFIX = name.substring (0, index + 1);
//  }

    /*
    * TEMPORARY CODE.  Install the runnable that
    * gets the current display. This code will
    * be removed in the future.
    */
    private static void static_this_DeviceFinder () {
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
    static_this();
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
    static_this();
    msg = new MSG();
    hookMsg = new MSG();
    super (data);
    synchronizer = new Synchronizer (this);
    cursors = new Cursor [SWT.CURSOR_HAND + 1];
}

Control _getFocusControl () {
    return findControl (OS.GetFocus ());
}

void addBar (Menu menu) {
    if (bars is null) bars = new Menu [4];
    int length_ = cast(int)/*64bit*/bars.length;
    for (int i=0; i<length_; i++) {
        if (bars [i] is menu) return;
    }
    int index = 0;
    while (index < length_) {
        if (bars [index] is null) break;
        index++;
    }
    if (index is length_) {
        Menu [] newBars = new Menu [length_ + 4];
        System.arraycopy (bars, 0, newBars, 0, length_);
        bars = newBars;
    }
    bars [index] = menu;
}

void addControl (HANDLE handle, Control control) {
    if (handle is null) return;
    if (freeSlot is -1) {
        auto length_ = (freeSlot = indexTable.length) + GROW_SIZE;
        ptrdiff_t [] newIndexTable = new ptrdiff_t [length_];
        Control [] newControlTable = new Control [length_];
        System.arraycopy (indexTable, 0, newIndexTable, 0, freeSlot);
        System.arraycopy (controlTable, 0, newControlTable, 0, freeSlot);
        for (auto i=freeSlot; i<length_-1; i++) newIndexTable [i] = i + 1;
        newIndexTable [length_ - 1] = -1;
        indexTable = newIndexTable;
        controlTable = newControlTable;
    }
    static if (USE_PROPERTY) {
        OS.SetProp (handle, cast(wchar*)SWT_OBJECT_INDEX, cast(void*) freeSlot + 1);
    } else {
        OS.SetWindowLongPtr (handle, OS.GWLP_USERDATA, freeSlot + 1);
    }
    auto oldSlot = freeSlot;
    freeSlot = indexTable [oldSlot];
    indexTable [oldSlot] = -2;
    controlTable [oldSlot] = control;
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

void addMenuItem (MenuItem item) {
    if (items is null) items = new MenuItem [64];
    for (int i=0; i<items.length; i++) {
        if (items [i] is null) {
            item.id = i + ID_START;
            items [i] = item;
            return;
        }
    }
    item.id = cast(int)/*64bit*/items.length + ID_START;
    MenuItem [] newItems = new MenuItem [items.length + 64];
    newItems [items.length] = item;
    System.arraycopy (items, 0, newItems, 0, items.length);
    items = newItems;
}

void addPopup (Menu menu) {
    if (popups is null) popups = new Menu [4];
    int length_ = cast(int)/*64bit*/popups.length;
    for (int i=0; i<length_; i++) {
        if (popups [i] is menu) return;
    }
    int index = 0;
    while (index < length_) {
        if (popups [index] is null) break;
        index++;
    }
    if (index is length_) {
        Menu [] newPopups = new Menu [length_ + 4];
        System.arraycopy (popups, 0, newPopups, 0, length_);
        popups = newPopups;
    }
    popups [index] = menu;
}

int asciiKey (int key) {
    static if (OS.IsWinCE) return 0;

    /* Get the current keyboard. */
    for (int i=0; i<keyboard.length; i++) keyboard [i] = 0;
    if (!OS.GetKeyboardState (keyboard.ptr)) return 0;

    /* Translate the key to ASCII or UNICODE using the virtual keyboard */
    static if (OS.IsUnicode) {
        wchar result;
        if (OS.ToUnicode (key, key, keyboard.ptr, &result, 1, 0) is 1) return result;
    } else {
        short [] result = new short [1];
        if (OS.ToAscii (key, key, keyboard, result, 0) is 1) return result [0];
    }
    return 0;
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
    checkDevice ();
    OS.MessageBeep (OS.MB_OK);
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
    //if (!isValidClass (getClass ())) error (SWT.ERROR_INVALID_SUBCLASS);
}

override protected void checkDevice () {
    if (thread is null) error (SWT.ERROR_WIDGET_DISPOSED);
    if (thread !is Thread.currentThread ()) {
        /*
        * Bug in IBM JVM 1.6.  For some reason, under
        * conditions that are yet to be full understood,
        * Thread.currentThread() is either returning null
        * or a different instance from the one that was
        * saved when the Display was created.  This is
        * possibly a JIT problem because modifying this
        * method to print logging information when the
        * error happens seems to fix the problem.  The
        * fix is to use operating system calls to verify
        * that the current thread is not the Display thread.
        * 
        * NOTE: Despite the fact that Thread.currentThread()
        * is used in other places, the failure has not been
        * observed in all places where it is called. 
        */
        if (threadId !is OS.GetCurrentThreadId ()) {
            error (SWT.ERROR_THREAD_INVALID_ACCESS);
        }
    }
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

void clearModal (Shell shell) {
    if (modalShells is null) return;
    int index = 0, length_ = cast(int)/*64bit*/modalShells.length;
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

int controlKey (int key) {
    int upper = cast(int)OS.CharUpper (cast(wchar*) key);
    if (64 <= upper && upper <= 95) return upper & 0xBF;
    return key;
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
override protected void create (DeviceData data) {
    checkSubclass ();
    checkDisplay (thread = Thread.currentThread (), true);
    createDisplay (data);
    register (this);
    if (Default is null) Default = this;
}

void createDisplay (DeviceData data) {
}

static HBITMAP create32bitDIB (Image image) {
    static_this();
    int transparentPixel = -1, alpha = -1;
    HBITMAP hMask;
    HBITMAP hBitmap;
    byte[] alphaData = null;
    switch (image.type) {
        case SWT.ICON:
            ICONINFO info;
            OS.GetIconInfo (image.handle, &info);
            hBitmap = info.hbmColor;
            hMask = info.hbmMask;
            break;
        case SWT.BITMAP:
            ImageData data = image.getImageData ();
            hBitmap = image.handle;
            alpha = data.alpha;
            alphaData = data.alphaData;
            transparentPixel = data.transparentPixel;
            break;
        default:
    }
    BITMAP bm;
    OS.GetObject (hBitmap, BITMAP.sizeof, &bm);
    int imgWidth = bm.bmWidth;
    int imgHeight = bm.bmHeight;
    auto hDC = OS.GetDC (null);
    auto srcHdc = OS.CreateCompatibleDC (hDC);
    auto oldSrcBitmap = OS.SelectObject (srcHdc, hBitmap);
    auto memHdc = OS.CreateCompatibleDC (hDC);
    BITMAPINFOHEADER bmiHeader;
    bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
    bmiHeader.biWidth = imgWidth;
    bmiHeader.biHeight = -imgHeight;
    bmiHeader.biPlanes = 1;
    bmiHeader.biBitCount = cast(short)32;
    bmiHeader.biCompression = OS.BI_RGB;
    byte [] bmi = new byte [BITMAPINFOHEADER.sizeof];
    bmi[ 0 .. BITMAPINFOHEADER.sizeof ] = (cast(byte*)&bmiHeader)[ 0 .. BITMAPINFOHEADER.sizeof ];
    void* pBits;
    auto memDib = OS.CreateDIBSection (null, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS, &pBits, null, 0);
    if (memDib is null) SWT.error (SWT.ERROR_NO_HANDLES);
    auto oldMemBitmap = OS.SelectObject (memHdc, memDib);
    BITMAP dibBM;
    OS.GetObject (memDib, BITMAP.sizeof, &dibBM);
    int sizeInBytes = dibBM.bmWidthBytes * dibBM.bmHeight;
    OS.BitBlt (memHdc, 0, 0, imgWidth, imgHeight, srcHdc, 0, 0, OS.SRCCOPY);
    byte red = 0, green = 0, blue = 0;
    if (transparentPixel !is -1) {
        if (bm.bmBitsPixel <= 8) {
            byte [4] color;
            OS.GetDIBColorTable (srcHdc, transparentPixel, 1, cast(RGBQUAD*)color.ptr);
            blue = color [0];
            green = color [1];
            red = color [2];
        } else {
            switch (bm.bmBitsPixel) {
                case 16:
                    blue = cast(byte)((transparentPixel & 0x1F) << 3);
                    green = cast(byte)((transparentPixel & 0x3E0) >> 2);
                    red = cast(byte)((transparentPixel & 0x7C00) >> 7);
                    break;
                case 24:
                    blue = cast(byte)((transparentPixel & 0xFF0000) >> 16);
                    green = cast(byte)((transparentPixel & 0xFF00) >> 8);
                    red = cast(byte)(transparentPixel & 0xFF);
                    break;
                case 32:
                    blue = cast(byte)((transparentPixel & 0xFF000000) >>> 24);
                    green = cast(byte)((transparentPixel & 0xFF0000) >> 16);
                    red = cast(byte)((transparentPixel & 0xFF00) >> 8);
                    break;
                default:
            }
        }
    }
    byte [] srcData = (cast(byte*)pBits)[ 0 .. sizeInBytes].dup;
    if (hMask !is null) {
        OS.SelectObject(srcHdc, hMask);
        for (int y = 0, dp = 0; y < imgHeight; ++y) {
            for (int x = 0; x < imgWidth; ++x) {
                if (OS.GetPixel(srcHdc, x, y) !is 0) {
                    srcData [dp + 0] = srcData [dp + 1] = srcData [dp + 2] = srcData[dp + 3] = cast(byte)0;
                } else {
                    srcData[dp + 3] = cast(byte)0xFF;
                }
                dp += 4;
            }
        }
    } else if (alpha !is -1) {
        for (int y = 0, dp = 0; y < imgHeight; ++y) {
            for (int x = 0; x < imgWidth; ++x) {
                srcData [dp + 3] = cast(byte)alpha;
                if (srcData [dp + 3] is 0) srcData [dp + 0] = srcData [dp + 1] = srcData [dp + 2] = 0;
                dp += 4;
            }
        }
    } else if (alphaData !is null) {
        for (int y = 0, dp = 0, ap = 0; y < imgHeight; ++y) {
            for (int x = 0; x < imgWidth; ++x) {
                srcData [dp + 3] = alphaData [ap++];
                if (srcData [dp + 3] is 0) srcData [dp + 0] = srcData [dp + 1] = srcData [dp + 2] = 0;
                dp += 4;
            }
        }
    } else if (transparentPixel !is -1) {
        for (int y = 0, dp = 0; y < imgHeight; ++y) {
            for (int x = 0; x < imgWidth; ++x) {
                if (srcData [dp] is blue && srcData [dp + 1] is green && srcData [dp + 2] is red) {
                    srcData [dp + 0] = srcData [dp + 1] = srcData [dp + 2] = srcData [dp + 3] = cast(byte)0;
                } else {
                    srcData [dp + 3] = cast(byte)0xFF;
                }
                dp += 4;
            }
        }
    } else {
        for (int y = 0, dp = 0; y < imgHeight; ++y) {
            for (int x = 0; x < imgWidth; ++x) {
                srcData [dp + 3] = cast(byte)0xFF;
                dp += 4;
            }
        }
    }
    (cast(byte*)pBits)[ 0 .. sizeInBytes] = srcData[];
    OS.SelectObject (srcHdc, oldSrcBitmap);
    OS.SelectObject (memHdc, oldMemBitmap);
    OS.DeleteObject (srcHdc);
    OS.DeleteObject (memHdc);
    OS.ReleaseDC (null, hDC);
    if (hBitmap !is image.handle && hBitmap !is null) OS.DeleteObject (hBitmap);
    if (hMask !is null) OS.DeleteObject (hMask);
    return memDib;
}

static HBITMAP create32bitDIB (HBITMAP hBitmap, int alpha, byte [] alphaData, int transparentPixel) {
    static_this();
    BITMAP bm;
    OS.GetObject (hBitmap, BITMAP.sizeof, &bm);
    int imgWidth = bm.bmWidth;
    int imgHeight = bm.bmHeight;
    auto hDC = OS.GetDC (null);
    auto srcHdc = OS.CreateCompatibleDC (hDC);
    auto oldSrcBitmap = OS.SelectObject (srcHdc, hBitmap);
    auto memHdc = OS.CreateCompatibleDC (hDC);
    BITMAPINFOHEADER bmiHeader;
    bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
    bmiHeader.biWidth = imgWidth;
    bmiHeader.biHeight = -imgHeight;
    bmiHeader.biPlanes = 1;
    bmiHeader.biBitCount = cast(short)32;
    bmiHeader.biCompression = OS.BI_RGB;
    byte [] bmi = (cast(byte*)&bmiHeader)[ 0 .. BITMAPINFOHEADER.sizeof];
    void* pBits;
    auto memDib = OS.CreateDIBSection (null, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS, &pBits, null, 0);
    if (memDib is null) SWT.error (SWT.ERROR_NO_HANDLES);
    auto oldMemBitmap = OS.SelectObject (memHdc, memDib);
    BITMAP dibBM;
    OS.GetObject (memDib, BITMAP.sizeof, &dibBM);
    int sizeInBytes = dibBM.bmWidthBytes * dibBM.bmHeight;
    OS.BitBlt (memHdc, 0, 0, imgWidth, imgHeight, srcHdc, 0, 0, OS.SRCCOPY);
    byte red = 0, green = 0, blue = 0;
    if (transparentPixel !is -1) {
        if (bm.bmBitsPixel <= 8) {
            byte [4] color;
            OS.GetDIBColorTable (srcHdc, transparentPixel, 1, cast(RGBQUAD*)color.ptr);
            blue = color [0];
            green = color [1];
            red = color [2];
        } else {
            switch (bm.bmBitsPixel) {
                case 16:
                    blue = cast(byte)((transparentPixel & 0x1F) << 3);
                    green = cast(byte)((transparentPixel & 0x3E0) >> 2);
                    red = cast(byte)((transparentPixel & 0x7C00) >> 7);
                    break;
                case 24:
                    blue = cast(byte)((transparentPixel & 0xFF0000) >> 16);
                    green = cast(byte)((transparentPixel & 0xFF00) >> 8);
                    red = cast(byte)(transparentPixel & 0xFF);
                    break;
                case 32:
                    blue = cast(byte)((transparentPixel & 0xFF000000) >>> 24);
                    green = cast(byte)((transparentPixel & 0xFF0000) >> 16);
                    red = cast(byte)((transparentPixel & 0xFF00) >> 8);
                    break;
                default:
            }
        }
    }
    OS.SelectObject (srcHdc, oldSrcBitmap);
    OS.SelectObject (memHdc, oldMemBitmap);
    OS.DeleteObject (srcHdc);
    OS.DeleteObject (memHdc);
    OS.ReleaseDC (null, hDC);
    byte [] srcData = (cast(byte*)pBits)[ 0 .. sizeInBytes ].dup;
    if (alpha !is -1) {
        for (int y = 0, dp = 0; y < imgHeight; ++y) {
            for (int x = 0; x < imgWidth; ++x) {
                srcData [dp + 3] = cast(byte)alpha;
                dp += 4;
            }
        }
    } else if (alphaData !is null) {
        for (int y = 0, dp = 0, ap = 0; y < imgHeight; ++y) {
            for (int x = 0; x < imgWidth; ++x) {
                srcData [dp + 3] = alphaData [ap++];
                dp += 4;
            }
        }
    } else if (transparentPixel !is -1) {
        for (int y = 0, dp = 0; y < imgHeight; ++y) {
            for (int x = 0; x < imgWidth; ++x) {
                if (srcData [dp] is blue && srcData [dp + 1] is green && srcData [dp + 2] is red) {
                    srcData [dp + 3] = cast(byte)0;
                } else {
                    srcData [dp + 3] = cast(byte)0xFF;
                }
                dp += 4;
            }
        }
    }
    (cast(byte*)pBits)[ 0 .. sizeInBytes ] = srcData[];
    return memDib;
}

static Image createIcon (Image image) {
    static_this();
    Device device = image.getDevice ();
    ImageData data = image.getImageData ();
    if (data.alpha is -1 && data.alphaData is null) {
        ImageData mask = data.getTransparencyMask ();
        return new Image (device, data, mask);
    }
    int width = data.width, height = data.height;
    HBITMAP hMask, hBitmap;
    auto hDC = device.internal_new_GC (null);
    auto dstHdc = OS.CreateCompatibleDC (hDC);
    HBITMAP oldDstBitmap;
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (5, 1)) {
        hBitmap = Display.create32bitDIB (image.handle, data.alpha, data.alphaData, data.transparentPixel);
        hMask = OS.CreateBitmap (width, height, 1, 1, null);
        oldDstBitmap = OS.SelectObject (dstHdc, hMask);
        OS.PatBlt (dstHdc, 0, 0, width, height, OS.BLACKNESS);
    } else {
        hMask = Display.createMaskFromAlpha (data, width, height);
        /* Icons need black pixels where the mask is transparent */
        hBitmap = OS.CreateCompatibleBitmap (hDC, width, height);
        oldDstBitmap = OS.SelectObject (dstHdc, hBitmap);
        auto srcHdc = OS.CreateCompatibleDC (hDC);
        auto oldSrcBitmap = OS.SelectObject (srcHdc, image.handle);
        OS.PatBlt (dstHdc, 0, 0, width, height, OS.BLACKNESS);
        OS.BitBlt (dstHdc, 0, 0, width, height, srcHdc, 0, 0, OS.SRCINVERT);
        OS.SelectObject (srcHdc, hMask);
        OS.BitBlt (dstHdc, 0, 0, width, height, srcHdc, 0, 0, OS.SRCAND);
        OS.SelectObject (srcHdc, image.handle);
        OS.BitBlt (dstHdc, 0, 0, width, height, srcHdc, 0, 0, OS.SRCINVERT);
        OS.SelectObject (srcHdc, oldSrcBitmap);
        OS.DeleteDC (srcHdc);
    }
    OS.SelectObject (dstHdc, oldDstBitmap);
    OS.DeleteDC (dstHdc);
    device.internal_dispose_GC (hDC, null);
    ICONINFO info;
    info.fIcon = true;
    info.hbmColor = hBitmap;
    info.hbmMask = hMask;
    auto hIcon = OS.CreateIconIndirect (&info);
    if (hIcon is null) SWT.error(SWT.ERROR_NO_HANDLES);
    OS.DeleteObject (hBitmap);
    OS.DeleteObject (hMask);
    return Image.win32_new (device, SWT.ICON, hIcon);
}

static HBITMAP createMaskFromAlpha (ImageData data, int destWidth, int destHeight) {
    static_this();
    int srcWidth = data.width;
    int srcHeight = data.height;
    ImageData mask = ImageData.internal_new (srcWidth, srcHeight, 1,
            new PaletteData([new RGB (0, 0, 0), new RGB (0xff, 0xff, 0xff)]),
            2, null, 1, null, null, -1, -1, -1, 0, 0, 0, 0);
    int ap = 0;
    for (int y = 0; y < mask.height; y++) {
        for (int x = 0; x < mask.width; x++) {
            mask.setPixel (x, y, (data.alphaData [ap++] & 0xff) <= 127 ? 1 : 0);
        }
    }
    auto hMask = OS.CreateBitmap (srcWidth, srcHeight, 1, 1, mask.data.ptr);
    if (srcWidth !is destWidth || srcHeight !is destHeight) {
        auto hdc = OS.GetDC (null);
        auto hdc1 = OS.CreateCompatibleDC (hdc);
        OS.SelectObject (hdc1, hMask);
        auto hdc2 = OS.CreateCompatibleDC (hdc);
        auto hMask2 = OS.CreateBitmap (destWidth, destHeight, 1, 1, null);
        OS.SelectObject (hdc2, hMask2);
        static if (!OS.IsWinCE) OS.SetStretchBltMode(hdc2, OS.COLORONCOLOR);
        OS.StretchBlt (hdc2, 0, 0, destWidth, destHeight, hdc1, 0, 0, srcWidth, srcHeight, OS.SRCCOPY);
        OS.DeleteDC (hdc1);
        OS.DeleteDC (hdc2);
        OS.ReleaseDC (null, hdc);
        OS.DeleteObject(hMask);
        hMask = hMask2;
    }
    return hMask;
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
override protected void destroy () {
    if (this is Default) Default = null;
    deregister (this);
    destroyDisplay ();
}

void destroyDisplay () {
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

void drawMenuBars () {
    if (bars is null) return;
    for (int i=0; i<bars.length; i++) {
        Menu menu = bars [i];
        if (menu !is null && !menu.isDisposed ()) menu.update ();
    }
    bars = null;
}

private static extern(Windows) .LRESULT embeddedFunc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
        case SWT_KEYMSG: {
            MSG* keyMsg = cast(MSG*)lParam;
            OS.TranslateMessage (keyMsg);
            OS.DispatchMessage (keyMsg);
            auto hHeap = OS.GetProcessHeap ();
            OS.HeapFree (hHeap, 0, cast(void*)lParam);
            break;
        }
        case SWT_DESTROY: {
            OS.DestroyWindow (hwnd);
            //if (embeddedCallback !is null) embeddedCallback.dispose ();
            //if (getMsgCallback !is null) getMsgCallback.dispose ();
            //embeddedCallback = getMsgCallback = null;
            //embeddedProc_ = getMsgProc_ = 0;
            break;
        }
        default:
    }
    return OS.DefWindowProc (hwnd, msg, wParam, lParam);
}

/**
 * Does whatever display specific cleanup is required, and then
 * uses the code in <code>SWTError.error</code> to handle the error.
 *
 * @param code the descriptive error code
 *
 * @see SWT#error(int)
 */
void error (int code) {
    SWT.error (code);
}

bool filterEvent (Event event) {
    if (filterTable !is null) filterTable.sendEvent (event);
    return false;
}

bool filters (int eventType) {
    if (filterTable is null) return false;
    return filterTable.hooks (eventType);
}

bool filterMessage (MSG* msg) {
    int message = msg.message;
    if (OS.WM_KEYFIRST <= message && message <= OS.WM_KEYLAST) {
        Control control = findControl (msg.hwnd);
        if (control !is null) {
            if (translateAccelerator (msg, control) || translateMnemonic (msg, control) || translateTraversal (msg, control)) {
                lastAscii = lastKey = 0;
                lastVirtual = lastNull = lastDead = false;
                return true;
            }
        }
    }
    return false;
}

Control findControl (HANDLE handle) {
    if (handle is null) return null;
    HWND hwndOwner = null;
    do {
        Control control = getControl (handle);
        if (control !is null) return control;
        hwndOwner = OS.GetWindow (handle, OS.GW_OWNER);
        handle = OS.GetParent (handle);
    } while (handle !is null && handle !is hwndOwner);
    return null;
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
public Widget findWidget (HANDLE handle) {
    checkDevice ();
    return getControl (handle);
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
public Widget findWidget (HANDLE handle, ptrdiff_t id) {
    checkDevice ();
    //TODO - should ids be long
    Control control = getControl (handle);
    return control !is null ? control.findItem (cast(HANDLE) id) : null;
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
    //TODO - should ids be long
    if (cast(Control)widget) {
        return findWidget ((cast(Control) widget).handle, id);
    }
    return null;
}

private static extern(Windows) .LRESULT foregroundIdleProcFunc (int code, WPARAM wParam, LPARAM lParam) {
    auto d = Display.getCurrent();
    return d.foregroundIdleProc( code, wParam, lParam );
}

.LRESULT foregroundIdleProc (int code, WPARAM wParam, LPARAM lParam) {
    if (code >= 0) {
        if (runMessages && getMessageCount () !is 0) {
            if (runMessagesInIdle) {
                if (runMessagesInMessageProc) {
                    OS.PostMessage (hwndMessage, SWT_RUNASYNC, 0, 0);
                } else {
                    runAsyncMessages (false);
                }
            }
            wakeThread ();
        }
    }
    return OS.CallNextHookEx (idleHook, code, wParam, lParam);
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
    static_this();
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
    Control control = findControl (OS.GetActiveWindow ());
    return control !is null ? control.getShell () : null;
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
override public Rectangle getBounds () {
    checkDevice ();
    if (OS.GetSystemMetrics (OS.SM_CMONITORS) < 2) {
        int width = OS.GetSystemMetrics (OS.SM_CXSCREEN);
        int height = OS.GetSystemMetrics (OS.SM_CYSCREEN);
        return new Rectangle (0, 0, width, height);
    }
    int x = OS.GetSystemMetrics (OS.SM_XVIRTUALSCREEN);
    int y = OS.GetSystemMetrics (OS.SM_YVIRTUALSCREEN);
    int width = OS.GetSystemMetrics (OS.SM_CXVIRTUALSCREEN);
    int height = OS.GetSystemMetrics (OS.SM_CYVIRTUALSCREEN);
    return new Rectangle (x, y, width, height);
}

/**
 * Returns the display which the currently running thread is
 * the user-interface thread for, or null if the currently
 * running thread is not a user-interface thread for any display.
 *
 * @return the current display
 */
public static Display getCurrent () {
    static_this();
    return findDisplay (Thread.currentThread ());
}

int getClickCount (int type, int button, HWND hwnd, LPARAM lParam) {
    switch (type) {
        case SWT.MouseDown:
            int doubleClick = OS.GetDoubleClickTime ();
            if (clickRect is null) clickRect = new RECT ();
            int deltaTime = Math.abs (lastTime - getLastEventTime ());
            POINT pt;
            OS.POINTSTOPOINT (pt, lParam);
            if (lastClickHwnd is hwnd && lastButton is button && (deltaTime <= doubleClick) && OS.PtInRect (clickRect, pt)) {
                clickCount++;
            } else {
                clickCount = 1;
            }
            goto case SWT.MouseDoubleClick;
        case SWT.MouseDoubleClick:
            lastButton = button;
            lastClickHwnd = hwnd;
            lastTime = getLastEventTime ();
            int xInset = OS.GetSystemMetrics (OS.SM_CXDOUBLECLK) / 2;
            int yInset = OS.GetSystemMetrics (OS.SM_CYDOUBLECLK) / 2;
            int x = OS.GET_X_LPARAM (lParam), y = OS.GET_Y_LPARAM (lParam);
            OS.SetRect (clickRect, x - xInset, y - yInset, x + xInset, y + yInset);
            goto case SWT.MouseUp;
        case SWT.MouseUp:
            return clickCount;
        default:
    }
    return 0;
}

/**
 * Returns a rectangle which describes the area of the
 * receiver which is capable of displaying data.
 *
 * @return the client area
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_DEVICE_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 *
 * @see #getBounds
 */
override public Rectangle getClientArea () {
    checkDevice ();
    if (OS.GetSystemMetrics (OS.SM_CMONITORS) < 2) {
        RECT rect;
        OS.SystemParametersInfo (OS.SPI_GETWORKAREA, 0, &rect, 0);
        int width = rect.right - rect.left;
        int height = rect.bottom - rect.top;
        return new Rectangle (rect.left, rect.top, width, height);
    }
    int x = OS.GetSystemMetrics (OS.SM_XVIRTUALSCREEN);
    int y = OS.GetSystemMetrics (OS.SM_YVIRTUALSCREEN);
    int width = OS.GetSystemMetrics (OS.SM_CXVIRTUALSCREEN);
    int height = OS.GetSystemMetrics (OS.SM_CYVIRTUALSCREEN);
    return new Rectangle (x, y, width, height);
}

Control getControl (HANDLE handle) {
    if (handle is null) return null;
    if (lastControl !is null && lastHwnd is handle) {
        return lastControl;
    }
    if (lastGetControl !is null && lastGetHwnd is handle) {
        return lastGetControl;
    }
    ptrdiff_t index;
    static if (USE_PROPERTY) {
        index = cast(ptrdiff_t)OS.GetProp (handle, cast(wchar*)SWT_OBJECT_INDEX) - 1;
    } else {
        index = OS.GetWindowLongPtr (handle, OS.GWLP_USERDATA) - 1;
    }
    if (0 <= index && index < controlTable.length) {
        Control control = controlTable [index];
        /*
        * Because GWL_USERDATA can be used by native widgets that
        * do not belong to SWT, it is possible that GWL_USERDATA
        * could return an index that is in the range of the table,
        * but was not put there by SWT.  Therefore, it is necessary
        * to check the handle of the control that is in the table
        * against the handle that provided the GWL_USERDATA.
        */
        if (control !is null && control.checkHandle (handle)) {
            lastGetHwnd = handle;
            lastGetControl = control;
            return control;
        }
    }
    return null;
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
    checkDevice ();
    POINT pt;
    if (!OS.GetCursorPos (&pt)) return null;
    return findControl (OS.WindowFromPoint (pt));
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
    POINT pt;
    OS.GetCursorPos (&pt);
    return new Point (pt.x, pt.y);
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
    return [
        new Point (OS.GetSystemMetrics (OS.SM_CXCURSOR), OS.GetSystemMetrics (OS.SM_CYCURSOR))];
}

/**
 * Returns the default display. One is created (making the
 * thread that invokes this method its user-interface thread)
 * if it did not already exist.
 *
 * @return the default display
 */
public static Display getDefault () {
    static_this();
    synchronized (Device.classinfo) {
        if (Default is null) Default = new Display ();
        return Default;
    }
}

//PORTING_TODO
/+static bool isValidClass (Class clazz) {
    String name = clazz.getName ();
    int index = name.lastIndexOf ('.');
    return name.substring (0, index + 1).equals (PACKAGE_PREFIX);
}+/

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
    // SWT extension: allow null string
    //if (key is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (key ==/*eq*/RUN_MESSAGES_IN_IDLE_KEY) {
        return new Boolean(runMessagesInIdle);
    }
    if (key.equals (RUN_MESSAGES_IN_MESSAGE_PROC_KEY)) {
        return new Boolean (runMessagesInMessageProc);
    }
    if (keys.length is 0) return null;
    for (int i=0; i<keys.length; i++) {
        if (keys [i] ==/*eq*/key) return values [i];
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
    return SWT.LEFT;
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
    return OS.GetDoubleClickTime ();
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
    return _getFocusControl ();
}

String getFontName (LOGFONT* logFont) {
    wchar* chars;
    static if (OS.IsUnicode) {
        chars = logFont.lfFaceName.ptr;
    } else {
        chars = new char[OS.LF_FACESIZE];
        byte[] bytes = logFont.lfFaceName;
        OS.MultiByteToWideChar (OS.CP_ACP, OS.MB_PRECOMPOSED, bytes, cast(int)/*64bit*/bytes.length, chars, cast(int)/*64bit*/chars.length);
    }
    return TCHARzToStr( chars );
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
    static if (OS.IsWinCE) {
        return false;
    }
    else {
        HIGHCONTRAST pvParam;
        pvParam.cbSize = HIGHCONTRAST.sizeof;
        OS.SystemParametersInfo (OS.SPI_GETHIGHCONTRAST, 0, &pvParam, 0);
        return (pvParam.dwFlags & OS.HCF_HIGHCONTRASTON) !is 0;
    }
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
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (5, 1)) {
        if (getDepth () >= 24) return 32;
    }

    /* Use the character encoding for the default locale */
    LPCTSTR buffer1 = StrToTCHARz( "Control Panel\\Desktop\\WindowMetrics" ); //$NON-NLS-1$

    void* phkResult;
    int result = OS.RegOpenKeyEx ( cast(void*)OS.HKEY_CURRENT_USER, buffer1, 0, OS.KEY_READ, &phkResult);
    if (result !is 0) return 4;
    int depth = 4;
    uint lpcbData;

    /* Use the character encoding for the default locale */
    LPCTSTR buffer2 = StrToTCHARz( "Shell Icon BPP" ); //$NON-NLS-1$
    result = OS.RegQueryValueEx (phkResult , buffer2, null, null, null, &lpcbData);
    if (result is 0) {
        ubyte[] lpData = new ubyte[ lpcbData  / TCHAR.sizeof ];
        lpData[] = 0;
        result = OS.RegQueryValueEx (phkResult , buffer2, null, null, lpData.ptr, &lpcbData);
        if (result is 0) {
            try {
                depth = Integer.parseInt ( cast(String) lpData );
            } catch (NumberFormatException e) {}
        }
    }
    OS.RegCloseKey (phkResult );
    return depth;
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
    return [
        new Point (OS.GetSystemMetrics (OS.SM_CXSMICON), OS.GetSystemMetrics (OS.SM_CYSMICON)),
        new Point (OS.GetSystemMetrics (OS.SM_CXICON), OS.GetSystemMetrics (OS.SM_CYICON))
    ];
}

ImageList getImageList (int style, int width, int height) {
    if (imageList is null) imageList = new ImageList [4];

    int i = 0;
    int length_ = cast(int)/*64bit*/imageList.length;
    while (i < length_) {
        ImageList list = imageList [i];
        if (list is null) break;
        Point size = list.getImageSize();
        if (size.x is width && size.y is height) {
            if (list.getStyle () is style) {
                list.addRef();
                return list;
            }
        }
        i++;
    }

    if (i is length_) {
        ImageList [] newList = new ImageList [length_ + 4];
        System.arraycopy (imageList, 0, newList, 0, length_);
        imageList = newList;
    }

    ImageList list = new ImageList (style);
    imageList [i] = list;
    list.addRef();
    return list;
}

ImageList getImageListToolBar (int style, int width, int height) {
    if (toolImageList is null) toolImageList = new ImageList [4];

    int i = 0;
    int length_ = cast(int)/*64bit*/toolImageList.length;
    while (i < length_) {
        ImageList list = toolImageList [i];
        if (list is null) break;
        Point size = list.getImageSize();
        if (size.x is width && size.y is height) {
            if (list.getStyle () is style) {
                list.addRef();
                return list;
            }
        }
        i++;
    }

    if (i is length_) {
        ImageList [] newList = new ImageList [length_ + 4];
        System.arraycopy (toolImageList, 0, newList, 0, length_);
        toolImageList = newList;
    }

    ImageList list = new ImageList (style);
    toolImageList [i] = list;
    list.addRef();
    return list;
}

ImageList getImageListToolBarDisabled (int style, int width, int height) {
    if (toolDisabledImageList is null) toolDisabledImageList = new ImageList [4];

    int i = 0;
    int length_ = cast(int)/*64bit*/toolDisabledImageList.length;
    while (i < length_) {
        ImageList list = toolDisabledImageList [i];
        if (list is null) break;
        Point size = list.getImageSize();
        if (size.x is width && size.y is height) {
            if (list.getStyle () is style) {
                list.addRef();
                return list;
            }
        }
        i++;
    }

    if (i is length_) {
        ImageList [] newList = new ImageList [length_ + 4];
        System.arraycopy (toolDisabledImageList, 0, newList, 0, length_);
        toolDisabledImageList = newList;
    }

    ImageList list = new ImageList (style);
    toolDisabledImageList [i] = list;
    list.addRef();
    return list;
}

ImageList getImageListToolBarHot (int style, int width, int height) {
    if (toolHotImageList is null) toolHotImageList = new ImageList [4];

    int i = 0;
    int length_ = cast(int)/*64bit*/toolHotImageList.length;
    while (i < length_) {
        ImageList list = toolHotImageList [i];
        if (list is null) break;
        Point size = list.getImageSize();
        if (size.x is width && size.y is height) {
            if (list.getStyle () is style) {
                list.addRef();
                return list;
            }
        }
        i++;
    }

    if (i is length_) {
        ImageList [] newList = new ImageList [length_ + 4];
        System.arraycopy (toolHotImageList, 0, newList, 0, length_);
        toolHotImageList = newList;
    }

    ImageList list = new ImageList (style);
    toolHotImageList [i] = list;
    list.addRef();
    return list;
}

int getLastEventTime () {
    return OS.IsWinCE ? OS.GetTickCount () : OS.GetMessageTime ();
}

MenuItem getMenuItem (int id) {
    if (items is null) return null;
    id = id - ID_START;
    if (0 <= id && id < items.length) return items [id];
    return null;
}

int getMessageCount () {
    return synchronizer.getMessageCount ();
}


Shell getModalShell () {
    if (modalShells is null) return null;
    int index = cast(int)/*64bit*/modalShells.length;
    while (--index >= 0) {
        Shell shell = modalShells [index];
        if (shell !is null) return shell;
    }
    return null;
}

Dialog getModalDialog () {
    return modalDialog;
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
    if (OS.IsWinCE || OS.WIN32_VERSION < OS.VERSION (4, 10)) {
        return [getPrimaryMonitor ()];
    }
    monitors = new org.eclipse.swt.widgets.Monitor.Monitor [4];
    OS.EnumDisplayMonitors (null, null, &monitorEnumFunc, cast(ptrdiff_t)cast(void*)this );
    org.eclipse.swt.widgets.Monitor.Monitor [] result = new org.eclipse.swt.widgets.Monitor.Monitor [monitorCount];
    System.arraycopy (monitors, 0, result, 0, monitorCount);
    monitors = null;
    monitorCount = 0;
    return result;
}

static extern(Windows) .LRESULT getMsgFunc (int code, WPARAM wParam, LPARAM lParam) {
    return Display.getCurrent().getMsgProc( code, wParam, lParam );
}

.LRESULT getMsgProc (int code, WPARAM wParam, LPARAM lParam) {
    if (embeddedHwnd is null) {
        auto hInstance = OS.GetModuleHandle (null);
        embeddedHwnd = OS.CreateWindowEx (0,
            windowClass_.ptr,
            null,
            OS.WS_OVERLAPPED,
            0, 0, 0, 0,
            null,
            null,
            hInstance,
            null);
        //embeddedCallback = new Callback (this, "embeddedProc", 4); //$NON-NLS-1$
        //embeddedProc_ = embeddedCallback.getAddress ();
        //if (embeddedProc_ is 0) error (SWT.ERROR_NO_MORE_CALLBACKS);
        OS.SetWindowLongPtr (embeddedHwnd, OS.GWLP_WNDPROC, cast(LONG_PTR) &embeddedFunc);
    }
    if (code >= 0 && (wParam & OS.PM_REMOVE) !is 0) {
        MSG* msg = cast(MSG*)lParam;
        Control control = null;
        switch (msg.message) {
            case OS.WM_KEYDOWN:
            case OS.WM_KEYUP:
            case OS.WM_SYSKEYDOWN:
            case OS.WM_SYSKEYUP: {
                control = findControl (msg.hwnd);
                if (control !is null) {
                    auto hHeap = OS.GetProcessHeap ();
                    MSG* keyMsg = cast(MSG*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, MSG.sizeof);
                    *keyMsg = *msg;
                    OS.PostMessage (hwndMessage, SWT_KEYMSG, wParam, cast(LPARAM)keyMsg);
                    switch (msg.wParam) {
                        case OS.VK_SHIFT:
                        case OS.VK_MENU:
                        case OS.VK_CONTROL:
                        case OS.VK_CAPITAL:
                        case OS.VK_NUMLOCK:
                        case OS.VK_SCROLL:
                            break;
                        default:
                            msg.message = OS.WM_NULL;
                            //OS.MoveMemory (lParam, msg, MSG.sizeof);
                    }
                }
                break;
            default:
                break;
            }
        }
    }
    return OS.CallNextHookEx (msgHook, code, wParam, lParam);
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
    if (OS.IsWinCE || OS.WIN32_VERSION < OS.VERSION (4, 10)) {
        org.eclipse.swt.widgets.Monitor.Monitor monitor = new org.eclipse.swt.widgets.Monitor.Monitor();
        int width = OS.GetSystemMetrics (OS.SM_CXSCREEN);
        int height = OS.GetSystemMetrics (OS.SM_CYSCREEN);
        monitor.width = width;
        monitor.height = height;
        RECT rect;
        OS.SystemParametersInfo (OS.SPI_GETWORKAREA, 0, &rect, 0);
        monitor.clientX = rect.left;
        monitor.clientY = rect.top;
        monitor.clientWidth = rect.right - rect.left;
        monitor.clientHeight = rect.bottom - rect.top;
        return monitor;
    }
    monitors = new org.eclipse.swt.widgets.Monitor.Monitor [4];
    OS.EnumDisplayMonitors (null, null, &monitorEnumFunc, cast(ptrdiff_t)cast(void*)this);
    org.eclipse.swt.widgets.Monitor.Monitor result = null;
    MONITORINFO lpmi;
    lpmi.cbSize = MONITORINFO.sizeof;
    for (int i = 0; i < monitorCount; i++) {
        org.eclipse.swt.widgets.Monitor.Monitor monitor = monitors [i];
        OS.GetMonitorInfo (monitors [i].handle, &lpmi);
        if ((lpmi.dwFlags & OS.MONITORINFOF_PRIMARY) !is 0) {
            result = monitor;
            break;
        }
    }
    monitors = null;
    monitorCount = 0;
    return result;
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
    for (int i = 0; i < controlTable.length; i++) {
        Control control = controlTable [i];
        if (control !is null && (cast(Shell)control)) {
            int j = 0;
            while (j < index) {
                if (result [j] is control) break;
                j++;
            }
            if (j is index) {
                if (index is result.length) {
                    Shell [] newResult = new Shell [index + 16];
                    System.arraycopy (result, 0, newResult, 0, index);
                    result = newResult;
                }
                result [index++] = cast(Shell) control;
            }
        }
    }
    if (index is result.length) return result;
    Shell [] newResult = new Shell [index];
    System.arraycopy (result, 0, newResult, 0, index);
    return newResult;
}

Image getSortImage (int direction) {
    switch (direction) {
        case SWT.UP: {
            if (upArrow !is null) return upArrow;
            Color c1 = getSystemColor (SWT.COLOR_WIDGET_NORMAL_SHADOW);
            Color c2 = getSystemColor (SWT.COLOR_WIDGET_HIGHLIGHT_SHADOW);
            Color c3 = getSystemColor (SWT.COLOR_WIDGET_BACKGROUND);
            PaletteData palette = new PaletteData([c1.getRGB (), c2.getRGB (), c3.getRGB ()]);
            ImageData imageData = new ImageData (8, 8, 4, palette);
            imageData.transparentPixel = 2;
            upArrow = new Image (this, imageData);
            GC gc = new GC (upArrow);
            gc.setBackground (c3);
            gc.fillRectangle (0, 0, 8, 8);
            gc.setForeground (c1);
            int [] line1 = [0,6, 1,6, 1,4, 2,4, 2,2, 3,2, 3,1];
            gc.drawPolyline (line1);
            gc.setForeground (c2);
            int [] line2 = [0,7, 7,7, 7,6, 6,6, 6,4, 5,4, 5,2, 4,2, 4,1];
            gc.drawPolyline (line2);
            gc.dispose ();
            return upArrow;
        }
        case SWT.DOWN: {
            if (downArrow !is null) return downArrow;
            Color c1 = getSystemColor (SWT.COLOR_WIDGET_NORMAL_SHADOW);
            Color c2 = getSystemColor (SWT.COLOR_WIDGET_HIGHLIGHT_SHADOW);
            Color c3 = getSystemColor (SWT.COLOR_WIDGET_BACKGROUND);
            PaletteData palette = new PaletteData ([c1.getRGB (), c2.getRGB (), c3.getRGB ()]);
            ImageData imageData = new ImageData (8, 8, 4, palette);
            imageData.transparentPixel = 2;
            downArrow = new Image (this, imageData);
            GC gc = new GC (downArrow);
            gc.setBackground (c3);
            gc.fillRectangle (0, 0, 8, 8);
            gc.setForeground (c1);
            int [] line1 = [7,0, 0,0, 0,1, 1,1, 1,3, 2,3, 2,5, 3,5, 3,6];
            gc.drawPolyline (line1);
            gc.setForeground (c2);
            int [] line2 = [4,6, 4,5, 5,5, 5,3, 6,3, 6,1, 7,1];
            gc.drawPolyline (line2);
            gc.dispose ();
            return downArrow;
        }
        default:
    }
    return null;
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
override public Color getSystemColor (int id) {
    checkDevice ();
    int pixel = 0x00000000;
    switch (id) {
        case SWT.COLOR_WIDGET_DARK_SHADOW:      pixel = OS.GetSysColor (OS.COLOR_3DDKSHADOW);   break;
        case SWT.COLOR_WIDGET_NORMAL_SHADOW:    pixel = OS.GetSysColor (OS.COLOR_3DSHADOW);     break;
        case SWT.COLOR_WIDGET_LIGHT_SHADOW:     pixel = OS.GetSysColor (OS.COLOR_3DLIGHT);      break;
        case SWT.COLOR_WIDGET_HIGHLIGHT_SHADOW: pixel = OS.GetSysColor (OS.COLOR_3DHIGHLIGHT);  break;
        case SWT.COLOR_WIDGET_BACKGROUND:       pixel = OS.GetSysColor (OS.COLOR_3DFACE);   break;
        case SWT.COLOR_WIDGET_BORDER:       pixel = OS.GetSysColor (OS.COLOR_WINDOWFRAME);  break;
        case SWT.COLOR_WIDGET_FOREGROUND:
        case SWT.COLOR_LIST_FOREGROUND:         pixel = OS.GetSysColor (OS.COLOR_WINDOWTEXT);   break;
        case SWT.COLOR_LIST_BACKGROUND:         pixel = OS.GetSysColor (OS.COLOR_WINDOW);   break;
        case SWT.COLOR_LIST_SELECTION:      pixel = OS.GetSysColor (OS.COLOR_HIGHLIGHT);    break;
        case SWT.COLOR_LIST_SELECTION_TEXT:     pixel = OS.GetSysColor (OS.COLOR_HIGHLIGHTTEXT);break;
        case SWT.COLOR_INFO_FOREGROUND:     pixel = OS.GetSysColor (OS.COLOR_INFOTEXT); break;
        case SWT.COLOR_INFO_BACKGROUND:     pixel = OS.GetSysColor (OS.COLOR_INFOBK);       break;
        case SWT.COLOR_TITLE_FOREGROUND:        pixel = OS.GetSysColor (OS.COLOR_CAPTIONTEXT);  break;
        case SWT.COLOR_TITLE_BACKGROUND:        pixel = OS.GetSysColor (OS.COLOR_ACTIVECAPTION);        break;
        case SWT.COLOR_TITLE_BACKGROUND_GRADIENT:
            pixel = OS.GetSysColor (OS.COLOR_GRADIENTACTIVECAPTION);
            if (pixel is 0) pixel = OS.GetSysColor (OS.COLOR_ACTIVECAPTION);
            break;
        case SWT.COLOR_TITLE_INACTIVE_FOREGROUND:       pixel = OS.GetSysColor (OS.COLOR_INACTIVECAPTIONTEXT);  break;
        case SWT.COLOR_TITLE_INACTIVE_BACKGROUND:           pixel = OS.GetSysColor (OS.COLOR_INACTIVECAPTION);      break;
        case SWT.COLOR_TITLE_INACTIVE_BACKGROUND_GRADIENT:
            pixel = OS.GetSysColor (OS.COLOR_GRADIENTINACTIVECAPTION);
            if (pixel is 0) pixel = OS.GetSysColor (OS.COLOR_INACTIVECAPTION);
            break;
        default:
            return super.getSystemColor (id);
    }
    return Color.win32_new (this, pixel);
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
override public Font getSystemFont () {
    checkDevice ();
    if (systemFont !is null) return systemFont;
    HFONT hFont;
    static if (!OS.IsWinCE) {
        NONCLIENTMETRICS info;
        info.cbSize = NONCLIENTMETRICS.sizeof;
        if (OS.SystemParametersInfo (OS.SPI_GETNONCLIENTMETRICS, 0, &info, 0)) {
            LOGFONT logFont = info.lfMessageFont;
            hFont = OS.CreateFontIndirect (&logFont);
            lfSystemFont = hFont !is null ? &logFont : null;
        }
    }
    if (hFont is null) hFont = OS.GetStockObject (OS.DEFAULT_GUI_FONT);
    if (hFont is null) hFont = OS.GetStockObject (OS.SYSTEM_FONT);
    return systemFont = Font.win32_new (this, hFont);
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
        case SWT.ICON_ERROR: {
            if (errorImage !is null) return errorImage;
            auto hIcon = OS.LoadImage (null, cast(wchar*)OS.OIC_HAND, OS.IMAGE_ICON, 0, 0, OS.LR_SHARED);
            return errorImage = Image.win32_new (this, SWT.ICON, hIcon);
        }
        case SWT.ICON_WORKING:
        case SWT.ICON_INFORMATION: {
            if (infoImage !is null) return infoImage;
            auto hIcon = OS.LoadImage (null, cast(wchar*)OS.OIC_INFORMATION, OS.IMAGE_ICON, 0, 0, OS.LR_SHARED);
            return infoImage = Image.win32_new (this, SWT.ICON, hIcon);
        }
        case SWT.ICON_QUESTION: {
            if (questionImage !is null) return questionImage;
            auto hIcon = OS.LoadImage (null, cast(wchar*)OS.OIC_QUES, OS.IMAGE_ICON, 0, 0, OS.LR_SHARED);
            return questionImage = Image.win32_new (this, SWT.ICON, hIcon);
        }
        case SWT.ICON_WARNING: {
            if (warningIcon !is null) return warningIcon;
            auto hIcon = OS.LoadImage (null, cast(wchar*)OS.OIC_BANG, OS.IMAGE_ICON, 0, 0, OS.LR_SHARED);
            return warningIcon = Image.win32_new (this, SWT.ICON, hIcon);
        }
        default:
    }
    return null;
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
    static if (!OS.IsWinCE) tray = new Tray (this, SWT.NONE);
    return tray;
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

HTHEME hButtonTheme () {
    if (hButtonTheme_ !is null) return hButtonTheme_;
    return hButtonTheme_ = OS.OpenThemeData (hwndMessage, BUTTON.ptr);
}

HTHEME hEditTheme () {
    if (hEditTheme_ !is null) return hEditTheme_;
    return hEditTheme_ = OS.OpenThemeData (hwndMessage, EDIT.ptr);
}

HTHEME hExplorerBarTheme () {
    if (hExplorerBarTheme_ !is null) return hExplorerBarTheme_;
    return hExplorerBarTheme_ = OS.OpenThemeData (hwndMessage, EXPLORERBAR.ptr);
}

HTHEME hScrollBarTheme () {
    if (hScrollBarTheme_ !is null) return hScrollBarTheme_;
    return hScrollBarTheme_ = OS.OpenThemeData (hwndMessage, SCROLLBAR.ptr);
}

HTHEME hTabTheme () {
    if (hTabTheme_ !is null) return hTabTheme_;
    return hTabTheme_ = OS.OpenThemeData (hwndMessage, TAB.ptr);
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
override public HDC internal_new_GC (GCData data) {
    if (isDisposed()) SWT.error(SWT.ERROR_DEVICE_DISPOSED);
    auto hDC = OS.GetDC (null);
    if (hDC is null) SWT.error (SWT.ERROR_NO_HANDLES);
    if (data !is null) {
        int mask = SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT;
        if ((data.style & mask) !is 0) {
            data.layout = (data.style & SWT.RIGHT_TO_LEFT) !is 0 ? OS.LAYOUT_RTL : 0;
        } else {
            data.style |= SWT.LEFT_TO_RIGHT;
        }
        data.device = this;
        data.font = getSystemFont ();
    }
    return hDC;
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
override protected void init_ () {
    super.init_ ();

    /* Create the callbacks */
    //windowCallback = new Callback (this, "windowProc", 4); //$NON-NLS-1$
    //windowProc_ = windowCallback.getAddress ();
    //if (windowProc_ is 0) error (SWT.ERROR_NO_MORE_CALLBACKS);

    /* Remember the current thread id */
    threadId = OS.GetCurrentThreadId ();

    /* Use the character encoding for the default locale */
    windowClass_ = StrToTCHARs ( 0, WindowName ~ String_valueOf(WindowClassCount), true );
    windowShadowClass = StrToTCHARs ( 0, WindowShadowName ~ String_valueOf(WindowClassCount), true );
    WindowClassCount++;

    /* Register the SWT window class */
    auto hHeap = OS.GetProcessHeap ();
    auto hInstance = OS.GetModuleHandle (null);
    WNDCLASS lpWndClass;
    lpWndClass.hInstance = hInstance;
    lpWndClass.lpfnWndProc = &windowProcFunc;
    lpWndClass.style = OS.CS_BYTEALIGNWINDOW | OS.CS_DBLCLKS;
    lpWndClass.hCursor = OS.LoadCursor (null, cast(wchar*)OS.IDC_ARROW);


    //DWT_TODO: Check if this can be disabled for SWT
    /+
    /*
    * Set the default icon for the window class to IDI_APPLICATION.
    * This is not necessary for native Windows applications but
    * versions of Java starting at JDK 1.6 set the icon in the
    * executable instead of leaving the default.
    */
    if (!OS.IsWinCE && Library.JAVA_VERSION >= Library.JAVA_VERSION (1, 6, 0)) {
        TCHAR[] lpszFile = NewTCHARs (0, OS.MAX_PATH);
        while (OS.GetModuleFileName (0, lpszFile.ptr, lpszFile.length) is lpszFile.length) {
            lpszFile = NewTCHARs (0, lpszFile.length + OS.MAX_PATH);
        }
        if (OS.ExtractIconEx (lpszFile.ptr, -1, null, null, 1) !is 0) {
            String fileName = TCHARzToStr( lpszFile.ptr );
            if (fileName.endsWith ("java.exe") || fileName.endsWith ("javaw.exe")) { //$NON-NLS-1$ //$NON-NLS-2$
                lpWndClass.hIcon = OS.LoadIcon (0, OS.IDI_APPLICATION);
            }
        }
    }
    +/
    auto byteCount = windowClass_.length * TCHAR.sizeof;
    auto buf = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
    lpWndClass.lpszClassName = buf;
    OS.MoveMemory (buf, windowClass_.ptr, byteCount);
    OS.RegisterClass (&lpWndClass);
    OS.HeapFree (hHeap, 0, buf);

    /* Register the SWT drop shadow window class */
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (5, 1)) {
        lpWndClass.style |= OS.CS_DROPSHADOW;
    }
    byteCount = windowShadowClass.length * TCHAR.sizeof;
    buf = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
    lpWndClass.lpszClassName = buf;
    OS.MoveMemory (buf, windowShadowClass.ptr, byteCount);
    OS.RegisterClass (&lpWndClass);
    OS.HeapFree (hHeap, 0, buf);

    /* Create the message only HWND */
    hwndMessage = OS.CreateWindowEx (0,
        windowClass_.ptr,
        null,
        OS.WS_OVERLAPPED,
        0, 0, 0, 0,
        null,
        null,
        hInstance,
        null);
    //messageCallback = new Callback (this, "messageProc", 4); //$NON-NLS-1$
    //messageProc_ = messageCallback.getAddress ();
    //if (messageProc_ is 0) error (SWT.ERROR_NO_MORE_CALLBACKS);
    OS.SetWindowLongPtr (hwndMessage, OS.GWLP_WNDPROC, cast(LONG_PTR) &messageProcFunc);

    /* Create the filter hook */
    static if (!OS.IsWinCE) {
        //msgFilterCallback = new Callback (this, "msgFilterProc", 3); //$NON-NLS-1$
        //msgFilterProc_ = msgFilterCallback.getAddress ();
        //if (msgFilterProc_ is 0) error (SWT.ERROR_NO_MORE_CALLBACKS);
        filterHook = OS.SetWindowsHookEx (OS.WH_MSGFILTER, &msgFilterProcFunc, null, threadId);
    }

    /* Create the idle hook */
    static if (!OS.IsWinCE) {
        //foregroundIdleCallback = new Callback (this, "foregroundIdleProc", 3); //$NON-NLS-1$
        //foregroundIdleProc_ = foregroundIdleCallback.getAddress ();
        //if (foregroundIdleProc_ is 0) error (SWT.ERROR_NO_MORE_CALLBACKS);
        idleHook = OS.SetWindowsHookEx (OS.WH_FOREGROUNDIDLE, &foregroundIdleProcFunc, null, threadId);
    }

    /* Register custom messages message */
    SWT_TASKBARCREATED = OS.RegisterWindowMessage (StrToTCHARz ( "TaskbarCreated" ));
    SWT_RESTORECARET = OS.RegisterWindowMessage (StrToTCHARz ( "SWT_RESTORECARET"));
    DI_GETDRAGIMAGE = OS.RegisterWindowMessage (StrToTCHARz ( "ShellGetDragImage")); //$NON-NLS-1$

    /* Initialize OLE */
    static if (!OS.IsWinCE) OS.OleInitialize (null);

    /* Initialize buffered painting */
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)){
        OS.BufferedPaintInit ();
    }

    /* Initialize the Widget Table */
    indexTable = new ptrdiff_t [GROW_SIZE];
    controlTable = new Control [GROW_SIZE];
    for (auto i=0; i<GROW_SIZE-1; i++) indexTable [i] = i + 1;
    indexTable [GROW_SIZE - 1] = -1;
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
override public void internal_dispose_GC (HDC hDC, GCData data) {
    OS.ReleaseDC (null, hDC);
}

bool isXMouseActive () {
    /*
    * NOTE: X-Mouse is active when bit 1 of the UserPreferencesMask is set.
    */
    bool xMouseActive = false;
    LPCTSTR key = StrToTCHARz( "Control Panel\\Desktop" ); //$NON-NLS-1$
    void* phKey;
    int result = OS.RegOpenKeyEx (cast(void*)OS.HKEY_CURRENT_USER, key, 0, OS.KEY_READ, &phKey);
    if (result is 0) {
        LPCTSTR lpValueName = StrToTCHARz ( "UserPreferencesMask" ); //$NON-NLS-1$
        uint[4] lpcbData;
        uint lpData;
        result = OS.RegQueryValueEx (phKey, lpValueName, null, null, cast(ubyte*)&lpData, lpcbData.ptr);
        if (result is 0) xMouseActive = (lpData & 0x01) !is 0;
        OS.RegCloseKey (phKey);
    }
    return xMouseActive;
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
    if (from is to) return new Point (x, y);
    auto hwndFrom = from !is null ? from.handle : null;
    auto hwndTo = to !is null ? to.handle : null;
    POINT point;
    point.x = x;
    point.y = y;
    OS.MapWindowPoints (hwndFrom, hwndTo, &point, 1);
    return new Point (point.x, point.y);
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
    checkDevice ();
    if (rectangle is null) error (SWT.ERROR_NULL_ARGUMENT);
    return map (from, to, rectangle.x, rectangle.y, rectangle.width, rectangle.height);
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
    checkDevice ();
    if (from !is null && from.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);
    if (to !is null && to.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);
    if (from is to) return new Rectangle (x, y, width, height);
    auto hwndFrom = from !is null ? from.handle : null;
    auto hwndTo = to !is null ? to.handle : null;
    RECT rect;
    rect.left = x;
    rect.top  = y;
    rect.right = x + width;
    rect.bottom = y + height;
    OS.MapWindowPoints (hwndFrom, hwndTo, cast(POINT*)&rect, 2);
    return new Rectangle (rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top);
}

/*
 * Returns a single character, converted from the default
 * multi-byte character set (MBCS) used by the operating
 * system widgets to a wide character set (WCS) used by Java.
 *
 * @param ch the MBCS character
 * @return the WCS character
 */
static wchar mbcsToWcs (int ch) {
    return mbcsToWcs (ch, 0);
}

/*
 * Returns a single character, converted from the specified
 * multi-byte character set (MBCS) used by the operating
 * system widgets to a wide character set (WCS) used by Java.
 *
 * @param ch the MBCS character
 * @param codePage the code page used to convert the character
 * @return the WCS character
 */
static wchar mbcsToWcs (int ch, int codePage) {
    if (OS.IsUnicode) return cast(wchar) ch;
    int key = ch & 0xFFFF;
    if (key <= 0x7F) return cast(wchar) ch;
    CHAR[] buffer;
    if (key <= 0xFF) {
        buffer = new CHAR [1];
        buffer [0] = cast(CHAR) key;
    } else {
        buffer = new CHAR [2];
        buffer [0] = cast(CHAR) ((key >> 8) & 0xFF);
        buffer [1] = cast(CHAR) (key & 0xFF);
    }
    wchar [] unicode = new wchar [1];
    int cp = codePage !is 0 ? codePage : OS.CP_ACP;
    int count = OS.MultiByteToWideChar (cp, OS.MB_PRECOMPOSED, buffer.ptr, cast(int)/*64bit*/buffer.length, unicode.ptr, 1);
    if (count is 0) return 0;
    return unicode [0];
}

private static extern(Windows) .LRESULT messageProcFunc (HWND hwnd, uint msg, WPARAM wParam, LPARAM lParam) {
    Display d = Display.getCurrent();
    return d.messageProc( hwnd, msg, wParam, lParam );
}

.LRESULT messageProc (HWND hwnd, uint msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
        case SWT_RUNASYNC: {
            if (runMessagesInIdle) runAsyncMessages (false);
            break;
        }
        case SWT_KEYMSG: {
            bool consumed = false;
            MSG* keyMsg = cast(MSG*) lParam;
            Control control = findControl (keyMsg.hwnd);
            if (control !is null) {
                /*
                * Feature in Windows.  When the user types an accent key such
                * as ^ in order to get an accented character on a German keyboard,
                * calling TranslateMessage(), ToUnicode() or ToAscii() consumes
                * the key.  This means that a subsequent call to TranslateMessage()
                * will see a regular key rather than the accented key.  The fix
                * is to use MapVirtualKey() and VkKeyScan () to detect an accent
                * and avoid calls to TranslateMessage().
                */
                bool accentKey = false;
                switch (keyMsg.message) {
                    case OS.WM_KEYDOWN:
                    case OS.WM_SYSKEYDOWN: {
                        static if (!OS.IsWinCE) {
                            switch (keyMsg.wParam) {
                                case OS.VK_SHIFT:
                                case OS.VK_MENU:
                                case OS.VK_CONTROL:
                                case OS.VK_CAPITAL:
                                case OS.VK_NUMLOCK:
                                case OS.VK_SCROLL:
                                    break;
                                default: {
                                    /*
                                    * Bug in Windows. The high bit in the result of MapVirtualKey() on
                                    * Windows NT is bit 32 while the high bit on Windows 95 is bit 16.
                                    * They should both be bit 32.  The fix is to test the right bit.
                                    */
                                    int mapKey = OS.MapVirtualKey (cast(int)/*64bit*/keyMsg.wParam, 2);
                                    if (mapKey !is 0) {
                                        accentKey = (mapKey & (OS.IsWinNT ? 0x80000000 : 0x8000)) !is 0;
                                        if (!accentKey) {
                                            for (int i=0; i<ACCENTS.length; i++) {
                                                int value = OS.VkKeyScan (ACCENTS [i]);
                                                if (value !is -1 && (value & 0xFF) is keyMsg.wParam) {
                                                    int state = value >> 8;
                                                    if ((OS.GetKeyState (OS.VK_SHIFT) < 0) is ((state & 0x1) !is 0) &&
                                                        (OS.GetKeyState (OS.VK_CONTROL) < 0) is ((state & 0x2) !is 0) &&
                                                        (OS.GetKeyState (OS.VK_MENU) < 0) is ((state & 0x4) !is 0)) {
                                                            if ((state & 0x7) !is 0) accentKey = true;
                                                            break;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                        break;
                    }
                    default:
                }
                if (!accentKey && !ignoreNextKey) {
                    keyMsg.hwnd = control.handle;
                    int flags = OS.PM_REMOVE | OS.PM_NOYIELD | OS.PM_QS_INPUT | OS.PM_QS_POSTMESSAGE;
                    do {
                        if (!(consumed |= filterMessage (keyMsg))) {
                            OS.TranslateMessage (keyMsg);
                            consumed |= OS.DispatchMessage (keyMsg) is 1;
                        }
                    } while (OS.PeekMessage (keyMsg, keyMsg.hwnd, OS.WM_KEYFIRST, OS.WM_KEYLAST, flags));
                }
                switch (keyMsg.message) {
                    case OS.WM_KEYDOWN:
                    case OS.WM_SYSKEYDOWN: {
                        switch (keyMsg.wParam) {
                            case OS.VK_SHIFT:
                            case OS.VK_MENU:
                            case OS.VK_CONTROL:
                            case OS.VK_CAPITAL:
                            case OS.VK_NUMLOCK:
                            case OS.VK_SCROLL:
                                break;
                            default: {
                                ignoreNextKey = accentKey;
                                break;
                            }
                        }
                        break;
                    }
                    default:
                        break;
                }
            }
            switch (keyMsg.wParam) {
                case OS.VK_SHIFT:
                case OS.VK_MENU:
                case OS.VK_CONTROL:
                case OS.VK_CAPITAL:
                case OS.VK_NUMLOCK:
                case OS.VK_SCROLL:
                    consumed = true;
                    break;
                default:
                    break;
            }
            if (consumed) {
                auto hHeap = OS.GetProcessHeap ();
                OS.HeapFree (hHeap, 0, cast(void*)lParam);
            } else {
                OS.PostMessage (embeddedHwnd, SWT_KEYMSG, wParam, lParam);
            }
            return 0;
        }
        case SWT_TRAYICONMSG: {
            if (tray !is null) {
                TrayItem [] items = tray.items;
                for (int i=0; i<items.length; i++) {
                    TrayItem item = items [i];
                    if (item !is null && item.id is wParam) {
                        return item.messageProc (hwnd, msg, wParam, lParam);
                    }
                }
            }
            return 0;
        }
        case OS.WM_ACTIVATEAPP: {
            /*
            * Feature in Windows.  When multiple shells are
            * disabled and one of the shells has an enabled
            * dialog child and the user selects a disabled
            * shell that does not have the enabled dialog
            * child using the Task bar, Windows brings the
            * disabled shell to the front.  As soon as the
            * user clicks on the disabled shell, the enabled
            * dialog child comes to the front.  This behavior
            * is unspecified and seems strange.  Normally, a
            * disabled shell is frozen on the screen and the
            * user cannot change the z-order by clicking with
            * the mouse.  The fix is to look for WM_ACTIVATEAPP
            * and force the enabled dialog child to the front.
            * This is typically what the user is expecting.
            *
            * NOTE: If the modal shell is disabled for any
            * reason, it should not be brought to the front.
            */
            if (wParam !is 0) {
                if (!isXMouseActive ()) {
                    auto hwndActive = OS.GetActiveWindow ();
                    if (hwndActive !is null && OS.IsWindowEnabled (hwndActive)) break;
                    Shell modal = modalDialog !is null ? modalDialog.parent : getModalShell ();
                    if (modal !is null && !modal.isDisposed ()) {
                        auto hwndModal = modal.handle;
                        if (OS.IsWindowEnabled (hwndModal)) {
                            modal.bringToTop ();
                            if (modal.isDisposed ()) break;
                        }
                        auto hwndPopup = OS.GetLastActivePopup (hwndModal);
                        if (hwndPopup !is null && hwndPopup !is modal.handle) {
                            if (getControl (hwndPopup) is null) {
                                if (OS.IsWindowEnabled (hwndPopup)) {
                                    OS.SetActiveWindow (hwndPopup);
                                }
                            }
                        }
                    }
                }
            }
            break;
        }
        case OS.WM_ENDSESSION: {
            if (wParam !is 0) {
                dispose ();
                /*
                * When the session is ending, no SWT program can continue
                * to run.  In order to avoid running code after the display
                * has been disposed, exit from Java.
                */
                /* This code is intentionally commented */
//              System.exit (0);
            }
            break;
        }
        case OS.WM_QUERYENDSESSION: {
            Event event = new Event ();
            sendEvent (SWT.Close, event);
            if (!event.doit) return 0;
            break;
        }
        case OS.WM_DWMCOLORIZATIONCOLORCHANGED: {
            OS.SetTimer (hwndMessage, SETTINGS_ID, SETTINGS_DELAY, null);
            break;
        }
        case OS.WM_SETTINGCHANGE: {
            if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
                OS.SetTimer (hwndMessage, SETTINGS_ID, SETTINGS_DELAY, null);
                break;
            }
            switch (wParam) {
                case 0:
                case 1:
                case OS.SPI_SETHIGHCONTRAST:
                    OS.SetTimer (hwndMessage, SETTINGS_ID, SETTINGS_DELAY, null);
                    break;
                default:
                    break;
            }
            break;
        }
        case OS.WM_THEMECHANGED: {
            if (OS.COMCTL32_MAJOR >= 6) {
                if (hButtonTheme_ !is null) OS.CloseThemeData (hButtonTheme_);
                if (hEditTheme_ !is null) OS.CloseThemeData (hEditTheme_);
                if (hExplorerBarTheme_ !is null) OS.CloseThemeData (hExplorerBarTheme_);
                if (hScrollBarTheme_ !is null) OS.CloseThemeData (hScrollBarTheme_);
                if (hTabTheme_ !is null) OS.CloseThemeData (hTabTheme_);
                hButtonTheme_ = hEditTheme_ = hExplorerBarTheme_ = hScrollBarTheme_ = hTabTheme_ = null;
            }
            break;
        }
        case OS.WM_TIMER: {
            if (wParam is SETTINGS_ID) {
                OS.KillTimer (hwndMessage, SETTINGS_ID);
                runSettings ();
            } else {
                runTimer (wParam);
            }
            break;
        }
        default: {
            if (msg is SWT_TASKBARCREATED) {
                if (tray !is null) {
                    TrayItem [] items = tray.items;
                    for (int i=0; i<items.length; i++) {
                        TrayItem item = items [i];
                        if (item !is null) item.recreate ();
                    }
                }
            }
        }
    }
    return OS.DefWindowProc (hwnd, msg, wParam, lParam);
}

private static extern(Windows) BOOL monitorEnumFunc (HMONITOR hmonitor, HDC hdc, RECT* lprcMonitor, LPARAM dwData) {
    auto d = cast(Display)cast(void*)dwData;
    return d.monitorEnumProc( hmonitor, hdc, lprcMonitor );
}
int monitorEnumProc (HMONITOR hmonitor, HDC hdc, RECT* lprcMonitor) {
    if (monitorCount >= monitors.length) {
        org.eclipse.swt.widgets.Monitor.Monitor[] newMonitors = new org.eclipse.swt.widgets.Monitor.Monitor [monitors.length + 4];
        System.arraycopy (monitors, 0, newMonitors, 0, monitors.length);
        monitors = newMonitors;
    }
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
    monitors [monitorCount++] = monitor;
    return 1;
}

private static extern(Windows) .LRESULT msgFilterProcFunc (int code, WPARAM wParam, LPARAM lParam) {
    Display pThis = Display.getCurrent();
    return pThis.msgFilterProc( code, wParam, lParam );
}

.LRESULT msgFilterProc (int code, WPARAM wParam, LPARAM lParam) {
    switch (code) {
        case OS.MSGF_COMMCTRL_BEGINDRAG: {
            if (!runDragDrop && !dragCancelled) {
                *hookMsg = *cast(MSG*)lParam;
                if (hookMsg.message is OS.WM_MOUSEMOVE) {
                    dragCancelled = true;
                    OS.SendMessage (hookMsg.hwnd, OS.WM_CANCELMODE, 0, 0);
                }
            }
            break;
        }
        /*
        * Feature in Windows.  For some reason, when the user clicks
        * a table or tree, the Windows hook WH_MSGFILTER is sent when
        * an input event from a dialog box, message box, menu, or scroll
        * bar did not occur, causing async messages to run at the wrong
        * time.  The fix is to check the message filter code.
        */
        case OS.MSGF_DIALOGBOX:
        case OS.MSGF_MAINLOOP:
        case OS.MSGF_MENU:
        case OS.MSGF_MOVE:
        case OS.MSGF_MESSAGEBOX:
        case OS.MSGF_NEXTWINDOW:
        case OS.MSGF_SCROLLBAR:
        case OS.MSGF_SIZE: {
            if (runMessages) {
                *hookMsg = *cast(MSG*)lParam;
                if (hookMsg.message is OS.WM_NULL) {
                    MSG msg;
                    int flags = OS.PM_NOREMOVE | OS.PM_NOYIELD | OS.PM_QS_INPUT | OS.PM_QS_POSTMESSAGE;
                    if (!OS.PeekMessage (&msg, null, 0, 0, flags)) {
                        if (runAsyncMessages (false)) wakeThread ();
                    }
                }
            }
            break;
        }
        default:
    }
    return OS.CallNextHookEx (filterHook, code, wParam, lParam);
}

int numpadKey (int key) {
    switch (key) {
        case OS.VK_NUMPAD0: return '0';
        case OS.VK_NUMPAD1: return '1';
        case OS.VK_NUMPAD2: return '2';
        case OS.VK_NUMPAD3: return '3';
        case OS.VK_NUMPAD4: return '4';
        case OS.VK_NUMPAD5: return '5';
        case OS.VK_NUMPAD6: return '6';
        case OS.VK_NUMPAD7: return '7';
        case OS.VK_NUMPAD8: return '8';
        case OS.VK_NUMPAD9: return '9';
        case OS.VK_MULTIPLY:    return '*';
        case OS.VK_ADD:         return '+';
        case OS.VK_SEPARATOR:   return '\0';
        case OS.VK_SUBTRACT:    return '-';
        case OS.VK_DECIMAL: return '.';
        case OS.VK_DIVIDE:      return '/';
        default:
    }
    return 0;
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
        int type = event.type;
        switch (type){
            case SWT.KeyDown:
            case SWT.KeyUp: {
            KEYBDINPUT inputs;
            inputs.wVk = cast(short) untranslateKey (event.keyCode);
                if (inputs.wVk is 0) {
                    char key = cast(char) event.character;
                    switch (key) {
                        case SWT.BS: inputs.wVk = cast(short) OS.VK_BACK; break;
                        case SWT.CR: inputs.wVk = cast(short) OS.VK_RETURN; break;
                        case SWT.DEL: inputs.wVk = cast(short) OS.VK_DELETE; break;
                        case SWT.ESC: inputs.wVk = cast(short) OS.VK_ESCAPE; break;
                        case SWT.TAB: inputs.wVk = cast(short) OS.VK_TAB; break;
                        /*
                        * Since there is no LF key on the keyboard, do not attempt
                        * to map LF to CR or attempt to post an LF key.
                        */
//                      case SWT.LF: inputs.wVk = cast(short) OS.VK_RETURN; break;
                        case SWT.LF: return false;
                        default: {
                            static if (OS.IsWinCE) {
                                inputs.wVk = cast(int)OS.CharUpper (cast(wchar*) key);
                            } else {
                                inputs.wVk = OS.VkKeyScan (cast(short) wcsToMbcs (key, 0));
                                if (inputs.wVk is -1) return false;
                                inputs.wVk &= 0xFF;
                            }
                        }
                    }
                }
                inputs.dwFlags = type is SWT.KeyUp ? OS.KEYEVENTF_KEYUP : 0;
                auto hHeap = OS.GetProcessHeap ();
                auto pInputs = cast(INPUT*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, INPUT.sizeof);
                pInputs.type = OS.INPUT_KEYBOARD;
                //TODO - DWORD type of INPUT structure aligned to 8 bytes on 64 bit
                pInputs.ki = inputs;
                //OS.MoveMemory (pInputs + 4, inputs, KEYBDINPUT.sizeof);
                bool result = OS.SendInput (1, pInputs, INPUT.sizeof) !is 0;
                OS.HeapFree (hHeap, 0, pInputs);
                return result;
            }
            case SWT.MouseDown:
            case SWT.MouseMove:
            case SWT.MouseUp:
            case SWT.MouseWheel: {
                MOUSEINPUT inputs;
                if (type is SWT.MouseMove){
                    inputs.dwFlags = OS.MOUSEEVENTF_MOVE | OS.MOUSEEVENTF_ABSOLUTE;
                    int x= 0, y = 0, width = 0, height = 0;
                    if (OS.WIN32_VERSION >= OS.VERSION (5, 0)) {
                        inputs.dwFlags |= OS.MOUSEEVENTF_VIRTUALDESK;
                        x = OS.GetSystemMetrics (OS.SM_XVIRTUALSCREEN);
                        y = OS.GetSystemMetrics (OS.SM_YVIRTUALSCREEN);
                        width = OS.GetSystemMetrics (OS.SM_CXVIRTUALSCREEN);
                        height = OS.GetSystemMetrics (OS.SM_CYVIRTUALSCREEN);
                    } else {
                        width = OS.GetSystemMetrics (OS.SM_CXSCREEN);
                        height = OS.GetSystemMetrics (OS.SM_CYSCREEN);
                    }
                    inputs.dx = ((event.x - x) * 65535 + width - 2) / (width - 1);
                    inputs.dy = ((event.y - y) * 65535 + height - 2) / (height - 1);
                } else {
                    if (type is SWT.MouseWheel) {
                        if (OS.WIN32_VERSION < OS.VERSION (5, 0)) return false;
                        inputs.dwFlags = OS.MOUSEEVENTF_WHEEL;
                        switch (event.detail) {
                            case SWT.SCROLL_PAGE:
                                inputs.mouseData = event.count * OS.WHEEL_DELTA;
                                break;
                            case SWT.SCROLL_LINE:
                                int value;
                                OS.SystemParametersInfo (OS.SPI_GETWHEELSCROLLLINES, 0, &value, 0);
                                inputs.mouseData = event.count * OS.WHEEL_DELTA / value;
                                break;
                            default: return false;
                        }
                    } else {
                        switch (event.button) {
                            case 1: inputs.dwFlags = type is SWT.MouseDown ? OS.MOUSEEVENTF_LEFTDOWN : OS.MOUSEEVENTF_LEFTUP; break;
                            case 2: inputs.dwFlags = type is SWT.MouseDown ? OS.MOUSEEVENTF_MIDDLEDOWN : OS.MOUSEEVENTF_MIDDLEUP; break;
                            case 3: inputs.dwFlags = type is SWT.MouseDown ? OS.MOUSEEVENTF_RIGHTDOWN : OS.MOUSEEVENTF_RIGHTUP; break;
                            case 4: {
                                if (OS.WIN32_VERSION < OS.VERSION (5, 0)) return false;
                                inputs.dwFlags = type is SWT.MouseDown ? OS.MOUSEEVENTF_XDOWN : OS.MOUSEEVENTF_XUP;
                                inputs.mouseData = OS.XBUTTON1;
                                break;
                            }
                            case 5: {
                                if (OS.WIN32_VERSION < OS.VERSION (5, 0)) return false;
                                inputs.dwFlags = type is SWT.MouseDown ? OS.MOUSEEVENTF_XDOWN : OS.MOUSEEVENTF_XUP;
                                inputs.mouseData = OS.XBUTTON2;
                                break;
                            }
                            default: return false;
                        }
                    }
                }
                auto hHeap = OS.GetProcessHeap ();
                auto pInputs = cast(INPUT*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, INPUT.sizeof);
                pInputs.type = OS.INPUT_MOUSE;
                //TODO - DWORD type of INPUT structure aligned to 8 bytes on 64 bit
                pInputs.mi = inputs;
                bool result = OS.SendInput (1, pInputs, INPUT.sizeof) !is 0;
                OS.HeapFree (hHeap, 0, pInputs);
                return result;
            }
        default:
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
    int index = 0;
    int length_ = cast(int)/*64bit*/eventQueue.length;
    while (index < length_) {
        if (eventQueue [index] is null) break;
        index++;
    }
    if (index is length_) {
        Event [] newQueue = new Event [length_ + 4];
        System.arraycopy (eventQueue, 0, newQueue, 0, length_);
        eventQueue = newQueue;
    }
    eventQueue [index] = event;
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
    lpStartupInfo = null;
    drawMenuBars ();
    runPopups ();
    if (OS.PeekMessage (msg, null, 0, 0, OS.PM_REMOVE)) {
        if (!filterMessage (msg)) {
            OS.TranslateMessage (msg);
            OS.DispatchMessage (msg);
        }
        runDeferredEvents ();
        return true;
    }
    return runMessages && runAsyncMessages (false);
}

static void register (Display display) {
    static_this();
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
override protected void release () {
    sendEvent (SWT.Dispose, new Event ());
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) {
        Shell shell = shells [i];
        if (!shell.isDisposed ()) shell.dispose ();
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
    if (embeddedHwnd !is null) {
        OS.PostMessage (embeddedHwnd, SWT_DESTROY, 0, 0);
    }

    /* Release XP Themes */
    if (OS.COMCTL32_MAJOR >= 6) {
        if (hButtonTheme_ !is null) OS.CloseThemeData (hButtonTheme_);
        if (hEditTheme_ !is null) OS.CloseThemeData (hEditTheme_);
        if (hExplorerBarTheme_ !is null) OS.CloseThemeData (hExplorerBarTheme_);
        if (hScrollBarTheme_ !is null) OS.CloseThemeData (hScrollBarTheme_);
        if (hTabTheme_ !is null) OS.CloseThemeData (hTabTheme_);
        hButtonTheme_ = hEditTheme_ = hExplorerBarTheme_ = hScrollBarTheme_ = hTabTheme_ = null;
    }

    /* Unhook the message hook */
    static if (!OS.IsWinCE) {
        if (msgHook !is null) OS.UnhookWindowsHookEx (msgHook);
        msgHook = null;
    }

    /* Unhook the filter hook */
    static if (!OS.IsWinCE) {
        if (filterHook !is null) OS.UnhookWindowsHookEx (filterHook);
        filterHook = null;
        //msgFilterCallback.dispose ();
        //msgFilterCallback = null;
        //msgFilterProc_ = 0;
    }

    /* Unhook the idle hook */
    static if (!OS.IsWinCE) {
        if (idleHook !is null) OS.UnhookWindowsHookEx (idleHook);
        idleHook = null;
        //foregroundIdleCallback.dispose ();
        //foregroundIdleCallback = null;
        //foregroundIdleProc_ = 0;
    }

    /* Destroy the message only HWND */
    if (hwndMessage !is null) OS.DestroyWindow (hwndMessage);
    hwndMessage = null;
    //messageCallback.dispose ();
    //messageCallback = null;
    //messageProc_ = 0;

    /* Unregister the SWT window class */
    auto hHeap = OS.GetProcessHeap ();
    auto hInstance = OS.GetModuleHandle (null);
    OS.UnregisterClass (windowClass_.ptr, hInstance);

    /* Unregister the SWT drop shadow window class */
    OS.UnregisterClass (windowShadowClass.ptr, hInstance);
    windowClass_ = windowShadowClass = null;
    //windowCallback.dispose ();
    //windowCallback = null;
    //windowProc_ = 0;

    /* Release the System fonts */
    if (systemFont !is null) systemFont.dispose ();
    systemFont = null;
    lfSystemFont = null;

    /* Release the System Images */
    if (errorImage !is null) errorImage.dispose ();
    if (infoImage !is null) infoImage.dispose ();
    if (questionImage !is null) questionImage.dispose ();
    if (warningIcon !is null) warningIcon.dispose ();
    errorImage = infoImage = questionImage = warningIcon = null;

    /* Release Sort Indicators */
    if (upArrow !is null) upArrow.dispose ();
    if (downArrow !is null) downArrow.dispose ();
    upArrow = downArrow = null;

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

    /* Release Custom Colors for ChooseColor */
    if (lpCustColors !is null) OS.HeapFree (hHeap, 0, lpCustColors);
    lpCustColors = null;

    /* Uninitialize OLE */
    static if (!OS.IsWinCE) OS.OleUninitialize ();

    /* Uninitialize buffered painting */
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
        OS.BufferedPaintUnInit ();
    }

    /* Release references */
    thread = null;
    msg = null;
    hookMsg = null;
    //keyboard = null;
    modalDialog = null;
    modalShells = null;
    data = null;
    keys = null;
    values = null;
    bars = popups = null;
    indexTable = null;
    timerIds = null;
    controlTable = null;
    lastControl = lastGetControl = lastHittestControl = null;
    imageList = toolImageList = toolHotImageList = toolDisabledImageList = null;
    timerList = null;
    tableBuffer = null;
    columnVisible = null;
    eventTable = filterTable = null;
    items = null;
    clickRect = null;
    hdr = null;
    plvfi = null;

    /* Release handles */
    threadId = 0;
}

void releaseImageList (ImageList list) {
    int i = 0;
    int length_ = cast(int)/*64bit*/imageList.length;
    while (i < length_) {
        if (imageList [i] is list) {
            if (list.removeRef () > 0) return;
            list.dispose ();
            System.arraycopy (imageList, i + 1, imageList, i, --length_ - i);
            imageList [length_] = null;
            for (int j=0; j<length_; j++) {
                if (imageList [j] !is null) return;
            }
            imageList = null;
            return;
        }
        i++;
    }
}

void releaseToolImageList (ImageList list) {
    int i = 0;
    int length_ = cast(int)/*64bit*/toolImageList.length;
    while (i < length_) {
        if (toolImageList [i] is list) {
            if (list.removeRef () > 0) return;
            list.dispose ();
            System.arraycopy (toolImageList, i + 1, toolImageList, i, --length_ - i);
            toolImageList [length_] = null;
            for (int j=0; j<length_; j++) {
                if (toolImageList [j] !is null) return;
            }
            toolImageList = null;
            return;
        }
        i++;
    }
}

void releaseToolHotImageList (ImageList list) {
    int i = 0;
    int length_ = cast(int)/*64bit*/toolHotImageList.length;
    while (i < length_) {
        if (toolHotImageList [i] is list) {
            if (list.removeRef () > 0) return;
            list.dispose ();
            System.arraycopy (toolHotImageList, i + 1, toolHotImageList, i, --length_ - i);
            toolHotImageList [length_] = null;
            for (int j=0; j<length_; j++) {
                if (toolHotImageList [j] !is null) return;
            }
            toolHotImageList = null;
            return;
        }
        i++;
    }
}

void releaseToolDisabledImageList (ImageList list) {
    int i = 0;
    int length_ = cast(int)/*64bit*/toolDisabledImageList.length;
    while (i < length_) {
        if (toolDisabledImageList [i] is list) {
            if (list.removeRef () > 0) return;
            list.dispose ();
            System.arraycopy (toolDisabledImageList, i + 1, toolDisabledImageList, i, --length_ - i);
            toolDisabledImageList [length_] = null;
            for (int j=0; j<length_; j++) {
                if (toolDisabledImageList [j] !is null) return;
            }
            toolDisabledImageList = null;
            return;
        }
        i++;
    }
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

void removeBar (Menu menu) {
    if (bars is null) return;
    for (int i=0; i<bars.length; i++) {
        if (bars [i] is menu) {
            bars [i] = null;
            return;
        }
    }
}

Control removeControl (HANDLE handle) {
    if (handle is null) return null;
    lastControl = lastGetControl = null;
    Control control = null;
    ptrdiff_t index;
    static if (USE_PROPERTY) {
        index = cast(ptrdiff_t)OS.RemoveProp (handle, cast(wchar*)SWT_OBJECT_INDEX) - 1;
    } else {
        index = OS.GetWindowLongPtr (handle, OS.GWLP_USERDATA) - 1;
        OS.SetWindowLongPtr (handle, OS.GWLP_USERDATA, 0);
    }
    if (0 <= index && index < controlTable.length) {
        control = controlTable [index];
        controlTable [index] = null;
        indexTable [index] = freeSlot;
        freeSlot = index;
    }
    return control;
}

void removeMenuItem (MenuItem item) {
    if (items is null) return;
    items [item.id - ID_START] = null;
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
        int length_ = cast(int)/*64bit*/eventQueue.length;
        System.arraycopy (eventQueue, 1, eventQueue, 0, --length_);
        eventQueue [length_] = null;

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
        * be null due to a recursive invocation
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
        int length_ = cast(int)/*64bit*/popups.length;
        System.arraycopy (popups, 1, popups, 0, --length_);
        popups [length_] = null;
        runDeferredEvents ();
        if (!menu.isDisposed ()) menu._setVisible (true);
        result = true;
    }
    popups = null;
    return result;
}

void runSettings () {
    Font oldFont = getSystemFont ();
    saveResources ();
    updateImages ();
    sendEvent (SWT.Settings, null);
    Font newFont = getSystemFont ();
    bool sameFont = cast(bool)( oldFont ==/*eq*/ newFont );
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) {
        Shell shell = shells [i];
        if (!shell.isDisposed ()) {
            if (!sameFont) {
                shell.updateFont (oldFont, newFont);
            }
            /* This code is intentionally commented */
            //shell.redraw (true);
            shell.layout (true, true);
        }
    }
}

bool runTimer (WPARAM id) {
    if (timerList !is null && timerIds !is null) {
        int index = 0;
        while (index <timerIds.length) {
            if (timerIds [index] is id) {
                OS.KillTimer (hwndMessage, timerIds [index]);
                timerIds [index] = 0;
                Runnable runnable = timerList [index];
                timerList [index] = null;
                if (runnable !is null) runnable.run ();
                return true;
            }
            index++;
        }
    }
    return false;
}

void saveResources () {
    int resourceCount = 0;
    if (resources is null) {
        resources = new Resource [RESOURCE_SIZE];
    } else {
        resourceCount = cast(int)/*64bit*/resources.length;
        Resource [] newResources = new Resource [resourceCount + RESOURCE_SIZE];
        System.arraycopy (resources, 0, newResources, 0, resourceCount);
        resources = newResources;
    }
    if (systemFont !is null) {
        static if (!OS.IsWinCE) {
            NONCLIENTMETRICS info;
            info.cbSize = NONCLIENTMETRICS.sizeof;
            if (OS.SystemParametersInfo (OS.SPI_GETNONCLIENTMETRICS, 0, &info, 0)) {
                LOGFONT* logFont = &info.lfMessageFont;
                if (lfSystemFont is null ||
                    logFont.lfCharSet !is lfSystemFont.lfCharSet ||
                    logFont.lfHeight !is lfSystemFont.lfHeight ||
                    logFont.lfWidth !is lfSystemFont.lfWidth ||
                    logFont.lfEscapement !is lfSystemFont.lfEscapement ||
                    logFont.lfOrientation !is lfSystemFont.lfOrientation ||
                    logFont.lfWeight !is lfSystemFont.lfWeight ||
                    logFont.lfItalic !is lfSystemFont.lfItalic ||
                    logFont.lfUnderline !is lfSystemFont.lfUnderline ||
                    logFont.lfStrikeOut !is lfSystemFont.lfStrikeOut ||
                    logFont.lfCharSet !is lfSystemFont.lfCharSet ||
                    logFont.lfOutPrecision !is lfSystemFont.lfOutPrecision ||
                    logFont.lfClipPrecision !is lfSystemFont.lfClipPrecision ||
                    logFont.lfQuality !is lfSystemFont.lfQuality ||
                    logFont.lfPitchAndFamily !is lfSystemFont.lfPitchAndFamily ||
                    getFontName (logFont) !=/*eq*/ getFontName (lfSystemFont)) {
                        resources [resourceCount++] = systemFont;
                        lfSystemFont = logFont;
                        systemFont = null;
                }
            }
        }
    }
    if (errorImage !is null) resources [resourceCount++] = errorImage;
    if (infoImage !is null) resources [resourceCount++] = infoImage;
    if (questionImage !is null) resources [resourceCount++] = questionImage;
    if (warningIcon !is null) resources [resourceCount++] = warningIcon;
    errorImage = infoImage = questionImage = warningIcon = null;
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
    OS.SetCursorPos (x, y);
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
    // SWT extension: allow null string
    //if (key is null) error (SWT.ERROR_NULL_ARGUMENT);

    if (key ==/*eq*/RUN_MESSAGES_IN_IDLE_KEY) {
        auto data = cast(Boolean) value;
        runMessagesInIdle = data !is null && data.value;
        return;
    }
    if (key.equals (RUN_MESSAGES_IN_MESSAGE_PROC_KEY)) {
        Boolean data = cast(Boolean) value;
        runMessagesInMessageProc = data !is null && data.booleanValue ();
        return;
    }

    /* Remove the key/value pair */
    if (value is null) {
        if (keys is null) return;
        int index = 0;
        while (index < keys.length && keys [index]!=/*eq*/key) index++;
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
        keys.length = 1;
        values.length = 1;
        keys[0] = key;
        values[0] = value;
        return;
    }
    for (int i=0; i<keys.length; i++) {
        if (keys [i] ==/*eq*/key ) {
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

/**
 * On platforms which support it, sets the application name
 * to be the argument. On Motif, for example, this can be used
 * to set the name used for resource lookup.  Specifying
 * <code>null</code> for the name clears it.
 *
 * @param name the new app name or <code>null</code>
 */
public static void setAppName (String name) {
    /* Do nothing */
}

void setModalDialog (Dialog modalDailog) {
    this.modalDialog = modalDailog;
    Shell [] shells = getShells ();
    for (int i=0; i<shells.length; i++) shells [i].updateModal ();
}

void setModalShell (Shell shell) {
    if (modalShells is null) modalShells = new Shell [4];
    int index = 0, length_ = cast(int)/*64bit*/modalShells.length;
    while (index < length_) {
        if (modalShells [index] is shell) return;
        if (modalShells [index] is null) break;
        index++;
    }
    if (index is length_) {
        Shell [] newModalShells = new Shell [length_ + 4];
        System.arraycopy (modalShells, 0, newModalShells, 0, length_);
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

int shiftedKey (int key) {
    static if (OS.IsWinCE) return 0;

    /* Clear the virtual keyboard and press the shift key */
    for (int i=0; i<keyboard.length; i++) keyboard [i] = 0;
    keyboard [OS.VK_SHIFT] |= 0x80;

    /* Translate the key to ASCII or UNICODE using the virtual keyboard */
    static if (OS.IsUnicode) {
        wchar result;
        if (OS.ToUnicode (key, key, keyboard.ptr, &result, 1, 0) is 1) return result;
    } else {
        wchar result;
        if (OS.ToAscii (key, key, keyboard.ptr, &result, 0) is 1) return result;
    }
    return 0;
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
    if (runMessages && getMessageCount () !is 0) return true;
    static if (OS.IsWinCE) {
        OS.MsgWaitForMultipleObjectsEx (0, null, OS.INFINITE, OS.QS_ALLINPUT, OS.MWMO_INPUTAVAILABLE);
        return true;
    }
    return cast(bool) OS.WaitMessage ();
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
    }
    synchronizer.syncExec (runnable);
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
    assert( runnable );
    if (timerList is null) timerList = new Runnable [4];
    if (timerIds is null) timerIds = new UINT_PTR [4];
    int index = 0;
    while (index < timerList.length) {
        if (timerList [index] is runnable) break;
        index++;
    }
    UINT_PTR timerId = 0;
    if (index !is timerList.length) {
        timerId = timerIds [index];
        if (milliseconds < 0) {
            OS.KillTimer (hwndMessage, timerId);
            timerList [index] = null;
            timerIds [index] = 0;
            return;
        }
    } else {
        if (milliseconds < 0) return;
        index = 0;
        while (index < timerList.length) {
            if (timerList [index] is null) break;
            index++;
        }
        timerId = nextTimerId++;
        if (index is timerList.length) {
            Runnable [] newTimerList = new Runnable [timerList.length + 4];
            SimpleType!(Runnable).arraycopy (timerList, 0, newTimerList, 0, timerList.length);
            timerList = newTimerList;
            UINT_PTR [] newTimerIds = new UINT_PTR [timerIds.length + 4];
            System.arraycopy (timerIds, 0, newTimerIds, 0, timerIds.length);
            timerIds = newTimerIds;
        }
    }
    auto newTimerID = OS.SetTimer (hwndMessage, timerId, milliseconds, null);
    if (newTimerID !is 0) {
        timerList [index] = runnable;
        timerIds [index] = newTimerID;
    }
}

bool translateAccelerator (MSG* msg, Control control) {
    accelKeyHit = true;
    bool result = control.translateAccelerator (msg);
    accelKeyHit = false;
    return result;
}

static int translateKey (int key) {
    for (int i=0; i<KeyTable.length; i++) {
        if (KeyTable [i] [0] is key) return KeyTable [i] [1];
    }
    return 0;
}

bool translateMnemonic (MSG* msg, Control control) {
    switch (msg.message) {
        case OS.WM_CHAR:
        case OS.WM_SYSCHAR:
            return control.translateMnemonic (msg);
        default:
    }
    return false;
}

bool translateTraversal (MSG* msg, Control control) {
    switch (msg.message) {
        case OS.WM_KEYDOWN:
            switch (msg.wParam) {
                case OS.VK_RETURN:
                case OS.VK_ESCAPE:
                case OS.VK_TAB:
                case OS.VK_UP:
                case OS.VK_DOWN:
                case OS.VK_LEFT:
                case OS.VK_RIGHT:
                case OS.VK_PRIOR:
                case OS.VK_NEXT:
                    return control.translateTraversal (msg);
                default:
            }
            break;
        case OS.WM_SYSKEYDOWN:
            switch (msg.wParam) {
                case OS.VK_MENU:
                    return control.translateTraversal (msg);
                default:
            }
            break;
        default:
    }
    return false;
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
public void update() {
    checkDevice ();
    /*
    * Feature in Windows.  When an application does not remove
    * events from the event queue for some time, Windows assumes
    * the application is not responding and no longer sends paint
    * events to the application.  The fix is to detect that the
    * application is not responding and call PeekMessage() with
    * PM_REMOVE to tell Windows that the application is ready
    * to dispatch events.  Note that the message does not have
    * to be found or dispatched in order to wake Windows up.
    *
    * NOTE: This allows other cross thread messages to be delivered,
    * most notably WM_ACTIVATE.
    */
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (4, 10)) {
        if (OS.IsHungAppWindow (hwndMessage)) {
            MSG msg;
            int flags = OS.PM_REMOVE | OS.PM_NOYIELD;
            OS.PeekMessage (&msg, hwndMessage, SWT_NULL, SWT_NULL, flags);
        }
    }
    Shell[] shells = getShells ();
    for (int i=0; i<shells.length; i++) {
        Shell shell = shells [i];
        if (!shell.isDisposed ()) shell.update (true);
    }
}

void updateImages () {
    if (upArrow !is null) upArrow.dispose ();
    if (downArrow !is null) downArrow.dispose ();
    upArrow = downArrow = null;
    for (int i=0; i<controlTable.length; i++) {
        Control control = controlTable [i];
        if (control !is null) control.updateImages ();
    }
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
    static if (OS.IsWinCE) {
        OS.PostMessage (hwndMessage, OS.WM_NULL, 0, 0);
    } else {
        OS.PostThreadMessage (threadId, OS.WM_NULL, 0, 0);
    }
}

/*
 * Returns a single character, converted from the wide
 * character set (WCS) used by Java to the specified
 * multi-byte character set used by the operating system
 * widgets.
 *
 * @param ch the WCS character
 * @param codePage the code page used to convert the character
 * @return the MBCS character
 */
static int wcsToMbcs (wchar ch, int codePage) {
    if (OS.IsUnicode) return ch;
    if (ch <= 0x7F) return ch;
    wchar[1] wc;
    wc[0] = ch;
    auto r = StrToMBCSs( String_valueOf(wc), codePage );
    return r[0];
}

/*
 * Returns a single character, converted from the wide
 * character set (WCS) used by Java to the default
 * multi-byte character set used by the operating system
 * widgets.
 *
 * @param ch the WCS character
 * @return the MBCS character
 */
static int wcsToMbcs (char ch) {
    return wcsToMbcs (ch, 0);
}

private static extern(Windows) .LRESULT windowProcFunc (HWND hwnd, uint msg, WPARAM wParam, LPARAM lParam) {
    auto d = Display.getCurrent();
    return d.windowProc( hwnd, msg, wParam, lParam );
}

ptrdiff_t windowProc(){
    return cast(ptrdiff_t)&windowProcFunc;
}

.LRESULT windowProc (HWND hwnd, uint msg, WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  On Vista only, it is faster to
    * compute and answer the data for the visible columns
    * of a table when scrolling, rather than just return
    * the data for each column when asked.
    */
    if (columnVisible !is null) {
        if (msg is OS.WM_NOTIFY && hwndParent is hwnd) {
            OS.MoveMemory (hdr, lParam, NMHDR.sizeof);
            switch (hdr.code) {
                case OS.LVN_GETDISPINFOA:
                case OS.LVN_GETDISPINFOW: {
                    OS.MoveMemory (plvfi, lParam, OS.NMLVDISPINFO_sizeof);
                    if (0 <= plvfi.item.iSubItem && plvfi.item.iSubItem < columnCount) {
                        if (!columnVisible [plvfi.item.iSubItem]) return 0;
                    }
                    break;
                }
                default:
            }
        }
    }
    /*
    * Bug in Adobe Reader 7.0.  For some reason, when Adobe
    * Reader 7.0 is deactivated from within Internet Explorer,
    * it sends thousands of consecutive WM_NCHITTEST messages
    * to the control that is under the cursor.  It seems that
    * if the control takes some time to respond to the message,
    * Adobe stops sending them.  The fix is to detect this case
    * and sleep.
    *
    * NOTE: Under normal circumstances, Windows will never send
    * consecutive WM_NCHITTEST messages to the same control without
    * another message (normally WM_SETCURSOR) in between.
    */
    if (msg is OS.WM_NCHITTEST) {
        if (hitCount++ >= 1024) {
            try {Thread.sleep (1);} catch (Exception t) {}
        }
    } else {
        hitCount = 0;
    }
    if (lastControl !is null && lastHwnd is hwnd) {
        return lastControl.windowProc (hwnd, msg, wParam, lParam);
    }
    ptrdiff_t index;
    static if (USE_PROPERTY) {
        index = cast(ptrdiff_t)OS.GetProp (hwnd, cast(wchar*)SWT_OBJECT_INDEX) - 1;
    } else {
        index = OS.GetWindowLongPtr (hwnd, OS.GWLP_USERDATA) - 1;
    }
    if (0 <= index && index < controlTable.length) {
        Control control = controlTable [index];
        if (control !is null) {
            lastHwnd = hwnd;
            lastControl = control;
            return control.windowProc (hwnd, msg, wParam, lParam);
        }
    }
    return OS.DefWindowProc (hwnd, msg, wParam, lParam);
}

static String withCrLf (String string) {

    /* If the string is empty, return the string. */
    int length_ = cast(int)/*64bit*/string.length;
    if (length_ is 0) return string;

    /*
    * Check for an LF or CR/LF and assume the rest of
    * the string is formated that way.  This will not
    * work if the string contains mixed delimiters.
    */
    int i = string.indexOf ('\n', 0);
    if (i is -1) return string;
    if (i > 0 && string.charAt (i - 1) is '\r') {
        return string;
    }

    /*
    * The string is formatted with LF.  Compute the
    * number of lines and the size of the buffer
    * needed to hold the result
    */
    i++;
    int count = 1;
    while (i < length_) {
        if ((i = string.indexOf ('\n', i)) is -1) break;
        count++; i++;
    }
    count += length_;

    /* Create a new string with the CR/LF line terminator. */
    i = 0;
    StringBuffer result = new StringBuffer (count);
    while (i < length_) {
        int j = string.indexOf ('\n', i);
        if (j is -1) j = length_;
        result.append (string.substring (i, j));
        if ((i = j) < length_) {
            result.append ("\r\n"); //$NON-NLS-1$
            i++;
        }
    }
    return result.toString ();
}

String windowClass(){
    return TCHARsToStr( windowClass_ );
}

}
