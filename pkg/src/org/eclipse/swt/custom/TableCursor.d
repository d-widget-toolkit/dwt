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
module org.eclipse.swt.custom.TableCursor;

import java.lang.all;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Canvas;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.ScrollBar;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableColumn;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Widget;

/**
 * A TableCursor provides a way for the user to navigate around a Table
 * using the keyboard.  It also provides a mechanism for selecting an
 * individual cell in a table.
 *
 * <p> Here is an example of using a TableCursor to navigate to a cell and then edit it.
 *
 * <code><pre>
 *  public static void main(String[] args) {
 *      Display display = new Display();
 *      Shell shell = new Shell(display);
 *      shell.setLayout(new GridLayout());
 *
 *      // create a a table with 3 columns and fill with data
 *      final Table table = new Table(shell, SWT.BORDER | SWT.MULTI | SWT.FULL_SELECTION);
 *      table.setLayoutData(new GridData(GridData.FILL_BOTH));
 *      TableColumn column1 = new TableColumn(table, SWT.NONE);
 *      TableColumn column2 = new TableColumn(table, SWT.NONE);
 *      TableColumn column3 = new TableColumn(table, SWT.NONE);
 *      for (int i = 0; i &lt; 100; i++) {
 *          TableItem item = new TableItem(table, SWT.NONE);
 *          item.setText(new String[] { "cell "+i+" 0", "cell "+i+" 1", "cell "+i+" 2"});
 *      }
 *      column1.pack();
 *      column2.pack();
 *      column3.pack();
 *
 *      // create a TableCursor to navigate around the table
 *      final TableCursor cursor = new TableCursor(table, SWT.NONE);
 *      // create an editor to edit the cell when the user hits "ENTER"
 *      // while over a cell in the table
 *      final ControlEditor editor = new ControlEditor(cursor);
 *      editor.grabHorizontal = true;
 *      editor.grabVertical = true;
 *
 *      cursor.addSelectionListener(new SelectionAdapter() {
 *          // when the TableEditor is over a cell, select the corresponding row in
 *          // the table
 *          public void widgetSelected(SelectionEvent e) {
 *              table.setSelection(new TableItem[] {cursor.getRow()});
 *          }
 *          // when the user hits "ENTER" in the TableCursor, pop up a text editor so that
 *          // they can change the text of the cell
 *          public void widgetDefaultSelected(SelectionEvent e){
 *              final Text text = new Text(cursor, SWT.NONE);
 *              TableItem row = cursor.getRow();
 *              int column = cursor.getColumn();
 *              text.setText(row.getText(column));
 *              text.addKeyListener(new KeyAdapter() {
 *                  public void keyPressed(KeyEvent e) {
 *                      // close the text editor and copy the data over
 *                      // when the user hits "ENTER"
 *                      if (e.character is SWT.CR) {
 *                          TableItem row = cursor.getRow();
 *                          int column = cursor.getColumn();
 *                          row.setText(column, text.getText());
 *                          text.dispose();
 *                      }
 *                      // close the text editor when the user hits "ESC"
 *                      if (e.character is SWT.ESC) {
 *                          text.dispose();
 *                      }
 *                  }
 *              });
 *              editor.setEditor(text);
 *              text.setFocus();
 *          }
 *      });
 *      // Hide the TableCursor when the user hits the "MOD1" or "MOD2" key.
 *      // This allows the user to select multiple items in the table.
 *      cursor.addKeyListener(new KeyAdapter() {
 *          public void keyPressed(KeyEvent e) {
 *              if (e.keyCode is SWT.MOD1 ||
 *                  e.keyCode is SWT.MOD2 ||
 *                  (e.stateMask & SWT.MOD1) !is 0 ||
 *                  (e.stateMask & SWT.MOD2) !is 0) {
 *                  cursor.setVisible(false);
 *              }
 *          }
 *      });
 *      // Show the TableCursor when the user releases the "MOD2" or "MOD1" key.
 *      // This signals the end of the multiple selection task.
 *      table.addKeyListener(new KeyAdapter() {
 *          public void keyReleased(KeyEvent e) {
 *              if (e.keyCode is SWT.MOD1 && (e.stateMask & SWT.MOD2) !is 0) return;
 *              if (e.keyCode is SWT.MOD2 && (e.stateMask & SWT.MOD1) !is 0) return;
 *              if (e.keyCode !is SWT.MOD1 && (e.stateMask & SWT.MOD1) !is 0) return;
 *              if (e.keyCode !is SWT.MOD2 && (e.stateMask & SWT.MOD2) !is 0) return;
 *
 *              TableItem[] selection = table.getSelection();
 *              TableItem row = (selection.length is 0) ? table.getItem(table.getTopIndex()) : selection[0];
 *              table.showItem(row);
 *              cursor.setSelection(row, 0);
 *              cursor.setVisible(true);
 *              cursor.setFocus();
 *          }
 *      });
 *
 *      shell.open();
 *      while (!shell.isDisposed()) {
 *          if (!display.readAndDispatch())
 *              display.sleep();
 *      }
 *      display.dispose();
 *  }
 * </pre></code>
 *
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>BORDER</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection, DefaultSelection</dd>
 * </dl>
 *
 * @since 2.0
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#tablecursor">TableCursor snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a> 
 */
