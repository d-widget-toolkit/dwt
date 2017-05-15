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
module org.eclipse.swt.widgets.Combo;

import org.eclipse.swt.widgets.Composite;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.VerifyListener;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Display;

import java.lang.all;

/**
 * Instances of this class are controls that allow the user
 * to choose an item from a list of items, or optionally
 * enter a new value by typing it into an editable text
 * field. Often, <code>Combo</code>s are used in the same place
 * where a single selection <code>List</code> widget could
 * be used but space is limited. A <code>Combo</code> takes
 * less space than a <code>List</code> widget and shows
 * similar information.
 * <p>
 * Note: Since <code>Combo</code>s can contain both a list
 * and an editable text field, it is possible to confuse methods
 * which access one versus the other (compare for example,
 * <code>clearSelection()</code> and <code>deselectAll()</code>).
 * The API documentation is careful to indicate either "the
 * receiver's list" or the "the receiver's text field" to
 * distinguish between the two cases.
 * </p><p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add children to it, or set a layout on it.
 * </p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>DROP_DOWN, READ_ONLY, SIMPLE</dd>
 * <dt><b>Events:</b></dt>
 * <dd>DefaultSelection, Modify, Selection, Verify</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles DROP_DOWN and SIMPLE may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see List
 * @see <a href="http://www.eclipse.org/swt/snippets/#combo">Combo snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class Combo : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.dragDetect dragDetect;
    alias Composite.sendKeyEvent sendKeyEvent;
    alias Composite.setBackgroundImage setBackgroundImage;
    alias Composite.setBounds setBounds;
    alias Composite.setToolTipText setToolTipText;

    private static Combo pThis;
    bool noSelection, ignoreDefaultSelection, ignoreCharacter, ignoreModify, ignoreResize;
    HHOOK cbtHook;
    int scrollWidth, visibleCount = 5;

    /**
     * the operating system limit for the number of characters
     * that the text field in an instance of this class can hold
     */
    private static int LIMIT_ = 0;

    /*
     * These values can be different on different platforms.
     * Therefore they are not initialized in the declaration
     * to stop the compiler from inlining.
     */
    public static int LIMIT(){
        if( LIMIT_ is 0 ){
            synchronized {
                LIMIT_ = OS.IsWinNT ? 0x7FFFFFFF : 0x7FFF;
            }
        }
        return LIMIT_;
    }
    /*
     * These are the undocumented control id's for the children of
     * a combo box.  Since there are no constants for these values,
     * they may change with different versions of Windows (but have
     * been the same since Windows 3.0).
     */
    static const int CBID_LIST = 1000;
    static const int CBID_EDIT = 1001;
    static /*final*/ WNDPROC EditProc, ListProc;

    mixin(gshared!(`static /+const+/ WNDPROC ComboProc;`));
    static const TCHAR* ComboClass = "COMBOBOX\0";

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
            OS.GetClassInfo (null, ComboClass, &lpWndClass);
            ComboProc = lpWndClass.lpfnWndProc;
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
 * @see SWT#DROP_DOWN
 * @see SWT#READ_ONLY
 * @see SWT#SIMPLE
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    static_this();
    super (parent, checkStyle (style));
    /* This code is intentionally commented */
    //if ((style & SWT.H_SCROLL) !is 0) this.style |= SWT.H_SCROLL;
    this.style |= SWT.H_SCROLL;
}

/**
 * Adds the argument to the end of the receiver's list.
 *
 * @param string the new item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #add(String,int)
 */
public void add (String string) {
    checkWidget ();
    // SWT extension: allow null string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    auto buffer = StrToTCHARs( getCodePage(), string, true );
    auto result = OS.SendMessage (handle, OS.CB_ADDSTRING, 0, cast(void*)buffer.ptr );
    if (result is OS.CB_ERR) error (SWT.ERROR_ITEM_NOT_ADDED);
    if (result is OS.CB_ERRSPACE) error (SWT.ERROR_ITEM_NOT_ADDED);
    if ((style & SWT.H_SCROLL) !is 0) setScrollWidth (buffer, true);
}

/**
 * Adds the argument to the receiver's list at the given
 * zero-relative index.
 * <p>
 * Note: To add an item at the end of the list, use the
 * result of calling <code>getItemCount()</code> as the
 * index or use <code>add(String)</code>.
 * </p>
 *
 * @param string the new item
 * @param index the index for the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #add(String)
 */
public void add (String string, int index) {
    checkWidget ();
    // SWT extension: allow null string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    auto count = OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
    if (!(0 <= index && index <= count)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    auto buffer = StrToTCHARs( getCodePage(), string, true );
    auto result = OS.SendMessage (handle, OS.CB_INSERTSTRING, index, cast(void*)buffer.ptr);
    if (result is OS.CB_ERRSPACE || result is OS.CB_ERR) {
        error (SWT.ERROR_ITEM_NOT_ADDED);
    }
    if ((style & SWT.H_SCROLL) !is 0) setScrollWidth (buffer, true);
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
 * be notified when the user changes the receiver's selection, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the user changes the combo's list selection.
 * <code>widgetDefaultSelected</code> is typically called when ENTER is pressed the combo's text area.
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
 *
 * @since 3.1
 */
public void addVerifyListener (VerifyListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Verify, typedListener);
}

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    if (hwnd is handle) {
        .LRESULT result = 0;
        switch (msg) {
            case OS.WM_SIZE: {
                ignoreResize = true;
                result = OS.CallWindowProc (ComboProc, hwnd, msg, wParam, lParam);
                ignoreResize = false;
                return result;
            default:
            }
        }
        return OS.CallWindowProc( ComboProc, hwnd, msg, wParam, lParam);
    }
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwnd is hwndText) {
        return OS.CallWindowProc( EditProc, hwnd, msg, wParam, lParam);
    }
    auto hwndList = OS.GetDlgItem (handle, CBID_LIST);
    if (hwnd is hwndList) {
        return OS.CallWindowProc( ListProc, hwnd, msg, wParam, lParam);
    }
    return OS.DefWindowProc (hwnd, msg, wParam, lParam);
}

private static extern(Windows) .LRESULT CBTFunc (int nCode, WPARAM wParam, LPARAM lParam) {
    return pThis.CBTProc( nCode, wParam, lParam );
}

.LRESULT CBTProc (int nCode, WPARAM wParam, LPARAM lParam) {
    if (nCode is OS.HCBT_CREATEWND) {
        TCHAR[128] buffer = 0;
        OS.GetClassName (cast(HANDLE)wParam, buffer.ptr, buffer.length );
        String className = TCHARzToStr(buffer.ptr);
        if (className=="Edit" || className=="EDIT") { //$NON-NLS-1$  //$NON-NLS-2$
            int bits = OS.GetWindowLong (cast(HANDLE)wParam, OS.GWL_STYLE);
            OS.SetWindowLong (cast(HANDLE)wParam, OS.GWL_STYLE, bits & ~OS.ES_NOHIDESEL);
        }
    }
    return OS.CallNextHookEx (cbtHook, nCode, wParam, lParam);
}

override bool checkHandle (HWND hwnd) {
    return hwnd is handle || hwnd is OS.GetDlgItem (handle, CBID_EDIT) || hwnd is OS.GetDlgItem (handle, CBID_LIST);
}

override protected void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

static int checkStyle (int style) {
    /*
     * Feature in Windows.  It is not possible to create
     * a combo box that has a border using Windows style
     * bits.  All combo boxes draw their own border and
     * do not use the standard Windows border styles.
     * Therefore, no matter what style bits are specified,
     * clear the BORDER bits so that the SWT style will
     * match the Windows widget.
     *
     * The Windows behavior is currently implemented on
     * all platforms.
     */
    style &= ~SWT.BORDER;

    /*
     * Even though it is legal to create this widget
     * with scroll bars, they serve no useful purpose
     * because they do not automatically scroll the
     * widget's client area.  The fix is to clear
     * the SWT style.
     */
    style &= ~(SWT.H_SCROLL | SWT.V_SCROLL);
    style = checkBits (style, SWT.DROP_DOWN, SWT.SIMPLE, 0, 0, 0, 0);
    if ((style & SWT.SIMPLE) !is 0) return style & ~SWT.READ_ONLY;
    return style;
}

/**
 * Sets the selection in the receiver's text field to an empty
 * selection starting just before the first character. If the
 * text field is editable, this has the effect of placing the
 * i-beam at the start of the text.
 * <p>
 * Note: To clear the selected items in the receiver's list,
 * use <code>deselectAll()</code>.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #deselectAll
 */
