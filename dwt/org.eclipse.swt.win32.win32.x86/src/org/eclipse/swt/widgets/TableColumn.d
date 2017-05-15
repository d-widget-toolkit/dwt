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
module org.eclipse.swt.widgets.TableColumn;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.ControlListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.swt.widgets.Event;

import java.lang.all;

/**
 * Instances of this class represent a column in a table widget.
 * <p><dl>
 * <dt><b>Styles:</b></dt>
 * <dd>LEFT, RIGHT, CENTER</dd>
 * <dt><b>Events:</b></dt>
 * <dd> Move, Resize, Selection</dd>
 * </dl>
 * </p><p>
 * Note: Only one of the styles LEFT, RIGHT and CENTER may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#table">Table, TableItem, TableColumn snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class TableColumn : Item {
    Table parent;
    bool resizable, moveable;
    String toolTipText;
    int id;

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Table</code>) and a style value
 * describing its behavior and appearance. The item is added
 * to the end of the items maintained by its parent.
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
 * @see SWT#LEFT
 * @see SWT#RIGHT
 * @see SWT#CENTER
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Table parent, int style) {
    super (parent, checkStyle (style));
    resizable = true;
    this.parent = parent;
    parent.createItem (this, parent.getColumnCount ());
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Table</code>), a style value
 * describing its behavior and appearance, and the index
 * at which to place it in the items maintained by its parent.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>SWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>SWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 * </p>
 * <p>
 * Note that due to a restriction on some platforms, the first column
 * is always left aligned.
 * </p>
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 * @param index the zero-relative index to store the receiver in its parent
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the parent (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#LEFT
 * @see SWT#RIGHT
 * @see SWT#CENTER
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Table parent, int style, int index) {
    super (parent, checkStyle (style));
    resizable = true;
    this.parent = parent;
    parent.createItem (this, index);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is moved or resized, by sending
 * it one of the messages defined in the <code>ControlListener</code>
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
 * @see ControlListener
 * @see #removeControlListener
 */
public void addControlListener(ControlListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Resize,typedListener);
    addListener (SWT.Move,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the column header is selected.
 * <code>widgetDefaultSelected</code> is not called.
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

static int checkStyle (int style) {
    return checkBits (style, SWT.LEFT, SWT.CENTER, SWT.RIGHT, 0, 0, 0);
}

override protected void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

override void destroyWidget () {
    parent.destroyItem (this);
    releaseHandle ();
}

/**
 * Returns a value which describes the position of the
 * text or image in the receiver. The value will be one of
 * <code>LEFT</code>, <code>RIGHT</code> or <code>CENTER</code>.
 *
 * @return the alignment
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getAlignment () {
    checkWidget ();
    if ((style & SWT.LEFT) !is 0) return SWT.LEFT;
    if ((style & SWT.CENTER) !is 0) return SWT.CENTER;
    if ((style & SWT.RIGHT) !is 0) return SWT.RIGHT;
    return SWT.LEFT;
}

override String getNameText () {
    return getText ();
}

/**
 * Returns the receiver's parent, which must be a <code>Table</code>.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Table getParent () {
    checkWidget ();
    return parent;
}

/**
 * Gets the moveable attribute. A column that is
 * not moveable cannot be reordered by the user
 * by dragging the header but may be reordered
 * by the programmer.
 *
 * @return the moveable attribute
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Table#getColumnOrder()
 * @see Table#setColumnOrder(int[])
 * @see TableColumn#setMoveable(bool)
 * @see SWT#Move
 *
 * @since 3.1
 */
public bool getMoveable () {
    checkWidget ();
    return moveable;
}

/**
 * Gets the resizable attribute. A column that is
 * not resizable cannot be dragged by the user but
 * may be resized by the programmer.
 *
 * @return the resizable attribute
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getResizable () {
    checkWidget ();
    return resizable;
}

/**
 * Returns the receiver's tool tip text, or null if it has
 * not been set.
 *
 * @return the receiver's tool tip text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public String getToolTipText () {
    checkWidget();
    return toolTipText;
}

/**
 * Gets the width of the receiver.
 *
 * @return the width
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getWidth () {
    checkWidget ();
    int index = parent.indexOf (this);
    if (index is -1) return 0;
    auto hwnd = parent.handle;
    return cast(int)/*64bit*/OS.SendMessage (hwnd, OS.LVM_GETCOLUMNWIDTH, index, 0);
}

