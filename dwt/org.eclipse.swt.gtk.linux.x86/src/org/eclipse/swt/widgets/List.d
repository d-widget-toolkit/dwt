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
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.widgets.Scrollable;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Display;
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
    alias Scrollable.dragDetect dragDetect;
    alias Scrollable.setBackgroundColor setBackgroundColor;
    alias Scrollable.setBounds setBounds;

    GtkWidget* modelHandle;

    static const int TEXT_COLUMN = 0;
    CallbackData treeSelectionProcCallbackData;

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
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    char* buffer = string.toStringzValidPtr();
    GtkTreeIter iter;
    OS.gtk_list_store_append (cast(GtkListStore*)modelHandle, &iter);
    OS.gtk_list_store_set1 (cast(GtkListStore*)modelHandle, &iter, TEXT_COLUMN, buffer);
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
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    int count = OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null);
    if (!(0 <= index && index <= count)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    char* buffer = string.toStringzValidPtr();
    GtkTreeIter iter;
    /*
    * Feature in GTK.  It is much faster to append to a list store
    * than to insert at the end using gtk_list_store_insert().
    */
    if (index is count) {
        OS.gtk_list_store_append (cast(GtkListStore*)modelHandle, &iter);
    } else {
        OS.gtk_list_store_insert (cast(GtkListStore*)modelHandle, &iter, index);
    }
    OS.gtk_list_store_set1 (cast(GtkListStore*)modelHandle, &iter, TEXT_COLUMN, buffer);
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
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
}

static int checkStyle (int style) {
    return checkBits (style, SWT.SINGLE, SWT.MULTI, 0, 0, 0, 0);
}

override void createHandle (int index) {
    state |= HANDLE;
    fixedHandle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (fixedHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_fixed_set_has_window (cast(GtkFixed*)fixedHandle, true);
    scrolledHandle = cast(GtkWidget*)OS.gtk_scrolled_window_new (null, null);
    if (scrolledHandle is null) error (SWT.ERROR_NO_HANDLES);
    /*
    * Columns:
    * 0 - text
    */
    size_t[] types = [OS.G_TYPE_STRING ()];
    modelHandle = cast(GtkWidget*)OS.gtk_list_store_newv (cast(int)/*64bit*/types.length, types.ptr);
    if (modelHandle is null) error (SWT.ERROR_NO_HANDLES);
    handle = OS.gtk_tree_view_new_with_model (modelHandle);
    if (handle is null) error (SWT.ERROR_NO_HANDLES);
    auto textRenderer = OS.gtk_cell_renderer_text_new ();
    if (textRenderer is null) error (SWT.ERROR_NO_HANDLES);
    auto columnHandle = OS.gtk_tree_view_column_new ();
    if (columnHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_tree_view_column_pack_start (cast(GtkTreeViewColumn*)columnHandle, textRenderer, true);
    OS.gtk_tree_view_column_add_attribute (cast(GtkTreeViewColumn*)columnHandle, textRenderer, OS.text.ptr, TEXT_COLUMN);
    OS.gtk_tree_view_insert_column (cast(GtkTreeView*)handle, columnHandle, index);
    OS.gtk_container_add (cast(GtkContainer*)fixedHandle, scrolledHandle);
    OS.gtk_container_add (cast(GtkContainer*)scrolledHandle, handle);

    int mode = (style & SWT.MULTI) !is 0 ? OS.GTK_SELECTION_MULTIPLE : OS.GTK_SELECTION_BROWSE;
    auto selectionHandle = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.gtk_tree_selection_set_mode (selectionHandle, mode);
    OS.gtk_tree_view_set_headers_visible (cast(GtkTreeView*)handle, false);
    int hsp = (style & SWT.H_SCROLL) !is 0 ? OS.GTK_POLICY_AUTOMATIC : OS.GTK_POLICY_NEVER;
    int vsp = (style & SWT.V_SCROLL) !is 0 ? OS.GTK_POLICY_AUTOMATIC : OS.GTK_POLICY_NEVER;
    OS.gtk_scrolled_window_set_policy (cast(GtkScrolledWindow*)scrolledHandle, hsp, vsp);
    if ((style & SWT.BORDER) !is 0) OS.gtk_scrolled_window_set_shadow_type (cast(GtkScrolledWindow*)scrolledHandle, OS.GTK_SHADOW_ETCHED_IN);
    /*
    * Bug in GTK. When a treeview is the child of an override shell,
    * and if the user has ever invokes the interactive search field,
    * and the treeview is disposed on a focus out event, it segment
    * faults. The fix is to disable the search field in an override
    * shell.
    */
    if ((getShell ().style & SWT.ON_TOP) !is 0) {
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
            OS.gtk_tree_view_set_search_column (cast(GtkTreeView*)handle, -1);
        } else {
            OS.gtk_tree_view_set_enable_search (cast(GtkTreeView*)handle, false);
        }
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

override void deregister() {
    super.deregister ();
    display.removeWidget (cast(GtkWidget*)OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle));
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
    checkWidget();
    if (!(0 <= index && index < OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null)))  return;
    GtkTreeIter iter;
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
    OS.gtk_tree_selection_unselect_iter (selection, &iter);
    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
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
    checkWidget();
    if (start < 0 && end < 0) return;
    int count = OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null);
    if (start >= count && end >= count) return;
    start = Math.min (count - 1, Math.max (0, start));
    end = Math.min (count - 1, Math.max (0, end));
    GtkTreeIter iter;
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    for (int index=start; index<=end; index++) {
        OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
        OS.gtk_tree_selection_unselect_iter (selection, &iter);
    }
    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
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
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (indices is null) error (SWT.ERROR_NULL_ARGUMENT);
    GtkTreeIter iter;
    int count = OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null);
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    for (int i=0; i<indices.length; i++) {
        int index = indices [i];
        if (index < 0 || index > count - 1) continue;
        OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
        OS.gtk_tree_selection_unselect_iter (selection, &iter);
    }
    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
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
    checkWidget();
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    OS.gtk_tree_selection_unselect_all (selection);
    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
}

