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

import org.eclipse.swt.graphics.Color;

import org.eclipse.swt.graphics.Font;

import org.eclipse.swt.graphics.GC;

import org.eclipse.swt.graphics.Image;

import org.eclipse.swt.graphics.Point;

import org.eclipse.swt.graphics.Rectangle;

import org.eclipse.swt.internal.gtk.OS;

import org.eclipse.swt.widgets.TreeItem;

import org.eclipse.swt.widgets.TreeColumn;

import org.eclipse.swt.widgets.Composite;

import org.eclipse.swt.widgets.ImageList;

import org.eclipse.swt.widgets.Listener;

import org.eclipse.swt.widgets.Shell;

import org.eclipse.swt.widgets.Decorations;

import org.eclipse.swt.widgets.Menu;

import org.eclipse.swt.widgets.ScrollBar;

import org.eclipse.swt.widgets.Control;

import org.eclipse.swt.widgets.Display;

import org.eclipse.swt.widgets.Event;

import org.eclipse.swt.widgets.TypedListener;

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

    alias Composite.createHandle createHandle;

    alias Composite.dragDetect dragDetect;

    alias Composite.mnemonicHit mnemonicHit;

    alias Composite.mnemonicMatch mnemonicMatch;

    alias Composite.setBackgroundColor setBackgroundColor;

    alias Composite.setBounds setBounds;



    CallbackData treeSelectionCallbackData;

    GtkTreeStore* modelHandle;

    GtkCellRenderer* checkRenderer;

    int columnCount, sortDirection;

    GtkWidget* ignoreCell;

    TreeItem[] items;

    TreeColumn [] columns;

    TreeColumn sortColumn;

    TreeItem currentItem;

    ImageList imageList, headerImageList;

    bool firstCustomDraw;

    bool modelChanged;

    bool expandAll;

    int drawState, drawFlags;

    GdkColor* drawForeground;

    bool ownerDraw, ignoreSize;



    static const int ID_COLUMN = 0;

    static const int CHECKED_COLUMN = 1;

    static const int GRAYED_COLUMN = 2;

    static const int FOREGROUND_COLUMN = 3;

    static const int BACKGROUND_COLUMN = 4;

    static const int FONT_COLUMN = 5;

    static const int FIRST_COLUMN = FONT_COLUMN + 1;

    static const int CELL_PIXBUF = 0;

    static const int CELL_TEXT = 1;

    static const int CELL_FOREGROUND = 2;

    static const int CELL_BACKGROUND = 3;

    static const int CELL_FONT = 4;

    static const int CELL_TYPES = CELL_FONT + 1;



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

    super (parent, checkStyle (style));

}



override void _addListener (int eventType, Listener listener) {

    super._addListener (eventType, listener);

    if (!ownerDraw) {

        switch (eventType) {

            case SWT.MeasureItem:

            case SWT.EraseItem:

            case SWT.PaintItem:

                ownerDraw = true;

                recreateRenderers ();

                break;

            default:

        }

    }

}



TreeItem _getItem (GtkTreeIter* iter) {

    int id = getId (iter, true);

    if (items [id] !is null) return items [id];

    auto path = OS.gtk_tree_model_get_path (modelHandle, iter);

    int depth = OS.gtk_tree_path_get_depth (path);

    int [] indices = new int [depth];

    indices[] = OS.gtk_tree_path_get_indices (path)[ 0 .. depth ];

    GtkTreeIter* parentIter;

    GtkTreeIter parentIterInst;

    if (depth > 1) {

        OS.gtk_tree_path_up (path);

        parentIter = &parentIterInst;

        OS.gtk_tree_model_get_iter (modelHandle, parentIter, path);

    }

    items [id] = new TreeItem (this, parentIter, SWT.NONE, indices [indices.length -1], false);

    OS.gtk_tree_path_free (path);

    return items [id];

}



TreeItem _getItem (GtkTreeIter* parentIter, int index) {

    GtkTreeIter iter;

    OS.gtk_tree_model_iter_nth_child(modelHandle, &iter, parentIter, index);

    int id = getId (&iter, true);

    if (items [id] !is null) return items [id];

    return items [id] = new TreeItem (this, parentIter, SWT.NONE, index, false);

}



int getId (GtkTreeIter* iter, bool queryModel) {

    if (queryModel) {

        int value;

        OS.gtk_tree_model_get1 (modelHandle, iter, ID_COLUMN, cast(void**)&value);

        if (value  !is -1) return value ;

    }

    // find next available id

    int id = 0;

    while (id < items.length && items [id] !is null) id++;

    if (id is items.length) {

        TreeItem [] newItems = new TreeItem [items.length + 4];

        System.arraycopy (items, 0, newItems, 0, items.length);

        items = newItems;

    }

    OS.gtk_tree_store_set1 (modelHandle, iter, ID_COLUMN, cast(void*)id );

    return id;

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

    /* GTK is always FULL_SELECTION */

    style |= SWT.FULL_SELECTION;

    return checkBits (style, SWT.SINGLE, SWT.MULTI, 0, 0, 0, 0);

}



override void cellDataProc (

    GtkTreeViewColumn *tree_column,

    GtkCellRenderer *cell,

    GtkTreeModel *tree_model,

    GtkTreeIter *iter,

    void* data)

{

    if (cell is cast(GtkCellRenderer*)ignoreCell) return;

    TreeItem item = _getItem (iter);

    if (item !is null) OS.g_object_set_qdata (cast(GObject*)cell, Display.SWT_OBJECT_INDEX2, item.handle);

    bool isPixbuf = OS.GTK_IS_CELL_RENDERER_PIXBUF (cell);

    if (!(isPixbuf || OS.GTK_IS_CELL_RENDERER_TEXT (cell))) return;

    int modelIndex = -1;

    bool customDraw = false;

    if (columnCount is 0) {

        modelIndex = Tree.FIRST_COLUMN;

        customDraw = firstCustomDraw;

    } else {

        TreeColumn column = cast(TreeColumn) display.getWidget (cast(GtkWidget*)tree_column);

        if (column !is null) {

            modelIndex = column.modelIndex;

            customDraw = column.customDraw;

        }

    }

    if (modelIndex is -1) return;

    bool setData = false;

    if ((style & SWT.VIRTUAL) !is 0) {

        /*

        * Feature in GTK.  On GTK before 2.4, fixed_height_mode is not

        * supported, and the tree asks for the data of all items.  The

        * fix is to only provide the data if the row is visible.

        */

        if (OS.GTK_VERSION < OS.buildVERSION (2, 3, 2)) {

            auto path = OS.gtk_tree_model_get_path (tree_model, iter);

            OS.gtk_widget_realize (handle);

            GdkRectangle visible;

            OS.gtk_tree_view_get_visible_rect (handle, &visible);

            GdkRectangle area;

            OS.gtk_tree_view_get_cell_area (handle, path, tree_column, &area);

            OS.gtk_tree_path_free (path);

            if (area.y + area.height < 0 || area.y + visible.y > visible.y + visible.height ) {

                /* Give an image from the image list to make sure the row has

                * the correct height.

                */

                if (imageList !is null && imageList.pixbufs.length > 0) {

                    if (isPixbuf) OS.g_object_set1 (cell, OS.pixbuf.ptr, cast(ptrdiff_t)imageList.pixbufs [0]);

                }

                return;

            }

        }

        if (!item.cached) {

            //lastIndexOf = index [0];

            setData = checkData (item);

        }

    }

    void* ptr;

    if (setData) {

        if (isPixbuf) {

            ptr = null;

            OS.gtk_tree_model_get1 (tree_model, iter, modelIndex + CELL_PIXBUF, &ptr);

            OS.g_object_set1 (cell, OS.pixbuf.ptr, cast(ptrdiff_t)ptr);

        } else {

            ptr = null;

            OS.gtk_tree_model_get1 (tree_model, iter, modelIndex + CELL_TEXT, &ptr);

            if (ptr !is null) {

                OS.g_object_set1 (cell, OS.text.ptr, cast(ptrdiff_t)ptr);

                OS.g_free (ptr);

            }

        }

    }

    if (customDraw) {

        /*

         * Bug on GTK. Gtk renders the background on top of the checkbox and pixbuf.

         * This only happens in version 2.2.1 and earlier. The fix is not to set the background.

         */

        if (OS.GTK_VERSION > OS.buildVERSION (2, 2, 1)) {

            if (!ownerDraw) {

                ptr = null;

                OS.gtk_tree_model_get1 (tree_model, iter, modelIndex + CELL_BACKGROUND, &ptr);

                if (ptr !is null) {

                    OS.g_object_set1 (cell, OS.cell_background_gdk.ptr, cast(ptrdiff_t)ptr);

                }

            }

        }

        if (!isPixbuf) {

            ptr = null;

            OS.gtk_tree_model_get1 (tree_model, iter, modelIndex + CELL_FOREGROUND, &ptr);

            if (ptr !is null) {

                OS.g_object_set1 (cell, OS.foreground_gdk.ptr, cast(ptrdiff_t)ptr);

            }

            ptr = null;

            OS.gtk_tree_model_get1 (tree_model, iter, modelIndex + CELL_FONT, &ptr);

            if (ptr !is null) {

                OS.g_object_set1 (cell, OS.font_desc.ptr, cast(ptrdiff_t)ptr);

            }

        }

    }

    if (setData) {

        ignoreCell = cast(GtkWidget*)cell;

        setScrollWidth (tree_column, item);

        ignoreCell = null;

    }

}



bool checkData (TreeItem item) {

    if (item.cached) return true;

    if ((style & SWT.VIRTUAL) !is 0) {

        item.cached = true;

        TreeItem parentItem = item.getParentItem ();

        Event event = new Event ();

        event.item = item;

        event.index = parentItem is null ? indexOf (item) : parentItem.indexOf (item);

        int mask = OS.G_SIGNAL_MATCH_DATA | OS.G_SIGNAL_MATCH_ID;

        int signal_id = OS.g_signal_lookup (OS.row_changed.ptr, OS.gtk_tree_model_get_type ());

        OS.g_signal_handlers_block_matched (modelHandle, mask, signal_id, 0, null, null, handle);

        currentItem = item;

        sendEvent (SWT.SetData, event);

        currentItem = null;

        //widget could be disposed at this point

        if (isDisposed ()) return false;

        OS.g_signal_handlers_unblock_matched (modelHandle, mask, signal_id, 0, null, null, handle);

        if (item.isDisposed ()) return false;

    }

    return true;

}



protected override void checkSubclass () {

    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);

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