public class TableCursor : Canvas {

    alias Canvas.dispose dispose;

    Table table;
    TableItem row = null;
    TableColumn column = null;
    Listener tableListener, resizeListener, disposeItemListener, disposeColumnListener;

    Color background = null;
    Color foreground = null;

    // By default, invert the list selection colors
    static const int BACKGROUND = SWT.COLOR_LIST_SELECTION_TEXT;
    static const int FOREGROUND = SWT.COLOR_LIST_SELECTION;

/**
 * Constructs a new instance of this class given its parent
 * table and a style value describing its behavior and appearance.
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
 * @param parent a Table control which will be the parent of the new instance (cannot be null)
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
 * @see SWT#BORDER
 * @see Widget#checkSubclass()
 * @see Widget#getStyle()
 */
public this(Table parent, int style) {
    super(parent, style);
    table = parent;
    setBackground(null);
    setForeground(null);

    Listener listener = new class() Listener {
        public void handleEvent(Event event) {
            switch (event.type) {
                case SWT.Dispose :
                    TableCursor.dispose(event);
                    break;
                case SWT.FocusIn :
                case SWT.FocusOut :
                    redraw();
                    break;
                case SWT.KeyDown :
                    keyDown(event);
                    break;
                case SWT.Paint :
                    paint(event);
                    break;
                case SWT.Traverse : {
                    event.doit = true;
                    switch (event.detail) {
                        case SWT.TRAVERSE_ARROW_NEXT :
                        case SWT.TRAVERSE_ARROW_PREVIOUS :
                        case SWT.TRAVERSE_RETURN :
                            event.doit = false;
                            break;
                        default:
                    }
                    break;
                }
                default:
            }
        }
    };
    int[] events = [SWT.Dispose, SWT.FocusIn, SWT.FocusOut, SWT.KeyDown, SWT.Paint, SWT.Traverse];
    for (int i = 0; i < events.length; i++) {
        addListener(events[i], listener);
    }

    tableListener = new class() Listener {
        public void handleEvent(Event event) {
            switch (event.type) {
                case SWT.MouseDown :
                    tableMouseDown(event);
                    break;
                case SWT.FocusIn :
                    tableFocusIn(event);
                    break;
                default:
            }
        }
    };
    table.addListener(SWT.FocusIn, tableListener);
    table.addListener(SWT.MouseDown, tableListener);

    disposeItemListener = new class() Listener {
        public void handleEvent(Event event) {
            unhookRowColumnListeners();
            row = null;
            column = null;
            _resize();
        }
    };
    disposeColumnListener = new class() Listener {
        public void handleEvent(Event event) {
            unhookRowColumnListeners();
            row = null;
            column = null;
            _resize();
        }
    };
    resizeListener = new class() Listener {
        public void handleEvent(Event event) {
            _resize();
        }
    };
    ScrollBar hBar = table.getHorizontalBar();
    if (hBar !is null) {
        hBar.addListener(SWT.Selection, resizeListener);
    }
    ScrollBar vBar = table.getVerticalBar();
    if (vBar !is null) {
        vBar.addListener(SWT.Selection, resizeListener);
    }
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
 * @see SelectionEvent
 * @see #removeSelectionListener(SelectionListener)
 *
 */
public void addSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null)
        SWT.error(SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener(listener);
    addListener(SWT.Selection, typedListener);
    addListener(SWT.DefaultSelection, typedListener);
}

void dispose(Event event) {
    table.removeListener(SWT.FocusIn, tableListener);
    table.removeListener(SWT.MouseDown, tableListener);
    unhookRowColumnListeners();
    ScrollBar hBar = table.getHorizontalBar();
    if (hBar !is null) {
        hBar.removeListener(SWT.Selection, resizeListener);
    }
    ScrollBar vBar = table.getVerticalBar();
    if (vBar !is null) {
        vBar.removeListener(SWT.Selection, resizeListener);
    }
}

void keyDown(Event event) {
    if (row is null) return;
    switch (event.character) {
        case SWT.CR :
            notifyListeners(SWT.DefaultSelection, new Event());
            return;
        default:
    }
    int rowIndex = table.indexOf(row);
    int columnIndex = column is null ? 0 : table.indexOf(column);
    switch (event.keyCode) {
        case SWT.ARROW_UP :
            setRowColumn(Math.max(0, rowIndex - 1), columnIndex, true);
            break;
        case SWT.ARROW_DOWN :
            setRowColumn(Math.min(rowIndex + 1, table.getItemCount() - 1), columnIndex, true);
            break;
        case SWT.ARROW_LEFT :
        case SWT.ARROW_RIGHT :
            {
                int columnCount = table.getColumnCount();
                if (columnCount is 0) break;
                int[] order = table.getColumnOrder();
                int index = 0;
                while (index < order.length) {
                    if (order[index] is columnIndex) break;
                    index++;
                }
                if (index is order.length) index = 0;
                int leadKey = (getStyle() & SWT.RIGHT_TO_LEFT) !is 0 ? SWT.ARROW_RIGHT : SWT.ARROW_LEFT;
                if (event.keyCode is leadKey) {
                   setRowColumn(rowIndex, order[Math.max(0, index - 1)], true);
                } else {
                   setRowColumn(rowIndex, order[Math.min(columnCount - 1, index + 1)], true);
                }
                break;
            }
        case SWT.HOME :
            setRowColumn(0, columnIndex, true);
            break;
        case SWT.END :
            {
                int i = table.getItemCount() - 1;
                setRowColumn(i, columnIndex, true);
                break;
            }
        case SWT.PAGE_UP :
            {
                int index = table.getTopIndex();
                if (index is rowIndex) {
                    Rectangle rect = table.getClientArea();
                    TableItem item = table.getItem(index);
                    Rectangle itemRect = item.getBounds(0);
                    rect.height -= itemRect.y;
                    int height = table.getItemHeight();
                    int page = Math.max(1, rect.height / height);
                    index = Math.max(0, index - page + 1);
                }
                setRowColumn(index, columnIndex, true);
                break;
            }
        case SWT.PAGE_DOWN :
            {
                int index = table.getTopIndex();
                Rectangle rect = table.getClientArea();
                TableItem item = table.getItem(index);
                Rectangle itemRect = item.getBounds(0);
                rect.height -= itemRect.y;
                int height = table.getItemHeight();
                int page = Math.max(1, rect.height / height);
                int end = table.getItemCount() - 1;
                index = Math.min(end, index + page - 1);
                if (index is rowIndex) {
                    index = Math.min(end, index + page - 1);
                }
                setRowColumn(index, columnIndex, true);
                break;
            }
        default:
    }
}

void paint(Event event) {
    if (row is null) return;
    int columnIndex = column is null ? 0 : table.indexOf(column);
    GC gc = event.gc;
    Display display = getDisplay();
    gc.setBackground(getBackground());
    gc.setForeground(getForeground());
    gc.fillRectangle(event.x, event.y, event.width, event.height);
    int x = 0;
    Point size = getSize();
    Image image = row.getImage(columnIndex);
    if (image !is null) {
        Rectangle imageSize = image.getBounds();
        int imageY = (size.y - imageSize.height) / 2;
        gc.drawImage(image, x, imageY);
        x += imageSize.width;
    }
    String text = row.getText(columnIndex);
    if (text.length > 0) {
        Rectangle bounds = row.getBounds(columnIndex);
        Point extent = gc.stringExtent(text);
        // Temporary code - need a better way to determine table trim
        String platform = SWT.getPlatform();
        if ("win32"==platform) { //$NON-NLS-1$
            if (table.getColumnCount() is 0 || columnIndex is 0) {
                x += 2;
            } else {
                int alignmnent = column.getAlignment();
                switch (alignmnent) {
                    case SWT.LEFT:
                        x += 6;
                        break;
                    case SWT.RIGHT:
                        x = bounds.width - extent.x - 6;
                        break;
                    case SWT.CENTER:
                        x += (bounds.width - x - extent.x) / 2;
                        break;
                    default:
                }
            }
        }  else {
            if (table.getColumnCount() is 0) {
                x += 5;
            } else {
                int alignmnent = column.getAlignment();
                switch (alignmnent) {
                    case SWT.LEFT:
                        x += 5;
                        break;
                    case SWT.RIGHT:
                        x = bounds.width- extent.x - 2;
                        break;
                    case SWT.CENTER:
                        x += (bounds.width - x - extent.x) / 2 + 2;
                        break;
                    default:
                }
            }
        }
        int textY = (size.y - extent.y) / 2;
        gc.drawString(text, x, textY);
    }
    if (isFocusControl()) {
        gc.setBackground(display.getSystemColor(SWT.COLOR_BLACK));
        gc.setForeground(display.getSystemColor(SWT.COLOR_WHITE));
        gc.drawFocus(0, 0, size.x, size.y);
    }
}

void tableFocusIn(Event event) {
    if (isDisposed()) return;
    if (isVisible()) {
        if (row is null && column is null) return;
        setFocus();
    }
}

void tableMouseDown(Event event) {
    if (isDisposed() || !isVisible()) return;
    Point pt = new Point(event.x, event.y);
    int lineWidth = table.getLinesVisible() ? table.getGridLineWidth() : 0;
    TableItem item = table.getItem(pt);
    if ((table.getStyle() & SWT.FULL_SELECTION) !is 0) {
        if (item is null) return;
    } else {
        int start = item !is null ? table.indexOf(item) : table.getTopIndex();
        int end = table.getItemCount();
        Rectangle clientRect = table.getClientArea();
        for (int i = start; i < end; i++) {
            TableItem nextItem = table.getItem(i);
            Rectangle rect = nextItem.getBounds(0);
            if (pt.y >= rect.y && pt.y < rect.y + rect.height + lineWidth) {
                item = nextItem;
                break;
            }
            if (rect.y > clientRect.y + clientRect.height)  return;
        }
        if (item is null) return;
    }
    TableColumn newColumn = null;
    int columnCount = table.getColumnCount();
    if (columnCount is 0) {
        if ((table.getStyle() & SWT.FULL_SELECTION) is 0) {
            Rectangle rect = item.getBounds(0);
            rect.width += lineWidth;
            rect.height += lineWidth;
            if (!rect.contains(pt)) return;
        }
    } else {
        for (int i = 0; i < columnCount; i++) {
            Rectangle rect = item.getBounds(i);
            rect.width += lineWidth;
            rect.height += lineWidth;
            if (rect.contains(pt)) {
                newColumn = table.getColumn(i);
                break;
            }
        }
        if (newColumn is null) {
            if ((table.getStyle() & SWT.FULL_SELECTION) is 0) return;
            newColumn = table.getColumn(0);
        }
    }
    setRowColumn(item, newColumn, true);
    setFocus();
    return;
}
void setRowColumn(int row, int column, bool notify) {
    TableItem item = row is -1 ? null : table.getItem(row);
    TableColumn col = column is -1 || table.getColumnCount() is 0 ? null : table.getColumn(column);
    setRowColumn(item, col, notify);
}
void setRowColumn(TableItem row, TableColumn column, bool notify) {
    if (this.row is row && this.column is column) {
        return;
    }
    if (this.row !is null && this.row !is row) {
        this.row.removeListener(SWT.Dispose, disposeItemListener);
        this.row = null;
    }
    if (this.column !is null && this.column !is column) {
        this.column.removeListener(SWT.Dispose, disposeColumnListener);
        this.column.removeListener(SWT.Move, resizeListener);
        this.column.removeListener(SWT.Resize, resizeListener);
        this.column = null;
    }
    if (row !is null) {
        if (this.row !is row) {
            this.row = row;
            row.addListener(SWT.Dispose, disposeItemListener);
            table.showItem(row);
        }
        if (this.column !is column && column !is null) {
            this.column = column;
            column.addListener(SWT.Dispose, disposeColumnListener);
            column.addListener(SWT.Move, resizeListener);
            column.addListener(SWT.Resize, resizeListener);
            table.showColumn(column);
        }
        int columnIndex = column is null ? 0 : table.indexOf(column);
        setBounds(row.getBounds(columnIndex));
        redraw();
        if (notify) {
            notifyListeners(SWT.Selection, new Event());
        }
    }
}

public override void setVisible(bool visible) {
    checkWidget();
    if (visible) _resize();
    super.setVisible(visible);
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
 * @see #addSelectionListener(SelectionListener)
 *
 * @since 3.0
 */
public void removeSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null) {
        SWT.error(SWT.ERROR_NULL_ARGUMENT);
    }
    removeListener(SWT.Selection, listener);
    removeListener(SWT.DefaultSelection, listener);
}

