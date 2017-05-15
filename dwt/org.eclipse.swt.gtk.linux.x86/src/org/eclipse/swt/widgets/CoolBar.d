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
module org.eclipse.swt.widgets.CoolBar;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.CoolItem;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Listener;

import java.lang.all;

/**
 * Instances of this class provide an area for dynamically
 * positioning the items they contain.
 * <p>
 * The item children that may be added to instances of this class
 * must be of type <code>CoolItem</code>.
 * </p><p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add <code>Control</code> children to it,
 * or set a layout on it.
 * </p><p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>FLAT, HORIZONTAL, VERTICAL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * </p><p>
 * Note: Only one of the styles HORIZONTAL and VERTICAL may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 * 
 * @see <a href="http://www.eclipse.org/swt/snippets/#coolbar">CoolBar snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class CoolBar : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.setCursor setCursor;

    CoolItem[][] items;
    CoolItem[] originalItems;
    Cursor hoverCursor, dragCursor, cursor;
    CoolItem dragging = null;
    int mouseXOffset, itemXOffset;
    bool isLocked = false;
    bool inDispose = false;
    static const int ROW_SPACING = 2;
    static const int CLICK_DISTANCE = 3;
    static const int DEFAULT_COOLBAR_WIDTH = 0;
    static const int DEFAULT_COOLBAR_HEIGHT = 0;

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
    super (parent, checkStyle(style));
    if ((style & SWT.VERTICAL) !is 0) {
        this.style |= SWT.VERTICAL;
        hoverCursor = new Cursor(display, SWT.CURSOR_SIZENS);
    } else {
        this.style |= SWT.HORIZONTAL;
        hoverCursor = new Cursor(display, SWT.CURSOR_SIZEWE);
    }
    dragCursor = new Cursor(display, SWT.CURSOR_SIZEALL);
    Listener listener = new class () Listener {
        public void handleEvent(Event event) {
            switch (event.type) {
                case SWT.Dispose:           onDispose(event);           break;
                case SWT.MouseDown:         onMouseDown(event);         break;
                case SWT.MouseExit:         onMouseExit();              break;
                case SWT.MouseMove:         onMouseMove(event);         break;
                case SWT.MouseUp:           onMouseUp(event);           break;
                case SWT.MouseDoubleClick:  onMouseDoubleClick(event);  break;
                case SWT.Paint:             onPaint(event);             break;
                case SWT.Resize:            onResize();                 break;
                default:
            }
        }
    };
    int[] events = [
        SWT.Dispose,
        SWT.MouseDown,
        SWT.MouseExit,
        SWT.MouseMove,
        SWT.MouseUp,
        SWT.MouseDoubleClick,
        SWT.Paint,
        SWT.Resize
    ];
    for (int i = 0; i < events.length; i++) {
        addListener(events[i], listener);
    }
}
static int checkStyle (int style) {
    style |= SWT.NO_FOCUS;
    return (style | SWT.NO_REDRAW_RESIZE) & ~(SWT.V_SCROLL | SWT.H_SCROLL);
}
void _setCursor (Cursor cursor) {
    if (this.cursor !is null) return;
    super.setCursor (cursor);
}
protected override void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

public override Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget();
    int width = 0, height = 0;
    wrapItems((style & SWT.VERTICAL) !is 0 ? hHint : wHint);
    bool flat = (style & SWT.FLAT) !is 0;
    for (int row = 0; row < items.length; row++) {
        int rowWidth = 0, rowHeight = 0;
        for (int i = 0; i < items[row].length; i++) {
            CoolItem item = items[row][i];
            rowWidth += item.preferredWidth;
            rowHeight = Math.max(rowHeight, item.preferredHeight);
        }
        height += rowHeight;
        if (!flat && row > 0) height += ROW_SPACING;
        width = Math.max(width, rowWidth);
    }
    wrapItems(getWidth());
    if (width is 0) width = DEFAULT_COOLBAR_WIDTH;
    if (height is 0) height = DEFAULT_COOLBAR_HEIGHT;
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    Rectangle trim = computeTrim(0, 0, width, height);
    return fixPoint(trim.width, trim.height);
}
CoolItem getGrabbedItem(int x, int y) {
    for (int row = 0; row < items.length; row++) {
        for (int i = 0; i < items[row].length; i++) {
            CoolItem item = items[row][i];
            Rectangle bounds = item.internalGetBounds();
            bounds.width = CoolItem.MINIMUM_WIDTH;
            if (bounds.x > x) break;
            if (bounds.y > y) return null;
            if (bounds.contains(x, y)) {
                return item;
            }
        }
    }
    return null;
}
/**
 * Returns the item that is currently displayed at the given,
 * zero-relative index. Throws an exception if the index is
 * out of range.
 *
 * @param index the visual index of the item to return
 * @return the item at the given visual index
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public CoolItem getItem (int index) {
    checkWidget();
    if (index < 0) error (SWT.ERROR_INVALID_RANGE);
    for (int row = 0; row < items.length; row++) {
        if (items[row].length > index) {
            return items[row][index];
        } else {
            index -= items[row].length;
        }
    }
    error (SWT.ERROR_INVALID_RANGE);
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
    return cast(int)/*64bit*/originalItems.length;
}
/**
 * Returns an array of <code>CoolItem</code>s in the order
 * in which they are currently being displayed.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the receiver's items in their current visual order
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public CoolItem [] getItems () {
    checkWidget();
    CoolItem [] result = new CoolItem [getItemCount()];
    int offset = 0;
    for (int row = 0; row < items.length; row++) {
        System.arraycopy(items[row], 0, result, offset, items[row].length);
        offset += items[row].length;
    }
    return result;
}
Point findItem (CoolItem item) {
    for (int row = 0; row < items.length; row++) {
        for (int i = 0; i < items[row].length; i++) {
            if (items[row][i] ==/*eq*/ item ) return new Point(i, row);
        }
    }
    return new Point(-1, -1);
}
void fixEvent (Event event) {
    if ((style & SWT.VERTICAL) !is 0) {
        int tmp = event.x;
        event.x = event.y;
        event.y = tmp;
    }
}
Rectangle fixRectangle (int x, int y, int width, int height) {
    if ((style & SWT.VERTICAL) !is 0) {
        return new Rectangle(y, x, height, width);
    }
    return new Rectangle(x, y, width, height);
}
Point fixPoint (int x, int y) {
    if ((style & SWT.VERTICAL) !is 0) {
        return new Point(y, x);
    }
    return new Point(x, y);
}
/**
 * Searches the receiver's items in the order they are currently
 * being displayed, starting at the first item (index 0), until
 * an item is found that is equal to the argument, and returns
 * the index of that item. If no item is found, returns -1.
 *
 * @param item the search item
 * @return the visual order index of the search item, or -1 if the item is not found
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the item is disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (CoolItem item) {
    checkWidget();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);
    int answer = 0;
    for (int row = 0; row < items.length; row++) {
        for (int i = 0; i < items[row].length; i++) {
            if (items[row][i] ==/*eq*/ item) {
                return answer;
            } else {
                answer++;
            }
        }
    }
    return -1;
}
/**
 * Insert the item into the row. Adjust the x and width values
 * appropriately.
 */