public void clearSelection () {
    checkWidget ();
    OS.SendMessage (handle, OS.CB_SETEDITSEL, 0, -1);
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = 0, height = 0;
    if (wHint is SWT.DEFAULT) {
        HFONT newFont, oldFont;
        auto hDC = OS.GetDC (handle);
        newFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
        if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
        auto count = OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
        RECT rect;
        int flags = OS.DT_CALCRECT | OS.DT_NOPREFIX;
        if ((style & SWT.READ_ONLY) is 0) flags |= OS.DT_EDITCONTROL;
        int length_ = OS.GetWindowTextLength (handle);
        int cp = getCodePage ();
        TCHAR[] buffer = new TCHAR[ length_ + 1];
        buffer[] = 0;
        OS.GetWindowText (handle, buffer.ptr, length_ + 1);
        OS.DrawText (hDC, buffer.ptr, length_, &rect, flags);
        width = Math.max (width, rect.right - rect.left);
        if ((style & SWT.H_SCROLL) !is 0) {
            width = Math.max (width, scrollWidth);
        } else {
            for (int i=0; i<count; i++) {
                length_ = cast(int)/*64bit*/OS.SendMessage (handle, OS.CB_GETLBTEXTLEN, i, 0);
                if (length_ !is OS.CB_ERR) {
                    if (length_ + 1 > buffer.length ) buffer = new TCHAR[ length_ + 1 ], buffer[] =0;
                    auto result = OS.SendMessage (handle, OS.CB_GETLBTEXT, i, buffer.ptr);
                    if (result !is OS.CB_ERR) {
                        OS.DrawText (hDC, buffer.ptr, length_, &rect, flags);
                        width = Math.max (width, rect.right - rect.left);
                    }
                }
            }
        }
        if (newFont !is null) OS.SelectObject (hDC, oldFont);
        OS.ReleaseDC (handle, hDC);
    }
    if (hHint is SWT.DEFAULT) {
        if ((style & SWT.SIMPLE) !is 0) {
            int count = cast(int)/*64bit*/OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
            int itemHeight = cast(int)/*64bit*/OS.SendMessage (handle, OS.CB_GETITEMHEIGHT, 0, 0);
            height = count * itemHeight;
        }
    }
    if (width is 0) width = DEFAULT_WIDTH;
    if (height is 0) height = DEFAULT_HEIGHT;
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    if ((style & SWT.READ_ONLY) !is 0) {
        width += 8;
    } else {
        auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
        if (hwndText !is null) {
            auto margins = OS.SendMessage (hwndText, OS.EM_GETMARGINS, 0, 0);
            int marginWidth = OS.LOWORD (margins) + OS.HIWORD (margins);
            width += marginWidth + 3;
        }
    }
    COMBOBOXINFO pcbi;
    pcbi.cbSize = COMBOBOXINFO.sizeof;
    if (((style & SWT.SIMPLE) is 0) && !OS.IsWinCE && OS.GetComboBoxInfo (handle, &pcbi)) {
        width += pcbi.rcItem.left + (pcbi.rcButton.right - pcbi.rcButton.left);
        height = (pcbi.rcButton.bottom - pcbi.rcButton.top) + pcbi.rcButton.top * 2;
    } else {
        int border = OS.GetSystemMetrics (OS.SM_CXEDGE);
        width += OS.GetSystemMetrics (OS.SM_CXVSCROLL) + border * 2;
        int textHeight = cast(int)/*64bit*/OS.SendMessage (handle, OS.CB_GETITEMHEIGHT, -1, 0);
        if ((style & SWT.DROP_DOWN) !is 0) {
            height = textHeight + 6;
        } else {
            height += textHeight + 10;
        }
    }
    if ((style & SWT.SIMPLE) !is 0 && (style & SWT.H_SCROLL) !is 0) {
        height += OS.GetSystemMetrics (OS.SM_CYHSCROLL);
    }
    return new Point (width, height);
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
 *
 * @since 2.1
 */
public void copy () {
    checkWidget ();
    OS.SendMessage (handle, OS.WM_COPY, 0, 0);
}

override void createHandle () {
    /*
    * Feature in Windows.  When the selection changes in a combo box,
    * Windows draws the selection, even when the combo box does not
    * have focus.  Strictly speaking, this is the correct Windows
    * behavior because the combo box sets ES_NOHIDESEL on the text
    * control that it creates.  Despite this, it looks strange because
    * Windows also clears the selection and selects all the text when
    * the combo box gets focus.  The fix is use the CBT hook to clear
    * the ES_NOHIDESEL style bit when the text control is created.
    */
    if (OS.IsWinCE || (style & (SWT.READ_ONLY | SWT.SIMPLE)) !is 0) {
        super.createHandle ();
    } else {
        int threadId = OS.GetCurrentThreadId ();
        //Callback cbtCallback = new Callback (this, "CBTProc", 3); //$NON-NLS-1$
        //int cbtProc = cbtCallback.getAddress ();
        //if (cbtProc is 0) error (SWT.ERROR_NO_MORE_CALLBACKS);
        pThis = this;
        cbtHook = OS.SetWindowsHookEx (OS.WH_CBT, &CBTFunc, null, threadId);
        super.createHandle ();
        if (cbtHook !is null) OS.UnhookWindowsHookEx (cbtHook);
        pThis = null;
        //cbtHook = 0;
        //cbtCallback.dispose ();
    }
    state &= ~(CANVAS | THEME_BACKGROUND);

    /* Get the text and list window procs */
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwndText !is null && EditProc is null) {
        EditProc = cast(WNDPROC) OS.GetWindowLongPtr (hwndText, OS.GWLP_WNDPROC);
    }
    auto hwndList = OS.GetDlgItem (handle, CBID_LIST);
    if (hwndList !is null && ListProc is null) {
        ListProc = cast(WNDPROC) OS.GetWindowLongPtr (hwndList, OS.GWLP_WNDPROC);
    }

    /*
    * Bug in Windows.  If the combo box has the CBS_SIMPLE style,
    * the list portion of the combo box is not drawn correctly the
    * first time, causing pixel corruption.  The fix is to ensure
    * that the combo box has been resized more than once.
    */
    if ((style & SWT.SIMPLE) !is 0) {
        int flags = OS.SWP_NOZORDER | OS.SWP_DRAWFRAME | OS.SWP_NOACTIVATE;
        SetWindowPos (handle, null, 0, 0, 0x3FFF, 0x3FFF, flags);
        SetWindowPos (handle, null, 0, 0, 0, 0, flags);
    }
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
 *
 * @since 2.1
 */
public void cut () {
    checkWidget ();
    if ((style & SWT.READ_ONLY) !is 0) return;
    OS.SendMessage (handle, OS.WM_CUT, 0, 0);
}

override int defaultBackground () {
    return OS.GetSysColor (OS.COLOR_WINDOW);
}

override void deregister () {
    super.deregister ();
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwndText !is null) display.removeControl (hwndText);
    auto hwndList = OS.GetDlgItem (handle, CBID_LIST);
    if (hwndList !is null) display.removeControl (hwndList);
}

/**
 * Deselects the item at the given zero-relative index in the receiver's
 * list.  If the item at the index was already deselected, it remains
 * deselected. Indices that are out of range are ignored.
 *
 * @param index the index of the item to deselect
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void deselect (int index) {
    checkWidget ();
    auto selection = OS.SendMessage (handle, OS.CB_GETCURSEL, 0, 0);
    if (index !is selection) return;
    OS.SendMessage (handle, OS.CB_SETCURSEL, -1, 0);
    sendEvent (SWT.Modify);
    // widget could be disposed at this point
}

/**
 * Deselects all selected items in the receiver's list.
 * <p>
 * Note: To clear the selection in the receiver's text field,
 * use <code>clearSelection()</code>.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #clearSelection
 */
public void deselectAll () {
    checkWidget ();
    OS.SendMessage (handle, OS.CB_SETCURSEL, -1, 0);
    sendEvent (SWT.Modify);
    // widget could be disposed at this point
}

override bool dragDetect (HWND hwnd, int x, int y, bool filter, bool [] detect, bool [] consume) {
    if (filter && (style & SWT.READ_ONLY) is 0) {
        auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
        if (hwndText !is null) {
            int start, end;
            OS.SendMessage (handle, OS.CB_GETEDITSEL, &start, &end);
            if (start !is end ) {
                auto lParam = OS.MAKELPARAM (x, y);
                int position = OS.LOWORD (OS.SendMessage (hwndText, OS.EM_CHARFROMPOS, 0, lParam));
                if (start <= position && position < end ) {
                    if (super.dragDetect (hwnd, x, y, filter, detect, consume)) {
                        if (consume !is null) consume [0] = true;
                        return true;
                    }
                }
            }
            return false;
        }
    }
    return super.dragDetect (hwnd, x, y, filter, detect, consume);
}

/**
 * Returns the item at the given, zero-relative index in the
 * receiver's list. Throws an exception if the index is out
 * of range.
 *
 * @param index the index of the item to return
 * @return the item at the given index
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getItem (int index) {
    checkWidget ();
    auto length_ = OS.SendMessage (handle, OS.CB_GETLBTEXTLEN, index, 0);
    if (length_ !is OS.CB_ERR) {
        TCHAR[] buffer = new TCHAR[ length_ + 1];
        auto result = OS.SendMessage (handle, OS.CB_GETLBTEXT, index, buffer.ptr);
        if (result !is OS.CB_ERR) return TCHARzToStr( buffer.ptr );
    }
    auto count = OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
    if (0 <= index && index < count) error (SWT.ERROR_CANNOT_GET_ITEM);
    error (SWT.ERROR_INVALID_RANGE);
    return "";
}

/**
 * Returns the number of items contained in the receiver's list.
 *
 * @return the number of items
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getItemCount () {
    checkWidget ();
    int count = cast(int)/*64bit*/OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
    if (count is OS.CB_ERR) error (SWT.ERROR_CANNOT_GET_COUNT);
    return count;
}

