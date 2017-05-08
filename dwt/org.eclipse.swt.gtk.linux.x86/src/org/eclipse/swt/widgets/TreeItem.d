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
module org.eclipse.swt.widgets.TreeItem;

import java.lang.all;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.ImageList;


/**
 * Instances of this class represent a selectable user interface object
 * that represents a hierarchy of tree items in a tree widget.
 *
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
 * @see <a href="http://www.eclipse.org/swt/snippets/#tree">Tree, TreeItem, TreeColumn snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class TreeItem : Item {
    Tree parent;
    Font font;
    Font[] cellFont;
    bool cached, grayed;
    static const int EXPANDER_EXTRA_PADDING = 4;

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Tree</code> or a <code>TreeItem</code>)
 * and a style value describing its behavior and appearance.
 * The item is added to the end of the items maintained by its parent.
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
 * @param parent a tree control which will be the parent of the new instance (cannot be null)
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
public this (Tree parent, int style) {
    this (checkNull (parent), null, style, -1, true);
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Tree</code> or a <code>TreeItem</code>),
 * a style value describing its behavior and appearance, and the index
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
 * @param parent a tree control which will be the parent of the new instance (cannot be null)
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
public this (Tree parent, int style, int index) {
    this (checkNull (parent), null, style, checkIndex (index), true);
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Tree</code> or a <code>TreeItem</code>)
 * and a style value describing its behavior and appearance.
 * The item is added to the end of the items maintained by its parent.
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
 * @param parentItem a tree control which will be the parent of the new instance (cannot be null)
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
public this (TreeItem parentItem, int style) {
    this (checkNull (parentItem).parent, cast(GtkTreeIter*)parentItem.handle, style, -1, true);
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Tree</code> or a <code>TreeItem</code>),
 * a style value describing its behavior and appearance, and the index
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
 * @param parentItem a tree control which will be the parent of the new instance (cannot be null)
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
public this (TreeItem parentItem, int style, int index) {
    this (checkNull (parentItem).parent, cast(GtkTreeIter*)parentItem.handle, style, checkIndex (index), true);
}

this (Tree parent, GtkTreeIter* parentIter, int style, int index, bool create) {
    super (parent, style);
    this.parent = parent;
    if (create) {
        parent.createItem (this, parentIter, index);
    } else {
        handle = cast(GtkWidget*)OS.g_malloc (GtkTreeIter.sizeof);
        OS.gtk_tree_model_iter_nth_child (parent.modelHandle, handle, parentIter, index);
    }
}

static int checkIndex (int index) {
    if (index < 0) SWT.error (SWT.ERROR_INVALID_RANGE);
    return index;
}

static TreeItem checkNull (TreeItem item) {
    if (item is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    return item;
}

static Tree checkNull (Tree control) {
    if (control is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    return control;
}

protected override void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

Color _getBackground () {
    void* ptr;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, Tree.BACKGROUND_COLUMN, &ptr);
    if (ptr is null) return parent.getBackground ();
    GdkColor* gdkColor = new GdkColor ();
    *gdkColor = *cast(GdkColor*) ptr;
    return Color.gtk_new (display, gdkColor);
}

Color _getBackground (int index) {
    int count = Math.max (1, parent.columnCount);
    if (0 > index || index > count - 1) return _getBackground ();
    void* ptr;
    int modelIndex = parent.columnCount is 0 ? Tree.FIRST_COLUMN : parent.columns [index].modelIndex;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, modelIndex + Tree.CELL_BACKGROUND, &ptr);
    if (ptr is null) return _getBackground ();
    GdkColor* gdkColor = new GdkColor ();
    *gdkColor = *cast(GdkColor*) ptr;
    return Color.gtk_new (display, gdkColor);
}

bool _getChecked () {
    void* ptr;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, Tree.CHECKED_COLUMN, &ptr);
    return ptr !is null;
}

Color _getForeground () {
    void* ptr;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, Tree.FOREGROUND_COLUMN, &ptr);
    if (ptr is null) return parent.getForeground ();
    GdkColor* gdkColor = new GdkColor ();
    *gdkColor = *cast(GdkColor*) ptr;
    return Color.gtk_new (display, gdkColor);
}

Color _getForeground (int index) {
    int count = Math.max (1, parent.columnCount);
    if (0 > index || index > count - 1) return _getForeground ();
    void* ptr;
    int modelIndex =  parent.columnCount is 0 ? Tree.FIRST_COLUMN : parent.columns [index].modelIndex;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, modelIndex + Tree.CELL_FOREGROUND, &ptr);
    if (ptr is null) return _getForeground ();
    GdkColor* gdkColor = new GdkColor ();
    *gdkColor = *cast(GdkColor*) ptr;
    return Color.gtk_new (display, gdkColor);
}

Image _getImage (int index) {
    int count = Math.max (1, parent.getColumnCount ());
    if (0 > index || index > count - 1) return null;
    void* ptr;
    int modelIndex = parent.columnCount is 0 ? Tree.FIRST_COLUMN : parent.columns [index].modelIndex;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, modelIndex + Tree.CELL_PIXBUF, &ptr);
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
    int modelIndex = parent.columnCount is 0 ? Tree.FIRST_COLUMN : parent.columns [index].modelIndex;
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, modelIndex + Tree.CELL_TEXT, &ptr);
    if (ptr is null) return ""; //$NON-NLS-1$
    String buffer = fromStringz( cast(char*)ptr)._idup();
    OS.g_free (ptr);
    return buffer;
}

void clear () {
    if (parent.currentItem is this) return;
    if (cached || (parent.style & SWT.VIRTUAL) is 0) {
        int columnCount = OS.gtk_tree_model_get_n_columns (parent.modelHandle);
        for (int i=Tree.CHECKED_COLUMN; i<columnCount; i++) {
            OS.gtk_tree_store_set1(parent.modelHandle, cast(GtkTreeIter*)handle, i, null);
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
    parent.clear (cast(GtkTreeIter*)handle, index, all);
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
    parent.clearAll (all, cast(GtkTreeIter*)handle);
}

override void destroyWidget () {
    parent.releaseItem (this, false);
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
 *
 */