void insertItemIntoRow(CoolItem item, int rowIndex, int x_root) {
    int barWidth = getWidth();
    int rowY = items[rowIndex][0].internalGetBounds().y;
    int x = Math.max(0, Math.abs(x_root - toDisplay(new Point(0, 0)).x));

    /* Find the insertion index and add the item. */
    int index;
    for (index = 0; index < items[rowIndex].length; index++) {
        if (x < items[rowIndex][index].internalGetBounds().x) break;
    }
    if (index is 0) {
        item.wrap = true;
        items[rowIndex][0].wrap = false;
    }
    ptrdiff_t oldLength = items[rowIndex].length;
    CoolItem[] newRow = new CoolItem[oldLength + 1];
    System.arraycopy(items[rowIndex], 0, newRow, 0, index);
    newRow[index] = item;
    System.arraycopy(items[rowIndex], index, newRow, index + 1, oldLength - index);
    items[rowIndex] = newRow;

    /* Adjust the width of the item to the left. */
    if (index > 0) {
        CoolItem left = items[rowIndex][index - 1];
        Rectangle leftBounds = left.internalGetBounds();
        int newWidth = x - leftBounds.x;
        if (newWidth < left.internalGetMinimumWidth()) {
            x += left.internalGetMinimumWidth() - newWidth;
            newWidth = left.internalGetMinimumWidth();
        }
        left.setBounds(leftBounds.x, leftBounds.y, newWidth, leftBounds.height);
        left.requestedWidth = newWidth;
    }

    /* Set the item's bounds. */
    int width = 0, height = item.internalGetBounds().height;
    if (index < items[rowIndex].length - 1) {
        CoolItem right = items[rowIndex][index + 1];
        width = right.internalGetBounds().x - x;
        if (width < right.internalGetMinimumWidth()) {
            moveRight(right, right.internalGetMinimumWidth() - width);
            width = right.internalGetBounds().x - x;
        }
        item.setBounds(x, rowY, width, height);
        if (width < item.internalGetMinimumWidth()) moveLeft(item, item.internalGetMinimumWidth() - width);
    } else {
        width = Math.max(item.internalGetMinimumWidth(), barWidth - x);
        item.setBounds(x, rowY, width, height);
        if (x + width > barWidth) moveLeft(item, x + width - barWidth);
    }
    Rectangle bounds = item.internalGetBounds();
    item.requestedWidth = bounds.width;
    internalRedraw(bounds.x, bounds.y, item.internalGetMinimumWidth(), bounds.height);
}
void internalRedraw (int x, int y, int width, int height) {
    if ((style & SWT.VERTICAL) !is 0) {
        redraw (y, x, height, width, false);
    } else {
        redraw (x, y, width, height, false);
    }
}
void createItem (CoolItem item, int index) {
    ptrdiff_t itemCount = getItemCount(), row = 0;
    if (!(0 <= index && index <= itemCount)) error (SWT.ERROR_INVALID_RANGE);
    if (items.length is 0) {
        items = new CoolItem[][]( 1,1 );
        items[0][0] = item;
    } else {
        ptrdiff_t i = index;
        /* find the row to insert into */
        if (index < itemCount) {
            while (i > items[row].length) {
                i -= items[row].length;
                row++;
            }
        } else {
            row = items.length - 1;
            i = items[row].length;
        }

        // Set the last item in the row to the preferred size
        // and add the new one just to it's right
        ptrdiff_t lastIndex = items[row].length - 1;
        CoolItem lastItem = items[row][lastIndex];
        if (lastItem.ideal) {
            Rectangle bounds = lastItem.internalGetBounds();
            bounds.width = lastItem.preferredWidth;
            bounds.height = lastItem.preferredHeight;
            lastItem.requestedWidth = lastItem.preferredWidth;
            lastItem.setBounds(bounds.x, bounds.y, bounds.width, bounds.height);
        }
        if (i is 0) {
            item.wrap = true;
            items[row][0].wrap = false;
        }
        ptrdiff_t oldLength = items[row].length;
        CoolItem[] newRow = new CoolItem[oldLength + 1];
        System.arraycopy(items[row], 0, newRow, 0, i);
        newRow[i] = item;
        System.arraycopy(items[row], i, newRow, i + 1, oldLength - i);
        items[row] = newRow;
    }
    item.requestedWidth = CoolItem.MINIMUM_WIDTH;

    ptrdiff_t length = originalItems.length;
    CoolItem [] newOriginals = new CoolItem [length + 1];
    System.arraycopy (originalItems, 0, newOriginals, 0, index);
    System.arraycopy (originalItems, index, newOriginals, index + 1, length - index);
    newOriginals [index] = item;
    originalItems = newOriginals;
    layoutItems();

}
void destroyItem(CoolItem item) {
    if (inDispose) return;
    int row = findItem(item).y;
    if (row is -1) return;
    Rectangle bounds = item.internalGetBounds();
    removeItemFromRow(item, row, true);

    int index = 0;
    while (index < originalItems.length) {
        if (originalItems [index] is item) break;
        index++;
    }
    ptrdiff_t length = originalItems.length - 1;
    CoolItem [] newOriginals = new CoolItem [length];
    System.arraycopy (originalItems, 0, newOriginals, 0, index);
    System.arraycopy (originalItems, index + 1, newOriginals, index, length - index);
    originalItems = newOriginals;

    internalRedraw(bounds.x, bounds.y, CoolItem.MINIMUM_WIDTH, bounds.height);
    relayout();
}
void moveDown(CoolItem item, int x_root) {
    int oldRowIndex = findItem(item).y;
    bool resize = false;
    if (items[oldRowIndex].length is 1) {
        resize = true;
        /* If this is the only item in the bottom row, don't move it. */
        if (oldRowIndex is items.length - 1) return;
    }
    int newRowIndex = (items[oldRowIndex].length is 1) ? oldRowIndex : oldRowIndex + 1;
    removeItemFromRow(item, oldRowIndex, false);
    Rectangle old = item.internalGetBounds();
    internalRedraw(old.x, old.y, CoolItem.MINIMUM_WIDTH, old.height);
    if (newRowIndex is items.length) {
        /* Create a new bottom row for the item. */
        CoolItem[][] newRows = new CoolItem[][](items.length + 1);
        SimpleType!(CoolItem[]).arraycopy(items, 0, newRows, 0, items.length);
        ptrdiff_t row = items.length;
        newRows[row] = new CoolItem[1];
        newRows[row][0] = item;
        items = newRows;
        resize = true;
        item.wrap = true;
    } else {
        insertItemIntoRow(item, newRowIndex, x_root);
    }
    if (resize) {
        relayout();
    } else {
        layoutItems();
    }
}
void moveLeft(CoolItem item, int pixels) {
    Point point = findItem(item);
    int row = point.y;
    int index = point.x;
    if (index is 0) return;
    Rectangle bounds = item.internalGetBounds();
    int minSpaceOnLeft = 0;
    for (int i = 0; i < index; i++) {
        minSpaceOnLeft += items[row][i].internalGetMinimumWidth();
    }
    int x = Math.max(minSpaceOnLeft, bounds.x - pixels);
    CoolItem left = items[row][index - 1];
    Rectangle leftBounds = left.internalGetBounds();
    if (leftBounds.x + left.internalGetMinimumWidth() > x) {
        int shift = leftBounds.x + left.internalGetMinimumWidth() - x;
        moveLeft(left, shift);
        leftBounds = left.internalGetBounds();
    }
    int leftWidth = Math.max(left.internalGetMinimumWidth(), leftBounds.width - pixels);
    left.setBounds(leftBounds.x, leftBounds.y, leftWidth, leftBounds.height);
    left.requestedWidth = leftWidth;
    int width = bounds.width + (bounds.x - x);
    item.setBounds(x, bounds.y, width, bounds.height);
    item.requestedWidth = width;

    int damagedWidth = bounds.x - x + CoolItem.MINIMUM_WIDTH;
    if (damagedWidth > CoolItem.MINIMUM_WIDTH) {
        internalRedraw(x, bounds.y, damagedWidth, bounds.height);
    }
}
void moveRight(CoolItem item, int pixels) {
    Point point = findItem(item);
    int row = point.y;
    int index = point.x;
    if (index is 0) return;
    Rectangle bounds = item.internalGetBounds();
    int minSpaceOnRight = 0;
    for (int i = index; i < items[row].length; i++) {
        minSpaceOnRight += items[row][i].internalGetMinimumWidth();
    }
    int max = getWidth() - minSpaceOnRight;
    int x = Math.min(max, bounds.x + pixels);
    int width = 0;
    if (index + 1 is items[row].length) {
        width = getWidth() - x;
    } else {
        CoolItem right = items[row][index + 1];
        Rectangle rightBounds = right.internalGetBounds();
        if (x + item.internalGetMinimumWidth() > rightBounds.x) {
            int shift = x + item.internalGetMinimumWidth() - rightBounds.x;
            moveRight(right, shift);
            rightBounds = right.internalGetBounds();
        }
        width = rightBounds.x - x;
    }
    item.setBounds(x, bounds.y, width, bounds.height);
    item.requestedWidth = width;
    CoolItem left = items[row][index - 1];
    Rectangle leftBounds = left.internalGetBounds();
    int leftWidth = x - leftBounds.x;
    left.setBounds(leftBounds.x, leftBounds.y, leftWidth, leftBounds.height);
    left.requestedWidth = leftWidth;

    int damagedWidth = x - bounds.x + CoolItem.MINIMUM_WIDTH + CoolItem.MARGIN_WIDTH;
    if (x - bounds.x > 0) {
        internalRedraw(bounds.x - CoolItem.MARGIN_WIDTH, bounds.y, damagedWidth, bounds.height);
    }
}
void moveUp(CoolItem item, int x_root) {
    Point point = findItem(item);
    int oldRowIndex = point.y;
    bool resize = false;
    if (items[oldRowIndex].length is 1) {
        resize = true;
        /* If this is the only item in the top row, don't move it. */
        if (oldRowIndex is 0) return;
    }
    removeItemFromRow(item, oldRowIndex, false);
    Rectangle old = item.internalGetBounds();
    internalRedraw(old.x, old.y, CoolItem.MINIMUM_WIDTH, old.height);
    int newRowIndex = Math.max(0, oldRowIndex - 1);
    if (oldRowIndex is 0) {
        /* Create a new top row for the item. */
        CoolItem[][] newRows = new CoolItem[][]( items.length + 1 );
        SimpleType!(CoolItem[]).arraycopy(items, 0, newRows, 1, items.length);
        newRows[0] = new CoolItem[1];
        newRows[0][0] = item;
        items = newRows;
        resize = true;
        item.wrap = true;
    } else {
        insertItemIntoRow(item, newRowIndex, x_root);
    }
    if (resize) {
        relayout();
    } else {
        layoutItems();
    }
}
void onDispose(Event event) {
    /*
     * Usually when an item is disposed, destroyItem will change the size of the items array
     * and reset the bounds of all the remaining cool items.
     * Since the whole cool bar is being disposed, this is not necessary.  For speed
     * the inDispose flag is used to skip over this part of the item dispose.
     */
    if (inDispose) return;
    inDispose = true;
    notifyListeners(SWT.Dispose, event);
    event.type = SWT.None;
    for (int i = 0; i < items.length; i++) {
        for (int j = 0; j < items[i].length; j++) {
            items[i][j].dispose();
        }
    }
    hoverCursor.dispose();
    dragCursor.dispose();
    cursor = null;
}
void onMouseDown(Event event) {
    if (isLocked || event.button !is 1) return;
    fixEvent(event);
    dragging = getGrabbedItem(event.x, event.y);
    if (dragging !is null) {
        mouseXOffset = event.x;
        itemXOffset = mouseXOffset - dragging.internalGetBounds().x;
        _setCursor(dragCursor);
    }
    fixEvent(event);
}
void onMouseExit() {
    if (dragging is null) _setCursor(null);
}
void onMouseMove(Event event) {
    if (isLocked) return;
    fixEvent(event);
    CoolItem grabbed = getGrabbedItem(event.x, event.y);
    if (dragging !is null) {
        int left_root = toDisplay(new Point(event.x - itemXOffset, event.y)).x;
        Rectangle bounds = dragging.internalGetBounds();
        if (event.y < bounds.y) {
            moveUp(dragging, left_root);
        } else if (event.y > bounds.y + bounds.height){
            moveDown(dragging, left_root);
        } else if (event.x < mouseXOffset) {
            int distance = Math.min(mouseXOffset, bounds.x + itemXOffset) - event.x;
            if (distance > 0) moveLeft(dragging, distance);
        } else if (event.x > mouseXOffset) {
            int distance = event.x - Math.max(mouseXOffset, bounds.x + itemXOffset);
            if (distance > 0) moveRight(dragging, distance);
        }
        mouseXOffset = event.x;
    } else {
        if (grabbed !is null) {
            _setCursor(hoverCursor);
        } else {
            _setCursor(null);
        }
    }
    fixEvent(event);
}
void onMouseUp(Event event) {
    _setCursor(null);
    dragging = null;
}
void onMouseDoubleClick(Event event) {
    if (isLocked) return;
    dragging = null;
    fixEvent(event);
    CoolItem target = getGrabbedItem(event.x, event.y);
    if (target is null) {
        _setCursor(null);
    } else {
        Point location = findItem(target);
        int row = location.y;
        int index = location.x;
        if (items[row].length > 1) {
            Rectangle  bounds = target.internalGetBounds();
            int maxSize = getWidth ();
            for (int i = 0; i < items[row].length; i++) {
                if (i !is index) {
                    maxSize -= items[row][i].internalGetMinimumWidth();
                }
            }
            if (bounds.width is maxSize) {
                /* The item is at its maximum width. It should be resized to its minimum width. */
                int distance = bounds.width - target.internalGetMinimumWidth();
                if (index + 1 < items[row].length) {
                    /* There is an item to the right. Maximize it. */
                    CoolItem right = items[row][index + 1];
                    moveLeft(right, distance);
                } else {
                    /* There is no item to the right. Move the item all the way right. */
                    moveRight(target, distance);
                }
            } else if (bounds.width < target.preferredWidth) {
                /* The item is less than its preferredWidth. Resize to preferredWidth. */
                int distance = target.preferredWidth - bounds.width;
                if (index + 1 < items[row].length) {
                    CoolItem right = items[row][index + 1];
                    moveRight(right, distance);
                    distance = target.preferredWidth - target.internalGetBounds().width;
                }
                if (distance > 0) {
                    moveLeft(target, distance);
                }
            } else {
                /* The item is at its minimum width. Maximize it. */
                for (int i = 0; i < items[row].length; i++) {
                    if (i !is index) {
                        CoolItem item = items[row][i];
                        item.requestedWidth = Math.max(item.internalGetMinimumWidth(), CoolItem.MINIMUM_WIDTH);
                    }
                }
                target.requestedWidth = maxSize;
                layoutItems();
            }
            _setCursor(hoverCursor);
        }
    }
    fixEvent(event);
}
void onPaint(Event event) {
    GC gc = event.gc;
    if (items.length is 0) return;
    Color shadowColor = display.getSystemColor(SWT.COLOR_WIDGET_NORMAL_SHADOW);
    Color highlightColor = display.getSystemColor(SWT.COLOR_WIDGET_HIGHLIGHT_SHADOW);
    bool vertical = (style & SWT.VERTICAL) !is 0;
    bool flat = (style & SWT.FLAT) !is 0;
    int stopX = getWidth();
    Rectangle rect;
    Rectangle clipping = gc.getClipping();
    for (int row = 0; row < items.length; row++) {
        Rectangle bounds = new Rectangle(0, 0, 0, 0);
        for (int i = 0; i < items[row].length; i++) {
            bounds = items[row][i].internalGetBounds();
            rect = fixRectangle(bounds.x, bounds.y, bounds.width, bounds.height);
            if (!clipping.intersects(rect)) continue;
            bool nativeGripper = false;

            /* Draw gripper. */
            if (!isLocked) {
                rect = fixRectangle(bounds.x, bounds.y, CoolItem.MINIMUM_WIDTH, bounds.height);
                if (!flat)  nativeGripper = drawGripper(rect.x, rect.y, rect.width, rect.height, vertical);
                if (!nativeGripper) {
                    int grabberTrim = 2;
                    int grabberHeight = bounds.height - (2 * grabberTrim) - 1;
                    gc.setForeground(shadowColor);
                    rect = fixRectangle(
                            bounds.x + CoolItem.MARGIN_WIDTH,
                            bounds.y + grabberTrim,
                            2,
                            grabberHeight);
                    gc.drawRectangle(rect);
                    gc.setForeground(highlightColor);
                    rect = fixRectangle(
                            bounds.x + CoolItem.MARGIN_WIDTH,
                            bounds.y + grabberTrim + 1,
                            bounds.x + CoolItem.MARGIN_WIDTH,
                            bounds.y + grabberTrim + grabberHeight - 1);
                    gc.drawLine(rect.x, rect.y, rect.width, rect.height);
                    rect = fixRectangle(
                            bounds.x + CoolItem.MARGIN_WIDTH,
                            bounds.y + grabberTrim,
                            bounds.x + CoolItem.MARGIN_WIDTH + 1,
                            bounds.y + grabberTrim);
                    gc.drawLine(rect.x, rect.y, rect.width, rect.height);
                }
            }

            /* Draw separator. */
            if (!flat && !nativeGripper && i !is 0) {
                gc.setForeground(shadowColor);
                rect = fixRectangle(bounds.x, bounds.y, bounds.x, bounds.y + bounds.height - 1);
                gc.drawLine(rect.x, rect.y, rect.width, rect.height);
                gc.setForeground(highlightColor);
                rect = fixRectangle(bounds.x + 1, bounds.y, bounds.x + 1, bounds.y + bounds.height - 1);
                gc.drawLine(rect.x, rect.y, rect.width, rect.height);
            }
        }
        if (!flat && row + 1 < items.length) {
            /* Draw row separator. */
            int separatorY = bounds.y + bounds.height;
            gc.setForeground(shadowColor);
            rect = fixRectangle(0, separatorY, stopX, separatorY);
            gc.drawLine(rect.x, rect.y, rect.width, rect.height);
            gc.setForeground(highlightColor);
            rect = fixRectangle(0, separatorY + 1, stopX, separatorY + 1);
            gc.drawLine(rect.x, rect.y, rect.width, rect.height);
        }
    }
}
void onResize () {
    layoutItems ();
}
override void removeControl (Control control) {
    super.removeControl (control);
    CoolItem [] items = getItems ();
    for (int i=0; i<items.length; i++) {
        CoolItem item = items [i];
        if (item.control is control) item.setControl (null);
    }
}
/**
 * Remove the item from the row. Adjust the x and width values
 * appropriately.
 */