/**
 * Returns the height of the area which would be used to
 * display <em>one</em> of the items in the receiver's list.
 *
 * @return the height of one item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getItemHeight () {
    checkWidget ();
    int result = cast(int)/*64bit*/OS.SendMessage (handle, OS.CB_GETITEMHEIGHT, 0, 0);
    if (result is OS.CB_ERR) error (SWT.ERROR_CANNOT_GET_ITEM_HEIGHT);
    return result;
}

/**
 * Returns a (possibly empty) array of <code>String</code>s which are
 * the items in the receiver's list.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the items in the receiver's list
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String [] getItems () {
    checkWidget ();
    int count = getItemCount ();
    String [] result = new String [count];
    for (int i=0; i<count; i++) result [i] = getItem (i);
    return result;
}

/**
 * Returns <code>true</code> if the receiver's list is visible,
 * and <code>false</code> otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, this method
 * may still indicate that it is considered visible even though
 * it may not actually be showing.
 * </p>
 *
 * @return the receiver's list's visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public bool getListVisible () {
    checkWidget ();
    if ((style & SWT.DROP_DOWN) !is 0) {
        return OS.SendMessage (handle, OS.CB_GETDROPPEDSTATE, 0, 0) !is 0;
    }
    return true;
}

override String getNameText () {
    return getText ();
}

/**
 * Marks the receiver's list as visible if the argument is <code>true</code>,
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
 *
 * @since 3.4
 */
public void setListVisible (bool visible) {
    checkWidget ();
    OS.SendMessage (handle, OS.CB_SHOWDROPDOWN, visible ? 1 : 0, 0);
}

/**
 * Returns the orientation of the receiver.
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
 * Returns a <code>Point</code> whose x coordinate is the
 * character position representing the start of the selection
 * in the receiver's text field, and whose y coordinate is the
 * character position representing the end of the selection.
 * An "empty" selection is indicated by the x and y coordinates
 * having the same value.
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
    if ((style & SWT.DROP_DOWN) !is 0 && (style & SWT.READ_ONLY) !is 0) {
        return new Point (0, OS.GetWindowTextLength (handle));
    }
    int start, end;
    OS.SendMessage (handle, OS.CB_GETEDITSEL, &start, &end);
    if (!OS.IsUnicode && OS.IsDBLocale) {
        start = mbcsToWcsPos (start);
        end = mbcsToWcsPos (end);
    }
    return new Point (start, end);
}

/**
 * Returns the zero-relative index of the item which is currently
 * selected in the receiver's list, or -1 if no item is selected.
 *
 * @return the index of the selected item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSelectionIndex () {
    checkWidget ();
    if (noSelection) return -1;
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.CB_GETCURSEL, 0, 0);
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
 */
public String getText () {
    checkWidget ();
    int length_ = OS.GetWindowTextLength (handle);
    if (length_ is 0) return "";
    TCHAR[] buffer = new TCHAR[ length_ + 1];
    OS.GetWindowText (handle, buffer.ptr, length_ + 1);
    return TCHARzToStr( buffer.ptr );
}

/**
 * Returns the height of the receivers's text field.
 *
 * @return the text height
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getTextHeight () {
    checkWidget ();
    COMBOBOXINFO pcbi;
    pcbi.cbSize = COMBOBOXINFO.sizeof;
    if (((style & SWT.SIMPLE) is 0) && !OS.IsWinCE && OS.GetComboBoxInfo (handle, &pcbi)) {
        return (pcbi.rcButton.bottom - pcbi.rcButton.top) + pcbi.rcButton.top * 2;
    }
    int result = cast(int)/*64bit*/OS.SendMessage (handle, OS.CB_GETITEMHEIGHT, -1, 0);
    if (result is OS.CB_ERR) error (SWT.ERROR_CANNOT_GET_ITEM_HEIGHT);
    return (style & SWT.DROP_DOWN) !is 0 ? result + 6 : result + 10;
}

/**
 * Returns the maximum number of characters that the receiver's
 * text field is capable of holding. If this has not been changed
 * by <code>setTextLimit()</code>, it will be the constant
 * <code>Combo.LIMIT</code>.
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
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwndText is null) return LIMIT;
    return OS.SendMessage (hwndText, OS.EM_GETLIMITTEXT, 0, 0) & 0x7FFFFFFF;
}

/**
 * Gets the number of items that are visible in the drop
 * down portion of the receiver's list.
 * <p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept.
 * </p>
 *
 * @return the number of items that are visible
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public int getVisibleItemCount () {
    checkWidget ();
    return visibleCount;
}

override bool hasFocus () {
    auto hwndFocus = OS.GetFocus ();
    if (hwndFocus is handle) return true;
    if (hwndFocus is null) return false;
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwndFocus is hwndText) return true;
    auto hwndList = OS.GetDlgItem (handle, CBID_LIST);
    if (hwndFocus is hwndList) return true;
    return false;
}

/**
 * Searches the receiver's list starting at the first item
 * (index 0) until an item is found that is equal to the
 * argument, and returns the index of that item. If no item
 * is found, returns -1.
 *
 * @param string the search item
 * @return the index of the item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (String string) {
    return indexOf (string, 0);
}

/**
 * Searches the receiver's list starting at the given,
 * zero-relative index until an item is found that is equal
 * to the argument, and returns the index of that item. If
 * no item is found or the starting index is out of range,
 * returns -1.
 *
 * @param string the search item
 * @param start the zero-relative index at which to begin the search
 * @return the index of the item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (String string, int start) {
    checkWidget ();
    // SWT externsion: allow null string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);

    /*
    * Bug in Windows.  For some reason, CB_FINDSTRINGEXACT
    * will not find empty strings even though it is legal
    * to insert an empty string into a combo.  The fix is
    * to search the combo, an item at a time.
    */
    if (string.length  is 0) {
        int count = getItemCount ();
        for (int i=start; i<count; i++) {
            if (string.equals (getItem (i))) return i;
        }
        return -1;
    }

    /* Use CB_FINDSTRINGEXACT to search for the item */
    auto count = OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
    if (!(0 <= start && start < count)) return -1;
    int index = start - 1, last = 0;
    LPCTSTR buffer = StrToTCHARz( string );
    do {
        index = cast(int)/*64bit*/OS.SendMessage (handle, OS.CB_FINDSTRINGEXACT, last = index, cast(void*)buffer);
        if (index is OS.CB_ERR || index <= last) return -1;
    } while (string!=/*eq*/getItem (index));
    return index;
}

int mbcsToWcsPos (int mbcsPos) {
    if (mbcsPos <= 0) return 0;
    if (OS.IsUnicode) return mbcsPos;
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwndText is null) return mbcsPos;
    int mbcsSize = OS.GetWindowTextLengthA (hwndText);
    if (mbcsSize is 0) return 0;
    if (mbcsPos >= mbcsSize) return mbcsSize;
    CHAR [] buffer = new CHAR [mbcsSize + 1];
    buffer[] = 0;
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
 *
 * @since 2.1
 */
public void paste () {
    checkWidget ();
    if ((style & SWT.READ_ONLY) !is 0) return;
    OS.SendMessage (handle, OS.WM_PASTE, 0, 0);
}

override void register () {
    super.register ();
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwndText !is null) display.addControl (hwndText, this);
    auto hwndList = OS.GetDlgItem (handle, CBID_LIST);
    if (hwndList !is null) display.addControl (hwndList, this);
}

/**
 * Removes the item from the receiver's list at the given
 * zero-relative index.
 *
 * @param index the index for the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void remove (int index) {
    checkWidget ();
    remove (index, true);
}

void remove (int index, bool notify) {
    TCHAR[] buffer = null;
    if ((style & SWT.H_SCROLL) !is 0) {
        auto length_ = OS.SendMessage (handle, OS.CB_GETLBTEXTLEN, index, 0);
        if (length_ is OS.CB_ERR) {
            auto count = OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
            if (0 <= index && index < count) error (SWT.ERROR_ITEM_NOT_REMOVED);
            error (SWT.ERROR_INVALID_RANGE);
        }
        buffer = new TCHAR[ length_ + 1];
        auto result = OS.SendMessage (handle, OS.CB_GETLBTEXT, index, buffer.ptr);
        if (result is OS.CB_ERR) {
            auto count = OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
            if (0 <= index && index < count) error (SWT.ERROR_ITEM_NOT_REMOVED);
            error (SWT.ERROR_INVALID_RANGE);
        }
    }
    int length_ = OS.GetWindowTextLength (handle);
    auto code = OS.SendMessage (handle, OS.CB_DELETESTRING, index, 0);
    if (code is OS.CB_ERR) {
        auto count = OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
        if (0 <= index && index < count) error (SWT.ERROR_ITEM_NOT_REMOVED);
        error (SWT.ERROR_INVALID_RANGE);
    }
    if ((style & SWT.H_SCROLL) !is 0) setScrollWidth (cast(StringT)buffer, true);
    if (notify && length_ !is OS.GetWindowTextLength (handle)) {
        sendEvent (SWT.Modify);
        if (isDisposed ()) return;
    }
    /*
    * Bug in Windows.  When the combo box is read only
    * with exactly one item that is currently selected
    * and that item is removed, the combo box does not
    * redraw to clear the text area.  The fix is to
    * force a redraw.
    */
    if ((style & SWT.READ_ONLY) !is 0) {
        auto count = OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
        if (count is 0) OS.InvalidateRect (handle, null, true);
    }
}