int calculateWidth (GtkTreeViewColumn *column, GtkTreeIter* iter, bool recurse) {

    OS.gtk_tree_view_column_cell_set_cell_data (column, modelHandle, iter, false, false);

    /*

    * Bug in GTK.  The width calculated by gtk_tree_view_column_cell_get_size()

    * always grows in size regardless of the text or images in the table.

    * The fix is to determine the column width from the cell renderers.

    */

    // Code intentionally commented

    //int [] width = new int [1];

    //OS.gtk_tree_view_column_cell_get_size (column, null, null, null, width, null);

    //return width [0];



    int width = 0;

    int w;

    GtkTreePath* path = null;



    if (OS.gtk_tree_view_get_expander_column (handle) is column) {

        /* indent */

        GdkRectangle rect;

        OS.gtk_widget_realize (handle);

        path = OS.gtk_tree_model_get_path (modelHandle, iter);

        OS.gtk_tree_view_get_cell_area (handle, path, column, &rect);

        width += rect.x;

        /* expander */

        OS.gtk_widget_style_get1 (handle, OS.expander_size.ptr, &w);

        width += w  + TreeItem.EXPANDER_EXTRA_PADDING;

    }

    OS.gtk_widget_style_get1(handle, OS.focus_line_width.ptr, &w);

    width += 2 * w ;

    auto list = OS.gtk_tree_view_column_get_cell_renderers (column);

    if (list is null) return 0;

    auto temp = list;

    while (temp !is null) {

        auto renderer = OS.g_list_data (temp);

        if (renderer !is null) {

            OS.gtk_cell_renderer_get_size (renderer, handle, null, null, null, &w, null);

            width += w ;

        }

        temp = OS.g_list_next (temp);

    }

    OS.g_list_free (list);



    if (recurse) {

        if (path is null) path = OS.gtk_tree_model_get_path (modelHandle, iter);

        bool expanded = OS.gtk_tree_view_row_expanded (handle, path) !is 0;

        if (expanded) {

            GtkTreeIter childIter;

            bool valid = OS.gtk_tree_model_iter_children (modelHandle, &childIter, iter) !is 0;

            while (valid) {

                width = Math.max (width, calculateWidth (column, &childIter, true));

                valid = OS.gtk_tree_model_iter_next (modelHandle, &childIter) !is 0;

            }

        }

    }



    if (path !is null) OS.gtk_tree_path_free (path);

    return width;

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

public void clear(int index, bool all) {

    checkWidget ();

    clear (null, index, all);

}



void clear (GtkTreeIter* parentIter, int index, bool all) {

    GtkTreeIter iter;

    OS.gtk_tree_model_iter_nth_child(modelHandle, &iter, parentIter, index);

    int value;

    OS.gtk_tree_model_get1 (modelHandle, &iter, ID_COLUMN, cast(void**)&value);

    if (value  !is -1) {

        TreeItem item = items [value ];

        item.clear ();

    }

    if (all) clearAll (all, &iter);

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

    clearAll (all, null);

}

void clearAll (bool all, GtkTreeIter* parentIter) {

    int length = OS.gtk_tree_model_iter_n_children (modelHandle, parentIter);

    if (length is 0) return;

    GtkTreeIter iter;

    bool valid = cast(bool)OS.gtk_tree_model_iter_children (modelHandle, &iter, parentIter);

    int value;

    while (valid) {

        OS.gtk_tree_model_get1 (modelHandle, &iter, ID_COLUMN, cast(void**)&value);

        if (value  !is -1) {

            TreeItem item = items [value ];

            item.clear ();

        }

        if (all) clearAll (all, &iter);

        valid = cast(bool)OS.gtk_tree_model_iter_next (modelHandle, &iter);

    }

}



public override Point computeSize (int wHint, int hHint, bool changed) {

    checkWidget ();

    if (wHint !is SWT.DEFAULT && wHint < 0) wHint = 0;

    if (hHint !is SWT.DEFAULT && hHint < 0) hHint = 0;

    Point size = computeNativeSize (handle, wHint, hHint, changed);

    Rectangle trim = computeTrim (0, 0, size.x, size.y);

    size.x = trim.width;

    size.y = trim.height;

    return size;

}



void copyModel (void* oldModel, int oldStart, void* newModel, int newStart, size_t [] types, void* oldParent, void* newParent, int modelLength) {

    GtkTreeIter iter;

    if (OS.gtk_tree_model_iter_children (oldModel, &iter, oldParent))  {

        GtkTreeIter*[] oldItems = new GtkTreeIter*[]( OS.gtk_tree_model_iter_n_children (oldModel, oldParent));

        int oldIndex = 0;

        do {

            GtkTreeIter* newItem = cast(GtkTreeIter*)OS.g_malloc (GtkTreeIter.sizeof);

            if (newItem is null) error (SWT.ERROR_NO_HANDLES);

            OS.gtk_tree_store_append (newModel, newItem, newParent);

            int index;

            OS.gtk_tree_model_get1 (oldModel, &iter, ID_COLUMN, cast(void**)&index);

            TreeItem item = null;

            if (index  !is -1) {

                item = items [index ];

                if (item !is null) {

                    auto oldItem = cast(GtkTreeIter*)item.handle;

                    oldItems[oldIndex++] = oldItem;

                    void* ptr;

                    for (int j = 0; j < FIRST_COLUMN; j++) {

                        OS.gtk_tree_model_get1 (oldModel, oldItem, j, &ptr);

                        OS.gtk_tree_store_set1 (newModel, newItem, j, ptr );

                        if (types [j] is OS.G_TYPE_STRING ()) OS.g_free ((ptr ));

                    }

                    for (int j= 0; j<modelLength - FIRST_COLUMN; j++) {

                        OS.gtk_tree_model_get1 (oldModel, oldItem, oldStart + j, &ptr);

                        OS.gtk_tree_store_set1 (newModel, newItem, newStart + j, ptr );

                        if (types [j] is OS.G_TYPE_STRING ()) OS.g_free ((ptr ));

                    }

                }

            } else {

                OS.gtk_tree_store_set1 (newModel, newItem, ID_COLUMN, cast(void*)-1 );

            }

            // recurse through children

            copyModel(oldModel, oldStart, newModel, newStart, types, &iter, newItem, modelLength);



            if (item!is null) {

                item.handle = cast(GtkWidget*)newItem;

            } else {

                OS.g_free (newItem);

            }

        } while (OS.gtk_tree_model_iter_next(oldModel, &iter));

        for (int i = 0; i < oldItems.length; i++) {

            auto oldItem = oldItems [i];

            if (oldItem !is null) {

                OS.gtk_tree_store_remove (oldModel, oldItem);

                OS.g_free (oldItem);

            }

        }

    }

}



void createColumn (TreeColumn column, int index) {

/*

* Bug in ATK. For some reason, ATK segments fault if

* the GtkTreeView has a column and does not have items.

* The fix is to insert the column only when an item is

* created.

*/



    int modelIndex = FIRST_COLUMN;

    if (columnCount !is 0) {

        int modelLength = OS.gtk_tree_model_get_n_columns (modelHandle);

        bool [] usedColumns = new bool [modelLength];

        for (int i=0; i<columnCount; i++) {

            int columnIndex = columns [i].modelIndex;

            for (int j = 0; j < CELL_TYPES; j++) {

                usedColumns [columnIndex + j] = true;

            }

        }

        while (modelIndex < modelLength) {

            if (!usedColumns [modelIndex]) break;

            modelIndex++;

        }

        if (modelIndex is modelLength) {

            auto oldModel = modelHandle;

            size_t[] types = getColumnTypes (columnCount + 4); // grow by 4 rows at a time

            auto newModel = OS.gtk_tree_store_newv (cast(int)/*64bit*/types.length, types.ptr);

            if (newModel is null) error (SWT.ERROR_NO_HANDLES);

            copyModel (oldModel, FIRST_COLUMN, newModel, FIRST_COLUMN, types, null, null, modelLength);

            OS.gtk_tree_view_set_model (handle, newModel);

            OS.g_object_unref (oldModel);

            modelHandle = newModel;

        }

    }

    auto columnHandle = OS.gtk_tree_view_column_new ();

    if (columnHandle is null) error (SWT.ERROR_NO_HANDLES);

    if (index is 0 && columnCount > 0) {

        TreeColumn checkColumn = columns [0];

        createRenderers (cast(GtkTreeViewColumn *)checkColumn.handle, checkColumn.modelIndex, false, checkColumn.style);

    }

    createRenderers (columnHandle, modelIndex, index is 0, column is null ? 0 : column.style);

    /*

    * Use GTK_TREE_VIEW_COLUMN_GROW_ONLY on GTK versions < 2.3.2

    * because fixed_height_mode is not supported.

    */

    bool useVirtual = (style & SWT.VIRTUAL) !is 0 && OS.GTK_VERSION >= OS.buildVERSION (2, 3, 2);

    if (!useVirtual && columnCount is 0) {

        OS.gtk_tree_view_column_set_sizing (columnHandle, OS.GTK_TREE_VIEW_COLUMN_GROW_ONLY);

    } else {

        OS.gtk_tree_view_column_set_sizing (columnHandle, OS.GTK_TREE_VIEW_COLUMN_FIXED);

        if (columnCount !is 0) OS.gtk_tree_view_column_set_visible (columnHandle, false);

    }

    OS.gtk_tree_view_column_set_resizable (columnHandle, true);

    OS.gtk_tree_view_column_set_clickable (columnHandle, true);

    OS.gtk_tree_view_column_set_min_width (columnHandle, 0);

    OS.gtk_tree_view_insert_column (handle, columnHandle, index);

    if (column !is null) {

        column.handle = cast(GtkWidget*)columnHandle;

        column.modelIndex = modelIndex;

    }

    /* Disable searching when using VIRTUAL */

    if ((style & SWT.VIRTUAL) !is 0) {

        /*

        * Bug in GTK. Until GTK 2.6.5, calling gtk_tree_view_set_enable_search(FALSE)

        * would prevent the user from being able to type in text to search the tree.

        * After 2.6.5, GTK introduced Ctrl+F as being the key binding for interactive

        * search. This meant that even if FALSE was passed to enable_search, the user

        * can still bring up the search pop up using the keybinding. GTK also introduced

        * the notion of passing a -1 to gtk_set_search_column to disable searching

        * (including the search key binding).  The fix is to use the right calls

        * for the right version.

        */

        if (OS.GTK_VERSION >= OS.buildVERSION (2, 6, 5)) {

            OS.gtk_tree_view_set_search_column (handle, -1);

        } else {

            OS.gtk_tree_view_set_enable_search (handle, false);

        }

    } else {

        /* Set the search column whenever the model changes */

        int firstColumn = columnCount is 0 ? FIRST_COLUMN : columns [0].modelIndex;

        OS.gtk_tree_view_set_search_column (handle, firstColumn + CELL_TEXT);

    }

}



override void createHandle (int index) {

    state |= HANDLE;

    fixedHandle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);

    if (fixedHandle is null) error (SWT.ERROR_NO_HANDLES);

    OS.gtk_fixed_set_has_window (fixedHandle, true);

    scrolledHandle = cast(GtkWidget*)OS.gtk_scrolled_window_new (null, null);

    if (scrolledHandle is null) error (SWT.ERROR_NO_HANDLES);

    size_t[] types = getColumnTypes (1);

    modelHandle = cast(GtkTreeStore*)OS.gtk_tree_store_newv (cast(int)/*64bit*/types.length, types.ptr);

    if (modelHandle is null) error (SWT.ERROR_NO_HANDLES);

    handle = cast(GtkWidget*)OS.gtk_tree_view_new_with_model (modelHandle);

    if (handle is null) error (SWT.ERROR_NO_HANDLES);

    if ((style & SWT.CHECK) !is 0) {

        checkRenderer = cast(GtkCellRenderer*)OS.gtk_cell_renderer_toggle_new ();

        if (checkRenderer is null) error (SWT.ERROR_NO_HANDLES);

        OS.g_object_ref (checkRenderer);

    }

    createColumn (null, 0);

    OS.gtk_container_add (fixedHandle, scrolledHandle);

    OS.gtk_container_add (scrolledHandle, handle);



    int mode = (style & SWT.MULTI) !is 0 ? OS.GTK_SELECTION_MULTIPLE : OS.GTK_SELECTION_BROWSE;

    auto selectionHandle = OS.gtk_tree_view_get_selection (handle);

    OS.gtk_tree_selection_set_mode (selectionHandle, mode);

    OS.gtk_tree_view_set_headers_visible (handle, false);

    int hsp = (style & SWT.H_SCROLL) !is 0 ? OS.GTK_POLICY_AUTOMATIC : OS.GTK_POLICY_NEVER;

    int vsp = (style & SWT.V_SCROLL) !is 0 ? OS.GTK_POLICY_AUTOMATIC : OS.GTK_POLICY_NEVER;

    OS.gtk_scrolled_window_set_policy (scrolledHandle, hsp, vsp);

    if ((style & SWT.BORDER) !is 0) OS.gtk_scrolled_window_set_shadow_type (scrolledHandle, OS.GTK_SHADOW_ETCHED_IN);

    /* Disable searching when using VIRTUAL */

    if ((style & SWT.VIRTUAL) !is 0) {

        /* The fixed_height_mode property only exists in GTK 2.3.2 and greater */

        if (OS.GTK_VERSION >= OS.buildVERSION (2, 3, 2)) {

            OS.g_object_set1 (handle, OS.fixed_height_mode.ptr, true);

        }

        /*

        * Bug in GTK. Until GTK 2.6.5, calling gtk_tree_view_set_enable_search(FALSE)

        * would prevent the user from being able to type in text to search the tree.

        * After 2.6.5, GTK introduced Ctrl+F as being the key binding for interactive

        * search. This meant that even if FALSE was passed to enable_search, the user

        * can still bring up the search pop up using the keybinding. GTK also introduced

        * the notion of passing a -1 to gtk_set_search_column to disable searching

        * (including the search key binding).  The fix is to use the right calls

        * for the right version.

        */

        if (OS.GTK_VERSION >= OS.buildVERSION (2, 6, 5)) {

            OS.gtk_tree_view_set_search_column (handle, -1);

        } else {

            OS.gtk_tree_view_set_enable_search (handle, false);

        }

    }

}



