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
module org.eclipse.swt.widgets.Sash;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;

import java.lang.all;

/**
 * Instances of the receiver represent a selectable user interface object
 * that allows the user to drag a rubber banded outline of the sash within
 * the parent control.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>HORIZONTAL, VERTICAL, SMOOTH</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles HORIZONTAL and VERTICAL may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#sash">Sash snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Sash : Control {

    alias Control.computeSize computeSize;
    alias Control.windowProc windowProc;

    bool dragging;
    int startX, startY, lastX, lastY;
    const static int INCREMENT = 1;
    const static int PAGE_INCREMENT = 9;

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
 * @see SWT#HORIZONTAL
 * @see SWT#VERTICAL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * When <code>widgetSelected</code> is called, the x, y, width, and height fields of the event object are valid.
 * If the receiver is being dragged, the event object detail field contains the value <code>SWT.DRAG</code>.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
 *
 * @param listener the listener which should be notified when the control is selected by the user
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

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    return OS.DefWindowProc (hwnd, msg, wParam, lParam);
}

override void createHandle () {
    super.createHandle ();
    state |= THEME_BACKGROUND;
}

static int checkStyle (int style) {
    return checkBits (style, SWT.HORIZONTAL, SWT.VERTICAL, 0, 0, 0, 0);
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int border = getBorderWidth ();
    int width = border * 2, height = border * 2;
    if ((style & SWT.HORIZONTAL) !is 0) {
        width += DEFAULT_WIDTH;  height += 3;
    } else {
        width += 3; height += DEFAULT_HEIGHT;
    }
    if (wHint !is SWT.DEFAULT) width = wHint + (border * 2);
    if (hHint !is SWT.DEFAULT) height = hHint + (border * 2);
    return new Point (width, height);
}

void drawBand (int x, int y, int width, int height) {
    if ((style & SWT.SMOOTH) !is 0) return;
    HWND hwndTrack = parent.handle;
    byte [] bits = [-86, 0, 85, 0, -86, 0, 85, 0, -86, 0, 85, 0, -86, 0, 85, 0];
    auto stippleBitmap = OS.CreateBitmap (8, 8, 1, 1, bits.ptr);
    auto stippleBrush = OS.CreatePatternBrush (stippleBitmap);
    auto hDC = OS.GetDCEx (hwndTrack, null, OS.DCX_CACHE);
    auto oldBrush = OS.SelectObject (hDC, stippleBrush);
    OS.PatBlt (hDC, x, y, width, height, OS.PATINVERT);
    OS.SelectObject (hDC, oldBrush);
    OS.ReleaseDC (hwndTrack, hDC);
    OS.DeleteObject (stippleBrush);
    OS.DeleteObject (stippleBitmap);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control is selected by the user.
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

override String windowClass () {
    return display.windowClass();
}

override ptrdiff_t windowProc () {
    return display.windowProc();
}

override LRESULT WM_ERASEBKGND (WPARAM wParam, LPARAM lParam) {
    super.WM_ERASEBKGND (wParam, lParam);
    drawBackground (cast(HANDLE) wParam);
    return LRESULT.ONE;
}

override LRESULT WM_KEYDOWN (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_KEYDOWN (wParam, lParam);
    if (result !is null) return result;
    switch (wParam) {
        case OS.VK_LEFT:
        case OS.VK_RIGHT:
        case OS.VK_UP:
        case OS.VK_DOWN:

            /* Calculate the new x or y position */
            if (OS.GetKeyState (OS.VK_LBUTTON) < 0) return result;
            int step = OS.GetKeyState (OS.VK_CONTROL) < 0 ? INCREMENT : PAGE_INCREMENT;
            POINT pt;
            if ((style & SWT.VERTICAL) !is 0) {
                if (wParam is OS.VK_UP || wParam is OS.VK_DOWN) break;
                pt.x = wParam is OS.VK_LEFT ? -step : step;
            } else {
                if (wParam is OS.VK_LEFT || wParam is OS.VK_RIGHT) break;
                pt.y = wParam is OS.VK_UP ? -step : step;
            }
            auto hwndTrack = parent.handle;
            OS.MapWindowPoints (handle, hwndTrack, &pt, 1);
            RECT rect, clientRect;
            OS.GetWindowRect (handle, &rect);
            int width = rect.right - rect.left;
            int height = rect.bottom - rect.top;
            OS.GetClientRect (hwndTrack, &clientRect);
            int clientWidth = clientRect.right - clientRect.left;
            int clientHeight = clientRect.bottom - clientRect.top;
            int newX = lastX, newY = lastY;
            if ((style & SWT.VERTICAL) !is 0) {
                newX = Math.min (Math.max (0, pt.x - startX), clientWidth - width);
            } else {
                newY = Math.min (Math.max (0, pt.y - startY), clientHeight - height);
            }
            if (newX is lastX && newY is lastY) return result;

            /* Update the pointer position */
            POINT cursorPt;
            cursorPt.x = pt.x;  cursorPt.y = pt.y;
            OS.ClientToScreen (hwndTrack, &cursorPt);
            if ((style & SWT.VERTICAL) !is 0) {
                cursorPt.y += height / 2;
            }
            else {
                cursorPt.x += width / 2;
            }
            OS.SetCursorPos (cursorPt.x, cursorPt.y);

            Event event = new Event ();
            event.x = newX;
            event.y = newY;
            event.width = width;
            event.height = height;
            sendEvent (SWT.Selection, event);
            if (isDisposed ()) return LRESULT.ZERO;
            if (event.doit) {
                if ((style & SWT.SMOOTH) !is 0) {
                    setBounds (event.x, event.y, width, height);
                }
            }
            return result;
        default:
    }
    return result;
}

