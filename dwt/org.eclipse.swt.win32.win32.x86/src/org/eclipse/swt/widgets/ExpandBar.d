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
module org.eclipse.swt.widgets.ExpandBar;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.ExpandAdapter;
import org.eclipse.swt.events.ExpandEvent;
import org.eclipse.swt.events.ExpandListener;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Drawable;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.ExpandItem;
import org.eclipse.swt.widgets.ScrollBar;
import org.eclipse.swt.widgets.ExpandItem;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;

import java.lang.all;

/**
 * Instances of this class support the layout of selectable
 * expand bar items.
 * <p>
 * The item children that may be added to instances of this class
 * must be of type <code>ExpandItem</code>.
 * </p><p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>V_SCROLL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Expand, Collapse</dd>
 * </dl>
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see ExpandItem
 * @see ExpandEvent
 * @see ExpandListener
 * @see ExpandAdapter
 * @see <a href="http://www.eclipse.org/swt/snippets/#expandbar">ExpandBar snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.2
 */
public class ExpandBar : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.windowProc windowProc;

    ExpandItem[] items;
    int itemCount;
    ExpandItem focusItem;
    int spacing = 4;
    int yCurrentScroll;
    HFONT hFont;


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
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when an item in the receiver is expanded or collapsed
 * by sending it one of the messages defined in the <code>ExpandListener</code>
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
 * @see ExpandListener
 * @see #removeExpandListener
 */
public void addExpandListener (ExpandListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Expand, typedListener);
    addListener (SWT.Collapse, typedListener);
}

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    return OS.DefWindowProc (hwnd, msg, wParam, lParam);
}

override protected void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

static int checkStyle (int style) {
    style &= ~SWT.H_SCROLL;
    return style | SWT.NO_BACKGROUND;
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int height = 0, width = 0;
    if (wHint is SWT.DEFAULT || hHint is SWT.DEFAULT) {
        if (itemCount > 0) {
            auto hDC = OS.GetDC (handle);
            HTHEME hTheme;
            if (isAppThemed ()) {
                hTheme = display.hExplorerBarTheme ();
            }
            HFONT hCurrentFont, oldFont;
            if (hTheme is null) {
                if (hFont !is null) {
                    hCurrentFont = hFont;
                } else {
                    static if (!OS.IsWinCE) {
                        NONCLIENTMETRICS info;
                        info.cbSize = NONCLIENTMETRICS.sizeof;
                        if (OS.SystemParametersInfo (OS.SPI_GETNONCLIENTMETRICS, 0, &info, 0)) {
                            LOGFONT* logFont = &info.lfCaptionFont;
                            hCurrentFont = OS.CreateFontIndirect (logFont);
                        }
                    }
                }
                if (hCurrentFont !is null) {
                    oldFont = OS.SelectObject (hDC, hCurrentFont);
                }
            }
            height += spacing;
            for (int i = 0; i < itemCount; i++) {
                ExpandItem item = items [i];
                height += item.getHeaderHeight ();
                if (item.expanded) height += item.height;
                height += spacing;
                width = Math.max (width, item.getPreferredWidth (hTheme, hDC));
            }
            if (hCurrentFont !is null) {
                OS.SelectObject (hDC, oldFont);
                if (hCurrentFont !is hFont) OS.DeleteObject (hCurrentFont);
            }
            OS.ReleaseDC (handle, hDC);
        }
    }
    if (width is 0) width = DEFAULT_WIDTH;
    if (height is 0) height = DEFAULT_HEIGHT;
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    Rectangle trim = computeTrim (0, 0, width, height);
    return new Point (trim.width, trim.height);
}

override void createHandle () {
    super.createHandle ();
    state &= ~CANVAS;
    state |= TRACK_MOUSE;
}

void createItem (ExpandItem item, int style, int index) {
    if (!(0 <= index && index <= itemCount)) error (SWT.ERROR_INVALID_RANGE);
    if (itemCount is items.length) {
        ExpandItem [] newItems = new ExpandItem [itemCount + 4];
        System.arraycopy (items, 0, newItems, 0, items.length);
        items = newItems;
    }
    System.arraycopy (items, index, items, index + 1, itemCount - index);
    items [index] = item;
    itemCount++;
    if (focusItem is null) focusItem = item;

    RECT rect;
    OS.GetWindowRect (handle, &rect);
    item.width = Math.max (0, rect.right - rect.left - spacing * 2);
    layoutItems (index, true);
}