override bool dragDetect (int x, int y, bool filter, bool* consume) {
    bool selected = false;
    if (filter) {
        GtkTreePath* path;
        if (OS.gtk_tree_view_get_path_at_pos (cast(GtkTreeView*)handle, x, y, &path, null, null, null)) {
            if (path !is null) {
                auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
                if (OS.gtk_tree_selection_path_is_selected (selection, path)) selected = true;
                OS.gtk_tree_path_free (path);
            }
        } else {
            return false;
        }
    }
    bool dragDetect = super.dragDetect (x, y, filter, consume);
    if (dragDetect && selected && consume !is null) *consume = true;
    return dragDetect;
}

override GdkDrawable* eventWindow () {
    return paintWindow ();
}

override GdkColor* getBackgroundColor () {
    return getBaseColor ();
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
    checkWidget();
    GtkTreePath * path;
    OS.gtk_tree_view_get_cursor (cast(GtkTreeView*)handle, &path, null);
    if (path is null) return -1;
    int* indices = OS.gtk_tree_path_get_indices (path);
    int index;
    if (indices !is null) index = indices[0];
    OS.gtk_tree_path_free (path);
    return index;
}

override
GdkColor* getForegroundColor () {
    return getTextColor ();
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
    checkWidget();
    if (!(0 <= index && index < OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null)))  {
        error (SWT.ERROR_INVALID_RANGE);
    }
    char* ptr;
    GtkTreeIter iter;
    OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
    OS.gtk_tree_model_get1 (cast(GtkTreeStore*)modelHandle, &iter, 0, cast(void**)&ptr );
    if (ptr is null) return null;
    String res = fromStringz( ptr )._idup();
    OS.g_free (ptr);
    return res;
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
    checkWidget();
    return OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null);
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
    checkWidget();
    int itemCount = OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null);
    auto column = OS.gtk_tree_view_get_column (cast(GtkTreeView*)handle, 0);
    if (itemCount is 0) {
        int w, h;
        OS.gtk_tree_view_column_cell_get_size (cast(GtkTreeViewColumn*)column, null, null, null, &w, &h);
        return h;
    } else {
        GtkTreeIter iter;
        OS.gtk_tree_model_get_iter_first (cast(GtkTreeStore*)modelHandle, &iter);
        OS.gtk_tree_view_column_cell_set_cell_data (cast(GtkTreeViewColumn*)column, modelHandle, &iter, false, false);
        int w, h;
        OS.gtk_tree_view_column_cell_get_size (cast(GtkTreeViewColumn*)column, null, null, null, &w, &h);
        return h;
    }
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
    checkWidget();
    int count = OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null);
    char* ptr;
    String [] result = new String[]( count );
    GtkTreeIter iter;
    for (int index=0; index<count; index++) {
        OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
        OS.gtk_tree_model_get1 (cast(GtkTreeStore*)modelHandle, &iter, 0, cast(void**)&ptr);
        if (ptr !is null) {
            String res = fromStringz( ptr )._idup();
            OS.g_free (ptr);
            result [index] = res;
        }
    }
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
    checkWidget();
    int [] indices = getSelectionIndices ();
    String [] result = new String[](indices.length);
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
    checkWidget();
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    if (OS.GTK_VERSION < OS.buildVERSION (2, 2, 0)) {
        display.treeSelectionLength = 0;
        display.treeSelection = null;
        display.doTreeSelectionProcConnect( &treeSelectionProcCallbackData, handle, selection );
        return display.treeSelectionLength;
    }
    return OS.gtk_tree_selection_count_selected_rows (selection);
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
    checkWidget();
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    if (OS.GTK_VERSION < OS.buildVERSION (2, 2, 0)) {
        int itemCount = OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null);
        display.treeSelectionLength  = 0;
        display.treeSelection = new int [itemCount];
        display.doTreeSelectionProcConnect( &treeSelectionProcCallbackData, handle, selection );
        if (display.treeSelectionLength is 0) return -1;
        return display.treeSelection [0];
    }
    /*
    * Bug in GTK.  gtk_tree_selection_get_selected_rows() segmentation faults
    * in versions smaller than 2.2.4 if the model is NULL.  The fix is
    * to give a valid pointer instead.
    */
    int dummy;
    int* model = OS.GTK_VERSION < OS.buildVERSION (2, 2, 4) ? &dummy : null;
    auto list = OS.gtk_tree_selection_get_selected_rows (selection, cast(void**)model);
    if (list !is null) {
        int count = OS.g_list_length (list);
        int index;
        for (int i=0; i<count; i++) {
            auto data = OS.g_list_nth_data (list, i);
            auto indices = OS.gtk_tree_path_get_indices (data);
            if (indices !is null) {
                index = indices[0];
                break;
            }
        }
        OS.g_list_free (list);
        return index;
    }
    return -1;
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
    checkWidget();
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    if (OS.GTK_VERSION < OS.buildVERSION (2, 2, 0)) {
        int itemCount = OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null);
        display.treeSelectionLength  = 0;
        display.treeSelection = new int [itemCount];
        display.doTreeSelectionProcConnect( &treeSelectionProcCallbackData, handle, selection );
        int [] result = new int [display.treeSelectionLength];
        for (int i = 0; i < display.treeSelectionLength; i++) {
            result[i] = display.treeSelection[i];
        }
        return result;
    }
    /*
    * Bug in GTK.  gtk_tree_selection_get_selected_rows() segmentation faults
    * in versions smaller than 2.2.4 if the model is NULL.  The fix is
    * to give a valid pointer instead.
    */
    int dummy;
    int* model = OS.GTK_VERSION < OS.buildVERSION (2, 2, 4) ? &dummy : null;
    auto list = OS.gtk_tree_selection_get_selected_rows (selection, cast(void**)model);
    if (list !is null) {
        int count = OS.g_list_length (list);
        int [] treeSelection = new int [count];
        int len = 0;
        for (int i=0; i<count; i++) {
            auto data = OS.g_list_nth_data (list, i);
            auto indices = OS.gtk_tree_path_get_indices (data);
            if (indices !is null) {
                treeSelection [len] = indices [0];
                len++;
            }
        }
        OS.g_list_free (list);
        int [] result = treeSelection[0..len].dup;
        return result;
    }
    return [0];
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
    checkWidget();
    GtkTreePath* path;
    OS.gtk_widget_realize (handle);
    if (!OS.gtk_tree_view_get_path_at_pos (cast(GtkTreeView*)handle, 1, 1, &path, null, null, null)) return 0;
    if (path is null) return 0;
    auto indices = OS.gtk_tree_path_get_indices (path);
    int index;
    if (indices !is null) index = indices[0];
    OS.gtk_tree_path_free (path);
    return index;
}