void removeItemFromRow(CoolItem item, int rowIndex, bool disposed) {
    int index = findItem(item).x;
    ptrdiff_t newLength = items[rowIndex].length - 1;
    Rectangle itemBounds = item.internalGetBounds();
    item.wrap = false;
    if (newLength > 0) {
        CoolItem[] newRow = new CoolItem[newLength];
        System.arraycopy(items[rowIndex], 0, newRow, 0, index);
        System.arraycopy(items[rowIndex], index + 1, newRow, index, newRow.length - index);
        items[rowIndex] = newRow;
        items[rowIndex][0].wrap = true;
    } else {
        CoolItem[][] newRows = new CoolItem[][]( items.length - 1 );
        SimpleType!(CoolItem[]).arraycopy(items, 0, newRows, 0, rowIndex);
        SimpleType!(CoolItem[]).arraycopy(items, rowIndex + 1, newRows, rowIndex, newRows.length - rowIndex);
        items = newRows;
        return;
    }
    if (!disposed) {
        if (index is 0) {
            CoolItem first = items[rowIndex][0];
            Rectangle bounds = first.internalGetBounds();
            int width = bounds.x + bounds.width;
            first.setBounds(0, bounds.y, width, bounds.height);
            first.requestedWidth = width;
            internalRedraw(bounds.x, bounds.y, CoolItem.MINIMUM_WIDTH, bounds.height);
        } else {
            CoolItem previous = items[rowIndex][index - 1];
            Rectangle bounds = previous.internalGetBounds();
            int width = bounds.width + itemBounds.width;
            previous.setBounds(bounds.x, bounds.y, width, bounds.height);
            previous.requestedWidth = width;
        }
    }
}
/**
 * Return the height of the bar after it has
 * been properly laid out for the given width.
 */
