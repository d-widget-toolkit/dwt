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
module org.eclipse.swt.widgets.Spinner;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.VerifyListener;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;

/**
 * Instances of this class are selectable user interface
 * objects that allow the user to enter and modify numeric
 * values.
 * <p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add children to it, or set a layout on it.
 * </p><p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>READ_ONLY, WRAP</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection, Modify, Verify</dd>
 * </dl>
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#spinner">Spinner snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.1
 */
public class Spinner : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.sendKeyEvent sendKeyEvent;
    alias Composite.setBackgroundImage setBackgroundImage;
    alias Composite.setToolTipText setToolTipText;
    alias Composite.windowProc windowProc;

    HWND hwndText, hwndUpDown;
    bool ignoreModify;
    int pageIncrement, digits;
    mixin(gshared!(`static /+const+/ WNDPROC EditProc;`));
    static const TCHAR[] EditClass = "EDIT";
    mixin(gshared!(`static /+const+/ WNDPROC UpDownProc;`));
    mixin(gshared!(`static const TCHAR[] UpDownClass = OS.UPDOWN_CLASS;`));

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
            OS.GetClassInfo (null, EditClass.ptr, &lpWndClass);
            EditProc = lpWndClass.lpfnWndProc;
            OS.GetClassInfo (null, UpDownClass.ptr, &lpWndClass);
            UpDownProc = lpWndClass.lpfnWndProc;
            static_this_completed = true;
        }
    }
    /**
     * the operating system limit for the number of characters
     * that the text field in an instance of this class can hold
     *
     * @since 3.4
     */
     mixin(gshared!(`public static int LIMIT;`));

    /*
     * These values can be different on different platforms.
     * Therefore they are not initialized in the declaration
     * to stop the compiler from inlining.
     */
    mixin(sharedStaticThis!(`{
        LIMIT = OS.IsWinNT ? 0x7FFFFFFF : 0x7FFF;
    }`));

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
 * @see SWT#READ_ONLY
 * @see SWT#WRAP
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    static_this();
    super (parent, checkStyle (style));
}

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    if (hwnd is hwndText) {
        return OS.CallWindowProc (EditProc, hwnd, msg, wParam, lParam);
    }
    if (hwnd is hwndUpDown) {
        return OS.CallWindowProc (UpDownProc, hwnd, msg, wParam, lParam);
    }
    return OS.DefWindowProc (handle, msg, wParam, lParam);
}

static int checkStyle (int style) {
    /*
    * Even though it is legal to create this widget
    * with scroll bars, they serve no useful purpose
    * because they do not automatically scroll the
    * widget's client area.  The fix is to clear
    * the SWT style.
    */
    return style & ~(SWT.H_SCROLL | SWT.V_SCROLL);
}

override bool checkHandle (HWND hwnd) {
    return hwnd is handle || hwnd is hwndText || hwnd is hwndUpDown;
}

override protected void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

override void createHandle () {
    super.createHandle ();
    state &= ~(CANVAS | THEME_BACKGROUND);
    auto hInstance = OS.GetModuleHandle (null);
    int textExStyle = (style & SWT.BORDER) !is 0 ? OS.WS_EX_CLIENTEDGE : 0;
    int textStyle = OS.WS_CHILD | OS.WS_VISIBLE | OS.ES_AUTOHSCROLL | OS.WS_CLIPSIBLINGS;
    if ((style & SWT.READ_ONLY) !is 0) textStyle |= OS.ES_READONLY;
    if (OS.WIN32_VERSION >= OS.VERSION (4, 10)) {
        if ((style & SWT.RIGHT_TO_LEFT) !is 0) textExStyle |= OS.WS_EX_LAYOUTRTL;
    }
    hwndText = OS.CreateWindowEx (
        textExStyle,
        EditClass.ptr,
        null,
        textStyle,
        0, 0, 0, 0,
        handle,
        null,
        hInstance,
        null);
    if (hwndText is null) error (SWT.ERROR_NO_HANDLES);
    OS.SetWindowLongPtr (hwndText, OS.GWLP_ID, cast(LONG_PTR)hwndText);
    int upDownStyle = OS.WS_CHILD | OS.WS_VISIBLE | OS.UDS_AUTOBUDDY;
    if ((style & SWT.WRAP) !is 0) upDownStyle |= OS.UDS_WRAP;
    if ((style & SWT.BORDER) !is 0) {
        if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
            upDownStyle |= OS.UDS_ALIGNLEFT;
        } else {
            upDownStyle |= OS.UDS_ALIGNRIGHT;
        }
    }
    hwndUpDown = OS.CreateWindowEx (
        0,
        UpDownClass.ptr,
        null,
        upDownStyle,
        0, 0, 0, 0,
        handle,
        null,
        hInstance,
        null);
    if (hwndUpDown is null) error (SWT.ERROR_NO_HANDLES);
    int flags = OS.SWP_NOSIZE | OS.SWP_NOMOVE | OS.SWP_NOACTIVATE;
    SetWindowPos (hwndText, hwndUpDown, 0, 0, 0, 0, flags);
    OS.SetWindowLongPtr (hwndUpDown, OS.GWLP_ID, cast(LONG_PTR)hwndUpDown);
    if (OS.IsDBLocale) {
        auto hIMC = OS.ImmGetContext (handle);
        OS.ImmAssociateContext (hwndText, hIMC);
        OS.ImmAssociateContext (hwndUpDown, hIMC);
        OS.ImmReleaseContext (handle, hIMC);
    }
    OS.SendMessage (hwndUpDown, OS.UDM_SETRANGE32, 0, 100);
    OS.SendMessage (hwndUpDown, OS.IsWinCE ? OS.UDM_SETPOS : OS.UDM_SETPOS32, 0, 0);
    pageIncrement = 10;
    digits = 0;
    LPCTSTR buffer = StrToTCHARz (getCodePage (), "0");
    OS.SetWindowText (hwndText, buffer);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the receiver's text is modified, by sending
 * it one of the messages defined in the <code>ModifyListener</code>
 * interface.
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
 * @see ModifyListener
 * @see #removeModifyListener
 */