override void createWidget () {
    super.createWidget ();
    items = new ExpandItem [4];
    if (!isAppThemed ()) {
        backgroundMode = SWT.INHERIT_DEFAULT;
    }
}

override int defaultBackground() {
    if (!isAppThemed ()) {
        return OS.GetSysColor (OS.COLOR_WINDOW);
    }
    return super.defaultBackground();
}

void destroyItem (ExpandItem item) {
    int index = 0;
    while (index < itemCount) {
        if (items [index] is item) break;
        index++;
    }
    if (index is itemCount) return;
    if (item is focusItem) {
        int focusIndex = index > 0 ? index - 1 : 1;
        if (focusIndex < itemCount) {
            focusItem = items [focusIndex];
            focusItem.redraw (true);
        } else {
            focusItem = null;
        }
    }
    System.arraycopy (items, index + 1, items, index, --itemCount - index);
    items [itemCount] = null;
    item.redraw (true);
    layoutItems (index, true);
}

override void drawThemeBackground (HDC hDC, HWND hwnd, RECT* rect) {
    RECT rect2;
    OS.GetClientRect (handle, &rect2);
    OS.MapWindowPoints (handle, hwnd, cast(POINT*) &rect2, 2);
    OS.DrawThemeBackground (display.hExplorerBarTheme (), hDC, OS.EBP_NORMALGROUPBACKGROUND, 0, &rect2, null);
}

void drawWidget (GC gc, RECT* clipRect) {
    HTHEME hTheme;
    if (isAppThemed ()) {
        hTheme = display.hExplorerBarTheme ();
    }
    if (hTheme !is null) {
        RECT rect;
        OS.GetClientRect (handle, &rect);
        OS.DrawThemeBackground (hTheme, gc.handle, OS.EBP_HEADERBACKGROUND, 0, &rect, clipRect);
    } else {
        drawBackground (gc.handle);
    }
    bool drawFocus = false;
    if (handle is OS.GetFocus ()) {
        auto uiState = OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
        drawFocus = (uiState & OS.UISF_HIDEFOCUS) is 0;
    }
    HFONT hCurrentFont, oldFont;
    if (hTheme is null) {
        if (hFont !is null) {
            hCurrentFont = hFont;
        } else {
            if (!OS.IsWinCE) {
                NONCLIENTMETRICS info;
                info.cbSize = NONCLIENTMETRICS.sizeof;
                if (OS.SystemParametersInfo (OS.SPI_GETNONCLIENTMETRICS, 0, &info, 0)) {
                    LOGFONT* logFont = &info.lfCaptionFont;
                    hCurrentFont = OS.CreateFontIndirect (logFont);
                }
            }
        }
        if (hCurrentFont !is null) {
            oldFont = OS.SelectObject (gc.handle, hCurrentFont);
        }
        if (foreground !is -1) {
            OS.SetTextColor (gc.handle, foreground);
        }
    }
    for (int i = 0; i < itemCount; i++) {
        ExpandItem item = items[i];
        item.drawItem (gc, hTheme, clipRect, item is focusItem && drawFocus);
    }
    if (hCurrentFont !is null) {
        OS.SelectObject (gc.handle, oldFont);
        if (hCurrentFont !is hFont) OS.DeleteObject (hCurrentFont);
    }
}

override Control findBackgroundControl () {
    Control control = super.findBackgroundControl ();
    if (!isAppThemed ()) {
        if (control is null) control = this;
    }
    return control;
}

override Control findThemeControl () {
    return isAppThemed () ? this : super.findThemeControl ();
}

