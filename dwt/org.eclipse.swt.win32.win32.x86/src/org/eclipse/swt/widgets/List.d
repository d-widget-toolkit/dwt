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
module org.eclipse.swt.widgets.List;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Scrollable;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.TypedListener;

import java.lang.all;

/**
 * Instances of this class represent a selectable user interface
 * object that displays a list of strings and issues notification
 * when a string is selected.  A list may be single or multi select.
 * <p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>SINGLE, MULTI</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection, DefaultSelection</dd>
 * </dl>
 * <p>
 * Note: Only one of SINGLE and MULTI may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#list">List snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class List : Scrollable {

    alias Scrollable.computeSize computeSize;
    alias Scrollable.windowProc windowProc;

    static const int INSET = 3;
    mixin(gshared!(`private static /+const+/ WNDPROC ListProc;`));
    static const TCHAR[] ListClass = "LISTBOX";

    private static bool static_this_completed = false;
    private static void static_this() {
        if( static_this_completed ){
            return;
        }
        synchronized {
            if( static_this_completed ){
                return;
            }
            WNDCLASS lpWndClass;
            OS.GetClassInfo (null, ListClass.ptr, &lpWndClass);
            ListProc = lpWndClass.lpfnWndProc;
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
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    static_this();
    super (parent, checkStyle (style));
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
    LPCTSTR buffer = StrToTCHARz ( getCodePage (), string);
    auto result = OS.SendMessage (handle, OS.LB_ADDSTRING, 0, cast(void*)buffer);
    if (result is OS.LB_ERR) error (SWT.ERROR_ITEM_NOT_ADDED);
    if (result is OS.LB_ERRSPACE) error (SWT.ERROR_ITEM_NOT_ADDED);
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
    if (index is -1) error (SWT.ERROR_INVALID_RANGE);
    LPCTSTR buffer = StrToTCHARz(getCodePage (), string);
    auto result = OS.SendMessage (handle, OS.LB_INSERTSTRING, index, cast(void*)buffer);
    if (result is OS.LB_ERRSPACE) error (SWT.ERROR_ITEM_NOT_ADDED);
    if (result is OS.LB_ERR) {
        auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
        if (0 <= index && index <= count) {
            error (SWT.ERROR_ITEM_NOT_ADDED);
        } else {
            error (SWT.ERROR_INVALID_RANGE);
        }
    }
    if ((style & SWT.H_SCROLL) !is 0) setScrollWidth (buffer, true);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the user changes the receiver's selection, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the selection changes.
 * <code>widgetDefaultSelected</code> is typically called when an item is double-clicked.
 * </p>
 *
 * @param listener the listener which should be notified when the user changes the receiver's selection
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

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    bool redraw = false;
    switch (msg) {
        case OS.WM_HSCROLL:
        case OS.WM_VSCROLL: {
            redraw = findImageControl () !is null && drawCount is 0 && OS.IsWindowVisible (handle);
            if (redraw) OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
            break;
        }
        default:
    }
    auto code = OS.CallWindowProc (ListProc, hwnd, msg, wParam, lParam);
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

static int checkStyle (int style) {
    return checkBits (style, SWT.SINGLE, SWT.MULTI, 0, 0, 0, 0);
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = 0, height = 0;
    if (wHint is SWT.DEFAULT) {
        if ((style & SWT.H_SCROLL) !is 0) {
            width = cast(int)/*64bit*/OS.SendMessage (handle, OS.LB_GETHORIZONTALEXTENT, 0, 0);
            width -= INSET;
        } else {
            auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
            HFONT newFont, oldFont;
            auto hDC = OS.GetDC (handle);
            newFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
            if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
            RECT rect;
            int flags = OS.DT_CALCRECT | OS.DT_SINGLELINE | OS.DT_NOPREFIX;
            int cp = getCodePage ();
            TCHAR[] buffer = NewTCHARs (cp, 64 + 1);
            for (int i=0; i<count; i++) {
                int length = cast(int)/*64bit*/OS.SendMessage (handle, OS.LB_GETTEXTLEN, i, 0);
                if (length !is OS.LB_ERR) {
                    if (length + 1 > buffer.length) {
                        buffer = NewTCHARs (cp, length + 1);
                    }
                    auto result = OS.SendMessage (handle, OS.LB_GETTEXT, i, buffer.ptr);
                    if (result !is OS.LB_ERR) {
                        OS.DrawText (hDC, buffer.ptr, length, &rect, flags);
                        width = Math.max (width, rect.right - rect.left);
                    }
                }
            }
            if (newFont !is null) OS.SelectObject (hDC, oldFont);
            OS.ReleaseDC (handle, hDC);
        }
    }
    if (hHint is SWT.DEFAULT) {
        int count = cast(int)/*64bit*/OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
        int itemHeight = cast(int)/*64bit*/OS.SendMessage (handle, OS.LB_GETITEMHEIGHT, 0, 0);
        height = count * itemHeight;
    }
    if (width is 0) width = DEFAULT_WIDTH;
    if (height is 0) height = DEFAULT_HEIGHT;
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    int border = getBorderWidth ();
    width += border * 2 + INSET;
    height += border * 2;
    if ((style & SWT.V_SCROLL) !is 0) {
        width += OS.GetSystemMetrics (OS.SM_CXVSCROLL);
    }
    if ((style & SWT.H_SCROLL) !is 0) {
        height += OS.GetSystemMetrics (OS.SM_CYHSCROLL);
    }
    return new Point (width, height);
}

override int defaultBackground () {
    return OS.GetSysColor (OS.COLOR_WINDOW);
}