public Color getBackground () {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return _getBackground ();
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
 * @since 3.1
 */
public Color getBackground (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return _getBackground (index);
}

/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent at a column in the tree.
 *
 * @param index the index that specifies the column
 * @return the receiver's bounding column rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public Rectangle getBounds (int index) {
    // TODO fully test on early and later versions of GTK
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
    if ((parent.getStyle () & SWT.MIRRORED) !is 0) rect.x = parent.getClientWidth () - rect.width - rect.x;

    if (OS.GTK_VERSION < OS.buildVERSION (2, 8, 18) && OS.gtk_tree_view_get_expander_column (parentHandle) is column) {
        int buffer;
        OS.gtk_widget_style_get1 (parentHandle, OS.expander_size.ptr, &buffer);
        rect.x += buffer + TreeItem.EXPANDER_EXTRA_PADDING;
        rect.width -= buffer + TreeItem.EXPANDER_EXTRA_PADDING;
        OS.gtk_widget_style_get1 (parentHandle, OS.horizontal_separator.ptr, &buffer);
        rect.x += buffer;
        //rect.width -= buffer [0]; // TODO Is this required for some versions?
    }
    /*
    * Bug in GTK. In GTK 2.8.x, the cell area is left aligned even
    * when the widget is mirrored. The fix is to sum up the indentation
    * of the expanders.
    */
    if ((parent.getStyle () & SWT.MIRRORED) !is 0 && (OS.GTK_VERSION < OS.buildVERSION (2, 10, 0))) {
        int depth = OS.gtk_tree_path_get_depth (path);
        int  expanderSize;
        OS.gtk_widget_style_get1 (parentHandle, OS.expander_size.ptr, &expanderSize);
        rect.x += depth * (expanderSize + TreeItem.EXPANDER_EXTRA_PADDING);
    }
    OS.gtk_tree_path_free (path);

    if (index is 0 && (parent.style & SWT.CHECK) !is 0) {
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 1, 3)) {
            int  x, w;
            OS.gtk_tree_view_column_cell_get_position (column, parent.checkRenderer, &x, &w);
            rect.x += x + w;
            rect.width -= x + w;
        } else {
            int w;
            OS.gtk_cell_renderer_get_size (parent.checkRenderer, parentHandle, null, null, null, &w, null);
            int buffer;
            OS.gtk_widget_style_get1 (parentHandle, OS.horizontal_separator.ptr, &buffer);
            rect.x += w  + buffer;
            rect.width -= w  + buffer;
        }
    }
    int width = OS.gtk_tree_view_column_get_visible (column) ? rect.width + 1 : 0;
    return new Rectangle (rect.x, rect.y, width, rect.height + 1);
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
    if ((parent.getStyle () & SWT.MIRRORED) !is 0) rect.x = parent.getClientWidth () - rect.width - rect.x;
    int right = rect.x + rect.width;

    int x, w;
    parent.ignoreSize = true;
    OS.gtk_cell_renderer_get_size (textRenderer, parentHandle, null, null, null, &w, null);
    parent.ignoreSize = false;
    rect.width = w;
    int buffer;
    if (OS.GTK_VERSION < OS.buildVERSION (2, 8, 18) && OS.gtk_tree_view_get_expander_column (parentHandle) is column) {
        OS.gtk_widget_style_get1 (parentHandle, OS.expander_size.ptr, &buffer);
        rect.x += buffer + TreeItem.EXPANDER_EXTRA_PADDING;
    }
    /*
    * Bug in GTK. In GTK 2.8.x, the cell area is left aligned even
    * when the widget is mirrored. The fix is to sum up the indentation
    * of the expanders.
    */
    if ((parent.getStyle () & SWT.MIRRORED) !is 0 && (OS.GTK_VERSION < OS.buildVERSION (2, 10, 0))) {
        int depth = OS.gtk_tree_path_get_depth (path);
        int expanderSize;
        OS.gtk_widget_style_get1 (parentHandle, OS.expander_size.ptr, &expanderSize);
        rect.x += depth * (expanderSize + TreeItem.EXPANDER_EXTRA_PADDING);
    }
    OS.gtk_tree_path_free (path);

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
 * Returns <code>true</code> if the receiver is checked,
 * and false otherwise.  When the parent does not have
 * the <code>CHECK style, return false.
 * <p>
 *
 * @return the checked state
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
 * Returns <code>true</code> if the receiver is expanded,
 * and false otherwise.
 * <p>
 *
 * @return the expanded state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getExpanded () {
    checkWidget();
    auto path = OS.gtk_tree_model_get_path (parent.modelHandle, handle);
    bool answer = cast(bool)OS.gtk_tree_view_row_expanded (parent.handle, path);
    OS.gtk_tree_path_free (path);
    return answer;
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
 * @since 3.1
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
 *
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
 * @since 3.1
 */
public Color getForeground (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return _getForeground (index);
}

/**
 * Returns <code>true</code> if the receiver is grayed,
 * and false otherwise. When the parent does not have
 * the <code>CHECK style, return false.
 * <p>
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
 *
 * @since 3.1
 */
public Image getImage (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return _getImage (index);
}

/**
 * Returns a rectangle describing the size and location
 * relative to its parent of an image at a column in the
 * tree.
 *
 * @param index the index that specifies the column
 * @return the receiver's bounding image rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public Rectangle getImageBounds (int index) {
    // TODO fully test on early and later versions of GTK
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    auto parentHandle = parent.handle;
    GtkTreeViewColumn* column;
    if (index >= 0 && index < parent.getColumnCount ()) {
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
    if ((parent.getStyle () & SWT.MIRRORED) !is 0) rect.x = parent.getClientWidth () - rect.width - rect.x;
    if (OS.GTK_VERSION < OS.buildVERSION (2, 8, 18) && OS.gtk_tree_view_get_expander_column (parentHandle) is column) {
        int buffer;
        OS.gtk_widget_style_get1 (parentHandle, OS.expander_size.ptr, &buffer);
        rect.x += buffer + TreeItem.EXPANDER_EXTRA_PADDING;
        rect.width -= buffer + TreeItem.EXPANDER_EXTRA_PADDING;
        //OS.gtk_widget_style_get (parentHandle, OS.horizontal_separator, buffer, 0);
        //int horizontalSeparator = buffer[0];
        //rect.x += horizontalSeparator;
    }
    /*
    * Bug in GTK. In GTK 2.8.x, the cell area is left aligned even
    * when the widget is mirrored. The fix is to sum up the indentation
    * of the expanders.
    */
    if ((parent.getStyle () & SWT.MIRRORED) !is 0 && (OS.GTK_VERSION < OS.buildVERSION (2, 10, 0))) {
        int depth = OS.gtk_tree_path_get_depth (path);
        int expanderSize;
        OS.gtk_widget_style_get1 (parentHandle, OS.expander_size.ptr, &expanderSize);
        rect.x += depth * (expanderSize + TreeItem.EXPANDER_EXTRA_PADDING);
    }
    OS.gtk_tree_path_free (path);

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
 * Returns the number of items contained in the receiver
 * that are direct item children of the receiver.
 *
 * @return the number of items
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getItemCount () {
    checkWidget();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return OS.gtk_tree_model_iter_n_children (parent.modelHandle, handle);
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
    checkWidget();
    if (index < 0) error (SWT.ERROR_INVALID_RANGE);
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    int itemCount = OS.gtk_tree_model_iter_n_children (parent.modelHandle, handle);
    if (index >= itemCount)  error (SWT.ERROR_INVALID_RANGE);
    return  parent._getItem (cast(GtkTreeIter*)handle, index);
}

/**
 * Returns a (possibly empty) array of <code>TreeItem</code>s which
 * are the direct item children of the receiver.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the receiver's items
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public TreeItem [] getItems () {
    checkWidget();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return parent.getItems (cast(GtkTreeIter*)handle);
}

override String getNameText () {
    if ((parent.style & SWT.VIRTUAL) !is 0) {
        if (!cached) return "*virtual*"; //$NON-NLS-1$
    }
    return super.getNameText ();
}

/**
 * Returns the receiver's parent, which must be a <code>Tree</code>.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Tree getParent () {
    checkWidget ();
    return parent;
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
    checkWidget();
    auto path = OS.gtk_tree_model_get_path (parent.modelHandle, handle);
    TreeItem item = null;
    int depth = OS.gtk_tree_path_get_depth (path);
    if (depth > 1) {
        OS.gtk_tree_path_up (path);
        GtkTreeIter iter;
        if (OS.gtk_tree_model_get_iter (parent.modelHandle, &iter, path)) {
            item = parent._getItem (&iter);
        }
    }
    OS.gtk_tree_path_free (path);
    return item;
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
 *
 * @since 3.1
 */
public String getText (int index) {
    checkWidget ();
    if (!parent.checkData (this)) error (SWT.ERROR_WIDGET_DISPOSED);
    return _getText (index);
}

/**
 * Returns a rectangle describing the size and location
 * relative to its parent of the text at a column in the
 * tree.
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
    if ((parent.getStyle () & SWT.MIRRORED) !is 0) rect.x = parent.getClientWidth () - rect.width - rect.x;
    int right = rect.x + rect.width;

    int x, w;
    parent.ignoreSize = true;
    OS.gtk_cell_renderer_get_size (textRenderer, parentHandle, null, null, null, &w, null);
    parent.ignoreSize = false;
    int buffer;
    if (OS.GTK_VERSION < OS.buildVERSION (2, 8, 18) && OS.gtk_tree_view_get_expander_column (parentHandle) is column) {
        OS.gtk_widget_style_get1 (parentHandle, OS.expander_size.ptr, &buffer);
        rect.x += buffer + TreeItem.EXPANDER_EXTRA_PADDING;
    }
    /*
    * Bug in GTK. In GTK 2.8.x, the cell area is left aligned even
    * when the widget is mirrored. The fix is to sum up the indentation
    * of the expanders.
    */
    if ((parent.getStyle () & SWT.MIRRORED) !is 0 && (OS.GTK_VERSION < OS.buildVERSION (2, 10, 0))) {
        int depth = OS.gtk_tree_path_get_depth (path);
        int expanderSize;
        OS.gtk_widget_style_get1 (parentHandle, OS.expander_size.ptr, &expanderSize);
        rect.x += depth * (expanderSize + TreeItem.EXPANDER_EXTRA_PADDING);
    }
    OS.gtk_tree_path_free (path);

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
    checkWidget();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);
    int index = -1;
    bool isParent = false;
    auto currentPath = OS.gtk_tree_model_get_path (parent.modelHandle, handle);
    auto parentPath = OS.gtk_tree_model_get_path (parent.modelHandle, item.handle);
    int depth = OS.gtk_tree_path_get_depth (parentPath);
    if (depth > 1 && OS.gtk_tree_path_up(parentPath)) {
        if (OS.gtk_tree_path_compare(currentPath, parentPath) is 0) isParent = true;
    }
    OS.gtk_tree_path_free (currentPath);
    OS.gtk_tree_path_free (parentPath);
    if (!isParent) return index;
    auto path = OS.gtk_tree_model_get_path (parent.modelHandle, item.handle);
    if (depth > 1) {
        auto indices = OS.gtk_tree_path_get_indices (path);
        if (indices !is null) {
            int[] temp = indices[ 0 .. depth];
            index = temp[temp.length - 1];
        }
    }
    OS.gtk_tree_path_free (path);
    return index;
}

