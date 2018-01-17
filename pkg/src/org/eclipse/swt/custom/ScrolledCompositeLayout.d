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
module org.eclipse.swt.custom.ScrolledCompositeLayout;

import java.lang.all;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Layout;
import org.eclipse.swt.widgets.ScrollBar;
import org.eclipse.swt.custom.ScrolledComposite;


/**
 * This class provides the layout for ScrolledComposite
 *
 * @see ScrolledComposite
 */
class ScrolledCompositeLayout : Layout {

    bool inLayout = false;
    static const int DEFAULT_WIDTH  = 64;
    static const int DEFAULT_HEIGHT = 64;

protected override Point computeSize(Composite composite, int wHint, int hHint, bool flushCache) {
    ScrolledComposite sc = cast(ScrolledComposite)composite;
    Point size = new Point(DEFAULT_WIDTH, DEFAULT_HEIGHT);
    if (sc.content !is null) {
        Point preferredSize = sc.content.computeSize(wHint, hHint, flushCache);
        Point currentSize = sc.content.getSize();
        size.x = sc.getExpandHorizontal() ? preferredSize.x : currentSize.x;
        size.y = sc.getExpandVertical() ? preferredSize.y : currentSize.y;
    }
    size.x = Math.max(size.x, sc.minWidth);
    size.y = Math.max(size.y, sc.minHeight);
    if (wHint !is SWT.DEFAULT) size.x = wHint;
    if (hHint !is SWT.DEFAULT) size.y = hHint;
    return size;
}

protected override bool flushCache(Control control) {
    return true;
}

protected override void layout(Composite composite, bool flushCache) {
    if (inLayout) return;
    ScrolledComposite sc = cast(ScrolledComposite)composite;
    if (sc.content is null) return;
    ScrollBar hBar = sc.getHorizontalBar();
    ScrollBar vBar = sc.getVerticalBar();
    if (hBar !is null) {
        if (hBar.getSize().y >= sc.getSize().y) {
            return;
        }
    }
    if (vBar !is null) {
        if (vBar.getSize().x >= sc.getSize().x) {
            return;
        }
    }
    inLayout = true;
    Rectangle contentRect = sc.content.getBounds();
    if (!sc.alwaysShowScroll) {
        bool hVisible = sc.needHScroll(contentRect, false);
        bool vVisible = sc.needVScroll(contentRect, hVisible);
        if (!hVisible && vVisible) hVisible = sc.needHScroll(contentRect, vVisible);
        if (hBar !is null) hBar.setVisible(hVisible);
        if (vBar !is null) vBar.setVisible(vVisible);
    }
    Rectangle hostRect = sc.getClientArea();
    if (sc.expandHorizontal) {
        contentRect.width = Math.max(sc.minWidth, hostRect.width);
    }
    if (sc.expandVertical) {
        contentRect.height = Math.max(sc.minHeight, hostRect.height);
    }

    if (hBar !is null) {
        hBar.setMaximum (contentRect.width);
        hBar.setThumb (Math.min (contentRect.width, hostRect.width));
        int hPage = contentRect.width - hostRect.width;
        int hSelection = hBar.getSelection ();
        if (hSelection >= hPage) {
            if (hPage <= 0) {
                hSelection = 0;
                hBar.setSelection(0);
            }
            contentRect.x = -hSelection;
        }
    }

    if (vBar !is null) {
        vBar.setMaximum (contentRect.height);
        vBar.setThumb (Math.min (contentRect.height, hostRect.height));
        int vPage = contentRect.height - hostRect.height;
        int vSelection = vBar.getSelection ();
        if (vSelection >= vPage) {
            if (vPage <= 0) {
                vSelection = 0;
                vBar.setSelection(0);
            }
            contentRect.y = -vSelection;
        }
    }

    sc.content.setBounds (contentRect);
    inLayout = false;
}
}