override int gtk_changed (GtkWidget* widget) {
    postEvent (SWT.Selection);
    return 0;
}

override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* gdkEvent) {
    auto result = super.gtk_button_press_event (widget, gdkEvent);
    if (result !is 0) return result;
    /*
    * Feature in GTK.  In a multi-select list view, when multiple items are already
    * selected, the selection state of the item is toggled and the previous selection
    * is cleared. This is not the desired behaviour when bringing up a popup menu.
    * Also, when an item is reselected with the right button, the tree view issues
    * an unwanted selection event. The workaround is to detect that case and not
    * run the default handler when the item is already part of the current selection.
    */
    int button = gdkEvent.button;
    if (button is 3 && gdkEvent.type is OS.GDK_BUTTON_PRESS) {
        GtkTreePath* path;
        if (OS.gtk_tree_view_get_path_at_pos (cast(GtkTreeView*)handle, cast(int)gdkEvent.x, cast(int)gdkEvent.y, &path, null, null, null)) {
            if (path !is null) {
                auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
                if (OS.gtk_tree_selection_path_is_selected (selection, path)) result = 1;
                OS.gtk_tree_path_free (path);
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
        GtkTreePath* path;
        if (OS.gtk_tree_view_get_path_at_pos (cast(GtkTreeView*)handle, cast(int)gdkEvent.x, cast(int)gdkEvent.y, &path, null, null, null)) {
            if (path  !is null) {
                auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
                OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
                OS.gtk_tree_view_set_cursor (cast(GtkTreeView*)handle, path, null, false);
                OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
                OS.gtk_tree_path_free (path);
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
                postEvent (SWT.DefaultSelection);
                break;
            }
            default:
        }
    }
    return result;
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

override void gtk_row_activated (GtkTreeView* tree, GtkTreePath* path, GtkTreeViewColumn* column){
    postEvent (SWT.DefaultSelection);
}

override void hookEvents () {
    super.hookEvents();
    auto selection = OS.gtk_tree_view_get_selection(cast(GtkTreeView*)handle);
    OS.g_signal_connect_closure (selection, OS.changed.ptr, display.closures [CHANGED], false);
    OS.g_signal_connect_closure (handle, OS.row_activated.ptr, display.closures [ROW_ACTIVATED], false);
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
    checkWidget();
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
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    String [] items = getItems ();
    for (int i=start; i<items.length; i++) {
        if (items [i].equals (string)) return i;
    }
    return -1;
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
    checkWidget();
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    char* buffer = toStringz(Integer.toString(index));
    auto path = OS.gtk_tree_path_new_from_string (buffer);
    bool answer = cast(bool)OS.gtk_tree_selection_path_is_selected (selection, path);
    OS.gtk_tree_path_free (path);
    return answer;
}

override GdkDrawable* paintWindow () {
    OS.gtk_widget_realize (handle);
    return OS.gtk_tree_view_get_bin_window (cast(GtkTreeView*)handle);
}

override void register () {
    super.register ();
    display.addWidget (cast(GtkWidget*)OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle), this);
}

override void releaseWidget () {
    super.releaseWidget ();
    if (modelHandle !is null) OS.g_object_unref (modelHandle);
    modelHandle = null;
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
    checkWidget();
    if (!(0 <= index && index < OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null)))  {
        error (SWT.ERROR_INVALID_RANGE);
    }
    GtkTreeIter iter;
    OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    OS.gtk_list_store_remove (cast(GtkListStore*)modelHandle, &iter);
    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
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
    checkWidget();
    if (start > end) return;
    int count =  OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null);
    if (!(0 <= start && start <= end && end < count)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    GtkTreeIter iter;
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    for (int index=end; index>=start; index--) {
        OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
        OS.gtk_list_store_remove (cast(GtkListStore*)modelHandle, &iter);
    }
    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
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
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    int index = indexOf (string, 0);
    if (index is -1) error (SWT.ERROR_INVALID_ARGUMENT);
    remove (index);
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
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (indices is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (indices.length is 0) return;
    int [] newIndices = new int []( indices.length );
    System.arraycopy (indices, 0, newIndices, 0, indices.length);
    sort (newIndices);
    int start = newIndices [newIndices.length - 1], end = newIndices [0];
    int count = getItemCount();
    if (!(0 <= start && start <= end && end < count)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    GtkTreeIter iter;
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    int last = -1;
    for (int i=0; i<newIndices.length; i++) {
        int index = newIndices [i];
        if (index !is last) {
            OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
            OS.gtk_list_store_remove (cast(GtkListStore*)modelHandle, &iter);
            last = index;
        }
    }
    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
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
    checkWidget();
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    OS.gtk_list_store_clear (cast(GtkListStore*)modelHandle);
    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
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
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Selection, listener);
    eventTable.unhook (SWT.DefaultSelection,listener);
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
    checkWidget();
    if (!(0 <= index && index < OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null)))  return;
    GtkTreeIter iter;
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
    OS.gtk_tree_selection_select_iter (selection, &iter);
    if ((style & SWT.SINGLE) !is 0) {
        auto path = OS.gtk_tree_model_get_path (cast(GtkTreeStore*)modelHandle, &iter);
        OS.gtk_tree_view_set_cursor (cast(GtkTreeView*)handle, path, null, false);
        OS.gtk_tree_path_free (path);
    }
    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
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
    int count = OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null);
    if (count is 0 || start >= count) return;
    start = Math.max (0, start);
    end = Math.min (end, count - 1);
    GtkTreeIter iter;
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    for (int index=start; index<=end; index++) {
        OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
        OS.gtk_tree_selection_select_iter (selection, &iter);
        if ((style & SWT.SINGLE) !is 0) {
            auto path = OS.gtk_tree_model_get_path (cast(GtkTreeStore*)modelHandle, &iter);
            OS.gtk_tree_view_set_cursor (cast(GtkTreeView*)handle, path, null, false);
            OS.gtk_tree_path_free (path);
        }
    }
    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
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
    // SWT extension: allow null for zero length string
    //if (indices is null) error (SWT.ERROR_NULL_ARGUMENT);
    ptrdiff_t length = indices.length;
    if (length is 0 || ((style & SWT.SINGLE) !is 0 && length > 1)) return;
    GtkTreeIter iter;
    int count = OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null);
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    for (int i=0; i<length; i++) {
        int index = indices [i];
        if (!(0 <= index && index < count)) continue;
        OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
        OS.gtk_tree_selection_select_iter (selection, &iter);
        if ((style & SWT.SINGLE) !is 0) {
            auto path = OS.gtk_tree_model_get_path (cast(GtkTreeStore*)modelHandle, &iter);
            OS.gtk_tree_view_set_cursor (cast(GtkTreeView*)handle, path, null, false);
            OS.gtk_tree_path_free (path);
        }
    }
    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
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
    checkWidget();
    if ((style & SWT.SINGLE) !is 0) return;
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    OS.gtk_tree_selection_select_all (selection);
    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
}

