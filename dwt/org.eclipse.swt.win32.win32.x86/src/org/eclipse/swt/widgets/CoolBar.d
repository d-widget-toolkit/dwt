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
module org.eclipse.swt.widgets.CoolBar;

import org.eclipse.swt.widgets.Composite;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.CoolItem;
import org.eclipse.swt.widgets.Event;

import java.lang.all;

/**
 * Instances of this class provide an area for dynamically
 * positioning the items they contain.
 * <p>
 * The item children that may be added to instances of this class
 * must be of type <code>CoolItem</code>.
 * </p><p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add <code>Control</code> children to it,
 * or set a layout on it.
 * </p><p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>FLAT, HORIZONTAL, VERTICAL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * </p><p>
 * Note: Only one of the styles HORIZONTAL and VERTICAL may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 * 
 * @see <a href="http://www.eclipse.org/swt/snippets/#coolbar">CoolBar snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class CoolBar : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.windowProc windowProc;

    CoolItem [] items;
    CoolItem [] originalItems;
    bool locked;
    bool ignoreResize;
    private static /+const+/ WNDPROC ReBarProc;
    mixin(gshared!(`static const TCHAR[] ReBarClass = OS.REBARCLASSNAME;`));

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
            icex.dwICC = OS.ICC_COOL_CLASSES;
            OS.InitCommonControlsEx (&icex);
            WNDCLASS lpWndClass;
            OS.GetClassInfo (null, ReBarClass.ptr, &lpWndClass);
            ReBarProc = lpWndClass.lpfnWndProc;
            static_this_completed = true;
        }
    }

    static const int SEPARATOR_WIDTH = 2;
    static const int MAX_WIDTH = 0x7FFF;
    static const int DEFAULT_COOLBAR_WIDTH = 0;
    static const int DEFAULT_COOLBAR_HEIGHT = 0;

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
 * @see SWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    static_this();
    super (parent, checkStyle (style));
    /*
    * Ensure that either of HORIZONTAL or VERTICAL is set.
    * NOTE: HORIZONTAL and VERTICAL have the same values
    * as H_SCROLL and V_SCROLL so it is necessary to first
    * clear these bits to avoid scroll bars and then reset
    * the bits using the original style supplied by the
    * programmer.
    *
    * NOTE: The CCS_VERT style cannot be applied when the
    * widget is created because of this conflict.
    */
    if ((style & SWT.VERTICAL) !is 0) {
        this.style |= SWT.VERTICAL;
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        OS.SetWindowLong (handle, OS.GWL_STYLE, bits | OS.CCS_VERT);
    } else {
        this.style |= SWT.HORIZONTAL;
    }
}

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    return OS.CallWindowProc (ReBarProc, hwnd, msg, wParam, lParam);
}

static int checkStyle (int style) {
    style |= SWT.NO_FOCUS;
    /*
    * Even though it is legal to create this widget
    * with scroll bars, they serve no useful purpose
    * because they do not automatically scroll the
    * widget's client area.  The fix is to clear
    * the SWT style.
    */
    return style & ~(SWT.H_SCROLL | SWT.V_SCROLL);
}

override protected void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = 0, height = 0;
    int border = getBorderWidth ();
    int newWidth = wHint is SWT.DEFAULT ? 0x3FFF : wHint + (border * 2);
    int newHeight = hHint is SWT.DEFAULT ? 0x3FFF : hHint + (border * 2);
    auto count = OS.SendMessage (handle, OS.RB_GETBANDCOUNT, 0, 0);
    if (count !is 0) {
        ignoreResize = true;
        bool redraw = false;
        if (OS.IsWindowVisible (handle)) {
            if (OS.COMCTL32_MAJOR >= 6) {
                redraw = true;
                OS.UpdateWindow (handle);
                OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
            } else {
                redraw = drawCount is 0;
                if (redraw) {
                    OS.UpdateWindow (handle);
                    OS.SendMessage (handle, OS.WM_SETREDRAW, 0, 0);
                }
            }
        }
        RECT oldRect;
        OS.GetWindowRect (handle, &oldRect);
        int oldWidth = oldRect.right - oldRect.left;
        int oldHeight = oldRect.bottom - oldRect.top;
        int flags = OS.SWP_NOACTIVATE | OS.SWP_NOMOVE | OS.SWP_NOREDRAW | OS.SWP_NOZORDER;
        SetWindowPos (handle, null, 0, 0, newWidth, newHeight, flags);
        RECT rect;
        OS.SendMessage (handle, OS.RB_GETRECT, count - 1, &rect);
        height = Math.max (height, rect.bottom);
        SetWindowPos (handle, null, 0, 0, oldWidth, oldHeight, flags);
        REBARBANDINFO rbBand;
        rbBand.cbSize = REBARBANDINFO.sizeof;
        rbBand.fMask = OS.RBBIM_IDEALSIZE | OS.RBBIM_STYLE;
        int rowWidth = 0;
        for (int i = 0; i < count; i++) {
            OS.SendMessage(handle, OS.RB_GETBANDINFO, i, &rbBand);
            if ((rbBand.fStyle & OS.RBBS_BREAK) !is 0) {
                width = Math.max(width, rowWidth);
                rowWidth = 0;
            }
            rowWidth += rbBand.cxIdeal + getMargin (i);
        }
        width = Math.max(width, rowWidth);
        if (redraw) {
            if (OS.COMCTL32_MAJOR >= 6) {
                OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
            } else {
                OS.SendMessage (handle, OS.WM_SETREDRAW, 1, 0);
            }
        }
        ignoreResize = false;
    }
    if (width is 0) width = DEFAULT_COOLBAR_WIDTH;
    if (height is 0) height = DEFAULT_COOLBAR_HEIGHT;
    if ((style & SWT.VERTICAL) !is 0) {
        int tmp = width;
        width = height;
        height = tmp;
    }
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    height += border * 2;
    width += border * 2;
    return new Point (width, height);
}

