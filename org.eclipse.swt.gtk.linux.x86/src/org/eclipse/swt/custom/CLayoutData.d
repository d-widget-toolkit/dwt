/*******************************************************************************
 * Copyright (c) 2005 IBM Corporation and others.
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
module org.eclipse.swt.custom.CLayoutData;


import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Control;

class CLayoutData {

    int defaultWidth = -1, defaultHeight = -1;
    int currentWhint, currentHhint, currentWidth = -1, currentHeight = -1;

Point computeSize (Control control, int wHint, int hHint, bool flushCache_) {
    if (flushCache_) flushCache();
    if (wHint is SWT.DEFAULT && hHint is SWT.DEFAULT) {
        if (defaultWidth is -1 || defaultHeight is -1) {
            Point size = control.computeSize (wHint, hHint, flushCache_);
            defaultWidth = size.x;
            defaultHeight = size.y;
        }
        return new Point(defaultWidth, defaultHeight);
    }
    if (currentWidth is -1 || currentHeight is -1 || wHint !is currentWhint || hHint !is currentHhint) {
        Point size = control.computeSize (wHint, hHint, flushCache_);
        currentWhint = wHint;
        currentHhint = hHint;
        currentWidth = size.x;
        currentHeight = size.y;
    }
    return new Point(currentWidth, currentHeight);
}
void flushCache () {
    defaultWidth = defaultHeight = -1;
    currentWidth = currentHeight = -1;
}
}
