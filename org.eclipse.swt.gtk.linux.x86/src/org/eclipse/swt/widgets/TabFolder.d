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
module org.eclipse.swt.widgets.TabFolder;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.TabItem;
import org.eclipse.swt.widgets.ImageList;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;
import java.lang.all;

/**
 * Instances of this class implement the notebook user interface
 * metaphor.  It allows the user to select a notebook page from
 * set of pages.
 * <p>
 * The item children that may be added to instances of this class
 * must be of type <code>TabItem</code>.
 * <code>Control</code> children are created and then set into a
 * tab item using <code>TabItem#setControl</code>.
 * </p><p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to set a layout on it.
 * </p><p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>TOP, BOTTOM</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles TOP and BOTTOM may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#tabfolder">TabFolder, TabItem snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class TabFolder : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.createHandle createHandle;
    alias Composite.mnemonicHit mnemonicHit;
    alias Composite.mnemonicMatch mnemonicMatch;
    alias Composite.setBounds setBounds;
    alias Composite.setForegroundColor setForegroundColor;

    TabItem [] items;
    ImageList imageList;

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
    super (parent, checkStyle (style));
}

static int checkStyle (int style) {
    style = checkBits (style, SWT.TOP, SWT.BOTTOM, 0, 0, 0, 0);
    /*
    * Even though it is legal to create this widget
    * with scroll bars, they serve no useful purpose
    * because they do not automatically scroll the
    * widget's client area.  The fix is to clear
    * the SWT style.
    */
    return style & ~(SWT.H_SCROLL | SWT.V_SCROLL);
}

protected override void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

override GtkStyle* childStyle () {
    auto rcStyle = OS.gtk_widget_get_modifier_style (handle);
    if ((OS.gtk_rc_style_get_color_flags (rcStyle, 0) & OS.GTK_RC_BG) !is 0) return null;
    OS.gtk_widget_realize (handle);
    return OS.gtk_widget_get_style (handle);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the user changes the receiver's selection, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * When <code>widgetSelected</code> is called, the item field of the event object is valid.
 * <code>widgetDefaultSelected</code> is not called.
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
    TypedListener typedListener = new TypedListener(listener);
    addListener(SWT.Selection,typedListener);
    addListener(SWT.DefaultSelection,typedListener);
}

override GtkWidget* clientHandle () {
    int index = OS.gtk_notebook_get_current_page (handle);
    if (index !is -1 && items [index] !is null) {
        return items [index].pageHandle;
    }
    return handle;
}

public override Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    Point size = super.computeSize (wHint, hHint, changed);
    if (wHint !is SWT.DEFAULT && wHint < 0) wHint = 0;
    if (hHint !is SWT.DEFAULT && hHint < 0) hHint = 0;
    bool scrollable = cast(bool)OS.gtk_notebook_get_scrollable (handle);
    OS.gtk_notebook_set_scrollable (handle, false);
    Point notebookSize = computeNativeSize (handle, wHint, hHint, changed);
    OS.gtk_notebook_set_scrollable (handle, scrollable);
    size.x = Math.max (notebookSize.x, size.x);
    size.y = Math.max (notebookSize.y, size.y);
    return size;
}

public override Rectangle computeTrim (int x, int y, int width, int height) {
    checkWidget();
    forceResize ();
    auto clientHandle = clientHandle ();
    int clientX = OS.GTK_WIDGET_X (clientHandle);
    int clientY = OS.GTK_WIDGET_Y (clientHandle);
    x -= clientX;
    y -= clientY;
    width +=  clientX + clientX;
    if ((style & SWT.BOTTOM) !is 0) {
        int parentHeight = OS.GTK_WIDGET_HEIGHT (handle);
        int clientHeight = OS.GTK_WIDGET_HEIGHT (clientHandle);
        height += parentHeight - clientHeight;
    } else {
        height +=  clientX + clientY;
    }
    return new Rectangle (x, y, width, height);
}

