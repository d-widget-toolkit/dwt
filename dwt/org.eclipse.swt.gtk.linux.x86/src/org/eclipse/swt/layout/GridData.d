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
module org.eclipse.swt.layout.GridData;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Control;

import java.lang.all;

/**
 * <code>GridData</code> is the layout data object associated with
 * <code>GridLayout</code>. To set a <code>GridData</code> object into a
 * control, you use the <code>Control.setLayoutData(Object)</code> method.
 * <p>
 * There are two ways to create a <code>GridData</code> object with certain
 * fields set. The first is to set the fields directly, like this:
 * <pre>
 *      GridData gridData = new GridData();
 *      gridData.horizontalAlignment = GridData.FILL;
 *      gridData.grabExcessHorizontalSpace = true;
 *      button1.setLayoutData(gridData);
 * </pre>
 * The second is to take advantage of convenience style bits defined
 * by <code>GridData</code>:
 * <pre>
 *      button1.setLayoutData(new GridData(GridData.HORIZONTAL_ALIGN_FILL | GridData.GRAB_HORIZONTAL));
 * </pre>
 * </p>
 * <p>
 * NOTE: Do not reuse <code>GridData</code> objects. Every control in a
 * <code>Composite</code> that is managed by a <code>GridLayout</code>
 * must have a unique <code>GridData</code> object. If the layout data
 * for a control in a <code>GridLayout</code> is null at layout time,
 * a unique <code>GridData</code> object is created for it.
 * </p>
 *
 * @see GridLayout
 * @see Control#setLayoutData
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class GridData {
    /**
     * verticalAlignment specifies how controls will be positioned
     * vertically within a cell.
     *
     * The default value is CENTER.
     *
     * Possible values are: <ul>
     *    <li>SWT.BEGINNING (or SWT.TOP): Position the control at the top of the cell</li>
     *    <li>SWT.CENTER: Position the control in the vertical center of the cell</li>
     *    <li>SWT.END (or SWT.BOTTOM): Position the control at the bottom of the cell</li>
     *    <li>SWT.FILL: Resize the control to fill the cell vertically</li>
     * </ul>
     */
    public int verticalAlignment = CENTER;

    /**
     * horizontalAlignment specifies how controls will be positioned
     * horizontally within a cell.
     *
     * The default value is BEGINNING.
     *
     * Possible values are: <ul>
     *    <li>SWT.BEGINNING (or SWT.LEFT): Position the control at the left of the cell</li>
     *    <li>SWT.CENTER: Position the control in the horizontal center of the cell</li>
     *    <li>SWT.END (or SWT.RIGHT): Position the control at the right of the cell</li>
     *    <li>SWT.FILL: Resize the control to fill the cell horizontally</li>
     * </ul>
     */
    public int horizontalAlignment = BEGINNING;

    /**
     * widthHint specifies the preferred width in pixels. This value
     * is the wHint passed into Control.computeSize(int, int, bool)
     * to determine the preferred size of the control.
     *
     * The default value is SWT.DEFAULT.
     *
     * @see Control#computeSize(int, int, bool)
     */
    public int widthHint = SWT.DEFAULT;

    /**
     * heightHint specifies the preferred height in pixels. This value
     * is the hHint passed into Control.computeSize(int, int, bool)
     * to determine the preferred size of the control.
     *
     * The default value is SWT.DEFAULT.
     *
     * @see Control#computeSize(int, int, bool)
     */
    public int heightHint = SWT.DEFAULT;

    /**
     * horizontalIndent specifies the number of pixels of indentation
     * that will be placed along the left side of the cell.
     *
     * The default value is 0.
     */
    public int horizontalIndent = 0;

    /**
     * verticalIndent specifies the number of pixels of indentation
     * that will be placed along the top side of the cell.
     *
     * The default value is 0.
     *
     * @since 3.1
     */
    public int verticalIndent = 0;

    /**
     * horizontalSpan specifies the number of column cells that the control
     * will take up.
     *
     * The default value is 1.
     */
    public int horizontalSpan = 1;

    /**
     * verticalSpan specifies the number of row cells that the control
     * will take up.
     *
     * The default value is 1.
     */
    public int verticalSpan = 1;

    /**
     * <p>grabExcessHorizontalSpace specifies whether the width of the cell
     * changes depending on the size of the parent Composite.  If
     * grabExcessHorizontalSpace is <code>true</code>, the following rules
     * apply to the width of the cell:</p>
     * <ul>
     * <li>If extra horizontal space is available in the parent, the cell will
     * grow to be wider than its preferred width.  The new width
     * will be "preferred width + delta" where delta is the extra
     * horizontal space divided by the number of grabbing columns.</li>
     * <li>If there is not enough horizontal space available in the parent, the
     * cell will shrink until it reaches its minimum width as specified by
     * GridData.minimumWidth. The new width will be the maximum of
     * "minimumWidth" and "preferred width - delta", where delta is
     * the amount of space missing divided by the number of grabbing columns.</li>
     * <li>If the parent is packed, the cell will be its preferred width
     * as specified by GridData.widthHint.</li>
     * <li>If the control spans multiple columns and there are no other grabbing
     * controls in any of the spanned columns, the last column in the span will
     * grab the extra space.  If there is at least one other grabbing control
     * in the span, the grabbing will be spread over the columns already
     * marked as grabExcessHorizontalSpace.</li>
     * </ul>
     *
     * <p>The default value is false.</p>
     *
     * @see GridData#minimumWidth
     * @see GridData#widthHint
     */
    public bool grabExcessHorizontalSpace = false;

    /**
     * <p>grabExcessVerticalSpace specifies whether the height of the cell
     * changes depending on the size of the parent Composite.  If
     * grabExcessVerticalSpace is <code>true</code>, the following rules
     * apply to the height of the cell:</p>
     * <ul>
     * <li>If extra vertical space is available in the parent, the cell will
     * grow to be taller than its preferred height.  The new height
     * will be "preferred height + delta" where delta is the extra
     * vertical space divided by the number of grabbing rows.</li>
     * <li>If there is not enough vertical space available in the parent, the
     * cell will shrink until it reaches its minimum height as specified by
     * GridData.minimumHeight. The new height will be the maximum of
     * "minimumHeight" and "preferred height - delta", where delta is
     * the amount of space missing divided by the number of grabbing rows.</li>
     * <li>If the parent is packed, the cell will be its preferred height
     * as specified by GridData.heightHint.</li>
     * <li>If the control spans multiple rows and there are no other grabbing
     * controls in any of the spanned rows, the last row in the span will
     * grab the extra space.  If there is at least one other grabbing control
     * in the span, the grabbing will be spread over the rows already
     * marked as grabExcessVerticalSpace.</li>
     * </ul>
     *
     * <p>The default value is false.</p>
     *
     * @see GridData#minimumHeight
     * @see GridData#heightHint
     */
    public bool grabExcessVerticalSpace = false;

    /**
     * minimumWidth specifies the minimum width in pixels.  This value
     * applies only if grabExcessHorizontalSpace is true. A value of
     * SWT.DEFAULT means that the minimum width will be the result
     * of Control.computeSize(int, int, bool) where wHint is
     * determined by GridData.widthHint.
     *
     * The default value is 0.
     *
     * @since 3.1
     * @see Control#computeSize(int, int, bool)
     * @see GridData#widthHint
     */
    public int minimumWidth = 0;

    /**
     * minimumHeight specifies the minimum height in pixels.  This value
     * applies only if grabExcessVerticalSpace is true.  A value of
     * SWT.DEFAULT means that the minimum height will be the result
     * of Control.computeSize(int, int, bool) where hHint is
     * determined by GridData.heightHint.
     *
     * The default value is 0.
     *
     * @since 3.1
     * @see Control#computeSize(int, int, bool)
     * @see GridData#heightHint
     */
    public int minimumHeight = 0;

    /**
     * exclude informs the layout to ignore this control when sizing
     * and positioning controls.  If this value is <code>true</code>,
     * the size and position of the control will not be managed by the
     * layout.  If this value is <code>false</code>, the size and
     * position of the control will be computed and assigned.
     *
     * The default value is <code>false</code>.
     *
     * @since 3.1
     */
    public bool exclude = false;

    /**
     * Value for horizontalAlignment or verticalAlignment.
     * Position the control at the top or left of the cell.
     * Not recommended. Use SWT.BEGINNING, SWT.TOP or SWT.LEFT instead.
     */
    public static const int BEGINNING = SWT.BEGINNING;

    /**
     * Value for horizontalAlignment or verticalAlignment.
     * Position the control in the vertical or horizontal center of the cell
     * Not recommended. Use SWT.CENTER instead.
     */
    public static const int CENTER = 2;

    /**
     * Value for horizontalAlignment or verticalAlignment.
     * Position the control at the bottom or right of the cell
     * Not recommended. Use SWT.END, SWT.BOTTOM or SWT.RIGHT instead.
     */
    public static const int END = 3;

    /**
     * Value for horizontalAlignment or verticalAlignment.
     * Resize the control to fill the cell horizontally or vertically.
     * Not recommended. Use SWT.FILL instead.
     */
    public static const int FILL = SWT.FILL;

    /**
     * Style bit for <code>new GridData(int)</code>.
     * Position the control at the top of the cell.
     * Not recommended. Use
     * <code>new GridData(int, SWT.BEGINNING, bool, bool)</code>
     * instead.
     */
    public static const int VERTICAL_ALIGN_BEGINNING =  1 << 1;

    /**
     * Style bit for <code>new GridData(int)</code> to position the
     * control in the vertical center of the cell.
     * Not recommended. Use
     * <code>new GridData(int, SWT.CENTER, bool, bool)</code>
     * instead.
     */
    public static const int VERTICAL_ALIGN_CENTER = 1 << 2;

    /**
     * Style bit for <code>new GridData(int)</code> to position the
     * control at the bottom of the cell.
     * Not recommended. Use
     * <code>new GridData(int, SWT.END, bool, bool)</code>
     * instead.
     */
    public static const int VERTICAL_ALIGN_END = 1 << 3;

    /**
     * Style bit for <code>new GridData(int)</code> to resize the
     * control to fill the cell vertically.
     * Not recommended. Use
     * <code>new GridData(int, SWT.FILL, bool, bool)</code>
     * instead
     */
    public static const int VERTICAL_ALIGN_FILL = 1 << 4;

    /**
     * Style bit for <code>new GridData(int)</code> to position the
     * control at the left of the cell.
     * Not recommended. Use
     * <code>new GridData(SWT.BEGINNING, int, bool, bool)</code>
     * instead.
     */
    public static const int HORIZONTAL_ALIGN_BEGINNING =  1 << 5;

    /**
     * Style bit for <code>new GridData(int)</code> to position the
     * control in the horizontal center of the cell.
     * Not recommended. Use
     * <code>new GridData(SWT.CENTER, int, bool, bool)</code>
     * instead.
     */
    public static const int HORIZONTAL_ALIGN_CENTER = 1 << 6;

    /**
     * Style bit for <code>new GridData(int)</code> to position the
     * control at the right of the cell.
     * Not recommended. Use
     * <code>new GridData(SWT.END, int, bool, bool)</code>
     * instead.
     */
    public static const int HORIZONTAL_ALIGN_END = 1 << 7;

    /**
     * Style bit for <code>new GridData(int)</code> to resize the
     * control to fill the cell horizontally.
     * Not recommended. Use
     * <code>new GridData(SWT.FILL, int, bool, bool)</code>
     * instead.
     */
    public static const int HORIZONTAL_ALIGN_FILL = 1 << 8;

    /**
     * Style bit for <code>new GridData(int)</code> to resize the
     * control to fit the remaining horizontal space.
     * Not recommended. Use
     * <code>new GridData(int, int, true, bool)</code>
     * instead.
     */
    public static const int GRAB_HORIZONTAL = 1 << 9;

    /**
     * Style bit for <code>new GridData(int)</code> to resize the
     * control to fit the remaining vertical space.
     * Not recommended. Use
     * <code>new GridData(int, int, bool, true)</code>
     * instead.
     */
    public static const int GRAB_VERTICAL = 1 << 10;

    /**
     * Style bit for <code>new GridData(int)</code> to resize the
     * control to fill the cell vertically and to fit the remaining
     * vertical space.
     * FILL_VERTICAL = VERTICAL_ALIGN_FILL | GRAB_VERTICAL
     * Not recommended. Use
     * <code>new GridData(int, SWT.FILL, bool, true)</code>
     * instead.
     */
    public static const int FILL_VERTICAL = VERTICAL_ALIGN_FILL | GRAB_VERTICAL;

    /**
     * Style bit for <code>new GridData(int)</code> to resize the
     * control to fill the cell horizontally and to fit the remaining
     * horizontal space.
     * FILL_HORIZONTAL = HORIZONTAL_ALIGN_FILL | GRAB_HORIZONTAL
     * Not recommended. Use
     * <code>new GridData(SWT.FILL, int, true, bool)</code>
     * instead.
     */
    public static const int FILL_HORIZONTAL = HORIZONTAL_ALIGN_FILL | GRAB_HORIZONTAL;

    /**
     * Style bit for <code>new GridData(int)</code> to resize the
     * control to fill the cell horizontally and vertically and
     * to fit the remaining horizontal and vertical space.
     * FILL_BOTH = FILL_VERTICAL | FILL_HORIZONTAL
     * Not recommended. Use
     * <code>new GridData(SWT.FILL, SWT.FILL, true, true)</code>
     * instead.
     */
    public static const int FILL_BOTH = FILL_VERTICAL | FILL_HORIZONTAL;

    int cacheWidth = -1, cacheHeight = -1;
    int defaultWhint, defaultHhint, defaultWidth = -1, defaultHeight = -1;
    int currentWhint, currentHhint, currentWidth = -1, currentHeight = -1;