/**
 * Deselects the items at the given zero-relative indices in the receiver.
 * If the item at the given zero-relative index in the receiver
 * is selected, it is deselected.  If the item at the index
 * was not selected, it remains deselected. Indices that are out
 * of range and duplicate indices are ignored.
 *
 * @param indices the array of indices for the items to deselect
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void deselect (int [] indices) {
    checkWidget ();
    // SWT extension: allow null array
    //if (indices is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (indices.length is 0) return;
    if ((style & SWT.SINGLE) !is 0) {
        auto oldIndex = OS.SendMessage (handle, OS.LB_GETCURSEL, 0, 0);
        if (oldIndex is OS.LB_ERR) return;
        for (int i=0; i<indices.length; i++) {
            if (oldIndex is indices [i]) {
                OS.SendMessage (handle, OS.LB_SETCURSEL, -1, 0);
                return;
            }
        }
        return;
    }
    for (int i=0; i<indices.length; i++) {
        int index = indices [i];
        if (index !is -1) {
            OS.SendMessage (handle, OS.LB_SETSEL, 0, index);
        }
    }
}

/**
 * Deselects the item at the given zero-relative index in the receiver.
 * If the item at the index was already deselected, it remains
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
    if (index is -1) return;
    if ((style & SWT.SINGLE) !is 0) {
        auto oldIndex = OS.SendMessage (handle, OS.LB_GETCURSEL, 0, 0);
        if (oldIndex is OS.LB_ERR) return;
        if (oldIndex is index) OS.SendMessage (handle, OS.LB_SETCURSEL, -1, 0);
        return;
    }
    OS.SendMessage (handle, OS.LB_SETSEL, 0, index);
}

/**
 * Deselects the items at the given zero-relative indices in the receiver.
 * If the item at the given zero-relative index in the receiver
 * is selected, it is deselected.  If the item at the index
 * was not selected, it remains deselected.  The range of the
 * indices is inclusive. Indices that are out of range are ignored.
 *
 * @param start the start index of the items to deselect
 * @param end the end index of the items to deselect
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void deselect (int start, int end) {
    checkWidget ();
    if (start > end) return;
    if ((style & SWT.SINGLE) !is 0) {
        auto oldIndex = OS.SendMessage (handle, OS.LB_GETCURSEL, 0, 0);
        if (oldIndex is OS.LB_ERR) return;
        if (start <= oldIndex && oldIndex <= end) {
            OS.SendMessage (handle, OS.LB_SETCURSEL, -1, 0);
        }
        return;
    }
    /*
    * Ensure that at least one item is contained in
    * the range from start to end.  Note that when
    * start = end, LB_SELITEMRANGEEX deselects the
    * item.
    */
    auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
    if (start < 0 && end < 0) return;
    if (start >= count && end >= count) return;
    auto start2 = Math.min (count - 1, Math.max (0, start));
    auto end2 = Math.min (count - 1, Math.max (0, end));
    OS.SendMessage (handle, OS.LB_SELITEMRANGEEX, end2, start2);
}

/**
 * Deselects all selected items in the receiver.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void deselectAll () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        OS.SendMessage (handle, OS.LB_SETCURSEL, -1, 0);
    } else {
        OS.SendMessage (handle, OS.LB_SETSEL, 0, -1);
    }
}

/**
 * Returns the zero-relative index of the item which currently
 * has the focus in the receiver, or -1 if no item has focus.
 *
 * @return the index of the selected item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getFocusIndex () {
    checkWidget ();
    int result = cast(int)/*64bit*/OS.SendMessage (handle, OS.LB_GETCARETINDEX, 0, 0);
    if (result is 0) {
        auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
        if (count is 0) return -1;
    }
    return result;
}

/**
 * Returns the item at the given, zero-relative index in the
 * receiver. Throws an exception if the index is out of range.
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
    auto length_ = OS.SendMessage (handle, OS.LB_GETTEXTLEN, index, 0);
    if (length_ !is OS.LB_ERR) {
        TCHAR[] buffer = NewTCHARs (getCodePage (), length_ + 1);
        auto result = OS.SendMessage (handle, OS.LB_GETTEXT, index, buffer.ptr);
        if (result !is OS.LB_ERR) return TCHARsToStr( buffer[0 .. length_] );
    }
    auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
    if (0 <= index && index < count) error (SWT.ERROR_CANNOT_GET_ITEM);
    error (SWT.ERROR_INVALID_RANGE);
    return "";
}

/**
 * Returns the number of items contained in the receiver.
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
    auto result = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
    if (result is OS.LB_ERR) error (SWT.ERROR_CANNOT_GET_COUNT);
    return cast(int)/*64bit*/result;
}

/**
 * Returns the height of the area which would be used to
 * display <em>one</em> of the items in the list.
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
    auto result = OS.SendMessage (handle, OS.LB_GETITEMHEIGHT, 0, 0);
    if (result is OS.LB_ERR) error (SWT.ERROR_CANNOT_GET_ITEM_HEIGHT);
    return cast(int)/*64bit*/result;
}

/**
 * Returns a (possibly empty) array of <code>String</code>s which
 * are the items in the receiver.
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
 * Returns an array of <code>String</code>s that are currently
 * selected in the receiver.  The order of the items is unspecified.
 * An empty array indicates that no items are selected.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its selection, so modifying the array will
 * not affect the receiver.
 * </p>
 * @return an array representing the selection
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String [] getSelection () {
    checkWidget ();
    int [] indices = getSelectionIndices ();
    String [] result = new String [indices.length];
    for (int i=0; i<indices.length; i++) {
        result [i] = getItem (indices [i]);
    }
    return result;
}

/**
 * Returns the number of selected items contained in the receiver.
 *
 * @return the number of selected items
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSelectionCount () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        auto result = OS.SendMessage (handle, OS.LB_GETCURSEL, 0, 0);
        if (result is OS.LB_ERR) return 0;
        return 1;
    }
    auto result = OS.SendMessage (handle, OS.LB_GETSELCOUNT, 0, 0);
    if (result is OS.LB_ERR) error (SWT.ERROR_CANNOT_GET_COUNT);
    return cast(int)/*64bit*/result;
}

