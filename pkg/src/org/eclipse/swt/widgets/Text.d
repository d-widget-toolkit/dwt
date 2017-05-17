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
module org.eclipse.swt.widgets.Text;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.VerifyListener;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Scrollable;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Control;

import java.lang.all;

/**
 * Instances of this class are selectable user interface
 * objects that allow the user to enter and modify text.
 * Text controls can be either single or multi-line.
 * When a text control is created with a border, the
 * operating system includes a platform specific inset
 * around the contents of the control.  When created
 * without a border, an effort is made to remove the
 * inset such that the preferred size of the control
 * is the same size as the contents.
 * <p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>CANCEL, CENTER, LEFT, MULTI, PASSWORD, SEARCH, SINGLE, RIGHT, READ_ONLY, WRAP</dd>
 * <dt><b>Events:</b></dt>
 * <dd>DefaultSelection, Modify, Verify</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles MULTI and SINGLE may be specified,
 * and only one of the styles LEFT, CENTER, and RIGHT may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#text">Text snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Text : Scrollable {

    alias Scrollable.computeSize computeSize;
    alias Scrollable.dragDetect dragDetect;
    alias Scrollable.sendKeyEvent sendKeyEvent;
    alias Scrollable.setBounds setBounds;

    int tabs, oldStart, oldEnd;
    bool doubleClick, ignoreModify, ignoreVerify, ignoreCharacter;
    String message;

    /**
    * The maximum number of characters that can be entered
    * into a text widget.
    * <p>
    * Note that this value is platform dependent, based upon
    * the native widget implementation.
    * </p>
    */
    mixin(gshared!(`private static int LIMIT_;`));
    public static int LIMIT(){
        assert( static_this_completed );
        return LIMIT_;
    }

    /**
    * The delimiter used by multi-line text widgets.  When text
    * is queried and from the widget, it will be delimited using
    * this delimiter.
    */
    public static const String DELIMITER = "\r\n";

    /*
    * This code is intentionally commented.
    */
//  static final char PASSWORD;

    /*
    * These values can be different on different platforms.
    * Therefore they are not initialized in the declaration
    * to stop the compiler from inlining.
    */

    mixin(gshared!(`private static /+const+/ WNDPROC EditProc;`));
    static const TCHAR[] EditClass = "EDIT\0";

    mixin(gshared!(`private static bool static_this_completed = false;`));
    private static void static_this() {
        if( static_this_completed ){
            return;
        }
        synchronized {
            if( static_this_completed ){
                return;
            }
            LIMIT_ = OS.IsWinNT ? 0x7FFFFFFF : 0x7FFF;
            WNDCLASS lpWndClass;
            OS.GetClassInfo (null, EditClass.ptr, &lpWndClass);
            EditProc = lpWndClass.lpfnWndProc;
            /*
            * This code is intentionally commented.
            */
    //      int hwndText = OS.CreateWindowEx (0,
    //          EditClass,
    //          null,
    //          OS.WS_OVERLAPPED | OS.ES_PASSWORD,
    //          0, 0, 0, 0,
    //          0,
    //          0,
    //          OS.GetModuleHandle (null),
    //          null);
    //      char echo = (char) OS.SendMessage (hwndText, OS.EM_GETPASSWORDCHAR, 0, 0);
    //      OS.DestroyWindow (hwndText);
    //      PASSWORD = echo !is 0 ? echo : '*';
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
 * @see SWT#SINGLE
 * @see SWT#MULTI
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
    bool redraw = false;
    switch (msg) {
        case OS.WM_ERASEBKGND: {
            if (findImageControl () !is null) return 0;
            break;
        }
        case OS.WM_HSCROLL:
        case OS.WM_VSCROLL: {
            redraw = findImageControl () !is null && drawCount is 0 && OS.IsWindowVisible (handle);
            if (redraw) OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
            break;
        }
        case OS.WM_PAINT: {
            if (findImageControl () !is null) {
                PAINTSTRUCT ps;
                auto paintDC = OS.BeginPaint (handle, &ps);
                int width = ps.rcPaint.right - ps.rcPaint.left;
                int height = ps.rcPaint.bottom - ps.rcPaint.top;
                if (width !is 0 && height !is 0) {
                    auto hDC = OS.CreateCompatibleDC (paintDC);
                    POINT lpPoint1, lpPoint2;
                    OS.SetWindowOrgEx (hDC, ps.rcPaint.left, ps.rcPaint.top, &lpPoint1);
                    OS.SetBrushOrgEx (hDC, ps.rcPaint.left, ps.rcPaint.top, &lpPoint2);
                    auto hBitmap = OS.CreateCompatibleBitmap (paintDC, width, height);
                    auto hOldBitmap = OS.SelectObject (hDC, hBitmap);
                    RECT rect;
                    OS.SetRect (&rect, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right, ps.rcPaint.bottom);
                    drawBackground (hDC, &rect);
                    OS.CallWindowProc ( EditProc, hwnd, OS.WM_PAINT, cast(ptrdiff_t)hDC, lParam);
                    OS.SetWindowOrgEx (hDC, lpPoint1.x, lpPoint1.y, null);
                    OS.SetBrushOrgEx (hDC, lpPoint2.x, lpPoint2.y, null);
                    OS.BitBlt (paintDC, ps.rcPaint.left, ps.rcPaint.top, width, height, hDC, 0, 0, OS.SRCCOPY);
                    OS.SelectObject (hDC, hOldBitmap);
                    OS.DeleteObject (hBitmap);
                    OS.DeleteObject (hDC);
                }
                OS.EndPaint (handle, &ps);
                return 0;
            }
            break;
        }
        default:
    }
    auto code = OS.CallWindowProc (EditProc, hwnd, msg, wParam, lParam);
    switch (msg) {
        case OS.WM_HSCROLL:
        case OS.WM_VSCROLL: {
            if (redraw) {
                OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
                OS.InvalidateRect (handle, null, true);
            }
            break;
        }
        default:
    }
    return code;
}

override void createHandle () {
    super.createHandle ();
    OS.SendMessage (handle, OS.EM_LIMITTEXT, 0, 0);
    if ((style & SWT.READ_ONLY) !is 0) {
        if ((style & (SWT.BORDER | SWT.H_SCROLL | SWT.V_SCROLL)) is 0) {
            state |= THEME_BACKGROUND;
        }
    }
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
 * <code>widgetDefaultSelected</code> is typically called when ENTER is pressed in a single-line text,
 * or when ENTER is pressed in a search text. If the receiver has the <code>SWT.SEARCH | SWT.CANCEL</code> style
 * and the user cancels the search, the event object detail field contains the value <code>SWT.CANCEL</code>.
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
public void addVerifyListener (VerifyListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Verify, typedListener);
}

/**
 * Appends a string.
 * <p>
 * The new text is appended to the text at
 * the end of the widget.
 * </p>
 *
 * @param string the string to be appended
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void append (String string) {
    checkWidget ();
    // SWT extension: allow null string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    string = Display.withCrLf (string);
    int length = OS.GetWindowTextLength (handle);
    if (hooks (SWT.Verify) || filters (SWT.Verify)) {
        string = verifyText (string, length, length, null);
        if (string is null) return;
    }
    OS.SendMessage (handle, OS.EM_SETSEL, length, length);
    LPCTSTR buffer = StrToTCHARz (getCodePage (), string);
    /*
    * Feature in Windows.  When an edit control with ES_MULTILINE
    * style that does not have the WS_VSCROLL style is full (i.e.
    * there is no space at the end to draw any more characters),
    * EM_REPLACESEL sends a WM_CHAR with a backspace character
    * to remove any further text that is added.  This is an
    * implementation detail of the edit control that is unexpected
    * and can cause endless recursion when EM_REPLACESEL is sent
    * from a WM_CHAR handler.  The fix is to ignore calling the
    * handler from WM_CHAR.
    */
    ignoreCharacter = true;
    OS.SendMessage (handle, OS.EM_REPLACESEL, 0, cast(void*)buffer);
    ignoreCharacter = false;
    OS.SendMessage (handle, OS.EM_SCROLLCARET, 0, 0);
}

static int checkStyle (int style) {
    if ((style & SWT.SEARCH) !is 0) {
        style |= SWT.SINGLE | SWT.BORDER;
        style &= ~SWT.PASSWORD;
    }
    if (OS.COMCTL32_MAJOR < 6) style &= ~SWT.SEARCH;
    if ((style & SWT.SINGLE) !is 0 && (style & SWT.MULTI) !is 0) {
        style &= ~SWT.MULTI;
    }
    style = checkBits (style, SWT.LEFT, SWT.CENTER, SWT.RIGHT, 0, 0, 0);
    if ((style & SWT.SINGLE) !is 0) style &= ~(SWT.H_SCROLL | SWT.V_SCROLL | SWT.WRAP);
    if ((style & SWT.WRAP) !is 0) {
        style |= SWT.MULTI;
        style &= ~SWT.H_SCROLL;
    }
    if ((style & SWT.MULTI) !is 0) style &= ~SWT.PASSWORD;
    if ((style & (SWT.SINGLE | SWT.MULTI)) !is 0) return style;
    if ((style & (SWT.H_SCROLL | SWT.V_SCROLL)) !is 0) return style | SWT.MULTI;
    return style | SWT.SINGLE;
}