/**
 * Causes the receiver to be resized to its preferred size.
 * For a composite, this involves computing the preferred size
 * from its layout, if there is one.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 */
public void pack () {
    checkWidget ();
    int index = parent.indexOf (this);
    if (index is -1) return;
    auto hwnd = parent.handle;
    auto oldWidth = OS.SendMessage (hwnd, OS.LVM_GETCOLUMNWIDTH, index, 0);
    LPCTSTR buffer = StrToTCHARz (parent.getCodePage (), text);
    auto headerWidth = OS.SendMessage (hwnd, OS.LVM_GETSTRINGWIDTH, 0, cast(void*)buffer) + Table.HEADER_MARGIN;
    if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) headerWidth += Table.HEADER_EXTRA;
    bool hasHeaderImage = false;
    if (image !is null || parent.sortColumn is this) {
        hasHeaderImage = true;
        Image headerImage = null;
        if (parent.sortColumn is this && parent.sortDirection !is SWT.NONE) {
            if (OS.COMCTL32_MAJOR < 6) {
                headerImage = display.getSortImage (parent.sortDirection);
            } else {
                headerWidth += Table.SORT_WIDTH;
            }
        } else {
            headerImage = image;
        }
        if (headerImage !is null) {
            Rectangle bounds = headerImage.getBounds ();
            headerWidth += bounds.width;
        }
        int margin = 0;
        if (OS.COMCTL32_VERSION >= OS.VERSION (5, 80)) {
            auto hwndHeader = cast(HWND) OS.SendMessage (hwnd, OS.LVM_GETHEADER, 0, 0);
            margin = cast(int)/*64bit*/OS.SendMessage (hwndHeader, OS.HDM_GETBITMAPMARGIN, 0, 0);
        } else {
            margin = OS.GetSystemMetrics (OS.SM_CXEDGE) * 3;
        }
        headerWidth += margin * 4;
    }
    parent.ignoreColumnResize = true;
    int columnWidth = 0;
    /*
    * Bug in Windows.  When the first column of a table does not
    * have an image and the user double clicks on the divider,
    * Windows packs the column but does not take into account
    * the empty space left for the image.  The fix is to measure
    * each items ourselves rather than letting Windows do it.
    */
    if ((index is 0 && !parent.firstColumnImage) || parent.hooks (SWT.MeasureItem)) {
        RECT headerRect;
        auto hwndHeader = cast(HWND) OS.SendMessage (hwnd, OS.LVM_GETHEADER, 0, 0);
        OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, index, &headerRect);
        OS.MapWindowPoints (hwndHeader, hwnd, cast(POINT*) &headerRect, 2);
        auto hDC = OS.GetDC (hwnd);
        HFONT oldFont, newFont = cast(HFONT) OS.SendMessage (hwnd, OS.WM_GETFONT, 0, 0);
        if (newFont !is null) oldFont = OS.SelectObject (hDC, newFont);
        auto count = OS.SendMessage (hwnd, OS.LVM_GETITEMCOUNT, 0, 0);
        for (int i=0; i<count; i++) {
            TableItem item = parent.items [i];
            if (item !is null) {
                auto hFont = item.fontHandle (index);
                if (hFont !is cast(HFONT)-1) hFont = OS.SelectObject (hDC, hFont);
                Event event = parent.sendMeasureItemEvent (item, i, index, hDC);
                if (hFont !is cast(HFONT)-1) hFont = OS.SelectObject (hDC, hFont);
                if (isDisposed () || parent.isDisposed ()) break;
                columnWidth = Math.max (columnWidth, event.x + event.width - headerRect.left);
            }
        }
        if (newFont !is null) OS.SelectObject (hDC, oldFont);
        OS.ReleaseDC (hwnd, hDC);
        OS.SendMessage (hwnd, OS.LVM_SETCOLUMNWIDTH, index, columnWidth);
    } else {
        OS.SendMessage (hwnd, OS.LVM_SETCOLUMNWIDTH, index, OS.LVSCW_AUTOSIZE);
        columnWidth = cast(int)/*64bit*/OS.SendMessage (hwnd, OS.LVM_GETCOLUMNWIDTH, index, 0);
        if (index is 0) {
            /*
            * Bug in Windows.  When LVM_SETCOLUMNWIDTH is used with LVSCW_AUTOSIZE
            * where each item has I_IMAGECALLBACK but there are no images in the
            * table, the size computed by LVM_SETCOLUMNWIDTH is too small for the
            * first column, causing long items to be clipped with '...'.  The fix
            * is to increase the column width by a small amount.
            */
            if (parent.imageList is null) columnWidth += 2;
            /*
            * Bug in Windows.  When LVM_SETCOLUMNWIDTH is used with LVSCW_AUTOSIZE
            * for a table with a state image list, the column is width does not
            * include space for the state icon.  The fix is to increase the column
            * width by the width of the image list.
            */
            if ((parent.style & SWT.CHECK) !is 0) {
                auto hStateList = cast(HANDLE) OS.SendMessage (hwnd, OS.LVM_GETIMAGELIST, OS.LVSIL_STATE, 0);
                if (hStateList !is null) {
                    int cx, cy;
                    OS.ImageList_GetIconSize (hStateList, &cx, &cy);
                    columnWidth += cx;
                }
            }
        }
    }
    if (headerWidth > columnWidth) {
        if (!hasHeaderImage) {
            /*
            * Feature in Windows.  When LVSCW_AUTOSIZE_USEHEADER is used
            * with LVM_SETCOLUMNWIDTH to resize the last column, the last
            * column is expanded to fill the client area.  The fix is to
            * resize the table to be small, set the column width and then
            * restore the table to its original size.
            */
            RECT rect;
            bool fixWidth = index is parent.getColumnCount () - 1;
            if (fixWidth) {
                //rect = new RECT ();
                OS.GetWindowRect (hwnd, &rect);
                OS.UpdateWindow (hwnd);
                int flags = OS.SWP_NOACTIVATE | OS.SWP_NOMOVE | OS.SWP_NOREDRAW | OS.SWP_NOZORDER;
                SetWindowPos (hwnd, null, 0, 0, 0, rect.bottom - rect.top, flags);
            }
            OS.SendMessage (hwnd, OS.LVM_SETCOLUMNWIDTH, index, OS.LVSCW_AUTOSIZE_USEHEADER);
            if (fixWidth) {
                int flags = OS.SWP_NOACTIVATE | OS.SWP_NOMOVE | OS.SWP_NOZORDER;
                SetWindowPos (hwnd, null, 0, 0, rect.right - rect.left, rect.bottom - rect.top, flags);
            }
        } else {
            OS.SendMessage (hwnd, OS.LVM_SETCOLUMNWIDTH, index, headerWidth);
        }
    } else {
        if (index is 0) {
            OS.SendMessage (hwnd, OS.LVM_SETCOLUMNWIDTH, index, columnWidth);
        }
    }
    parent.ignoreColumnResize = false;
    auto newWidth = OS.SendMessage (hwnd, OS.LVM_GETCOLUMNWIDTH, index, 0);
    if (oldWidth !is newWidth) {
        updateToolTip (index);
        sendEvent (SWT.Resize);
        if (isDisposed ()) return;
        bool moved = false;
        int [] order = parent.getColumnOrder ();
        TableColumn [] columns = parent.getColumns ();
        for (int i=0; i<order.length; i++) {
            TableColumn column = columns [order [i]];
            if (moved && !column.isDisposed ()) {
                column.updateToolTip (order [i]);
                column.sendEvent (SWT.Move);
            }
            if (column is this) moved = true;
        }
    }
}