/**
 * Removes the items from the receiver's list which are
 * between the given zero-relative start and end
 * indices (inclusive).
 *
 * @param start the start of the range
 * @param end the end of the range
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if either the start or end are not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void remove (int start, int end) {
    checkWidget ();
    if (start > end) return;
    auto count = OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
    if (!(0 <= start && start <= end && end < count)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    int textLength = OS.GetWindowTextLength (handle);
    RECT rect;
    HDC hDC;
    HFONT oldFont, newFont;
    int newWidth = 0;
    if ((style & SWT.H_SCROLL) !is 0) {
        //rect = new RECT ();
        hDC = OS.GetDC (handle);
        newFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
        if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
    }
    int cp = getCodePage ();
    int flags = OS.DT_CALCRECT | OS.DT_SINGLELINE | OS.DT_NOPREFIX;
    for (int i=start; i<=end; i++) {
        TCHAR[] buffer = null;
        if ((style & SWT.H_SCROLL) !is 0) {
            auto length_ = OS.SendMessage (handle, OS.CB_GETLBTEXTLEN, start, 0);
            if (length_ is OS.CB_ERR) break;
            buffer = new TCHAR[ length_ + 1];
            auto result = OS.SendMessage (handle, OS.CB_GETLBTEXT, start, buffer.ptr);
            if (result is OS.CB_ERR) break;
        }
        auto result = OS.SendMessage (handle, OS.CB_DELETESTRING, start, 0);
        if (result is OS.CB_ERR) error (SWT.ERROR_ITEM_NOT_REMOVED);
        if ((style & SWT.H_SCROLL) !is 0) {
            OS.DrawText (hDC, buffer.ptr, -1, &rect, flags);
            newWidth = Math.max (newWidth, rect.right - rect.left);
        }
    }
    if ((style & SWT.H_SCROLL) !is 0) {
        if (newFont !is null) OS.SelectObject (hDC, oldFont);
        OS.ReleaseDC (handle, hDC);
        setScrollWidth (newWidth, false);
    }
    if (textLength !is OS.GetWindowTextLength (handle)) {
        sendEvent (SWT.Modify);
        if (isDisposed ()) return;
    }
    /*
    * Bug in Windows.  When the combo box is read only
    * with exactly one item that is currently selected
    * and that item is removed, the combo box does not
    * redraw to clear the text area.  The fix is to
    * force a redraw.
    */
    if ((style & SWT.READ_ONLY) !is 0) {
        count = OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
        if (count is 0) OS.InvalidateRect (handle, null, true);
    }
}

/**
 * Searches the receiver's list starting at the first item
 * until an item is found that is equal to the argument,
 * and removes that item from the list.
 *
 * @param string the item to remove
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the string is not found in the list</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void remove (String string) {
    checkWidget ();
    // SWT extension: allow null string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    int index = indexOf (string, 0);
    if (index is -1) error (SWT.ERROR_INVALID_ARGUMENT);
    remove (index);
}

/**
 * Removes all of the items from the receiver's list and clear the
 * contents of receiver's text field.
 * <p>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void removeAll () {
    checkWidget ();
    OS.SendMessage (handle, OS.CB_RESETCONTENT, 0, 0);
    sendEvent (SWT.Modify);
    if (isDisposed ()) return;
    if ((style & SWT.H_SCROLL) !is 0) setScrollWidth (0);
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
 * be notified when the user changes the receiver's selection.
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
 *
 * @since 3.1
 */
public void removeVerifyListener (VerifyListener listener) {
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
    * If the left button is down, the text widget refuses the character.
    */
    if (OS.GetKeyState (OS.VK_LBUTTON) < 0) {
        return true;
    }

    /* Verify the character */
    String oldText = "";
    int start, end;
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwndText is null) return true;
    OS.SendMessage (hwndText, OS.EM_GETSEL, start, end);
    switch (key) {
        case 0x08:  /* Bs */
            if (start  is end ) {
                if (start  is 0) return true;
                start  = start  - 1;
                if (!OS.IsUnicode && OS.IsDBLocale) {
                    int newStart, newEnd;
                    OS.SendMessage (hwndText, OS.EM_SETSEL, start , end );
                    OS.SendMessage (hwndText, OS.EM_GETSEL, newStart, newEnd);
                    if (start  !is newStart ) start  = start  - 1;
                }
                start  = Math.max (start , 0);
            }
            break;
        case 0x7F:  /* Del */
            if (start  is end ) {
                int length_ = OS.GetWindowTextLength (hwndText);
                if (start  is length_) return true;
                end  = end  + 1;
                if (!OS.IsUnicode && OS.IsDBLocale) {
                    int newStart, newEnd;
                    OS.SendMessage (hwndText, OS.EM_SETSEL, start , end );
                    OS.SendMessage (hwndText, OS.EM_GETSEL, newStart, newEnd);
                    if (end  !is newEnd ) end  = end  + 1;
                }
                end  = Math.min (end , length_);
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
    LPCTSTR buffer = StrToTCHARz( newText );
    OS.SendMessage (hwndText, OS.EM_SETSEL, start, end);
    OS.SendMessage (hwndText, OS.EM_REPLACESEL, 0, cast(void*)buffer);
    return false;
}

/**
 * Selects the item at the given zero-relative index in the receiver's
 * list.  If the item at the index was already selected, it remains
 * selected. Indices that are out of range are ignored.
 *
 * @param index the index of the item to select
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void select (int index) {
    checkWidget ();
    auto count = OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
    if (0 <= index && index < count) {
        auto selection = OS.SendMessage (handle, OS.CB_GETCURSEL, 0, 0);
        auto code = OS.SendMessage (handle, OS.CB_SETCURSEL, index, 0);
        if (code !is OS.CB_ERR && code !is selection) {
            sendEvent (SWT.Modify);
            // widget could be disposed at this point
        }
    }
}

override void setBackgroundImage (HBITMAP hBitmap) {
    super.setBackgroundImage (hBitmap);
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwndText !is null) OS.InvalidateRect (hwndText, null, true);
    auto hwndList = OS.GetDlgItem (handle, CBID_LIST);
    if (hwndList !is null) OS.InvalidateRect (hwndList, null, true);
}

override void setBackgroundPixel (int pixel) {
    super.setBackgroundPixel (pixel);
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwndText !is null) OS.InvalidateRect (hwndText, null, true);
    auto hwndList = OS.GetDlgItem (handle, CBID_LIST);
    if (hwndList !is null) OS.InvalidateRect (hwndList, null, true);
}

override void setBounds (int x, int y, int width, int height, int flags) {
    /*
    * Feature in Windows.  If the combo box has the CBS_DROPDOWN
    * or CBS_DROPDOWNLIST style, Windows uses the height that the
    * programmer sets in SetWindowPos () to control height of the
    * drop down list.  When the width is non-zero, Windows remembers
    * this value and sets the height to be the height of the text
    * field part of the combo box.  If the width is zero, Windows
    * allows the height to have any value.  Therefore, when the
    * programmer sets and then queries the height, the values can
    * be different depending on the width.  The problem occurs when
    * the programmer uses computeSize () to determine the preferred
    * height (always the height of the text field) and then uses
    * this value to set the height of the combo box.  The result
    * is a combo box with a zero size drop down list.  The fix, is
    * to always set the height to show a fixed number of combo box
    * items and ignore the height value that the programmer supplies.
    */
    if ((style & SWT.DROP_DOWN) !is 0) {
        height = getTextHeight () + (getItemHeight () * visibleCount) + 2;
        /*
        * Feature in Windows.  When a drop down combo box is resized,
        * the combo box resizes the height of the text field and uses
        * the height provided in SetWindowPos () to determine the height
        * of the drop down list.  For some reason, the combo box redraws
        * the whole area, not just the text field.  The fix is to set the
        * SWP_NOSIZE bits when the height of text field and the drop down
        * list is the same as the requested height.
        *
        * NOTE:  Setting the width of a combo box to zero does not update
        * the width of the drop down control rect.  If the width of the
        * combo box is zero, then do not set SWP_NOSIZE.
        */
        RECT rect;
        OS.GetWindowRect (handle, &rect);
        if (rect.right - rect.left !is 0) {
            if (OS.SendMessage (handle, OS.CB_GETDROPPEDCONTROLRECT, 0, &rect) !is 0) {
                int oldWidth = rect.right - rect.left, oldHeight = rect.bottom - rect.top;
                if (oldWidth is width && oldHeight is height) flags |= OS.SWP_NOSIZE;
            }
        }
        SetWindowPos (handle, null, x, y, width, height, flags);
    } else {
        super.setBounds (x, y, width, height, flags);
    }
}

override public void setFont (Font font) {
    checkWidget ();
    super.setFont (font);
    if ((style & SWT.H_SCROLL) !is 0) setScrollWidth ();
}