void selectFocusIndex (int index) {
    /*
    * Note that this method both selects and sets the focus to the
    * specified index, so any previous selection in the list will be lost.
    * gtk does not provide a way to just set focus to a specified list item.
    */
    int count = OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null);
    if (!(0 <= index && index < count))  return;
    GtkTreeIter iter;
    OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
    auto path = OS.gtk_tree_model_get_path (cast(GtkTreeStore*)modelHandle, &iter);
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    OS.gtk_tree_view_set_cursor (cast(GtkTreeView*)handle, path, null, false);
    /*
    * Bug in GTK. For some reason, when an event loop is run from
    * within a key pressed handler and a dialog is displayed that
    * contains a GtkTreeView,  gtk_tree_view_set_cursor() does
    * not set the cursor or select the item.  The fix is to select the
    * item with gtk_tree_selection_select_iter() as well.
    *
    * NOTE: This happens in GTK 2.2.1 and is fixed in GTK 2.2.4.
    */
    OS.gtk_tree_selection_select_iter (selection, &iter);
    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    OS.gtk_tree_path_free (path);
}

override void setBackgroundColor (GdkColor* color) {
    super.setBackgroundColor (color);
    OS.gtk_widget_modify_base (handle, 0, color);
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
    if (OS.GTK_VERSION < OS.buildVERSION (2, 6, 0) && OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null) is 0) {
        redraw (false);
    }
    return result;
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
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (!(0 <= index && index < OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null)))  {
        error (SWT.ERROR_INVALID_RANGE);
    }
    GtkTreeIter iter;
    OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
    char* buffer = string.toStringzValidPtr();
    OS.gtk_list_store_set1 (cast(GtkListStore*)modelHandle, &iter, TEXT_COLUMN, buffer);
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
    checkWidget();
    // SWT extension, allow null a null length list.
    //if (items is null) error (SWT.ERROR_NULL_ARGUMENT);
    for (int i=0; i<items.length; i++) {
        if (items [i] is null) error (SWT.ERROR_INVALID_ARGUMENT);
    }
    auto selection = OS.gtk_tree_view_get_selection (cast(GtkTreeView*)handle);
    OS.g_signal_handlers_block_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    OS.gtk_list_store_clear (cast(GtkListStore*)modelHandle);
    OS.g_signal_handlers_unblock_matched (selection, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    GtkTreeIter iter;
    for (int i=0; i<items.length; i++) {
        String string = items [i];
        char* buffer = toStringz(string);
        OS.gtk_list_store_append (cast(GtkListStore*)modelHandle, &iter);
        OS.gtk_list_store_set1 (cast(GtkListStore*)modelHandle, &iter, TEXT_COLUMN, buffer);
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
    selectFocusIndex (index);
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
    int count = OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null);
    if (count is 0 || start >= count) return;
    start = Math.max (0, start);
    end = Math.min (end, count - 1);
    selectFocusIndex (start);
    if ((style & SWT.MULTI) !is 0) {
        select (start, end);
    }
    showSelection ();
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
public void setSelection(int[] indices) {
    checkWidget ();
    // SWT extension: allow null for zero length string
    //if (indices is null) error (SWT.ERROR_NULL_ARGUMENT);
    deselectAll ();
    ptrdiff_t length = indices.length;
    if (length is 0 || ((style & SWT.SINGLE) !is 0 && length > 1)) return;
    selectFocusIndex (indices [0]);
    if ((style & SWT.MULTI) !is 0) {
        select (indices);
    }
    showSelection ();
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
    // SWT extension: allow null for zero length string
    //if (items is null) error (SWT.ERROR_NULL_ARGUMENT);
    deselectAll ();
    ptrdiff_t length = items.length;
    if (length is 0 || ((style & SWT.SINGLE) !is 0 && length > 1)) return;
    bool first = true;
    for (int i = 0; i < length; i++) {
        int index = 0;
        String string = items [i];
        if (string !is null) {
            while ((index = indexOf (string, index)) !is -1) {
                if ((style & SWT.MULTI) !is 0) {
                    if (first) {
                        first = false;
                        selectFocusIndex (index);
                    } else {
                        select (index);
                    }
                } else {
                    selectFocusIndex (index);
                    break;
                }
                index++;
            }
        }
    }
    showSelection ();
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
    checkWidget();
    if (!(0 <= index && index < OS.gtk_tree_model_iter_n_children (cast(GtkTreeStore*)modelHandle, null))) return;
    GtkTreeIter iter;
    OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
    auto path = OS.gtk_tree_model_get_path (cast(GtkTreeStore*)modelHandle, &iter);
    OS.gtk_tree_view_scroll_to_cell (cast(GtkTreeView*)handle, path, null, true, 0, 0);
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
        OS.gtk_tree_view_get_cell_area (cast(GtkTreeView*)handle, path, null, &cellRect);
        int tx, ty;
        OS.gtk_tree_view_widget_to_tree_coords(cast(GtkTreeView*)handle, cellRect.x, cellRect.y, &tx, &ty);
        OS.gtk_tree_view_scroll_to_point (cast(GtkTreeView*)handle, -1, ty);
    }
    OS.gtk_tree_path_free (path);
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
    checkWidget();
    int index = getSelectionIndex ();
    if (index is -1) return;
    GtkTreeIter iter;
    OS.gtk_tree_model_iter_nth_child (cast(GtkTreeStore*)modelHandle, &iter, null, index);
    auto path = OS.gtk_tree_model_get_path (cast(GtkTreeStore*)modelHandle, &iter);
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
//  OS.gtk_tree_view_scroll_to_cell (handle, path, 0, false, 0, 0);
    OS.gtk_widget_realize (handle);
    GdkRectangle visibleRect;
    OS.gtk_tree_view_get_visible_rect (cast(GtkTreeView*)handle, &visibleRect);
    GdkRectangle cellRect;
    OS.gtk_tree_view_get_cell_area (cast(GtkTreeView*)handle, path, null, &cellRect);
    int tx, ty;
    OS.gtk_tree_view_widget_to_tree_coords(cast(GtkTreeView*)handle, cellRect.x, cellRect.y, &tx, &ty);
    if (ty < visibleRect.y ) {
        OS.gtk_tree_view_scroll_to_cell (cast(GtkTreeView*)handle, path, null, true, 0f, 0f);
        OS.gtk_tree_view_scroll_to_point (cast(GtkTreeView*)handle, -1, ty);
    } else {
        int height = Math.min (visibleRect.height, cellRect.height);
        if (ty + height > visibleRect.y + visibleRect.height) {
            OS.gtk_tree_view_scroll_to_cell (cast(GtkTreeView*)handle, path, null, true, 1f, 0f);
            ty += cellRect.height - visibleRect.height;
            OS.gtk_tree_view_scroll_to_point (cast(GtkTreeView*)handle, -1, ty);
        }
    }
    OS.gtk_tree_path_free (path);
}

override void treeSelectionProc (GtkTreeModel *model, GtkTreePath *path, GtkTreeIter *iter, int[] selection, int length_) {
    if (selection !is null) {
        auto indices = OS.gtk_tree_path_get_indices (path);
        if (indices !is null) {
            selection [length_] = indices[0];
        }
    }
}

}