public void addModifyListener (ModifyListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Modify, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is not called for texts.
 * <code>widgetDefaultSelected</code> is typically called when ENTER is pressed in a single-line text.
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
public void addSelectionListener(SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the receiver's text is verified, by sending
 * it one of the messages defined in the <code>VerifyListener</code>
 * interface.
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
 * @see VerifyListener
 * @see #removeVerifyListener
 */
void addVerifyListener (VerifyListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Verify, typedListener);
}

override HWND borderHandle () {
    return hwndText;
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = 0, height = 0;
    if (wHint is SWT.DEFAULT || hHint is SWT.DEFAULT) {
        HFONT newFont, oldFont;
        auto hDC = OS.GetDC (hwndText);
        newFont = cast(HFONT) OS.SendMessage (hwndText, OS.WM_GETFONT, 0, 0);
        if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
        TEXTMETRIC tm;
        OS.GetTextMetrics (hDC, &tm);
        height = tm.tmHeight;
        RECT rect;
        int max;
        OS.SendMessage (hwndUpDown , OS.UDM_GETRANGE32, null, &max);
        String string = String_valueOf( max );
        if (digits > 0) {
            StringBuffer buffer = new StringBuffer ();
            buffer.append (string);
            buffer.append (getDecimalSeparator ());
            int count = digits - cast(int)/*64bit*/string.length;
            while (count >= 0) {
                buffer.append ("0");
                count--;
            }
            string = buffer.toString ();
        }
        StringT buffer = StrToTCHARs (getCodePage (), string, false);
        int flags = OS.DT_CALCRECT | OS.DT_EDITCONTROL | OS.DT_NOPREFIX;
        OS.DrawText (hDC, buffer.ptr, cast(int)/*64bit*/buffer.length, &rect, flags);
        width = rect.right - rect.left;
        if (newFont !is null ) OS.SelectObject (hDC, oldFont);
        OS.ReleaseDC (hwndText, hDC);
    }
    if (width is 0) width = DEFAULT_WIDTH;
    if (height is 0) height = DEFAULT_HEIGHT;
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    Rectangle trim = computeTrim (0, 0, width, height);
    if (hHint is SWT.DEFAULT) {
        int upDownHeight = OS.GetSystemMetrics (OS.SM_CYVSCROLL) + 2 * getBorderWidth ();
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
            upDownHeight += (style & SWT.BORDER) !is 0 ? 1 : 3;
        }
        trim.height = Math.max (trim.height, upDownHeight);
    }
    return new Point (trim.width, trim.height);
}

override public Rectangle computeTrim (int x, int y, int width, int height) {
    checkWidget ();

    /* Get the trim of the text control */
    RECT rect;
    OS.SetRect (&rect, x, y, x + width, y + height);
    int bits0 = OS.GetWindowLong (hwndText, OS.GWL_STYLE);
    int bits1 = OS.GetWindowLong (hwndText, OS.GWL_EXSTYLE);
    OS.AdjustWindowRectEx (&rect, bits0, false, bits1);
    width = rect.right - rect.left;
    height = rect.bottom - rect.top;

    /*
    * The preferred height of a single-line text widget
    * has been hand-crafted to be the same height as
    * the single-line text widget in an editable combo
    * box.
    */
    auto margins = OS.SendMessage (hwndText, OS.EM_GETMARGINS, 0, 0);
    x -= OS.LOWORD (margins);
    width += OS.LOWORD (margins) + OS.HIWORD (margins);
    if ((style & SWT.BORDER) !is 0) {
        x -= 1;
        y -= 1;
        width += 2;
        height += 2;
    }
    width += OS.GetSystemMetrics (OS.SM_CXVSCROLL);
    return new Rectangle (x, y, width, height);
}

