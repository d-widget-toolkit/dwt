/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Bill Baxter <bill@billbaxter.com>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet67;

/*
 * ToolBar example snippet: place a drop down menu in a tool bar
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.ToolItem;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Event;
import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    ToolBar toolBar = new ToolBar (shell, SWT.NONE);
    Menu menu = new Menu (shell, SWT.POP_UP);
    for (int i=0; i<8; i++) {
        MenuItem item = new MenuItem (menu, SWT.PUSH);
        item.setText ("Item " ~ to!(String)(i));
    }
    ToolItem item = new ToolItem (toolBar, SWT.DROP_DOWN);
    item.addListener (SWT.Selection, new class Listener {
        void handleEvent (Event event) {
            if (event.detail == SWT.ARROW) {
                Rectangle rect = item.getBounds ();
                Point pt = new Point (rect.x, rect.y + rect.height);
                pt = toolBar.toDisplay (pt);
                menu.setLocation (pt.x, pt.y);
                menu.setVisible (true);
            }
        }
    });
    toolBar.pack ();
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    menu.dispose ();
    display.dispose ();
}