override void createHandle () {
    super.createHandle ();
    state &= ~(CANVAS | THEME_BACKGROUND);

    /*
    * Feature in Windows.  When the control is created,
    * it does not use the default system font.  A new HFONT
    * is created and destroyed when the control is destroyed.
    * This means that a program that queries the font from
    * this control, uses the font in another control and then
    * destroys this control will have the font unexpectedly
    * destroyed in the other control.  The fix is to assign
    * the font ourselves each time the control is created.
    * The control will not destroy a font that it did not
    * create.
    */
    auto hFont = OS.GetStockObject (OS.SYSTEM_FONT);
    OS.SendMessage (handle, OS.WM_SETFONT, hFont, 0);
}

void createItem (CoolItem item, int index) {
    auto count = OS.SendMessage (handle, OS.RB_GETBANDCOUNT, 0, 0);
    if (!(0 <= index && index <= count)) error (SWT.ERROR_INVALID_RANGE);
    int id = 0;
    while (id < items.length && items [id] !is null) id++;
    if (id is items.length) {
        CoolItem [] newItems = new CoolItem [items.length + 4];
        System.arraycopy (items, 0, newItems, 0, items.length);
        items = newItems;
    }
    auto hHeap = OS.GetProcessHeap ();
    auto lpText = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, TCHAR.sizeof);
    REBARBANDINFO rbBand;
    rbBand.cbSize = REBARBANDINFO.sizeof;
    rbBand.fMask = OS.RBBIM_TEXT | OS.RBBIM_STYLE | OS.RBBIM_ID;
    rbBand.fStyle = OS.RBBS_VARIABLEHEIGHT | OS.RBBS_GRIPPERALWAYS;
    if ((item.style & SWT.DROP_DOWN) !is 0) {
        rbBand.fStyle |= OS.RBBS_USECHEVRON;
    }
    rbBand.lpText = lpText;
    rbBand.wID = id;

    /*
    * Feature in Windows.  When inserting an item at end of a row,
    * sometimes, Windows will begin to place the item on the right
    * side of the cool bar.  The fix is to resize the new items to
    * the maximum size and then resize the next to last item to the
    * ideal size.
    */
    auto lastIndex = getLastIndexOfRow (index - 1);
    bool fixLast = index is lastIndex + 1;
    if (fixLast) {
        rbBand.fMask |= OS.RBBIM_SIZE;
        rbBand.cx = MAX_WIDTH;
    }

    /*
    * Feature in Windows. Is possible that the item at index zero
    * has the RBBS_BREAK flag set. When a new item is inserted at
    * position zero, the previous item at position zero moves to
    * a new line.  The fix is to detect this case and clear the
    * RBBS_BREAK flag on the previous item before inserting the
    * new item.
    */
    if (index is 0 && count > 0) {
        getItem (0).setWrap (false);
    }

    /* Insert the item */
    if (OS.SendMessage (handle, OS.RB_INSERTBAND, index, &rbBand) is 0) {
        error (SWT.ERROR_ITEM_NOT_ADDED);
    }

    /* Resize the next to last item to the ideal size */
    if (fixLast) {
        resizeToPreferredWidth (lastIndex);
    }

    OS.HeapFree (hHeap, 0, lpText);
    items [item.id = id] = item;
    int length = cast(int)/*64bit*/originalItems.length;
    CoolItem [] newOriginals = new CoolItem [length + 1];
    System.arraycopy (originalItems, 0, newOriginals, 0, index);
    System.arraycopy (originalItems, index, newOriginals, index + 1, length - index);
    newOriginals [index] = item;
    originalItems = newOriginals;
}

override void createWidget () {
    super.createWidget ();
    items = new CoolItem [4];
    originalItems = new CoolItem [0];
}

