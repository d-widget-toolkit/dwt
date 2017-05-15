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
module org.eclipse.swt.layout.GridLayout;

import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Layout;
import org.eclipse.swt.widgets.Scrollable;

import java.lang.System;

import java.lang.all;


/**
 * Instances of this class lay out the control children of a
 * <code>Composite</code> in a grid.
 * <p>
 * <code>GridLayout</code> has a number of configuration fields, and the
 * controls it lays out can have an associated layout data object, called
 * <code>GridData</code>. The power of <code>GridLayout</code> lies in the
 * ability to configure <code>GridData</code> for each control in the layout.
 * </p>
 * <p>
 * The following code creates a shell managed by a <code>GridLayout</code>
 * with 3 columns:
 * <pre>
 *      Display display = new Display();
 *      Shell shell = new Shell(display);
 *      GridLayout gridLayout = new GridLayout();
 *      gridLayout.numColumns = 3;
 *      shell.setLayout(gridLayout);
 * </pre>
 * The <code>numColumns</code> field is the most important field in a
 * <code>GridLayout</code>. Widgets are laid out in columns from left
 * to right, and a new row is created when <code>numColumns</code> + 1
 * controls are added to the <code>Composite<code>.
 * </p>
 *
 * @see GridData
 * @see <a href="http://www.eclipse.org/swt/snippets/#gridlayout">GridLayout snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: LayoutExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class GridLayout : Layout {

    /**
     * numColumns specifies the number of cell columns in the layout.
     * If numColumns has a value less than 1, the layout will not
     * set the size and position of any controls.
     *
     * The default value is 1.
     */
    public int numColumns = 1;

    /**
     * makeColumnsEqualWidth specifies whether all columns in the layout
     * will be forced to have the same width.
     *
     * The default value is false.
     */
    public bool makeColumnsEqualWidth = false;

    /**
     * marginWidth specifies the number of pixels of horizontal margin
     * that will be placed along the left and right edges of the layout.
     *
     * The default value is 5.
     */
    public int marginWidth = 5;

    /**
     * marginHeight specifies the number of pixels of vertical margin
     * that will be placed along the top and bottom edges of the layout.
     *
     * The default value is 5.
     */
    public int marginHeight = 5;

    /**
     * marginLeft specifies the number of pixels of horizontal margin
     * that will be placed along the left edge of the layout.
     *
     * The default value is 0.
     *
     * @since 3.1
     */
    public int marginLeft = 0;

    /**
     * marginTop specifies the number of pixels of vertical margin
     * that will be placed along the top edge of the layout.
     *
     * The default value is 0.
     *
     * @since 3.1
     */
    public int marginTop = 0;

    /**
     * marginRight specifies the number of pixels of horizontal margin
     * that will be placed along the right edge of the layout.
     *
     * The default value is 0.
     *
     * @since 3.1
     */
    public int marginRight = 0;

    /**
     * marginBottom specifies the number of pixels of vertical margin
     * that will be placed along the bottom edge of the layout.
     *
     * The default value is 0.
     *
     * @since 3.1
     */
    public int marginBottom = 0;

    /**
     * horizontalSpacing specifies the number of pixels between the right
     * edge of one cell and the left edge of its neighbouring cell to
     * the right.
     *
     * The default value is 5.
     */
    public int horizontalSpacing = 5;

    /**
     * verticalSpacing specifies the number of pixels between the bottom
     * edge of one cell and the top edge of its neighbouring cell underneath.
     *
     * The default value is 5.
     */
    public int verticalSpacing = 5;

/**
 * Constructs a new instance of this class.
 */
public this () {}

/**
 * Constructs a new instance of this class given the
 * number of columns, and whether or not the columns
 * should be forced to have the same width.
 * If numColumns has a value less than 1, the layout will not
 * set the size and position of any controls.
 *
 * @param numColumns the number of columns in the grid
 * @param makeColumnsEqualWidth whether or not the columns will have equal width
 *
 * @since 2.0
 */
