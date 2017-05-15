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
module org.eclipse.swt.ole.win32.OleFrame;

import java.util.Vector;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.OLEIDL;
import org.eclipse.swt.internal.ole.win32.extras;
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Widget;

import org.eclipse.swt.ole.win32.OleClientSite;
import org.eclipse.swt.ole.win32.OLE;

import org.eclipse.swt.internal.LONG;

import java.lang.all;
import java.lang.Runnable;

/**
 *
 * OleFrame is an OLE Container's top level frame.
 *
 * <p>This object implements the OLE Interfaces IUnknown and IOleInPlaceFrame
 *
 * <p>OleFrame allows the container to do the following: <ul>
 *  <li>position and size the ActiveX Control or OLE Document within the application
 *  <li>insert menu items from the application into the OLE Document's menu
 *  <li>activate and deactivate the OLE Document's menus
 *  <li>position the OLE Document's menu in the application
 *  <li>translate accelerator keystrokes intended for the container's frame</ul>
 *
 * <dl>
 *  <dt><b>Styles</b> <dd>BORDER
 *  <dt><b>Events</b> <dd>Dispose, Move, Resize
 * </dl>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#ole">OLE and ActiveX snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Examples: OLEExample, OleWebBrowser</a>
 */
final public class OleFrame : Composite
{
    // Interfaces for this Ole Client Container
    //private COMObject iUnknown;
    private _IOleInPlaceFrameImpl iOleInPlaceFrame;

    // Access to the embedded/linked Ole Object
    private IOleInPlaceActiveObject objIOleInPlaceActiveObject;

    private OleClientSite currentdoc;

    private int refCount = 0;

    private MenuItem[] fileMenuItems;
    private MenuItem[] containerMenuItems;
    private MenuItem[] windowMenuItems;

    private Listener listener;

    private static String CHECK_FOCUS = "OLE_CHECK_FOCUS"; //$NON-NLS-1$
    private static String HHOOK = "OLE_HHOOK"; //$NON-NLS-1$
    private static String HHOOKMSG = "OLE_HHOOK_MSG"; //$NON-NLS-1$

    private static bool ignoreNextKey;
    private static const short [] ACCENTS = [ cast(short)'~', '`', '\'', '^', '"'];

