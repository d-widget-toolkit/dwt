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
module org.eclipse.swt.widgets.DateTime;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.TypedListener;

import java.lang.all;

//TODO - features not yet implemented: read-only, drop-down calendar for date
//TODO - font, colors, background image not yet implemented (works on some platforms)

/**
 * Instances of this class are selectable user interface
 * objects that allow the user to enter and modify date
 * or time values.
 * <p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add children to it, or set a layout on it.
 * </p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>DATE, TIME, CALENDAR, SHORT, MEDIUM, LONG</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles DATE, TIME, or CALENDAR may be specified,
 * and only one of the styles SHORT, MEDIUM, or LONG may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 * 
 * @see <a href="http://www.eclipse.org/swt/snippets/#datetime">DateTime snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.3
 */

public class DateTime : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.windowProc windowProc;

    bool ignoreSelection;
    SYSTEMTIME* lastSystemTime;
    SYSTEMTIME time; // only used in calendar mode
    mixin(gshared!(`static /+const+/ WNDPROC DateTimeProc;`));
    mixin(gshared!(`static const TCHAR[] DateTimeClass = OS.DATETIMEPICK_CLASS;`));
    mixin(gshared!(`static /+const+/ WNDPROC CalendarProc;`));
    mixin(gshared!(`static const TCHAR[] CalendarClass = OS.MONTHCAL_CLASS;`));

    mixin(gshared!(`private static bool static_this_completed = false;`));
    private static void static_this() {
        if( static_this_completed ){
            return;
        }
        synchronized {
            if( static_this_completed ){
                return;
            }
            INITCOMMONCONTROLSEX icex;
            icex.dwSize = INITCOMMONCONTROLSEX.sizeof;
            icex.dwICC = OS.ICC_DATE_CLASSES;
            OS.InitCommonControlsEx (&icex);
            WNDCLASS lpWndClass;
            OS.GetClassInfo (null, DateTimeClass.ptr, &lpWndClass);
            DateTimeProc = lpWndClass.lpfnWndProc;
            /*
            * Feature in Windows.  The date time window class
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
            auto byteCount = DateTimeClass.length * TCHAR.sizeof;
            auto lpszClassName = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
            OS.MoveMemory (lpszClassName, DateTimeClass.ptr, byteCount);
            lpWndClass.lpszClassName = lpszClassName;
            OS.RegisterClass (&lpWndClass);
            OS.HeapFree (hHeap, 0, lpszClassName);
            OS.GetClassInfo (null, CalendarClass.ptr, &lpWndClass);
            CalendarProc = lpWndClass.lpfnWndProc;
            /*
            * Feature in Windows.  The date time window class
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
            hInstance = OS.GetModuleHandle (null);
            hHeap = OS.GetProcessHeap ();
            lpWndClass.hInstance = hInstance;
            lpWndClass.style &= ~OS.CS_GLOBALCLASS;
            lpWndClass.style |= OS.CS_DBLCLKS;
            byteCount = CalendarClass.length * TCHAR.sizeof;
            lpszClassName = cast(TCHAR*)OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
            OS.MoveMemory (lpszClassName, CalendarClass.ptr, byteCount);
            lpWndClass.lpszClassName = lpszClassName;
            OS.RegisterClass (&lpWndClass);
            OS.HeapFree (hHeap, 0, lpszClassName);
            static_this_completed = true;
        }
    }

    static const int MARGIN = 4;
    static const int MAX_DIGIT = 9;
    static const int MAX_DAY = 31;
    static const int MAX_12HOUR = 12;
    static const int MAX_24HOUR = 24;
    static const int MAX_MINUTE = 60;
    static const int MONTH_DAY_YEAR = 0;
    static const int DAY_MONTH_YEAR = 1;
    static const int YEAR_MONTH_DAY = 2;
    static const char SINGLE_QUOTE = '\''; //$NON-NLS-1$ short date format may include quoted text
    static const char DAY_FORMAT_CONSTANT = 'd'; //$NON-NLS-1$ 1-4 lowercase 'd's represent day
    static const char MONTH_FORMAT_CONSTANT = 'M'; //$NON-NLS-1$ 1-4 uppercase 'M's represent month
    static const char YEAR_FORMAT_CONSTANT = 'y'; //$NON-NLS-1$ 1-5 lowercase 'y's represent year
    static const char HOURS_FORMAT_CONSTANT = 'h'; //$NON-NLS-1$ 1-2 upper or lowercase 'h's represent hours
    static const char MINUTES_FORMAT_CONSTANT = 'm'; //$NON-NLS-1$ 1-2 lowercase 'm's represent minutes
    static const char SECONDS_FORMAT_CONSTANT = 's'; //$NON-NLS-1$ 1-2 lowercase 's's represent seconds
    static const char AMPM_FORMAT_CONSTANT = 't'; //$NON-NLS-1$ 1-2 lowercase 't's represent am/pm
    static const int[] MONTH_NAMES = [OS.LOCALE_SMONTHNAME1, OS.LOCALE_SMONTHNAME2, OS.LOCALE_SMONTHNAME3, OS.LOCALE_SMONTHNAME4, OS.LOCALE_SMONTHNAME5, OS.LOCALE_SMONTHNAME6, OS.LOCALE_SMONTHNAME7, OS.LOCALE_SMONTHNAME8, OS.LOCALE_SMONTHNAME9, OS.LOCALE_SMONTHNAME10, OS.LOCALE_SMONTHNAME11, OS.LOCALE_SMONTHNAME12];


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
 * @see SWT#DATE
 * @see SWT#TIME
 * @see SWT#CALENDAR
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    static_this();
    super (parent, checkStyle (style));
    if ((this.style & SWT.SHORT) !is 0) {
        String buffer = ((this.style & SWT.DATE) !is 0) ? getCustomShortDateFormat() : getCustomShortTimeFormat();
        StringT lpszFormat = StrToTCHARs (0, buffer, true);
        OS.SendMessage (handle, OS.DTM_SETFORMAT, 0, cast(void*)lpszFormat.ptr);
    }
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the user changes the control's value.
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
 * @see SelectionEvent
 */
public void addSelectionListener (SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection, typedListener);
    addListener (SWT.DefaultSelection, typedListener);
}

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    return OS.CallWindowProc ( cast(WNDPROC)windowProc(), hwnd, msg, wParam, lParam);
}