/**
 * Returns the zero-relative index of the item which is currently
 * selected in the receiver, or -1 if no item is selected.
 *
 * @return the index of the selected item or -1
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSelectionIndex () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        return cast(int)/*64bit*/OS.SendMessage (handle, OS.LB_GETCURSEL, 0, 0);
    }
    auto count = OS.SendMessage (handle, OS.LB_GETSELCOUNT, 0, 0);
    if (count is OS.LB_ERR) error (SWT.ERROR_CANNOT_GET_SELECTION);
    if (count is 0) return -1;
    auto index = OS.SendMessage (handle, OS.LB_GETCARETINDEX, 0, 0);
    auto result = OS.SendMessage (handle, OS.LB_GETSEL, index, 0);
    if (result is OS.LB_ERR) error (SWT.ERROR_CANNOT_GET_SELECTION);
    if (result !is 0) return cast(int)/*64bit*/index;
    INT_PTR buffer;
    result = OS.SendMessage (handle, OS.LB_GETSELITEMS, 1, &buffer);
    if (result !is 1) error (SWT.ERROR_CANNOT_GET_SELECTION);
    return cast(int)/*64bit*/buffer;
}

/**
 * Returns the zero-relative indices of the items which are currently
 * selected in the receiver.  The order of the indices is unspecified.
 * The array is empty if no items are selected.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its selection, so modifying the array will
 * not affect the receiver.
 * </p>
 * @return the array of indices of the selected items
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int [] getSelectionIndices () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        auto result = OS.SendMessage (handle, OS.LB_GETCURSEL, 0, 0);
        if (result is OS.LB_ERR) return new int [0];
        return [cast(int)/*64bit*/result];
    }
    auto length = OS.SendMessage (handle, OS.LB_GETSELCOUNT, 0, 0);
    if (length is OS.LB_ERR) error (SWT.ERROR_CANNOT_GET_SELECTION);
    int [] indices = new int [length];
    auto result = OS.SendMessage (handle, OS.LB_GETSELITEMS, length, indices.ptr);
    if (result !is length) error (SWT.ERROR_CANNOT_GET_SELECTION);
    return indices;
}

/**
 * Returns the zero-relative index of the item which is currently
 * at the top of the receiver. This index can change when items are
 * scrolled or new items are added or removed.
 *
 * @return the index of the top item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getTopIndex () {
    checkWidget ();
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.LB_GETTOPINDEX, 0, 0);
}

/**
 * Gets the index of an item.
 * <p>
 * The list is searched starting at 0 until an
 * item is found that is equal to the search item.
 * If no item is found, -1 is returned.  Indexing
 * is zero based.
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
 * @param start the zero-relative index at which to start the search
 * @return the index of the item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (String string, int start) {
    checkWidget ();
    // SWT extension: allow null string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);

    /*
    * Bug in Windows.  For some reason, LB_FINDSTRINGEXACT
    * will not find empty strings even though it is legal
    * to insert an empty string into a list.  The fix is
    * to search the list, an item at a time.
    */
    if (string.length is 0) {
        int count = getItemCount ();
        for (int i=start; i<count; i++) {
            if (string ==/*eq*/ getItem (i)) return i;
        }
        return -1;
    }

    /* Use LB_FINDSTRINGEXACT to search for the item */
    auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
    if (!(0 <= start && start < count)) return -1;
    int index = start - 1, last;
    LPCTSTR buffer = StrToTCHARz (getCodePage (), string );
    do {
        index = cast(int)/*64bit*/OS.SendMessage (handle, OS.LB_FINDSTRINGEXACT, last = index, cast(void*)buffer);
        if (index is OS.LB_ERR || index <= last) return -1;
    } while (string !=/*eq*/ getItem (index));
    return index;
}