override void releaseHandle () {
    super.releaseHandle ();
    parent = null;
}

override void releaseParent () {
    super.releaseParent ();
    if (parent.sortColumn is this) {
        parent.sortColumn = null;
    }
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control is moved or resized.
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
 * @see ControlListener
 * @see #addControlListener
 */
public void removeControlListener (ControlListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Move, listener);
    eventTable.unhook (SWT.Resize, listener);
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
 * Controls how text and images will be displayed in the receiver.
 * The argument should be one of <code>LEFT</code>, <code>RIGHT</code>
 * or <code>CENTER</code>.
 * <p>
 * Note that due to a restriction on some platforms, the first column
 * is always left aligned.
 * </p>
 * @param alignment the new alignment
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setAlignment (int alignment) {
    checkWidget ();
    if ((alignment & (SWT.LEFT | SWT.RIGHT | SWT.CENTER)) is 0) return;
    int index = parent.indexOf (this);
    if (index is -1 || index is 0) return;
    style &= ~(SWT.LEFT | SWT.RIGHT | SWT.CENTER);
    style |= alignment & (SWT.LEFT | SWT.RIGHT | SWT.CENTER);
    auto hwnd = parent.handle;
    LVCOLUMN lvColumn;
    lvColumn.mask = OS.LVCF_FMT;
    OS.SendMessage (hwnd, OS.LVM_GETCOLUMN, index, &lvColumn);
    lvColumn.fmt &= ~OS.LVCFMT_JUSTIFYMASK;
    int fmt = 0;
    if ((style & SWT.LEFT) is SWT.LEFT) fmt = OS.LVCFMT_LEFT;
    if ((style & SWT.CENTER) is SWT.CENTER) fmt = OS.LVCFMT_CENTER;
    if ((style & SWT.RIGHT) is SWT.RIGHT) fmt = OS.LVCFMT_RIGHT;
    lvColumn.fmt |= fmt;
    OS.SendMessage (hwnd, OS.LVM_SETCOLUMN, index, &lvColumn);
    /*
    * Bug in Windows.  When LVM_SETCOLUMN is used to change
    * the alignment of a column, the column is not redrawn
    * to show the new alignment.  The fix is to compute the
    * visible rectangle for the column and redraw it.
    */
    if (index !is 0) {
        parent.forceResize ();
        RECT rect, headerRect;
        OS.GetClientRect (hwnd, &rect);
        auto hwndHeader = cast(HWND) OS.SendMessage (hwnd, OS.LVM_GETHEADER, 0, 0);
        OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, index, &headerRect);
        OS.MapWindowPoints (hwndHeader, hwnd, cast(POINT*) &headerRect, 2);
        rect.left = headerRect.left;
        rect.right = headerRect.right;
        OS.InvalidateRect (hwnd, &rect, true);
    }
}