void createItem (TreeColumn column, int index) {

    if (!(0 <= index && index <= columnCount)) error (SWT.ERROR_INVALID_RANGE);

    if (index is 0) {

        // first column must be left aligned

        column.style &= ~(SWT.LEFT | SWT.RIGHT | SWT.CENTER);

        column.style |= SWT.LEFT;

    }

    if (columnCount is 0) {

        column.handle = cast(GtkWidget*)OS.gtk_tree_view_get_column (handle, 0);

        OS.gtk_tree_view_column_set_sizing (column.handle, OS.GTK_TREE_VIEW_COLUMN_FIXED);

        OS.gtk_tree_view_column_set_visible (column.handle, false);

        column.modelIndex = FIRST_COLUMN;

        createRenderers (cast(GtkTreeViewColumn *)column.handle, column.modelIndex, true, column.style);

        column.customDraw = firstCustomDraw;

        firstCustomDraw = false;

    } else {

        createColumn (column, index);

    }

    auto boxHandle = OS.gtk_hbox_new (false, 3);

    if (boxHandle is null) error (SWT.ERROR_NO_HANDLES);

    auto labelHandle = OS.gtk_label_new_with_mnemonic (null);

    if (labelHandle is null) error (SWT.ERROR_NO_HANDLES);

    auto imageHandle = OS.gtk_image_new ();

    if (imageHandle is null) error (SWT.ERROR_NO_HANDLES);

    OS.gtk_container_add (boxHandle, imageHandle);

    OS.gtk_container_add (boxHandle, labelHandle);

    OS.gtk_widget_show (boxHandle);

    OS.gtk_widget_show (labelHandle);

    column.labelHandle = labelHandle;

    column.imageHandle = imageHandle;

    OS.gtk_tree_view_column_set_widget (column.handle, boxHandle);

    auto widget = OS.gtk_widget_get_parent (boxHandle);

    while (widget !is handle) {

        if (OS.GTK_IS_BUTTON (widget)) {

            column.buttonHandle = widget;

            break;

        }

        widget = OS.gtk_widget_get_parent (widget);

    }

    if (columnCount is columns.length) {

        TreeColumn [] newColumns = new TreeColumn [columns.length + 4];

        System.arraycopy (columns, 0, newColumns, 0, columns.length);

        columns = newColumns;

    }

    System.arraycopy (columns, index, columns, index + 1, columnCount++ - index);

    columns [index] = column;

    if ((state & FONT) !is 0) {

        column.setFontDescription (getFontDescription ());

    }

    if (columnCount >= 1) {

        for (int i=0; i<items.length; i++) {

            TreeItem item = items [i];

            if (item !is null) {

                Font [] cellFont = item.cellFont;

                if (cellFont !is null) {

                    Font [] temp = new Font [columnCount];

                    System.arraycopy (cellFont, 0, temp, 0, index);

                    System.arraycopy (cellFont, index, temp, index+1, columnCount-index-1);

                    item.cellFont = temp;

                }

            }

        }

    }

}



void createItem (TreeItem item, GtkTreeIter* parentIter, int index) {

    int count = OS.gtk_tree_model_iter_n_children (modelHandle, parentIter);

    if (index is -1) index = count;

    if (!(0 <= index && index <= count)) error (SWT.ERROR_INVALID_RANGE);

    item.handle = cast(GtkWidget*)OS.g_malloc (GtkTreeIter.sizeof);

    if (item.handle is null) error(SWT.ERROR_NO_HANDLES);

    /*

    * Feature in GTK.  It is much faster to append to a tree store

    * than to insert at the end using gtk_tree_store_insert().

    */

    if (index is count) {

        OS.gtk_tree_store_append (modelHandle, item.handle, parentIter);

    } else {

        OS.gtk_tree_store_insert (modelHandle, item.handle, parentIter, index);

    }

    int id = getId (cast(GtkTreeIter*) item.handle, false);

    items [id] = item;

    modelChanged = true;

}



void createRenderers (GtkTreeViewColumn* columnHandle, int modelIndex, bool check, int columnStyle) {

    OS.gtk_tree_view_column_clear (columnHandle);

    if ((style & SWT.CHECK) !is 0 && check) {

        OS.gtk_tree_view_column_pack_start (columnHandle, checkRenderer, false);

        OS.gtk_tree_view_column_add_attribute (columnHandle, checkRenderer, OS.active.ptr, CHECKED_COLUMN);

        /*

        * Feature in GTK. The inconsistent property only exists in GTK 2.2.x.

        */

        if (OS.GTK_VERSION >= OS.buildVERSION (2, 2, 0)) {

            OS.gtk_tree_view_column_add_attribute (columnHandle, checkRenderer, OS.inconsistent.ptr, GRAYED_COLUMN);

        }

        /*

        * Bug in GTK. GTK renders the background on top of the checkbox.

        * This only happens in version 2.2.1 and earlier. The fix is not to set the background.

        */

        if (OS.GTK_VERSION > OS.buildVERSION (2, 2, 1)) {

            if (!ownerDraw) OS.gtk_tree_view_column_add_attribute (columnHandle, checkRenderer, OS.cell_background_gdk.ptr, BACKGROUND_COLUMN);

        }

        if (ownerDraw) {

            display.doCellDataProc( handle, cast(GtkTreeViewColumn*)columnHandle, cast(GtkCellRenderer*)checkRenderer );

            OS.g_object_set_qdata (cast(GObject*)checkRenderer, Display.SWT_OBJECT_INDEX1, columnHandle);

        }

    }

    auto pixbufRenderer = ownerDraw ? cast(GtkCellRenderer*)OS.g_object_new (display.gtk_cell_renderer_pixbuf_get_type (), null) : OS.gtk_cell_renderer_pixbuf_new ();

    if (pixbufRenderer is null) error (SWT.ERROR_NO_HANDLES);

    auto textRenderer = ownerDraw ? cast(GtkCellRenderer*)OS.g_object_new (display.gtk_cell_renderer_text_get_type (), null) : OS.gtk_cell_renderer_text_new ();

    if (textRenderer is null) error (SWT.ERROR_NO_HANDLES);



    if (ownerDraw) {

        OS.g_object_set_qdata (cast(GObject*)pixbufRenderer, Display.SWT_OBJECT_INDEX1, columnHandle);

        OS.g_object_set_qdata (cast(GObject*)textRenderer, Display.SWT_OBJECT_INDEX1, columnHandle);

    }



    /*

    * Feature in GTK.  When a tree view column contains only one activatable

    * cell renderer such as a toggle renderer, mouse clicks anywhere in a cell

    * activate that renderer. The workaround is to set a second  cell renderer

    * to be activatable.

    */

    if ((style & SWT.CHECK) !is 0 && check) {

        OS.g_object_set1 (pixbufRenderer, OS.mode.ptr, OS.GTK_CELL_RENDERER_MODE_ACTIVATABLE);

    }



    /* Set alignment */

    if ((columnStyle & SWT.RIGHT) !is 0) {

        OS.g_object_set1_float(textRenderer, OS.xalign.ptr, 1.0f);

        OS.gtk_tree_view_column_pack_end (columnHandle, textRenderer, true);

        OS.gtk_tree_view_column_pack_end (columnHandle, pixbufRenderer, false);

        OS.gtk_tree_view_column_set_alignment (columnHandle, 1f);

    } else if ((columnStyle & SWT.CENTER) !is 0) {

        OS.g_object_set1_float(textRenderer, OS.xalign.ptr, 0.5f);

        OS.gtk_tree_view_column_pack_start (columnHandle, pixbufRenderer, false);

        OS.gtk_tree_view_column_pack_end (columnHandle, textRenderer, true);

        OS.gtk_tree_view_column_set_alignment (columnHandle, 0.5f);

    } else {

        OS.gtk_tree_view_column_pack_start (columnHandle, pixbufRenderer, false);

        OS.gtk_tree_view_column_pack_start (columnHandle, textRenderer, true);

        OS.gtk_tree_view_column_set_alignment (columnHandle, 0f);

    }



    /* Add attributes */

    OS.gtk_tree_view_column_add_attribute (columnHandle, pixbufRenderer, OS.pixbuf.ptr, modelIndex + CELL_PIXBUF);

    /*

     * Bug on GTK. Gtk renders the background on top of the pixbuf.

     * This only happens in version 2.2.1 and earlier. The fix is not to set the background.

     */

    if (OS.GTK_VERSION > OS.buildVERSION (2, 2, 1)) {

        if (!ownerDraw) {

            OS.gtk_tree_view_column_add_attribute (columnHandle, pixbufRenderer, OS.cell_background_gdk.ptr, BACKGROUND_COLUMN);

            OS.gtk_tree_view_column_add_attribute (columnHandle, textRenderer, OS.cell_background_gdk.ptr, BACKGROUND_COLUMN);

        }

    }

    OS.gtk_tree_view_column_add_attribute (columnHandle, textRenderer, OS.text.ptr, modelIndex + CELL_TEXT);

    OS.gtk_tree_view_column_add_attribute (columnHandle, textRenderer, OS.foreground_gdk.ptr, FOREGROUND_COLUMN);

    OS.gtk_tree_view_column_add_attribute (columnHandle, textRenderer, OS.font_desc.ptr, FONT_COLUMN);



    bool customDraw = firstCustomDraw;

    if (columnCount !is 0) {

        for (int i=0; i<columnCount; i++) {

            if (columns [i].handle is cast(GtkWidget*)columnHandle) {

                customDraw = columns [i].customDraw;

                break;

            }

        }

    }

    if ((style & SWT.VIRTUAL) !is 0 || customDraw || ownerDraw) {

        display.doCellDataProc( handle, cast(GtkTreeViewColumn*)columnHandle, cast(GtkCellRenderer*)textRenderer );

        display.doCellDataProc( handle, cast(GtkTreeViewColumn*)columnHandle, cast(GtkCellRenderer*)pixbufRenderer );

    }

}



override

void createWidget (int index) {

    super.createWidget (index);

    items = new TreeItem [4];

    columns = new TreeColumn [4];

    columnCount = 0;

}



GdkColor* defaultBackground () {

    return display.COLOR_LIST_BACKGROUND;

}



GdkColor* defaultForeground () {

    return display.COLOR_LIST_FOREGROUND;

}



override void deregister () {

    super.deregister ();

    display.removeWidget (cast(GtkWidget*)OS.gtk_tree_view_get_selection (handle));

    if (checkRenderer !is null) display.removeWidget (cast(GtkWidget*)checkRenderer);

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

    bool fixColumn = showFirstColumn ();

    auto selection = OS.gtk_tree_view_get_selection (handle);

    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

    OS.gtk_tree_selection_unselect_iter (selection, item.handle);

    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

    if (fixColumn) hideFirstColumn ();

}



/**

 * Deselects all selected items in the receiver.

 *

 * @exception SWTException <ul>

 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>

 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>

 * </ul>

 */

public void deselectAll() {

    checkWidget();

    bool fixColumn = showFirstColumn ();

    auto selection = OS.gtk_tree_view_get_selection (handle);

    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

    OS.gtk_tree_selection_unselect_all (selection);

    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

    if (fixColumn) hideFirstColumn ();

}