/**
 * Constructs a new instance of GridData using
 * default values.
 */
public this () {
}

/**
 * Constructs a new instance based on the GridData style.
 * This constructor is not recommended.
 *
 * @param style the GridData style
 */
public this (int style) {
    if ((style & VERTICAL_ALIGN_BEGINNING) !is 0) verticalAlignment = BEGINNING;
    if ((style & VERTICAL_ALIGN_CENTER) !is 0) verticalAlignment = CENTER;
    if ((style & VERTICAL_ALIGN_FILL) !is 0) verticalAlignment = FILL;
    if ((style & VERTICAL_ALIGN_END) !is 0) verticalAlignment = END;
    if ((style & HORIZONTAL_ALIGN_BEGINNING) !is 0) horizontalAlignment = BEGINNING;
    if ((style & HORIZONTAL_ALIGN_CENTER) !is 0) horizontalAlignment = CENTER;
    if ((style & HORIZONTAL_ALIGN_FILL) !is 0) horizontalAlignment = FILL;
    if ((style & HORIZONTAL_ALIGN_END) !is 0) horizontalAlignment = END;
    grabExcessHorizontalSpace = (style & GRAB_HORIZONTAL) !is 0;
    grabExcessVerticalSpace = (style & GRAB_VERTICAL) !is 0;
}