/**
 * Clears the selection.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void clearSelection () {
    checkWidget ();
    static if (OS.IsWinCE) {
        /*
        * Bug in WinCE.  Calling EM_SETSEL with -1 and 0 is equivalent
        * to calling EM_SETSEL with 0 and -1.  It causes the entire
        * text to be selected instead of clearing the selection.  The
        * fix is to set the start of the selection to the  end of the
        * current selection.
        */
        int end;
        OS.SendMessage (handle, OS.EM_GETSEL, null, &end);
        OS.SendMessage (handle, OS.EM_SETSEL, end , end );
    } else {
        OS.SendMessage (handle, OS.EM_SETSEL, -1, 0);
    }
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int height = 0, width = 0;
    if (wHint is SWT.DEFAULT || hHint is SWT.DEFAULT) {
        HFONT newFont, oldFont;
        auto hDC = OS.GetDC (handle);
        newFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
        if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
        TEXTMETRIC tm;
        OS.GetTextMetrics (hDC, &tm);
        int count = (style & SWT.SINGLE) !is 0 ? 1 : cast(int)/*64bit*/OS.SendMessage (handle, OS.EM_GETLINECOUNT, 0, 0);
        height = count * tm.tmHeight;
        RECT rect;
        int flags = OS.DT_CALCRECT | OS.DT_EDITCONTROL | OS.DT_NOPREFIX;
        bool wrap = (style & SWT.MULTI) !is 0 && (style & SWT.WRAP) !is 0;
        if (wrap && wHint !is SWT.DEFAULT) {
            flags |= OS.DT_WORDBREAK;
            rect.right = wHint;
        }
        int length = OS.GetWindowTextLength (handle);
        if (length !is 0) {
            TCHAR[] buffer = NewTCHARs (getCodePage (), length + 1);
            OS.GetWindowText (handle, buffer.ptr, length + 1);
            OS.DrawText (hDC, buffer.ptr, length, &rect, flags);
            width = rect.right - rect.left;
        }
        //This code is intentionally commented
//      if (OS.COMCTL32_MAJOR >= 6) {
//          if ((style & SWT.SEARCH) !is 0) {
//              length = message.length ();
//              if (length !is 0) {
//                  char [] buffer = new char [length + 1];
//                  message.getChars (0, length, buffer, 0);
//                  SIZE size = new SIZE ();
//                  OS.GetTextExtentPoint32W (hDC, buffer, length, size);
//                  width = Math.max (width, size.cx);
//              }
//          }
//      }
        if (wrap && hHint is SWT.DEFAULT) {
            int newHeight = rect.bottom - rect.top;
            if (newHeight !is 0) height = newHeight;
        }
        if (newFont !is null) OS.SelectObject (hDC, oldFont);
        OS.ReleaseDC (handle, hDC);
    }
    if (width is 0) width = DEFAULT_WIDTH;
    if (height is 0) height = DEFAULT_HEIGHT;
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    Rectangle trim = computeTrim (0, 0, width, height);
    return new Point (trim.width, trim.height);
}

override public Rectangle computeTrim (int x, int y, int width, int height) {
    checkWidget ();
    Rectangle rect = super.computeTrim (x, y, width, height);
    /*
    * The preferred height of a single-line text widget
    * has been hand-crafted to be the same height as
    * the single-line text widget in an editable combo
    * box.
    */
    auto margins = OS.SendMessage(handle, OS.EM_GETMARGINS, 0, 0);
    rect.x -= OS.LOWORD (margins);
    rect.width += OS.LOWORD (margins) + OS.HIWORD (margins);
    if ((style & SWT.H_SCROLL) !is 0) rect.width++;
    if ((style & SWT.BORDER) !is 0) {
        rect.x -= 1;
        rect.y -= 1;
        rect.width += 2;
        rect.height += 2;
    }
    return rect;
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
    OS.SendMessage (handle, OS.WM_COPY, 0, 0);
}

override void createWidget () {
    super.createWidget ();
    message = "";
    doubleClick = true;
    setTabStops (tabs = 8);
    fixAlignment ();
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
    OS.SendMessage (handle, OS.WM_CUT, 0, 0);
}

override int defaultBackground () {
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    return OS.GetSysColor ((bits & OS.ES_READONLY) !is 0 ? OS.COLOR_3DFACE : OS.COLOR_WINDOW);
}

override bool dragDetect (HWND hwnd, int x, int y, bool filter, bool [] detect, bool [] consume) {
    if (filter) {
        int start, end;
        OS.SendMessage (handle, OS.EM_GETSEL, &start, &end);
        if (start !is end ) {
            auto lParam = OS.MAKELPARAM (x, y);
            int position = OS.LOWORD (OS.SendMessage (handle, OS.EM_CHARFROMPOS, 0, lParam));
            if (start <= position && position < end) {
                if (super.dragDetect (hwnd, x, y, filter, detect, consume)) {
                    if (consume !is null) consume [0] = true;
                    return true;
                }
            }
        }
        return false;
    }
    return super.dragDetect (hwnd, x, y, filter, detect, consume);
}

void fixAlignment () {
    /*
    * Feature in Windows.  When the edit control is not
    * mirrored, it uses WS_EX_RIGHT, WS_EX_RTLREADING and
    * WS_EX_LEFTSCROLLBAR to give the control a right to
    * left appearance.  This causes the control to be lead
    * aligned no matter what alignment was specified by
    * the programmer.  For example, setting ES_RIGHT and
    * WS_EX_LAYOUTRTL should cause the contents of the
    * control to be left (trail) aligned in a mirrored world.
    * When the orientation is changed by the user or
    * specified by the programmer, WS_EX_RIGHT conflicts
    * with the mirrored alignment.  The fix is to clear
    * or set WS_EX_RIGHT to achieve the correct alignment
    * according to the orientation and mirroring.
    */
    if ((style & SWT.MIRRORED) !is 0) return;
    int bits1 = OS.GetWindowLong (handle, OS.GWL_EXSTYLE);
    int bits2 = OS.GetWindowLong (handle, OS.GWL_STYLE);
    if ((style & SWT.LEFT_TO_RIGHT) !is 0) {
        /*
        * Bug in Windows 98. When the edit control is created
        * with the style ES_RIGHT it automatically sets the
        * WS_EX_LEFTSCROLLBAR bit.  The fix is to clear the
        * bit when the orientation of the control is left
        * to right.
        */
        bits1 &= ~OS.WS_EX_LEFTSCROLLBAR;
        if ((style & SWT.RIGHT) !is 0) {
            bits1 |= OS.WS_EX_RIGHT;
            bits2 |= OS.ES_RIGHT;
        }
        if ((style & SWT.LEFT) !is 0) {
            bits1 &= ~OS.WS_EX_RIGHT;
            bits2 &= ~OS.ES_RIGHT;
        }
    } else {
        if ((style & SWT.RIGHT) !is 0) {
            bits1 &= ~OS.WS_EX_RIGHT;
            bits2 &= ~OS.ES_RIGHT;
        }
        if ((style & SWT.LEFT) !is 0) {
            bits1 |= OS.WS_EX_RIGHT;
            bits2 |= OS.ES_RIGHT;
        }
    }
    if ((style & SWT.CENTER) !is 0) {
        bits2 |= OS.ES_CENTER;
    }
    OS.SetWindowLong (handle, OS.GWL_EXSTYLE, bits1);
    OS.SetWindowLong (handle, OS.GWL_STYLE, bits2);
}

override public int getBorderWidth () {
    checkWidget ();
    /*
    * Feature in Windows 2000 and XP.  Despite the fact that WS_BORDER
    * is set when the edit control is created, the style bit is cleared.
    * The fix is to avoid the check for WS_BORDER and use the SWT widget
    * style bits instead.
    */
//  if ((style & SWT.BORDER) !is 0 && (style & SWT.FLAT) !is 0) {
//      return OS.GetSystemMetrics (OS.SM_CXBORDER);
//  }
    return super.getBorderWidth ();
}

