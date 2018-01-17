/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * D Port:
 *     Thomas Demmer <t_demmer AT web DOT de>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet46;

/*
 * Composite example snippet: intercept mouse events (drag a button with the mouse)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.layout.FillLayout;

import java.lang.all;

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    Composite composite = new Composite (shell, SWT.NONE);
    composite.setEnabled (false);
    composite.setLayout (new FillLayout ());
    Button button = new Button (composite, SWT.PUSH);
    button.setText ("Button");
    composite.pack ();
    composite.setLocation (10, 10);
    Point[1] offset;
    Listener listener = new class Listener{
        public void handleEvent (Event event) {
            switch (event.type) {
                case SWT.MouseDown:
                Rectangle rect = composite.getBounds ();
                if (rect.contains (event.x, event.y)) {
                    Point pt1 = composite.toDisplay (0, 0);
                    Point pt2 = shell.toDisplay (event.x, event.y);
                    offset [0] = new Point (pt2.x - pt1.x, pt2.y - pt1.y);
                }
                break;
                case SWT.MouseMove:
                if (offset [0] !is null) {
                    Point pt = offset [0];
                    composite.setLocation (event.x - pt.x, event.y - pt.y);
                }
                break;
                case SWT.MouseUp:
                offset [0] = null;
                break;
                default:
            }
        }
    };
    shell.addListener (SWT.MouseDown, listener);
    shell.addListener (SWT.MouseUp, listener);
    shell.addListener (SWT.MouseMove, listener);
    shell.setSize (300, 300);
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}

