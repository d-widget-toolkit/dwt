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
module org.eclipse.swt.widgets.Tree;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.TreeListener;
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.ImageList;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.TreeItem;
import org.eclipse.swt.widgets.TreeColumn;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.Table;

import java.lang.all;


/**
 * Instances of this class provide a selectable user interface object
 * that displays a hierarchy of items and issues notification when an
 * item in the hierarchy is selected.
 * <p>
 * The item children that may be added to instances of this class
 * must be of type <code>TreeItem</code>.
 * </p><p>
 * Style <code>VIRTUAL</code> is used to create a <code>Tree</code> whose
 * <code>TreeItem</code>s are to be populated by the client on an on-demand basis
 * instead of up-front.  This can provide significant performance improvements for
 * trees that are very large or for which <code>TreeItem</code> population is
 * expensive (for example, retrieving values from an external source).
 * </p><p>
 * Here is an example of using a <code>Tree</code> with style <code>VIRTUAL</code>:
 * <code><pre>
 *  final Tree tree = new Tree(parent, SWT.VIRTUAL | SWT.BORDER);
 *  tree.setItemCount(20);
 *  tree.addListener(SWT.SetData, new Listener() {
 *      public void handleEvent(Event event) {
 *          TreeItem item = (TreeItem)event.item;
 *          TreeItem parentItem = item.getParentItem();
 *          String text = null;
 *          if (parentItem is null) {
 *              text = "node " + tree.indexOf(item);
 *          } else {
 *              text = parentItem.getText() + " - " + parentItem.indexOf(item);
 *          }
 *          item.setText(text);
 *          System.out.println(text);
 *          item.setItemCount(10);
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
 * <dd>SINGLE, MULTI, CHECK, FULL_SELECTION, VIRTUAL, NO_SCROLL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection, DefaultSelection, Collapse, Expand, SetData, MeasureItem, EraseItem, PaintItem</dd>
 * </dl>
 * </p><p>
 * Note: Only one of the styles SINGLE and MULTI may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#tree">Tree, TreeItem, TreeColumn snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Tree : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.setBackgroundImage setBackgroundImage;
    alias Composite.setBounds setBounds;
    alias Composite.setCursor setCursor;
    alias Composite.sort sort;

    TreeItem [] items;
    TreeColumn [] columns;
    int columnCount;
    ImageList imageList, headerImageList;
    TreeItem currentItem;
    TreeColumn sortColumn;
    RECT* focusRect;
    HWND hwndParent, hwndHeader;
    HANDLE hAnchor, hInsert, hSelect;
    int lastID;
    HANDLE hFirstIndexOf, hLastIndexOf;
    int lastIndexOf, itemCount, sortDirection;
    bool dragStarted, gestureCompleted, insertAfter, shrink, ignoreShrink;
    bool ignoreSelect, ignoreExpand, ignoreDeselect, ignoreResize;
    bool lockSelection, oldSelected, newSelected, ignoreColumnMove;
    bool linesVisible, customDraw, printClient, painted, ignoreItemHeight;
    bool ignoreCustomDraw, ignoreDrawForeground, ignoreDrawBackground, ignoreDrawFocus;
    bool ignoreDrawSelection, ignoreDrawHot, ignoreFullSelection, explorerTheme;
    int scrollWidth, selectionForeground;
    HANDLE headerToolTipHandle, itemToolTipHandle;
    static const int INSET = 3;
    static const int GRID_WIDTH = 1;
    static const int SORT_WIDTH = 10;
    static const int HEADER_MARGIN = 12;
    static const int HEADER_EXTRA = 3;
    static const int INCREMENT = 5;
    static const int EXPLORER_EXTRA = 2;
    static const int DRAG_IMAGE_SIZE = 301;
    static const bool EXPLORER_THEME = true;
    mixin(gshared!(`private static /+const+/ WNDPROC TreeProc;`));
    mixin(gshared!(`static const TCHAR[] TreeClass = OS.WC_TREEVIEW;`));
    mixin(gshared!(`private static /+const+/ WNDPROC HeaderProc;`));
    mixin(gshared!(`static const TCHAR[] HeaderClass = OS.WC_HEADER;`));

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
            OS.GetClassInfo (null, TreeClass.ptr, &lpWndClass);
            TreeProc = lpWndClass.lpfnWndProc;
            OS.GetClassInfo (null, HeaderClass.ptr, &lpWndClass);
            HeaderProc = lpWndClass.lpfnWndProc;
            static_this_completed = true;
        }
    }

    mixin(gshared!(`private static Tree sThis;`));
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
 * @see SWT#VIRTUAL
 * @see SWT#NO_SCROLL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    static_this();
    super (parent, checkStyle (style));
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
    /*
    * Note: Windows only supports TVS_NOSCROLL and TVS_NOHSCROLL.
    */
    if ((style & SWT.H_SCROLL) !is 0 && (style & SWT.V_SCROLL) is 0) {
        style |= SWT.V_SCROLL;
    }
    return checkBits (style, SWT.SINGLE, SWT.MULTI, 0, 0, 0, 0);
}

override void _addListener (int eventType, Listener listener) {
    super._addListener (eventType, listener);
    switch (eventType) {
        case SWT.DragDetect: {
            if ((state & DRAG_DETECT) !is 0) {
                int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
                bits &= ~OS.TVS_DISABLEDRAGDROP;
                OS.SetWindowLong (handle, OS.GWL_STYLE, bits);
            }
            break;
        }
        case SWT.MeasureItem:
        case SWT.EraseItem:
        case SWT.PaintItem: {
            customDraw = true;
            style |= SWT.DOUBLE_BUFFERED;
            if (isCustomToolTip ()) createItemToolTips ();
            OS.SendMessage (handle, OS.TVM_SETSCROLLTIME, 0, 0);
            int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
            if (eventType is SWT.MeasureItem) {
                /*
                * This code is intentionally commented.
                */
//              if (explorerTheme) {
//                  int bits1 = (int)/*64*/OS.SendMessage (handle, OS.TVM_GETEXTENDEDSTYLE, 0, 0);
//                  bits1 &= ~OS.TVS_EX_AUTOHSCROLL;
//                  OS.SendMessage (handle, OS.TVM_SETEXTENDEDSTYLE, 0, bits1);
//              }
                bits |= OS.TVS_NOHSCROLL;
            }
            /*
            * Feature in Windows.  When the tree has the style
            * TVS_FULLROWSELECT, the background color for the
            * entire row is filled when an item is painted,
            * drawing on top of any custom drawing.  The fix
            * is to clear TVS_FULLROWSELECT.
            */
            if ((style & SWT.FULL_SELECTION) !is 0) {
                if (eventType !is SWT.MeasureItem) {
                    if (!explorerTheme) bits &= ~OS.TVS_FULLROWSELECT;
                }
            }
            if (bits !is OS.GetWindowLong (handle, OS.GWL_STYLE)) {
                OS.SetWindowLong (handle, OS.GWL_STYLE, bits);
                OS.InvalidateRect (handle, null, true);
                /*
                * Bug in Windows.  When TVS_NOHSCROLL is set after items
                * have been inserted into the tree, Windows shows the
                * scroll bar.  The fix is to check for this case and
                * explicitly hide the scroll bar.
                */
                auto count = OS.SendMessage (handle, OS.TVM_GETCOUNT, 0, 0);
                if (count !is 0 && (bits & OS.TVS_NOHSCROLL) !is 0) {
                    static if (!OS.IsWinCE) OS.ShowScrollBar (handle, OS.SB_HORZ, false);
                }
            }
            break;
        }
        default:
    }
}

TreeItem _getItem (HANDLE hItem) {
    TVITEM tvItem;
    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM;
    tvItem.hItem = cast(HTREEITEM)hItem;
    if (OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem) !is 0) {
        return _getItem (tvItem.hItem, tvItem.lParam);
    }
    return null;
}

TreeItem _getItem (HANDLE hItem, LPARAM id) {
    if ((style & SWT.VIRTUAL) is 0) return items [id];
    return id !is -1 ? items [id] : new TreeItem (this, SWT.NONE, cast(HANDLE)-1, cast(HANDLE)-1, hItem);
}

