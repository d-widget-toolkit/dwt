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
module org.eclipse.swt.widgets.TableItem;

import java.lang.all;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.ImageList;
import org.eclipse.swt.widgets.TreeItem;


/**
 * Instances of this class represent a selectable user interface object
 * that represents an item in a table.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#table">Table, TableItem, TableColumn snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class TableItem : Item {
    Table parent;
    Font font;
    Font[] cellFont;
    bool cached, grayed;

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
 *
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
 * @see SWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Table parent, int style, int index) {
    this (parent, style, index, true);
}

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
 * @see SWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Table parent, int style) {
    this (parent, style, checkNull (parent).getItemCount (), true);
}


this (Table parent, int style, int index, bool create) {
    super (parent, style);
    this.parent = parent;
    if (create) {
        parent.createItem (this, index);
    } else {
        handle = cast(GtkWidget*)OS.g_malloc (GtkTreeIter.sizeof);
        OS.gtk_tree_model_iter_nth_child (parent.modelHandle, handle, null, index);
    }
}

static Table checkNull (Table control) {
    if (control is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    return control;
}

Color _getBackground () {
    void* ptr;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, Table.BACKGROUND_COLUMN, &ptr);
    if (ptr is null) return parent.getBackground ();
    GdkColor* gdkColor = new GdkColor ();
    *gdkColor = *cast(GdkColor*) ptr;
    return Color.gtk_new (display, gdkColor);
}

Color _getBackground (int index) {
    int count = Math.max (1, parent.columnCount);
    if (0 > index || index > count - 1) return _getBackground ();
    void* ptr;
    int modelIndex = parent.columnCount is 0 ? Table.FIRST_COLUMN : parent.columns [index].modelIndex;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, modelIndex + Table.CELL_BACKGROUND, &ptr);
    if (ptr is null) return _getBackground ();
    GdkColor* gdkColor = new GdkColor ();
    *gdkColor = *cast(GdkColor*) ptr;
    return Color.gtk_new (display, gdkColor);
}

bool _getChecked () {
    void* ptr;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, Table.CHECKED_COLUMN, &ptr);
    return ptr !is null;
}

Color _getForeground () {
    void* ptr;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, Table.FOREGROUND_COLUMN, &ptr);
    if (ptr is null) return parent.getForeground ();
    GdkColor* gdkColor = new GdkColor ();
    *gdkColor = *cast(GdkColor*) ptr;
    return Color.gtk_new (display, gdkColor);
}

Color _getForeground (int index) {
    int count = Math.max (1, parent.columnCount);
    if (0 > index || index > count - 1) return _getForeground ();
    void* ptr;
    int modelIndex =  parent.columnCount is 0 ? Table.FIRST_COLUMN : parent.columns [index].modelIndex;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, modelIndex + Table.CELL_FOREGROUND, &ptr);
    if (ptr is null) return _getForeground ();
    GdkColor* gdkColor = new GdkColor ();
    *gdkColor = *cast(GdkColor*) ptr;
    return Color.gtk_new (display, gdkColor);
}

Image _getImage (int index) {
    int count = Math.max (1, parent.getColumnCount ());
    if (0 > index || index > count - 1) return null;
    void* ptr;
    int modelIndex = parent.columnCount is 0 ? Table.FIRST_COLUMN : parent.columns [index].modelIndex;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, modelIndex + Table.CELL_PIXBUF, &ptr);
    if (ptr is null) return null;
    ImageList imageList = parent.imageList;
    int imageIndex = imageList.indexOf (ptr);
    if (imageIndex is -1) return null;
    return imageList.get (imageIndex);
}

String _getText (int index) {
    int count = Math.max (1, parent.getColumnCount ());
    if (0 > index || index > count - 1) return "";
    void* ptr;
    int modelIndex = parent.columnCount is 0 ? Table.FIRST_COLUMN : parent.columns [index].modelIndex;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, modelIndex + Table.CELL_TEXT, &ptr);
    if (ptr is null) return "";
    String buffer = fromStringz( cast(char*)ptr)._idup();
    OS.g_free (ptr);
    return buffer;
}

protected override void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

void clear () {
    if (parent.currentItem is this) return;
    if (cached || (parent.style & SWT.VIRTUAL) is 0) {
        int columnCount = OS.gtk_tree_model_get_n_columns (parent.modelHandle);
        for (int i=0; i<columnCount; i++) {
            OS.gtk_list_store_set1 (parent.modelHandle, handle, i, null);
        }
        /*
        * Bug in GTK.  When using fixed-height-mode,
        * row changes do not cause the row to be repainted.  The fix is to
        * invalidate the row when it is cleared.
        */
        if ((parent.style & SWT.VIRTUAL) !is 0) {
            if (OS.GTK_VERSION >= OS.buildVERSION (2, 3, 2) && OS.GTK_VERSION < OS.buildVERSION (2, 6, 3)) {
                redraw ();
            }
        }
    }
    cached = false;
    font = null;
    cellFont = null;
}

