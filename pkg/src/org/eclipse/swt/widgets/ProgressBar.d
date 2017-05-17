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
module org.eclipse.swt.widgets.ProgressBar;

import org.eclipse.swt.widgets.Control;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Composite;

import java.lang.all;

/**
 * Instances of the receiver represent an unselectable
 * user interface object that is used to display progress,
 * typically in the form of a bar.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>SMOOTH, HORIZONTAL, VERTICAL, INDETERMINATE</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles HORIZONTAL and VERTICAL may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#progressbar">ProgressBar snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class ProgressBar : Control {

    alias Control.computeSize computeSize;
    alias Control.windowProc windowProc;

    static const int DELAY = 100;
    static const int TIMER_ID = 100;
    static const int MINIMUM_WIDTH = 100;
    mixin(gshared!(`private static /+const+/ WNDPROC ProgressBarProc;`));
    static const TCHAR[] ProgressBarClass = OS.PROGRESS_CLASS;

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
            OS.GetClassInfo (null, ProgressBarClass.ptr, &lpWndClass);
            ProgressBarProc = lpWndClass.lpfnWndProc;
            /*
            * Feature in Windows.  The progress bar window class
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
            int byteCount = (ProgressBarClass.length+1) * TCHAR.sizeof;
            TCHAR* lpszClassName = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
            OS.MoveMemory (lpszClassName, ProgressBarClass.ptr, byteCount);
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
 * @see SWT#SMOOTH
 * @see SWT#HORIZONTAL
 * @see SWT#VERTICAL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    static_this();
    super (parent, checkStyle (style));
}

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    return OS.CallWindowProc (ProgressBarProc, hwnd, msg, wParam, lParam);
}

static int checkStyle (int style) {
    style |= SWT.NO_FOCUS;
    return checkBits (style, SWT.HORIZONTAL, SWT.VERTICAL, 0, 0, 0, 0);
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int border = getBorderWidth ();
    int width = border * 2, height = border * 2;
    if ((style & SWT.HORIZONTAL) !is 0) {
        width += OS.GetSystemMetrics (OS.SM_CXHSCROLL) * 10;
        height += OS.GetSystemMetrics (OS.SM_CYHSCROLL);
    } else {
        width += OS.GetSystemMetrics (OS.SM_CXVSCROLL);
        height += OS.GetSystemMetrics (OS.SM_CYVSCROLL) * 10;
    }
    if (wHint !is SWT.DEFAULT) width = wHint + (border * 2);
    if (hHint !is SWT.DEFAULT) height = hHint + (border * 2);
    return new Point (width, height);
}

override void createHandle () {
    super.createHandle ();
    startTimer ();
}

override int defaultForeground () {
    return OS.GetSysColor (OS.COLOR_HIGHLIGHT);
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
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.PBM_GETRANGE, 0, 0);
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
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.PBM_GETRANGE, 1, 0);
}

/**
 * Returns the single 'selection' that is the receiver's position.
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
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.PBM_GETPOS, 0, 0);
}

/**
 * Returns the state of the receiver. The value will be one of:
 * <ul>
 *  <li>{@link SWT#NORMAL}</li>
 *  <li>{@link SWT#ERROR}</li>
 *  <li>{@link SWT#PAUSED}</li>
 * </ul>
 *
 * @return the state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public int getState () {
    checkWidget ();
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
        auto state = OS.SendMessage (handle, OS.PBM_GETSTATE, 0, 0);
        switch (state) {
            case OS.PBST_NORMAL: return SWT.NORMAL;
            case OS.PBST_ERROR: return SWT.ERROR;
            case OS.PBST_PAUSED: return SWT.PAUSED;
            default:
        }
    }
    return SWT.NORMAL;
}

override void releaseWidget () {
    super.releaseWidget ();
    stopTimer ();
}

void startTimer () {
    if ((style & SWT.INDETERMINATE) !is 0) {
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        if (OS.COMCTL32_MAJOR < 6 || (bits & OS.PBS_MARQUEE) is 0) {
            OS.SetTimer (handle, TIMER_ID, DELAY, null);
        } else {
            OS.SendMessage (handle, OS.PBM_SETMARQUEE, 1, DELAY);
        }
    }
}

void stopTimer () {
    if ((style & SWT.INDETERMINATE) !is 0) {
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        if (OS.COMCTL32_MAJOR < 6 || (bits & OS.PBS_MARQUEE) is 0) {
            OS.KillTimer (handle, TIMER_ID);
        } else {
            OS.SendMessage (handle, OS.PBM_SETMARQUEE, 0, 0);
        }
    }
}

override void setBackgroundPixel (int pixel) {
    if (pixel is -1) pixel = OS.CLR_DEFAULT;
    OS.SendMessage (handle, OS.PBM_SETBKCOLOR, 0, pixel);
}

override void setForegroundPixel (int pixel) {
    if (pixel is -1) pixel = OS.CLR_DEFAULT;
    OS.SendMessage (handle, OS.PBM_SETBARCOLOR, 0, pixel);
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
    auto minimum = OS.SendMessage (handle, OS.PBM_GETRANGE, 1, 0);
    if (0 <= minimum && minimum < value) {
        OS.SendMessage (handle, OS.PBM_SETRANGE32, minimum, value);
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
    auto maximum = OS.SendMessage (handle, OS.PBM_GETRANGE, 0, 0);
    if (0 <= value && value < maximum) {
        OS.SendMessage (handle, OS.PBM_SETRANGE32, value, maximum);
    }
}

/**
 * Sets the single 'selection' that is the receiver's
 * position to the argument which must be greater than or equal
 * to zero.
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
    /*
    * Feature in Vista.  When the progress bar is not in
    * a normal state, PBM_SETPOS does not set the position
    * of the bar when the selection is equal to the minimum.
    * This is undocumented.  The fix is to temporarily
    * set the state to PBST_NORMAL, set the position, then
    * reset the state.
    */
    .LRESULT state = 0;
    bool fixSelection = false;
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
        auto minumum = OS.SendMessage (handle, OS.PBM_GETRANGE, 1, 0);
        auto selection = OS.SendMessage (handle, OS.PBM_GETPOS, 0, 0);
        if (selection is minumum) {
            fixSelection = true;
            state = OS.SendMessage (handle, OS.PBM_GETSTATE, 0, 0);
            OS.SendMessage (handle, OS.PBM_SETSTATE, OS.PBST_NORMAL, 0);
        }
    }
    OS.SendMessage (handle, OS.PBM_SETPOS, value, 0);
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
        if (fixSelection) OS.SendMessage (handle, OS.PBM_SETSTATE, state, 0);
    }
}