int layoutItems () {
    int y = 0, width;
    if ((style&SWT.VERTICAL) !is 0) {
        width = getClientArea().height;
    } else {
        width = getClientArea().width;
    }
    wrapItems(width);
    int rowSpacing = (style & SWT.FLAT) !is 0 ? 0 : ROW_SPACING;
    for (int row = 0; row < items.length; row++) {
        ptrdiff_t count = items[row].length;
        int x = 0;

        /* determine the height and the available width for the row */
        int rowHeight = 0;
        int available = width;
        for (int i = 0; i < count; i++) {
            CoolItem item = items[row][i];
            rowHeight = Math.max(rowHeight, item.internalGetBounds().height);
            available -= item.internalGetMinimumWidth();
        }
        if (row > 0) y += rowSpacing;

        /* lay the items out */
        for (int i = 0; i < count; i++) {
            CoolItem child = items[row][i];
            int newWidth = available + child.internalGetMinimumWidth();
            if (i + 1 < count) {
                newWidth = Math.min(newWidth, child.requestedWidth);
                available -= (newWidth - child.internalGetMinimumWidth());
            }
            Rectangle oldBounds = child.internalGetBounds();
            Rectangle newBounds = new Rectangle(x, y, newWidth, rowHeight);
            if ( oldBounds !=/*eq*/ newBounds) {
                child.setBounds(newBounds.x, newBounds.y, newBounds.width, newBounds.height);
                Rectangle damage = new Rectangle(0, 0, 0, 0);
                /* Cases are in descending order from most area to redraw to least. */
                if (oldBounds.y !is newBounds.y) {
                    damage = newBounds;
                    damage.add(oldBounds);
                    /* Redraw the row separator as well. */
                    damage.y -= rowSpacing;
                    damage.height += 2 * rowSpacing;
                } else if (oldBounds.height !is newBounds.height) {
                    /*
                     * Draw from the bottom of the gripper to the bottom of the new area.
                     * (Bottom of the gripper is -3 from the bottom of the item).
                     */
                    damage.y = newBounds.y + Math.min(oldBounds.height, newBounds.height) - 3;
                    damage.height = newBounds.y + newBounds.height + rowSpacing;
                    damage.x = oldBounds.x - CoolItem.MARGIN_WIDTH;
                    damage.width = oldBounds.width + CoolItem.MARGIN_WIDTH;
                } else if (oldBounds.x !is newBounds.x) {
                    /* Redraw only the difference between the separators. */
                    damage.x = Math.min(oldBounds.x, newBounds.x);
                    damage.width = Math.abs(oldBounds.x - newBounds.x) + CoolItem.MINIMUM_WIDTH;
                    damage.y = oldBounds.y;
                    damage.height = oldBounds.height;
                }
                internalRedraw(damage.x, damage.y, damage.width, damage.height);
            }
            x += newWidth;
        }
        y += rowHeight;
    }
    return y;
}
void relayout() {
    Point size = getSize();
    int height = layoutItems();
    if ((style & SWT.VERTICAL) !is 0) {
        Rectangle trim = computeTrim (0, 0, height, 0);
        if (height !is size.x) super.setSize(trim.width, size.y);
    } else {
        Rectangle trim = computeTrim (0, 0, 0, height);
        if (height !is size.y) super.setSize(size.x, trim.height);
    }
}
/**
 * Returns an array of zero-relative ints that map
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
 */