int getBandHeight () {
    if (hFont is null) return ExpandItem.CHEVRON_SIZE;
    auto hDC = OS.GetDC (handle);
    auto oldHFont = OS.SelectObject (hDC, hFont);
    TEXTMETRIC lptm;
    OS.GetTextMetrics (hDC, &lptm);
    OS.SelectObject (hDC, oldHFont);
    OS.ReleaseDC (handle, hDC);
    return Math.max (ExpandItem.CHEVRON_SIZE, lptm.tmHeight + 4);
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
public ExpandItem getItem (int index) {
    checkWidget ();
    if (!(0 <= index && index < itemCount)) error (SWT.ERROR_INVALID_RANGE);
    return items [index];
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
    return itemCount;
}

/**
 * Returns an array of <code>ExpandItem</code>s which are the items
 * in the receiver.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the items in the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public ExpandItem [] getItems () {
    checkWidget ();
    ExpandItem [] result = new ExpandItem [itemCount];
    System.arraycopy (items, 0, result, 0, itemCount);
    return result;
}

/**
 * Returns the receiver's spacing.
 *
 * @return the spacing
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSpacing () {
    checkWidget ();
    return spacing;
}

/**
 * Searches the receiver's list starting at the first item
 * (index 0) until an item is found that is equal to the
 * argument, and returns the index of that item. If no item
 * is found, returns -1.
 *
 * @param item the search item
 * @return the index of the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the item has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (ExpandItem item) {
    checkWidget ();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    for (int i = 0; i < itemCount; i++) {
        if (items [i] is item) return i;
    }
    return -1;
}

bool isAppThemed () {
    if (background !is -1) return false;
    if (foreground !is -1) return false;
    if (hFont !is null) return false;
    return OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ();
}

void layoutItems (int index, bool setScrollbar_) {
    if (index < itemCount) {
        int y = spacing - yCurrentScroll;
        for (int i = 0; i < index; i++) {
            ExpandItem item = items [i];
            if (item.expanded) y += item.height;
            y += item.getHeaderHeight () + spacing;
        }
        for (int i = index; i < itemCount; i++) {
            ExpandItem item = items [i];
            item.setBounds (spacing, y, 0, 0, true, false);
            if (item.expanded) y += item.height;
            y += item.getHeaderHeight () + spacing;
        }
    }
    if (setScrollbar_) setScrollbar ();
}

override void releaseChildren (bool destroy) {
    if (items !is null) {
        for (int i=0; i<items.length; i++) {
            ExpandItem item = items [i];
            if (item !is null && !item.isDisposed ()) {
                item.release (false);
            }
        }
        items = null;
    }
    focusItem = null;
    super.releaseChildren (destroy);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when items in the receiver are expanded or collapsed.
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
 * @see ExpandListener
 * @see #addExpandListener
 */
public void removeExpandListener (ExpandListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Expand, listener);
    eventTable.unhook (SWT.Collapse, listener);
}

override void setBackgroundPixel (int pixel) {
    super.setBackgroundPixel (pixel);
    static if (!OS.IsWinCE) {
        int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE | OS.RDW_ALLCHILDREN;
        OS.RedrawWindow (handle, null, null, flags);
    }
}

override public void setFont (Font font) {
    super.setFont (font);
    hFont = font !is null ? font.handle : null;
    layoutItems (0, true);
}

override void setForegroundPixel (int pixel) {
    super.setForegroundPixel (pixel);
    static if (!OS.IsWinCE) {
        int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE | OS.RDW_ALLCHILDREN;
        OS.RedrawWindow (handle, null, null, flags);
    }
}

void setScrollbar () {
    if (itemCount is 0) return;
    if ((style & SWT.V_SCROLL) is 0) return;
    RECT rect;
    OS.GetClientRect (handle, &rect);
    int height = rect.bottom - rect.top;
    ExpandItem item = items [itemCount - 1];
    int maxHeight = item.y + getBandHeight () + spacing;
    if (item.expanded) maxHeight += item.height;

    //claim bottom free space
    if (yCurrentScroll > 0 && height > maxHeight) {
        yCurrentScroll = Math.max (0, yCurrentScroll + maxHeight - height);
        layoutItems (0, false);
    }
    maxHeight += yCurrentScroll;

    SCROLLINFO info;
    info.cbSize = SCROLLINFO.sizeof;
    info.fMask = OS.SIF_RANGE | OS.SIF_PAGE | OS.SIF_POS;
    info.nMin = 0;
    info.nMax = maxHeight;
    info.nPage = height;
    info.nPos = Math.min (yCurrentScroll, info.nMax);
    if (info.nPage !is 0) info.nPage++;
    OS.SetScrollInfo (handle, OS.SB_VERT, &info, true);
}