/**
 * Copies the selected text.
 * <p>
 * The current selection is copied to the clipboard.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void copy () {
    checkWidget ();
    OS.SendMessage (hwndText, OS.WM_COPY, 0, 0);
}

/**
 * Cuts the selected text.
 * <p>
 * The current selection is first copied to the
 * clipboard and then deleted from the widget.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void cut () {
    checkWidget ();
    if ((style & SWT.READ_ONLY) !is 0) return;
    OS.SendMessage (hwndText, OS.WM_CUT, 0, 0);
}

override int defaultBackground () {
    return OS.GetSysColor (OS.COLOR_WINDOW);
}

override void enableWidget (bool enabled) {
    super.enableWidget (enabled);
    OS.EnableWindow (hwndText, enabled);
    OS.EnableWindow (hwndUpDown, enabled);
}

override void deregister () {
    super.deregister ();
    display.removeControl (hwndText);
    display.removeControl (hwndUpDown);
}

override bool hasFocus () {
    auto hwndFocus = OS.GetFocus ();
    if (hwndFocus is handle) return true;
    if (hwndFocus is hwndText) return true;
    if (hwndFocus is hwndUpDown) return true;
    return false;
}

/**
 * Returns the number of decimal places used by the receiver.
 *
 * @return the digits
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getDigits () {
    checkWidget ();
    return digits;
}

String getDecimalSeparator () {
    TCHAR[] tchar = NewTCHARs (getCodePage (), 4);
    int size = OS.GetLocaleInfo (OS.LOCALE_USER_DEFAULT, OS.LOCALE_SDECIMAL, tchar.ptr, 4);
    return size !is 0 ? TCHARsToStr( tchar[0 .. size-1] ) : ".";
}

/**
 * Returns the amount that the receiver's value will be
 * modified by when the up/down arrows are pressed.
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
    UDACCEL udaccel;
    OS.SendMessage (hwndUpDown, OS.UDM_GETACCEL, 1, &udaccel);
    return udaccel.nInc;
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
    int max;
    OS.SendMessage (hwndUpDown , OS.UDM_GETRANGE32, null, &max);
    return max;
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
    int min;
    OS.SendMessage (hwndUpDown , OS.UDM_GETRANGE32, &min, null);
    return min;
}

/**
 * Returns the amount that the receiver's position will be
 * modified by when the page up/down keys are pressed.
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
    return pageIncrement;
}

/**
 * Returns the <em>selection</em>, which is the receiver's position.
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
    static if (OS.IsWinCE) {
        return OS.LOWORD (OS.SendMessage (hwndUpDown, OS.UDM_GETPOS, 0, 0));
    } else {
        return cast(int)/*64bit*/OS.SendMessage (hwndUpDown, OS.UDM_GETPOS32, 0, 0);
    }
}

int getSelectionText (bool [] parseFail) {
    int length_ = OS.GetWindowTextLength (hwndText);
    TCHAR[] buffer = NewTCHARs (getCodePage (), length_ + 1);
    OS.GetWindowText (hwndText, buffer.ptr, length_ + 1);
    String string = TCHARsToStr( buffer[ 0 .. length_] );
    try {
        int value;
        if (digits > 0) {
            String decimalSeparator = getDecimalSeparator ();
            int index = string.indexOf (decimalSeparator);
            if (index !is -1)  {
                int startIndex = string.startsWith ("+") || string.startsWith ("-") ? 1 : 0;
                String wholePart = startIndex !is index ? string.substring (startIndex, index) : "0";
                String decimalPart = string.substring (index + 1);
                if (decimalPart.length > digits) {
                    decimalPart = decimalPart.substring (0, digits);
                } else {
                    int i = digits - cast(int)/*64bit*/decimalPart.length;
                    for (int j = 0; j < i; j++) {
                        decimalPart = decimalPart ~ "0";
                    }
                }
                int wholeValue = Integer.parseInt (wholePart);
                int decimalValue = Integer.parseInt (decimalPart);
                for (int i = 0; i < digits; i++) wholeValue *= 10;
                value = wholeValue + decimalValue;
                if (string.startsWith ("-")) value = -value;
            } else {
                value = Integer.parseInt (string);
                for (int i = 0; i < digits; i++) value *= 10;
            }
        } else {
            value = Integer.parseInt (string);
        }
        int max, min;
        OS.SendMessage (hwndUpDown , OS.UDM_GETRANGE32, &min, &max);
        if (min <= value && value <= max) return value;
    } catch (NumberFormatException e) {
    }
    parseFail [0] = true;
    return -1;
}

/**
 * Returns a string containing a copy of the contents of the
 * receiver's text field, or an empty string if there are no
 * contents.
 *
 * @return the receiver's text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public String getText () {
    checkWidget ();
    int length_ = OS.GetWindowTextLength (hwndText);
    if (length_ is 0) return "";
    TCHAR[] buffer = NewTCHARs (getCodePage (), length_ + 1);
    OS.GetWindowText (hwndText, buffer.ptr, length_ + 1);
    return TCHARsToStr( buffer[0 .. length_] );
}

/**
 * Returns the maximum number of characters that the receiver's
 * text field is capable of holding. If this has not been changed
 * by <code>setTextLimit()</code>, it will be the constant
 * <code>Spinner.LIMIT</code>.
 *
 * @return the text limit
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #LIMIT
 *
 * @since 3.4
 */
public int getTextLimit () {
    checkWidget ();
    return OS.SendMessage (hwndText, OS.EM_GETLIMITTEXT, 0, 0) & 0x7FFFFFFF;
}

int mbcsToWcsPos (int mbcsPos) {
    if (mbcsPos <= 0) return 0;
    if (OS.IsUnicode) return mbcsPos;
    int mbcsSize = OS.GetWindowTextLengthA (hwndText);
    if (mbcsSize is 0) return 0;
    if (mbcsPos >= mbcsSize) return mbcsSize;
    CHAR [] buffer = new CHAR [mbcsSize + 1];
    OS.GetWindowTextA (hwndText, buffer.ptr, mbcsSize + 1);
    return OS.MultiByteToWideChar (getCodePage (), OS.MB_PRECOMPOSED, buffer.ptr, mbcsPos, null, 0);
}

/**
 * Pastes text from clipboard.
 * <p>
 * The selected text is deleted from the widget
 * and new text inserted from the clipboard.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void paste () {
    checkWidget ();
    if ((style & SWT.READ_ONLY) !is 0) return;
    OS.SendMessage (hwndText, OS.WM_PASTE, 0, 0);
}

override void register () {
    super.register ();
    display.addControl (hwndText, this);
    display.addControl (hwndUpDown, this);
}

override void releaseHandle () {
    super.releaseHandle ();
    hwndText = hwndUpDown = null;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the receiver's text is modified.
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
 * @see ModifyListener
 * @see #addModifyListener
 */
public void removeModifyListener (ModifyListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Modify, listener);
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

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control is verified.
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
 * @see VerifyListener
 * @see #addVerifyListener
 */