override public void setImage (Image image) {
    checkWidget();
    if (image !is null && image.isDisposed ()) {
        error (SWT.ERROR_INVALID_ARGUMENT);
    }
    super.setImage (image);
    if (parent.sortColumn !is this || parent.sortDirection !is SWT.NONE) {
        setImage (image, false, false);
    }
}

void setImage (Image image, bool sort, bool right) {
    int index = parent.indexOf (this);
    if (index is -1) return;
    auto hwnd = parent.handle;
    if (OS.COMCTL32_MAJOR < 6) {
        auto hwndHeader = cast(HWND) OS.SendMessage (hwnd, OS.LVM_GETHEADER, 0, 0);
        HDITEM hdItem;
        hdItem.mask = OS.HDI_FORMAT | OS.HDI_IMAGE | OS.HDI_BITMAP;
        OS.SendMessage (hwndHeader, OS.HDM_GETITEM, index, &hdItem);
        hdItem.fmt &= ~OS.HDF_BITMAP_ON_RIGHT;
        if (image !is null) {
            if (sort) {
                hdItem.mask &= ~OS.HDI_IMAGE;
                hdItem.fmt &= ~OS.HDF_IMAGE;
                hdItem.fmt |= OS.HDF_BITMAP;
                hdItem.hbm = image.handle;
            } else {
                hdItem.mask &= ~OS.HDI_BITMAP;
                hdItem.fmt &= ~OS.HDF_BITMAP;
                hdItem.fmt |= OS.HDF_IMAGE;
                hdItem.iImage = parent.imageIndexHeader (image);
            }
            if (right) hdItem.fmt |= OS.HDF_BITMAP_ON_RIGHT;
        } else {
            hdItem.fmt &= ~(OS.HDF_IMAGE | OS.HDF_BITMAP);
        }
        OS.SendMessage (hwndHeader, OS.HDM_SETITEM, index, &hdItem);
    } else {
        LVCOLUMN lvColumn;
        lvColumn.mask = OS.LVCF_FMT | OS.LVCF_IMAGE;
        OS.SendMessage (hwnd, OS.LVM_GETCOLUMN, index, &lvColumn);
        if (image !is null) {
            lvColumn.fmt |= OS.LVCFMT_IMAGE;
            lvColumn.iImage = parent.imageIndexHeader (image);
            if (right) lvColumn.fmt |= OS.LVCFMT_BITMAP_ON_RIGHT;
        } else {
            lvColumn.mask &= ~OS.LVCF_IMAGE;
            lvColumn.fmt &= ~(OS.LVCFMT_IMAGE | OS.LVCFMT_BITMAP_ON_RIGHT);
        }
        OS.SendMessage (hwnd, OS.LVM_SETCOLUMN, index, &lvColumn);
    }
}