/**
 * Constructs a new instance of GridData according to the parameters.
 *
 * @param horizontalAlignment how control will be positioned horizontally within a cell,
 *      one of: SWT.BEGINNING (or SWT.LEFT), SWT.CENTER, SWT.END (or SWT.RIGHT), or SWT.FILL
 * @param verticalAlignment how control will be positioned vertically within a cell,
 *      one of: SWT.BEGINNING (or SWT.TOP), SWT.CENTER, SWT.END (or SWT.BOTTOM), or SWT.FILL
 * @param grabExcessHorizontalSpace whether cell will be made wide enough to fit the remaining horizontal space
 * @param grabExcessVerticalSpace whether cell will be made high enough to fit the remaining vertical space
 *
 * @since 3.0
 */
public this (int horizontalAlignment, int verticalAlignment, bool grabExcessHorizontalSpace, bool grabExcessVerticalSpace) {
    this (horizontalAlignment, verticalAlignment, grabExcessHorizontalSpace, grabExcessVerticalSpace, 1, 1);
}

/**
 * Constructs a new instance of GridData according to the parameters.
 *
 * @param horizontalAlignment how control will be positioned horizontally within a cell,
 *      one of: SWT.BEGINNING (or SWT.LEFT), SWT.CENTER, SWT.END (or SWT.RIGHT), or SWT.FILL
 * @param verticalAlignment how control will be positioned vertically within a cell,
 *      one of: SWT.BEGINNING (or SWT.TOP), SWT.CENTER, SWT.END (or SWT.BOTTOM), or SWT.FILL
 * @param grabExcessHorizontalSpace whether cell will be made wide enough to fit the remaining horizontal space
 * @param grabExcessVerticalSpace whether cell will be made high enough to fit the remaining vertical space
 * @param horizontalSpan the number of column cells that the control will take up
 * @param verticalSpan the number of row cells that the control will take up
 *
 * @since 3.0
 */