static int checkStyle (int style) {
    /*
    * Even though it is legal to create this widget
    * with scroll bars, they serve no useful purpose
    * because they do not automatically scroll the
    * widget's client area.  The fix is to clear
    * the SWT style.
    */
    style &= ~(SWT.H_SCROLL | SWT.V_SCROLL);
    style = checkBits (style, SWT.DATE, SWT.TIME, SWT.CALENDAR, 0, 0, 0);
    return checkBits (style, SWT.MEDIUM, SWT.SHORT, SWT.LONG, 0, 0, 0);
}

override protected void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = 0, height = 0;
    if (wHint is SWT.DEFAULT || hHint is SWT.DEFAULT) {
        if ((style & SWT.CALENDAR) !is 0) {
            RECT rect;
            OS.SendMessage(handle, OS.MCM_GETMINREQRECT, 0, &rect);
            width = rect.right;
            height = rect.bottom;
        } else {
            TCHAR[] buffer = new TCHAR[128];
            HFONT newFont, oldFont;
            auto hDC = OS.GetDC (handle);
            newFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
            if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
            RECT rect;
            int flags = OS.DT_CALCRECT | OS.DT_EDITCONTROL | OS.DT_NOPREFIX;
            SYSTEMTIME systime;
            if ((style & SWT.DATE) !is 0) {
                /* Determine the widest/tallest year string. */
                systime.wMonth = 1;
                systime.wDay = 1;
                int widest = 0, secondWidest = 0, thirdWidest = 0;
                for (int i = 0; i <= MAX_DIGIT; i++) {
                    systime.wYear = cast(short) (2000 + i); // year 2000 + i is guaranteed to exist
                    int size = OS.GetDateFormat(OS.LOCALE_USER_DEFAULT, OS.DATE_SHORTDATE, &systime, null, buffer.ptr, cast(int)/*64bit*/buffer.length);
                    if (size is 0) {
                        buffer = new TCHAR[size];
                        OS.GetDateFormat(OS.LOCALE_USER_DEFAULT, OS.DATE_SHORTDATE, &systime, null, buffer.ptr, cast(int)/*64bit*/buffer.length);
                    }
                    rect.left = rect.top = rect.right = rect.bottom = 0;
                    OS.DrawText (hDC, buffer.ptr, size, &rect, flags);
                    if (rect.right - rect.left >= width) {
                        width = rect.right - rect.left;
                        thirdWidest = secondWidest;
                        secondWidest = widest;
                        widest = i;
                    }
                    height = Math.max(height, rect.bottom - rect.top);
                }
                if (widest > 1) widest = widest * 1000 + widest * 100 + widest * 10 + widest;
                else if (secondWidest > 1) widest = secondWidest * 1000 + widest * 100 + widest * 10 + widest;
                else widest = thirdWidest * 1000 + widest * 100 + widest * 10 + widest;
                systime.wYear = cast(short) widest;

                /* Determine the widest/tallest month name string. */
                width = widest = 0;
                for (short i = 0; i < MONTH_NAMES.length; i++) {
                    int name = MONTH_NAMES [i];
                    int size = OS.GetLocaleInfo (OS.LOCALE_USER_DEFAULT, name, buffer.ptr, cast(int)/*64bit*/buffer.length);
                    if (size is 0) {
                        buffer = new TCHAR[size];
                        OS.GetLocaleInfo (OS.LOCALE_USER_DEFAULT, name, buffer.ptr, cast(int)/*64bit*/buffer.length);
                    }
                    rect.left = rect.top = rect.right = rect.bottom = 0;
                    OS.DrawText (hDC, buffer.ptr, size, &rect, flags);
                    if (rect.right - rect.left > width) {
                        width = rect.right - rect.left;
                        widest = i;
                    }
                    height = Math.max(height, rect.bottom - rect.top);
                }
                systime.wMonth = cast(short) (widest + 1);

                /* Determine the widest/tallest date string in the widest month of the widest year. */
                int dwFlags = ((style & SWT.MEDIUM) !is 0) ? OS.DATE_SHORTDATE : ((style & SWT.SHORT) !is 0) ? OS.DATE_YEARMONTH : OS.DATE_LONGDATE;
                width = 0;
                for (short i = 1; i <= MAX_DAY; i++) {
                    systime.wDay = i;
                    int size = OS.GetDateFormat(OS.LOCALE_USER_DEFAULT, dwFlags, &systime, null, buffer.ptr, cast(int)/*64bit*/buffer.length);
                    if (size is 0) {
                        buffer = new TCHAR[size];
                        OS.GetDateFormat(OS.LOCALE_USER_DEFAULT, dwFlags, &systime, null, buffer.ptr, cast(int)/*64bit*/buffer.length);
                    }
                    rect.left = rect.top = rect.right = rect.bottom = 0;
                    OS.DrawText (hDC, buffer.ptr, size, &rect, flags);
                    width = Math.max(width, rect.right - rect.left);
                    height = Math.max(height, rect.bottom - rect.top);
                    if ((style & SWT.SHORT) !is 0) break;
                }
            } else if ((style & SWT.TIME) !is 0) {
                /* Determine the widest/tallest hour string. This code allows for the possibility of ligatures. */
                int dwFlags = ((style & SWT.SHORT) !is 0) ? OS.TIME_NOSECONDS : 0;
                short widest = 0;
                int max = is24HourTime () ? MAX_24HOUR : MAX_12HOUR;
                for (short i = 0; i < max; i++) {
                    systime.wHour = i;
                    int size = OS.GetTimeFormat(OS.LOCALE_USER_DEFAULT, dwFlags, &systime, null, buffer.ptr, cast(int)/*64bit*/buffer.length);
                    if (size is 0) {
                        buffer = new TCHAR[size];
                        OS.GetTimeFormat(OS.LOCALE_USER_DEFAULT, dwFlags, &systime, null, buffer.ptr, cast(int)/*64bit*/buffer.length);
                    }
                    rect.left = rect.top = rect.right = rect.bottom = 0;
                    OS.DrawText (hDC, buffer.ptr, size, &rect, flags);
                    if (rect.right - rect.left > width) {
                        width = rect.right - rect.left;
                        widest = i;
                    }
                    height = Math.max(height, rect.bottom - rect.top);
                }
                systime.wHour = widest;

                /* Determine the widest/tallest minute and second string. */
                width = widest = 0;
                for (short i = 0; i < MAX_MINUTE; i++) {
                    systime.wMinute = i;
                    int size = OS.GetTimeFormat(OS.LOCALE_USER_DEFAULT, dwFlags, &systime, null, buffer.ptr, cast(int)/*64bit*/buffer.length);
                    if (size is 0) {
                        buffer = new TCHAR[size];
                        OS.GetTimeFormat(OS.LOCALE_USER_DEFAULT, dwFlags, &systime, null, buffer.ptr, cast(int)/*64bit*/buffer.length);
                    }
                    rect.left = rect.top = rect.right = rect.bottom = 0;
                    OS.DrawText (hDC, buffer.ptr, size, &rect, flags);
                    if (rect.right - rect.left > width) {
                        width = rect.right - rect.left;
                        widest = i;
                    }
                    height = Math.max(height, rect.bottom - rect.top);
                }
                systime.wMinute = widest;
                systime.wSecond = widest;

                /* Determine the widest/tallest time string for the widest hour, widest minute, and if applicable, widest second. */
                int size = OS.GetTimeFormat(OS.LOCALE_USER_DEFAULT, dwFlags, &systime, null, buffer.ptr, cast(int)/*64bit*/buffer.length);
                if (size is 0) {
                    buffer = new TCHAR[size];
                    OS.GetTimeFormat(OS.LOCALE_USER_DEFAULT, dwFlags, &systime, null, buffer.ptr, cast(int)/*64bit*/buffer.length);
                }
                rect.left = rect.top = rect.right = rect.bottom = 0;
                OS.DrawText (hDC, buffer.ptr, size, &rect, flags);
                width = rect.right - rect.left;
                height = Math.max(height, rect.bottom - rect.top);
            }
            if (newFont !is null) OS.SelectObject (hDC, oldFont);
            OS.ReleaseDC (handle, hDC);
            int upDownWidth = OS.GetSystemMetrics (OS.SM_CXVSCROLL);
            width += upDownWidth + MARGIN;
            int upDownHeight = OS.GetSystemMetrics (OS.SM_CYVSCROLL);
            // TODO: On Vista, can send DTM_GETDATETIMEPICKERINFO to ask the Edit control what its margins are
            if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) upDownHeight += 7;
            height = Math.max (height, upDownHeight);
        }
    }
    if (width is 0) width = DEFAULT_WIDTH;
    if (height is 0) height = DEFAULT_HEIGHT;
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    int border = getBorderWidth ();
    width += border * 2;
    height += border * 2;
    return new Point (width, height);
}