override void destroyWidget () {
    parent.destroyItem (this);
    releaseHandle ();
}

/**
 * Returns the receiver's background color.
 *
 * @return the background color
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 */
public Color getBackground () {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return _getBackground ();
}

/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent.
 *
 * @return the receiver's bounding rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public Rectangle getBounds () {
    // TODO fully test on early and later versions of GTK
    // shifted a bit too far right on later versions of GTK - however, old Tree also had this problem
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    auto parentHandle = parent.handle;
    auto column = OS.gtk_tree_view_get_column (parentHandle, 0);
    if (column is null) return new Rectangle (0, 0, 0, 0);
    auto textRenderer = parent.getTextRenderer (column);
    auto pixbufRenderer = parent.getPixbufRenderer (column);
    if (textRenderer is null || pixbufRenderer is null)  return new Rectangle (0, 0, 0, 0);

    auto path = OS.gtk_tree_model_get_path (parent.modelHandle, handle);
    OS.gtk_widget_realize (parentHandle);

    bool isExpander = OS.gtk_tree_model_iter_n_children (parent.modelHandle, handle) > 0;
    bool isExpanded = cast(bool)OS.gtk_tree_view_row_expanded (parentHandle, path);
    OS.gtk_tree_view_column_cell_set_cell_data (column, parent.modelHandle, handle, isExpander, isExpanded);

    GdkRectangle rect;
    OS.gtk_tree_view_get_cell_area (parentHandle, path, column, &rect);
    OS.gtk_tree_path_free (path);
    if ((parent.getStyle () & SWT.MIRRORED) !is 0) rect.x = parent.getClientWidth () - rect.width - rect.x;
    int right = rect.x + rect.width;

    int x, w;
    parent.ignoreSize = true;
    OS.gtk_cell_renderer_get_size (textRenderer, parentHandle, null, null, null, &w, null);
    parent.ignoreSize = false;
    rect.width = w;
    int buffer;
    if (OS.gtk_tree_view_get_expander_column (parentHandle) is column) {
        OS.gtk_widget_style_get1 (parentHandle, OS.expander_size.ptr, &buffer);
        rect.x += buffer + TreeItem.EXPANDER_EXTRA_PADDING;
    }
    OS.gtk_widget_style_get1 (parentHandle, OS.horizontal_separator.ptr, &buffer);
    int horizontalSeparator = buffer;
    rect.x += horizontalSeparator;

    if (OS.GTK_VERSION >= OS.buildVERSION (2, 1, 3)) {
        OS.gtk_tree_view_column_cell_get_position (column, textRenderer, &x, null);
        rect.x += x;
    } else {
        if ((parent.style & SWT.CHECK) !is 0) {
            OS.gtk_cell_renderer_get_size (parent.checkRenderer, parentHandle, null, null, null, &w, null);
            rect.x += w + horizontalSeparator;
        }
        OS.gtk_cell_renderer_get_size (pixbufRenderer, parentHandle, null, null, null, &w, null);
        rect.x += w + horizontalSeparator;
    }
    if (parent.columnCount > 0) {
        if (rect.x + rect.width > right) {
            rect.width = Math.max (0, right - rect.x);
        }
    }
    int width = OS.gtk_tree_view_column_get_visible (column) ? rect.width + 1 : 0;
    return new Rectangle (rect.x, rect.y, width, rect.height + 1);
}

