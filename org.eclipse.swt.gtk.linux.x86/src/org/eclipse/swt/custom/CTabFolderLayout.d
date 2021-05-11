/*******************************************************************************
 * Copyright (c) 2000, 2012 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *     alice <stigma@disroot.org>
 *******************************************************************************/
module org.eclipse.swt.custom.CTabFolderLayout;

import java.lang.all;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Layout;
import org.eclipse.swt.custom.CTabFolder;
import org.eclipse.swt.custom.CTabItem;
import org.eclipse.swt.custom.CTabFolderRenderer;

/**
 * This class provides the layout for CTabFolder
 *
 * @see CTabFolder
 */
class CTabFolderLayout : Layout {
package(org.eclipse.swt.custom):

override
protected Point computeSize(Composite composite, int wHint, int hHint, bool flushCache) {
    CTabFolder folder = cast(CTabFolder)composite;
    CTabItem[] items = folder.items;
    CTabFolderRenderer renderer = folder.renderer;
    // preferred width of tab area to show all tabs
    int tabW = 0;
    int selectedIndex = folder.selectedIndex;
    if (selectedIndex == -1) selectedIndex = 0;
    GC gc = new GC(folder);
    for (int i = 0; i < items.length; i++) {
        if (folder.single) {
            tabW = Math.max(tabW, renderer.computeSize(i, SWT.SELECTED, gc, SWT.DEFAULT, SWT.DEFAULT).x);
        } else {
            int state = 0;
            if (i == selectedIndex) state |= SWT.SELECTED;
            tabW += renderer.computeSize(i, state, gc, SWT.DEFAULT, SWT.DEFAULT).x;
        }
    }

    int width = 0, wrapHeight = 0;
    bool leftControl = false, rightControl = false;
    if (wHint == SWT.DEFAULT) {
        for (int i = 0; i < folder.controls.length; i++) {
            Control control = folder.controls[i];
            if (!control.isDisposed() && control.getVisible()) {
                if ((folder.controlAlignments[i] & SWT.LEAD) != 0) {
                    leftControl = true;
                } else {
                    rightControl = true;
                }
                width += control.computeSize(SWT.DEFAULT, SWT.DEFAULT).x;
            }
        }
    } else {
        Point size = new Point (wHint, hHint);
        bool[][] positions;
        /+ DWT: Port CTabFolder.computeControlBounds(Point, bool[][])
        // Rectangle[] rects = folder.computeControlBounds(size, positions);
        int minY = Integer.MAX_VALUE, maxY = 0;
        for (int i = 0; i < rects.length; i++) {
            if (positions[0][i]) {
                minY = Math.min(minY, rects[i].y);
                maxY = Math.max(maxY, rects[i].y + rects[i].height);
                wrapHeight = maxY - minY;
            } else {
                if ((folder.controlAlignments[i] & SWT.LEAD) != 0) {
                    leftControl = true;
                } else {
                    rightControl = true;
                }
                width += rects[i].width;
            }
        }+/
    }
    if (leftControl) width += CTabFolder.SPACING * 2;
    if (rightControl) width += CTabFolder.SPACING * 2;
    tabW += width;

    gc.dispose();

    int controlW = 0;
    int controlH = 0;
    // preferred size of controls in tab items
    for (int i = 0; i < items.length; i++) {
        Control control = items[i].getControl();
        if (control !is null && !control.isDisposed()){
            Point size = control.computeSize (wHint, hHint, flushCache);
            controlW = Math.max (controlW, size.x);
            controlH = Math.max (controlH, size.y);
        }
    }

    int minWidth = Math.max(tabW, controlW + folder.marginWidth);
    int minHeight = (folder.minimized) ? 0 : controlH + wrapHeight;
    if (minWidth is 0) minWidth = CTabFolder.DEFAULT_WIDTH;
    if (minHeight is 0) minHeight = CTabFolder.DEFAULT_HEIGHT;

    if (wHint !is SWT.DEFAULT) minWidth  = wHint;
    if (hHint !is SWT.DEFAULT) minHeight = hHint;

    return new Point (minWidth, minHeight);
}
override
protected bool flushCache(Control control) {
    return true;
}
override
protected void layout(Composite composite, bool flushCache) {
    CTabFolder folder = cast(CTabFolder)composite;
    // resize content
    if (folder.selectedIndex !is -1) {
        Control control = folder.items[folder.selectedIndex].control;
        if (control !is null && !control.isDisposed()) {
            control.setBounds(folder.getClientArea());
        }
    }
}
}
