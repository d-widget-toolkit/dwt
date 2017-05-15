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
module org.eclipse.swt.widgets.Scale;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;

import java.lang.all;

/**
 * Instances of the receiver represent a selectable user
 * interface object that present a range of continuous
 * numeric values.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>HORIZONTAL, VERTICAL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles HORIZONTAL and VERTICAL may be specified.
 * </p><p>
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#scale">Scale snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class Scale : Control {

    alias Control.computeSize computeSize;
    alias Control.setBackgroundImage setBackgroundImage;
    alias Control.windowProc windowProc;

    bool ignoreResize, ignoreSelection;
    mixin(gshared!(`private static /+const+/ WNDPROC TrackBarProc;`));
    mixin(gshared!(`static const TCHAR[] TrackBarClass = OS.TRACKBAR_CLASS;`));

    mixin(gshared!(`private static bool static_this_completed = false;`));
    private static void static_this() {
        if( static_this_completed ){
            return;
        }
        synchronized {
            if( static_this_completed ){
                return;
            }
            WNDCLASS lpWndClass;
            OS.GetClassInfo (null, TrackBarClass.ptr, &lpWndClass);
            TrackBarProc = lpWndClass.lpfnWndProc;
            /*
            * Feature in Windows.  The track bar window class
            * does not include CS_DBLCLKS.  This means that these
            * controls will not get double click messages such as
            * WM_LBUTTONDBLCLK.  The fix is to register a new
            * window class with CS_DBLCLKS.
            *
            * NOTE:  Screen readers look for the exact class name
            * of the control in order to provide the correct kind
            * of assistance.  Therefore, it is critical that the
            * new window class have the same name.  It is possible
            * to register a local window class with the same name
            * as a global class.  Since bits that affect the class
            * are being changed, it is possible that other native
            * code, other than SWT, could create a control with
            * this class name, and fail unexpectedly.
            */
            auto hInstance = OS.GetModuleHandle (null);
            auto hHeap = OS.GetProcessHeap ();
            lpWndClass.hInstance = hInstance;
            lpWndClass.style &= ~OS.CS_GLOBALCLASS;
            lpWndClass.style |= OS.CS_DBLCLKS;
            int byteCount = (TrackBarClass.length+1) * TCHAR.sizeof;
            auto lpszClassName = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
            OS.MoveMemory (lpszClassName, TrackBarClass.ptr, byteCount);
            lpWndClass.lpszClassName = lpszClassName;
            OS.RegisterClass (&lpWndClass);
            OS.HeapFree (hHeap, 0, lpszClassName);
            static_this_completed = true;
        }
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
 * @see SWT#HORIZONTAL
 * @see SWT#VERTICAL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    static_this();
    super (parent, checkStyle (style));
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the user changes the receiver's value, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the user changes the receiver's value.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
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
 * @see SelectionListener
 * @see #removeSelectionListener
 */
public void addSelectionListener(SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
}

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    return OS.CallWindowProc (TrackBarProc, hwnd, msg, wParam, lParam);
}

static int checkStyle (int style) {
    return checkBits (style, SWT.HORIZONTAL, SWT.VERTICAL, 0, 0, 0, 0);
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int border = getBorderWidth ();
    int width = border * 2, height = border * 2;
    RECT rect;
    OS.SendMessage (handle, OS.TBM_GETTHUMBRECT, 0, &rect);
    if ((style & SWT.HORIZONTAL) !is 0) {
        width += OS.GetSystemMetrics (OS.SM_CXHSCROLL) * 10;
        int scrollY = OS.GetSystemMetrics (OS.SM_CYHSCROLL);
        height += (rect.top * 2) + scrollY + (scrollY / 3);
    } else {
        int scrollX = OS.GetSystemMetrics (OS.SM_CXVSCROLL);
        width += (rect.left * 2) + scrollX + (scrollX / 3);
        height += OS.GetSystemMetrics (OS.SM_CYVSCROLL) * 10;
    }
    if (wHint !is SWT.DEFAULT) width = wHint + (border * 2);
    if (hHint !is SWT.DEFAULT) height = hHint + (border * 2);
    return new Point (width, height);
}

override void createHandle () {
    super.createHandle ();
    state |= THEME_BACKGROUND | DRAW_BACKGROUND;
    OS.SendMessage (handle, OS.TBM_SETRANGEMAX, 0, 100);
    OS.SendMessage (handle, OS.TBM_SETPAGESIZE, 0, 10);
    OS.SendMessage (handle, OS.TBM_SETTICFREQ, 10, 0);
}

override int defaultForeground () {
    return OS.GetSysColor (OS.COLOR_BTNFACE);
}