void _setBackgroundPixel (int newPixel) {
    auto oldPixel = OS.SendMessage (handle, OS.TVM_GETBKCOLOR, 0, 0);
    if (oldPixel !is newPixel) {
        /*
        * Bug in Windows.  When TVM_SETBKCOLOR is used more
        * than once to set the background color of a tree,
        * the background color of the lines and the plus/minus
        * does not change to the new color.  The fix is to set
        * the background color to the default before setting
        * the new color.
        */
        if (oldPixel !is -1) {
            OS.SendMessage (handle, OS.TVM_SETBKCOLOR, 0, -1);
        }

        /* Set the background color */
        OS.SendMessage (handle, OS.TVM_SETBKCOLOR, 0, newPixel);

        /*
        * Feature in Windows.  When TVM_SETBKCOLOR is used to
        * set the background color of a tree, the plus/minus
        * animation draws badly.  The fix is to clear the effect.
        */
        if (explorerTheme) {
            auto bits2 = OS.SendMessage (handle, OS.TVM_GETEXTENDEDSTYLE, 0, 0);
            if (newPixel is -1 && findImageControl () is null) {
                bits2 |= OS.TVS_EX_FADEINOUTEXPANDOS;
            } else {
                bits2 &= ~OS.TVS_EX_FADEINOUTEXPANDOS;
            }
            OS.SendMessage (handle, OS.TVM_SETEXTENDEDSTYLE, 0, bits2);
        }

        /* Set the checkbox image list */
        if ((style & SWT.CHECK) !is 0) setCheckboxImageList ();
    }
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
public void addSelectionListener(SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection, typedListener);
    addListener (SWT.DefaultSelection, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when an item in the receiver is expanded or collapsed
 * by sending it one of the messages defined in the <code>TreeListener</code>
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
 * @see TreeListener
 * @see #removeTreeListener
 */
public void addTreeListener(TreeListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Expand, typedListener);
    addListener (SWT.Collapse, typedListener);
}

override HWND borderHandle () {
    return hwndParent !is null ? hwndParent : handle;
}

LRESULT CDDS_ITEMPOSTPAINT (NMTVCUSTOMDRAW* nmcd, WPARAM wParam, LPARAM lParam) {
    if (ignoreCustomDraw) return null;
    if (nmcd.nmcd.rc.left is nmcd.nmcd.rc.right) return new LRESULT (OS.CDRF_DODEFAULT);
    auto hDC = nmcd.nmcd.hdc;
    OS.RestoreDC (hDC, -1);
    TreeItem item = getItem (nmcd);

    /*
    * Feature in Windows.  When a new tree item is inserted
    * using TVM_INSERTITEM and the tree is using custom draw,
    * a NM_CUSTOMDRAW is sent before TVM_INSERTITEM returns
    * and before the item is added to the items array.  The
    * fix is to check for null.
    *
    * NOTE: This only happens on XP with the version 6.00 of
    * COMCTL32.DLL,
    */
    if (item is null) return null;

    /*
    * Feature in Windows.  Under certain circumstances, Windows
    * sends CDDS_ITEMPOSTPAINT for an empty rectangle.  This is
    * not a problem providing that graphics do not occur outside
    * the rectangle.  The fix is to test for the rectangle and
    * draw nothing.
    *
    * NOTE:  This seems to happen when both I_IMAGECALLBACK
    * and LPSTR_TEXTCALLBACK are used at the same time with
    * TVM_SETITEM.
    */
    if (nmcd.nmcd.rc.left >= nmcd.nmcd.rc.right || nmcd.nmcd.rc.top >= nmcd.nmcd.rc.bottom) return null;
    if (!OS.IsWindowVisible (handle)) return null;
    if ((style & SWT.FULL_SELECTION) !is 0 || findImageControl () !is null || ignoreDrawSelection || explorerTheme) {
        OS.SetBkMode (hDC, OS.TRANSPARENT);
    }
    bool selected = isItemSelected (nmcd);
    bool hot = explorerTheme && (nmcd.nmcd.uItemState & OS.CDIS_HOT) !is 0;
    if (OS.IsWindowEnabled (handle)) {
        if (explorerTheme) {
            int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
            if ((bits & OS.TVS_TRACKSELECT) !is 0) {
                if ((style & SWT.FULL_SELECTION) !is 0 && (selected || hot)) {
                    OS.SetTextColor (hDC, OS.GetSysColor (OS.COLOR_WINDOWTEXT));
                } else {
                    OS.SetTextColor (hDC, getForegroundPixel ());
                }
            }
        }
    }
    int [] order = null;
    RECT clientRect;
    OS.GetClientRect (scrolledHandle (), &clientRect);
    if (hwndHeader !is null) {
        OS.MapWindowPoints (hwndParent, handle, cast(POINT*) &clientRect, 2);
        if (columnCount !is 0) {
            order = new int [columnCount];
            OS.SendMessage (hwndHeader, OS.HDM_GETORDERARRAY, columnCount, order.ptr);
        }
    }
    int sortIndex = -1, clrSortBk = -1;
    if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
        if (sortColumn !is null && sortDirection !is SWT.NONE) {
            if (findImageControl () is null) {
                sortIndex = indexOf (sortColumn);
                clrSortBk = getSortColumnPixel ();
            }
        }
    }
    int x = 0;
    Point size = null;
    for (int i=0; i<Math.max (1, columnCount); i++) {
        int index = order is null ? i : order [i], width = nmcd.nmcd.rc.right - nmcd.nmcd.rc.left;
        if (columnCount > 0 && hwndHeader !is null) {
            HDITEM hdItem;
            hdItem.mask = OS.HDI_WIDTH;
            OS.SendMessage (hwndHeader, OS.HDM_GETITEM, index, &hdItem);
            width = hdItem.cxy;
        }
        if (i is 0) {
            if ((style & SWT.FULL_SELECTION) !is 0) {
                bool clear = !explorerTheme && !ignoreDrawSelection && findImageControl () is null;
                if (clear || (selected && !ignoreDrawSelection) || (hot && !ignoreDrawHot)) {
                    bool draw = true;
                    RECT pClipRect;
                    OS.SetRect (&pClipRect, width, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
                    if (explorerTheme) {
                        if (hooks (SWT.EraseItem)) {
                            RECT* itemRect = item.getBounds (index, true, true, false, false, true, hDC);
                            itemRect.left -= EXPLORER_EXTRA;
                            itemRect.right += EXPLORER_EXTRA + 1;
                            pClipRect.left = itemRect.left;
                            pClipRect.right = itemRect.right;
                            if (columnCount > 0 && hwndHeader !is null) {
                                HDITEM hdItem;
                                hdItem.mask = OS.HDI_WIDTH;
                                OS.SendMessage (hwndHeader, OS.HDM_GETITEM, index, &hdItem);
                                pClipRect.right = Math.min (pClipRect.right, nmcd.nmcd.rc.left + hdItem.cxy);
                            }
                        }
                        RECT pRect;
                        OS.SetRect (&pRect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
                        if (columnCount > 0 && hwndHeader !is null) {
                            int totalWidth = 0;
                            HDITEM hdItem;
                            hdItem.mask = OS.HDI_WIDTH;
                            for (int j=0; j<columnCount; j++) {
                                OS.SendMessage (hwndHeader, OS.HDM_GETITEM, j, &hdItem);
                                totalWidth += hdItem.cxy;
                            }
                            if (totalWidth > clientRect.right - clientRect.left) {
                                pRect.left = 0;
                                pRect.right = totalWidth;
                            } else {
                                pRect.left = clientRect.left;
                                pRect.right = clientRect.right;
                            }
                        }
                        draw = false;
                        auto hTheme = OS.OpenThemeData (handle, cast(TCHAR*) Display.TREEVIEW);
                        int iStateId = selected ? OS.TREIS_SELECTED : OS.TREIS_HOT;
                        if (OS.GetFocus () !is handle && selected && !hot) iStateId = OS.TREIS_SELECTEDNOTFOCUS;
                        OS.DrawThemeBackground (hTheme, hDC, OS.TVP_TREEITEM, iStateId, &pRect, &pClipRect);
                        OS.CloseThemeData (hTheme);
                    }
                    if (draw) fillBackground (hDC, OS.GetBkColor (hDC), &pClipRect);
                }
            }
        }
        if (x + width > clientRect.left) {
            RECT* rect = new RECT(), backgroundRect = null;
            bool drawItem = true, drawText = true, drawImage = true, drawBackground_ = false;
            if (i is 0) {
                drawItem = drawImage = drawText = false;
                if (findImageControl () !is null) {
                    if (explorerTheme) {
                        if (OS.IsWindowEnabled (handle) && !hooks (SWT.EraseItem)) {
                            Image image = null;
                            if (index is 0) {
                                image = item.image;
                            } else {
                                Image [] images  = item.images;
                                if (images !is null) image = images [index];
                            }
                            if (image !is null) {
                                Rectangle bounds = image.getBounds ();
                                if (size is null) size = getImageSize ();
                                if (!ignoreDrawForeground) {
                                    GCData data = new GCData();
                                    data.device = display;
                                    GC gc = GC.win32_new (hDC, data);
                                    RECT* iconRect = item.getBounds (index, false, true, false, false, true, hDC);
                                    gc.setClipping (iconRect.left, iconRect.top, iconRect.right - iconRect.left, iconRect.bottom - iconRect.top);
                                    gc.drawImage (image, 0, 0, bounds.width, bounds.height, iconRect.left, iconRect.top, size.x, size.y);
                                    OS.SelectClipRgn (hDC, null);
                                    gc.dispose ();
                                }
                            }
                        }
                    } else {
                        drawItem = drawText = drawBackground_ = true;
                        rect = item.getBounds (index, true, false, false, false, true, hDC);
                        if (linesVisible) {
                            rect.right++;
                            rect.bottom++;
                        }
                    }
                }
                if (selected && !ignoreDrawSelection && !ignoreDrawBackground) {
                    if (!explorerTheme) fillBackground (hDC, OS.GetBkColor (hDC), rect);
                    drawBackground_ = false;
                }
                backgroundRect = rect;
                if (hooks (SWT.EraseItem)) {
                    drawItem = drawText = drawImage = true;
                    rect = item.getBounds (index, true, true, false, false, true, hDC);
                    if ((style & SWT.FULL_SELECTION) !is 0) {
                        backgroundRect = rect;
                    } else {
                        backgroundRect = item.getBounds (index, true, false, false, false, true, hDC);
                    }
                }
            } else {
                selectionForeground = -1;
                ignoreDrawForeground = ignoreDrawBackground = ignoreDrawSelection = ignoreDrawFocus = ignoreDrawHot = false;
                OS.SetRect (rect, x, nmcd.nmcd.rc.top, x + width, nmcd.nmcd.rc.bottom);
                backgroundRect = rect;
            }
            int clrText = -1, clrTextBk = -1;
            auto hFont = item.fontHandle (index);
            if (selectionForeground !is -1) clrText = selectionForeground;
            if (OS.IsWindowEnabled (handle)) {
                bool drawForeground = false;
                if (selected) {
                    if (i !is 0 && (style & SWT.FULL_SELECTION) is 0) {
                        OS.SetTextColor (hDC, getForegroundPixel ());
                        OS.SetBkColor (hDC, getBackgroundPixel ());
                        drawForeground = drawBackground_ = true;
                    }
                } else {
                    drawForeground = drawBackground_ = true;
                }
                if (drawForeground) {
                    clrText = item.cellForeground !is null ? item.cellForeground [index] : -1;
                    if (clrText is -1) clrText = item.foreground;
                }
                if (drawBackground_) {
                    clrTextBk = item.cellBackground !is null ? item.cellBackground [index] : -1;
                    if (clrTextBk is -1) clrTextBk = item.background;
                    if (clrTextBk is -1 && index is sortIndex) clrTextBk = clrSortBk;
                }
            } else {
                if (clrTextBk is -1 && index is sortIndex) {
                    drawBackground_ = true;
                    clrTextBk = clrSortBk;
                }
            }
            if (explorerTheme) {
                if (selected || (nmcd.nmcd.uItemState & OS.CDIS_HOT) !is 0) {
                    if ((style & SWT.FULL_SELECTION) !is 0) {
                        drawBackground_ = false;
                    } else {
                        if (i is 0) {
                            drawBackground_ = false;
                            if (!hooks (SWT.EraseItem)) drawText = false;
                        }
                    }
                }
            }
            if (drawItem) {
                if (i !is 0) {
                    if (hooks (SWT.MeasureItem)) {
                        sendMeasureItemEvent (item, index, hDC);
                        if (isDisposed () || item.isDisposed ()) break;
                    }
                    if (hooks (SWT.EraseItem)) {
                        RECT* cellRect = item.getBounds (index, true, true, true, true, true, hDC);
                        int nSavedDC = OS.SaveDC (hDC);
                        GCData data = new GCData ();
                        data.device = display;
                        data.foreground = OS.GetTextColor (hDC);
                        data.background = OS.GetBkColor (hDC);
                        if (!selected || (style & SWT.FULL_SELECTION) is 0) {
                            if (clrText !is -1) data.foreground = clrText;
                            if (clrTextBk !is -1) data.background = clrTextBk;
                        }
                        data.font = item.getFont (index);
                        data.uiState = cast(int)/*64bit*/OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
                        GC gc = GC.win32_new (hDC, data);
                        Event event = new Event ();
                        event.item = item;
                        event.index = index;
                        event.gc = gc;
                        event.detail |= SWT.FOREGROUND;
                        if (clrTextBk !is -1) event.detail |= SWT.BACKGROUND;
                        if ((style & SWT.FULL_SELECTION) !is 0) {
                            if (hot) event.detail |= SWT.HOT;
                            if (selected) event.detail |= SWT.SELECTED;
                            if (!explorerTheme) {
                                //if ((nmcd.uItemState & OS.CDIS_FOCUS) !is 0) {
                                if (OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0) is nmcd.nmcd.dwItemSpec) {
                                    if (handle is OS.GetFocus ()) {
                                        auto uiState = OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
                                        if ((uiState & OS.UISF_HIDEFOCUS) is 0) event.detail |= SWT.FOCUSED;
                                    }
                                }
                            }
                        }
                        event.x = cellRect.left;
                        event.y = cellRect.top;
                        event.width = cellRect.right - cellRect.left;
                        event.height = cellRect.bottom - cellRect.top;
                        gc.setClipping (event.x, event.y, event.width, event.height);
                        sendEvent (SWT.EraseItem, event);
                        event.gc = null;
                        int newTextClr = data.foreground;
                        gc.dispose ();
                        OS.RestoreDC (hDC, nSavedDC);
                        if (isDisposed () || item.isDisposed ()) break;
                        if (event.doit) {
                            ignoreDrawForeground = (event.detail & SWT.FOREGROUND) is 0;
                            ignoreDrawBackground = (event.detail & SWT.BACKGROUND) is 0;
                            if ((style & SWT.FULL_SELECTION) !is 0) {
                                ignoreDrawSelection = (event.detail & SWT.SELECTED) is 0;
                                ignoreDrawFocus = (event.detail & SWT.FOCUSED) is 0;
                                ignoreDrawHot = (event.detail & SWT.HOT) is 0;
                            }
                        } else {
                            ignoreDrawForeground = ignoreDrawBackground = ignoreDrawSelection = ignoreDrawFocus = ignoreDrawHot = true;
                        }
                        if (selected && ignoreDrawSelection) ignoreDrawHot = true;
                        if ((style & SWT.FULL_SELECTION) !is 0) {
                            if (ignoreDrawSelection) ignoreFullSelection = true;
                            if (!ignoreDrawSelection || !ignoreDrawHot) {
                                if (!selected && !hot) {
                                    selectionForeground = OS.GetSysColor (OS.COLOR_HIGHLIGHTTEXT);
                                } else {
                                    if (!explorerTheme) {
                                        drawBackground_ = true;
                                        ignoreDrawBackground = false;
                                        if ((handle is OS.GetFocus () || display.getHighContrast ()) && OS.IsWindowEnabled (handle)) {
                                            clrTextBk = OS.GetSysColor (OS.COLOR_HIGHLIGHT);
                                        } else {
                                            clrTextBk = OS.GetSysColor (OS.COLOR_3DFACE);
                                        }
                                        if (!ignoreFullSelection && index is columnCount - 1) {
                                            RECT* selectionRect = new RECT ();
                                            OS.SetRect (selectionRect, backgroundRect.left, backgroundRect.top, nmcd.nmcd.rc.right, backgroundRect.bottom);
                                            backgroundRect = selectionRect;
                                        }
                                    } else {
                                        RECT pRect;
                                        OS.SetRect (&pRect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
                                        if (columnCount > 0 && hwndHeader !is null) {
                                            int totalWidth = 0;
                                            HDITEM hdItem;
                                            hdItem.mask = OS.HDI_WIDTH;
                                            for (int j=0; j<columnCount; j++) {
                                                OS.SendMessage (hwndHeader, OS.HDM_GETITEM, j, &hdItem);
                                                totalWidth += hdItem.cxy;
                                            }
                                            if (totalWidth > clientRect.right - clientRect.left) {
                                                pRect.left = 0;
                                                pRect.right = totalWidth;
                                            } else {
                                                pRect.left = clientRect.left;
                                                pRect.right = clientRect.right;
                                            }
                                            if (index is columnCount - 1) {
                                                RECT* selectionRect = new RECT ();
                                                OS.SetRect (selectionRect, backgroundRect.left, backgroundRect.top, pRect.right, backgroundRect.bottom);
                                                backgroundRect = selectionRect;
                                            }
                                        }
                                        auto hTheme = OS.OpenThemeData (handle, cast(TCHAR*) Display.TREEVIEW);
                                        int iStateId = selected ? OS.TREIS_SELECTED : OS.TREIS_HOT;
                                        if (OS.GetFocus () !is handle && selected && !hot) iStateId = OS.TREIS_SELECTEDNOTFOCUS;
                                        OS.DrawThemeBackground (hTheme, hDC, OS.TVP_TREEITEM, iStateId, &pRect, backgroundRect);
                                        OS.CloseThemeData (hTheme);
                                    }
                                }
                            } else {
                                if (selected) {
                                    selectionForeground = newTextClr;
                                    if (!explorerTheme) {
                                        if (clrTextBk is -1 && OS.IsWindowEnabled (handle)) {
                                            Control control = findBackgroundControl ();
                                            if (control is null) control = this;
                                            clrTextBk = control.getBackgroundPixel ();
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (selectionForeground !is -1) clrText = selectionForeground;
                }
                if (!ignoreDrawBackground) {
                    if (clrTextBk !is -1) {
                        if (drawBackground_) fillBackground (hDC, clrTextBk, backgroundRect);
                    } else {
                        Control control = findImageControl ();
                        if (control !is null) {
                            if (i is 0) {
                                int right = Math.min (rect.right, width);
                                OS.SetRect (rect, rect.left, rect.top, right, rect.bottom);
                                if (drawBackground_) fillImageBackground (hDC, control, rect);
                            } else {
                                if (drawBackground_) fillImageBackground (hDC, control, rect);
                            }
                        }
                    }
                }
                rect.left += INSET - 1;
                if (drawImage) {
                    Image image = null;
                    if (index is 0) {
                        image = item.image;
                    } else {
                        Image [] images  = item.images;
                        if (images !is null) image = images [index];
                    }
                    int inset = i !is 0 ? INSET : 0;
                    int offset = i !is 0 ? INSET : INSET + 2;
                    if (image !is null) {
                        Rectangle bounds = image.getBounds ();
                        if (size is null) size = getImageSize ();
                        if (!ignoreDrawForeground) {
                            //int y1 = rect.top + (index is 0 ? (getItemHeight () - size.y) / 2 : 0);
                            int y1 = rect.top;
                            int x1 = Math.max (rect.left, rect.left - inset + 1);
                            GCData data = new GCData();
                            data.device = display;
                            GC gc = GC.win32_new (hDC, data);
                            gc.setClipping (x1, rect.top, rect.right - x1, rect.bottom - rect.top);
                            gc.drawImage (image, 0, 0, bounds.width, bounds.height, x1, y1, size.x, size.y);
                            OS.SelectClipRgn (hDC, null);
                            gc.dispose ();
                        }
                        OS.SetRect (rect, rect.left + size.x + offset, rect.top, rect.right - inset, rect.bottom);
                    } else {
                        if (i is 0) {
                            if (OS.SendMessage (handle, OS.TVM_GETIMAGELIST, OS.TVSIL_NORMAL, 0) !is 0) {
                                if (size is null) size = getImageSize ();
                                rect.left = Math.min (rect.left + size.x + offset, rect.right);
                            }
                        } else {
                            OS.SetRect (rect, rect.left + offset, rect.top, rect.right - inset, rect.bottom);
                        }
                    }
                }
                if (drawText) {
                    /*
                    * Bug in Windows.  When DrawText() is used with DT_VCENTER
                    * and DT_ENDELLIPSIS, the ellipsis can draw outside of the
                    * rectangle when the rectangle is empty.  The fix is avoid
                    * all text drawing for empty rectangles.
                    */
                    if (rect.left < rect.right) {
                        String string = null;
                        if (index is 0) {
                            string = item.text;
                        } else {
                            String [] strings  = item.strings;
                            if (strings !is null) string = strings [index];
                        }
                        if (string !is null) {
                            if (hFont !is cast(HFONT)-1) hFont = cast(HFONT)OS.SelectObject (hDC, hFont);
                            if (clrText !is -1) clrText = OS.SetTextColor (hDC, clrText);
                            if (clrTextBk !is -1) clrTextBk = OS.SetBkColor (hDC, clrTextBk);
                            int flags = OS.DT_NOPREFIX | OS.DT_SINGLELINE | OS.DT_VCENTER;
                            if (i !is 0) flags |= OS.DT_ENDELLIPSIS;
                            TreeColumn column = columns !is null ? columns [index] : null;
                            if (column !is null) {
                                if ((column.style & SWT.CENTER) !is 0) flags |= OS.DT_CENTER;
                                if ((column.style & SWT.RIGHT) !is 0) flags |= OS.DT_RIGHT;
                            }
                            StringT buffer = StrToTCHARs (getCodePage (), string, false);
                            if (!ignoreDrawForeground) OS.DrawText (hDC, buffer.ptr, cast(int)/*64bit*/buffer.length, rect, flags);
                            OS.DrawText (hDC, buffer.ptr, cast(int)/*64bit*/buffer.length, rect, flags | OS.DT_CALCRECT);
                            if (hFont !is cast(HFONT)-1) hFont = cast(HFONT)OS.SelectObject (hDC, hFont);
                            if (clrText !is -1) clrText = OS.SetTextColor (hDC, clrText);
                            if (clrTextBk !is -1) clrTextBk = OS.SetBkColor (hDC, clrTextBk);
                        }
                    }
                }
            }
            if (selectionForeground !is -1) clrText = selectionForeground;
            if (hooks (SWT.PaintItem)) {
                RECT* itemRect = item.getBounds (index, true, true, false, false, false, hDC);
                int nSavedDC = OS.SaveDC (hDC);
                GCData data = new GCData ();
                data.device = display;
                data.font = item.getFont (index);
                data.foreground = OS.GetTextColor (hDC);
                data.background = OS.GetBkColor (hDC);
                if (selected && (style & SWT.FULL_SELECTION) !is 0) {
                    if (selectionForeground !is -1) data.foreground = selectionForeground;
                } else {
                    if (clrText !is -1) data.foreground = clrText;
                    if (clrTextBk !is -1) data.background = clrTextBk;
                }
                data.uiState = cast(int)/*64bit*/OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
                GC gc = GC.win32_new (hDC, data);
                Event event = new Event ();
                event.item = item;
                event.index = index;
                event.gc = gc;
                event.detail |= SWT.FOREGROUND;
                if (clrTextBk !is -1) event.detail |= SWT.BACKGROUND;
                if (hot) event.detail |= SWT.HOT;
                if (selected && (i is 0 /*nmcd.iSubItem is 0*/ || (style & SWT.FULL_SELECTION) !is 0)) {
                    event.detail |= SWT.SELECTED;
                }
                if (!explorerTheme) {
                    //if ((nmcd.uItemState & OS.CDIS_FOCUS) !is 0) {
                    if (OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0) is nmcd.nmcd.dwItemSpec) {
                        if (i is 0 /*nmcd.iSubItem is 0*/ || (style & SWT.FULL_SELECTION) !is 0) {
                            if (handle is OS.GetFocus ()) {
                                auto uiState = OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
                                if ((uiState & OS.UISF_HIDEFOCUS) is 0) event.detail |= SWT.FOCUSED;
                            }
                        }
                    }
                }
                event.x = itemRect.left;
                event.y = itemRect.top;
                event.width = itemRect.right - itemRect.left;
                event.height = itemRect.bottom - itemRect.top;
                RECT* cellRect = item.getBounds (index, true, true, true, true, true, hDC);
                int cellWidth = cellRect.right - cellRect.left;
                int cellHeight = cellRect.bottom - cellRect.top;
                gc.setClipping (cellRect.left, cellRect.top, cellWidth, cellHeight);
                sendEvent (SWT.PaintItem, event);
                if (data.focusDrawn) focusRect = null;
                event.gc = null;
                gc.dispose ();
                OS.RestoreDC (hDC, nSavedDC);
                if (isDisposed () || item.isDisposed ()) break;
            }
        }
        x += width;
        if (x > clientRect.right) break;
    }
    if (linesVisible) {
        if ((style & SWT.FULL_SELECTION) !is 0) {
            if (columnCount !is 0) {
                HDITEM hdItem;
                hdItem.mask = OS.HDI_WIDTH;
                OS.SendMessage (hwndHeader, OS.HDM_GETITEM, 0, &hdItem);
                RECT rect;
                OS.SetRect (&rect, nmcd.nmcd.rc.left + hdItem.cxy, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
                OS.DrawEdge (hDC, &rect, OS.BDR_SUNKENINNER, OS.BF_BOTTOM);
            }
        }
        RECT rect;
        OS.SetRect (&rect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
        OS.DrawEdge (hDC, &rect, OS.BDR_SUNKENINNER, OS.BF_BOTTOM);
    }
    if (!ignoreDrawFocus && focusRect !is null) {
        OS.DrawFocusRect (hDC, focusRect);
        focusRect = null;
    } else {
        if (!explorerTheme) {
            if (handle is OS.GetFocus ()) {
                auto uiState = OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
                if ((uiState & OS.UISF_HIDEFOCUS) is 0) {
                    auto hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
                    if (hItem is item.handle) {
                        if (!ignoreDrawFocus && findImageControl () !is null) {
                            if ((style & SWT.FULL_SELECTION) !is 0) {
                                RECT focusRect;
                                OS.SetRect (&focusRect, 0, nmcd.nmcd.rc.top, clientRect.right + 1, nmcd.nmcd.rc.bottom);
                                OS.DrawFocusRect (hDC, &focusRect);
                            } else {
                                int index = cast(int)/*64bit*/OS.SendMessage (hwndHeader, OS.HDM_ORDERTOINDEX, 0, 0);
                                RECT* focusRect = item.getBounds (index, true, false, false, false, false, hDC);
                                RECT* clipRect = item.getBounds (index, true, false, false, false, true, hDC);
                                OS.IntersectClipRect (hDC, clipRect.left, clipRect.top, clipRect.right, clipRect.bottom);
                                OS.DrawFocusRect (hDC, focusRect);
                                OS.SelectClipRgn (hDC, null);
                            }
                        }
                    }
                }
            }
        }
    }
    return new LRESULT (OS.CDRF_DODEFAULT);
}

LRESULT CDDS_ITEMPREPAINT (NMTVCUSTOMDRAW* nmcd, WPARAM wParam, LPARAM lParam) {
    /*
    * Even when custom draw is being ignored, the font needs
    * to be selected into the HDC so that the item bounds are
    * measured correctly.
    */
    TreeItem item = getItem (nmcd);
    /*
    * Feature in Windows.  When a new tree item is inserted
    * using TVM_INSERTITEM and the tree is using custom draw,
    * a NM_CUSTOMDRAW is sent before TVM_INSERTITEM returns
    * and before the item is added to the items array.  The
    * fix is to check for null.
    *
    * NOTE: This only happens on XP with the version 6.00 of
    * COMCTL32.DLL,
    */
    if (item is null) return null;
    auto hDC = nmcd.nmcd.hdc;
    int index = hwndHeader !is null ? cast(int)/*64bit*/OS.SendMessage (hwndHeader, OS.HDM_ORDERTOINDEX, 0, 0) : 0;
    auto hFont = item.fontHandle (index);
    if (hFont !is cast(HFONT)-1) OS.SelectObject (hDC, hFont);
    if (ignoreCustomDraw || nmcd.nmcd.rc.left is nmcd.nmcd.rc.right) {
        return new LRESULT (hFont is cast(HFONT)-1 ? OS.CDRF_DODEFAULT : OS.CDRF_NEWFONT);
    }
    RECT* clipRect = null;
    if (columnCount !is 0) {
        bool clip = !printClient;
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
            clip = true;
        }
        if (clip) {
            clipRect = new RECT ();
            HDITEM hdItem;
            hdItem.mask = OS.HDI_WIDTH;
            OS.SendMessage (hwndHeader, OS.HDM_GETITEM, index, &hdItem);
            OS.SetRect (clipRect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.left + hdItem.cxy, nmcd.nmcd.rc.bottom);
        }
    }
    int clrText = -1, clrTextBk = -1;
    if (OS.IsWindowEnabled (handle)) {
        clrText = item.cellForeground !is null ? item.cellForeground [index] : -1;
        if (clrText is -1) clrText = item.foreground;
        clrTextBk = item.cellBackground !is null ? item.cellBackground [index] : -1;
        if (clrTextBk is -1) clrTextBk = item.background;
    }
    int clrSortBk = -1;
    if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
        if (sortColumn !is null && sortDirection !is SWT.NONE) {
            if (findImageControl () is null) {
                if (indexOf (sortColumn) is index) {
                    clrSortBk = getSortColumnPixel ();
                    if (clrTextBk is -1) clrTextBk = clrSortBk;
                }
            }
        }
    }
    bool selected = isItemSelected (nmcd);
    bool hot = explorerTheme && (nmcd.nmcd.uItemState & OS.CDIS_HOT) !is 0;
    bool focused = explorerTheme && (nmcd.nmcd.uItemState & OS.CDIS_FOCUS) !is 0;
    if (OS.IsWindowVisible (handle) && nmcd.nmcd.rc.left < nmcd.nmcd.rc.right && nmcd.nmcd.rc.top < nmcd.nmcd.rc.bottom) {
        if (hFont !is cast(HFONT)-1) OS.SelectObject (hDC, hFont);
        if (linesVisible) {
            RECT rect;
            OS.SetRect (&rect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
            OS.DrawEdge (hDC, &rect, OS.BDR_SUNKENINNER, OS.BF_BOTTOM);
        }
        //TODO - BUG - measure and erase sent when first column is clipped
        Event measureEvent = null;
        if (hooks (SWT.MeasureItem)) {
            measureEvent = sendMeasureItemEvent (item, index, hDC);
            if (isDisposed () || item.isDisposed ()) return null;
        }
        selectionForeground = -1;
        ignoreDrawForeground = ignoreDrawBackground = ignoreDrawSelection = ignoreDrawFocus = ignoreDrawHot = ignoreFullSelection = false;
        if (hooks (SWT.EraseItem)) {
            RECT rect;
            OS.SetRect (&rect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
            RECT* cellRect = item.getBounds (index, true, true, true, true, true, hDC);
            if (clrSortBk !is -1) {
                drawBackground (hDC, cellRect, clrSortBk);
            } else {
                if (OS.IsWindowEnabled (handle) || findImageControl () !is null) {
                    drawBackground (hDC, &rect);
                } else {
                    fillBackground (hDC, OS.GetBkColor (hDC), &rect);
                }
            }
            int nSavedDC = OS.SaveDC (hDC);
            GCData data = new GCData ();
            data.device = display;
            if (selected && explorerTheme) {
                data.foreground = OS.GetSysColor (OS.COLOR_WINDOWTEXT);
            } else {
                data.foreground = OS.GetTextColor (hDC);
            }
            data.background = OS.GetBkColor (hDC);
            if (!selected) {
                if (clrText !is -1) data.foreground = clrText;
                if (clrTextBk !is -1) data.background = clrTextBk;
            }
            data.uiState = cast(int)/*64bit*/OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
            data.font = item.getFont (index);
            GC gc = GC.win32_new (hDC, data);
            Event event = new Event ();
            event.index = index;
            event.item = item;
            event.gc = gc;
            event.detail |= SWT.FOREGROUND;
            if (clrTextBk !is -1) event.detail |= SWT.BACKGROUND;
            if (hot) event.detail |= SWT.HOT;
            if (selected) event.detail |= SWT.SELECTED;
            if (!explorerTheme) {
                //if ((nmcd.uItemState & OS.CDIS_FOCUS) !is 0) {
                if (OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0) is nmcd.nmcd.dwItemSpec) {
                    if (handle is OS.GetFocus ()) {
                        auto uiState = OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
                        if ((uiState & OS.UISF_HIDEFOCUS) is 0) {
                            focused = true;
                            event.detail |= SWT.FOCUSED;
                        }
                    }
                }
            }
            event.x = cellRect.left;
            event.y = cellRect.top;
            event.width = cellRect.right - cellRect.left;
            event.height = cellRect.bottom - cellRect.top;
            gc.setClipping (event.x, event.y, event.width, event.height);
            sendEvent (SWT.EraseItem, event);
            event.gc = null;
            int newTextClr = data.foreground;
            gc.dispose ();
            OS.RestoreDC (hDC, nSavedDC);
            if (isDisposed () || item.isDisposed ()) return null;
            if (event.doit) {
                ignoreDrawForeground = (event.detail & SWT.FOREGROUND) is 0;
                ignoreDrawBackground = (event.detail & SWT.BACKGROUND) is 0;
                ignoreDrawSelection = (event.detail & SWT.SELECTED) is 0;
                ignoreDrawFocus = (event.detail & SWT.FOCUSED) is 0;
                ignoreDrawHot = (event.detail & SWT.HOT) is 0;
            } else {
                ignoreDrawForeground = ignoreDrawBackground = ignoreDrawSelection = ignoreDrawFocus = ignoreDrawHot = true;
            }
            if (selected && ignoreDrawSelection) ignoreDrawHot = true;
            if (!ignoreDrawBackground && clrTextBk !is -1) {
                bool draw = !selected && !hot;
                if (!explorerTheme && selected) draw = !ignoreDrawSelection;
                if (draw) {
                    if (columnCount is 0) {
                        if ((style & SWT.FULL_SELECTION) !is 0) {
                            fillBackground (hDC, clrTextBk, &rect);
                        } else {
                            RECT* textRect = item.getBounds (index, true, false, false, false, true, hDC);
                            if (measureEvent !is null) {
                                textRect.right = Math.min (cellRect.right, measureEvent.x + measureEvent.width);
                            }
                            fillBackground (hDC, clrTextBk, textRect);
                        }
                    } else {
                        fillBackground (hDC, clrTextBk, cellRect);
                    }
                }
            }
            if (ignoreDrawSelection) ignoreFullSelection = true;
            if (!ignoreDrawSelection || !ignoreDrawHot) {
                if (!selected && !hot) {
                    selectionForeground = clrText = OS.GetSysColor (OS.COLOR_HIGHLIGHTTEXT);
                }
                if (explorerTheme) {
                    if ((style & SWT.FULL_SELECTION) is 0) {
                        RECT* pRect = item.getBounds (index, true, true, false, false, false, hDC);
                        RECT* pClipRect = item.getBounds (index, true, true, true, false, true, hDC);
                        if (measureEvent !is null) {
                            pRect.right = Math.min (pClipRect.right, measureEvent.x + measureEvent.width);
                        } else {
                            pRect.right += EXPLORER_EXTRA;
                            pClipRect.right += EXPLORER_EXTRA;
                        }
                        pRect.left -= EXPLORER_EXTRA;
                        pClipRect.left -= EXPLORER_EXTRA;
                        auto hTheme = OS.OpenThemeData (handle, Display.TREEVIEW.ptr);
                        int iStateId = selected ? OS.TREIS_SELECTED : OS.TREIS_HOT;
                        if (OS.GetFocus () !is handle && selected && !hot) iStateId = OS.TREIS_SELECTEDNOTFOCUS;
                        OS.DrawThemeBackground (hTheme, hDC, OS.TVP_TREEITEM, iStateId, pRect, pClipRect);
                        OS.CloseThemeData (hTheme);
                    }
                } else {
                    /*
                    * Feature in Windows.  When the tree has the style
                    * TVS_FULLROWSELECT, the background color for the
                    * entire row is filled when an item is painted,
                    * drawing on top of any custom drawing.  The fix
                    * is to emulate TVS_FULLROWSELECT.
                    */
                    if ((style & SWT.FULL_SELECTION) !is 0) {
                        if ((style & SWT.FULL_SELECTION) !is 0 && columnCount is 0) {
                            fillBackground (hDC, OS.GetBkColor (hDC), &rect);
                        } else {
                            fillBackground (hDC, OS.GetBkColor (hDC), cellRect);
                        }
                    } else {
                        RECT* textRect = item.getBounds (index, true, false, false, false, true, hDC);
                        if (measureEvent !is null) {
                            textRect.right = Math.min (cellRect.right, measureEvent.x + measureEvent.width);
                        }
                        fillBackground (hDC, OS.GetBkColor (hDC), textRect);
                    }
                }
            } else {
                if (selected || hot) {
                    selectionForeground = clrText = newTextClr;
                    ignoreDrawSelection = ignoreDrawHot = true;
                }
                if (explorerTheme) {
                    nmcd.nmcd.uItemState |= OS.CDIS_DISABLED;
                    /*
                    * Feature in Windows.  On Vista only, when the text
                    * color is unchanged and an item is asked to draw
                    * disabled, it uses the disabled color.  The fix is
                    * to modify the color so that is it no longer equal.
                    */
                    int newColor = clrText is -1 ? getForegroundPixel () : clrText;
                    if (nmcd.clrText is newColor) {
                        nmcd.clrText |= 0x20000000;
                        if (nmcd.clrText is newColor) nmcd.clrText &= ~0x20000000;
                    } else {
                        nmcd.clrText = newColor;
                    }
                    OS.MoveMemory (lParam, nmcd, NMTVCUSTOMDRAW.sizeof);
                }
            }
            if (focused && !ignoreDrawFocus && (style & SWT.FULL_SELECTION) is 0) {
                RECT* textRect = item.getBounds (index, true, explorerTheme, false, false, true, hDC);
                if (measureEvent !is null) {
                    textRect.right = Math.min (cellRect.right, measureEvent.x + measureEvent.width);
                }
                nmcd.nmcd.uItemState &= ~OS.CDIS_FOCUS;
                OS.MoveMemory (lParam, nmcd, NMTVCUSTOMDRAW.sizeof);
                focusRect = textRect;
            }
            if (explorerTheme) {
                if (selected || (hot && ignoreDrawHot)) nmcd.nmcd.uItemState &= ~OS.CDIS_HOT;
                OS.MoveMemory (lParam, nmcd, NMTVCUSTOMDRAW.sizeof);
            }
            RECT* itemRect = item.getBounds (index, true, true, false, false, false, hDC);
            OS.SaveDC (hDC);
            OS.SelectClipRgn (hDC, null);
            if (explorerTheme) {
                itemRect.left -= EXPLORER_EXTRA;
                itemRect.right += EXPLORER_EXTRA;
            }
            //TODO - bug in Windows selection or SWT itemRect
            /*if (selected)*/ itemRect.right++;
            if (linesVisible) itemRect.bottom++;
            if (clipRect !is null) {
                OS.IntersectClipRect (hDC, clipRect.left, clipRect.top, clipRect.right, clipRect.bottom);
            }
            OS.ExcludeClipRect (hDC, itemRect.left, itemRect.top, itemRect.right, itemRect.bottom);
            return new LRESULT (OS.CDRF_DODEFAULT | OS.CDRF_NOTIFYPOSTPAINT);
        }
        /*
        * Feature in Windows.  When the tree has the style
        * TVS_FULLROWSELECT, the background color for the
        * entire row is filled when an item is painted,
        * drawing on top of any custom drawing.  The fix
        * is to emulate TVS_FULLROWSELECT.
        */
        if ((style & SWT.FULL_SELECTION) !is 0) {
            int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
            if ((bits & OS.TVS_FULLROWSELECT) is 0) {
                RECT rect;
                OS.SetRect (&rect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
                if (selected) {
                    fillBackground (hDC, OS.GetBkColor (hDC), &rect);
                } else {
                    if (OS.IsWindowEnabled (handle)) drawBackground (hDC, &rect);
                }
                nmcd.nmcd.uItemState &= ~OS.CDIS_FOCUS;
                OS.MoveMemory (lParam, nmcd, NMTVCUSTOMDRAW.sizeof);
            }
        }
    }
    LRESULT result = null;
    if (clrText is -1 && clrTextBk is -1 && hFont is cast(HFONT)-1) {
        result = new LRESULT (OS.CDRF_DODEFAULT | OS.CDRF_NOTIFYPOSTPAINT);
    } else {
        result = new LRESULT (OS.CDRF_NEWFONT | OS.CDRF_NOTIFYPOSTPAINT);
        if (hFont !is cast(HFONT)-1) OS.SelectObject (hDC, hFont);
        if (OS.IsWindowEnabled (handle) && OS.IsWindowVisible (handle)) {
            /*
            * Feature in Windows.  Windows does not fill the entire cell
            * with the background color when TVS_FULLROWSELECT is not set.
            * The fix is to fill the cell with the background color.
            */
            if (clrTextBk !is -1) {
                int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
                if ((bits & OS.TVS_FULLROWSELECT) is 0) {
                    if (columnCount !is 0 && hwndHeader !is null) {
                        RECT rect;
                        HDITEM hdItem;
                        hdItem.mask = OS.HDI_WIDTH;
                        OS.SendMessage (hwndHeader, OS.HDM_GETITEM, index, &hdItem);
                        OS.SetRect (&rect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.left + hdItem.cxy, nmcd.nmcd.rc.bottom);
                        if (OS.COMCTL32_MAJOR < 6 || !OS.IsAppThemed ()) {
                            RECT itemRect;
                            if (OS.TreeView_GetItemRect (handle, cast(HTREEITEM)item.handle, &itemRect, true)) {
                                rect.left = Math.min (itemRect.left, rect.right);
                            }
                        }
                        if ((style & SWT.FULL_SELECTION) !is 0) {
                            if (!selected) fillBackground (hDC, clrTextBk, &rect);
                        } else {
                            if (explorerTheme) {
                                if (!selected && !hot) fillBackground (hDC, clrTextBk, &rect);
                            } else {
                                fillBackground (hDC, clrTextBk, &rect);
                            }
                        }
                    } else {
                        if ((style & SWT.FULL_SELECTION) !is 0) {
                            RECT rect;
                            OS.SetRect (&rect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
                            if (!selected) fillBackground (hDC, clrTextBk, &rect);
                        }
                    }
                }
            }
            if (!selected) {
                nmcd.clrText = clrText is -1 ? getForegroundPixel () : clrText;
                nmcd.clrTextBk = clrTextBk is -1 ? getBackgroundPixel () : clrTextBk;
                OS.MoveMemory (lParam, nmcd, NMTVCUSTOMDRAW.sizeof);
            }
        }
    }
    if (OS.IsWindowEnabled (handle)) {
        /*
        * On Vista only, when an item is asked to draw disabled,
        * the background of the text is not filled with the
        * background color of the tree.  This is true for both
        * regular and full selection trees.  In order to draw a
        * background image, mark the item as disabled using
        * CDIS_DISABLED (when not selected) and set the text
        * to the regular text color to avoid drawing disabled.
        */
        if (explorerTheme) {
            if (findImageControl () !is  null) {
                if (!selected && (nmcd.nmcd.uItemState & (OS.CDIS_HOT | OS.CDIS_SELECTED)) is 0) {
                    nmcd.nmcd.uItemState |= OS.CDIS_DISABLED;
                    /*
                    * Feature in Windows.  On Vista only, when the text
                    * color is unchanged and an item is asked to draw
                    * disabled, it uses the disabled color.  The fix is
                    * to modify the color so it is no longer equal.
                    */
                    int newColor = clrText is -1 ? getForegroundPixel () : clrText;
                    if (nmcd.clrText is newColor) {
                        nmcd.clrText |= 0x20000000;
                        if (nmcd.clrText is newColor) nmcd.clrText &= ~0x20000000;
                    } else {
                        nmcd.clrText = newColor;
                    }
                    OS.MoveMemory (lParam, nmcd, NMTVCUSTOMDRAW.sizeof);
                    if (clrTextBk !is -1) {
                        if ((style & SWT.FULL_SELECTION) !is 0) {
                            RECT rect;
                            if (columnCount !is 0) {
                                HDITEM hdItem;
                                hdItem.mask = OS.HDI_WIDTH;
                                OS.SendMessage (hwndHeader, OS.HDM_GETITEM, index, &hdItem);
                                OS.SetRect (&rect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.left + hdItem.cxy, nmcd.nmcd.rc.bottom);
                            } else {
                                OS.SetRect (&rect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
                            }
                            fillBackground (hDC, clrTextBk, &rect);
                        } else {
                            RECT* textRect = item.getBounds (index, true, false, true, false, true, hDC);
                            fillBackground (hDC, clrTextBk, textRect);
                        }
                    }
                }
            }
        }
    } else {
        /*
        * Feature in Windows.  When the tree is disabled, it draws
        * with a gray background over the sort column.  The fix is
        * to fill the background with the sort column color.
        */
        if (clrSortBk !is -1) {
            RECT rect;
            HDITEM hdItem;
            hdItem.mask = OS.HDI_WIDTH;
            OS.SendMessage (hwndHeader, OS.HDM_GETITEM, index, &hdItem);
            OS.SetRect (&rect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.left + hdItem.cxy, nmcd.nmcd.rc.bottom);
            fillBackground (hDC, clrSortBk, &rect);
        }
    }
    OS.SaveDC (hDC);
    if (clipRect !is null) {
        auto hRgn = OS.CreateRectRgn (clipRect.left, clipRect.top, clipRect.right, clipRect.bottom);
        POINT lpPoint;
        OS.GetWindowOrgEx (hDC, &lpPoint);
        OS.OffsetRgn (hRgn, -lpPoint.x, -lpPoint.y);
        OS.SelectClipRgn (hDC, hRgn);
        OS.DeleteObject (hRgn);
    }
    return result;
}

LRESULT CDDS_POSTPAINT (NMTVCUSTOMDRAW* nmcd, WPARAM wParam, LPARAM lParam) {
    if (ignoreCustomDraw) return null;
    if (OS.IsWindowVisible (handle)) {
        if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
            if (sortColumn !is null && sortDirection !is SWT.NONE) {
                if (findImageControl () is null) {
                    int index = indexOf (sortColumn);
                    if (index !is -1) {
                        int top = nmcd.nmcd.rc.top;
                        /*
                        * Bug in Windows.  For some reason, during a collapse,
                        * when TVM_GETNEXTITEM is sent with TVGN_LASTVISIBLE
                        * and the collapse causes the item being collapsed
                        * to become the last visible item in the tree, the
                        * message takes a long time to process.  In order for
                        * the slowness to happen, the children of the item
                        * must have children.  Times of up to 11 seconds have
                        * been observed with 23 children, each having one
                        * child.  The fix is to use the bottom partially
                        * visible item rather than the last possible item
                        * that could be visible.
                        *
                        * NOTE: This problem only happens on Vista during
                        * WM_NOTIFY with NM_CUSTOMDRAW and CDDS_POSTPAINT.
                        */
                        HANDLE hItem;
                        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
                            hItem = getBottomItem ();
                        } else {
                            hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_LASTVISIBLE, 0);
                        }
                        if (hItem !is null) {
                            RECT rect;
                            if (OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hItem, &rect, false)) {
                                top = rect.bottom;
                            }
                        }
                        RECT rect;
                        OS.SetRect (&rect, nmcd.nmcd.rc.left, top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
                        RECT headerRect;
                        OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, index, &headerRect);
                        rect.left = headerRect.left;
                        rect.right = headerRect.right;
                        fillBackground (nmcd.nmcd.hdc, getSortColumnPixel (), &rect);
                    }
                }
            }
        }
        if (linesVisible) {
            auto hDC = nmcd.nmcd.hdc;
            if (hwndHeader !is null) {
                int x = 0;
                RECT rect;
                HDITEM hdItem;
                hdItem.mask = OS.HDI_WIDTH;
                for (int i=0; i<columnCount; i++) {
                    auto index = OS.SendMessage (hwndHeader, OS.HDM_ORDERTOINDEX, i, 0);
                    OS.SendMessage (hwndHeader, OS.HDM_GETITEM, index, &hdItem);
                    OS.SetRect (&rect, x, nmcd.nmcd.rc.top, x + hdItem.cxy, nmcd.nmcd.rc.bottom);
                    OS.DrawEdge (hDC, &rect, OS.BDR_SUNKENINNER, OS.BF_RIGHT);
                    x += hdItem.cxy;
                }
            }
            int height = 0;
            RECT rect;
            /*
            * Bug in Windows.  For some reason, during a collapse,
            * when TVM_GETNEXTITEM is sent with TVGN_LASTVISIBLE
            * and the collapse causes the item being collapsed
            * to become the last visible item in the tree, the
            * message takes a long time to process.  In order for
            * the slowness to happen, the children of the item
            * must have children.  Times of up to 11 seconds have
            * been observed with 23 children, each having one
            * child.  The fix is to use the bottom partially
            * visible item rather than the last possible item
            * that could be visible.
            *
            * NOTE: This problem only happens on Vista during
            * WM_NOTIFY with NM_CUSTOMDRAW and CDDS_POSTPAINT.
            */
            HANDLE hItem;
            if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
                hItem = getBottomItem ();
            } else {
                hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_LASTVISIBLE, 0);
            }
            if (hItem !is null) {
                if (OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hItem, &rect, false)) {
                    height = rect.bottom - rect.top;
                }
            }
            if (height is 0) {
                height = cast(int)/*64bit*/OS.SendMessage (handle, OS.TVM_GETITEMHEIGHT, 0, 0);
                OS.GetClientRect (handle, &rect);
                OS.SetRect (&rect, rect.left, rect.top, rect.right, rect.top + height);
                OS.DrawEdge (hDC, &rect, OS.BDR_SUNKENINNER, OS.BF_BOTTOM);
            }
            while (rect.bottom < nmcd.nmcd.rc.bottom) {
                int top = rect.top + height;
                OS.SetRect (&rect, rect.left, top, rect.right, top + height);
                OS.DrawEdge (hDC, &rect, OS.BDR_SUNKENINNER, OS.BF_BOTTOM);
            }
        }
    }
    return new LRESULT (OS.CDRF_DODEFAULT);
}

LRESULT CDDS_PREPAINT (NMTVCUSTOMDRAW* nmcd, WPARAM wParam, LPARAM lParam) {
    if (explorerTheme) {
        if ((OS.IsWindowEnabled (handle) && hooks (SWT.EraseItem)) || findImageControl () !is null) {
            RECT rect;
            OS.SetRect (&rect, nmcd.nmcd.rc.left, nmcd.nmcd.rc.top, nmcd.nmcd.rc.right, nmcd.nmcd.rc.bottom);
            drawBackground (nmcd.nmcd.hdc, &rect);
        }
    }
    return new LRESULT (OS.CDRF_NOTIFYITEMDRAW | OS.CDRF_NOTIFYPOSTPAINT);
}

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    if (hwndParent !is null && hwnd is hwndParent) {
        return OS.DefWindowProc (hwnd, msg, wParam, lParam);
    }
    if (hwndHeader !is null && hwnd is hwndHeader) {
        return OS.CallWindowProc (HeaderProc, hwnd, msg, wParam, lParam);
    }
    switch (msg) {
        case OS.WM_SETFOCUS: {
            /*
            * Feature in Windows.  When a tree control processes WM_SETFOCUS,
            * if no item is selected, the first item in the tree is selected.
            * This is unexpected and might clear the previous selection.
            * The fix is to detect that there is no selection and set it to
            * the first visible item in the tree.  If the item was not selected,
            * only the focus is assigned.
            */
            if ((style & SWT.SINGLE) !is 0) break;
            HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
            if (hItem is null) {
                hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_FIRSTVISIBLE, 0);
                if (hItem !is null) {
                    TVITEM tvItem;
                    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
                    tvItem.hItem = cast(HTREEITEM)hItem;
                    OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
                    hSelect = hItem;
                    ignoreDeselect = ignoreSelect = lockSelection = true;
                    OS.SendMessage (handle, OS.TVM_SELECTITEM, OS.TVGN_CARET, hItem);
                    ignoreDeselect = ignoreSelect = lockSelection = false;
                    hSelect = null;
                    if ((tvItem.state & OS.TVIS_SELECTED) is 0) {
                        OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                    }
                }
            }
            break;
        }
        default:
    }
    HANDLE hItem;
    bool redraw = false;
    switch (msg) {
        /* Keyboard messages */
        case OS.WM_KEYDOWN:
            if (wParam is OS.VK_CONTROL || wParam is OS.VK_SHIFT) break;
            goto case OS.WM_CHAR;
        case OS.WM_CHAR:
        case OS.WM_IME_CHAR:
        case OS.WM_KEYUP:
        case OS.WM_SYSCHAR:
        case OS.WM_SYSKEYDOWN:
        case OS.WM_SYSKEYUP:
            goto case OS.WM_HSCROLL;

        /* Scroll messages */
        case OS.WM_HSCROLL:
        case OS.WM_VSCROLL:
            goto case OS.WM_SIZE;

        /* Resize messages */
        case OS.WM_SIZE:
            redraw = findImageControl () !is null && drawCount is 0 && OS.IsWindowVisible (handle);
            if (redraw) OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
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
                hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_FIRSTVISIBLE, 0);
            }
            break;
        }
        default:
    }
    auto code = OS.CallWindowProc (TreeProc, hwnd, msg, wParam, lParam);
    switch (msg) {
        /* Keyboard messages */
        case OS.WM_KEYDOWN:
            if (wParam is OS.VK_CONTROL || wParam is OS.VK_SHIFT) break;
            goto case OS.WM_CHAR;
        case OS.WM_CHAR:
        case OS.WM_IME_CHAR:
        case OS.WM_KEYUP:
        case OS.WM_SYSCHAR:
        case OS.WM_SYSKEYDOWN:
        case OS.WM_SYSKEYUP:
            goto case OS.WM_HSCROLL;

        /* Scroll messages */
        case OS.WM_HSCROLL:
        case OS.WM_VSCROLL:
            goto case OS.WM_SIZE;

        /* Resize messages */
        case OS.WM_SIZE:
            if (redraw) {
                OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
                OS.InvalidateRect (handle, null, true);
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
                if (hItem !is cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_FIRSTVISIBLE, 0)) {
                    OS.InvalidateRect (handle, null, true);
                }
            }
            updateScrollBar ();
            break;
        }

        case OS.WM_PAINT:
            painted = true;
            break;
        default:
    }
    return code;
}

override void checkBuffered () {
    super.checkBuffered ();
    if ((style & SWT.VIRTUAL) !is 0) {
        style |= SWT.DOUBLE_BUFFERED;
        OS.SendMessage (handle, OS.TVM_SETSCROLLTIME, 0, 0);
    }
    if (EXPLORER_THEME) {
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0) && OS.IsAppThemed ()) {
            auto exStyle = OS.SendMessage (handle, OS.TVM_GETEXTENDEDSTYLE, 0, 0);
            if ((exStyle & OS.TVS_EX_DOUBLEBUFFER) !is 0) style |= SWT.DOUBLE_BUFFERED;
        }
    }
}