/**
 * Sets the receiver's spacing. Spacing specifies the number of pixels allocated around
 * each item.
 * 
 * @param spacing the spacing around each item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSpacing (int spacing) {
    checkWidget ();
    if (spacing < 0) return;
    if (spacing is this.spacing) return;
    this.spacing = spacing;
    RECT rect;
    OS.GetClientRect (handle, &rect);
    int width = Math.max (0, (rect.right - rect.left) - spacing * 2);
    for (int i = 0; i < itemCount; i++) {
        ExpandItem item = items[i];
        if (item.width !is width) item.setBounds (0, 0, width, item.height, false, true);
    }
    layoutItems (0, true);
    OS.InvalidateRect (handle, null, true);
}

void showItem (ExpandItem item) {
    Control control = item.control;
    if (control !is null && !control.isDisposed ()) {
        control.setVisible (item.expanded);
    }
    item.redraw (true);
    int index = indexOf (item);
    layoutItems (index + 1, true);
}

void showFocus (bool up) {
    RECT rect;
    OS.GetClientRect (handle, &rect);
    int height = rect.bottom - rect.top;
    int updateY = 0;
    if (up) {
        if (focusItem.y < 0) {
            updateY = Math.min (yCurrentScroll, -focusItem.y);
        }
    } else {
        int itemHeight = focusItem.y + getBandHeight ();
        if (focusItem.expanded) {
            if (height >= getBandHeight () + focusItem.height) {
                itemHeight += focusItem.height;
            }
        }
        if (itemHeight > height) {
            updateY = height - itemHeight;
        }
    }
    if (updateY !is 0) {
        yCurrentScroll = Math.max (0, yCurrentScroll - updateY);
        if ((style & SWT.V_SCROLL) !is 0) {
            SCROLLINFO info;
            info.cbSize = SCROLLINFO.sizeof;
            info.fMask = OS.SIF_POS;
            info.nPos = yCurrentScroll;
            OS.SetScrollInfo (handle, OS.SB_VERT, &info, true);
        }
        OS.ScrollWindowEx (handle, 0, updateY, null, null, null, null, OS.SW_SCROLLCHILDREN | OS.SW_INVALIDATE);
        for (int i = 0; i < itemCount; i++) {
            items [i].y += updateY;
        }
    }
}

override String windowClass () {
    return display.windowClass;
}

override ptrdiff_t windowProc () {
    return cast(ptrdiff_t) display.windowProc;
}

override LRESULT WM_KEYDOWN (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_KEYDOWN (wParam, lParam);
    if (result !is null) return result;
    if (focusItem is null) return result;
    switch (wParam) {
        case OS.VK_SPACE:
        case OS.VK_RETURN:
            Event event = new Event ();
            event.item = focusItem;
            sendEvent (focusItem.expanded ? SWT.Collapse : SWT.Expand, event);
            focusItem.expanded = !focusItem.expanded;
            showItem (focusItem);
            return LRESULT.ZERO;
        case OS.VK_UP: {
            int focusIndex = indexOf (focusItem);
            if (focusIndex > 0) {
                focusItem.redraw (true);
                focusItem = items [focusIndex - 1];
                focusItem.redraw (true);
                showFocus (true);
                return LRESULT.ZERO;
            }
            break;
        }
        case OS.VK_DOWN: {
            int focusIndex = indexOf (focusItem);
            if (focusIndex < itemCount - 1) {
                focusItem.redraw (true);
                focusItem = items [focusIndex + 1];
                focusItem.redraw (true);
                showFocus (false);
                return LRESULT.ZERO;
            }
            break;
        }
        default:
    }
    return result;
}

override LRESULT WM_KILLFOCUS (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_KILLFOCUS (wParam, lParam);
    if (focusItem !is null) focusItem.redraw (true);
    return result;
}

override LRESULT WM_LBUTTONDOWN (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_LBUTTONDOWN (wParam, lParam);
    if (result is LRESULT.ZERO) return result;
    int x = OS.GET_X_LPARAM (lParam);
    int y = OS.GET_Y_LPARAM (lParam);
    for (int i = 0; i < itemCount; i++) {
        ExpandItem item = items[i];
        bool hover = item.isHover (x, y);
        if (hover && focusItem !is item) {
            focusItem.redraw (true);
            focusItem = item;
            focusItem.redraw (true);
            forceFocus ();
            break;
        }
    }
    return result;
}

override LRESULT WM_LBUTTONUP (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_LBUTTONUP (wParam, lParam);
    if (result is LRESULT.ZERO) return result;
    if (focusItem is null) return result;
    int x = OS.GET_X_LPARAM (lParam);
    int y = OS.GET_Y_LPARAM (lParam);
    bool hover = focusItem.isHover (x, y);
    if (hover) {
        Event event = new Event ();
        event.item = focusItem;
        sendEvent (focusItem.expanded ? SWT.Collapse : SWT.Expand, event);
        focusItem.expanded = !focusItem.expanded;
        showItem (focusItem);
    }
    return result;
}

override LRESULT WM_MOUSELEAVE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_MOUSELEAVE (wParam, lParam);
    if (result !is null) return result;
    for (int i = 0; i < itemCount; i++) {
        ExpandItem item = items [i];
        if (item.hover) {
            item.hover = false;
            item.redraw (false);
            break;
        }
    }
    return result;
}

override LRESULT WM_MOUSEMOVE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_MOUSEMOVE (wParam, lParam);
    if (result is LRESULT.ZERO) return result;
    int x = OS.GET_X_LPARAM (lParam);
    int y = OS.GET_Y_LPARAM (lParam);
    for (int i = 0; i < itemCount; i++) {
        ExpandItem item = items [i];
        bool hover = item.isHover (x, y);
        if (item.hover !is hover) {
            item.hover = hover;
            item.redraw (false);
        }
    }
    return result;
}

override LRESULT WM_PAINT (WPARAM wParam, LPARAM lParam) {
    PAINTSTRUCT ps;
    GCData data = new GCData ();
    data.ps = &ps;
    data.hwnd = handle;
    GC gc = new_GC (data);
    if (gc !is null) {
        int width = ps.rcPaint.right - ps.rcPaint.left;
        int height = ps.rcPaint.bottom - ps.rcPaint.top;
        if (width !is 0 && height !is 0) {
            RECT rect;
            OS.SetRect (&rect, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right, ps.rcPaint.bottom);
            drawWidget (gc, &rect);
            if (hooks (SWT.Paint) || filters (SWT.Paint)) {
                Event event = new Event ();
                event.gc = gc;
                event.x = rect.left;
                event.y = rect.top;
                event.width = width;
                event.height = height;
                sendEvent (SWT.Paint, event);
                event.gc = null;
            }
        }
        gc.dispose ();
    }
    return LRESULT.ZERO;
}

override LRESULT WM_PRINTCLIENT (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_PRINTCLIENT (wParam, lParam);
    RECT rect;
    OS.GetClientRect (handle, &rect);
    GCData data = new GCData ();
    data.device = display;
    data.foreground = getForegroundPixel ();
    GC gc = GC.win32_new ( cast(Drawable)cast(void*)wParam, data);
    drawWidget (gc, &rect);
    gc.dispose ();
    return result;
}

override LRESULT WM_SETCURSOR (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SETCURSOR (wParam, lParam);
    if (result !is null) return result;
    int hitTest = cast(short) OS.LOWORD (lParam);
    if (hitTest is OS.HTCLIENT) {
        for (int i = 0; i < itemCount; i++) {
            ExpandItem item = items [i];
            if (item.hover) {
                auto hCursor = OS.LoadCursor (null, cast(LPCTSTR)OS.IDC_HAND);
                OS.SetCursor (hCursor);
                return LRESULT.ONE;
            }
        }
    }
    return result;
}

override LRESULT WM_SETFOCUS (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SETFOCUS (wParam, lParam);
    if (focusItem !is null) focusItem.redraw (true);
    return result;
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SIZE (wParam, lParam);
    RECT rect;
    OS.GetClientRect (handle, &rect);
    int width = Math.max (0, (rect.right - rect.left) - spacing * 2);
    for (int i = 0; i < itemCount; i++) {
        ExpandItem item = items[i];
        if (item.width !is width) item.setBounds (0, 0, width, item.height, false, true);
    }
    setScrollbar ();
    OS.InvalidateRect (handle, null, true);
    return result;
}

override LRESULT wmScroll (ScrollBar bar, bool update, HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.wmScroll (bar, true, hwnd, msg, wParam, lParam);
    SCROLLINFO info;
    info.cbSize = SCROLLINFO.sizeof;
    info.fMask = OS.SIF_POS;
    OS.GetScrollInfo (handle, OS.SB_VERT, &info);
    int updateY = yCurrentScroll - info.nPos;
    OS.ScrollWindowEx (handle, 0, updateY, null, null, null, null, OS.SW_SCROLLCHILDREN | OS.SW_INVALIDATE);
    yCurrentScroll = info.nPos;
    if (updateY !is 0) {
        for (int i = 0; i < itemCount; i++) {
            items [i].y += updateY;
        }
    }
    return result;
}
}