void removeVerifyListener (VerifyListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Verify, listener);
}

override bool sendKeyEvent (int type, int msg, WPARAM wParam, LPARAM lParam, Event event) {
    if (!super.sendKeyEvent (type, msg, wParam, lParam, event)) {
        return false;
    }
    if ((style & SWT.READ_ONLY) !is 0) return true;
    if (type !is SWT.KeyDown) return true;
    if (msg !is OS.WM_CHAR && msg !is OS.WM_KEYDOWN && msg !is OS.WM_IME_CHAR) {
        return true;
    }
    if (event.character is 0) return true;
//  if (!hooks (SWT.Verify) && !filters (SWT.Verify)) return true;
    char key = cast(char) event.character;
    int stateMask = event.stateMask;

    /*
    * Disable all magic keys that could modify the text
    * and don't send events when Alt, Shift or Ctrl is
    * pressed.
    */
    switch (msg) {
        case OS.WM_CHAR:
            if (key !is 0x08 && key !is 0x7F && key !is '\r' && key !is '\t' && key !is '\n') break;
            goto case OS.WM_KEYDOWN;
        case OS.WM_KEYDOWN:
            if ((stateMask & (SWT.ALT | SWT.SHIFT | SWT.CONTROL)) !is 0) return false;
            break;
        default:
    }

    /*
    * If the left button is down, the text widget refuses the character.
    */
    if (OS.GetKeyState (OS.VK_LBUTTON) < 0) {
        return true;
    }

    /* Verify the character */
    String oldText = "";
    int start, end;
    OS.SendMessage (hwndText, OS.EM_GETSEL, &start, &end);
    switch (key) {
        case 0x08:  /* Bs */
            if (start is end) {
                if (start is 0) return true;
                start = start - 1;
                if (!OS.IsUnicode && OS.IsDBLocale) {
                    int newStart, newEnd;
                    OS.SendMessage (hwndText, OS.EM_SETSEL, start, end);
                    OS.SendMessage (hwndText, OS.EM_GETSEL, &newStart, &newEnd);
                    if (start !is newStart) start = start - 1;
                }
                start = Math.max (start, 0);
            }
            break;
        case 0x7F:  /* Del */
            if (start is end) {
                int length_ = OS.GetWindowTextLength (hwndText);
                if (start is length_) return true;
                end = end + 1;
                if (!OS.IsUnicode && OS.IsDBLocale) {
                    int newStart, newEnd;
                    OS.SendMessage (hwndText, OS.EM_SETSEL, start, end);
                    OS.SendMessage (hwndText, OS.EM_GETSEL, &newStart, &newEnd);
                    if (end !is newEnd) end = end + 1;
                }
                end = Math.min (end, length_);
            }
            break;
        case '\r':  /* Return */
            return true;
        default:    /* Tab and other characters */
            if (key !is '\t' && key < 0x20) return true;
            oldText = [key];
            break;
    }
    String newText = verifyText (oldText, start, end, event);
    if (newText is null) return false;
    if (newText is oldText) return true;
    LPCTSTR buffer = StrToTCHARz (getCodePage (), newText);
    OS.SendMessage (hwndText, OS.EM_SETSEL, start, end);
    OS.SendMessage (hwndText, OS.EM_REPLACESEL, 0, cast(void*)buffer);
    return false;
}

override void setBackgroundImage (HBITMAP hBitmap) {
    super.setBackgroundImage (hBitmap);
    OS.InvalidateRect (hwndText, null, true);
}

override void setBackgroundPixel (int pixel) {
    super.setBackgroundPixel (pixel);
    OS.InvalidateRect (hwndText, null, true);
}

/**
 * Sets the number of decimal places used by the receiver.
 * <p>
 * The digit setting is used to allow for floating point values in the receiver.
 * For example, to set the selection to a floating point value of 1.37 call setDigits() with
 * a value of 2 and setSelection() with a value of 137. Similarly, if getDigits() has a value
 * of 2 and getSelection() returns 137 this should be interpreted as 1.37. This applies to all
 * numeric APIs.
 * </p>
 *
 * @param value the new digits (must be greater than or equal to zero)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the value is less than zero</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setDigits (int value) {
    checkWidget ();
    if (value < 0) error (SWT.ERROR_INVALID_ARGUMENT);
    if (value is this.digits) return;
    this.digits = value;
    int pos;
    static if (OS.IsWinCE) {
        pos = OS.LOWORD (OS.SendMessage (hwndUpDown, OS.UDM_GETPOS, 0, 0));
    } else {
        pos = cast(int)/*64bit*/OS.SendMessage (hwndUpDown, OS.UDM_GETPOS32, 0, 0);
    }
    setSelection (pos, false, true, false);
}

override void setForegroundPixel (int pixel) {
    super.setForegroundPixel (pixel);
    OS.InvalidateRect (hwndText, null, true);
}