/**
 * Returns the line number of the caret.
 * <p>
 * The line number of the caret is returned.
 * </p>
 *
 * @return the line number
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getCaretLineNumber () {
    checkWidget ();
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.EM_LINEFROMCHAR, -1, 0);
}

/**
 * Returns a point describing the receiver's location relative
 * to its parent (or its display if its parent is null).
 * <p>
 * The location of the caret is returned.
 * </p>
 *
 * @return a point, the location of the caret
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getCaretLocation () {
    checkWidget ();
    /*
    * Bug in Windows.  For some reason, Windows is unable
    * to return the pixel coordinates of the last character
    * in the widget.  The fix is to temporarily insert a
    * space, query the coordinates and delete the space.
    * The selection is always an i-beam in this case because
    * this is the only time the start of the selection can
    * be equal to the last character position in the widget.
    * If EM_POSFROMCHAR fails for any other reason, return
    * pixel coordinates (0,0).
    */
    int position = getCaretPosition ();
    auto caretPos = OS.SendMessage (handle, OS.EM_POSFROMCHAR, position, 0);
    if (caretPos is -1) {
        caretPos = 0;
        if (position >= OS.GetWindowTextLength (handle)) {
            int cp = getCodePage ();
            int start, end;
            OS.SendMessage (handle, OS.EM_GETSEL, &start, &end);
            OS.SendMessage (handle, OS.EM_SETSEL, position, position);
            /*
            * Feature in Windows.  When an edit control with ES_MULTILINE
            * style that does not have the WS_VSCROLL style is full (i.e.
            * there is no space at the end to draw any more characters),
            * EM_REPLACESEL sends a WM_CHAR with a backspace character
            * to remove any further text that is added.  This is an
            * implementation detail of the edit control that is unexpected
            * and can cause endless recursion when EM_REPLACESEL is sent
            * from a WM_CHAR handler.  The fix is to ignore calling the
            * handler from WM_CHAR.
            */
            ignoreCharacter = ignoreModify = true;
            OS.SendMessage (handle, OS.EM_REPLACESEL, 0, cast(void*)StrToTCHARz (cp, " "));
            caretPos = OS.SendMessage (handle, OS.EM_POSFROMCHAR, position, 0);
            OS.SendMessage (handle, OS.EM_SETSEL, position, position + 1);
            OS.SendMessage (handle, OS.EM_REPLACESEL, 0, cast(void*)StrToTCHARz (cp, ""));
            ignoreCharacter = ignoreModify = false;
            OS.SendMessage (handle, OS.EM_SETSEL, start , start );
            OS.SendMessage (handle, OS.EM_SETSEL, start , end );
        }
    }
    return new Point (OS.GET_X_LPARAM (caretPos), OS.GET_Y_LPARAM (caretPos));
}

/**
 * Returns the character position of the caret.
 * <p>
 * Indexing is zero based.
 * </p>
 *
 * @return the position of the caret
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getCaretPosition () {
    checkWidget ();
    int start, end;
    OS.SendMessage (handle, OS.EM_GETSEL, &start, &end);
    /*
    * In Windows, there is no API to get the position of the caret
    * when the selection is not an i-beam.  The best that can be done
    * is to query the pixel position of the current caret and compare
    * it to the pixel position of the start and end of the selection.
    *
    * NOTE:  This does not work when the i-beam belongs to another
    * control.  In this case, guess that the i-beam is at the start
    * of the selection.
    */
    int caret = start ;
    if (start !is end ) {
        auto startLine = OS.SendMessage (handle, OS.EM_LINEFROMCHAR, start, 0);
        auto endLine = OS.SendMessage (handle, OS.EM_LINEFROMCHAR, end, 0);
        if (startLine is endLine) {
            static if (!OS.IsWinCE) {
                int idThread = OS.GetWindowThreadProcessId (handle, null);
                GUITHREADINFO lpgui;
                lpgui.cbSize = GUITHREADINFO.sizeof;
                if (OS.GetGUIThreadInfo (idThread, &lpgui)) {
                    if (lpgui.hwndCaret is handle || lpgui.hwndCaret is null) {
                        POINT ptCurrentPos;
                        if (OS.GetCaretPos (&ptCurrentPos)) {
                            auto endPos = OS.SendMessage (handle, OS.EM_POSFROMCHAR, end, 0);
                            if (endPos is -1) {
                                auto startPos = OS.SendMessage (handle, OS.EM_POSFROMCHAR, start, 0);
                                int startX = cast(short) (startPos & 0xFFFF);
                                if (ptCurrentPos.x > startX) caret = end;
                            } else {
                                int endX = cast(short) (endPos & 0xFFFF);
                                if (ptCurrentPos.x >= endX) caret = end;
                            }
                        }
                    }
                }
            }
        } else {
            auto caretPos = OS.SendMessage (handle, OS.EM_LINEINDEX, -1, 0);
            auto caretLine = OS.SendMessage (handle, OS.EM_LINEFROMCHAR, caretPos, 0);
            if (caretLine is endLine) caret = end;
        }
    }
    if (!OS.IsUnicode && OS.IsDBLocale) caret = mbcsToWcsPos (caret);
    return caret;
}

/**
 * Returns the number of characters.
 *
 * @return number of characters in the widget
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getCharCount () {
    checkWidget ();
    int length = OS.GetWindowTextLength (handle);
    if (!OS.IsUnicode && OS.IsDBLocale) length = mbcsToWcsPos (length);
    return length;
}

/**
 * Returns the double click enabled flag.
 * <p>
 * The double click flag enables or disables the
 * default action of the text widget when the user
 * double clicks.
 * </p>
 *
 * @return whether or not double click is enabled
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getDoubleClickEnabled () {
    checkWidget ();
    return doubleClick;
}

/**
 * Returns the echo character.
 * <p>
 * The echo character is the character that is
 * displayed when the user enters text or the
 * text is changed by the programmer.
 * </p>
 *
 * @return the echo character
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setEchoChar
 */
public char getEchoChar () {
    checkWidget ();
    wchar echo = cast(wchar) OS.SendMessage (handle, OS.EM_GETPASSWORDCHAR, 0, 0);
    if (echo !is 0 && (echo = Display.mbcsToWcs (echo, getCodePage ())) is 0) echo = '*';
	return cast(char) echo;
}

/**
 * Returns the editable state.
 *
 * @return whether or not the receiver is editable
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getEditable () {
    checkWidget ();
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    return (bits & OS.ES_READONLY) is 0;
}

/**
 * Returns the number of lines.
 *
 * @return the number of lines in the widget
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getLineCount () {
    checkWidget ();
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.EM_GETLINECOUNT, 0, 0);
}

/**
 * Returns the line delimiter.
 *
 * @return a string that is the line delimiter
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #DELIMITER
 */
public String getLineDelimiter () {
    checkWidget ();
    return DELIMITER;
}

/**
 * Returns the height of a line.
 *
 * @return the height of a row of text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getLineHeight () {
    checkWidget ();
    HFONT newFont, oldFont;
    auto hDC = OS.GetDC (handle);
    newFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
    if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
    TEXTMETRIC tm;
    OS.GetTextMetrics (hDC, &tm);
    if (newFont !is null) OS.SelectObject (hDC, oldFont);
    OS.ReleaseDC (handle, hDC);
    return tm.tmHeight;
}

/**
 * Returns the orientation of the receiver, which will be one of the
 * constants <code>SWT.LEFT_TO_RIGHT</code> or <code>SWT.RIGHT_TO_LEFT</code>.
 *
 * @return the orientation style
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1.2
 */
public int getOrientation () {
    checkWidget();
    return style & (SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT);
}

/**
 * Returns the widget message. When the widget is created
 * with the style <code>SWT.SEARCH</code>, the message text
 * is displayed as a hint for the user, indicating the
 * purpose of the field.
 * <p>
 * Note: This operation is a <em>HINT</em> and is not
 * supported on platforms that do not have this concept.
 * </p>
 *
 * @return the widget message
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.3
 */
public String getMessage () {
    checkWidget ();
    return message;
}

/**
 * Returns the character position at the given point in the receiver
 * or -1 if no such position exists. The point is in the coordinate
 * system of the receiver.
 * <p>
 * Indexing is zero based.
 * </p>
 *
 * @return the position of the caret
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.3
 */
//TODO - Javadoc
/*public*/ int getPosition (Point point) {
    checkWidget();
    if (point is null) error (SWT.ERROR_NULL_ARGUMENT);
    auto lParam = OS.MAKELPARAM (point.x, point.y);
    int position = OS.LOWORD (OS.SendMessage (handle, OS.EM_CHARFROMPOS, 0, lParam));
    if (!OS.IsUnicode && OS.IsDBLocale) position = mbcsToWcsPos (position);
    return position;
}

