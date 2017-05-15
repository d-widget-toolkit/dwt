/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
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
module org.eclipse.swt.custom.TableTree;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.TreeListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.custom.TableTreeItem;
import java.lang.all;

/**
 * A TableTree is a selectable user interface object
 * that displays a hierarchy of items, and issues
 * notification when an item is selected.
 * A TableTree may be single or multi select.
 * <p>
 * The item children that may be added to instances of this class
 * must be of type <code>TableTreeItem</code>.
 * </p><p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add <code>Control</code> children to it,
 * or set a layout on it.
 * </p><p>
 * <dl>
 *  <dt><b>Styles:</b> <dd> SINGLE, MULTI, CHECK, FULL_SELECTION
 *  <dt><b>Events:</b> <dd> Selection, DefaultSelection, Collapse, Expand
 * </dl>
 * <p>
 * Note: Only one of the styles SINGLE, and MULTI may be specified.
 * </p>
 *
 * @deprecated As of 3.1 use Tree, TreeItem and TreeColumn
 */
public class TableTree : Composite {

    alias Composite.computeSize computeSize;

    Table table;
    TableTreeItem[] items;
    Image plusImage, minusImage, sizeImage;

    /*
    * TableTreeItems are not treated as children but rather as items.
    * When the TableTree is disposed, all children are disposed because
    * TableTree inherits this behaviour from Composite.  The items
    * must be disposed separately.  Because TableTree is not part of
    * the org.eclipse.swt.widgets module, the method releaseWidget can
    * not be overridden (this is how items are disposed of in Table and Tree).
    * Instead, the items are disposed of in response to the dispose event on the
    * TableTree.  The "inDispose" flag is used to distinguish between disposing
    * one TableTreeItem (e.g. when removing an entry from the TableTree) and
    * disposing the entire TableTree.
    */
    bool inDispose = false;

    static /+const+/ TableTreeItem[] EMPTY_ITEMS;
    static /+const+/ String[] EMPTY_TEXTS;
    static /+const+/ Image[] EMPTY_IMAGES;
    static /+const+/ String ITEMID = "TableTreeItemID"; //$NON-NLS-1$

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
 * @param parent a widget which will be the parent of the new instance (cannot be null)
 * @param style the style of widget to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 *
 * @see SWT#SINGLE
 * @see SWT#MULTI
 * @see SWT#CHECK
 * @see SWT#FULL_SELECTION
 * @see #getStyle
 */
public this(Composite parent, int style) {
    super(parent, checkStyle (style));
    items = EMPTY_ITEMS;
    table = new Table(this, style);
    Listener tableListener = new class() Listener {
        public void handleEvent(Event e) {
            switch (e.type) {
            case SWT.MouseDown: onMouseDown(e); break;
            case SWT.Selection: onSelection(e); break;
            case SWT.DefaultSelection: onSelection(e); break;
            case SWT.KeyDown: onKeyDown(e); break;
            default:
            }
        }
    };
    int[] tableEvents = [SWT.MouseDown,
                                   SWT.Selection,
                                   SWT.DefaultSelection,
                                   SWT.KeyDown];
    for (int i = 0; i < tableEvents.length; i++) {
        table.addListener(tableEvents[i], tableListener);
    }

    Listener listener = new class() Listener {
        public void handleEvent(Event e) {
            switch (e.type) {
            case SWT.Dispose: onDispose(e); break;
            case SWT.Resize:  onResize(e); break;
            case SWT.FocusIn: onFocusIn(e); break;
            default:
            }
        }
    };
    int[] events = [SWT.Dispose,
                              SWT.Resize,
                              SWT.FocusIn];
    for (int i = 0; i < events.length; i++) {
        addListener(events[i], listener);
    }
}

int addItem(TableTreeItem item, int index) {
    if (index < 0 || index > items.length) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    TableTreeItem[] newItems = new TableTreeItem[items.length + 1];
    System.arraycopy(items, 0, newItems, 0, index);
    newItems[index] = item;
    System.arraycopy(items, index, newItems, index + 1, items.length - index);
    items = newItems;

    /* Return the index in the table where this table should be inserted */
    if (index is items.length - 1 )
        return table.getItemCount();
    else
        return table.indexOf(items[index+1].tableItem);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the user changes the receiver's selection, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * When <code>widgetSelected</code> is called, the item field of the event object is valid.
 * If the receiver has <code>SWT.CHECK</code> style set and the check selection changes,
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
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
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
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Expand, typedListener);
    addListener (SWT.Collapse, typedListener);
}
private static int checkStyle (int style) {
    int mask = SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT;
    style = style & mask;
    return style;
}
public override Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget();
    return table.computeSize (wHint, hHint, changed);
}
public override Rectangle computeTrim (int x, int y, int width, int height) {
    checkWidget();
    return table.computeTrim(x, y, width, height);
}