/**
 * Sets the moveable attribute.  A column that is
 * moveable can be reordered by the user by dragging
 * the header. A column that is not moveable cannot be
 * dragged by the user but may be reordered
 * by the programmer.
 *
 * @param moveable the moveable attribute
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Table#setColumnOrder(int[])
 * @see Table#getColumnOrder()
 * @see TableColumn#getMoveable()
 * @see SWT#Move
 *
 * @since 3.1
 */
public void setMoveable (bool moveable) {
    checkWidget ();
    this.moveable = moveable;
    parent.updateMoveable ();
}

/**
 * Sets the resizable attribute.  A column that is
 * resizable can be resized by the user dragging the
 * edge of the header.  A column that is not resizable
 * cannot be dragged by the user but may be resized
 * by the programmer.
 *
 * @param resizable the resize attribute
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setResizable (bool resizable) {
    checkWidget ();
    this.resizable = resizable;
}

void setSortDirection (int direction) {
    if (OS.COMCTL32_MAJOR >= 6) {
        int index = parent.indexOf (this);
        if (index is -1) return;
        auto hwnd = parent.handle;
        auto hwndHeader = cast(HWND) OS.SendMessage (hwnd, OS.LVM_GETHEADER, 0, 0);
        HDITEM hdItem;
        hdItem.mask = OS.HDI_FORMAT | OS.HDI_IMAGE;
        OS.SendMessage (hwndHeader, OS.HDM_GETITEM, index, &hdItem);
        switch (direction) {
            case SWT.UP:
                hdItem.fmt &= ~(OS.HDF_IMAGE | OS.HDF_SORTDOWN);
                hdItem.fmt |= OS.HDF_SORTUP;
                if (image is null) hdItem.mask &= ~OS.HDI_IMAGE;
                break;
            case SWT.DOWN:
                hdItem.fmt &= ~(OS.HDF_IMAGE | OS.HDF_SORTUP);
                hdItem.fmt |= OS.HDF_SORTDOWN;
                if (image is null) hdItem.mask &= ~OS.HDI_IMAGE;
                break;
            case SWT.NONE:
                hdItem.fmt &= ~(OS.HDF_SORTUP | OS.HDF_SORTDOWN);
                if (image !is null) {
                    hdItem.fmt |= OS.HDF_IMAGE;
                    hdItem.iImage = parent.imageIndexHeader (image);
                } else {
                    hdItem.fmt &= ~OS.HDF_IMAGE;
                    hdItem.mask &= ~OS.HDI_IMAGE;
                }
                break;
            default:
        }
        OS.SendMessage (hwndHeader, OS.HDM_SETITEM, index, &hdItem);
        /*
        * Bug in Windows.  When LVM_SETSELECTEDCOLUMN is used to
        * specify a selected column, Windows does not redraw either
        * the new or the previous selected column.  The fix is to
        * force a redraw of both.
        *
        * Feature in Windows.  When LVM_SETBKCOLOR is used with
        * CLR_NONE and LVM_SETSELECTEDCOLUMN is used to select
        * a column, Windows fills the column with the selection
        * color, drawing on top of the background image and any
        * other custom drawing.  The fix is to avoid setting the
        * selected column.
        */
        parent.forceResize ();
        RECT rect;
        OS.GetClientRect (hwnd, &rect);
        if (OS.SendMessage (hwnd, OS.LVM_GETBKCOLOR, 0, 0) !is OS.CLR_NONE) {
            auto oldColumn = OS.SendMessage (hwnd, OS.LVM_GETSELECTEDCOLUMN, 0, 0);
            int newColumn = direction is SWT.NONE ? -1 : index;
            OS.SendMessage (hwnd, OS.LVM_SETSELECTEDCOLUMN, newColumn, 0);
            RECT headerRect;
            if (oldColumn !is -1) {
                if (OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, oldColumn, &headerRect) !is 0) {
                    OS.MapWindowPoints (hwndHeader, hwnd, cast(POINT*) &headerRect, 2);
                    rect.left = headerRect.left;
                    rect.right = headerRect.right;
                    OS.InvalidateRect (hwnd, &rect, true);
                }
            }
        }
        RECT headerRect;
        if (OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, index, &headerRect) !is 0) {
            OS.MapWindowPoints (hwndHeader, hwnd, cast(POINT*)  &headerRect, 2);
            rect.left = headerRect.left;
            rect.right = headerRect.right;
            OS.InvalidateRect (hwnd, &rect, true);
        }
    } else {
        switch (direction) {
            case SWT.UP:
            case SWT.DOWN:
                setImage (display.getSortImage (direction), true, true);
                break;
            case SWT.NONE:
                setImage (image, false, false);
                break;
            default:
        }
    }
}