/**
 * Returns a <code>Point</code> whose x coordinate is the
 * character position representing the start of the selected
 * text, and whose y coordinate is the character position
 * representing the end of the selection. An "empty" selection
 * is indicated by the x and y coordinates having the same value.
 * <p>
 * Indexing is zero based.  The range of a selection is from
 * 0..N where N is the number of characters in the widget.
 * </p>
 *
 * @return a point representing the selection start and end
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getSelection () {
    checkWidget ();
    int start, end;
    OS.SendMessage (handle, OS.EM_GETSEL, &start, &end);
    if (!OS.IsUnicode && OS.IsDBLocale) {
        start = mbcsToWcsPos (start);
        end = mbcsToWcsPos (end);
    }
    return new Point (start, end);
}

/**
 * Returns the number of selected characters.
 *
 * @return the number of selected characters.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSelectionCount () {
    checkWidget ();
    Point selection = getSelection ();
    return selection.y - selection.x;
}

/**
 * Gets the selected text, or an empty string if there is no current selection.
 *
 * @return the selected text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getSelectionText () {
    checkWidget ();
    int length = OS.GetWindowTextLength (handle);
    if (length is 0) return "";
    int start, end;
    OS.SendMessage (handle, OS.EM_GETSEL, &start, &end);
    if (start is end ) return "";
    TCHAR[] buffer = NewTCHARs (getCodePage (), length + 1);
    OS.GetWindowText (handle, buffer.ptr, length + 1);
    return TCHARsToStr( buffer[ start .. end ] );
}

/**
 * Returns the number of tabs.
 * <p>
 * Tab stop spacing is specified in terms of the
 * space (' ') character.  The width of a single
 * tab stop is the pixel width of the spaces.
 * </p>
 *
 * @return the number of tab characters
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getTabs () {
    checkWidget ();
    return tabs;
}

int getTabWidth (int tabs) {
    HFONT oldFont;
    RECT rect;
    auto hDC = OS.GetDC (handle);
    HFONT newFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
    if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
    int flags = OS.DT_CALCRECT | OS.DT_SINGLELINE | OS.DT_NOPREFIX;
    StringT SPACE = StrToTCHARs (getCodePage (), " ", false);
    OS.DrawText (hDC, SPACE.ptr, cast(int)/*64bit*/SPACE.length, &rect, flags);
    if (newFont !is null) OS.SelectObject (hDC, oldFont);
    OS.ReleaseDC (handle, hDC);
    return (rect.right - rect.left) * tabs;
}

/**
 * Returns the widget text.
 * <p>
 * The text for a text widget is the characters in the widget, or
 * an empty string if this has never been set.
 * </p>
 *
 * @return the widget text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText () {
    checkWidget ();
    int length_ = OS.GetWindowTextLength (handle);
    if (length_ is 0) return "";
    TCHAR[] buffer = NewTCHARs (getCodePage (), length_ + 1);
    OS.GetWindowText (handle, buffer.ptr, length_ + 1);
    return TCHARsToStr( buffer[0 .. length_] );
}

/**
 * Returns a range of text.  Returns an empty string if the
 * start of the range is greater than the end.
 * <p>
 * Indexing is zero based.  The range of
 * a selection is from 0..N-1 where N is
 * the number of characters in the widget.
 * </p>
 *
 * @param start the start of the range
 * @param end the end of the range
 * @return the range of text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText (int start, int end) {
    checkWidget ();
    if (!(start <= end && 0 <= end)) return "";
    int length = OS.GetWindowTextLength (handle);
    if (!OS.IsUnicode && OS.IsDBLocale) length = mbcsToWcsPos (length);
    start = Math.max (0, start);
    end = Math.min (end, length - 1);
    /*
    * NOTE: The current implementation uses substring ()
    * which can reference a potentially large character
    * array.
    */
    //FIXME: no UTF-8 support
    return getText ().substring (start, end + 1);
}

/**
 * Returns the maximum number of characters that the receiver is capable of holding.
 * <p>
 * If this has not been changed by <code>setTextLimit()</code>,
 * it will be the constant <code>Text.LIMIT</code>.
 * </p>
 *
 * @return the text limit
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #LIMIT
 */
public int getTextLimit () {
    checkWidget ();
    return OS.SendMessage (handle, OS.EM_GETLIMITTEXT, 0, 0) & 0x7FFFFFFF;
}

/**
 * Returns the zero-relative index of the line which is currently
 * at the top of the receiver.
 * <p>
 * This index can change when lines are scrolled or new lines are added or removed.
 * </p>
 *
 * @return the index of the top line
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getTopIndex () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) return 0;
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.EM_GETFIRSTVISIBLELINE, 0, 0);
}

/**
 * Returns the top pixel.
 * <p>
 * The top pixel is the pixel position of the line
 * that is currently at the top of the widget.  On
 * some platforms, a text widget can be scrolled by
 * pixels instead of lines so that a partial line
 * is displayed at the top of the widget.
 * </p><p>
 * The top pixel changes when the widget is scrolled.
 * The top pixel does not include the widget trimming.
 * </p>
 *
 * @return the pixel position of the top line
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getTopPixel () {
    checkWidget ();
    /*
    * Note, EM_GETSCROLLPOS is implemented in Rich Edit 3.0
    * and greater.  The plain text widget and previous versions
    * of Rich Edit return zero.
    */
    int [2] buffer;
    auto code = OS.SendMessage (handle, OS.EM_GETSCROLLPOS, 0, buffer.ptr);
    if (code is 1) return buffer [1];
    return getTopIndex () * getLineHeight ();
}

/**
 * Inserts a string.
 * <p>
 * The old selection is replaced with the new text.
 * </p>
 *
 * @param string the string
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void insert (String string) {
    checkWidget ();
    // SWT extension: allow null string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    string = Display.withCrLf (string);
    if (hooks (SWT.Verify) || filters (SWT.Verify)) {
        int start, end;
        OS.SendMessage (handle, OS.EM_GETSEL, &start, &end);
        string = verifyText (string, start, end, null);
        if (string is null) return;
    }
    LPCTSTR buffer = StrToTCHARz (getCodePage (), string );
    /*
    * Feature in Windows.  When an edit control with ES_MULTILINE
    * style that does not have the WS_VSCROLL style is full (i.e.
    * there is no space at the end to draw any more characters),
    * EM_REPLACESEL sends a WM_CHAR with a backspace character
    * to remove any further text that is added.  This is an
    * implementation detail of the edit control that is unexpected
    * and can cause endless recursion when EM_REPLACESEL is sent
    * from a WM_CHAR handler.  The fix is to ignore calling the
    * handler from WM_CHAR.
    */
    ignoreCharacter = true;
    OS.SendMessage (handle, OS.EM_REPLACESEL, 0, cast(void*)buffer);
    ignoreCharacter = false;
}

int mbcsToWcsPos (int mbcsPos) {
    if (mbcsPos <= 0) return 0;
    if (OS.IsUnicode) return mbcsPos;
    int cp = getCodePage ();
    int wcsTotal = 0, mbcsTotal = 0;
    CHAR [] buffer = new CHAR [128];
    String delimiter = getLineDelimiter();
    int delimiterSize = cast(int)/*64bit*/delimiter.length;
    auto count = OS.SendMessageA (handle, OS.EM_GETLINECOUNT, 0, 0);
    for (int line=0; line<count; line++) {
        int wcsSize = 0;
        auto linePos = OS.SendMessageA (handle, OS.EM_LINEINDEX, line, 0);
        auto mbcsSize = OS.SendMessageA (handle, OS.EM_LINELENGTH, linePos, 0);
        if (mbcsSize !is 0) {
            if (mbcsSize + delimiterSize > buffer.length) {
                buffer = new CHAR [mbcsSize + delimiterSize];
            }
            //ENDIAN
            buffer [0] = cast(char) (mbcsSize & 0xFF);
            buffer [1] = cast(char) (mbcsSize >> 8);
            mbcsSize = OS.SendMessageA (handle, OS.EM_GETLINE, line, buffer.ptr);
            wcsSize = OS.MultiByteToWideChar (cp, OS.MB_PRECOMPOSED, buffer.ptr, cast(int)/*64bit*/mbcsSize, null, 0);
        }
        if (line - 1 !is count) {
            for (int i=0; i<delimiterSize; i++) {
                buffer [mbcsSize++] = cast(CHAR) delimiter.charAt (i);
            }
            wcsSize += delimiterSize;
        }
        if ((mbcsTotal + mbcsSize) >= mbcsPos) {
            int bufferSize = mbcsPos - mbcsTotal;
            wcsSize = OS.MultiByteToWideChar (cp, OS.MB_PRECOMPOSED, buffer.ptr, bufferSize, null, 0);
            return wcsTotal + wcsSize;
        }
        wcsTotal += wcsSize;
        mbcsTotal += mbcsSize;
    }
    return wcsTotal;
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
    OS.SendMessage (handle, OS.WM_PASTE, 0, 0);
}