/**
 * Returns <code>true</code> if the item is selected,
 * and <code>false</code> otherwise.  Indices out of
 * range are ignored.
 *
 * @param index the index of the item
 * @return the selection state of the item at the index
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool isSelected (int index) {
    checkWidget ();
    auto result = OS.SendMessage (handle, OS.LB_GETSEL, index, 0);
    return (result !is 0) && (result !is OS.LB_ERR);
}

/**
 * Removes the items from the receiver at the given
 * zero-relative indices.
 *
 * @param indices the array of indices of the items
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void remove (int [] indices) {
    checkWidget ();
    // SWT extension: allow null array
    //if (indices is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (indices.length is 0) return;
    int [] newIndices = new int [indices.length];
    System.arraycopy (indices, 0, newIndices, 0, indices.length);
    sort (newIndices);
    int start = newIndices [newIndices.length - 1], end = newIndices [0];
    auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
    if (!(0 <= start && start <= end && end < count)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    auto topIndex = OS.SendMessage (handle, OS.LB_GETTOPINDEX, 0, 0);
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
    int i = 0, topCount = 0, last = -1;
    while (i < newIndices.length) {
        int index = newIndices [i];
        if (index !is last) {
            TCHAR[] buffer = null;
            if ((style & SWT.H_SCROLL) !is 0) {
                auto length = OS.SendMessage (handle, OS.LB_GETTEXTLEN, index, 0);
                if (length is OS.LB_ERR) break;
                buffer = NewTCHARs (cp, length + 1);
                auto result = OS.SendMessage (handle, OS.LB_GETTEXT, index, buffer.ptr);
                if (result is OS.LB_ERR) break;
            }
            auto result = OS.SendMessage (handle, OS.LB_DELETESTRING, index, 0);
            if (result is OS.LB_ERR) break;
            if ((style & SWT.H_SCROLL) !is 0) {
                int flags = OS.DT_CALCRECT | OS.DT_SINGLELINE | OS.DT_NOPREFIX;
                OS.DrawText (hDC, buffer.ptr, -1, &rect, flags);
                newWidth = Math.max (newWidth, rect.right - rect.left);
            }
            if (index < topIndex) topCount++;
            last = index;
        }
        i++;
    }
    if ((style & SWT.H_SCROLL) !is 0) {
        if (newFont !is null) OS.SelectObject (hDC, oldFont);
        OS.ReleaseDC (handle, hDC);
        setScrollWidth (newWidth, false);
    }
    if (topCount > 0) {
        topIndex -= topCount;
        OS.SendMessage (handle, OS.LB_SETTOPINDEX, topIndex, 0);
    }
    if (i < newIndices.length) error (SWT.ERROR_ITEM_NOT_REMOVED);
}

/**
 * Removes the item from the receiver at the given
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
    TCHAR[] buffer = null;
    if ((style & SWT.H_SCROLL) !is 0) {
        auto length = OS.SendMessage (handle, OS.LB_GETTEXTLEN, index, 0);
        if (length is OS.LB_ERR) {
            auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
            if (0 <= index && index < count) error (SWT.ERROR_ITEM_NOT_REMOVED);
            error (SWT.ERROR_INVALID_RANGE);
        }
        buffer = NewTCHARs (getCodePage (), length + 1);
        auto result = OS.SendMessage (handle, OS.LB_GETTEXT, index, buffer.ptr);
        if (result is OS.LB_ERR) {
            auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
            if (0 <= index && index < count) error (SWT.ERROR_ITEM_NOT_REMOVED);
            error (SWT.ERROR_INVALID_RANGE);
        }
    }
    auto topIndex = OS.SendMessage (handle, OS.LB_GETTOPINDEX, 0, 0);
    auto result = OS.SendMessage (handle, OS.LB_DELETESTRING, index, 0);
    if (result is OS.LB_ERR) {
        auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
        if (0 <= index && index < count) error (SWT.ERROR_ITEM_NOT_REMOVED);
        error (SWT.ERROR_INVALID_RANGE);
    }
    if ((style & SWT.H_SCROLL) !is 0) setScrollWidth (buffer.ptr, false);
    if (index < topIndex) {
        OS.SendMessage (handle, OS.LB_SETTOPINDEX, topIndex - 1, 0);
    }
}

/**
 * Removes the items from the receiver which are
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
    auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
    if (!(0 <= start && start <= end && end < count)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    if (start is 0 && end is count - 1) {
        removeAll ();
        return;
    }
    auto topIndex = OS.SendMessage (handle, OS.LB_GETTOPINDEX, 0, 0);
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
    int index = start;
    int flags = OS.DT_CALCRECT | OS.DT_SINGLELINE | OS.DT_NOPREFIX;
    while (index <= end) {
        TCHAR[] buffer = null;
        if ((style & SWT.H_SCROLL) !is 0) {
            auto length = OS.SendMessage (handle, OS.LB_GETTEXTLEN, start, 0);
            if (length is OS.LB_ERR) break;
            buffer = NewTCHARs (cp, length + 1);
            auto result = OS.SendMessage (handle, OS.LB_GETTEXT, start, buffer.ptr);
            if (result is OS.LB_ERR) break;
        }
        auto result = OS.SendMessage (handle, OS.LB_DELETESTRING, start, 0);
        if (result is OS.LB_ERR) break;
        if ((style & SWT.H_SCROLL) !is 0) {
            OS.DrawText (hDC, buffer.ptr, -1, &rect, flags);
            newWidth = Math.max (newWidth, rect.right - rect.left);
        }
        index++;
    }
    if ((style & SWT.H_SCROLL) !is 0) {
        if (newFont !is null) OS.SelectObject (hDC, oldFont);
        OS.ReleaseDC (handle, hDC);
        setScrollWidth (newWidth, false);
    }
    if (end < topIndex) {
        topIndex -= end - start + 1;
        OS.SendMessage (handle, OS.LB_SETTOPINDEX, topIndex, 0);
    }
    if (index <= end) error (SWT.ERROR_ITEM_NOT_REMOVED);
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
 * Removes all of the items from the receiver.
 * <p>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void removeAll () {
    checkWidget ();
    OS.SendMessage (handle, OS.LB_RESETCONTENT, 0, 0);
    if ((style & SWT.H_SCROLL) !is 0) {
        OS.SendMessage (handle, OS.LB_SETHORIZONTALEXTENT, 0, 0);
    }
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
public void removeSelectionListener(SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Selection, listener);
    eventTable.unhook (SWT.DefaultSelection,listener);
}

/**
 * Selects the items at the given zero-relative indices in the receiver.
 * The current selection is not cleared before the new items are selected.
 * <p>
 * If the item at a given index is not selected, it is selected.
 * If the item at a given index was already selected, it remains selected.
 * Indices that are out of range and duplicate indices are ignored.
 * If the receiver is single-select and multiple indices are specified,
 * then all indices are ignored.
 *
 * @param indices the array of indices for the items to select
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see List#setSelection(int[])
 */
public void select (int [] indices) {
    checkWidget ();
    // SWT extension: allow null array
    //if (indices is null) error (SWT.ERROR_NULL_ARGUMENT);
    int length = cast(int)/*64bit*/indices.length;
    if (length is 0 || ((style & SWT.SINGLE) !is 0 && length > 1)) return;
    select (indices, false);
}

void select (int [] indices, bool scroll) {
    int i = 0;
    while (i < indices.length) {
        int index = indices [i];
        if (index !is -1) {
            select (index, false);
        }
        i++;
    }
    if (scroll) showSelection ();
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
    select (index, false);
}