override void createHandle () {
    super.createHandle ();
    state &= ~(CANVAS | THEME_BACKGROUND);

    if ((style & SWT.BORDER) is 0) {
        int bits = OS.GetWindowLong (handle, OS.GWL_EXSTYLE);
        bits &= ~(OS.WS_EX_CLIENTEDGE | OS.WS_EX_STATICEDGE);
        OS.SetWindowLong (handle, OS.GWL_EXSTYLE, bits);
    }
}

override int defaultBackground () {
    return OS.GetSysColor (OS.COLOR_WINDOW);
}

String getComputeSizeString () {
    // TODO: Not currently used but might need for WinCE
    if ((style & SWT.DATE) !is 0) {
        if ((style & SWT.SHORT) !is 0) return getCustomShortDateFormat ();
        if ((style & SWT.MEDIUM) !is 0) return getShortDateFormat ();
        if ((style & SWT.LONG) !is 0) return getLongDateFormat ();
    }
    if ((style & SWT.TIME) !is 0) {
        if ((style & SWT.SHORT) !is 0) return getCustomShortTimeFormat ();
        return getTimeFormat ();
    }
    return "";
}

String getCustomShortDateFormat () {
    if (true) {
        TCHAR[] tchar = new TCHAR[80];
        int size = OS.GetLocaleInfo (OS.LOCALE_USER_DEFAULT, OS.LOCALE_SYEARMONTH, tchar.ptr, 80);
        return size !is 0 ? TCHARsToStr(tchar[0..size - 1])  : "M/yyyy"; //$NON-NLS-1$
    }

    //TODO: Not currently used, but may need for WinCE (or if numeric short date is required)
    String buffer = getShortDateFormat ();
    int length = cast(int)/*64bit*/buffer.length;
    bool inQuotes = false;
    int start = 0, end = 0;
    while (start < length) {
        char ch = buffer.charAt (start);
        if (ch is SINGLE_QUOTE) inQuotes = !inQuotes;
        else if (ch is DAY_FORMAT_CONSTANT && !inQuotes) {
            end = start + 1;
            while (end < length && buffer.charAt (end) is DAY_FORMAT_CONSTANT) end++;
            int ordering = getShortDateFormatOrdering ();
            switch (ordering) {
            case MONTH_DAY_YEAR:
                // skip the following separator
                while (end < length && buffer.charAt (end) !is YEAR_FORMAT_CONSTANT) end++;
                break;
            case DAY_MONTH_YEAR:
                // skip the following separator
                while (end < length && buffer.charAt (end) !is MONTH_FORMAT_CONSTANT) end++;
                break;
            case YEAR_MONTH_DAY:
                // skip the preceding separator
                while (start > 0 && buffer.charAt (start) !is MONTH_FORMAT_CONSTANT) start--;
                break;
            default:
            }
            break;
        }
        start++;
    }
    if (start < end) buffer.length = start - 1;
    return buffer;
}

