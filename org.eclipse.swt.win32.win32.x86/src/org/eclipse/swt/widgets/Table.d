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
module org.eclipse.swt.widgets.Table;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.ImageList;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.swt.widgets.TableColumn;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;
import java.nonstandard.UnsafeUtf;


/**
 * Instances of this class implement a selectable user interface
 * object that displays a list of images and strings and issues
 * notification when selected.
 * <p>
 * The item children that may be added to instances of this class
 * must be of type <code>TableItem</code>.
 * </p><p>
 * Style <code>VIRTUAL</code> is used to create a <code>Table</code> whose
 * <code>TableItem</code>s are to be populated by the client on an on-demand basis
 * instead of up-front.  This can provide significant performance improvements for
 * tables that are very large or for which <code>TableItem</code> population is
 * expensive (for example, retrieving values from an external source).
 * </p><p>
 * Here is an example of using a <code>Table</code> with style <code>VIRTUAL</code>:
 * <code><pre>
 *  final Table table = new Table (parent, SWT.VIRTUAL | SWT.BORDER);
 *  table.setItemCount (1000000);
 *  table.addListener (SWT.SetData, new Listener () {
 *      public void handleEvent (Event event) {
 *          TableItem item = (TableItem) event.item;
 *          int index = table.indexOf (item);
 *          item.setText ("Item " + index);
 *          System.out.println (item.getText ());
 *      }
 *  });
 * </pre></code>
 * </p><p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not normally make sense to add <code>Control</code> children to
 * it, or set a layout on it, unless implementing something like a cell
 * editor.
 * </p><p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>SINGLE, MULTI, CHECK, FULL_SELECTION, HIDE_SELECTION, VIRTUAL, NO_SCROLL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection, DefaultSelection, SetData, MeasureItem, EraseItem, PaintItem</dd>
 * </dl>
 * </p><p>
 * Note: Only one of the styles SINGLE, and MULTI may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#table">Table, TableItem, TableColumn snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class Table : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.setBackgroundImage setBackgroundImage;
    alias Composite.setBounds setBounds;
    alias Composite.sort sort;
    alias Composite.update update;

    TableItem [] items;
    TableColumn [] columns;
    int columnCount, customCount;
    ImageList imageList, headerImageList;
    TableItem currentItem;
    TableColumn sortColumn;
    RECT* focusRect;
    HWND headerToolTipHandle;
    bool ignoreCustomDraw, ignoreDrawForeground, ignoreDrawBackground, ignoreDrawFocus, ignoreDrawSelection, ignoreDrawHot;
    bool customDraw, dragStarted, explorerTheme, firstColumnImage, fixScrollWidth, tipRequested, wasSelected, wasResized;
    bool ignoreActivate, ignoreSelect, ignoreShrink, ignoreResize, ignoreColumnMove, ignoreColumnResize, fullRowSelect;
    int itemHeight, lastIndexOf, lastWidth, sortDirection, resizeCount, selectionForeground, hotIndex;
    mixin(gshared!(`static /*final*/ WNDPROC HeaderProc;`));
    static const int INSET = 4;
    static const int GRID_WIDTH = 1;
    static const int SORT_WIDTH = 10;
    static const int HEADER_MARGIN = 12;
    static const int HEADER_EXTRA = 3;
    static const int VISTA_EXTRA = 2;
    static const int EXPLORER_EXTRA = 2;
    static const int H_SCROLL_LIMIT = 32;
    static const int V_SCROLL_LIMIT = 16;
    static const int DRAG_IMAGE_SIZE = 301;
    static const bool EXPLORER_THEME = true;
    mixin(gshared!(`private static /+const+/ WNDPROC TableProc;`));
    mixin(gshared!(`static const TCHAR[] TableClass = OS.WC_LISTVIEW;`));

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
            OS.GetClassInfo (null, TableClass.ptr, &lpWndClass);
            TableProc = lpWndClass.lpfnWndProc;
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
 * @see SWT#CHECK
 * @see SWT#FULL_SELECTION
 * @see SWT#HIDE_SELECTION
 * @see SWT#VIRTUAL
 * @see SWT#NO_SCROLL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    static_this();
    super (parent, checkStyle (style));
}

override void _addListener (int eventType, Listener listener) {
    super._addListener (eventType, listener);
    switch (eventType) {
        case SWT.MeasureItem:
        case SWT.EraseItem:
        case SWT.PaintItem:
            setCustomDraw (true);
            setBackgroundTransparent (true);
            if (OS.COMCTL32_MAJOR < 6) style |= SWT.DOUBLE_BUFFERED;
            if (OS.IsWinCE) OS.SendMessage (handle, OS.LVM_SETEXTENDEDLISTVIEWSTYLE, OS.LVS_EX_LABELTIP, 0);
            break;
        default:
    }
}

TableItem _getItem (int index) {
    if ((style & SWT.VIRTUAL) is 0) return items [index];
    if (items [index] !is null) return items [index];
    return items [index] = new TableItem (this, SWT.NONE, -1, false);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the user changes the receiver's selection, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * When <code>widgetSelected</code> is called, the item field of the event object is valid.
 * If the receiver has the <code>SWT.CHECK</code> style and the check selection changes,
 * the event object detail field contains the value <code>SWT.CHECK</code>.
 * <code>widgetDefaultSelected</code> is typically called when an item is double-clicked.
 * The item field of the event object is valid for default selection, but the detail field is not used.
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
public void addSelectionListener (SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
}

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    return callWindowProc (hwnd, msg, wParam, lParam, false);
}

.LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam, bool forceSelect) {
    if (handle is null) return 0;
    if (handle !is hwnd) {
        return OS.CallWindowProc (HeaderProc, hwnd, msg, wParam, lParam);
    }
    .LRESULT topIndex = 0;
    bool checkSelection = false, checkActivate = false, redraw = false;
    switch (msg) {
        /* Keyboard messages */
        /*
        * Feature in Windows.  Windows sends LVN_ITEMACTIVATE from WM_KEYDOWN
        * instead of WM_CHAR.  This means that application code that expects
        * to consume the key press and therefore avoid a SWT.DefaultSelection
        * event will fail.  The fix is to ignore LVN_ITEMACTIVATE when it is
        * caused by WM_KEYDOWN and send SWT.DefaultSelection from WM_CHAR.
        */
        case OS.WM_KEYDOWN:
            checkActivate = true;
            goto case OS.WM_CHAR;
        case OS.WM_CHAR:
        case OS.WM_IME_CHAR:
        case OS.WM_KEYUP:
        case OS.WM_SYSCHAR:
        case OS.WM_SYSKEYDOWN:
        case OS.WM_SYSKEYUP:
            //FALL THROUGH

        /* Scroll messages */
        case OS.WM_HSCROLL:
        case OS.WM_VSCROLL:
            //FALL THROUGH

        /* Resize messages */
        case OS.WM_WINDOWPOSCHANGED:
            redraw = findImageControl () !is null && drawCount is 0 && OS.IsWindowVisible (handle);
            if (redraw) {
                /*
                * Feature in Windows.  When LVM_SETBKCOLOR is used with CLR_NONE
                * to make the background of the table transparent, drawing becomes
                * slow.  The fix is to temporarily clear CLR_NONE when redraw is
                * turned off.
                */
                OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
                OS.SendMessage (handle, OS.LVM_SETBKCOLOR, 0, 0xFFFFFF);
            }
            goto case OS.WM_LBUTTONDBLCLK;

        /* Mouse messages */
        case OS.WM_LBUTTONDBLCLK:
        case OS.WM_LBUTTONDOWN:
        case OS.WM_LBUTTONUP:
        case OS.WM_MBUTTONDBLCLK:
        case OS.WM_MBUTTONDOWN:
        case OS.WM_MBUTTONUP:
        case OS.WM_MOUSEHOVER:
        case OS.WM_MOUSELEAVE:
        case OS.WM_MOUSEMOVE:
        case OS.WM_MOUSEWHEEL:
        case OS.WM_RBUTTONDBLCLK:
        case OS.WM_RBUTTONDOWN:
        case OS.WM_RBUTTONUP:
        case OS.WM_XBUTTONDBLCLK:
        case OS.WM_XBUTTONDOWN:
        case OS.WM_XBUTTONUP:
            checkSelection = true;
            goto case OS.WM_SETFONT;

        /* Other messages */
        case OS.WM_SETFONT:
        case OS.WM_TIMER: {
            if (findImageControl () !is null) {
                topIndex = OS.SendMessage (handle, OS.LVM_GETTOPINDEX, 0, 0);
            }
            break;
        }
        default:
            break;
    }
    bool oldSelected = wasSelected;
    if (checkSelection) wasSelected = false;
    if (checkActivate) ignoreActivate = true;

    /*
    * Bug in Windows.  For some reason, when the WS_EX_COMPOSITED
    * style is set in a parent of a table and the header is visible,
    * Windows issues an endless stream of WM_PAINT messages.  The
    * fix is to call BeginPaint() and EndPaint() outside of WM_PAINT
    * and pass the paint HDC in to the window proc.
    */
    bool fixPaint = false;
    if (msg is OS.WM_PAINT) {
        int bits0 = OS.GetWindowLong (handle, OS.GWL_STYLE);
        if ((bits0 & OS.LVS_NOCOLUMNHEADER) is 0) {
            HWND hwndParent = OS.GetParent (handle), hwndOwner = null;
            while (hwndParent !is null) {
                int bits1 = OS.GetWindowLong (hwndParent, OS.GWL_EXSTYLE);
                if ((bits1 & OS.WS_EX_COMPOSITED) !is 0) {
                    fixPaint = true;
                    break;
                }
                hwndOwner = OS.GetWindow (hwndParent, OS.GW_OWNER);
                if (hwndOwner !is null) break;
                hwndParent = OS.GetParent (hwndParent);
            }
        }
    }

    /* Remove the scroll bars that Windows keeps automatically adding */
    bool fixScroll = false;
    if ((style & SWT.H_SCROLL) is 0 || (style & SWT.V_SCROLL) is 0) {
        switch (msg) {
            case OS.WM_PAINT:
            case OS.WM_NCPAINT:
            case OS.WM_WINDOWPOSCHANGING: {
                int bits = OS.GetWindowLong (hwnd, OS.GWL_STYLE);
                if ((style & SWT.H_SCROLL) is 0 && (bits & OS.WS_HSCROLL) !is 0) {
                    fixScroll = true;
                    bits &= ~OS.WS_HSCROLL;
                }
                if ((style & SWT.V_SCROLL) is 0 && (bits & OS.WS_VSCROLL) !is 0) {
                    fixScroll = true;
                    bits &= ~OS.WS_VSCROLL;
                }
                if (fixScroll) OS.SetWindowLong (handle, OS.GWL_STYLE, bits);
                break;
            }
            default:
                break;
        }
    }
    .LRESULT code = 0;
    if (fixPaint) {
        PAINTSTRUCT ps;
        auto hDC = OS.BeginPaint (hwnd, &ps);
        code = OS.CallWindowProc (TableProc, hwnd, OS.WM_PAINT, cast(ptrdiff_t)hDC, lParam);
        OS.EndPaint (hwnd, &ps);
    } else {
        code = OS.CallWindowProc (TableProc, hwnd, msg, wParam, lParam);
    }
    if (fixScroll) {
        int flags = OS.RDW_FRAME | OS.RDW_INVALIDATE;
        OS.RedrawWindow (handle, null, null, flags);
    }

    if (checkActivate) ignoreActivate = false;
    if (checkSelection) {
        if (wasSelected || forceSelect) {
            Event event = new Event ();
            auto index = OS.SendMessage (handle, OS.LVM_GETNEXTITEM, -1, OS.LVNI_FOCUSED);
            if (index !is -1) event.item = _getItem (cast(int)/*64bit*/index);
            postEvent (SWT.Selection, event);
        }
        wasSelected = oldSelected;
    }
    switch (msg) {
        /* Keyboard messages */
        case OS.WM_KEYDOWN:
        case OS.WM_CHAR:
        case OS.WM_IME_CHAR:
        case OS.WM_KEYUP:
        case OS.WM_SYSCHAR:
        case OS.WM_SYSKEYDOWN:
        case OS.WM_SYSKEYUP:
            //FALL THROUGH

        /* Scroll messages */
        case OS.WM_HSCROLL:
        case OS.WM_VSCROLL:
            //FALL THROUGH

        /* Resize messages */
        case OS.WM_WINDOWPOSCHANGED:
            if (redraw) {
                OS.SendMessage (handle, OS.LVM_SETBKCOLOR, 0, OS.CLR_NONE);
                OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
                OS.InvalidateRect (handle, null, true);
                auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
                if (hwndHeader !is null) OS.InvalidateRect (hwndHeader, null, true);
            }
            goto case OS.WM_LBUTTONDBLCLK;

        /* Mouse messages */
        case OS.WM_LBUTTONDBLCLK:
        case OS.WM_LBUTTONDOWN:
        case OS.WM_LBUTTONUP:
        case OS.WM_MBUTTONDBLCLK:
        case OS.WM_MBUTTONDOWN:
        case OS.WM_MBUTTONUP:
        case OS.WM_MOUSEHOVER:
        case OS.WM_MOUSELEAVE:
        case OS.WM_MOUSEMOVE:
        case OS.WM_MOUSEWHEEL:
        case OS.WM_RBUTTONDBLCLK:
        case OS.WM_RBUTTONDOWN:
        case OS.WM_RBUTTONUP:
        case OS.WM_XBUTTONDBLCLK:
        case OS.WM_XBUTTONDOWN:
        case OS.WM_XBUTTONUP:
            goto case OS.WM_SETFONT;

        /* Other messages */
        case OS.WM_SETFONT:
        case OS.WM_TIMER: {
            if (findImageControl () !is null) {
                if (topIndex !is OS.SendMessage (handle, OS.LVM_GETTOPINDEX, 0, 0)) {
                    OS.InvalidateRect (handle, null, true);
                }
            }
            break;
        }
        default:
            break;
    }
    return code;
}

static int checkStyle (int style) {
    /*
    * Feature in Windows.  Even when WS_HSCROLL or
    * WS_VSCROLL is not specified, Windows creates
    * trees and tables with scroll bars.  The fix
    * is to set H_SCROLL and V_SCROLL.
    *
    * NOTE: This code appears on all platforms so that
    * applications have consistent scroll bar behavior.
    */
    if ((style & SWT.NO_SCROLL) is 0) {
        style |= SWT.H_SCROLL | SWT.V_SCROLL;
    }
    return checkBits (style, SWT.SINGLE, SWT.MULTI, 0, 0, 0, 0);
}

LRESULT CDDS_ITEMPOSTPAINT (NMLVCUSTOMDRAW* nmcd, WPARAM wParam, LPARAM lParam) {
    auto hDC = nmcd.nmcd.hdc;
    if (explorerTheme && !ignoreCustomDraw) {
        hotIndex = -1;
        if (hooks (SWT.EraseItem) && nmcd.nmcd.rc.left !is nmcd.nmcd.rc.right) {
            OS.RestoreDC (hDC, -1);
        }
    }
    /*
    * Bug in Windows.  When the table has the extended style
    * LVS_EX_FULLROWSELECT and LVM_SETBKCOLOR is used with
    * CLR_NONE to make the table transparent, Windows fills
    * a black rectangle around any column that contains an
    * image.  The fix is clear LVS_EX_FULLROWSELECT during
    * custom draw.
    *
    * NOTE: Since CDIS_FOCUS is cleared during custom draw,
    * it is necessary to draw the focus rectangle after the
    * item has been drawn.
    */
    if (!ignoreCustomDraw && !ignoreDrawFocus && nmcd.nmcd.rc.left !is nmcd.nmcd.rc.right) {
        if (OS.IsWindowVisible (handle) && OS.IsWindowEnabled (handle)) {
            if (!explorerTheme && (style & SWT.FULL_SELECTION) !is 0) {
                if (OS.SendMessage (handle, OS.LVM_GETBKCOLOR, 0, 0) is OS.CLR_NONE) {
                    auto dwExStyle = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
                    if ((dwExStyle & OS.LVS_EX_FULLROWSELECT) is 0) {
//                      if ((nmcd.uItemState & OS.CDIS_FOCUS) !is 0) {
                        if (OS.SendMessage (handle, OS.LVM_GETNEXTITEM, -1, OS.LVNI_FOCUSED) is nmcd.nmcd.dwItemSpec) {
                            if (handle is OS.GetFocus ()) {
                                auto uiState = OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
                                if ((uiState & OS.UISF_HIDEFOCUS) is 0) {
                                    RECT rect;
                                    rect.left = OS.LVIR_BOUNDS;
                                    bool oldIgnore = ignoreCustomDraw;
                                    ignoreCustomDraw = true;
                                    OS.SendMessage (handle, OS. LVM_GETITEMRECT, nmcd.nmcd.dwItemSpec, &rect);
                                    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
                                    auto index = OS.SendMessage (hwndHeader, OS.HDM_ORDERTOINDEX, 0, 0);
                                    RECT itemRect;
                                    if (index is 0) {
                                        itemRect.left = OS.LVIR_LABEL;
                                        OS.SendMessage (handle, OS. LVM_GETITEMRECT, index, &itemRect);
                                    } else {
                                        itemRect.top = cast(int)/*64bit*/index;
                                        itemRect.left = OS.LVIR_ICON;
                                        OS.SendMessage (handle, OS. LVM_GETSUBITEMRECT, nmcd.nmcd.dwItemSpec, &itemRect);
                                    }
                                    ignoreCustomDraw = oldIgnore;
                                    rect.left = itemRect.left;
                                    OS.DrawFocusRect (nmcd.nmcd.hdc, &rect);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return null;
}

LRESULT CDDS_ITEMPREPAINT (NMLVCUSTOMDRAW* nmcd, WPARAM wParam, LPARAM lParam) {
    /*
    * Bug in Windows.  When the table has the extended style
    * LVS_EX_FULLROWSELECT and LVM_SETBKCOLOR is used with
    * CLR_NONE to make the table transparent, Windows fills
    * a black rectangle around any column that contains an
    * image.  The fix is clear LVS_EX_FULLROWSELECT during
    * custom draw.
    *
    * NOTE: It is also necessary to clear CDIS_FOCUS to stop
    * the table from drawing the focus rectangle around the
    * first item instead of the full row.
    */
    if (!ignoreCustomDraw) {
        if (OS.IsWindowVisible (handle) && OS.IsWindowEnabled (handle)) {
            if (!explorerTheme && (style & SWT.FULL_SELECTION) !is 0) {
                if (OS.SendMessage (handle, OS.LVM_GETBKCOLOR, 0, 0) is OS.CLR_NONE) {
                    auto dwExStyle = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
                    if ((dwExStyle & OS.LVS_EX_FULLROWSELECT) is 0) {
                        if ((nmcd.nmcd.uItemState & OS.CDIS_FOCUS) !is 0) {
                            nmcd.nmcd.uItemState &= ~OS.CDIS_FOCUS;
                            OS.MoveMemory (lParam, nmcd, OS.NMLVCUSTOMDRAW_sizeof);
                        }
                    }
                }
            }
        }
    }
    if (explorerTheme && !ignoreCustomDraw) {
        hotIndex = (nmcd.nmcd.uItemState & OS.CDIS_HOT) !is 0 ? cast(int)/*64bit*/nmcd.nmcd.dwItemSpec : -1;
        if (hooks (SWT.EraseItem) && nmcd.nmcd.rc.left !is nmcd.nmcd.rc.right) {
            OS.SaveDC (nmcd.nmcd.hdc);
            auto hrgn = OS.CreateRectRgn (0, 0, 0, 0);
            OS.SelectClipRgn (nmcd.nmcd.hdc, hrgn);
            OS.DeleteObject (hrgn);
        }
    }
    return new LRESULT (OS.CDRF_NOTIFYSUBITEMDRAW | OS.CDRF_NOTIFYPOSTPAINT);
}

LRESULT CDDS_POSTPAINT (NMLVCUSTOMDRAW* nmcd, WPARAM wParam, LPARAM lParam) {
    if (ignoreCustomDraw) return null;
    /*
    * Bug in Windows.  When the table has the extended style
    * LVS_EX_FULLROWSELECT and LVM_SETBKCOLOR is used with
    * CLR_NONE to make the table transparent, Windows fills
    * a black rectangle around any column that contains an
    * image.  The fix is clear LVS_EX_FULLROWSELECT during
    * custom draw.
    */
    if (--customCount is 0 && OS.IsWindowVisible (handle)) {
        if (!explorerTheme && (style & SWT.FULL_SELECTION) !is 0) {
            if (OS.SendMessage (handle, OS.LVM_GETBKCOLOR, 0, 0) is OS.CLR_NONE) {
                auto dwExStyle = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
                if ((dwExStyle & OS.LVS_EX_FULLROWSELECT) is 0) {
                    int bits = OS.LVS_EX_FULLROWSELECT;
                    /*
                    * Feature in Windows.  When LVM_SETEXTENDEDLISTVIEWSTYLE is
                    * used to set or clear the extended style bits and the table
                    * has a tooltip, the tooltip is hidden.  The fix is to clear
                    * the tooltip before setting the bits and then reset it.
                    */
                    auto hwndToolTip = OS.SendMessage (handle, OS.LVM_SETTOOLTIPS, 0, 0);
                    static if (OS.IsWinCE) {
                        RECT rect;
                        bool damaged = cast(bool) OS.GetUpdateRect (handle, &rect, true);
                        OS.SendMessage (handle, OS.LVM_SETEXTENDEDLISTVIEWSTYLE, bits, bits);
                        OS.ValidateRect (handle, null);
                        if (damaged) OS.InvalidateRect (handle, &rect, true);
                    } else {
                        auto rgn = OS.CreateRectRgn (0, 0, 0, 0);
                        int result = OS.GetUpdateRgn (handle, rgn, true);
                        OS.SendMessage (handle, OS.LVM_SETEXTENDEDLISTVIEWSTYLE, bits, bits);
                        OS.ValidateRect (handle, null);
                        if (result !is OS.NULLREGION) OS.InvalidateRgn (handle, rgn, true);
                        OS.DeleteObject (rgn);
                    }
                    /*
                    * Bug in Windows.  Despite the documentation, LVM_SETTOOLTIPS
                    * uses WPARAM instead of LPARAM for the new tooltip  The fix
                    * is to put the tooltip in both parameters.
                    */
                    hwndToolTip = OS.SendMessage (handle, OS.LVM_SETTOOLTIPS, hwndToolTip, hwndToolTip);
                }
            }
        }
    }
    return null;
}

LRESULT CDDS_PREPAINT (NMLVCUSTOMDRAW* nmcd, WPARAM wParam, LPARAM lParam) {
    if (ignoreCustomDraw) {
        return new LRESULT (OS.CDRF_NOTIFYITEMDRAW | OS.CDRF_NOTIFYPOSTPAINT);
    }
    /*
    * Bug in Windows.  When the table has the extended style
    * LVS_EX_FULLROWSELECT and LVM_SETBKCOLOR is used with
    * CLR_NONE to make the table transparent, Windows fills
    * a black rectangle around any column that contains an
    * image.  The fix is clear LVS_EX_FULLROWSELECT during
    * custom draw.
    */
    if (customCount++ is 0 && OS.IsWindowVisible (handle)) {
        if (!explorerTheme && (style & SWT.FULL_SELECTION) !is 0) {
            if (OS.SendMessage (handle, OS.LVM_GETBKCOLOR, 0, 0) is OS.CLR_NONE) {
                auto dwExStyle = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
                if ((dwExStyle & OS.LVS_EX_FULLROWSELECT) !is 0) {
                    int bits = OS.LVS_EX_FULLROWSELECT;
                    /*
                    * Feature in Windows.  When LVM_SETEXTENDEDLISTVIEWSTYLE is
                    * used to set or clear the extended style bits and the table
                    * has a tooltip, the tooltip is hidden.  The fix is to clear
                    * the tooltip before setting the bits and then reset it.
                    */
                    auto hwndToolTip = OS.SendMessage (handle, OS.LVM_SETTOOLTIPS, 0, 0);
                    static if (OS.IsWinCE) {
                        RECT rect;
                        bool damaged = cast(bool) OS.GetUpdateRect (handle, &rect, true);
                        OS.SendMessage (handle, OS.LVM_SETEXTENDEDLISTVIEWSTYLE, bits, 0);
                        OS.ValidateRect (handle, null);
                        if (damaged) OS.InvalidateRect (handle, &rect, true);
                    } else {
                        auto rgn = OS.CreateRectRgn (0, 0, 0, 0);
                        int result = OS.GetUpdateRgn (handle, rgn, true);
                        OS.SendMessage (handle, OS.LVM_SETEXTENDEDLISTVIEWSTYLE, bits, 0);
                        OS.ValidateRect (handle, null);
                        if (result !is OS.NULLREGION) OS.InvalidateRgn (handle, rgn, true);
                        OS.DeleteObject (rgn);
                    }
                    /*
                    * Bug in Windows.  Despite the documentation, LVM_SETTOOLTIPS
                    * uses WPARAM instead of LPARAM for the new tooltip  The fix
                    * is to put the tooltip in both parameters.
                    */
                    hwndToolTip = OS.SendMessage (handle, OS.LVM_SETTOOLTIPS, hwndToolTip, hwndToolTip);
                }
            }
        }
    }
    if (OS.IsWindowVisible (handle)) {
        bool draw = true;
        /*
        * Feature in Windows.  On Vista using the explorer theme,
        * Windows draws a vertical line to separate columns.  When
        * there is only a single column, the line looks strange.
        * The fix is to draw the background using custom draw.
        */
        if (explorerTheme && columnCount is 0) {
            auto hDC = nmcd.nmcd.hdc;
            RECT rect;
            OS.SetRect (&rect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
            if (OS.IsWindowEnabled (handle) || findImageControl () !is null) {
                drawBackground (hDC, &rect);
            } else {
                fillBackground (hDC, OS.GetSysColor (OS.COLOR_3DFACE), &rect);
            }
            draw = false;
        }
        if (draw) {
            Control control = findBackgroundControl ();
            if (control !is null && control.backgroundImage !is null) {
                RECT rect;
                OS.SetRect (&rect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
                fillImageBackground (nmcd.nmcd.hdc, control, &rect);
            } else {
                if (OS.SendMessage (handle, OS.LVM_GETBKCOLOR, 0, 0) is OS.CLR_NONE) {
                    if (OS.IsWindowEnabled (handle)) {
                        RECT rect;
                        OS.SetRect (&rect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
                        if (control is null) control = this;
                        fillBackground (nmcd.nmcd.hdc, control.getBackgroundPixel (), &rect);
                        if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
                            if (sortColumn !is null && sortDirection !is SWT.NONE) {
                                int index = indexOf (sortColumn);
                                if (index !is -1) {
                                    parent.forceResize ();
                                    int clrSortBk = getSortColumnPixel ();
                                    RECT columnRect, headerRect;
                                    OS.GetClientRect (handle, &columnRect);
                                    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
                                    if (OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, index, &headerRect) !is 0) {
                                        OS.MapWindowPoints (hwndHeader, handle, cast(POINT*) &headerRect, 2);
                                        columnRect.left = headerRect.left;
                                        columnRect.right = headerRect.right;
                                        if (OS.IntersectRect(&columnRect, &columnRect, &rect)) {
                                            fillBackground (nmcd.nmcd.hdc, clrSortBk, &columnRect);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return new LRESULT (OS.CDRF_NOTIFYITEMDRAW | OS.CDRF_NOTIFYPOSTPAINT);
}

LRESULT CDDS_SUBITEMPOSTPAINT (NMLVCUSTOMDRAW* nmcd, WPARAM wParam, LPARAM lParam) {
    if (ignoreCustomDraw) return null;
    if (nmcd.nmcd.rc.left is nmcd.nmcd.rc.right) return new LRESULT (OS.CDRF_DODEFAULT);
    auto hDC = nmcd.nmcd.hdc;
    if (ignoreDrawForeground) OS.RestoreDC (hDC, -1);
    if (OS.IsWindowVisible (handle)) {
        /*
        * Feature in Windows.  When there is a sort column, the sort column
        * color draws on top of the background color for an item.  The fix
        * is to clear the sort column in CDDS_SUBITEMPREPAINT, and reset it
        * in CDDS_SUBITEMPOSTPAINT.
        */
        if (OS.SendMessage (handle, OS.LVM_GETBKCOLOR, 0, 0) !is OS.CLR_NONE) {
            if ((sortDirection & (SWT.UP | SWT.DOWN)) !is 0) {
                if (sortColumn !is null && !sortColumn.isDisposed ()) {
                    auto oldColumn = OS.SendMessage (handle, OS.LVM_GETSELECTEDCOLUMN, 0, 0);
                    if (oldColumn is -1) {
                        int newColumn = indexOf (sortColumn);
                        int result = 0;
                        HRGN rgn;
                        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
                            rgn = OS.CreateRectRgn (0, 0, 0, 0);
                            result = OS.GetUpdateRgn (handle, rgn, true);
                        }
                        OS.SendMessage (handle, OS.LVM_SETSELECTEDCOLUMN, newColumn, 0);
                        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
                            OS.ValidateRect (handle, null);
                            if (result !is OS.NULLREGION) OS.InvalidateRgn (handle, rgn, true);
                            OS.DeleteObject (rgn);
                        }
                    }
                }
            }
        }
        if (hooks (SWT.PaintItem)) {
            TableItem item = _getItem (cast(int)/*64bit*/nmcd.nmcd.dwItemSpec);
            sendPaintItemEvent (item, nmcd);
            //widget could be disposed at this point
        }
        if (!ignoreDrawFocus && focusRect !is null) {
            OS.SetTextColor (nmcd.nmcd.hdc, 0);
            OS.SetBkColor (nmcd.nmcd.hdc, 0xFFFFFF);
            OS.DrawFocusRect (nmcd.nmcd.hdc, focusRect);
            focusRect = null;
        }
    }
    return null;
}

LRESULT CDDS_SUBITEMPREPAINT (NMLVCUSTOMDRAW* nmcd, WPARAM wParam, LPARAM lParam) {
    auto hDC = nmcd.nmcd.hdc;
    if (explorerTheme && !ignoreCustomDraw && hooks (SWT.EraseItem) && (nmcd.nmcd.rc.left !is nmcd.nmcd.rc.right)) {
        OS.RestoreDC (hDC, -1);
    }
    /*
    * Feature in Windows.  When a new table item is inserted
    * using LVM_INSERTITEM in a table that is transparent
    * (ie. LVM_SETBKCOLOR has been called with CLR_NONE),
    * TVM_INSERTITEM calls NM_CUSTOMDRAW before the new item
    * has been added to the array.  The fix is to check for
    * null.
    */
    TableItem item = _getItem (cast(int)/*64bit*/nmcd.nmcd.dwItemSpec);
    if (item is null) return null;
    HFONT hFont = item.fontHandle (nmcd.iSubItem);
    if (hFont !is cast(HFONT)-1) OS.SelectObject (hDC, hFont);
    if (ignoreCustomDraw || (nmcd.nmcd.rc.left is nmcd.nmcd.rc.right)) {
        return new LRESULT (hFont is cast(HFONT)-1 ? OS.CDRF_DODEFAULT : OS.CDRF_NEWFONT);
    }
    int code = OS.CDRF_DODEFAULT;
    selectionForeground = -1;
    ignoreDrawForeground = ignoreDrawSelection = ignoreDrawFocus = ignoreDrawBackground = false;
    if (OS.IsWindowVisible (handle)) {
        Event measureEvent = null;
        if (hooks (SWT.MeasureItem)) {
            measureEvent = sendMeasureItemEvent (item, cast(int)/*64bit*/nmcd.nmcd.dwItemSpec, nmcd.iSubItem, nmcd.nmcd.hdc);
            if (isDisposed () || item.isDisposed ()) return null;
        }
        if (hooks (SWT.EraseItem)) {
            sendEraseItemEvent (item, nmcd, cast(int)/*64bit*/lParam, measureEvent);
            if (isDisposed () || item.isDisposed ()) return null;
            code |= OS.CDRF_NOTIFYPOSTPAINT;
        }
        if (ignoreDrawForeground || hooks (SWT.PaintItem)) code |= OS.CDRF_NOTIFYPOSTPAINT;
    }
    int clrText = item.cellForeground !is null ? item.cellForeground [nmcd.iSubItem] : -1;
    if (clrText is -1) clrText = item.foreground;
    int clrTextBk = item.cellBackground !is null ? item.cellBackground [nmcd.iSubItem] : -1;
    if (clrTextBk is -1) clrTextBk = item.background;
    if (selectionForeground !is -1) clrText = selectionForeground;
    /*
    * Bug in Windows.  When the table has the extended style
    * LVS_EX_FULLROWSELECT and LVM_SETBKCOLOR is used with
    * CLR_NONE to make the table transparent, Windows draws
    * a black rectangle around any column that contains an
    * image.  The fix is emulate LVS_EX_FULLROWSELECT by
    * drawing the selection.
    */
    if (OS.IsWindowVisible (handle) && OS.IsWindowEnabled (handle)) {
        if (!explorerTheme && !ignoreDrawSelection && (style & SWT.FULL_SELECTION) !is 0) {
            auto bits = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
            if ((bits & OS.LVS_EX_FULLROWSELECT) is 0) {
                /*
                * Bug in Windows.  For some reason, CDIS_SELECTED always set,
                * even for items that are not selected.  The fix is to get
                * the selection state from the item.
                */
                LVITEM lvItem;
                lvItem.mask = OS.LVIF_STATE;
                lvItem.stateMask = OS.LVIS_SELECTED;
                lvItem.iItem = cast(int)/*64bit*/nmcd.nmcd.dwItemSpec;
                auto result = OS.SendMessage (handle, OS.LVM_GETITEM, 0, &lvItem);
                if ((result !is 0 && (lvItem.state & OS.LVIS_SELECTED) !is 0)) {
                    int clrSelection = -1;
                    if (nmcd.iSubItem is 0) {
                        if (OS.GetFocus () is handle || display.getHighContrast ()) {
                            clrSelection = OS.GetSysColor (OS.COLOR_HIGHLIGHT);
                        } else {
                            if ((style & SWT.HIDE_SELECTION) is 0) {
                                clrSelection = OS.GetSysColor (OS.COLOR_3DFACE);
                            }
                        }
                    } else {
                        if (OS.GetFocus () is handle || display.getHighContrast ()) {
                            clrText = OS.GetSysColor (OS.COLOR_HIGHLIGHTTEXT);
                            clrTextBk = clrSelection = OS.GetSysColor (OS.COLOR_HIGHLIGHT);
                        } else {
                            if ((style & SWT.HIDE_SELECTION) is 0) {
                                clrTextBk = clrSelection = OS.GetSysColor (OS.COLOR_3DFACE);
                            }
                        }
                    }
                    if (clrSelection !is -1) {
                        RECT rect = item.getBounds (cast(int)/*64bit*/nmcd.nmcd.dwItemSpec, nmcd.iSubItem, true, nmcd.iSubItem !is 0, true, false, hDC);
                        fillBackground (hDC, clrSelection, &rect);
                    }
                }
            }
        }
    }
    if (!ignoreDrawForeground) {
        /*
        * Bug in Windows.  When the attributes are for one cell in a table,
        * Windows does not reset them for the next cell.  As a result, all
        * subsequent cells are drawn using the previous font, foreground and
        * background colors.  The fix is to set the all attributes when any
        * attribute could have changed.
        */
        bool hasAttributes = true;
        if (hFont is cast(HFONT)-1 && clrText is -1 && clrTextBk is -1) {
            if (item.cellForeground is null && item.cellBackground is null && item.cellFont is null) {
                auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
                auto count = OS.SendMessage (hwndHeader, OS.HDM_GETITEMCOUNT, 0, 0);
                if (count is 1) hasAttributes = false;
            }
        }
        if (hasAttributes) {
            if (hFont is cast(HFONT)-1) hFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
            OS.SelectObject (hDC, hFont);
            if (OS.IsWindowEnabled (handle)) {
                nmcd.clrText = clrText is -1 ? getForegroundPixel () : clrText;
                if (clrTextBk is -1) {
                    nmcd.clrTextBk = OS.CLR_NONE;
                    if (selectionForeground is -1) {
                        Control control = findBackgroundControl ();
                        if (control is null) control = this;
                        if (control.backgroundImage is null) {
                            if (OS.SendMessage (handle, OS.LVM_GETBKCOLOR, 0, 0) !is OS.CLR_NONE) {
                                nmcd.clrTextBk = control.getBackgroundPixel ();
                            }
                        }
                    }
                } else {
                    nmcd.clrTextBk = selectionForeground !is -1 ? OS.CLR_NONE : clrTextBk;
                }
                OS.MoveMemory (lParam, nmcd, OS.NMLVCUSTOMDRAW_sizeof);
            }
            code |= OS.CDRF_NEWFONT;
        }
    }
    if (OS.IsWindowEnabled (handle)) {
        /*
        * Feature in Windows.  When there is a sort column, the sort column
        * color draws on top of the background color for an item.  The fix
        * is to clear the sort column in CDDS_SUBITEMPREPAINT, and reset it
        * in CDDS_SUBITEMPOSTPAINT.
        */
        if (clrTextBk !is -1) {
            auto oldColumn = OS.SendMessage (handle, OS.LVM_GETSELECTEDCOLUMN, 0, 0);
            if (oldColumn !is -1 && oldColumn is nmcd.iSubItem) {
                int result = 0;
                HRGN rgn;
                if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
                    rgn = OS.CreateRectRgn (0, 0, 0, 0);
                    result = OS.GetUpdateRgn (handle, rgn, true);
                }
                OS.SendMessage (handle, OS.LVM_SETSELECTEDCOLUMN, -1, 0);
                if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
                    OS.ValidateRect (handle, null);
                    if (result !is OS.NULLREGION) OS.InvalidateRgn (handle, rgn, true);
                    OS.DeleteObject (rgn);
                }
                code |= OS.CDRF_NOTIFYPOSTPAINT;
            }
        }
    } else {
        /*
        * Feature in Windows.  When the table is disabled, it draws
        * with a gray background but does not gray the text.  The fix
        * is to explicitly gray the text.
        */
        nmcd.clrText = OS.GetSysColor (OS.COLOR_GRAYTEXT);
        if (findImageControl () !is null) {
            nmcd.clrTextBk = OS.CLR_NONE;
        } else {
            nmcd.clrTextBk = OS.GetSysColor (OS.COLOR_3DFACE);
        }
        nmcd.nmcd.uItemState &= ~OS.CDIS_SELECTED;
        OS.MoveMemory (lParam, nmcd, OS.NMLVCUSTOMDRAW_sizeof);
        code |= OS.CDRF_NEWFONT;
    }
    return new LRESULT (code);
}

override void checkBuffered () {
    super.checkBuffered ();
    if (OS.COMCTL32_MAJOR >= 6) style |= SWT.DOUBLE_BUFFERED;
    if ((style & SWT.VIRTUAL) !is 0) style |= SWT.DOUBLE_BUFFERED;
}

bool checkData (TableItem item, bool redraw) {
    if ((style & SWT.VIRTUAL) is 0) return true;
    return checkData (item, indexOf (item), redraw);
}

bool checkData (TableItem item, int index, bool redraw) {
    if ((style & SWT.VIRTUAL) is 0) return true;
    if (!item.cached) {
        item.cached = true;
        Event event = new Event ();
        event.item = item;
        event.index = index;
        currentItem = item;
        sendEvent (SWT.SetData, event);
        //widget could be disposed at this point
        currentItem = null;
        if (isDisposed () || item.isDisposed ()) return false;
        if (redraw) {
            if (!setScrollWidth (item, false)) {
                item.redraw ();
            }
        }
    }
    return true;
}

override bool checkHandle (HWND hwnd) {
    if (hwnd is handle) return true;
    return hwnd is cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
}

override protected void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

/**
 * Clears the item at the given zero-relative index in the receiver.
 * The text, icon and other attributes of the item are set to the default
 * value.  If the table was created with the <code>SWT.VIRTUAL</code> style,
 * these attributes are requested again as needed.
 *
 * @param index the index of the item to clear
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SWT#VIRTUAL
 * @see SWT#SetData
 *
 * @since 3.0
 */
public void clear (int index) {
    checkWidget ();
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (!(0 <= index && index < count)) error (SWT.ERROR_INVALID_RANGE);
    TableItem item = items [index];
    if (item !is null) {
        if (item !is currentItem) item.clear ();
        /*
        * Bug in Windows.  Despite the fact that every item in the
        * table always has LPSTR_TEXTCALLBACK, Windows caches the
        * bounds for the selected items.  This means that
        * when you change the string to be something else, Windows
        * correctly asks you for the new string but when the item
        * is selected, the selection draws using the bounds of the
        * previous item.  The fix is to reset LPSTR_TEXTCALLBACK
        * even though it has not changed, causing Windows to flush
        * cached bounds.
        */
        if ((style & SWT.VIRTUAL) is 0 && item.cached) {
            LVITEM lvItem;
            lvItem.mask = OS.LVIF_TEXT | OS.LVIF_INDENT;
            lvItem.pszText = OS.LPSTR_TEXTCALLBACK;
            lvItem.iItem = index;
            OS.SendMessage (handle, OS.LVM_SETITEM, 0, &lvItem);
            item.cached = false;
        }
        if (currentItem is null && drawCount is 0 && OS.IsWindowVisible (handle)) {
            OS.SendMessage (handle, OS.LVM_REDRAWITEMS, index, index);
        }
        setScrollWidth (item, false);
    }
}

/**
 * Removes the items from the receiver which are between the given
 * zero-relative start and end indices (inclusive).  The text, icon
 * and other attributes of the items are set to their default values.
 * If the table was created with the <code>SWT.VIRTUAL</code> style,
 * these attributes are requested again as needed.
 *
 * @param start the start index of the item to clear
 * @param end the end index of the item to clear
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if either the start or end are not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SWT#VIRTUAL
 * @see SWT#SetData
 *
 * @since 3.0
 */
public void clear (int start, int end) {
    checkWidget ();
    if (start > end) return;
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (!(0 <= start && start <= end && end < count)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    if (start is 0 && end is count - 1) {
        clearAll ();
    } else {
        LVITEM lvItem;
        bool cleared = false;
        for (int i=start; i<=end; i++) {
            TableItem item = items [i];
            if (item !is null) {
                if (item !is currentItem) {
                    cleared = true;
                    item.clear ();
                }
                /*
                * Bug in Windows.  Despite the fact that every item in the
                * table always has LPSTR_TEXTCALLBACK, Windows caches the
                * bounds for the selected items.  This means that
                * when you change the string to be something else, Windows
                * correctly asks you for the new string but when the item
                * is selected, the selection draws using the bounds of the
                * previous item.  The fix is to reset LPSTR_TEXTCALLBACK
                * even though it has not changed, causing Windows to flush
                * cached bounds.
                */
                if ((style & SWT.VIRTUAL) is 0 && item.cached) {
                    //if (lvItem is null) {
                        //lvItem = new LVITEM ();
                        lvItem.mask = OS.LVIF_TEXT | OS.LVIF_INDENT;
                        lvItem.pszText = OS.LPSTR_TEXTCALLBACK;
                    //}
                    lvItem.iItem = i;
                    OS.SendMessage (handle, OS.LVM_SETITEM, 0, &lvItem);
                    item.cached = false;
                }
            }
        }
        if (cleared) {
            if (currentItem is null && drawCount is 0 && OS.IsWindowVisible (handle)) {
                OS.SendMessage (handle, OS.LVM_REDRAWITEMS, start, end);
            }
            TableItem item = start is end ? items [start] : null;
            setScrollWidth (item, false);
        }
    }
}

/**
 * Clears the items at the given zero-relative indices in the receiver.
 * The text, icon and other attributes of the items are set to their default
 * values.  If the table was created with the <code>SWT.VIRTUAL</code> style,
 * these attributes are requested again as needed.
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
 *
 * @see SWT#VIRTUAL
 * @see SWT#SetData
 *
 * @since 3.0
 */
public void clear (int [] indices) {
    checkWidget ();
    // SWT extension: allow null array
    //if (indices is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (indices.length is 0) return;
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    for (int i=0; i<indices.length; i++) {
        if (!(0 <= indices [i] && indices [i] < count)) {
            error (SWT.ERROR_INVALID_RANGE);
        }
    }
    LVITEM lvItem;
    bool cleared = false;
    for (int i=0; i<indices.length; i++) {
        int index = indices [i];
        TableItem item = items [index];
        if (item !is null) {
            if (item !is currentItem) {
                cleared = true;
                item.clear ();
            }
            /*
            * Bug in Windows.  Despite the fact that every item in the
            * table always has LPSTR_TEXTCALLBACK, Windows caches the
            * bounds for the selected items.  This means that
            * when you change the string to be something else, Windows
            * correctly asks you for the new string but when the item
            * is selected, the selection draws using the bounds of the
            * previous item.  The fix is to reset LPSTR_TEXTCALLBACK
            * even though it has not changed, causing Windows to flush
            * cached bounds.
            */
            if ((style & SWT.VIRTUAL) is 0 && item.cached) {
                //if (lvItem is null) {
                    //lvItem = new LVITEM ();
                    lvItem.mask = OS.LVIF_TEXT | OS.LVIF_INDENT;
                    lvItem.pszText = OS.LPSTR_TEXTCALLBACK;
                //}
                lvItem.iItem = i;
                OS.SendMessage (handle, OS.LVM_SETITEM, 0, &lvItem);
                item.cached = false;
            }
            if (currentItem is null && drawCount is 0 && OS.IsWindowVisible (handle)) {
                OS.SendMessage (handle, OS.LVM_REDRAWITEMS, index, index);
            }
        }
    }
    if (cleared) setScrollWidth (null, false);
}

/**
 * Clears all the items in the receiver. The text, icon and other
 * attributes of the items are set to their default values. If the
 * table was created with the <code>SWT.VIRTUAL</code> style, these
 * attributes are requested again as needed.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SWT#VIRTUAL
 * @see SWT#SetData
 *
 * @since 3.0
 */
public void clearAll () {
    checkWidget ();
    LVITEM lvItem;
    bool cleared = false;
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    for (int i=0; i<count; i++) {
        TableItem item = items [i];
        if (item !is null) {
            if (item !is currentItem) {
                cleared = true;
                item.clear ();
            }
            /*
            * Bug in Windows.  Despite the fact that every item in the
            * table always has LPSTR_TEXTCALLBACK, Windows caches the
            * bounds for the selected items.  This means that
            * when you change the string to be something else, Windows
            * correctly asks you for the new string but when the item
            * is selected, the selection draws using the bounds of the
            * previous item.  The fix is to reset LPSTR_TEXTCALLBACK
            * even though it has not changed, causing Windows to flush
            * cached bounds.
            */
            if ((style & SWT.VIRTUAL) is 0 && item.cached) {
                //if (lvItem is null) {
                    //lvItem = new LVITEM ();
                    lvItem.mask = OS.LVIF_TEXT | OS.LVIF_INDENT;
                    lvItem.pszText = OS.LPSTR_TEXTCALLBACK;
                //}
                lvItem.iItem = i;
                OS.SendMessage (handle, OS.LVM_SETITEM, 0, &lvItem);
                item.cached = false;
            }
        }
    }
    if (cleared) {
        if (currentItem is null && drawCount is 0 && OS.IsWindowVisible (handle)) {
            OS.SendMessage (handle, OS.LVM_REDRAWITEMS, 0, count - 1);
        }
        setScrollWidth (null, false);
    }
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    if (fixScrollWidth) setScrollWidth (null, true);
    //This code is intentionally commented
//  if (itemHeight is -1 && hooks (SWT.MeasureItem)) {
//      int i = 0;
//      TableItem item = items [i];
//      if (item !is null) {
//          int hDC = OS.GetDC (handle);
//          auto oldFont = 0, newFont = OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
//          if (newFont !is 0) oldFont = OS.SelectObject (hDC, newFont);
//          int index = 0, count = Math.max (1, columnCount);
//          while (index < count) {
//              int hFont = item.cellFont !is null ? item.cellFont [index] : -1;
//              if (hFont is -1) hFont = item.font;
//              if (hFont !is -1) hFont = OS.SelectObject (hDC, hFont);
//              sendMeasureItemEvent (item, i, index, hDC);
//              if (hFont !is -1) hFont = OS.SelectObject (hDC, hFont);
//              if (isDisposed () || item.isDisposed ()) break;
//              index++;
//          }
//          if (newFont !is 0) OS.SelectObject (hDC, oldFont);
//          OS.ReleaseDC (handle, hDC);
//      }
//  }
    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    RECT rect;
    OS.GetWindowRect (hwndHeader, &rect);
    int height = rect.bottom - rect.top;
    int bits = 0;
    if (wHint !is SWT.DEFAULT) {
        bits |= wHint & 0xFFFF;
    } else {
        int width = 0;
        auto count = OS.SendMessage (hwndHeader, OS.HDM_GETITEMCOUNT, 0, 0);
        for (int i=0; i<count; i++) {
            width += OS.SendMessage (handle, OS.LVM_GETCOLUMNWIDTH, i, 0);
        }
        bits |= width & 0xFFFF;
    }
    auto result = OS.SendMessage (handle, OS.LVM_APPROXIMATEVIEWRECT, -1, OS.MAKELPARAM (bits, 0xFFFF));
    int width = OS.LOWORD (result);
    auto empty = OS.SendMessage (handle, OS.LVM_APPROXIMATEVIEWRECT, 0, 0);
    auto oneItem = OS.SendMessage (handle, OS.LVM_APPROXIMATEVIEWRECT, 1, 0);
    int itemHeight = OS.HIWORD (oneItem) - OS.HIWORD (empty);
    height += OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0) * itemHeight;
    if (width is 0) width = DEFAULT_WIDTH;
    if (height is 0) height = DEFAULT_HEIGHT;
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    int border = getBorderWidth ();
    width += border * 2;  height += border * 2;
    if ((style & SWT.V_SCROLL) !is 0) {
        width += OS.GetSystemMetrics (OS.SM_CXVSCROLL);
    }
    if ((style & SWT.H_SCROLL) !is 0) {
        height += OS.GetSystemMetrics (OS.SM_CYHSCROLL);
    }
    return new Point (width, height);
}

override void createHandle () {
    super.createHandle ();
    state &= ~(CANVAS | THEME_BACKGROUND);

    /* Use the Explorer theme */
    if (EXPLORER_THEME) {
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0) && OS.IsAppThemed ()) {
            explorerTheme = true;
            OS.SetWindowTheme (handle, Display.EXPLORER.ptr, null);
        }
    }

    /* Get the header window proc */
    if (HeaderProc is null) {
        auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
        HeaderProc = cast(WNDPROC) OS.GetWindowLongPtr (hwndHeader, OS.GWLP_WNDPROC);
    }

    /*
    * Feature in Windows.  In version 5.8 of COMCTL32.DLL,
    * if the font is changed for an item, the bounds for the
    * item are not updated, causing the text to be clipped.
    * The fix is to detect the version of COMCTL32.DLL, and
    * if it is one of the versions with the problem, then
    * use version 5.00 of the control (a version that does
    * not have the problem).  This is the recommended work
    * around from the MSDN.
    */
    static if (!OS.IsWinCE) {
        if (OS.COMCTL32_MAJOR < 6) {
            OS.SendMessage (handle, OS.CCM_SETVERSION, 5, 0);
        }
    }

    /*
    * This code is intentionally commented.  According to
    * the documentation, setting the default item size is
    * supposed to improve performance.  By experimentation,
    * this does not seem to have much of an effect.
    */
//  OS.SendMessage (handle, OS.LVM_SETITEMCOUNT, 1024 * 2, 0);

    /* Set the checkbox image list */
    if ((style & SWT.CHECK) !is 0) {
        auto empty = OS.SendMessage (handle, OS.LVM_APPROXIMATEVIEWRECT, 0, 0);
        auto oneItem = OS.SendMessage (handle, OS.LVM_APPROXIMATEVIEWRECT, 1, 0);
        int width = OS.HIWORD (oneItem) - OS.HIWORD (empty), height = width;
        setCheckboxImageList (width, height, false);
        OS.SendMessage (handle, OS. LVM_SETCALLBACKMASK, OS.LVIS_STATEIMAGEMASK, 0);
    }

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

    /*
    * Bug in Windows.  When the first column is inserted
    * without setting the header text, Windows will never
    * allow the header text for the first column to be set.
    * The fix is to set the text to an empty string when
    * the column is inserted.
    */
    LVCOLUMN lvColumn;
    lvColumn.mask = OS.LVCF_TEXT | OS.LVCF_WIDTH;
    auto hHeap = OS.GetProcessHeap ();
    auto pszText = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, TCHAR.sizeof);
    lvColumn.pszText = pszText;
    OS.SendMessage (handle, OS.LVM_INSERTCOLUMN, 0, &lvColumn);
    OS.HeapFree (hHeap, 0, pszText);

    /* Set the extended style bits */
    int bits1 = OS.LVS_EX_LABELTIP;
    if ((style & SWT.FULL_SELECTION) !is 0) bits1 |= OS.LVS_EX_FULLROWSELECT;
    if (OS.COMCTL32_MAJOR >= 6) bits1 |= OS.LVS_EX_DOUBLEBUFFER;
    OS.SendMessage (handle, OS.LVM_SETEXTENDEDLISTVIEWSTYLE, bits1, bits1);

    /*
    * Feature in Windows.  Windows does not explicitly set the orientation of
    * the header.  Instead, the orientation is inherited when WS_EX_LAYOUTRTL
    * is specified for the table.  This means that when both WS_EX_LAYOUTRTL
    * and WS_EX_NOINHERITLAYOUT are specified for the table, the header will
    * not be oriented correctly.  The fix is to explicitly set the orientation
    * for the header.
    *
    * NOTE: WS_EX_LAYOUTRTL is not supported on Windows NT.
    */
    if (OS.WIN32_VERSION >= OS.VERSION (4, 10)) {
        if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
            auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
            int bits2 = OS.GetWindowLong (hwndHeader, OS.GWL_EXSTYLE);
            OS.SetWindowLong (hwndHeader, OS.GWL_EXSTYLE, bits2 | OS.WS_EX_LAYOUTRTL);
            auto hwndTooltop = cast(HWND)OS.SendMessage (handle, OS.LVM_GETTOOLTIPS, 0, 0);
            int bits3 = OS.GetWindowLong (hwndTooltop, OS.GWL_EXSTYLE);
            OS.SetWindowLong (hwndTooltop, OS.GWL_EXSTYLE, bits3 | OS.WS_EX_LAYOUTRTL);
        }
    }
}

void createHeaderToolTips () {
    static if (OS.IsWinCE) return;
    if (headerToolTipHandle !is null) return;
    int bits = 0;
    if (OS.WIN32_VERSION >= OS.VERSION (4, 10)) {
        if ((style & SWT.RIGHT_TO_LEFT) !is 0) bits |= OS.WS_EX_LAYOUTRTL;
    }
    headerToolTipHandle = OS.CreateWindowEx (
        bits,
        OS.TOOLTIPS_CLASS.dup.ptr,
        null,
        OS.TTS_NOPREFIX,
        OS.CW_USEDEFAULT, 0, OS.CW_USEDEFAULT, 0,
        handle,
        null,
        OS.GetModuleHandle (null),
        null);
    if (headerToolTipHandle is null) error (SWT.ERROR_NO_HANDLES);
    /*
    * Feature in Windows.  Despite the fact that the
    * tool tip text contains \r\n, the tooltip will
    * not honour the new line unless TTM_SETMAXTIPWIDTH
    * is set.  The fix is to set TTM_SETMAXTIPWIDTH to
    * a large value.
    */
    OS.SendMessage (headerToolTipHandle, OS.TTM_SETMAXTIPWIDTH, 0, 0x7FFF);
}

void createItem (TableColumn column, int index) {
    if (!(0 <= index && index <= columnCount)) error (SWT.ERROR_INVALID_RANGE);
    auto oldColumn = OS.SendMessage (handle, OS.LVM_GETSELECTEDCOLUMN, 0, 0);
    if (oldColumn >= index) {
        OS.SendMessage (handle, OS.LVM_SETSELECTEDCOLUMN, oldColumn + 1, 0);
    }
    if (columnCount is columns.length) {
        TableColumn [] newColumns = new TableColumn [columns.length + 4];
        System.arraycopy (columns, 0, newColumns, 0, columns.length);
        columns = newColumns;
    }
    auto itemCount = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    for (int i=0; i<itemCount; i++) {
        TableItem item = items [i];
        if (item !is null) {
            String [] strings = item.strings;
            if (strings !is null) {
                String [] temp = new String [columnCount + 1];
                System.arraycopy (strings, 0, temp, 0, index);
                System.arraycopy (strings, index, temp, index + 1, columnCount -  index);
                item.strings = temp;
            }
            Image [] images = item.images;
            if (images !is null) {
                Image [] temp = new Image [columnCount + 1];
                System.arraycopy (images, 0, temp, 0, index);
                System.arraycopy (images, index, temp, index + 1, columnCount - index);
                item.images = temp;
            }
            if (index is 0) {
                if (columnCount !is 0) {
                    if (strings is null) {
                        item.strings = new String [columnCount + 1];
                        item.strings [1] = item.text;
                    }
                    item.text = ""; //$NON-NLS-1$
                    if (images is null) {
                        item.images = new Image [columnCount + 1];
                        item.images [1] = item.image;
                    }
                    item.image = null;
                }
            }
            if (item.cellBackground !is null) {
                int [] cellBackground = item.cellBackground;
                int [] temp = new int [columnCount + 1];
                System.arraycopy (cellBackground, 0, temp, 0, index);
                System.arraycopy (cellBackground, index, temp, index + 1, columnCount - index);
                temp [index] = -1;
                item.cellBackground = temp;
            }
            if (item.cellForeground !is null) {
                int [] cellForeground = item.cellForeground;
                int [] temp = new int [columnCount + 1];
                System.arraycopy (cellForeground, 0, temp, 0, index);
                System.arraycopy (cellForeground, index, temp, index + 1, columnCount - index);
                temp [index] = -1;
                item.cellForeground = temp;
            }
            if (item.cellFont !is null) {
                Font [] cellFont = item.cellFont;
                Font [] temp = new Font [columnCount + 1];
                System.arraycopy (cellFont, 0, temp, 0, index);
                System.arraycopy (cellFont, index, temp, index + 1, columnCount - index);
                item.cellFont = temp;
            }
        }
    }
    /*
    * Insert the column into the columns array before inserting
    * it into the widget so that the column will be present when
    * any callbacks are issued as a result of LVM_INSERTCOLUMN
    * or LVM_SETCOLUMN.
    */
    System.arraycopy (columns, index, columns, index + 1, columnCount++ - index);
    columns [index] = column;

    /*
    * Ensure that resize listeners for the table and for columns
    * within the table are not called.  This can happen when the
    * first column is inserted into a table or when a new column
    * is inserted in the first position.
    */
    ignoreColumnResize = true;
    if (index is 0) {
        if (columnCount > 1) {
            LVCOLUMN lvColumn;
            lvColumn.mask = OS.LVCF_WIDTH;
            OS.SendMessage (handle, OS.LVM_INSERTCOLUMN, 1, &lvColumn);
            OS.SendMessage (handle, OS.LVM_GETCOLUMN, 1, &lvColumn);
            int width = lvColumn.cx;
            int cchTextMax = 1024;
            auto hHeap = OS.GetProcessHeap ();
            auto byteCount = cchTextMax * TCHAR.sizeof;
            auto pszText = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
            lvColumn.mask = OS.LVCF_TEXT | OS.LVCF_IMAGE | OS.LVCF_WIDTH | OS.LVCF_FMT;
            lvColumn.pszText = pszText;
            lvColumn.cchTextMax = cchTextMax;
            OS.SendMessage (handle, OS.LVM_GETCOLUMN, 0, &lvColumn);
            OS.SendMessage (handle, OS.LVM_SETCOLUMN, 1, &lvColumn);
            lvColumn.fmt = OS.LVCFMT_IMAGE;
            lvColumn.cx = width;
            lvColumn.iImage = OS.I_IMAGENONE;
            lvColumn.pszText = null, lvColumn.cchTextMax = 0;
            OS.SendMessage (handle, OS.LVM_SETCOLUMN, 0, &lvColumn);
            lvColumn.mask = OS.LVCF_FMT;
            lvColumn.fmt = OS.LVCFMT_LEFT;
            OS.SendMessage (handle, OS.LVM_SETCOLUMN, 0, &lvColumn);
            if (pszText !is null) OS.HeapFree (hHeap, 0, pszText);
        } else {
            OS.SendMessage (handle, OS.LVM_SETCOLUMNWIDTH, 0, 0);
        }
        /*
        * Bug in Windows.  Despite the fact that every item in the
        * table always has LPSTR_TEXTCALLBACK, Windows caches the
        * bounds for the selected items.  This means that
        * when you change the string to be something else, Windows
        * correctly asks you for the new string but when the item
        * is selected, the selection draws using the bounds of the
        * previous item.  The fix is to reset LPSTR_TEXTCALLBACK
        * even though it has not changed, causing Windows to flush
        * cached bounds.
        */
        if ((style & SWT.VIRTUAL) is 0) {
            LVITEM lvItem;
            lvItem.mask = OS.LVIF_TEXT | OS.LVIF_IMAGE;
            lvItem.pszText = OS.LPSTR_TEXTCALLBACK;
            lvItem.iImage = OS.I_IMAGECALLBACK;
            for (int i=0; i<itemCount; i++) {
                lvItem.iItem = i;
                OS.SendMessage (handle, OS.LVM_SETITEM, 0, &lvItem);
            }
        }
    } else {
        int fmt = OS.LVCFMT_LEFT;
        if ((column.style & SWT.CENTER) is SWT.CENTER) fmt = OS.LVCFMT_CENTER;
        if ((column.style & SWT.RIGHT) is SWT.RIGHT) fmt = OS.LVCFMT_RIGHT;
        LVCOLUMN lvColumn;
        lvColumn.mask = OS.LVCF_WIDTH | OS.LVCF_FMT;
        lvColumn.fmt = fmt;
        OS.SendMessage (handle, OS.LVM_INSERTCOLUMN, index, &lvColumn);
    }
    ignoreColumnResize = false;

    /* Add the tool tip item for the header */
    if (headerToolTipHandle !is null) {
        RECT rect;
        auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
        if (OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, index, &rect) !is 0) {
            TOOLINFO lpti;
            lpti.cbSize = OS.TOOLINFO_sizeof;
            lpti.uFlags = OS.TTF_SUBCLASS;
            lpti.hwnd = hwndHeader;
            lpti.uId = column.id = display.nextToolTipId++;
            lpti.rect.left = rect.left;
            lpti.rect.top = rect.top;
            lpti.rect.right = rect.right;
            lpti.rect.bottom = rect.bottom;
            lpti.lpszText = OS.LPSTR_TEXTCALLBACK;
            OS.SendMessage (headerToolTipHandle, OS.TTM_ADDTOOL, 0, &lpti);
        }
    }
}

void createItem (TableItem item, int index) {
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (!(0 <= index && index <= count)) error (SWT.ERROR_INVALID_RANGE);
    if (count is items.length) {
        /*
        * Grow the array faster when redraw is off or the
        * table is not visible.  When the table is painted,
        * the items array is resized to be smaller to reduce
        * memory usage.
        */
        bool small = drawCount is 0 && OS.IsWindowVisible (handle);
        int length = small ? cast(int)/*64bit*/items.length + 4 : Math.max (4, cast(int)/*64bit*/items.length * 3 / 2);
        TableItem [] newItems = new TableItem [length];
        System.arraycopy (items, 0, newItems, 0, items.length);
        items = newItems;
    }
    LVITEM lvItem;
    lvItem.mask = OS.LVIF_TEXT | OS.LVIF_IMAGE;
    lvItem.iItem = index;
    lvItem.pszText = OS.LPSTR_TEXTCALLBACK;
    /*
    * Bug in Windows.  Despite the fact that the image list
    * index has never been set for the item, Windows always
    * assumes that the image index for the item is valid.
    * When an item is inserted, the image index is zero.
    * Therefore, when the first image is inserted and is
    * assigned image index zero, every item draws with this
    * image.  The fix is to set the image index when the
    * the item is created.
    */
    lvItem.iImage = OS.I_IMAGECALLBACK;

    /* Insert the item */
    setDeferResize (true);
    ignoreSelect = ignoreShrink = true;
    auto result = OS.SendMessage (handle, OS.LVM_INSERTITEM, 0, &lvItem);
    ignoreSelect = ignoreShrink = false;
    if (result is -1) error (SWT.ERROR_ITEM_NOT_ADDED);
    System.arraycopy (items, index, items, index + 1, count - index);
    items [index] = item;
    setDeferResize (false);

    /* Resize to show the first item */
    if (count is 0) setScrollWidth (item, false);
}

override void createWidget () {
    super.createWidget ();
    itemHeight = hotIndex = -1;
    items = new TableItem [4];
    columns = new TableColumn [4];
}

override int defaultBackground () {
    return OS.GetSysColor (OS.COLOR_WINDOW);
}

override void deregister () {
    super.deregister ();
    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    if (hwndHeader !is null) display.removeControl (hwndHeader);
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
    LVITEM lvItem;
    lvItem.stateMask = OS.LVIS_SELECTED;
    for (int i=0; i<indices.length; i++) {
        /*
        * An index of -1 will apply the change to all
        * items.  Ensure that indices are greater than -1.
        */
        if (indices [i] >= 0) {
            ignoreSelect = true;
            OS.SendMessage (handle, OS.LVM_SETITEMSTATE, indices [i], &lvItem);
            ignoreSelect = false;
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
    /*
    * An index of -1 will apply the change to all
    * items.  Ensure that index is greater than -1.
    */
    if (index < 0) return;
    LVITEM lvItem;
    lvItem.stateMask = OS.LVIS_SELECTED;
    ignoreSelect = true;
    OS.SendMessage (handle, OS.LVM_SETITEMSTATE, index, &lvItem);
    ignoreSelect = false;
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
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (start is 0 && end is count - 1) {
        deselectAll ();
    } else {
        LVITEM lvItem;
        lvItem.stateMask = OS.LVIS_SELECTED;
        /*
        * An index of -1 will apply the change to all
        * items.  Ensure that indices are greater than -1.
        */
        start = Math.max (0, start);
        for (int i=start; i<=end; i++) {
            ignoreSelect = true;
            OS.SendMessage (handle, OS.LVM_SETITEMSTATE, i, &lvItem);
            ignoreSelect = false;
        }
    }
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
    LVITEM lvItem;
    lvItem.mask = OS.LVIF_STATE;
    lvItem.stateMask = OS.LVIS_SELECTED;
    ignoreSelect = true;
    OS.SendMessage (handle, OS.LVM_SETITEMSTATE, -1, &lvItem);
    ignoreSelect = false;
}

void destroyItem (TableColumn column) {
    int index = 0;
    while (index < columnCount) {
        if (columns [index] is column) break;
        index++;
    }
    auto oldColumn = OS.SendMessage (handle, OS.LVM_GETSELECTEDCOLUMN, 0, 0);
    if (oldColumn is index) {
        OS.SendMessage (handle, OS.LVM_SETSELECTEDCOLUMN, -1, 0);
    } else {
        if (oldColumn > index) {
            OS.SendMessage (handle, OS.LVM_SETSELECTEDCOLUMN, oldColumn - 1, 0);
        }
    }
    int orderIndex = 0;
    int [] oldOrder = new int [columnCount];
    OS.SendMessage (handle, OS.LVM_GETCOLUMNORDERARRAY, columnCount, oldOrder.ptr);
    while (orderIndex < columnCount) {
        if (oldOrder [orderIndex] is index) break;
        orderIndex++;
    }
    ignoreColumnResize = true;
    bool first = false;
    if (index is 0) {
        first = true;
        if (columnCount > 1) {
            index = 1;
            int cchTextMax = 1024;
            auto hHeap = OS.GetProcessHeap ();
            auto byteCount = cchTextMax * TCHAR.sizeof;
            auto pszText = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
            LVCOLUMN lvColumn;
            lvColumn.mask = OS.LVCF_TEXT | OS.LVCF_IMAGE | OS.LVCF_WIDTH | OS.LVCF_FMT;
            lvColumn.pszText = pszText;
            lvColumn.cchTextMax = cchTextMax;
            OS.SendMessage (handle, OS.LVM_GETCOLUMN, 1, &lvColumn);
            lvColumn.fmt &= ~(OS.LVCFMT_CENTER | OS.LVCFMT_RIGHT);
            lvColumn.fmt |= OS.LVCFMT_LEFT;
            OS.SendMessage (handle, OS.LVM_SETCOLUMN, 0, &lvColumn);
            if (pszText !is null) OS.HeapFree (hHeap, 0, pszText);
        } else {
            auto hHeap = OS.GetProcessHeap ();
            auto pszText = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, TCHAR.sizeof);
            LVCOLUMN lvColumn;
            lvColumn.mask = OS.LVCF_TEXT | OS.LVCF_IMAGE | OS.LVCF_WIDTH | OS.LVCF_FMT;
            lvColumn.pszText = pszText;
            lvColumn.iImage = OS.I_IMAGENONE;
            lvColumn.fmt = OS.LVCFMT_LEFT;
            OS.SendMessage (handle, OS.LVM_SETCOLUMN, 0, &lvColumn);
            if (pszText !is null) OS.HeapFree (hHeap, 0, pszText);
            if (OS.COMCTL32_MAJOR >= 6) {
                HDITEM hdItem;
                hdItem.mask = OS.HDI_FORMAT;
                hdItem.fmt = OS.HDF_LEFT;
                auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
                OS.SendMessage (hwndHeader, OS.HDM_SETITEM, index, &hdItem);
            }
        }
        /*
        * Bug in Windows.  Despite the fact that every item in the
        * table always has LPSTR_TEXTCALLBACK, Windows caches the
        * bounds for the selected items.  This means that
        * when you change the string to be something else, Windows
        * correctly asks you for the new string but when the item
        * is selected, the selection draws using the bounds of the
        * previous item.  The fix is to reset LPSTR_TEXTCALLBACK
        * even though it has not changed, causing Windows to flush
        * cached bounds.
        */
        if ((style & SWT.VIRTUAL) is 0) {
            LVITEM lvItem;
            lvItem.mask = OS.LVIF_TEXT | OS.LVIF_IMAGE;
            lvItem.pszText = OS.LPSTR_TEXTCALLBACK;
            lvItem.iImage = OS.I_IMAGECALLBACK;
            auto itemCount = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
            for (int i=0; i<itemCount; i++) {
                lvItem.iItem = i;
                OS.SendMessage (handle, OS.LVM_SETITEM, 0, &lvItem);
            }
        }
    }
    if (columnCount > 1) {
        if (OS.SendMessage (handle, OS.LVM_DELETECOLUMN, index, 0) is 0) {
            error (SWT.ERROR_ITEM_NOT_REMOVED);
        }
    }
    if (first) index = 0;
    System.arraycopy (columns, index + 1, columns, index, --columnCount - index);
    columns [columnCount] = null;
    auto itemCount = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    for (int i=0; i<itemCount; i++) {
        TableItem item = items [i];
        if (item !is null) {
            if (columnCount is 0) {
                item.strings = null;
                item.images = null;
                item.cellBackground = null;
                item.cellForeground = null;
                item.cellFont = null;
            } else {
                if (item.strings !is null) {
                    String [] strings = item.strings;
                    if (index is 0) {
                        item.text = strings [1] !is null ? strings [1] : ""; //$NON-NLS-1$
                    }
                    String [] temp = new String [columnCount];
                    System.arraycopy (strings, 0, temp, 0, index);
                    System.arraycopy (strings, index + 1, temp, index, columnCount - index);
                    item.strings = temp;
                } else {
                    if (index is 0) item.text = ""; //$NON-NLS-1$
                }
                if (item.images !is null) {
                    Image [] images = item.images;
                    if (index is 0) item.image = images [1];
                    Image [] temp = new Image [columnCount];
                    System.arraycopy (images, 0, temp, 0, index);
                    System.arraycopy (images, index + 1, temp, index, columnCount - index);
                    item.images = temp;
                } else {
                    if (index is 0) item.image = null;
                }
                if (item.cellBackground !is null) {
                    int [] cellBackground = item.cellBackground;
                    int [] temp = new int [columnCount];
                    System.arraycopy (cellBackground, 0, temp, 0, index);
                    System.arraycopy (cellBackground, index + 1, temp, index, columnCount - index);
                    item.cellBackground = temp;
                }
                if (item.cellForeground !is null) {
                    int [] cellForeground = item.cellForeground;
                    int [] temp = new int [columnCount];
                    System.arraycopy (cellForeground, 0, temp, 0, index);
                    System.arraycopy (cellForeground, index + 1, temp, index, columnCount - index);
                    item.cellForeground = temp;
                }
                if (item.cellFont !is null) {
                    Font [] cellFont = item.cellFont;
                    Font [] temp = new Font [columnCount];
                    System.arraycopy (cellFont, 0, temp, 0, index);
                    System.arraycopy (cellFont, index + 1, temp, index, columnCount - index);
                    item.cellFont = temp;
                }
            }
        }
    }
    if (columnCount is 0) setScrollWidth (null, true);
    updateMoveable ();
    ignoreColumnResize = false;
    if (columnCount !is 0) {
        /*
        * Bug in Windows.  When LVM_DELETECOLUMN is used to delete a
        * column zero when that column is both the first column in the
        * table and the first column in the column order array, Windows
        * incorrectly computes the new column order.  For example, both
        * the orders {0, 3, 1, 2} and {0, 3, 2, 1} give a new column
        * order of {0, 2, 1}, while {0, 2, 1, 3} gives {0, 1, 2, 3}.
        * The fix is to compute the new order and compare it with the
        * order that Windows is using.  If the two differ, the new order
        * is used.
        */
        int count = 0;
        int oldIndex = oldOrder [orderIndex];
        int [] newOrder = new int [columnCount];
        for (int i=0; i<oldOrder.length; i++) {
            if (oldOrder [i] !is oldIndex) {
                int newIndex = oldOrder [i] <= oldIndex ? oldOrder [i] : oldOrder [i] - 1;
                newOrder [count++] = newIndex;
            }
        }
        OS.SendMessage (handle, OS.LVM_GETCOLUMNORDERARRAY, columnCount, oldOrder.ptr);
        int j = 0;
        while (j < newOrder.length) {
            if (oldOrder [j] !is newOrder [j]) break;
            j++;
        }
        if (j !is newOrder.length) {
            OS.SendMessage (handle, OS.LVM_SETCOLUMNORDERARRAY, newOrder.length, newOrder.ptr);
            /*
            * Bug in Windows.  When LVM_SETCOLUMNORDERARRAY is used to change
            * the column order, the header redraws correctly but the table does
            * not.  The fix is to force a redraw.
            */
            OS.InvalidateRect (handle, null, true);
        }
        TableColumn [] newColumns = new TableColumn [columnCount - orderIndex];
        for (int i=orderIndex; i<newOrder.length; i++) {
            newColumns [i - orderIndex] = columns [newOrder [i]];
            newColumns [i - orderIndex].updateToolTip (newOrder [i]);
        }
        for (int i=0; i<newColumns.length; i++) {
            if (!newColumns [i].isDisposed ()) {
                newColumns [i].sendEvent (SWT.Move);
            }
        }
    }

    /* Remove the tool tip item for the header */
    if (headerToolTipHandle !is null) {
        TOOLINFO lpti;
        lpti.cbSize = OS.TOOLINFO_sizeof;
        lpti.uId = column.id;
        lpti.hwnd = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
        OS.SendMessage (headerToolTipHandle, OS.TTM_DELTOOL, 0, &lpti);
    }
}

void destroyItem (TableItem item) {
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    int index = 0;
    while (index < count) {
        if (items [index] is item) break;
        index++;
    }
    if (index is count) return;
    setDeferResize (true);
    ignoreSelect = ignoreShrink = true;
    auto code = OS.SendMessage (handle, OS.LVM_DELETEITEM, index, 0);
    ignoreSelect = ignoreShrink = false;
    if (code is 0) error (SWT.ERROR_ITEM_NOT_REMOVED);
    System.arraycopy (items, index + 1, items, index, --count - index);
    items [count] = null;
    if (count is 0) setTableEmpty ();
    setDeferResize (false);
}

void fixCheckboxImageList (bool fixScroll) {
    /*
    * Bug in Windows.  When the state image list is larger than the
    * image list, Windows incorrectly positions the state images.  When
    * the table is scrolled, Windows draws garbage.  The fix is to force
    * the state image list to be the same size as the image list.
    */
    if ((style & SWT.CHECK) is 0) return;
    HANDLE hImageList = cast(HANDLE) OS.SendMessage (handle, OS.LVM_GETIMAGELIST, OS.LVSIL_SMALL, 0);
    if (hImageList is null) return;
    int cx, cy;
    OS.ImageList_GetIconSize (hImageList, &cx, &cy);
    HANDLE hStateList = cast(HANDLE) OS.SendMessage (handle, OS.LVM_GETIMAGELIST, OS.LVSIL_STATE, 0);
    if (hStateList is null) return;
    int stateCx, stateCy;
    OS.ImageList_GetIconSize (hStateList, &stateCx, &stateCy);
    if (cx is stateCx && cy is stateCy ) return;
    setCheckboxImageList (cx, cy, fixScroll);
}

void fixCheckboxImageListColor (bool fixScroll) {
    if ((style & SWT.CHECK) is 0) return;
    auto hStateList = cast(HANDLE) OS.SendMessage (handle, OS.LVM_GETIMAGELIST, OS.LVSIL_STATE, 0);
    if (hStateList is null) return;
    int cx, cy;
    OS.ImageList_GetIconSize (hStateList, &cx, &cy);
    setCheckboxImageList (cx, cy, fixScroll);
}

void fixItemHeight (bool fixScroll) {
    /*
    * Bug in Windows.  When both a header and grid lines are
    * displayed, the grid lines do not take into account the
    * height of the header and draw in the wrong place.  The
    * fix is to set the height of the table items to be the
    * height of the header so that the lines draw in the right
    * place.  The height of a table item is the maximum of the
    * height of the font or the height of image list.
    *
    * NOTE: In version 5.80 of COMCTL32.DLL, the bug is fixed.
    */
    if (itemHeight !is -1) return;
    if (OS.COMCTL32_VERSION >= OS.VERSION (5, 80)) return;
    auto bits = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
    if ((bits & OS.LVS_EX_GRIDLINES) is 0) return;
    bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    if ((bits & OS.LVS_NOCOLUMNHEADER) !is 0) return;
    /*
    * Bug in Windows.  Making any change to an item that
    * changes the item height of a table while the table
    * is scrolled can cause the lines to draw incorrectly.
    * This happens even when the lines are not currently
    * visible and are shown afterwards.  The fix is to
    * save the top index, scroll to the top of the table
    * and then restore the original top index.
    */
    int topIndex = getTopIndex ();
    if (fixScroll && topIndex !is 0) {
        setRedraw (false);
        setTopIndex (0);
    }
    auto hOldList = cast(HANDLE) OS.SendMessage (handle, OS.LVM_GETIMAGELIST, OS.LVSIL_SMALL, 0);
    if (hOldList !is null) return;
    auto hwndHeader = cast(HANDLE) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    RECT rect;
    OS.GetWindowRect (hwndHeader, &rect);
    int height = rect.bottom - rect.top - 1;
    auto hImageList = OS.ImageList_Create (1, height, 0, 0, 0);
    OS.SendMessage (handle, OS.LVM_SETIMAGELIST, OS.LVSIL_SMALL, hImageList);
    fixCheckboxImageList (false);
    OS.SendMessage (handle, OS.LVM_SETIMAGELIST, OS.LVSIL_SMALL, 0);
    if (headerImageList !is null) {
        auto hHeaderImageList = headerImageList.getHandle ();
        OS.SendMessage (hwndHeader, OS.HDM_SETIMAGELIST, 0, hHeaderImageList);
    }
    OS.ImageList_Destroy (hImageList);
    if (fixScroll && topIndex !is 0) {
        setTopIndex (topIndex);
        setRedraw (true);
    }
}

/**
 * Returns the column at the given, zero-relative index in the
 * receiver. Throws an exception if the index is out of range.
 * Columns are returned in the order that they were created.
 * If no <code>TableColumn</code>s were created by the programmer,
 * this method will throw <code>ERROR_INVALID_RANGE</code> despite
 * the fact that a single column of data may be visible in the table.
 * This occurs when the programmer uses the table like a list, adding
 * items but never creating a column.
 *
 * @param index the index of the column to return
 * @return the column at the given index
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Table#getColumnOrder()
 * @see Table#setColumnOrder(int[])
 * @see TableColumn#getMoveable()
 * @see TableColumn#setMoveable(bool)
 * @see SWT#Move
 */
public TableColumn getColumn (int index) {
    checkWidget ();
    if (!(0 <= index && index < columnCount)) error (SWT.ERROR_INVALID_RANGE);
    return columns [index];
}

/**
 * Returns the number of columns contained in the receiver.
 * If no <code>TableColumn</code>s were created by the programmer,
 * this value is zero, despite the fact that visually, one column
 * of items may be visible. This occurs when the programmer uses
 * the table like a list, adding items but never creating a column.
 *
 * @return the number of columns
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getColumnCount () {
    checkWidget ();
    return columnCount;
}

/**
 * Returns an array of zero-relative integers that map
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
 *
 * @see Table#setColumnOrder(int[])
 * @see TableColumn#getMoveable()
 * @see TableColumn#setMoveable(bool)
 * @see SWT#Move
 *
 * @since 3.1
 */
public int[] getColumnOrder () {
    checkWidget ();
    if (columnCount is 0) return new int [0];
    int [] order = new int [columnCount];
    OS.SendMessage (handle, OS.LVM_GETCOLUMNORDERARRAY, columnCount, order.ptr);
    return order;
}

/**
 * Returns an array of <code>TableColumn</code>s which are the
 * columns in the receiver.  Columns are returned in the order
 * that they were created.  If no <code>TableColumn</code>s were
 * created by the programmer, the array is empty, despite the fact
 * that visually, one column of items may be visible. This occurs
 * when the programmer uses the table like a list, adding items but
 * never creating a column.
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
 *
 * @see Table#getColumnOrder()
 * @see Table#setColumnOrder(int[])
 * @see TableColumn#getMoveable()
 * @see TableColumn#setMoveable(bool)
 * @see SWT#Move
 */
public TableColumn [] getColumns () {
    checkWidget ();
    TableColumn [] result = new TableColumn [columnCount];
    System.arraycopy (columns, 0, result, 0, columnCount);
    return result;
}

int getFocusIndex () {
//  checkWidget ();
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.LVM_GETNEXTITEM, -1, OS.LVNI_FOCUSED);
}

/**
 * Returns the width in pixels of a grid line.
 *
 * @return the width of a grid line in pixels
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getGridLineWidth () {
    checkWidget ();
    return GRID_WIDTH;
}

/**
 * Returns the height of the receiver's header
 *
 * @return the height of the header or zero if the header is not visible
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 */
public int getHeaderHeight () {
    checkWidget ();
    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    if (hwndHeader is null) return 0;
    RECT rect;
    OS.GetWindowRect (hwndHeader, &rect);
    return rect.bottom - rect.top;
}

/**
 * Returns <code>true</code> if the receiver's header is visible,
 * and <code>false</code> otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, this method
 * may still indicate that it is considered visible even though
 * it may not actually be showing.
 * </p>
 *
 * @return the receiver's header's visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getHeaderVisible () {
    checkWidget ();
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    return (bits & OS.LVS_NOCOLUMNHEADER) is 0;
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
public TableItem getItem (int index) {
    checkWidget ();
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (!(0 <= index && index < count)) error (SWT.ERROR_INVALID_RANGE);
    return _getItem (index);
}

/**
 * Returns the item at the given point in the receiver
 * or null if no such item exists. The point is in the
 * coordinate system of the receiver.
 * <p>
 * The item that is returned represents an item that could be selected by the user.
 * For example, if selection only occurs in items in the first column, then null is
 * returned if the point is outside of the item.
 * Note that the SWT.FULL_SELECTION style hint, which specifies the selection policy,
 * determines the extent of the selection.
 * </p>
 *
 * @param point the point used to locate the item
 * @return the item at the given point, or null if the point is not in a selectable item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public TableItem getItem (Point point) {
    checkWidget ();
    if (point is null) error (SWT.ERROR_NULL_ARGUMENT);
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (count is 0) return null;
    LVHITTESTINFO pinfo;
    pinfo.pt.x = point.x;
    pinfo.pt.y = point.y;
    if ((style & SWT.FULL_SELECTION) is 0) {
        if (hooks (SWT.MeasureItem)) {
            OS.SendMessage (handle, OS.LVM_SUBITEMHITTEST, 0, &pinfo);
            if (pinfo.iItem is -1) {
                RECT rect;
                rect.left = OS.LVIR_ICON;
                ignoreCustomDraw = true;
                auto code = OS.SendMessage (handle, OS.LVM_GETITEMRECT, 0, &rect);
                ignoreCustomDraw = false;
                if (code !is 0) {
                    pinfo.pt.x = rect.left;
                    OS.SendMessage (handle, OS.LVM_SUBITEMHITTEST, 0, &pinfo);
                }
            }
            if (pinfo.iItem !is -1 && pinfo.iSubItem is 0) {
                if (hitTestSelection (pinfo.iItem, pinfo.pt.x, pinfo.pt.y)) {
                    return _getItem (pinfo.iItem);
                }
            }
            return null;
        }
    }
    OS.SendMessage (handle, OS.LVM_HITTEST, 0, &pinfo);
    if (pinfo.iItem !is -1) {
        /*
        * Bug in Windows.  When the point that is used by
        * LVM_HITTEST is inside the header, Windows returns
        * the first item in the table.  The fix is to check
        * when LVM_HITTEST returns the first item and make
        * sure that when the point is within the header,
        * the first item is not returned.
        */
        if (pinfo.iItem is 0) {
            int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
            if ((bits & OS.LVS_NOCOLUMNHEADER) is 0) {
                auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
                if (hwndHeader !is null) {
                    RECT rect;
                    OS.GetWindowRect (hwndHeader, &rect);
                    POINT pt;
                    pt.x = pinfo.pt.x;
                    pt.y = pinfo.pt.y;
                    OS.MapWindowPoints (handle, null, &pt, 1);
                    if (OS.PtInRect (&rect, pt)) return null;
                }
            }
        }
        return _getItem (pinfo.iItem);
    }
    return null;
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
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
}

/**
 * Returns the height of the area which would be used to
 * display <em>one</em> of the items in the receiver.
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
    auto empty = OS.SendMessage (handle, OS.LVM_APPROXIMATEVIEWRECT, 0, 0);
    auto oneItem = OS.SendMessage (handle, OS.LVM_APPROXIMATEVIEWRECT, 1, 0);
    return OS.HIWORD (oneItem) - OS.HIWORD (empty);
}

/**
 * Returns a (possibly empty) array of <code>TableItem</code>s which
 * are the items in the receiver.
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
public TableItem [] getItems () {
    checkWidget ();
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    TableItem [] result = new TableItem [count];
    if ((style & SWT.VIRTUAL) !is 0) {
        for (int i=0; i<count; i++) {
            result [i] = _getItem (i);
        }
    } else {
        System.arraycopy (items, 0, result, 0, count);
    }
    return result;
}

/**
 * Returns <code>true</code> if the receiver's lines are visible,
 * and <code>false</code> otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, this method
 * may still indicate that it is considered visible even though
 * it may not actually be showing.
 * </p>
 *
 * @return the visibility state of the lines
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getLinesVisible () {
    checkWidget ();
    auto bits = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
    return (bits & OS.LVS_EX_GRIDLINES) !is 0;
}

/**
 * Returns an array of <code>TableItem</code>s that are currently
 * selected in the receiver. The order of the items is unspecified.
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
public TableItem [] getSelection () {
    checkWidget ();
    .LRESULT i = -1, j = 0, count = OS.SendMessage (handle, OS.LVM_GETSELECTEDCOUNT, 0, 0);
    TableItem [] result = new TableItem [count];
    while ((i = OS.SendMessage (handle, OS.LVM_GETNEXTITEM, i, OS.LVNI_SELECTED)) !is -1) {
        result [j++] = _getItem (cast(int)/*64bit*/i);
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
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.LVM_GETSELECTEDCOUNT, 0, 0);
}

/**
 * Returns the zero-relative index of the item which is currently
 * selected in the receiver, or -1 if no item is selected.
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
    auto focusIndex = OS.SendMessage (handle, OS.LVM_GETNEXTITEM, -1, OS.LVNI_FOCUSED);
    auto selectedIndex = OS.SendMessage (handle, OS.LVM_GETNEXTITEM, -1, OS.LVNI_SELECTED);
    if (focusIndex is selectedIndex) return cast(int)/*64bit*/selectedIndex;
    .LRESULT i = -1;
    while ((i = OS.SendMessage (handle, OS.LVM_GETNEXTITEM, i, OS.LVNI_SELECTED)) !is -1) {
        if (i is focusIndex) return cast(int)/*64bit*/i;
    }
    return cast(int)/*64bit*/selectedIndex;
}

/**
 * Returns the zero-relative indices of the items which are currently
 * selected in the receiver. The order of the indices is unspecified.
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
    .LRESULT i = -1, j = 0, count = OS.SendMessage (handle, OS.LVM_GETSELECTEDCOUNT, 0, 0);
    int [] result = new int [count];
    while ((i = OS.SendMessage (handle, OS.LVM_GETNEXTITEM, i, OS.LVNI_SELECTED)) !is -1) {
        result [j++] = cast(int)/*64bit*/i;
    }
    return result;
}

/**
 * Returns the column which shows the sort indicator for
 * the receiver. The value may be null if no column shows
 * the sort indicator.
 *
 * @return the sort indicator
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setSortColumn(TableColumn)
 *
 * @since 3.2
 */
public TableColumn getSortColumn () {
    checkWidget ();
    return sortColumn;
}

int getSortColumnPixel () {
    int pixel = OS.IsWindowEnabled (handle) ? getBackgroundPixel () : OS.GetSysColor (OS.COLOR_3DFACE);
    int red = pixel & 0xFF;
    int green = (pixel & 0xFF00) >> 8;
    int blue = (pixel & 0xFF0000) >> 16;
    if (red > 240 && green > 240 && blue > 240) {
        red -= 8;
        green -= 8;
        blue -= 8;
    } else {
        red = Math.min (0xFF, (red / 10) + red);
        green = Math.min (0xFF, (green / 10) + green);
        blue = Math.min (0xFF, (blue / 10) + blue);
    }
    return (red & 0xFF) | ((green & 0xFF) << 8) | ((blue & 0xFF) << 16);
}

/**
 * Returns the direction of the sort indicator for the receiver.
 * The value will be one of <code>UP</code>, <code>DOWN</code>
 * or <code>NONE</code>.
 *
 * @return the sort direction
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setSortDirection(int)
 *
 * @since 3.2
 */
public int getSortDirection () {
    checkWidget ();
    return sortDirection;
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
    /*
    * Bug in Windows.  Under rare circumstances, LVM_GETTOPINDEX
    * can return a negative number.  When this happens, the table
    * is displaying blank lines at the top of the controls.  The
    * fix is to check for a negative number and return zero instead.
    */
    return cast(int)/*64bit*/Math.max (0, OS.SendMessage (handle, OS.LVM_GETTOPINDEX, 0, 0));
}

bool hasChildren () {
    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    auto hwndChild = OS.GetWindow (handle, OS.GW_CHILD);
    while (hwndChild !is null) {
        if (hwndChild !is hwndHeader) return true;
        hwndChild = OS.GetWindow (hwndChild, OS.GW_HWNDNEXT);
    }
    return false;
}

bool hitTestSelection (int index, int x, int y) {
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (count is 0) return false;
    if (!hooks (SWT.MeasureItem)) return false;
    bool result = false;
    if (0 <= index && index < count) {
        TableItem item = _getItem (index);
        auto hDC = OS.GetDC (handle);
        HFONT oldFont, newFont = cast(HFONT)OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
        if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
        auto hFont = item.fontHandle (0);
        if (hFont !is cast(HFONT)-1) hFont = OS.SelectObject (hDC, hFont);
        Event event = sendMeasureItemEvent (item, index, 0, hDC);
        if (event.getBounds ().contains (x, y)) result = true;
        if (hFont !is cast(HFONT)-1) hFont = OS.SelectObject (hDC, hFont);
        if (newFont !is null) OS.SelectObject (hDC, oldFont);
        OS.ReleaseDC (handle, hDC);
//      if (isDisposed () || item.isDisposed ()) return false;
    }
    return result;
}

int imageIndex (Image image, int column) {
    if (image is null) return OS.I_IMAGENONE;
    if (column is 0) {
        firstColumnImage = true;
    } else {
        setSubImagesVisible (true);
    }
    if (imageList is null) {
        Rectangle bounds = image.getBounds ();
        imageList = display.getImageList (style & SWT.RIGHT_TO_LEFT, bounds.width, bounds.height);
        int index = imageList.indexOf (image);
        if (index is -1) index = imageList.add (image);
        auto hImageList = imageList.getHandle ();
        /*
        * Bug in Windows.  Making any change to an item that
        * changes the item height of a table while the table
        * is scrolled can cause the lines to draw incorrectly.
        * This happens even when the lines are not currently
        * visible and are shown afterwards.  The fix is to
        * save the top index, scroll to the top of the table
        * and then restore the original top index.
        */
        int topIndex = getTopIndex ();
        if (topIndex !is 0) {
            setRedraw (false);
            setTopIndex (0);
        }
        OS.SendMessage (handle, OS.LVM_SETIMAGELIST, OS.LVSIL_SMALL, hImageList);
        if (headerImageList !is null) {
            auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
            auto hHeaderImageList = headerImageList.getHandle ();
            OS.SendMessage (hwndHeader, OS.HDM_SETIMAGELIST, 0, hHeaderImageList);
        }
        fixCheckboxImageList (false);
        if (itemHeight !is -1) setItemHeight (false);
        if (topIndex !is 0) {
            setTopIndex (topIndex);
            setRedraw (true);
        }
        return index;
    }
    int index = imageList.indexOf (image);
    if (index !is -1) return index;
    return imageList.add (image);
}

int imageIndexHeader (Image image) {
    if (image is null) return OS.I_IMAGENONE;
    if (headerImageList is null) {
        Rectangle bounds = image.getBounds ();
        headerImageList = display.getImageList (style & SWT.RIGHT_TO_LEFT, bounds.width, bounds.height);
        int index = headerImageList.indexOf (image);
        if (index is -1) index = headerImageList.add (image);
        auto hImageList = headerImageList.getHandle ();
        auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
        OS.SendMessage (hwndHeader, OS.HDM_SETIMAGELIST, 0, hImageList);
        return index;
    }
    int index = headerImageList.indexOf (image);
    if (index !is -1) return index;
    return headerImageList.add (image);
}

/**
 * Searches the receiver's list starting at the first column
 * (index 0) until a column is found that is equal to the
 * argument, and returns the index of that column. If no column
 * is found, returns -1.
 *
 * @param column the search column
 * @return the index of the column
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the column is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (TableColumn column) {
    checkWidget ();
    if (column is null) error (SWT.ERROR_NULL_ARGUMENT);
    for (int i=0; i<columnCount; i++) {
        if (columns [i] is column) return i;
    }
    return -1;
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
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (TableItem item) {
    checkWidget ();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    int count = cast(int)/*64bit*/OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (1 <= lastIndexOf && lastIndexOf < count - 1) {
        if (items [lastIndexOf] is item) return lastIndexOf;
        if (items [lastIndexOf + 1] is item) return ++lastIndexOf;
        if (items [lastIndexOf - 1] is item) return --lastIndexOf;
    }
    if (lastIndexOf < count / 2) {
        for (int i=0; i<count; i++) {
            if (items [i] is item) return lastIndexOf = i;
        }
    } else {
        for (int i=count - 1; i>=0; --i) {
            if (items [i] is item) return lastIndexOf = i;
        }
    }
    return -1;
}

bool isCustomToolTip () {
    return hooks (SWT.MeasureItem);
}

bool isOptimizedRedraw () {
    if ((style & SWT.H_SCROLL) is 0 || (style & SWT.V_SCROLL) is 0) return false;
    return !hasChildren () && !hooks (SWT.Paint) && !filters (SWT.Paint);
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
    LVITEM lvItem;
    lvItem.mask = OS.LVIF_STATE;
    lvItem.stateMask = OS.LVIS_SELECTED;
    lvItem.iItem = index;
    auto result = OS.SendMessage (handle, OS.LVM_GETITEM, 0, &lvItem);
    return (result !is 0) && ((lvItem.state & OS.LVIS_SELECTED) !is 0);
}

override void register () {
    super.register ();
    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    if (hwndHeader !is null) display.addControl (hwndHeader, this);
}

override void releaseChildren (bool destroy) {
    if (items !is null) {
        int itemCount = cast(int)/*64bit*/OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
        /*
        * Feature in Windows 98.  When there are a large number
        * of columns and items in a table (>1000) where each
        * of the subitems in the table has a string, it is much
        * faster to delete each item with LVM_DELETEITEM rather
        * than using LVM_DELETEALLITEMS.  The fix is to detect
        * this case and delete the items, one by one.  The fact
        * that the fix is only necessary on Windows 98 was
        * confirmed using version 5.81 of COMCTL32.DLL on both
        * Windows 98 and NT.
        *
        * NOTE: LVM_DELETEALLITEMS is also sent by the table
        * when the table is destroyed.
        */
        if (OS.IsWin95 && columnCount > 1) {
            /* Turn off redraw and resize events and leave them off */
            resizeCount = 1;
            OS.SendMessage (handle, OS.WM_SETREDRAW, 0, 0);
            for (int i=itemCount-1; i>=0; --i) {
                TableItem item = items [i];
                if (item !is null && !item.isDisposed ()) item.release (false);
                ignoreSelect = ignoreShrink = true;
                OS.SendMessage (handle, OS.LVM_DELETEITEM, i, 0);
                ignoreSelect = ignoreShrink = false;
            }
        } else {
            for (int i=0; i<itemCount; i++) {
                TableItem item = items [i];
                if (item !is null && !item.isDisposed ()) item.release (false);
            }
        }
        items = null;
    }
    if (columns !is null) {
        for (int i=0; i<columnCount; i++) {
            TableColumn column = columns [i];
            if (!column.isDisposed ()) column.release (false);
        }
        columns = null;
    }
    super.releaseChildren (destroy);
}

override void releaseWidget () {
    super.releaseWidget ();
    customDraw = false;
    currentItem = null;
    if (imageList !is null) {
        OS.SendMessage (handle, OS.LVM_SETIMAGELIST, OS.LVSIL_SMALL, 0);
        display.releaseImageList (imageList);
    }
    if (headerImageList !is null) {
        auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
        OS.SendMessage (hwndHeader, OS.HDM_SETIMAGELIST, 0, 0);
        display.releaseImageList (headerImageList);
    }
    imageList = headerImageList = null;
    auto hStateList = cast(HANDLE) OS.SendMessage (handle, OS.LVM_GETIMAGELIST, OS.LVSIL_STATE, 0);
    OS.SendMessage (handle, OS.LVM_SETIMAGELIST, OS.LVSIL_STATE, 0);
    if (hStateList !is null) OS.ImageList_Destroy (hStateList);
    if (headerToolTipHandle !is null) OS.DestroyWindow (headerToolTipHandle);
    headerToolTipHandle = null;
}

/**
 * Removes the items from the receiver's list at the given
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
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (!(0 <= start && start <= end && end < count)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    setDeferResize (true);
    int last = -1;
    for (int i=0; i<newIndices.length; i++) {
        int index = newIndices [i];
        if (index !is last) {
            TableItem item = items [index];
            if (item !is null && !item.isDisposed ()) item.release (false);
            ignoreSelect = ignoreShrink = true;
            auto code = OS.SendMessage (handle, OS.LVM_DELETEITEM, index, 0);
            ignoreSelect = ignoreShrink = false;
            if (code is 0) error (SWT.ERROR_ITEM_NOT_REMOVED);
            System.arraycopy (items, index + 1, items, index, --count - index);
            items [count] = null;
            last = index;
        }
    }
    if (count is 0) setTableEmpty ();
    setDeferResize (false);
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
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (!(0 <= index && index < count)) error (SWT.ERROR_INVALID_RANGE);
    TableItem item = items [index];
    if (item !is null && !item.isDisposed ()) item.release (false);
    setDeferResize (true);
    ignoreSelect = ignoreShrink = true;
    auto code = OS.SendMessage (handle, OS.LVM_DELETEITEM, index, 0);
    ignoreSelect = ignoreShrink = false;
    if (code is 0) error (SWT.ERROR_ITEM_NOT_REMOVED);
    System.arraycopy (items, index + 1, items, index, --count - index);
    items [count] = null;
    if (count is 0) setTableEmpty ();
    setDeferResize (false);
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
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (!(0 <= start && start <= end && end < count)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    if (start is 0 && end is count - 1) {
        removeAll ();
    } else {
        setDeferResize (true);
        int index = start;
        while (index <= end) {
            TableItem item = items [index];
            if (item !is null && !item.isDisposed ()) item.release (false);
            ignoreSelect = ignoreShrink = true;
            auto code = OS.SendMessage (handle, OS.LVM_DELETEITEM, start, 0);
            ignoreSelect = ignoreShrink = false;
            if (code is 0) break;
            index++;
        }
        System.arraycopy (items, index, items, start, count - index);
        for (auto i=count-(index-start); i<count; i++) items [i] = null;
        if (index <= end) error (SWT.ERROR_ITEM_NOT_REMOVED);
        /*
        * This code is intentionally commented.  It is not necessary
        * to check for an empty table because removeAll() was called
        * when the start is 0 and end is count - 1.
        */
        //if (count - index is 0) setTableEmpty ();
        setDeferResize (false);
    }
}

/**
 * Removes all of the items from the receiver.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void removeAll () {
    checkWidget ();
    auto itemCount = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    for (int i=0; i<itemCount; i++) {
        TableItem item = items [i];
        if (item !is null && !item.isDisposed ()) item.release (false);
    }
    /*
    * Feature in Windows 98.  When there are a large number
    * of columns and items in a table (>1000) where each
    * of the subitems in the table has a string, it is much
    * faster to delete each item with LVM_DELETEITEM rather
    * than using LVM_DELETEALLITEMS.  The fix is to detect
    * this case and delete the items, one by one.  The fact
    * that the fix is only necessary on Windows 98 was
    * confirmed using version 5.81 of COMCTL32.DLL on both
    * Windows 98 and NT.
    *
    * NOTE: LVM_DELETEALLITEMS is also sent by the table
    * when the table is destroyed.
    */
    setDeferResize (true);
    if (OS.IsWin95 && columnCount > 1) {
        bool redraw = drawCount is 0 && OS.IsWindowVisible (handle);
        if (redraw) OS.SendMessage (handle, OS.WM_SETREDRAW, 0, 0);
        auto index = itemCount - 1;
        while (index >= 0) {
            ignoreSelect = ignoreShrink = true;
            auto code = OS.SendMessage (handle, OS.LVM_DELETEITEM, index, 0);
            ignoreSelect = ignoreShrink = false;
            if (code is 0) break;
            --index;
        }
        if (redraw) {
            OS.SendMessage (handle, OS.WM_SETREDRAW, 1, 0);
            /*
            * This code is intentionally commented.  The window proc
            * for the table implements WM_SETREDRAW to invalidate
            * and erase the table so it is not necessary to do this
            * again.
            */
//          int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE;
//          OS.RedrawWindow (handle, null, 0, flags);
        }
        if (index !is -1) error (SWT.ERROR_ITEM_NOT_REMOVED);
    } else {
        ignoreSelect = ignoreShrink = true;
        auto code = OS.SendMessage (handle, OS.LVM_DELETEALLITEMS, 0, 0);
        ignoreSelect = ignoreShrink = false;
        if (code is 0) error (SWT.ERROR_ITEM_NOT_REMOVED);
    }
    setTableEmpty ();
    setDeferResize (false);
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
 * @see #addSelectionListener(SelectionListener)
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
 * </p>
 *
 * @param indices the array of indices for the items to select
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Table#setSelection(int[])
 */
public void select (int [] indices) {
    checkWidget ();
    // SWT extension: allow null array
    //if (indices is null) error (SWT.ERROR_NULL_ARGUMENT);
    int length = cast(int)/*64bit*/indices.length;
    if (length is 0 || ((style & SWT.SINGLE) !is 0 && length > 1)) return;
    LVITEM lvItem;
    lvItem.state = OS.LVIS_SELECTED;
    lvItem.stateMask = OS.LVIS_SELECTED;
    for (int i=length-1; i>=0; --i) {
        /*
        * An index of -1 will apply the change to all
        * items.  Ensure that indices are greater than -1.
        */
        if (indices [i] >= 0) {
            ignoreSelect = true;
            OS.SendMessage (handle, OS.LVM_SETITEMSTATE, indices [i], &lvItem);
            ignoreSelect = false;
        }
    }
}

/**
 * Selects the item at the given zero-relative index in the receiver.
 * If the item at the index was already selected, it remains
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
    /*
    * An index of -1 will apply the change to all
    * items.  Ensure that index is greater than -1.
    */
    if (index < 0) return;
    LVITEM lvItem;
    lvItem.state = OS.LVIS_SELECTED;
    lvItem.stateMask = OS.LVIS_SELECTED;
    ignoreSelect = true;
    OS.SendMessage (handle, OS.LVM_SETITEMSTATE, index, &lvItem);
    ignoreSelect = false;
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
 * </p>
 *
 * @param start the start of the range
 * @param end the end of the range
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Table#setSelection(int,int)
 */
public void select (int start, int end) {
    checkWidget ();
    if (end < 0 || start > end || ((style & SWT.SINGLE) !is 0 && start !is end)) return;
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (count is 0 || start >= count) return;
    start = cast(int)/*64bit*/Math.max (0, start);
    end = cast(int)/*64bit*/Math.min (end, count - 1);
    if (start is 0 && end is count - 1) {
        selectAll ();
    } else {
        /*
        * An index of -1 will apply the change to all
        * items.  Indices must be greater than -1.
        */
        LVITEM lvItem;
        lvItem.state = OS.LVIS_SELECTED;
        lvItem.stateMask = OS.LVIS_SELECTED;
        for (int i=start; i<=end; i++) {
            ignoreSelect = true;
            OS.SendMessage (handle, OS.LVM_SETITEMSTATE, i, &lvItem);
            ignoreSelect = false;
        }
    }
}

/**
 * Selects all of the items in the receiver.
 * <p>
 * If the receiver is single-select, do nothing.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void selectAll () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) return;
    LVITEM lvItem;
    lvItem.mask = OS.LVIF_STATE;
    lvItem.state = OS.LVIS_SELECTED;
    lvItem.stateMask = OS.LVIS_SELECTED;
    ignoreSelect = true;
    OS.SendMessage (handle, OS.LVM_SETITEMSTATE, -1, &lvItem);
    ignoreSelect = false;
}

void sendEraseItemEvent (TableItem item, NMLVCUSTOMDRAW* nmcd, int lParam, Event measureEvent) {
    auto hDC = nmcd.nmcd.hdc;
    int clrText = item.cellForeground !is null ? item.cellForeground [nmcd.iSubItem] : -1;
    if (clrText is -1) clrText = item.foreground;
    int clrTextBk = -1;
    if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
        if (sortColumn !is null && sortDirection !is SWT.NONE) {
            if (findImageControl () is null) {
                if (indexOf (sortColumn) is nmcd.iSubItem) {
                    clrTextBk = getSortColumnPixel ();
                }
            }
        }
    }
    clrTextBk = item.cellBackground !is null ? item.cellBackground [nmcd.iSubItem] : -1;
    if (clrTextBk is -1) clrTextBk = item.background;
    /*
    * Bug in Windows.  For some reason, CDIS_SELECTED always set,
    * even for items that are not selected.  The fix is to get
    * the selection state from the item.
    */
    LVITEM lvItem;
    lvItem.mask = OS.LVIF_STATE;
    lvItem.stateMask = OS.LVIS_SELECTED;
    lvItem.iItem = cast(int)/*64bit*/nmcd.nmcd.dwItemSpec;
    auto result = OS.SendMessage (handle, OS.LVM_GETITEM, 0, &lvItem);
    bool selected = (result !is 0 && (lvItem.state & OS.LVIS_SELECTED) !is 0);
    GCData data = new GCData ();
    data.device = display;
    int clrSelectionBk = -1;
    bool drawSelected = false, drawBackground = false, drawHot = false;
    if (nmcd.iSubItem is 0 || (style & SWT.FULL_SELECTION) !is 0) {
        drawHot = hotIndex is nmcd.nmcd.dwItemSpec;
    }
    if (OS.IsWindowEnabled (handle)) {
        if (selected && (nmcd.iSubItem is 0 || (style & SWT.FULL_SELECTION) !is 0)) {
            if (OS.GetFocus () is handle || display.getHighContrast ()) {
                drawSelected = true;
                data.foreground = OS.GetSysColor (OS.COLOR_HIGHLIGHTTEXT);
                data.background = clrSelectionBk = OS.GetSysColor (OS.COLOR_HIGHLIGHT);
            } else {
                drawSelected = (style & SWT.HIDE_SELECTION) is 0;
                data.foreground = OS.GetTextColor (hDC);
                data.background = clrSelectionBk = OS.GetSysColor (OS.COLOR_3DFACE);
            }
            if (explorerTheme) {
                data.foreground = clrText !is -1 ? clrText : getForegroundPixel ();
            }
        } else {
            drawBackground = clrTextBk !is -1;
            /*
            * Bug in Windows.  When LVM_SETTEXTBKCOLOR, LVM_SETBKCOLOR
            * or LVM_SETTEXTCOLOR is used to set the background color of
            * the the text or the control, the color is not set in the HDC
            * that is provided in Custom Draw.  The fix is to explicitly
            * set the color.
            */
            if (clrText is -1 || clrTextBk is -1) {
                Control control = findBackgroundControl ();
                if (control is null) control = this;
                if (clrText is -1) clrText = control.getForegroundPixel ();
                if (clrTextBk is -1) clrTextBk = control.getBackgroundPixel ();
            }
            data.foreground = clrText !is -1 ? clrText : OS.GetTextColor (hDC);
            data.background = clrTextBk !is -1 ? clrTextBk : OS.GetBkColor (hDC);
        }
    } else {
        data.foreground = OS.GetSysColor (OS.COLOR_GRAYTEXT);
        data.background = OS.GetSysColor (OS.COLOR_3DFACE);
        if (selected) clrSelectionBk = data.background;
    }
    data.font = item.getFont (nmcd.iSubItem);
    data.uiState = cast(int)/*64bit*/OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
    auto nSavedDC = OS.SaveDC (hDC);
    GC gc = GC.win32_new (hDC, data);
    RECT cellRect = item.getBounds (cast(int)/*64bit*/nmcd.nmcd.dwItemSpec, nmcd.iSubItem, true, true, true, true, hDC);
    Event event = new Event ();
    event.item = item;
    event.gc = gc;
    event.index = nmcd.iSubItem;
    event.detail |= SWT.FOREGROUND;
//  if ((nmcd.nmcd.uItemState & OS.CDIS_FOCUS) !is 0) {
    if (OS.SendMessage (handle, OS.LVM_GETNEXTITEM, -1, OS.LVNI_FOCUSED) is nmcd.nmcd.dwItemSpec) {
        if (nmcd.iSubItem is 0 || (style & SWT.FULL_SELECTION) !is 0) {
            if (handle is OS.GetFocus ()) {
                auto uiState = OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
                if ((uiState & OS.UISF_HIDEFOCUS) is 0) event.detail |= SWT.FOCUSED;
            }
        }
    }
    bool focused = (event.detail & SWT.FOCUSED) !is 0;
    if (drawHot) event.detail |= SWT.HOT;
    if (drawSelected) event.detail |= SWT.SELECTED;
    if (drawBackground) event.detail |= SWT.BACKGROUND;
    event.x = cellRect.left;
    event.y = cellRect.top;
    event.width = cellRect.right - cellRect.left;
    event.height = cellRect.bottom - cellRect.top;
    gc.setClipping (event.x, event.y, event.width, event.height);
    sendEvent (SWT.EraseItem, event);
    event.gc = null;
    auto clrSelectionText = data.foreground;
    gc.dispose ();
    OS.RestoreDC (hDC, nSavedDC);
    if (isDisposed () || item.isDisposed ()) return;
    if (event.doit) {
        ignoreDrawForeground = (event.detail & SWT.FOREGROUND) is 0;
        ignoreDrawBackground = (event.detail & SWT.BACKGROUND) is 0;
        ignoreDrawSelection = (event.detail & SWT.SELECTED) is 0;
        ignoreDrawFocus = (event.detail & SWT.FOCUSED) is 0;
        ignoreDrawHot = (event.detail & SWT.HOT) is 0;
    } else {
        ignoreDrawForeground = ignoreDrawBackground = ignoreDrawSelection = ignoreDrawFocus = ignoreDrawHot = true;
    }
    if (drawSelected) {
        if (ignoreDrawSelection) {
            ignoreDrawHot = true;
            if (nmcd.iSubItem is 0 || (style & SWT.FULL_SELECTION) !is 0) {
                selectionForeground = clrSelectionText;
            }
            nmcd.nmcd.uItemState &= ~OS.CDIS_SELECTED;
            OS.MoveMemory (lParam, nmcd, OS.NMLVCUSTOMDRAW_sizeof);
        }
    } else {
        if (ignoreDrawSelection) {
            nmcd.nmcd.uItemState |= OS.CDIS_SELECTED;
            OS.MoveMemory (lParam, nmcd, OS.NMLVCUSTOMDRAW_sizeof);
        }
    }

    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    bool firstColumn = nmcd.iSubItem is OS.SendMessage (hwndHeader, OS.HDM_ORDERTOINDEX, 0, 0);
    if (ignoreDrawForeground && ignoreDrawHot) {
        if (!ignoreDrawBackground && drawBackground) {
            RECT backgroundRect = item.getBounds (cast(int)/*64bit*/nmcd.nmcd.dwItemSpec, nmcd.iSubItem, true, false, true, false, hDC);
            fillBackground (hDC, clrTextBk, &backgroundRect);
        }
    }
    focusRect = null;
    if (!ignoreDrawHot || !ignoreDrawSelection || !ignoreDrawFocus) {
        bool fullText = (style & SWT.FULL_SELECTION) !is 0 || !firstColumn;
        RECT textRect = item.getBounds (cast(int)/*64bit*/nmcd.nmcd.dwItemSpec, nmcd.iSubItem, true, false, fullText, false, hDC);
        if ((style & SWT.FULL_SELECTION) is 0) {
            if (measureEvent !is null) {
                textRect.right = Math.min (cellRect.right, measureEvent.x + measureEvent.width);
            }
            if (!ignoreDrawFocus) {
                nmcd.nmcd.uItemState &= ~OS.CDIS_FOCUS;
                OS.MoveMemory (lParam, nmcd, OS.NMLVCUSTOMDRAW_sizeof);
                focusRect = new RECT;
                *focusRect = textRect;
            }
        }
        if (explorerTheme) {
            if (!ignoreDrawHot || (!ignoreDrawSelection && clrSelectionBk !is -1)) {
                bool hot = drawHot;
                RECT pClipRect;
                OS.SetRect (&pClipRect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
                RECT rect;
                OS.SetRect (&rect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
                if ((style & SWT.FULL_SELECTION) !is 0) {
                    auto count = OS.SendMessage (hwndHeader, OS.HDM_GETITEMCOUNT, 0, 0);
                    auto index = OS.SendMessage (hwndHeader, OS.HDM_ORDERTOINDEX, count - 1, 0);
                    RECT headerRect;
                    OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, index, &headerRect);
                    OS.MapWindowPoints (hwndHeader, handle, cast(POINT*) &headerRect, 2);
                    rect.left = 0;
                    rect.right = headerRect.right;
                    pClipRect.left = cellRect.left;
                    pClipRect.right += EXPLORER_EXTRA;
                } else {
                    rect.right += EXPLORER_EXTRA;
                    pClipRect.right += EXPLORER_EXTRA;
                }
                auto hTheme = OS.OpenThemeData (handle, Display.LISTVIEW.ptr);
                int iStateId = selected ? OS.LISS_SELECTED : OS.LISS_HOT;
                if (OS.GetFocus () !is handle && selected && !hot) iStateId = OS.LISS_SELECTEDNOTFOCUS;
                OS.DrawThemeBackground (hTheme, hDC, OS.LVP_LISTITEM, iStateId, &rect, &pClipRect);
                OS.CloseThemeData (hTheme);
            }
        } else {
            if (!ignoreDrawSelection && clrSelectionBk !is -1) fillBackground (hDC, clrSelectionBk, &textRect);
        }
    }
    if (focused && ignoreDrawFocus) {
        nmcd.nmcd.uItemState &= ~OS.CDIS_FOCUS;
        OS.MoveMemory (lParam, nmcd, OS.NMLVCUSTOMDRAW_sizeof);
    }
    if (ignoreDrawForeground) {
        RECT clipRect = item.getBounds (cast(int)/*64bit*/nmcd.nmcd.dwItemSpec, nmcd.iSubItem, true, true, true, false, hDC);
        OS.SaveDC (hDC);
        OS.SelectClipRgn (hDC, null);
        OS.ExcludeClipRect (hDC, clipRect.left, clipRect.top, clipRect.right, clipRect.bottom);
    }
}

Event sendEraseItemEvent (TableItem item, NMTTCUSTOMDRAW* nmcd, int column, RECT* cellRect) {
    int nSavedDC = OS.SaveDC (nmcd.nmcd.hdc);
    RECT* insetRect = toolTipInset (cellRect);
    OS.SetWindowOrgEx (nmcd.nmcd.hdc, insetRect.left, insetRect.top, null);
    GCData data = new GCData ();
    data.device = display;
    data.foreground = OS.GetTextColor (nmcd.nmcd.hdc);
    data.background = OS.GetBkColor (nmcd.nmcd.hdc);
    data.font = item.getFont (column);
    data.uiState = cast(int)/*64bit*/OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
    GC gc = GC.win32_new (nmcd.nmcd.hdc, data);
    Event event = new Event ();
    event.item = item;
    event.index = column;
    event.gc = gc;
    event.detail |= SWT.FOREGROUND;
    event.x = cellRect.left;
    event.y = cellRect.top;
    event.width = cellRect.right - cellRect.left;
    event.height = cellRect.bottom - cellRect.top;
    //gc.setClipping (event.x, event.y, event.width, event.height);
    sendEvent (SWT.EraseItem, event);
    event.gc = null;
    //int newTextClr = data.foreground;
    gc.dispose ();
    OS.RestoreDC (nmcd.nmcd.hdc, nSavedDC);
    return event;
}

Event sendMeasureItemEvent (TableItem item, int row, int column, HDC hDC) {
    GCData data = new GCData ();
    data.device = display;
    data.font = item.getFont (column);
    int nSavedDC = OS.SaveDC (hDC);
    GC gc = GC.win32_new (hDC, data);
    RECT itemRect = item.getBounds (row, column, true, true, false, false, hDC);
    Event event = new Event ();
    event.item = item;
    event.gc = gc;
    event.index = column;
    event.x = itemRect.left;
    event.y = itemRect.top;
    event.width = itemRect.right - itemRect.left;
    event.height = itemRect.bottom - itemRect.top;
    sendEvent (SWT.MeasureItem, event);
    event.gc = null;
    gc.dispose ();
    OS.RestoreDC (hDC, nSavedDC);
    if (!isDisposed () && !item.isDisposed ()) {
        if (columnCount is 0) {
            auto width = OS.SendMessage (handle, OS.LVM_GETCOLUMNWIDTH, 0, 0);
            if (event.x + event.width > width) {
                OS.SendMessage (handle, OS.LVM_SETCOLUMNWIDTH, 0, event.x + event.width);
            }
        }
        if (event.height > getItemHeight ()) setItemHeight (event.height);
    }
    return event;
}

LRESULT sendMouseDownEvent (int type, int button, int msg, WPARAM wParam, LPARAM lParam) {
    Display display = this.display;
    display.captureChanged = false;
    if (!sendMouseEvent (type, button, handle, msg, wParam, lParam)) {
        if (!display.captureChanged && !isDisposed ()) {
            if (OS.GetCapture () !is handle) OS.SetCapture (handle);
        }
        return LRESULT.ZERO;
    }

    /*
    * Feature in Windows.  Inside WM_LBUTTONDOWN and WM_RBUTTONDOWN,
    * the widget starts a modal loop to determine if the user wants
    * to begin a drag/drop operation or marque select.  Unfortunately,
    * this modal loop eats the corresponding mouse up.  The fix is to
    * detect the cases when the modal loop has eaten the mouse up and
    * issue a fake mouse up.
    *
    * By observation, when the mouse is clicked anywhere but the check
    * box, the widget eats the mouse up.  When the mouse is dragged,
    * the widget does not eat the mouse up.
    */
    LVHITTESTINFO pinfo;
    pinfo.pt.x = OS.GET_X_LPARAM (lParam);
    pinfo.pt.y = OS.GET_Y_LPARAM (lParam);
    OS.SendMessage (handle, OS.LVM_HITTEST, 0, &pinfo);
    if ((style & SWT.FULL_SELECTION) is 0) {
        if (hooks (SWT.MeasureItem)) {
            OS.SendMessage (handle, OS.LVM_SUBITEMHITTEST, 0, &pinfo);
            if (pinfo.iItem is -1) {
                auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
                if (count !is 0) {
                    RECT rect;
                    rect.left = OS.LVIR_ICON;
                    ignoreCustomDraw = true;
                    auto code = OS.SendMessage (handle, OS.LVM_GETITEMRECT, 0, &rect);
                    ignoreCustomDraw = false;
                    if (code !is 0) {
                        pinfo.pt.x = rect.left;
                        OS.SendMessage (handle, OS.LVM_SUBITEMHITTEST, 0, &pinfo);
                        pinfo.flags &= ~(OS.LVHT_ONITEMICON | OS.LVHT_ONITEMLABEL);
                    }
                }
            } else {
                if (pinfo.iSubItem !is 0) pinfo.iItem = -1;
            }
        }
    }

    /*
    * Force the table to have focus so that when the user
    * reselects the focus item, the LVIS_FOCUSED state bits
    * for the item will be set.  If the user did not click on
    * an item, then set focus to the table so that it will
    * come to the front and take focus in the work around
    * below.
    */
    OS.SetFocus (handle);

    /*
    * Feature in Windows.  When the user selects outside of
    * a table item, Windows deselects all the items, even
    * when the table is multi-select.  While not strictly
    * wrong, this is unexpected.  The fix is to detect the
    * case and avoid calling the window proc.
    */
    if ((style & SWT.SINGLE) !is 0 || hooks (SWT.MouseDown) || hooks (SWT.MouseUp)) {
        if (pinfo.iItem is -1) {
            if (!display.captureChanged && !isDisposed ()) {
                if (OS.GetCapture () !is handle) OS.SetCapture (handle);
            }
            return LRESULT.ZERO;
        }
    }

    /*
    * Feature in Windows.  When a table item is reselected
    * in a single-select table, Windows does not issue a
    * WM_NOTIFY because the item state has not changed.
    * This is strictly correct but is inconsistent with the
    * list widget and other widgets in Windows.  The fix is
    * to detect the case when an item is reselected and mark
    * it as selected.
    */
    bool forceSelect = false;
    auto count = OS.SendMessage (handle, OS.LVM_GETSELECTEDCOUNT, 0, 0);
    if (count is 1 && pinfo.iItem !is -1) {
        LVITEM lvItem;
        lvItem.mask = OS.LVIF_STATE;
        lvItem.stateMask = OS.LVIS_SELECTED;
        lvItem.iItem = pinfo.iItem;
        OS.SendMessage (handle, OS.LVM_GETITEM, 0, &lvItem);
        if ((lvItem.state & OS.LVIS_SELECTED) !is 0) {
            forceSelect = true;
        }
    }

    /* Determine whether the user has selected an item based on SWT.MeasureItem */
    fullRowSelect = false;
    if (pinfo.iItem !is -1) {
        if ((style & SWT.FULL_SELECTION) is 0) {
            if (hooks (SWT.MeasureItem)) {
                fullRowSelect = hitTestSelection (pinfo.iItem, pinfo.pt.x, pinfo.pt.y);
                if (fullRowSelect) {
                    int flags = OS.LVHT_ONITEMICON | OS.LVHT_ONITEMLABEL;
                    if ((pinfo.flags & flags) !is 0) fullRowSelect = false;
                }
            }
        }
    }

    /*
    * Feature in Windows.  Inside WM_LBUTTONDOWN and WM_RBUTTONDOWN,
    * the widget starts a modal loop to determine if the user wants
    * to begin a drag/drop operation or marque select.  This modal
    * loop eats mouse events until a drag is detected.  The fix is
    * to avoid this behavior by only running the drag and drop when
    * the event is hooked and the mouse is over an item.
    */
    bool dragDetect = (state & DRAG_DETECT) !is 0 && hooks (SWT.DragDetect);
    if (!dragDetect) {
        int flags = OS.LVHT_ONITEMICON | OS.LVHT_ONITEMLABEL;
        dragDetect = pinfo.iItem is -1 || (pinfo.flags & flags) is 0;
        if (fullRowSelect) dragDetect = true;
    }

    /*
    * Temporarily set LVS_EX_FULLROWSELECT to allow drag and drop
    * and the mouse to manipulate items based on the results of
    * the SWT.MeasureItem event.
    */
    if (fullRowSelect) {
        OS.UpdateWindow (handle);
        OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
        OS.SendMessage (handle, OS.LVM_SETEXTENDEDLISTVIEWSTYLE, OS.LVS_EX_FULLROWSELECT, OS.LVS_EX_FULLROWSELECT);
    }
    dragStarted = false;
    display.dragCancelled = false;
    if (!dragDetect) display.runDragDrop = false;
    auto code = callWindowProc (handle, msg, wParam, lParam, forceSelect);
    if (!dragDetect) display.runDragDrop = true;
    if (fullRowSelect) {
        fullRowSelect = false;
        OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
        OS.SendMessage (handle, OS.LVM_SETEXTENDEDLISTVIEWSTYLE, OS.LVS_EX_FULLROWSELECT, 0);
    }

    if (dragStarted || display.dragCancelled) {
        if (!display.captureChanged && !isDisposed ()) {
            if (OS.GetCapture () !is handle) OS.SetCapture (handle);
        }
    } else {
        int flags = OS.LVHT_ONITEMLABEL | OS.LVHT_ONITEMICON;
        bool fakeMouseUp = (pinfo.flags & flags) !is 0;
        if (!fakeMouseUp && (style & SWT.MULTI) !is 0) {
            fakeMouseUp = (pinfo.flags & OS.LVHT_ONITEMSTATEICON) is 0;
        }
        if (fakeMouseUp) {
            sendMouseEvent (SWT.MouseUp, button, handle, msg, wParam, lParam);
        }
    }
    return new LRESULT (code);
}

void sendPaintItemEvent (TableItem item, NMLVCUSTOMDRAW* nmcd) {
    auto hDC = nmcd.nmcd.hdc;
    GCData data = new GCData ();
    data.device = display;
    data.font = item.getFont (nmcd.iSubItem);
    /*
    * Bug in Windows.  For some reason, CDIS_SELECTED always set,
    * even for items that are not selected.  The fix is to get
    * the selection state from the item.
    */
    LVITEM lvItem;
    lvItem.mask = OS.LVIF_STATE;
    lvItem.stateMask = OS.LVIS_SELECTED;
    lvItem.iItem = cast(int)/*64bit*/nmcd.nmcd.dwItemSpec;
    auto result = OS.SendMessage (handle, OS.LVM_GETITEM, 0, &lvItem);
    bool selected = result !is 0 && (lvItem.state & OS.LVIS_SELECTED) !is 0;
    bool drawSelected = false, drawBackground = false, drawHot = false;
    if (nmcd.iSubItem is 0 || (style & SWT.FULL_SELECTION) !is 0) {
        drawHot = hotIndex is nmcd.nmcd.dwItemSpec;
    }
    if (OS.IsWindowEnabled (handle)) {
        if (selected && (nmcd.iSubItem is 0 || (style & SWT.FULL_SELECTION) !is 0)) {
            if (OS.GetFocus () is handle || display.getHighContrast ()) {
                drawSelected = true;
                if (selectionForeground !is -1) {
                    data.foreground = selectionForeground;
                } else {
                    data.foreground = OS.GetSysColor (OS.COLOR_HIGHLIGHTTEXT);
                }
                data.background = OS.GetSysColor (OS.COLOR_HIGHLIGHT);
            } else {
                drawSelected = (style & SWT.HIDE_SELECTION) is 0;
                data.foreground = OS.GetTextColor (hDC);
                data.background = OS.GetSysColor (OS.COLOR_3DFACE);
            }
            if (explorerTheme && selectionForeground is -1) {
                int clrText = item.cellForeground !is null ? item.cellForeground [nmcd.iSubItem] : -1;
                if (clrText is -1) clrText = item.foreground;
                data.foreground = clrText !is -1 ? clrText : getForegroundPixel ();
            }
        } else {
            int clrText = item.cellForeground !is null ? item.cellForeground [nmcd.iSubItem] : -1;
            if (clrText is -1) clrText = item.foreground;
            int clrTextBk = item.cellBackground !is null ? item.cellBackground [nmcd.iSubItem] : -1;
            if (clrTextBk is -1) clrTextBk = item.background;
            drawBackground = clrTextBk !is -1;
            /*
            * Bug in Windows.  When LVM_SETTEXTBKCOLOR, LVM_SETBKCOLOR
            * or LVM_SETTEXTCOLOR is used to set the background color of
            * the the text or the control, the color is not set in the HDC
            * that is provided in Custom Draw.  The fix is to explicitly
            * set the color.
            */
            if (clrText is -1 || clrTextBk is -1) {
                Control control = findBackgroundControl ();
                if (control is null) control = this;
                if (clrText is -1) clrText = control.getForegroundPixel ();
                if (clrTextBk is -1) clrTextBk = control.getBackgroundPixel ();
            }
            data.foreground = clrText !is -1 ? clrText : OS.GetTextColor (hDC);
            data.background = clrTextBk !is -1 ? clrTextBk : OS.GetBkColor (hDC);
        }
    } else {
        data.foreground = OS.GetSysColor (OS.COLOR_GRAYTEXT);
        data.background = OS.GetSysColor (OS.COLOR_3DFACE);
    }
    data.uiState = cast(int)/*64bit*/OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
    auto nSavedDC = OS.SaveDC (hDC);
    GC gc = GC.win32_new (hDC, data);
    RECT itemRect = item.getBounds (cast(int)/*64bit*/nmcd.nmcd.dwItemSpec, nmcd.iSubItem, true, true, false, false, hDC);
    Event event = new Event ();
    event.item = item;
    event.gc = gc;
    event.index = nmcd.iSubItem;
    event.detail |= SWT.FOREGROUND;
//  if ((nmcd.nmcd.uItemState & OS.CDIS_FOCUS) !is 0) {
    if (OS.SendMessage (handle, OS.LVM_GETNEXTITEM, -1, OS.LVNI_FOCUSED) is nmcd.nmcd.dwItemSpec) {
        if (nmcd.iSubItem is 0 || (style & SWT.FULL_SELECTION) !is 0) {
            if (handle is OS.GetFocus ()) {
                auto uiState = OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
                if ((uiState & OS.UISF_HIDEFOCUS) is 0) event.detail |= SWT.FOCUSED;
            }
        }
    }
    if (drawHot) event.detail |= SWT.HOT;
    if (drawSelected) event.detail |= SWT.SELECTED;
    if (drawBackground) event.detail |= SWT.BACKGROUND;
    event.x = itemRect.left;
    event.y = itemRect.top;
    event.width = itemRect.right - itemRect.left;
    event.height = itemRect.bottom - itemRect.top;
    RECT cellRect = item.getBounds (cast(int)/*64bit*/nmcd.nmcd.dwItemSpec, nmcd.iSubItem, true, true, true, true, hDC);
    int cellWidth = cellRect.right - cellRect.left;
    int cellHeight = cellRect.bottom - cellRect.top;
    gc.setClipping (cellRect.left, cellRect.top, cellWidth, cellHeight);
    sendEvent (SWT.PaintItem, event);
    if (data.focusDrawn) focusRect = null;
    event.gc = null;
    gc.dispose ();
    OS.RestoreDC (hDC, nSavedDC);
}

Event sendPaintItemEvent (TableItem item, NMTTCUSTOMDRAW* nmcd, int column, RECT* itemRect) {
    int nSavedDC = OS.SaveDC (nmcd.nmcd.hdc);
    RECT* insetRect = toolTipInset (itemRect);
    OS.SetWindowOrgEx (nmcd.nmcd.hdc, insetRect.left, insetRect.top, null);
    GCData data = new GCData ();
    data.device = display;
    data.font = item.getFont (column);
    data.foreground = OS.GetTextColor (nmcd.nmcd.hdc);
    data.background = OS.GetBkColor (nmcd.nmcd.hdc);
    data.uiState = cast(int)/*64bit*/OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
    GC gc = GC.win32_new (nmcd.nmcd.hdc, data);
    Event event = new Event ();
    event.item = item;
    event.index = column;
    event.gc = gc;
    event.detail |= SWT.FOREGROUND;
    event.x = itemRect.left;
    event.y = itemRect.top;
    event.width = itemRect.right - itemRect.left;
    event.height = itemRect.bottom - itemRect.top;
    //gc.setClipping (cellRect.left, cellRect.top, cellWidth, cellHeight);
    sendEvent (SWT.PaintItem, event);
    event.gc = null;
    gc.dispose ();
    OS.RestoreDC (nmcd.nmcd.hdc, nSavedDC);
    return event;
}

override
void setBackgroundImage (HBITMAP hBitmap) {
    super.setBackgroundImage (hBitmap);
    if (hBitmap !is null) {
        setBackgroundTransparent (true);
    } else {
        if (!hooks (SWT.MeasureItem) && !hooks (SWT.EraseItem) && !hooks (SWT.PaintItem)) {
            setBackgroundTransparent (false);
        }
    }
}

override void setBackgroundPixel (int newPixel) {
    auto oldPixel = OS.SendMessage (handle, OS.LVM_GETBKCOLOR, 0, 0);
    if (oldPixel !is OS.CLR_NONE) {
        if (findImageControl () !is null) return;
        if (newPixel is -1) newPixel = defaultBackground ();
        if (oldPixel !is newPixel) {
            OS.SendMessage (handle, OS.LVM_SETBKCOLOR, 0, newPixel);
            OS.SendMessage (handle, OS.LVM_SETTEXTBKCOLOR, 0, newPixel);
            if ((style & SWT.CHECK) !is 0) fixCheckboxImageListColor (true);
        }
    }
    /*
    * Feature in Windows.  When the background color is changed,
    * the table does not redraw until the next WM_PAINT.  The fix
    * is to force a redraw.
    */
    OS.InvalidateRect (handle, null, true);
}

void setBackgroundTransparent (bool transparent) {
    /*
    * Bug in Windows.  When the table has the extended style
    * LVS_EX_FULLROWSELECT and LVM_SETBKCOLOR is used with
    * CLR_NONE to make the table transparent, Windows draws
    * a black rectangle around the first column.  The fix is
    * clear LVS_EX_FULLROWSELECT.
    *
    * Feature in Windows.  When LVM_SETBKCOLOR is used with
    * CLR_NONE and LVM_SETSELECTEDCOLUMN is used to select
    * a column, Windows fills the column with the selection
    * color, drawing on top of the background image and any
    * other custom drawing.  The fix is to clear the selected
    * column.
    */
    auto oldPixel = OS.SendMessage (handle, OS.LVM_GETBKCOLOR, 0, 0);
    if (transparent) {
        if (oldPixel !is OS.CLR_NONE) {
            /*
            * Bug in Windows.  When the background color is changed,
            * the table does not redraw until the next WM_PAINT.  The
            * fix is to force a redraw.
            */
            OS.SendMessage (handle, OS.LVM_SETBKCOLOR, 0, OS.CLR_NONE);
            OS.SendMessage (handle, OS.LVM_SETTEXTBKCOLOR, 0, OS.CLR_NONE);
            OS.InvalidateRect (handle, null, true);

            /* Clear LVS_EX_FULLROWSELECT */
            if (!explorerTheme && (style & SWT.FULL_SELECTION) !is 0) {
                int bits = OS.LVS_EX_FULLROWSELECT;
                OS.SendMessage (handle, OS.LVM_SETEXTENDEDLISTVIEWSTYLE, bits, 0);
            }

            /* Clear LVM_SETSELECTEDCOLUMN */
            if ((sortDirection & (SWT.UP | SWT.DOWN)) !is 0) {
                if (sortColumn !is null && !sortColumn.isDisposed ()) {
                    OS.SendMessage (handle, OS.LVM_SETSELECTEDCOLUMN, -1, 0);
                    /*
                    * Bug in Windows.  When LVM_SETSELECTEDCOLUMN is set, Windows
                    * does not redraw either the new or the previous selected column.
                    * The fix is to force a redraw.
                    */
                    OS.InvalidateRect (handle, null, true);
                }
            }
        }
    } else {
        if (oldPixel is OS.CLR_NONE) {
            Control control = findBackgroundControl ();
            if (control is null) control = this;
            if (control.backgroundImage is null) {
                int newPixel = control.getBackgroundPixel ();
                OS.SendMessage (handle, OS.LVM_SETBKCOLOR, 0, newPixel);
                OS.SendMessage (handle, OS.LVM_SETTEXTBKCOLOR, 0, newPixel);
                if ((style & SWT.CHECK) !is 0) fixCheckboxImageListColor (true);
                OS.InvalidateRect (handle, null, true);
            }

            /* Set LVS_EX_FULLROWSELECT */
            if (!explorerTheme && (style & SWT.FULL_SELECTION) !is 0) {
                if (!hooks (SWT.EraseItem) && !hooks (SWT.PaintItem)) {
                    int bits = OS.LVS_EX_FULLROWSELECT;
                    OS.SendMessage (handle, OS.LVM_SETEXTENDEDLISTVIEWSTYLE, bits, bits);
                }
            }

            /* Set LVM_SETSELECTEDCOLUMN */
            if ((sortDirection & (SWT.UP | SWT.DOWN)) !is 0) {
                if (sortColumn !is null && !sortColumn.isDisposed ()) {
                    int column = indexOf (sortColumn);
                    if (column !is -1) {
                        OS.SendMessage (handle, OS.LVM_SETSELECTEDCOLUMN, column, 0);
                        /*
                        * Bug in Windows.  When LVM_SETSELECTEDCOLUMN is set, Windows
                        * does not redraw either the new or the previous selected column.
                        * The fix is to force a redraw.
                        */
                        OS.InvalidateRect (handle, null, true);
                    }
                }
            }
        }
    }
}

override void setBounds (int x, int y, int width, int height, int flags, bool defer) {
    /*
    * Bug in Windows.  If the table column widths are adjusted
    * in WM_SIZE or WM_POSITIONCHANGED using LVM_SETCOLUMNWIDTH
    * blank lines may be inserted at the top of the table.  A
    * call to LVM_GETTOPINDEX will return a negative number (this
    * is an impossible result).  Once the blank lines appear,
    * there seems to be no way to get rid of them, other than
    * destroying and recreating the table.  The fix is to send
    * the resize notification after the size has been changed in
    * the operating system.
    *
    * NOTE:  This does not fix the case when the user is resizing
    * columns dynamically.  There is no fix for this case at this
    * time.
    */
    setDeferResize (true);
    super.setBounds (x, y, width, height, flags, false);
    setDeferResize (false);
}

/**
 * Sets the order that the items in the receiver should
 * be displayed in to the given argument which is described
 * in terms of the zero-relative ordering of when the items
 * were added.
 *
 * @param order the new order to display the items
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the item order is not the same length as the number of items</li>
 * </ul>
 *
 * @see Table#getColumnOrder()
 * @see TableColumn#getMoveable()
 * @see TableColumn#setMoveable(bool)
 * @see SWT#Move
 *
 * @since 3.1
 */
public void setColumnOrder (int [] order) {
    checkWidget ();
    // SWT extension: allow null array
    //if (order is null) error (SWT.ERROR_NULL_ARGUMENT);
    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    if (columnCount is 0) {
        if (order.length !is 0) error (SWT.ERROR_INVALID_ARGUMENT);
        return;
    }
    if (order.length !is columnCount) error (SWT.ERROR_INVALID_ARGUMENT);
    int [] oldOrder = new int [columnCount];
    OS.SendMessage (handle, OS.LVM_GETCOLUMNORDERARRAY, columnCount, oldOrder.ptr);
    bool reorder = false;
    bool [] seen = new bool [columnCount];
    for (int i=0; i<order.length; i++) {
        int index = order [i];
        if (index < 0 || index >= columnCount) error (SWT.ERROR_INVALID_RANGE);
        if (seen [index]) error (SWT.ERROR_INVALID_ARGUMENT);
        seen [index] = true;
        if (index !is oldOrder [i]) reorder = true;
    }
    if (reorder) {
        RECT [] oldRects = new RECT [columnCount];
        for (int i=0; i<columnCount; i++) {
            //oldRects [i] = new RECT ();
            OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, i, &oldRects [i]);
        }
        OS.SendMessage (handle, OS.LVM_SETCOLUMNORDERARRAY, order.length, order.ptr);
        /*
        * Bug in Windows.  When LVM_SETCOLUMNORDERARRAY is used to change
        * the column order, the header redraws correctly but the table does
        * not.  The fix is to force a redraw.
        */
        OS.InvalidateRect (handle, null, true);
        TableColumn[] newColumns = new TableColumn [columnCount];
        System.arraycopy (columns, 0, newColumns, 0, columnCount);
        RECT newRect;
        for (int i=0; i<columnCount; i++) {
            TableColumn column = newColumns [i];
            if (!column.isDisposed ()) {
                OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, i, &newRect);
                if (newRect.left !is oldRects [i].left) {
                    column.updateToolTip (i);
                    column.sendEvent (SWT.Move);
                }
            }
        }
    }
}

void setCustomDraw (bool customDraw) {
    if (this.customDraw is customDraw) return;
    if (!this.customDraw && customDraw && currentItem !is null) {
        OS.InvalidateRect (handle, null, true);
    }
    this.customDraw = customDraw;
}

void setDeferResize (bool defer) {
    if (defer) {
        if (resizeCount++ is 0) {
            wasResized = false;
            /*
            * Feature in Windows.  When LVM_SETBKCOLOR is used with CLR_NONE
            * to make the background of the table transparent, drawing becomes
            * slow.  The fix is to temporarily clear CLR_NONE when redraw is
            * turned off.
            */
            if (hooks (SWT.MeasureItem) || hooks (SWT.EraseItem) || hooks (SWT.PaintItem)) {
                if (drawCount++ is 0 && OS.IsWindowVisible (handle)) {
                    OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
                    OS.SendMessage (handle, OS.LVM_SETBKCOLOR, 0, 0xFFFFFF);
                }
            }
        }
    } else {
        if (--resizeCount is 0) {
            if (hooks (SWT.MeasureItem) || hooks (SWT.EraseItem) || hooks (SWT.PaintItem)) {
                if (--drawCount is 0 /*&& OS.IsWindowVisible (handle)*/) {
                    OS.SendMessage (handle, OS.LVM_SETBKCOLOR, 0, OS.CLR_NONE);
                    OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
                    static if (OS.IsWinCE) {
                        auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
                        if (hwndHeader !is null) OS.InvalidateRect (hwndHeader, null, true);
                        OS.InvalidateRect (handle, null, true);
                    } else {
                        int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE | OS.RDW_ALLCHILDREN;
                        OS.RedrawWindow (handle, null, null, flags);
                    }
                }
            }
            if (wasResized) {
                wasResized = false;
                setResizeChildren (false);
                sendEvent (SWT.Resize);
                if (isDisposed ()) return;
                if (layout_ !is null) {
                    markLayout (false, false);
                    updateLayout (false, false);
                }
                setResizeChildren (true);
            }
        }
    }
}

void setCheckboxImageList (int width, int height, bool fixScroll) {
    if ((style & SWT.CHECK) is 0) return;
    int count = 4, flags = 0;
    static if (OS.IsWinCE) {
        flags |= OS.ILC_COLOR;
    } else {
        {// new scope for hDC
        auto hDC = OS.GetDC (handle);
        auto bits = OS.GetDeviceCaps (hDC, OS.BITSPIXEL);
        auto planes = OS.GetDeviceCaps (hDC, OS.PLANES);
        OS.ReleaseDC (handle, hDC);
        int depth = bits * planes;
        switch (depth) {
            case 4: flags |= OS.ILC_COLOR4; break;
            case 8: flags |= OS.ILC_COLOR8; break;
            case 16: flags |= OS.ILC_COLOR16; break;
            case 24: flags |= OS.ILC_COLOR24; break;
            case 32: flags |= OS.ILC_COLOR32; break;
            default: flags |= OS.ILC_COLOR; break;
        }
        }
    }
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) flags |= OS.ILC_MIRROR;
    if (OS.COMCTL32_MAJOR < 6 || !OS.IsAppThemed ()) flags |= OS.ILC_MASK;
    auto hStateList = OS.ImageList_Create (width, height, flags, count, count);
    auto hDC = OS.GetDC (handle);
    auto memDC = OS.CreateCompatibleDC (hDC);
    auto hBitmap = OS.CreateCompatibleBitmap (hDC, width * count, height);
    auto hOldBitmap = OS.SelectObject (memDC, hBitmap);
    RECT rect;
    OS.SetRect (&rect, 0, 0, width * count, height);
    int clrBackground;
    if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
        Control control = findBackgroundControl ();
        if (control is null) control = this;
        clrBackground = control.getBackgroundPixel ();
    } else {
        clrBackground = 0x020000FF;
        if ((clrBackground & 0xFFFFFF) is OS.GetSysColor (OS.COLOR_WINDOW)) {
            clrBackground = 0x0200FF00;
        }
    }
    auto hBrush = OS.CreateSolidBrush (clrBackground);
    OS.FillRect (memDC, &rect, hBrush);
    OS.DeleteObject (hBrush);
    auto oldFont = OS.SelectObject (hDC, defaultFont ());
    TEXTMETRIC tm;
    OS.GetTextMetrics (hDC, &tm);
    OS.SelectObject (hDC, oldFont);
    int itemWidth = Math.min (tm.tmHeight, width);
    int itemHeight = Math.min (tm.tmHeight, height);
    int left = (width - itemWidth) / 2, top = (height - itemHeight) / 2 + 1;
    OS.SetRect (&rect, left, top, left + itemWidth, top + itemHeight);
    if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
        auto hTheme = display.hButtonTheme ();
        OS.DrawThemeBackground (hTheme, memDC, OS.BP_CHECKBOX, OS.CBS_UNCHECKEDNORMAL, &rect, null);
        rect.left += width;  rect.right += width;
        OS.DrawThemeBackground (hTheme, memDC, OS.BP_CHECKBOX, OS.CBS_CHECKEDNORMAL, &rect, null);
        rect.left += width;  rect.right += width;
        OS.DrawThemeBackground (hTheme, memDC, OS.BP_CHECKBOX, OS.CBS_UNCHECKEDNORMAL, &rect, null);
        rect.left += width;  rect.right += width;
        OS.DrawThemeBackground (hTheme, memDC, OS.BP_CHECKBOX, OS.CBS_MIXEDNORMAL, &rect, null);
    } else {
        OS.DrawFrameControl (memDC, &rect, OS.DFC_BUTTON, OS.DFCS_BUTTONCHECK | OS.DFCS_FLAT);
        rect.left += width;  rect.right += width;
        OS.DrawFrameControl (memDC, &rect, OS.DFC_BUTTON, OS.DFCS_BUTTONCHECK | OS.DFCS_CHECKED | OS.DFCS_FLAT);
        rect.left += width;  rect.right += width;
        OS.DrawFrameControl (memDC, &rect, OS.DFC_BUTTON, OS.DFCS_BUTTONCHECK | OS.DFCS_INACTIVE | OS.DFCS_FLAT);
        rect.left += width;  rect.right += width;
        OS.DrawFrameControl (memDC, &rect, OS.DFC_BUTTON, OS.DFCS_BUTTONCHECK | OS.DFCS_CHECKED | OS.DFCS_INACTIVE | OS.DFCS_FLAT);
    }
    OS.SelectObject (memDC, hOldBitmap);
    OS.DeleteDC (memDC);
    OS.ReleaseDC (handle, hDC);
    if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
        OS.ImageList_Add (hStateList, hBitmap, null);
    } else {
        OS.ImageList_AddMasked (hStateList, hBitmap, clrBackground);
    }
    OS.DeleteObject (hBitmap);
    /*
    * Bug in Windows.  Making any change to an item that
    * changes the item height of a table while the table
    * is scrolled can cause the lines to draw incorrectly.
    * This happens even when the lines are not currently
    * visible and are shown afterwards.  The fix is to
    * save the top index, scroll to the top of the table
    * and then restore the original top index.
    */
    int topIndex = getTopIndex ();
    if (fixScroll && topIndex !is 0) {
        setRedraw (false);
        setTopIndex (0);
    }
    auto hOldStateList = cast(HANDLE) OS.SendMessage (handle, OS.LVM_GETIMAGELIST, OS.LVSIL_STATE, 0);
    OS.SendMessage (handle, OS.LVM_SETIMAGELIST, OS.LVSIL_STATE, hStateList);
    if (hOldStateList !is null) OS.ImageList_Destroy (hOldStateList);
    /*
    * Bug in Windows.  Setting the LVSIL_STATE state image list
    * when the table already has a LVSIL_SMALL image list causes
    * pixel corruption of the images.  The fix is to reset the
    * LVSIL_SMALL image list.
    */
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
        auto hImageList = cast(HANDLE) OS.SendMessage (handle, OS.LVM_GETIMAGELIST, OS.LVSIL_SMALL, 0);
        OS.SendMessage (handle, OS.LVM_SETIMAGELIST, OS.LVSIL_SMALL, hImageList);
    }
    if (fixScroll && topIndex !is 0) {
        setTopIndex (topIndex);
        setRedraw (true);
    }
}

void setFocusIndex (int index) {
//  checkWidget ();
    /*
    * An index of -1 will apply the change to all
    * items.  Ensure that index is greater than -1.
    */
    if (index < 0) return;
    LVITEM lvItem;
    lvItem.state = OS.LVIS_FOCUSED;
    lvItem.stateMask = OS.LVIS_FOCUSED;
    ignoreSelect = true;
    OS.SendMessage (handle, OS.LVM_SETITEMSTATE, index, &lvItem);
    ignoreSelect = false;
    OS.SendMessage (handle, OS.LVM_SETSELECTIONMARK, 0, index);
}

override public void setFont (Font font) {
    checkWidget ();
    /*
    * Bug in Windows.  Making any change to an item that
    * changes the item height of a table while the table
    * is scrolled can cause the lines to draw incorrectly.
    * This happens even when the lines are not currently
    * visible and are shown afterwards.  The fix is to
    * save the top index, scroll to the top of the table
    * and then restore the original top index.
    */
    int topIndex = getTopIndex ();
    if (topIndex !is 0) {
        setRedraw (false);
        setTopIndex (0);
    }
    if (itemHeight !is -1) {
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        OS.SetWindowLong (handle, OS.GWL_STYLE, bits | OS.LVS_OWNERDRAWFIXED);
    }
    super.setFont (font);
    if (itemHeight !is -1) {
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        OS.SetWindowLong (handle, OS.GWL_STYLE, bits & ~OS.LVS_OWNERDRAWFIXED);
    }
    setScrollWidth (null, true);
    if (topIndex !is 0) {
        setTopIndex (topIndex);
        setRedraw (true);
    }

    /*
    * Bug in Windows.  Setting the font will cause the table
    * to be redrawn but not the column headers.  The fix is
    * to force a redraw of the column headers.
    */
    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    OS.InvalidateRect (hwndHeader, null, true);
}

override void setForegroundPixel (int pixel) {
    /*
    * The Windows table control uses CLR_DEFAULT to indicate
    * that it is using the default foreground color.  This
    * is undocumented.
    */
    if (pixel is -1) pixel = OS.CLR_DEFAULT;
    OS.SendMessage (handle, OS.LVM_SETTEXTCOLOR, 0, pixel);

    /*
    * Feature in Windows.  When the foreground color is
    * changed, the table does not redraw until the next
    * WM_PAINT.  The fix is to force a redraw.
    */
    OS.InvalidateRect (handle, null, true);
}

/**
 * Marks the receiver's header as visible if the argument is <code>true</code>,
 * and marks it invisible otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, marking
 * it visible may not actually cause it to be displayed.
 * </p>
 *
 * @param show the new visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setHeaderVisible (bool show) {
    checkWidget ();
    int newBits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    newBits &= ~OS.LVS_NOCOLUMNHEADER;
    if (!show) newBits |= OS.LVS_NOCOLUMNHEADER;
    /*
    * Feature in Windows.  Setting or clearing LVS_NOCOLUMNHEADER
    * causes the table to scroll to the beginning.  The fix is to
    * save and restore the top index causing the table to scroll
    * to the new location.
    */
    int oldIndex = getTopIndex ();
    OS.SetWindowLong (handle, OS.GWL_STYLE, newBits);

    /*
    * Bug in Windows.  Making any change to an item that
    * changes the item height of a table while the table
    * is scrolled can cause the lines to draw incorrectly.
    * This happens even when the lines are not currently
    * visible and are shown afterwards.  The fix is to
    * save the top index, scroll to the top of the table
    * and then restore the original top index.
    */
    int newIndex = getTopIndex ();
    if (newIndex !is 0) {
        setRedraw (false);
        setTopIndex (0);
    }
    if (show) {
        auto bits = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
        if ((bits & OS.LVS_EX_GRIDLINES) !is 0) fixItemHeight (false);
    }
    setTopIndex (oldIndex);
    if (newIndex !is 0) {
        setRedraw (true);
    }
    updateHeaderToolTips ();
}

/**
 * Sets the number of items contained in the receiver.
 *
 * @param count the number of items
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setItemCount (int count) {
    checkWidget ();
    count = Math.max (0, count);
    auto itemCount = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (count is itemCount) return;
    setDeferResize (true);
    bool isVirtual = (style & SWT.VIRTUAL) !is 0;
    if (!isVirtual) setRedraw (false);
    int index = count;
    while (index < itemCount) {
        TableItem item = items [index];
        if (item !is null && !item.isDisposed ()) item.release (false);
        if (!isVirtual) {
            ignoreSelect = ignoreShrink = true;
            auto code = OS.SendMessage (handle, OS.LVM_DELETEITEM, count, 0);
            ignoreSelect = ignoreShrink = false;
            if (code is 0) break;
        }
        index++;
    }
    if (index < itemCount) error (SWT.ERROR_ITEM_NOT_REMOVED);
    int length = Math.max (4, (count + 3) / 4 * 4);
    TableItem [] newItems = new TableItem [length];
    System.arraycopy (items, 0, newItems, 0, Math.min (count, itemCount));
    items = newItems;
    if (isVirtual) {
        int flags = OS.LVSICF_NOINVALIDATEALL | OS.LVSICF_NOSCROLL;
        OS.SendMessage (handle, OS.LVM_SETITEMCOUNT, count, flags);
        /*
        * Bug in Windows.  When a virtual table contains items and
        * LVM_SETITEMCOUNT is used to set the new item count to zero,
        * Windows does not redraw the table.  Note that simply not
        * specifying LVSICF_NOINVALIDATEALL or LVSICF_NOSCROLL does
        * correct the problem.  The fix is to force a redraw.
        */
        if (count is 0 && itemCount !is 0) {
            OS.InvalidateRect (handle, null, true);
        }
    } else {
        for (auto i=itemCount; i<count; i++) {
            items [i] = new TableItem (this, SWT.NONE, cast(int)/*64bit*/i, true);
        }
    }
    if (!isVirtual) setRedraw (true);
    if (itemCount is 0) setScrollWidth (null, false);
    setDeferResize (false);
}

void setItemHeight (bool fixScroll) {
    /*
    * Bug in Windows.  Making any change to an item that
    * changes the item height of a table while the table
    * is scrolled can cause the lines to draw incorrectly.
    * This happens even when the lines are not currently
    * visible and are shown afterwards.  The fix is to
    * save the top index, scroll to the top of the table
    * and then restore the original top index.
    */
    int topIndex = getTopIndex ();
    if (fixScroll && topIndex !is 0) {
        setRedraw (false);
        setTopIndex (0);
    }
    if (itemHeight is -1) {
        /*
        * Feature in Windows.  Windows has no API to restore the
        * defualt item height for a table.  The fix is to use
        * WM_SETFONT which recomputes and assigns the default item
        * height.
        */
        auto hFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
        OS.SendMessage (handle, OS.WM_SETFONT, hFont, 0);
    } else {
        /*
        * Feature in Windows.  Window has no API to set the item
        * height for a table.  The fix is to set temporarily set
        * LVS_OWNERDRAWFIXED then resize the table, causing a
        * WM_MEASUREITEM to be sent, then clear LVS_OWNERDRAWFIXED.
        */
        forceResize ();
        RECT rect;
        OS.GetWindowRect (handle, &rect);
        int width = rect.right - rect.left, height = rect.bottom - rect.top;
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        OS.SetWindowLong (handle, OS.GWL_STYLE, bits | OS.LVS_OWNERDRAWFIXED);
        int flags = OS.SWP_NOACTIVATE | OS.SWP_NOMOVE | OS.SWP_NOREDRAW | OS.SWP_NOZORDER;
        ignoreResize = true;
        SetWindowPos (handle, null , 0, 0, width, height + 1, flags);
        SetWindowPos (handle, null , 0, 0, width, height, flags);
        ignoreResize = false;
        OS.SetWindowLong (handle, OS.GWL_STYLE, bits);
    }
    if (fixScroll && topIndex !is 0) {
        setTopIndex (topIndex);
        setRedraw (true);
    }
}

/**
 * Sets the height of the area which would be used to
 * display <em>one</em> of the items in the table.
 *
 * @param itemHeight the height of one item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
/*public*/ void setItemHeight (int itemHeight) {
    checkWidget ();
    if (itemHeight < -1) error (SWT.ERROR_INVALID_ARGUMENT);
    this.itemHeight = itemHeight;
    setItemHeight (true);
    setScrollWidth (null, true);
}

/**
 * Marks the receiver's lines as visible if the argument is <code>true</code>,
 * and marks it invisible otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, marking
 * it visible may not actually cause it to be displayed.
 * </p>
 *
 * @param show the new visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLinesVisible (bool show) {
    checkWidget ();
    int newBits = show  ? OS.LVS_EX_GRIDLINES : 0;
    OS.SendMessage (handle, OS.LVM_SETEXTENDEDLISTVIEWSTYLE, OS.LVS_EX_GRIDLINES, newBits);
    if (show) {
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        if ((bits & OS.LVS_NOCOLUMNHEADER) is 0) fixItemHeight (true);
    }
}

override public void setRedraw (bool redraw) {
    checkWidget ();
    /*
     * Feature in Windows.  When WM_SETREDRAW is used to turn
     * off drawing in a widget, it clears the WS_VISIBLE bits
     * and then sets them when redraw is turned back on.  This
     * means that WM_SETREDRAW will make a widget unexpectedly
     * visible.  The fix is to track the visibility state while
     * drawing is turned off and restore it when drawing is turned
     * back on.
     */
    if (drawCount is 0) {
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        if ((bits & OS.WS_VISIBLE) is 0) state |= HIDDEN;
    }
    if (redraw) {
        if (--drawCount is 0) {
            /*
            * When many items are added to a table, it is faster to
            * temporarily unsubclass the window proc so that messages
            * are dispatched directly to the table.
            *
            * NOTE: This is optimization somewhat dangerous because any
            * operation can occur when redraw is turned off, even operations
            * where the table must be subclassed in order to have the correct
            * behavior or work around a Windows bug.
            *
            * This code is intentionally commented.
            */
//          subclass ();

            /* Set the width of the horizontal scroll bar */
            setScrollWidth (null, true);

            /*
            * Bug in Windows.  For some reason, when WM_SETREDRAW is used
            * to turn redraw back on this may result in a WM_SIZE.  If the
            * table column widths are adjusted in WM_SIZE, blank lines may
            * be inserted at the top of the widget.  A call to LVM_GETTOPINDEX
            * will return a negative number (this is an impossible result).
            * The fix is to send the resize notification after the size has
            * been changed in the operating system.
            */
            setDeferResize (true);
            OS.SendMessage (handle, OS.WM_SETREDRAW, 1, 0);
            auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
            if (hwndHeader !is null) OS.SendMessage (hwndHeader, OS.WM_SETREDRAW, 1, 0);
            if ((state & HIDDEN) !is 0) {
                state &= ~HIDDEN;
                OS.ShowWindow (handle, OS.SW_HIDE);
            } else {
                static if (OS.IsWinCE) {
                    OS.InvalidateRect (handle, null, false);
                    if (hwndHeader !is null) {
                        OS.InvalidateRect (hwndHeader, null, false);
                    }
                } else {
                    int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE | OS.RDW_ALLCHILDREN;
                    OS.RedrawWindow (handle, null, null, flags);
                }
            }
            setDeferResize (false);
        }
    } else {
        if (drawCount++ is 0) {
            OS.SendMessage (handle, OS.WM_SETREDRAW, 0, 0);
            auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
            if (hwndHeader !is null) OS.SendMessage (hwndHeader, OS.WM_SETREDRAW, 0, 0);

            /*
            * When many items are added to a table, it is faster to
            * temporarily unsubclass the window proc so that messages
            * are dispatched directly to the table.
            *
            * NOTE: This is optimization somewhat dangerous because any
            * operation can occur when redraw is turned off, even operations
            * where the table must be subclassed in order to have the correct
            * behavior or work around a Windows bug.
            *
            * This code is intentionally commented.
            */
//          unsubclass ();
        }
    }
}

bool setScrollWidth (TableItem item, bool force) {
    if (currentItem !is null) {
        if (currentItem !is item) fixScrollWidth = true;
        return false;
    }
    if (!force && (drawCount !is 0 || !OS.IsWindowVisible (handle))) {
        fixScrollWidth = true;
        return false;
    }
    fixScrollWidth = false;
    /*
    * NOTE: It is much faster to measure the strings and compute the
    * width of the scroll bar in non-virtual table rather than using
    * LVM_SETCOLUMNWIDTH with LVSCW_AUTOSIZE.
    */
    if (columnCount is 0) {
        int newWidth = 0, imageIndent = 0, index = 0;
        auto itemCount = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
        while (index < itemCount) {
            String string = null;
            HFONT hFont = cast(HFONT)-1;
            if (item !is null) {
                string = item.text;
                imageIndent = Math.max (imageIndent, item.imageIndent);
                hFont = item.fontHandle (0);
            } else {
                if (items [index] !is null) {
                    TableItem tableItem = items [index];
                    string = tableItem.text;
                    imageIndent = Math.max (imageIndent, tableItem.imageIndent);
                    hFont = tableItem.fontHandle (0);
                }
            }
            if (string !is null && string.length !is 0) {
                if (hFont !is cast(HFONT)-1) {
                    auto hDC = OS.GetDC (handle);
                    auto oldFont = OS.SelectObject (hDC, hFont);
                    int flags = OS.DT_CALCRECT | OS.DT_SINGLELINE | OS.DT_NOPREFIX;
                    StringT buffer = StrToTCHARs (getCodePage (), string, false);
                    RECT rect;
                    OS.DrawText (hDC, buffer.ptr, cast(int)/*64bit*/buffer.length, &rect, flags);
                    OS.SelectObject (hDC, oldFont);
                    OS.ReleaseDC (handle, hDC);
                    newWidth = Math.max (newWidth, rect.right - rect.left);
                } else {
                    LPCTSTR buffer = StrToTCHARz (getCodePage (), string );
                    newWidth = cast(int)/*64bit*/Math.max (newWidth, OS.SendMessage (handle, OS.LVM_GETSTRINGWIDTH, 0, cast(void*)buffer));
                }
            }
            if (item !is null) break;
            index++;
        }
        /*
        * Bug in Windows.  When the width of the first column is
        * small but not zero, Windows draws '...' outside of the
        * bounds of the text.  This is strange, but only causes
        * problems when the item is selected.  In this case, Windows
        * clears the '...' but doesn't redraw it when the item is
        * deselected, causing pixel corruption.  The fix is to ensure
        * that the column is at least wide enough to draw a single
        * space.
        */
        if (newWidth is 0) {
            StringT buffer = StrToTCHARs (getCodePage (), " ", true);
            newWidth = cast(int)/*64bit*/Math.max (newWidth, OS.SendMessage (handle, OS.LVM_GETSTRINGWIDTH, 0, cast(void*)buffer.ptr));
        }
        auto hStateList = cast(HANDLE) OS.SendMessage (handle, OS.LVM_GETIMAGELIST, OS.LVSIL_STATE, 0);
        if (hStateList !is null) {
            int cx, cy;
            OS.ImageList_GetIconSize (hStateList, &cx, &cy);
            newWidth += cx + INSET;
        }
        auto hImageList = cast(HANDLE) OS.SendMessage (handle, OS.LVM_GETIMAGELIST, OS.LVSIL_SMALL, 0);
        if (hImageList !is null) {
            int cx, cy;
            OS.ImageList_GetIconSize (hImageList, &cx, &cy);
            newWidth += (imageIndent + 1) * cx;
        } else {
            /*
            * Bug in Windows.  When LVM_SETIMAGELIST is used to remove the
            * image list by setting it to NULL, the item width and height
            * is not changed and space is reserved for icons despite the
            * fact that there are none.  The fix is to set the image list
            * to be very small before setting it to NULL.  This causes
            * Windows to reserve the smallest possible space when an image
            * list is removed.  In this case, the scroll width must be one
            * pixel larger.
            */
            newWidth++;
        }
        newWidth += INSET * 2;
        auto oldWidth = OS.SendMessage (handle, OS.LVM_GETCOLUMNWIDTH, 0, 0);
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
            newWidth += VISTA_EXTRA;
        }
        if (newWidth > oldWidth) {
            /*
            * Feature in Windows.  When LVM_SETCOLUMNWIDTH is sent,
            * Windows draws right away instead of queuing a WM_PAINT.
            * This can cause recursive calls when called from paint
            * or from messages that are retrieving the item data,
            * such as WM_NOTIFY, causing a stack overflow.  The fix
            * is to turn off redraw and queue a repaint, collapsing
            * the recursive calls.
            */
            bool redraw = drawCount is 0 && OS.IsWindowVisible (handle);
            if (redraw) OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
            OS.SendMessage (handle, OS.LVM_SETCOLUMNWIDTH, 0, newWidth);
            if (redraw) {
                OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
                static if (OS.IsWinCE) {
                    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
                    if (hwndHeader !is null) OS.InvalidateRect (hwndHeader, null, true);
                    OS.InvalidateRect (handle, null, true);
                } else {
                    int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE | OS.RDW_ALLCHILDREN;
                    OS.RedrawWindow (handle, null, null, flags);
                }
            }
            return true;
        }
    }
    return false;
}

/**
 * Selects the items at the given zero-relative indices in the receiver.
 * The current selection is cleared before the new items are selected.
 * <p>
 * Indices that are out of range and duplicate indices are ignored.
 * If the receiver is single-select and multiple indices are specified,
 * then all indices are ignored.
 * </p>
 *
 * @param indices the indices of the items to select
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Table#deselectAll()
 * @see Table#select(int[])
 */
public void setSelection (int [] indices) {
    checkWidget ();
    // SWT extension: allow null array
    //if (indices is null) error (SWT.ERROR_NULL_ARGUMENT);
    deselectAll ();
    auto length = indices.length;
    if (length is 0 || ((style & SWT.SINGLE) !is 0 && length > 1)) return;
    select (indices);
    int focusIndex = indices [0];
    if (focusIndex !is -1) setFocusIndex (focusIndex);
    showSelection ();
}

/**
 * Sets the receiver's selection to the given item.
 * The current selection is cleared before the new item is selected.
 * <p>
 * If the item is not in the receiver, then it is ignored.
 * </p>
 *
 * @param item the item to select
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the item has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setSelection (TableItem  item) {
    checkWidget ();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    setSelection ([item]);
}

/**
 * Sets the receiver's selection to be the given array of items.
 * The current selection is cleared before the new items are selected.
 * <p>
 * Items that are not in the receiver are ignored.
 * If the receiver is single-select and multiple items are specified,
 * then all items are ignored.
 * </p>
 *
 * @param items the array of items
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if one of the items has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Table#deselectAll()
 * @see Table#select(int[])
 * @see Table#setSelection(int[])
 */
public void setSelection (TableItem [] items) {
    checkWidget ();
    // SWT extension: allow null array
    //if (items is null) error (SWT.ERROR_NULL_ARGUMENT);
    deselectAll ();
    int length = cast(int)/*64bit*/items.length;
    if (length is 0 || ((style & SWT.SINGLE) !is 0 && length > 1)) return;
    int focusIndex = -1;
    for (int i=length-1; i>=0; --i) {
        int index = indexOf (items [i]);
        if (index !is -1) {
            select (focusIndex = index);
        }
    }
    if (focusIndex !is -1) setFocusIndex (focusIndex);
    showSelection ();
}

/**
 * Selects the item at the given zero-relative index in the receiver.
 * The current selection is first cleared, then the new item is selected.
 *
 * @param index the index of the item to select
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Table#deselectAll()
 * @see Table#select(int)
 */
public void setSelection (int index) {
    checkWidget ();
    deselectAll ();
    select (index);
    if (index !is -1) setFocusIndex (index);
    showSelection ();
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
 * </p>
 *
 * @param start the start index of the items to select
 * @param end the end index of the items to select
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Table#deselectAll()
 * @see Table#select(int,int)
 */
public void setSelection (int start, int end) {
    checkWidget ();
    deselectAll ();
    if (end < 0 || start > end || ((style & SWT.SINGLE) !is 0 && start !is end)) return;
    int count = cast(int)/*64bit*/OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (count is 0 || start >= count) return;
    start = Math.max (0, start);
    end = Math.min (end, count - 1);
    select (start, end);
    setFocusIndex (start);
    showSelection ();
}

/**
 * Sets the column used by the sort indicator for the receiver. A null
 * value will clear the sort indicator.  The current sort column is cleared
 * before the new column is set.
 *
 * @param column the column used by the sort indicator or <code>null</code>
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the column is disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setSortColumn (TableColumn column) {
    checkWidget ();
    if (column !is null && column.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
    if (sortColumn !is null && !sortColumn.isDisposed ()) {
        sortColumn.setSortDirection (SWT.NONE);
    }
    sortColumn = column;
    if (sortColumn !is null && sortDirection !is SWT.NONE) {
        sortColumn.setSortDirection (sortDirection);
    }
}

/**
 * Sets the direction of the sort indicator for the receiver. The value
 * can be one of <code>UP</code>, <code>DOWN</code> or <code>NONE</code>.
 *
 * @param direction the direction of the sort indicator
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setSortDirection (int direction) {
    checkWidget ();
    if ((direction & (SWT.UP | SWT.DOWN)) is 0 && direction !is SWT.NONE) return;
    sortDirection = direction;
    if (sortColumn !is null && !sortColumn.isDisposed ()) {
        sortColumn.setSortDirection (direction);
    }
}

void setSubImagesVisible (bool visible) {
    auto dwExStyle = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
    if (((dwExStyle & OS.LVS_EX_SUBITEMIMAGES) !is 0 ) is visible) return;
    int bits = visible ? OS.LVS_EX_SUBITEMIMAGES : 0;
    OS.SendMessage (handle, OS.LVM_SETEXTENDEDLISTVIEWSTYLE, OS.LVS_EX_SUBITEMIMAGES, bits);
}

void setTableEmpty () {
    if (imageList !is null) {
        /*
        * Bug in Windows.  When LVM_SETIMAGELIST is used to remove the
        * image list by setting it to NULL, the item width and height
        * is not changed and space is reserved for icons despite the
        * fact that there are none.  The fix is to set the image list
        * to be very small before setting it to NULL.  This causes
        * Windows to reserve the smallest possible space when an image
        * list is removed.
        */
        auto hImageList = OS.ImageList_Create (1, 1, 0, 0, 0);
        OS.SendMessage (handle, OS.LVM_SETIMAGELIST, OS.LVSIL_SMALL, hImageList);
        OS.SendMessage (handle, OS.LVM_SETIMAGELIST, OS.LVSIL_SMALL, 0);
        if (headerImageList !is null) {
            auto hHeaderImageList = headerImageList.getHandle ();
            auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
            OS.SendMessage (hwndHeader, OS.HDM_SETIMAGELIST, 0, hHeaderImageList);
        }
        OS.ImageList_Destroy (hImageList);
        display.releaseImageList (imageList);
        imageList = null;
        if (itemHeight !is -1) setItemHeight (false);
    }
    if (!hooks (SWT.MeasureItem) && !hooks (SWT.EraseItem) && !hooks (SWT.PaintItem)) {
        Control control = findBackgroundControl ();
        if (control is null) control = this;
        if (control.backgroundImage is null) {
            setCustomDraw (false);
            setBackgroundTransparent (false);
            if (OS.COMCTL32_MAJOR < 6) style &= ~SWT.DOUBLE_BUFFERED;
        }
    }
    items = new TableItem [4];
    if (columnCount is 0) {
        OS.SendMessage (handle, OS.LVM_SETCOLUMNWIDTH, 0, 0);
        setScrollWidth (null, false);
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
    auto topIndex = OS.SendMessage (handle, OS.LVM_GETTOPINDEX, 0, 0);
    if (index is topIndex) return;

    /*
    * Bug in Windows.  For some reason, LVM_SCROLL refuses to
    * scroll a table vertically when the width and height of
    * the table is smaller than a certain size.  The values
    * that seem to cause the problem are width=68 and height=6
    * but there is no guarantee that these values cause the
    * failure on different machines or on different versions
    * of Windows.  It may depend on the font and any number
    * of other factors.  For example, setting the font to
    * anything but the default sometimes fixes the problem.
    * The fix is to use LVM_GETCOUNTPERPAGE to detect the
    * case when the number of visible items is zero and
    * use LVM_ENSUREVISIBLE to scroll the table to make the
    * index visible.
    */

    /*
    * Bug in Windows.  When the table header is visible and
    * there is not enough space to show a single table item,
    * LVM_GETCOUNTPERPAGE can return a negative number instead
    * of zero.  The fix is to test for negative or zero.
    */
    if (OS.SendMessage (handle, OS.LVM_GETCOUNTPERPAGE, 0, 0) <= 0) {
        /*
        * Bug in Windows.  For some reason, LVM_ENSUREVISIBLE can
        * scroll one item more or one item less when there is not
        * enough space to show a single table item.  The fix is
        * to detect the case and call LVM_ENSUREVISIBLE again with
        * the same arguments.  It seems that once LVM_ENSUREVISIBLE
        * has scrolled into the general area, it is able to scroll
        * to the exact item.
        */
        OS.SendMessage (handle, OS.LVM_ENSUREVISIBLE, index, 1);
        if (index !is OS.SendMessage (handle, OS.LVM_GETTOPINDEX, 0, 0)) {
            OS.SendMessage (handle, OS.LVM_ENSUREVISIBLE, index, 1);
        }
        return;
    }

    /* Use LVM_SCROLL to scroll the table */
    RECT rect;
    rect.left = OS.LVIR_BOUNDS;
    ignoreCustomDraw = true;
    OS.SendMessage (handle, OS.LVM_GETITEMRECT, 0, &rect);
    ignoreCustomDraw = false;
    auto dy = (index - topIndex) * (rect.bottom - rect.top);
    OS.SendMessage (handle, OS.LVM_SCROLL, 0, dy);
}

/**
 * Shows the column.  If the column is already showing in the receiver,
 * this method simply returns.  Otherwise, the columns are scrolled until
 * the column is visible.
 *
 * @param column the column to be shown
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the column is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the column has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void showColumn (TableColumn column) {
    checkWidget ();
    if (column is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (column.isDisposed()) error(SWT.ERROR_INVALID_ARGUMENT);
    if (column.parent !is this) return;
    int index = indexOf (column);
    if (!(0 <= index && index < columnCount)) return;
    /*
    * Feature in Windows.  Calling LVM_GETSUBITEMRECT with -1 for the
    * row number gives the bounds of the item that would be above the
    * first row in the table.  This is undocumented and does not work
    * for the first column. In this case, to get the bounds of the
    * first column, get the bounds of the second column and subtract
    * the width of the first. The left edge of the second column is
    * also used as the right edge of the first.
    */
    RECT itemRect;
    itemRect.left = OS.LVIR_BOUNDS;
    if (index is 0) {
        itemRect.top = 1;
        ignoreCustomDraw = true;
        OS.SendMessage (handle, OS.LVM_GETSUBITEMRECT, -1, &itemRect);
        ignoreCustomDraw = false;
        itemRect.right = itemRect.left;
        auto width = cast(int)/*64bit*/OS.SendMessage (handle, OS.LVM_GETCOLUMNWIDTH, 0, 0);
        itemRect.left = itemRect.right - width;
    } else {
        itemRect.top = index;
        ignoreCustomDraw = true;
        OS.SendMessage (handle, OS.LVM_GETSUBITEMRECT, -1, &itemRect);
        ignoreCustomDraw = false;
    }
    /*
    * Bug in Windows.  When a table that is drawing grid lines
    * is slowly scrolled horizontally to the left, the table does
    * not redraw the newly exposed vertical grid lines.  The fix
    * is to save the old scroll position, call the window proc,
    * get the new scroll position and redraw the new area.
    */
    int oldPos = 0;
    auto bits = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
    if ((bits & OS.LVS_EX_GRIDLINES) !is 0) {
        SCROLLINFO info;
        info.cbSize = SCROLLINFO.sizeof;
        info.fMask = OS.SIF_POS;
        OS.GetScrollInfo (handle, OS.SB_HORZ, &info);
        oldPos = info.nPos;
    }
    RECT rect;
    OS.GetClientRect (handle, &rect);
    if (itemRect.left < rect.left) {
        int dx = itemRect.left - rect.left;
        OS.SendMessage (handle, OS.LVM_SCROLL, dx, 0);
    } else {
        int width = Math.min (rect.right - rect.left, itemRect.right - itemRect.left);
        if (itemRect.left + width > rect.right) {
            int dx = itemRect.left + width - rect.right;
            OS.SendMessage (handle, OS.LVM_SCROLL, dx, 0);
        }
    }
    /*
    * Bug in Windows.  When a table that is drawing grid lines
    * is slowly scrolled horizontally to the left, the table does
    * not redraw the newly exposed vertical grid lines.  The fix
    * is to save the old scroll position, call the window proc,
    * get the new scroll position and redraw the new area.
    */
    if ((bits & OS.LVS_EX_GRIDLINES) !is 0) {
        SCROLLINFO info;
        info.cbSize = SCROLLINFO.sizeof;
        info.fMask = OS.SIF_POS;
        OS.GetScrollInfo (handle, OS.SB_HORZ, &info);
        int newPos = info.nPos;
        if (newPos < oldPos) {
            rect.right = oldPos - newPos + GRID_WIDTH;
            OS.InvalidateRect (handle, &rect, true);
        }
    }
}

void showItem (int index) {
    /*
    * Bug in Windows.  For some reason, when there is insufficient space
    * to show an item, LVM_ENSUREVISIBLE causes blank lines to be
    * inserted at the top of the widget.  A call to LVM_GETTOPINDEX will
    * return a negative number (this is an impossible result).  The fix
    * is to use LVM_GETCOUNTPERPAGE to detect the case when the number
    * of visible items is zero and use LVM_ENSUREVISIBLE with the
    * fPartialOK flag set to true to scroll the table.
    */
    if (OS.SendMessage (handle, OS.LVM_GETCOUNTPERPAGE, 0, 0) <= 0) {
        /*
        * Bug in Windows.  For some reason, LVM_ENSUREVISIBLE can
        * scroll one item more or one item less when there is not
        * enough space to show a single table item.  The fix is
        * to detect the case and call LVM_ENSUREVISIBLE again with
        * the same arguments.  It seems that once LVM_ENSUREVISIBLE
        * has scrolled into the general area, it is able to scroll
        * to the exact item.
        */
        OS.SendMessage (handle, OS.LVM_ENSUREVISIBLE, index, 1);
        if (index !is OS.SendMessage (handle, OS.LVM_GETTOPINDEX, 0, 0)) {
            OS.SendMessage (handle, OS.LVM_ENSUREVISIBLE, index, 1);
        }
    } else {
        OS.SendMessage (handle, OS.LVM_ENSUREVISIBLE, index, 0);
    }
}

/**
 * Shows the item.  If the item is already showing in the receiver,
 * this method simply returns.  Otherwise, the items are scrolled until
 * the item is visible.
 *
 * @param item the item to be shown
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the item has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Table#showSelection()
 */
public void showItem (TableItem item) {
    checkWidget ();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed()) error(SWT.ERROR_INVALID_ARGUMENT);
    int index = indexOf (item);
    if (index !is -1) showItem (index);
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
 *
 * @see Table#showItem(TableItem)
 */
public void showSelection () {
    checkWidget ();
    auto index = OS.SendMessage (handle, OS.LVM_GETNEXTITEM, -1, OS.LVNI_SELECTED);
    if (index !is -1) showItem (cast(int)/*64bit*/index);
}

/*public*/ void sort () {
    checkWidget ();
//  if ((style & SWT.VIRTUAL) !is 0) return;
//  auto itemCount = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
//  if (itemCount is 0 || itemCount is 1) return;
//  Comparator comparator = new Comparator () {
//      int index = sortColumn is null ? 0 : indexOf (sortColumn);
//      public int compare (Object object1, Object object2) {
//          TableItem item1 = (TableItem) object1, item2 = (TableItem) object2;
//          if (sortDirection is SWT.UP || sortDirection is SWT.NONE) {
//              return item1.getText (index).compareTo (item2.getText (index));
//          } else {
//              return item2.getText (index).compareTo (item1.getText (index));
//          }
//      }
//  };
//  Arrays.sort (items, 0, itemCount, comparator);
//  redraw ();
}

override void subclass () {
    super.subclass ();
    if (HeaderProc !is null) {
        auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
        OS.SetWindowLongPtr (hwndHeader, OS.GWLP_WNDPROC, display.windowProc);
    }
}

RECT* toolTipInset (RECT* rect) {
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
        RECT* insetRect = new RECT;
        OS.SetRect (insetRect, rect.left - 1, rect.top - 1, rect.right + 1, rect.bottom + 1);
        return insetRect;
    }
    return rect;
}

RECT* toolTipRect (RECT* rect) {
    RECT* toolRect = new RECT;
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
        OS.SetRect (toolRect, rect.left - 1, rect.top - 1, rect.right + 1, rect.bottom + 1);
    } else {
        HWND hwndToolTip = cast(HWND)OS.SendMessage (handle, OS.LVM_GETTOOLTIPS, 0, 0);
        OS.SetRect (toolRect, rect.left, rect.top, rect.right, rect.bottom);
        int dwStyle = OS.GetWindowLong (hwndToolTip, OS.GWL_STYLE);
        int dwExStyle = OS.GetWindowLong (hwndToolTip, OS.GWL_EXSTYLE);
        OS.AdjustWindowRectEx (toolRect, dwStyle, false, dwExStyle);
    }
    return toolRect;
}

override String toolTipText (NMTTDISPINFO* hdr) {
    auto hwndToolTip = cast(HWND) OS.SendMessage (handle, OS.LVM_GETTOOLTIPS, 0, 0);
    if (hwndToolTip is hdr.hdr.hwndFrom && toolTipText_ !is null) return ""; //$NON-NLS-1$
    if (headerToolTipHandle is hdr.hdr.hwndFrom) {
        for (int i=0; i<columnCount; i++) {
            TableColumn column = columns [i];
            if (column.id is hdr.hdr.idFrom) return column.toolTipText;
        }
    }
    return super.toolTipText (hdr);
}

override void unsubclass () {
    super.unsubclass ();
    if (HeaderProc !is null) {
        auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
        OS.SetWindowLongPtr (hwndHeader, OS.GWLP_WNDPROC, cast(LONG_PTR)HeaderProc);
    }
}

override void update (bool all) {
//  checkWidget ();
    /*
    * When there are many columns in a table, scrolling performance
    * can be improved by temporarily unsubclassing the window proc
    * so that internal messages are dispatched directly to the table.
    * If the application expects to see a paint event or has a child
    * whose font, foreground or background color might be needed,
    * the window proc cannot be unsubclassed.
    *
    * NOTE: The header tooltip can subclass the header proc so the
    * current proc must be restored or header tooltips stop working.
    */
    WNDPROC oldHeaderProc, oldTableProc;
    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    bool fixSubclass = isOptimizedRedraw ();
    if (fixSubclass) {
        oldTableProc = cast(WNDPROC)OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)TableProc);
        oldHeaderProc = cast(WNDPROC)OS.SetWindowLongPtr (hwndHeader, OS.GWLP_WNDPROC, cast(LONG_PTR)HeaderProc);
    }
    super.update (all);
    if (fixSubclass) {
        OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)oldTableProc);
        OS.SetWindowLongPtr (hwndHeader, OS.GWLP_WNDPROC, cast(LONG_PTR)oldHeaderProc);
    }
}

void updateHeaderToolTips () {
    if (headerToolTipHandle is null) return;
    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    RECT rect;
    TOOLINFO lpti;
    lpti.cbSize = OS.TOOLINFO_sizeof;
    lpti.uFlags = OS.TTF_SUBCLASS;
    lpti.hwnd = hwndHeader;
    lpti.lpszText = OS.LPSTR_TEXTCALLBACK;
    for (int i=0; i<columnCount; i++) {
        TableColumn column = columns [i];
        if (OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, i, &rect) !is 0) {
            lpti.uId = column.id = display.nextToolTipId++;
            lpti.rect.left = rect.left;
            lpti.rect.top = rect.top;
            lpti.rect.right = rect.right;
            lpti.rect.bottom = rect.bottom;
            OS.SendMessage (headerToolTipHandle, OS.TTM_ADDTOOL, 0, &lpti);
        }
    }
}

override void updateImages () {
    if (sortColumn !is null && !sortColumn.isDisposed ()) {
        if (OS.COMCTL32_MAJOR < 6) {
            switch (sortDirection) {
                case SWT.UP:
                case SWT.DOWN:
                    sortColumn.setImage (display.getSortImage (sortDirection), true, true);
                    break;
                default:
            }
        }
    }
}

void updateMoveable () {
    int index = 0;
    while (index < columnCount) {
        if (columns [index].moveable) break;
        index++;
    }
    int newBits = index < columnCount ? OS.LVS_EX_HEADERDRAGDROP : 0;
    OS.SendMessage (handle, OS.LVM_SETEXTENDEDLISTVIEWSTYLE, OS.LVS_EX_HEADERDRAGDROP, newBits);
}

override int widgetStyle () {
    int bits = super.widgetStyle () | OS.LVS_SHAREIMAGELISTS;
    if ((style & SWT.HIDE_SELECTION) is 0) bits |= OS.LVS_SHOWSELALWAYS;
    if ((style & SWT.SINGLE) !is 0) bits |= OS.LVS_SINGLESEL;
    /*
    * This code is intentionally commented.  In the future,
    * the FLAT bit may be used to make the header flat and
    * unresponsive to mouse clicks.
    */
//  if ((style & SWT.FLAT) !is 0) bits |= OS.LVS_NOSORTHEADER;
    bits |= OS.LVS_REPORT | OS.LVS_NOCOLUMNHEADER;
    if ((style & SWT.VIRTUAL) !is 0) bits |= OS.LVS_OWNERDATA;
    return bits;
}

override String windowClass () {
    return TCHARsToStr( TableClass );
}

override ptrdiff_t windowProc () {
    return cast(ptrdiff_t) TableProc;
}

override .LRESULT windowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    if (hwnd !is handle) {
        switch (msg) {
            /* This code is intentionally commented */
//          case OS.WM_CONTEXTMENU: {
//              LRESULT result = wmContextMenu (hwnd, wParam, lParam);
//              if (result !is null) return result.value;
//              break;
//          }
            case OS.WM_CAPTURECHANGED: {
                /*
                * Bug in Windows.  When the capture changes during a
                * header drag, Windows does not redraw the header item
                * such that the header remains pressed.  For example,
                * when focus is assigned to a push button, the mouse is
                * pressed (but not released), then the SPACE key is
                * pressed to activate the button, the capture changes,
                * the header not notified and NM_RELEASEDCAPTURE is not
                * sent.  The fix is to redraw the header when the capture
                * changes to another control.
                *
                * This does not happen on XP.
                */
                if (OS.COMCTL32_MAJOR < 6) {
                    if (lParam !is 0) {
                        auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
                        if (lParam !is cast(ptrdiff_t)hwndHeader) OS.InvalidateRect (hwndHeader, null, true);
                    }
                }
                break;
            }
            case OS.WM_MOUSELEAVE: {
                /*
                * Bug in Windows.  On XP, when a tooltip is hidden
                * due to a time out or mouse press, the tooltip
                * remains active although no longer visible and
                * won't show again until another tooltip becomes
                * active.  The fix is to reset the tooltip bounds.
                */
                if (OS.COMCTL32_MAJOR >= 6) updateHeaderToolTips ();
                updateHeaderToolTips ();
                break;
            }
            case OS.WM_NOTIFY: {
                NMHDR* hdr = cast(NMHDR*)lParam;
                //OS.MoveMemory (hdr, lParam, NMHDR.sizeof);
                switch (hdr.code) {
                    case OS.TTN_SHOW:
                    case OS.TTN_POP:
                    case OS.TTN_GETDISPINFOA:
                    case OS.TTN_GETDISPINFOW:
                        return OS.SendMessage (handle, msg, wParam, lParam);
                    default:
                }
                break;
            }
            case OS.WM_SETCURSOR: {
                if (wParam is cast(ptrdiff_t)hwnd) {
                    int hitTest = cast(short) OS.LOWORD (lParam);
                    if (hitTest is OS.HTCLIENT) {
                        HDHITTESTINFO pinfo;
                        int pos = OS.GetMessagePos ();
                        POINT pt;
                        OS.POINTSTOPOINT (pt, pos);
                        OS.ScreenToClient (hwnd, &pt);
                        pinfo.pt.x = pt.x;
                        pinfo.pt.y = pt.y;
                        auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
                        auto index = OS.SendMessage (hwndHeader, OS.HDM_HITTEST, 0, &pinfo);
                        if (0 <= index && index < columnCount && !columns [index].resizable) {
                            if ((pinfo.flags & (OS.HHT_ONDIVIDER | OS.HHT_ONDIVOPEN)) !is 0) {
                                OS.SetCursor (OS.LoadCursor (null, cast(TCHAR*)OS.IDC_ARROW));
                                return 1;
                            }
                        }
                    }
                }
                break;
            }
            default:
        }
        return callWindowProc (hwnd, msg, wParam, lParam);
    }
    if (msg is Display.DI_GETDRAGIMAGE) {
        /*
        * Bug in Windows.  On Vista, for some reason, DI_GETDRAGIMAGE
        * returns an image that does not contain strings.
        *
        * Bug in Windows. For custom draw control the window origin the 
        * in HDC is wrong.
        * 
        * The fix for both cases is to create the image using PrintWindow(). 
        */
        if ((!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) || (style & SWT.VIRTUAL) !is 0 || hooks (SWT.EraseItem) || hooks (SWT.PaintItem)) {
            auto topIndex = OS.SendMessage (handle, OS.LVM_GETTOPINDEX, 0, 0);
            auto selection = OS.SendMessage (handle, OS.LVM_GETNEXTITEM, topIndex - 1, OS.LVNI_SELECTED);
            if (selection is -1) return 0;
            POINT mousePos;
            OS.POINTSTOPOINT (mousePos, OS.GetMessagePos ());
            OS.MapWindowPoints(null, handle, &mousePos, 1);
            RECT clientRect;
            OS.GetClientRect (handle, &clientRect);
            TableItem item = _getItem (cast(int)/*64bit*/selection);
            RECT rect = item.getBounds (cast(int)/*64bit*/selection, 0, true, true, true);
            if ((style & SWT.FULL_SELECTION) !is 0) {
                int width = DRAG_IMAGE_SIZE;
                rect.left = Math.max (clientRect.left, mousePos.x - width / 2);
                if (clientRect.right > rect.left + width) {
                    rect.right = rect.left + width;
                } else {
                    rect.right = clientRect.right;
                    rect.left = Math.max (clientRect.left, rect.right - width);
                }
            }
            auto hRgn = OS.CreateRectRgn (rect.left, rect.top, rect.right, rect.bottom);
            while ((selection = OS.SendMessage (handle, OS.LVM_GETNEXTITEM, selection, OS.LVNI_SELECTED)) !is -1) {
                if (rect.bottom - rect.top > DRAG_IMAGE_SIZE) break;
                if (rect.bottom > clientRect.bottom) break;
                RECT itemRect = item.getBounds (cast(int)/*64bit*/selection, 0, true, true, true);
                auto rectRgn = OS.CreateRectRgn (rect.left, itemRect.top, rect.right, itemRect.bottom);
                OS.CombineRgn (hRgn, hRgn, rectRgn, OS.RGN_OR);
                OS.DeleteObject (rectRgn);
                rect.bottom = itemRect.bottom;
            }
            OS.GetRgnBox (hRgn, &rect);
            
            /* Create resources */
            auto hdc = OS.GetDC (handle);
            auto memHdc = OS.CreateCompatibleDC (hdc);
            BITMAPINFOHEADER bmiHeader;
            bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
            bmiHeader.biWidth = rect.right - rect.left;
            bmiHeader.biHeight = -(rect.bottom - rect.top);
            bmiHeader.biPlanes = 1;
            bmiHeader.biBitCount = 32;
            bmiHeader.biCompression = OS.BI_RGB;
            byte [] bmi = new byte [BITMAPINFOHEADER.sizeof];
            OS.MoveMemory (bmi.ptr, &bmiHeader, BITMAPINFOHEADER.sizeof);
            void*[1] pBits;
            auto memDib = OS.CreateDIBSection (null, cast(BITMAPINFO*) bmi.ptr, OS.DIB_RGB_COLORS, pBits.ptr, null, 0);
            if (memDib is null) SWT.error (SWT.ERROR_NO_HANDLES);
            auto oldMemBitmap = OS.SelectObject (memHdc, memDib);
            int colorKey = 0x0000FD;
            POINT pt;
            OS.SetWindowOrgEx (memHdc, rect.left, rect.top, &pt);
            OS.FillRect (memHdc, &rect, findBrush (colorKey, OS.BS_SOLID));
            OS.OffsetRgn (hRgn, -rect.left, -rect.top);
            OS.SelectClipRgn (memHdc, hRgn);
            OS.PrintWindow (handle, memHdc, 0);
            OS.SetWindowOrgEx (memHdc, pt.x, pt.y, null);
            OS.SelectObject (memHdc, oldMemBitmap);
            OS.DeleteDC (memHdc);
            OS.ReleaseDC (null, hdc);
            OS.DeleteObject (hRgn);
            
            SHDRAGIMAGE shdi;
            shdi.hbmpDragImage = memDib;
            shdi.crColorKey = colorKey;
            shdi.sizeDragImage.cx = bmiHeader.biWidth;
            shdi.sizeDragImage.cy = -bmiHeader.biHeight;
            shdi.ptOffset.x = mousePos.x - rect.left;
            shdi.ptOffset.y = mousePos.y - rect.top;
            if ((style & SWT.MIRRORED) !is 0) {
                shdi.ptOffset.x = shdi.sizeDragImage.cx - shdi.ptOffset.x; 
            }
            OS.MoveMemory (lParam, &shdi, SHDRAGIMAGE.sizeof);
            return 1;
        }
    }
    return super.windowProc (hwnd, msg, wParam, lParam);
}

override LRESULT WM_CHAR (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_CHAR (wParam, lParam);
    if (result !is null) return result;
    switch (wParam) {
        case ' ':
            if ((style & SWT.CHECK) !is 0) {
                int index = cast(int)/*64bit*/OS.SendMessage (handle, OS.LVM_GETNEXTITEM, -1, OS.LVNI_FOCUSED);
                if (index !is -1) {
                    TableItem item = _getItem (index);
                    item.setChecked (!item.getChecked (), true);
                    static if (!OS.IsWinCE) {
                        OS.NotifyWinEvent (OS.EVENT_OBJECT_FOCUS, handle, OS.OBJID_CLIENT, index + 1);
                    }
                }
            }
            /*
            * NOTE: Call the window proc with WM_KEYDOWN rather than WM_CHAR
            * so that the key that was ignored during WM_KEYDOWN is processed.
            * This allows the application to cancel an operation that is normally
            * performed in WM_KEYDOWN from WM_CHAR.
            */
            auto code = callWindowProc (handle, OS.WM_KEYDOWN, wParam, lParam);
            return new LRESULT (code);
        case SWT.CR:
            /*
            * Feature in Windows.  Windows sends LVN_ITEMACTIVATE from WM_KEYDOWN
            * instead of WM_CHAR.  This means that application code that expects
            * to consume the key press and therefore avoid a SWT.DefaultSelection
            * event will fail.  The fix is to ignore LVN_ITEMACTIVATE when it is
            * caused by WM_KEYDOWN and send SWT.DefaultSelection from WM_CHAR.
            */
            auto index = OS.SendMessage (handle, OS.LVM_GETNEXTITEM, -1, OS.LVNI_FOCUSED);
            if (index !is -1) {
                Event event = new Event ();
                event.item = _getItem (cast(int)/*64bit*/index);
                postEvent (SWT.DefaultSelection, event);
            }
            return LRESULT.ZERO;
        default:
    }
    return result;
}

override LRESULT WM_CONTEXTMENU (WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  For some reason, when the right
    * mouse button is pressed over an item, Windows sends
    * a WM_CONTEXTMENU from WM_RBUTTONDOWN, instead of from
    * WM_RBUTTONUP.  This causes two context menus requests
    * to be sent.  The fix is to ignore WM_CONTEXTMENU on
    * mouse down.
    *
    * NOTE: This only happens when dragging is disabled.
    * When the table is detecting drag, the WM_CONTEXTMENU
    * is not sent WM_RBUTTONUP.
    */
    if (!display.runDragDrop) return LRESULT.ZERO;
    return super.WM_CONTEXTMENU (wParam, lParam);
}

override LRESULT WM_ERASEBKGND (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_ERASEBKGND (wParam, lParam);
    if (findImageControl () !is null) return LRESULT.ONE;
    if (OS.COMCTL32_MAJOR < 6) {
        if ((style & SWT.DOUBLE_BUFFERED) !is 0) {
            auto bits = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
            if ((bits & OS.LVS_EX_DOUBLEBUFFER) is 0) return LRESULT.ONE;
        }
    }
    return result;
}

override LRESULT WM_GETOBJECT (WPARAM wParam, LPARAM lParam) {
    /*
    * Ensure that there is an accessible object created for this
    * control because support for checked item accessibility is
    * temporarily implemented in the accessibility package.
    */
    if ((style & SWT.CHECK) !is 0) {
        if (accessible is null) accessible = new_Accessible (this);
    }
    return super.WM_GETOBJECT (wParam, lParam);
}

override LRESULT WM_KEYDOWN (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_KEYDOWN (wParam, lParam);
    if (result !is null) return result;
    switch (wParam) {
        case OS.VK_SPACE:
            /*
            * Ensure that the window proc does not process VK_SPACE
            * so that it can be handled in WM_CHAR.  This allows the
            * application to cancel an operation that is normally
            * performed in WM_KEYDOWN from WM_CHAR.
            */
            return LRESULT.ZERO;
        case OS.VK_ADD:
            if (OS.GetKeyState (OS.VK_CONTROL) < 0) {
                int index = 0;
                while (index < columnCount) {
                    if (!columns [index].getResizable ()) break;
                    index++;
                }
                if (index !is columnCount || hooks (SWT.MeasureItem)) {
                    TableColumn [] newColumns = new TableColumn [columnCount];
                    System.arraycopy (columns, 0, newColumns, 0, columnCount);
                    for (int i=0; i<newColumns.length; i++) {
                        TableColumn column = newColumns [i];
                        if (!column.isDisposed () && column.getResizable ()) {
                            column.pack ();
                        }
                    }
                    return LRESULT.ZERO;
                }
            }
            break;
        case OS.VK_PRIOR:
        case OS.VK_NEXT:
        case OS.VK_HOME:
        case OS.VK_END:
            /*
            * When there are many columns in a table, scrolling performance
            * can be improved by temporarily unsubclassing the window proc
            * so that internal messages are dispatched directly to the table.
            * If the application expects to see a paint event, the window
            * proc cannot be unsubclassed or the event will not be seen.
            *
            * NOTE: The header tooltip can subclass the header proc so the
            * current proc must be restored or header tooltips stop working.
            */
            ptrdiff_t oldHeaderProc = 0, oldTableProc = 0;
            auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
            bool fixSubclass = isOptimizedRedraw ();
            if (fixSubclass) {
                oldTableProc = OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)TableProc);
                oldHeaderProc = OS.SetWindowLongPtr (hwndHeader, OS.GWLP_WNDPROC, cast(LONG_PTR)HeaderProc);
            }
            auto code = callWindowProc (handle, OS.WM_KEYDOWN, wParam, lParam);
            result = code is 0 ? LRESULT.ZERO : new LRESULT (code);
            if (fixSubclass) {
                OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, oldTableProc);
                OS.SetWindowLongPtr (hwndHeader, OS.GWLP_WNDPROC, oldHeaderProc);
            }
            goto case OS.VK_UP;
        case OS.VK_UP:
        case OS.VK_DOWN:
            OS.SendMessage (handle, OS.WM_CHANGEUISTATE, OS.UIS_INITIALIZE, 0);
            break;
        default:
    }
    return result;
}

override LRESULT WM_KILLFOCUS (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_KILLFOCUS (wParam, lParam);
    /*
    * Bug in Windows.  When focus is lost, Windows does not
    * redraw the selection properly, leaving the image and
    * check box appearing selected.  The fix is to redraw
    * the table.
    */
    if (imageList !is null || (style & SWT.CHECK) !is 0) {
        OS.InvalidateRect (handle, null, false);
    }
    return result;
}

override LRESULT WM_LBUTTONDBLCLK (WPARAM wParam, LPARAM lParam) {

    /*
    * Feature in Windows.  When the user selects outside of
    * a table item, Windows deselects all the items, even
    * when the table is multi-select.  While not strictly
    * wrong, this is unexpected.  The fix is to detect the
    * case and avoid calling the window proc.
    */
    LVHITTESTINFO pinfo;
    pinfo.pt.x = OS.GET_X_LPARAM (lParam);
    pinfo.pt.y = OS.GET_Y_LPARAM (lParam);
    int index = cast(int)/*64bit*/OS.SendMessage (handle, OS.LVM_HITTEST, 0, &pinfo);
    Display display = this.display;
    display.captureChanged = false;
    sendMouseEvent (SWT.MouseDown, 1, handle, OS.WM_LBUTTONDOWN, wParam, lParam);
    if (!sendMouseEvent (SWT.MouseDoubleClick, 1, handle, OS.WM_LBUTTONDBLCLK, wParam, lParam)) {
        if (!display.captureChanged && !isDisposed ()) {
            if (OS.GetCapture () !is handle) OS.SetCapture (handle);
        }
        return LRESULT.ZERO;
    }
    if (pinfo.iItem !is -1) callWindowProc (handle, OS.WM_LBUTTONDBLCLK, wParam, lParam);
    if (!display.captureChanged && !isDisposed ()) {
        if (OS.GetCapture () !is handle) OS.SetCapture (handle);
    }

    /* Look for check/uncheck */
    if ((style & SWT.CHECK) !is 0) {
        /*
        * Note that when the table has LVS_EX_FULLROWSELECT and the
        * user clicks anywhere on a row except on the check box, all
        * of the bits are set.  The hit test flags are LVHT_ONITEM.
        * This means that a bit test for LVHT_ONITEMSTATEICON is not
        * the correct way to determine that the user has selected
        * the check box, equality is needed.
        */
        if (index !is -1 && pinfo.flags is OS.LVHT_ONITEMSTATEICON) {
            TableItem item = _getItem (index);
            item.setChecked (!item.getChecked (), true);
            static if (!OS.IsWinCE) {
                OS.NotifyWinEvent (OS.EVENT_OBJECT_FOCUS, handle, OS.OBJID_CLIENT, index + 1);
            }
        }
    }
    return LRESULT.ZERO;
}

override LRESULT WM_LBUTTONDOWN (WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  For some reason, capturing
    * the mouse after processing the mouse event for the
    * widget interferes with the normal mouse processing
    * for the widget.  The fix is to avoid the automatic
    * mouse capture.
    */
    LRESULT result = sendMouseDownEvent (SWT.MouseDown, 1, OS.WM_LBUTTONDOWN, wParam, lParam);
    if (result is LRESULT.ZERO) return result;

    /* Look for check/uncheck */
    if ((style & SWT.CHECK) !is 0) {
        LVHITTESTINFO pinfo;
        pinfo.pt.x = OS.GET_X_LPARAM (lParam);
        pinfo.pt.y = OS.GET_Y_LPARAM (lParam);
        /*
        * Note that when the table has LVS_EX_FULLROWSELECT and the
        * user clicks anywhere on a row except on the check box, all
        * of the bits are set.  The hit test flags are LVHT_ONITEM.
        * This means that a bit test for LVHT_ONITEMSTATEICON is not
        * the correct way to determine that the user has selected
        * the check box, equality is needed.
        */
        int index = cast(int)/*64bit*/OS.SendMessage (handle, OS.LVM_HITTEST, 0, &pinfo);
        if (index !is -1 && pinfo.flags is OS.LVHT_ONITEMSTATEICON) {
            TableItem item = _getItem (index);
            item.setChecked (!item.getChecked (), true);
            static if (!OS.IsWinCE) {
                OS.NotifyWinEvent (OS.EVENT_OBJECT_FOCUS, handle, OS.OBJID_CLIENT, index + 1);
            }
        }
    }
    return result;
}

override LRESULT WM_MOUSEHOVER (WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  Despite the fact that hot
    * tracking is not enabled, the hot tracking code
    * in WM_MOUSEHOVER is executed causing the item
    * under the cursor to be selected.  The fix is to
    * avoid calling the window proc.
    */
    LRESULT result = super.WM_MOUSEHOVER (wParam, lParam);
    auto bits = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
    int mask = OS.LVS_EX_ONECLICKACTIVATE | OS.LVS_EX_TRACKSELECT | OS.LVS_EX_TWOCLICKACTIVATE;
    if ((bits & mask) !is 0) return result;
    return LRESULT.ZERO;
}

override LRESULT WM_PAINT (WPARAM wParam, LPARAM lParam) {
    if (!ignoreShrink) {
        /* Resize the item array to match the item count */
        auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
        if (items.length > 4 && items.length - count > 3) {
            auto length = Math.max (4, (count + 3) / 4 * 4);
            TableItem [] newItems = new TableItem [length];
            System.arraycopy (items, 0, newItems, 0, count);
            items = newItems;
        }
    }
    if (fixScrollWidth) setScrollWidth (null, true);
    if (OS.COMCTL32_MAJOR < 6) {
        if ((style & SWT.DOUBLE_BUFFERED) !is 0 || findImageControl () !is null) {
            auto bits = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
            if ((bits & OS.LVS_EX_DOUBLEBUFFER) is 0) {
                GC gc = null;
                HDC paintDC;
                PAINTSTRUCT ps;
                bool hooksPaint = hooks (SWT.Paint);
                if (hooksPaint) {
                    GCData data = new GCData ();
                    data.ps = &ps;
                    data.hwnd = handle;
                    gc = GC.win32_new (this, data);
                    paintDC = gc.handle;
                } else {
                    paintDC = OS.BeginPaint (handle, &ps);
                }
                int width = ps.rcPaint.right - ps.rcPaint.left;
                int height = ps.rcPaint.bottom - ps.rcPaint.top;
                if (width !is 0 && height !is 0) {
                    auto hDC = OS.CreateCompatibleDC (paintDC);
                    POINT lpPoint1, lpPoint2;
                    OS.SetWindowOrgEx (hDC, ps.rcPaint.left, ps.rcPaint.top, &lpPoint1);
                    OS.SetBrushOrgEx (hDC, ps.rcPaint.left, ps.rcPaint.top, &lpPoint2);
                    auto hBitmap = OS.CreateCompatibleBitmap (paintDC, width, height);
                    auto hOldBitmap = OS.SelectObject (hDC, hBitmap);
                    if (OS.SendMessage (handle, OS.LVM_GETBKCOLOR, 0, 0) !is OS.CLR_NONE) {
                        RECT rect;
                        OS.SetRect (&rect, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right, ps.rcPaint.bottom);
                        drawBackground (hDC, &rect);
                    }
                    callWindowProc (handle, OS.WM_PAINT, cast(ptrdiff_t)hDC, 0);
                    OS.SetWindowOrgEx (hDC, lpPoint1.x, lpPoint1.y, null);
                    OS.SetBrushOrgEx (hDC, lpPoint2.x, lpPoint2.y, null);
                    OS.BitBlt (paintDC, ps.rcPaint.left, ps.rcPaint.top, width, height, hDC, 0, 0, OS.SRCCOPY);
                    OS.SelectObject (hDC, hOldBitmap);
                    OS.DeleteObject (hBitmap);
                    OS.DeleteObject (hDC);
                    if (hooksPaint) {
                        Event event = new Event ();
                        event.gc = gc;
                        event.x = ps.rcPaint.left;
                        event.y = ps.rcPaint.top;
                        event.width = ps.rcPaint.right - ps.rcPaint.left;
                        event.height = ps.rcPaint.bottom - ps.rcPaint.top;
                        sendEvent (SWT.Paint, event);
                        // widget could be disposed at this point
                        event.gc = null;
                    }
                }
                if (hooksPaint) {
                    gc.dispose ();
                } else {
                    OS.EndPaint (handle, &ps);
                }
                return LRESULT.ZERO;
            }
        }
    }
    return super.WM_PAINT (wParam, lParam);
}

override LRESULT WM_RBUTTONDBLCLK (WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  When the user selects outside of
    * a table item, Windows deselects all the items, even
    * when the table is multi-select.  While not strictly
    * wrong, this is unexpected.  The fix is to detect the
    * case and avoid calling the window proc.
    */
    LVHITTESTINFO pinfo;
    pinfo.pt.x = OS.GET_X_LPARAM (lParam);
    pinfo.pt.y = OS.GET_Y_LPARAM (lParam);
    OS.SendMessage (handle, OS.LVM_HITTEST, 0, &pinfo);
    Display display = this.display;
    display.captureChanged = false;
    sendMouseEvent (SWT.MouseDown, 3, handle, OS.WM_RBUTTONDOWN, wParam, lParam);
    if (sendMouseEvent (SWT.MouseDoubleClick, 3, handle, OS.WM_RBUTTONDBLCLK, wParam, lParam)) {
        if (pinfo.iItem !is -1) callWindowProc (handle, OS.WM_RBUTTONDBLCLK, wParam, lParam);
    }
    if (!display.captureChanged && !isDisposed ()) {
        if (OS.GetCapture () !is handle) OS.SetCapture (handle);
    }
    return LRESULT.ZERO;
}

override LRESULT WM_RBUTTONDOWN (WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  For some reason, capturing
    * the mouse after processing the mouse event for the
    * widget interferes with the normal mouse processing
    * for the widget.  The fix is to avoid the automatic
    * mouse capture.
    */
    return sendMouseDownEvent (SWT.MouseDown, 3, OS.WM_RBUTTONDOWN, wParam, lParam);
}

override LRESULT WM_SETFOCUS (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SETFOCUS (wParam, lParam);
    /*
    * Bug in Windows.  When focus is gained after the
    * selection has been changed using LVM_SETITEMSTATE,
    * Windows redraws the selected text but does not
    * redraw the image or the check box, leaving them
    * appearing unselected.  The fix is to redraw
    * the table.
    */
    if (imageList !is null || (style & SWT.CHECK) !is 0) {
        OS.InvalidateRect (handle, null, false);
    }

    /*
    * Bug in Windows.  For some reason, the table does
    * not set the default focus rectangle to be the first
    * item in the table when it gets focus and there is
    * no selected item.  The fix to make the first item
    * be the focus item.
    */
    auto count = OS.SendMessage (handle, OS.LVM_GETITEMCOUNT, 0, 0);
    if (count is 0) return result;
    auto index = OS.SendMessage (handle, OS.LVM_GETNEXTITEM, -1, OS.LVNI_FOCUSED);
    if (index is -1) {
        LVITEM lvItem;
        lvItem.state = OS.LVIS_FOCUSED;
        lvItem.stateMask = OS.LVIS_FOCUSED;
        ignoreSelect = true;
        OS.SendMessage (handle, OS.LVM_SETITEMSTATE, 0, &lvItem);
        ignoreSelect = false;
    }
    return result;
}

override LRESULT WM_SETFONT (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SETFONT (wParam, lParam);
    if (result !is null) return result;

    /*
    * Bug in Windows.  When a header has a sort indicator
    * triangle, Windows resizes the indicator based on the
    * size of the n-1th font.  The fix is to always make
    * the n-1th font be the default.  This makes the sort
    * indicator always be the default size.
    *
    * NOTE: The table window proc sets the actual font in
    * the header so that all that is necessary here is to
    * set the default first.
    */
    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    OS.SendMessage (hwndHeader, OS.WM_SETFONT, 0, lParam);

    if (headerToolTipHandle !is null) {
        OS.SendMessage (headerToolTipHandle, OS.WM_SETFONT, wParam, lParam);
    }
    return result;
}

override LRESULT WM_SETREDRAW (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SETREDRAW (wParam, lParam);
    if (result !is null) return result;
    /*
    * Feature in Windows.  When LVM_SETBKCOLOR is used with CLR_NONE
    * to make the background of the table transparent, drawing becomes
    * slow.  The fix is to temporarily clear CLR_NONE when redraw is
    * turned off.
    */
    if (wParam is 1) {
        if (OS.SendMessage (handle, OS.LVM_GETBKCOLOR, 0, 0) !is OS.CLR_NONE) {
            if (hooks (SWT.MeasureItem) || hooks (SWT.EraseItem) || hooks (SWT.PaintItem)) {
                OS.SendMessage (handle, OS.LVM_SETBKCOLOR, 0, OS.CLR_NONE);
            }
        }
    }
    auto code = callWindowProc (handle, OS.WM_SETREDRAW, wParam, lParam);
    if (wParam is 0) {
        if (OS.SendMessage (handle, OS.LVM_GETBKCOLOR, 0, 0) is OS.CLR_NONE) {
            OS.SendMessage (handle, OS.LVM_SETBKCOLOR, 0, 0xFFFFFF);
        }
    }
    return code is 0 ? LRESULT.ZERO : new LRESULT (code);
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    if (ignoreResize) return null;
    if (hooks (SWT.EraseItem) || hooks (SWT.PaintItem)) {
        OS.InvalidateRect (handle, null, true);
    }
    if (resizeCount !is 0) {
        wasResized = true;
        return null;
    }
    return super.WM_SIZE (wParam, lParam);
}

override LRESULT WM_SYSCOLORCHANGE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SYSCOLORCHANGE (wParam, lParam);
    if (result !is null) return result;
    if (findBackgroundControl () is null) {
        setBackgroundPixel (defaultBackground ());
    } else {
        auto oldPixel = OS.SendMessage (handle, OS.LVM_GETBKCOLOR, 0, 0);
        if (oldPixel !is OS.CLR_NONE) {
            if (findImageControl () is null) {
                if ((style & SWT.CHECK) !is 0) fixCheckboxImageListColor (true);
            }
        }
    }
    return result;
}

override LRESULT WM_HSCROLL (WPARAM wParam, LPARAM lParam) {
    /*
    * Bug in Windows.  When a table that is drawing grid lines
    * is slowly scrolled horizontally to the left, the table does
    * not redraw the newly exposed vertical grid lines.  The fix
    * is to save the old scroll position, call the window proc,
    * get the new scroll position and redraw the new area.
    */
    int oldPos = 0;
    auto bits = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
    if ((bits & OS.LVS_EX_GRIDLINES) !is 0) {
        SCROLLINFO info;
        info.cbSize = SCROLLINFO.sizeof;
        info.fMask = OS.SIF_POS;
        OS.GetScrollInfo (handle, OS.SB_HORZ, &info);
        oldPos = info.nPos;
    }

    /*
    * Feature in Windows.  When there are many columns in a table,
    * scrolling performance can be improved by unsubclassing the
    * window proc so that internal messages are dispatched directly
    * to the table.  If the application expects to see a paint event
    * or has a child whose font, foreground or background color might
    * be needed, the window proc cannot be unsubclassed
    *
    * NOTE: The header tooltip can subclass the header proc so the
    * current proc must be restored or header tooltips stop working.
    */
    WNDPROC oldHeaderProc, oldTableProc;
    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    bool fixSubclass = isOptimizedRedraw ();
    if (fixSubclass) {
        oldTableProc = cast(WNDPROC)OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)TableProc);
        oldHeaderProc = cast(WNDPROC)OS.SetWindowLongPtr (hwndHeader, OS.GWLP_WNDPROC, cast(LONG_PTR)HeaderProc);
    }

    /*
    * Feature in Windows.  For some reason, when the table window
    * proc processes WM_HSCROLL or WM_VSCROLL when there are many
    * columns in the table, scrolling is slow and the table does
    * not keep up with the position of the scroll bar.  The fix
    * is to turn off redraw, scroll, turn redraw back on and redraw
    * the entire table.  Strangly, redrawing the entire table is
    * faster.
    */
    bool fixScroll = false;
    if (OS.LOWORD (wParam) !is OS.SB_ENDSCROLL) {
        if (OS.COMCTL32_MAJOR >= 6) {
            if (columnCount > H_SCROLL_LIMIT) {
                auto rowCount = OS.SendMessage (handle, OS.LVM_GETCOUNTPERPAGE, 0, 0);
                if (rowCount > V_SCROLL_LIMIT) fixScroll = drawCount is 0 && OS.IsWindowVisible (handle);
            }
        }
    }
    if (fixScroll) OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
    LRESULT result = super.WM_HSCROLL (wParam, lParam);
    if (fixScroll) {
        OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
        int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE | OS.RDW_ALLCHILDREN;
        OS.RedrawWindow (handle, null, null, flags);
        /*
        * Feature in Windows.  On Vista only, it is faster to
        * compute and answer the data for the visible columns
        * of a table when scrolling, rather than just return
        * the data for each column when asked.
        */
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
            RECT headerRect, rect;
            OS.GetClientRect (handle, &rect);
            bool [] visible = new bool [columnCount];
            for (int i=0; i<columnCount; i++) {
                visible [i] = true;
                if (OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, i, &headerRect) !is 0) {
                    OS.MapWindowPoints (hwndHeader, handle, cast(POINT*)&headerRect, 2);
                    visible [i] = OS.IntersectRect(&headerRect, &rect, &headerRect) !is 0;
                }
            }
            try {
                display.hwndParent = OS.GetParent (handle);
                display.columnVisible = visible;
                OS.UpdateWindow (handle);
            } finally {
                display.columnVisible = null;
            }
        }
    }

    if (fixSubclass) {
        OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)oldTableProc);
        OS.SetWindowLongPtr (hwndHeader, OS.GWLP_WNDPROC, cast(LONG_PTR)oldHeaderProc);
    }

    /*
    * Bug in Windows.  When a table that is drawing grid lines
    * is slowly scrolled horizontally to the left, the table does
    * not redraw the newly exposed vertical grid lines.  The fix
    * is to save the old scroll position, call the window proc,
    * get the new scroll position and redraw the new area.
    */
    if ((bits & OS.LVS_EX_GRIDLINES) !is 0) {
        SCROLLINFO info;
        info.cbSize = SCROLLINFO.sizeof;
        info.fMask = OS.SIF_POS;
        OS.GetScrollInfo (handle, OS.SB_HORZ, &info);
        int newPos = info.nPos;
        if (newPos < oldPos) {
            RECT rect;
            OS.GetClientRect (handle, &rect);
            rect.right = oldPos - newPos + GRID_WIDTH;
            OS.InvalidateRect (handle, &rect, true);
        }
    }
    return result;
}

override LRESULT WM_VSCROLL (WPARAM wParam, LPARAM lParam) {
    /*
    * When there are many columns in a table, scrolling performance
    * can be improved by temporarily unsubclassing the window proc
    * so that internal messages are dispatched directly to the table.
    * If the application expects to see a paint event or has a child
    * whose font, foreground or background color might be needed,
    * the window proc cannot be unsubclassed.
    *
    * NOTE: The header tooltip can subclass the header proc so the
    * current proc must be restored or header tooltips stop working.
    */
    WNDPROC oldHeaderProc, oldTableProc;
    auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    bool fixSubclass = isOptimizedRedraw ();
    if (fixSubclass) {
        oldTableProc = cast(WNDPROC)OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)TableProc);
        oldHeaderProc = cast(WNDPROC)OS.SetWindowLongPtr (hwndHeader, OS.GWLP_WNDPROC, cast(LONG_PTR)HeaderProc);
    }

    /*
    * Feature in Windows.  For some reason, when the table window
    * proc processes WM_HSCROLL or WM_VSCROLL when there are many
    * columns in the table, scrolling is slow and the table does
    * not keep up with the position of the scroll bar.  The fix
    * is to turn off redraw, scroll, turn redraw back on and redraw
    * the entire table.  Strangly, redrawing the entire table is
    * faster.
    */
    bool fixScroll = false;
    if (OS.LOWORD (wParam) !is OS.SB_ENDSCROLL) {
        if (OS.COMCTL32_MAJOR >= 6) {
            if (columnCount > H_SCROLL_LIMIT) {
                auto rowCount = OS.SendMessage (handle, OS.LVM_GETCOUNTPERPAGE, 0, 0);
                if (rowCount > V_SCROLL_LIMIT) fixScroll = drawCount is 0 && OS.IsWindowVisible (handle);
            }
        }
    }
    if (fixScroll) OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
    LRESULT result = super.WM_VSCROLL (wParam, lParam);
    if (fixScroll) {
        OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
        int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE | OS.RDW_ALLCHILDREN;
        OS.RedrawWindow (handle, null, null, flags);
        /*
        * Feature in Windows.  On Vista only, it is faster to
        * compute and answer the data for the visible columns
        * of a table when scrolling, rather than just return
        * the data for each column when asked.
        */
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
            RECT headerRect, rect;
            OS.GetClientRect (handle, &rect);
            bool [] visible = new bool [columnCount];
            for (int i=0; i<columnCount; i++) {
                visible [i] = true;
                if (OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, i, &headerRect) !is 0) {
                    OS.MapWindowPoints (hwndHeader, handle, cast(POINT*)&headerRect, 2);
                    visible [i] = OS.IntersectRect(&headerRect, &rect, &headerRect) !is 0;
                }
            }
            try {
                display.hwndParent = OS.GetParent (handle);
                display.columnVisible = visible;
                OS.UpdateWindow (handle);
            } finally {
                display.columnVisible = null;
            }
        }
    }

    if (fixSubclass) {
        OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)oldTableProc);
        OS.SetWindowLongPtr (hwndHeader, OS.GWLP_WNDPROC, cast(LONG_PTR)oldHeaderProc);
    }

    /*
    * Bug in Windows.  When a table is drawing grid lines and the
    * user scrolls vertically up or down by a line or a page, the
    * table does not redraw the grid lines for newly exposed items.
    * The fix is to invalidate the items.
    */
    auto bits = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
    if ((bits & OS.LVS_EX_GRIDLINES) !is 0) {
        int code = OS.LOWORD (wParam);
        switch (code) {
            case OS.SB_ENDSCROLL:
            case OS.SB_THUMBPOSITION:
            case OS.SB_THUMBTRACK:
            case OS.SB_TOP:
            case OS.SB_BOTTOM:
                break;
            case OS.SB_LINEDOWN:
            case OS.SB_LINEUP:
                RECT rect;
                OS.GetWindowRect (hwndHeader, &rect);
                int headerHeight = rect.bottom - rect.top;
                RECT clientRect;
                OS.GetClientRect (handle, &clientRect);
                clientRect.top += headerHeight;
                auto empty = OS.SendMessage (handle, OS.LVM_APPROXIMATEVIEWRECT, 0, 0);
                auto oneItem = OS.SendMessage (handle, OS.LVM_APPROXIMATEVIEWRECT, 1, 0);
                int itemHeight = OS.HIWORD (oneItem) - OS.HIWORD (empty);
                if (code is OS.SB_LINEDOWN) {
                    clientRect.top = clientRect.bottom - itemHeight - GRID_WIDTH;
                } else {
                    clientRect.bottom = clientRect.top + itemHeight + GRID_WIDTH;
                }
                OS.InvalidateRect (handle, &clientRect, true);
                break;
            case OS.SB_PAGEDOWN:
            case OS.SB_PAGEUP:
                OS.InvalidateRect (handle, null, true);
                break;
            default:
        }
    }
    return result;
}

override LRESULT wmMeasureChild (WPARAM wParam, LPARAM lParam) {
    MEASUREITEMSTRUCT* struct_ = cast(MEASUREITEMSTRUCT*)lParam;
    //OS.MoveMemory (struct_, lParam, MEASUREITEMSTRUCT.sizeof);
    if (itemHeight is -1) {
        auto empty = OS.SendMessage (handle, OS.LVM_APPROXIMATEVIEWRECT, 0, 0);
        auto oneItem = OS.SendMessage (handle, OS.LVM_APPROXIMATEVIEWRECT, 1, 0);
        struct_.itemHeight = OS.HIWORD (oneItem) - OS.HIWORD (empty);
    } else {
        struct_.itemHeight = itemHeight;
    }
    //OS.MoveMemory (lParam, struct_, MEASUREITEMSTRUCT.sizeof);
    return null;
}

override LRESULT wmNotify (NMHDR* hdr, WPARAM wParam, LPARAM lParam) {
    HWND hwndToolTip = cast(HWND) OS.SendMessage (handle, OS.LVM_GETTOOLTIPS, 0, 0);
    if (hdr.hwndFrom is hwndToolTip) {
        LRESULT result = wmNotifyToolTip (hdr, wParam, lParam);
        if (result !is null) return result;
    }
    HWND hwndHeader = cast(HWND)OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
    if (hdr.hwndFrom is hwndHeader) {
        LRESULT result = wmNotifyHeader (hdr, wParam, lParam);
        if (result !is null) return result;
    }
    return super.wmNotify (hdr, wParam, lParam);
}

override LRESULT wmNotifyChild (NMHDR* hdr, WPARAM wParam, LPARAM lParam) {
    switch (hdr.code) {
        case OS.LVN_ODFINDITEMA:
        case OS.LVN_ODFINDITEMW: {
            if ((style & SWT.VIRTUAL) !is 0) return new LRESULT (-1);
            break;
        }
        case OS.LVN_ODSTATECHANGED: {
            if ((style & SWT.VIRTUAL) !is 0) {
                if (!ignoreSelect) {
                    NMLVODSTATECHANGE* lpStateChange  = cast(NMLVODSTATECHANGE*)lParam;
                    //OS.MoveMemory (lpStateChange, lParam, NMLVODSTATECHANGE.sizeof);
                    bool oldSelected = (lpStateChange.uOldState & OS.LVIS_SELECTED) !is 0;
                    bool newSelected = (lpStateChange.uNewState & OS.LVIS_SELECTED) !is 0;
                    if (oldSelected !is newSelected) wasSelected = true;
                }
            }
            break;
        }
        case OS.LVN_GETDISPINFOA:
        case OS.LVN_GETDISPINFOW: {
//          if (drawCount !is 0 || !OS.IsWindowVisible (handle)) break;
            NMLVDISPINFO* plvfi = cast(NMLVDISPINFO*)lParam;
            //OS.MoveMemory (plvfi, lParam, OS.NMLVDISPINFO_sizeof);

            bool [] visible = display.columnVisible;
            if (visible !is null && !visible [plvfi.item.iSubItem]) {
                break;
            }

            /*
            * When an item is being deleted from a virtual table, do not
            * allow the application to provide data for a new item that
            * becomes visible until the item has been removed from the
            * items array.  Because arbitrary application code can run
            * during the callback, the items array might be accessed
            * in an inconsistent state.  Rather than answering the data
            * right away, queue a redraw for later.
            */
            if ((style & SWT.VIRTUAL) !is 0) {
                if (ignoreShrink) {
                    OS.SendMessage (handle, OS.LVM_REDRAWITEMS, plvfi.item.iItem, plvfi.item.iItem);
                    break;
                }
            }

            /*
            * Feature in Windows.  When a new table item is inserted
            * using LVM_INSERTITEM in a table that is transparent
            * (ie. LVM_SETBKCOLOR has been called with CLR_NONE),
            * TVM_INSERTITEM calls LVN_GETDISPINFO before the item
            * has been added to the array.  The fix is to check for
            * null.
            */
            TableItem item = _getItem (plvfi.item.iItem);
            if (item is null) break;

            /*
            * The cached flag is used by both virtual and non-virtual
            * tables to indicate that Windows has asked at least once
            * for a table item.
            */
            if (!item.cached) {
                if ((style & SWT.VIRTUAL) !is 0) {
                    lastIndexOf = plvfi.item.iItem;
                    if (!checkData (item, lastIndexOf, false)) break;
                    TableItem newItem = fixScrollWidth ? null : item;
                    if (setScrollWidth (newItem, true)) {
                        OS.InvalidateRect (handle, null, true);
                    }
                }
                item.cached = true;
            }
            if ((plvfi.item.mask & OS.LVIF_TEXT) !is 0) {
                String string = null;
                if (plvfi.item.iSubItem is 0) {
                    string = item.text;
                } else {
                    String [] strings  = item.strings;
                    if (strings !is null) string = strings [plvfi.item.iSubItem];
                }
                if (string !is null) {
                    /*
                    * Bug in Windows.  When pszText points to a zero length
                    * NULL terminated string, Windows correctly draws the
                    * empty string but the cache of the bounds for the item
                    * is not reset.  This means that when the text for the
                    * item is set and then reset to an empty string, the
                    * selection draws using the bounds of the previous text.
                    * The fix is to use a space rather than an empty string
                    * when anything but a tool tip is requested (to avoid
                    * a tool tip that is a single space).
                    *
                    * NOTE: This is only a problem for items in the first
                    * column.  Assigning NULL to other columns stops Windows
                    * from drawing the selection when LVS_EX_FULLROWSELECT
                    * is set.
                    */
                    ptrdiff_t length_ = Math.min (string.length, plvfi.item.cchTextMax - 1);
                    if (!tipRequested && plvfi.item.iSubItem is 0 && length_ is 0) {
                        string = " "; //$NON-NLS-1$
                        length_ = 1;
                    }
                    char [] buffer = display.tableBuffer;
                    if (buffer is null || plvfi.item.cchTextMax > buffer.length) {
                        buffer = display.tableBuffer = new char [plvfi.item.cchTextMax];
                    }
                    /* Prevents becoming an invalid multibyte string. */
                    adjustUTF8index ( string, length_ );
                    string.getChars (0, cast(int)/*64bit*/length_, buffer, 0);
                    buffer [length_++] = 0;
                    static if (OS.IsUnicode) {
                        auto tcharz = StrToTCHARz( buffer[0..length_] );
                        OS.MoveMemory (plvfi.item.pszText, tcharz, (TCHARzLen(tcharz) + 1) * 2);
                    } else {
                        OS.WideCharToMultiByte (getCodePage (), 0, buffer.ptr, length_, plvfi.item.pszText, plvfi.item.cchTextMax, null, null);
                        byte dummy;
                        OS.MoveMemory (plvfi.item.pszText + plvfi.item.cchTextMax - 1, &dummy, 1);
                    }
                }
            }
            bool move = false;
            if ((plvfi.item.mask & OS.LVIF_IMAGE) !is 0) {
                Image image = null;
                if (plvfi.item.iSubItem is 0) {
                    image = item.image;
                } else {
                    Image [] images = item.images;
                    if (images !is null) image = images [plvfi.item.iSubItem];
                }
                if (image !is null) {
                    plvfi.item.iImage = imageIndex (image, plvfi.item.iSubItem);
                    move = true;
                }
            }
            if ((plvfi.item.mask & OS.LVIF_STATE) !is 0) {
                if (plvfi.item.iSubItem is 0) {
                    int state = 1;
                    if (item.checked) state++;
                    if (item.grayed) state +=2;
                    plvfi.item.state = state << 12;
                    plvfi.item.stateMask = OS.LVIS_STATEIMAGEMASK;
                    move = true;
                }
            }
            if ((plvfi.item.mask & OS.LVIF_INDENT) !is 0) {
                if (plvfi.item.iSubItem is 0) {
                    plvfi.item.iIndent = item.imageIndent;
                    move = true;
                }
            }
            //if (move) OS.MoveMemory (lParam, plvfi, OS.NMLVDISPINFO_sizeof);
            break;
        }
        case OS.NM_CUSTOMDRAW: {
            auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
            if (hdr.hwndFrom is hwndHeader) break;
            if (!customDraw && findImageControl () is null) {
                /*
                * Feature in Windows.  When the table is disabled, it draws
                * with a gray background but does not gray the text.  The fix
                * is to explicitly gray the text using Custom Draw.
                */
                if (OS.IsWindowEnabled (handle)) {
                    /*
                    * Feature in Windows.  On Vista using the explorer theme,
                    * Windows draws a vertical line to separate columns.  When
                    * there is only a single column, the line looks strange.
                    * The fix is to draw the background using custom draw.
                    */
                    if (!explorerTheme || columnCount !is 0) break;
                }
            }
            NMLVCUSTOMDRAW* nmcd = cast(NMLVCUSTOMDRAW*)lParam;
            //OS.MoveMemory (nmcd, lParam, OS.NMLVCUSTOMDRAW_sizeof);
            switch (nmcd.nmcd.dwDrawStage) {
                case OS.CDDS_PREPAINT: return CDDS_PREPAINT (nmcd, wParam, lParam);
                case OS.CDDS_ITEMPREPAINT: return CDDS_ITEMPREPAINT (nmcd, wParam, lParam);
                case OS.CDDS_ITEMPOSTPAINT: return CDDS_ITEMPOSTPAINT (nmcd, wParam, lParam);
                case OS.CDDS_SUBITEMPREPAINT: return CDDS_SUBITEMPREPAINT (nmcd, wParam, lParam);
                case OS.CDDS_SUBITEMPOSTPAINT: return CDDS_SUBITEMPOSTPAINT (nmcd, wParam, lParam);
                case OS.CDDS_POSTPAINT: return CDDS_POSTPAINT (nmcd, wParam, lParam);
                default:
            }
            break;
        }
        case OS.LVN_MARQUEEBEGIN: {
            if ((style & SWT.SINGLE) !is 0) return LRESULT.ONE;
            if (hooks (SWT.MouseDown) || hooks (SWT.MouseUp)) {
                return LRESULT.ONE;
            }
            if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
                if (findImageControl () !is null) return LRESULT.ONE;
            }
            break;
        }
        case OS.LVN_BEGINDRAG:
        case OS.LVN_BEGINRDRAG: {
            if (OS.GetKeyState (OS.VK_LBUTTON) >= 0) break;
            dragStarted = true;
            if (hdr.code is OS.LVN_BEGINDRAG) {
                int pos = OS.GetMessagePos ();
                POINT pt;
                OS.POINTSTOPOINT (pt, pos);
                OS.ScreenToClient (handle, &pt);
                sendDragEvent (1, pt.x, pt.y);
            }
            break;
        }
        case OS.LVN_COLUMNCLICK: {
            NMLISTVIEW* pnmlv = cast(NMLISTVIEW*)lParam;
            //OS.MoveMemory(pnmlv, lParam, NMLISTVIEW.sizeof);
            TableColumn column = columns [pnmlv.iSubItem];
            if (column !is null) {
                column.postEvent (SWT.Selection);
            }
            break;
        }
        case OS.LVN_ITEMACTIVATE: {
            if (ignoreActivate) break;
            NMLISTVIEW* pnmlv = cast(NMLISTVIEW*)lParam;
            //OS.MoveMemory(pnmlv, lParam, NMLISTVIEW.sizeof);
            if (pnmlv.iItem !is -1) {
                Event event = new Event ();
                event.item = _getItem (pnmlv.iItem);
                postEvent (SWT.DefaultSelection, event);
            }
            break;
        }
        case OS.LVN_ITEMCHANGED: {
            if (fullRowSelect) {
                fullRowSelect = false;
                OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
                OS.SendMessage (handle, OS.LVM_SETEXTENDEDLISTVIEWSTYLE, OS.LVS_EX_FULLROWSELECT, 0);
            }
            if (!ignoreSelect) {
                NMLISTVIEW* pnmlv = cast(NMLISTVIEW*)lParam;
                //OS.MoveMemory (pnmlv, lParam, NMLISTVIEW.sizeof);
                if ((pnmlv.uChanged & OS.LVIF_STATE) !is 0) {
                    if (pnmlv.iItem is -1) {
                        wasSelected = true;
                    } else {
                        bool oldSelected = (pnmlv.uOldState & OS.LVIS_SELECTED) !is 0;
                        bool newSelected = (pnmlv.uNewState & OS.LVIS_SELECTED) !is 0;
                        if (oldSelected !is newSelected) wasSelected = true;
                    }
                }
            }
            if (hooks (SWT.EraseItem) || hooks (SWT.PaintItem)) {
                auto hwndHeader = cast(HWND) OS.SendMessage (handle, OS.LVM_GETHEADER, 0, 0);
                auto count = OS.SendMessage (hwndHeader, OS.HDM_GETITEMCOUNT, 0, 0);
                if (count !is 0) {
                    forceResize ();
                    RECT rect;
                    OS.GetClientRect (handle, &rect);
                    NMLISTVIEW* pnmlv = cast(NMLISTVIEW*)lParam;
                    //OS.MoveMemory (pnmlv, lParam, NMLISTVIEW.sizeof);
                    if (pnmlv.iItem !is -1) {
                        RECT itemRect;
                        itemRect.left = OS.LVIR_BOUNDS;
                        ignoreCustomDraw = true;
                        OS.SendMessage (handle, OS. LVM_GETITEMRECT, pnmlv.iItem, &itemRect);
                        ignoreCustomDraw = false;
                        RECT headerRect;
                        auto index = OS.SendMessage (hwndHeader, OS.HDM_ORDERTOINDEX, count - 1, 0);
                        OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, index, &headerRect);
                        OS.MapWindowPoints (hwndHeader, handle, cast(POINT*) &headerRect, 2);
                        rect.left = headerRect.right;
                        rect.top = itemRect.top;
                        rect.bottom = itemRect.bottom;
                        OS.InvalidateRect (handle, &rect, true);
                    }
                }
            }
            break;
        }
        case OS.NM_RECOGNIZEGESTURE:
            /*
            * Feature on Pocket PC.  The tree and table controls detect the tap
            * and hold gesture by default. They send a GN_CONTEXTMENU message to show
            * the popup menu.  This default behaviour is unwanted on Pocket PC 2002
            * when no menu has been set, as it still draws a red circle.  The fix
            * is to disable this default behaviour when no menu is set by returning
            * TRUE when receiving the Pocket PC 2002 specific NM_RECOGNIZEGESTURE
            * message.
            */
            if (OS.IsPPC) {
                bool hasMenu = menu !is null && !menu.isDisposed ();
                if (!hasMenu && !hooks (SWT.MenuDetect)) return LRESULT.ONE;
            }
            break;
        case OS.GN_CONTEXTMENU:
            if (OS.IsPPC) {
                bool hasMenu = menu !is null && !menu.isDisposed ();
                if (hasMenu || hooks (SWT.MenuDetect)) {
                    NMRGINFO* nmrg = cast(NMRGINFO*)lParam;
                    //OS.MoveMemory (nmrg, lParam, NMRGINFO.sizeof);
                    showMenu (nmrg.x, nmrg.y);
                    return LRESULT.ONE;
                }
            }
            break;
        default:
    }
    return super.wmNotifyChild (hdr, wParam, lParam);
}

LRESULT wmNotifyHeader (NMHDR* hdr, WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  On NT, the automatically created
    * header control is created as a UNICODE window, not an
    * ANSI window despite the fact that the parent is created
    * as an ANSI window.  This means that it sends UNICODE
    * notification messages to the parent window on NT for
    * no good reason.  The data and size in the NMHEADER and
    * HDITEM structs is identical between the platforms so no
    * different message is actually necessary.  Despite this,
    * Windows sends different messages.  The fix is to look
    * for both messages, despite the platform.  This works
    * because only one will be sent on either platform, never
    * both.
    */
    switch (hdr.code) {
        case OS.HDN_BEGINTRACKW:
        case OS.HDN_BEGINTRACKA:
        case OS.HDN_DIVIDERDBLCLICKW:
        case OS.HDN_DIVIDERDBLCLICKA: {
            if (columnCount is 0) return LRESULT.ONE;
            NMHEADER* phdn = cast(NMHEADER*)lParam;
            TableColumn column = columns [phdn.iItem];
            if (column !is null && !column.getResizable ()) {
                return LRESULT.ONE;
            }
            ignoreColumnMove = true;
            switch (hdr.code) {
                case OS.HDN_DIVIDERDBLCLICKW:
                case OS.HDN_DIVIDERDBLCLICKA:
                    /*
                    * Bug in Windows.  When the first column of a table does not
                    * have an image and the user double clicks on the divider,
                    * Windows packs the column but does not take into account
                    * the empty space left for the image.  The fix is to measure
                    * each items ourselves rather than letting Windows do it.
                    */
                    bool fixPack = phdn.iItem is 0 && !firstColumnImage;
                    if (column !is null && (fixPack || hooks (SWT.MeasureItem))) {
                        column.pack ();
                        return LRESULT.ONE;
                    }
                    break;
                default:
                    break;
            }
            break;
        }
        case OS.NM_RELEASEDCAPTURE: {
            if (!ignoreColumnMove) {
                for (int i=0; i<columnCount; i++) {
                    TableColumn column = columns [i];
                    column.updateToolTip (i);
                }
            }
            ignoreColumnMove = false;
            break;
        }
        case OS.HDN_BEGINDRAG: {
            if (ignoreColumnMove) return LRESULT.ONE;
            auto bits = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
            if ((bits & OS.LVS_EX_HEADERDRAGDROP) is 0) break;
            if (columnCount is 0) return LRESULT.ONE;
            NMHEADER* phdn = cast(NMHEADER*)lParam;
            if (phdn.iItem !is -1) {
                TableColumn column = columns [phdn.iItem];
                if (column !is null && !column.getMoveable ()) {
                    ignoreColumnMove = true;
                    return LRESULT.ONE;
                }
            }
            break;
        }
        case OS.HDN_ENDDRAG: {
            auto bits = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
            if ((bits & OS.LVS_EX_HEADERDRAGDROP) is 0) break;
            NMHEADER* phdn = cast(NMHEADER*)lParam;
            if (cast(ptrdiff_t)phdn.iItem !is -1 && cast(ptrdiff_t)phdn.pitem !is 0) {
                HDITEM* pitem = cast(HDITEM*)phdn.pitem;
                if ((pitem.mask & OS.HDI_ORDER) !is 0 && pitem.iOrder !is -1) {
                    if (columnCount is 0) break;
                    int [] order = new int [columnCount];
                    OS.SendMessage (handle, OS.LVM_GETCOLUMNORDERARRAY, columnCount, order.ptr);
                    int index = 0;
                    while (index < order.length) {
                        if (order [index] is phdn.iItem) break;
                        index++;
                    }
                    if (index is order.length) index = 0;
                    if (index is pitem.iOrder) break;
                    int start = Math.min (index, pitem.iOrder);
                    int end = Math.max (index, pitem.iOrder);
                    ignoreColumnMove = false;
                    for (int i=start; i<=end; i++) {
                        TableColumn column = columns [order [i]];
                        if (!column.isDisposed ()) {
                            column.postEvent (SWT.Move);
                        }
                    }
                }
            }
            break;
        }
        case OS.HDN_ITEMCHANGEDW:
        case OS.HDN_ITEMCHANGEDA: {
            /*
            * Bug in Windows.  When a table has the LVS_EX_GRIDLINES extended
            * style and the user drags any column over the first column in the
            * table, making the size become zero, when the user drags a column
            * such that the size of the first column becomes non-zero, the grid
            * lines are not redrawn.  The fix is to detect the case and force
            * a redraw of the first column.
            */
            int width = cast(int)/*64bit*/OS.SendMessage (handle, OS.LVM_GETCOLUMNWIDTH, 0, 0);
            if (lastWidth is 0 && width > 0) {
                auto bits = OS.SendMessage (handle, OS.LVM_GETEXTENDEDLISTVIEWSTYLE, 0, 0);
                if ((bits & OS.LVS_EX_GRIDLINES) !is 0) {
                    RECT rect;
                    OS.GetClientRect (handle, &rect);
                    rect.right = rect.left + width;
                    OS.InvalidateRect (handle, &rect, true);
                }
            }
            lastWidth = width;
            if (!ignoreColumnResize) {
                NMHEADER* phdn = cast(NMHEADER*)lParam;
                if (phdn.pitem !is null) {
                    HDITEM* pitem = cast(HDITEM*)phdn.pitem;
                    if ((pitem.mask & OS.HDI_WIDTH) !is 0) {
                        TableColumn column = columns [phdn.iItem];
                        if (column !is null) {
                            column.updateToolTip (phdn.iItem);
                            column.sendEvent (SWT.Resize);
                            if (isDisposed ()) return LRESULT.ZERO;
                            /*
                            * It is possible (but unlikely), that application
                            * code could have disposed the column in the move
                            * event.  If this happens, process the move event
                            * for those columns that have not been destroyed.
                            */
                            TableColumn [] newColumns = new TableColumn [columnCount];
                            System.arraycopy (columns, 0, newColumns, 0, columnCount);
                            int [] order = new int [columnCount];
                            OS.SendMessage (handle, OS.LVM_GETCOLUMNORDERARRAY, columnCount, order.ptr);
                            bool moved = false;
                            for (int i=0; i<columnCount; i++) {
                                TableColumn nextColumn = newColumns [order [i]];
                                if (moved && !nextColumn.isDisposed ()) {
                                    nextColumn.updateToolTip (order [i]);
                                    nextColumn.sendEvent (SWT.Move);
                                }
                                if (nextColumn is column) moved = true;
                            }
                        }
                    }
                }
            }
            break;
        }
        case OS.HDN_ITEMDBLCLICKW:
        case OS.HDN_ITEMDBLCLICKA: {
            NMHEADER* phdn = cast(NMHEADER*)lParam;
            TableColumn column = columns [phdn.iItem];
            if (column !is null) {
                column.postEvent (SWT.DefaultSelection);
            }
            break;
        }
        default:
    }
    return null;
}

LRESULT wmNotifyToolTip (NMHDR* hdr, WPARAM wParam, LPARAM lParam) {
    if (OS.IsWinCE) return null;
    switch (hdr.code) {
        case OS.NM_CUSTOMDRAW: {
            if (toolTipText_ !is null) break;
            if (isCustomToolTip ()) {
                NMTTCUSTOMDRAW* nmcd = cast(NMTTCUSTOMDRAW*)lParam;
                return wmNotifyToolTip (nmcd, lParam);
            }
            break;
        }
        case OS.TTN_GETDISPINFOA:
        case OS.TTN_GETDISPINFOW:
        case OS.TTN_SHOW: {
            LRESULT result = super.wmNotify (hdr, wParam, lParam);
            if (result !is null) return result;
            if (hdr.code !is OS.TTN_SHOW) tipRequested = true;
            auto code = callWindowProc (handle, OS.WM_NOTIFY, wParam, lParam);
            if (hdr.code !is OS.TTN_SHOW) tipRequested = false;
            if (toolTipText_ !is null) break;
            if (isCustomToolTip ()) {
                LVHITTESTINFO pinfo;
                int pos = OS.GetMessagePos ();
                POINT pt;
                OS.POINTSTOPOINT (pt, pos);
                OS.ScreenToClient (handle, &pt);
                pinfo.pt.x = pt.x;
                pinfo.pt.y = pt.y;
                if (OS.SendMessage (handle, OS.LVM_SUBITEMHITTEST, 0, &pinfo) !is -1) {
                    TableItem item = _getItem (pinfo.iItem);
                    auto hDC = OS.GetDC (handle);
                    HFONT oldFont, newFont = cast(HFONT)OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
                    if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
                    auto hFont = item.fontHandle (pinfo.iSubItem);
                    if (cast(ptrdiff_t)hFont !is -1) hFont = cast(HFONT)OS.SelectObject (hDC, hFont);
                    Event event = sendMeasureItemEvent (item, pinfo.iItem, pinfo.iSubItem, hDC);
                    if (!isDisposed () && !item.isDisposed ()) {
                        RECT itemRect;
                        OS.SetRect (&itemRect, event.x, event.y, event.x + event.width, event.y + event.height);
                        if (hdr.code is OS.TTN_SHOW) {
                            RECT* toolRect = toolTipRect (&itemRect);
                            OS.MapWindowPoints (handle, null, cast(POINT*)toolRect, 2);
                            auto hwndToolTip = cast(HWND) OS.SendMessage (handle, OS.LVM_GETTOOLTIPS, 0, 0);
                            int flags = OS.SWP_NOACTIVATE | OS.SWP_NOZORDER;
                            int width = toolRect.right - toolRect.left, height = toolRect.bottom - toolRect.top;
                            SetWindowPos (hwndToolTip, null, toolRect.left , toolRect.top, width, height, flags);
                        } else {
                            NMTTDISPINFO* lpnmtdi = null;
                            if (hdr.code is OS.TTN_GETDISPINFOA) {
                                lpnmtdi = cast(NMTTDISPINFO*)new NMTTDISPINFOA;
                                OS.MoveMemory (cast(void*)lpnmtdi, cast(void*) lParam, NMTTDISPINFOA.sizeof);
                                if (lpnmtdi.lpszText !is null) {
                                    (cast(char*)lpnmtdi.lpszText)[0] = 0;
                                }
                            } else {
                                lpnmtdi = cast(NMTTDISPINFO*)new NMTTDISPINFOW;
                                OS.MoveMemory (lpnmtdi, lParam, NMTTDISPINFOW.sizeof);
                                if (lpnmtdi.lpszText !is null) {
                                    (cast(wchar*)lpnmtdi.lpszText)[0] = 0;
                                }
                            }
                            RECT cellRect = item.getBounds (pinfo.iItem, pinfo.iSubItem, true, true, true, true, hDC);
                            if (itemRect.right > cellRect.right) {
                                //TEMPORARY CODE
                                String string = " ";
//                              String string = null;
//                              if (pinfo.iSubItem is 0) {
//                                  string = item.text;
//                              } else {
//                                  String [] strings  = item.strings;
//                                  if (strings !is null) string = strings [pinfo.iSubItem];
//                              }
                                if (string !is null) {
                                    Shell shell = getShell ();
                                    StringT chars = StrToTCHARs(string, true );
                                    if (hdr.code is OS.TTN_GETDISPINFOA) {
                                        CHAR [] bytes = new CHAR [chars.length * 2];
                                        OS.WideCharToMultiByte (getCodePage (), 0, chars.ptr, cast(int)/*64bit*/chars.length, bytes.ptr, cast(int)/*64bit*/bytes.length, null, null);
                                        shell.setToolTipText (lpnmtdi, bytes);
                                        OS.MoveMemory (lParam, cast(NMTTDISPINFOA*)lpnmtdi, NMTTDISPINFOA.sizeof);
                                    } else {
                                        shell.setToolTipText (lpnmtdi, chars);
                                        OS.MoveMemory (lParam, cast(NMTTDISPINFOW*)lpnmtdi, NMTTDISPINFOW.sizeof);
                                    }
                                }
                            }
                        }
                    }
                    if (hFont !is cast(HFONT)-1) hFont = OS.SelectObject (hDC, hFont);
                    if (newFont !is null) OS.SelectObject (hDC, oldFont);
                    OS.ReleaseDC (handle, hDC);
                }
            }
            return new LRESULT (code);
        }
        default:
    }
    return null;
}

LRESULT wmNotifyToolTip (NMTTCUSTOMDRAW* nmcd, LPARAM lParam) {
    if (OS.IsWinCE) return null;
    switch (nmcd.nmcd.dwDrawStage) {
        case OS.CDDS_PREPAINT: {
            if (isCustomToolTip ()) {
                //TEMPORARY CODE
//              nmcd.uDrawFlags |= OS.DT_CALCRECT;
//              OS.MoveMemory (lParam, nmcd, NMTTCUSTOMDRAW.sizeof);
                return new LRESULT (OS.CDRF_NOTIFYPOSTPAINT | OS.CDRF_NEWFONT);
            }
            break;
        }
        case OS.CDDS_POSTPAINT: {
            LVHITTESTINFO pinfo;
            int pos = OS.GetMessagePos ();
            POINT pt;
            OS.POINTSTOPOINT (pt, pos);
            OS.ScreenToClient (handle, &pt);
            pinfo.pt.x = pt.x;
            pinfo.pt.y = pt.y;
            if (OS.SendMessage (handle, OS.LVM_SUBITEMHITTEST, 0, &pinfo) !is -1) {
                TableItem item = _getItem (pinfo.iItem);
                auto hDC = OS.GetDC (handle);
                auto hFont = item.fontHandle (pinfo.iSubItem);
                if (cast(ptrdiff_t)hFont is -1) hFont = cast(HFONT)OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
                auto oldFont = cast(HFONT)OS.SelectObject (hDC, hFont);
                bool drawForeground = true;
                RECT cellRect = item.getBounds (pinfo.iItem, pinfo.iSubItem, true, true, false, false, hDC);
                if (hooks (SWT.EraseItem)) {
                    Event event = sendEraseItemEvent (item, nmcd, pinfo.iSubItem, &cellRect);
                    if (isDisposed () || item.isDisposed ()) break;
                    if (event.doit) {
                        drawForeground = (event.detail & SWT.FOREGROUND) !is 0;
                    } else {
                        drawForeground = false;
                    }
                }
                if (drawForeground) {
                    int nSavedDC = OS.SaveDC (nmcd.nmcd.hdc);
                    int gridWidth = getLinesVisible () ? Table.GRID_WIDTH : 0;
                    RECT* insetRect = toolTipInset (&cellRect);
                    OS.SetWindowOrgEx (nmcd.nmcd.hdc, insetRect.left, insetRect.top, null);
                    GCData data = new GCData ();
                    data.device = display;
                    data.foreground = OS.GetTextColor (nmcd.nmcd.hdc);
                    data.background = OS.GetBkColor (nmcd.nmcd.hdc);
                    data.font = Font.win32_new (display, hFont);
                    GC gc = GC.win32_new (nmcd.nmcd.hdc, data);
                    int x = cellRect.left;
                    if (pinfo.iSubItem !is 0) x -= gridWidth;
                    Image image = item.getImage (pinfo.iSubItem);
                    if (image !is null) {
                        Rectangle rect = image.getBounds ();
                        RECT imageRect = item.getBounds (pinfo.iItem, pinfo.iSubItem, false, true, false, false, hDC);
                        Point size = imageList is null ? new Point (rect.width, rect.height) : imageList.getImageSize ();
                        int y = imageRect.top;
                        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
                            y = y + Math.max (0, (imageRect.bottom - imageRect.top - size.y) / 2);
                        }
                        gc.drawImage (image, rect.x, rect.y, rect.width, rect.height, x, y, size.x, size.y);
                        x += size.x + INSET + (pinfo.iSubItem is 0 ? -2 : 4);
                    } else {
                        x += INSET + 2;
                    }
                    String string = item.getText (pinfo.iSubItem);
                    if (string !is null) {
                        int flags = OS.DT_NOPREFIX | OS.DT_SINGLELINE | OS.DT_VCENTER;
                        TableColumn column = columns !is null ? columns [pinfo.iSubItem] : null;
                        if (column !is null) {
                            if ((column.style & SWT.CENTER) !is 0) flags |= OS.DT_CENTER;
                            if ((column.style & SWT.RIGHT) !is 0) flags |= OS.DT_RIGHT;
                        }
                        StringT buffer = StrToTCHARs (getCodePage (), string, false);
                        RECT textRect;
                        OS.SetRect (&textRect, x, cellRect.top, cellRect.right, cellRect.bottom);
                        OS.DrawText (nmcd.nmcd.hdc, buffer.ptr, cast(int)/*64bit*/buffer.length, &textRect, flags);
                    }
                    gc.dispose ();
                    OS.RestoreDC (nmcd.nmcd.hdc, nSavedDC);
                }
                if (hooks (SWT.PaintItem)) {
                    RECT itemRect = item.getBounds (pinfo.iItem, pinfo.iSubItem, true, true, false, false, hDC);
                    sendPaintItemEvent (item, nmcd, pinfo.iSubItem, &itemRect);
                }
                OS.SelectObject (hDC, oldFont);
                OS.ReleaseDC (handle, hDC);
            }
            break;
        }
        default:
            break;
    }
    return null;
}
}