/**
 * Returns the background color at the given column index in the receiver.
 *
 * @param index the column index
 * @return the background color
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public Color getBackground (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return _getBackground (index);
}

/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent at a column in the table.
 *
 * @param index the index that specifies the column
 * @return the receiver's bounding column rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Rectangle getBounds (int index) {
    checkWidget();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    auto parentHandle = parent.handle;
    GtkTreeViewColumn* column;
    if (index >= 0 && index < parent.columnCount) {
        column = cast(GtkTreeViewColumn*)parent.columns [index].handle;
    } else {
        column = OS.gtk_tree_view_get_column (parentHandle, index);
    }
    if (column is null) return new Rectangle (0, 0, 0, 0);
    auto path = OS.gtk_tree_model_get_path (parent.modelHandle, handle);
    OS.gtk_widget_realize (parentHandle);
    GdkRectangle rect;
    OS.gtk_tree_view_get_cell_area (parentHandle, path, column, &rect);
    OS.gtk_tree_path_free (path);
    if ((parent.getStyle () & SWT.MIRRORED) !is 0) rect.x = parent.getClientWidth () - rect.width - rect.x;

    if (index is 0 && (parent.style & SWT.CHECK) !is 0) {
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 1, 3)) {
            int x, w;
            OS.gtk_tree_view_column_cell_get_position (column, parent.checkRenderer, &x, &w);
            rect.x += x + w;
            rect.width -= x + w;
        } else {
            int w;
            OS.gtk_cell_renderer_get_size (parent.checkRenderer, parentHandle, null, null, null, &w, null);
            int buffer;
            OS.gtk_widget_style_get1 (parentHandle, OS.horizontal_separator.ptr, &buffer);
            rect.x += w + buffer;
            rect.width -= w + buffer;
        }
    }
    int width = OS.gtk_tree_view_column_get_visible (column) ? rect.width + 1 : 0;
    return new Rectangle (rect.x, rect.y, width, rect.height + 1);
}

/**
 * Returns <code>true</code> if the receiver is checked,
 * and false otherwise.  When the parent does not have
 * the <code>CHECK</code> style, return false.
 *
 * @return the checked state of the checkbox
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getChecked () {
    checkWidget();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    if ((parent.style & SWT.CHECK) is 0) return false;
    return _getChecked ();
}

/**
 * Returns the font that the receiver will use to paint textual information for this item.
 *
 * @return the receiver's font
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public Font getFont () {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return font !is null ? font : parent.getFont ();
}

/**
 * Returns the font that the receiver will use to paint textual information
 * for the specified cell in this item.
 *
 * @param index the column index
 * @return the receiver's font
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public Font getFont (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    int count = Math.max (1, parent.columnCount);
    if (0 > index || index > count - 1) return getFont ();
    if (cellFont is null || cellFont [index] is null) return getFont ();
    return cellFont [index];
}

/**
 * Returns the foreground color that the receiver will use to draw.
 *
 * @return the receiver's foreground color
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 */
public Color getForeground () {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return _getForeground ();
}

/**
 *
 * Returns the foreground color at the given column index in the receiver.
 *
 * @param index the column index
 * @return the foreground color
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public Color getForeground (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return _getForeground (index);
}

/**
 * Returns <code>true</code> if the receiver is grayed,
 * and false otherwise. When the parent does not have
 * the <code>CHECK</code> style, return false.
 *
 * @return the grayed state of the checkbox
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getGrayed () {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    if ((parent.style & SWT.CHECK) is 0) return false;
    return grayed;
}

public override Image getImage () {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return getImage (0);
}

/**
 * Returns the image stored at the given column index in the receiver,
 * or null if the image has not been set or if the column does not exist.
 *
 * @param index the column index
 * @return the image stored at the given column index in the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Image getImage (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return _getImage (index);
}

/**
 * Returns a rectangle describing the size and location
 * relative to its parent of an image at a column in the
 * table.  An empty rectangle is returned if index exceeds
 * the index of the table's last column.
 *
 * @param index the index that specifies the column
 * @return the receiver's bounding image rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Rectangle getImageBounds (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    auto parentHandle = parent.handle;
    GtkTreeViewColumn* column;
    if (index >= 0 && index < parent.columnCount) {
        column = cast(GtkTreeViewColumn*)parent.columns [index].handle;
    } else {
        column = OS.gtk_tree_view_get_column (parentHandle, index);
    }
    if (column is null) return new Rectangle (0, 0, 0, 0);
    auto pixbufRenderer = parent.getPixbufRenderer (column);
    if (pixbufRenderer is null)  return new Rectangle (0, 0, 0, 0);
    GdkRectangle rect;
    auto path = OS.gtk_tree_model_get_path (parent.modelHandle, handle);
    OS.gtk_widget_realize (parentHandle);
    OS.gtk_tree_view_get_cell_area (parentHandle, path, column, &rect);
    OS.gtk_tree_path_free (path);
    if ((parent.getStyle () & SWT.MIRRORED) !is 0) rect.x = parent.getClientWidth () - rect.width - rect.x;
    /*
    * The OS call gtk_cell_renderer_get_size() provides the width of image to be drawn
    * by the cell renderer.  If there is no image in the cell, the width is zero.  If the table contains
    * images of varying widths, gtk_cell_renderer_get_size() will return the width of the image,
    * not the width of the area in which the image is drawn.
    * New API was added in GTK 2.1.3 for determining the full width of the renderer area.
    * For earlier versions of GTK, the result is only correct if all rows have images of the same
    * width.
    */
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 1, 3)) {
        int x, w;
        OS.gtk_tree_view_column_cell_get_position (column, pixbufRenderer, &x, &w);
        rect.x += x;
        rect.width = w;
    } else {
        int w;
        OS.gtk_tree_view_column_cell_set_cell_data (column, parent.modelHandle, handle, false, false);
        OS.gtk_cell_renderer_get_size (pixbufRenderer, parentHandle, null, null, null, &w, null);
        rect.width = w;
    }
    int width = OS.gtk_tree_view_column_get_visible (column) ? rect.width : 0;
    return new Rectangle (rect.x, rect.y, width, rect.height + 1);
}