override void releaseWidget () {
    super.releaseWidget ();
    message = null;
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
public void removeSelectionListener (SelectionListener listener) {
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
public void removeVerifyListener (VerifyListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Verify, listener);
}

/**
 * Selects all the text in the receiver.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void selectAll () {
    checkWidget ();
    OS.SendMessage (handle, OS.EM_SETSEL, 0, -1);
}

override bool sendKeyEvent (int type, int msg, WPARAM wParam, LPARAM lParam, Event event) {
    if (!super.sendKeyEvent (type, msg, wParam, lParam, event)) {
        return false;
    }
    if ((style & SWT.READ_ONLY) !is 0) return true;
    if (ignoreVerify) return true;
    if (type !is SWT.KeyDown) return true;
    if (msg !is OS.WM_CHAR && msg !is OS.WM_KEYDOWN && msg !is OS.WM_IME_CHAR) {
        return true;
    }
    if (event.character is 0) return true;
    if (!hooks (SWT.Verify) && !filters (SWT.Verify)) return true;
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
    * Feature in Windows.  If the left button is down in
    * the text widget, it refuses the character.  The fix
    * is to detect this case and avoid sending a verify
    * event.
    */
    if (OS.GetKeyState (OS.VK_LBUTTON) < 0) {
        if (handle is OS.GetCapture()) return true;
    }

    /* Verify the character */
    String oldText = "";
    int start, end; //Windows' indices: UTF-16 or Windows 8-bit character set
    OS.SendMessage (handle, OS.EM_GETSEL, &start, &end);
    switch (key) {
        case 0x08:  /* Bs */
            if (start is end ) {
                if (start is 0) return true;
                auto lineStart = OS.SendMessage (handle, OS.EM_LINEINDEX, -1, 0);
                if (start is lineStart) {
                    start = start - cast(int)/*64bit*/DELIMITER.length;
                } else {
                    start = start - 1;
                    if (!OS.IsUnicode && OS.IsDBLocale) {
                        int newStart, newEnd;
                        OS.SendMessage (handle, OS.EM_SETSEL, start, end);
                        OS.SendMessage (handle, OS.EM_GETSEL, &newStart, &newEnd);
                        if (start !is newStart) start = start - 1;
                    }
                }
                start = Math.max (start, 0);
            }
            break;
        case 0x7F:  /* Del */
            if (start is end) {
                int length = OS.GetWindowTextLength (handle);
                if (start is length) return true;
                auto line = OS.SendMessage (handle, OS.EM_LINEFROMCHAR, end, 0);
                auto lineStart = OS.SendMessage (handle, OS.EM_LINEINDEX, line + 1, 0);
                if (end is lineStart - DELIMITER.length) {
                    end = end + cast(int)/*64bit*/DELIMITER.length;
                } else {
                    end = end + 1;
                    if (!OS.IsUnicode && OS.IsDBLocale) {
                        int newStart, newEnd;
                        OS.SendMessage (handle, OS.EM_SETSEL, start, end);
                        OS.SendMessage (handle, OS.EM_GETSEL, &newStart, &newEnd);
                        if (end !is newEnd) end = end + 1;
                    }
                }
                end = Math.min (end, length);
            }
            break;
        case '\r':  /* Return */
            if ((style & SWT.SINGLE) !is 0) return true;
            oldText = DELIMITER;
            break;
        default:    /* Tab and other characters */
            if (key !is '\t' && key < 0x20) return true;
            oldText = [key];
            break;
    }
    String newText = verifyText (oldText, start, end, event);
    if (newText is null) return false;
    if (newText is oldText) return true;
    newText = Display.withCrLf (newText);
    LPCTSTR buffer = StrToTCHARz (getCodePage (), newText);
    OS.SendMessage (handle, OS.EM_SETSEL, start, end);
    /*
    * Feature in Windows.  When an edit control with ES_MULTILINE
    * style that does not have the WS_VSCROLL style is full (i.e.
    * there is no space at the end to draw any more characters),
    * EM_REPLACESEL sends a WM_CHAR with a backspace character
    * to remove any further text that is added.  This is an
    * implementation detail of the edit control that is unexpected
    * and can cause endless recursion when EM_REPLACESEL is sent
    * from a WM_CHAR handler.  The fix is to ignore calling the
    * handler from WM_CHAR.
    */
    ignoreCharacter = true;
    OS.SendMessage (handle, OS.EM_REPLACESEL, 0, cast(void*)buffer);
    ignoreCharacter = false;
    return false;
}

override void setBounds (int x, int y, int width, int height, int flags) {
    /*
    * Feature in Windows.  When the caret is moved,
    * the text widget scrolls to show the new location.
    * This means that the text widget may be scrolled
    * to the right in order to show the caret when the
    * widget is not large enough to show both the caret
    * location and all the text.  Unfortunately, when
    * the text widget is resized such that all the text
    * and the caret could be visible, Windows does not
    * scroll the widget back.  The fix is to resize the
    * text widget, set the selection to the start of the
    * text and then restore the selection.  This will
    * cause the text widget compute the correct scroll
    * position.
    */
    if ((flags & OS.SWP_NOSIZE) is 0 && width !is 0) {
        RECT rect;
        OS.GetWindowRect (handle, &rect);
        auto margins = OS.SendMessage (handle, OS.EM_GETMARGINS, 0, 0);
        int marginWidth = OS.LOWORD (margins) + OS.HIWORD (margins);
        if (rect.right - rect.left <= marginWidth) {
            int start, end;
            OS.SendMessage (handle, OS.EM_GETSEL, &start, &end);
            if (start !is 0 || end !is 0) {
                SetWindowPos (handle, null, x, y, width, height, flags);
                OS.SendMessage (handle, OS.EM_SETSEL, 0, 0);
                OS.SendMessage (handle, OS.EM_SETSEL, start, end);
                return;
            }
        }
    }
    super.setBounds (x, y, width, height, flags);
}

override void setDefaultFont () {
    super.setDefaultFont ();
    setMargins ();
}

/**
 * Sets the double click enabled flag.
 * <p>
 * The double click flag enables or disables the
 * default action of the text widget when the user
 * double clicks.
 * </p><p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept.
 * </p>
 *
 * @param doubleClick the new double click flag
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setDoubleClickEnabled (bool doubleClick) {
    checkWidget ();
    this.doubleClick = doubleClick;
}

/**
 * Sets the echo character.
 * <p>
 * The echo character is the character that is
 * displayed when the user enters text or the
 * text is changed by the programmer. Setting
 * the echo character to '\0' clears the echo
 * character and redraws the original text.
 * If for any reason the echo character is invalid,
 * or if the platform does not allow modification
 * of the echo character, the default echo character
 * for the platform is used.
 * </p>
 *
 * @param echo the new echo character
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setEchoChar (char echo) {
    checkWidget ();
    if ((style & SWT.MULTI) !is 0) return;
    if (echo !is 0) {
        if ((echo = cast(char) Display.wcsToMbcs (echo, getCodePage ())) is 0) echo = '*';
    }
    OS.SendMessage (handle, OS.EM_SETPASSWORDCHAR, echo, 0);
    /*
    * Bug in Windows.  When the password character is changed,
    * Windows does not redraw to show the new password character.
    * The fix is to force a redraw when the character is set.
    */
    OS.InvalidateRect (handle, null, true);
}

/**
 * Sets the editable state.
 *
 * @param editable the new editable state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setEditable (bool editable) {
    checkWidget ();
    style &= ~SWT.READ_ONLY;
    if (!editable) style |= SWT.READ_ONLY;
    OS.SendMessage (handle, OS.EM_SETREADONLY, editable ? 0 : 1, 0);
}

override public void setFont (Font font) {
    checkWidget ();
    super.setFont (font);
    setTabStops (tabs);
    setMargins ();
}

void setMargins () {
    /*
    * Bug in Windows.  When EM_SETCUEBANNER is used to set the
    * banner text, the control does not take into account the
    * margins, causing the first character to be clipped.  The
    * fix is to set the margins to zero.
    */
    if (OS.COMCTL32_MAJOR >= 6) {
        if ((style & SWT.SEARCH) !is 0) {
            OS.SendMessage (handle, OS.EM_SETMARGINS, OS.EC_LEFTMARGIN | OS.EC_RIGHTMARGIN, 0);
        }
    }
}

/**
 * Sets the widget message. When the widget is created
 * with the style <code>SWT.SEARCH</code>, the message text
 * is displayed as a hint for the user, indicating the
 * purpose of the field.
 * <p>
 * Note: This operation is a <em>HINT</em> and is not
 * supported on platforms that do not have this concept.
 * </p>
 *
 * @param message the new message
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.3
 */
public void setMessage (String message) {
    checkWidget ();
    // SWT extension: allow null string
    //if (message is null) error (SWT.ERROR_NULL_ARGUMENT);
    this.message = message;
    if (OS.COMCTL32_MAJOR >= 6) {
        if ((style & SWT.SEARCH) !is 0) {
            int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
            if ((bits & OS.ES_MULTILINE) is 0) {
                OS.SendMessage (handle, OS.EM_SETCUEBANNER, 0, cast(void*)StrToTCHARz( 0, message ));
            }
        }
    }
}

/**
 * Sets the orientation of the receiver, which must be one
 * of the constants <code>SWT.LEFT_TO_RIGHT</code> or <code>SWT.RIGHT_TO_LEFT</code>.
 * <p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept.
 * </p>
 *
 * @param orientation new orientation style
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1.2
 */
public void setOrientation (int orientation) {
    checkWidget();
    static if (OS.IsWinCE) return;
    if (OS.WIN32_VERSION < OS.VERSION (4, 10)) return;
    int flags = SWT.RIGHT_TO_LEFT | SWT.LEFT_TO_RIGHT;
    if ((orientation & flags) is 0 || (orientation & flags) is flags) return;
    style &= ~flags;
    style |= orientation & flags;
    int bits = OS.GetWindowLong (handle, OS.GWL_EXSTYLE);
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        bits |= OS.WS_EX_RTLREADING | OS.WS_EX_LEFTSCROLLBAR;
    } else {
        bits &= ~(OS.WS_EX_RTLREADING | OS.WS_EX_LEFTSCROLLBAR);
    }
    OS.SetWindowLong (handle, OS.GWL_EXSTYLE, bits);
    fixAlignment ();
}