/**
 * Returns the amount that the receiver's value will be
 * modified by when the up/down (or right/left) arrows
 * are pressed.
 *
 * @return the increment
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getIncrement () {
    checkWidget ();
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.TBM_GETLINESIZE, 0, 0);
}

/**
 * Returns the maximum value which the receiver will allow.
 *
 * @return the maximum
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getMaximum () {
    checkWidget ();
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.TBM_GETRANGEMAX, 0, 0);
}

/**
 * Returns the minimum value which the receiver will allow.
 *
 * @return the minimum
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getMinimum () {
    checkWidget ();
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.TBM_GETRANGEMIN, 0, 0);
}

/**
 * Returns the amount that the receiver's value will be
 * modified by when the page increment/decrement areas
 * are selected.
 *
 * @return the page increment
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getPageIncrement () {
    checkWidget ();
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.TBM_GETPAGESIZE, 0, 0);
}

/**
 * Returns the 'selection', which is the receiver's position.
 *
 * @return the selection
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSelection () {
    checkWidget ();
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.TBM_GETPOS, 0, 0);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the user changes the receiver's value.
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

override void setBackgroundImage (HBITMAP hImage) {
    super.setBackgroundImage (hImage);
    /*
    * Bug in Windows.  Changing the background color of the Scale
    * widget and calling InvalidateRect() still draws with the old
    * color.  The fix is to send a fake WM_SIZE event to cause
    * it to redraw with the new background color.
    */
    ignoreResize = true;
    OS.SendMessage (handle, OS.WM_SIZE, 0, 0);
    ignoreResize = false;
}

override void setBackgroundPixel (int pixel) {
    super.setBackgroundPixel (pixel);
    /*
    * Bug in Windows.  Changing the background color of the Scale
    * widget and calling InvalidateRect() still draws with the old
    * color.  The fix is to send a fake WM_SIZE event to cause
    * it to redraw with the new background color.
    */
    ignoreResize = true;
    OS.SendMessage (handle, OS.WM_SIZE, 0, 0);
    ignoreResize = false;
}

override
void setBounds (int x, int y, int width, int height, int flags, bool defer) {
    /*
    * Bug in Windows.  If SetWindowPos() is called on a
    * track bar with either SWP_DRAWFRAME, a new size,
    * or both during mouse down, the track bar posts a
    * WM_MOUSEMOVE message when the mouse has not moved.
    * The window proc for the track bar uses WM_MOUSEMOVE
    * to issue WM_HSCROLL or WM_SCROLL events to notify
    * the application that the slider has changed.  The
    * end result is that when the user requests a page
    * scroll and the application resizes the track bar
    * during the change notification, continuous stream
    * of WM_MOUSEMOVE messages are generated and the
    * thumb moves to the mouse position rather than
    * scrolling by a page.  The fix is to clear the
    * SWP_DRAWFRAME flag.
    *
    * NOTE:  There is no fix for the WM_MOUSEMOVE that
    * is generated by a new size.  Clearing SWP_DRAWFRAME
    * does not fix the problem.  However, it is unlikely
    * that the programmer will resize the control during
    * mouse down.
    */
    flags &= ~OS.SWP_DRAWFRAME;
    super.setBounds (x, y, width, height, flags, true);
}

/**
 * Sets the amount that the receiver's value will be
 * modified by when the up/down (or right/left) arrows
 * are pressed to the argument, which must be at least
 * one.
 *
 * @param increment the new increment (must be greater than zero)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setIncrement (int increment) {
    checkWidget ();
    if (increment < 1) return;
    auto minimum = OS.SendMessage (handle, OS.TBM_GETRANGEMIN, 0, 0);
    auto maximum = OS.SendMessage (handle, OS.TBM_GETRANGEMAX, 0, 0);
    if (increment > maximum - minimum) return;
    OS.SendMessage (handle, OS.TBM_SETLINESIZE, 0, increment);
}

/**
 * Sets the maximum value that the receiver will allow.  This new
 * value will be ignored if it is not greater than the receiver's current
 * minimum value.  If the new maximum is applied then the receiver's
 * selection value will be adjusted if necessary to fall within its new range.
 *
 * @param value the new maximum, which must be greater than the current minimum
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMaximum (int value) {
    checkWidget ();
    auto minimum = OS.SendMessage (handle, OS.TBM_GETRANGEMIN, 0, 0);
    if (0 <= minimum && minimum < value) {
        OS.SendMessage (handle, OS.TBM_SETRANGEMAX, 1, value);
    }
}

/**
 * Sets the minimum value that the receiver will allow.  This new
 * value will be ignored if it is negative or is not less than the receiver's
 * current maximum value.  If the new minimum is applied then the receiver's
 * selection value will be adjusted if necessary to fall within its new range.
 *
 * @param value the new minimum, which must be nonnegative and less than the current maximum
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMinimum (int value) {
    checkWidget ();
    auto maximum = OS.SendMessage (handle, OS.TBM_GETRANGEMAX, 0, 0);
    if (0 <= value && value < maximum) {
        OS.SendMessage (handle, OS.TBM_SETRANGEMIN, 1, value);
    }
}

/**
 * Sets the amount that the receiver's value will be
 * modified by when the page increment/decrement areas
 * are selected to the argument, which must be at least
 * one.
 *
 * @param pageIncrement the page increment (must be greater than zero)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setPageIncrement (int pageIncrement) {
    checkWidget ();
    if (pageIncrement < 1) return;
    auto minimum = OS.SendMessage (handle, OS.TBM_GETRANGEMIN, 0, 0);
    auto maximum = OS.SendMessage (handle, OS.TBM_GETRANGEMAX, 0, 0);
    if (pageIncrement > maximum - minimum) return;
    OS.SendMessage (handle, OS.TBM_SETPAGESIZE, 0, pageIncrement);
    OS.SendMessage (handle, OS.TBM_SETTICFREQ, pageIncrement, 0);
}

/**
 * Sets the 'selection', which is the receiver's value,
 * to the argument which must be greater than or equal to zero.
 *
 * @param value the new selection (must be zero or greater)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (int value) {
    checkWidget ();
    OS.SendMessage (handle, OS.TBM_SETPOS, 1, value);
}

override int widgetStyle () {
    int bits = super.widgetStyle () | OS.WS_TABSTOP | OS.TBS_BOTH | OS.TBS_AUTOTICKS;
    if ((style & SWT.HORIZONTAL) !is 0) return bits | OS.TBS_HORZ | OS.TBS_DOWNISLEFT;
    return bits | OS.TBS_VERT;
}

override String windowClass () {
    return TCHARsToStr(TrackBarClass);
}

override ptrdiff_t windowProc () {
    return cast(ptrdiff_t) TrackBarProc;
}

override LRESULT WM_MOUSEWHEEL (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_MOUSEWHEEL (wParam, lParam);
    if (result !is null) return result;
    /*
    * Bug in Windows.  When a track bar slider is changed
    * from WM_MOUSEWHEEL, it does not always send either
    * a WM_VSCROLL or M_HSCROLL to notify the application
    * of the change.  The fix is to detect that the selection
    * has changed and that notification has not been issued
    * and send the selection event.
    */
    auto oldPosition = OS.SendMessage (handle, OS.TBM_GETPOS, 0, 0);
    ignoreSelection = true;
    auto code = callWindowProc (handle, OS.WM_MOUSEWHEEL, wParam, lParam);
    ignoreSelection = false;
    auto newPosition = OS.SendMessage (handle, OS.TBM_GETPOS, 0, 0);
    if (oldPosition !is newPosition) {
        /*
        * Send the event because WM_HSCROLL and WM_VSCROLL
        * are sent from a modal message loop in windows that
        * is active when the user is scrolling.
        */
        sendEvent (SWT.Selection);
        // widget could be disposed at this point
    }
    return new LRESULT (code);
}