/**
 * Sets the amount that the receiver's value will be
 * modified by when the up/down arrows are pressed to
 * the argument, which must be at least one.
 *
 * @param value the new increment (must be greater than zero)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setIncrement (int value) {
    checkWidget ();
    if (value < 1) return;
    auto hHeap = OS.GetProcessHeap ();
    auto count = OS.SendMessage (hwndUpDown, OS.UDM_GETACCEL, 0, cast(UDACCEL*)null);
    auto udaccels = cast(UDACCEL*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, UDACCEL.sizeof * count);
    OS.SendMessage (hwndUpDown, OS.UDM_GETACCEL, count, udaccels);
    int first = -1;
    UDACCEL udaccel;
    for (int i = 0; i < count; i++) {
        void* offset = udaccels + i;
        OS.MoveMemory (&udaccel, offset, UDACCEL.sizeof);
        if (first is -1) first = udaccel.nInc;
        udaccel.nInc  =  udaccel.nInc * value / first;
        OS.MoveMemory (offset, &udaccel, UDACCEL.sizeof);
    }
    OS.SendMessage (hwndUpDown, OS.UDM_SETACCEL, count, udaccels);
    OS.HeapFree (hHeap, 0, udaccels);
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
    int min;
    OS.SendMessage (hwndUpDown , OS.UDM_GETRANGE32, &min, null);
    if (value <= min) return;
    .LRESULT pos;
    static if (OS.IsWinCE) {
        pos = OS.LOWORD (OS.SendMessage (hwndUpDown, OS.UDM_GETPOS, 0, 0));
    } else {
        pos = OS.SendMessage (hwndUpDown, OS.UDM_GETPOS32, 0, 0);
    }
    OS.SendMessage (hwndUpDown , OS.UDM_SETRANGE32, min, value);
    if (pos > value) setSelection (value, true, true, false);
}

/**
 * Sets the minimum value that the receiver will allow.  This new
 * value will be ignored if it is not less than the receiver's
 * current maximum value.  If the new minimum is applied then the receiver's
 * selection value will be adjusted if necessary to fall within its new range.
 *
 * @param value the new minimum, which must be less than the current maximum
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMinimum (int value) {
    checkWidget ();
    int max;
    OS.SendMessage (hwndUpDown , OS.UDM_GETRANGE32, null, &max);
    if (value >= max) return;
    .LRESULT pos;
    static if (OS.IsWinCE) {
        pos = OS.LOWORD (OS.SendMessage (hwndUpDown, OS.UDM_GETPOS, 0, 0));
    } else {
        pos = OS.SendMessage (hwndUpDown, OS.UDM_GETPOS32, 0, 0);
    }
    OS.SendMessage (hwndUpDown , OS.UDM_SETRANGE32, value, max);
    if (pos < value) setSelection (value, true, true, false);
}

/**
 * Sets the amount that the receiver's position will be
 * modified by when the page up/down keys are pressed
 * to the argument, which must be at least one.
 *
 * @param value the page increment (must be greater than zero)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setPageIncrement (int value) {
    checkWidget ();
    if (value < 1) return;
    pageIncrement = value;
}

/**
 * Sets the <em>selection</em>, which is the receiver's
 * position, to the argument. If the argument is not within
 * the range specified by minimum and maximum, it will be
 * adjusted to fall within this range.
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
    int max, min;
    OS.SendMessage (hwndUpDown , OS.UDM_GETRANGE32, &min, &max);
    value = Math.min (Math.max (min, value), max );
    setSelection (value, true, true, false);
}

void setSelection (int value, bool setPos, bool setText, bool notify) {
    if (setPos) {
        OS.SendMessage (hwndUpDown , OS.IsWinCE ? OS.UDM_SETPOS : OS.UDM_SETPOS32, 0, value);
    }
    if (setText) {
        String string;
        if (digits is 0) {
            string = String_valueOf (value);
        } else {
            string = String_valueOf(Math.abs (value));
            String decimalSeparator = getDecimalSeparator ();
            int index = cast(int)/*64bit*/string.length - digits;
            StringBuffer buffer = new StringBuffer ();
            if (value < 0) buffer.append ("-");
            if (index > 0) {
                buffer.append (string.substring (0, index));
                buffer.append (decimalSeparator);
                buffer.append (string.substring (index));
            } else {
                buffer.append ("0");
                buffer.append (decimalSeparator);
                while (index++ < 0) buffer.append ("0");
                buffer.append (string);
            }
            string = buffer.toString ();
        }
        if (hooks (SWT.Verify) || filters (SWT.Verify)) {
            int length_ = OS.GetWindowTextLength (hwndText);
            string = verifyText (string, 0, length_, null);
            if (string is null) return;
        }
        LPCTSTR buffer = StrToTCHARz (getCodePage (), string);
        OS.SetWindowText (hwndText, buffer);
        OS.SendMessage (hwndText, OS.EM_SETSEL, 0, -1);
        if (!OS.IsWinCE) {
            OS.NotifyWinEvent (OS.EVENT_OBJECT_FOCUS, hwndText, OS.OBJID_CLIENT, 0);
        }
    }
    if (notify) postEvent (SWT.Selection);
}

/**
 * Sets the maximum number of characters that the receiver's
 * text field is capable of holding to be the argument.
 * <p>
 * To reset this value to the default, use <code>setTextLimit(Spinner.LIMIT)</code>.
 * Specifying a limit value larger than <code>Spinner.LIMIT</code> sets the
 * receiver's limit to <code>Spinner.LIMIT</code>.
 * </p>
 * @param limit new text limit
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_CANNOT_BE_ZERO - if the limit is zero</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #LIMIT
 *
 * @since 3.4
 */
public void setTextLimit (int limit) {
    checkWidget ();
    if (limit is 0) error (SWT.ERROR_CANNOT_BE_ZERO);
    OS.SendMessage (hwndText, OS.EM_SETLIMITTEXT, limit, 0);
}

override void setToolTipText (Shell shell, String string) {
    shell.setToolTipText (hwndText, string);
    shell.setToolTipText (hwndUpDown, string);
}

