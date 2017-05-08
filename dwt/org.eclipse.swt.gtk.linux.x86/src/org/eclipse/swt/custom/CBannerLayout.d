/*******************************************************************************
 * Copyright (c) 2000, 2006 IBM Corporation and others.
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
module org.eclipse.swt.custom.CBannerLayout;

import java.lang.all;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Layout;
import org.eclipse.swt.widgets.Scrollable;
import org.eclipse.swt.custom.CBanner;
import org.eclipse.swt.custom.CLayoutData;


/**
 * This class provides the layout for CBanner
 *
 * @see CBanner
 */
class CBannerLayout : Layout {

protected override Point computeSize(Composite composite, int wHint, int hHint, bool flushCache) {
    CBanner banner = cast(CBanner)composite;
    Control left = banner.left;
    Control right = banner.right;
    Control bottom = banner.bottom;
    bool showCurve = left !is null && right !is null;
    int height = hHint;
    int width = wHint;

    // Calculate component sizes
    Point bottomSize = new Point(0, 0);
    if (bottom !is null) {
        int trim = computeTrim(bottom);
        int w = wHint is SWT.DEFAULT ? SWT.DEFAULT : Math.max(0, width - trim);
        bottomSize = computeChildSize(bottom, w, SWT.DEFAULT, flushCache);
    }
    Point rightSize = new Point(0, 0);
    if (right !is null) {
        int trim = computeTrim(right);
        int w = SWT.DEFAULT;
        if (banner.rightWidth !is SWT.DEFAULT) {
            w = banner.rightWidth - trim;
            if (left !is null) {
                w = Math.min(w, width - banner.curve_width + 2* banner.curve_indent - CBanner.MIN_LEFT - trim);
            }
            w = Math.max(0, w);
        }
        rightSize = computeChildSize(right, w, SWT.DEFAULT, flushCache);
        if (wHint !is SWT.DEFAULT) {
            width -= rightSize.x + banner.curve_width - 2* banner.curve_indent;
        }
    }
    Point leftSize = new Point(0, 0);
    if (left !is null) {
        int trim = computeTrim(left);
        int w = wHint is SWT.DEFAULT ? SWT.DEFAULT : Math.max(0, width - trim);
        leftSize = computeChildSize(left, w, SWT.DEFAULT, flushCache);
    }

    // Add up sizes
    width = leftSize.x + rightSize.x;
    height = bottomSize.y;
    if (bottom !is null && (left !is null || right !is null)) {
        height += CBanner.BORDER_STRIPE + 2;
    }
    if (left !is null) {
        if (right is null) {
            height += leftSize.y;
        } else {
            height += Math.max(leftSize.y, banner.rightMinHeight is SWT.DEFAULT ? rightSize.y : banner.rightMinHeight);
        }
    } else {
        height += rightSize.y;
    }
    if (showCurve) {
        width += banner.curve_width - 2*banner.curve_indent;
        height +=  CBanner.BORDER_TOP + CBanner.BORDER_BOTTOM + 2*CBanner.BORDER_STRIPE;
    }

    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;

    return new Point(width, height);
}
Point computeChildSize(Control control, int wHint, int hHint, bool flushCache) {
    Object data = control.getLayoutData();
    if (data is null || !( null !is cast(CLayoutData)data)) {
        data = new CLayoutData();
        control.setLayoutData(data);
    }
    return (cast(CLayoutData)data).computeSize(control, wHint, hHint, flushCache);
}
int computeTrim(Control c) {
    if ( auto s = cast(Scrollable)c) {
        Rectangle rect = s.computeTrim (0, 0, 0, 0);
        return rect.width;
    }
    return c.getBorderWidth () * 2;
}
protected override bool flushCache(Control control) {
    Object data = control.getLayoutData();
    if ( auto ld = cast(CLayoutData)data ) ld.flushCache();
    return true;
}
protected override void layout(Composite composite, bool flushCache) {
    CBanner banner = cast(CBanner)composite;
    Control left = banner.left;
    Control right = banner.right;
    Control bottom = banner.bottom;

    Point size = banner.getSize();
    bool showCurve = left !is null && right !is null;
    int width = size.x - 2*banner.getBorderWidth();
    int height = size.y - 2*banner.getBorderWidth();

    Point bottomSize = new Point(0, 0);
    if (bottom !is null) {
        int trim = computeTrim(bottom);
        int w = Math.max(0, width - trim);
        bottomSize = computeChildSize(bottom, w, SWT.DEFAULT, flushCache);
        height -= bottomSize.y + CBanner.BORDER_STRIPE + 2;
    }
    if (showCurve) height -=  CBanner.BORDER_TOP + CBanner.BORDER_BOTTOM + 2*CBanner.BORDER_STRIPE;
    height = Math.max(0, height);
    Point rightSize = new Point(0,0);
    if (right !is null) {
        int trim = computeTrim(right);
        int w = SWT.DEFAULT;
        if (banner.rightWidth !is SWT.DEFAULT) {
            w = banner.rightWidth - trim;
            if (left !is null) {
                w = Math.min(w, width - banner.curve_width + 2* banner.curve_indent - CBanner.MIN_LEFT - trim);
            }
            w = Math.max(0, w);
        }
        rightSize = computeChildSize(right, w, SWT.DEFAULT, flushCache);
        width = width - (rightSize.x - banner.curve_indent + banner.curve_width - banner.curve_indent);
    }
    Point leftSize = new Point(0, 0);
    if (left !is null) {
        int trim = computeTrim(left);
        int w = Math.max(0, width - trim);
        leftSize = computeChildSize(left, w, SWT.DEFAULT, flushCache);
    }

    int x = 0;
    int y = 0;
    int oldStart = banner.curveStart;
    Rectangle leftRect = null;
    Rectangle rightRect = null;
    Rectangle bottomRect = null;
    if (bottom !is null) {
        bottomRect = new Rectangle(x, y+size.y-bottomSize.y, bottomSize.x, bottomSize.y);
    }
    if (showCurve) y += CBanner.BORDER_TOP + CBanner.BORDER_STRIPE;
    if(left !is null) {
        leftRect = new Rectangle(x, y, leftSize.x, leftSize.y);
        banner.curveStart = x + leftSize.x - banner.curve_indent;
        x += leftSize.x - banner.curve_indent + banner.curve_width - banner.curve_indent;
    }
    if (right !is null) {
        if (left !is null) {
            rightSize.y = Math.max(leftSize.y, banner.rightMinHeight is SWT.DEFAULT ? rightSize.y : banner.rightMinHeight);
        }
        rightRect = new Rectangle(x, y, rightSize.x, rightSize.y);
    }
    if (banner.curveStart < oldStart) {
        banner.redraw(banner.curveStart - CBanner.CURVE_TAIL, 0, oldStart + banner.curve_width - banner.curveStart + CBanner.CURVE_TAIL + 5, size.y, false);
    }
    if (banner.curveStart > oldStart) {
        banner.redraw(oldStart - CBanner.CURVE_TAIL, 0, banner.curveStart + banner.curve_width - oldStart + CBanner.CURVE_TAIL + 5, size.y, false);
    }
    /*
     * The paint events must be flushed in order to make the curve draw smoothly
     * while the user drags the divider.
     * On Windows, it is necessary to flush the paints before the children are
     * resized because otherwise the children (particularly toolbars) will flash.
     */
    banner.update();
    banner.curveRect = new Rectangle(banner.curveStart, 0, banner.curve_width, size.y);
    if (bottomRect !is null) bottom.setBounds(bottomRect);
    if (rightRect !is null) right.setBounds(rightRect);
    if (leftRect !is null) left.setBounds(leftRect);
}
}