override void createHandle (int index) {
    state |= HANDLE;
    fixedHandle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (fixedHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_fixed_set_has_window (fixedHandle, true);
    handle = cast(GtkWidget*)OS.gtk_notebook_new ();
    if (handle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_container_add (fixedHandle, handle);
    OS.gtk_notebook_set_scrollable (handle, true);
    OS.gtk_notebook_set_show_tabs (handle, true);
    if ((style & SWT.BOTTOM) !is 0) {
        OS.gtk_notebook_set_tab_pos (handle, OS.GTK_POS_BOTTOM);
    }
}

override void createWidget (int index) {
    super.createWidget(index);
    items = new TabItem [4];
}

void createItem (TabItem item, int index) {
    auto list = OS.gtk_container_get_children (handle);
    int itemCount = 0;
    if (list !is null) {
        itemCount = OS.g_list_length (list);
        OS.g_list_free (list);
    }
    if (!(0 <= index && index <= itemCount)) error (SWT.ERROR_INVALID_RANGE);
    if (itemCount is items.length) {
        TabItem [] newItems = new TabItem [items.length + 4];
        System.arraycopy (items, 0, newItems, 0, items.length);
        items = newItems;
    }
    auto boxHandle = OS.gtk_hbox_new (false, 0);
    if (boxHandle is null) error (SWT.ERROR_NO_HANDLES);
    auto labelHandle = OS.gtk_label_new_with_mnemonic (null);
    if (labelHandle is null) error (SWT.ERROR_NO_HANDLES);
    auto imageHandle = OS.gtk_image_new ();
    if (imageHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_container_add (boxHandle, imageHandle);
    OS.gtk_container_add (boxHandle, labelHandle);
    auto pageHandle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (pageHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udSWITCH_PAGE);
    OS.gtk_notebook_insert_page (handle, pageHandle, boxHandle, index);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udSWITCH_PAGE);
    OS.gtk_widget_show (boxHandle);
    OS.gtk_widget_show (labelHandle);
    OS.gtk_widget_show (pageHandle);
    item.state |= HANDLE;
    item.handle = boxHandle;
    item.labelHandle = labelHandle;
    item.imageHandle = imageHandle;
    item.pageHandle = pageHandle;
    System.arraycopy (items, index, items, index + 1, itemCount++ - index);
    items [index] = item;
    if ((state & FOREGROUND) !is 0) {
        item.setForegroundColor (getForegroundColor());
    }
    if ((state & FONT) !is 0) {
        item.setFontDescription (getFontDescription());
    }
    if (itemCount is 1) {
        OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udSWITCH_PAGE);
        OS.gtk_notebook_set_current_page (handle, 0);
        OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udSWITCH_PAGE);
        Event event = new Event();
        event.item = items[0];
        sendEvent (SWT.Selection, event);
        // the widget could be destroyed at this point
    }
}

void destroyItem (TabItem item) {
    int index = 0;
    int itemCount = getItemCount();
    while (index < itemCount) {
        if (items [index] is item) break;
        index++;
    }
    if (index is itemCount) error (SWT.ERROR_ITEM_NOT_REMOVED);
    int oldIndex = OS.gtk_notebook_get_current_page (handle);
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udSWITCH_PAGE);
    OS.gtk_notebook_remove_page (handle, index);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udSWITCH_PAGE);
    System.arraycopy (items, index + 1, items, index, --itemCount - index);
    items [itemCount] = null;
    if (index is oldIndex) {
        int newIndex = OS.gtk_notebook_get_current_page (handle);
        if (newIndex !is -1) {
            Control control = items [newIndex].getControl ();
            if (control !is null && !control.isDisposed ()) {
                control.setBounds (getClientArea());
                control.setVisible (true);
            }
            Event event = new Event ();
            event.item = items [newIndex];
            sendEvent (SWT.Selection, event);
            // the widget could be destroyed at this point
        }
    }
}