override void setForegroundPixel (int pixel) {
    super.setForegroundPixel (pixel);
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwndText !is null) OS.InvalidateRect (hwndText, null, true);
    auto hwndList = OS.GetDlgItem (handle, CBID_LIST);
    if (hwndList !is null) OS.InvalidateRect (hwndList, null, true);
}

/**
 * Sets the text of the item in the receiver's list at the given
 * zero-relative index to the string argument.
 *
 * @param index the index for the item
 * @param string the new text for the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setItem (int index, String string) {
    checkWidget ();
    // SWT extension: allow null string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    int selection = getSelectionIndex ();
    remove (index, false);
    if (isDisposed ()) return;
    add (string, index);
    if (selection !is -1) select (selection);
}

/**
 * Sets the receiver's list to be the given array of items.
 *
 * @param items the array of items
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if an item in the items array is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setItems (String [] items) {
    checkWidget ();
    // SWT extension: allow null string
    //if (items is null) error (SWT.ERROR_NULL_ARGUMENT);
    for (int i=0; i<items.length; i++) {
        if (items [i] is null) error (SWT.ERROR_INVALID_ARGUMENT);
    }
    RECT rect;
    HDC hDC;
    HFONT oldFont, newFont;
    int newWidth = 0;
    if ((style & SWT.H_SCROLL) !is 0) {
        //rect = new RECT ();
        hDC = OS.GetDC (handle);
        newFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
        if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
        setScrollWidth (0);
    }
    OS.SendMessage (handle, OS.CB_RESETCONTENT, 0, 0);
    int codePage = getCodePage ();
    for (int i=0; i<items.length; i++) {
        String string = items [i];
        LPCTSTR buffer = StrToTCHARz( string );
        auto code = OS.SendMessage (handle, OS.CB_ADDSTRING, 0, cast(void*)buffer);
        if (code is OS.CB_ERR) error (SWT.ERROR_ITEM_NOT_ADDED);
        if (code is OS.CB_ERRSPACE) error (SWT.ERROR_ITEM_NOT_ADDED);
        if ((style & SWT.H_SCROLL) !is 0) {
            int flags = OS.DT_CALCRECT | OS.DT_SINGLELINE | OS.DT_NOPREFIX;
            OS.DrawText (hDC, buffer, -1, &rect, flags);
            newWidth = Math.max (newWidth, rect.right - rect.left);
        }
    }
    if ((style & SWT.H_SCROLL) !is 0) {
        if (newFont !is null) OS.SelectObject (hDC, oldFont);
        OS.ReleaseDC (handle, hDC);
        setScrollWidth (newWidth + 3);
    }
    sendEvent (SWT.Modify);
    // widget could be disposed at this point
}

/**
 * Sets the orientation of the receiver, which must be one
 * of the constants <code>SWT.LEFT_TO_RIGHT</code> or <code>SWT.RIGHT_TO_LEFT</code>.
 * <p>
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
    int bits  = OS.GetWindowLong (handle, OS.GWL_EXSTYLE);
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        style |= SWT.MIRRORED;
        bits |= OS.WS_EX_LAYOUTRTL;
    } else {
        style &= ~SWT.MIRRORED;
        bits &= ~OS.WS_EX_LAYOUTRTL;
    }
    OS.SetWindowLong (handle, OS.GWL_EXSTYLE, bits);
    HWND hwndText, hwndList;
    COMBOBOXINFO pcbi;
    pcbi.cbSize = COMBOBOXINFO.sizeof;
    if (OS.GetComboBoxInfo (handle, &pcbi)) {
        hwndText = pcbi.hwndItem;
        hwndList = pcbi.hwndList;
    }
    if (hwndText !is null) {
        int bits1 = OS.GetWindowLong (hwndText, OS.GWL_EXSTYLE);
        int bits2 = OS.GetWindowLong (hwndText, OS.GWL_STYLE);
        if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
            bits1 |= OS.WS_EX_RIGHT | OS.WS_EX_RTLREADING;
            bits2 |= OS.ES_RIGHT;
        } else {
            bits1 &= ~(OS.WS_EX_RIGHT | OS.WS_EX_RTLREADING);
            bits2 &= ~OS.ES_RIGHT;
        }
        OS.SetWindowLong (hwndText, OS.GWL_EXSTYLE, bits1);
        OS.SetWindowLong (hwndText, OS.GWL_STYLE, bits2);

        /*
        * Bug in Windows.  For some reason, the single line text field
        * portion of the combo box does not redraw to reflect the new
        * style bits.  The fix is to force the widget to be resized by
        * temporarily shrinking and then growing the width and height.
        */
        RECT rect;
        OS.GetWindowRect (hwndText, &rect);
        int width = rect.right - rect.left, height = rect.bottom - rect.top;
        OS.GetWindowRect (handle, &rect);
        int widthCombo = rect.right - rect.left, heightCombo = rect.bottom - rect.top;
        int uFlags = OS.SWP_NOMOVE | OS.SWP_NOZORDER | OS.SWP_NOACTIVATE;
        SetWindowPos (hwndText, null, 0, 0, width - 1, height - 1, uFlags);
        SetWindowPos (handle, null, 0, 0, widthCombo - 1, heightCombo - 1, uFlags);
        SetWindowPos (hwndText, null, 0, 0, width, height, uFlags);
        SetWindowPos (handle, null, 0, 0, widthCombo, heightCombo, uFlags);
        OS.InvalidateRect (handle, null, true);
    }
    if (hwndList !is null) {
        int bits1 = OS.GetWindowLong (hwndList, OS.GWL_EXSTYLE);
        if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
            bits1 |= OS.WS_EX_LAYOUTRTL;
        } else {
            bits1 &= ~OS.WS_EX_LAYOUTRTL;
        }
        OS.SetWindowLong (hwndList, OS.GWL_EXSTYLE, bits1);
    }
}

void setScrollWidth () {
    int newWidth = 0;
    RECT rect;
    HFONT newFont, oldFont;
    HDC hDC = OS.GetDC (handle);
    newFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
    if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
    int cp = getCodePage ();
    auto count = OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
    int flags = OS.DT_CALCRECT | OS.DT_SINGLELINE | OS.DT_NOPREFIX;
    for (int i=0; i<count; i++) {
        auto length_ = OS.SendMessage (handle, OS.CB_GETLBTEXTLEN, i, 0);
        if (length_ !is OS.CB_ERR) {
            TCHAR[] buffer = new TCHAR [ length_ + 1];
            auto result = OS.SendMessage (handle, OS.CB_GETLBTEXT, i, buffer.ptr);
            if (result !is OS.CB_ERR) {
                OS.DrawText (hDC, buffer.ptr, -1, &rect, flags);
                newWidth = Math.max (newWidth, rect.right - rect.left);
            }
        }
    }
    if (newFont !is null) OS.SelectObject (hDC, oldFont);
    OS.ReleaseDC (handle, hDC);
    setScrollWidth (newWidth + 3);
}

void setScrollWidth (int scrollWidth) {
    this.scrollWidth = scrollWidth;
    if ((style & SWT.SIMPLE) !is 0) {
        OS.SendMessage (handle, OS.CB_SETHORIZONTALEXTENT, scrollWidth, 0);
        return;
    }
    bool scroll = false;
    auto count = OS.SendMessage (handle, OS.CB_GETCOUNT, 0, 0);
    if (count > 3) {
        int maxWidth = 0;
        if (OS.IsWinCE || OS.WIN32_VERSION < OS.VERSION (4, 10)) {
            RECT rect;
            OS.SystemParametersInfo (OS.SPI_GETWORKAREA, 0, &rect, 0);
            maxWidth = (rect.right - rect.left) / 4;
        } else {
            auto hmonitor = OS.MonitorFromWindow (handle, OS.MONITOR_DEFAULTTONEAREST);
            MONITORINFO lpmi;
            lpmi.cbSize = MONITORINFO.sizeof;
            OS.GetMonitorInfo (hmonitor, &lpmi);
            maxWidth = (lpmi.rcWork.right - lpmi.rcWork.left) / 4;
        }
        scroll = scrollWidth > maxWidth;
    }
    if (scroll) {
        OS.SendMessage (handle, OS.CB_SETDROPPEDWIDTH, 0, 0);
        OS.SendMessage (handle, OS.CB_SETHORIZONTALEXTENT, scrollWidth, 0);
    } else {
        scrollWidth += OS.GetSystemMetrics (OS.SM_CYHSCROLL);
        OS.SendMessage (handle, OS.CB_SETDROPPEDWIDTH, scrollWidth, 0);
        OS.SendMessage (handle, OS.CB_SETHORIZONTALEXTENT, 0, 0);
    }
}

void setScrollWidth (StringT buffer, bool grow) {
    RECT rect;
    HFONT newFont, oldFont;
    auto hDC = OS.GetDC (handle);
    newFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
    if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
    int flags = OS.DT_CALCRECT | OS.DT_SINGLELINE | OS.DT_NOPREFIX;
    OS.DrawText (hDC, buffer.ptr, -1, &rect, flags);
    if (newFont !is null) OS.SelectObject (hDC, oldFont);
    OS.ReleaseDC (handle, hDC);
    setScrollWidth (rect.right - rect.left, grow);
}