override LRESULT WM_PAINT (WPARAM wParam, LPARAM lParam) {
    /*
    * Bug in Windows.  For some reason, when WM_CTLCOLORSTATIC
    * is used to implement transparency and returns a NULL brush,
    * Windows doesn't always draw the track bar.  It seems that
    * it is drawn correctly the first time.  It is possible that
    * Windows double buffers the control and the double buffer
    * strategy fails when WM_CTLCOLORSTATIC returns unexpected
    * results.  The fix is to send a fake WM_SIZE to force it
    * to redraw every time there is a WM_PAINT.
    */
    bool fixPaint = findBackgroundControl () !is null;
    if (!fixPaint) {
        if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
            Control control = findThemeControl ();
            fixPaint = control !is null;
        }
    }
    if (fixPaint) {
        bool redraw = drawCount is 0 && OS.IsWindowVisible (handle);
        if (redraw) OS.SendMessage (handle, OS.WM_SETREDRAW, 0, 0);
        ignoreResize = true;
        OS.SendMessage (handle, OS.WM_SIZE, 0, 0);
        ignoreResize = false;
        if (redraw) {
            OS.SendMessage (handle, OS.WM_SETREDRAW, 1, 0);
            OS.InvalidateRect (handle, null, false);
        }
    }
    return super.WM_PAINT (wParam, lParam);
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    if (ignoreResize) return null;
    return super.WM_SIZE (wParam, lParam);
}

override LRESULT wmScrollChild (WPARAM wParam, LPARAM lParam) {

    /* Do nothing when scrolling is ending */
    int code = OS.LOWORD (wParam);
    switch (code) {
        case OS.TB_ENDTRACK:
        case OS.TB_THUMBPOSITION:
            return null;
        default:
    }

    if (!ignoreSelection) {
        Event event = new Event ();
        /*
        * This code is intentionally commented.  The event
        * detail field is not currently supported on all
        * platforms.
        */
//      switch (code) {
//          case OS.TB_TOP:         event.detail = SWT.HOME;  break;
//          case OS.TB_BOTTOM:      event.detail = SWT.END;  break;
//          case OS.TB_LINEDOWN:    event.detail = SWT.ARROW_DOWN;  break;
//          case OS.TB_LINEUP:      event.detail = SWT.ARROW_UP;  break;
//          case OS.TB_PAGEDOWN:    event.detail = SWT.PAGE_DOWN;  break;
//          case OS.TB_PAGEUP:      event.detail = SWT.PAGE_UP;  break;
//      default:
//      }

        /*
        * Send the event because WM_HSCROLL and WM_VSCROLL
        * are sent from a modal message loop in windows that
        * is active when the user is scrolling.
        */
        sendEvent (SWT.Selection, event);
        // widget could be disposed at this point
    }
    return null;
}

}