void destroyItem (CoolItem item) {
    auto index = OS.SendMessage (handle, OS.RB_IDTOINDEX, item.id, 0);
    auto count = OS.SendMessage (handle, OS.RB_GETBANDCOUNT, 0, 0);
    if (count !is 0) {
        auto lastIndex = getLastIndexOfRow (index);
        if (index is lastIndex) {
            /*
            * Feature in Windows.  If the last item in a row is
            * given its ideal size, it will be placed at the far
            * right hand edge of the coolbar.  It is preferred
            * that the last item appear next to the second last
            * item.  The fix is to size the last item of each row
            * so that it occupies all the available space to the
            * right in the row.
            */
            resizeToMaximumWidth (lastIndex - 1);
        }
    }

    /*
    * Feature in Windows.  When Windows removed a rebar
    * band, it makes the band child invisible.  The fix
    * is to show the child.
    */
    Control control = item.control;
    bool wasVisible = control !is null && !control.isDisposed() && control.getVisible ();

    /*
    * When a wrapped item is being deleted, make the next
    * item in the row wrapped in order to preserve the row.
    * In order to avoid an unnecessary layout, temporarily
    * ignore WM_SIZE.  If the next item is wrapped then a
    * row will be deleted and the WM_SIZE is necessary.
    */
    CoolItem nextItem = null;
    if (item.getWrap ()) {
        if (index + 1 < count) {
            nextItem = getItem (cast(int)/*64bit*/index + 1);
            ignoreResize = !nextItem.getWrap ();
        }
    }
    if (OS.SendMessage (handle, OS.RB_DELETEBAND, index, 0) is 0) {
        error (SWT.ERROR_ITEM_NOT_REMOVED);
    }
    items [item.id] = null;
    item.id = -1;
    if (ignoreResize) {
        nextItem.setWrap (true);
        ignoreResize = false;
    }

    /* Restore the visible state of the control */
    if (wasVisible) control.setVisible (true);

    index = 0;
    while (index < originalItems.length) {
        if (originalItems [index] is item) break;
        index++;
    }
    int length = cast(int)/*64bit*/originalItems.length - 1;
    CoolItem [] newOriginals = new CoolItem [length];
    System.arraycopy (originalItems, 0, newOriginals, 0, index);
    System.arraycopy (originalItems, index + 1, newOriginals, index, length - index);
    originalItems = newOriginals;
}

override void drawThemeBackground (HDC hDC, HWND hwnd, RECT* rect) {
    if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
        if (background is -1 && (style & SWT.FLAT) !is 0) {
            Control control = findBackgroundControl ();
            if (control !is null && control.backgroundImage !is null) {
                fillBackground (hDC, control.getBackgroundPixel (), rect);
                return;
            }
        }
    }
    RECT rect2;
    OS.GetClientRect (handle, &rect2);
    OS.MapWindowPoints (handle, hwnd, cast(POINT*) &rect2, 2);
    POINT lpPoint;
    OS.SetWindowOrgEx (hDC, -rect2.left, -rect2.top, &lpPoint);
    OS.SendMessage (handle, OS.WM_PRINT, hDC, OS.PRF_CLIENT | OS.PRF_ERASEBKGND);
    OS.SetWindowOrgEx (hDC, lpPoint.x, lpPoint.y, null);
}

override Control findThemeControl () {
    if ((style & SWT.FLAT) !is 0) return this;
    return background is -1 && backgroundImage is null ? this : super.findThemeControl ();
}

int getMargin (int index) {
    int margin = 0;
    if (OS.COMCTL32_MAJOR >= 6) {
        MARGINS margins;
        OS.SendMessage (handle, OS.RB_GETBANDMARGINS, 0, &margins);
        margin += margins.cxLeftWidth + margins.cxRightWidth;
    }
    RECT rect;
    OS.SendMessage (handle, OS.RB_GETBANDBORDERS, index, &rect);
    if ((style & SWT.FLAT) !is 0) {
        /*
        * Bug in Windows.  When the style bit  RBS_BANDBORDERS is not set
        * the rectangle returned by RBS_BANDBORDERS is four pixels too small.
        * The fix is to add four pixels to the result.
        */
        if ((style & SWT.VERTICAL) !is 0) {
            margin += rect.top + 4;
        } else {
            margin += rect.left + 4;
        }
    } else {
        if ((style & SWT.VERTICAL) !is 0) {
            margin += rect.top + rect.bottom;
        } else {
            margin += rect.left + rect.right;
        }
    }
    if ((style & SWT.FLAT) is 0) {
        if (!isLastItemOfRow (index)) {
            margin += CoolBar.SEPARATOR_WIDTH;
        }
    }
    return margin;
}