void destroyItem (TreeColumn column) {

    int index = 0;

    while (index < columnCount) {

        if (columns [index] is column) break;

        index++;

    }

    if (index is columnCount) return;

    auto columnHandle = column.handle;

    if (columnCount is 1) {

        firstCustomDraw = column.customDraw;

    }

    System.arraycopy (columns, index + 1, columns, index, --columnCount - index);

    columns [columnCount] = null;

    OS.gtk_tree_view_remove_column (handle, columnHandle);

    if (columnCount is 0) {

        auto oldModel = modelHandle;

        size_t[] types = getColumnTypes (1);

        auto newModel = OS.gtk_tree_store_newv (cast(int)/*64bit*/types.length, types.ptr);

        if (newModel is null) error (SWT.ERROR_NO_HANDLES);

        copyModel(oldModel, column.modelIndex, newModel, FIRST_COLUMN, types, null, null, FIRST_COLUMN + CELL_TYPES);

        OS.gtk_tree_view_set_model (handle, newModel);

        OS.g_object_unref (oldModel);

        modelHandle = newModel;

        createColumn (null, 0);



    } else {

        for (int i=0; i<items.length; i++) {

            TreeItem item = items [i];

            if (item !is null) {

                auto iter = cast(GtkTreeIter*)item.handle;

                int modelIndex = column.modelIndex;

                OS.gtk_tree_store_set1 (modelHandle, iter, modelIndex + CELL_PIXBUF, null);

                OS.gtk_tree_store_set1 (modelHandle, iter, modelIndex + CELL_TEXT, null);

                OS.gtk_tree_store_set1 (modelHandle, iter, modelIndex + CELL_FOREGROUND, null);

                OS.gtk_tree_store_set1 (modelHandle, iter, modelIndex + CELL_BACKGROUND, null);

                OS.gtk_tree_store_set1 (modelHandle, iter, modelIndex + CELL_FONT, null);



                Font [] cellFont = item.cellFont;

                if (cellFont !is null) {

                    if (columnCount is 0) {

                        item.cellFont = null;

                    } else {

                        Font [] temp = new Font [columnCount];

                        System.arraycopy (cellFont, 0, temp, 0, index);

                        System.arraycopy (cellFont, index + 1, temp, index, columnCount - index);

                        item.cellFont = temp;

                    }

                }

            }

        }

        if (index is 0) {

            // first column must be left aligned and must show check box

            TreeColumn firstColumn = columns [0];

            firstColumn.style &= ~(SWT.LEFT | SWT.RIGHT | SWT.CENTER);

            firstColumn.style |= SWT.LEFT;

            createRenderers (cast(GtkTreeViewColumn*)firstColumn.handle, firstColumn.modelIndex, true, firstColumn.style);

        }

    }

    /* Disable searching when using VIRTUAL */

    if ((style & SWT.VIRTUAL) !is 0) {

        /*

        * Bug in GTK. Until GTK 2.6.5, calling gtk_tree_view_set_enable_search(FALSE)

        * would prevent the user from being able to type in text to search the tree.

        * After 2.6.5, GTK introduced Ctrl+F as being the key binding for interactive

        * search. This meant that even if FALSE was passed to enable_search, the user

        * can still bring up the search pop up using the keybinding. GTK also introduced

        * the notion of passing a -1 to gtk_set_search_column to disable searching

        * (including the search key binding).  The fix is to use the right calls

        * for the right version.

        */

        if (OS.GTK_VERSION >= OS.buildVERSION (2, 6, 5)) {

            OS.gtk_tree_view_set_search_column (handle, -1);

        } else {

            OS.gtk_tree_view_set_enable_search (handle, false);

        }

    } else {

        /* Set the search column whenever the model changes */

        int firstColumn = columnCount is 0 ? FIRST_COLUMN : columns [0].modelIndex;

        OS.gtk_tree_view_set_search_column (handle, firstColumn + CELL_TEXT);

    }

}





void destroyItem (TreeItem item) {

    /*

    * Bug in GTK.  GTK segment faults when a root tree item

    * is destroyed when the tree is expanded and the last leaf of

    * the root is selected.  This only happens in versions earlier

    * than 2.0.6.  The fix is to collapse the tree item being destroyed

    * when it is a root, before it is destroyed.

    */

    if (OS.GTK_VERSION < OS.buildVERSION (2, 0, 6)) {

        int length = OS.gtk_tree_model_iter_n_children (modelHandle, null);

        if (length > 0) {

            GtkTreeIter iter;

            bool valid = cast(bool)OS.gtk_tree_model_iter_children (modelHandle, &iter, null);

            while (valid) {

                //PORTING_TODO: is this condition reasonable?

                if (item.handle is cast(GtkWidget*)&iter) {

                    item.setExpanded (false);

                    break;

                }

                valid = cast(bool)OS.gtk_tree_model_iter_next (modelHandle, &iter);

            }

        }

    }

    auto selection = OS.gtk_tree_view_get_selection (handle);

    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

    OS.gtk_tree_store_remove (modelHandle, item.handle);

    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

    modelChanged = true;

}



override bool dragDetect (int x, int y, bool filter, bool * consume) {

    bool selected = false;

    if (filter) {

        void* path;

        if (OS.gtk_tree_view_get_path_at_pos (handle, x, y, &path, null, null, null)) {

            if (path  !is null) {

                auto selection = OS.gtk_tree_view_get_selection (handle);

                if (OS.gtk_tree_selection_path_is_selected (selection, path )) selected = true;

                OS.gtk_tree_path_free (path );

            }

        } else {

            return false;

        }

    }

    bool dragDetect = super.dragDetect (x, y, filter, consume);

    if (dragDetect && selected && consume !is null) consume [0] = true;

    return dragDetect;

}



override GdkDrawable* eventWindow () {

    return paintWindow ();

}



override void fixChildren (Shell newShell, Shell oldShell, Decorations newDecorations, Decorations oldDecorations, Menu [] menus) {

    super.fixChildren (newShell, oldShell, newDecorations, oldDecorations, menus);

    for (int i=0; i<columnCount; i++) {

        TreeColumn column = columns [i];

        if (column.toolTipText !is null) {

            column.setToolTipText(oldShell, null);

            column.setToolTipText(newShell, column.toolTipText);

        }

    }

}



override GdkColor* getBackgroundColor () {

    return getBaseColor ();

}



public override Rectangle getClientArea () {

    checkWidget ();

    forceResize ();

    OS.gtk_widget_realize (handle);

    auto fixedWindow = OS.GTK_WIDGET_WINDOW (fixedHandle);

    auto binWindow = OS.gtk_tree_view_get_bin_window (handle);

    int binX, binY;

    OS.gdk_window_get_origin (binWindow, &binX, &binY);

    int fixedX, fixedY;

    OS.gdk_window_get_origin (fixedWindow, &fixedX, &fixedY);

    auto clientHandle = clientHandle ();

    int width = (state & ZERO_WIDTH) !is 0 ? 0 : OS.GTK_WIDGET_WIDTH (clientHandle);

    int height = (state & ZERO_HEIGHT) !is 0 ? 0 : OS.GTK_WIDGET_HEIGHT (clientHandle);

    return new Rectangle (fixedX  - binX , fixedY  - binY , width, height);

}



override

