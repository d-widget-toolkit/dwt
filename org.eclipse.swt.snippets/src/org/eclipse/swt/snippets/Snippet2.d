#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet2"
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
module org.eclipse.swt.snippets.Snippet2;

import std.algorithm.comparison : cmp;

/*
 * Table example snippet: sort a table by column
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.2
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.layout.all;
import org.eclipse.swt.widgets.all;

void main(string[] args) {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());
    Table table = new Table(shell, SWT.BORDER);
    table.setHeaderVisible(true);
    TableColumn column1 = new TableColumn(table, SWT.NONE);
    column1.setText("Column 1");
    TableColumn column2 = new TableColumn(table, SWT.NONE);
    column2.setText("Column 2");
    TableItem item = new TableItem(table, SWT.NONE);
    item.setText(["a", "3"]);
    item = new TableItem(table, SWT.NONE);
    item.setText(["b", "2"]);
    item = new TableItem(table, SWT.NONE);
    item.setText(["c", "1"]);
    column1.setWidth(100);
    column2.setWidth(100);

    SelectionListener sortListener = new class SelectionListener {
        override void widgetSelected(SelectionEvent e) {
            TableItem[] items = table.getItems();
            TableColumn column = cast(TableColumn)e.widget;
            int index = column is column1 ? 0 : 1;
            for (int i = 1; i < items.length; i++) {
                string value1 = items[i].getText(index);
                for (int j = 0; j < i; j++) {
                    string value2 = items[j].getText(index);
                    if (cmp(value1, value2) < 0) {
                        string[] values = [items[i].getText(0), items[i].getText(1)];
                        items[i].dispose();
                        TableItem item1 = new TableItem(table, SWT.NONE, j);
                        item1.setText(values);
                        items = table.getItems();
                        break;
                    }
                }
            }
            table.setSortColumn(column);
        }

        override void widgetDefaultSelected(SelectionEvent e) {}
    };

    column1.addSelectionListener(sortListener);
    column2.addSelectionListener(sortListener);
    table.setSortColumn(column1);
    table.setSortDirection(SWT.UP);
    shell.setSize(shell.computeSize(SWT.DEFAULT, SWT.DEFAULT).x, 300);
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}