/**
 * Returns the item that is currently displayed at the given,
 * zero-relative index. Throws an exception if the index is
 * out of range.
 *
 * @param index the visual index of the item to return
 * @return the item at the given visual index
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public CoolItem getItem (int index) {
    checkWidget ();
    auto count = OS.SendMessage (handle, OS.RB_GETBANDCOUNT, 0, 0);
    if (!(0 <= index && index < count)) error (SWT.ERROR_INVALID_RANGE);
    REBARBANDINFO rbBand;
    rbBand.cbSize = REBARBANDINFO.sizeof;
    rbBand.fMask = OS.RBBIM_ID;
    OS.SendMessage (handle, OS.RB_GETBANDINFO, index, &rbBand);
    return items [rbBand.wID];
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
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.RB_GETBANDCOUNT, 0, 0);
}

/**
 * Returns an array of zero-relative ints that map
 * the creation order of the receiver's items to the
 * order in which they are currently being displayed.
 * <p>
 * Specifically, the indices of the returned array represent
 * the current visual order of the items, and the contents
 * of the array represent the creation order of the items.
 * </p><p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the current visual order of the receiver's items
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int [] getItemOrder () {
    checkWidget ();
    auto count = OS.SendMessage (handle, OS.RB_GETBANDCOUNT, 0, 0);
    int [] indices = new int [count];
    REBARBANDINFO rbBand;
    rbBand.cbSize = REBARBANDINFO.sizeof;
    rbBand.fMask = OS.RBBIM_ID;
    for (int i=0; i<count; i++) {
        OS.SendMessage (handle, OS.RB_GETBANDINFO, i, &rbBand);
        CoolItem item = items [rbBand.wID];
        int index = 0;
        while (index<originalItems.length) {
            if (originalItems [index] is item) break;
            index++;
        }
        if (index is originalItems.length) error (SWT.ERROR_CANNOT_GET_ITEM);
        indices [i] = index;
    }
    return indices;
}

/**
 * Returns an array of <code>CoolItem</code>s in the order
 * in which they are currently being displayed.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the receiver's items in their current visual order
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public CoolItem [] getItems () {
    checkWidget ();
    auto count = OS.SendMessage (handle, OS.RB_GETBANDCOUNT, 0, 0);
    CoolItem [] result = new CoolItem [count];
    REBARBANDINFO rbBand;
    rbBand.cbSize = REBARBANDINFO.sizeof;
    rbBand.fMask = OS.RBBIM_ID;
    for (int i=0; i<count; i++) {
        OS.SendMessage (handle, OS.RB_GETBANDINFO, i, &rbBand);
        result [i] = items [rbBand.wID];
    }
    return result;
}

/**
 * Returns an array of points whose x and y coordinates describe
 * the widths and heights (respectively) of the items in the receiver
 * in the order in which they are currently being displayed.
 *
 * @return the receiver's item sizes in their current visual order
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point [] getItemSizes () {
    checkWidget ();
    auto count = OS.SendMessage (handle, OS.RB_GETBANDCOUNT, 0, 0);
    Point [] sizes = new Point [count];
    REBARBANDINFO rbBand;
    rbBand.cbSize = REBARBANDINFO.sizeof;
    rbBand.fMask = OS.RBBIM_CHILDSIZE;
    int separator = (style & SWT.FLAT) is 0 ? SEPARATOR_WIDTH : 0;
    MARGINS margins;
    for (int i=0; i<count; i++) {
        RECT rect;
        OS.SendMessage (handle, OS.RB_GETRECT, i, &rect);
        OS.SendMessage (handle, OS.RB_GETBANDINFO, i, &rbBand);
        if (OS.COMCTL32_MAJOR >= 6) {
            OS.SendMessage (handle, OS.RB_GETBANDMARGINS, 0, &margins);
            rect.left -= margins.cxLeftWidth;
            rect.right += margins.cxRightWidth;
        }
        if (!isLastItemOfRow(i)) rect.right += separator;
        if ((style & SWT.VERTICAL) !is 0) {
            sizes [i] = new Point (rbBand.cyChild, rect.right - rect.left);
        } else {
            sizes [i] = new Point (rect.right - rect.left, rbBand.cyChild);
        }
    }
    return sizes;
}

ptrdiff_t getLastIndexOfRow (ptrdiff_t index) {
    auto count = OS.SendMessage (handle, OS.RB_GETBANDCOUNT, 0, 0);
    if (count is 0) return -1;
    REBARBANDINFO rbBand;
    rbBand.cbSize = REBARBANDINFO.sizeof;
    rbBand.fMask = OS.RBBIM_STYLE;
    for (auto i=index + 1; i<count; i++) {
        OS.SendMessage (handle, OS.RB_GETBANDINFO, i, &rbBand);
        if ((rbBand.fStyle & OS.RBBS_BREAK) !is 0) {
            return i - 1;
        }
    }
    return count - 1;
}

bool isLastItemOfRow (int index) {
    auto count = OS.SendMessage (handle, OS.RB_GETBANDCOUNT, 0, 0);
    if (index + 1 is count) return true;
    REBARBANDINFO rbBand;
    rbBand.cbSize = REBARBANDINFO.sizeof;
    rbBand.fMask = OS.RBBIM_STYLE;
    OS.SendMessage (handle, OS.RB_GETBANDINFO, index + 1, &rbBand);
    return (rbBand.fStyle & OS.RBBS_BREAK) !is 0;
}

/**
 * Returns whether or not the receiver is 'locked'. When a coolbar
 * is locked, its items cannot be repositioned.
 *
 * @return true if the coolbar is locked, false otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 */
public bool getLocked () {
    checkWidget ();
    return locked;
}