int getClientWidth () {

    int w, h;

    OS.gtk_widget_realize (handle);

    OS.gdk_drawable_get_size(OS.gtk_tree_view_get_bin_window(handle), &w, &h);

    return w;

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

    checkWidget();

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

    checkWidget();

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

public int [] getColumnOrder () {

    checkWidget ();

    if (columnCount is 0) return null;

    auto list = OS.gtk_tree_view_get_columns (handle);

    if (list is null) return null;

    int  i = 0, count = OS.g_list_length (list);

    int [] order = new int [count];

    auto temp = list;

    while (temp !is null) {

        auto column = OS.g_list_data (temp);

        if (column !is null) {

            for (int j=0; j<columnCount; j++) {

                if (columns [j].handle is column) {

                    order [i++] = j;

                    break;

                }

            }

        }

        temp = OS.g_list_next (temp);

    }

    OS.g_list_free (list);

    return order;

}



size_t[] getColumnTypes (int columnCount) {

    size_t[] types = new size_t [FIRST_COLUMN + (columnCount * CELL_TYPES)];

    // per row data

    types [ID_COLUMN] = OS.G_TYPE_INT ();

    types [CHECKED_COLUMN] = OS.G_TYPE_BOOLEAN ();

    types [GRAYED_COLUMN] = OS.G_TYPE_BOOLEAN ();

    types [FOREGROUND_COLUMN] = OS.GDK_TYPE_COLOR ();

    types [BACKGROUND_COLUMN] = OS.GDK_TYPE_COLOR ();

    types [FONT_COLUMN] = OS.PANGO_TYPE_FONT_DESCRIPTION ();

    // per cell data

    for (int i=FIRST_COLUMN; i<types.length; i+=CELL_TYPES) {

        types [i + CELL_PIXBUF] = OS.GDK_TYPE_PIXBUF ();

        types [i + CELL_TEXT] = OS.G_TYPE_STRING ();

        types [i + CELL_FOREGROUND] = OS.GDK_TYPE_COLOR ();

        types [i + CELL_BACKGROUND] = OS.GDK_TYPE_COLOR ();

        types [i + CELL_FONT] = OS.PANGO_TYPE_FONT_DESCRIPTION ();

    }

    return types;

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

    checkWidget();

    TreeColumn [] result = new TreeColumn [columnCount];

    System.arraycopy (columns, 0, result, 0, columnCount);

    return result;

}



TreeItem getFocusItem () {

    GtkTreePath* path;

    OS.gtk_tree_view_get_cursor (handle, &path, null);

    if (path  is null) return null;

    TreeItem item = null;

    GtkTreeIter iter;

    if (OS.gtk_tree_model_get_iter (modelHandle, &iter, path)) {

        int index;

        OS.gtk_tree_model_get1 (modelHandle, &iter, ID_COLUMN, cast(void**)&index);

        if (index  !is -1) item = items [index ]; //TODO should we be creating this item when index is -1?

    }

    OS.gtk_tree_path_free (path );

    return item;

}



override GdkColor* getForegroundColor () {

    return getTextColor ();

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

    checkWidget();

    return 0;

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

    if (!OS.gtk_tree_view_get_headers_visible (handle)) return 0;

    if (columnCount > 0) {

        GtkRequisition requisition;

        int height = 0;

        for (int i=0; i<columnCount; i++) {

            auto buttonHandle = columns [i].buttonHandle;

            if (buttonHandle !is null) {

                OS.gtk_widget_size_request (buttonHandle, &requisition);

                height = Math.max (height, requisition.height);

            }

        }

        return height;

    }

    OS.gtk_widget_realize (handle);

    auto fixedWindow = OS.GTK_WIDGET_WINDOW (fixedHandle);

    auto binWindow = OS.gtk_tree_view_get_bin_window (handle);

    int binY ;

    OS.gdk_window_get_origin (binWindow, null, &binY);

    int fixedY;

    OS.gdk_window_get_origin (fixedWindow, null, &fixedY);

    return binY  - fixedY;

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

    checkWidget();

    return cast(bool)OS.gtk_tree_view_get_headers_visible (handle);

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

    if (!(0 <= index && index < OS.gtk_tree_model_iter_n_children (modelHandle, null)))  {

        error (SWT.ERROR_INVALID_RANGE);

    }

    return _getItem (null, index);

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

    void* path;

    OS.gtk_widget_realize (handle);

    GtkTreeViewColumn* columnHandle;

    if (!OS.gtk_tree_view_get_path_at_pos (handle, point.x, point.y, &path, &columnHandle, null, null)) return null;

    if (path  is null) return null;

    TreeItem item = null;

    GtkTreeIter iter;

    if (OS.gtk_tree_model_get_iter (modelHandle, &iter, path )) {

        bool overExpander = false;

        if (OS.gtk_tree_view_get_expander_column (handle) is columnHandle ) {

            int buffer;

            GdkRectangle rect;

            OS.gtk_tree_view_get_cell_area (handle, path, columnHandle, &rect);

            if (OS.GTK_VERSION < OS.buildVERSION (2, 8, 18)) {

                OS.gtk_widget_style_get1 (handle, OS.expander_size.ptr, &buffer);

                int expanderSize = buffer  + TreeItem.EXPANDER_EXTRA_PADDING;

                overExpander = point.x < rect.x + expanderSize;

            } else {

                overExpander = point.x < rect.x;

            }

        }

        if (!overExpander) {

            item = _getItem (&iter);

        }

    }

    OS.gtk_tree_path_free (path );

    return item;

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

    return OS.gtk_tree_model_iter_n_children (modelHandle, null);

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

    int itemCount = OS.gtk_tree_model_iter_n_children (modelHandle, null);

    if (itemCount is 0) {

        auto column = OS.gtk_tree_view_get_column (handle, 0);

        int w, h;

        ignoreSize = true;

        OS.gtk_tree_view_column_cell_get_size (column, null, null, null, &w, &h);

        ignoreSize = false;

        return h ;

    } else {

        int height = 0;

        GtkTreeIter iter;

        OS.gtk_tree_model_get_iter_first (modelHandle, &iter);

        int columnCount = Math.max (1, this.columnCount);

        for (int i=0; i<columnCount; i++) {

            auto column = OS.gtk_tree_view_get_column (handle, i);

            OS.gtk_tree_view_column_cell_set_cell_data (column, modelHandle, &iter, false, false);

            int w, h;

            OS.gtk_tree_view_column_cell_get_size (column, null, null, null, &w, &h);

            height = Math.max (height, h );

        }

        return height;

    }

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

    checkWidget();

    return getItems (null);

}



TreeItem [] getItems (GtkTreeIter* parent) {

    int length = OS.gtk_tree_model_iter_n_children (modelHandle, parent);

    TreeItem[] result = new TreeItem [length];

    if (length is 0) return result;

    if ((style & SWT.VIRTUAL) !is 0) {

        for (int i=0; i<length; i++) {

            result [i] = _getItem (parent, i);

        }

    } else {

        int i = 0;

        int index;

        GtkTreeIter iter;

        bool valid = cast(bool)OS.gtk_tree_model_iter_children (modelHandle, &iter, parent);

        while (valid) {

            OS.gtk_tree_model_get1 (modelHandle, &iter, ID_COLUMN, cast(void**)&index);

            result [i++] = items [index ];

            valid = cast(bool)OS.gtk_tree_model_iter_next (modelHandle, &iter);

        }

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

public bool getLinesVisible() {

    checkWidget();

    return cast(bool)OS.gtk_tree_view_get_rules_hint (handle);

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



GtkCellRendererPixbuf* getPixbufRenderer (GtkTreeViewColumn* column) {

    auto list = OS.gtk_tree_view_column_get_cell_renderers (column);

    if (list is null) return null;

    int count = OS.g_list_length (list);

    GtkCellRendererPixbuf* pixbufRenderer;

    int i = 0;

    while (i < count) {

        auto renderer = OS.g_list_nth_data (list, i);

        if (OS.GTK_IS_CELL_RENDERER_PIXBUF (renderer)) {

            pixbufRenderer = cast(GtkCellRendererPixbuf*)renderer;

            break;

        }

        i++;

    }

    OS.g_list_free (list);

    return pixbufRenderer;

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

public TreeItem[] getSelection () {

    checkWidget();

    auto selection = OS.gtk_tree_view_get_selection (handle);

    if (OS.GTK_VERSION < OS.buildVERSION (2, 2, 0)) {

        display.treeSelectionLength  = 0;

        display.treeSelection = new int [items.length];

        display.doTreeSelectionProcConnect( &treeSelectionCallbackData, handle, selection );

        TreeItem [] result = new TreeItem [display.treeSelectionLength];

        for (int i=0; i<result.length; i++) result [i] = items [display.treeSelection [i]];

        return result;

    }

    /*

    * Bug in GTK.  gtk_tree_selection_get_selected_rows() segmentation faults

    * in versions smaller than 2.2.4 if the model is NULL.  The fix is

    * to give a valid pointer instead.

    */

    int dummy;

    void* model = OS.GTK_VERSION < OS.buildVERSION (2, 2, 4) ? &dummy : null;

    auto list = OS.gtk_tree_selection_get_selected_rows (selection, &model);

    if (list !is null) {

        int count = OS.g_list_length (list);

        TreeItem [] treeSelection = new TreeItem [count];

        int length_ = 0;

        for (int i=0; i<count; i++) {

            auto data = OS.g_list_nth_data (list, i);

            GtkTreeIter iter;

            if (OS.gtk_tree_model_get_iter (modelHandle, &iter, data)) {

                treeSelection [length_] = _getItem (&iter);

                length_++;

            }

        }

        OS.g_list_free (list);

        if (length_ < count) {

            TreeItem [] temp = new TreeItem [length_];

            System.arraycopy(treeSelection, 0, temp, 0, length_);

            treeSelection = temp;

        }

        return treeSelection;

    }

    return null;

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

    checkWidget();

    auto selection = OS.gtk_tree_view_get_selection (handle);

    if (OS.GTK_VERSION < OS.buildVERSION (2, 2, 0)) {

        display.treeSelectionLength = 0;

        display.treeSelection = null;

        display.doTreeSelectionProcConnect( &treeSelectionCallbackData, handle, selection );

        return display.treeSelectionLength;

    }

    return OS.gtk_tree_selection_count_selected_rows (selection);

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



GtkCellRendererText* getTextRenderer (GtkTreeViewColumn* column) {

    auto list = OS.gtk_tree_view_column_get_cell_renderers (column);

    if (list is null) return null;

    int count = OS.g_list_length (list);

    GtkCellRendererText* textRenderer;

    int i = 0;

    while (i < count) {

        auto renderer = OS.g_list_nth_data (list, i);

         if (OS.GTK_IS_CELL_RENDERER_TEXT (renderer)) {

            textRenderer = cast(GtkCellRendererText*)renderer;

            break;

        }

        i++;

    }

    OS.g_list_free (list);

    return textRenderer;

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

    void* path;

    OS.gtk_widget_realize (handle);

    if (!OS.gtk_tree_view_get_path_at_pos (handle, 1, 1, &path, null, null, null)) return null;

    if (path  is null) return null;

    TreeItem item = null;

    GtkTreeIter iter;

    if (OS.gtk_tree_model_get_iter (modelHandle, &iter, path )) {

        item = _getItem (&iter);

    }

    OS.gtk_tree_path_free (path );

    return item;

}



override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* gdkEvent) {

    if (gdkEvent.window !is OS.gtk_tree_view_get_bin_window (handle)) return 0;

    auto result = super.gtk_button_press_event (widget, gdkEvent);

    if (result !is 0) return result;

    /*

    * Feature in GTK.  In a multi-select tree view, when multiple items are already

    * selected, the selection state of the item is toggled and the previous selection

    * is cleared. This is not the desired behaviour when bringing up a popup menu.

    * Also, when an item is reselected with the right button, the tree view issues

    * an unwanted selection event. The workaround is to detect that case and not

    * run the default handler when the item is already part of the current selection.

    */

    int button = gdkEvent.button;

    if (button is 3 && gdkEvent.type is OS.GDK_BUTTON_PRESS) {

        void* path;

        if (OS.gtk_tree_view_get_path_at_pos (handle, cast(int)/*64bit*/gdkEvent.x, cast(int)/*64bit*/gdkEvent.y, &path, null, null, null)) {

            if (path !is null) {

                auto selection = OS.gtk_tree_view_get_selection (handle);

                if (OS.gtk_tree_selection_path_is_selected (selection, path )) result = 1;

                OS.gtk_tree_path_free (path );

            }

        }

    }



    /*

    * Feature in GTK.  When the user clicks in a single selection GtkTreeView

    * and there are no selected items, the first item is selected automatically

    * before the click is processed, causing two selection events.  The is fix

    * is the set the cursor item to be same as the clicked item to stop the

    * widget from automatically selecting the first item.

    */

    if ((style & SWT.SINGLE) !is 0 && getSelectionCount () is 0) {

        void* path;

        if (OS.gtk_tree_view_get_path_at_pos (handle, cast(int)/*64bit*/gdkEvent.x, cast(int)/*64bit*/gdkEvent.y, &path, null, null, null)) {

            if (path  !is null) {

                auto selection = OS.gtk_tree_view_get_selection (handle);

                OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

                OS.gtk_tree_view_set_cursor (handle, path , null, false);

                OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

                OS.gtk_tree_path_free (path );

            }

        }

    }

    /*

    * Bug in GTK. GTK segments fault, if the GtkTreeView widget is

    * not in focus and all items in the widget are disposed before

    * it finishes processing a button press.  The fix is to give

    * focus to the widget before it starts processing the event.

    */

    if (!OS.GTK_WIDGET_HAS_FOCUS (handle)) {

        OS.gtk_widget_grab_focus (handle);

    }

    return result;

}



override int gtk_button_release_event (GtkWidget* widget, GdkEventButton* event) {

    auto window = OS.GDK_EVENT_WINDOW (event);

    if (window !is OS.gtk_tree_view_get_bin_window (handle)) return 0;

    return super.gtk_button_release_event (widget, event);

}



override int gtk_changed (GtkWidget* widget) {

    TreeItem item = getFocusItem ();

    if (item !is null) {

        Event event = new Event ();

        event.item = item;

        postEvent (SWT.Selection, event);

    }

    return 0;

}



override int gtk_expand_collapse_cursor_row (GtkWidget* widget, ptrdiff_t logical, ptrdiff_t expand, ptrdiff_t open_all) {

    // FIXME - this flag is never cleared.  It should be cleared when the expand all operation completes.

    if (expand !is 0 && open_all !is 0) expandAll = true;

    return 0;

}



override int gtk_key_press_event (GtkWidget* widget, GdkEventKey* keyEvent) {

    auto result = super.gtk_key_press_event (widget, keyEvent);

    if (result !is 0) return result;

    if (OS.GTK_VERSION < OS.buildVERSION (2, 2 ,0)) {

        /*

        * Feature in GTK 2.0.x.  When an item is default selected using

        * the return key, GTK does not issue notification. The fix is

        * to issue this notification when the return key is pressed.

        */

        int key = keyEvent.keyval;

        switch (key) {

            case OS.GDK_Return:

            case OS.GDK_KP_Enter: {

                Event event = new Event ();

                event.item = getFocusItem ();

                postEvent (SWT.DefaultSelection, event);

                break;

            }

            default:

        }

    }

    return result;

}



override int gtk_motion_notify_event (GtkWidget* widget, GdkEventMotion* event) {

    auto window = OS.GDK_EVENT_WINDOW (event);

    if (window !is OS.gtk_tree_view_get_bin_window (handle)) return 0;

    return super.gtk_motion_notify_event (widget, event);

}



override int gtk_popup_menu (GtkWidget* widget) {

    auto result = super.gtk_popup_menu (widget);

    /*

    * Bug in GTK.  The context menu for the typeahead in GtkTreeViewer

    * opens in the bottom right corner of the screen when Shift+F10

    * is pressed and the typeahead window was not visible.  The fix is

    * to prevent the context menu from opening by stopping the default

    * handler.

    *

    * NOTE: The bug only happens in GTK 2.6.5 and lower.

    */

    return OS.GTK_VERSION < OS.buildVERSION (2, 6, 5) ? 1 : result;

}



override void gtk_row_activated (GtkTreeView* tree, GtkTreePath* path, GtkTreeViewColumn* column) {

    if (path is null) return;

    TreeItem item = null;

    GtkTreeIter iter;

    if (OS.gtk_tree_model_get_iter (modelHandle, &iter, path)) {

        int index;

        OS.gtk_tree_model_get1 (modelHandle, &iter, ID_COLUMN, cast(void**)&index);

        item = items [index ];

    }

    Event event = new Event ();

    event.item = item;

    postEvent (SWT.DefaultSelection, event);

    return;

}



override int gtk_test_collapse_row (

    GtkTreeView *tree,

    GtkTreeIter *iter,

    GtkTreePath *path)

{

    int index ;

    OS.gtk_tree_model_get1 (modelHandle, iter, ID_COLUMN, cast(void**)&index);

    TreeItem item = items [index ];

    Event event = new Event ();

    event.item = item;

    bool oldModelChanged = modelChanged;

    modelChanged = false;

    sendEvent (SWT.Collapse, event);

    /*

    * Bug in GTK.  Collapsing the target row during the test_collapse_row

    * handler will cause a segmentation fault if the animation code is allowed

    * to run.  The fix is to block the animation if the row is already

    * collapsed.

    */

    bool changed = modelChanged || !OS.gtk_tree_view_row_expanded (handle, path);

    modelChanged = oldModelChanged;

    if (isDisposed () || item.isDisposed ()) return 1;

    /*

    * Bug in GTK.  Expanding or collapsing a row which has no more

    * children causes the model state to become invalid, causing

    * GTK to give warnings and behave strangely.  Other changes to

    * the model can cause expansion to fail when using the multiple

    * expansion keys (such as *).  The fix is to stop the expansion

    * if there are model changes.

    *

    * Note: This callback must return 0 for the collapsing

    * animation to occur.

    */

    if (changed) {

        OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udTEST_COLLAPSE_ROW);

        OS.gtk_tree_view_collapse_row (handle, path);

        OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udTEST_COLLAPSE_ROW);

        return 1;

    }

    return 0;

}



override int gtk_test_expand_row (

    GtkTreeView *tree,

    GtkTreeIter *iter,

    GtkTreePath *path)

{

    int index ;

    OS.gtk_tree_model_get1 (modelHandle, iter, ID_COLUMN, cast(void**)&index);

    TreeItem item = items [index ];

    Event event = new Event ();

    event.item = item;

    bool oldModelChanged = modelChanged;

    modelChanged = false;

    sendEvent (SWT.Expand, event);

    /*

    * Bug in GTK.  Expanding the target row during the test_expand_row

    * handler will cause a segmentation fault if the animation code is allowed

    * to run.  The fix is to block the animation if the row is already

    * expanded.

    */

    bool changed = modelChanged || OS.gtk_tree_view_row_expanded (handle, path);

    modelChanged = oldModelChanged;

    if (isDisposed () || item.isDisposed ()) return 1;

    /*

    * Bug in GTK.  Expanding or collapsing a row which has no more

    * children causes the model state to become invalid, causing

    * GTK to give warnings and behave strangely.  Other changes to

    * the model can cause expansion to fail when using the multiple

    * expansion keys (such as *).  The fix is to stop the expansion

    * if there are model changes.

    *

    * Bug in GTK.  test-expand-row does not get called for each row

    * in an expand all operation.  The fix is to block the initial

    * expansion and only expand a single level.

    *

    * Note: This callback must return 0 for the collapsing

    * animation to occur.

    */

    if (changed || expandAll) {

        OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udTEST_EXPAND_ROW);

        OS.gtk_tree_view_expand_row (handle, path, false);

        OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udTEST_EXPAND_ROW);

        return 1;

    }

    return 0;

}



override int gtk_toggled (int renderer, char* pathStr) {

    auto path = OS.gtk_tree_path_new_from_string (pathStr);

    if (path is null) return 0;

    TreeItem item = null;

    GtkTreeIter iter;

    if (OS.gtk_tree_model_get_iter (modelHandle, &iter, path)) {

        item = _getItem (&iter);

    }

    OS.gtk_tree_path_free (path);

    if (item !is null) {

        item.setChecked (!item.getChecked ());

        Event event = new Event ();

        event.detail = SWT.CHECK;

        event.item = item;

        postEvent (SWT.Selection, event);

    }

    return 0;

}



override void gtk_widget_size_request (GtkWidget* widget, GtkRequisition* requisition) {

    /*

     * Bug in GTK.  For some reason, gtk_widget_size_request() fails

     * to include the height of the tree view items when there are

     * no columns visible.  The fix is to temporarily make one column

     * visible.

     */

    if (columnCount is 0) {

        super.gtk_widget_size_request (widget, requisition);

        return;

    }

    auto columns = OS.gtk_tree_view_get_columns (handle), list = columns;

    bool fixVisible = columns !is null;

    while (list !is null) {

        auto column = OS.g_list_data (list);

        if (OS.gtk_tree_view_column_get_visible (column)) {

            fixVisible = false;

            break;

        }

        list = OS.g_list_next (list);

    }

    GtkTreeViewColumn* columnHandle;

    if (fixVisible) {

        columnHandle = cast(GtkTreeViewColumn*)OS.g_list_data (columns);

        OS.gtk_tree_view_column_set_visible (columnHandle, true);

    }

    super.gtk_widget_size_request (widget, requisition);

    if (fixVisible) {

        OS.gtk_tree_view_column_set_visible (columnHandle, false);

    }

    if (columns !is null) OS.g_list_free (columns);

}



void hideFirstColumn () {

    auto firstColumn = OS.gtk_tree_view_get_column (handle, 0);

    OS.gtk_tree_view_column_set_visible (firstColumn, false);

}



override void hookEvents () {

    super.hookEvents ();

    auto selection = OS.gtk_tree_view_get_selection(handle);

    OS.g_signal_connect_closure (selection, OS.changed.ptr, display.closures [CHANGED], false);

    OS.g_signal_connect_closure (handle, OS.row_activated.ptr, display.closures [ROW_ACTIVATED], false);

    OS.g_signal_connect_closure (handle, OS.test_expand_row.ptr, display.closures [TEST_EXPAND_ROW], false);

    OS.g_signal_connect_closure (handle, OS.test_collapse_row.ptr, display.closures [TEST_COLLAPSE_ROW], false);

    OS.g_signal_connect_closure (handle, OS.expand_collapse_cursor_row.ptr, display.closures [EXPAND_COLLAPSE_CURSOR_ROW], false);

    if (checkRenderer !is null) {

        OS.g_signal_connect_closure (checkRenderer, OS.toggled.ptr, display.closures [TOGGLED], false);

    }

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

    checkWidget();

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

    auto path = OS.gtk_tree_model_get_path (modelHandle, item.handle);

    int depth = OS.gtk_tree_path_get_depth (path);

    if (depth is 1) {

        auto indices = OS.gtk_tree_path_get_indices (path);

        if (indices !is null) {

            index = indices[0];

        }

    }

    OS.gtk_tree_path_free (path);

    return index;

}



override bool mnemonicHit (wchar key) {

    for (int i=0; i<columnCount; i++) {

        auto labelHandle = columns [i].labelHandle;

        if (labelHandle !is null && mnemonicHit (labelHandle, key)) return true;

    }

    return false;

}



override bool mnemonicMatch (wchar key) {

    for (int i=0; i<columnCount; i++) {

        auto labelHandle = columns [i].labelHandle;

        if (labelHandle !is null && mnemonicMatch (labelHandle, key)) return true;

    }

    return false;

}



override GdkDrawable* paintWindow () {

    OS.gtk_widget_realize (handle);

    return OS.gtk_tree_view_get_bin_window (handle);

}



void recreateRenderers () {

    if (checkRenderer !is null) {

        display.removeWidget (cast(GtkWidget*)checkRenderer);

        OS.g_object_unref (checkRenderer);

        checkRenderer = ownerDraw ? cast(GtkCellRenderer*)OS.g_object_new (display.gtk_cell_renderer_toggle_get_type(), null) : OS.gtk_cell_renderer_toggle_new ();

        if (checkRenderer is null) error (SWT.ERROR_NO_HANDLES);

        OS.g_object_ref (checkRenderer);

        display.addWidget (cast(GtkWidget*)checkRenderer, this);

        OS.g_signal_connect_closure (checkRenderer, OS.toggled.ptr, display.closures [TOGGLED], false);

    }

    if (columnCount is 0) {

        createRenderers (OS.gtk_tree_view_get_column (handle, 0), Tree.FIRST_COLUMN, true, 0);

    } else {

        for (int i = 0; i < columnCount; i++) {

            TreeColumn column = columns [i];

            createRenderers (cast(GtkTreeViewColumn*)column.handle, column.modelIndex, i is 0, column.style);

        }

    }

}



override void redrawBackgroundImage () {

    Control control = findBackgroundControl ();

    if (control !is null && control.backgroundImage !is null) {

        redrawWidget (0, 0, 0, 0, true, false, false);

    }

}



override void register () {

    super.register ();

    display.addWidget (cast(GtkWidget*)OS.gtk_tree_view_get_selection (handle), this);

    if (checkRenderer !is null) display.addWidget (cast(GtkWidget*)checkRenderer, this);

}



void releaseItem (TreeItem item, bool release) {

    int index;

    OS.gtk_tree_model_get1 (modelHandle, item.handle, ID_COLUMN, cast(void**)&index);

    if (index is -1) return;

    if (release) item.release (false);

    items [index ] = null;

}



void releaseItems (GtkTreeIter* parentIter) {

    int index;

    GtkTreeIter iter;

    bool valid = cast(bool)OS.gtk_tree_model_iter_children (modelHandle, &iter, parentIter);

    while (valid) {

        releaseItems (&iter);

        if (!isDisposed ()) {

            OS.gtk_tree_model_get1 (modelHandle, &iter, ID_COLUMN, cast(void**)&index);

            if (index  !is -1) {

                TreeItem item = items [index ];

                if (item !is null) releaseItem (item, true);

            }

        }

        valid = cast(bool)OS.gtk_tree_model_iter_next (modelHandle, &iter);

    }

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

        for (int i=0; i<columnCount; i++) {

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

    if (modelHandle !is null) OS.g_object_unref (modelHandle);

    modelHandle = null;

    if (checkRenderer !is null) OS.g_object_unref (checkRenderer);

    checkRenderer = null;

    if (imageList !is null) imageList.dispose ();

    if (headerImageList !is null) headerImageList.dispose ();

    imageList = headerImageList = null;

    currentItem = null;

}



void remove (GtkTreeIter* parentIter, int start, int end) {

    if (start > end) return;

    int itemCount = OS.gtk_tree_model_iter_n_children (modelHandle, parentIter);

    if (!(0 <= start && start <= end && end < itemCount)) {

        error (SWT.ERROR_INVALID_RANGE);

    }

    auto selection = OS.gtk_tree_view_get_selection (handle);

    GtkTreeIter iter;

    int index = start;

    for (int i = start; i <= end; i++) {

        OS.gtk_tree_model_iter_nth_child (modelHandle, &iter, parentIter, index);

        int value;

        OS.gtk_tree_model_get1 (modelHandle, &iter, ID_COLUMN, cast(void**)&value);

        TreeItem item = value  !is -1 ? items [value ] : null;

        if (item !is null && !item.isDisposed ()) {

            item.dispose ();

        } else {

            OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

            OS.gtk_tree_store_remove (modelHandle, &iter);

            OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

        }

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

    for (int i=0; i<items.length; i++) {

        TreeItem item = items [i];

        if (item !is null && !item.isDisposed ()) item.release (false);

    }

    items = new TreeItem[4];

    auto selection = OS.gtk_tree_view_get_selection (handle);

    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

    OS.gtk_tree_store_clear (modelHandle);

    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);



    /* Disable searching when using VIRTUAL */

    if ((style & SWT.VIRTUAL) !is 0) {

        /*

        * Bug in GTK. Until GTK 2.6.5, calling gtk_tree_view_set_enable_search(FALSE)

        * would prevent the user from being able to type in text to search the tree.

        * After 2.6.5, GTK introduced Ctrl+F as being the key binding for interactive

        * search. This meant that even if FALSE was passed to enable_search, the user

        * can still bring up the search pop up using the keybinding. GTK also introduced

        * the notion of passing a -1 to gtk_set_search_column to disable searching

        * (including the search key binding).  The fix is to use the right calls

        * for the right version.

        */

        if (OS.GTK_VERSION >= OS.buildVERSION (2, 6, 5)) {

            OS.gtk_tree_view_set_search_column (handle, -1);

        } else {

            OS.gtk_tree_view_set_enable_search (handle, false);

        }

    } else {

        /* Set the search column whenever the model changes */

        int firstColumn = columnCount is 0 ? FIRST_COLUMN : columns [0].modelIndex;

        OS.gtk_tree_view_set_search_column (handle, firstColumn + CELL_TEXT);

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



override void rendererGetSizeProc (

    GtkCellRenderer      *cell,

    GtkWidget            *widget,

    GdkRectangle         *cell_area,

    int                  *x_offset,

    int                  *y_offset,

    int                  *width,

    int                  *height)

{

    auto g_class = OS.g_type_class_peek_parent (OS.G_OBJECT_GET_CLASS (cell));

    GtkCellRendererClass* klass = cast(GtkCellRendererClass*)g_class;

    klass.get_size( cell, handle, cell_area, x_offset, y_offset, width, height);

    if (!ignoreSize && OS.GTK_IS_CELL_RENDERER_TEXT (cell)) {

        auto iter = cast(GtkTreeIter*)OS.g_object_get_qdata (cast(GObject*)cell, Display.SWT_OBJECT_INDEX2);

        TreeItem item = null;

        if (iter !is null) item = _getItem (iter);

        if (item !is null) {

            int columnIndex = 0;

            if (columnCount > 0) {

                auto columnHandle = cast(GtkTreeViewColumn*)OS.g_object_get_qdata (cast(GObject*)cell, Display.SWT_OBJECT_INDEX1);

                for (int i = 0; i < columnCount; i++) {

                    if (columns [i].handle is cast(GtkWidget*)columnHandle) {

                        columnIndex = i;

                        break;

                    }

                }

            }

            if (hooks (SWT.MeasureItem)) {

                int contentWidth, contentHeight;

                if (width !is null) contentWidth = *width;

                if (height !is null) contentHeight = *height;

                Image image = item.getImage (columnIndex);

                int imageWidth = 0;

                if (image !is null) {

                    Rectangle bounds = image.getBounds ();

                    imageWidth = bounds.width;

                }

                contentWidth += imageWidth;

                GC gc = new GC (this);

                gc.setFont (item.getFont (columnIndex));

                Event event = new Event ();

                event.item = item;

                event.index = columnIndex;

                event.gc = gc;

                event.width = contentWidth ;

                event.height = contentHeight ;

                sendEvent (SWT.MeasureItem, event);

                gc.dispose ();

                contentWidth  = event.width - imageWidth;

                if (contentHeight < event.height) contentHeight = event.height;

                if (width !is null) *width = contentWidth;

                if (height !is null) *height = contentHeight;

            }

        }

    }

}



override void rendererRenderProc (

    GtkCellRenderer * cell,

    GdkDrawable * window,

    GtkWidget * widget,

    GdkRectangle *background_area,

    GdkRectangle *cell_area,

    GdkRectangle *expose_area,

    int flags)

{

    TreeItem item = null;

    auto iter = cast(GtkTreeIter*)OS.g_object_get_qdata (cast(GObject*)cell, Display.SWT_OBJECT_INDEX2);

    if (iter !is null) item = _getItem (iter);

    auto columnHandle = cast(GtkTreeViewColumn*)OS.g_object_get_qdata (cast(GObject*)cell, Display.SWT_OBJECT_INDEX1);

    int columnIndex = 0;

    if (columnCount > 0) {

        for (int i = 0; i < columnCount; i++) {

            if (columns [i].handle is cast(GtkWidget*)columnHandle) {

                columnIndex = i;

                break;

            }

        }

    }

    if (item !is null) {

        if (OS.GTK_IS_CELL_RENDERER_TOGGLE (cell) || (OS.GTK_IS_CELL_RENDERER_PIXBUF (cell) && (columnIndex !is 0 || (style & SWT.CHECK) is 0))) {

            drawFlags = flags;

            drawState = SWT.FOREGROUND;

            void* ptr;

            OS.gtk_tree_model_get1 (modelHandle, item.handle, Tree.BACKGROUND_COLUMN, &ptr);

            if (ptr is null) {

                int modelIndex = columnCount is 0 ? Tree.FIRST_COLUMN : columns [columnIndex].modelIndex;

                OS.gtk_tree_model_get1 (modelHandle, item.handle, modelIndex + Tree.CELL_BACKGROUND, &ptr);

            }

            if (ptr !is null) drawState |= SWT.BACKGROUND;

            if ((flags & OS.GTK_CELL_RENDERER_SELECTED) !is 0) drawState |= SWT.SELECTED;

            if ((flags & OS.GTK_CELL_RENDERER_FOCUSED) !is 0) drawState |= SWT.FOCUSED;



            GdkRectangle rect;

            auto path = OS.gtk_tree_model_get_path (modelHandle, iter);

            OS.gtk_tree_view_get_background_area (handle, path, columnHandle, &rect);

            OS.gtk_tree_path_free (path);



            if ((drawState & SWT.SELECTED) is 0) {

                Control control = findBackgroundControl ();

                if (control !is null && control.backgroundImage !is null) {

                    OS.gdk_window_clear_area (window, rect.x, rect.y, rect.width, rect.height);

                }

            }



            if (hooks (SWT.EraseItem)) {

                bool wasSelected = false;

                if ((drawState & SWT.SELECTED) !is 0) {

                    wasSelected = true;

                    OS.gdk_window_clear_area (window, rect.x, rect.y, rect.width, rect.height);

                }

                GC gc = new GC (this);

                if ((drawState & SWT.SELECTED) !is 0) {

                    gc.setBackground (display.getSystemColor (SWT.COLOR_LIST_SELECTION));

                    gc.setForeground (display.getSystemColor (SWT.COLOR_LIST_SELECTION_TEXT));

                } else {

                    gc.setBackground (item.getBackground (columnIndex));

                    gc.setForeground (item.getForeground (columnIndex));

                }

                gc.setFont (item.getFont (columnIndex));

                if ((style & SWT.MIRRORED) !is 0) rect.x = getClientWidth () - rect.width - rect.x;

                gc.setClipping (rect.x, rect.y, rect.width, rect.height);

                Event event = new Event ();

                event.item = item;

                event.index = columnIndex;

                event.gc = gc;

                event.x = rect.x;

                event.y = rect.y;

                event.width = rect.width;

                event.height = rect.height;

                event.detail = drawState;

                sendEvent (SWT.EraseItem, event);

                drawForeground = null;

                drawState = event.doit ? event.detail : 0;

                drawFlags &= ~(OS.GTK_CELL_RENDERER_FOCUSED | OS.GTK_CELL_RENDERER_SELECTED);

                if ((drawState & SWT.SELECTED) !is 0) drawFlags |= OS.GTK_CELL_RENDERER_SELECTED;

                if ((drawState & SWT.FOCUSED) !is 0) drawFlags |= OS.GTK_CELL_RENDERER_FOCUSED;

                if ((drawState & SWT.SELECTED) !is 0) {

                    auto style = OS.gtk_widget_get_style (widget);

                    //TODO - parity and sorted

                    OS.gtk_paint_flat_box (style, window, OS.GTK_STATE_SELECTED, OS.GTK_SHADOW_NONE, &rect, widget, "cell_odd".ptr, rect.x, rect.y, rect.width, rect.height);

                } else {

                    if (wasSelected) drawForeground = gc.getForeground ().handle;

                }

                gc.dispose();

            }

        }

    }

    int result = 0;

    if ((drawState & SWT.BACKGROUND) !is 0 && (drawState & SWT.SELECTED) is 0) {

        GC gc = new GC (this);

        gc.setBackground (item.getBackground (columnIndex));

        gc.fillRectangle (background_area.x, background_area.y, background_area.width, background_area.height);

        gc.dispose ();

    }

    if ((drawState & SWT.FOREGROUND) !is 0 || OS.GTK_IS_CELL_RENDERER_TOGGLE (cell)) {

        auto g_class = OS.g_type_class_peek_parent (OS.G_OBJECT_GET_CLASS (cell));

        GtkCellRendererClass* klass = cast(GtkCellRendererClass*)g_class;

        if (drawForeground !is null && OS.GTK_IS_CELL_RENDERER_TEXT (cell)) {

            OS.g_object_set1 (cell, OS.foreground_gdk.ptr, cast(ptrdiff_t)drawForeground);

        }

        klass.render( cell, window, handle, background_area, cell_area, expose_area, drawFlags);

    }

    if (item !is null) {

        if (OS.GTK_IS_CELL_RENDERER_TEXT (cell)) {

            if (hooks (SWT.PaintItem)) {

                GdkRectangle rect;

                auto path = OS.gtk_tree_model_get_path (modelHandle, iter);

                OS.gtk_tree_view_get_cell_area (handle, path, columnHandle, &rect);

                OS.gtk_tree_path_free (path);

                if (OS.GTK_VERSION < OS.buildVERSION (2, 8, 18) && OS.gtk_tree_view_get_expander_column (handle) is columnHandle) {

                    int buffer;

                    OS.gtk_widget_style_get1 (handle, OS.expander_size.ptr, &buffer);

                    rect.x += buffer + TreeItem.EXPANDER_EXTRA_PADDING;

                    rect.width -= buffer + TreeItem.EXPANDER_EXTRA_PADDING;

                    //OS.gtk_widget_style_get (handle, OS.horizontal_separator, buffer, 0);

                    //rect.x += buffer[0];

                    //rect.width -= buffer [0]; // TODO Is this required for some versions?

                }

                ignoreSize = true;

                int contentX, contentWidth;

                OS.gtk_cell_renderer_get_size (cell, handle, null, null, null, &contentWidth, null);

                OS.gtk_tree_view_column_cell_get_position (columnHandle, cell, &contentX, null);

                ignoreSize = false;

                Image image = item.getImage (columnIndex);

                int imageWidth = 0;

                if (image !is null) {

                    Rectangle bounds = image.getBounds ();

                    imageWidth = bounds.width;

                }

                contentX -= imageWidth;

                contentWidth += imageWidth;

                GC gc = new GC (this);

                if ((drawState & SWT.SELECTED) !is 0) {

                    gc.setBackground (display.getSystemColor (SWT.COLOR_LIST_SELECTION));

                    gc.setForeground (display.getSystemColor (SWT.COLOR_LIST_SELECTION_TEXT));

                } else {

                    gc.setBackground (item.getBackground (columnIndex));

                    Color foreground = drawForeground !is null ? Color.gtk_new (display, drawForeground) : item.getForeground (columnIndex);

                    gc.setForeground (foreground);

                }

                gc.setFont (item.getFont (columnIndex));

                if ((style & SWT.MIRRORED) !is 0) rect.x = getClientWidth () - rect.width - rect.x;

                gc.setClipping (rect.x, rect.y, rect.width, rect.height);

                Event event = new Event ();

                event.item = item;

                event.index = columnIndex;

                event.gc = gc;

                event.x = rect.x + contentX;

                event.y = rect.y;

                event.width = contentWidth;

                event.height = rect.height;

                event.detail = drawState;

                sendEvent (SWT.PaintItem, event);

                gc.dispose();

            }

        }

    }

    //return result;

}



void resetCustomDraw () {

    if ((style & SWT.VIRTUAL) !is 0 || ownerDraw) return;

    int end = Math.max (1, columnCount);

    for (int i=0; i<end; i++) {

        bool customDraw = columnCount !is 0 ? columns [i].customDraw : firstCustomDraw;

        if (customDraw) {

            auto column = OS.gtk_tree_view_get_column (handle, i);

            auto textRenderer = getTextRenderer (column);

            OS.gtk_tree_view_column_set_cell_data_func (column, textRenderer, null, null, null);

            if (columnCount !is 0) columns [i].customDraw = false;

        }

    }

    firstCustomDraw = false;

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

    if (item is null) {

        OS.gtk_tree_view_set_drag_dest_row(handle, null, OS.GTK_TREE_VIEW_DROP_BEFORE);

        return;

    }

    if (item.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);

    if (item.parent !is this) return;

    Rectangle rect = item.getBounds();

    void* path;

    OS.gtk_widget_realize (handle);

    if (!OS.gtk_tree_view_get_path_at_pos(handle, rect.x, rect.y, &path, null, null, null)) return;

    if (path is null) return;

    int position = before ? OS.GTK_TREE_VIEW_DROP_BEFORE : OS.GTK_TREE_VIEW_DROP_AFTER;

    OS.gtk_tree_view_set_drag_dest_row(handle, path, position);

    OS.gtk_tree_path_free (path );

}



void setItemCount (GtkTreeIter* parentIter, int count) {

    int itemCount = OS.gtk_tree_model_iter_n_children (modelHandle, parentIter);

    if (count is itemCount) return;

    bool isVirtual = (style & SWT.VIRTUAL) !is 0;

    if (!isVirtual) setRedraw (false);

    remove (parentIter, count, itemCount - 1);

    if (isVirtual) {

        for (int i=itemCount; i<count; i++) {

            GtkTreeIter iter;

            OS.gtk_tree_store_append (modelHandle, &iter, parentIter);

            OS.gtk_tree_store_set1 (modelHandle, &iter, ID_COLUMN, cast(void*)-1);

        }

    } else {

        for (int i=itemCount; i<count; i++) {

            new TreeItem (this, parentIter, SWT.NONE, i, true);

        }

    }

    if (!isVirtual) setRedraw (true);

    modelChanged = true;

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

    setItemCount (null, count);

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

    bool fixColumn = showFirstColumn ();

    auto selection = OS.gtk_tree_view_get_selection (handle);

    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

    OS.gtk_tree_selection_select_iter (selection, item.handle);

    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

    if (fixColumn) hideFirstColumn ();

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

    checkWidget();

    if ((style & SWT.SINGLE) !is 0) return;

    bool fixColumn = showFirstColumn ();

    auto selection = OS.gtk_tree_view_get_selection (handle);

    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

    OS.gtk_tree_selection_select_all (selection);

    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

    if (fixColumn) hideFirstColumn ();

}



override void setBackgroundColor (GdkColor* color) {

    super.setBackgroundColor (color);

    OS.gtk_widget_modify_base (handle, 0, color);

}



override void setBackgroundPixmap (GdkPixmap* pixmap) {

    super.setBackgroundPixmap (pixmap);

    auto window = paintWindow ();

    if (window !is null) OS.gdk_window_set_back_pixmap (window, null, true);

}



override int setBounds (int x, int y, int width, int height, bool move, bool resize) {

    int result = super.setBounds (x, y, width, height, move, resize);

    /*

    * Bug on GTK.  The tree view sometimes does not get a paint

    * event or resizes to a one pixel square when resized in a new

    * shell that is not visible after any event loop has been run.  The

    * problem is intermittent. It doesn't seem to happen the first time

    * a new shell is created. The fix is to ensure the tree view is realized

    * after it has been resized.

    */

    OS.gtk_widget_realize (handle);

    /*

    * Bug in GTK.  An empty GtkTreeView fails to repaint the focus rectangle

    * correctly when resized on versions before 2.6.0.  The fix is to force

    * the widget to redraw.

    */

    if (OS.GTK_VERSION < OS.buildVERSION (2, 6, 0) && OS.gtk_tree_model_iter_n_children (modelHandle, null) is 0) {

        redraw (false);

    }

    return result;

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

    // SWT extension: allow null for zero length string

    //if (order is null) error (SWT.ERROR_NULL_ARGUMENT);

    if (columnCount is 0) {

        if (order.length > 0) error (SWT.ERROR_INVALID_ARGUMENT);

        return;

    }

    if (order.length !is columnCount) error (SWT.ERROR_INVALID_ARGUMENT);

    bool [] seen = new bool [columnCount];

    for (int i = 0; i<order.length; i++) {

        int index = order [i];

        if (index < 0 || index >= columnCount) error (SWT.ERROR_INVALID_RANGE);

        if (seen [index]) error (SWT.ERROR_INVALID_ARGUMENT);

        seen [index] = true;

    }

    void* baseColumn;

    for (int i=0; i<order.length; i++) {

        auto column = columns [order [i]].handle;

        OS.gtk_tree_view_move_column_after (handle, column, baseColumn);

        baseColumn = column;

    }

}



override void setFontDescription (PangoFontDescription* font) {

    super.setFontDescription (font);

    TreeColumn[] columns = getColumns ();

    for (int i = 0; i < columns.length; i++) {

        if (columns[i] !is null) {

            columns[i].setFontDescription (font);

        }

    }

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

    OS.gtk_tree_view_set_headers_visible (handle, show);

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

    checkWidget();

    OS.gtk_tree_view_set_rules_hint (handle, show);

}



override void setParentBackground () {

    super.setParentBackground ();

    auto window = paintWindow ();

    if (window !is null) OS.gdk_window_set_back_pixmap (window, null, true);

}



override void setParentWindow (GtkWidget* widget) {

    auto window = eventWindow ();

    OS.gtk_widget_set_parent_window (widget, window);

}



void setScrollWidth (GtkTreeViewColumn* column, TreeItem item) {

    if (columnCount !is 0 || currentItem is item) return;

    /*

    * Use GTK_TREE_VIEW_COLUMN_GROW_ONLY on GTK versions < 2.3.2

    * because fixed_height_mode is not supported.

    */

    if (((style & SWT.VIRTUAL) !is 0) && OS.GTK_VERSION < OS.buildVERSION (2, 3, 2)) return;

    int width = OS.gtk_tree_view_column_get_fixed_width (column);

    int itemWidth = calculateWidth (column, cast(GtkTreeIter*)item.handle, true);

    if (width < itemWidth) {

        OS.gtk_tree_view_column_set_fixed_width (column, itemWidth);

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

    // SWT extension: allow null for zero length string

    //if (items is null) error (SWT.ERROR_NULL_ARGUMENT);

    deselectAll ();

    ptrdiff_t length = items.length;

    if (length is 0 || ((style & SWT.SINGLE) !is 0 && length > 1)) return;

    bool fixColumn = showFirstColumn ();

    auto selection = OS.gtk_tree_view_get_selection (handle);

    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

    bool first = true;

    for (int i = 0; i < length; i++) {

        TreeItem item = items [i];

        if (item is null) continue;

        if (item.isDisposed ()) break;

        if (item.parent !is this) continue;

        auto path = OS.gtk_tree_model_get_path (modelHandle, item.handle);

        showItem (path, false);

        if (first) {

            OS.gtk_tree_view_set_cursor (handle, path, null, false);

        }

        OS.gtk_tree_selection_select_iter (selection, item.handle);

        OS.gtk_tree_path_free (path);

        first = false;

    }

    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);

    if (fixColumn) hideFirstColumn ();

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

    if (sortColumn !is null && !sortColumn.isDisposed()) {

        OS.gtk_tree_view_column_set_sort_indicator (sortColumn.handle, false);

    }

    sortColumn = column;

    if (sortColumn !is null && sortDirection !is SWT.NONE) {

        OS.gtk_tree_view_column_set_sort_indicator (sortColumn.handle, true);

        OS.gtk_tree_view_column_set_sort_order (sortColumn.handle, sortDirection is SWT.DOWN ? 0 : 1);

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

public void setSortDirection  (int direction) {

    checkWidget ();

    if (direction !is SWT.UP && direction !is SWT.DOWN && direction !is SWT.NONE) return;

    sortDirection = direction;

    if (sortColumn is null || sortColumn.isDisposed ()) return;

    if (sortDirection is SWT.NONE) {

        OS.gtk_tree_view_column_set_sort_indicator (sortColumn.handle, false);

    } else {

        OS.gtk_tree_view_column_set_sort_indicator (sortColumn.handle, true);

        OS.gtk_tree_view_column_set_sort_order (sortColumn.handle, sortDirection is SWT.DOWN ? 0 : 1);

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

    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);

    if (item.isDisposed ()) error(SWT.ERROR_INVALID_ARGUMENT);

    if (item.parent !is this) return;

    auto path = OS.gtk_tree_model_get_path (modelHandle, item.handle);

    showItem (path, false);

    OS.gtk_tree_view_scroll_to_cell (handle, path, null, true, 0f, 0f);

    if (OS.GTK_VERSION < OS.buildVERSION (2, 8, 0)) {

        /*

        * Bug in GTK.  According to the documentation, gtk_tree_view_scroll_to_cell

        * should vertically scroll the cell to the top if use_align is true and row_align is 0.

        * However, prior to version 2.8 it does not scroll at all.  The fix is to determine

        * the new location and use gtk_tree_view_scroll_to_point.

        * If the widget is a pinhead, calling gtk_tree_view_scroll_to_point

        * will have no effect. Therefore, it is still neccessary to call

        * gtk_tree_view_scroll_to_cell.

        */

        OS.gtk_widget_realize (handle);

        GdkRectangle cellRect;

        OS.gtk_tree_view_get_cell_area (handle, path, null, &cellRect);

        int tx, ty;

        OS.gtk_tree_view_widget_to_tree_coords(handle, cellRect.x, cellRect.y, &tx, &ty);

        OS.gtk_tree_view_scroll_to_point (handle, -1, ty);

    }

    OS.gtk_tree_path_free (path);

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

    if (column.isDisposed()) error(SWT.ERROR_INVALID_ARGUMENT);

    if (column.parent !is this) return;

    /*

    * This code is intentionally commented. According to the

    * documentation, gtk_tree_view_scroll_to_cell should scroll the

    * minimum amount to show the column but instead it scrolls strangely.

    */

    //OS.gtk_tree_view_scroll_to_cell (handle, 0, column.handle, false, 0, 0);

    OS.gtk_widget_realize (handle);

    GdkRectangle cellRect;

    OS.gtk_tree_view_get_cell_area (handle, null, column.handle, &cellRect);

    GdkRectangle visibleRect;

    OS.gtk_tree_view_get_visible_rect (handle, &visibleRect);

    if (cellRect.x < visibleRect.x) {

        OS.gtk_tree_view_scroll_to_point (handle, cellRect.x, -1);

    } else {

        int width = Math.min (visibleRect.width, cellRect.width);

        if (cellRect.x + width > visibleRect.x + visibleRect.width) {

            int tree_x = cellRect.x + width - visibleRect.width;

            OS.gtk_tree_view_scroll_to_point (handle, tree_x, -1);

        }

    }

}



bool showFirstColumn () {

    /*

    * Bug in GTK.  If no columns are visible, changing the selection

    * will fail.  The fix is to temporarily make a column visible.

    */

    int columnCount = Math.max (1, this.columnCount);

    for (int i=0; i<columnCount; i++) {

        auto column = OS.gtk_tree_view_get_column (handle, i);

        if (OS.gtk_tree_view_column_get_visible (column)) return false;

    }

    auto firstColumn = OS.gtk_tree_view_get_column (handle, 0);

    OS.gtk_tree_view_column_set_visible (firstColumn, true);

    return true;

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

    checkWidget();

    TreeItem [] items = getSelection ();

    if (items.length !is 0 && items [0] !is null) showItem (items [0]);

}



void showItem (GtkTreePath* path, bool scroll) {

    int depth = OS.gtk_tree_path_get_depth (path);

    if (depth > 1) {

        auto indicesPtr = OS.gtk_tree_path_get_indices (path);

        int [] indices = indicesPtr[ 0 .. depth - 1];

        auto tempPath = OS.gtk_tree_path_new ();

        for (int i=0; i<indices.length; i++) {

            OS.gtk_tree_path_append_index (tempPath, indices [i]);

            OS.gtk_tree_view_expand_row (handle, tempPath, false);

        }

        OS.gtk_tree_path_free (tempPath);

    }

    if (scroll) {

        OS.gtk_widget_realize (handle);

        GdkRectangle cellRect;

        OS.gtk_tree_view_get_cell_area (handle, path, null, &cellRect);

        bool isHidden = cellRect.y is 0 && cellRect.height is 0;

        int tx, ty;

        OS.gtk_tree_view_widget_to_tree_coords (handle, cellRect.x, cellRect.y, &tx, &ty);

        GdkRectangle visibleRect;

        OS.gtk_tree_view_get_visible_rect (handle, &visibleRect);

        if (!isHidden) {

            if (ty < visibleRect.y || ty + cellRect.height > visibleRect.y + visibleRect.height) {

                isHidden = true;

            }

        }

        if (isHidden) {

            /*

            * This code intentionally commented.

            * Bug in GTK.  According to the documentation, gtk_tree_view_scroll_to_cell

            * should scroll the minimum amount to show the cell if use_align is false.

            * However, what actually happens is the cell is scrolled to the top.

            * The fix is to determine the new location and use gtk_tree_view_scroll_to_point.

            * If the widget is a pinhead, calling gtk_tree_view_scroll_to_point

            * will have no effect. Therefore, it is still neccessary to

            * call gtk_tree_view_scroll_to_cell.

            */

            //  OS.gtk_tree_view_scroll_to_cell (handle, path, 0, depth !is 1, 0.5f, 0.0f);

            if (depth !is 1) {

                OS.gtk_tree_view_scroll_to_cell (handle, path, null, true, 0.5f, 0.0f);

            } else {

                if (ty < visibleRect.y ) {

                    OS.gtk_tree_view_scroll_to_point (handle, -1, ty);

                } else {

                    int height = Math.min (visibleRect.height, cellRect.height);

                    if (ty + height > visibleRect.y + visibleRect.height) {

                        OS.gtk_tree_view_scroll_to_point (handle, -1, ty + cellRect.height - visibleRect.height);

                    }

                }

            }

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

    if (item.parent !is this) return;

    auto path = OS.gtk_tree_model_get_path (modelHandle, item.handle);

    showItem (path, true);

    OS.gtk_tree_path_free (path);

}



override void treeSelectionProc (

    GtkTreeModel *model,

    GtkTreePath *path,

    GtkTreeIter *iter,

    int[] selection,

    int length_)

{

    if (selection !is null) {

        int index;

        OS.gtk_tree_model_get1 (modelHandle, iter, ID_COLUMN, cast(void**)&index);

        selection [length_] = index;

    }

}



override void updateScrollBarValue (ScrollBar bar) {

    super.updateScrollBarValue (bar);

    /*

    * Bug in GTK. Scrolling changes the XWindow position

    * and makes the child widgets appear to scroll even

    * though when queried their position is unchanged.

    * The fix is to queue a resize event for each child to

    * force the position to be corrected.

    */

    auto parentHandle = parentingHandle ();

    auto list = OS.gtk_container_get_children (parentHandle);

    if (list is null) return;

    auto temp = list;

    while (temp !is null) {

        auto widget = OS.g_list_data (temp);

        if (widget !is null) OS.gtk_widget_queue_resize  (widget);

        temp = OS.g_list_next (temp);

    }

    OS.g_list_free (list);

}



}