/**
 * Gets the image indent.
 *
 * @return the indent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getImageIndent () {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    /* Image indent is not supported on GTK */
    return 0;
}

override String getNameText () {
    if ((parent.style & SWT.VIRTUAL) !is 0) {
        if (!cached) return "*virtual*"; //$NON-NLS-1$
    }
    return super.getNameText ();
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

public override String getText () {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return getText (0);
}

/**
 * Returns the text stored at the given column index in the receiver,
 * or empty string if the text has not been set.
 *
 * @param index the column index
 * @return the text stored at the given column index in the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return _getText (index);
}

/**
 * Returns a rectangle describing the size and location
 * relative to its parent of the text at a column in the
 * table.  An empty rectangle is returned if index exceeds
 * the index of the table's last column.
 *
 * @param index the index that specifies the column
 * @return the receiver's bounding text rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.3
 */
public Rectangle getTextBounds (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    int count = Math.max (1, parent.getColumnCount ());
    if (0 > index || index > count - 1) return new Rectangle (0, 0, 0, 0);
    // TODO fully test on early and later versions of GTK
    // shifted a bit too far right on later versions of GTK - however, old Tree also had this problem
    auto parentHandle = parent.handle;
    GtkTreeViewColumn* column;
    if (index >= 0 && index < parent.columnCount) {
        column = cast(GtkTreeViewColumn*)parent.columns [index].handle;
    } else {
        column = OS.gtk_tree_view_get_column (parentHandle, index);
    }
    if (column is null) return new Rectangle (0, 0, 0, 0);
    auto textRenderer = parent.getTextRenderer (column);
    auto pixbufRenderer = parent.getPixbufRenderer (column);
    if (textRenderer is null || pixbufRenderer is null)  return new Rectangle (0, 0, 0, 0);

    auto path = OS.gtk_tree_model_get_path (parent.modelHandle, handle);
    OS.gtk_widget_realize (parentHandle);

    bool isExpander = OS.gtk_tree_model_iter_n_children (parent.modelHandle, handle) > 0;
    bool isExpanded = cast(bool)OS.gtk_tree_view_row_expanded (parentHandle, path);
    OS.gtk_tree_view_column_cell_set_cell_data (column, parent.modelHandle, handle, isExpander, isExpanded);

    GdkRectangle rect;
    OS.gtk_tree_view_get_cell_area (parentHandle, path, column, &rect);
    OS.gtk_tree_path_free (path);
    if ((parent.getStyle () & SWT.MIRRORED) !is 0) rect.x = parent.getClientWidth () - rect.width - rect.x;
    int right = rect.x + rect.width;

    int x, w;
    parent.ignoreSize = true;
    OS.gtk_cell_renderer_get_size (textRenderer, parentHandle, null, null, null, &w, null);
    parent.ignoreSize = false;
    int buffer;
    if (OS.gtk_tree_view_get_expander_column (parentHandle) is column) {
        OS.gtk_widget_style_get1 (parentHandle, OS.expander_size.ptr, &buffer);
        rect.x += buffer + TreeItem.EXPANDER_EXTRA_PADDING;
    }
    OS.gtk_widget_style_get1 (parentHandle, OS.horizontal_separator.ptr, &buffer);
    int horizontalSeparator = buffer;
    rect.x += horizontalSeparator;

    if (OS.GTK_VERSION >= OS.buildVERSION (2, 1, 3)) {
        OS.gtk_tree_view_column_cell_get_position (column, textRenderer, &x, null);
        rect.x += x;
    } else {
        if ((parent.style & SWT.CHECK) !is 0) {
            OS.gtk_cell_renderer_get_size (parent.checkRenderer, parentHandle, null, null, null, &w, null);
            rect.x += w + horizontalSeparator;
        }
        OS.gtk_cell_renderer_get_size (pixbufRenderer, parentHandle, null, null, null, &w, null);
        rect.x += w + horizontalSeparator;
    }
    if (parent.columnCount > 0) {
        if (rect.x + rect.width > right) {
            rect.width = Math.max (0, right - rect.x);
        }
    }
    int width = OS.gtk_tree_view_column_get_visible (column) ? rect.width + 1 : 0;
    return new Rectangle (rect.x, rect.y, width, rect.height + 1);
}

void redraw () {
    if ((OS.GTK_WIDGET_FLAGS (parent.handle) & OS.GTK_REALIZED) !is 0) {
        auto parentHandle = parent.handle;
        auto path = OS.gtk_tree_model_get_path (parent.modelHandle, handle);
        GdkRectangle rect;
        OS.gtk_tree_view_get_cell_area (parentHandle, path, null, &rect);
        OS.gtk_tree_path_free (path);
        auto window = OS.gtk_tree_view_get_bin_window (parentHandle);
        rect.x = 0;
        int w, h;
        OS.gdk_drawable_get_size (window, &w, &h);
        rect.width = w;
        OS.gdk_window_invalidate_rect (window, &rect, false);
    }
}

override void releaseHandle () {
    if (handle !is null) OS.g_free (handle);
    handle = null;
    super.releaseHandle ();
    parent = null;
}

override void releaseWidget () {
    super.releaseWidget ();
    font = null;
    cellFont = null;
}

/**
 * Sets the receiver's background color to the color specified
 * by the argument, or to the default system color for the item
 * if the argument is null.
 *
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 */
public void setBackground (Color color) {
    checkWidget ();
    if (color !is null && color.isDisposed ()) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    if (_getBackground ().opEquals (color)) return;
    GdkColor* gdkColor = color !is null ? color.handle : null;
    OS.gtk_list_store_set1 (parent.modelHandle, handle, Table.BACKGROUND_COLUMN, gdkColor);
    /*
    * Bug in GTK.  When using fixed-height-mode,
    * row changes do not cause the row to be repainted.  The fix is to
    * invalidate the row when it is cleared.
    */
    if ((parent.style & SWT.VIRTUAL) !is 0) {
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 3, 2) && OS.GTK_VERSION < OS.buildVERSION (2, 6, 3)) {
            redraw ();
        }
    }
    cached = true;
}