String getCustomShortTimeFormat () {
    String buffer = getTimeFormat ();
    int length = cast(int)/*64bit*/buffer.length;
    bool inQuotes = false;
    int start = 0, end = 0;
    while (start < length) {
        char ch = buffer.charAt (start);
        if (ch is SINGLE_QUOTE) inQuotes = !inQuotes;
        else if (ch is SECONDS_FORMAT_CONSTANT && !inQuotes) {
            end = start + 1;
            while (end < length && buffer.charAt (end) is SECONDS_FORMAT_CONSTANT) end++;
            // skip the preceding separator
            while (start > 0 && buffer.charAt (start) !is MINUTES_FORMAT_CONSTANT) start--;
            start++;
            break;
        }
        start++;
    }
    if (start < end) buffer.length = start - 1;
    return buffer;
}

String getLongDateFormat () {
    //TODO: Not currently used, but may need for WinCE
    TCHAR[80] tchar;
    int size = OS.GetLocaleInfo (OS.LOCALE_USER_DEFAULT, OS.LOCALE_SLONGDATE, tchar.ptr, 80);
    return size > 0 ? TCHARsToStr(tchar[0..size - 1]) : "dddd, MMMM dd, yyyy"; //$NON-NLS-1$
}

String getShortDateFormat () {
    //TODO: Not currently used, but may need for WinCE
    TCHAR[80] tchar;
    //TODO: May need to OR with LOCALE_ICENTURY
    int size = OS.GetLocaleInfo (OS.LOCALE_USER_DEFAULT, OS.LOCALE_SSHORTDATE, tchar.ptr, 80);
    return size > 0 ? TCHARsToStr(tchar[0..size - 1]) : "M/d/yyyy"; //$NON-NLS-1$
}