/**
 * Returns an array of ints that describe the zero-relative
 * indices of any item(s) in the receiver that will begin on
 * a new row. The 0th visible item always begins the first row,
 * therefore it does not count as a wrap index.
 *
 * @return an array containing the receiver's wrap indices, or an empty array if all items are in one row
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int [] getWrapIndices () {
    checkWidget ();
    CoolItem [] items = getItems ();
    int [] indices = new int [items.length];
    int count = 0;
    for (int i=0; i<items.length; i++) {
        if (items [i].getWrap ()) indices [count++] = i;
    }
    int [] result = new int [count];
    System.arraycopy (indices, 0, result, 0, count);
    return result;
}

/**
 * Searches the receiver's items in the order they are currently
 * being displayed, starting at the first item (index 0), until
 * an item is found that is equal to the argument, and returns
 * the index of that item. If no item is found, returns -1.
 *
 * @param item the search item
 * @return the visual order index of the search item, or -1 if the item is not found
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the item is disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (CoolItem item) {
    checkWidget ();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.RB_IDTOINDEX, item.id, 0);
}

void resizeToPreferredWidth (ptrdiff_t index) {
    /*
    * Bug in Windows.  When RB_GETBANDBORDERS is sent
    * with an index out of range, Windows GP's.  The
    * fix is to ensure the index is in range.
    */
    auto count = OS.SendMessage(handle, OS.RB_GETBANDCOUNT, 0, 0);
    if (0 <= index && index < count) {
        REBARBANDINFO rbBand;
        rbBand.cbSize = REBARBANDINFO.sizeof;
        rbBand.fMask = OS.RBBIM_IDEALSIZE;
        OS.SendMessage (handle, OS.RB_GETBANDINFO, index, &rbBand);
        RECT rect;
        OS.SendMessage (handle, OS.RB_GETBANDBORDERS, index, &rect);
        rbBand.cx = rbBand.cxIdeal + rect.left;
        if ((style & SWT.FLAT) is 0) rbBand.cx += rect.right;
        rbBand.fMask = OS.RBBIM_SIZE;
        OS.SendMessage (handle, OS.RB_SETBANDINFO, index, &rbBand);
    }
}

void resizeToMaximumWidth (ptrdiff_t index) {
    REBARBANDINFO rbBand;
    rbBand.cbSize = REBARBANDINFO.sizeof;
    rbBand.fMask = OS.RBBIM_SIZE;
    rbBand.cx = MAX_WIDTH;
    OS.SendMessage (handle, OS.RB_SETBANDINFO, index, &rbBand);
}

override void releaseChildren (bool destroy) {
    if (items !is null) {
        for (int i=0; i<items.length; i++) {
            CoolItem item = items [i];
            if (item !is null && !item.isDisposed ()) {
                item.release (false);
            }
        }
        items = null;
    }
    super.releaseChildren (destroy);
}

override void removeControl (Control control) {
    super.removeControl (control);
    for (int i=0; i<items.length; i++) {
        CoolItem item = items [i];
        if (item !is null && item.control is control) {
            item.setControl (null);
        }
    }
}

override void setBackgroundPixel (int pixel) {
    if (pixel is -1) pixel = defaultBackground ();
    OS.SendMessage (handle, OS.RB_SETBKCOLOR, 0, pixel);
    setItemColors (cast(int)/*64bit*/OS.SendMessage (handle, OS.RB_GETTEXTCOLOR, 0, 0), pixel);
    /*
    * Feature in Windows.  For some reason, Windows
    * does not fully erase the coolbar area and coolbar
    * items when you set the background.  The fix is
    * to invalidate the coolbar area.
    */
    if (!OS.IsWindowVisible (handle)) return;
    static if (OS.IsWinCE) {
        OS.InvalidateRect (handle, null, true);
    } else {
        int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE | OS.RDW_ALLCHILDREN;
        OS.RedrawWindow (handle, null, null, flags);
    }
}

override void setForegroundPixel (int pixel) {
    if (pixel is -1) pixel = defaultForeground ();
    OS.SendMessage (handle, OS.RB_SETTEXTCOLOR, 0, pixel);
    setItemColors (pixel, cast(int)/*64bit*/OS.SendMessage (handle, OS.RB_GETBKCOLOR, 0, 0));
}

void setItemColors (int foreColor, int backColor) {
    auto count = OS.SendMessage (handle, OS.RB_GETBANDCOUNT, 0, 0);
    REBARBANDINFO rbBand;
    rbBand.cbSize = REBARBANDINFO.sizeof;
    rbBand.fMask = OS.RBBIM_COLORS;
    rbBand.clrFore = foreColor;
    rbBand.clrBack = backColor;
    for (int i=0; i<count; i++) {
        OS.SendMessage (handle, OS.RB_SETBANDINFO, i, &rbBand);
    }
}