/**
 * Deselects all items.
 * <p>
 * If an item is selected, it is deselected.
 * If an item is not selected, it remains unselected.
 *
 * @exception SWTException <ul>
 *  <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread
 *  <li>ERROR_WIDGET_DISPOSED when the widget has been disposed
 * </ul>
 */
public void deselectAll () {
    checkWidget();
    table.deselectAll();
}

/* Expand upward from the specified leaf item. */
void expandItem (TableTreeItem item) {
    if (item is null) return;
    expandItem(item.parentItem);
    if (!item.getVisible()) item.setVisible(true);
    if ( !item.expanded && item.items.length > 0) {
        item.setExpanded(true);
        Event event = new Event();
        event.item = item;
        notifyListeners(SWT.Expand, event);
    }
}
public override Color getBackground () {
    // This method must be overridden otherwise, in a TableTree in which the first
    // item has no sub items, a grey (Widget background colour) square will appear in
    // the first column of the first item.
    // It is not possible in the constructor to set the background of the TableTree
    // to be the same as the background of the Table because this interferes with
    // the TableTree adapting to changes in the System color settings.
    return table.getBackground();
}
public override Rectangle getClientArea () {
    return table.getClientArea();
}
public override Color getForeground () {
    return table.getForeground();
}
public override Font getFont () {
    return table.getFont();
}
/**
 * Gets the number of items.
 * <p>
 * @return the number of items in the widget
 */
public int getItemCount () {
    //checkWidget();
    return cast(int)/*64bit*/items.length;
}

/**
 * Gets the height of one item.
 * <p>
 * This operation will fail if the height of
 * one item could not be queried from the OS.
 *
 * @return the height of one item in the widget
 *
 * @exception SWTException <ul>
 *  <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread
 *  <li>ERROR_WIDGET_DISPOSED when the widget has been disposed
 * </ul>
 */
public int getItemHeight () {
    checkWidget();
    return table.getItemHeight();
}

/**
 * Gets the items.
 * <p>
 * @return the items in the widget
 */
public TableTreeItem [] getItems () {
    //checkWidget();
    TableTreeItem[] newItems = new TableTreeItem[items.length];
    System.arraycopy(items, 0, newItems, 0, items.length);
    return newItems;
}

/**
 * Gets the selected items.
 * <p>
 * This operation will fail if the selected
 * items cannot be queried from the OS.
 *
 * @return the selected items in the widget
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 */
public TableTreeItem [] getSelection () {
    checkWidget();
    TableItem[] selection = table.getSelection();
    TableTreeItem [] result = new TableTreeItem[selection.length];
    for (int i = 0; i < selection.length; i++){
        result[i] = cast(TableTreeItem) selection[i].getData(ITEMID);
    }
    return result;
}

/**
 * Gets the number of selected items.
 * <p>
 * This operation will fail if the number of selected
 * items cannot be queried from the OS.
 *
 * @return the number of selected items in the widget
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 */
public int getSelectionCount () {
    checkWidget();
    return table.getSelectionCount();
}

public override int getStyle () {
    checkWidget();
    return table.getStyle();
}

/**
 * Returns the underlying Table control.
 *
 * @return the underlying Table control
 */
public Table getTable () {
    //checkWidget();
    return table;
}

void createImages () {

    int itemHeight = sizeImage.getBounds().height;
    // Calculate border around image.
    // At least 9 pixels are needed to draw the image
    // Leave at least a 6 pixel border.
    int indent = Math.min(6, (itemHeight - 9) / 2);
    indent = Math.max(0, indent);
    int size = Math.max (10, itemHeight - 2 * indent);
    size = ((size + 1) / 2) * 2; // size must be an even number
    int midpoint = indent + size / 2;

    Color foreground = getForeground();
    Color plusMinus = getDisplay().getSystemColor(SWT.COLOR_WIDGET_NORMAL_SHADOW);
    Color background = getBackground();

    /* Plus image */
    PaletteData palette = new PaletteData( [ foreground.getRGB(), background.getRGB(), plusMinus.getRGB()]);
    ImageData imageData = new ImageData(itemHeight, itemHeight, 4, palette);
    imageData.transparentPixel = 1;
    plusImage = new Image(getDisplay(), imageData);
    GC gc = new GC(plusImage);
    gc.setBackground(background);
    gc.fillRectangle(0, 0, itemHeight, itemHeight);
    gc.setForeground(plusMinus);
    gc.drawRectangle(indent, indent, size, size);
    gc.setForeground(foreground);
    gc.drawLine(midpoint, indent + 2, midpoint, indent + size - 2);
    gc.drawLine(indent + 2, midpoint, indent + size - 2, midpoint);
    gc.dispose();

    /* Minus image */
    palette = new PaletteData([foreground.getRGB(), background.getRGB(), plusMinus.getRGB()]);
    imageData = new ImageData(itemHeight, itemHeight, 4, palette);
    imageData.transparentPixel = 1;
    minusImage = new Image(getDisplay(), imageData);
    gc = new GC(minusImage);
    gc.setBackground(background);
    gc.fillRectangle(0, 0, itemHeight, itemHeight);
    gc.setForeground(plusMinus);
    gc.drawRectangle(indent, indent, size, size);
    gc.setForeground(foreground);
    gc.drawLine(indent + 2, midpoint, indent + size - 2, midpoint);
    gc.dispose();
}