/**
 * Sets the background color at the given column index in the receiver
 * to the color specified by the argument, or to the default system color for the item
 * if the argument is null.
 *
 * @param index the column index
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setBackground (int index, Color color) {
    checkWidget ();
    if (color !is null && color.isDisposed ()) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    if (_getBackground (index).opEquals (color)) return;
    int count = Math.max (1, parent.getColumnCount ());
    if (0 > index || index > count - 1) return;
    int modelIndex = parent.columnCount is 0 ? Table.FIRST_COLUMN : parent.columns [index].modelIndex;
    GdkColor* gdkColor = color !is null ? color.handle : null;
    OS.gtk_list_store_set1 (parent.modelHandle, handle, modelIndex + Table.CELL_BACKGROUND, gdkColor);
    /*
    * Bug in GTK.  When using fixed-height-mode,
    * row changes do not cause the row to be repainted.  The fix is to
    * invalidate the row when it is cleared.
    */
    if ((parent.style & SWT.VIRTUAL) !is 0) {
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 3, 2) && OS.GTK_VERSION < OS.buildVERSION (2, 6, 3)) {
            redraw ();
        }
    }
    cached = true;

    if (color !is null) {
        bool customDraw = (parent.columnCount is 0)  ? parent.firstCustomDraw : parent.columns [index].customDraw;
        if (!customDraw) {
            if ((parent.style & SWT.VIRTUAL) is 0) {
                auto parentHandle = parent.handle;
                GtkTreeViewColumn* column;
                if (parent.columnCount > 0) {
                    column = cast(GtkTreeViewColumn*)parent.columns [index].handle;
                } else {
                    column = OS.gtk_tree_view_get_column (parentHandle, index);
                }
                if (column is null) return;
                auto textRenderer = parent.getTextRenderer (column);
                auto imageRenderer = parent.getPixbufRenderer (column);
                display.doCellDataProc( parentHandle, column, cast(GtkCellRenderer*)textRenderer );
                display.doCellDataProc( parentHandle, column, cast(GtkCellRenderer*)imageRenderer );
            }
            if (parent.columnCount is 0) {
                parent.firstCustomDraw = true;
            } else {
                parent.columns [index].customDraw = true;
            }
        }
    }
}