public int[] getItemOrder () {
    checkWidget ();
    int count = getItemCount ();
    int [] indices = new int [count];
    count = 0;
    for (int i = 0; i < items.length; i++) {
        for (int j = 0; j < items[i].length; j++) {
            CoolItem item = items[i][j];
            int index = 0;
            while (index<originalItems.length) {
                if (originalItems [index] is item) break;
                index++;
            }
            if (index is originalItems.length) error (SWT.ERROR_CANNOT_GET_ITEM);
            indices [count++] = index;
        }
    }
    return indices;
}
void setItemOrder (int[] itemOrder) {
    // SWT extension: allow null for zero length string
    //if (itemOrder is null) error(SWT.ERROR_NULL_ARGUMENT);
    ptrdiff_t count = originalItems.length;
    if (itemOrder.length !is count) error(SWT.ERROR_INVALID_ARGUMENT);

    /* Ensure that itemOrder does not contain any duplicates. */
    bool [] set = new bool [count];
    for (int i = 0; i < set.length; i++) set [i] = false;
    for (int i = 0; i < itemOrder.length; i++) {
        if (itemOrder [i] < 0 || itemOrder [i] >= count) error (SWT.ERROR_INVALID_ARGUMENT);
        if (set [itemOrder [i]]) error (SWT.ERROR_INVALID_ARGUMENT);
        set [itemOrder [i]] = true;
    }

    CoolItem[] row = new CoolItem[count];
    for (int i = 0; i < count; i++) {
        row[i] = originalItems[itemOrder[i]];
    }
    items = new CoolItem[][](1,count);
    items[0] = row;
}
/**
 * Returns an array of points whose x and y coordinates describe
 * the widths and heights (respectively) of the items in the receiver
 * in the order in which they are currently being displayed.
 *
 * @return the receiver's item sizes in their current visual order
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point[] getItemSizes () {
    checkWidget();
    CoolItem[] items = getItems();
    Point[] sizes = new Point[items.length];
    for (int i = 0; i < items.length; i++) {
        sizes[i] = items[i].getSize();
    }
    return sizes;
}
void setItemSizes (Point[] sizes) {
    // SWT extension: allow null for zero length string
    //if (sizes is null) error(SWT.ERROR_NULL_ARGUMENT);
    CoolItem[] items = getItems();
    if (sizes.length !is items.length) error(SWT.ERROR_INVALID_ARGUMENT);
    for (int i = 0; i < items.length; i++) {
        items[i].setSize(sizes[i]);
    }
}
/**
 * Returns whether or not the receiver is 'locked'. When a coolbar
 * is locked, its items cannot be repositioned.
 *
 * @return true if the coolbar is locked, false otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 */
