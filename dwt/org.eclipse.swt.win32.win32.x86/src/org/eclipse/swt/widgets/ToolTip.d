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


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.TrayItem;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.TypedListener;

import java.lang.all;

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
    TrayItem item;
    String text = "", message = "";
    int id, x, y;
    bool autoHide = true, hasLocation, visible;
    static const int TIMER_ID = 100;

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
    checkOrientation (parent);
    parent.createToolTip (this);
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
    TypedListener typedListener = new TypedListener(listener);
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
}

override void destroyWidget () {
    if (parent !is null) parent.destroyToolTip (this);
    releaseHandle ();
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
    checkWidget();
    return autoHide;
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
    checkWidget();
    return message;
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
    checkWidget();
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
    checkWidget();
    static if (OS.IsWinCE) return false;
    if (item !is null) return visible;
    auto hwndToolTip_ = hwndToolTip ();
    if (OS.SendMessage (hwndToolTip_, OS.TTM_GETCURRENTTOOL, 0, 0) !is 0) {
        TOOLINFO lpti;
        lpti.cbSize = OS.TOOLINFO_sizeof;
        if (OS.SendMessage (hwndToolTip_, OS.TTM_GETCURRENTTOOL, 0, &lpti) !is 0) {
            return (lpti.uFlags & OS.TTF_IDISHWND) is 0 && lpti.uId is id;
        }
    }
    return false;
}

HWND hwndToolTip () {
    return (style & SWT.BALLOON) !is 0 ? parent.balloonTipHandle () : parent.toolTipHandle ();
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
    if (item !is null) return getVisible () && item.getVisible ();
    return getVisible ();
}

override void releaseHandle () {
    super.releaseHandle ();
    parent = null;
    item = null;
    id = -1;
}