int getShortDateFormatOrdering () {
    //TODO: Not currently used, but may need for WinCE
    TCHAR[80] tchar;
    int size = OS.GetLocaleInfo (OS.LOCALE_USER_DEFAULT, OS.LOCALE_IDATE, tchar.ptr, 4);
    if (size > 0) {
        String number = TCHARsToStr(tchar[0..size - 1]);
        return Integer.parseInt (number);
    }
    return 0;
}

String getTimeFormat () {
    TCHAR[80] tchar;
    int size = OS.GetLocaleInfo (OS.LOCALE_USER_DEFAULT, OS.LOCALE_STIMEFORMAT, tchar.ptr, 80);
    return size > 0 ? TCHARsToStr(tchar[0..size - 1]) : "h:mm:ss tt"; //$NON-NLS-1$
}

bool is24HourTime () {
    TCHAR[4] tchar;
    int size = OS.GetLocaleInfo (OS.LOCALE_USER_DEFAULT, OS.LOCALE_ITIME, tchar.ptr, 4);
    if (size > 0) {
        String number = TCHARsToStr(tchar[0..size - 1]);
        return Integer.parseInt (number) !is 0;
    }
    return true;
}

/**
 * Returns the receiver's date, or day of the month.
 * <p>
 * The first day of the month is 1, and the last day depends on the month and year.
 * </p>
 *
 * @return a positive integer beginning with 1
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getDay () {
    checkWidget ();
    SYSTEMTIME systime;
    int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
    OS.SendMessage (handle, msg, 0, &systime);
    return systime.wDay;
}

/**
 * Returns the receiver's hours.
 * <p>
 * Hours is an integer between 0 and 23.
 * </p>
 *
 * @return an integer between 0 and 23
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getHours () {
    checkWidget ();
    if ((style & SWT.CALENDAR) !is 0) return time.wHour;
    SYSTEMTIME systime;
    int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
    OS.SendMessage (handle, msg, 0, &systime);
    return systime.wHour;
}

/**
 * Returns the receiver's minutes.
 * <p>
 * Minutes is an integer between 0 and 59.
 * </p>
 *
 * @return an integer between 0 and 59
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getMinutes () {
    checkWidget ();
    if ((style & SWT.CALENDAR) !is 0) return time.wMinute;
    SYSTEMTIME systime;
    int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
    OS.SendMessage (handle, msg, 0, &systime);
    return systime.wMinute;
}

/**
 * Returns the receiver's month.
 * <p>
 * The first month of the year is 0, and the last month is 11.
 * </p>
 *
 * @return an integer between 0 and 11
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getMonth () {
    checkWidget ();
    SYSTEMTIME systime;
    int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
    OS.SendMessage (handle, msg, 0, &systime);
    return systime.wMonth - 1;
}

override String getNameText () {
    return (style & SWT.TIME) !is 0 ? Format( "{}:{}:{}", getHours(), getMinutes(), getSeconds())
            : Format("{}/{}/{}", (getMonth() + 1), getDay(), getYear());
}

/**
 * Returns the receiver's seconds.
 * <p>
 * Seconds is an integer between 0 and 59.
 * </p>
 *
 * @return an integer between 0 and 59
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSeconds () {
    checkWidget ();
    if ((style & SWT.CALENDAR) !is 0) return time.wSecond;
    SYSTEMTIME systime;
    int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
    OS.SendMessage (handle, msg, 0, &systime);
    return systime.wSecond;
}

/**
 * Returns the receiver's year.
 * <p>
 * The first year is 1752 and the last year is 9999.
 * </p>
 *
 * @return an integer between 1752 and 9999
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getYear () {
    checkWidget ();
    SYSTEMTIME systime;
    int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
    OS.SendMessage (handle, msg, 0, &systime);
    return systime.wYear;
}

override
void releaseWidget () {
    super.releaseWidget ();
    lastSystemTime = null;
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
public void removeSelectionListener (SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Selection, listener);
    eventTable.unhook (SWT.DefaultSelection, listener);
}

/**
 * Sets the receiver's year, month, and day in a single operation.
 * <p>
 * This is the recommended way to set the date, because setting the year,
 * month, and day separately may result in invalid intermediate dates.
 * </p>
 *
 * @param year an integer between 1752 and 9999
 * @param month an integer between 0 and 11
 * @param day a positive integer beginning with 1
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setDate (int year, int month, int day) {
    checkWidget ();
    SYSTEMTIME systime;
    int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
    OS.SendMessage (handle, msg, 0, &systime);
    msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_SETCURSEL : OS.DTM_SETSYSTEMTIME;
    systime.wYear = cast(short)year;
    systime.wMonth = cast(short)(month + 1);
    systime.wDay = cast(short)day;
    OS.SendMessage (handle, msg, 0, &systime);
    lastSystemTime = null;
}

/**
 * Sets the receiver's date, or day of the month, to the specified day.
 * <p>
 * The first day of the month is 1, and the last day depends on the month and year.
 * </p>
 *
 * @param day a positive integer beginning with 1
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setDay (int day) {
    checkWidget ();
    SYSTEMTIME systime;
    int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
    OS.SendMessage (handle, msg, 0, &systime);
    msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_SETCURSEL : OS.DTM_SETSYSTEMTIME;
    systime.wDay = cast(short)day;
    OS.SendMessage (handle, msg, 0, &systime);
    lastSystemTime = null;
}

/**
 * Sets the receiver's hours.
 * <p>
 * Hours is an integer between 0 and 23.
 * </p>
 *
 * @param hours an integer between 0 and 23
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setHours (int hours) {
    checkWidget ();
    SYSTEMTIME systime;
    int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
    OS.SendMessage (handle, msg, 0, &systime);
    msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_SETCURSEL : OS.DTM_SETSYSTEMTIME;
    systime.wHour = cast(short)hours;
    OS.SendMessage (handle, msg, 0, &systime);
    if ((style & SWT.CALENDAR) !is 0 && hours >= 0 && hours <= 23) time.wHour = cast(short)hours;
}

/**
 * Sets the receiver's minutes.
 * <p>
 * Minutes is an integer between 0 and 59.
 * </p>
 *
 * @param minutes an integer between 0 and 59
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMinutes (int minutes) {
    checkWidget ();
    SYSTEMTIME systime;
    int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
    OS.SendMessage (handle, msg, 0, &systime);
    msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_SETCURSEL : OS.DTM_SETSYSTEMTIME;
    systime.wMinute = cast(short)minutes;
    OS.SendMessage (handle, msg, 0, &systime);
    if ((style & SWT.CALENDAR) !is 0 && minutes >= 0 && minutes <= 59) time.wMinute = cast(short)minutes;
}

/**
 * Sets the receiver's month.
 * <p>
 * The first month of the year is 0, and the last month is 11.
 * </p>
 *
 * @param month an integer between 0 and 11
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMonth (int month) {
    checkWidget ();
    SYSTEMTIME systime;
    int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
    OS.SendMessage (handle, msg, 0, &systime);
    msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_SETCURSEL : OS.DTM_SETSYSTEMTIME;
    systime.wMonth = cast(short)(month + 1);
    OS.SendMessage (handle, msg, 0, &systime);
    lastSystemTime = null;
}

/**
 * Sets the receiver's seconds.
 * <p>
 * Seconds is an integer between 0 and 59.
 * </p>
 *
 * @param seconds an integer between 0 and 59
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSeconds (int seconds) {
    checkWidget ();
    SYSTEMTIME systime;
    int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
    OS.SendMessage (handle, msg, 0, &systime);
    msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_SETCURSEL : OS.DTM_SETSYSTEMTIME;
    systime.wSecond = cast(short)seconds;
    OS.SendMessage (handle, msg, 0, &systime);
    if ((style & SWT.CALENDAR) !is 0 && seconds >= 0 && seconds <= 59) time.wSecond = cast(short)seconds;
}

/**
 * Sets the receiver's hours, minutes, and seconds in a single operation.
 *
 * @param hours an integer between 0 and 23
 * @param minutes an integer between 0 and 59
 * @param seconds an integer between 0 and 59
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setTime (int hours, int minutes, int seconds) {
    checkWidget ();
    SYSTEMTIME systime;
    int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
    OS.SendMessage (handle, msg, 0, &systime);
    msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_SETCURSEL : OS.DTM_SETSYSTEMTIME;
    systime.wHour = cast(short)hours;
    systime.wMinute = cast(short)minutes;
    systime.wSecond = cast(short)seconds;
    OS.SendMessage (handle, msg, 0, &systime);
    if ((style & SWT.CALENDAR) !is 0
            && hours >= 0 && hours <= 23
            && minutes >= 0 && minutes <= 59
            && seconds >= 0 && seconds <= 59) {
        time.wHour = cast(short)hours;
        time.wMinute = cast(short)minutes;
        time.wSecond = cast(short)seconds;
    }
}

/**
 * Sets the receiver's year.
 * <p>
 * The first year is 1752 and the last year is 9999.
 * </p>
 *
 * @param year an integer between 1752 and 9999
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setYear (int year) {
    checkWidget ();
    SYSTEMTIME systime;
    int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
    OS.SendMessage (handle, msg, 0, &systime);
    msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_SETCURSEL : OS.DTM_SETSYSTEMTIME;
    systime.wYear = cast(short)year;
    OS.SendMessage (handle, msg, 0, &systime);
    lastSystemTime = null;
}

override int widgetStyle () {
    int bits = super.widgetStyle () | OS.WS_TABSTOP;
    if ((style & SWT.CALENDAR) !is 0) return bits | OS.MCS_NOTODAY;
    /*
    * Bug in Windows: When WS_CLIPCHILDREN is set in a
    * Date and Time Picker, the widget draws on top of
    * the updown control. The fix is to clear the bits.
    */
    bits &= ~OS.WS_CLIPCHILDREN;
    if ((style & SWT.TIME) !is 0) bits |= OS.DTS_TIMEFORMAT;
    if ((style & SWT.DATE) !is 0) bits |= ((style & SWT.MEDIUM) !is 0 ? OS.DTS_SHORTDATECENTURYFORMAT : OS.DTS_LONGDATEFORMAT) | OS.DTS_UPDOWN;
    return bits;
}