/**
 * Sets the selection.
 * <p>
 * Indexing is zero based.  The range of
 * a selection is from 0..N where N is
 * the number of characters in the widget.
 * </p><p>
 * Text selections are specified in terms of
 * caret positions.  In a text widget that
 * contains N characters, there are N+1 caret
 * positions, ranging from 0..N.  This differs
 * from other functions that address character
 * position such as getText () that use the
 * regular array indexing rules.
 * </p>
 *
 * @param start new caret position
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (int start) {
    checkWidget ();
    if (!OS.IsUnicode && OS.IsDBLocale) start = wcsToMbcsPos (start);
    OS.SendMessage (handle, OS.EM_SETSEL, start, start);
    OS.SendMessage (handle, OS.EM_SCROLLCARET, 0, 0);
}

/**
 * Sets the selection to the range specified
 * by the given start and end indices.
 * <p>
 * Indexing is zero based.  The range of
 * a selection is from 0..N where N is
 * the number of characters in the widget.
 * </p><p>
 * Text selections are specified in terms of
 * caret positions.  In a text widget that
 * contains N characters, there are N+1 caret
 * positions, ranging from 0..N.  This differs
 * from other functions that address character
 * position such as getText () that use the
 * usual array indexing rules.
 * </p>
 *
 * @param start the start of the range
 * @param end the end of the range
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (int start, int end) {
    checkWidget ();
    if (!OS.IsUnicode && OS.IsDBLocale) {
        start = wcsToMbcsPos (start);
        end = wcsToMbcsPos (end);
    }
    OS.SendMessage (handle, OS.EM_SETSEL, start, end);
    OS.SendMessage (handle, OS.EM_SCROLLCARET, 0, 0);
}

override public void setRedraw (bool redraw) {
    checkWidget ();
    super.setRedraw (redraw);
    /*
    * Feature in Windows.  When WM_SETREDRAW is used to turn
    * redraw off, the edit control is not scrolled to show the
    * i-beam.  The fix is to detect that the i-beam has moved
    * while redraw is turned off and force it to be visible
    * when redraw is restored.
    */
    if (drawCount !is 0) return;
    int start, end;
    OS.SendMessage (handle, OS.EM_GETSEL, &start, &end);
    if (!redraw) {
        oldStart = start;  oldEnd = end;
    } else {
        if (oldStart is start && oldEnd is end) return;
        OS.SendMessage (handle, OS.EM_SCROLLCARET, 0, 0);
    }
}

/**
 * Sets the selection to the range specified
 * by the given point, where the x coordinate
 * represents the start index and the y coordinate
 * represents the end index.
 * <p>
 * Indexing is zero based.  The range of
 * a selection is from 0..N where N is
 * the number of characters in the widget.
 * </p><p>
 * Text selections are specified in terms of
 * caret positions.  In a text widget that
 * contains N characters, there are N+1 caret
 * positions, ranging from 0..N.  This differs
 * from other functions that address character
 * position such as getText () that use the
 * usual array indexing rules.
 * </p>
 *
 * @param selection the point
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (Point selection) {
    checkWidget ();
    if (selection is null) error (SWT.ERROR_NULL_ARGUMENT);
    setSelection (selection.x, selection.y);
}

/**
 * Sets the number of tabs.
 * <p>
 * Tab stop spacing is specified in terms of the
 * space (' ') character.  The width of a single
 * tab stop is the pixel width of the spaces.
 * </p>
 *
 * @param tabs the number of tabs
 *
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setTabs (int tabs) {
    checkWidget ();
    if (tabs < 0) return;
    setTabStops (this.tabs = tabs);
}

void setTabStops (int tabs) {
    /*
    * Feature in Windows.  Windows expects the tab spacing in
    * dialog units so we must convert from space widths.  Due
    * to round off error, the tab spacing may not be the exact
    * number of space widths, depending on the font.
    */
    int width = (getTabWidth (tabs) * 4) / OS.LOWORD (OS.GetDialogBaseUnits ());
    OS.SendMessage (handle, OS.EM_SETTABSTOPS, 1, &width);
}

/**
 * Sets the contents of the receiver to the given string. If the receiver has style
 * SINGLE and the argument contains multiple lines of text, the result of this
 * operation is undefined and may vary from platform to platform.
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
    string = Display.withCrLf (string);
    if (hooks (SWT.Verify) || filters (SWT.Verify)) {
        int length = OS.GetWindowTextLength (handle);
        string = verifyText (string, 0, length, null);
        if (string is null) return;
    }
    int limit = cast(int)/*64bit*/OS.SendMessage (handle, OS.EM_GETLIMITTEXT, 0, 0) & 0x7FFFFFFF;
    if (string.length > limit) string = string.substring (0, limit);
    LPCTSTR buffer = StrToTCHARz (getCodePage (), string);
    OS.SetWindowText (handle, buffer);
    /*
    * Bug in Windows.  When the widget is multi line
    * text widget, it does not send a WM_COMMAND with
    * control code EN_CHANGE from SetWindowText () to
    * notify the application that the text has changed.
    * The fix is to send the event.
    */
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    if ((bits & OS.ES_MULTILINE) !is 0) {
        sendEvent (SWT.Modify);
        // widget could be disposed at this point
    }
}

/**
 * Sets the maximum number of characters that the receiver
 * is capable of holding to be the argument.
 * <p>
 * Instead of trying to set the text limit to zero, consider
 * creating a read-only text widget.
 * </p><p>
 * To reset this value to the default, use <code>setTextLimit(Text.LIMIT)</code>.
 * Specifying a limit value larger than <code>Text.LIMIT</code> sets the
 * receiver's limit to <code>Text.LIMIT</code>.
 * </p>
 *
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
 */
public void setTextLimit (int limit) {
    checkWidget ();
    if (limit is 0) error (SWT.ERROR_CANNOT_BE_ZERO);
    OS.SendMessage (handle, OS.EM_SETLIMITTEXT, limit, 0);
}

/**
 * Sets the zero-relative index of the line which is currently
 * at the top of the receiver. This index can change when lines
 * are scrolled or new lines are added and removed.
 *
 * @param index the index of the top item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setTopIndex (int index) {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) return;
    auto count = OS.SendMessage (handle, OS.EM_GETLINECOUNT, 0, 0);
    index = cast(int)/*64bit*/Math.min (Math.max (index, 0), count - 1);
    auto topIndex = OS.SendMessage (handle, OS.EM_GETFIRSTVISIBLELINE, 0, 0);
    OS.SendMessage (handle, OS.EM_LINESCROLL, 0, index - topIndex);
}

/**
 * Shows the selection.
 * <p>
 * If the selection is already showing
 * in the receiver, this method simply returns.  Otherwise,
 * lines are scrolled until the selection is visible.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void showSelection () {
    checkWidget ();
    OS.SendMessage (handle, OS.EM_SCROLLCARET, 0, 0);
}

String verifyText (String string, int start, int end, Event keyEvent) {
    if (ignoreVerify) return string;
    Event event = new Event ();
    event.text = string;
    event.start = start;
    event.end = end;
    if (keyEvent !is null) {
        event.character = keyEvent.character;
        event.keyCode = keyEvent.keyCode;
        event.stateMask = keyEvent.stateMask;
    }
    if (!OS.IsUnicode && OS.IsDBLocale) {
        event.start = mbcsToWcsPos (start);
        event.end = mbcsToWcsPos (end);
    }
    //FIXME: start and end should be converted from UTF-16 to UTF-8
    /*
    * It is possible (but unlikely), that application
    * code could have disposed the widget in the verify
    * event.  If this happens, answer null to cancel
    * the operation.
    */
    sendEvent (SWT.Verify, event);
    if (!event.doit || isDisposed ()) return null;
    return event.text;
}

