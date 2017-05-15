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
module org.eclipse.swt.custom.TableTreeItem;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.custom.TableTree;
import java.lang.all;


/**
 * A TableTreeItem is a selectable user interface object
 * that represents an item in a hierarchy of items in a
 * TableTree.
 *
 * @deprecated As of 3.1 use Tree, TreeItem and TreeColumn
 */
public class TableTreeItem : Item {
    TableItem tableItem;
    TableTree parent;
    TableTreeItem parentItem;
    TableTreeItem [] items;
    String[] texts;
    Image[] images;
    Color background;
    Color foreground;
    Font font;
    bool expanded;
    bool checked;
    bool grayed;

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>TableTree</code>)
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
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 *
 * @see SWT
 * @see Widget#getStyle()
 */
public this(TableTree parent, int style) {
    this (parent, style, parent.getItemCount());
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>TableTree</code>,
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
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 * @param index the index to store the receiver in its parent
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 *
 * @see SWT
 * @see Widget#getStyle()
 */
public this(TableTree parent, int style, int index) {
    this (parent, null, style, index);
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>TableTreeItem</code>)
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
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 *
 * @see SWT
 * @see Widget#getStyle()
 */
public this(TableTreeItem parent, int style) {
    this (parent, style, parent.getItemCount());
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>TableTreeItem</code>),
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
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 * @param index the index to store the receiver in its parent
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 *
 * @see SWT
 * @see Widget#getStyle()
 */
public this(TableTreeItem parent, int style, int index) {
    this (parent.getParent(), parent, style, index);
}

this(TableTree parent, TableTreeItem parentItem, int style, int index) {

    items = TableTree.EMPTY_ITEMS;
    texts = TableTree.EMPTY_TEXTS;
    images = TableTree.EMPTY_IMAGES;

    super(parent, style);
    this.parent = parent;
    this.parentItem = parentItem;
    if (parentItem is null) {

        /* Root items are visible immediately */
        int tableIndex = parent.addItem(this, index);
        tableItem = new TableItem(parent.getTable(), style, tableIndex);
        tableItem.setData(TableTree.ITEMID, this);
        addCheck();
        /*
        * Feature in the Table.  The table uses the first image that
        * is inserted into the table to size the table rows.  If the
        * user is allowed to insert the first image, this will cause
        * the +/- images to be scaled.  The fix is to insert a dummy
        * image to force the size.
        */
        if (parent.sizeImage is null) {
            int itemHeight = parent.getItemHeight();
            parent.sizeImage = new Image(parent.getDisplay(), itemHeight, itemHeight);
            GC gc = new GC (parent.sizeImage);
            gc.setBackground(parent.getBackground());
            gc.fillRectangle(0, 0, itemHeight, itemHeight);
            gc.dispose();
            tableItem.setImage(0, parent.sizeImage);
        }
    } else {
        parentItem.addItem(this, index);
    }
}
void addCheck() {
    Table table = parent.getTable();
    if ((table.getStyle() & SWT.CHECK) is 0) return;
    tableItem.setChecked(checked);
    tableItem.setGrayed(grayed);
}
void addItem(TableTreeItem item, int index) {
    if (item is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (index < 0 || index > items.length) SWT.error(SWT.ERROR_INVALID_ARGUMENT);

    /* Now that item has a sub-node it must indicate that it can be expanded */
    if (items.length is 0 && index is 0) {
        if (tableItem !is null) {
            Image image = expanded ? parent.getMinusImage() : parent.getPlusImage();
            tableItem.setImage(0, image);
        }
    }

    /* Put the item in the items list */
    TableTreeItem[] newItems = new TableTreeItem[items.length + 1];
    System.arraycopy(items, 0, newItems, 0, index);
    newItems[index] = item;
    System.arraycopy(items, index, newItems, index + 1, items.length - index);
    items = newItems;
    if (expanded) item.setVisible(true);
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
    return (background is null) ? parent.getBackground() : background;
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
public Rectangle getBounds (int index) {
    checkWidget();
    if (tableItem !is null) {
        return tableItem.getBounds(index);
    } else {
        return new Rectangle(0, 0, 0, 0);
    }
}
/**
 * Returns <code>true</code> if the receiver is checked,
 * and false otherwise.  When the parent does not have
 * the <code>CHECK style, return false.
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
    if (tableItem is null) return checked;
    return tableItem.getChecked();
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
 *
 * @since 2.1
 */
public bool getGrayed () {
    checkWidget();
    if (tableItem is null) return grayed;
    return tableItem.getGrayed();
}

/**
 * Returns <code>true</code> if the receiver is expanded,
 * and false otherwise.
 * <p>
 *
 * @return the expanded state
 */
public bool getExpanded () {
    //checkWidget();
    return expanded;
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
    return (font is null) ? parent.getFont() : font;
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
    return (foreground is null) ? parent.getForeground() : foreground;
}
/**
 * Gets the first image.
 * <p>
 * The image in column 0 is reserved for the [+] and [-]
 * images of the tree, therefore getImage(0) will return null.
 *
 * @return the image at index 0
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public override Image getImage () {
    checkWidget();
    return getImage(0);
}

/**
 * Gets the image at the specified index.
 * <p>
 * Indexing is zero based. The image can be null.
 * The image in column 0 is reserved for the [+] and [-]
 * images of the tree, therefore getImage(0) will return null.
 * Return null if the index is out of range.
 *
 * @param index the index of the image
 * @return the image at the specified index or null
 */
public Image getImage (int index) {
    //checkWidget();
    if (0 < index && index < images.length) return images[index];
    return null;
}

int getIndent() {
    if (parentItem is null) return 0;
    return parentItem.getIndent() + 1;
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
    auto count = items.length;
    if (!(0 <= index && index < count)) SWT.error (SWT.ERROR_INVALID_RANGE);
    return items [index];
}

/**
 * Returns the number of items contained in the receiver
 * that are direct item children of the receiver.
 *
 * @return the number of items
 */
public int getItemCount () {
    //checkWidget();
    return cast(int)/*64bit*/items.length;
}

/**
 * Returns an array of <code>TableTreeItem</code>s which are the
 * direct item children of the receiver.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the receiver's items
 */
public TableTreeItem[] getItems () {
    //checkWidget();
    TableTreeItem[] newItems = new TableTreeItem[items.length];
    System.arraycopy(items, 0, newItems, 0, items.length);
    return newItems;
}

TableTreeItem getItem(TableItem tableItem) {
    if (tableItem is null) return null;
    if (this.tableItem is tableItem) return this;
    for (int i = 0; i < items.length; i++) {
        TableTreeItem item =  items[i].getItem(tableItem);
            if (item !is null) return item;
    }
    return null;
}

/**
 * Returns the receiver's parent, which must be a <code>TableTree</code>.
 *
 * @return the receiver's parent
 */
public TableTree getParent () {
    //checkWidget();
    return parent;
}

/**
 * Returns the receiver's parent item, which must be a
 * <code>TableTreeItem</code> or null when the receiver is a
 * root.
 *
 * @return the receiver's parent item
 */
public TableTreeItem getParentItem () {
    //checkWidget();
    return parentItem;
}
public override String getText () {
    checkWidget();
    return getText(0);
}

/**
 * Gets the item text at the specified index.
 * <p>
 * Indexing is zero based.
 *
 * This operation will fail when the index is out
 * of range or an item could not be queried from
 * the OS.
 *
 * @param index the index of the item
 * @return the item text at the specified index, which can be null
 */
public String getText(int index) {
    //checkWidget();
    if (0 <= index && index < texts.length) return texts[index];
    return null;
}

bool getVisible () {
    return tableItem !is null;
}

/**
 * Gets the index of the specified item.
 *
 * <p>The widget is searched starting at 0 until an
 * item is found that is equal to the search item.
 * If no item is found, -1 is returned.  Indexing
 * is zero based.  This index is relative to the parent only.
 *
 * @param item the search item
 * @return the index of the item or -1 if the item is not found
 *
 */
public int indexOf (TableTreeItem item) {
    //checkWidget();
    for (int i = 0; i < items.length; i++) {
        if (items[i] is item) return i;
    }
    return -1;
}

void expandAll(bool notify) {
    if (items.length is 0) return;
    if (!expanded) {
        setExpanded(true);
        if (notify) {
            Event event = new Event();
            event.item = this;
            parent.notifyListeners(SWT.Expand, event);
        }
    }
    for (int i = 0; i < items.length; i++) {
        items[i].expandAll(notify);
    }
}
int expandedIndexOf (TableTreeItem item) {
    int index = 0;
    for (int i = 0; i < items.length; i++) {
        if (items[i] is item) return index;
        if (items[i].expanded) index += items[i].visibleChildrenCount ();
        index++;
    }
    return -1;
}

int visibleChildrenCount () {
    int count = 0;
    for (int i = 0; i < items.length; i++) {
        if (items[i].getVisible ()) {
            count += 1 + items[i].visibleChildrenCount ();
        }
    }
    return count;
}

public override void dispose () {
    if (isDisposed()) return;
    for (ptrdiff_t i = cast(ptrdiff_t) (items.length) - 1; i >= 0; i--) {
        items[i].dispose();
    }
    super.dispose();
    if (!parent.inDispose) {
        if (parentItem !is null) {
            parentItem.removeItem(this);
        } else {
            parent.removeItem(this);
        }
        if (tableItem !is null) tableItem.dispose();
    }
    items = null;
    parentItem = null;
    parent = null;
    images = null;
    texts = null;
    tableItem = null;
    foreground = null;
    background = null;
    font = null;
}

void removeItem(TableTreeItem item) {
    int index = 0;
    while (index < items.length && items[index] !is item) index++;
    if (index is items.length) return;
    TableTreeItem[] newItems = new TableTreeItem[items.length - 1];
    System.arraycopy(items, 0, newItems, 0, index);
    System.arraycopy(items, index + 1, newItems, index, items.length - index - 1);
    items = newItems;
    if (items.length is 0) {
        if (tableItem !is null) tableItem.setImage(0, null);
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
    if (tableItem !is null) {
        tableItem.setBackground(color);
    }
    background = color;
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
    Table table = parent.getTable();
    if ((table.getStyle() & SWT.CHECK) is 0) return;
    if (tableItem !is null) {
        tableItem.setChecked(checked);
    }
    this.checked = checked;
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
 *
 * @since 2.1
 */
public void setGrayed (bool grayed) {
    checkWidget();
    Table table = parent.getTable();
    if ((table.getStyle() & SWT.CHECK) is 0) return;
    if (tableItem !is null) {
        tableItem.setGrayed(grayed);
    }
    this.grayed = grayed;
}

/**
 * Sets the expanded state.
 * <p>
 * @param expanded the new expanded state.
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 */
public void setExpanded (bool expanded) {
    checkWidget();
    if (items.length is 0) return;
    if (this.expanded is expanded) return;
    this.expanded = expanded;
    if (tableItem is null) return;
    parent.setRedraw(false);
    for (int i = 0; i < items.length; i++) {
        items[i].setVisible(expanded);
    }
    Image image = expanded ? parent.getMinusImage() : parent.getPlusImage();
    tableItem.setImage(0, image);
    parent.setRedraw(true);
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
    if (tableItem !is null) {
        tableItem.setFont(font);
    }
    this.font = font;
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
public void setForeground (Color color) {
    checkWidget ();
    if (color !is null && color.isDisposed ()) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    if (tableItem !is null) {
        tableItem.setForeground(color);
    }
    foreground = color;
}

/**
 * Sets the image at an index.
 * <p>
 * The image can be null.
 * The image in column 0 is reserved for the [+] and [-]
 * images of the tree, therefore do nothing if index is 0.
 *
 * @param image the new image or null
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 */
public void setImage (int index, Image image) {
    checkWidget();
    int columnCount = Math.max(parent.getTable().getColumnCount(), 1);
    if (index <= 0 || index >= columnCount) return;
    if (images.length < columnCount) {
        Image[] newImages = new Image[columnCount];
        System.arraycopy(images, 0, newImages, 0, images.length);
        images = newImages;
    }
    images[index] = image;
    if (tableItem !is null) tableItem.setImage(index, image);
}

/**
 * Sets the first image.
 * <p>
 * The image can be null.
 * The image in column 0 is reserved for the [+] and [-]
 * images of the tree, therefore do nothing.
 *
 * @param image the new image or null
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 */
public override void setImage (Image image) {
    setImage(0, image);
}

/**
 * Sets the widget text.
 * <p>
 *
 * The widget text for an item is the label of the
 * item or the label of the text specified by a column
 * number.
 *
 * @param index the column number
 * @param text the new text
 *
 * @exception SWTException <ul>
 *      <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *      <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 *  </ul>
 */
public void setText(int index, String text) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (text is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    int columnCount = Math.max(parent.getTable().getColumnCount(), 1);
    if (index < 0 || index >= columnCount) return;
    if (texts.length < columnCount) {
        String[] newTexts = new String[columnCount];
        System.arraycopy(texts, 0, newTexts, 0, texts.length);
        texts = newTexts;
    }
    texts[index] = text;
    if (tableItem !is null) tableItem.setText(index, text);
}
public override void setText (String string) {
    setText(0, string);
}

void setVisible (bool show) {
    if (parentItem is null) return; // this is a root and can not be toggled between visible and hidden
    if (getVisible() is show) return;

    if (show) {
        if (!parentItem.getVisible()) return; // parentItem must already be visible
        // create underlying table item and set data in table item to stored data
        Table table = parent.getTable();
        int parentIndex = table.indexOf(parentItem.tableItem);
        int index = parentItem.expandedIndexOf(this) + parentIndex + 1;
        if (index < 0) return;
        tableItem = new TableItem(table, getStyle(), index);
        tableItem.setData(TableTree.ITEMID, this);
        tableItem.setImageIndent(getIndent());
        if (background !is null) tableItem.setBackground(background);
        if (foreground !is null) tableItem.setForeground(foreground);
        if (font !is null) tableItem.setFont(font);
        addCheck();

        // restore fields to item
        // ignore any images in the first column
        int columnCount = Math.max(table.getColumnCount(), 1);
        for (int i = 0; i < columnCount; i++) {
            if (i < texts.length && texts[i] !is null) setText(i, texts[i]);
            if (i < images.length && images[i] !is null) setImage(i, images[i]);
        }

        // display the children and the appropriate [+]/[-] symbol as required
        if (items.length !is 0) {
            if (expanded) {
                tableItem.setImage(0, parent.getMinusImage());
                for (size_t i = 0, length = items.length; i < length; i++) {
                    items[i].setVisible(true);
                }
            } else {
                tableItem.setImage(0, parent.getPlusImage());
            }
        }

    } else {

        for (size_t i = 0, length = items.length; i < length; i++) {
            items[i].setVisible(false);
        }
        // remove row from table
        tableItem.dispose();
        tableItem = null;
    }
}
}