/**
 * Sets the receiver's selection, minimum value, maximum
 * value, digits, increment and page increment all at once.
 * <p>
 * Note: This is similar to setting the values individually
 * using the appropriate methods, but may be implemented in a
 * more efficient fashion on some platforms.
 * </p>
 *
 * @param selection the new selection value
 * @param minimum the new minimum value
 * @param maximum the new maximum value
 * @param digits the new digits value
 * @param increment the new increment value
 * @param pageIncrement the new pageIncrement value
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setValues (int selection, int minimum, int maximum, int digits, int increment, int pageIncrement) {
    checkWidget ();
    if (maximum <= minimum) return;
    if (digits < 0) return;
    if (increment < 1) return;
    if (pageIncrement < 1) return;
    selection = Math.min (Math.max (minimum, selection), maximum);
    setIncrement (increment);
    this.pageIncrement = pageIncrement;
    this.digits = digits;
    OS.SendMessage (hwndUpDown , OS.UDM_SETRANGE32, minimum, maximum);
    setSelection (selection, true, true, false);
}

override void subclass () {
    super.subclass ();
    auto newProc = display.windowProc;
    OS.SetWindowLongPtr (hwndText, OS.GWLP_WNDPROC, newProc);
    OS.SetWindowLongPtr (hwndUpDown, OS.GWLP_WNDPROC, newProc);
}

override void unsubclass () {
    super.unsubclass ();
    OS.SetWindowLongPtr (hwndText, OS.GWLP_WNDPROC, cast(LONG_PTR)EditProc);
    OS.SetWindowLongPtr (hwndUpDown, OS.GWLP_WNDPROC, cast(LONG_PTR)UpDownProc);
}

String verifyText (String string, int start, int end, Event keyEvent) {
    Event event = new Event ();
    event.text = string;
    event.start = start;
    event.end = end;
    if (keyEvent !is null) {
        event.character = keyEvent.character;
        event.keyCode = keyEvent.keyCode;
        event.stateMask = keyEvent.stateMask;
    }
    int index = 0;
    if (digits > 0) {
        String decimalSeparator = getDecimalSeparator ();
        index = string.indexOf (decimalSeparator);
        if (index !is -1) {
            string = string.substring (0, index) ~ string.substring (index + 1);
        }
        index = 0;
    }
    if (string.length > 0) {
        int min;
        OS.SendMessage (hwndUpDown , OS.UDM_GETRANGE32, &min, null);
        if (min < 0 && string.charAt (0) is '-') index++;
    }
    while (index < string.length ) {
        if (!CharacterIsDigit (string.charAt (index))) break;
        index++;
    }
    event.doit = index is string.length ;
    if (!OS.IsUnicode && OS.IsDBLocale) {
        event.start = mbcsToWcsPos (start);
        event.end = mbcsToWcsPos (end);
    }
    sendEvent (SWT.Verify, event);
    if (!event.doit || isDisposed ()) return null;
    return event.text;
}

override int widgetExtStyle () {
    return super.widgetExtStyle () & ~OS.WS_EX_CLIENTEDGE;
}

override .LRESULT windowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (hwnd is hwndText || hwnd is hwndUpDown) {
        LRESULT result = null;
        switch (msg) {
            /* Keyboard messages */
            case OS.WM_CHAR:        result = wmChar (hwnd, wParam, lParam); break;
            case OS.WM_IME_CHAR:    result = wmIMEChar (hwnd, wParam, lParam); break;
            case OS.WM_KEYDOWN:     result = wmKeyDown (hwnd, wParam, lParam); break;
            case OS.WM_KEYUP:       result = wmKeyUp (hwnd, wParam, lParam); break;
            case OS.WM_SYSCHAR:     result = wmSysChar (hwnd, wParam, lParam); break;
            case OS.WM_SYSKEYDOWN:  result = wmSysKeyDown (hwnd, wParam, lParam); break;
            case OS.WM_SYSKEYUP:    result = wmSysKeyUp (hwnd, wParam, lParam); break;

            /* Mouse Messages */
            case OS.WM_CAPTURECHANGED:  result = wmCaptureChanged (hwnd, wParam, lParam); break;
            case OS.WM_LBUTTONDBLCLK:   result = wmLButtonDblClk (hwnd, wParam, lParam); break;
            case OS.WM_LBUTTONDOWN:     result = wmLButtonDown (hwnd, wParam, lParam); break;
            case OS.WM_LBUTTONUP:       result = wmLButtonUp (hwnd, wParam, lParam); break;
            case OS.WM_MBUTTONDBLCLK:   result = wmMButtonDblClk (hwnd, wParam, lParam); break;
            case OS.WM_MBUTTONDOWN:     result = wmMButtonDown (hwnd, wParam, lParam); break;
            case OS.WM_MBUTTONUP:       result = wmMButtonUp (hwnd, wParam, lParam); break;
            case OS.WM_MOUSEHOVER:      result = wmMouseHover (hwnd, wParam, lParam); break;
            case OS.WM_MOUSELEAVE:      result = wmMouseLeave (hwnd, wParam, lParam); break;
            case OS.WM_MOUSEMOVE:       result = wmMouseMove (hwnd, wParam, lParam); break;