void redraw () {
    auto parentHandle = parent.handle;
    if ((OS.GTK_WIDGET_FLAGS (parentHandle) & OS.GTK_REALIZED) !is 0) {
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

override void releaseChildren (bool destroy) {
    if (destroy) {
        parent.releaseItems (cast(GtkTreeIter*)handle);
    }
    super.releaseChildren (destroy);
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
 * Removes all of the items from the receiver.
 * <p>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void removeAll () {
    checkWidget ();
    int length = OS.gtk_tree_model_iter_n_children (parent.modelHandle, handle);
    if (length is 0) return;
    GtkTreeIter iter;
    int index;
    while (OS.gtk_tree_model_iter_children (parent.modelHandle, &iter, handle)) {
        OS.gtk_tree_model_get1 (parent.modelHandle, &iter, Tree.ID_COLUMN, cast(void**)&index);
        if (index !is -1) {
            TreeItem item = parent.items [index];
            if (item !is null && !item.isDisposed ()) {
                item.dispose ();
            }
        }
    }
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
 *
 */
public void setBackground (Color color) {
    checkWidget ();
    if (color !is null && color.isDisposed ()) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    if (_getBackground ().opEquals (color)) return;
    GdkColor* gdkColor = color !is null ? color.handle : null;
    OS.gtk_tree_store_set1 (parent.modelHandle, cast(GtkTreeIter*)handle, Tree.BACKGROUND_COLUMN, gdkColor);
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
 * @since 3.1
 *
 */
public void setBackground (int index, Color color) {
    checkWidget ();
    if (color !is null && color.isDisposed ()) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    if (_getBackground (index).opEquals (color)) return;
    int count = Math.max (1, parent.getColumnCount ());
    if (0 > index || index > count - 1) return;
    int modelIndex = parent.columnCount is 0 ? Tree.FIRST_COLUMN : parent.columns [index].modelIndex;
    GdkColor* gdkColor = color !is null ? color.handle : null;
    OS.gtk_tree_store_set1 (parent.modelHandle, cast(GtkTreeIter*)handle, modelIndex + Tree.CELL_BACKGROUND, gdkColor);
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
                display.doCellDataProc( parentHandle, cast(GtkTreeViewColumn*)column, cast(GtkCellRenderer*)textRenderer );
                display.doCellDataProc( parentHandle, cast(GtkTreeViewColumn*)column, cast(GtkCellRenderer*)imageRenderer );
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
 * Sets the checked state of the receiver.
 * <p>
 *
 * @param checked the new checked state
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
    OS.gtk_tree_store_set1 (parent.modelHandle, cast(GtkTreeIter*)handle, Tree.CHECKED_COLUMN, cast(void*)cast(int)checked);
    /*
    * GTK+'s "inconsistent" state does not match SWT's concept of grayed.  To
    * show checked+grayed differently from unchecked+grayed, we must toggle the
    * grayed state on check and uncheck.
    */
    OS.gtk_tree_store_set1 (parent.modelHandle, cast(GtkTreeIter*)handle, Tree.GRAYED_COLUMN, cast(void*)cast(int)( !checked ? false : grayed));
    cached = true;
}

/**
 * Sets the expanded state of the receiver.
 * <p>
 *
 * @param expanded the new expanded state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setExpanded (bool expanded) {
    checkWidget();
    auto path = OS.gtk_tree_model_get_path (parent.modelHandle, handle);
    if (expanded) {
        OS.g_signal_handlers_block_matched (parent.handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udTEST_EXPAND_ROW);
        OS.gtk_tree_view_expand_row (parent.handle, path, false);
        OS.g_signal_handlers_unblock_matched (parent.handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udTEST_EXPAND_ROW);
    } else {
        OS.g_signal_handlers_block_matched (parent.handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udTEST_COLLAPSE_ROW);
        OS.gtk_widget_realize (parent.handle);
        OS.gtk_tree_view_collapse_row (parent.handle, path);
        OS.g_signal_handlers_unblock_matched (parent.handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udTEST_COLLAPSE_ROW);
    }
    OS.gtk_tree_path_free (path);
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
    void* fontHandle = font !is null ? font.handle : null;
    OS.gtk_tree_store_set1 (parent.modelHandle, cast(GtkTreeIter*)handle, Tree.FONT_COLUMN, fontHandle);
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
 * @since 3.1
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

    int modelIndex = parent.columnCount is 0 ? Tree.FIRST_COLUMN : parent.columns [index].modelIndex;
    auto fontHandle  = font !is null ? font.handle : null;
    OS.gtk_tree_store_set1 (parent.modelHandle, cast(GtkTreeIter*)handle, modelIndex + Tree.CELL_FONT, fontHandle);
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
                display.doCellDataProc( parentHandle, cast(GtkTreeViewColumn*)column, cast(GtkCellRenderer*)textRenderer );
                display.doCellDataProc( parentHandle, cast(GtkTreeViewColumn*)column, cast(GtkCellRenderer*)imageRenderer );
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
 * @since 2.0
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
 *
 */
public void setForeground (Color color){
    checkWidget ();
    if (color !is null && color.isDisposed ()) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    if (_getForeground ().opEquals (color)) return;
    GdkColor *gdkColor = color !is null ? color.handle : null;
    OS.gtk_tree_store_set1 (parent.modelHandle, cast(GtkTreeIter*)handle, Tree.FOREGROUND_COLUMN, gdkColor);
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
 * @since 3.1
 *
 */
public void setForeground (int index, Color color){
    checkWidget ();
    if (color !is null && color.isDisposed ()) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    if (_getForeground (index).opEquals (color)) return;
    int count = Math.max (1, parent.getColumnCount ());
    if (0 > index || index > count - 1) return;
    int modelIndex = parent.columnCount is 0 ? Tree.FIRST_COLUMN : parent.columns [index].modelIndex;
    GdkColor *gdkColor = color !is null ? color.handle : null;
    OS.gtk_tree_store_set1 (parent.modelHandle, cast(GtkTreeIter*)handle, modelIndex + Tree.CELL_FOREGROUND, gdkColor);
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
                display.doCellDataProc( parentHandle, cast(GtkTreeViewColumn*)column, cast(GtkCellRenderer*)textRenderer );
                display.doCellDataProc( parentHandle, cast(GtkTreeViewColumn*)column, cast(GtkCellRenderer*)imageRenderer );
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
 * only applies if the Tree was created with the SWT.CHECK style.
 *
 * @param grayed the new grayed state of the checkbox
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
    OS.gtk_tree_model_get1 (parent.modelHandle, handle, Tree.CHECKED_COLUMN, &ptr);
    OS.gtk_tree_store_set1 (parent.modelHandle, cast(GtkTreeIter*)handle, Tree.GRAYED_COLUMN, cast(void*)cast(int)( ptr is null ? false : grayed));
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
 *
 * @since 3.1
 */
public void setImage (int index, Image image) {
    checkWidget ();
    if (image !is null && image.isDisposed()) {
        error(SWT.ERROR_INVALID_ARGUMENT);
    }
    if (image !is null && image.type is SWT.ICON) {
        if (image.opEquals (_getImage (index))) return;
    }
    int count = Math.max (1, parent.getColumnCount ());
    if (0 > index || index > count - 1) return;
    GdkPixbuf* pixbuf;
    if (image !is null) {
        ImageList imageList = parent.imageList;
        if (imageList is null) imageList = parent.imageList = new ImageList ();
        int imageIndex = imageList.indexOf (image);
        if (imageIndex is -1) imageIndex = imageList.add (image);
        pixbuf = imageList.getPixbuf (imageIndex);
    }
    int modelIndex = parent.columnCount is 0 ? Tree.FIRST_COLUMN : parent.columns [index].modelIndex;
    OS.gtk_tree_store_set1 (parent.modelHandle, cast(GtkTreeIter*)handle, modelIndex + Tree.CELL_PIXBUF, pixbuf);
    /*
    * Bug in GTK.  When using fixed-height-mode,
    * row changes do not cause the row to be repainted.  The fix is to
    * invalidate the row when the image changes.
    */
    if ((parent.style & SWT.VIRTUAL) !is 0) {
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 3, 2) && OS.GTK_VERSION < OS.buildVERSION (2, 6, 3)) {
            if (parent.columnCount is 0) {
                redraw ();
            }
        }
    }
    /*
    * Bug in GTK.  When using fixed-height-mode, GTK does not recalculate the cell renderer width
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
 * Sets the image for multiple columns in the tree.
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
 *
 * @since 3.1
 */
public void setImage (Image [] images) {
    checkWidget ();
    // SWT extension: allow null for zero length string
    //if (images is null) error (SWT.ERROR_NULL_ARGUMENT);
    for (int i=0; i<images.length; i++) {
        setImage (i, images [i]);
    }
}

/**
 * Sets the number of child items contained in the receiver.
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
    parent.setItemCount (cast(GtkTreeIter*)handle, count);
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
 *
 * @since 3.1
 */
public void setText (int index, String string) {
    checkWidget ();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (_getText (index).equals (string)) return;
    int count = Math.max (1, parent.getColumnCount ());
    if (0 > index || index > count - 1) return;
    char* buffer = toStringz(string);
    int modelIndex = parent.columnCount is 0 ? Tree.FIRST_COLUMN : parent.columns [index].modelIndex;
    OS.gtk_tree_store_set1 (parent.modelHandle, cast(GtkTreeIter*)handle, modelIndex + Tree.CELL_TEXT, buffer);
    /*
    * Bug in GTK.  When using fixed-height-mode,
    * row changes do not cause the row to be repainted.  The fix is to
    * invalidate the row when the text changes.
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
 * Sets the text for multiple columns in the tree.
 *
 * @param strings the array of new strings
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void setText (String [] strings) {
    checkWidget ();
    // SWT extension: allow null for zero length string
    //if (strings is null) error (SWT.ERROR_NULL_ARGUMENT);
    for (int i=0; i<strings.length; i++) {
        String string = strings [i];
        if (string !is null) setText (i, string);
    }
}
}