/**
 * Sets the receiver's item order, wrap indices, and item sizes
 * all at once. This method is typically used to restore the
 * displayed state of the receiver to a previously stored state.
 * <p>
 * The item order is the order in which the items in the receiver
 * should be displayed, given in terms of the zero-relative ordering
 * of when the items were added.
 * </p><p>
 * The wrap indices are the indices of all item(s) in the receiver
 * that will begin on a new row. The indices are given in the order
 * specified by the item order. The 0th item always begins the first
 * row, therefore it does not count as a wrap index. If wrap indices
 * is null or empty, the items will be placed on one line.
 * </p><p>
 * The sizes are specified in an array of points whose x and y
 * coordinates describe the new widths and heights (respectively)
 * of the receiver's items in the order specified by the item order.
 * </p>
 *
 * @param itemOrder an array of indices that describe the new order to display the items in
 * @param wrapIndices an array of wrap indices, or null
 * @param sizes an array containing the new sizes for each of the receiver's items in visual order
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if item order or sizes is not the same length as the number of items</li>
 * </ul>
 */
public void setItemLayout (int [] itemOrder, int [] wrapIndices, Point [] sizes) {
    checkWidget ();
    setRedraw (false);
    setItemOrder (itemOrder);
    setWrapIndices (wrapIndices);
    setItemSizes (sizes);
    setRedraw (true);
}

/*
 * Sets the order that the items in the receiver should
 * be displayed in to the given argument which is described
 * in terms of the zero-relative ordering of when the items
 * were added.
 *
 * @param itemOrder the new order to display the items in
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the item order is not the same length as the number of items</li>
 * </ul>
 */
void setItemOrder (int [] itemOrder) {
    // SWT extension: allow null array
    //if (itemOrder is null) error (SWT.ERROR_NULL_ARGUMENT);
    auto itemCount = OS.SendMessage (handle, OS.RB_GETBANDCOUNT, 0, 0);
    if (itemOrder.length !is itemCount) error (SWT.ERROR_INVALID_ARGUMENT);

    /* Ensure that itemOrder does not contain any duplicates. */
    bool [] set = new bool [itemCount];
    for (int i=0; i<itemOrder.length; i++) {
        int index = itemOrder [i];
        if (index < 0 || index >= itemCount) error (SWT.ERROR_INVALID_RANGE);
        if (set [index]) error (SWT.ERROR_INVALID_ARGUMENT);
        set [index] = true;
    }

    //REBARBANDINFO rbBand;
    //rbBand.cbSize = REBARBANDINFO.sizeof;
    for (int i=0; i<itemOrder.length; i++) {
        int id = originalItems [itemOrder [i]].id;
        auto index = OS.SendMessage (handle, OS.RB_IDTOINDEX, id, 0);
        if (index !is i) {
            auto lastItemSrcRow = getLastIndexOfRow (index);
            auto lastItemDstRow = getLastIndexOfRow (i);
            if (index is lastItemSrcRow) {
                resizeToPreferredWidth (index);
            }
            if (i is lastItemDstRow) {
                resizeToPreferredWidth (i);
            }

            /* Move the item */
            OS.SendMessage (handle, OS.RB_MOVEBAND, index, i);

            if (index is lastItemSrcRow && index - 1 >= 0) {
                resizeToMaximumWidth (index - 1);
            }
            if (i is lastItemDstRow) {
                resizeToMaximumWidth (i);
            }
        }
    }
}

/*
 * Sets the width and height of the receiver's items to the ones
 * specified by the argument, which is an array of points whose x
 * and y coordinates describe the widths and heights (respectively)
 * in the order in which the items are currently being displayed.
 *
 * @param sizes an array containing the new sizes for each of the receiver's items in visual order
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the array of sizes is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the array of sizes is not the same length as the number of items</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
void setItemSizes (Point [] sizes) {
    // SWT extension: allow null array
    //if (sizes is null) error (SWT.ERROR_NULL_ARGUMENT);
    auto count = OS.SendMessage (handle, OS.RB_GETBANDCOUNT, 0, 0);
    if (sizes.length !is count) error (SWT.ERROR_INVALID_ARGUMENT);
    REBARBANDINFO rbBand;
    rbBand.cbSize = REBARBANDINFO.sizeof;
    rbBand.fMask = OS.RBBIM_ID;
    for (int i=0; i<count; i++) {
        OS.SendMessage (handle, OS.RB_GETBANDINFO, i, &rbBand);
        items [rbBand.wID].setSize (sizes [i].x, sizes [i].y);
    }
}

/**
 * Sets whether or not the receiver is 'locked'. When a coolbar
 * is locked, its items cannot be repositioned.
 *
 * @param locked lock the coolbar if true, otherwise unlock the coolbar
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 */
public void setLocked (bool locked) {
    checkWidget ();
    this.locked = locked;
    auto count = OS.SendMessage (handle, OS.RB_GETBANDCOUNT, 0, 0);
    REBARBANDINFO rbBand;
    rbBand.cbSize = REBARBANDINFO.sizeof;
    rbBand.fMask = OS.RBBIM_STYLE;
    for (int i=0; i<count; i++) {
        OS.SendMessage (handle, OS.RB_GETBANDINFO, i, &rbBand);
        if (locked) {
            rbBand.fStyle |= OS.RBBS_NOGRIPPER;
        } else {
            rbBand.fStyle &= ~OS.RBBS_NOGRIPPER;
        }
        OS.SendMessage (handle, OS.RB_SETBANDINFO, i, &rbBand);
    }
}

