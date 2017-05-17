/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * D Port
 *     Jesse Phillips <Jesse.K.Phillips+D> gmail.com
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet9;

/*
 * Composite example snippet: scroll a child control automatically
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.PaintListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.ScrollBar;
import org.eclipse.swt.widgets.Shell;
import java.lang.all;

void main () {
    auto display = new Display ();
    auto shell = new Shell
       (display, SWT.SHELL_TRIM | SWT.H_SCROLL | SWT.V_SCROLL);
    auto composite = new Composite (shell, SWT.BORDER);
    composite.setSize (700, 600);
    auto red = display.getSystemColor (SWT.COLOR_RED);
    composite.addPaintListener (new class PaintListener {
        public void paintControl (PaintEvent e) {
            e.gc.setBackground (red);
            e.gc.fillOval (5, 5, 690, 590);
        }
    });
    auto hBar = shell.getHorizontalBar ();
    hBar.addListener (SWT.Selection, new class Listener {
        public void handleEvent (Event e) {
            auto location = composite.getLocation ();
            location.x = -hBar.getSelection ();
            composite.setLocation (location);
        }
    });
    ScrollBar vBar = shell.getVerticalBar ();
    vBar.addListener (SWT.Selection, new class Listener {
        public void handleEvent (Event e) {
            Point location = composite.getLocation ();
            location.y = -vBar.getSelection ();
            composite.setLocation (location);
        }
    });
    shell.addListener (SWT.Resize,  new class Listener {
        public void handleEvent (Event e) {
            Point size = composite.getSize ();
            Rectangle rect = shell.getClientArea ();
            hBar.setMaximum (size.x);
            vBar.setMaximum (size.y);
            hBar.setThumb (Math.min (size.x, rect.width));
            vBar.setThumb (Math.min (size.y, rect.height));
            int hPage = size.x - rect.width;
            int vPage = size.y - rect.height;
            int hSelection = hBar.getSelection ();
            int vSelection = vBar.getSelection ();
            Point location = composite.getLocation ();
            if (hSelection >= hPage) {
                if (hPage <= 0) hSelection = 0;
                location.x = -hSelection;
            }
            if (vSelection >= vPage) {
                if (vPage <= 0) vSelection = 0;
                location.y = -vSelection;
            }
            composite.setLocation (location);
        }
    });
    shell.open ();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