public this (int numColumns, bool makeColumnsEqualWidth) {
    this.numColumns = numColumns;
    this.makeColumnsEqualWidth = makeColumnsEqualWidth;
}

override protected Point computeSize (Composite composite, int wHint, int hHint, bool flushCache_) {
    Point size = layout (composite, false, 0, 0, wHint, hHint, flushCache_);
    if (wHint !is SWT.DEFAULT) size.x = wHint;
    if (hHint !is SWT.DEFAULT) size.y = hHint;
    return size;
}

override protected bool flushCache (Control control) {
    Object data = control.getLayoutData ();
    if (data !is null) (cast(GridData) data).flushCache ();
    return true;
}

GridData getData (Control [][] grid, int row, int column, int rowCount, int columnCount, bool first) {
    Control control = grid [row] [column];
    if (control !is null) {
        GridData data = cast(GridData) control.getLayoutData ();
        int hSpan = Math.max (1, Math.min (data.horizontalSpan, columnCount));
        int vSpan = Math.max (1, data.verticalSpan);
        int i = first ? row + vSpan - 1 : row - vSpan + 1;
        int j = first ? column + hSpan - 1 : column - hSpan + 1;
        if (0 <= i && i < rowCount) {
            if (0 <= j && j < columnCount) {
                if (control is grid [i][j]) return data;
            }
        }
    }
    return null;
}

override protected void layout (Composite composite, bool flushCache_) {
    Rectangle rect = composite.getClientArea ();
    layout (composite, true, rect.x, rect.y, rect.width, rect.height, flushCache_);
}