//          case OS.WM_MOUSEWHEEL:      result = wmMouseWheel (hwnd, wParam, lParam); break;
            case OS.WM_RBUTTONDBLCLK:   result = wmRButtonDblClk (hwnd, wParam, lParam); break;
            case OS.WM_RBUTTONDOWN:     result = wmRButtonDown (hwnd, wParam, lParam); break;
            case OS.WM_RBUTTONUP:       result = wmRButtonUp (hwnd, wParam, lParam); break;
            case OS.WM_XBUTTONDBLCLK:   result = wmXButtonDblClk (hwnd, wParam, lParam); break;
            case OS.WM_XBUTTONDOWN:     result = wmXButtonDown (hwnd, wParam, lParam); break;
            case OS.WM_XBUTTONUP:       result = wmXButtonUp (hwnd, wParam, lParam); break;

            /* Focus Messages */
            case OS.WM_SETFOCUS:        result = wmSetFocus (hwnd, wParam, lParam); break;
            case OS.WM_KILLFOCUS:       result = wmKillFocus (hwnd, wParam, lParam); break;

            /* Paint messages */
            case OS.WM_PAINT:           result = wmPaint (hwnd, wParam, lParam); break;
            case OS.WM_PRINT:           result = wmPrint (hwnd, wParam, lParam); break;

            /* Menu messages */
            case OS.WM_CONTEXTMENU:     result = wmContextMenu (hwnd, wParam, lParam); break;

            /* Clipboard messages */
            case OS.WM_CLEAR:
            case OS.WM_CUT:
            case OS.WM_PASTE:
            case OS.WM_UNDO:
            case OS.EM_UNDO:
                if (hwnd is hwndText) {
                    result = wmClipboard (hwnd, msg, wParam, lParam);
                }
                break;
            default:
        }
        if (result !is null) return result.value;
        return callWindowProc (hwnd, msg, wParam, lParam);
    }
    return super.windowProc (hwnd, msg, wParam, lParam);
}

override LRESULT WM_ERASEBKGND (WPARAM wParam, LPARAM lParam) {
    super.WM_ERASEBKGND (wParam, lParam);
    drawBackground (cast(HANDLE)wParam);
    return LRESULT.ONE;
}

override LRESULT WM_KILLFOCUS (WPARAM wParam, LPARAM lParam) {
    return null;
}

override LRESULT WM_SETFOCUS (WPARAM wParam, LPARAM lParam) {
    OS.SetFocus (hwndText);
    OS.SendMessage (hwndText, OS.EM_SETSEL, 0, -1);
    return null;
}

override LRESULT WM_SETFONT (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SETFONT (wParam, lParam);
    if (result !is null) return result;
    OS.SendMessage (hwndText, OS.WM_SETFONT, wParam, lParam);
    return result;
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SIZE (wParam, lParam);
    if (isDisposed ()) return result;
    int width = OS.LOWORD (lParam), height = OS.HIWORD (lParam);
    int upDownWidth = OS.GetSystemMetrics (OS.SM_CXVSCROLL);
    int textWidth = width - upDownWidth;
    int border = OS.GetSystemMetrics (OS.SM_CXEDGE);
    int flags = OS.SWP_NOZORDER | OS.SWP_DRAWFRAME | OS.SWP_NOACTIVATE;
    SetWindowPos (hwndText, null, 0, 0, textWidth + border, height, flags);
    SetWindowPos (hwndUpDown, null, textWidth, 0, upDownWidth, height, flags);
    return result;
}

override LRESULT wmChar (HWND hwnd, WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.wmChar (hwnd, wParam, lParam);
    if (result !is null) return result;
    /*
    * Feature in Windows.  For some reason, when the
    * widget is a single line text widget, when the
    * user presses tab, return or escape, Windows beeps.
    * The fix is to look for these keys and not call
    * the window proc.
    */
    switch (wParam) {
        case SWT.CR:
            postEvent (SWT.DefaultSelection);
            goto case SWT.TAB;
        case SWT.TAB:
        case SWT.ESC: return LRESULT.ZERO;
        default:
    }
    return result;
}

LRESULT wmClipboard (HWND hwndText, int msg, WPARAM wParam, LPARAM lParam) {
    if ((style & SWT.READ_ONLY) !is 0) return null;
//  if (!hooks (SWT.Verify) && !filters (SWT.Verify)) return null;
    bool call = false;
    int start, end;
    String newText = null;
    switch (msg) {
        case OS.WM_CLEAR:
        case OS.WM_CUT:
            OS.SendMessage (hwndText, OS.EM_GETSEL, &start, &end);
            if (start !is end) {
                newText = "";
                call = true;
            }
            break;
        case OS.WM_PASTE:
            OS.SendMessage (hwndText, OS.EM_GETSEL, &start, &end);
            newText = getClipboardText ();
            break;
        case OS.EM_UNDO:
        case OS.WM_UNDO:
            if (OS.SendMessage (hwndText, OS.EM_CANUNDO, 0, 0) !is 0) {
                ignoreModify = true;
                OS.SendMessage (hwndText, OS.EM_GETSEL, &start, &end);
                OS.CallWindowProc (EditProc, hwndText, msg, wParam, lParam);
                int length_ = OS.GetWindowTextLength (hwndText);
                int newStart, newEnd;
                OS.SendMessage (hwndText, OS.EM_GETSEL, &newStart, &newEnd);
                if (length_ !is 0 && newStart !is newEnd ) {
                    TCHAR[] buffer = NewTCHARs (getCodePage (), length_ + 1);
                    OS.GetWindowText (hwndText, buffer.ptr, length_ + 1);
                    newText = TCHARsToStr( buffer[ newStart .. newEnd ] );
                } else {
                    newText = "";
                }
                OS.CallWindowProc (EditProc, hwndText, msg, wParam, lParam);
                ignoreModify = false;
            }
            break;
        default:
    }
    if (newText !is null) {
        String oldText = newText;
        newText = verifyText (newText, start, end, null);
        if (newText is null) return LRESULT.ZERO;
        if ( newText !=/*eq*/ oldText ) {
            if (call) {
                OS.CallWindowProc (EditProc, hwndText, msg, wParam, lParam);
            }
            StringT buffer = StrToTCHARs (getCodePage (), newText, true);
            if (msg is OS.WM_SETTEXT) {
                auto hHeap = OS.GetProcessHeap ();
                auto byteCount = buffer.length * TCHAR.sizeof;
                auto pszText = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
                OS.MoveMemory (pszText, buffer.ptr, byteCount);
                auto code = OS.CallWindowProc (EditProc, hwndText, msg, wParam, cast(ptrdiff_t)pszText);
                OS.HeapFree (hHeap, 0, pszText);
                return new LRESULT (code);
            } else {
                OS.SendMessage (hwndText, OS.EM_REPLACESEL, 0, cast(void*)buffer.ptr);
                return LRESULT.ZERO;
            }
        }
    }
    return null;
}