/**
 * Sets the checked state of the checkbox for this item.  This state change
 * only applies if the Table was created with the SWT.CHECK style.
 *
 * @param checked the new checked state of the checkbox
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setChecked (bool checked) {
    checkWidget();
    if ((parent.style & SWT.CHECK) is 0) return;
    if (_getChecked () is checked) return;
    OS.gtk_list_store_set1 (parent.modelHandle, handle, Table.CHECKED_COLUMN, cast(void*)cast(int)checked);
    /*
    * GTK+'s "inconsistent" state does not match SWT's concept of grayed.  To
    * show checked+grayed differently from unchecked+grayed, we must toggle the
    * grayed state on check and uncheck.
    */
    OS.gtk_list_store_set1 (parent.modelHandle, handle, Table.GRAYED_COLUMN, cast(void*)cast(int)( !checked ? false : grayed));
    cached = true;
}

/**
 * Sets the font that the receiver will use to paint textual information
 * for this item to the font specified by the argument, or to the default font
 * for that kind of control if the argument is null.
 *
 * @param font the new font (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setFont (Font font){
    checkWidget ();
    if (font !is null && font.isDisposed ()) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    Font oldFont = this.font;
    if (oldFont is font) return;
    this.font = font;
    if (oldFont !is null && oldFont.opEquals (font)) return;
    auto fontHandle = font !is null ? font.handle : null;
    OS.gtk_list_store_set1 (parent.modelHandle, handle, Table.FONT_COLUMN, fontHandle);
    /*
    * Bug in GTK.  When using fixed-height-mode,
    * row changes do not cause the row to be repainted.  The fix is to
    * invalidate the row when it is cleared.
    */
    if ((parent.style & SWT.VIRTUAL) !is 0) {
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 3, 2) && OS.GTK_VERSION < OS.buildVERSION (2, 6, 3)) {
            redraw ();
        }
    }
    cached = true;
}

/**
 * Sets the font that the receiver will use to paint textual information
 * for the specified cell in this item to the font specified by the
 * argument, or to the default font for that kind of control if the
 * argument is null.
 *
 * @param index the column index
 * @param font the new font (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setFont (int index, Font font) {
    checkWidget ();
    if (font !is null && font.isDisposed ()) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    int count = Math.max (1, parent.getColumnCount ());
    if (0 > index || index > count - 1) return;
    if (cellFont is null) {
        if (font is null) return;
        cellFont = new Font [count];
    }
    Font oldFont = cellFont [index];
    if (oldFont is font) return;
    cellFont [index] = font;
    if (oldFont !is null && oldFont.opEquals (font)) return;

    int modelIndex = parent.columnCount is 0 ? Table.FIRST_COLUMN : parent.columns [index].modelIndex;
    auto fontHandle  = font !is null ? font.handle : null;
    OS.gtk_list_store_set1 (parent.modelHandle, handle, modelIndex + Table.CELL_FONT, fontHandle);
    /*
    * Bug in GTK.  When using fixed-height-mode,
    * row changes do not cause the row to be repainted.  The fix is to
    * invalidate the row when it is cleared.
    */
    if ((parent.style & SWT.VIRTUAL) !is 0) {
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 3, 2) && OS.GTK_VERSION < OS.buildVERSION (2, 6, 3)) {
            redraw ();
        }
    }
    cached = true;

    if (font !is null) {
        bool customDraw = (parent.columnCount is 0)  ? parent.firstCustomDraw : parent.columns [index].customDraw;
        if (!customDraw) {
            if ((parent.style & SWT.VIRTUAL) is 0) {
                auto parentHandle = parent.handle;
                GtkTreeViewColumn* column;
                if (parent.columnCount > 0) {
                    column = cast(GtkTreeViewColumn*)parent.columns [index].handle;
                } else {
                    column = OS.gtk_tree_view_get_column (parentHandle, index);
                }
                if (column is null) return;
                auto textRenderer = parent.getTextRenderer (column);
                auto imageRenderer = parent.getPixbufRenderer (column);
                display.doCellDataProc( parentHandle, column, cast(GtkCellRenderer*)textRenderer );
                display.doCellDataProc( parentHandle, column, cast(GtkCellRenderer*)imageRenderer );
            }
            if (parent.columnCount is 0) {
                parent.firstCustomDraw = true;
            } else {
                parent.columns [index].customDraw = true;
            }
        }
    }
}