void _resize() {
    if (row is null) {
        setBounds(-200, -200, 0, 0);
    } else {
        int columnIndex = column is null ? 0 : table.indexOf(column);
        setBounds(row.getBounds(columnIndex));
    }
}
/**
 * Returns the column over which the TableCursor is positioned.
 *
 * @return the column for the current position
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getColumn() {
    checkWidget();
    return column is null ? 0 : table.indexOf(column);
}
/**
 * Returns the background color that the receiver will use to draw.
 *
 * @return the receiver's background color
 */
override
public Color getBackground() {
    checkWidget();
    if (background is null) {
        return getDisplay().getSystemColor(BACKGROUND);
    }
    return background;
}
/**
 * Returns the foreground color that the receiver will use to draw.
 *
 * @return the receiver's foreground color
 */
override
public Color getForeground() {
    checkWidget();
    if (foreground is null) {
        return getDisplay().getSystemColor(FOREGROUND);
    }
    return foreground;
}
/**
 * Returns the row over which the TableCursor is positioned.
 *
 * @return the item for the current position
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public TableItem getRow() {
    checkWidget();
    return row;
}
/**
 * Sets the receiver's background color to the color specified
 * by the argument, or to the default system color for the control
 * if the argument is null.
 * <p>
 * Note: This operation is a hint and may be overridden by the platform.
 * For example, on Windows the background of a Button cannot be changed.
 * </p>
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li> 
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public override void setBackground (Color color) {
    background = color;
    super.setBackground(getBackground());
    redraw();
}
/**
 * Sets the receiver's foreground color to the color specified
 * by the argument, or to the default system color for the control
 * if the argument is null.
 * <p>
 * Note: This operation is a hint and may be overridden by the platform.
 * </p>
 * @param color the new color (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li> 
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public override void setForeground (Color color) {
    foreground = color;
    super.setForeground(getForeground());
    redraw();
}
/**
 * Positions the TableCursor over the cell at the given row and column in the parent table.
 *
 * @param row the index of the row for the cell to select
 * @param column the index of column for the cell to select
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 */
public void setSelection(int row, int column) {
    checkWidget();
    int columnCount = table.getColumnCount();
    int maxColumnIndex =  columnCount is 0 ? 0 : columnCount - 1;
    if (row < 0
        || row >= table.getItemCount()
        || column < 0
        || column > maxColumnIndex)
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    setRowColumn(row, column, false);
}
/**
 * Positions the TableCursor over the cell at the given row and column in the parent table.
 *
 * @param row the TableItem of the row for the cell to select
 * @param column the index of column for the cell to select
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 */
public void setSelection(TableItem row, int column) {
    checkWidget();
    int columnCount = table.getColumnCount();
    int maxColumnIndex =  columnCount is 0 ? 0 : columnCount - 1;
    if (row is null
        || row.isDisposed()
        || column < 0
        || column > maxColumnIndex)
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    setRowColumn(table.indexOf(row), column, false);
}
void unhookRowColumnListeners() {
    if (column !is null) {
        column.removeListener(SWT.Dispose, disposeColumnListener);
        column.removeListener(SWT.Move, resizeListener);
        column.removeListener(SWT.Resize, resizeListener);
        column = null;
    }
    if (row !is null) {
        row.removeListener(SWT.Dispose, disposeItemListener);
        row = null;
    }
}
}