public bool getLocked () {
    checkWidget ();
    return isLocked;
}
int getWidth () {
    if ((style & SWT.VERTICAL) !is 0) return getSize().y;
    return getSize().x;
}
/**
 * Returns an array of ints that describe the zero-relative
 * indices of any item(s) in the receiver that will begin on
 * a new row. The 0th visible item always begins the first row,
 * therefore it does not count as a wrap index.
 *
 * @return an array containing the receiver's wrap indices, or an empty array if all items are in one row
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int[] getWrapIndices () {
    checkWidget();
    if (items.length <= 1) return null;
    int[] wrapIndices = new int[]( items.length - 1 );
    ptrdiff_t i = 0, nextWrap = items[0].length;
    for (int row = 1; row < items.length; row++) {
        if (items[row][0].wrap) wrapIndices[i++] = cast(int)/*64bit*/nextWrap;
        nextWrap += items[row].length;
    }
    if (i !is wrapIndices.length) {
        int[] tmp = new int[i];
        System.arraycopy(wrapIndices, 0, tmp, 0, i);
        return tmp;
    }
    return wrapIndices;
}
/**
 * Sets whether or not the receiver is 'locked'. When a coolbar
 * is locked, its items cannot be repositioned.
 *
 * @param locked lock the coolbar if true, otherwise unlock the coolbar
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 */
public void setLocked (bool locked) {
    checkWidget ();
    if (isLocked !is locked) {
        redraw();
    }
    isLocked = locked;

}
/**
 * Sets the indices of all item(s) in the receiver that will
 * begin on a new row. The indices are given in the order in
 * which they are currently being displayed. The 0th item
 * always begins the first row, therefore it does not count
 * as a wrap index. If indices is null or empty, the items
 * will be placed on one line.
 *
 * @param indices an array of wrap indices, or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setWrapIndices (int[] indices) {
    checkWidget();
    if (indices is null) indices = new int[0];
    ptrdiff_t count = originalItems.length;
    for (int i=0; i<indices.length; i++) {
        if (indices[i] < 0 || indices[i] >= count) {
            error (SWT.ERROR_INVALID_ARGUMENT);
        }
    }
    for (int i=0; i<originalItems.length; i++) {
        originalItems[i].wrap = false;
    }
    for (int i=0; i<indices.length; i++) {
        int index = indices[i];
        for (int row = 0; row < items.length; row++) {
            if (items[row].length > index) {
                items[row][index].wrap = true;
                break;
            } else {
                index -= items[row].length;
            }
        }
    }
    relayout();
}
public override void setCursor (Cursor cursor) {
    checkWidget ();
    super.setCursor (this.cursor = cursor);
}
/**
 * Sets the receiver's item order, wrap indices, and item sizes
 * all at once. This method is typically used to restore the
 * displayed state of the receiver to a previously stored state.
 * <p>
 * The item order is the order in which the items in the receiver
 * should be displayed, given in terms of the zero-relative ordering
 * of when the items were added.
 * </p><p>
 * The wrap indices are the indices of all item(s) in the receiver
 * that will begin on a new row. The indices are given in the order
 * specified by the item order. The 0th item always begins the first
 * row, therefore it does not count as a wrap index. If wrap indices
 * is null or empty, the items will be placed on one line.
 * </p><p>
 * The sizes are specified in an array of points whose x and y
 * coordinates describe the new widths and heights (respectively)
 * of the receiver's items in the order specified by the item order.
 * </p>
 *
 * @param itemOrder an array of indices that describe the new order to display the items in
 * @param wrapIndices an array of wrap indices, or null
 * @param sizes an array containing the new sizes for each of the receiver's items in visual order
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if item order or sizes is not the same length as the number of items</li>
 * </ul>
 */