/**
 * Sets the indices of all item(s) in the receiver that will
 * begin on a new row. The indices are given in the order in
 * which they are currently being displayed. The 0th item
 * always begins the first row, therefore it does not count
 * as a wrap index. If indices is null or empty, the items
 * will be placed on one line.
 *
 * @param indices an array of wrap indices, or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setWrapIndices (int [] indices) {
    checkWidget ();
    if (indices is null) indices = new int [0];
    int count = getItemCount ();
    for (int i=0; i<indices.length; i++) {
        if (indices [i] < 0 || indices [i] >= count) {
            error (SWT.ERROR_INVALID_RANGE);
        }
    }
    setRedraw (false);
    CoolItem [] items = getItems ();
    for (int i=0; i<items.length; i++) {
        CoolItem item = items [i];
        if (item.getWrap ()) {
            resizeToPreferredWidth (i - 1);
            item.setWrap (false);
        }
    }
    resizeToMaximumWidth (count - 1);
    for (int i=0; i<indices.length; i++) {
        int index = indices [i];
        if (0 <= index && index < items.length) {
            CoolItem item = items [index];
            item.setWrap (true);
            resizeToMaximumWidth (index - 1);
        }
    }
    setRedraw (true);
}

override int widgetStyle () {
    int bits = super.widgetStyle () | OS.CCS_NODIVIDER | OS.CCS_NORESIZE;
    bits |= OS.RBS_VARHEIGHT | OS.RBS_DBLCLKTOGGLE;
    if ((style & SWT.FLAT) is 0) bits |= OS.RBS_BANDBORDERS;
    return bits;
}

override String windowClass () {
    return TCHARzToStr( ReBarClass.ptr );
}

override ptrdiff_t windowProc () {
    return cast(ptrdiff_t) ReBarProc;
}

override LRESULT WM_COMMAND (WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  When the coolbar window
    * proc processes WM_COMMAND, it forwards this
    * message to its parent.  This is done so that
    * children of this control that send this message
    * type to their parent will notify not only
    * this control but also the parent of this control,
    * which is typically the application window and
    * the window that is looking for the message.
    * If the control did not forward the message,
    * applications would have to subclass the control
    * window to see the message. Because the control
    * window is subclassed by SWT, the message
    * is delivered twice, once by SWT and once when
    * the message is forwarded by the window proc.
    * The fix is to avoid calling the window proc
    * for this control.
    */
    LRESULT result = super.WM_COMMAND (wParam, lParam);
    if (result !is null) return result;
    return LRESULT.ZERO;
}

override LRESULT WM_ERASEBKGND (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_ERASEBKGND (wParam, lParam);
    /*
    * Feature in Windows.  For some reason, Windows
    * does not fully erase the area that the cool bar
    * occupies when the size of the cool bar is larger
    * than the space occupied by the cool bar items.
    * The fix is to erase the cool bar background.
    *
    * NOTE: On versions of Windows prior to XP, for
    * some reason, the cool bar draws separators in
    * WM_ERASEBKGND.  Therefore it is essential to run
    * the cool bar window proc after the background has
    * been erased.
    */
    if (OS.COMCTL32_MAJOR < 6 || !OS.IsAppThemed ()) {
        drawBackground ( cast(HDC) wParam);
        return null;
    }
    return result;
}

override LRESULT WM_NOTIFY (WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  When the cool bar window
    * proc processes WM_NOTIFY, it forwards this
    * message to its parent.  This is done so that
    * children of this control that send this message
    * type to their parent will notify not only
    * this control but also the parent of this control,
    * which is typically the application window and
    * the window that is looking for the message.
    * If the control did not forward the message,
    * applications would have to subclass the control
    * window to see the message. Because the control
    * window is subclassed by SWT, the message
    * is delivered twice, once by SWT and once when
    * the message is forwarded by the window proc.
    * The fix is to avoid calling the window proc
    * for this control.
    */
    LRESULT result = super.WM_NOTIFY (wParam, lParam);
    if (result !is null) return result;
    return LRESULT.ZERO;
}

