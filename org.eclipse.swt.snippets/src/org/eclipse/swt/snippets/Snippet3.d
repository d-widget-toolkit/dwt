#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet3"
    dependency "dwt" path="../../../../../../" version="*"
    lflags "/subsystem:console:4" platform="x86_omf"
    libs \
      "atk-1.0" \
      "cairo" \
      "dl" \
      "fontconfig" \
      "gdk-x11-2.0" \
      "gdk_pixbuf-2.0" \
      "gio-2.0" \
      "glib-2.0" \
      "gmodule-2.0" \
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
 * Copyright (c) 2000, 2016 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * D Port:
 *     alice <stigma@disroot.org>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet3;

import std.conv : to;
import std.stdio : writeln;

/*
 * Table example snippet: find a table cell from mouse down (SWT.FULL_SELECTION)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.all;
import org.eclipse.swt.graphics.all;
import org.eclipse.swt.widgets.all;

void main(string[] args) {
    Display display = new Display();
    Shell shell = new Shell(display);
    Table table = new Table(shell, SWT.BORDER | SWT.V_SCROLL |
            SWT.FULL_SELECTION);
    table.setHeaderVisible(true);
    table.setLinesVisible(true);
    const int rowCount = 64, columnCount = 4;
    for (int i = 0; i < columnCount; i++) {
        TableColumn column = new TableColumn(table, SWT.NONE);
        column.setText("Column " ~ to!string(i));
    }
    for (int i = 0; i < rowCount; i++) {
        TableItem item = new TableItem(table, SWT.NONE);
        for (int j = 0; j < columnCount; j++) {
            item.setText(j, "Item " ~ to!string(i) ~ "-" ~ to!string(j));
        }
    }
    for (int i = 0; i < columnCount; i++) {
        table.getColumn(i).pack();
    }
    Rectangle clientArea = shell.getClientArea();
    table.setLocation(clientArea.x, clientArea.y);
    Point size = table.computeSize(SWT.DEFAULT, 200);
    table.setSize(size);
    shell.pack();
    table.addListener(SWT.MouseDown, new class Listener {
        override void handleEvent(Event event) {
            Point pt = new Point(event.x, event.y);
            TableItem item = table.getItem(pt);
            if (item is null)
                return;
            for (int i = 0; i < columnCount; i++) {
                Rectangle rect = item.getBounds(i);
                if (rect.contains(pt)) {
                    int index = table.indexOf(item);
                    writeln("Item ", index, "-", i);
                }
            }
        }
    });
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}