override GtkWidget* eventHandle () {
    return handle;
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
public TabItem getItem (int index) {
    checkWidget();
    if (!(0 <= index && index < getItemCount())) error (SWT.ERROR_INVALID_RANGE);
    auto list = OS.gtk_container_get_children (handle);
    if (list is null) error (SWT.ERROR_CANNOT_GET_ITEM);
    int itemCount = OS.g_list_length (list);
    OS.g_list_free (list);
    if (!(0 <= index && index < itemCount)) error (SWT.ERROR_CANNOT_GET_ITEM);
    return items [index];
}

/**
 * Returns the tab item at the given point in the receiver
 * or null if no such item exists. The point is in the
 * coordinate system of the receiver.
 *
 * @param point the point used to locate the item
 * @return the tab item at the given point, or null if the point is not in a tab item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public TabItem getItem(Point point) {
    checkWidget();
    if (point is null) error (SWT.ERROR_NULL_ARGUMENT);
    auto list = OS.gtk_container_get_children (handle);
    if (list is null) return null;
    int itemCount = OS.g_list_length (list);
    OS.g_list_free (list);
    for (int i = 0; i < itemCount; i++) {
        TabItem item = items[i];
        Rectangle rect = item.getBounds();
        if (rect.contains(point)) return item;
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
    checkWidget();
    auto list = OS.gtk_container_get_children (handle);
    if (list is null) return 0;
    int itemCount = OS.g_list_length (list);
    OS.g_list_free (list);
    return itemCount;
}

/**
 * Returns an array of <code>TabItem</code>s which are the items
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
public TabItem [] getItems () {
    checkWidget();
    int count = getItemCount ();
    TabItem [] result = new TabItem [count];
    System.arraycopy (items, 0, result, 0, count);
    return result;
}

/**
 * Returns an array of <code>TabItem</code>s that are currently
 * selected in the receiver. An empty array indicates that no
 * items are selected.
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
public TabItem [] getSelection () {
    checkWidget();
    int index = OS.gtk_notebook_get_current_page (handle);
    if (index is -1) return new TabItem [0];
    return [ items [index] ];
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
    checkWidget();
    return OS.gtk_notebook_get_current_page (handle);
}

override int gtk_focus (GtkWidget* widget, ptrdiff_t directionType) {
    return 0;
}

override int gtk_switch_page (GtkWidget* widget, ptrdiff_t page, ptrdiff_t page_num) {
    int index = OS.gtk_notebook_get_current_page (handle);
    if (index !is -1) {
        Control control = items [index].getControl ();
        if (control !is null && !control.isDisposed ()) {
            control.setVisible (false);
        }
    }
    TabItem item = items [page_num];
    Control control = item.getControl ();
    if (control !is null && !control.isDisposed ()) {
        control.setBounds(getClientArea());
        control.setVisible (true);
    }
    Event event = new Event();
    event.item = item;
    postEvent(SWT.Selection, event);
    return 0;
}

override void hookEvents () {
    super.hookEvents ();
    OS.g_signal_connect_closure (handle, OS.switch_page.ptr, display.closures [SWITCH_PAGE], false);
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
public int indexOf (TabItem item) {
    checkWidget();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    auto list = OS.gtk_container_get_children (handle);
    if (list is null) return -1;
    int count = OS.g_list_length (list);
    OS.g_list_free (list);
    for (int i=0; i<count; i++) {
        if (items [i] is item) return i;
    }
    return -1;
}

override Point minimumSize (int wHint, int hHint, bool flushCache) {
    Control [] children = _getChildren ();
    int width = 0, height = 0;
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        int index = 0;
        int count = 0;
        auto list = OS.gtk_container_get_children (handle);
        if (list !is null) {
            count = OS.g_list_length (list);
            OS.g_list_free (list);
        }
        while (index < count) {
            if (items [index].control is child) break;
            index++;
        }
        if (index is count) {
            Rectangle rect = child.getBounds ();
            width = Math.max (width, rect.x + rect.width);
            height = Math.max (height, rect.y + rect.height);
        } else {
            Point size = child.computeSize (wHint, hHint, flushCache);
            width = Math.max (width, size.x);
            height = Math.max (height, size.y);
        }
    }
    return new Point (width, height);
}

override bool mnemonicHit (wchar key) {
    int itemCount = getItemCount ();
    for (int i=0; i<itemCount; i++) {
        auto labelHandle = items [i].labelHandle;
        if (labelHandle !is null && mnemonicHit (labelHandle, key)) return true;
    }
    return false;
}

override bool mnemonicMatch (wchar key) {
    int itemCount = getItemCount ();
    for (int i=0; i<itemCount; i++) {
        auto labelHandle = items [i].labelHandle;
        if (labelHandle !is null && mnemonicHit (labelHandle, key)) return true;
    }
    return false;
}

override void releaseChildren (bool destroy) {
    if (items !is null) {
        for (int i=0; i<items.length; i++) {
            TabItem item = items [i];
            if (item !is null && !item.isDisposed ()) {
                item.release (false);
            }
        }
        items = null;
    }
    super.releaseChildren (destroy);
}

override void releaseWidget () {
    super.releaseWidget ();
    if (imageList !is null) imageList.dispose ();
    imageList = null;
}

override void removeControl (Control control) {
    super.removeControl (control);
    int count = getItemCount ();
    for (int i=0; i<count; i++) {
        TabItem item = items [i];
        if (item.control is control) item.setControl (null);
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
    if (eventTable is null) return;
    eventTable.unhook (SWT.Selection, listener);
    eventTable.unhook (SWT.DefaultSelection,listener);
}

override int setBounds (int x, int y, int width, int height, bool move, bool resize) {
    int result = super.setBounds (x, y, width, height, move, resize);
    if ((result & RESIZED) !is 0) {
        int index = getSelectionIndex ();
        if (index !is -1) {
            TabItem item = items [index];
            Control control = item.control;
            if (control !is null && !control.isDisposed ()) {
                control.setBounds (getClientArea ());
            }
        }
    }
    return result;
}

override void setFontDescription (PangoFontDescription* font) {
    super.setFontDescription (font);
    TabItem [] items = getItems ();
    for (int i = 0; i < items.length; i++) {
        if (items[i] !is null) {
            items[i].setFontDescription (font);
        }
    }
}

override void setForegroundColor (GdkColor* color) {
    super.setForegroundColor (color);
    TabItem [] items = getItems ();
    for (int i = 0; i < items.length; i++) {
        if (items[i] !is null) {
            items[i].setForegroundColor (color);
        }
    }
}

/**
 * Selects the item at the given zero-relative index in the receiver.
 * If the item at the index was already selected, it remains selected.
 * The current selection is first cleared, then the new items are
 * selected. Indices that are out of range are ignored.
 *
 * @param index the index of the item to select
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (int index) {
    checkWidget ();
    if (!(0 <= index && index < getItemCount ())) return;
    setSelection (index, false);
}

void setSelection (int index, bool notify) {
    if (index < 0) return;
    int oldIndex = OS.gtk_notebook_get_current_page (handle);
    if (oldIndex is index) return;
    if (oldIndex !is -1) {
        TabItem item = items [oldIndex];
        Control control = item.control;
        if (control !is null && !control.isDisposed ()) {
            control.setVisible (false);
        }
    }
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udSWITCH_PAGE);
    OS.gtk_notebook_set_current_page (handle, index);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udSWITCH_PAGE);
    int newIndex = OS.gtk_notebook_get_current_page (handle);
    if (newIndex !is -1) {
        TabItem item = items [newIndex];
        Control control = item.control;
        if (control !is null && !control.isDisposed ()) {
            control.setBounds (getClientArea ());
            control.setVisible (true);
        }
        if (notify) {
            Event event = new Event ();
            event.item = item;
            sendEvent (SWT.Selection, event);
        }
    }
}

/**
 * Sets the receiver's selection to the given item.
 * The current selected is first cleared, then the new item is
 * selected.
 *
 * @param item the item to select
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setSelection (TabItem item) {
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    setSelection( [item] );
}

/**
 * Sets the receiver's selection to be the given array of items.
 * The current selected is first cleared, then the new items are
 * selected.
 *
 * @param items the array of items
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (TabItem [] items) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (items is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (items.length is 0) {
        setSelection (-1, false);
    } else {
        for (ptrdiff_t i=cast(ptrdiff_t) (items.length)-1; i>=0; --i) {
            int index = indexOf (items [i]);
            if (index !is -1) setSelection (index, false);
        }
    }
}

override bool traversePage (bool next) {
    if (next) {
        OS.gtk_notebook_next_page (handle);
    } else {
        OS.gtk_notebook_prev_page (handle);
    }
    return true;
}

}