override public void setText (String string) {
    checkWidget ();
    // SWT extension: allow null string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (string.equals (text)) return;
    int index = parent.indexOf (this);
    if (index is -1) return;
    super.setText (string);

    /*
    * Bug in Windows.  For some reason, when the title
    * of a column is changed after the column has been
    * created, the alignment must also be reset or the
    * text does not draw.  The fix is to query and then
    * set the alignment.
    */
    auto hwnd = parent.handle;
    LVCOLUMN lvColumn;
    lvColumn.mask = OS.LVCF_FMT;
    OS.SendMessage (hwnd, OS.LVM_GETCOLUMN, index, &lvColumn);

    /*
    * Bug in Windows.  When a column header contains a
    * mnemonic character, Windows does not measure the
    * text properly.  This causes '...' to always appear
    * at the end of the text.  The fix is to remove
    * mnemonic characters and replace doubled mnemonics
    * with spaces.
    */
    auto hHeap = OS.GetProcessHeap ();
    StringT buffer = StrToTCHARs (parent.getCodePage (), fixMnemonic (string, true), true);
    auto byteCount = buffer.length * TCHAR.sizeof;
    auto pszText = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
    OS.MoveMemory (pszText, buffer.ptr, byteCount);
    lvColumn.mask |= OS.LVCF_TEXT;
    lvColumn.pszText = pszText;
    auto result = OS.SendMessage (hwnd, OS.LVM_SETCOLUMN, index, &lvColumn);
    if (pszText !is null) OS.HeapFree (hHeap, 0, pszText);
    if (result is 0) error (SWT.ERROR_CANNOT_SET_TEXT);
}

/**
 * Sets the receiver's tool tip text to the argument, which
 * may be null indicating that no tool tip text should be shown.
 *
 * @param string the new tool tip text (or null)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setToolTipText (String string) {
    checkWidget();
    toolTipText = string;
    auto hwndHeaderToolTip = parent.headerToolTipHandle;
    if (hwndHeaderToolTip is null) {
        parent.createHeaderToolTips ();
        parent.updateHeaderToolTips ();
    }
}

/**
 * Sets the width of the receiver.
 *
 * @param width the new width
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setWidth (int width) {
    checkWidget ();
    if (width < 0) return;
    int index = parent.indexOf (this);
    if (index is -1) return;
    auto hwnd = parent.handle;
    OS.SendMessage (hwnd, OS.LVM_SETCOLUMNWIDTH, index, width);
}

void updateToolTip (int index) {
    auto hwndHeaderToolTip = parent.headerToolTipHandle;
    if (hwndHeaderToolTip !is null) {
        auto hwnd = parent.handle;
        auto hwndHeader = cast(HWND) OS.SendMessage (hwnd, OS.LVM_GETHEADER, 0, 0);
        RECT rect;
        if (OS.SendMessage (hwndHeader, OS.HDM_GETITEMRECT, index, &rect) !is 0) {
            TOOLINFO lpti;
            lpti.cbSize = OS.TOOLINFO_sizeof;
            lpti.hwnd = hwndHeader;
            lpti.uId = id;
            lpti.rect.left = rect.left;
            lpti.rect.top = rect.top;
            lpti.rect.right = rect.right;
            lpti.rect.bottom = rect.bottom;
            OS.SendMessage (hwndHeaderToolTip, OS.TTM_NEWTOOLRECT, 0, &lpti);
        }
    }
}

}