bool checkData (TreeItem item, bool redraw) {
    if ((style & SWT.VIRTUAL) is 0) return true;
    if (!item.cached) {
        TreeItem parentItem = item.getParentItem ();
        return checkData (item, parentItem is null ? indexOf (item) : parentItem.indexOf (item), redraw);
    }
    return true;
}

bool checkData (TreeItem item, int index, bool redraw) {
    if ((style & SWT.VIRTUAL) is 0) return true;
    if (!item.cached) {
        item.cached = true;
        Event event = new Event ();
        event.item = item;
        event.index = index;
        TreeItem oldItem = currentItem;
        currentItem = item;
        sendEvent (SWT.SetData, event);
        //widget could be disposed at this point
        currentItem = oldItem;
        if (isDisposed () || item.isDisposed ()) return false;
        if (redraw) item.redraw ();
    }
    return true;
}

override bool checkHandle (HWND hwnd) {
    return hwnd is handle || (hwndParent !is null && hwnd is hwndParent) || (hwndHeader !is null && hwnd is hwndHeader);
}

bool checkScroll (HANDLE hItem) {
    /*
    * Feature in Windows.  If redraw is turned off using WM_SETREDRAW
    * and a tree item that is not a child of the first root is selected or
    * scrolled using TVM_SELECTITEM or TVM_ENSUREVISIBLE, then scrolling
    * does not occur.  The fix is to detect this case, and make sure
    * that redraw is temporarily enabled.  To avoid flashing, DefWindowProc()
    * is called to disable redrawing.
    *
    * NOTE:  The code that actually works around the problem is in the
    * callers of this method.
    */
    if (drawCount is 0) return false;
    auto hRoot = OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
    auto hParent = OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_PARENT, hItem);
    while (hParent !is hRoot && hParent !is 0) {
        hParent = OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_PARENT, hParent);
    }
    return hParent is 0;
}

override protected void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

/**
 * Clears the item at the given zero-relative index in the receiver.
 * The text, icon and other attributes of the item are set to the default
 * value.  If the tree was created with the <code>SWT.VIRTUAL</code> style,
 * these attributes are requested again as needed.
 *
 * @param index the index of the item to clear
 * @param all <code>true</code> if all child items of the indexed item should be
 * cleared recursively, and <code>false</code> otherwise
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
 * @since 3.2
 */
public void clear (int index, bool all) {
    checkWidget ();
    HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
    if (hItem is null) error (SWT.ERROR_INVALID_RANGE);
    hItem = findItem (hItem, index);
    if (hItem is null) error (SWT.ERROR_INVALID_RANGE);
    TVITEM tvItem;
    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM;
    clear (hItem, &tvItem);
    if (all) {
        hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CHILD, hItem);
        clearAll (hItem, &tvItem, all);
    }
}

void clear (HANDLE hItem, TVITEM* tvItem) {
    tvItem.hItem = cast(HTREEITEM)hItem;
    TreeItem item = null;
    if (OS.SendMessage (handle, OS.TVM_GETITEM, 0, tvItem) !is 0) {
        item = tvItem.lParam !is -1 ? items [tvItem.lParam] : null;
    }
    if (item !is null) {
        if ((style & SWT.VIRTUAL) !is 0 && !item.cached) return;
        item.clear ();
        item.redraw ();
    }
}

/**
 * Clears all the items in the receiver. The text, icon and other
 * attributes of the items are set to their default values. If the
 * tree was created with the <code>SWT.VIRTUAL</code> style, these
 * attributes are requested again as needed.
 *
 * @param all <code>true</code> if all child items should be cleared
 * recursively, and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SWT#VIRTUAL
 * @see SWT#SetData
 *
 * @since 3.2
 */
public void clearAll (bool all) {
    checkWidget ();
    HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
    if (hItem is null) return;
    if (all) {
        bool redraw = false;
        for (int i=0; i<items.length; i++) {
            TreeItem item = items [i];
            if (item !is null && item !is currentItem) {
                item.clear ();
                redraw = true;
            }
        }
        if (redraw) OS.InvalidateRect (handle, null, true);
    } else {
        TVITEM tvItem;
        tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM;
        clearAll (hItem, &tvItem, all);
    }
}

void clearAll (HANDLE hItem, TVITEM* tvItem, bool all) {
    while (hItem !is null) {
        clear (hItem, tvItem);
        if (all) {
            auto hFirstItem = cast(HANDLE)OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CHILD, hItem);
            clearAll (hFirstItem, tvItem, all);
        }
        hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hItem);
    }
}

private static extern(Windows) int CompareFunc (LPARAM lParam1, LPARAM lParam2, LPARAM lParamSort) {
    return sThis.CompareProc( lParam1, lParam2, lParamSort );
}
int CompareProc (LPARAM lParam1, LPARAM lParam2, LPARAM lParamSort) {
    TreeItem item1 = items [lParam1], item2 = items [lParam2];
    String text1 = item1.getText (cast(int)/*64bit*/lParamSort), text2 = item2.getText (cast(int)/*64bit*/lParamSort);
    return sortDirection is SWT.UP ? ( text1 < text2 ) : ( text2 < text1 );
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = 0, height = 0;
    if (hwndHeader !is null) {
        HDITEM hdItem;
        hdItem.mask = OS.HDI_WIDTH;
        for (int i=0; i<columnCount; i++) {
            OS.SendMessage (hwndHeader, OS.HDM_GETITEM, i, &hdItem);
            width += hdItem.cxy;
        }
        RECT rect;
        OS.GetWindowRect (hwndHeader, &rect);
        height += rect.bottom - rect.top;
    }
    RECT rect;
    HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
    while (hItem !is null) {
        if ((style & SWT.VIRTUAL) is 0 && !painted) {
            TVITEM tvItem;
            tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_TEXT;
            tvItem.hItem = cast(HTREEITEM)hItem;
            tvItem.pszText = OS.LPSTR_TEXTCALLBACK;
            ignoreCustomDraw = true;
            OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
            ignoreCustomDraw = false;
        }
        if (OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hItem, &rect, true)) {
            width = Math.max (width, rect.right);
            height += rect.bottom - rect.top;
        }
        hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXTVISIBLE, hItem);
    }
    if (width is 0) width = DEFAULT_WIDTH;
    if (height is 0) height = DEFAULT_HEIGHT;
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    int border = getBorderWidth ();
    width += border * 2;
    height += border * 2;
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
            OS.SetWindowTheme (handle, cast(TCHAR*) Display.EXPLORER, null);
            int bits = OS.TVS_EX_DOUBLEBUFFER | OS.TVS_EX_FADEINOUTEXPANDOS | OS.TVS_EX_RICHTOOLTIP;
            /*
            * This code is intentionally commented.
            */
//          if ((style & SWT.FULL_SELECTION) is 0) bits |= OS.TVS_EX_AUTOHSCROLL;
            OS.SendMessage (handle, OS.TVM_SETEXTENDEDSTYLE, 0, bits);
            /*
            * Bug in Windows.  When the tree is using the explorer
            * theme, it does not use COLOR_WINDOW_TEXT for the
            * default foreground color.  The fix is to explicitly
            * set the foreground.
            */
            setForegroundPixel (-1);
        }
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

    /* Set the checkbox image list */
    if ((style & SWT.CHECK) !is 0) setCheckboxImageList ();

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
    HFONT hFont = OS.GetStockObject (OS.SYSTEM_FONT);
    OS.SendMessage (handle, OS.WM_SETFONT, hFont, 0);
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

void createItem (TreeColumn column, int index) {
    if (hwndHeader is null) createParent ();
    if (!(0 <= index && index <= columnCount)) error (SWT.ERROR_INVALID_RANGE);
    if (columnCount is columns.length) {
        TreeColumn [] newColumns = new TreeColumn [columns.length + 4];
        System.arraycopy (columns, 0, newColumns, 0, columns.length);
        columns = newColumns;
    }
    for (int i=0; i<items.length; i++) {
        TreeItem item = items [i];
        if (item !is null) {
            String [] strings = item.strings;
            if (strings !is null) {
                String [] temp = new String [columnCount + 1];
                System.arraycopy (strings, 0, temp, 0, index);
                System.arraycopy (strings, index, temp, index + 1, columnCount - index);
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
                    item.text = "";
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
                System.arraycopy (cellFont, index, temp, index + 1, columnCount- index);
                item.cellFont = temp;
            }
        }
    }
    System.arraycopy (columns, index, columns, index + 1, columnCount++ - index);
    columns [index] = column;

    /*
    * Bug in Windows.  For some reason, when HDM_INSERTITEM
    * is used to insert an item into a header without text,
    * if is not possible to set the text at a later time.
    * The fix is to insert the item with an empty string.
    */
    auto hHeap = OS.GetProcessHeap ();
    auto pszText = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, TCHAR.sizeof);
    HDITEM hdItem;
    hdItem.mask = OS.HDI_TEXT | OS.HDI_FORMAT;
    hdItem.pszText = pszText;
    if ((column.style & SWT.LEFT) is SWT.LEFT) hdItem.fmt = OS.HDF_LEFT;
    if ((column.style & SWT.CENTER) is SWT.CENTER) hdItem.fmt = OS.HDF_CENTER;
    if ((column.style & SWT.RIGHT) is SWT.RIGHT) hdItem.fmt = OS.HDF_RIGHT;
    OS.SendMessage (hwndHeader, OS.HDM_INSERTITEM, index, &hdItem);
    if (pszText !is null) OS.HeapFree (hHeap, 0, pszText);

    /* When the first column is created, hide the horizontal scroll bar */
    if (columnCount is 1) {
        scrollWidth = 0;
        if ((style & SWT.H_SCROLL) !is 0) {
            int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
            bits |= OS.TVS_NOHSCROLL;
            OS.SetWindowLong (handle, OS.GWL_STYLE, bits);
        }
        /*
        * Bug in Windows.  When TVS_NOHSCROLL is set after items
        * have been inserted into the tree, Windows shows the
        * scroll bar.  The fix is to check for this case and
        * explicitly hide the scroll bar explicitly.
        */
        auto count = OS.SendMessage (handle, OS.TVM_GETCOUNT, 0, 0);
        if (count !is 0) {
            static if (!OS.IsWinCE) OS.ShowScrollBar (handle, OS.SB_HORZ, false);
        }
        createItemToolTips ();
        if (itemToolTipHandle !is null) {
            OS.SendMessage (itemToolTipHandle, OS.TTM_SETDELAYTIME, OS.TTDT_AUTOMATIC, -1);
        }
    }
    setScrollWidth ();
    updateImageList ();
    updateScrollBar ();

    /* Redraw to hide the items when the first column is created */
    if (columnCount is 1 && OS.SendMessage (handle, OS.TVM_GETCOUNT, 0, 0) !is 0) {
        OS.InvalidateRect (handle, null, true);
    }

    /* Add the tool tip item for the header */
    if (headerToolTipHandle !is null) {
        RECT rect;
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

void createItem (TreeItem item, HANDLE hParent, HANDLE hInsertAfter, HANDLE hItem) {
    int id = -1;
    if (item !is null) {
        id = lastID < items.length ? lastID : 0;
        while (id < items.length && items [id] !is null) id++;
        if (id is items.length) {
            /*
            * Grow the array faster when redraw is off or the
            * table is not visible.  When the table is painted,
            * the items array is resized to be smaller to reduce
            * memory usage.
            */
            size_t length = 0;
            if (drawCount is 0 && OS.IsWindowVisible (handle)) {
                length = items.length + 4;
            } else {
                shrink = true;
                length = Math.max (4, items.length * 3 / 2);
            }
            TreeItem [] newItems = new TreeItem [length];
            System.arraycopy (items, 0, newItems, 0, items.length);
            items = newItems;
        }
        lastID = id + 1;
    }
    HANDLE hNewItem;
    HANDLE hFirstItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CHILD, hParent);
    bool fixParent = hFirstItem is null;
    if (hItem is null) {
        TVINSERTSTRUCT tvInsert;
        tvInsert.hParent = cast(HTREEITEM)hParent;
        tvInsert.hInsertAfter = cast(HTREEITEM)hInsertAfter;
        tvInsert.item.lParam = id;
        tvInsert.item.pszText = OS.LPSTR_TEXTCALLBACK;
        tvInsert.item.iImage = tvInsert.item.iSelectedImage = cast(HBITMAP) OS.I_IMAGECALLBACK;
        tvInsert.item.mask = OS.TVIF_TEXT | OS.TVIF_IMAGE | OS.TVIF_SELECTEDIMAGE | OS.TVIF_HANDLE | OS.TVIF_PARAM;
        if ((style & SWT.CHECK) !is 0) {
            tvInsert.item.mask = tvInsert.item.mask | OS.TVIF_STATE;
            tvInsert.item.state = 1 << 12;
            tvInsert.item.stateMask = OS.TVIS_STATEIMAGEMASK;
        }
        ignoreCustomDraw = true;
        hNewItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_INSERTITEM, 0, &tvInsert);
        ignoreCustomDraw = false;
        if (hNewItem is null) error (SWT.ERROR_ITEM_NOT_ADDED);
        /*
        * This code is intentionally commented.
        */
//      if (hParent !is 0) {
//          int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
//          bits |= OS.TVS_LINESATROOT;
//          OS.SetWindowLong (handle, OS.GWL_STYLE, bits);
//      }
    } else {
        TVITEM tvItem;
        tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM;
        tvItem.hItem = cast(HTREEITEM)( hNewItem = hItem );
        tvItem.lParam = id;
        OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
    }
    if (item !is null) {
        item.handle = hNewItem;
        items [id] = item;
    }
    if (hFirstItem is null) {
        if (cast(ptrdiff_t)hInsertAfter is OS.TVI_FIRST || cast(ptrdiff_t)hInsertAfter is OS.TVI_LAST) {
            hFirstIndexOf = hLastIndexOf = hFirstItem = hNewItem;
            itemCount = lastIndexOf = 0;
        }
    }
    if (hFirstItem is hFirstIndexOf && itemCount !is -1) itemCount++;
    if (hItem is null) {
        /*
        * Bug in Windows.  When a child item is added to a parent item
        * that has no children outside of WM_NOTIFY with control code
        * TVN_ITEMEXPANDED, the tree widget does not redraw the + / -
        * indicator.  The fix is to detect the case when the first
        * child is added to a visible parent item and redraw the parent.
        */
        if (fixParent) {
            if (drawCount is 0 && OS.IsWindowVisible (handle)) {
                RECT rect;
                if (OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hParent, &rect, false)) {
                    OS.InvalidateRect (handle, &rect, true);
                }
            }
        }
        /*
        * Bug in Windows.  When a new item is added while Windows
        * is requesting data a tree item using TVN_GETDISPINFO,
        * outstanding damage for items that are below the new item
        * is not scrolled.  The fix is to explicitly damage the
        * new area.
        */
        if ((style & SWT.VIRTUAL) !is 0) {
            if (currentItem !is null) {
                RECT rect;
                if (OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hNewItem, &rect, false)) {
                    RECT damageRect;
                    bool damaged = cast(bool) OS.GetUpdateRect (handle, &damageRect, true);
                    if (damaged && damageRect.top < rect.bottom) {
                        static if (OS.IsWinCE) {
                            OS.OffsetRect (&damageRect, 0, rect.bottom - rect.top);
                            OS.InvalidateRect (handle, &damageRect, true);
                        } else {
                            HRGN rgn = OS.CreateRectRgn (0, 0, 0, 0);
                            int result = OS.GetUpdateRgn (handle, rgn, true);
                            if (result !is OS.NULLREGION) {
                                OS.OffsetRgn (rgn, 0, rect.bottom - rect.top);
                                OS.InvalidateRgn (handle, rgn, true);
                            }
                            OS.DeleteObject (rgn);
                        }
                    }
                }
            }
        }
        updateScrollBar ();
    }
}

void createItemToolTips () {
    static if (OS.IsWinCE) return;
    if (itemToolTipHandle !is null) return;
    int bits1 = OS.GetWindowLong (handle, OS.GWL_STYLE);
    bits1 |= OS.TVS_NOTOOLTIPS;
    OS.SetWindowLong (handle, OS.GWL_STYLE, bits1);
    int bits2 = 0;
    if (OS.WIN32_VERSION >= OS.VERSION (4, 10)) {
        if ((style & SWT.RIGHT_TO_LEFT) !is 0) bits2 |= OS.WS_EX_LAYOUTRTL;
    }
    /*
    * Feature in Windows.  For some reason, when the user
    * clicks on a tool tip, it temporarily takes focus, even
    * when WS_EX_NOACTIVATE is specified.  The fix is to
    * use WS_EX_TRANSPARENT, even though WS_EX_TRANSPARENT
    * is documented to affect painting, not hit testing.
    *
    * NOTE: Windows 2000 doesn't have the problem and
    * setting WS_EX_TRANSPARENT causes pixel corruption.
    */
    if (OS.COMCTL32_MAJOR >= 6) bits2 |= OS.WS_EX_TRANSPARENT;
    itemToolTipHandle = OS.CreateWindowEx (
        bits2,
        OS.TOOLTIPS_CLASS.dup.ptr,
        null,
        OS.TTS_NOPREFIX | OS.TTS_NOANIMATE | OS.TTS_NOFADE,
        OS.CW_USEDEFAULT, 0, OS.CW_USEDEFAULT, 0,
        handle,
        null,
        OS.GetModuleHandle (null),
        null);
    if (itemToolTipHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.SendMessage (itemToolTipHandle, OS.TTM_SETDELAYTIME, OS.TTDT_INITIAL, 0);
    TOOLINFO lpti;
    lpti.cbSize = OS.TOOLINFO_sizeof;
    lpti.hwnd = handle;
    lpti.uId = cast(ptrdiff_t)handle;
    lpti.uFlags = OS.TTF_SUBCLASS | OS.TTF_TRANSPARENT;
    lpti.lpszText = OS.LPSTR_TEXTCALLBACK;
    OS.SendMessage (itemToolTipHandle, OS.TTM_ADDTOOL, 0, &lpti);
}

void createParent () {
    forceResize ();
    RECT rect;
    OS.GetWindowRect (handle, &rect);
    OS.MapWindowPoints (null, parent.handle, cast(POINT*) &rect, 2);
    int oldStyle = OS.GetWindowLong (handle, OS.GWL_STYLE);
    int newStyle = super.widgetStyle () & ~OS.WS_VISIBLE;
    if ((oldStyle & OS.WS_DISABLED) !is 0) newStyle |= OS.WS_DISABLED;
//  if ((oldStyle & OS.WS_VISIBLE) !is 0) newStyle |= OS.WS_VISIBLE;
    hwndParent = OS.CreateWindowEx (
        super.widgetExtStyle (),
        StrToTCHARz( 0, super.windowClass () ),
        null,
        newStyle,
        rect.left,
        rect.top,
        rect.right - rect.left,
        rect.bottom - rect.top,
        parent.handle,
        null,
        OS.GetModuleHandle (null),
        null);
    if (hwndParent is null) error (SWT.ERROR_NO_HANDLES);
    OS.SetWindowLongPtr (hwndParent, OS.GWLP_ID, cast(LONG_PTR)hwndParent);
    int bits = 0;
    if (OS.WIN32_VERSION >= OS.VERSION (4, 10)) {
        bits |= OS.WS_EX_NOINHERITLAYOUT;
        if ((style & SWT.RIGHT_TO_LEFT) !is 0) bits |= OS.WS_EX_LAYOUTRTL;
    }
    hwndHeader = OS.CreateWindowEx (
        bits,
        HeaderClass.ptr,
        null,
        OS.HDS_BUTTONS | OS.HDS_FULLDRAG | OS.HDS_DRAGDROP | OS.HDS_HIDDEN | OS.WS_CHILD | OS.WS_CLIPSIBLINGS,
        0, 0, 0, 0,
        hwndParent,
        null,
        OS.GetModuleHandle (null),
        null);
    if (hwndHeader is null) error (SWT.ERROR_NO_HANDLES);
    OS.SetWindowLongPtr (hwndHeader, OS.GWLP_ID, cast(LONG_PTR)hwndHeader);
    if (OS.IsDBLocale) {
        auto hIMC = OS.ImmGetContext (handle);
        OS.ImmAssociateContext (hwndParent, hIMC);
        OS.ImmAssociateContext (hwndHeader, hIMC);
        OS.ImmReleaseContext (handle, hIMC);
    }
    //This code is intentionally commented
//  if (!OS.IsPPC) {
//      if ((style & SWT.BORDER) !is 0) {
//          int oldExStyle = OS.GetWindowLong (handle, OS.GWL_EXSTYLE);
//          oldExStyle &= ~OS.WS_EX_CLIENTEDGE;
//          OS.SetWindowLong (handle, OS.GWL_EXSTYLE, oldExStyle);
//      }
//  }
    HFONT hFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
    if (hFont !is null) OS.SendMessage (hwndHeader, OS.WM_SETFONT, hFont, 0);
    HANDLE hwndInsertAfter = OS.GetWindow (handle, OS.GW_HWNDPREV);
    int flags = OS.SWP_NOSIZE | OS.SWP_NOMOVE | OS.SWP_NOACTIVATE;
    SetWindowPos (hwndParent, hwndInsertAfter, 0, 0, 0, 0, flags);
    SCROLLINFO info;
    info.cbSize = SCROLLINFO.sizeof;
    info.fMask = OS.SIF_RANGE | OS.SIF_PAGE;
    OS.GetScrollInfo (hwndParent, OS.SB_HORZ, &info);
    info.nPage = info.nMax + 1;
    OS.SetScrollInfo (hwndParent, OS.SB_HORZ, &info, true);
    OS.GetScrollInfo (hwndParent, OS.SB_VERT, &info);
    info.nPage = info.nMax + 1;
    OS.SetScrollInfo (hwndParent, OS.SB_VERT, &info, true);
    customDraw = true;
    deregister ();
    if ((oldStyle & OS.WS_VISIBLE) !is 0) {
        OS.ShowWindow (hwndParent, OS.SW_SHOW);
    }
    HWND hwndFocus = OS.GetFocus ();
    if (hwndFocus is handle) OS.SetFocus (hwndParent);
    OS.SetParent (handle, hwndParent);
    if (hwndFocus is handle) OS.SetFocus (handle);
    register ();
    subclass ();
}

override void createWidget () {
    super.createWidget ();
    items = new TreeItem [4];
    columns = new TreeColumn [4];
    itemCount = -1;
}

override int defaultBackground () {
    return OS.GetSysColor (OS.COLOR_WINDOW);
}

override void deregister () {
    super.deregister ();
    if (hwndParent !is null) display.removeControl (hwndParent);
    if (hwndHeader !is null) display.removeControl (hwndHeader);
}

void deselect (HANDLE hItem, TVITEM* tvItem, HANDLE hIgnoreItem) {
    while (hItem !is null) {
        if (hItem !is hIgnoreItem) {
            tvItem.hItem = cast(HTREEITEM)hItem;
            OS.SendMessage (handle, OS.TVM_SETITEM, 0, tvItem);
        }
        auto hFirstItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CHILD, hItem);
        deselect (hFirstItem, tvItem, hIgnoreItem);
        hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hItem);
    }
}

/**
 * Deselects an item in the receiver.  If the item was already
 * deselected, it remains deselected.
 *
 * @param item the item to be deselected
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
 * @since 3.4
 */
public void deselect (TreeItem item) {
    checkWidget ();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
    TVITEM tvItem;
    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
    tvItem.stateMask = OS.TVIS_SELECTED;
    tvItem.hItem = cast(HTREEITEM)item.handle;
    OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
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
    TVITEM tvItem;
    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
    tvItem.stateMask = OS.TVIS_SELECTED;
    if ((style & SWT.SINGLE) !is 0) {
        HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
        if (hItem !is null) {
            tvItem.hItem = cast(HTREEITEM)hItem;
            OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
        }
    } else {
        auto oldProc = OS.GetWindowLongPtr (handle, OS.GWLP_WNDPROC);
        OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)TreeProc);
        if ((style & SWT.VIRTUAL) !is 0) {
            HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
            deselect (hItem, &tvItem, null);
        } else {
            for (int i=0; i<items.length; i++) {
                TreeItem item = items [i];
                if (item !is null) {
                    tvItem.hItem = cast(HTREEITEM)item.handle;
                    OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                }
            }
        }
        OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, oldProc);
    }
}

void destroyItem (TreeColumn column) {
    if (hwndHeader is null) error (SWT.ERROR_ITEM_NOT_REMOVED);
    int index = 0;
    while (index < columnCount) {
        if (columns [index] is column) break;
        index++;
    }
    int [] oldOrder = new int [columnCount];
    OS.SendMessage (hwndHeader, OS.HDM_GETORDERARRAY, columnCount, oldOrder.ptr);
    int orderIndex = 0;
    while (orderIndex < columnCount) {
        if (oldOrder [orderIndex] is index) break;
        orderIndex++;
    }
    RECT headerRect;
    OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, index, &headerRect);
    if (OS.SendMessage (hwndHeader, OS.HDM_DELETEITEM, index, 0) is 0) {
        error (SWT.ERROR_ITEM_NOT_REMOVED);
    }
    System.arraycopy (columns, index + 1, columns, index, --columnCount - index);
    columns [columnCount] = null;
    for (int i=0; i<items.length; i++) {
        TreeItem item = items [i];
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
                        item.text = strings [1] !is null ? strings [1] : "";
                    }
                    String [] temp = new String [columnCount];
                    System.arraycopy (strings, 0, temp, 0, index);
                    System.arraycopy (strings, index + 1, temp, index, columnCount - index);
                    item.strings = temp;
                } else {
                    if (index is 0) item.text = "";
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

    /*
    * When the last column is deleted, show the horizontal
    * scroll bar.  Otherwise, left align the first column
    * and redraw the columns to the right.
    */
    if (columnCount is 0) {
        scrollWidth = 0;
        if (!hooks (SWT.MeasureItem)) {
            int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
            if ((style & SWT.H_SCROLL) !is 0) bits &= ~OS.TVS_NOHSCROLL;
            OS.SetWindowLong (handle, OS.GWL_STYLE, bits);
            OS.InvalidateRect (handle, null, true);
        }
        if (itemToolTipHandle !is null) {
            OS.SendMessage (itemToolTipHandle, OS.TTM_SETDELAYTIME, OS.TTDT_INITIAL, 0);
        }
    } else {
        if (index is 0) {
            columns [0].style &= ~(SWT.LEFT | SWT.RIGHT | SWT.CENTER);
            columns [0].style |= SWT.LEFT;
            HDITEM hdItem;
            hdItem.mask = OS.HDI_FORMAT | OS.HDI_IMAGE;
            OS.SendMessage (hwndHeader, OS.HDM_GETITEM, index, &hdItem);
            hdItem.fmt &= ~OS.HDF_JUSTIFYMASK;
            hdItem.fmt |= OS.HDF_LEFT;
            OS.SendMessage (hwndHeader, OS.HDM_SETITEM, index, &hdItem);
        }
        RECT rect;
        OS.GetClientRect (handle, &rect);
        rect.left = headerRect.left;
        OS.InvalidateRect (handle, &rect, true);
    }
    setScrollWidth ();
    updateImageList ();
    updateScrollBar ();
    if (columnCount !is 0) {
        int [] newOrder = new int [columnCount];
        OS.SendMessage (hwndHeader, OS.HDM_GETORDERARRAY, columnCount, newOrder.ptr);
        TreeColumn [] newColumns = new TreeColumn [columnCount - orderIndex];
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
        lpti.hwnd = hwndHeader;
        OS.SendMessage (headerToolTipHandle, OS.TTM_DELTOOL, 0, &lpti);
    }
}

void destroyItem (TreeItem item, HANDLE hItem) {
    hFirstIndexOf = hLastIndexOf = null;
    itemCount = -1;
    /*
    * Feature in Windows.  When an item is removed that is not
    * visible in the tree because it belongs to a collapsed branch,
    * Windows redraws the tree causing a flash for each item that
    * is removed.  The fix is to detect whether the item is visible,
    * force the widget to be fully painted, turn off redraw, remove
    * the item and validate the damage caused by the removing of
    * the item.
    *
    * NOTE: This fix is not necessary when double buffering and
    * can cause problems for virtual trees due to the call to
    * UpdateWindow() that flushes outstanding WM_PAINT events,
    * allowing application code to add or remove items during
    * this remove operation.
    */
    HANDLE hParent;
    bool fixRedraw = false;
    if ((style & SWT.DOUBLE_BUFFERED) is 0) {
        if (drawCount is 0 && OS.IsWindowVisible (handle)) {
            RECT rect;
            fixRedraw = !OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hItem, &rect, false);
        }
    }
    if (fixRedraw) {
        hParent = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_PARENT, hItem);
        OS.UpdateWindow (handle);
        OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
        /*
        * This code is intentionally commented.
        */
//      OS.SendMessage (handle, OS.WM_SETREDRAW, 0, 0);
    }
    if ((style & SWT.MULTI) !is 0) {
        ignoreDeselect = ignoreSelect = lockSelection = true;
    }

    /*
    * Feature in Windows.  When an item is deleted and a tool tip
    * is showing, Window requests the new text for the new item
    * that is under the cursor right away.  This means that when
    * multiple items are deleted, the tool tip flashes, showing
    * each new item in the tool tip as it is scrolled into view.
    * The fix is to hide tool tips when any item is deleted.
    *
    * NOTE:  This only happens on Vista.
    */
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
        auto hwndToolTip = cast(HWND) OS.SendMessage (handle, OS.TVM_GETTOOLTIPS, 0, 0);
        if (hwndToolTip !is null) OS.SendMessage (hwndToolTip, OS.TTM_POP, 0 ,0);
    }

    shrink = ignoreShrink = true;
    OS.SendMessage (handle, OS.TVM_DELETEITEM, 0, hItem);
    ignoreShrink = false;
    if ((style & SWT.MULTI) !is 0) {
        ignoreDeselect = ignoreSelect = lockSelection = false;
    }
    if (fixRedraw) {
        OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
        OS.ValidateRect (handle, null);
        /*
        * If the item that was deleted was the last child of a tree item that
        * is visible, redraw the parent item to force the + / - to be updated.
        */
        if (OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CHILD, hParent) is 0) {
            RECT rect;
            if (OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hParent, &rect, false)) {
                OS.InvalidateRect (handle, &rect, true);
            }
        }
    }
    auto count = OS.SendMessage (handle, OS.TVM_GETCOUNT, 0, 0);
    if (count is 0) {
        if (imageList !is null) {
            OS.SendMessage (handle, OS.TVM_SETIMAGELIST, 0, 0);
            display.releaseImageList (imageList);
        }
        imageList = null;
        if (hwndParent is null && !linesVisible) {
            if (!hooks (SWT.MeasureItem) && !hooks (SWT.EraseItem) && !hooks (SWT.PaintItem)) {
                customDraw = false;
            }
        }
        items = new TreeItem [4];
        scrollWidth = 0;
        setScrollWidth ();
    }
    updateScrollBar ();
}

override void destroyScrollBar (int type) {
    super.destroyScrollBar (type);
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    if ((style & (SWT.H_SCROLL | SWT.V_SCROLL)) is 0) {
        bits &= ~(OS.WS_HSCROLL | OS.WS_VSCROLL);
        bits |= OS.TVS_NOSCROLL;
    } else {
        if ((style & SWT.H_SCROLL) is 0) {
            bits &= ~OS.WS_HSCROLL;
            bits |= OS.TVS_NOHSCROLL;
        }
    }
    OS.SetWindowLong (handle, OS.GWL_STYLE, bits);
}

override void enableDrag (bool enabled) {
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    if (enabled && hooks (SWT.DragDetect)) {
        bits &= ~OS.TVS_DISABLEDRAGDROP;
    } else {
        bits |= OS.TVS_DISABLEDRAGDROP;
    }
    OS.SetWindowLong (handle, OS.GWL_STYLE, bits);
}