public this (int horizontalAlignment, int verticalAlignment, bool grabExcessHorizontalSpace, bool grabExcessVerticalSpace, int horizontalSpan, int verticalSpan) {
    this.horizontalAlignment = horizontalAlignment;
    this.verticalAlignment = verticalAlignment;
    this.grabExcessHorizontalSpace = grabExcessHorizontalSpace;
    this.grabExcessVerticalSpace = grabExcessVerticalSpace;
    this.horizontalSpan = horizontalSpan;
    this.verticalSpan = verticalSpan;
}

/**
 * Constructs a new instance of GridData according to the parameters.
 * A value of SWT.DEFAULT indicates that no minimum width or
 * no minimum height is specified.
 *
 * @param width a minimum width for the column
 * @param height a minimum height for the row
 *
 * @since 3.0
 */
public this (int width, int height) {
    this.widthHint = width;
    this.heightHint = height;
}

void computeSize (Control control, int wHint, int hHint, bool flushCache) {
    if (cacheWidth !is -1 && cacheHeight !is -1) return;
    if (wHint is this.widthHint && hHint is this.heightHint) {
        if (defaultWidth is -1 || defaultHeight is -1 || wHint !is defaultWhint || hHint !is defaultHhint) {
            Point size = control.computeSize (wHint, hHint, flushCache);
            defaultWhint = wHint;
            defaultHhint = hHint;
            defaultWidth = size.x;
            defaultHeight = size.y;
        }
        cacheWidth = defaultWidth;
        cacheHeight = defaultHeight;
        return;
    }
    if (currentWidth is -1 || currentHeight is -1 || wHint !is currentWhint || hHint !is currentHhint) {
        Point size = control.computeSize (wHint, hHint, flushCache);
        currentWhint = wHint;
        currentHhint = hHint;
        currentWidth = size.x;
        currentHeight = size.y;
    }
    cacheWidth = currentWidth;
    cacheHeight = currentHeight;
}