override LRESULT WM_SETREDRAW (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SETREDRAW (wParam, lParam);
    if (result !is null) return result;
    /*
    * Feature in Windows.  When redraw is turned off, the rebar
    * control does not call the default window proc.  This means
    * that the rebar will redraw and children of the rebar will
    * also redraw.  The fix is to call both the rebar window proc
    * and the default window proc.
    *
    * NOTE: The rebar control can resize itself in WM_SETREDRAW.
    * When redraw is turned off by the default window proc, this
    * can leave pixel corruption in the parent.  The fix is to
    * detect the size change and damage the previous area in the
    * parent.
    *
    * NOTE:  In version 6.00 of COMCTL32.DLL, when WM_SETREDRAW
    * is off, we cannot detect that the size has changed causing
    * pixel corruption.  The fix is to disallow WM_SETREDRAW by
    * not running the default window proc or the rebar window
    * proc.
    */
    if (OS.COMCTL32_MAJOR >= 6) return LRESULT.ZERO;
    Rectangle rect = getBounds ();
    auto code = callWindowProc (handle, OS.WM_SETREDRAW, wParam, lParam);
    OS.DefWindowProc (handle, OS.WM_SETREDRAW, wParam, lParam);
    if ( rect != getBounds ()) {
        parent.redraw (rect.x, rect.y, rect.width, rect.height, true);
    }
    return new LRESULT (code);
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    if (ignoreResize) {
        auto code = callWindowProc (handle, OS.WM_SIZE, wParam, lParam);
        if (code is 0) return LRESULT.ZERO;
        return new LRESULT (code);
    }
    //TEMPORARY CODE
//  if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
//      if (background is -1 && (style & SWT.FLAT) is 0) {
//          OS.InvalidateRect (handle, null, true);
//      }
//  }
    return super.WM_SIZE (wParam, lParam);
}

override LRESULT wmNotifyChild (NMHDR* hdr, WPARAM wParam, LPARAM lParam) {
    switch (hdr.code) {
        case OS.RBN_BEGINDRAG: {
            int pos = OS.GetMessagePos ();
            POINT pt;
            OS.POINTSTOPOINT (pt, pos);
            OS.ScreenToClient (handle, &pt);
            int button = display.lastButton !is 0 ? display.lastButton : 1;
            if (!sendDragEvent (button, pt.x, pt.y)) return LRESULT.ONE;
            break;
        }
        case OS.RBN_CHILDSIZE: {
            /*
            * Bug in Windows.  When Windows sets the size of the rebar band
            * child and the child is a combo box, the size of the drop down
            * portion of the combo box is resized to zero.  The fix is to set
            * the size of the control to the current size after the rebar has
            * already resized it.  If the control is not a combo, this does
            * nothing.  If the control is a combo, the drop down portion is
            * recalculated.
            */
            NMREBARCHILDSIZE* lprbcs = cast(NMREBARCHILDSIZE*)lParam;
            //OS.MoveMemory (lprbcs, lParam, NMREBARCHILDSIZE.sizeof);
            if (lprbcs.uBand !is -1) {
                CoolItem item = items [lprbcs.wID];
                Control control = item.control;
                if (control !is null) {
                    int width = lprbcs.rcChild.right - lprbcs.rcChild.left;
                    int height = lprbcs.rcChild.bottom - lprbcs.rcChild.top;
                    control.setBounds (lprbcs.rcChild.left, lprbcs.rcChild.top, width, height);
                }
            }
            break;
        }
        case OS.RBN_HEIGHTCHANGE: {
            if (!ignoreResize) {
                Point size = getSize ();
                int border = getBorderWidth ();
                int barHeight = cast(int)/*64bit*/OS.SendMessage (handle, OS.RB_GETBARHEIGHT, 0, 0);
                if ((style & SWT.VERTICAL) !is 0) {
                    setSize (barHeight + 2 * border, size.y);
                } else {
                    setSize (size.x, barHeight + 2 * border);
                }
            }
            break;
        }
        case OS.RBN_CHEVRONPUSHED: {
            NMREBARCHEVRON* lpnm = cast(NMREBARCHEVRON*)lParam;
            //OS.MoveMemory (lpnm, lParam, NMREBARCHEVRON.sizeof);
            CoolItem item = items [lpnm.wID];
            if (item !is null) {
                Event event = new Event();
                event.detail = SWT.ARROW;
                if ((style & SWT.VERTICAL) !is 0) {
                    event.x = lpnm.rc.right;
                    event.y = lpnm.rc.top;
                } else {
                    event.x = lpnm.rc.left;
                    event.y = lpnm.rc.bottom;
                }
                item.postEvent (SWT.Selection, event);
            }
            break;
        }
        case OS.NM_CUSTOMDRAW: {
            /*
            * Bug in Windows.  On versions of Windows prior to XP,
            * drawing the background color in NM_CUSTOMDRAW erases
            * the separators.  The fix is to draw the background
            * in WM_ERASEBKGND.
            */
            if (OS.COMCTL32_MAJOR < 6) break;
            if (findBackgroundControl () !is null || (style & SWT.FLAT) !is 0) {
                NMCUSTOMDRAW* nmcd = cast(NMCUSTOMDRAW*)lParam;
                //OS.MoveMemory (nmcd, lParam, NMCUSTOMDRAW.sizeof);
                switch (nmcd.dwDrawStage) {
                    case OS.CDDS_PREERASE:
                        return new LRESULT (OS.CDRF_SKIPDEFAULT | OS.CDRF_NOTIFYPOSTERASE);
                    case OS.CDDS_POSTERASE:
                        drawBackground (nmcd.hdc);
                        break;
                    default:
                }
            }
            break;
        }
        default:
    }
    return super.wmNotifyChild (hdr, wParam, lParam);
}
}