override LRESULT WM_GETDLGCODE (WPARAM wParam, LPARAM lParam) {
    return new LRESULT (OS.DLGC_STATIC);
}

override LRESULT WM_LBUTTONDOWN (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_LBUTTONDOWN (wParam, lParam);
    if (result is LRESULT.ZERO) return result;

    /* Compute the banding rectangle */
    auto hwndTrack = parent.handle;
    POINT pt;
    OS.POINTSTOPOINT (pt, lParam);
    RECT rect;
    OS.GetWindowRect (handle, &rect);
    OS.MapWindowPoints (handle, null, &pt, 1);
    startX = pt.x - rect.left;
    startY = pt.y - rect.top;
    OS.MapWindowPoints (null, hwndTrack, cast(POINT*) &rect, 2);
    lastX = rect.left;
    lastY = rect.top;
    int width = rect.right - rect.left;
    int height = rect.bottom - rect.top;

    /* The event must be sent because doit flag is used */
    Event event = new Event ();
    event.x = lastX;
    event.y = lastY;
    event.width = width;
    event.height = height;
    if ((style & SWT.SMOOTH) is 0) {
        event.detail = SWT.DRAG;
    }
    sendEvent (SWT.Selection, event);
    if (isDisposed ()) return LRESULT.ZERO;

    /* Draw the banding rectangle */
    if (event.doit) {
        dragging = true;
        lastX = event.x;
        lastY = event.y;
        menuShell ().bringToTop ();
        if (isDisposed ()) return LRESULT.ZERO;
        static if (OS.IsWinCE) {
            OS.UpdateWindow (hwndTrack);
        } else {
            int flags = OS.RDW_UPDATENOW | OS.RDW_ALLCHILDREN;
            OS.RedrawWindow (hwndTrack, null, null, flags);
        }
        drawBand (event.x, event.y, width, height);
        if ((style & SWT.SMOOTH) !is 0) {
            setBounds (event.x, event.y, width, height);
            // widget could be disposed at this point
        }
    }
    return result;
}

override LRESULT WM_LBUTTONUP (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_LBUTTONUP (wParam, lParam);
    if (result is LRESULT.ZERO) return result;

    /* Compute the banding rectangle */
    if (!dragging) return result;
    dragging = false;
    RECT rect;
    OS.GetWindowRect (handle, &rect);
    int width = rect.right - rect.left;
    int height = rect.bottom - rect.top;

    /* The event must be sent because doit flag is used */
    Event event = new Event ();
    event.x = lastX;
    event.y = lastY;
    event.width = width;
    event.height = height;
    drawBand (event.x, event.y, width, height);
    sendEvent (SWT.Selection, event);
    if (isDisposed ()) return result;
    if (event.doit) {
        if ((style & SWT.SMOOTH) !is 0) {
            setBounds (event.x, event.y, width, height);
            // widget could be disposed at this point
        }
    }
    return result;
}

override LRESULT WM_MOUSEMOVE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_MOUSEMOVE (wParam, lParam);
    if (result !is null) return result;
    if (!dragging || (wParam & OS.MK_LBUTTON) is 0) return result;

    /* Compute the banding rectangle */
    POINT pt;
    OS.POINTSTOPOINT (pt, lParam);
    auto hwndTrack = parent.handle;
    OS.MapWindowPoints (handle, hwndTrack, &pt, 1);
    RECT rect, clientRect;
    OS.GetWindowRect (handle, &rect);
    int width = rect.right - rect.left;
    int height = rect.bottom - rect.top;
    OS.GetClientRect (hwndTrack, &clientRect);
    int newX = lastX, newY = lastY;
    if ((style & SWT.VERTICAL) !is 0) {
        int clientWidth = clientRect.right - clientRect.left;
        newX = Math.min (Math.max (0, pt.x - startX), clientWidth - width);
    } else {
        int clientHeight = clientRect.bottom - clientRect.top;
        newY = Math.min (Math.max (0, pt.y - startY), clientHeight - height);
    }
    if (newX is lastX && newY is lastY) return result;
    drawBand (lastX, lastY, width, height);

    /* The event must be sent because doit flag is used */
    Event event = new Event ();
    event.x = newX;
    event.y = newY;
    event.width = width;
    event.height = height;
    if ((style & SWT.SMOOTH) is 0) {
        event.detail = SWT.DRAG;
    }
    sendEvent (SWT.Selection, event);
    if (isDisposed ()) return LRESULT.ZERO;
    if (event.doit) {
        lastX = event.x;
        lastY = event.y;
    }
    static if (OS.IsWinCE) {
        OS.UpdateWindow (hwndTrack);
    } else {
        int flags = OS.RDW_UPDATENOW | OS.RDW_ALLCHILDREN;
        OS.RedrawWindow (hwndTrack, null, null, flags);
    }
    drawBand (lastX, lastY, width, height);
    if ((style & SWT.SMOOTH) !is 0) {
        setBounds (lastX, lastY, width, height);
        // widget could be disposed at this point
    }
    return result;
}

override LRESULT WM_SETCURSOR (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SETCURSOR (wParam, lParam);
    if (result !is null) return result;
    int hitTest = cast(short) OS.LOWORD (lParam);
    if (hitTest is OS.HTCLIENT) {
        HCURSOR hCursor;
        if ((style & SWT.HORIZONTAL) !is 0) {
            hCursor = OS.LoadCursor (null, cast(TCHAR*)OS.IDC_SIZENS);
        } else {
            hCursor = OS.LoadCursor (null, cast(TCHAR*)OS.IDC_SIZEWE);
        }
        OS.SetCursor (hCursor);
        return LRESULT.ONE;
    }
    return result;
}

}

