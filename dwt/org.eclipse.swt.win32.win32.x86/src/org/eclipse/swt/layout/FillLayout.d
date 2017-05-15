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
module org.eclipse.swt.layout.FillLayout;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Layout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Scrollable;
import org.eclipse.swt.layout.FillData;

import java.lang.all;

/**
 * <code>FillLayout</code> is the simplest layout class. It lays out
 * controls in a single row or column, forcing them to be the same size.
 * <p>
 * Initially, the controls will all be as tall as the tallest control,
 * and as wide as the widest. <code>FillLayout</code> does not wrap,
 * but you can specify margins and spacing. You might use it to
 * lay out buttons in a task bar or tool bar, or to stack checkboxes
 * in a <code>Group</code>. <code>FillLayout</code> can also be used
 * when a <code>Composite</code> only has one child. For example,
 * if a <code>Shell</code> has a single <code>Group</code> child,
 * <code>FillLayout</code> will cause the <code>Group</code> to
 * completely fill the <code>Shell</code> (if margins are 0).
 * </p>
 * <p>
 * Example code: first a <code>FillLayout</code> is created and
 * its type field is set, and then the layout is set into the
 * <code>Composite</code>. Note that in a <code>FillLayout</code>,
 * children are always the same size, and they fill all available space.
 * <pre>
 *      FillLayout fillLayout = new FillLayout();
 *      fillLayout.type = SWT.VERTICAL;
 *      shell.setLayout(fillLayout);
 * </pre>
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: LayoutExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class FillLayout : Layout {
    /**
     * type specifies how controls will be positioned
     * within the layout.
     *
     * The default value is HORIZONTAL.
     *
     * Possible values are: <ul>
     *    <li>HORIZONTAL: Position the controls horizontally from left to right</li>
     *    <li>VERTICAL: Position the controls vertically from top to bottom</li>
     * </ul>
     */
    public int type = SWT.HORIZONTAL;

    /**
     * marginWidth specifies the number of pixels of horizontal margin
     * that will be placed along the left and right edges of the layout.
     *
     * The default value is 0.
     *
     * @since 3.0
     */
    public int marginWidth = 0;

    /**
     * marginHeight specifies the number of pixels of vertical margin
     * that will be placed along the top and bottom edges of the layout.
     *
     * The default value is 0.
     *
     * @since 3.0
     */
    public int marginHeight = 0;

    /**
     * spacing specifies the number of pixels between the edge of one cell
     * and the edge of its neighbouring cell.
     *
     * The default value is 0.
     *
     * @since 3.0
     */
    public int spacing = 0;

/**
 * Constructs a new instance of this class.
 */
public this () {
}

/**
 * Constructs a new instance of this class given the type.
 *
 * @param type the type of fill layout
 *
 * @since 2.0
 */
public this (int type) {
    this.type = type;
}

override protected Point computeSize (Composite composite, int wHint, int hHint, bool flushCache) {
    Control [] children = composite.getChildren ();
    int count = cast(int)/*64bit*/children.length;
    int maxWidth = 0, maxHeight = 0;
    for (int i=0; i<count; i++) {
        Control child = children [i];
        int w = wHint, h = hHint;
        if (count > 0) {
            if (type is SWT.HORIZONTAL && wHint !is SWT.DEFAULT) {
                w = Math.max (0, (wHint - (count - 1) * spacing) / count);
            }
            if (type is SWT.VERTICAL && hHint !is SWT.DEFAULT) {
                h = Math.max (0, (hHint - (count - 1) * spacing) / count);
            }
        }
        Point size = computeChildSize (child, w, h, flushCache);
        maxWidth = Math.max (maxWidth, size.x);
        maxHeight = Math.max (maxHeight, size.y);
    }
    int width = 0, height = 0;
    if (type is SWT.HORIZONTAL) {
        width = count * maxWidth;
        if (count !is 0) width += (count - 1) * spacing;
        height = maxHeight;
    } else {
        width = maxWidth;
        height = count * maxHeight;
        if (count !is 0) height += (count - 1) * spacing;
    }
    width += marginWidth * 2;
    height += marginHeight * 2;
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    return new Point (width, height);
}

Point computeChildSize (Control control, int wHint, int hHint, bool flushCache) {
    FillData data = cast(FillData)control.getLayoutData ();
    if (data is null) {
        data = new FillData ();
        control.setLayoutData (data);
    }
    Point size = null;
    if (wHint is SWT.DEFAULT && hHint is SWT.DEFAULT) {
        size = data.computeSize (control, wHint, hHint, flushCache);
    } else {
        // TEMPORARY CODE
        int trimX, trimY;
        if ( auto sa = cast(Scrollable)control ) {
            Rectangle rect = sa.computeTrim (0, 0, 0, 0);
            trimX = rect.width;
            trimY = rect.height;
        } else {
            trimX = trimY = control.getBorderWidth () * 2;
        }
        int w = wHint is SWT.DEFAULT ? wHint : Math.max (0, wHint - trimX);
        int h = hHint is SWT.DEFAULT ? hHint : Math.max (0, hHint - trimY);
        size = data.computeSize (control, w, h, flushCache);
    }
    return size;
}

override protected bool flushCache (Control control) {
    Object data = control.getLayoutData();
    if (data !is null) (cast(FillData)data).flushCache();
    return true;
}

String getName () {
    String string = this.classinfo.name;
    int index = string.lastIndexOf( '.');
    if (index is -1 ) return string;
    return string[ index + 1 .. string.length ];
}

override protected void layout (Composite composite, bool flushCache) {
    Rectangle rect = composite.getClientArea ();
    Control [] children = composite.getChildren ();
    int count = cast(int)/*64bit*/children.length;
    if (count is 0) return;
    int width = rect.width - marginWidth * 2;
    int height = rect.height - marginHeight * 2;
    if (type is SWT.HORIZONTAL) {
        width -= (count - 1) * spacing;
        int x = rect.x + marginWidth, extra = width % count;
        int y = rect.y + marginHeight, cellWidth = width / count;
        for (int i=0; i<count; i++) {
            Control child = children [i];
            int childWidth = cellWidth;
            if (i is 0) {
                childWidth += extra / 2;
            } else {
                if (i is count - 1) childWidth += (extra + 1) / 2;
            }
            child.setBounds (x, y, childWidth, height);
            x += childWidth + spacing;
        }
    } else {
        height -= (count - 1) * spacing;
        int x = rect.x + marginWidth, cellHeight = height / count;
        int y = rect.y + marginHeight, extra = height % count;
        for (int i=0; i<count; i++) {
            Control child = children [i];
            int childHeight = cellHeight;
            if (i is 0) {
                childHeight += extra / 2;
            } else {
                if (i is count - 1) childHeight += (extra + 1) / 2;
            }
            child.setBounds (x, y, width, childHeight);
            y += childHeight + spacing;
        }
    }
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the layout
 */
override public String toString () {
    String string = getName () ~ " {";
    string ~= "type="~((type is SWT.VERTICAL) ? "SWT.VERTICAL" : "SWT.HORIZONTAL")~" ";
    if (marginWidth !is 0) string ~= "marginWidth="~String_valueOf(marginWidth)~" ";
    if (marginHeight !is 0) string ~= "marginHeight="~String_valueOf(marginHeight)~" ";
    if (spacing !is 0) string ~= "spacing="~String_valueOf(spacing)~" ";
    string = string.trim();
    string ~= "}";
    return string;
}
}