void select (int index, bool scroll) {
    if (index < 0) return;
    auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
    if (index >= count) return;
    if (scroll) {
        if ((style & SWT.SINGLE) !is 0) {
            OS.SendMessage (handle, OS.LB_SETCURSEL, index, 0);
        } else {
            OS.SendMessage (handle, OS.LB_SETSEL, 1, index);
        }
        return;
    }
    auto topIndex = OS.SendMessage (handle, OS.LB_GETTOPINDEX, 0, 0);
    RECT itemRect, selectedRect;
    bool selectedRectNull = true;
    OS.SendMessage (handle, OS.LB_GETITEMRECT, index, &itemRect);
    bool redraw = drawCount is 0 && OS.IsWindowVisible (handle);
    if (redraw) {
        OS.UpdateWindow (handle);
        OS.SendMessage (handle, OS.WM_SETREDRAW, 0, 0);
    }
    int focusIndex = -1;
    if ((style & SWT.SINGLE) !is 0) {
        auto oldIndex = OS.SendMessage (handle, OS.LB_GETCURSEL, 0, 0);
        if (oldIndex !is -1) {
            //selectedRect = new RECT ();
            selectedRectNull = false;
            OS.SendMessage (handle, OS.LB_GETITEMRECT, oldIndex, &selectedRect);
        }
        OS.SendMessage (handle, OS.LB_SETCURSEL, index, 0);
    } else {
        focusIndex = cast(int)/*64bit*/OS.SendMessage (handle, OS.LB_GETCARETINDEX, 0, 0);
        OS.SendMessage (handle, OS.LB_SETSEL, 1, index);
    }
    if ((style & SWT.MULTI) !is 0) {
        if (focusIndex !is -1) {
            OS.SendMessage (handle, OS.LB_SETCARETINDEX, focusIndex, 0);
        }
    }
    OS.SendMessage (handle, OS.LB_SETTOPINDEX, topIndex, 0);
    if (redraw) {
        OS.SendMessage (handle, OS.WM_SETREDRAW, 1, 0);
        OS.ValidateRect (handle, null);
        OS.InvalidateRect (handle, &itemRect, true);
        if (!selectedRectNull) {
            OS.InvalidateRect (handle, &selectedRect, true);
        }
    }
}

/**
 * Selects the items in the range specified by the given zero-relative
 * indices in the receiver. The range of indices is inclusive.
 * The current selection is not cleared before the new items are selected.
 * <p>
 * If an item in the given range is not selected, it is selected.
 * If an item in the given range was already selected, it remains selected.
 * Indices that are out of range are ignored and no items will be selected
 * if start is greater than end.
 * If the receiver is single-select and there is more than one item in the
 * given range, then all indices are ignored.
 *
 * @param start the start of the range
 * @param end the end of the range
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see List#setSelection(int,int)
 */
public void select (int start, int end) {
    checkWidget ();
    if (end < 0 || start > end || ((style & SWT.SINGLE) !is 0 && start !is end)) return;
    auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
    if (count is 0 || start >= count) return;
    start = Math.max (0, start);
    end = cast(int)/*64bit*/Math.min (end, count - 1);
    if ((style & SWT.SINGLE) !is 0) {
        select (start, false);
    } else {
        select (start, end, false);
    }
}

void select (int start, int end, bool scroll) {
    /*
    * Note that when start = end, LB_SELITEMRANGEEX
    * deselects the item.
    */
    if (start is end) {
        select (start, scroll);
        return;
    }
    OS.SendMessage (handle, OS.LB_SELITEMRANGEEX, start, end);
    if (scroll) showSelection ();
}

/**
 * Selects all of the items in the receiver.
 * <p>
 * If the receiver is single-select, do nothing.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void selectAll () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) return;
    OS.SendMessage (handle, OS.LB_SETSEL, 1, -1);
}

void setFocusIndex (int index) {
//  checkWidget ();
    auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
    if (!(0 <= index && index < count)) return;
    OS.SendMessage (handle, OS.LB_SETCARETINDEX, index, 0);
}

override public void setFont (Font font) {
    checkWidget ();
    super.setFont (font);
    if ((style & SWT.H_SCROLL) !is 0) setScrollWidth ();
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
    int topIndex = getTopIndex ();
    bool isSelected = isSelected (index);
    remove (index);
    add (string, index);
    if (isSelected) select (index, false);
    setTopIndex (topIndex);
}

/**
 * Sets the receiver's items to be the given array of items.
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
    // SWT extension: allow null array
    //if (items is null) error (SWT.ERROR_NULL_ARGUMENT);
    // SWT extension: allow null item strings
    //for (int i=0; i<items.length; i++) {
    //    if (items [i] is null) error (SWT.ERROR_INVALID_ARGUMENT);
    //}
    auto oldProc = OS.GetWindowLongPtr (handle, OS.GWLP_WNDPROC);
    OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR) ListProc);
    bool redraw = drawCount is 0 && OS.IsWindowVisible (handle);
    if (redraw) {
        OS.SendMessage (handle, OS.WM_SETREDRAW, 0, 0);
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
        OS.SendMessage (handle, OS.LB_SETHORIZONTALEXTENT, 0, 0);
    }
    int length = cast(int)/*64bit*/items.length;
    OS.SendMessage (handle, OS.LB_RESETCONTENT, 0, 0);
    OS.SendMessage (handle, OS.LB_INITSTORAGE, length, length * 32);
    int index = 0;
    int cp = getCodePage ();
    while (index < length) {
        String string = items [index];
        LPCTSTR buffer = StrToTCHARz (cp, string);
        auto result = OS.SendMessage (handle, OS.LB_ADDSTRING, 0, cast(void*)buffer);
        if (result is OS.LB_ERR || result is OS.LB_ERRSPACE) break;
        if ((style & SWT.H_SCROLL) !is 0) {
            int flags = OS.DT_CALCRECT | OS.DT_SINGLELINE | OS.DT_NOPREFIX;
            OS.DrawText (hDC, buffer, -1, &rect, flags);
            newWidth = Math.max (newWidth, rect.right - rect.left);
        }
        index++;
    }
    if ((style & SWT.H_SCROLL) !is 0) {
        if (newFont !is null) OS.SelectObject (hDC, oldFont);
        OS.ReleaseDC (handle, hDC);
        OS.SendMessage (handle, OS.LB_SETHORIZONTALEXTENT, newWidth + INSET, 0);
    }
    if (redraw) {
        OS.SendMessage (handle, OS.WM_SETREDRAW, 1, 0);
        /*
        * This code is intentionally commented.  The window proc
        * for the list box implements WM_SETREDRAW to invalidate
        * and erase the widget.  This is undocumented behavior.
        * The commented code below shows what is actually happening
        * and reminds us that we are relying on this undocumented
        * behavior.
        */
//      int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE;
//      OS.RedrawWindow (handle, null, 0, flags);
    }
    OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, oldProc);
    if (index < items.length) error (SWT.ERROR_ITEM_NOT_ADDED);
}