void setScrollWidth (int newWidth, bool grow) {
    if (grow) {
        if (newWidth <= scrollWidth) return;
        setScrollWidth (newWidth + 3);
    } else {
        if (newWidth < scrollWidth) return;
        setScrollWidth ();
    }
}

/**
 * Sets the selection in the receiver's text field to the
 * range specified by the argument whose x coordinate is the
 * start of the selection and whose y coordinate is the end
 * of the selection.
 *
 * @param selection a point representing the new selection start and end
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
    int start = selection.x, end = selection.y;
    if (!OS.IsUnicode && OS.IsDBLocale) {
        start = wcsToMbcsPos (start);
        end = wcsToMbcsPos (end);
    }
    auto bits = OS.MAKELPARAM (start, end);
    OS.SendMessage (handle, OS.CB_SETEDITSEL, 0, bits);
}

/**
 * Sets the contents of the receiver's text field to the
 * given string.
 * <p>
 * Note: The text field in a <code>Combo</code> is typically
 * only capable of displaying a single line of text. Thus,
 * setting the text to a string containing line breaks or
 * other special characters will probably cause it to
 * display incorrectly.
 * </p>
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
    // SWT externsion: allow null string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if ((style & SWT.READ_ONLY) !is 0) {
        int index = indexOf (string);
        if (index !is -1) select (index);
        return;
    }
    int limit = LIMIT;
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwndText !is null) {
        limit = OS.SendMessage (hwndText, OS.EM_GETLIMITTEXT, 0, 0) & 0x7FFFFFFF;
    }
    if (string.length  > limit) string = string.substring (0, limit);
    LPCTSTR buffer = StrToTCHARz( string );
    if (OS.SetWindowText (handle, buffer)) {
        sendEvent (SWT.Modify);
        // widget could be disposed at this point
    }
}

/**
 * Sets the maximum number of characters that the receiver's
 * text field is capable of holding to be the argument.
 * <p>
 * To reset this value to the default, use <code>setTextLimit(Combo.LIMIT)</code>.
 * Specifying a limit value larger than <code>Combo.LIMIT</code> sets the
 * receiver's limit to <code>Combo.LIMIT</code>.
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
 */
public void setTextLimit (int limit) {
    checkWidget ();
    if (limit is 0) error (SWT.ERROR_CANNOT_BE_ZERO);
    OS.SendMessage (handle, OS.CB_LIMITTEXT, limit, 0);
}

override void setToolTipText (Shell shell, String string) {
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    auto hwndList = OS.GetDlgItem (handle, CBID_LIST);
    if (hwndText !is null) shell.setToolTipText (hwndText, string);
    if (hwndList !is null) shell.setToolTipText (hwndList, string);
    shell.setToolTipText (handle, string);
}

/**
 * Sets the number of items that are visible in the drop
 * down portion of the receiver's list.
 * <p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept.
 * </p>
 *
 * @param count the new number of items to be visible
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setVisibleItemCount (int count) {
    checkWidget ();
    if (count < 0) return;
    visibleCount = count;
    if ((style & SWT.DROP_DOWN) !is 0) {
        forceResize ();
        RECT rect;
        OS.GetWindowRect (handle, &rect);
        int flags = OS.SWP_NOMOVE | OS.SWP_NOZORDER | OS.SWP_DRAWFRAME | OS.SWP_NOACTIVATE;
        setBounds (0, 0, rect.right - rect.left, rect.bottom - rect.top, flags);
    }
}

override void subclass () {
    super.subclass ();
    auto newProc = display.windowProc;
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwndText !is null) {
        OS.SetWindowLongPtr (hwndText, OS.GWLP_WNDPROC, newProc);
    }
    auto hwndList = OS.GetDlgItem (handle, CBID_LIST);
    if (hwndList !is null) {
        OS.SetWindowLongPtr (hwndList, OS.GWLP_WNDPROC, newProc);
    }
}

override bool translateTraversal (MSG* msg) {
    /*
    * When the combo box is dropped down, allow return
    * to select an item in the list and escape to close
    * the combo box.
    */
    switch ((msg.wParam)) {
        case OS.VK_RETURN:
        case OS.VK_ESCAPE:
            if ((style & SWT.DROP_DOWN) !is 0) {
                if (OS.SendMessage (handle, OS.CB_GETDROPPEDSTATE, 0, 0) !is 0) {
                    return false;
                }
            }
            break;
        default:
            break;
    }
    return super.translateTraversal (msg);
}

override bool traverseEscape () {
    if ((style & SWT.DROP_DOWN) !is 0) {
        if (OS.SendMessage (handle, OS.CB_GETDROPPEDSTATE, 0, 0) !is 0) {
            OS.SendMessage (handle, OS.CB_SHOWDROPDOWN, 0, 0);
            return true;
        }
    }
    return super.traverseEscape ();
}

override bool traverseReturn () {
    if ((style & SWT.DROP_DOWN) !is 0) {
        if (OS.SendMessage (handle, OS.CB_GETDROPPEDSTATE, 0, 0) !is 0) {
            OS.SendMessage (handle, OS.CB_SHOWDROPDOWN, 0, 0);
            return true;
        }
    }
    return super.traverseReturn ();
}

override void unsubclass () {
    super.unsubclass ();
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwndText !is null && EditProc !is null) {
        OS.SetWindowLongPtr (hwndText, OS.GWLP_WNDPROC, cast(LONG_PTR)EditProc);
    }
    auto hwndList = OS.GetDlgItem (handle, CBID_LIST);
    if (hwndList !is null && ListProc !is null) {
        OS.SetWindowLongPtr (hwndList, OS.GWLP_WNDPROC, cast(LONG_PTR)ListProc);
    }
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
    if (!OS.IsUnicode && OS.IsDBLocale) {
        event.start = mbcsToWcsPos (start);
        event.end = mbcsToWcsPos (end);
    }
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
    auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
    if (hwndText is null) return wcsPos;
    int mbcsSize = OS.GetWindowTextLengthA (hwndText);
    if (mbcsSize is 0) return 0;
    CHAR [] buffer = new CHAR [mbcsSize + 1];
    OS.GetWindowTextA (hwndText, buffer.ptr, mbcsSize + 1);
    int mbcsPos = 0, wcsCount = 0;
    while (mbcsPos < mbcsSize) {
        if (wcsPos is wcsCount) break;
        if (OS.IsDBCSLeadByte (buffer [mbcsPos++])) mbcsPos++;
        wcsCount++;
    }
    return mbcsPos;
}

override int widgetExtStyle () {
    return super.widgetExtStyle () & ~OS.WS_EX_NOINHERITLAYOUT;
}

override int widgetStyle () {
    int bits = super.widgetStyle () | OS.CBS_AUTOHSCROLL | OS.CBS_NOINTEGRALHEIGHT | OS.WS_HSCROLL |OS.WS_VSCROLL;
    if ((style & SWT.SIMPLE) !is 0) return bits | OS.CBS_SIMPLE;
    if ((style & SWT.READ_ONLY) !is 0) return bits | OS.CBS_DROPDOWNLIST;
    return bits | OS.CBS_DROPDOWN;
}

override String windowClass () {
    return TCHARzToStr( ComboClass );
}

override ptrdiff_t windowProc () {
    return cast(ptrdiff_t) ComboProc;
}

override .LRESULT windowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    if (hwnd !is handle) {
        auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
        auto hwndList = OS.GetDlgItem (handle, CBID_LIST);
        if ((hwndText !is null && hwnd is hwndText) || (hwndList !is null && hwnd is hwndList)) {
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
//              case OS.WM_MOUSEWHEEL:      result = wmMouseWheel (hwnd, wParam, lParam); break;
                case OS.WM_RBUTTONDBLCLK:   result = wmRButtonDblClk (hwnd, wParam, lParam); break;
                case OS.WM_RBUTTONDOWN:     result = wmRButtonDown (hwnd, wParam, lParam); break;
                case OS.WM_RBUTTONUP:       result = wmRButtonUp (hwnd, wParam, lParam); break;
                case OS.WM_XBUTTONDBLCLK:   result = wmXButtonDblClk (hwnd, wParam, lParam); break;
                case OS.WM_XBUTTONDOWN:     result = wmXButtonDown (hwnd, wParam, lParam); break;
                case OS.WM_XBUTTONUP:       result = wmXButtonUp (hwnd, wParam, lParam); break;

                /* Paint messages */
                case OS.WM_PAINT:           result = wmPaint (hwnd, wParam, lParam); break;

                /* Menu messages */
                case OS.WM_CONTEXTMENU:     result = wmContextMenu (hwnd, wParam, lParam); break;

                /* Clipboard messages */
                case OS.WM_CLEAR:
                case OS.WM_CUT:
                case OS.WM_PASTE:
                case OS.WM_UNDO:
                case OS.EM_UNDO:
                case OS.WM_SETTEXT:
                    if (hwnd is hwndText) {
                        result = wmClipboard (hwnd, msg, wParam, lParam);
                    }
                    break;
                default:
            }
            if (result !is null) return result.value;
            return callWindowProc (hwnd, msg, wParam, lParam);
        }
    }
    if (msg is OS.CB_SETCURSEL) {
        if ((style & SWT.READ_ONLY) !is 0) {
            if (hooks (SWT.Verify) || filters (SWT.Verify)) {
                String oldText = getText (), newText = null;
                if (wParam is -1) {
                    newText = "";
                } else {
                    if (0 <= wParam && wParam < getItemCount ()) {
                        newText = getItem (cast(int)/*64bit*/wParam);
                    }
                }
                if (newText !is null && newText!=/*eq*/oldText) {
                    int length_ = OS.GetWindowTextLength (handle);
                    oldText = newText;
                    newText = verifyText (newText, 0, length_, null);
                    if (newText is null) return 0;
                    if (newText!=/*eq*/oldText) {
                        int index = indexOf (newText);
                        if (index !is -1 && index !is wParam) {
                            return callWindowProc (handle, OS.CB_SETCURSEL, index, lParam);
                        }
                    }
                }
            }
        }
    }
    return super.windowProc (hwnd, msg, wParam, lParam);
}

