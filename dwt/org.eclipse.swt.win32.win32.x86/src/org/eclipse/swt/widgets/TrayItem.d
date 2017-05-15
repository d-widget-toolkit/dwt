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
module org.eclipse.swt.widgets.TrayItem;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.MenuDetectListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.ToolTip;
import org.eclipse.swt.widgets.Tray;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Display;

import java.lang.all;

/**
 * Instances of this class represent icons that can be placed on the
 * system tray or task bar status area.
 * <p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>DefaultSelection, MenuDetect, Selection</dd>
 * </dl>
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#tray">Tray, TrayItem snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.0
 */
public class TrayItem : Item {
    Tray parent;
    int id;
    Image image2;
    ToolTip toolTip;
    String toolTipText;
    bool visible = true;

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Tray</code>) and a style value
 * describing its behavior and appearance. The item is added
 * to the end of the items maintained by its parent.
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
 * @see SWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Tray parent, int style) {
    super (parent, style);
    this.parent = parent;
    parent.createItem (this, parent.getItemCount ());
    createWidget ();
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the receiver is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the receiver is selected
 * <code>widgetDefaultSelected</code> is called when the receiver is double-clicked
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
public void addSelectionListener(SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
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

override protected void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

void createWidget () {
    NOTIFYICONDATA iconData;
    iconData.cbSize = NOTIFYICONDATA.sizeof;
    iconData.uID = id = display.nextTrayId++;
    iconData.hWnd = display.hwndMessage;
    iconData.uFlags = OS.NIF_MESSAGE;
    iconData.uCallbackMessage = Display.SWT_TRAYICONMSG;
    OS.Shell_NotifyIcon (OS.NIM_ADD, &iconData);
}

override void destroyWidget () {
    parent.destroyItem (this);
    releaseHandle ();
}

/**
 * Returns the receiver's parent, which must be a <code>Tray</code>.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public Tray getParent () {
    checkWidget ();
    return parent;
}

/**
 * Returns the receiver's tool tip, or null if it has
 * not been set.
 *
 * @return the receiver's tool tip text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public ToolTip getToolTip () {
    checkWidget ();
    return toolTip;
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
    return toolTipText;
}

/**
 * Returns <code>true</code> if the receiver is visible and
 * <code>false</code> otherwise.
 *
 * @return the receiver's visibility
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getVisible () {
    checkWidget ();
    return visible;
}

.LRESULT messageProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  When the user clicks on the tray
    * icon, another application may be the foreground window.
    * This means that the event loop is not running and can
    * cause problems.  For example, if a menu is shown, when
    * the user clicks outside of the menu to cancel it, the
    * menu is not hidden until an event is processed.  If
    * another application is the foreground window, then the
    * menu is not hidden.  The fix is to force the tray icon
    * message window to the foreground when sending an event.
    */
    switch (lParam) {
        case OS.WM_LBUTTONDOWN:
            if (hooks (SWT.Selection)) {
                OS.SetForegroundWindow (hwnd);
                postEvent (SWT.Selection);
            }
            break;
        case OS.WM_LBUTTONDBLCLK:
        case OS.WM_RBUTTONDBLCLK:
            if (hooks (SWT.DefaultSelection)) {
                OS.SetForegroundWindow (hwnd);
                postEvent (SWT.DefaultSelection);
            }
            break;
        case OS.WM_RBUTTONUP: {
            if (hooks (SWT.MenuDetect)) {
                OS.SetForegroundWindow (hwnd);
                sendEvent (SWT.MenuDetect);
                // widget could be disposed at this point
                if (isDisposed()) return 0;
            }
            break;
        }
        case OS.NIN_BALLOONSHOW:
            if (toolTip !is null && !toolTip.visible) {
                toolTip.visible = true;
                if (toolTip.hooks (SWT.Show)) {
                    OS.SetForegroundWindow (hwnd);
                    toolTip.sendEvent (SWT.Show);
                    // widget could be disposed at this point
                    if (isDisposed()) return 0;
                }
            }
            break;
        case OS.NIN_BALLOONHIDE:
        case OS.NIN_BALLOONTIMEOUT:
        case OS.NIN_BALLOONUSERCLICK:
            if (toolTip !is null) {
                if (toolTip.visible) {
                    toolTip.visible = false;
                    if (toolTip.hooks (SWT.Hide)) {
                        OS.SetForegroundWindow (hwnd);
                        toolTip.sendEvent (SWT.Hide);
                        // widget could be disposed at this point
                        if (isDisposed()) return 0;
                    }
                }
                if (lParam is OS.NIN_BALLOONUSERCLICK) {
                    if (toolTip.hooks (SWT.Selection)) {
                        OS.SetForegroundWindow (hwnd);
                        toolTip.postEvent (SWT.Selection);
                        // widget could be disposed at this point
                        if (isDisposed()) return 0;
                    }
                }
            }
            break;
        default:
    }
    display.wakeThread ();
    return 0;
}

void recreate () {
    createWidget ();
    if (!visible) setVisible (false);
    if (text.length  !is 0) setText (text);
    if (image !is null) setImage (image);
    if (toolTipText !is null) setToolTipText (toolTipText);
}

override void releaseHandle () {
    super.releaseHandle ();
    parent = null;
}

override void releaseWidget () {
    super.releaseWidget ();
    if (toolTip !is null) toolTip.item = null;
    toolTip = null;
    if (image2 !is null) image2.dispose ();
    image2 = null;
    toolTipText = null;
    NOTIFYICONDATA iconData;
    iconData.cbSize = NOTIFYICONDATA.sizeof;
    iconData.uID = id;
    iconData.hWnd = display.hwndMessage;
    OS.Shell_NotifyIcon (OS.NIM_DELETE, &iconData);
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
public void removeSelectionListener(SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Selection, listener);
    eventTable.unhook (SWT.DefaultSelection,listener);
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
 * Sets the receiver's image.
 *
 * @param image the new image
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
override public void setImage (Image image) {
    checkWidget ();
    if (image !is null && image.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
    super.setImage (image);
    if (image2 !is null) image2.dispose ();
    image2 = null;
    HICON hIcon;
    Image icon = image;
    if (icon !is null) {
        switch (icon.type) {
            case SWT.BITMAP:
                image2 = Display.createIcon (image);
                hIcon = image2.handle;
                break;
            case SWT.ICON:
                hIcon = icon.handle;
                break;
            default:
        }
    }
    NOTIFYICONDATA iconData;
    iconData.cbSize = NOTIFYICONDATA.sizeof;
    iconData.uID = id;
    iconData.hWnd = display.hwndMessage;
    iconData.hIcon = hIcon;
    iconData.uFlags = OS.NIF_ICON;
    OS.Shell_NotifyIcon (OS.NIM_MODIFY, &iconData);
}

/**
 * Sets the receiver's tool tip to the argument, which
 * may be null indicating that no tool tip should be shown.
 *
 * @param toolTip the new tool tip (or null)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setToolTip (ToolTip toolTip) {
    checkWidget ();
    ToolTip oldTip = this.toolTip, newTip = toolTip;
    if (oldTip !is null) oldTip.item = null;
    this.toolTip = newTip;
    if (newTip !is null) newTip.item = this;
}

/**
 * Sets the receiver's tool tip text to the argument, which
 * may be null indicating that no tool tip text should be shown.
 *
 * @param value the new tool tip text (or null)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setToolTipText (String value) {
    checkWidget ();
    toolTipText = value;
    NOTIFYICONDATA iconData;
    StringT buffer = StrToTCHARs (0, toolTipText is null ? "X"[1..1] : toolTipText, true);
    assert( buffer.ptr !is null );
    /*
    * Note that the size of the szTip field is different in version 5.0 of shell32.dll.
    */
    int length_ = OS.SHELL32_MAJOR < 5 ? 64 : 128;
    static if (OS.IsUnicode) {
        TCHAR [] szTip = iconData.szTip[];
        length_ = Math.min (length_ - 1, cast(int)/*64bit*/buffer.length );
        System.arraycopy!(TCHAR) (buffer, 0, szTip, 0, length_);
    } else {
        TCHAR [] szTip = iconData.szTip[];
        length_ = Math.min (length_ - 1, buffer.length );
        System.arraycopy!(TCHAR) (buffer, 0, szTip, 0, length_);
    }
    iconData.cbSize = NOTIFYICONDATA.sizeof;
    iconData.uID = id;
    iconData.hWnd = display.hwndMessage;
    iconData.uFlags = OS.NIF_TIP;
    OS.Shell_NotifyIcon (OS.NIM_MODIFY, &iconData);
}

/**
 * Makes the receiver visible if the argument is <code>true</code>,
 * and makes it invisible otherwise.
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
    if (this.visible is visible) return;
    if (visible) {
        /*
        * It is possible (but unlikely), that application
        * code could have disposed the widget in the show
        * event.  If this happens, just return.
        */
        sendEvent (SWT.Show);
        if (isDisposed ()) return;
    }
    this.visible = visible;
    NOTIFYICONDATA iconData;
    iconData.cbSize = NOTIFYICONDATA.sizeof;
    iconData.uID = id;
    iconData.hWnd = display.hwndMessage;
    if (OS.SHELL32_MAJOR < 5) {
        if (visible) {
            iconData.uFlags = OS.NIF_MESSAGE;
            iconData.uCallbackMessage = Display.SWT_TRAYICONMSG;
            OS.Shell_NotifyIcon (OS.NIM_ADD, &iconData);
            setImage (image);
            setToolTipText (toolTipText);
        } else {
            OS.Shell_NotifyIcon (OS.NIM_DELETE, &iconData);
        }
    } else {
        iconData.uFlags = OS.NIF_STATE;
        iconData.dwState = visible ? 0 : OS.NIS_HIDDEN;
        iconData.dwStateMask = OS.NIS_HIDDEN;
        OS.Shell_NotifyIcon (OS.NIM_MODIFY, &iconData);
    }
    if (!visible) sendEvent (SWT.Hide);
}

}

