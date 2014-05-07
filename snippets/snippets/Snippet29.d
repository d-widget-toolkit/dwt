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
 *     Jesse Phillips <Jesse.K.Phillips+D> gmail.com
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet29;

/*
 * Menu example snippet: create a bar and pull down menu (accelerators, mnemonics)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.swt.widgets.Shell;

version(Tango){
    import tango.io.Stdout;
} else { // Phobos
    import std.stdio;
}

void main () {
    auto display = new Display ();
    auto shell = new Shell (display);
    auto bar = new Menu (shell, SWT.BAR);
    shell.setMenuBar (bar);
    auto fileItem = new MenuItem (bar, SWT.CASCADE);
    fileItem.setText ("&File");
    auto submenu = new Menu (shell, SWT.DROP_DOWN);
    fileItem.setMenu (submenu);
    auto item = new MenuItem (submenu, SWT.PUSH);
    item.addListener (SWT.Selection, new class Listener {
        public void handleEvent (Event e) {
            version(Tango){
                Stdout("Select All").newline;
            } else { // Phobos
                writeln("Select All");
            }
        }
    });
    item.setText ("Select &All\tCtrl+A");
    item.setAccelerator (SWT.CTRL + 'A');
    shell.setSize (200, 200);
    shell.open ();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