override LRESULT WM_CTLCOLOR (WPARAM wParam, LPARAM lParam) {
    return wmColorChild (wParam, lParam);
}

override LRESULT WM_GETDLGCODE (WPARAM wParam, LPARAM lParam) {
    auto code = callWindowProc (handle, OS.WM_GETDLGCODE, wParam, lParam);
    return new LRESULT (code | OS.DLGC_WANTARROWS);
}

override LRESULT WM_KILLFOCUS (WPARAM wParam, LPARAM lParam) {
    /*
    * Bug in Windows.  When a combo box that is read only
    * is disposed in CBN_KILLFOCUS, Windows segment faults.
    * The fix is to send focus from WM_KILLFOCUS instead
    * of CBN_KILLFOCUS.
    *
    * NOTE: In version 6 of COMCTL32.DLL, the bug is fixed.
    */
    if ((style & SWT.READ_ONLY) !is 0) {
        return super.WM_KILLFOCUS (wParam, lParam);
    }

    /*
    * Return NULL - Focus notification is
    * done in WM_COMMAND by CBN_KILLFOCUS.
    */
    return null;
}

override LRESULT WM_LBUTTONDOWN (WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  When an editable combo box is dropped
    * down and the text in the entry field partially matches an
    * item in the list, Windows selects the item but doesn't send
    * WM_COMMAND with CBN_SELCHANGE.  The fix is to detect that
    * the selection has changed and issue the notification.
    */
    auto oldSelection = OS.SendMessage (handle, OS.CB_GETCURSEL, 0, 0);
    LRESULT result = super.WM_LBUTTONDOWN (wParam, lParam);
    if (result is LRESULT.ZERO) return result;
    if ((style & SWT.READ_ONLY) is 0) {
        auto newSelection = OS.SendMessage (handle, OS.CB_GETCURSEL, 0, 0);
        if (oldSelection !is newSelection) {
            sendEvent (SWT.Modify);
            if (isDisposed ()) return LRESULT.ZERO;
            sendEvent (SWT.Selection);
            if (isDisposed ()) return LRESULT.ZERO;
        }
    }
    return result;
}

override LRESULT WM_SETFOCUS (WPARAM wParam, LPARAM lParam) {
    /*
    * Return NULL - Focus notification is
    * done by WM_COMMAND with CBN_SETFOCUS.
    */
    return null;
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  When a combo box is resized,
    * the size of the drop down rectangle is specified
    * using the height and then the combo box resizes
    * to be the height of the text field.  This causes
    * two WM_SIZE messages to be sent and two SWT.Resize
    * events to be issued.  The fix is to ignore the
    * second resize.
    */
    if (ignoreResize) return null;
    /*
    * Bug in Windows.  If the combo box has the CBS_SIMPLE style,
    * the list portion of the combo box is not redrawn when the
    * combo box is resized.  The fix is to force a redraw when
    * the size has changed.
    */
    if ((style & SWT.SIMPLE) !is 0) {
        LRESULT result = super.WM_SIZE (wParam, lParam);
        if (OS.IsWindowVisible (handle)) {
            static if (OS.IsWinCE) {
                auto hwndText = OS.GetDlgItem (handle, CBID_EDIT);
                if (hwndText !is null) OS.InvalidateRect (hwndText, null, true);
                auto hwndList = OS.GetDlgItem (handle, CBID_LIST);
                if (hwndList !is null) OS.InvalidateRect (hwndList, null, true);
            } else {
                int uFlags = OS.RDW_ERASE | OS.RDW_INVALIDATE | OS.RDW_ALLCHILDREN;
                OS.RedrawWindow (handle, null, null, uFlags);
            }
        }
        return result;
    }

    /*
    * Feature in Windows.  When an editable drop down combo box
    * contains text that does not correspond to an item in the
    * list, when the widget is resized, it selects the closest
    * match from the list.  The fix is to remember the original
    * text and reset it after the widget is resized.
    */
    LRESULT result = null;
    if ((style & SWT.READ_ONLY) !is 0) {
        result = super.WM_SIZE (wParam, lParam);
    } else {
        auto index = OS.SendMessage (handle, OS.CB_GETCURSEL, 0, 0);
        bool redraw = false;
        TCHAR[] buffer = null;
        int start, end;
        if (index is OS.CB_ERR) {
            int length_ = OS.GetWindowTextLength (handle);
            if (length_ !is 0) {
                buffer = new TCHAR[ length_ + 1];
                OS.GetWindowText (handle, buffer.ptr, length_ + 1);
                OS.SendMessage (handle, OS.CB_GETEDITSEL, &start, &end);
                redraw = drawCount is 0 && OS.IsWindowVisible (handle);
                if (redraw) setRedraw (false);
            }
        }
        result = super.WM_SIZE (wParam, lParam);
        /*
        * It is possible (but unlikely), that application
        * code could have disposed the widget in the resize
        * event.  If this happens, end the processing of the
        * Windows message by returning the result of the
        * WM_SIZE message.
        */
        if (isDisposed ()) return result;
        if (buffer !is null) {
            OS.SetWindowText (handle, buffer.ptr);
            auto bits = OS.MAKELPARAM (start, end);
            OS.SendMessage (handle, OS.CB_SETEDITSEL, 0, bits);
            if (redraw) setRedraw (true);
        }
    }
    /*
    * Feature in Windows.  When CB_SETDROPPEDWIDTH is called with
    * a width that is smaller than the current size of the combo
    * box, it is ignored.  This the fix is to set the width after
    * the combo box has been resized.
    */
    if ((style & SWT.H_SCROLL) !is 0) setScrollWidth (scrollWidth);
    return result;
}

override LRESULT WM_WINDOWPOSCHANGING (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_WINDOWPOSCHANGING (wParam, lParam);
    if (result !is null) return result;
    /*
    * Feature in Windows.  When a combo box is resized,
    * the size of the drop down rectangle is specified
    * using the height and then the combo box resizes
    * to be the height of the text field.  This causes
    * sibling windows that intersect with the original
    * bounds to redrawn.  The fix is to stop the redraw
    * using SWP_NOREDRAW and then damage the combo box
    * text field and the area in the parent where the
    * combo box used to be.
    */
    if (OS.IsWinCE) return result;
    if (drawCount !is 0) return result;
    if (!OS.IsWindowVisible (handle)) return result;
    if (ignoreResize) {
        WINDOWPOS* lpwp = cast(WINDOWPOS*)lParam;
        if ((lpwp.flags & OS.SWP_NOSIZE) is 0) {
            lpwp.flags |= OS.SWP_NOREDRAW;
            OS.InvalidateRect (handle, null, true);
            RECT rect;
            OS.GetWindowRect (handle, &rect);
            int width = rect.right - rect.left;
            int height = rect.bottom - rect.top;
            if (width !is 0 && height !is 0) {
                auto hwndParent = parent.handle;
                auto hwndChild = OS.GetWindow (hwndParent, OS.GW_CHILD);
                OS.MapWindowPoints (null, hwndParent, cast(POINT*)&rect, 2);
                auto rgn1 = OS.CreateRectRgn (rect.left, rect.top, rect.right, rect.bottom);
                while (hwndChild !is null) {
                    if (hwndChild !is handle) {
                        OS.GetWindowRect (hwndChild, &rect);
                        OS.MapWindowPoints (null, hwndParent, cast(POINT*)&rect, 2);
                        auto rgn2 = OS.CreateRectRgn (rect.left, rect.top, rect.right, rect.bottom);
                        OS.CombineRgn (rgn1, rgn1, rgn2, OS.RGN_DIFF);
                        OS.DeleteObject (rgn2);
                    }
                    hwndChild = OS.GetWindow (hwndChild, OS.GW_HWNDNEXT);
                }
                int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE;
                OS.RedrawWindow (hwndParent, null, rgn1, flags);
                OS.DeleteObject (rgn1);
            }
        }
    }
    return result;
}