void setScrollWidth () {
    int newWidth = 0;
    RECT rect;
    HFONT newFont, oldFont;
    auto hDC = OS.GetDC (handle);
    newFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
    if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
    int cp = getCodePage ();
    auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
    int flags = OS.DT_CALCRECT | OS.DT_SINGLELINE | OS.DT_NOPREFIX;
    for (int i=0; i<count; i++) {
        auto length = OS.SendMessage (handle, OS.LB_GETTEXTLEN, i, 0);
        if (length !is OS.LB_ERR) {
            TCHAR[] buffer = NewTCHARs (cp, length + 1 );
            auto result = OS.SendMessage (handle, OS.LB_GETTEXT, i, buffer.ptr);
            if (result !is OS.LB_ERR) {
                OS.DrawText (hDC, buffer.ptr, -1, &rect, flags);
                newWidth = Math.max (newWidth, rect.right - rect.left);
            }
        }
    }
    if (newFont !is null) OS.SelectObject (hDC, oldFont);
    OS.ReleaseDC (handle, hDC);
    OS.SendMessage (handle, OS.LB_SETHORIZONTALEXTENT, newWidth + INSET, 0);
}

void setScrollWidth (LPCTSTR buffer, bool grow) {
    RECT rect;
    HFONT newFont, oldFont;
    auto hDC = OS.GetDC (handle);
    newFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
    if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
    int flags = OS.DT_CALCRECT | OS.DT_SINGLELINE | OS.DT_NOPREFIX;
    OS.DrawText (hDC, buffer, -1, &rect, flags);
    if (newFont !is null) OS.SelectObject (hDC, oldFont);
    OS.ReleaseDC (handle, hDC);
    setScrollWidth (rect.right - rect.left, grow);
}

void setScrollWidth (int newWidth, bool grow) {
    newWidth += INSET;
    auto width = OS.SendMessage (handle, OS.LB_GETHORIZONTALEXTENT, 0, 0);
    if (grow) {
        if (newWidth <= width) return;
        OS.SendMessage (handle, OS.LB_SETHORIZONTALEXTENT, newWidth, 0);
    } else {
        if (newWidth < width) return;
        setScrollWidth ();
    }
}

/**
 * Selects the items at the given zero-relative indices in the receiver.
 * The current selection is cleared before the new items are selected.
 * <p>
 * Indices that are out of range and duplicate indices are ignored.
 * If the receiver is single-select and multiple indices are specified,
 * then all indices are ignored.
 *
 * @param indices the indices of the items to select
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see List#deselectAll()
 * @see List#select(int[])
 */
public void setSelection(int [] indices) {
    checkWidget ();
    // SWT extension: allow null array
    //if (indices is null) error (SWT.ERROR_NULL_ARGUMENT);
    deselectAll ();
    int length = cast(int)/*64bit*/indices.length;
    if (length is 0 || ((style & SWT.SINGLE) !is 0 && length > 1)) return;
    select (indices, true);
    if ((style & SWT.MULTI) !is 0) {
        int focusIndex = indices [0];
        if (focusIndex >= 0) setFocusIndex (focusIndex);
    }
}

/**
 * Sets the receiver's selection to be the given array of items.
 * The current selection is cleared before the new items are selected.
 * <p>
 * Items that are not in the receiver are ignored.
 * If the receiver is single-select and multiple items are specified,
 * then all items are ignored.
 *
 * @param items the array of items
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see List#deselectAll()
 * @see List#select(int[])
 * @see List#setSelection(int[])
 */
public void setSelection (String [] items) {
    checkWidget ();
    // SWT extension: allow null array
    //if (items is null) error (SWT.ERROR_NULL_ARGUMENT);
    deselectAll ();
    int length = cast(int)/*64bit*/items.length;
    if (length is 0 || ((style & SWT.SINGLE) !is 0 && length > 1)) return;
    int focusIndex = -1;
    for (int i=length-1; i>=0; --i) {
        String string = items [i];
        int index = 0;
        if (string !is null) {
            int localFocus = -1;
            while ((index = indexOf (string, index)) !is -1) {
                if (localFocus is -1) localFocus = index;
                select (index, false);
                if ((style & SWT.SINGLE) !is 0 && isSelected (index)) {
                    showSelection ();
                    return;
                }
                index++;
            }
            if (localFocus !is -1) focusIndex = localFocus;
        }
    }
    if ((style & SWT.MULTI) !is 0) {
        if (focusIndex >= 0) setFocusIndex (focusIndex);
    }
}