override void releaseWidget () {
    super.releaseWidget ();
    if (item is null) {
        if (autoHide) {
            auto hwndToolTip_ = hwndToolTip ();
            if (OS.SendMessage (hwndToolTip_, OS.TTM_GETCURRENTTOOL, 0, 0) !is 0) {
                TOOLINFO lpti;
                lpti.cbSize = OS.TOOLINFO_sizeof;
                if (OS.SendMessage (hwndToolTip_, OS.TTM_GETCURRENTTOOL, 0, &lpti) !is 0) {
                    if ((lpti.uFlags & OS.TTF_IDISHWND) is 0) {
                        if (lpti.uId is id) {
                            OS.SendMessage (hwndToolTip_, OS.TTM_TRACKACTIVATE, 0, &lpti);
                            OS.SendMessage (hwndToolTip_, OS.TTM_POP, 0, 0);
                            OS.KillTimer (hwndToolTip_, TIMER_ID);
                        }
                    }
                }
            }
        }
    }
    if (item !is null && item.toolTip is this) {
        item.toolTip = null;
    }
    item = null;
    text = message = null;
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
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Selection, listener);
    eventTable.unhook (SWT.DefaultSelection,listener);
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
public void setAutoHide (bool autoHide) {
    checkWidget ();
    this.autoHide = autoHide;
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
    hasLocation = true;
    //TODO - update when visible
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
    // SWT extension: allow null string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    message = string;
    //TODO - update when visible
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
    // SWT extension: allow null string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    text = string;
    //TODO - update when visible
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
    static if (OS.IsWinCE) return;
    if (visible is getVisible ()) return;
    if (item is null) {
        auto hwnd = parent.handle;
        TOOLINFO lpti;
        lpti.cbSize = OS.TOOLINFO_sizeof;
        lpti.uId = id;
        lpti.hwnd = hwnd;
        auto hwndToolTip_ = hwndToolTip ();
        Shell shell = parent.getShell ();
        if (text.length !is 0) {
            int icon = OS.TTI_NONE;
            if ((style & SWT.ICON_INFORMATION) !is 0) icon = OS.TTI_INFO;
            if ((style & SWT.ICON_WARNING) !is 0) icon = OS.TTI_WARNING;
            if ((style & SWT.ICON_ERROR) !is 0) icon = OS.TTI_ERROR;
            shell.setToolTipTitle (hwndToolTip_, text, cast(HICON) icon);
        } else {
            shell.setToolTipTitle (hwndToolTip_, null, null);
        }
        int maxWidth = 0;
        if (OS.IsWinCE || OS.WIN32_VERSION < OS.VERSION (4, 10)) {
            RECT rect;
            OS.SystemParametersInfo (OS.SPI_GETWORKAREA, 0, &rect, 0);
            maxWidth = (rect.right - rect.left) / 4;
        } else {
            auto hmonitor = OS.MonitorFromWindow (hwnd, OS.MONITOR_DEFAULTTONEAREST);
            MONITORINFO lpmi;
            lpmi.cbSize = MONITORINFO.sizeof;
            OS.GetMonitorInfo (hmonitor, &lpmi);
            maxWidth = (lpmi.rcWork.right - lpmi.rcWork.left) / 4;
        }
        OS.SendMessage (hwndToolTip_, OS.TTM_SETMAXTIPWIDTH, 0, maxWidth);
        if (visible) {
            int nX = x, nY = y;
            if (!hasLocation) {
                POINT pt;
                if (OS.GetCursorPos (&pt)) {
                    nX = pt.x;
                    nY = pt.y;
                }
            }
            auto lParam = OS.MAKELPARAM (nX, nY);
            OS.SendMessage (hwndToolTip_, OS.TTM_TRACKPOSITION, 0, lParam);

            /*
            * Feature in Windows.  Windows will not show a tool tip
            * if the cursor is outside the parent window (even on XP,
            * TTM_POPUP will not do this).  The fix is to temporarily
            * move the cursor into the tool window, show the tool tip,
            * and then restore the cursor.
            */
            POINT pt;
            OS.GetCursorPos (&pt);
            RECT rect;
            OS.GetClientRect (hwnd, &rect);
            OS.MapWindowPoints (hwnd, null, cast(POINT*) &rect, 2);
            if (!OS.PtInRect (&rect, pt)) {
                HCURSOR hCursor = OS.GetCursor ();
                OS.SetCursor (null);
                OS.SetCursorPos (rect.left, rect.top);
                OS.SendMessage (hwndToolTip_, OS.TTM_TRACKACTIVATE, 1, &lpti);
                OS.SetCursorPos (pt.x, pt.y);
                OS.SetCursor (hCursor);
            } else {
                OS.SendMessage (hwndToolTip_, OS.TTM_TRACKACTIVATE, 1, &lpti);
            }

            auto time = OS.SendMessage (hwndToolTip_, OS.TTM_GETDELAYTIME, OS.TTDT_AUTOPOP, 0);
            OS.SetTimer (hwndToolTip_, TIMER_ID, cast(int)/*64bit*/time, null);
        } else {
            OS.SendMessage (hwndToolTip_, OS.TTM_TRACKACTIVATE, 0, &lpti);
            OS.SendMessage (hwndToolTip_, OS.TTM_POP, 0, 0);
            OS.KillTimer (hwndToolTip_, TIMER_ID);
        }
        return;
    }
    if (item !is null && OS.SHELL32_MAJOR >= 5) {
        if (visible) {
            NOTIFYICONDATA iconData;
            StringT buffer1 = StrToTCHARs (0, text, true);
            StringT buffer2 = StrToTCHARs (0, message, true);
            static if (OS.IsUnicode) {
                TCHAR [] szInfoTitle = iconData.szInfoTitle;
                auto length1 = Math.min (szInfoTitle.length - 1, buffer1.length);
                System.arraycopy!(TCHAR) (buffer1, 0, szInfoTitle, 0, length1);
                TCHAR [] szInfo = iconData.szInfo;
                auto length2 = Math.min (szInfo.length - 1, buffer2.length );
                System.arraycopy!(TCHAR) (buffer2, 0, szInfo, 0, length2);
            } else {
                byte [] szInfoTitle = iconData.szInfoTitle;
                int length = Math.min (szInfoTitle.length - 1, buffer1.length );
                System.arraycopy (buffer1, 0, szInfoTitle, 0, length);
                byte [] szInfo = iconData.szInfo;
                int length2 = Math.min (szInfo.length - 1, buffer2.length );
                System.arraycopy!(TCHAR) (buffer2, 0, szInfo, 0, length2);
            }
            Display display = item.getDisplay ();
            iconData.cbSize = NOTIFYICONDATA.sizeof;
            iconData.uID = item.id;
            iconData.hWnd = display.hwndMessage;
            iconData.uFlags = OS.NIF_INFO;
            if ((style & SWT.ICON_INFORMATION) !is 0) iconData.dwInfoFlags = OS.NIIF_INFO;
            if ((style & SWT.ICON_WARNING) !is 0) iconData.dwInfoFlags = OS.NIIF_WARNING;
            if ((style & SWT.ICON_ERROR) !is 0) iconData.dwInfoFlags = OS.NIIF_ERROR;
            sendEvent (SWT.Show);
            this.visible = cast(bool) OS.Shell_NotifyIcon (OS.NIM_MODIFY, &iconData);
        } else {
            //TODO - hide the tray item
        }
    }
}
}