Point layout (Composite composite, bool move, int x, int y, int width, int height, bool flushCache_) {
    if (numColumns < 1) {
        return new Point (marginLeft + marginWidth * 2 + marginRight, marginTop + marginHeight * 2 + marginBottom);
    }
    Control [] children = composite.getChildren ();
    int count = 0;
    for (int i=0; i<children.length; i++) {
        Control control = children [i];
        GridData data = cast(GridData) control.getLayoutData ();
        if (data is null || !data.exclude) {
            children [count++] = children [i];
        }
    }
    if (count is 0) {
        return new Point (marginLeft + marginWidth * 2 + marginRight, marginTop + marginHeight * 2 + marginBottom);
    }
    for (int i=0; i<count; i++) {
        Control child = children [i];
        GridData data = cast(GridData) child.getLayoutData ();
        if (data is null) child.setLayoutData (data = new GridData ());
        if (flushCache_) data.flushCache ();
        data.computeSize (child, data.widthHint, data.heightHint, flushCache_);
        if (data.grabExcessHorizontalSpace && data.minimumWidth > 0) {
            if (data.cacheWidth < data.minimumWidth) {
                int trim = 0;
                //TEMPORARY CODE
                if ( auto sa = cast(Scrollable)child ) {
                    Rectangle rect = sa.computeTrim (0, 0, 0, 0);
                    trim = rect.width;
                } else {
                    trim = child.getBorderWidth () * 2;
                }
                data.cacheWidth = data.cacheHeight = SWT.DEFAULT;
                data.computeSize (child, Math.max (0, data.minimumWidth - trim), data.heightHint, false);
            }
        }
        if (data.grabExcessVerticalSpace && data.minimumHeight > 0) {
            data.cacheHeight = Math.max (data.cacheHeight, data.minimumHeight);
        }
    }

    /* Build the grid */
    int row = 0, column = 0, rowCount = 0, columnCount = numColumns;
    Control [][] grid = new Control [][]( 4, columnCount );
    for (int i=0; i<count; i++) {
        Control child = children [i];
        GridData data = cast(GridData) child.getLayoutData ();
        int hSpan = Math.max (1, Math.min (data.horizontalSpan, columnCount));
        int vSpan = Math.max (1, data.verticalSpan);
        while (true) {
            int lastRow = row + vSpan;
            if (lastRow >= grid.length) {
                Control [][] newGrid = new Control[][]( lastRow + 4, columnCount );
                SimpleType!(Control[]).arraycopy (grid, 0, newGrid, 0, cast(int)/*64bit*/grid.length);
                grid = newGrid;
            }
            if (grid [row] is null) {
                grid [row] = new Control [columnCount];
            }
            while (column < columnCount && grid [row] [column] !is null) {
                column++;
            }
            int endCount = column + hSpan;
            if (endCount <= columnCount) {
                int index = column;
                while (index < endCount && grid [row] [index] is null) {
                    index++;
                }
                if (index is endCount) break;
                column = index;
            }
            if (column + hSpan >= columnCount) {
                column = 0;
                row++;
            }
        }
        for (int j=0; j<vSpan; j++) {
            if (grid [row + j] is null) {
                grid [row + j] = new Control [columnCount];
            }
            for (int k=0; k<hSpan; k++) {
                grid [row + j] [column + k] = child;
            }
        }
        rowCount = Math.max (rowCount, row + vSpan);
        column += hSpan;
    }

    /* Column widths */
    int availableWidth = width - horizontalSpacing * (columnCount - 1) - (marginLeft + marginWidth * 2 + marginRight);
    int expandCount = 0;
    int [] widths = new int [columnCount];
    int [] minWidths = new int [columnCount];
    bool [] expandColumn = new bool [columnCount];
    for (int j=0; j<columnCount; j++) {
        for (int i=0; i<rowCount; i++) {
            GridData data = getData (grid, i, j, rowCount, columnCount, true);
            if (data !is null) {
                int hSpan = Math.max (1, Math.min (data.horizontalSpan, columnCount));
                if (hSpan is 1) {
                    int w = data.cacheWidth + data.horizontalIndent;
                    widths [j] = Math.max (widths [j], w);
                    if (data.grabExcessHorizontalSpace) {
                        if (!expandColumn [j]) expandCount++;
                        expandColumn [j] = true;
                    }
                    if (!data.grabExcessHorizontalSpace || data.minimumWidth !is 0) {
                        w = !data.grabExcessHorizontalSpace || data.minimumWidth is SWT.DEFAULT ? data.cacheWidth : data.minimumWidth;
                        w += data.horizontalIndent;
                        minWidths [j] = Math.max (minWidths [j], w);
                    }
                }
            }
        }
        for (int i=0; i<rowCount; i++) {
            GridData data = getData (grid, i, j, rowCount, columnCount, false);
            if (data !is null) {
                int hSpan = Math.max (1, Math.min (data.horizontalSpan, columnCount));
                if (hSpan > 1) {
                    int spanWidth = 0, spanMinWidth = 0, spanExpandCount = 0;
                    for (int k=0; k<hSpan; k++) {
                        spanWidth += widths [j-k];
                        spanMinWidth += minWidths [j-k];
                        if (expandColumn [j-k]) spanExpandCount++;
                    }
                    if (data.grabExcessHorizontalSpace && spanExpandCount is 0) {
                        expandCount++;
                        expandColumn [j] = true;
                    }
                    int w = data.cacheWidth + data.horizontalIndent - spanWidth - (hSpan - 1) * horizontalSpacing;
                    if (w > 0) {
                        if (makeColumnsEqualWidth) {
                            int equalWidth = (w + spanWidth) / hSpan;
                            int remainder = (w + spanWidth) % hSpan, last = -1;
                            for (int k = 0; k < hSpan; k++) {
                                widths [last=j-k] = Math.max (equalWidth, widths [j-k]);
                            }
                            if (last > -1) widths [last] += remainder;
                        } else {
                            if (spanExpandCount is 0) {
                                widths [j] += w;
                            } else {
                                int delta = w / spanExpandCount;
                                int remainder = w % spanExpandCount, last = -1;
                                for (int k = 0; k < hSpan; k++) {
                                    if (expandColumn [j-k]) {
                                        widths [last=j-k] += delta;
                                    }
                                }
                                if (last > -1) widths [last] += remainder;
                            }
                        }
                    }
                    if (!data.grabExcessHorizontalSpace || data.minimumWidth !is 0) {
                        w = !data.grabExcessHorizontalSpace || data.minimumWidth is SWT.DEFAULT ? data.cacheWidth : data.minimumWidth;
                        w += data.horizontalIndent - spanMinWidth - (hSpan - 1) * horizontalSpacing;
                        if (w > 0) {
                            if (spanExpandCount is 0) {
                                minWidths [j] += w;
                            } else {
                                int delta = w / spanExpandCount;
                                int remainder = w % spanExpandCount, last = -1;
                                for (int k = 0; k < hSpan; k++) {
                                    if (expandColumn [j-k]) {
                                        minWidths [last=j-k] += delta;
                                    }
                                }
                                if (last > -1) minWidths [last] += remainder;
                            }
                        }
                    }
                }
            }
        }
    }
    if (makeColumnsEqualWidth) {
        int minColumnWidth = 0;
        int columnWidth = 0;
        for (int i=0; i<columnCount; i++) {
            minColumnWidth = Math.max (minColumnWidth, minWidths [i]);
            columnWidth = Math.max (columnWidth, widths [i]);
        }
        columnWidth = width is SWT.DEFAULT || expandCount is 0 ? columnWidth : Math.max (minColumnWidth, availableWidth / columnCount);
        for (int i=0; i<columnCount; i++) {
            expandColumn [i] = expandCount > 0;
            widths [i] = columnWidth;
        }
    } else {
        if (width !is SWT.DEFAULT && expandCount > 0) {
            int totalWidth = 0;
            for (int i=0; i<columnCount; i++) {
                totalWidth += widths [i];
            }
            int c = expandCount;
            int delta = (availableWidth - totalWidth) / c;
            int remainder = (availableWidth - totalWidth) % c;
            int last = -1;
            while (totalWidth !is availableWidth) {
                for (int j=0; j<columnCount; j++) {
                    if (expandColumn [j]) {
                        if (widths [j] + delta > minWidths [j]) {
                            widths [last = j] = widths [j] + delta;
                        } else {
                            widths [j] = minWidths [j];
                            expandColumn [j] = false;
                            c--;
                        }
                    }
                }
                if (last > -1) widths [last] += remainder;

                for (int j=0; j<columnCount; j++) {
                    for (int i=0; i<rowCount; i++) {
                        GridData data = getData (grid, i, j, rowCount, columnCount, false);
                        if (data !is null) {
                            int hSpan = Math.max (1, Math.min (data.horizontalSpan, columnCount));
                            if (hSpan > 1) {
                                if (!data.grabExcessHorizontalSpace || data.minimumWidth !is 0) {
                                    int spanWidth = 0, spanExpandCount = 0;
                                    for (int k=0; k<hSpan; k++) {
                                        spanWidth += widths [j-k];
                                        if (expandColumn [j-k]) spanExpandCount++;
                                    }
                                    int w = !data.grabExcessHorizontalSpace || data.minimumWidth is SWT.DEFAULT ? data.cacheWidth : data.minimumWidth;
                                    w += data.horizontalIndent - spanWidth - (hSpan - 1) * horizontalSpacing;
                                    if (w > 0) {
                                        if (spanExpandCount is 0) {
                                            widths [j] += w;
                                        } else {
                                            int delta2 = w / spanExpandCount;
                                            int remainder2 = w % spanExpandCount, last2 = -1;
                                            for (int k = 0; k < hSpan; k++) {
                                                if (expandColumn [j-k]) {
                                                    widths [last2=j-k] += delta2;
                                                }
                                            }
                                            if (last2 > -1) widths [last2] += remainder2;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if (c is 0) break;
                totalWidth = 0;
                for (int i=0; i<columnCount; i++) {
                    totalWidth += widths [i];
                }
                delta = (availableWidth - totalWidth) / c;
                remainder = (availableWidth - totalWidth) % c;
                last = -1;
            }
        }
    }

    /* Wrapping */
    GridData [] flush = null;
    int flushLength = 0;
    if (width !is SWT.DEFAULT) {
        for (int j=0; j<columnCount; j++) {
            for (int i=0; i<rowCount; i++) {
                GridData data = getData (grid, i, j, rowCount, columnCount, false);
                if (data !is null) {
                    if (data.heightHint is SWT.DEFAULT) {
                        Control child = grid [i][j];
                        //TEMPORARY CODE
                        int hSpan = Math.max (1, Math.min (data.horizontalSpan, columnCount));
                        int currentWidth = 0;
                        for (int k=0; k<hSpan; k++) {
                            currentWidth += widths [j-k];
                        }
                        currentWidth += (hSpan - 1) * horizontalSpacing - data.horizontalIndent;
                        if ((currentWidth !is data.cacheWidth && data.horizontalAlignment is SWT.FILL) || (data.cacheWidth > currentWidth)) {
                            int trim = 0;
                            if ( auto sa = cast(Scrollable)child ) {
                                Rectangle rect = sa.computeTrim (0, 0, 0, 0);
                                trim = rect.width;
                            } else {
                                trim = child.getBorderWidth () * 2;
                            }
                            data.cacheWidth = data.cacheHeight = SWT.DEFAULT;
                            data.computeSize (child, Math.max (0, currentWidth - trim), data.heightHint, false);
                            if (data.grabExcessVerticalSpace && data.minimumHeight > 0) {
                                data.cacheHeight = Math.max (data.cacheHeight, data.minimumHeight);
                            }
                            if (flush is null) flush = new GridData [count];
                            flush [flushLength++] = data;
                        }
                    }
                }
            }
        }
    }

    /* Row heights */
    int availableHeight = height - verticalSpacing * (rowCount - 1) - (marginTop + marginHeight * 2 + marginBottom);
    expandCount = 0;
    int [] heights = new int [rowCount];
    int [] minHeights = new int [rowCount];
    bool [] expandRow = new bool [rowCount];
    for (int i=0; i<rowCount; i++) {
        for (int j=0; j<columnCount; j++) {
            GridData data = getData (grid, i, j, rowCount, columnCount, true);
            if (data !is null) {
                int vSpan = Math.max (1, Math.min (data.verticalSpan, rowCount));
                if (vSpan is 1) {
                    int h = data.cacheHeight + data.verticalIndent;
                    heights [i] = Math.max (heights [i], h);
                    if (data.grabExcessVerticalSpace) {
                        if (!expandRow [i]) expandCount++;
                        expandRow [i] = true;
                    }
                    if (!data.grabExcessVerticalSpace || data.minimumHeight !is 0) {
                        h = !data.grabExcessVerticalSpace || data.minimumHeight is SWT.DEFAULT ? data.cacheHeight : data.minimumHeight;
                        h += data.verticalIndent;
                        minHeights [i] = Math.max (minHeights [i], h);
                    }
                }
            }
        }
        for (int j=0; j<columnCount; j++) {
            GridData data = getData (grid, i, j, rowCount, columnCount, false);
            if (data !is null) {
                int vSpan = Math.max (1, Math.min (data.verticalSpan, rowCount));
                if (vSpan > 1) {
                    int spanHeight = 0, spanMinHeight = 0, spanExpandCount = 0;
                    for (int k=0; k<vSpan; k++) {
                        spanHeight += heights [i-k];
                        spanMinHeight += minHeights [i-k];
                        if (expandRow [i-k]) spanExpandCount++;
                    }
                    if (data.grabExcessVerticalSpace && spanExpandCount is 0) {
                        expandCount++;
                        expandRow [i] = true;
                    }
                    int h = data.cacheHeight + data.verticalIndent - spanHeight - (vSpan - 1) * verticalSpacing;
                    if (h > 0) {
                        if (spanExpandCount is 0) {
                            heights [i] += h;
                        } else {
                            int delta = h / spanExpandCount;
                            int remainder = h % spanExpandCount, last = -1;
                            for (int k = 0; k < vSpan; k++) {
                                if (expandRow [i-k]) {
                                    heights [last=i-k] += delta;
                                }
                            }
                            if (last > -1) heights [last] += remainder;
                        }
                    }
                    if (!data.grabExcessVerticalSpace || data.minimumHeight !is 0) {
                        h = !data.grabExcessVerticalSpace || data.minimumHeight is SWT.DEFAULT ? data.cacheHeight : data.minimumHeight;
                        h += data.verticalIndent - spanMinHeight - (vSpan - 1) * verticalSpacing;
                        if (h > 0) {
                            if (spanExpandCount is 0) {
                                minHeights [i] += h;
                            } else {
                                int delta = h / spanExpandCount;
                                int remainder = h % spanExpandCount, last = -1;
                                for (int k = 0; k < vSpan; k++) {
                                    if (expandRow [i-k]) {
                                        minHeights [last=i-k] += delta;
                                    }
                                }
                                if (last > -1) minHeights [last] += remainder;
                            }
                        }
                    }
                }
            }
        }
    }
    if (height !is SWT.DEFAULT && expandCount > 0) {
        int totalHeight = 0;
        for (int i=0; i<rowCount; i++) {
            totalHeight += heights [i];
        }
        int c = expandCount;
        int delta = (availableHeight - totalHeight) / c;
        int remainder = (availableHeight - totalHeight) % c;
        int last = -1;
        while (totalHeight !is availableHeight) {
            for (int i=0; i<rowCount; i++) {
                if (expandRow [i]) {
                    if (heights [i] + delta > minHeights [i]) {
                        heights [last = i] = heights [i] + delta;
                    } else {
                        heights [i] = minHeights [i];
                        expandRow [i] = false;
                        c--;
                    }
                }
            }
            if (last > -1) heights [last] += remainder;

            for (int i=0; i<rowCount; i++) {
                for (int j=0; j<columnCount; j++) {
                    GridData data = getData (grid, i, j, rowCount, columnCount, false);
                    if (data !is null) {
                        int vSpan = Math.max (1, Math.min (data.verticalSpan, rowCount));
                        if (vSpan > 1) {
                            if (!data.grabExcessVerticalSpace || data.minimumHeight !is 0) {
                                int spanHeight = 0, spanExpandCount = 0;
                                for (int k=0; k<vSpan; k++) {
                                    spanHeight += heights [i-k];
                                    if (expandRow [i-k]) spanExpandCount++;
                                }
                                int h = !data.grabExcessVerticalSpace || data.minimumHeight is SWT.DEFAULT ? data.cacheHeight : data.minimumHeight;
                                h += data.verticalIndent - spanHeight - (vSpan - 1) * verticalSpacing;
                                if (h > 0) {
                                    if (spanExpandCount is 0) {
                                        heights [i] += h;
                                    } else {
                                        int delta2 = h / spanExpandCount;
                                        int remainder2 = h % spanExpandCount, last2 = -1;
                                        for (int k = 0; k < vSpan; k++) {
                                            if (expandRow [i-k]) {
                                                heights [last2=i-k] += delta2;
                                            }
                                        }
                                        if (last2 > -1) heights [last2] += remainder2;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if (c is 0) break;
            totalHeight = 0;
            for (int i=0; i<rowCount; i++) {
                totalHeight += heights [i];
            }
            delta = (availableHeight - totalHeight) / c;
            remainder = (availableHeight - totalHeight) % c;
            last = -1;
        }
    }

    /* Position the controls */
    if (move) {
        int gridY = y + marginTop + marginHeight;
        for (int i=0; i<rowCount; i++) {
            int gridX = x + marginLeft + marginWidth;
            for (int j=0; j<columnCount; j++) {
                GridData data = getData (grid, i, j, rowCount, columnCount, true);
                if (data !is null) {
                    int hSpan = Math.max (1, Math.min (data.horizontalSpan, columnCount));
                    int vSpan = Math.max (1, data.verticalSpan);
                    int cellWidth = 0, cellHeight = 0;
                    for (int k=0; k<hSpan; k++) {
                        cellWidth += widths [j+k];
                    }
                    for (int k=0; k<vSpan; k++) {
                        cellHeight += heights [i+k];
                    }
                    cellWidth += horizontalSpacing * (hSpan - 1);
                    int childX = gridX + data.horizontalIndent;
                    int childWidth = Math.min (data.cacheWidth, cellWidth);
                    switch (data.horizontalAlignment) {
                        case SWT.CENTER:
                        case GridData.CENTER:
                            childX += Math.max (0, (cellWidth - data.horizontalIndent - childWidth) / 2);
                            break;
                        case SWT.RIGHT:
                        case SWT.END:
                        case GridData.END:
                            childX += Math.max (0, cellWidth - data.horizontalIndent - childWidth);
                            break;
                        case SWT.FILL:
                            childWidth = cellWidth - data.horizontalIndent;
                            break;
                        default:
                    }
                    cellHeight += verticalSpacing * (vSpan - 1);
                    int childY = gridY + data.verticalIndent;
                    int childHeight = Math.min (data.cacheHeight, cellHeight);
                    switch (data.verticalAlignment) {
                        case SWT.CENTER:
                        case GridData.CENTER:
                            childY += Math.max (0, (cellHeight - data.verticalIndent - childHeight) / 2);
                            break;
                        case SWT.BOTTOM:
                        case SWT.END:
                        case GridData.END:
                            childY += Math.max (0, cellHeight - data.verticalIndent - childHeight);
                            break;
                        case SWT.FILL:
                            childHeight = cellHeight - data.verticalIndent;
                            break;
                        default:
                    }
                    Control child = grid [i][j];
                    if (child !is null) {
                        child.setBounds (childX, childY, childWidth, childHeight);
                    }
                }
                gridX += widths [j] + horizontalSpacing;
            }
            gridY += heights [i] + verticalSpacing;
        }
    }

    // clean up cache
    for (int i = 0; i < flushLength; i++) {
        flush [i].cacheWidth = flush [i].cacheHeight = -1;
    }

    int totalDefaultWidth = 0;
    int totalDefaultHeight = 0;
    for (int i=0; i<columnCount; i++) {
        totalDefaultWidth += widths [i];
    }
    for (int i=0; i<rowCount; i++) {
        totalDefaultHeight += heights [i];
    }
    totalDefaultWidth += horizontalSpacing * (columnCount - 1) + marginLeft + marginWidth * 2 + marginRight;
    totalDefaultHeight += verticalSpacing * (rowCount - 1) + marginTop + marginHeight * 2 + marginBottom;
    return new Point (totalDefaultWidth, totalDefaultHeight);
}

String getName () {
    String string = this.classinfo.name;
    int index = string.lastIndexOf('.');
    if (index is -1 ) return string;
    return string[ index + 1 .. string.length ];
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the layout
 */
override public String toString () {
    String string = getName ()~" {";
    if (numColumns !is 1) string ~= "numColumns="~String_valueOf(numColumns)~" ";
    if (makeColumnsEqualWidth) string ~= "makeColumnsEqualWidth="~String_valueOf(makeColumnsEqualWidth)~" ";
    if (marginWidth !is 0) string ~= "marginWidth="~String_valueOf(marginWidth)~" ";
    if (marginHeight !is 0) string ~= "marginHeight="~String_valueOf(marginHeight)~" ";
    if (marginLeft !is 0) string ~= "marginLeft="~String_valueOf(marginLeft)~" ";
    if (marginRight !is 0) string ~= "marginRight="~String_valueOf(marginRight)~" ";
    if (marginTop !is 0) string ~= "marginTop="~String_valueOf(marginTop)~" ";
    if (marginBottom !is 0) string ~= "marginBottom="~String_valueOf(marginBottom)~" ";
    if (horizontalSpacing !is 0) string ~= "horizontalSpacing="~String_valueOf(horizontalSpacing)~" ";
    if (verticalSpacing !is 0) string ~= "verticalSpacing="~String_valueOf(verticalSpacing)~" ";
    string = string.trim();
    string ~= "}";
    return string;
}
}