override LRESULT wmChar (HWND hwnd, WPARAM wParam, LPARAM lParam) {
    if (ignoreCharacter) return null;
    LRESULT result = super.wmChar (hwnd, wParam, lParam);
    if (result !is null) return result;
    /*
    * Feature in Windows.  For some reason, when the
    * widget is a single line text widget, when the
    * user presses tab, return or escape, Windows beeps.
    * The fix is to look for these keys and not call
    * the window proc.
    *
    * NOTE: This only happens when the drop down list
    * is not visible.
    */
    switch (wParam) {
        case SWT.TAB: return LRESULT.ZERO;
        case SWT.CR:
            if (!ignoreDefaultSelection) postEvent (SWT.DefaultSelection);
            ignoreDefaultSelection = false;
            goto case SWT.ESC;
        case SWT.ESC:
            if ((style & SWT.DROP_DOWN) !is 0) {
                if (OS.SendMessage (handle, OS.CB_GETDROPPEDSTATE, 0, 0) is 0) {
                    return LRESULT.ZERO;
                }
            }
            break;
        default:
            break;
    }
    return result;
}

LRESULT wmClipboard (HWND hwndText, int msg, WPARAM wParam, LPARAM lParam) {
    if ((style & SWT.READ_ONLY) !is 0) return null;
    if (!hooks (SWT.Verify) && !filters (SWT.Verify)) return null;
    bool call = false;
    int start, end;
    String newText = null;
    switch (msg) {
        case OS.WM_CLEAR:
        case OS.WM_CUT:
            OS.SendMessage (hwndText, OS.EM_GETSEL, &start, &end);
            if (start  !is end ) {
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
                OS.SendMessage (hwndText, OS.EM_GETSEL, start, end);
                OS.CallWindowProc (EditProc, hwndText, msg, wParam, lParam);
                int length_ = OS.GetWindowTextLength (hwndText);
                int newStart, newEnd;
                OS.SendMessage (hwndText, OS.EM_GETSEL, &newStart, &newEnd);
                if (length_ !is 0 && newStart  !is newEnd ) {
                    TCHAR[] buffer = new TCHAR [ length_ + 1];
                    OS.GetWindowText (hwndText, buffer.ptr, length_ + 1);
                    newText = TCHARsToStr( buffer[newStart .. newEnd ] );
                } else {
                    newText = "";
                }
                OS.CallWindowProc (EditProc, hwndText, msg, wParam, lParam);
                ignoreModify = false;
            }
            break;
        case OS.WM_SETTEXT:
            end = OS.GetWindowTextLength (hwndText);
            //int length_ = OS.IsUnicode ? OS.wcslen (lParam) : OS.strlen (lParam);
            //TCHAR buffer = new TCHAR (getCodePage (), length_);
            //int byteCount = buffer.length  * TCHAR.sizeof;
            //OS.MoveMemory (buffer, lParam, byteCount);
            //newText = buffer.toString (0, length_);
            newText = TCHARzToStr( cast(TCHAR*)lParam );
            break;
        default:
    }
    if (newText !is null) {
        String oldText = newText;
        newText = verifyText (newText, start, end, null);
        if (newText is null) return LRESULT.ZERO;
        if (newText!=/*eq*/oldText) {
            if (call) {
                OS.CallWindowProc (EditProc, hwndText, msg, wParam, lParam);
            }
            if (msg is OS.WM_SETTEXT) {
                StringT buffer = StrToTCHARs( getCodePage(), newText, true );
                auto hHeap = OS.GetProcessHeap ();
                auto byteCount = buffer.length * TCHAR.sizeof;
                auto pszText = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
                OS.MoveMemory (pszText, buffer.ptr, byteCount);
                auto code = OS.CallWindowProc (EditProc, hwndText, msg, wParam, cast(ptrdiff_t)pszText);
                OS.HeapFree (hHeap, 0, pszText);
                return new LRESULT (code);
            } else {
                LPCTSTR buffer = StrToTCHARz( newText );
                OS.SendMessage (hwndText, OS.EM_REPLACESEL, 0, cast(void*)buffer);
                return LRESULT.ZERO;
            }
        }
    }
    return null;
}

override LRESULT wmCommandChild (WPARAM wParam, LPARAM lParam) {
    int code = OS.HIWORD (wParam);
    switch (code) {
        case OS.CBN_EDITCHANGE:
            if (ignoreModify) break;
            /*
            * Feature in Windows.  If the combo box list selection is
            * queried using CB_GETCURSEL before the WM_COMMAND (with
            * CBN_EDITCHANGE) returns, CB_GETCURSEL returns the previous
            * selection in the list.  It seems that the combo box sends
            * the WM_COMMAND before it makes the selection in the list box
            * match the entry field.  The fix is remember that no selection
            * in the list should exist in this case.
            */
            noSelection = true;
            sendEvent (SWT.Modify);
            if (isDisposed ()) return LRESULT.ZERO;
            noSelection = false;
            break;
        case OS.CBN_SELCHANGE:
            /*
            * Feature in Windows.  If the text in an editable combo box
            * is queried using GetWindowText () before the WM_COMMAND
            * (with CBN_SELCHANGE) returns, GetWindowText () returns is
            * the previous text in the combo box.  It seems that the combo
            * box sends the WM_COMMAND before it updates the text field to
            * match the list selection.  The fix is to force the text field
            * to match the list selection by re-selecting the list item.
            */
            auto index = OS.SendMessage (handle, OS.CB_GETCURSEL, 0, 0);
            if (index !is OS.CB_ERR) {
                OS.SendMessage (handle, OS.CB_SETCURSEL, index, 0);
            }
            /*
            * It is possible (but unlikely), that application
            * code could have disposed the widget in the modify
            * event.  If this happens, end the processing of the
            * Windows message by returning zero as the result of
            * the window proc.
            */
            sendEvent (SWT.Modify);
            if (isDisposed ()) return LRESULT.ZERO;
            postEvent (SWT.Selection);
            break;
        case OS.CBN_SETFOCUS:
            sendFocusEvent (SWT.FocusIn);
            if (isDisposed ()) return LRESULT.ZERO;
            break;
        case OS.CBN_KILLFOCUS:
            /*
            * Bug in Windows.  When a combo box that is read only
            * is disposed in CBN_KILLFOCUS, Windows segment faults.
            * The fix is to send focus from WM_KILLFOCUS instead
            * of CBN_KILLFOCUS.
            *
            * NOTE: In version 6 of COMCTL32.DLL, the bug is fixed.
            */
            if ((style & SWT.READ_ONLY) !is 0) break;
            sendFocusEvent (SWT.FocusOut);
            if (isDisposed ()) return LRESULT.ZERO;
            break;
        default:
    }
    return super.wmCommandChild (wParam, lParam);
}

override LRESULT wmIMEChar (HWND hwnd, WPARAM wParam, LPARAM lParam) {

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
    auto result = callWindowProc (hwnd, OS.WM_IME_CHAR, wParam, lParam);
    MSG msg;
    int flags = OS.PM_REMOVE | OS.PM_NOYIELD | OS.PM_QS_INPUT | OS.PM_QS_POSTMESSAGE;
    while (OS.PeekMessage (&msg, hwnd, OS.WM_CHAR, OS.WM_CHAR, flags)) {
        OS.TranslateMessage (&msg);
        OS.DispatchMessage (&msg);
    }
    ignoreCharacter = false;

    sendKeyEvent (SWT.KeyUp, OS.WM_IME_CHAR, wParam, lParam);
    // widget could be disposed at this point
    display.lastKey = display.lastAscii = 0;
    return new LRESULT (result);
}

override LRESULT wmKeyDown (HWND hwnd, WPARAM wParam, LPARAM lParam) {
    if (ignoreCharacter) return null;
    LRESULT result = super.wmKeyDown (hwnd, wParam, lParam);
    if (result !is null) return result;
    ignoreDefaultSelection = false;
    if (wParam is OS.VK_RETURN) {
        if ((style & SWT.DROP_DOWN) !is 0) {
            if (OS.SendMessage (handle, OS.CB_GETDROPPEDSTATE, 0, 0) !is 0) {
                ignoreDefaultSelection = true;
            }
        }
    }
    return result;
}

override LRESULT wmSysKeyDown (HWND hwnd, WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  When an editable combo box is dropped
    * down using Alt+Down and the text in the entry field partially
    * matches an item in the list, Windows selects the item but doesn't
    * send WM_COMMAND with CBN_SELCHANGE.  The fix is to detect that
    * the selection has changed and issue the notification.
    */
    auto oldSelection = OS.SendMessage (handle, OS.CB_GETCURSEL, 0, 0);
    LRESULT result = super.wmSysKeyDown (hwnd, wParam, lParam);
    if (result !is null) return result;
    if ((style & SWT.READ_ONLY) is 0) {
        if (wParam is OS.VK_DOWN) {
            auto code = callWindowProc (hwnd, OS.WM_SYSKEYDOWN, wParam, lParam);
            auto newSelection = OS.SendMessage (handle, OS.CB_GETCURSEL, 0, 0);
            if (oldSelection !is newSelection) {
                sendEvent (SWT.Modify);
                if (isDisposed ()) return LRESULT.ZERO;
                sendEvent (SWT.Selection);
                if (isDisposed ()) return LRESULT.ZERO;
            }
            return new LRESULT (code);
        }
    }
    return result;
}

}