Image getPlusImage() {
    if (plusImage is null) createImages();
    return plusImage;
}

Image getMinusImage() {
    if (minusImage is null) createImages();
    return minusImage;
}

/**
 * Gets the index of an item.
 *
 * <p>The widget is searched starting at 0 until an
 * item is found that is equal to the search item.
 * If no item is found, -1 is returned.  Indexing
 * is zero based.  This index is relative to the parent only.
 *
 * @param item the search item
 * @return the index of the item or -1
 */
public int indexOf (TableTreeItem item) {
    //checkWidget();
    for (int i = 0; i < items.length; i++) {
        if (item is items[i]) return i;
    }
    return -1;
}

void onDispose(Event e) {
    /*
     * Usually when an item is disposed, destroyItem will change the size of the items array
     * and dispose of the underlying table items.
     * Since the whole table tree is being disposed, this is not necessary.  For speed
     * the inDispose flag is used to skip over this part of the item dispose.
     */
    inDispose = true;
    for (int i = 0; i < items.length; i++) {
        items[i].dispose();
    }
    inDispose = false;
    if (plusImage !is null) plusImage.dispose();
    if (minusImage !is null) minusImage.dispose();
    if (sizeImage !is null) sizeImage.dispose();
    plusImage = minusImage = sizeImage = null;
}

void onResize(Event e) {
    Point size = getSize();
    table.setBounds(0, 0, size.x, size.y);
}

void onSelection(Event e) {
    Event event = new Event();
    TableItem tableItem = cast(TableItem)e.item;
    TableTreeItem item = getItem(tableItem);
    event.item = item;

    if (e.type is SWT.Selection && e.detail is SWT.CHECK && item !is null) {
        event.detail = SWT.CHECK;
        item.checked = tableItem.getChecked();
    }
    notifyListeners(e.type, event);
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
public TableTreeItem getItem (int index) {
    checkWidget();
    int count = cast(int)/*64bit*/items.length;
    if (!(0 <= index && index < count)) SWT.error (SWT.ERROR_INVALID_RANGE);
    return items [index];
}

/**
 * Returns the item at the given point in the receiver
 * or null if no such item exists. The point is in the
 * coordinate system of the receiver.
 *
 * @param point the point used to locate the item
 * @return the item at the given point
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public TableTreeItem getItem(Point point) {
    checkWidget();
    TableItem item = table.getItem(point);
    if (item is null) return null;
    return getItem(item);

}
TableTreeItem getItem(TableItem tableItem) {
    if (tableItem is null) return null;
    for (int i = 0; i < items.length; i++) {
            TableTreeItem item = items[i].getItem(tableItem);
            if (item !is null) return item;
    }
    return null;
}
void onFocusIn (Event e) {
    table.setFocus();
}

void onKeyDown (Event e) {
    TableTreeItem[] selection = getSelection();
    if (selection.length is 0) return;
    TableTreeItem item = selection[0];
    int type = 0;
    if (e.keyCode is SWT.ARROW_RIGHT || e.keyCode is SWT.ARROW_LEFT) {
        int trailKey = (getStyle() & SWT.MIRRORED) !is 0 ? SWT.ARROW_LEFT : SWT.ARROW_RIGHT;
        if (e.keyCode is trailKey) {
            if (item.getItemCount() is 0) return;
            if (item.getExpanded()) {
                TableTreeItem newSelection = item.getItems()[0];
                table.setSelection([newSelection.tableItem]);
                showItem(newSelection);
                type = SWT.Selection;
            } else {
                item.setExpanded(true);
                type = SWT.Expand;
            }
        } else {
            if (item.getExpanded()) {
                item.setExpanded(false);
                type = SWT.Collapse;
            } else {
                TableTreeItem parent = item.getParentItem();
                if (parent !is null) {
                    int index = parent.indexOf(item);
                    if (index !is 0) return;
                    table.setSelection([parent.tableItem]);
                    type = SWT.Selection;
                }
            }
        }
    }
    if (e.character is '*') {
        item.expandAll(true);
    }
    if (e.character is '-') {
        if (item.getExpanded()) {
            item.setExpanded(false);
            type = SWT.Collapse;
        }
    }
    if (e.character is '+') {
        if (item.getItemCount() > 0 && !item.getExpanded()) {
            item.setExpanded(true);
            type = SWT.Expand;
        }
    }
    if (type is 0) return;
    Event event = new Event();
    event.item = item;
    notifyListeners(type, event);
}
void onMouseDown(Event event) {
    /* If user clicked on the [+] or [-], expand or collapse the tree. */
    TableItem[] items = table.getItems();
    for (int i = 0; i < items.length; i++) {
        Rectangle rect = items[i].getImageBounds(0);
        if (rect.contains(event.x, event.y)) {
            TableTreeItem item = cast(TableTreeItem) items[i].getData(ITEMID);
            event = new Event();
            event.item = item;
            item.setExpanded(!item.getExpanded());
            if (item.getExpanded()) {
                notifyListeners(SWT.Expand, event);
            } else {
                notifyListeners(SWT.Collapse, event);
            }
            return;
        }
    }
}