override void enableWidget (bool enabled) {
    super.enableWidget (enabled);
    /*
    * Feature in Windows.  When a tree is given a background color
    * using TVM_SETBKCOLOR and the tree is disabled, Windows draws
    * the tree using the background color rather than the disabled
    * colors.  This is different from the table which draws grayed.
    * The fix is to set the default background color while the tree
    * is disabled and restore it when enabled.
    */
    Control control = findBackgroundControl ();
    /*
    * Bug in Windows.  On Vista only, Windows does not draw using
    * the background color when the tree is disabled.  The fix is
    * to set the default color, even when the color has not been
    * changed, causing Windows to draw correctly.
    */
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
        if (control is null) control = this;
    }
    if (control !is null) {
        if (control.backgroundImage is null) {
            _setBackgroundPixel (enabled ? control.getBackgroundPixel () : -1);
        }
    }
    if (hwndParent !is null) OS.EnableWindow (hwndParent, enabled);

    /*
    * Feature in Windows.  When the tree has the style
    * TVS_FULLROWSELECT, the background color for the
    * entire row is filled when an item is painted,
    * drawing on top of the sort column color.  The fix
    * is to clear TVS_FULLROWSELECT when a their is
    * as sort column.
    */
    updateFullSelection ();
}

bool findCell (int x, int y, ref TreeItem item, ref int index, ref RECT* cellRect, ref RECT* itemRect) {
    bool found = false;
    TVHITTESTINFO lpht;
    lpht.pt.x = x;
    lpht.pt.y = y;
    OS.SendMessage (handle, OS.TVM_HITTEST, 0, &lpht);
    if (lpht.hItem !is null) {
        item = _getItem (lpht.hItem);
        POINT pt;
        pt.x = x;
        pt.y = y;
        auto hDC = OS.GetDC (handle);
        HFONT oldFont;
        auto newFont = cast(HFONT)OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
        if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
        RECT rect;
        if (hwndParent !is null) {
            OS.GetClientRect (hwndParent, &rect);
            OS.MapWindowPoints (hwndParent, handle, cast(POINT*)&rect, 2);
        } else {
            OS.GetClientRect (handle, &rect);
        }
        int count = Math.max (1, columnCount);
        int [] order = new int [count];
        if (hwndHeader !is null) OS.SendMessage (hwndHeader, OS.HDM_GETORDERARRAY, count, order.ptr);
        index = 0;
        bool quit = false;
        while (index < count && !quit) {
            auto hFont = item.fontHandle (order [index]);
            if (hFont !is cast(HFONT)-1) hFont = OS.SelectObject (hDC, hFont);
            cellRect = item.getBounds (order [index], true, false, true, false, true, hDC);
            if (cellRect.left > rect.right) {
                quit = true;
            } else {
                cellRect.right = Math.min (cellRect.right, rect.right);
                if (OS.PtInRect ( cellRect, pt)) {
                    if (isCustomToolTip ()) {
                        Event event = sendMeasureItemEvent (item, order [index], hDC);
                        if (isDisposed () || item.isDisposed ()) break;
                        itemRect = new RECT ();
                        itemRect.left = event.x;
                        itemRect.right = event.x + event.width;
                        itemRect.top = event.y;
                        itemRect.bottom = event.y + event.height;
                    } else {
                        itemRect = item.getBounds (order [index], true, false, false, false, false, hDC);
                    }
                    if (itemRect.right > cellRect.right) found = true;
                    quit = true;
                }
            }
            if (hFont !is cast(HFONT)-1) OS.SelectObject (hDC, hFont);
            if (!found) index++;
        }
        if (newFont !is null) OS.SelectObject (hDC, oldFont);
        OS.ReleaseDC (handle, hDC);
    }
    return found;
}

int findIndex (HANDLE hFirstItem, HANDLE hItem) {
    if (hFirstItem is null) return -1;
    if (hFirstItem is hFirstIndexOf) {
        if (hFirstIndexOf is hItem) {
            hLastIndexOf = hFirstIndexOf;
            return lastIndexOf = 0;
        }
        if (hLastIndexOf is hItem) return lastIndexOf;
        auto hPrevItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_PREVIOUS, hLastIndexOf);
        if (hPrevItem is hItem) {
            hLastIndexOf = hPrevItem;
            return --lastIndexOf;
        }
        HANDLE hNextItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hLastIndexOf);
        if (hNextItem is hItem) {
            hLastIndexOf = hNextItem;
            return ++lastIndexOf;
        }
        int previousIndex = lastIndexOf - 1;
        while (hPrevItem !is null && hPrevItem !is hItem) {
            hPrevItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_PREVIOUS, hPrevItem);
            --previousIndex;
        }
        if (hPrevItem is hItem) {
            hLastIndexOf = hPrevItem;
            return lastIndexOf = previousIndex;
        }
        int nextIndex = lastIndexOf + 1;
        while (hNextItem !is null && hNextItem !is hItem) {
            hNextItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hNextItem);
            nextIndex++;
        }
        if (hNextItem is hItem) {
            hLastIndexOf = hNextItem;
            return lastIndexOf = nextIndex;
        }
        return -1;
    }
    int index = 0;
    auto hNextItem = hFirstItem;
    while (hNextItem !is null && hNextItem !is hItem) {
        hNextItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hNextItem);
        index++;
    }
    if (hNextItem is hItem) {
        itemCount = -1;
        hFirstIndexOf = hFirstItem;
        hLastIndexOf = hNextItem;
        return lastIndexOf = index;
    }
    return -1;
}

override Widget findItem (HANDLE hItem) {
    return _getItem (hItem);
}

HANDLE findItem (HANDLE hFirstItem, int index) {
    if (hFirstItem is null) return null;
    if (hFirstItem is hFirstIndexOf) {
        if (index is 0) {
            lastIndexOf = 0;
            return hLastIndexOf = hFirstIndexOf;
        }
        if (lastIndexOf is index) return hLastIndexOf;
        if (lastIndexOf - 1 is index) {
            --lastIndexOf;
            return hLastIndexOf = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_PREVIOUS, hLastIndexOf);
        }
        if (lastIndexOf + 1 is index) {
            lastIndexOf++;
            return hLastIndexOf = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hLastIndexOf);
        }
        if (index < lastIndexOf) {
            int previousIndex = lastIndexOf - 1;
            auto hPrevItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_PREVIOUS, hLastIndexOf);
            while (hPrevItem !is null && index < previousIndex) {
                hPrevItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_PREVIOUS, hPrevItem);
                --previousIndex;
            }
            if (index is previousIndex) {
                lastIndexOf = previousIndex;
                return hLastIndexOf = hPrevItem;
            }
        } else {
            int nextIndex = lastIndexOf + 1;
            auto hNextItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hLastIndexOf);
            while (hNextItem !is null && nextIndex < index) {
                hNextItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hNextItem);
                nextIndex++;
            }
            if (index is nextIndex) {
                lastIndexOf = nextIndex;
                return hLastIndexOf = hNextItem;
            }
        }
        return null;
    }
    int nextIndex = 0;
    auto hNextItem = hFirstItem;
    while (hNextItem !is null && nextIndex < index) {
        hNextItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hNextItem);
        nextIndex++;
    }
    if (index is nextIndex) {
        itemCount = -1;
        lastIndexOf = nextIndex;
        hFirstIndexOf = hFirstItem;
        return hLastIndexOf = hNextItem;
    }
    return null;
}

TreeItem getFocusItem () {
//  checkWidget ();
    HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
    return hItem !is null ? _getItem (hItem) : null;
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
 *
 * @since 3.1
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
 * @since 3.1
 */
public int getHeaderHeight () {
    checkWidget ();
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
 *
 * @since 3.1
 */
public bool getHeaderVisible () {
    checkWidget ();
    if (hwndHeader is null) return false;
    int bits = OS.GetWindowLong (hwndHeader, OS.GWL_STYLE);
    return (bits & OS.WS_VISIBLE) !is 0;
}

Point getImageSize () {
    if (imageList !is null) return imageList.getImageSize ();
    return new Point (0, getItemHeight ());
}

HANDLE getBottomItem () {
    HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_FIRSTVISIBLE, 0);
    if (hItem is null) return null;
    auto index = 0, count = OS.SendMessage (handle, OS.TVM_GETVISIBLECOUNT, 0, 0);
    while (index < count) {
        HANDLE hNextItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXTVISIBLE, hItem);
        if (hNextItem is null) return hItem;
        hItem = hNextItem;
        index++;
    }
    return hItem;
}

/**
 * Returns the column at the given, zero-relative index in the
 * receiver. Throws an exception if the index is out of range.
 * Columns are returned in the order that they were created.
 * If no <code>TreeColumn</code>s were created by the programmer,
 * this method will throw <code>ERROR_INVALID_RANGE</code> despite
 * the fact that a single column of data may be visible in the tree.
 * This occurs when the programmer uses the tree like a list, adding
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
 * @see Tree#getColumnOrder()
 * @see Tree#setColumnOrder(int[])
 * @see TreeColumn#getMoveable()
 * @see TreeColumn#setMoveable(bool)
 * @see SWT#Move
 *
 * @since 3.1
 */
public TreeColumn getColumn (int index) {
    checkWidget ();
    if (!(0 <= index && index < columnCount)) error (SWT.ERROR_INVALID_RANGE);
    return columns [index];
}

/**
 * Returns the number of columns contained in the receiver.
 * If no <code>TreeColumn</code>s were created by the programmer,
 * this value is zero, despite the fact that visually, one column
 * of items may be visible. This occurs when the programmer uses
 * the tree like a list, adding items but never creating a column.
 *
 * @return the number of columns
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
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
 * @see Tree#setColumnOrder(int[])
 * @see TreeColumn#getMoveable()
 * @see TreeColumn#setMoveable(bool)
 * @see SWT#Move
 *
 * @since 3.2
 */
public int[] getColumnOrder () {
    checkWidget ();
    if (columnCount is 0) return null;
    int [] order = new int [columnCount];
    OS.SendMessage (hwndHeader, OS.HDM_GETORDERARRAY, columnCount, order.ptr);
    return order;
}

/**
 * Returns an array of <code>TreeColumn</code>s which are the
 * columns in the receiver. Columns are returned in the order
 * that they were created.  If no <code>TreeColumn</code>s were
 * created by the programmer, the array is empty, despite the fact
 * that visually, one column of items may be visible. This occurs
 * when the programmer uses the tree like a list, adding items but
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
 * @see Tree#getColumnOrder()
 * @see Tree#setColumnOrder(int[])
 * @see TreeColumn#getMoveable()
 * @see TreeColumn#setMoveable(bool)
 * @see SWT#Move
 *
 * @since 3.1
 */
public TreeColumn [] getColumns () {
    checkWidget ();
    TreeColumn [] result = new TreeColumn [columnCount];
    System.arraycopy (columns, 0, result, 0, columnCount);
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
 *
 * @since 3.1
 */
public TreeItem getItem (int index) {
    checkWidget ();
    if (index < 0) error (SWT.ERROR_INVALID_RANGE);
    auto hFirstItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
    if (hFirstItem is null) error (SWT.ERROR_INVALID_RANGE);
    HANDLE hItem = findItem (hFirstItem, index);
    if (hItem is null) error (SWT.ERROR_INVALID_RANGE);
    return _getItem (hItem);
}

TreeItem getItem (NMTVCUSTOMDRAW* nmcd) {
    /*
    * Bug in Windows.  If the lParam field of TVITEM
    * is changed during custom draw using TVM_SETITEM,
    * the lItemlParam field of the NMTVCUSTOMDRAW struct
    * is not updated until the next custom draw.  The
    * fix is to query the field from the item instead
    * of using the struct.
    */
    auto id = nmcd.nmcd.lItemlParam;
    if ((style & SWT.VIRTUAL) !is 0) {
        if (id is -1) {
            TVITEM tvItem;
            tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM;
            tvItem.hItem = cast(HTREEITEM) nmcd.nmcd.dwItemSpec;
            OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
            id = tvItem.lParam;
        }
    }
    return _getItem (cast(HANDLE) nmcd.nmcd.dwItemSpec, id);
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
public TreeItem getItem (Point point) {
    checkWidget ();
    if (point is null) error (SWT.ERROR_NULL_ARGUMENT);
    TVHITTESTINFO lpht;
    lpht.pt.x = point.x;
    lpht.pt.y = point.y;
    OS.SendMessage (handle, OS.TVM_HITTEST, 0, &lpht);
    if (lpht.hItem !is null) {
        int flags = OS.TVHT_ONITEM;
        if ((style & SWT.FULL_SELECTION) !is 0) {
            flags |= OS.TVHT_ONITEMRIGHT | OS.TVHT_ONITEMINDENT;
        } else {
            if (hooks (SWT.MeasureItem)) {
                lpht.flags &= ~(OS.TVHT_ONITEMICON | OS.TVHT_ONITEMLABEL);
                if (hitTestSelection ( lpht.hItem, lpht.pt.x, lpht.pt.y)) {
                    lpht.flags |= OS.TVHT_ONITEMICON | OS.TVHT_ONITEMLABEL;
                }
            }
        }
        if ((lpht.flags & flags) !is 0) return _getItem (lpht.hItem);
    }
    return null;
}

/**
 * Returns the number of items contained in the receiver
 * that are direct item children of the receiver.  The
 * number that is returned is the number of roots in the
 * tree.
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
    HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
    if (hItem is null) return 0;
    return getItemCount (hItem);
}

int getItemCount (HANDLE hItem) {
    int count = 0;
    auto hFirstItem = hItem;
    if (hItem is hFirstIndexOf) {
        if (itemCount !is -1) return itemCount;
        hFirstItem = hLastIndexOf;
        count = lastIndexOf;
    }
    while (hFirstItem !is null) {
        hFirstItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hFirstItem);
        count++;
    }
    if (hItem is hFirstIndexOf) itemCount = count;
    return count;
}

/**
 * Returns the height of the area which would be used to
 * display <em>one</em> of the items in the tree.
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
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.TVM_GETITEMHEIGHT, 0, 0);
}

/**
 * Returns a (possibly empty) array of items contained in the
 * receiver that are direct item children of the receiver.  These
 * are the roots of the tree.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the items
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public TreeItem [] getItems () {
    checkWidget ();
    HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
    if (hItem is null) return null;
    return getItems (hItem);
}

TreeItem [] getItems (HANDLE hTreeItem) {
    int count = 0;
    auto hItem = hTreeItem;
    while (hItem !is null) {
        hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hItem);
        count++;
    }
    int index = 0;
    TreeItem [] result = new TreeItem [count];
    TVITEM tvItem;
    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM;
    tvItem.hItem = cast(HTREEITEM)hTreeItem;
    /*
    * Feature in Windows.  In some cases an expand or collapse message
    * can occur from within TVM_DELETEITEM.  When this happens, the item
    * being destroyed has been removed from the list of items but has not
    * been deleted from the tree.  The fix is to check for null items and
    * remove them from the list.
    */
    while (tvItem.hItem !is null) {
        OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
        TreeItem item = _getItem (tvItem.hItem, tvItem.lParam);
        if (item !is null) result [index++] = item;
        tvItem.hItem = cast(HTREEITEM) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, tvItem.hItem);
    }
    if (index !is count) {
        TreeItem [] newResult = new TreeItem [index];
        System.arraycopy (result, 0, newResult, 0, index);
        result = newResult;
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
 *
 * @since 3.1
 */
public bool getLinesVisible () {
    checkWidget ();
    return linesVisible;
}

HANDLE getNextSelection (HANDLE hItem, TVITEM* tvItem) {
    while (hItem !is null) {
        .LRESULT state = 0;
        static if (OS.IsWinCE) {
            tvItem.hItem = hItem;
            OS.SendMessage (handle, OS.TVM_GETITEM, 0, tvItem);
            state = tvItem.state;
        } else {
            state = OS.SendMessage (handle, OS.TVM_GETITEMSTATE, hItem, OS.TVIS_SELECTED);
        }
        if ((state & OS.TVIS_SELECTED) !is 0) return hItem;
        auto hFirstItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CHILD, hItem);
        auto hSelected = getNextSelection (hFirstItem, tvItem);
        if (hSelected !is null) return hSelected;
        hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hItem);
    }
    return null;
}

/**
 * Returns the receiver's parent item, which must be a
 * <code>TreeItem</code> or null when the receiver is a
 * root.
 *
 * @return the receiver's parent item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public TreeItem getParentItem () {
    checkWidget ();
    return null;
}

int getSelection (HANDLE hItem, TVITEM* tvItem, TreeItem [] selection, int index, int count, bool bigSelection, bool all) {
    while (hItem !is null) {
        if (OS.IsWinCE || bigSelection) {
            tvItem.hItem = cast(HTREEITEM)hItem;
            OS.SendMessage (handle, OS.TVM_GETITEM, 0, tvItem);
            if ((tvItem.state & OS.TVIS_SELECTED) !is 0) {
                if (selection !is null && index < selection.length) {
                    selection [index] = _getItem (hItem, tvItem.lParam);
                }
                index++;
            }
        } else {
            auto state = OS.SendMessage (handle, OS.TVM_GETITEMSTATE, hItem, OS.TVIS_SELECTED);
            if ((state & OS.TVIS_SELECTED) !is 0) {
                if (tvItem !is null && selection !is null && index < selection.length) {
                    tvItem.hItem = cast(HTREEITEM)hItem;
                    OS.SendMessage (handle, OS.TVM_GETITEM, 0, tvItem);
                    selection [index] = _getItem (hItem, tvItem.lParam);
                }
                index++;
            }
        }
        if (index is count) break;
        if (all) {
            auto hFirstItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CHILD, hItem);
            if ((index = getSelection (hFirstItem, tvItem, selection, index, count, bigSelection, all)) is count) {
                break;
            }
            hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hItem);
        } else {
            hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXTVISIBLE, hItem);
        }
    }
    return index;
}

/**
 * Returns an array of <code>TreeItem</code>s that are currently
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
public TreeItem [] getSelection () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
        if (hItem is null) return new TreeItem [0];
        TVITEM tvItem;
        tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM | OS.TVIF_STATE;
        tvItem.hItem = cast(HTREEITEM)hItem;
        OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
        if ((tvItem.state & OS.TVIS_SELECTED) is 0) return new TreeItem [0];
        return [_getItem (tvItem.hItem, tvItem.lParam)];
    }
    int count = 0;
    TreeItem [] guess = new TreeItem [(style & SWT.VIRTUAL) !is 0 ? 8 : 1];
    LONG_PTR oldProc = OS.GetWindowLongPtr (handle, OS.GWLP_WNDPROC);
    OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)TreeProc);
    if ((style & SWT.VIRTUAL) !is 0) {
        TVITEM tvItem;
        tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM | OS.TVIF_STATE;
        HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
        count = getSelection (hItem, &tvItem, guess, 0, -1, false, true);
    } else {
        TVITEM tvItem;
        static if (OS.IsWinCE) {
            //tvItem = new TVITEM ();
            tvItem.mask = OS.TVIF_STATE;
        }
        for (int i=0; i<items.length; i++) {
            TreeItem item = items [i];
            if (item !is null) {
                HANDLE hItem = item.handle;
                .LRESULT state = 0;
                static if (OS.IsWinCE) {
                    tvItem.hItem = hItem;
                    OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
                    state = tvItem.state;
                } else {
                    state = OS.SendMessage (handle, OS.TVM_GETITEMSTATE, hItem, OS.TVIS_SELECTED);
                }
                if ((state & OS.TVIS_SELECTED) !is 0) {
                    if (count < guess.length) guess [count] = item;
                    count++;
                }
            }
        }
    }
    OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, oldProc);
    if (count is 0) return new TreeItem [0];
    if (count is guess.length) return guess;
    TreeItem [] result = new TreeItem [count];
    if (count < guess.length) {
        System.arraycopy (guess, 0, result, 0, count);
        return result;
    }
    OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)TreeProc);
    TVITEM tvItem;
    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM | OS.TVIF_STATE;
    HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
    auto itemCount = OS.SendMessage (handle, OS.TVM_GETCOUNT, 0, 0);
    bool bigSelection = result.length > itemCount / 2;
    if (count !is getSelection (hItem, &tvItem, result, 0, count, bigSelection, false)) {
        getSelection (hItem, &tvItem, result, 0, count, bigSelection, true);
    }
    OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, oldProc);
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
        HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
        if (hItem is null) return 0;
        .LRESULT state = 0;
        static if (OS.IsWinCE) {
            TVITEM tvItem;
            tvItem.hItem = hItem;
            tvItem.mask = OS.TVIF_STATE;
            OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
            state = tvItem.state;
        } else {
            state = OS.SendMessage (handle, OS.TVM_GETITEMSTATE, hItem, OS.TVIS_SELECTED);
        }
        return (state & OS.TVIS_SELECTED) is 0 ? 0 : 1;
    }
    int count = 0;
    auto oldProc = OS.GetWindowLongPtr (handle, OS.GWLP_WNDPROC);
    TVITEM tvItem_;
    TVITEM* tvItem = null;
    static if (OS.IsWinCE) {
        tvItem = &tvitem_;
        tvItem.mask = OS.TVIF_STATE;
    }
    OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)TreeProc);
    if ((style & SWT.VIRTUAL) !is 0) {
        HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
        count = getSelection (hItem, tvItem, null, 0, -1, false, true);
    } else {
        for (int i=0; i<items.length; i++) {
            TreeItem item = items [i];
            if (item !is null) {
                auto hItem = item.handle;
                .LRESULT state = 0;
                static if (OS.IsWinCE) {
                    tvItem.hItem = hItem;
                    OS.SendMessage (handle, OS.TVM_GETITEM, 0, tvItem);
                    state = tvItem.state;
                } else {
                    state = OS.SendMessage (handle, OS.TVM_GETITEMSTATE, hItem, OS.TVIS_SELECTED);
                }
                if ((state & OS.TVIS_SELECTED) !is 0) count++;
            }
        }
    }
    OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, oldProc);
    return count;
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
 * @see #setSortColumn(TreeColumn)
 *
 * @since 3.2
 */
public TreeColumn getSortColumn () {
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
 * Returns the item which is currently at the top of the receiver.
 * This item can change when items are expanded, collapsed, scrolled
 * or new items are added or removed.
 *
 * @return the item at the top of the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1
 */
public TreeItem getTopItem () {
    checkWidget ();
    HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_FIRSTVISIBLE, 0);
    return hItem !is null ? _getItem (hItem) : null;
}

bool hitTestSelection (HANDLE hItem, int x, int y) {
    if (hItem is null) return false;
    TreeItem item = _getItem (hItem);
    if (item is null) return false;
    if (!hooks (SWT.MeasureItem)) return false;
    bool result = false;

    //BUG? - moved columns, only hittest first column
    //BUG? - check drag detect
    int [] order = new int [1], index = new int [1];

    auto hDC = OS.GetDC (handle);
    HFONT oldFont, newFont = cast(HFONT)OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
    if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
    auto hFont = item.fontHandle (order [index [0]]);
    if (hFont !is cast(HFONT)-1) hFont = OS.SelectObject (hDC, hFont);
    Event event = sendMeasureItemEvent (item, order [index [0]], hDC);
    if (event.getBounds ().contains (x, y)) result = true;
    if (newFont !is null) OS.SelectObject (hDC, oldFont);
    OS.ReleaseDC (handle, hDC);
//  if (isDisposed () || item.isDisposed ()) return false;
    return result;
}

int imageIndex (Image image, int index) {
    if (image is null) return OS.I_IMAGENONE;
    if (imageList is null) {
        Rectangle bounds = image.getBounds ();
        imageList = display.getImageList (style & SWT.RIGHT_TO_LEFT, bounds.width, bounds.height);
    }
    int imageIndex = imageList.indexOf (image);
    if (imageIndex is -1) imageIndex = imageList.add (image);
    if (hwndHeader is null || OS.SendMessage (hwndHeader, OS.HDM_ORDERTOINDEX, 0, 0) is index) {
        /*
        * Feature in Windows.  When setting the same image list multiple
        * times, Windows does work making this operation slow.  The fix
        * is to test for the same image list before setting the new one.
        */
        auto hImageList = imageList.getHandle ();
        auto hOldImageList = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETIMAGELIST, OS.TVSIL_NORMAL, 0);
        if (hOldImageList !is hImageList) {
            OS.SendMessage (handle, OS.TVM_SETIMAGELIST, OS.TVSIL_NORMAL, hImageList);
            updateScrollBar ();
        }
    }
    return imageIndex;
}

int imageIndexHeader (Image image) {
    if (image is null) return OS.I_IMAGENONE;
    if (headerImageList is null) {
        Rectangle bounds = image.getBounds ();
        headerImageList = display.getImageList (style & SWT.RIGHT_TO_LEFT, bounds.width, bounds.height);
        int index = headerImageList.indexOf (image);
        if (index is -1) index = headerImageList.add (image);
        auto hImageList = headerImageList.getHandle ();
        if (hwndHeader !is null) {
            OS.SendMessage (hwndHeader, OS.HDM_SETIMAGELIST, 0, hImageList);
        }
        updateScrollBar ();
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
 *
 * @since 3.1
 */
public int indexOf (TreeColumn column) {
    checkWidget ();
    if (column is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (column.isDisposed()) error(SWT.ERROR_INVALID_ARGUMENT);
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
 *    <li>ERROR_INVALID_ARGUMENT - if the item has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public int indexOf (TreeItem item) {
    checkWidget ();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed()) error(SWT.ERROR_INVALID_ARGUMENT);
    HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
    return hItem is null ? -1 : findIndex (hItem, item.handle);
}

bool isCustomToolTip () {
    return hooks (SWT.MeasureItem);
}

bool isItemSelected (NMTVCUSTOMDRAW* nmcd) {
    bool selected = false;
    if (OS.IsWindowEnabled (handle)) {
        TVITEM tvItem;
        tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
        tvItem.hItem = cast(HTREEITEM)nmcd.nmcd.dwItemSpec;
        OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
        if ((tvItem.state & (OS.TVIS_SELECTED | OS.TVIS_DROPHILITED)) !is 0) {
            selected = true;
            /*
            * Feature in Windows.  When the mouse is pressed and the
            * selection is first drawn for a tree, the previously
            * selected item is redrawn but the the TVIS_SELECTED bits
            * are not cleared.  When the user moves the mouse slightly
            * and a drag and drop operation is not started, the item is
            * drawn again and this time with TVIS_SELECTED is cleared.
            * This means that an item that contains colored cells will
            * not draw with the correct background until the mouse is
            * moved.  The fix is to test for the selection colors and
            * guess that the item is not selected.
            *
            * NOTE: This code does not work when the foreground and
            * background of the tree are set to the selection colors
            * but this does not happen in a regular application.
            */
            if (handle is OS.GetFocus ()) {
                if (OS.GetTextColor (nmcd.nmcd.hdc) !is OS.GetSysColor (OS.COLOR_HIGHLIGHTTEXT)) {
                    selected = false;
                } else {
                    if (OS.GetBkColor (nmcd.nmcd.hdc) !is OS.GetSysColor (OS.COLOR_HIGHLIGHT)) {
                        selected = false;
                    }
                }
            }
        } else {
            if (nmcd.nmcd.dwDrawStage is OS.CDDS_ITEMPOSTPAINT) {
                /*
                * Feature in Windows.  When the mouse is pressed and the
                * selection is first drawn for a tree, the item is drawn
                * selected, but the TVIS_SELECTED bits for the item are
                * not set.  When the user moves the mouse slightly and
                * a drag and drop operation is not started, the item is
                * drawn again and this time TVIS_SELECTED is set.  This
                * means that an item that is in a tree that has the style
                * TVS_FULLROWSELECT and that also contains colored cells
                * will not draw the entire row selected until the user
                * moves the mouse.  The fix is to test for the selection
                * colors and guess that the item is selected.
                *
                * NOTE: This code does not work when the foreground and
                * background of the tree are set to the selection colors
                * but this does not happen in a regular application.
                */
                if (OS.GetTextColor (nmcd.nmcd.hdc) is OS.GetSysColor (OS.COLOR_HIGHLIGHTTEXT)) {
                    if (OS.GetBkColor (nmcd.nmcd.hdc) is OS.GetSysColor (OS.COLOR_HIGHLIGHT)) {
                        selected = true;
                    }
                }
            }
        }
    }
    return selected;
}

void redrawSelection () {
    if ((style & SWT.SINGLE) !is 0) {
        HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
        if (hItem !is null) {
            RECT rect;
            if (OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hItem, &rect, false)) {
                OS.InvalidateRect (handle, &rect, true);
            }
        }
    } else {
        HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_FIRSTVISIBLE, 0);
        if (hItem !is null) {
            TVITEM tvItem;
            static if (OS.IsWinCE) {
                //tvItem = new TVITEM ();
                tvItem.mask = OS.TVIF_STATE;
            }
            RECT rect;
            auto index = 0, count = OS.SendMessage (handle, OS.TVM_GETVISIBLECOUNT, 0, 0);
            while (index <= count && hItem !is null) {
                .LRESULT state = 0;
                static if (OS.IsWinCE) {
                    tvItem.hItem = hItem;
                    OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
                    state = tvItem.state;
                } else {
                    state = OS.SendMessage (handle, OS.TVM_GETITEMSTATE, hItem, OS.TVIS_SELECTED);
                }
                if ((state & OS.TVIS_SELECTED) !is 0) {
                    if (OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hItem, &rect, false)) {
                        OS.InvalidateRect (handle, &rect, true);
                    }
                }
                hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXTVISIBLE, hItem);
                index++;
            }
        }
    }
}

override void register () {
    super.register ();
    if (hwndParent !is null) display.addControl (hwndParent, this);
    if (hwndHeader !is null) display.addControl (hwndHeader, this);
}

void releaseItem (HANDLE hItem, TVITEM* tvItem, bool release) {
    if (hItem is hAnchor) hAnchor = null;
    if (hItem is hInsert) hInsert = null;
    tvItem.hItem = cast(HTREEITEM)hItem;
    if (OS.SendMessage (handle, OS.TVM_GETITEM, 0, tvItem) !is 0) {
        if (tvItem.lParam !is -1) {
            if (tvItem.lParam < lastID) lastID = cast(int)/*64bit*/tvItem.lParam;
            if (release) {
                TreeItem item = items [tvItem.lParam];
                if (item !is null) item.release (false);
            }
            items [tvItem.lParam] = null;
        }
    }
}

void releaseItems (HANDLE hItem, TVITEM* tvItem) {
    hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CHILD, hItem);
    while (hItem !is null) {
        releaseItems (hItem, tvItem);
        releaseItem (hItem, tvItem, true);
        hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hItem);
    }
}

override void releaseHandle () {
    super.releaseHandle ();
    hwndParent = hwndHeader = null;
}

override void releaseChildren (bool destroy) {
    if (items !is null) {
        for (int i=0; i<items.length; i++) {
            TreeItem item = items [i];
            if (item !is null && !item.isDisposed ()) {
                item.release (false);
            }
        }
        items = null;
    }
    if (columns !is null) {
        for (int i=0; i<columns.length; i++) {
            TreeColumn column = columns [i];
            if (column !is null && !column.isDisposed ()) {
                column.release (false);
            }
        }
        columns = null;
    }
    super.releaseChildren (destroy);
}

