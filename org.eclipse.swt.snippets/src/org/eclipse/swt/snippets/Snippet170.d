#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet170"
    dependency "dwt" path="../../../../../../"
    lflags "/subsystem:console:4" platform="x86_omf"
    libs \
      "atk-1.0" \
      "cairo" \
      "dl" \
      "fontconfig" \
      "gdk-x11-2.0" \
      "gdk_pixbuf-2.0" \
      "glib-2.0" \
      "gmodule-2.0" \
      "gnomeui-2" \
      "gnomevfs-2" \
      "gobject-2.0" \
      "gthread-2.0" \
      "gtk-x11-2.0" \
      "pango-1.0" \
      "pangocairo-1.0" \
      "X11" \
      "Xcomposite" \
      "Xcursor" \
      "Xdamage" \
      "Xext" \
      "Xfixes" \
      "Xi" \
      "Xinerama" \
      "Xrandr" \
      "Xrender" \
      "Xtst" \
      platform="linux"
+/

/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * D Port:
 *     Bill Baxter <wbaxter@gmail.com>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet170;

/*
 * Tree example snippet: Create a Tree with columns
 * 
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 * 
 * @since 3.1
 */

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.TreeItem;
import org.eclipse.swt.widgets.TreeColumn;
import org.eclipse.swt.layout.FillLayout;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

import java.lang.all;

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());
    Tree tree = new Tree(shell, SWT.BORDER | SWT.H_SCROLL | SWT.V_SCROLL);
    tree.setHeaderVisible(true);
    TreeColumn column1 = new TreeColumn(tree, SWT.LEFT);
    column1.setText("Column 1");
    column1.setWidth(200);
    TreeColumn column2 = new TreeColumn(tree, SWT.CENTER);
    column2.setText("Column 2");
    column2.setWidth(200);
    TreeColumn column3 = new TreeColumn(tree, SWT.RIGHT);
    column3.setText("Column 3");
    column3.setWidth(200);
    for (int i = 0; i < 4; i++) {
        TreeItem item = new TreeItem(tree, SWT.NONE);
        item.setText([ "item " ~ to!(String)(i), "abc", "defghi" ]);
        for (int j = 0; j < 4; j++) {
            TreeItem subItem = new TreeItem(item, SWT.NONE);
            subItem.setText([ "subitem " ~ to!(String)(j), "jklmnop", "qrs" ]);
            for (int k = 0; k < 4; k++) {
                TreeItem subsubItem = new TreeItem(subItem, SWT.NONE);
                subsubItem.setText([ "subsubitem " ~ to!(String)(k), "tuv", "wxyz" ]);
            }
        }
    }
    shell.pack();
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) {
            display.sleep();
        }
    }
    display.dispose();
}