/**
 * Removes all items.
 * <p>
 * This operation will fail when an item
 * could not be removed in the OS.
 *
 * @exception SWTException <ul>
 *  <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread
 *  <li>ERROR_WIDGET_DISPOSED when the widget has been disposed
 * </ul>
 */
public void removeAll () {
    checkWidget();
    setRedraw(false);
    for (ptrdiff_t i = cast(ptrdiff_t) (items.length) - 1; i >= 0; i--) {
        items[i].dispose();
    }
    items = EMPTY_ITEMS;
    setRedraw(true);
}

void removeItem(TableTreeItem item) {
    int index = 0;
    while (index < items.length && items[index] !is item) index++;
    if (index is items.length) return;
    TableTreeItem[] newItems = new TableTreeItem[items.length - 1];
    System.arraycopy(items, 0, newItems, 0, index);
    System.arraycopy(items, index + 1, newItems, index, items.length - index - 1);
    items = newItems;
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
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    removeListener(SWT.Selection, listener);
    removeListener(SWT.DefaultSelection, listener);
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
public void removeTreeListener (TreeListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    removeListener(SWT.Expand, listener);
    removeListener(SWT.Collapse, listener);
}

/**
 * Selects all of the items in the receiver.
 * <p>
 * If the receiver is single-select, do nothing.
 *
 * @exception SWTException <ul>
 *  <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread
 *  <li>ERROR_WIDGET_DISPOSED when the widget has been disposed
 * </ul>
 */
public void selectAll () {
    checkWidget();
    table.selectAll();
}
public override void setBackground (Color color) {
    super.setBackground(color);
    table.setBackground(color);
    if (sizeImage !is null) {
        GC gc = new GC (sizeImage);
        gc.setBackground(getBackground());
        Rectangle size = sizeImage.getBounds();
        gc.fillRectangle(size);
        gc.dispose();
    }
}
public override void setEnabled (bool enabled) {
    super.setEnabled(enabled);
    table.setEnabled(enabled);
}
public override void setFont (Font font) {
    super.setFont(font);
    table.setFont(font);
}
public override void setForeground (Color color) {
    super.setForeground(color);
    table.setForeground(color);
}
public override void setMenu (Menu menu) {
    super.setMenu(menu);
    table.setMenu(menu);
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
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if one of the item has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see TableTree#deselectAll()
 */
public void setSelection (TableTreeItem[] items) {
    checkWidget ();
    // SWT extension: allow null for zero length string
    //if (items is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    int length = cast(int)/*64bit*/items.length;
    if (length is 0 || ((table.getStyle() & SWT.SINGLE) !is 0 && length > 1)) {
        deselectAll();
        return;
    }
    TableItem[] tableItems = new TableItem[length];
    for (int i = 0; i < length; i++) {
        if (items[i] is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
        if (!items[i].getVisible()) expandItem (items[i]);
        tableItems[i] = items[i].tableItem;
    }
    table.setSelection(tableItems);
}
public override void setToolTipText (String string) {
    super.setToolTipText(string);
    table.setToolTipText(string);
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
 * @see TableTree#showSelection()
 */
public void showItem (TableTreeItem item) {
    checkWidget();
    if (item is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    if (!item.getVisible()) expandItem (item);
    TableItem tableItem = item.tableItem;
    table.showItem(tableItem);
}

/**
 * Shows the selection.
 * <p>
 * If there is no selection or the selection
 * is already visible, this method does nothing.
 * If the selection is scrolled out of view,
 * the top index of the widget is changed such
 * that selection becomes visible.
 *
 * @exception SWTException <ul>
 *  <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread
 *  <li>ERROR_WIDGET_DISPOSED when the widget has been disposed
 * </ul>
 */
public void showSelection () {
    checkWidget();
    table.showSelection();
}
}