override void releaseWidget () {
    super.releaseWidget ();
    /*
    * Feature in Windows.  For some reason, when TVM_GETIMAGELIST
    * or TVM_SETIMAGELIST is sent, the tree issues NM_CUSTOMDRAW
    * messages.  This behavior is unwanted when the tree is being
    * disposed.  The fix is to ignore NM_CUSTOMDRAW messages by
    * clearing the custom draw flag.
    *
    * NOTE: This only happens on Windows XP.
    */
    customDraw = false;
    if (imageList !is null) {
        OS.SendMessage (handle, OS.TVM_SETIMAGELIST, OS.TVSIL_NORMAL, 0);
        display.releaseImageList (imageList);
    }
    if (headerImageList !is null) {
        if (hwndHeader !is null) {
            OS.SendMessage (hwndHeader, OS.HDM_SETIMAGELIST, 0, 0);
        }
        display.releaseImageList (headerImageList);
    }
    imageList = headerImageList = null;
    auto hStateList = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETIMAGELIST, OS.TVSIL_STATE, 0);
    OS.SendMessage (handle, OS.TVM_SETIMAGELIST, OS.TVSIL_STATE, 0);
    if (hStateList !is null) OS.ImageList_Destroy (hStateList);
    if (itemToolTipHandle !is null) OS.DestroyWindow (itemToolTipHandle);
    if (headerToolTipHandle !is null) OS.DestroyWindow (headerToolTipHandle);
    itemToolTipHandle = headerToolTipHandle = null;
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
    hFirstIndexOf = hLastIndexOf = null;
    itemCount = -1;
    for (int i=0; i<items.length; i++) {
        TreeItem item = items [i];
        if (item !is null && !item.isDisposed ()) {
            item.release (false);
        }
    }
    ignoreDeselect = ignoreSelect = true;
    bool redraw = drawCount is 0 && OS.IsWindowVisible (handle);
    if (redraw) OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
    shrink = ignoreShrink = true;
    auto result = OS.SendMessage (handle, OS.TVM_DELETEITEM, 0, OS.TVI_ROOT);
    ignoreShrink = false;
    if (redraw) {
        OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
        OS.InvalidateRect (handle, null, true);
    }
    ignoreDeselect = ignoreSelect = false;
    if (result is 0) error (SWT.ERROR_ITEM_NOT_REMOVED);
    if (imageList !is null) {
        OS.SendMessage (handle, OS.TVM_SETIMAGELIST, 0, 0);
        display.releaseImageList (imageList);
    }
    imageList = null;
    if (hwndParent is null && !linesVisible) {
        if (!hooks (SWT.MeasureItem) && !hooks (SWT.EraseItem) && !hooks (SWT.PaintItem)) {
            customDraw = false;
        }
    }
    hAnchor = hInsert = hFirstIndexOf = hLastIndexOf = null;
    itemCount = -1;
    items = new TreeItem [4];
    scrollWidth = 0;
    setScrollWidth ();
    updateScrollBar ();
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
    eventTable.unhook (SWT.Selection, listener);
    eventTable.unhook (SWT.DefaultSelection, listener);
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
 * @see TreeListener
 * @see #addTreeListener
 */
public void removeTreeListener(TreeListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Expand, listener);
    eventTable.unhook (SWT.Collapse, listener);
}

/**
 * Display a mark indicating the point at which an item will be inserted.
 * The drop insert item has a visual hint to show where a dragged item
 * will be inserted when dropped on the tree.
 *
 * @param item the insert item.  Null will clear the insertion mark.
 * @param before true places the insert mark above 'item'. false places
 *  the insert mark below 'item'.
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the item has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setInsertMark (TreeItem item, bool before) {
    checkWidget ();
    HANDLE hItem;
    if (item !is null) {
        if (item.isDisposed()) error(SWT.ERROR_INVALID_ARGUMENT);
        hItem = item.handle;
    }
    hInsert = hItem;
    insertAfter = !before;
    OS.SendMessage (handle, OS.TVM_SETINSERTMARK, insertAfter ? 1 : 0, hInsert);
}

/**
 * Sets the number of root-level items contained in the receiver.
 *
 * @param count the number of items
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setItemCount (int count) {
    checkWidget ();
    count = Math.max (0, count);
    HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
    setItemCount (count, cast(HANDLE) OS.TVGN_ROOT, hItem);
}

void setItemCount (int count, HANDLE hParent, HANDLE hItem) {
    bool redraw = false;
    if (OS.SendMessage (handle, OS.TVM_GETCOUNT, 0, 0) is 0) {
        redraw = drawCount is 0 && OS.IsWindowVisible (handle);
        if (redraw) OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
    }
    int itemCount = 0;
    while (hItem !is null && itemCount < count) {
        hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hItem);
        itemCount++;
    }
    bool expanded = false;
    TVITEM tvItem;
    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM;
    if (!redraw && (style & SWT.VIRTUAL) !is 0) {
        if (OS.IsWinCE) {
            tvItem.hItem = cast(HTREEITEM)hParent;
            tvItem.mask = OS.TVIF_STATE;
            OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
            expanded = (tvItem.state & OS.TVIS_EXPANDED) !is 0;
        } else {
            /*
            * Bug in Windows.  Despite the fact that TVM_GETITEMSTATE claims
            * to return only the bits specified by the stateMask, when called
            * with TVIS_EXPANDED, the entire state is returned.  The fix is
            * to explicitly check for the TVIS_EXPANDED bit.
            */
            auto state = OS.SendMessage (handle, OS.TVM_GETITEMSTATE, hParent, OS.TVIS_EXPANDED);
            expanded = (state & OS.TVIS_EXPANDED) !is 0;
        }
    }
    while (hItem !is null) {
        tvItem.hItem = cast(HTREEITEM)hItem;
        OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
        hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hItem);
        TreeItem item = tvItem.lParam !is -1 ? items [tvItem.lParam] : null;
        if (item !is null && !item.isDisposed ()) {
            item.dispose ();
        } else {
            releaseItem (tvItem.hItem, &tvItem, false);
            destroyItem (null, tvItem.hItem);
        }
    }
    if ((style & SWT.VIRTUAL) !is 0) {
        for (int i=itemCount; i<count; i++) {
            if (expanded) ignoreShrink = true;
            createItem (null, hParent, cast(HTREEITEM) OS.TVI_LAST, null);
            if (expanded) ignoreShrink = false;
        }
    } else {
        shrink = true;
        int extra = Math.max (4, (count + 3) / 4 * 4);
        TreeItem [] newItems = new TreeItem [items.length + extra];
        System.arraycopy (items, 0, newItems, 0, items.length);
        items = newItems;
        for (int i=itemCount; i<count; i++) {
            new TreeItem (this, SWT.NONE, hParent, cast(HTREEITEM) OS.TVI_LAST, null);
        }
    }
    if (redraw) {
        OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
        OS.InvalidateRect (handle, null, true);
    }
}

/**
 * Sets the height of the area which would be used to
 * display <em>one</em> of the items in the tree.
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
    OS.SendMessage (handle, OS.TVM_SETITEMHEIGHT, itemHeight, 0);
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
 *
 * @since 3.1
 */
public void setLinesVisible (bool show) {
    checkWidget ();
    if (linesVisible is show) return;
    linesVisible = show;
    if (hwndParent is null && linesVisible) customDraw = true;
    OS.InvalidateRect (handle, null, true);
}

override HWND scrolledHandle () {
    if (hwndHeader is null) return handle;
    return columnCount is 0 && scrollWidth is 0 ? handle : hwndParent;
}

void select (HANDLE hItem, TVITEM* tvItem) {
    while (hItem !is null) {
        tvItem.hItem = cast(HTREEITEM)hItem;
        OS.SendMessage (handle, OS.TVM_SETITEM, 0, tvItem);
        auto hFirstItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CHILD, hItem);
        select (hFirstItem, tvItem);
        hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hItem);
    }
}

/**
 * Selects an item in the receiver.  If the item was already
 * selected, it remains selected.
 *
 * @param item the item to be selected
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
 * @since 3.4
 */
public void select (TreeItem item) {
    checkWidget ();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
    if ((style & SWT.SINGLE) !is 0) {
        auto hItem = item.handle;
        .LRESULT state = 0;
        static if (OS.IsWinCE) {
            TVITEM tvItem;
            tvItem.hItem = hItem;
            tvItem.mask = OS.TVIF_STATE;
            OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
            state = tvItem.state;
        } else {
            state = OS.SendMessage (handle, OS.TVM_GETITEMSTATE, &hItem, OS.TVIS_SELECTED);
        }
        if ((state & OS.TVIS_SELECTED) !is 0) return;
        /*
        * Feature in Windows.  When an item is selected with
        * TVM_SELECTITEM and TVGN_CARET, the tree expands and
        * scrolls to show the new selected item.  Unfortunately,
        * there is no other way in Windows to set the focus
        * and select an item.  The fix is to save the current
        * scroll bar positions, turn off redraw, select the item,
        * then scroll back to the original position and redraw
        * the entire tree.
        */
        SCROLLINFO* hInfo = null;
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        if ((bits & (OS.TVS_NOHSCROLL | OS.TVS_NOSCROLL)) is 0) {
            hInfo = new SCROLLINFO ();
            hInfo.cbSize = SCROLLINFO.sizeof;
            hInfo.fMask = OS.SIF_ALL;
            OS.GetScrollInfo (handle, OS.SB_HORZ, hInfo);
        }
        SCROLLINFO vInfo;
        vInfo.cbSize = SCROLLINFO.sizeof;
        vInfo.fMask = OS.SIF_ALL;
        OS.GetScrollInfo (handle, OS.SB_VERT, &vInfo);
        bool redraw = drawCount is 0 && OS.IsWindowVisible (handle);
        if (redraw) {
            OS.UpdateWindow (handle);
            OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
        }
        setSelection (item);
        if (hInfo !is null) {
            auto hThumb = OS.MAKELPARAM (OS.SB_THUMBPOSITION, hInfo.nPos);
            OS.SendMessage (handle, OS.WM_HSCROLL, hThumb, 0);
        }
        auto vThumb = OS.MAKELPARAM (OS.SB_THUMBPOSITION, vInfo.nPos);
        OS.SendMessage (handle, OS.WM_VSCROLL, vThumb, 0);
        if (redraw) {
            OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
            OS.InvalidateRect (handle, null, true);
            if ((style & SWT.DOUBLE_BUFFERED) is 0) {
                int oldStyle = style;
                style |= SWT.DOUBLE_BUFFERED;
                OS.UpdateWindow (handle);
                style = oldStyle;
            }
        }
        return;
    }
    TVITEM tvItem;
    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
    tvItem.stateMask = OS.TVIS_SELECTED;
    tvItem.state = OS.TVIS_SELECTED;
    tvItem.hItem = cast(HTREEITEM)item.handle;
    OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
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
    TVITEM tvItem;
    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
    tvItem.state = OS.TVIS_SELECTED;
    tvItem.stateMask = OS.TVIS_SELECTED;
    auto oldProc = OS.GetWindowLongPtr (handle, OS.GWLP_WNDPROC);
    OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)TreeProc);
    if ((style & SWT.VIRTUAL) !is 0) {
        HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
        select (hItem, &tvItem);
    } else {
        for (int i=0; i<items.length; i++) {
            TreeItem item = items [i];
            if (item !is null) {
                tvItem.hItem = cast(HTREEITEM)item.handle;
                OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
            }
        }
    }
    OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, oldProc);
}

Event sendEraseItemEvent (TreeItem item, NMTTCUSTOMDRAW* nmcd, int column, RECT* cellRect) {
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

Event sendMeasureItemEvent (TreeItem item, int index, HDC hDC) {
    RECT* itemRect = item.getBounds (index, true, true, false, false, false, hDC);
    int nSavedDC = OS.SaveDC (hDC);
    GCData data = new GCData ();
    data.device = display;
    data.font = item.getFont (index);
    GC gc = GC.win32_new (hDC, data);
    Event event = new Event ();
    event.item = item;
    event.gc = gc;
    event.index = index;
    event.x = itemRect.left;
    event.y = itemRect.top;
    event.width = itemRect.right - itemRect.left;
    event.height = itemRect.bottom - itemRect.top;
    sendEvent (SWT.MeasureItem, event);
    event.gc = null;
    gc.dispose ();
    OS.RestoreDC (hDC, nSavedDC);
    if (isDisposed () || item.isDisposed ()) return null;
    if (hwndHeader !is null) {
        if (columnCount is 0) {
            if (event.x + event.width > scrollWidth) {
                setScrollWidth (scrollWidth = event.x + event.width);
            }
        }
    }
    if (event.height > getItemHeight ()) setItemHeight (event.height);
    return event;
}

Event sendPaintItemEvent (TreeItem item, NMTTCUSTOMDRAW* nmcd, int column, RECT* itemRect) {
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

override void setBackgroundImage (HBITMAP hBitmap) {
    super.setBackgroundImage (hBitmap);
    if (hBitmap !is null) {
        /*
        * Feature in Windows.  If TVM_SETBKCOLOR is never
        * used to set the background color of a tree, the
        * background color of the lines and the plus/minus
        * will be drawn using the default background color,
        * not the HBRUSH returned from WM_CTLCOLOR.  The fix
        * is to set the background color to the default (when
        * it is already the default) to make Windows use the
        * brush.
        */
        if (OS.SendMessage (handle, OS.TVM_GETBKCOLOR, 0, 0) is -1) {
            OS.SendMessage (handle, OS.TVM_SETBKCOLOR, 0, -1);
        }
        _setBackgroundPixel (-1);
    } else {
        Control control = findBackgroundControl ();
        if (control is null) control = this;
        if (control.backgroundImage is null) {
            setBackgroundPixel (control.getBackgroundPixel ());
        }
    }
    /*
    * Feature in Windows.  When the tree has the style
    * TVS_FULLROWSELECT, the background color for the
    * entire row is filled when an item is painted,
    * drawing on top of the background image.  The fix
    * is to clear TVS_FULLROWSELECT when a background
    * image is set.
    */
    updateFullSelection ();
}

override void setBackgroundPixel (int pixel) {
    Control control = findImageControl ();
    if (control !is null) {
        setBackgroundImage (control.backgroundImage);
        return;
    }
    /*
    * Feature in Windows.  When a tree is given a background color
    * using TVM_SETBKCOLOR and the tree is disabled, Windows draws
    * the tree using the background color rather than the disabled
    * colors.  This is different from the table which draws grayed.
    * The fix is to set the default background color while the tree
    * is disabled and restore it when enabled.
    */
    if (OS.IsWindowEnabled (handle)) _setBackgroundPixel (pixel);

    /*
    * Feature in Windows.  When the tree has the style
    * TVS_FULLROWSELECT, the background color for the
    * entire row is filled when an item is painted,
    * drawing on top of the background image.  The fix
    * is to restore TVS_FULLROWSELECT when a background
    * color is set.
    */
    updateFullSelection ();
}

override void setCursor () {
    /*
    * Bug in Windows.  Under certain circumstances, when WM_SETCURSOR
    * is sent from SendMessage(), Windows GP's in the window proc for
    * the tree.  The fix is to avoid calling the tree window proc and
    * set the cursor for the tree outside of WM_SETCURSOR.
    *
    * NOTE:  This code assumes that the default cursor for the tree
    * is IDC_ARROW.
    */
    Cursor cursor = findCursor ();
    auto hCursor = cursor is null ? OS.LoadCursor (null, cast(TCHAR*) OS.IDC_ARROW) : cursor.handle;
    OS.SetCursor (hCursor);
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
 * @see Tree#getColumnOrder()
 * @see TreeColumn#getMoveable()
 * @see TreeColumn#setMoveable(bool)
 * @see SWT#Move
 *
 * @since 3.2
 */
public void setColumnOrder (int [] order) {
    checkWidget ();
    // SWT extension: allow null array
    //if (order is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (columnCount is 0) {
        if (order.length !is 0) error (SWT.ERROR_INVALID_ARGUMENT);
        return;
    }
    if (order.length !is columnCount) error (SWT.ERROR_INVALID_ARGUMENT);
    int [] oldOrder = new int [columnCount];
    OS.SendMessage (hwndHeader, OS.HDM_GETORDERARRAY, columnCount, oldOrder.ptr);
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
            OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, i, & oldRects [i]);
        }
        OS.SendMessage (hwndHeader, OS.HDM_SETORDERARRAY, order.length, order.ptr);
        OS.InvalidateRect (handle, null, true);
        updateImageList ();
        TreeColumn [] newColumns = new TreeColumn [columnCount];
        System.arraycopy (columns, 0, newColumns, 0, columnCount);
        RECT newRect;
        for (int i=0; i<columnCount; i++) {
            TreeColumn column = newColumns [i];
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

void setCheckboxImageList () {
    if ((style & SWT.CHECK) is 0) return;
    int count = 5, flags = 0;
    static if (OS.IsWinCE) {
        flags |= OS.ILC_COLOR;
    } else {
        if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
            flags |= OS.ILC_COLOR32;
        } else {
            auto hDC = OS.GetDC (handle);
            int bits = OS.GetDeviceCaps (hDC, OS.BITSPIXEL);
            int planes = OS.GetDeviceCaps (hDC, OS.PLANES);
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
            flags |= OS.ILC_MASK;
        }
    }
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) flags |= OS.ILC_MIRROR;
    auto height = OS.SendMessage (handle, OS.TVM_GETITEMHEIGHT, 0, 0), width = height;
    auto hStateList = OS.ImageList_Create (cast(int)/*64bit*/width, cast(int)/*64bit*/height, flags, count, count);
    auto hDC = OS.GetDC (handle);
    auto memDC = OS.CreateCompatibleDC (hDC);
    auto hBitmap = OS.CreateCompatibleBitmap (hDC, cast(int)/*64bit*/width * count, cast(int)/*64bit*/height);
    auto hOldBitmap = OS.SelectObject (memDC, hBitmap);
    RECT rect;
    OS.SetRect (&rect, 0, 0, cast(int)/*64bit*/width * count, cast(int)/*64bit*/height);
    /*
    * NOTE: DrawFrameControl() draws a black and white
    * mask when not drawing a push button.  In order to
    * make the box surrounding the check mark transparent,
    * fill it with a color that is neither black or white.
    */
    int clrBackground = 0;
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
    int itemWidth = cast(int)/*64bit*/Math.min (tm.tmHeight, width);
    int itemHeight = cast(int)/*64bit*/Math.min (tm.tmHeight, height);
    int left = cast(int)/*64bit*/(width - itemWidth) / 2, top = cast(int)/*64bit*/(height - itemHeight) / 2 + 1;
    OS.SetRect (&rect, left + cast(int)/*64bit*/width, top, left + cast(int)/*64bit*/width + itemWidth, top + itemHeight);
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
    auto hOldStateList = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETIMAGELIST, OS.TVSIL_STATE, 0);
    OS.SendMessage (handle, OS.TVM_SETIMAGELIST, OS.TVSIL_STATE, hStateList);
    if (hOldStateList !is null) OS.ImageList_Destroy (hOldStateList);
}

override public void setFont (Font font) {
    checkWidget ();
    super.setFont (font);
    if ((style & SWT.CHECK) !is 0) setCheckboxImageList ();
}

override void setForegroundPixel (int pixel) {
    /*
    * Bug in Windows.  When the tree is using the explorer
    * theme, it does not use COLOR_WINDOW_TEXT for the
    * foreground.  When TVM_SETTEXTCOLOR is called with -1,
    * it resets the color to black, not COLOR_WINDOW_TEXT.
    * The fix is to explicitly set the color.
    */
    if (explorerTheme) {
        if (pixel is -1) pixel = defaultForeground ();
    }
    OS.SendMessage (handle, OS.TVM_SETTEXTCOLOR, 0, pixel);
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
 *
 * @since 3.1
 */
public void setHeaderVisible (bool show) {
    checkWidget ();
    if (hwndHeader is null) {
        if (!show) return;
        createParent ();
    }
    int bits = OS.GetWindowLong (hwndHeader, OS.GWL_STYLE);
    if (show) {
        if ((bits & OS.HDS_HIDDEN) is 0) return;
        bits &= ~OS.HDS_HIDDEN;
        OS.SetWindowLong (hwndHeader, OS.GWL_STYLE, bits);
        OS.ShowWindow (hwndHeader, OS.SW_SHOW);
    } else {
        if ((bits & OS.HDS_HIDDEN) !is 0) return;
        bits |= OS.HDS_HIDDEN;
        OS.SetWindowLong (hwndHeader, OS.GWL_STYLE, bits);
        OS.ShowWindow (hwndHeader, OS.SW_HIDE);
    }
    setScrollWidth ();
    updateHeaderToolTips ();
    updateScrollBar ();
}

override public void setRedraw (bool redraw) {
    checkWidget ();
    /*
    * Feature in Windows.  When WM_SETREDRAW is used to
    * turn off redraw, the scroll bars are updated when
    * items are added and removed.  The fix is to call
    * the default window proc to stop all drawing.
    *
    * Bug in Windows.  For some reason, when WM_SETREDRAW
    * is used to turn redraw on for a tree and the tree
    * contains no items, the last item in the tree does
    * not redraw properly.  If the tree has only one item,
    * that item is not drawn.  If another window is dragged
    * on top of the item, parts of the item are redrawn
    * and erased at random.  The fix is to ensure that this
    * case doesn't happen by inserting and deleting an item
    * when redraw is turned on and there are no items in
    * the tree.
    */
    HANDLE hItem;
    if (redraw) {
        if (drawCount is 1) {
            auto count = OS.SendMessage (handle, OS.TVM_GETCOUNT, 0, 0);
            if (count is 0) {
                TVINSERTSTRUCT tvInsert;
                tvInsert.hInsertAfter = cast(HTREEITEM) OS.TVI_FIRST;
                hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_INSERTITEM, 0, &tvInsert);
            }
            OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
            updateScrollBar ();
        }
    }
    super.setRedraw (redraw);
    if (!redraw) {
        if (drawCount is 1) OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
    }
    if (hItem !is null) {
        ignoreShrink = true;
        OS.SendMessage (handle, OS.TVM_DELETEITEM, 0, hItem);
        ignoreShrink = false;
    }
}

void setScrollWidth () {
    if (hwndHeader is null || hwndParent is null) return;
    int width = 0;
    HDITEM hdItem;
    for (int i=0; i<columnCount; i++) {
        hdItem.mask = OS.HDI_WIDTH;
        OS.SendMessage (hwndHeader, OS.HDM_GETITEM, i, &hdItem);
        width += hdItem.cxy;
    }
    setScrollWidth (Math.max (scrollWidth, width));
}

void setScrollWidth (int width) {
    if (hwndHeader is null || hwndParent is null) return;
    //TEMPORARY CODE
    //scrollWidth = width;
    int left = 0;
    RECT rect;
    SCROLLINFO info;
    info.cbSize = SCROLLINFO.sizeof;
    info.fMask = OS.SIF_RANGE | OS.SIF_PAGE;
    if (columnCount is 0 && width is 0) {
        OS.GetScrollInfo (hwndParent, OS.SB_HORZ, &info);
        info.nPage = info.nMax + 1;
        OS.SetScrollInfo (hwndParent, OS.SB_HORZ, &info, true);
        OS.GetScrollInfo (hwndParent, OS.SB_VERT, &info);
        info.nPage = info.nMax + 1;
        OS.SetScrollInfo (hwndParent, OS.SB_VERT, &info, true);
    } else {
        if ((style & SWT.H_SCROLL) !is 0) {
            OS.GetClientRect (hwndParent, &rect);
            OS.GetScrollInfo (hwndParent, OS.SB_HORZ, &info);
            info.nMax = width;
            info.nPage = rect.right - rect.left + 1;
            OS.SetScrollInfo (hwndParent, OS.SB_HORZ, &info, true);
            info.fMask = OS.SIF_POS;
            OS.GetScrollInfo (hwndParent, OS.SB_HORZ, &info);
            left = info.nPos;
        }
    }
    if (horizontalBar !is null) {
        horizontalBar.setIncrement (INCREMENT);
        horizontalBar.setPageIncrement (info.nPage);
    }
    OS.GetClientRect (hwndParent, &rect);
    HDLAYOUT playout;
    RECT layoutrect = rect;
    playout.prc = &layoutrect;
    WINDOWPOS pos;
    playout.pwpos = &pos;
    OS.SendMessage (hwndHeader, OS.HDM_LAYOUT, 0, &playout);
    SetWindowPos (hwndHeader, cast(HWND)OS.HWND_TOP, pos.x - left, pos.y, pos.cx + left, pos.cy, OS.SWP_NOACTIVATE);
    int bits = OS.GetWindowLong (handle, OS.GWL_EXSTYLE);
    int b = (bits & OS.WS_EX_CLIENTEDGE) !is 0 ? OS.GetSystemMetrics (OS.SM_CXEDGE) : 0;
    int w = pos.cx + (columnCount is 0 && width is 0 ? 0 : OS.GetSystemMetrics (OS.SM_CXVSCROLL));
    int h = rect.bottom - rect.top - pos.cy;
    bool oldIgnore = ignoreResize;
    ignoreResize = true;
    SetWindowPos (handle, null, pos.x - left - b, pos.y + pos.cy - b, w + left + b * 2, h + b * 2, OS.SWP_NOACTIVATE | OS.SWP_NOZORDER);
    ignoreResize = oldIgnore;
}

void setSelection (HANDLE hItem, TVITEM* tvItem, TreeItem [] selection) {
    while (hItem !is null) {
        int index = 0;
        while (index < selection.length) {
            TreeItem item = selection [index];
            if (item !is null && item.handle is hItem) break;
            index++;
        }
        tvItem.hItem = cast(HTREEITEM)hItem;
        OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
        if ((tvItem.state & OS.TVIS_SELECTED) !is 0) {
            if (index is selection.length) {
                tvItem.state = 0;
                OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
            }
        } else {
            if (index !is selection.length) {
                tvItem.state = OS.TVIS_SELECTED;
                OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
            }
        }
        auto hFirstItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CHILD, hItem);
        setSelection (hFirstItem, tvItem, selection);
        hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXT, hItem);
    }
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
public void setSelection (TreeItem item) {
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
 * @see Tree#deselectAll()
 */
public void setSelection (TreeItem [] items) {
    checkWidget ();
    // SWT extension: allow null array
    //if (items is null) error (SWT.ERROR_NULL_ARGUMENT);
    int length = cast(int)/*64bit*/items.length;
    if (length is 0 || ((style & SWT.SINGLE) !is 0 && length > 1)) {
        deselectAll();
        return;
    }

    /* Select/deselect the first item */
    TreeItem item = items [0];
    if (item !is null) {
        if (item.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
        HANDLE hOldItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
        HANDLE hNewItem = hAnchor = item.handle;

        /*
        * Bug in Windows.  When TVM_SELECTITEM is used to select and
        * scroll an item to be visible and the client area of the tree
        * is smaller that the size of one item, TVM_SELECTITEM makes
        * the next item in the tree visible by making it the top item
        * instead of making the desired item visible.  The fix is to
        * detect the case when the client area is too small and make
        * the desired visible item be the top item in the tree.
        *
        * Note that TVM_SELECTITEM when called with TVGN_FIRSTVISIBLE
        * also requires the work around for scrolling.
        */
        bool fixScroll = checkScroll (hNewItem);
        if (fixScroll) {
            OS.SendMessage (handle, OS.WM_SETREDRAW, 1, 0);
            OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
        }
        ignoreSelect = true;
        OS.SendMessage (handle, OS.TVM_SELECTITEM, OS.TVGN_CARET, hNewItem);
        ignoreSelect = false;
        if (OS.SendMessage (handle, OS.TVM_GETVISIBLECOUNT, 0, 0) is 0) {
            OS.SendMessage (handle, OS.TVM_SELECTITEM, OS.TVGN_FIRSTVISIBLE, hNewItem);
            auto hParent = OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_PARENT, hNewItem);
            if (hParent is 0) OS.SendMessage (handle, OS.WM_HSCROLL, OS.SB_TOP, 0);
        }
        if (fixScroll) {
            OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
            OS.SendMessage (handle, OS.WM_SETREDRAW, 0, 0);
        }

        /*
        * Feature in Windows.  When the old and new focused item
        * are the same, Windows does not check to make sure that
        * the item is actually selected, not just focused.  The
        * fix is to force the item to draw selected by setting
        * the state mask, and to ensure that it is visible.
        */
        if (hOldItem is hNewItem) {
            TVITEM tvItem;
            tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
            tvItem.state = OS.TVIS_SELECTED;
            tvItem.stateMask = OS.TVIS_SELECTED;
            tvItem.hItem = cast(HTREEITEM)hNewItem;
            OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
            showItem (hNewItem);
        }
    }
    if ((style & SWT.SINGLE) !is 0) return;

    /* Select/deselect the rest of the items */
    TVITEM tvItem;
    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
    tvItem.stateMask = OS.TVIS_SELECTED;
    auto oldProc = OS.GetWindowLongPtr (handle, OS.GWLP_WNDPROC);
    OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)TreeProc);
    if ((style & SWT.VIRTUAL) !is 0) {
        HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
        setSelection (hItem, &tvItem, items);
    } else {
        for (int i=0; i<this.items.length; i++) {
            item = this.items [i];
            if (item !is null) {
                int index = 0;
                while (index < length) {
                    if (items [index] is item) break;
                    index++;
                }
                tvItem.hItem = cast(HTREEITEM)item.handle;
                OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
                if ((tvItem.state & OS.TVIS_SELECTED) !is 0) {
                    if (index is length) {
                        tvItem.state = 0;
                        OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                    }
                } else {
                    if (index !is length) {
                        tvItem.state = OS.TVIS_SELECTED;
                        OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                    }
                }
            }
        }
    }
    OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, oldProc);
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
public void setSortColumn (TreeColumn column) {
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

/**
 * Sets the item which is currently at the top of the receiver.
 * This item can change when items are expanded, collapsed, scrolled
 * or new items are added or removed.
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
 * @see Tree#getTopItem()
 *
 * @since 2.1
 */
public void setTopItem (TreeItem item) {
    checkWidget ();
    if (item is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed ()) SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    HANDLE hItem = item.handle;
    auto hTopItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_FIRSTVISIBLE, 0);
    if (hItem is hTopItem) return;
    bool fixScroll = checkScroll (hItem), redraw = false;
    if (fixScroll) {
        OS.SendMessage (handle, OS.WM_SETREDRAW, 1, 0);
        OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
    } else {
        redraw = drawCount is 0 && OS.IsWindowVisible (handle);
        if (redraw) OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
    }
    OS.SendMessage (handle, OS.TVM_SELECTITEM, OS.TVGN_FIRSTVISIBLE, hItem);
    auto hParent = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_PARENT, hItem);
    if (hParent is null) OS.SendMessage (handle, OS.WM_HSCROLL, OS.SB_TOP, 0);
    if (fixScroll) {
        OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
        OS.SendMessage (handle, OS.WM_SETREDRAW, 0, 0);
    } else {
        if (redraw) {
            OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
            OS.InvalidateRect (handle, null, true);
        }
    }
    updateScrollBar ();
}