/**
 * Sets the receiver's foreground color to the color specified
 * by the argument, or to the default system color for the item
 * if the argument is null.
 *
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 */
public void setForeground (Color color){
    checkWidget ();
    if (color !is null && color.isDisposed ()) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    if (_getForeground ().opEquals (color)) return;
    GdkColor* gdkColor = color !is null ? color.handle : null;
    OS.gtk_list_store_set1 (parent.modelHandle, handle, Table.FOREGROUND_COLUMN, gdkColor);
    /*
    * Bug in GTK.  When using fixed-height-mode,
    * row changes do not cause the row to be repainted.  The fix is to
    * invalidate the row when it is cleared.
    */
    if ((parent.style & SWT.VIRTUAL) !is 0) {
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 3, 2) && OS.GTK_VERSION < OS.buildVERSION (2, 6, 3)) {
            redraw ();
        }
    }
    cached = true;
}

/**
 * Sets the foreground color at the given column index in the receiver
 * to the color specified by the argument, or to the default system color for the item
 * if the argument is null.
 *
 * @param index the column index
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setForeground (int index, Color color){
    checkWidget ();
    if (color !is null && color.isDisposed ()) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    if (_getForeground (index).opEquals (color)) return;
    int count = Math.max (1, parent.getColumnCount ());
    if (0 > index || index > count - 1) return;
    int modelIndex = parent.columnCount is 0 ? Table.FIRST_COLUMN : parent.columns [index].modelIndex;
    GdkColor* gdkColor = color !is null ? color.handle : null;
    OS.gtk_list_store_set1 (parent.modelHandle, handle, modelIndex + Table.CELL_FOREGROUND, gdkColor);
    /*
    * Bug in GTK.  When using fixed-height-mode,
    * row changes do not cause the row to be repainted.  The fix is to
    * invalidate the row when it is cleared.
    */
    if ((parent.style & SWT.VIRTUAL) !is 0) {
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 3, 2) && OS.GTK_VERSION < OS.buildVERSION (2, 6, 3)) {
            redraw ();
        }
    }
    cached = true;

    if (color !is null) {
        bool customDraw = (parent.columnCount is 0)  ? parent.firstCustomDraw : parent.columns [index].customDraw;
        if (!customDraw) {
            if ((parent.style & SWT.VIRTUAL) is 0) {
                auto parentHandle = parent.handle;
                GtkTreeViewColumn* column;
                if (parent.columnCount > 0) {
                    column = cast(GtkTreeViewColumn*)parent.columns [index].handle;
                } else {
                    column = OS.gtk_tree_view_get_column (parentHandle, index);
                }
                if (column is null) return;
                auto textRenderer = parent.getTextRenderer (column);
                auto imageRenderer = parent.getPixbufRenderer (column);
                display.doCellDataProc( parentHandle, column, cast(GtkCellRenderer*)textRenderer );
                display.doCellDataProc( parentHandle, column, cast(GtkCellRenderer*)imageRenderer );
            }
            if (parent.columnCount is 0) {
                parent.firstCustomDraw = true;
            } else {
                parent.columns [index].customDraw = true;
            }
        }
    }
}

/**
 * Sets the grayed state of the checkbox for this item.  This state change
 * only applies if the Table was created with the SWT.CHECK style.
 *
 * @param grayed the new grayed state of the checkbox;
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setGrayed (bool grayed) {
    checkWidget();
    if ((parent.style & SWT.CHECK) is 0) return;
    if (this.grayed is grayed) return;
    this.grayed = grayed;
    /*
    * GTK+'s "inconsistent" state does not match SWT's concept of grayed.
    * Render checked+grayed as "inconsistent", unchecked+grayed as blank.
    */
    void* ptr;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, Table.CHECKED_COLUMN, &ptr);
    OS.gtk_list_store_set1 (parent.modelHandle, handle, Table.GRAYED_COLUMN, cast(void*)cast(int)( ptr is null ? false : grayed));
    cached = true;
}