override LRESULT wmCommandChild (WPARAM wParam, LPARAM lParam) {
    int code = OS.HIWORD (wParam);
    switch (code) {
        case OS.EN_CHANGE:
            if (ignoreModify) break;
            bool [] parseFail = new bool [1];
            int value = getSelectionText (parseFail);
            if (!parseFail [0]) {
                .LRESULT pos;
                static if (OS.IsWinCE) {
                    pos = OS.LOWORD (OS.SendMessage (hwndUpDown, OS.UDM_GETPOS, 0, 0));
                } else {
                    pos = OS.SendMessage (hwndUpDown, OS.UDM_GETPOS32, 0, 0);
                }
                if (pos !is value) setSelection (value, true, false, true);
            }
            sendEvent (SWT.Modify);
            if (isDisposed ()) return LRESULT.ZERO;
            break;
        default:
    }
    return super.wmCommandChild (wParam, lParam);
}

override LRESULT wmKeyDown (HWND hwnd, WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.wmKeyDown (hwnd, wParam, lParam);
    if (result !is null) return result;

    /* Increment the value */
    UDACCEL udaccel;
    OS.SendMessage (hwndUpDown, OS.UDM_GETACCEL, 1, &udaccel);
    int delta = 0;
    switch (wParam) {
        case OS.VK_UP: delta = udaccel.nInc; break;
        case OS.VK_DOWN: delta = -udaccel.nInc; break;
        case OS.VK_PRIOR: delta = pageIncrement; break;
        case OS.VK_NEXT: delta = -pageIncrement; break;
        default:
    }
    if (delta !is 0) {
        bool [1] parseFail;
        .LRESULT value = getSelectionText (parseFail);
        if (parseFail [0]) {
            static if (OS.IsWinCE) {
                value = OS.LOWORD (OS.SendMessage (hwndUpDown, OS.UDM_GETPOS, 0, 0));
            } else {
                value = OS.SendMessage (hwndUpDown, OS.UDM_GETPOS32, 0, 0);
            }
        }
        auto newValue = value + delta;
        int max, min;
        OS.SendMessage (hwndUpDown , OS.UDM_GETRANGE32, &min, &max);
        if ((style & SWT.WRAP) !is 0) {
            if (newValue < min ) newValue = max;
            if (newValue > max ) newValue = min;
        }
        newValue = Math.min (Math.max (min , newValue), max );
        if (value !is newValue) setSelection (cast(int)/*64bit*/newValue, true, true, true);
    }

    /*  Stop the edit control from moving the caret */
    switch (wParam) {
        case OS.VK_UP:
        case OS.VK_DOWN:
            return LRESULT.ZERO;
        default:
    }
    return result;
}

override LRESULT wmKillFocus (HWND hwnd, WPARAM wParam, LPARAM lParam) {
    bool [1] parseFail;
    .LRESULT value = getSelectionText (parseFail);
    if (parseFail [0]) {
        static if (OS.IsWinCE) {
            value = OS.LOWORD (OS.SendMessage (hwndUpDown, OS.UDM_GETPOS, 0, 0));
        } else {
            value = OS.SendMessage (hwndUpDown, OS.UDM_GETPOS32, 0, 0);
        }
        setSelection (cast(int)/*64bit*/value, false, true, false);
    }
    return super.wmKillFocus (hwnd, wParam, lParam);
}

override LRESULT wmNotifyChild (NMHDR* hdr, WPARAM wParam, LPARAM lParam) {
    switch (hdr.code) {
        case OS.UDN_DELTAPOS:
            NMUPDOWN* lpnmud = cast(NMUPDOWN*)lParam;
            //OS.MoveMemory (lpnmud, lParam, NMUPDOWN.sizeof);
            int value = lpnmud.iPos + lpnmud.iDelta;
            int max, min;
            OS.SendMessage (hwndUpDown , OS.UDM_GETRANGE32, &min, &max);
            if ((style & SWT.WRAP) !is 0) {
                if (value < min ) value = max ;
                if (value > max ) value = min ;
            }
            /*
            * The SWT.Modify event is sent after the widget has been
            * updated with the new state.  Rather than allowing
            * the default updown window proc to set the value
            * when the user clicks on the updown control, set
            * the value explicitly and stop the window proc
            * from running.
            */
            value = Math.min (Math.max (min , value), max );
            if (value !is lpnmud.iPos) {
                setSelection (value, true, true, true);
            }
            return LRESULT.ONE;
        default:
    }
    return super.wmNotifyChild (hdr, wParam, lParam);
}

override LRESULT wmScrollChild (WPARAM wParam, LPARAM lParam) {
    int code = OS.LOWORD (wParam);
    switch (code) {
        case OS.SB_THUMBPOSITION:
            postEvent (SWT.Selection);
            break;
        default:
    }
    return super.wmScrollChild (wParam, lParam);
}

}