void showItem (HANDLE hItem) {
    /*
    * Bug in Windows.  When TVM_ENSUREVISIBLE is used to ensure
    * that an item is visible and the client area of the tree is
    * smaller that the size of one item, TVM_ENSUREVISIBLE makes
    * the next item in the tree visible by making it the top item
    * instead of making the desired item visible.  The fix is to
    * detect the case when the client area is too small and make
    * the desired visible item be the top item in the tree.
    */
    if (OS.SendMessage (handle, OS.TVM_GETVISIBLECOUNT, 0, 0) is 0) {
        bool fixScroll = checkScroll (hItem);
        if (fixScroll) {
            OS.SendMessage (handle, OS.WM_SETREDRAW, 1, 0);
            OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
        }
        OS.SendMessage (handle, OS.TVM_SELECTITEM, OS.TVGN_FIRSTVISIBLE, hItem);
        /* This code is intentionally commented */
        //auto hParent = OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_PARENT, hItem);
        //if (hParent is 0) OS.SendMessage (handle, OS.WM_HSCROLL, OS.SB_TOP, 0);
        OS.SendMessage (handle, OS.WM_HSCROLL, OS.SB_TOP, 0);
        if (fixScroll) {
            OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
            OS.SendMessage (handle, OS.WM_SETREDRAW, 0, 0);
        }
    } else {
        bool scroll = true;
        RECT itemRect;
        if (OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hItem, &itemRect, true)) {
            forceResize ();
            RECT rect;
            OS.GetClientRect (handle, &rect);
            POINT pt;
            pt.x = itemRect.left;
            pt.y = itemRect.top;
            if (OS.PtInRect (&rect, pt)) {
                pt.y = itemRect.bottom;
                if (OS.PtInRect (&rect, pt)) scroll = false;
            }
        }
        if (scroll) {
            bool fixScroll = checkScroll (hItem);
            if (fixScroll) {
                OS.SendMessage (handle, OS.WM_SETREDRAW, 1, 0);
                OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
            }
            OS.SendMessage (handle, OS.TVM_ENSUREVISIBLE, 0, hItem);
            if (fixScroll) {
                OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
                OS.SendMessage (handle, OS.WM_SETREDRAW, 0, 0);
            }
        }
    }
    if (hwndParent !is null) {
        RECT itemRect;
        if (OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hItem, &itemRect, true)) {
            forceResize ();
            RECT rect;
            OS.GetClientRect (hwndParent, &rect);
            OS.MapWindowPoints (hwndParent, handle, cast(POINT*) &rect, 2);
            POINT pt;
            pt.x = itemRect.left;
            pt.y = itemRect.top;
            if (!OS.PtInRect (&rect, pt)) {
                pt.y = itemRect.bottom;
                if (!OS.PtInRect (&rect, pt)) {
                    SCROLLINFO info;
                    info.cbSize = SCROLLINFO.sizeof;
                    info.fMask = OS.SIF_POS;
                    info.nPos = Math.max (0, pt.x - Tree.INSET / 2);
                    OS.SetScrollInfo (hwndParent, OS.SB_HORZ, &info, true);
                    setScrollWidth ();
                }
            }
        }
    }
    updateScrollBar ();
}

/**
 * Shows the column.  If the column is already showing in the receiver,
 * this method simply returns.  Otherwise, the columns are scrolled until
 * the column is visible.
 *
 * @param column the column to be shown
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
 * @since 3.1
 */
public void showColumn (TreeColumn column) {
    checkWidget ();
    if (column is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (column.isDisposed ()) error(SWT.ERROR_INVALID_ARGUMENT);
    if (column.parent !is this) return;
    int index = indexOf (column);
    if (index is -1) return;
    if (0 <= index && index < columnCount) {
        forceResize ();
        RECT rect;
        OS.GetClientRect (hwndParent, &rect);
        OS.MapWindowPoints (hwndParent, handle, cast(POINT*) &rect, 2);
        RECT headerRect;
        OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, index, &headerRect);
        bool scroll = headerRect.left < rect.left;
        if (!scroll) {
            int width = Math.min (rect.right - rect.left, headerRect.right - headerRect.left);
            scroll = headerRect.left + width > rect.right;
        }
        if (scroll) {
            SCROLLINFO info;
            info.cbSize = SCROLLINFO.sizeof;
            info.fMask = OS.SIF_POS;
            info.nPos = Math.max (0, headerRect.left - Tree.INSET / 2);
            OS.SetScrollInfo (hwndParent, OS.SB_HORZ, &info, true);
            setScrollWidth ();
        }
    }
}

/**
 * Shows the item.  If the item is already showing in the receiver,
 * this method simply returns.  Otherwise, the items are scrolled
 * and expanded until the item is visible.
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
 * @see Tree#showSelection()
 */
public void showItem (TreeItem item) {
    checkWidget ();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed ()) error(SWT.ERROR_INVALID_ARGUMENT);
    showItem (item.handle);
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
 * @see Tree#showItem(TreeItem)
 */
public void showSelection () {
    checkWidget ();
    HANDLE hItem;
    if ((style & SWT.SINGLE) !is 0) {
        hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
        if (hItem is null) return;
        .LRESULT state = 0;
        static if (OS.IsWinCE) {
            TVITEM tvItem;
            tvItem.hItem = hItem;
            tvItem.mask = OS.TVIF_STATE;
            OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
            state = tvItem.state;
        } else {
            state = OS.SendMessage (handle, OS.TVM_GETITEMSTATE, hItem, OS.TVIS_SELECTED);
        }
        if ((state & OS.TVIS_SELECTED) is 0) return;
    } else {
        LONG_PTR oldProc = OS.GetWindowLongPtr (handle, OS.GWLP_WNDPROC);
        OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)TreeProc);
        TVITEM tvItem_;
        TVITEM* tvItem;
        static if (OS.IsWinCE) {
            tvItem = &tvItem_;
            tvItem.mask = OS.TVIF_STATE;
        }
        if ((style & SWT.VIRTUAL) !is 0) {
            auto hRoot = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
            hItem = getNextSelection (hRoot, tvItem);
        } else {
            //FIXME - this code expands first selected item it finds
            int index = 0;
            while (index <items.length) {
                TreeItem item = items [index];
                if (item !is null) {
                    .LRESULT state = 0;
                    static if (OS.IsWinCE) {
                        tvItem.hItem = item.handle;
                        OS.SendMessage (handle, OS.TVM_GETITEM, 0, tvItem);
                        state = tvItem.state;
                    } else {
                        state = OS.SendMessage (handle, OS.TVM_GETITEMSTATE, item.handle, OS.TVIS_SELECTED);
                    }
                    if ((state & OS.TVIS_SELECTED) !is 0) {
                        hItem = item.handle;
                        break;
                    }
                }
                index++;
            }
        }
        OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, oldProc);
    }
    if (hItem !is null) showItem (hItem);
}

/*public*/ void sort () {
    checkWidget ();
    if ((style & SWT.VIRTUAL) !is 0) return;
    sort ( cast(HTREEITEM) OS.TVI_ROOT, false);
}

void sort (HANDLE hParent, bool all) {
    auto itemCount = OS.SendMessage (handle, OS.TVM_GETCOUNT, 0, 0);
    if (itemCount is 0 || itemCount is 1) return;
    hFirstIndexOf = hLastIndexOf = null;
    itemCount = -1;
    if (sortDirection is SWT.UP || sortDirection is SWT.NONE) {
        OS.SendMessage (handle, OS.TVM_SORTCHILDREN, all ? 1 : 0, hParent);
    } else {
        //Callback compareCallback = new Callback (this, "CompareFunc", 3);
        //int lpfnCompare = compareCallback.getAddress ();
        sThis = this;
        TVSORTCB psort;
        psort.hParent = cast(HTREEITEM)hParent;
        psort.lpfnCompare = &CompareFunc;
        psort.lParam = sortColumn is null ? 0 : indexOf (sortColumn);
        OS.SendMessage (handle, OS.TVM_SORTCHILDRENCB, all ? 1 : 0, &psort);
        sThis = null;
        //compareCallback.dispose ();
    }
}

override void subclass () {
    super.subclass ();
    if (hwndHeader !is null) {
        OS.SetWindowLongPtr (hwndHeader, OS.GWLP_WNDPROC, display.windowProc);
    }
}

RECT* toolTipInset (RECT* rect) {
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
        RECT* insetRect = new RECT();
        OS.SetRect (insetRect, rect.left - 1, rect.top - 1, rect.right + 1, rect.bottom + 1);
        return insetRect;
    }
    return rect;
}

RECT* toolTipRect (RECT* rect) {
    RECT* toolRect = new RECT ();
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
        OS.SetRect (toolRect, rect.left - 1, rect.top - 1, rect.right + 1, rect.bottom + 1);
    } else {
        OS.SetRect (toolRect, rect.left, rect.top, rect.right, rect.bottom);
        int dwStyle = OS.GetWindowLong (itemToolTipHandle, OS.GWL_STYLE);
        int dwExStyle = OS.GetWindowLong (itemToolTipHandle, OS.GWL_EXSTYLE);
        OS.AdjustWindowRectEx (toolRect, dwStyle, false, dwExStyle);
    }
    return toolRect;
}

override String toolTipText (NMTTDISPINFO* hdr) {
    auto hwndToolTip = cast(HWND) OS.SendMessage (handle, OS.TVM_GETTOOLTIPS, 0, 0);
    if (hwndToolTip is hdr.hdr.hwndFrom && toolTipText_ !is null) return ""; //$NON-NLS-1$
    if (headerToolTipHandle is hdr.hdr.hwndFrom) {
        for (int i=0; i<columnCount; i++) {
            TreeColumn column = columns [i];
            if (column.id is hdr.hdr.idFrom) return column.toolTipText;
        }
        return super.toolTipText (hdr);
    }
    if (itemToolTipHandle is hdr.hdr.hwndFrom) {
        if (toolTipText_ !is null) return "";
        int pos = OS.GetMessagePos ();
        POINT pt;
        OS.POINTSTOPOINT (pt, pos);
        OS.ScreenToClient (handle, &pt);
        int index;
        TreeItem item;
        RECT* cellRect, itemRect;
        if (findCell (pt.x, pt.y, item, index, cellRect, itemRect)) {
            String text = null;
            if (index is 0) {
                text = item.text;
            } else {
                String[] strings = item.strings;
                if (strings !is null) text = strings [index];
            }
            //TEMPORARY CODE
            if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
                if (isCustomToolTip ()) text = " ";
            }
            if (text !is null) return text;
        }
    }
    return super.toolTipText (hdr);
}

override HWND topHandle () {
    return hwndParent !is null ? hwndParent : handle;
}

void updateFullSelection () {
    if ((style & SWT.FULL_SELECTION) !is 0) {
        int oldBits = OS.GetWindowLong (handle, OS.GWL_STYLE), newBits = oldBits;
        if ((newBits & OS.TVS_FULLROWSELECT) !is 0) {
            if (!OS.IsWindowEnabled (handle) || findImageControl () !is null) {
                if (!explorerTheme) newBits &= ~OS.TVS_FULLROWSELECT;
            }
        } else {
            if (OS.IsWindowEnabled (handle) && findImageControl () is null) {
                if (!hooks (SWT.EraseItem) && !hooks (SWT.PaintItem)) {
                    newBits |= OS.TVS_FULLROWSELECT;
                }
            }
        }
        if (newBits !is oldBits) {
            OS.SetWindowLong (handle, OS.GWL_STYLE, newBits);
            OS.InvalidateRect (handle, null, true);
        }
    }
}

void updateHeaderToolTips () {
    if (headerToolTipHandle is null) return;
    RECT rect;
    TOOLINFO lpti;
    lpti.cbSize = OS.TOOLINFO_sizeof;
    lpti.uFlags = OS.TTF_SUBCLASS;
    lpti.hwnd = hwndHeader;
    lpti.lpszText = OS.LPSTR_TEXTCALLBACK;
    for (int i=0; i<columnCount; i++) {
        TreeColumn column = columns [i];
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

void updateImageList () {
    if (imageList is null) return;
    if (hwndHeader is null) return;
    auto i = 0, index = OS.SendMessage (hwndHeader, OS.HDM_ORDERTOINDEX, 0, 0);
    while (i < items.length) {
        TreeItem item = items [i];
        if (item !is null) {
            Image image = null;
            if (index is 0) {
                image = item.image;
            } else {
                Image [] images = item.images;
                if (images !is null) image = images [index];
            }
            if (image !is null) break;
        }
        i++;
    }
    /*
    * Feature in Windows.  When setting the same image list multiple
    * times, Windows does work making this operation slow.  The fix
    * is to test for the same image list before setting the new one.
    */
    HBITMAP hImageList = i is items.length ? null : imageList.getHandle ();
    HANDLE hOldImageList = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETIMAGELIST, OS.TVSIL_NORMAL, 0);
    if (hImageList !is hOldImageList) {
        OS.SendMessage (handle, OS.TVM_SETIMAGELIST, OS.TVSIL_NORMAL, hImageList);
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

void updateScrollBar () {
    if (hwndParent !is null) {
        if (columnCount !is 0 || scrollWidth !is 0) {
            SCROLLINFO info;
            info.cbSize = SCROLLINFO.sizeof;
            info.fMask = OS.SIF_ALL;
            auto itemCount = OS.SendMessage (handle, OS.TVM_GETCOUNT, 0, 0);
            if (itemCount is 0) {
                OS.GetScrollInfo (hwndParent, OS.SB_VERT, &info);
                info.nPage = info.nMax + 1;
                OS.SetScrollInfo (hwndParent, OS.SB_VERT, &info, true);
            } else {
                OS.GetScrollInfo (handle, OS.SB_VERT, &info);
                if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION(4, 10)) {
                    if (info.nPage is 0) {
                        SCROLLBARINFO psbi;
                        psbi.cbSize = SCROLLBARINFO.sizeof;
                        OS.GetScrollBarInfo (handle, OS.OBJID_VSCROLL, &psbi);
                        if ((psbi.rgstate [0] & OS.STATE_SYSTEM_INVISIBLE) !is 0) {
                            info.nPage = info.nMax + 1;
                        }
                    }
                }
                OS.SetScrollInfo (hwndParent, OS.SB_VERT, &info, true);
            }
        }
    }
}

override void unsubclass () {
    super.unsubclass ();
    if (hwndHeader !is null) {
        OS.SetWindowLongPtr (hwndHeader, OS.GWLP_WNDPROC, cast(LONG_PTR)HeaderProc);
    }
}

override int widgetStyle () {
    int bits = super.widgetStyle () | OS.TVS_SHOWSELALWAYS | OS.TVS_LINESATROOT | OS.TVS_HASBUTTONS | OS.TVS_NONEVENHEIGHT;
    if (EXPLORER_THEME && !OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0) && OS.IsAppThemed ()) {
        bits |= OS.TVS_TRACKSELECT;
        if ((style & SWT.FULL_SELECTION) !is 0) bits |= OS.TVS_FULLROWSELECT;
    } else {
        if ((style & SWT.FULL_SELECTION) !is 0) {
            bits |= OS.TVS_FULLROWSELECT;
        } else {
            bits |= OS.TVS_HASLINES;
        }
    }
    if ((style & (SWT.H_SCROLL | SWT.V_SCROLL)) is 0) {
        bits &= ~(OS.WS_HSCROLL | OS.WS_VSCROLL);
        bits |= OS.TVS_NOSCROLL;
    } else {
        if ((style & SWT.H_SCROLL) is 0) {
            bits &= ~OS.WS_HSCROLL;
            bits |= OS.TVS_NOHSCROLL;
        }
    }
//  bits |= OS.TVS_NOTOOLTIPS | OS.TVS_DISABLEDRAGDROP;
    return bits | OS.TVS_DISABLEDRAGDROP;
}

override String windowClass () {
    return TCHARsToStr(TreeClass);
}

override ptrdiff_t windowProc () {
    return cast(ptrdiff_t) TreeProc;
}

override .LRESULT windowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (hwndHeader !is null && hwnd is hwndHeader) {
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
                    if (lParam !is 0 && cast(HANDLE) lParam !is hwndHeader) {
                        OS.InvalidateRect (hwndHeader, null, true);
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
                if (cast(HWND)wParam is hwnd) {
                    int hitTest = cast(short) OS.LOWORD (lParam);
                    if (hitTest is OS.HTCLIENT) {
                        HDHITTESTINFO pinfo;
                        int pos = OS.GetMessagePos ();
                        POINT pt;
                        OS.POINTSTOPOINT (pt, pos);
                        OS.ScreenToClient (hwnd, &pt);
                        pinfo.pt.x = pt.x;
                        pinfo.pt.y = pt.y;
                        auto index = OS.SendMessage (hwndHeader, OS.HDM_HITTEST, 0, &pinfo);
                        if (0 <= index && index < columnCount && !columns [index].resizable) {
                            if ((pinfo.flags & (OS.HHT_ONDIVIDER | OS.HHT_ONDIVOPEN)) !is 0) {
                                OS.SetCursor (OS.LoadCursor (null, cast(TCHAR*) OS.IDC_ARROW));
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
    if (hwndParent !is null && hwnd is hwndParent) {
        switch (msg) {
            case OS.WM_MOVE: {
                sendEvent (SWT.Move);
                return 0;
            }
            case OS.WM_SIZE: {
                setScrollWidth ();
                if (ignoreResize) return 0;
                setResizeChildren (false);
                auto code = callWindowProc (hwnd, OS.WM_SIZE, wParam, lParam);
                sendEvent (SWT.Resize);
                if (isDisposed ()) return 0;
                if (layout_ !is null) {
                    markLayout (false, false);
                    updateLayout (false, false);
                }
                setResizeChildren (true);
                updateScrollBar ();
                return code;
            }
            case OS.WM_NCPAINT: {
                LRESULT result = wmNCPaint (hwnd, wParam, lParam);
                if (result !is null) return result.value;
                break;
            }
            case OS.WM_PRINT: {
                LRESULT result = wmPrint (hwnd, wParam, lParam);
                if (result !is null) return result.value;
                break;
            }
            case OS.WM_COMMAND:
            case OS.WM_NOTIFY:
            case OS.WM_SYSCOLORCHANGE: {
                return OS.SendMessage (handle, msg, wParam, lParam);
            }
            case OS.WM_HSCROLL: {
                /*
                * Bug on WinCE.  lParam should be NULL when the message is not sent
                * by a scroll bar control, but it contains the handle to the window.
                * When the message is sent by a scroll bar control, it correctly
                * contains the handle to the scroll bar.  The fix is to check for
                * both.
                */
                if (horizontalBar !is null && (lParam is 0 || lParam is cast(ptrdiff_t)hwndParent)) {
                    wmScroll (horizontalBar, true, hwndParent, OS.WM_HSCROLL, wParam, lParam);
                }
                setScrollWidth ();
                break;
            }
            case OS.WM_VSCROLL: {
                SCROLLINFO info;
                info.cbSize = SCROLLINFO.sizeof;
                info.fMask = OS.SIF_ALL;
                OS.GetScrollInfo (hwndParent, OS.SB_VERT, &info);
                /*
                * Update the nPos field to match the nTrackPos field
                * so that the tree scrolls when the scroll bar of the
                * parent is dragged.
                *
                * NOTE: For some reason, this code is only necessary
                * on Windows Vista.
                */
                if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
                    if (OS.LOWORD (wParam) is OS.SB_THUMBTRACK) {
                        info.nPos = info.nTrackPos;
                    }
                }
                OS.SetScrollInfo (handle, OS.SB_VERT, &info, true);
                auto code = OS.SendMessage (handle, OS.WM_VSCROLL, wParam, lParam);
                OS.GetScrollInfo (handle, OS.SB_VERT, &info);
                OS.SetScrollInfo (hwndParent, OS.SB_VERT, &info, true);
                return code;
            }
            default:
        }
        return callWindowProc (hwnd, msg, wParam, lParam);
    }
    if (msg is Display.DI_GETDRAGIMAGE) {
        /*
        * When there is more than one item selected, DI_GETDRAGIMAGE
        * returns the item under the cursor.  This happens because
        * the tree does not have implement multi-select.  The fix
        * is to disable DI_GETDRAGIMAGE when more than one item is
        * selected.
        */
        if ((style & SWT.MULTI) !is 0 || hooks (SWT.EraseItem) || hooks (SWT.PaintItem)) {
            auto hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_FIRSTVISIBLE, 0);
            TreeItem [] items = new TreeItem [10];
            TVITEM tvItem;
            tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM | OS.TVIF_STATE;
            int count = getSelection (hItem, &tvItem, items, 0, 10, false, true);
            if (count is 0) return 0;
            POINT mousePos;
            OS.POINTSTOPOINT (mousePos, OS.GetMessagePos ());
            OS.MapWindowPoints (null, handle, &mousePos, 1);
            RECT clientRect;
            OS.GetClientRect(handle, &clientRect);
            RECT rect = *(items [0].getBounds (0, true, true, false));
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
            for (int i = 1; i < count; i++) {
                if (rect.bottom - rect.top > DRAG_IMAGE_SIZE) break;
                if (rect.bottom > clientRect.bottom) break;
                RECT itemRect = *(items[i].getBounds (0, true, true, false));
                if ((style & SWT.FULL_SELECTION) !is 0) {
                    itemRect.left = rect.left;
                    itemRect.right = rect.right;
                }
                auto rectRgn = OS.CreateRectRgn (itemRect.left, itemRect.top, itemRect.right, itemRect.bottom);
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
            void* [1] pBits;
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
    /*
    * Feature in Windows.  The tree control beeps
    * in WM_CHAR when the search for the item that
    * matches the key stroke fails.  This is the
    * standard tree behavior but is unexpected when
    * the key that was typed was ESC, CR or SPACE.
    * The fix is to avoid calling the tree window
    * proc in these cases.
    */
    switch (wParam) {
        case ' ': {
            HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
            if (hItem !is null) {
                hAnchor = hItem;
                OS.SendMessage (handle, OS.TVM_ENSUREVISIBLE, 0, hItem);
                TVITEM tvItem;
                tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE | OS.TVIF_PARAM;
                tvItem.hItem = cast(HTREEITEM)hItem;
                if ((style & SWT.CHECK) !is 0) {
                    tvItem.stateMask = OS.TVIS_STATEIMAGEMASK;
                    OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
                    int state = tvItem.state >> 12;
                    if ((state & 0x1) !is 0) {
                        state++;
                    } else  {
                        --state;
                    }
                    tvItem.state = state << 12;
                    OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                    static if (!OS.IsWinCE) {
                        auto id = cast(int)/*64bit*/hItem;
                        if (OS.COMCTL32_MAJOR >= 6) {
                            id = cast(int)/*64bit*/OS.SendMessage (handle, OS.TVM_MAPHTREEITEMTOACCID, hItem, 0);
                        }
                        OS.NotifyWinEvent (OS.EVENT_OBJECT_FOCUS, handle, OS.OBJID_CLIENT, id);
                    }
                }
                tvItem.stateMask = OS.TVIS_SELECTED;
                OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
                if ((style & SWT.MULTI) !is 0 && OS.GetKeyState (OS.VK_CONTROL) < 0) {
                    if ((tvItem.state & OS.TVIS_SELECTED) !is 0) {
                        tvItem.state &= ~OS.TVIS_SELECTED;
                    } else {
                        tvItem.state |= OS.TVIS_SELECTED;
                    }
                } else {
                    tvItem.state |= OS.TVIS_SELECTED;
                }
                OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                TreeItem item = _getItem (hItem, tvItem.lParam);
                Event event = new Event ();
                event.item = item;
                postEvent (SWT.Selection, event);
                if ((style & SWT.CHECK) !is 0) {
                    event = new Event ();
                    event.item = item;
                    event.detail = SWT.CHECK;
                    postEvent (SWT.Selection, event);
                }
            }
            return LRESULT.ZERO;
        }
        case SWT.CR: {
            /*
            * Feature in Windows.  Windows sends NM_RETURN from WM_KEYDOWN
            * instead of using WM_CHAR.  This means that application code
            * that expects to consume the key press and therefore avoid a
            * SWT.DefaultSelection event from WM_CHAR will fail.  The fix
            * is to implement SWT.DefaultSelection in WM_CHAR instead of
            * using NM_RETURN.
            */
            Event event = new Event ();
            HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
            if (hItem !is null) event.item = _getItem (hItem);
            postEvent (SWT.DefaultSelection, event);
            return LRESULT.ZERO;
        }
        case SWT.ESC:
            return LRESULT.ZERO;
        default:
    }
    return result;
}

override LRESULT WM_ERASEBKGND (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_ERASEBKGND (wParam, lParam);
    if ((style & SWT.DOUBLE_BUFFERED) !is 0) return LRESULT.ONE;
    if (findImageControl () !is null) return LRESULT.ONE;
    return result;
}

override LRESULT WM_GETOBJECT (WPARAM wParam, LPARAM lParam) {
    /*
    * Ensure that there is an accessible object created for this
    * control because support for checked item and tree column
    * accessibility is temporarily implemented in the accessibility
    * package.
    */
    if ((style & SWT.CHECK) !is 0 || hwndParent !is null) {
        if (accessible is null) accessible = new_Accessible (this);
    }
    return super.WM_GETOBJECT (wParam, lParam);
}

override LRESULT WM_HSCROLL (WPARAM wParam, LPARAM lParam) {
    bool fixScroll = false;
    if ((style & SWT.DOUBLE_BUFFERED) !is 0) {
        fixScroll = (style & SWT.VIRTUAL) !is 0 || hooks (SWT.EraseItem) || hooks (SWT.PaintItem);
    }
    if (fixScroll) {
        style &= ~SWT.DOUBLE_BUFFERED;
        if (explorerTheme) {
            OS.SendMessage (handle, OS.TVM_SETEXTENDEDSTYLE, OS.TVS_EX_DOUBLEBUFFER, 0);
        }
    }
    LRESULT result = super.WM_HSCROLL (wParam, lParam);
    if (fixScroll) {
        style |= SWT.DOUBLE_BUFFERED;
        if (explorerTheme) {
            OS.SendMessage (handle, OS.TVM_SETEXTENDEDSTYLE, OS.TVS_EX_DOUBLEBUFFER, OS.TVS_EX_DOUBLEBUFFER);
        }
    }
    if (result !is null) return result;
    return result;
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
                if (hwndHeader !is null) {
                    TreeColumn [] newColumns = new TreeColumn [columnCount];
                    System.arraycopy (columns, 0, newColumns, 0, columnCount);
                    for (int i=0; i<columnCount; i++) {
                        TreeColumn column = newColumns [i];
                        if (!column.isDisposed () && column.getResizable ()) {
                            column.pack ();
                        }
                    }
                }
            }
            break;
        case OS.VK_UP:
        case OS.VK_DOWN:
        case OS.VK_PRIOR:
        case OS.VK_NEXT:
        case OS.VK_HOME:
        case OS.VK_END: {
            OS.SendMessage (handle, OS.WM_CHANGEUISTATE, OS.UIS_INITIALIZE, 0);
            if ((style & SWT.SINGLE) !is 0) break;
            if (OS.GetKeyState (OS.VK_SHIFT) < 0) {
                HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
                if (hItem !is null) {
                    if (hAnchor is null) hAnchor = hItem;
                    ignoreSelect = ignoreDeselect = true;
                    auto code = callWindowProc (handle, OS.WM_KEYDOWN, wParam, lParam);
                    ignoreSelect = ignoreDeselect = false;
                    auto hNewItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
                    TVITEM tvItem;
                    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
                    tvItem.stateMask = OS.TVIS_SELECTED;
                    auto hDeselectItem = hItem;
                    RECT rect1;
                    if (!OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hAnchor, &rect1, false)) {
                        hAnchor = hItem;
                        OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hAnchor, &rect1, false);
                    }
                    RECT rect2;
                    OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hDeselectItem, &rect2, false);
                    int flags = rect1.top < rect2.top ? OS.TVGN_PREVIOUSVISIBLE : OS.TVGN_NEXTVISIBLE;
                    while (hDeselectItem !is hAnchor) {
                        tvItem.hItem = cast(HTREEITEM)hDeselectItem;
                        OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                        hDeselectItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, flags, hDeselectItem);
                    }
                    auto hSelectItem = hAnchor;
                    OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hNewItem, &rect1, false);
                    OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hSelectItem, &rect2, false);
                    tvItem.state = OS.TVIS_SELECTED;
                    flags = rect1.top < rect2.top ? OS.TVGN_PREVIOUSVISIBLE : OS.TVGN_NEXTVISIBLE;
                    while (hSelectItem !is hNewItem) {
                        tvItem.hItem = cast(HTREEITEM)hSelectItem;
                        OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                        hSelectItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, flags, hSelectItem);
                    }
                    tvItem.hItem = cast(HTREEITEM)hNewItem;
                    OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM;
                    tvItem.hItem = cast(HTREEITEM)hNewItem;
                    OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
                    Event event = new Event ();
                    event.item = _getItem (hNewItem, tvItem.lParam);
                    postEvent (SWT.Selection, event);
                    return new LRESULT (code);
                }
            }
            if (OS.GetKeyState (OS.VK_CONTROL) < 0) {
                HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
                if (hItem !is null) {
                    TVITEM tvItem;
                    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
                    tvItem.stateMask = OS.TVIS_SELECTED;
                    tvItem.hItem = cast(HTREEITEM)hItem;
                    OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
                    bool oldSelected = (tvItem.state & OS.TVIS_SELECTED) !is 0;
                    HANDLE hNewItem;
                    switch (wParam) {
                        case OS.VK_UP:
                            hNewItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_PREVIOUSVISIBLE, hItem);
                            break;
                        case OS.VK_DOWN:
                            hNewItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXTVISIBLE, hItem);
                            break;
                        case OS.VK_HOME:
                            hNewItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
                            break;
                        case OS.VK_PRIOR:
                            hNewItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_FIRSTVISIBLE, 0);
                            if (hNewItem is hItem) {
                                OS.SendMessage (handle, OS.WM_VSCROLL, OS.SB_PAGEUP, 0);
                                hNewItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_FIRSTVISIBLE, 0);
                            }
                            break;
                        case OS.VK_NEXT:
                            RECT rect, clientRect;
                            OS.GetClientRect (handle, &clientRect);
                            hNewItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_FIRSTVISIBLE, 0);
                            do {
                                auto hVisible = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXTVISIBLE, hNewItem);
                                if (hVisible is null) break;
                                if (!OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hVisible, &rect, false)) break;
                                if (rect.bottom > clientRect.bottom) break;
                                if ((hNewItem = hVisible) is hItem) {
                                    OS.SendMessage (handle, OS.WM_VSCROLL, OS.SB_PAGEDOWN, 0);
                                }
                            } while (hNewItem !is null);
                            break;
                        case OS.VK_END:
                            hNewItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_LASTVISIBLE, 0);
                            break;
                        default:
                    }
                    if (hNewItem !is null) {
                        OS.SendMessage (handle, OS.TVM_ENSUREVISIBLE, 0, hNewItem);
                        tvItem.hItem = cast(HTREEITEM)hNewItem;
                        OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
                        bool newSelected = (tvItem.state & OS.TVIS_SELECTED) !is 0;
                        bool redraw = !newSelected && drawCount is 0 && OS.IsWindowVisible (handle);
                        if (redraw) {
                            OS.UpdateWindow (handle);
                            OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
                        }
                        hSelect = hNewItem;
                        ignoreSelect = true;
                        OS.SendMessage (handle, OS.TVM_SELECTITEM, OS.TVGN_CARET, hNewItem);
                        ignoreSelect = false;
                        hSelect = null;
                        if (oldSelected) {
                            tvItem.state = OS.TVIS_SELECTED;
                            tvItem.hItem = cast(HTREEITEM)hItem;
                            OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                        }
                        if (!newSelected) {
                            tvItem.state = 0;
                            tvItem.hItem = cast(HTREEITEM)hNewItem;
                            OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                        }
                        if (redraw) {
                            RECT rect1, rect2;
                            bool fItemRect = (style & SWT.FULL_SELECTION) is 0;
                            if (hooks (SWT.EraseItem) || hooks (SWT.PaintItem)) fItemRect = false;
                            if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) fItemRect = false;
                            OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hItem, &rect1, fItemRect);
                            OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hNewItem, &rect2, fItemRect);
                            OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
                            OS.InvalidateRect (handle, &rect1, true);
                            OS.InvalidateRect (handle, &rect2, true);
                            OS.UpdateWindow (handle);
                        }
                        return LRESULT.ZERO;
                    }
                }
            }
            auto code = callWindowProc (handle, OS.WM_KEYDOWN, wParam, lParam);
            hAnchor = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
            return new LRESULT (code);
        }
        default:
    }
    return result;
}

override LRESULT WM_KILLFOCUS (WPARAM wParam, LPARAM lParam) {
    /*
    * Bug in Windows.  When a tree item that has an image
    * with alpha is expanded or collapsed, the area where
    * the image is drawn is not erased before it is drawn.
    * This means that the image gets darker each time.
    * The fix is to redraw the selection.
    *
    * Feature in Windows.  When multiple item have
    * the TVIS_SELECTED state, Windows redraws only
    * the focused item in the color used to show the
    * selection when the tree loses or gains focus.
    * The fix is to force Windows to redraw the
    * selection when focus is gained or lost.
    */
    bool redraw = (style & SWT.MULTI) !is 0;
    if (!redraw) {
        if (!OS.IsWinCE && OS.COMCTL32_MAJOR >= 6) {
            if (imageList !is null) {
                int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
                if ((bits & OS.TVS_FULLROWSELECT) is 0) {
                    redraw = true;
                }
            }
        }
    }
    if (redraw) redrawSelection ();
    return super.WM_KILLFOCUS (wParam, lParam);
}