/**
 * Selects the item at the given zero-relative index in the receiver.
 * If the item at the index was already selected, it remains selected.
 * The current selection is first cleared, then the new item is selected.
 * Indices that are out of range are ignored.
 *
 * @param index the index of the item to select
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * @see List#deselectAll()
 * @see List#select(int)
 */
public void setSelection (int index) {
    checkWidget ();
    deselectAll ();
    select (index, true);
    if ((style & SWT.MULTI) !is 0) {
        if (index >= 0) setFocusIndex (index);
    }
}

/**
 * Selects the items in the range specified by the given zero-relative
 * indices in the receiver. The range of indices is inclusive.
 * The current selection is cleared before the new items are selected.
 * <p>
 * Indices that are out of range are ignored and no items will be selected
 * if start is greater than end.
 * If the receiver is single-select and there is more than one item in the
 * given range, then all indices are ignored.
 *
 * @param start the start index of the items to select
 * @param end the end index of the items to select
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see List#deselectAll()
 * @see List#select(int,int)
 */
public void setSelection (int start, int end) {
    checkWidget ();
    deselectAll ();
    if (end < 0 || start > end || ((style & SWT.SINGLE) !is 0 && start !is end)) return;
    auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
    if (count is 0 || start >= count) return;
    start = Math.max (0, start);
    end = cast(int)/*64bit*/Math.min (end, count - 1);
    if ((style & SWT.SINGLE) !is 0) {
        select (start, true);
    } else {
        select (start, end, true);
        setFocusIndex (start);
    }
}

/**
 * Sets the zero-relative index of the item which is currently
 * at the top of the receiver. This index can change when items
 * are scrolled or new items are added and removed.
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
    auto result = OS.SendMessage (handle, OS.LB_SETTOPINDEX, index, 0);
    if (result is OS.LB_ERR) {
        auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
        auto index2 = Math.min (count - 1, Math.max (0, index));
        OS.SendMessage (handle, OS.LB_SETTOPINDEX, index2, 0);
    }
}

/**
 * Shows the selection.  If the selection is already showing in the receiver,
 * this method simply returns.  Otherwise, the items are scrolled until
 * the selection is visible.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void showSelection () {
    checkWidget ();
    .LRESULT index;
    if ((style & SWT.SINGLE) !is 0) {
        index = OS.SendMessage (handle, OS.LB_GETCURSEL, 0, 0);
    } else {
        .LRESULT indices;
        auto result = OS.SendMessage (handle, OS.LB_GETSELITEMS, 1, &indices);
        index = indices;
        if (result !is 1) index = -1;
    }
    if (index is -1) return;
    auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
    if (count is 0) return;
    auto height = OS.SendMessage (handle, OS.LB_GETITEMHEIGHT, 0, 0);
    forceResize ();
    RECT rect;
    OS.GetClientRect (handle, &rect);
    auto topIndex = OS.SendMessage (handle, OS.LB_GETTOPINDEX, 0, 0);
    auto visibleCount = Math.max (rect.bottom / height, 1);
    auto bottomIndex = Math.min (topIndex + visibleCount, count) - 1;
    if (topIndex <= index && index <= bottomIndex) return;
    auto newTop = Math.min (Math.max (index - (visibleCount / 2), 0), count - 1);
    OS.SendMessage (handle, OS.LB_SETTOPINDEX, newTop, 0);
}

override int widgetStyle () {
    int bits = super.widgetStyle () | OS.LBS_NOTIFY | OS.LBS_NOINTEGRALHEIGHT;
    if ((style & SWT.SINGLE) !is 0) return bits;
    if ((style & SWT.MULTI) !is 0) {
        if ((style & SWT.SIMPLE) !is 0) return bits | OS.LBS_MULTIPLESEL;
        return bits | OS.LBS_EXTENDEDSEL;
    }
    return bits;
}

override String windowClass () {
    return TCHARsToStr( ListClass );
}

override ptrdiff_t windowProc () {
    return cast(ptrdiff_t) ListProc;
}

override LRESULT WM_CHAR (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_CHAR (wParam, lParam);
    if (result !is null) return result;
    /*
    * Feature in Windows.  The Windows list box does not implement
    * the control key interface for multi-select list boxes, making
    * it inaccessible from the keyboard.  The fix is to implement
    * the key processing.
    */
    if (OS.GetKeyState (OS.VK_CONTROL) < 0 && OS.GetKeyState (OS.VK_SHIFT) >= 0) {
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        if ((bits & OS.LBS_EXTENDEDSEL) !is 0) {
            switch (wParam) {
                case OS.VK_SPACE: {
                    auto index = OS.SendMessage (handle, OS.LB_GETCARETINDEX, 0, 0);
                    auto code = OS.SendMessage (handle, OS.LB_GETSEL, index, 0);
                    if (code is OS.LB_ERR) break;
                    OS.SendMessage (handle, OS.LB_SETSEL, code !is 0 ? 0 : 1, index);
                    OS.SendMessage (handle, OS.LB_SETANCHORINDEX, index, 0);
                    postEvent (SWT.Selection);
                    return LRESULT.ZERO;
                }
                default:
            }
        }
    }
    return result;
}

