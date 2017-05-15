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
module org.eclipse.swt.snippets.Snippet97;
 
/*
 * Menu example snippet: fill a menu dynamically (when menu shown)
 * Select items then right click to show menu.
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
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.TreeItem;
import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

void main () {
    auto display = new Display ();
    auto shell = new Shell (display);
    auto tree = new Tree (shell, SWT.BORDER | SWT.MULTI);
    auto menu = new Menu (shell, SWT.POP_UP);
    tree.setMenu (menu);
    for (int i=0; i<12; i++) {
        auto item = new TreeItem (tree, SWT.NONE);
        item.setText ("Item " ~ to!(String)(i));
    }
    menu.addListener (SWT.Show, new class Listener {
        public void handleEvent (Event event) {
            auto menuItems = menu.getItems ();
            foreach (item; menuItems) {
                item.dispose ();
            }
            auto treeItems = tree.getSelection ();
            foreach (item; treeItems) {
                auto menuItem = new MenuItem (menu, SWT.PUSH);
                menuItem.setText (item.getText ());
            }
        }
    });
    tree.setSize (200, 200);
    shell.setSize (300, 300);
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