override LRESULT WM_LBUTTONDBLCLK (WPARAM wParam, LPARAM lParam) {
    TVHITTESTINFO lpht;
    lpht.pt.x = OS.GET_X_LPARAM (lParam);
    lpht.pt.y = OS.GET_Y_LPARAM (lParam);
    OS.SendMessage (handle, OS.TVM_HITTEST, 0, &lpht);
    if (lpht.hItem !is null) {
        if ((style & SWT.CHECK) !is 0) {
            if ((lpht.flags & OS.TVHT_ONITEMSTATEICON) !is 0) {
                Display display = this.display;
                display.captureChanged = false;
                sendMouseEvent (SWT.MouseDown, 1, handle, OS.WM_LBUTTONDOWN, wParam, lParam);
                if (!sendMouseEvent (SWT.MouseDoubleClick, 1, handle, OS.WM_LBUTTONDBLCLK, wParam, lParam)) {
                    if (!display.captureChanged && !isDisposed ()) {
                        if (OS.GetCapture () !is handle) OS.SetCapture (handle);
                    }
                    return LRESULT.ZERO;
                }
                if (!display.captureChanged && !isDisposed ()) {
                    if (OS.GetCapture () !is handle) OS.SetCapture (handle);
                }
                OS.SetFocus (handle);
                TVITEM tvItem;
                tvItem.hItem = lpht.hItem;
                tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM | OS.TVIF_STATE;
                tvItem.stateMask = OS.TVIS_STATEIMAGEMASK;
                OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
                int state = tvItem.state >> 12;
                if ((state & 0x1) !is 0) {
                    state++;
                } else  {
                    --state;
                }
                tvItem.state = state << 12;
                OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                static if (!OS.IsWinCE) {
                    int id = cast(int)/*64bit*/tvItem.hItem;
                    if (OS.COMCTL32_MAJOR >= 6) {
                        id = cast(int)/*64bit*/OS.SendMessage (handle, OS.TVM_MAPHTREEITEMTOACCID, tvItem.hItem, 0);
                    }
                    OS.NotifyWinEvent (OS.EVENT_OBJECT_FOCUS, handle, OS.OBJID_CLIENT, id);
                }
                Event event = new Event ();
                event.item = _getItem (tvItem.hItem, tvItem.lParam);
                event.detail = SWT.CHECK;
                postEvent (SWT.Selection, event);
                return LRESULT.ZERO;
            }
        }
    }
    LRESULT result = super.WM_LBUTTONDBLCLK (wParam, lParam);
    if (result is LRESULT.ZERO) return result;
    if (lpht.hItem !is null) {
        int flags = OS.TVHT_ONITEM;
        if ((style & SWT.FULL_SELECTION) !is 0) {
            flags |= OS.TVHT_ONITEMRIGHT | OS.TVHT_ONITEMINDENT;
        } else {
            if (hooks (SWT.MeasureItem)) {
                lpht.flags &= ~(OS.TVHT_ONITEMICON | OS.TVHT_ONITEMLABEL);
                if (hitTestSelection (lpht.hItem, lpht.pt.x, lpht.pt.y)) {
                    lpht.flags |= OS.TVHT_ONITEMICON | OS.TVHT_ONITEMLABEL;
                }
            }
        }
        if ((lpht.flags & flags) !is 0) {
            Event event = new Event ();
            event.item = _getItem (lpht.hItem);
            postEvent (SWT.DefaultSelection, event);
        }
    }
    return result;
}

override LRESULT WM_LBUTTONDOWN (WPARAM wParam, LPARAM lParam) {
    /*
    * In a multi-select tree, if the user is collapsing a subtree that
    * contains selected items, clear the selection from these items and
    * issue a selection event.  Only items that are selected and visible
    * are cleared.  This code also runs in the case when the white space
    * below the last item is selected.
    */
    TVHITTESTINFO lpht;
    lpht.pt.x = OS.GET_X_LPARAM (lParam);
    lpht.pt.y = OS.GET_Y_LPARAM (lParam);
    OS.SendMessage (handle, OS.TVM_HITTEST, 0, &lpht);
    if (lpht.hItem is null || (lpht.flags & OS.TVHT_ONITEMBUTTON) !is 0) {
        Display display = this.display;
        display.captureChanged = false;
        if (!sendMouseEvent (SWT.MouseDown, 1, handle, OS.WM_LBUTTONDOWN, wParam, lParam)) {
            if (!display.captureChanged && !isDisposed ()) {
                if (OS.GetCapture () !is handle) OS.SetCapture (handle);
            }
            return LRESULT.ZERO;
        }
        bool fixSelection = false, deselected = false;
        HANDLE hOldSelection = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
        if (lpht.hItem !is null && (style & SWT.MULTI) !is 0) {
            if (hOldSelection !is null) {
                TVITEM tvItem;
                tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
                tvItem.hItem = lpht.hItem;
                OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
                if ((tvItem.state & OS.TVIS_EXPANDED) !is 0) {
                    fixSelection = true;
                    tvItem.stateMask = OS.TVIS_SELECTED;
                    auto hNext = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXTVISIBLE, lpht.hItem);
                    while (hNext !is null) {
                        if (hNext is hAnchor) hAnchor = null;
                        tvItem.hItem = cast(HTREEITEM)hNext;
                        OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
                        if ((tvItem.state & OS.TVIS_SELECTED) !is 0) deselected = true;
                        tvItem.state = 0;
                        OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                        HANDLE hItem = hNext = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_NEXTVISIBLE, hNext);
                        while (hItem !is null && hItem !is lpht.hItem) {
                            hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_PARENT, hItem);
                        }
                        if (hItem is null) break;
                    }
                }
            }
        }
        dragStarted = gestureCompleted = false;
        if (fixSelection) ignoreDeselect = ignoreSelect = lockSelection = true;
        auto code = callWindowProc (handle, OS.WM_LBUTTONDOWN, wParam, lParam);
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
            if (OS.GetFocus () !is handle) OS.SetFocus (handle);
        }
        if (fixSelection) ignoreDeselect = ignoreSelect = lockSelection = false;
        HANDLE hNewSelection = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
        if (hOldSelection !is hNewSelection) hAnchor = hNewSelection;
        if (dragStarted) {
            if (!display.captureChanged && !isDisposed ()) {
                if (OS.GetCapture () !is handle) OS.SetCapture (handle);
            }
        }
        /*
        * Bug in Windows.  When a tree has no images and an item is
        * expanded or collapsed, for some reason, Windows changes
        * the size of the selection.  When the user expands a tree
        * item, the selection rectangle is made a few pixels larger.
        * When the user collapses an item, the selection rectangle
        * is restored to the original size but the selection is not
        * redrawn, causing pixel corruption.  The fix is to detect
        * this case and redraw the item.
        */
        if ((lpht.flags & OS.TVHT_ONITEMBUTTON) !is 0) {
            int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
            if ((bits & OS.TVS_FULLROWSELECT) is 0) {
                if (OS.SendMessage (handle, OS.TVM_GETIMAGELIST, OS.TVSIL_NORMAL, 0) is 0) {
                    auto hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
                    if (hItem !is null) {
                        RECT rect;
                        if (OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hItem, &rect, false)) {
                            OS.InvalidateRect (handle, &rect, true);
                        }
                    }
                }
            }
        }
        if (deselected) {
            Event event = new Event ();
            event.item = _getItem (lpht.hItem);
            postEvent (SWT.Selection, event);
        }
        return new LRESULT (code);
    }

    /* Look for check/uncheck */
    if ((style & SWT.CHECK) !is 0) {
        if ((lpht.flags & OS.TVHT_ONITEMSTATEICON) !is 0) {
            Display display = this.display;
            display.captureChanged = false;
            if (!sendMouseEvent (SWT.MouseDown, 1, handle, OS.WM_LBUTTONDOWN, wParam, lParam)) {
                if (!display.captureChanged && !isDisposed ()) {
                    if (OS.GetCapture () !is handle) OS.SetCapture (handle);
                }
                return LRESULT.ZERO;
            }
            if (!display.captureChanged && !isDisposed ()) {
                if (OS.GetCapture () !is handle) OS.SetCapture (handle);
            }
            OS.SetFocus (handle);
            TVITEM tvItem;
            tvItem.hItem = lpht.hItem;
            tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM | OS.TVIF_STATE;
            tvItem.stateMask = OS.TVIS_STATEIMAGEMASK;
            OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
            int state = tvItem.state >> 12;
            if ((state & 0x1) !is 0) {
                state++;
            } else  {
                --state;
            }
            tvItem.state = state << 12;
            OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
            static if (!OS.IsWinCE) {
                int id = cast(int)/*64bit*/tvItem.hItem;
                if (OS.COMCTL32_MAJOR >= 6) {
                    id = cast(int)/*64bit*/OS.SendMessage (handle, OS.TVM_MAPHTREEITEMTOACCID, tvItem.hItem, 0);
                }
                OS.NotifyWinEvent (OS.EVENT_OBJECT_FOCUS, handle, OS.OBJID_CLIENT, id);
            }
            Event event = new Event ();
            event.item = _getItem (tvItem.hItem, tvItem.lParam);
            event.detail = SWT.CHECK;
            postEvent (SWT.Selection, event);
            return LRESULT.ZERO;
        }
    }

    /*
    * Feature in Windows.  When the tree has the style
    * TVS_FULLROWSELECT, the background color for the
    * entire row is filled when an item is painted,
    * drawing on top of any custom drawing.  The fix
    * is to emulate TVS_FULLROWSELECT.
    */
    bool selected = false;
    bool fakeSelection = false;
    if (lpht.hItem !is null) {
        if ((style & SWT.FULL_SELECTION) !is 0) {
            int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
            if ((bits & OS.TVS_FULLROWSELECT) is 0) fakeSelection = true;
        } else {
            if (hooks (SWT.MeasureItem)) {
                selected = hitTestSelection (lpht.hItem, lpht.pt.x, lpht.pt.y) !is 0;
                if (selected) {
                    if ((lpht.flags & OS.TVHT_ONITEM) is 0) fakeSelection = true;
                }
            }
        }
    }

    /* Process the mouse when an item is not selected */
    if (!selected && (style & SWT.FULL_SELECTION) is 0) {
        if ((lpht.flags & OS.TVHT_ONITEM) is 0) {
            Display display = this.display;
            display.captureChanged = false;
            if (!sendMouseEvent (SWT.MouseDown, 1, handle, OS.WM_LBUTTONDOWN, wParam, lParam)) {
                if (!display.captureChanged && !isDisposed ()) {
                    if (OS.GetCapture () !is handle) OS.SetCapture (handle);
                }
                return LRESULT.ZERO;
            }
            auto code = callWindowProc (handle, OS.WM_LBUTTONDOWN, wParam, lParam);
            if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
                if (OS.GetFocus () !is handle) OS.SetFocus (handle);
            }
            if (!display.captureChanged && !isDisposed ()) {
                if (OS.GetCapture () !is handle) OS.SetCapture (handle);
            }
            return new LRESULT (code);
        }
    }

    /* Get the selected state of the item under the mouse */
    TVITEM tvItem;
    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
    tvItem.stateMask = OS.TVIS_SELECTED;
    bool hittestSelected = false;
    if ((style & SWT.MULTI) !is 0) {
        tvItem.hItem = lpht.hItem;
        OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
        hittestSelected = (tvItem.state & OS.TVIS_SELECTED) !is 0;
    }

    /* Get the selected state of the last selected item */
    auto hOldItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
    if ((style & SWT.MULTI) !is 0) {
        tvItem.hItem = cast(HTREEITEM)hOldItem;
        OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);

        /* Check for CONTROL or drag selection */
        if (hittestSelected || (wParam & OS.MK_CONTROL) !is 0) {
            /*
            * Feature in Windows.  When the tree is not drawing focus
            * and the user selects a tree item while the CONTROL key
            * is down, the tree window proc sends WM_UPDATEUISTATE
            * to the top level window, causing controls within the shell
            * to redraw.  When drag detect is enabled, the tree window
            * proc runs a modal loop that allows WM_PAINT messages to be
            * delivered during WM_LBUTTONDOWN.  When WM_SETREDRAW is used
            * to disable drawing for the tree and a WM_PAINT happens for
            * a parent of the tree (or a sibling that overlaps), the parent
            * will draw on top of the tree.  If WM_SETREDRAW is turned back
            * on without redrawing the entire tree, pixel corruption occurs.
            * This case only seems to happen when the tree has been given
            * focus from WM_MOUSEACTIVATE of the shell.  The fix is to
            * force the WM_UPDATEUISTATE to be sent before disabling
            * the drawing.
            *
            * NOTE:  Any redraw of a parent (or sibling) will be dispatched
            * during the modal drag detect loop.  This code only fixes the
            * case where the tree causes a redraw from WM_UPDATEUISTATE.
            * In SWT, the InvalidateRect() that caused the pixel corruption
            * is found in Composite.WM_UPDATEUISTATE().
            */
            auto uiState = OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
            if ((uiState & OS.UISF_HIDEFOCUS) !is 0) {
                OS.SendMessage (handle, OS.WM_CHANGEUISTATE, OS.UIS_INITIALIZE, 0);
            }
            OS.UpdateWindow (handle);
            OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
        } else {
            deselectAll ();
        }
    }

    /* Do the selection */
    Display display = this.display;
    display.captureChanged = false;
    if (!sendMouseEvent (SWT.MouseDown, 1, handle, OS.WM_LBUTTONDOWN, wParam, lParam)) {
        if (!display.captureChanged && !isDisposed ()) {
            if (OS.GetCapture () !is handle) OS.SetCapture (handle);
        }
        return LRESULT.ZERO;
    }
    hSelect = lpht.hItem;
    dragStarted = gestureCompleted = false;
    ignoreDeselect = ignoreSelect = true;
    auto code = callWindowProc (handle, OS.WM_LBUTTONDOWN, wParam, lParam);
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
        if (OS.GetFocus () !is handle) OS.SetFocus (handle);
    }
    auto hNewItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
    if (fakeSelection) {
        if (hOldItem is null || (hNewItem is hOldItem && lpht.hItem !is hOldItem)) {
            OS.SendMessage (handle, OS.TVM_SELECTITEM, OS.TVGN_CARET, lpht.hItem);
            hNewItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CARET, 0);
        }
        if (!dragStarted && (state & DRAG_DETECT) !is 0 && hooks (SWT.DragDetect)) {
            dragStarted = dragDetect (handle, lpht.pt.x, lpht.pt.y, false, null, null);
        }
    }
    ignoreDeselect = ignoreSelect = false;
    hSelect = null;
    if (dragStarted) {
        if (!display.captureChanged && !isDisposed ()) {
            if (OS.GetCapture () !is handle) OS.SetCapture (handle);
        }
    }

    /*
    * Feature in Windows.  When the old and new focused item
    * are the same, Windows does not check to make sure that
    * the item is actually selected, not just focused.  The
    * fix is to force the item to draw selected by setting
    * the state mask.  This is only necessary when the tree
    * is single select.
    */
    if ((style & SWT.SINGLE) !is 0) {
        if (hOldItem is hNewItem) {
            tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
            tvItem.state = OS.TVIS_SELECTED;
            tvItem.stateMask = OS.TVIS_SELECTED;
            tvItem.hItem = cast(HTREEITEM)hNewItem;
            OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
        }
    }

    /* Reselect the last item that was unselected */
    if ((style & SWT.MULTI) !is 0) {

        /* Check for CONTROL and reselect the last item */
        if (hittestSelected || (wParam & OS.MK_CONTROL) !is 0) {
            if (hOldItem is hNewItem && hOldItem is lpht.hItem) {
                if ((wParam & OS.MK_CONTROL) !is 0) {
                    tvItem.state ^= OS.TVIS_SELECTED;
                    if (dragStarted) tvItem.state = OS.TVIS_SELECTED;
                    OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                }
            } else {
                if ((tvItem.state & OS.TVIS_SELECTED) !is 0) {
                    tvItem.state = OS.TVIS_SELECTED;
                    OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                }
                if ((wParam & OS.MK_CONTROL) !is 0 && !dragStarted) {
                    if (hittestSelected) {
                        tvItem.state = 0;
                        tvItem.hItem = lpht.hItem;
                        OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                    }
                }
            }
            RECT rect1, rect2;
            bool fItemRect = (style & SWT.FULL_SELECTION) is 0;
            if (hooks (SWT.EraseItem) || hooks (SWT.PaintItem)) fItemRect = false;
            if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) fItemRect = false;
            OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hOldItem, &rect1, fItemRect);
            OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hNewItem, &rect2, fItemRect);
            OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
            OS.InvalidateRect (handle, &rect1, true);
            OS.InvalidateRect (handle, &rect2, true);
            OS.UpdateWindow (handle);
        }

        /* Check for SHIFT or normal select and deselect/reselect items */
        if ((wParam & OS.MK_CONTROL) is 0) {
            if (!hittestSelected || !dragStarted) {
                tvItem.state = 0;
                auto oldProc = OS.GetWindowLongPtr (handle, OS.GWLP_WNDPROC);
                OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, cast(LONG_PTR)TreeProc);
                if ((style & SWT.VIRTUAL) !is 0) {
                    HANDLE hItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_ROOT, 0);
                    deselect (hItem, &tvItem, hNewItem);
                } else {
                    for (int i=0; i<items.length; i++) {
                        TreeItem item = items [i];
                        if (item !is null && item.handle !is hNewItem) {
                            tvItem.hItem = cast(HTREEITEM)item.handle;
                            OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                        }
                    }
                }
                tvItem.hItem = cast(HTREEITEM)hNewItem;
                tvItem.state = OS.TVIS_SELECTED;
                OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                OS.SetWindowLongPtr (handle, OS.GWLP_WNDPROC, oldProc);
                if ((wParam & OS.MK_SHIFT) !is 0) {
                    RECT rect1;
                    if (hAnchor is null) hAnchor = hNewItem;
                    if (OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hAnchor, &rect1, false)) {
                        RECT rect2;
                        if (OS.TreeView_GetItemRect (handle, cast(HTREEITEM)hNewItem, &rect2, false)) {
                            int flags = rect1.top < rect2.top ? OS.TVGN_NEXTVISIBLE : OS.TVGN_PREVIOUSVISIBLE;
                            tvItem.state = OS.TVIS_SELECTED;
                            auto hItem = tvItem.hItem = cast(HTREEITEM)hAnchor;
                            OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                            while (hItem !is hNewItem) {
                                tvItem.hItem = hItem;
                                OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                                hItem = cast(HTREEITEM) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, flags, hItem);
                            }
                        }
                    }
                }
            }
        }
    }
    if ((wParam & OS.MK_SHIFT) is 0) hAnchor = hNewItem;

    /* Issue notification */
    if (!gestureCompleted) {
        tvItem.hItem = cast(HTREEITEM)hNewItem;
        tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM;
        OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
        Event event = new Event ();
        event.item = _getItem (tvItem.hItem, tvItem.lParam);
        postEvent (SWT.Selection, event);
    }
    gestureCompleted = false;

    /*
    * Feature in Windows.  Inside WM_LBUTTONDOWN and WM_RBUTTONDOWN,
    * the widget starts a modal loop to determine if the user wants
    * to begin a drag/drop operation or marquee select.  Unfortunately,
    * this modal loop eats the corresponding mouse up.  The fix is to
    * detect the cases when the modal loop has eaten the mouse up and
    * issue a fake mouse up.
    */
    if (dragStarted) {
        sendDragEvent (1, OS.GET_X_LPARAM (lParam), OS.GET_Y_LPARAM (lParam));
    } else {
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        if ((bits & OS.TVS_DISABLEDRAGDROP) is 0) {
            sendMouseEvent (SWT.MouseUp, 1, handle, OS.WM_LBUTTONUP, wParam, lParam);
        }
    }
    dragStarted = false;
    return new LRESULT (code);
}

override LRESULT WM_MOUSEMOVE (WPARAM wParam, LPARAM lParam) {
    Display display = this.display;
    LRESULT result = super.WM_MOUSEMOVE (wParam, lParam);
    if (result !is null) return result;
    if (itemToolTipHandle !is null) {
        /*
        * Bug in Windows.  On some machines that do not have XBUTTONs,
        * the MK_XBUTTON1 and OS.MK_XBUTTON2 bits are sometimes set,
        * causing mouse capture to become stuck.  The fix is to test
        * for the extra buttons only when they exist.
        */
        int mask = OS.MK_LBUTTON | OS.MK_MBUTTON | OS.MK_RBUTTON;
        if (display.xMouse) mask |= OS.MK_XBUTTON1 | OS.MK_XBUTTON2;
        if ((wParam & mask) is 0) {
            int x = OS.GET_X_LPARAM (lParam);
            int y = OS.GET_Y_LPARAM (lParam);
            int index;
            TreeItem item;
            RECT* cellRect, itemRect;
            if (findCell (x, y, item, index, cellRect, itemRect)) {
                /*
                * Feature in Windows.  When the new tool rectangle is
                * set using TTM_NEWTOOLRECT and the tooltip is visible,
                * Windows draws the tooltip right away and the sends
                * WM_NOTIFY with TTN_SHOW.  This means that the tooltip
                * shows first at the wrong location and then moves to
                * the right one.  The fix is to hide the tooltip window.
                */
                if (OS.SendMessage (itemToolTipHandle, OS.TTM_GETCURRENTTOOL, 0, 0) is 0) {
                    if (OS.IsWindowVisible (itemToolTipHandle)) {
                        OS.ShowWindow (itemToolTipHandle, OS.SW_HIDE);
                    }
                }
                TOOLINFO lpti;
                lpti.cbSize = OS.TOOLINFO_sizeof;
                lpti.hwnd = handle;
                lpti.uId = cast(ptrdiff_t)handle;
                lpti.uFlags = OS.TTF_SUBCLASS | OS.TTF_TRANSPARENT;
                lpti.rect.left = cellRect.left;
                lpti.rect.top = cellRect.top;
                lpti.rect.right = cellRect.right;
                lpti.rect.bottom = cellRect.bottom;
                OS.SendMessage (itemToolTipHandle, OS.TTM_NEWTOOLRECT, 0, &lpti);
            }
        }
    }
    return result;
}

override LRESULT WM_MOVE (WPARAM wParam, LPARAM lParam) {
    if (ignoreResize) return null;
    return super.WM_MOVE (wParam, lParam);
}

override LRESULT WM_RBUTTONDOWN (WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  The receiver uses WM_RBUTTONDOWN
    * to initiate a drag/drop operation depending on how the
    * user moves the mouse.  If the user clicks the right button,
    * without moving the mouse, the tree consumes the corresponding
    * WM_RBUTTONUP.  The fix is to avoid calling the window proc for
    * the tree.
    */
    Display display = this.display;
    display.captureChanged = false;
    if (!sendMouseEvent (SWT.MouseDown, 3, handle, OS.WM_RBUTTONDOWN, wParam, lParam)) {
        if (!display.captureChanged && !isDisposed ()) {
            if (OS.GetCapture () !is handle) OS.SetCapture (handle);
        }
        return LRESULT.ZERO;
    }
    /*
    * This code is intentionally commented.
    */
//  if (OS.GetCapture () !is handle) OS.SetCapture (handle);
    if (OS.GetFocus () !is handle) OS.SetFocus (handle);

    /*
    * Feature in Windows.  When the user selects a tree item
    * with the right mouse button, the item remains selected
    * only as long as the user does not release or move the
    * mouse.  As soon as this happens, the selection snaps
    * back to the previous selection.  This behavior can be
    * observed in the Explorer but is not instantly apparent
    * because the Explorer explicitly sets the selection when
    * the user chooses a menu item.  If the user cancels the
    * menu, the selection snaps back.  The fix is to avoid
    * calling the window proc and do the selection ourselves.
    * This behavior is consistent with the table.
    */
    TVHITTESTINFO lpht;
    lpht.pt.x = OS.GET_X_LPARAM (lParam);
    lpht.pt.y = OS.GET_Y_LPARAM (lParam);
    OS.SendMessage (handle, OS.TVM_HITTEST, 0, &lpht);
    if (lpht.hItem !is null) {
        bool fakeSelection = (style & SWT.FULL_SELECTION) !is 0;
        if (!fakeSelection) {
            if (hooks (SWT.MeasureItem)) {
                fakeSelection = hitTestSelection (lpht.hItem, lpht.pt.x, lpht.pt.y);
            } else {
                int flags = OS.TVHT_ONITEMICON | OS.TVHT_ONITEMLABEL;
                fakeSelection = (lpht.flags & flags) !is 0;
            }
        }
        if (fakeSelection) {
            if ((wParam & (OS.MK_CONTROL | OS.MK_SHIFT)) is 0) {
                TVITEM tvItem;
                tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_STATE;
                tvItem.stateMask = OS.TVIS_SELECTED;
                tvItem.hItem = lpht.hItem;
                OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
                if ((tvItem.state & OS.TVIS_SELECTED) is 0) {
                    ignoreSelect = true;
                    OS.SendMessage (handle, OS.TVM_SELECTITEM, OS.TVGN_CARET, 0);
                    ignoreSelect = false;
                    OS.SendMessage (handle, OS.TVM_SELECTITEM, OS.TVGN_CARET, lpht.hItem);
                }
            }
        }
    }
    return LRESULT.ZERO;
}

override LRESULT WM_PAINT (WPARAM wParam, LPARAM lParam) {
    if (shrink && !ignoreShrink) {
        /* Resize the item array to fit the last item */
        int count = cast(int)/*64bit*/items.length - 1;
        while (count >= 0) {
            if (items [count] !is null) break;
            --count;
        }
        count++;
        if (items.length > 4 && items.length - count > 3) {
            int length = Math.max (4, (count + 3) / 4 * 4);
            TreeItem [] newItems = new TreeItem [length];
            System.arraycopy (items, 0, newItems, 0, count);
            items = newItems;
        }
        shrink = false;
    }
    if ((style & SWT.DOUBLE_BUFFERED) !is 0 || findImageControl () !is null) {
        bool doubleBuffer = true;
        if (explorerTheme) {
            auto exStyle = OS.SendMessage (handle, OS.TVM_GETEXTENDEDSTYLE, 0, 0);
            if ((exStyle & OS.TVS_EX_DOUBLEBUFFER) !is 0) doubleBuffer = false;
        }
        if (doubleBuffer) {
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
                RECT rect;
                OS.SetRect (&rect, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right, ps.rcPaint.bottom);
                drawBackground (hDC, &rect);
                callWindowProc (handle, OS.WM_PAINT, cast(WPARAM)hDC, 0);
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
    return super.WM_PAINT (wParam, lParam);
}

override LRESULT WM_PRINTCLIENT (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_PRINTCLIENT (wParam, lParam);
    if (result !is null) return result;
    /*
    * Feature in Windows.  For some reason, when WM_PRINT is used
    * to capture an image of a hierarchy that contains a tree with
    * columns, the clipping that is used to stop the first column
    * from drawing on top of subsequent columns stops the first
    * column and the tree lines from drawing.  This does not happen
    * during WM_PAINT.  The fix is to draw without clipping and
    * then draw the rest of the columns on top.  Since the drawing
    * is happening in WM_PRINTCLIENT, the redrawing is not visible.
    */
    printClient = true;
    auto code = callWindowProc (handle, OS.WM_PRINTCLIENT, wParam, lParam);
    printClient = false;
    return new LRESULT (code);
}

override LRESULT WM_SETFOCUS (WPARAM wParam, LPARAM lParam) {
    /*
    * Bug in Windows.  When a tree item that has an image
    * with alpha is expanded or collapsed, the area where
    * the image is drawn is not erased before it is drawn.
    * This means that the image gets darker each time.
    * The fix is to redraw the selection.
    *
    * Feature in Windows.  When multiple item have
    * the TVIS_SELECTED state, Windows redraws only
    * the focused item in the color used to show the
    * selection when the tree loses or gains focus.
    * The fix is to force Windows to redraw the
    * selection when focus is gained or lost.
    */
    bool redraw = (style & SWT.MULTI) !is 0;
    if (!redraw) {
        if (!OS.IsWinCE && OS.COMCTL32_MAJOR >= 6) {
            if (imageList !is null) {
                int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
                if ((bits & OS.TVS_FULLROWSELECT) is 0) {
                    redraw = true;
                }
            }
        }
    }
    if (redraw) redrawSelection ();
    return super.WM_SETFOCUS (wParam, lParam);
}

override LRESULT WM_SETFONT (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SETFONT (wParam, lParam);
    if (result !is null) return result;
    if (hwndHeader !is null) {
        /*
        * Bug in Windows.  When a header has a sort indicator
        * triangle, Windows resizes the indicator based on the
        * size of the n-1th font.  The fix is to always make
        * the n-1th font be the default.  This makes the sort
        * indicator always be the default size.
        */
        OS.SendMessage (hwndHeader, OS.WM_SETFONT, 0, lParam);
        OS.SendMessage (hwndHeader, OS.WM_SETFONT, wParam, lParam);
    }
    if (itemToolTipHandle !is null) {
        OS.SendMessage (itemToolTipHandle, OS.WM_SETFONT, wParam, lParam);
    }
    if (headerToolTipHandle !is null) {
        OS.SendMessage (headerToolTipHandle, OS.WM_SETFONT, wParam, lParam);
    }
    return result;
}

override LRESULT WM_SETREDRAW (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SETREDRAW (wParam, lParam);
    if (result !is null) return result;
    /*
    * Bug in Windows.  Under certain circumstances, when
    * WM_SETREDRAW is used to turn off drawing and then
    * TVM_GETITEMRECT is sent to get the bounds of an item
    * that is not inside the client area, Windows segment
    * faults.  The fix is to call the default window proc
    * rather than the default tree proc.
    *
    * NOTE:  This problem is intermittent and happens on
    * Windows Vista running under the theme manager.
    */
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
        auto code = OS.DefWindowProc (handle, OS.WM_SETREDRAW, wParam, lParam);
        return code is 0 ? LRESULT.ZERO : new LRESULT (code);
    }
    return result;
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    /*
    * Bug in Windows.  When TVS_NOHSCROLL is set when the
    * size of the tree is zero, the scroll bar is shown the
    * next time the tree resizes.  The fix is to hide the
    * scroll bar every time the tree is resized.
    */
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    if ((bits & OS.TVS_NOHSCROLL) !is 0) {
        static if (!OS.IsWinCE) OS.ShowScrollBar (handle, OS.SB_HORZ, false);
    }
    /*
    * Bug in Windows.  On Vista, when the Explorer theme
    * is used with a full selection tree, when the tree
    * is resized to be smaller, the rounded right edge
    * of the selected items is not drawn.  The fix is the
    * redraw the entire tree.
    */
    if (explorerTheme && (style & SWT.FULL_SELECTION) !is 0) {
        OS.InvalidateRect (handle, null, false);
    }
    if (ignoreResize) return null;
    return super.WM_SIZE (wParam, lParam);
}

override LRESULT WM_SYSCOLORCHANGE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SYSCOLORCHANGE (wParam, lParam);
    if (result !is null) return result;
    /*
    * Bug in Windows.  When the tree is using the explorer
    * theme, it does not use COLOR_WINDOW_TEXT for the
    * default foreground color.  The fix is to explicitly
    * set the foreground.
    */
    if (explorerTheme) {
        if (foreground is -1) setForegroundPixel (-1);
    }
    if ((style & SWT.CHECK) !is 0) setCheckboxImageList ();
    return result;
}