override LRESULT WM_KEYDOWN (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_KEYDOWN (wParam, lParam);
    if (result !is null) return result;
    /*
    * Feature in Windows.  The Windows list box does not implement
    * the control key interface for multi-select list boxes, making
    * it inaccessible from the keyboard.  The fix is to implement
    * the key processing.
    */
    if (OS.GetKeyState (OS.VK_CONTROL) < 0 && OS.GetKeyState (OS.VK_SHIFT) >= 0) {
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        if ((bits & OS.LBS_EXTENDEDSEL) !is 0) {
            .LRESULT location = -1;
            switch (wParam) {
                case OS.VK_SPACE: {
                    /*
                    * Ensure that the window proc does not process VK_SPACE
                    * so that it can be handled in WM_CHAR.  This allows the
                    * application to cancel an operation that is normally
                    * performed in WM_KEYDOWN from WM_CHAR.
                    */
                    return LRESULT.ZERO;
                }
                case OS.VK_UP:
                case OS.VK_DOWN: {
                    auto index = OS.SendMessage (handle, OS.LB_GETCARETINDEX, 0, 0);
                    location = Math.max (0, index + ((wParam) is OS.VK_UP ? -1 : 1));
                    break;
                }
                case OS.VK_PRIOR: {
                    auto index = OS.SendMessage (handle, OS.LB_GETCARETINDEX, 0, 0);
                    auto topIndex = OS.SendMessage (handle, OS.LB_GETTOPINDEX, 0, 0);
                    if (index !is topIndex) {
                        location = topIndex;
                    } else {
                        forceResize ();
                        RECT rect;
                        OS.GetClientRect (handle, &rect);
                        auto itemHeight = OS.SendMessage (handle, OS.LB_GETITEMHEIGHT, 0, 0);
                        auto pageSize = Math.max (2, (rect.bottom / itemHeight));
                        location = Math.max (0, topIndex - (pageSize - 1));
                    }
                    break;
                }
                case OS.VK_NEXT: {
                    auto index = OS.SendMessage (handle, OS.LB_GETCARETINDEX, 0, 0);
                    auto topIndex = OS.SendMessage (handle, OS.LB_GETTOPINDEX, 0, 0);
                    forceResize ();
                    RECT rect;
                    OS.GetClientRect (handle, &rect);
                    auto itemHeight = OS.SendMessage (handle, OS.LB_GETITEMHEIGHT, 0, 0);
                    auto pageSize = Math.max (2, (rect.bottom / itemHeight));
                    auto bottomIndex = topIndex + pageSize - 1;
                    if (index !is bottomIndex) {
                        location = bottomIndex;
                    } else {
                        location = bottomIndex + pageSize - 1;
                    }
                    auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
                    if (count !is OS.LB_ERR) location = Math.min (count - 1, location);
                    break;
                }
                case OS.VK_HOME: {
                    location = 0;
                    break;
                }
                case OS.VK_END: {
                    auto count = OS.SendMessage (handle, OS.LB_GETCOUNT, 0, 0);
                    if (count is OS.LB_ERR) break;
                    location = count - 1;
                    break;
                }
                default:
            }
            if (location !is -1) {
                OS.SendMessage (handle, OS.WM_CHANGEUISTATE, OS.UIS_INITIALIZE, 0);
                OS.SendMessage (handle, OS.LB_SETCARETINDEX, location, 0);
                return LRESULT.ZERO;
            }
        }
    }

    /*
    * Feature in Windows.  When the user changes focus using
    * the keyboard, the focus indicator does not draw.  The
    * fix is to update the UI state for the control whenever
    * the focus indicator changes as a result of something
    * the user types.
    */
    auto uiState = OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
    if ((uiState & OS.UISF_HIDEFOCUS) !is 0) {
        auto oldIndex = OS.SendMessage (handle, OS.LB_GETCARETINDEX, 0, 0);
        auto code = callWindowProc (handle, OS.WM_KEYDOWN, wParam, lParam);
        auto newIndex = OS.SendMessage (handle, OS.LB_GETCARETINDEX, 0, 0);
        if (oldIndex !is newIndex) {
            OS.SendMessage (handle, OS.WM_CHANGEUISTATE, OS.UIS_INITIALIZE, 0);
            /*
            * Bug in Windows.  When the WM_CHANGEUISTATE is used
            * to update the UI state for a list that has been
            * selected using Shift+Arrow, the focus indicator
            * has pixel corruption.  The fix is to redraw the
            * focus item.
            */
            RECT itemRect;
            OS.SendMessage (handle, OS.LB_GETITEMRECT, newIndex, &itemRect);
            OS.InvalidateRect (handle, &itemRect, true);
        }
        return new LRESULT (code);
    }
    return result;
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    /*
    * Bug in Windows.  If the top index is changed while the
    * list is being resized, Windows does not redraw properly
    * when their is white space at the bottom of the control.
    * The fix is to detect when the top index has changed and
    * redraw the control.
    *
    * Bug in Windows.  If the receiver is scrolled horizontally
    * and is resized, the list does not redraw properly.  The fix
    * is to redraw the control when the horizontal scroll bar is
    * not at the beginning.
    */
    auto oldIndex = OS.SendMessage (handle, OS.LB_GETTOPINDEX, 0, 0);
    LRESULT result = super.WM_SIZE (wParam, lParam);
    if (!isDisposed ()) {
        SCROLLINFO info;
        info.cbSize = SCROLLINFO.sizeof;
        info.fMask = OS.SIF_POS;
        if (OS.GetScrollInfo (handle, OS.SB_HORZ, &info)) {
            if (info.nPos !is 0) OS.InvalidateRect (handle, null, true);
        }
        auto newIndex = OS.SendMessage (handle, OS.LB_GETTOPINDEX, 0, 0);
        if (oldIndex !is newIndex) OS.InvalidateRect (handle, null, true);
    }
    return result;
}

override LRESULT wmCommandChild (WPARAM wParam, LPARAM lParam) {
    int code = OS.HIWORD (wParam);
    switch (code) {
        case OS.LBN_SELCHANGE:
            postEvent (SWT.Selection);
            break;
        case OS.LBN_DBLCLK:
            postEvent (SWT.DefaultSelection);
            break;
        default:
    }
    return super.wmCommandChild (wParam, lParam);
}



}