int wcsToMbcsPos (int wcsPos) {
    if (wcsPos <= 0) return 0;
    if (OS.IsUnicode) return wcsPos;
    int cp = getCodePage ();
    int wcsTotal = 0, mbcsTotal = 0;
    CHAR [] buffer = new CHAR [128];
    String delimiter = getLineDelimiter ();
    int delimiterSize = cast(int)/*64bit*/delimiter.length;
    auto count = OS.SendMessageA (handle, OS.EM_GETLINECOUNT, 0, 0);
    for (int line=0; line<count; line++) {
        int wcsSize = 0;
        auto linePos = OS.SendMessageA (handle, OS.EM_LINEINDEX, line, 0);
        auto mbcsSize = OS.SendMessageA (handle, OS.EM_LINELENGTH, linePos, 0);
        if (mbcsSize !is 0) {
            if (mbcsSize + delimiterSize > buffer.length) {
                buffer = new CHAR [mbcsSize + delimiterSize];
            }
            //ENDIAN
            buffer [0] = cast(char) (mbcsSize & 0xFF);
            buffer [1] = cast(char) (mbcsSize >> 8);
            mbcsSize = OS.SendMessageA (handle, OS.EM_GETLINE, line, buffer.ptr);
            wcsSize = OS.MultiByteToWideChar (cp, OS.MB_PRECOMPOSED, buffer.ptr, cast(int)/*64bit*/mbcsSize, null, 0);
        }
        if (line - 1 !is count) {
            for (int i=0; i<delimiterSize; i++) {
                buffer [mbcsSize++] = cast(byte) delimiter.charAt (i);
            }
            wcsSize += delimiterSize;
        }
        if ((wcsTotal + wcsSize) >= wcsPos) {
            wcsSize = 0;
            int index = 0;
            while (index < mbcsSize) {
                if ((wcsTotal + wcsSize) is wcsPos) {
                    return mbcsTotal + index;
                }
                if (OS.IsDBCSLeadByte (buffer [index++])) index++;
                wcsSize++;
            }
            return mbcsTotal + cast(int)/*64bit*/mbcsSize;
        }
        wcsTotal += wcsSize;
        mbcsTotal += mbcsSize;
    }
    return mbcsTotal;
}

override int widgetStyle () {
    int bits = super.widgetStyle () | OS.ES_AUTOHSCROLL;
    if ((style & SWT.PASSWORD) !is 0) bits |= OS.ES_PASSWORD;
    if ((style & SWT.CENTER) !is 0) bits |= OS.ES_CENTER;
    if ((style & SWT.RIGHT) !is 0) bits |= OS.ES_RIGHT;
    if ((style & SWT.READ_ONLY) !is 0) bits |= OS.ES_READONLY;
    if ((style & SWT.SINGLE) !is 0) {
        /*
        * Feature in Windows.  When a text control is read-only,
        * uses COLOR_3DFACE for the background .  If the text
        * controls single-line and is within a tab folder or
        * some other themed control, using WM_ERASEBKGND and
        * WM_CTRCOLOR to draw the theme background results in
        * pixel corruption.  The fix is to use an ES_MULTILINE
        * text control instead.
        */
        if ((style & SWT.READ_ONLY) !is 0) {
            if ((style & (SWT.BORDER | SWT.H_SCROLL | SWT.V_SCROLL)) is 0) {
                if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
                    bits |= OS.ES_MULTILINE;
                }
            }
        }
        return bits;
    }
    bits |= OS.ES_MULTILINE | OS.ES_NOHIDESEL | OS.ES_AUTOVSCROLL;
    if ((style & SWT.WRAP) !is 0) bits &= ~(OS.WS_HSCROLL | OS.ES_AUTOHSCROLL);
    return bits;
}

override String windowClass () {
    return TCHARsToStr(EditClass);
}

override ptrdiff_t windowProc () {
    return cast(ptrdiff_t)EditProc;
}

override .LRESULT windowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (msg is OS.EM_UNDO) {
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        if ((bits & OS.ES_MULTILINE) is 0) {
            LRESULT result = wmClipboard (OS.EM_UNDO, wParam, lParam);
            if (result !is null) return result.value;
            return callWindowProc (hwnd, OS.EM_UNDO, wParam, lParam);
        }
    }
    if (msg is Display.SWT_RESTORECARET) {
        callWindowProc (hwnd, OS.WM_KILLFOCUS, 0, 0);
        callWindowProc (hwnd, OS.WM_SETFOCUS, 0, 0);
        return 1;
    }
    return super.windowProc (hwnd, msg, wParam, lParam);
}

override LRESULT WM_CHAR (WPARAM wParam, LPARAM lParam) {
    if (ignoreCharacter) return null;
    LRESULT result = super.WM_CHAR (wParam, lParam);
    if (result !is null) return result;

    /*
    * Bug in Windows.  When the user types CTRL and BS
    * in an edit control, a DEL character is generated.
    * Rather than deleting the text, the DEL character
    * is inserted into the control.  The fix is to detect
    * this case and not call the window proc.
    */
    switch (wParam) {
        case SWT.DEL:
            if (OS.GetKeyState (OS.VK_CONTROL) < 0) {
                return LRESULT.ZERO;
            }
            break;
        default:
            break;
    }

    /*
    * Feature in Windows.  For some reason, when the
    * widget is a single line text widget, when the
    * user presses tab, return or escape, Windows beeps.
    * The fix is to look for these keys and not call
    * the window proc.
    */
    if ((style & SWT.SINGLE) !is 0) {
        switch (wParam) {
            case SWT.CR:
                postEvent (SWT.DefaultSelection);
                goto case SWT.TAB;
            case SWT.TAB:
            case SWT.ESC: return LRESULT.ZERO;
            default:
        }
    }
    return result;
}

override LRESULT WM_CLEAR (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_CLEAR (wParam, lParam);
    if (result !is null) return result;
    return wmClipboard (OS.WM_CLEAR, wParam, lParam);
}

override LRESULT WM_CUT (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_CUT (wParam, lParam);
    if (result !is null) return result;
    return wmClipboard (OS.WM_CUT, wParam, lParam);
}

override LRESULT WM_ERASEBKGND (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_ERASEBKGND (wParam, lParam);
    if ((style & SWT.READ_ONLY) !is 0) {
        if ((style & (SWT.BORDER | SWT.H_SCROLL | SWT.V_SCROLL)) is 0) {
            int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
            if ((bits & OS.ES_MULTILINE) !is 0) {
                Control control = findBackgroundControl ();
                if (control is null && background is -1) {
                    if ((state & THEME_BACKGROUND) !is 0) {
                        if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
                            control = findThemeControl ();
                            if (control !is null) {
                                RECT rect;
                                OS.GetClientRect (handle, &rect);
                                fillThemeBackground (cast(HANDLE)wParam, control, &rect);
                                return LRESULT.ONE;
                            }
                        }
                    }
                }
            }
        }
    }
    return result;
}

override LRESULT WM_GETDLGCODE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_GETDLGCODE (wParam, lParam);
    if (result !is null) return result;

    /*
    * Bug in WinCE PPC.  For some reason, sending WM_GETDLGCODE
    * to a multi-line edit control causes it to ignore return and
    * tab keys.  The fix is to return the value which is normally
    * returned by the text window proc on other versions of Windows.
    */
    if (OS.IsPPC) {
        if ((style & SWT.MULTI) !is 0 && (style & SWT.READ_ONLY) is 0 && lParam is 0) {
            return new LRESULT (OS.DLGC_HASSETSEL | OS.DLGC_WANTALLKEYS | OS.DLGC_WANTCHARS);
        }
    }

    /*
    * Feature in Windows.  Despite the fact that the
    * edit control is read only, it still returns a
    * dialog code indicating that it wants all keys.
    * The fix is to detect this case and clear the bits.
    *
    * NOTE: A read only edit control processes arrow keys
    * so DLGC_WANTARROWS should not be cleared.
    */
    if ((style & SWT.READ_ONLY) !is 0) {
        auto code = callWindowProc (handle, OS.WM_GETDLGCODE, wParam, lParam);
        code &= ~(OS.DLGC_WANTALLKEYS | OS.DLGC_WANTTAB);
        return new LRESULT (code);
    }
    return null;
}

override LRESULT WM_IME_CHAR (WPARAM wParam, LPARAM lParam) {

    /* Process a DBCS character */
    Display display = this.display;
    display.lastKey = 0;
    display.lastAscii = cast(int)/*64bit*/wParam;
    display.lastVirtual = display.lastNull = display.lastDead = false;
    if (!sendKeyEvent (SWT.KeyDown, OS.WM_IME_CHAR, wParam, lParam)) {
        return LRESULT.ZERO;
    }

    /*
    * Feature in Windows.  The Windows text widget uses
    * two 2 WM_CHAR's to process a DBCS key instead of
    * using WM_IME_CHAR.  The fix is to allow the text
    * widget to get the WM_CHAR's but ignore sending
    * them to the application.
    */
    ignoreCharacter = true;
    auto result = callWindowProc (handle, OS.WM_IME_CHAR, wParam, lParam);
    MSG msg;
    int flags = OS.PM_REMOVE | OS.PM_NOYIELD | OS.PM_QS_INPUT | OS.PM_QS_POSTMESSAGE;
    while (OS.PeekMessage (&msg, handle, OS.WM_CHAR, OS.WM_CHAR, flags)) {
        OS.TranslateMessage (&msg);
        OS.DispatchMessage (&msg);
    }
    ignoreCharacter = false;

    sendKeyEvent (SWT.KeyUp, OS.WM_IME_CHAR, wParam, lParam);
    // widget could be disposed at this point
    display.lastKey = display.lastAscii = 0;
    return new LRESULT (result);
}