    private static const String CONSUME_KEY = "org.eclipse.swt.OleFrame.ConsumeKey"; //$NON-NLS-1$

/**
 * Create an OleFrame child widget using style bits
 * to select a particular look or set of properties.
 *
 * @param parent a composite widget (cannot be null)
 * @param style the bitwise OR'ing of widget styles
 *
 * @exception IllegalArgumentException <ul>
 *     <li>ERROR_NULL_ARGUMENT when the parent is null
 * </ul>
 * @exception SWTException <ul>
 *     <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread
 * </ul>
 *
 */
public this(Composite parent, int style) {
    super(parent, style);

    createCOMInterfaces();

    // setup cleanup proc
    listener = new class() Listener  {
        public void handleEvent(Event e) {
            switch (e.type) {
            case SWT.Activate :    onActivate(e); break;
            case SWT.Deactivate :  onDeactivate(e); break;
            case SWT.Dispose :  onDispose(e); break;
            case SWT.Resize :
            case SWT.Move :     onResize(e); break;
            default :
                OLE.error(SWT.ERROR_NOT_IMPLEMENTED);
            }
        }
    };


    addListener(SWT.Activate, listener);
    addListener(SWT.Deactivate, listener);
    addListener(SWT.Dispose, listener);

    // inform inplaceactiveobject whenever frame resizes
    addListener(SWT.Resize, listener);

    // inform inplaceactiveobject whenever frame moves
    addListener(SWT.Move, listener);

    // Maintain a reference to yourself so that when
    // ClientSites close, they don't take the frame away
    // with them.
    this.AddRef();

    // Check for focus change
    Display display = getDisplay();
    initCheckFocus(display);
    initMsgHook(display);
}
private static void initCheckFocus (Display display_) {
    if (display_.getData(CHECK_FOCUS) !is null) return;
    display_.setData(CHECK_FOCUS, new ArrayWrapperString(CHECK_FOCUS));
    static const int time = 50;
    auto timer = new class(display_) Runnable {
        Display display;
        Control[1] lastFocus;
        this( Display display){ this.display = display; }
        public void run() {
            if (( null !is cast(OleClientSite)lastFocus[0] ) && !lastFocus[0].isDisposed()) {
                // ignore popup menus and dialogs
                auto hwnd = OS.GetFocus();
                while (hwnd !is null) {
                    auto ownerHwnd = OS.GetWindow(hwnd, OS.GW_OWNER);
                    if (ownerHwnd !is null) {
                        display.timerExec(time, this);
                        return;
                    }
                    hwnd = OS.GetParent(hwnd);
                }
            }
            if (lastFocus[0] is null || lastFocus[0].isDisposed() || !lastFocus[0].isFocusControl()) {
                Control currentFocus = display.getFocusControl();
                if ( auto frame = cast(OleFrame)currentFocus ) {
                    currentFocus = frame.getCurrentDocument();
                }
                if (lastFocus[0] !is currentFocus) {
                    Event event = new Event();
                    if (( null !is cast(OleClientSite)lastFocus[0] ) && !lastFocus[0].isDisposed()) {
                        lastFocus[0].notifyListeners (SWT.FocusOut, event);
                    }
                    if (( null !is cast(OleClientSite)currentFocus ) && !currentFocus.isDisposed()) {
                        currentFocus.notifyListeners(SWT.FocusIn, event);
                    }
                }
                lastFocus[0] = currentFocus;
            }
            display.timerExec(time, this);
        }
    };
    display_.timerExec(time, timer);
}
private static void initMsgHook(Display display) {
    if (display.getData(HHOOK) !is null) return;
    //final Callback callback = new Callback(OleFrame.class, "getMsgProc", 3); //$NON-NLS-1$
    //int address = callback.getAddress();
    //if (address is 0) SWT.error(SWT.ERROR_NO_MORE_CALLBACKS);
    int threadId = OS.GetCurrentThreadId();
    auto hHook_ = OS.SetWindowsHookEx(OS.WH_GETMESSAGE, &getMsgProc, null, threadId);
    if (hHook_ is null) {
        //callback.dispose();
        return;
    }
    display.setData(HHOOK, new ValueWrapperT!(void*)(hHook_));
    display.setData(HHOOKMSG, new ValueWrapperT!(MSG*)(new MSG()));
    display.disposeExec(new class(hHook_) Runnable {
        void* hHook;
        this( void* hHook ){ this.hHook = hHook; }
        public void run() {
            if (hHook !is null) OS.UnhookWindowsHookEx(hHook);
            //if (callback !is null) callback.dispose();
        }
    });
}
static extern(Windows) .LRESULT getMsgProc(int code, WPARAM wParam, LPARAM lParam) {
    Display display = Display.getCurrent();
    if (display is null) return 0;
    auto hHook = cast(ValueWrapperT!(void*))display.getData(HHOOK);
    if (hHook is null) return 0;
    if (code < 0) {
        return OS.CallNextHookEx(hHook.value, code, wParam, lParam);
    }
    MSG* msg = cast(MSG*)(cast(ValueWrapperT!(MSG*))display.getData(HHOOKMSG)).value;
    OS.MoveMemory(msg, lParam, MSG.sizeof);
    int message = msg.message;
    if (OS.WM_KEYFIRST <= message && message <= OS.WM_KEYLAST) {
        if (display !is null) {
            Widget widget = null;
            auto hwnd = msg.hwnd;
            while (hwnd !is null) {
                widget = display.findWidget (hwnd);
                if (widget !is null) break;
                hwnd = OS.GetParent (hwnd);
            }
            if (widget !is null && (null !is cast(OleClientSite)widget )) {
                OleClientSite site = cast(OleClientSite)widget;
                if (site.handle is hwnd) {
                    bool consumed = false;
                    /* Allow activeX control to translate accelerators except when a menu is active. */
                    int thread = OS.GetWindowThreadProcessId(msg.hwnd, null);
                    GUITHREADINFO*  lpgui = new GUITHREADINFO();
                    lpgui.cbSize = GUITHREADINFO.sizeof;
                    bool rc = cast(bool) OS.GetGUIThreadInfo(thread, lpgui);
                    int mask = OS.GUI_INMENUMODE | OS.GUI_INMOVESIZE | OS.GUI_POPUPMENUMODE | OS.GUI_SYSTEMMENUMODE;
                    if (!rc || (lpgui.flags & mask) is 0) {
                        OleFrame frame = site.frame;
                        frame.setData(CONSUME_KEY, null);
                        consumed = frame.translateOleAccelerator(msg);
                        if (frame.getData(CONSUME_KEY) !is null) consumed = false;
                        frame.setData(CONSUME_KEY, null);
                    }
                    bool accentKey = false;
                    switch (msg.message) {
                        case OS.WM_KEYDOWN:
                        case OS.WM_SYSKEYDOWN: {
                            static if (!OS.IsWinCE) {
                                switch (msg.wParam) {
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
                                        int mapKey = OS.MapVirtualKey (cast(int)/*64bit*/msg.wParam, 2);
                                        if (mapKey !is 0) {
                                            accentKey = (mapKey & (OS.IsWinNT ? 0x80000000 : 0x8000)) !is 0;
                                            if (!accentKey) {
                                                for (int i=0; i<ACCENTS.length; i++) {
                                                    int value = OS.VkKeyScan (ACCENTS [i]);
                                                    if (value !is -1 && (value & 0xFF) is msg.wParam) {
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
                    /* Allow OleClientSite to process key events before activeX control */
                    if (!consumed && !accentKey && !ignoreNextKey) {
                        auto hwndOld = msg.hwnd;
                        msg.hwnd = site.handle;
                        consumed = OS.DispatchMessage (msg) is 1;
                        msg.hwnd = hwndOld;
                    }
                    switch (msg.message) {
                        case OS.WM_KEYDOWN:
                        case OS.WM_SYSKEYDOWN: {
                            switch (msg.wParam) {
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

                    if (consumed) {
                        // In order to prevent this message from also being processed
                        // by the application, zero out message, wParam and lParam
                        msg.message = OS.WM_NULL;
                        msg.wParam = msg.lParam = 0;
                        OS.MoveMemory(lParam, msg, MSG.sizeof);
                        return 0;
                    }
                }
            }
        }
    }
    return OS.CallNextHookEx( hHook.value, code, wParam, lParam);
}
/**
 * Increment the count of references to this instance
 *
 * @return the current reference count
 */
int AddRef() {
    refCount++;
    return refCount;
}
private int ContextSensitiveHelp(int fEnterMode) {
    return COM.S_OK;
}
private void createCOMInterfaces() {
    iOleInPlaceFrame = new _IOleInPlaceFrameImpl(this);
}
private void disposeCOMInterfaces () {
    iOleInPlaceFrame = null;
}
private HRESULT GetBorder(LPRECT lprectBorder) {
    /*
    The IOleInPlaceUIWindow::GetBorder function, when called on a document or frame window
    object, returns the outer rectangle (relative to the window) where the object can put
    toolbars or similar controls.
    */
    if (lprectBorder is null) return COM.E_INVALIDARG;
    RECT* rectBorder = new RECT();
    // Coordinates must be relative to the window
    OS.GetClientRect(handle, lprectBorder);
    return COM.S_OK;
}
/**
 *
 * Returns the application menu items that will appear in the Container location when an OLE Document
 * is in-place activated.
 *
 * <p>When an OLE Document is in-place active, the Document provides its own menus but the application
 * is given the opportunity to merge some of its menus into the menubar.  The application
 * is allowed to insert its menus in three locations: File (far left), Container(middle) and Window
 * (far right just before Help).  The OLE Document retains control of the Edit, Object and Help
 * menu locations.  Note that an application can insert more than one menu into a single location.
 *
 * @return the application menu items that will appear in the Container location when an OLE Document
 *         is in-place activated.
 *
 */
public MenuItem[] getContainerMenus(){
    return containerMenuItems;
}
/**
 *
 * Returns the application menu items that will appear in the File location when an OLE Document
 * is in-place activated.
 *
 * <p>When an OLE Document is in-place active, the Document provides its own menus but the application
 * is given the opportunity to merge some of its menus into the menubar.  The application
 * is allowed to insert its menus in three locations: File (far left), Container(middle) and Window
 * (far right just before Help).  The OLE Document retains control of the Edit, Object and Help
 * menu locations.  Note that an application can insert more than one menu into a single location.
 *
 * @return the application menu items that will appear in the File location when an OLE Document
 *         is in-place activated.
 *
 */
public MenuItem[] getFileMenus(){
    return fileMenuItems;
}
IOleInPlaceFrame getIOleInPlaceFrame() {
    return iOleInPlaceFrame;
}
private ptrdiff_t getMenuItemID(HMENU hMenu, int index) {
    ptrdiff_t id = 0;
    MENUITEMINFO lpmii;
    lpmii.cbSize = OS.MENUITEMINFO_sizeof;
    lpmii.fMask = OS.MIIM_STATE | OS.MIIM_SUBMENU | OS.MIIM_ID;
    OS.GetMenuItemInfo(hMenu, index, true, &lpmii);
    if ((lpmii.fState & OS.MF_POPUP) is OS.MF_POPUP) {
        id = cast(ptrdiff_t)lpmii.hSubMenu;
    } else {
        id = lpmii.wID;
    }
    return id;
}
private int GetWindow(HWND* phwnd) {
    if (phwnd !is null) {
        *phwnd = handle;
    }
    return COM.S_OK;
}
/**
 *
 * Returns the application menu items that will appear in the Window location when an OLE Document
 * is in-place activated.
 *
 * <p>When an OLE Document is in-place active, the Document provides its own menus but the application
 * is given the opportunity to merge some of its menus into the menubar.  The application
 * is allowed to insert its menus in three locations: File (far left), Container(middle) and Window
 * (far right just before Help).  The OLE Document retains control of the Edit, Object and Help
 * menu locations.  Note that an application can insert more than one menu into a single location.
 *
 * @return the application menu items that will appear in the Window location when an OLE Document
 *         is in-place activated.
 *
 */
public MenuItem[] getWindowMenus(){
    return windowMenuItems;
}
private HRESULT InsertMenus( HMENU hmenuShared, LPOLEMENUGROUPWIDTHS lpMenuWidths ) {
    // locate menu bar
    Menu menubar = getShell().getMenuBar();
    if (menubar is null || menubar.isDisposed()) {
        int temp = 0;
        COM.MoveMemory(lpMenuWidths, &temp, 4);
        return COM.S_OK;
    }
    HMENU hMenu = menubar.handle;

    // Create a holder for menu information.  This will be passed down to
    // the OS and the OS will fill in the requested information for each menu.
    MENUITEMINFO lpmii;
    auto hHeap = OS.GetProcessHeap();
    int cch = 128;
    auto byteCount = cch * TCHAR.sizeof;
    auto pszText = cast(TCHAR*) OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
    lpmii.cbSize = OS.MENUITEMINFO_sizeof;
    lpmii.fMask = OS.MIIM_STATE | OS.MIIM_ID | OS.MIIM_TYPE | OS.MIIM_SUBMENU | OS.MIIM_DATA;
    lpmii.dwTypeData = pszText;
    lpmii.cch = cch;

    // Loop over all "File-like" menus in the menubar and get information about the
    // item from the OS.
    int fileMenuCount = 0;
    int newindex = 0;
    if (this.fileMenuItems !is null) {
        for (int i = 0; i < this.fileMenuItems.length; i++) {
            MenuItem item = this.fileMenuItems[i];
            if (item !is null) {
                int index = item.getParent().indexOf(item);
                lpmii.cch = cch;  // lpmii.cch gets updated by GetMenuItemInfo to indicate the
                                  // exact number of characters in name.  Reset it to our max size
                                  // before each call.
                if (OS.GetMenuItemInfo(hMenu, index, true, &lpmii)) {
                    if (OS.InsertMenuItem(hmenuShared, newindex, true, &lpmii)) {
                        // keep track of the number of items
                        fileMenuCount++;
                        newindex++;
                    }
                }
            }
        }
    }

    // copy the menu item count information to the pointer
    COM.MoveMemory(lpMenuWidths, &fileMenuCount, 4);

    // Loop over all "Container-like" menus in the menubar and get information about the
    // item from the OS.
    int containerMenuCount = 0;
    if (this.containerMenuItems !is null) {
        for (int i = 0; i < this.containerMenuItems.length; i++) {
            MenuItem item = this.containerMenuItems[i];
            if (item !is null) {
                int index = item.getParent().indexOf(item);
                lpmii.cch = cch; // lpmii.cch gets updated by GetMenuItemInfo to indicate the
                                           // exact number of characters in name.  Reset it to a large number
                                           // before each call.
                if (OS.GetMenuItemInfo(hMenu, index, true, &lpmii)) {
                    if (OS.InsertMenuItem(hmenuShared, newindex, true, &lpmii)) {
                        // keep track of the number of items
                        containerMenuCount++;
                        newindex++;
                    }
                }
            }
        }
    }

    // copy the menu item count information to the pointer
    COM.MoveMemory((cast(void*)lpMenuWidths) + 8, &containerMenuCount, 4);

    // Loop over all "Window-like" menus in the menubar and get information about the
    // item from the OS.
    int windowMenuCount = 0;
    if (this.windowMenuItems !is null) {
        for (int i = 0; i < this.windowMenuItems.length; i++) {
            MenuItem item = this.windowMenuItems[i];
            if (item !is null) {
                int index = item.getParent().indexOf(item);
                lpmii.cch = cch; // lpmii.cch gets updated by GetMenuItemInfo to indicate the
                                           // exact number of characters in name.  Reset it to a large number
                                           // before each call.
                if (OS.GetMenuItemInfo(hMenu, index, true, &lpmii)) {
                    if (OS.InsertMenuItem(hmenuShared, newindex, true, &lpmii)) {
                        // keep track of the number of items
                        windowMenuCount++;
                        newindex++;
                    }
                }
            }
        }
    }

    // copy the menu item count information to the pointer
    COM.MoveMemory((cast(void*)lpMenuWidths) + 16, &windowMenuCount, 4);

    // free resources used in querying the OS
    if (pszText !is null)
        OS.HeapFree(hHeap, 0, pszText);
    return COM.S_OK;
}
void onActivate(Event e) {
    if (objIOleInPlaceActiveObject !is null) {
        objIOleInPlaceActiveObject.OnFrameWindowActivate(true);
    }
    if (objIOleInPlaceActiveObject !is null) {
        objIOleInPlaceActiveObject.OnDocWindowActivate(true);
    }
}
void onDeactivate(Event e) {
    if (objIOleInPlaceActiveObject !is null) {
        objIOleInPlaceActiveObject.OnFrameWindowActivate(false);
    }
    if (objIOleInPlaceActiveObject !is null) {
        objIOleInPlaceActiveObject.OnDocWindowActivate(false);
    }
}
private void onDispose(Event e) {

    releaseObjectInterfaces();
    currentdoc = null;

    this.Release();
    removeListener(SWT.Activate, listener);
    removeListener(SWT.Deactivate, listener);
    removeListener(SWT.Dispose, listener);
    removeListener(SWT.Resize, listener);
    removeListener(SWT.Move, listener);
}
private void onResize(Event e) {
    if (objIOleInPlaceActiveObject !is null) {
        RECT lpRect;
        OS.GetClientRect(handle, &lpRect);
        objIOleInPlaceActiveObject.ResizeBorder(&lpRect, iOleInPlaceFrame, true);
    }
}
private HRESULT QueryInterface(REFCIID riid, void** ppvObject) {
//  implements IUnknown, IOleInPlaceFrame, IOleContainer, IOleInPlaceUIWindow
    if (riid is null || ppvObject is null)
        return COM.E_INVALIDARG;

    if (COM.IsEqualGUID(riid, &COM.IIDIUnknown) || COM.IsEqualGUID(riid, &COM.IIDIOleInPlaceFrame) ) {
        *ppvObject = cast(void*)cast(IOleInPlaceFrame)iOleInPlaceFrame;
        AddRef();
        return COM.S_OK;
    }

    *ppvObject = null;
    return COM.E_NOINTERFACE;
}
/**
 * Decrement the count of references to this instance
 *
 * @return the current reference count
 */
int Release() {
    refCount--;
    if (refCount is 0){
        disposeCOMInterfaces();
        COM.CoFreeUnusedLibraries();
    }
    return refCount;
}
private void releaseObjectInterfaces() {
    if (objIOleInPlaceActiveObject !is null) {
        objIOleInPlaceActiveObject.Release();
    }
    objIOleInPlaceActiveObject = null;
}
private int RemoveMenus(HMENU hmenuShared) {

    Menu menubar = getShell().getMenuBar();
    if (menubar is null || menubar.isDisposed()) return COM.S_FALSE;

    auto hMenu = menubar.handle;

    Vector ids = new Vector();
    if (this.fileMenuItems !is null) {
        for (int i = 0; i < this.fileMenuItems.length; i++) {
            MenuItem item = this.fileMenuItems[i];
            if (item !is null && !item.isDisposed()) {
                int index = item.getParent().indexOf(item);
                // get Id from original menubar
                auto id = getMenuItemID(hMenu, index);
                ids.addElement(new org.eclipse.swt.internal.LONG.LONG_PTR(id));
            }
        }
    }
    if (this.containerMenuItems !is null) {
        for (int i = 0; i < this.containerMenuItems.length; i++) {
            MenuItem item = this.containerMenuItems[i];
            if (item !is null && !item.isDisposed()) {
                int index = item.getParent().indexOf(item);
                auto id = getMenuItemID(hMenu, index);
                ids.addElement(new org.eclipse.swt.internal.LONG.LONG_PTR(id));
            }
        }
    }
    if (this.windowMenuItems !is null) {
        for (int i = 0; i < this.windowMenuItems.length; i++) {
            MenuItem item = this.windowMenuItems[i];
            if (item !is null && !item.isDisposed()) {
                int index = item.getParent().indexOf(item);
                auto id = getMenuItemID(hMenu, index);
                ids.addElement(new org.eclipse.swt.internal.LONG.LONG_PTR(id));
            }
        }
    }
    int index = OS.GetMenuItemCount(hmenuShared) - 1;
    for (int i = index; i >= 0; i--) {
        auto id = getMenuItemID(hmenuShared, i);
        if (ids.contains(new org.eclipse.swt.internal.LONG.LONG_PTR(id))){
            OS.RemoveMenu(hmenuShared, i, OS.MF_BYPOSITION);
        }
    }
    return COM.S_OK;
}
private int RequestBorderSpace(LPCBORDERWIDTHS pborderwidths) {
    return COM.S_OK;
}
HRESULT SetActiveObject( LPOLEINPLACEACTIVEOBJECT pActiveObject, LPCOLESTR pszObjName ) {
    if (objIOleInPlaceActiveObject !is null) {
        objIOleInPlaceActiveObject.Release();
        objIOleInPlaceActiveObject = null;
    }
    if (pActiveObject !is null) {
        objIOleInPlaceActiveObject = pActiveObject;
        objIOleInPlaceActiveObject.AddRef();
    }

    return COM.S_OK;
}

private HRESULT SetBorderSpace( LPCBORDERWIDTHS pborderwidths ) {
    // A Control/Document can :
    // Use its own toolbars, requesting border space of a specific size, or,
    // Use no toolbars, but force the container to remove its toolbars by passing a
    //   valid BORDERWIDTHS structure containing nothing but zeros in the pborderwidths parameter, or,
    // Use no toolbars but allow the in-place container to leave its toolbars up by
    //   passing NULL as the pborderwidths parameter.
    if (objIOleInPlaceActiveObject is null) return COM.S_OK;
    RECT* borderwidth = new RECT();
    if (pborderwidths is null || currentdoc is null ) return COM.S_OK;

    COM.MoveMemory(borderwidth, pborderwidths, RECT.sizeof);
    currentdoc.setBorderSpace(borderwidth);

    return COM.S_OK;
}
/**
 *
 * Specify the menu items that should appear in the Container location when an OLE Document
 * is in-place activated.
 *
 * <p>When an OLE Document is in-place active, the Document provides its own menus but the application
 * is given the opportunity to merge some of its menus into the menubar.  The application
 * is allowed to insert its menus in three locations: File (far left), Container(middle) and Window
 * (far right just before Help).  The OLE Document retains control of the Edit, Object and Help
 * menu locations.  Note that an application can insert more than one menu into a single location.
 *
 * <p>This method must be called before in place activation of the OLE Document.  After the Document
 * is activated, the menu bar will not be modified until a subsequent activation.
 *
 * @param containerMenus an array of top level MenuItems to be inserted into the Container location of
 *        the menubar
 */
public void setContainerMenus(MenuItem[] containerMenus){
    containerMenuItems = containerMenus;
}
OleClientSite getCurrentDocument() {
    return currentdoc;
}
void setCurrentDocument(OleClientSite doc) {
    currentdoc = doc;

    if (currentdoc !is null && objIOleInPlaceActiveObject !is null) {
        RECT lpRect;
        OS.GetClientRect(handle, &lpRect);
        objIOleInPlaceActiveObject.ResizeBorder(&lpRect, iOleInPlaceFrame, true);
    }
}
/**
 *
 * Specify the menu items that should appear in the File location when an OLE Document
 * is in-place activated.
 *
 * <p>When an OLE Document is in-place active, the Document provides its own menus but the application
 * is given the opportunity to merge some of its menus into the menubar.  The application
 * is allowed to insert its menus in three locations: File (far left), Container(middle) and Window
 * (far right just before Help).  The OLE Document retains control of the Edit, Object and Help
 * menu locations.  Note that an application can insert more than one menu into a single location.
 *
 * <p>This method must be called before in place activation of the OLE Document.  After the Document
 * is activated, the menu bar will not be modified until a subsequent activation.
 *
 * @param fileMenus an array of top level MenuItems to be inserted into the File location of
 *        the menubar
 */
public void setFileMenus(MenuItem[] fileMenus){
    fileMenuItems = fileMenus;
}
HRESULT SetMenu( HMENU hmenuShared, HOLEMENU holemenu, HWND hwndActiveObject ) {
    IOleInPlaceActiveObject inPlaceActiveObject;
    if (objIOleInPlaceActiveObject !is null)
        inPlaceActiveObject = objIOleInPlaceActiveObject;

    Menu menubar = getShell().getMenuBar();
    if (menubar is null || menubar.isDisposed()){
        return COM.OleSetMenuDescriptor(null, getShell().handle, hwndActiveObject, iOleInPlaceFrame, inPlaceActiveObject);
    }

    HWND handle = menubar.getShell().handle;

    if (hmenuShared is null && holemenu is null) {
        // re-instate the original menu - this occurs on deactivation
        hmenuShared = menubar.handle;
    }
    if (hmenuShared is null) return COM.E_FAIL;

    OS.SetMenu(handle, hmenuShared);
    OS.DrawMenuBar(handle);

    return COM.OleSetMenuDescriptor(holemenu, handle, hwndActiveObject, iOleInPlaceFrame, inPlaceActiveObject);
}

/**
 *
 * Set the menu items that should appear in the Window location when an OLE Document
 * is in-place activated.
 *
 * <p>When an OLE Document is in-place active, the Document provides its own menus but the application
 * is given the opportunity to merge some of its menus into the menubar.  The application
 * is allowed to insert its menus in three locations: File (far left), Container(middle) and Window
 * (far right just before Help).  The OLE Document retains control of the Edit, Object and Help
 * menu locations.  Note that an application can insert more than one menu into a single location.
 *
 * <p>This method must be called before in place activation of the OLE Document.  After the Document
 * is activated, the menu bar will not be modified until a subsequent activation.
 *
 * @param windowMenus an array of top level MenuItems to be inserted into the Window location of
 *        the menubar
 */
public void setWindowMenus(MenuItem[] windowMenus){
    windowMenuItems = windowMenus;
}
private bool translateOleAccelerator(MSG* msg) {
    if (objIOleInPlaceActiveObject is null) return false;
    int result = objIOleInPlaceActiveObject.TranslateAccelerator(msg);
    return (result != COM.S_FALSE && result != COM.E_NOTIMPL);
}

HRESULT TranslateAccelerator( LPMSG lpmsg, WORD wID ){
    Menu menubar = getShell().getMenuBar();
    if (menubar is null || menubar.isDisposed() || !menubar.isEnabled()) return COM.S_FALSE;
    if (wID < 0) return COM.S_FALSE;

    Shell shell = menubar.getShell();
    HWND hwnd = shell.handle;
    HACCEL hAccel = cast(HACCEL)OS.SendMessage(hwnd, OS.WM_APP+1, 0, 0);
    if (hAccel is null) return COM.S_FALSE;

    MSG msg = *lpmsg;
    int result = OS.TranslateAccelerator(hwnd, hAccel, &msg);
    return result == 0 ? COM.S_FALSE : COM.S_OK;
}
}

//  implements IOleInPlaceFrame, IOleInPlaceUIWindow, IOleWindow, IUnknown
class _IOleInPlaceFrameImpl : IOleInPlaceFrame {

    OleFrame parent;
    this(OleFrame p) { parent = p; }
extern (Windows) :
    // interface of IUnknown
    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }
    ULONG AddRef()  { return parent.AddRef(); }
    ULONG Release() { return parent.Release(); }

    // interface IOleWindow
    HRESULT GetWindow( HWND * phwnd ) { return parent.GetWindow(phwnd); }
    HRESULT ContextSensitiveHelp( BOOL fEnterMode ){ return COM.S_OK; }

    //interface IOleInPlaceUIWindow
    HRESULT GetBorder( LPRECT lprectBorder ) { return parent.GetBorder(lprectBorder); }
    HRESULT RequestBorderSpace( LPCBORDERWIDTHS pborderwidths ){ return COM.S_OK; }
    HRESULT SetBorderSpace( LPCBORDERWIDTHS pborderwidths ) { return parent.SetBorderSpace(pborderwidths); }
    HRESULT SetActiveObject( LPOLEINPLACEACTIVEOBJECT pActiveObject, LPCOLESTR pszObjName ) {
        return parent.SetActiveObject(pActiveObject, pszObjName);
    }

    // interface IOleInPlaceFrame : IOleInPlaceUIWindow
    HRESULT InsertMenus( HMENU hmenuShared, LPOLEMENUGROUPWIDTHS lpMenuWidths ){
        return parent.InsertMenus(hmenuShared, lpMenuWidths);
    }
    HRESULT SetMenu( HMENU hmenuShared, HOLEMENU holemenu, HWND hwndActiveObject ){
        return parent.SetMenu(hmenuShared, holemenu, hwndActiveObject);
    }
    HRESULT RemoveMenus( HMENU hmenuShared ) {
        return parent.RemoveMenus(hmenuShared);
    }
    HRESULT SetStatusText( LPCOLESTR pszStatusText ) { return COM.E_NOTIMPL; }
    HRESULT EnableModeless( BOOL fEnable ) { return COM.E_NOTIMPL; }
    HRESULT TranslateAccelerator( LPMSG lpmsg, WORD wID ) {
        return parent.TranslateAccelerator(lpmsg, wID);
    }

}