public void setItemLayout (int[] itemOrder, int[] wrapIndices, Point[] sizes) {
    checkWidget();
    setItemOrder(itemOrder);
    setWrapIndices(wrapIndices);
    setItemSizes(sizes);
    relayout();
}
void wrapItems (int maxWidth) {
    ptrdiff_t itemCount = originalItems.length;
    if (itemCount < 2) return;
    CoolItem[] itemsVisual = new CoolItem[itemCount];
    int start = 0;
    for (int row = 0; row < items.length; row++) {
        System.arraycopy(items[row], 0, itemsVisual, start, items[row].length);
        start += items[row].length;
    }
    CoolItem[][] newItems = new CoolItem[][](itemCount);
    int rowCount = 0, rowWidth =  0;
    start = 0;
    for (int i = 0; i < itemCount; i++) {
        CoolItem item = itemsVisual[i];
        int itemWidth = item.internalGetMinimumWidth();
        if ((i > 0 && item.wrap) || (maxWidth !is SWT.DEFAULT && rowWidth + itemWidth > maxWidth)) {
            if (i is start) {
                newItems[rowCount] = new CoolItem[1];
                newItems[rowCount][0] = item;
                start = i + 1;
                rowWidth = 0;
            } else {
                int count = i - start;
                newItems[rowCount] = new CoolItem[count];
                System.arraycopy(itemsVisual, start, newItems[rowCount], 0, count);
                start = i;
                rowWidth = itemWidth;
            }
            rowCount++;
        } else {
            rowWidth += itemWidth;
        }
    }
    if (start < itemCount) {
        ptrdiff_t count = itemCount - start;
        newItems[rowCount] = new CoolItem[count];
        System.arraycopy(itemsVisual, start, newItems[rowCount], 0, count);
        rowCount++;
    }
    if (newItems.length !is rowCount) {
        CoolItem[][] tmp = new CoolItem[][](rowCount);
        SimpleType!(CoolItem[]).arraycopy(newItems, 0, tmp, 0, rowCount);
        items = tmp;
    } else {
        items = newItems;
    }
}
}