override LRESULT WM_LBUTTONDBLCLK (WPARAM wParam, LPARAM lParam) {
    /*
    * Prevent Windows from processing WM_LBUTTONDBLCLK
    * when double clicking behavior is disabled by not
    * calling the window proc.
    */
    LRESULT result = null;
    sendMouseEvent (SWT.MouseDown, 1, handle, OS.WM_LBUTTONDOWN, wParam, lParam);
    if (!sendMouseEvent (SWT.MouseDoubleClick, 1, handle, OS.WM_LBUTTONDBLCLK, wParam, lParam)) {
        result = LRESULT.ZERO;
    }
    if (!display.captureChanged && !isDisposed ()) {
        if (OS.GetCapture () !is handle) OS.SetCapture (handle);
    }
    if (!doubleClick) return LRESULT.ZERO;

    /*
    * Bug in Windows.  When the last line of text in the
    * widget is double clicked and the line is empty, Windows
    * hides the i-beam then moves it to the first line in
    * the widget but does not scroll to show the user.
    * If the user types without clicking the mouse, invalid
    * characters are displayed at the end of each line of
    * text in the widget.  The fix is to detect this case
    * and avoid calling the window proc.
    */
    int start, end;
    OS.SendMessage (handle, OS.EM_GETSEL, &start, &end);
    if (start  is end ) {
        int length = OS.GetWindowTextLength (handle);
        if (length is start) {
            auto code = OS.SendMessage (handle, OS.EM_LINELENGTH, length, 0);
            if (code is 0) return LRESULT.ZERO;
        }
    }
    return result;
}

override LRESULT WM_LBUTTONDOWN (WPARAM wParam, LPARAM lParam) {
    static if( OS.IsWinCE )
    if (OS.IsPPC) {
        LRESULT result = null;
        Display display = this.display;
        display.captureChanged = false;
        bool dispatch = sendMouseEvent (SWT.MouseDown, 1, handle, OS.WM_LBUTTONDOWN, wParam, lParam);
        /*
        * Note: On WinCE PPC, only attempt to recognize the gesture for
        * a context menu when the control contains a valid menu or there
        * are listeners for the MenuDetect event.
        *
        * Note: On WinCE PPC, the gesture that brings up a popup menu
        * on the text widget must keep the current text selection.  As a
        * result, the window proc is only called if the menu is not shown.
        */
        bool hasMenu = menu !is null && !menu.isDisposed ();
        if (hasMenu || hooks (SWT.MenuDetect)) {
            int x = OS.GET_X_LPARAM (lParam);
            int y = OS.GET_Y_LPARAM (lParam);
            SHRGINFO shrg;
            shrg.cbSize = SHRGINFO.sizeof;
            shrg.hwndClient = handle;
            shrg.ptDown.x = x;
            shrg.ptDown.y = y;
            shrg.dwFlags = OS.SHRG_RETURNCMD;
            int type = OS.SHRecognizeGesture (&shrg);
            if (type is OS.GN_CONTEXTMENU) {
                showMenu (x, y);
                return LRESULT.ONE;
            }
        }
        if (dispatch) {
            result = new LRESULT (callWindowProc (handle, OS.WM_LBUTTONDOWN, wParam, lParam));
        } else {
            result = LRESULT.ZERO;
        }
        if (!display.captureChanged && !isDisposed ()) {
            if (OS.GetCapture () !is handle) OS.SetCapture (handle);
        }
        return result;
    }
    return super.WM_LBUTTONDOWN (wParam, lParam);
}

override LRESULT WM_PASTE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_PASTE (wParam, lParam);
    if (result !is null) return result;
    return wmClipboard (OS.WM_PASTE, wParam, lParam);
}

override LRESULT WM_UNDO (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_UNDO (wParam, lParam);
    if (result !is null) return result;
    return wmClipboard (OS.WM_UNDO, wParam, lParam);
}

LRESULT wmClipboard (int msg, WPARAM wParam, LPARAM lParam) {
    if ((style & SWT.READ_ONLY) !is 0) return null;
    if (!hooks (SWT.Verify) && !filters (SWT.Verify)) return null;
    bool call = false;
    int start, end;
    String newText = null;
    switch (msg) {
        case OS.WM_CLEAR:
        case OS.WM_CUT:
            OS.SendMessage (handle, OS.EM_GETSEL, &start, &end);
            if (start !is end ) {
                newText = "";
                call = true;
            }
            break;
        case OS.WM_PASTE:
            OS.SendMessage (handle, OS.EM_GETSEL, start, end);
            newText = getClipboardText ();
            break;
        case OS.EM_UNDO:
        case OS.WM_UNDO:
            if (OS.SendMessage (handle, OS.EM_CANUNDO, 0, 0) !is 0) {
                ignoreModify = ignoreCharacter = true;
                OS.SendMessage (handle, OS.EM_GETSEL, &start, &end);
                callWindowProc (handle, msg, wParam, lParam);
                int length = OS.GetWindowTextLength (handle);
                int newStart, newEnd;
                OS.SendMessage (handle, OS.EM_GETSEL, &newStart, &newEnd);
                if (length !is 0 && newStart !is newEnd) {
                    TCHAR[] buffer = NewTCHARs (getCodePage (), length + 1);
                    OS.GetWindowText (handle, buffer.ptr, length + 1);
                    newText = TCHARsToStr( buffer[ newStart .. newEnd ] );
                } else {
                    newText = "";
                }
                callWindowProc (handle, msg, wParam, lParam);
                ignoreModify = ignoreCharacter = false;
            }
            break;
        default:
    }
    if (newText !is null) {
        String oldText = newText;
        newText = verifyText (newText, start, end, null);
        if (newText is null) return LRESULT.ZERO;
        if (newText !=/*eq*/oldText) {
            if (call) {
                callWindowProc (handle, msg, wParam, lParam);
            }
            newText = Display.withCrLf (newText);
            LPCTSTR buffer = StrToTCHARz(getCodePage (), newText);
            /*
            * Feature in Windows.  When an edit control with ES_MULTILINE
            * style that does not have the WS_VSCROLL style is full (i.e.
            * there is no space at the end to draw any more characters),
            * EM_REPLACESEL sends a WM_CHAR with a backspace character
            * to remove any further text that is added.  This is an
            * implementation detail of the edit control that is unexpected
            * and can cause endless recursion when EM_REPLACESEL is sent
            * from a WM_CHAR handler.  The fix is to ignore calling the
            * handler from WM_CHAR.
            */
            ignoreCharacter = true;
            OS.SendMessage (handle, OS.EM_REPLACESEL, 0, cast(void*)buffer);
            ignoreCharacter = false;
            return LRESULT.ZERO;
        }
    }
    if (msg is OS.WM_UNDO) {
        ignoreVerify = ignoreCharacter = true;
        callWindowProc (handle, OS.WM_UNDO, wParam, lParam);
        ignoreVerify = ignoreCharacter = false;
        return LRESULT.ONE;
    }
    return null;
}

override LRESULT wmColorChild (WPARAM wParam, LPARAM lParam) {
    if ((style & SWT.READ_ONLY) !is 0) {
        if ((style & (SWT.BORDER | SWT.H_SCROLL | SWT.V_SCROLL)) is 0) {
            int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
            if ((bits & OS.ES_MULTILINE) !is 0) {
                Control control = findBackgroundControl ();
                if (control is null && background is -1) {
                    if ((state & THEME_BACKGROUND) !is 0) {
                        if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
                            control = findThemeControl ();
                            if (control !is null) {
                                OS.SetTextColor (cast(HANDLE) wParam, getForegroundPixel ());
                                OS.SetBkColor (cast(HANDLE) wParam, getBackgroundPixel ());
                                OS.SetBkMode (cast(HANDLE) wParam, OS.TRANSPARENT);
                                return new LRESULT (OS.GetStockObject (OS.NULL_BRUSH));
                            }
                        }
                    }
                }
            }
        }
    }
    return super.wmColorChild (wParam, lParam);
}

override LRESULT wmCommandChild (WPARAM wParam, LPARAM lParam) {
    int code = OS.HIWORD (wParam);
    switch (code) {
        case OS.EN_CHANGE:
            if (findImageControl () !is null) {
                OS.InvalidateRect (handle, null, true);
            }
            if (ignoreModify) break;
            /*
            * It is possible (but unlikely), that application
            * code could have disposed the widget in the modify
            * event.  If this happens, end the processing of the
            * Windows message by returning zero as the result of
            * the window proc.
            */
            sendEvent (SWT.Modify);
            if (isDisposed ()) return LRESULT.ZERO;
            break;
        case OS.EN_ALIGN_LTR_EC:
            style &= ~SWT.RIGHT_TO_LEFT;
            style |= SWT.LEFT_TO_RIGHT;
            fixAlignment ();
            break;
        case OS.EN_ALIGN_RTL_EC:
            style &= ~SWT.LEFT_TO_RIGHT;
            style |= SWT.RIGHT_TO_LEFT;
            fixAlignment ();
            break;
        default:
    }
    return super.wmCommandChild (wParam, lParam);
}

}