override String windowClass () {
    return (style & SWT.CALENDAR) !is 0 ? TCHARsToStr(CalendarClass) : TCHARsToStr(DateTimeClass);
}

override ptrdiff_t windowProc () {
    return (style & SWT.CALENDAR) !is 0 ? cast(ptrdiff_t)CalendarProc : cast(ptrdiff_t)DateTimeProc;
}

override LRESULT wmNotifyChild (NMHDR* hdr, WPARAM wParam, LPARAM lParam) {
    switch (hdr.code) {
        case OS.MCN_SELCHANGE:
        case OS.DTN_DATETIMECHANGE:
            if (ignoreSelection) break;
            SYSTEMTIME systime;
            int msg = (style & SWT.CALENDAR) !is 0 ? OS.MCM_GETCURSEL : OS.DTM_GETSYSTEMTIME;
            OS.SendMessage (handle, msg, 0, &systime);
            if (lastSystemTime is null || systime.wDay !is lastSystemTime.wDay || systime.wMonth !is lastSystemTime.wMonth || systime.wYear !is lastSystemTime.wYear) {
                postEvent (SWT.Selection);
                if ((style & SWT.TIME) is 0) {
                    lastSystemTime = new SYSTEMTIME();
                    *lastSystemTime = systime;
                }
            }
            break;
        default:
    }
    return super.wmNotifyChild (hdr, wParam, lParam);
}

override
LRESULT WM_TIMER (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_TIMER (wParam, lParam);
    if (result !is null) return result;
    /*
    * Feature in Windows. For some reason, Windows sends WM_NOTIFY with
    * MCN_SELCHANGE at regular intervals. This is unexpected. The fix is
    * to ignore MCN_SELCHANGE during WM_TIMER.
    */
    ignoreSelection = true;
    auto code = callWindowProc(handle, OS.WM_TIMER, wParam, lParam);
    ignoreSelection = false;
    return code is 0 ? LRESULT.ZERO : new LRESULT(code);
}
}