void flushCache () {
    cacheWidth = cacheHeight = -1;
    defaultWidth = defaultHeight = -1;
    currentWidth = currentHeight = -1;
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
 * @return a string representation of the GridData object
 */
override public String toString () {
    String hAlign = "";
    switch (horizontalAlignment) {
        case SWT.FILL: hAlign = "SWT.FILL"; break;
        case SWT.BEGINNING: hAlign = "SWT.BEGINNING"; break;
        case SWT.LEFT: hAlign = "SWT.LEFT"; break;
        case SWT.END: hAlign = "SWT.END"; break;
        case END: hAlign = "GridData.END"; break;
        case SWT.RIGHT: hAlign = "SWT.RIGHT"; break;
        case SWT.CENTER: hAlign = "SWT.CENTER"; break;
        case CENTER: hAlign = "GridData.CENTER"; break;
        default: hAlign = "Undefined "~String_valueOf(horizontalAlignment); break;
    }
    String vAlign = "";
    switch (verticalAlignment) {
        case SWT.FILL: vAlign = "SWT.FILL"; break;
        case SWT.BEGINNING: vAlign = "SWT.BEGINNING"; break;
        case SWT.TOP: vAlign = "SWT.TOP"; break;
        case SWT.END: vAlign = "SWT.END"; break;
        case END: vAlign = "GridData.END"; break;
        case SWT.BOTTOM: vAlign = "SWT.BOTTOM"; break;
        case SWT.CENTER: vAlign = "SWT.CENTER"; break;
        case CENTER: vAlign = "GridData.CENTER"; break;
        default: vAlign = "Undefined "~String_valueOf(verticalAlignment); break;
    }
    String string = getName()~" {";
    string ~= "horizontalAlignment="~hAlign~" ";
    if (horizontalIndent !is 0) string ~= "horizontalIndent="~String_valueOf(horizontalIndent)~" ";
    if (horizontalSpan !is 1) string ~= "horizontalSpan="~String_valueOf(horizontalSpan)~" ";
    if (grabExcessHorizontalSpace) string ~= "grabExcessHorizontalSpace="~String_valueOf(grabExcessHorizontalSpace)~" ";
    if (widthHint !is SWT.DEFAULT) string ~= "widthHint="~String_valueOf(widthHint)~" ";
    if (minimumWidth !is 0) string ~= "minimumWidth="~String_valueOf(minimumWidth)~" ";
    string ~= "verticalAlignment="~vAlign~" ";
    if (verticalIndent !is 0) string ~= "verticalIndent="~String_valueOf(verticalIndent)~" ";
    if (verticalSpan !is 1) string ~= "verticalSpan="~String_valueOf(verticalSpan)~" ";
    if (grabExcessVerticalSpace) string ~= "grabExcessVerticalSpace="~String_valueOf(grabExcessVerticalSpace)~" ";
    if (heightHint !is SWT.DEFAULT) string ~= "heightHint="~String_valueOf(heightHint)~" ";
    if (minimumHeight !is 0) string ~= "minimumHeight="~String_valueOf(minimumHeight)~" ";
    if (exclude) string ~= "exclude="~String_valueOf(exclude)~" ";
    string = string.trim();
    string ~= "}";
    return string;
}
}