/**
 * Sets the state of the receiver. The state must be one of these values:
 * <ul>
 *  <li>{@link SWT#NORMAL}</li>
 *  <li>{@link SWT#ERROR}</li>
 *  <li>{@link SWT#PAUSED}</li>
 * </ul>
 *
 * @param state the new state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setState (int state) {
    checkWidget ();
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
        switch (state) {
            case SWT.NORMAL:
                OS.SendMessage (handle, OS.PBM_SETSTATE, OS.PBST_NORMAL, 0);
                break;
            case SWT.ERROR:
                OS.SendMessage (handle, OS.PBM_SETSTATE, OS.PBST_ERROR, 0);
                break;
            case SWT.PAUSED:
                OS.SendMessage (handle, OS.PBM_SETSTATE, OS.PBST_PAUSED, 0);
                break;
            default:
        }
    }
}

override int widgetStyle () {
    int bits = super.widgetStyle ();
    if ((style & SWT.SMOOTH) !is 0) bits |= OS.PBS_SMOOTH;
    if ((style & SWT.VERTICAL) !is 0) bits |= OS.PBS_VERTICAL;
    if ((style & SWT.INDETERMINATE) !is 0) bits |= OS.PBS_MARQUEE;
    return bits;
}

override String windowClass () {
    return TCHARsToStr( ProgressBarClass );
}

override ptrdiff_t windowProc () {
    return cast(ptrdiff_t) ProgressBarProc;
}

override LRESULT WM_GETDLGCODE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_GETDLGCODE (wParam, lParam);
    if (result !is null) return result;
    /*
    * Feature in Windows.  The progress bar does
    * not implement WM_GETDLGCODE.  As a result,
    * a progress bar takes focus and takes part
    * in tab traversal.  This behavior, while
    * unspecified, is unwanted.  The fix is to
    * implement WM_GETDLGCODE to behave like a
    * STATIC control.
    */
    return new LRESULT (OS.DLGC_STATIC);
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SIZE (wParam, lParam);
    if (result !is null) return result;
    /*
    * Feature in Windows.  When a progress bar with the style
    * PBS_MARQUEE becomes too small, the animation (currently
    * a small bar moving from right to left) does not have
    * enough space to draw.  The result is that the progress
    * bar does not appear to be moving.  The fix is to detect
    * this case, clear the PBS_MARQUEE style and emulate the
    * animation using PBM_STEPIT.
    *
    * NOTE:  This only happens on Window XP.
    */
    if ((style & SWT.INDETERMINATE) !is 0) {
        if (OS.COMCTL32_MAJOR >= 6) {
            forceResize ();
            RECT rect;
            OS.GetClientRect (handle, &rect);
            int oldBits = OS.GetWindowLong (handle, OS.GWL_STYLE);
            int newBits = oldBits;
            if (rect.right - rect.left < MINIMUM_WIDTH) {
                newBits &= ~OS.PBS_MARQUEE;
            } else {
                newBits |= OS.PBS_MARQUEE;
            }
            if (newBits !is oldBits) {
                stopTimer ();
                OS.SetWindowLong (handle, OS.GWL_STYLE, newBits);
                startTimer ();
            }
        }
    }
    return result;
}

override LRESULT WM_TIMER (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_TIMER (wParam, lParam);
    if (result !is null) return result;
    if ((style & SWT.INDETERMINATE) !is 0) {
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        if (OS.COMCTL32_MAJOR < 6 || (bits & OS.PBS_MARQUEE) is 0) {
            if (wParam is TIMER_ID) {
                OS.SendMessage (handle, OS.PBM_STEPIT, 0, 0);
            }
        }
    }
    return result;
}

}