/**
 * Sets the receiver's image at a column.
 *
 * @param index the column index
 * @param image the new image
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setImage (int index, Image image) {
    checkWidget ();
    if (image !is null && image.isDisposed ()) {
        error(SWT.ERROR_INVALID_ARGUMENT);
    }
    if (image !is null && image.type is SWT.ICON) {
        if (image.opEquals (_getImage (index))) return;
    }
    int count = Math.max (1, parent.getColumnCount ());
    if (0 > index || index > count - 1) return;
    void* pixbuf;
    if (image !is null) {
        ImageList imageList = parent.imageList;
        if (imageList is null) imageList = parent.imageList = new ImageList ();
        int imageIndex = imageList.indexOf (image);
        if (imageIndex is -1) imageIndex = imageList.add (image);
        pixbuf = imageList.getPixbuf (imageIndex);
    }
    int modelIndex = parent.columnCount is 0 ? Table.FIRST_COLUMN : parent.columns [index].modelIndex;
    OS.gtk_list_store_set1 (parent.modelHandle, handle, modelIndex + Table.CELL_PIXBUF, pixbuf);
    /*
    * Bug in GTK.  When using fixed-height-mode,
    * row changes do not cause the row to be repainted.  The fix is to
    * invalidate the row when it is cleared.
    */
    if ((parent.style & SWT.VIRTUAL) !is 0) {
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 3, 2) && OS.GTK_VERSION < OS.buildVERSION (2, 6, 3)) {
            redraw ();
        }
    }
    /*
     * Bug in GTK.  When in fixed height mode, GTK does not recalculate the cell renderer width
     * when the image is changed in the model.  The fix is to force it to recalculate the width if
     * more space is required.
     */
    if ((parent.style & SWT.VIRTUAL) !is 0 && parent.currentItem is null) {
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 3, 2)) {
            if (image !is null) {
                auto parentHandle = parent.handle;
                auto column = OS.gtk_tree_view_get_column (parentHandle, index);
                int w;
                auto pixbufRenderer = parent.getPixbufRenderer(column);
                OS.gtk_tree_view_column_cell_get_position (column, pixbufRenderer, null, &w);
                if (w < image.getBounds().width) {
                    /*
                    * There is no direct way to clear the cell renderer width so we
                    * are relying on the fact that it is done as part of modifying
                    * the style.
                    */
                    auto style = OS.gtk_widget_get_modifier_style (parentHandle);
                    parent.modifyStyle (parentHandle, style);
                }
            }
        }
    }
    cached = true;
}

public override void setImage (Image image) {
    checkWidget ();
    setImage (0, image);
}

/**
 * Sets the image for multiple columns in the table.
 *
 * @param images the array of new images
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if one of the images has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setImage (Image [] images) {
    checkWidget ();
    for (int i=0; i<images.length; i++) {
        setImage (i, images [i]);
    }
}

/**
 * Sets the indent of the first column's image, expressed in terms of the image's width.
 *
 * @param indent the new indent
 *
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @deprecated this functionality is not supported on most platforms
 */
public void setImageIndent (int indent) {
    checkWidget ();
    if (indent < 0) return;
    /* Image indent is not supported on GTK */
    cached = true;
}

/**
 * Sets the receiver's text at a column
 *
 * @param index the column index
 * @param string the new text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setText (int index, String string) {
    checkWidget ();
    if (_getText (index).equals (string)) return;
    int count = Math.max (1, parent.getColumnCount ());
    if (0 > index || index > count - 1) return;
    char* buffer = toStringz( string );
    int modelIndex = parent.columnCount is 0 ? Table.FIRST_COLUMN : parent.columns [index].modelIndex;
    OS.gtk_list_store_set1 (parent.modelHandle, handle, modelIndex + Table.CELL_TEXT, buffer);
    /*
    * Bug in GTK.  When using fixed-height-mode,
    * row changes do not cause the row to be repainted.  The fix is to
    * invalidate the row when it is cleared.
    */
    if ((parent.style & SWT.VIRTUAL) !is 0) {
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 3, 2) && OS.GTK_VERSION < OS.buildVERSION (2, 6, 3)) {
            redraw ();
        }
    }
    cached = true;
}

public override void setText (String string) {
    checkWidget ();
    setText (0, string);
}

/**
 * Sets the text for multiple columns in the table.
 *
 * @param strings the array of new strings
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setText (String [] strings) {
    checkWidget ();
    for (int i=0; i<strings.length; i++) {
        String string = strings [i];
        if (string !is null) setText (i, string);
    }
}
}