override LRESULT WM_VSCROLL (WPARAM wParam, LPARAM lParam) {
    bool fixScroll = false;
    if ((style & SWT.DOUBLE_BUFFERED) !is 0) {
        int code = OS.LOWORD (wParam);
        switch (code) {
            case OS.SB_TOP:
            case OS.SB_BOTTOM:
            case OS.SB_LINEDOWN:
            case OS.SB_LINEUP:
            case OS.SB_PAGEDOWN:
            case OS.SB_PAGEUP:
                fixScroll = (style & SWT.VIRTUAL) !is 0 || hooks (SWT.EraseItem) || hooks (SWT.PaintItem);
                break;
            default:
        }
    }
    if (fixScroll) {
        style &= ~SWT.DOUBLE_BUFFERED;
        if (explorerTheme) {
            OS.SendMessage (handle, OS.TVM_SETEXTENDEDSTYLE, OS.TVS_EX_DOUBLEBUFFER, 0);
        }
    }
    LRESULT result = super.WM_VSCROLL (wParam, lParam);
    if (fixScroll) {
        style |= SWT.DOUBLE_BUFFERED;
        if (explorerTheme) {
            OS.SendMessage (handle, OS.TVM_SETEXTENDEDSTYLE, OS.TVS_EX_DOUBLEBUFFER, OS.TVS_EX_DOUBLEBUFFER);
        }
    }
    if (result !is null) return result;
    return result;
}

override LRESULT wmColorChild (WPARAM wParam, LPARAM lParam) {
    if (findImageControl () !is null) {
        if (OS.COMCTL32_MAJOR < 6) {
            return super.wmColorChild (wParam, lParam);
        }
        return new LRESULT (OS.GetStockObject (OS.NULL_BRUSH));
    }
    /*
    * Feature in Windows.  Tree controls send WM_CTLCOLOREDIT
    * to allow application code to change the default colors.
    * This is undocumented and conflicts with TVM_SETTEXTCOLOR
    * and TVM_SETBKCOLOR, the documented way to do this.  The
    * fix is to ignore WM_CTLCOLOREDIT messages from trees.
    */
    return null;
}

override LRESULT wmNotify (NMHDR* hdr, WPARAM wParam, LPARAM lParam) {
    if (hdr.hwndFrom is itemToolTipHandle) {
        LRESULT result = wmNotifyToolTip (hdr, wParam, lParam);
        if (result !is null) return result;
    }
    if (hdr.hwndFrom is hwndHeader) {
        LRESULT result = wmNotifyHeader (hdr, wParam, lParam);
        if (result !is null) return result;
    }
    return super.wmNotify (hdr, wParam, lParam);
}

override LRESULT wmNotifyChild (NMHDR* hdr, WPARAM wParam, LPARAM lParam) {
    switch (hdr.code) {
        case OS.TVN_GETDISPINFOA:
        case OS.TVN_GETDISPINFOW: {
            NMTVDISPINFO* lptvdi = cast(NMTVDISPINFO*)lParam;
            //OS.MoveMemory (lptvdi, lParam, NMTVDISPINFO.sizeof);
            if ((style & SWT.VIRTUAL) !is 0) {
                /*
                * Feature in Windows.  When a new tree item is inserted
                * using TVM_INSERTITEM, a TVN_GETDISPINFO is sent before
                * TVM_INSERTITEM returns and before the item is added to
                * the items array.  The fix is to check for null.
                *
                * NOTE: This only happens on XP with the version 6.00 of
                * COMCTL32.DLL.
                */
                bool checkVisible = true;
                /*
                * When an item is being deleted from a virtual tree, do not
                * allow the application to provide data for a new item that
                * becomes visible until the item has been removed from the
                * items array.  Because arbitrary application code can run
                * during the callback, the items array might be accessed
                * in an inconsistent state.  Rather than answering the data
                * right away, queue a redraw for later.
                */
                if (!ignoreShrink) {
                    if (items !is null && lptvdi.item.lParam !is -1) {
                        if (items [lptvdi.item.lParam] !is null && items [lptvdi.item.lParam].cached) {
                            checkVisible = false;
                        }
                    }
                }
                if (checkVisible) {
                    if (drawCount !is 0 || !OS.IsWindowVisible (handle)) break;
                    RECT itemRect;
                    if (!OS.TreeView_GetItemRect (handle, lptvdi.item.hItem, &itemRect, false)) {
                        break;
                    }
                    RECT rect;
                    OS.GetClientRect (handle, &rect);
                    if (!OS.IntersectRect (&rect, &rect, &itemRect)) break;
                    if (ignoreShrink) {
                        OS.InvalidateRect (handle, &rect, true);
                        break;
                    }
                }
            }
            if (items is null) break;
            /*
            * Bug in Windows.  If the lParam field of TVITEM
            * is changed during custom draw using TVM_SETITEM,
            * the lItemlParam field of the NMTVCUSTOMDRAW struct
            * is not updated until the next custom draw.  The
            * fix is to query the field from the item instead
            * of using the struct.
            */
            auto id = lptvdi.item.lParam;
            if ((style & SWT.VIRTUAL) !is 0) {
                if (id is -1) {
                    TVITEM tvItem;
                    tvItem.mask = OS.TVIF_HANDLE | OS.TVIF_PARAM;
                    tvItem.hItem = lptvdi.item.hItem;
                    OS.SendMessage (handle, OS.TVM_GETITEM, 0, &tvItem);
                    id = tvItem.lParam;
                }
            }
            TreeItem item = _getItem (lptvdi.item.hItem, id);
            /*
            * Feature in Windows.  When a new tree item is inserted
            * using TVM_INSERTITEM, a TVN_GETDISPINFO is sent before
            * TVM_INSERTITEM returns and before the item is added to
            * the items array.  The fix is to check for null.
            *
            * NOTE: This only happens on XP with the version 6.00 of
            * COMCTL32.DLL.
            *
            * Feature in Windows.  When TVM_DELETEITEM is called with
            * TVI_ROOT to remove all items from a tree, under certain
            * circumstances, the tree sends TVN_GETDISPINFO for items
            * that are about to be disposed.  The fix is to check for
            * disposed items.
            */
            if (item is null) break;
            if (item.isDisposed ()) break;
            if (!item.cached) {
                if ((style & SWT.VIRTUAL) !is 0) {
                    if (!checkData (item, false)) break;
                }
                if (painted) item.cached = true;
            }
            .LRESULT index = 0;
            if (hwndHeader !is null) {
                index = OS.SendMessage (hwndHeader, OS.HDM_ORDERTOINDEX, 0, 0);
            }
            if ((lptvdi.item.mask & OS.TVIF_TEXT) !is 0) {
                String string = null;
                if (index is 0) {
                    string = item.text;
                } else {
                    String [] strings  = item.strings;
                    if (strings !is null) string = strings [index];
                }
                if (string !is null) {
                    StringT buffer = StrToTCHARs (getCodePage (), string, false);
                    auto byteCount = Math.min (buffer.length, lptvdi.item.cchTextMax - 1) * TCHAR.sizeof;
                    OS.MoveMemory (lptvdi.item.pszText, buffer.ptr, byteCount);
                    auto st = byteCount/TCHAR.sizeof;
                    lptvdi.item.pszText[ st .. st+1 ] = 0;
                    //OS.MoveMemory (lptvdi.pszText + byteCount, new byte [TCHAR.sizeof], TCHAR.sizeof);
                    lptvdi.item.cchTextMax = cast(int)/*64bit*/Math.min (lptvdi.item.cchTextMax, string.length + 1);
                }
            }
            if ((lptvdi.item.mask & (OS.TVIF_IMAGE | OS.TVIF_SELECTEDIMAGE)) !is 0) {
                Image image = null;
                if (index is 0) {
                    image = item.image;
                } else {
                    Image [] images  = item.images;
                    if (images !is null) image = images [index];
                }
                lptvdi.item.iImage = lptvdi.item.iSelectedImage = OS.I_IMAGENONE;
                if (image !is null) {
                    lptvdi.item.iImage = lptvdi.item.iSelectedImage = imageIndex (image, cast(int)/*64bit*/index);
                }
                if (explorerTheme && OS.IsWindowEnabled (handle)) {
                    if (findImageControl () !is null) {
                        lptvdi.item.iImage = lptvdi.item.iSelectedImage = OS.I_IMAGENONE;
                    }
                }
            }
            //OS.MoveMemory (cast(void*)lParam, lptvdi, NMTVDISPINFO.sizeof);
            break;
        }
        case OS.NM_CUSTOMDRAW: {
            if (hdr.hwndFrom is hwndHeader) break;
            if (hooks (SWT.MeasureItem)) {
                if (hwndHeader is null) createParent ();
            }
            if (!customDraw && findImageControl () is null) {
                if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
                    if (sortColumn is null || sortDirection is SWT.NONE) {
                        break;
                    }
                }
            }
            NMTVCUSTOMDRAW* nmcd = cast(NMTVCUSTOMDRAW*)lParam;
            //OS.MoveMemory (nmcd, lParam, NMTVCUSTOMDRAW.sizeof);
            switch (nmcd.nmcd.dwDrawStage) {
                case OS.CDDS_PREPAINT: return CDDS_PREPAINT (nmcd, wParam, lParam);
                case OS.CDDS_ITEMPREPAINT: return CDDS_ITEMPREPAINT (nmcd, wParam, lParam);
                case OS.CDDS_ITEMPOSTPAINT: return CDDS_ITEMPOSTPAINT (nmcd, wParam, lParam);
                case OS.CDDS_POSTPAINT: return CDDS_POSTPAINT (nmcd, wParam, lParam);
                default:
            }
            break;
        }
        case OS.NM_DBLCLK: {
            /*
            * When the user double clicks on a tree item
            * or a line beside the item, the window proc
            * for the tree collapses or expand the branch.
            * When application code associates an action
            * with double clicking, then the tree expand
            * is unexpected and unwanted.  The fix is to
            * avoid the operation by testing to see whether
            * the mouse was inside a tree item.
            */
            if (hooks (SWT.MeasureItem)) return LRESULT.ONE;
            if (hooks (SWT.DefaultSelection)) {
                POINT pt;
                int pos = OS.GetMessagePos ();
                OS.POINTSTOPOINT (pt, pos);
                OS.ScreenToClient (handle, &pt);
                TVHITTESTINFO lpht;
                lpht.pt.x = pt.x;
                lpht.pt.y = pt.y;
                OS.SendMessage (handle, OS.TVM_HITTEST, 0, &lpht);
                if (lpht.hItem !is null && (lpht.flags & OS.TVHT_ONITEM) !is 0) {
                    return LRESULT.ONE;
                }
            }
            break;
        }
        /*
        * Bug in Windows.  On Vista, when TVM_SELECTITEM is called
        * with TVGN_CARET in order to set the selection, for some
        * reason, Windows deselects the previous two items that
        * were selected.  The fix is to stop the selection from
        * changing on all but the item that is supposed to be
        * selected.
        */
        case OS.TVN_ITEMCHANGINGA:
        case OS.TVN_ITEMCHANGINGW: {
            if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
                if ((style & SWT.MULTI) !is 0) {
                    if (hSelect !is null) {
                        NMTVITEMCHANGE* pnm = cast(NMTVITEMCHANGE*)lParam;
                        //OS.MoveMemory (pnm, lParam, NMTVITEMCHANGE.sizeof);
                        if (hSelect is pnm.hItem) break;
                        return LRESULT.ONE;
                    }
                }
            }
            break;
        }
        case OS.TVN_SELCHANGINGA:
        case OS.TVN_SELCHANGINGW: {
            if ((style & SWT.MULTI) !is 0) {
                if (lockSelection) {
                    /* Save the old selection state for both items */
                    auto treeView = cast(NMTREEVIEW*)lParam;
                    TVITEM* tvItem = &treeView.itemOld;
                    oldSelected = (tvItem.state & OS.TVIS_SELECTED) !is 0;
                    tvItem = &treeView.itemNew;
                    newSelected = (tvItem.state & OS.TVIS_SELECTED) !is 0;
                }
            }
            if (!ignoreSelect && !ignoreDeselect) {
                hAnchor = null;
                if ((style & SWT.MULTI) !is 0) deselectAll ();
            }
            break;
        }
        case OS.TVN_SELCHANGEDA:
        case OS.TVN_SELCHANGEDW: {
            NMTREEVIEW* treeView = null;
            if ((style & SWT.MULTI) !is 0) {
                if (lockSelection) {
                    /* Restore the old selection state of both items */
                    if (oldSelected) {
                        if (treeView is null) {
                            treeView = cast(NMTREEVIEW*)lParam;
                        }
                        TVITEM tvItem = treeView.itemOld;
                        tvItem.mask = OS.TVIF_STATE;
                        tvItem.stateMask = OS.TVIS_SELECTED;
                        tvItem.state = OS.TVIS_SELECTED;
                        OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                    }
                    if (!newSelected && ignoreSelect) {
                        if (treeView is null) {
                            treeView = cast(NMTREEVIEW*)lParam;
                        }
                        TVITEM tvItem = treeView.itemNew;
                        tvItem.mask = OS.TVIF_STATE;
                        tvItem.stateMask = OS.TVIS_SELECTED;
                        tvItem.state = 0;
                        OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
                    }
                }
            }
            if (!ignoreSelect) {
                if (treeView is null) {
                    treeView = cast(NMTREEVIEW*)lParam;
                }
                TVITEM tvItem = treeView.itemNew;
                hAnchor = tvItem.hItem;
                Event event = new Event ();
                event.item = _getItem (&tvItem.hItem, tvItem.lParam);
                postEvent (SWT.Selection, event);
            }
            updateScrollBar ();
            break;
        }
        case OS.TVN_ITEMEXPANDINGA:
        case OS.TVN_ITEMEXPANDINGW: {
            bool runExpanded = false;
            if ((style & SWT.VIRTUAL) !is 0) style &= ~SWT.DOUBLE_BUFFERED;
            if (hooks (SWT.EraseItem) || hooks (SWT.PaintItem)) style &= ~SWT.DOUBLE_BUFFERED;
            if (findImageControl () !is null && drawCount is 0 && OS.IsWindowVisible (handle)) {
                OS.DefWindowProc (handle, OS.WM_SETREDRAW, 0, 0);
            }
            /*
            * Bug in Windows.  When TVM_SETINSERTMARK is used to set
            * an insert mark for a tree and an item is expanded or
            * collapsed near the insert mark, the tree does not redraw
            * the insert mark properly.  The fix is to hide and show
            * the insert mark whenever an item is expanded or collapsed.
            */
            if (hInsert !is null) {
                OS.SendMessage (handle, OS.TVM_SETINSERTMARK, 0, 0);
            }
            if (!ignoreExpand) {
                NMTREEVIEW* treeView = cast(NMTREEVIEW*)lParam;

                TVITEM* tvItem = &treeView.itemNew;
                /*
                * Feature in Windows.  In some cases, TVM_ITEMEXPANDING
                * is sent from within TVM_DELETEITEM for the tree item
                * being destroyed.  By the time the message is sent,
                * the item has already been removed from the list of
                * items.  The fix is to check for null.
                */
                if (items is null) break;
                TreeItem item = _getItem (tvItem.hItem, tvItem.lParam);
                if (item is null) break;
                Event event = new Event ();
                event.item = item;
                switch (treeView.action) {
                    case OS.TVE_EXPAND:
                        /*
                        * Bug in Windows.  When the numeric keypad asterisk
                        * key is used to expand every item in the tree, Windows
                        * sends TVN_ITEMEXPANDING to items in the tree that
                        * have already been expanded.  The fix is to detect
                        * that the item is already expanded and ignore the
                        * notification.
                        */
                        if ((tvItem.state & OS.TVIS_EXPANDED) is 0) {
                            sendEvent (SWT.Expand, event);
                            if (isDisposed ()) return LRESULT.ZERO;
                        }
                        break;
                    case OS.TVE_COLLAPSE:
                        sendEvent (SWT.Collapse, event);
                        if (isDisposed ()) return LRESULT.ZERO;
                        break;
                    default:
                }
                /*
                * Bug in Windows.  When all of the items are deleted during
                * TVN_ITEMEXPANDING, Windows does not send TVN_ITEMEXPANDED.
                * The fix is to detect this case and run the TVN_ITEMEXPANDED
                * code in this method.
                */
                auto hFirstItem = cast(HANDLE) OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CHILD, tvItem.hItem);
                runExpanded = hFirstItem is null;
            }
            if (!runExpanded) break;
            goto case OS.TVN_ITEMEXPANDEDA;
        }
        case OS.TVN_ITEMEXPANDEDA:
        case OS.TVN_ITEMEXPANDEDW: {
            if ((style & SWT.VIRTUAL) !is 0) style |= SWT.DOUBLE_BUFFERED;
            if (hooks (SWT.EraseItem) || hooks (SWT.PaintItem)) style |= SWT.DOUBLE_BUFFERED;
            if (findImageControl () !is null && drawCount is 0 /*&& OS.IsWindowVisible (handle)*/) {
                OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
                OS.InvalidateRect (handle, null, true);
            }
            /*
            * Bug in Windows.  When TVM_SETINSERTMARK is used to set
            * an insert mark for a tree and an item is expanded or
            * collapsed near the insert mark, the tree does not redraw
            * the insert mark properly.  The fix is to hide and show
            * the insert mark whenever an item is expanded or collapsed.
            */
            if (hInsert !is null) {
                OS.SendMessage (handle, OS.TVM_SETINSERTMARK, insertAfter ? 1 : 0, hInsert);
            }
            /*
            * Bug in Windows.  When a tree item that has an image
            * with alpha is expanded or collapsed, the area where
            * the image is drawn is not erased before it is drawn.
            * This means that the image gets darker each time.
            * The fix is to redraw the item.
            */
            if (!OS.IsWinCE && OS.COMCTL32_MAJOR >= 6) {
                if (imageList !is null) {
                    NMTREEVIEW* treeView = cast(NMTREEVIEW*)lParam;

                    TVITEM* tvItem = &treeView.itemNew;
                    if (tvItem.hItem !is null) {
                        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
                        if ((bits & OS.TVS_FULLROWSELECT) is 0) {
                            RECT rect;
                            if (OS.TreeView_GetItemRect (handle, tvItem.hItem, &rect, false)) {
                                OS.InvalidateRect (handle, &rect, true);
                            }
                        }
                    }
                }
            }
            updateScrollBar ();
            break;
        }
        case OS.TVN_BEGINDRAGA:
        case OS.TVN_BEGINDRAGW:
            if (OS.GetKeyState (OS.VK_LBUTTON) >= 0) break;
            goto case OS.TVN_BEGINRDRAGA;
        case OS.TVN_BEGINRDRAGA:
        case OS.TVN_BEGINRDRAGW: {
            dragStarted = true;
            NMTREEVIEW* treeView = cast(NMTREEVIEW*)lParam;
            TVITEM* tvItem = &treeView.itemNew;
            if (tvItem.hItem !is null && (tvItem.state & OS.TVIS_SELECTED) is 0) {
                hSelect = tvItem.hItem;
                ignoreSelect = ignoreDeselect = true;
                OS.SendMessage (handle, OS.TVM_SELECTITEM, OS.TVGN_CARET, tvItem.hItem);
                ignoreSelect = ignoreDeselect = false;
                hSelect = null;
            }
            break;
        }
        case OS.NM_RECOGNIZEGESTURE: {
            /*
            * Feature in Pocket PC.  The tree and table controls detect the tap
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
        }
        case OS.GN_CONTEXTMENU: {
            if (OS.IsPPC) {
                bool hasMenu = menu !is null && !menu.isDisposed ();
                if (hasMenu || hooks (SWT.MenuDetect)) {
                    NMRGINFO* nmrg = cast(NMRGINFO*)lParam;
                    //OS.MoveMemory (nmrg, lParam, NMRGINFO.sizeof);
                    showMenu (nmrg.x, nmrg.y);
                    gestureCompleted = true;
                    return LRESULT.ONE;
                }
            }
            break;
        }
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
            NMHEADER* phdn = cast(NMHEADER*)lParam;
            TreeColumn column = columns [phdn.iItem];
            if (column !is null && !column.getResizable ()) {
                return LRESULT.ONE;
            }
            ignoreColumnMove = true;
            switch (hdr.code) {
                case OS.HDN_DIVIDERDBLCLICKW:
                case OS.HDN_DIVIDERDBLCLICKA:
                    if (column !is null) column.pack ();
                    break;
                default:
                    break;
            }
            break;
        }
        case OS.NM_RELEASEDCAPTURE: {
            if (!ignoreColumnMove) {
                for (int i=0; i<columnCount; i++) {
                    TreeColumn column = columns [i];
                    column.updateToolTip (i);
                }
                updateImageList ();
            }
            ignoreColumnMove = false;
            break;
        }
        case OS.HDN_BEGINDRAG: {
            if (ignoreColumnMove) return LRESULT.ONE;
            NMHEADER* phdn = cast(NMHEADER*)lParam;
            if (phdn.iItem !is -1) {
                TreeColumn column = columns [phdn.iItem];
                if (column !is null && !column.getMoveable ()) {
                    ignoreColumnMove = true;
                    return LRESULT.ONE;
                }
            }
            break;
        }
        case OS.HDN_ENDDRAG: {
            NMHEADER* phdn = cast(NMHEADER*)lParam;
            if (phdn.iItem !is -1 && phdn.pitem !is null) {
                HDITEM* pitem = cast(HDITEM*)phdn.pitem;
                if ((pitem.mask & OS.HDI_ORDER) !is 0 && pitem.iOrder !is -1) {
                    int [] order = new int [columnCount];
                    OS.SendMessage (hwndHeader, OS.HDM_GETORDERARRAY, columnCount, order.ptr);
                    int index = 0;
                    while (index < order.length) {
                        if (order [index] is phdn.iItem) break;
                        index++;
                    }
                    if (index is order.length) index = 0;
                    if (index is pitem.iOrder) break;
                    int start = Math.min (index, pitem.iOrder);
                    int end = Math.max (index, pitem.iOrder);
                    RECT rect, headerRect;
                    OS.GetClientRect (handle, &rect);
                    OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, order [start], &headerRect);
                    rect.left = Math.max (rect.left, headerRect.left);
                    OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, order [end], &headerRect);
                    rect.right = Math.min (rect.right, headerRect.right);
                    OS.InvalidateRect (handle, &rect, true);
                    ignoreColumnMove = false;
                    for (int i=start; i<=end; i++) {
                        TreeColumn column = columns [order [i]];
                        if (!column.isDisposed ()) {
                            column.postEvent (SWT.Move);
                        }
                    }
                }
            }
            break;
        }
        case OS.HDN_ITEMCHANGINGW:
        case OS.HDN_ITEMCHANGINGA: {
            NMHEADER* phdn = cast(NMHEADER*)lParam;
            if (phdn.pitem !is null) {
                HDITEM* newItem = cast(HDITEM*)phdn.pitem;
                if ((newItem.mask & OS.HDI_WIDTH) !is 0) {
                    RECT rect;
                    OS.GetClientRect (handle, &rect);
                    HDITEM oldItem;
                    oldItem.mask = OS.HDI_WIDTH;
                    OS.SendMessage (hwndHeader, OS.HDM_GETITEM, phdn.iItem, &oldItem);
                    int deltaX = newItem.cxy - oldItem.cxy;
                    RECT headerRect;
                    OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, phdn.iItem, &headerRect);
                    int gridWidth = linesVisible ? GRID_WIDTH : 0;
                    rect.left = headerRect.right - gridWidth;
                    int newX = rect.left + deltaX;
                    rect.right = Math.max (rect.right, rect.left + Math.abs (deltaX));
                    if (explorerTheme || (findImageControl () !is null || hooks (SWT.MeasureItem) || hooks (SWT.EraseItem) || hooks (SWT.PaintItem))) {
                        rect.left -= OS.GetSystemMetrics (OS.SM_CXFOCUSBORDER);
                        OS.InvalidateRect (handle, &rect, true);
                        OS.OffsetRect (&rect, deltaX, 0);
                        OS.InvalidateRect (handle, &rect, true);
                    } else {
                        int flags = OS.SW_INVALIDATE | OS.SW_ERASE;
                        OS.ScrollWindowEx (handle, deltaX, 0, &rect, null, null, null, flags);
                    }
                    if (OS.SendMessage (hwndHeader, OS.HDM_ORDERTOINDEX, phdn.iItem, 0) !is 0) {
                        rect.left = headerRect.left;
                        rect.right = newX;
                        OS.InvalidateRect (handle, &rect, true);
                    }
                    setScrollWidth ();
                }
            }
            break;
        }
        case OS.HDN_ITEMCHANGEDW:
        case OS.HDN_ITEMCHANGEDA: {
            NMHEADER* phdn = cast(NMHEADER*)lParam;
            if (phdn.pitem !is null) {
                HDITEM* pitem = cast(HDITEM*)phdn.pitem;
                if ((pitem.mask & OS.HDI_WIDTH) !is 0) {
                    if (ignoreColumnMove) {
                        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
                            int flags = OS.RDW_UPDATENOW | OS.RDW_ALLCHILDREN;
                            OS.RedrawWindow (handle, null, null, flags);
                        } else {
                            if ((style & SWT.DOUBLE_BUFFERED) is 0) {
                                int oldStyle = style;
                                style |= SWT.DOUBLE_BUFFERED;
                                OS.UpdateWindow (handle);
                                style = oldStyle;
                            }
                        }
                    }
                    TreeColumn column = columns [phdn.iItem];
                    if (column !is null) {
                        column.updateToolTip (phdn.iItem);
                        column.sendEvent (SWT.Resize);
                        if (isDisposed ()) return LRESULT.ZERO;
                        TreeColumn [] newColumns = new TreeColumn [columnCount];
                        System.arraycopy (columns, 0, newColumns, 0, columnCount);
                        int [] order = new int [columnCount];
                        OS.SendMessage (hwndHeader, OS.HDM_GETORDERARRAY, columnCount, order.ptr);
                        bool moved = false;
                        for (int i=0; i<columnCount; i++) {
                            TreeColumn nextColumn = newColumns [order [i]];
                            if (moved && !nextColumn.isDisposed ()) {
                                nextColumn.updateToolTip (order [i]);
                                nextColumn.sendEvent (SWT.Move);
                            }
                            if (nextColumn is column) moved = true;
                        }
                    }
                }
                setScrollWidth ();
            }
            break;
        }
        case OS.HDN_ITEMCLICKW:
        case OS.HDN_ITEMCLICKA: {
            NMHEADER* phdn = cast(NMHEADER*)lParam;
            TreeColumn column = columns [phdn.iItem];
            if (column !is null) {
                column.postEvent (SWT.Selection);
            }
            break;
        }
        case OS.HDN_ITEMDBLCLICKW:
        case OS.HDN_ITEMDBLCLICKA: {
            NMHEADER* phdn = cast(NMHEADER*)lParam;
            TreeColumn column = columns [phdn.iItem];
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
            NMTTCUSTOMDRAW* nmcd = cast(NMTTCUSTOMDRAW*)lParam;
            return wmNotifyToolTip (nmcd, lParam);
        }
        case OS.TTN_SHOW: {
            LRESULT result = super.wmNotify (hdr, wParam, lParam);
            if (result !is null) return result;
            int pos = OS.GetMessagePos ();
            POINT pt;
            OS.POINTSTOPOINT (pt, pos);
            OS.ScreenToClient (handle, &pt);
            int index;
            TreeItem item;
            RECT* cellRect, itemRect;
            if (findCell (pt.x, pt.y, item, index, cellRect, itemRect)) {
                RECT* toolRect = toolTipRect (itemRect);
                OS.MapWindowPoints (handle, null, cast(POINT*)toolRect, 2);
                int width = toolRect.right - toolRect.left;
                int height = toolRect.bottom - toolRect.top;
                int flags = OS.SWP_NOACTIVATE | OS.SWP_NOZORDER | OS.SWP_NOSIZE;
                if (isCustomToolTip ()) flags &= ~OS.SWP_NOSIZE;
                SetWindowPos (itemToolTipHandle, null, toolRect.left, toolRect.top, width, height, flags);
                return LRESULT.ONE;
            }
            return result;
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
                //nmcd.uDrawFlags |= OS.DT_CALCRECT;
                //OS.MoveMemory (lParam, nmcd, NMTTCUSTOMDRAW.sizeof);
                if (!OS.IsWinCE && OS.WIN32_VERSION < OS.VERSION (6, 0)) {
                    OS.SetTextColor (nmcd.nmcd.hdc, OS.GetSysColor (OS.COLOR_INFOBK));
                }
                return new LRESULT (OS.CDRF_NOTIFYPOSTPAINT | OS.CDRF_NEWFONT);
            }
            break;
        }
        case OS.CDDS_POSTPAINT: {
            if (!OS.IsWinCE && OS.WIN32_VERSION < OS.VERSION (6, 0)) {
                OS.SetTextColor (nmcd.nmcd.hdc, OS.GetSysColor (OS.COLOR_INFOTEXT));
            }
            if (OS.SendMessage (itemToolTipHandle, OS.TTM_GETCURRENTTOOL, 0, 0) !is 0) {
                TOOLINFO lpti;
                lpti.cbSize = OS.TOOLINFO_sizeof;
                if (OS.SendMessage (itemToolTipHandle, OS.TTM_GETCURRENTTOOL, 0, &lpti) !is 0) {
                    int index;
                    TreeItem item;
                    RECT* cellRect, itemRect;
                    int pos = OS.GetMessagePos ();
                    POINT pt;
                    OS.POINTSTOPOINT (pt, pos);
                    OS.ScreenToClient (handle, &pt);
                    if (findCell (pt.x, pt.y, item, index, cellRect, itemRect)) {
                        auto hDC = OS.GetDC (handle);
                        auto hFont = item.fontHandle (index);
                        if (hFont is cast(HFONT)-1) hFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
                        HFONT oldFont = OS.SelectObject (hDC, hFont);
                        LRESULT result = null;
                        bool drawForeground = true;
                        cellRect = item.getBounds (index, true, true, false, false, false, hDC);
                        if (hooks (SWT.EraseItem)) {
                            Event event = sendEraseItemEvent (item, nmcd, index, cellRect);
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
                            RECT* insetRect = toolTipInset (cellRect);
                            OS.SetWindowOrgEx (nmcd.nmcd.hdc, insetRect.left, insetRect.top, null);
                            GCData data = new GCData ();
                            data.device = display;
                            data.foreground = OS.GetTextColor (nmcd.nmcd.hdc);
                            data.background = OS.GetBkColor (nmcd.nmcd.hdc);
                            data.font = Font.win32_new (display, hFont);
                            GC gc = GC.win32_new (nmcd.nmcd.hdc, data);
                            int x = cellRect.left + INSET;
                            if (index !is 0) x -= gridWidth;
                            Image image = item.getImage (index);
                            if (image !is null || index is 0) {
                                Point size = getImageSize ();
                                RECT* imageRect = item.getBounds (index, false, true, false, false, false, hDC);
                                if (imageList is null) size.x = imageRect.right - imageRect.left;
                                if (image !is null) {
                                    Rectangle rect = image.getBounds ();
                                    gc.drawImage (image, rect.x, rect.y, rect.width, rect.height, x, imageRect.top, size.x, size.y);
                                    x += INSET + (index is 0 ? 1 : 0);
                                }
                                x += size.x;
                            } else {
                                x += INSET;
                            }
                            String string = item.getText (index);
                            if (string !is null) {
                                int flags = OS.DT_NOPREFIX | OS.DT_SINGLELINE | OS.DT_VCENTER;
                                TreeColumn column = columns !is null ? columns [index] : null;
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
                            itemRect = item.getBounds (index, true, true, false, false, false, hDC);
                            sendPaintItemEvent (item, nmcd, index, itemRect);
                        }
                        OS.SelectObject (hDC, oldFont);
                        OS.ReleaseDC (handle, hDC);
                        if (result !is null) return result;
                    }
                    break;
                }
            }
            break;
        }
        default:
    }
    return null;
}

}
