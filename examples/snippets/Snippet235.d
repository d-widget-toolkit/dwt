/*******************************************************************************
 * Copyright (c) 2000, 2006 IBM Corporation and others.
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
module org.eclipse.swt.snippets.Snippet235;
/* 
 * example snippet: detect a system settings change
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 * 
 * @since 3.2
 */

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableColumn;
import org.eclipse.swt.widgets.TableItem;

import java.lang.all;

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setText("The SWT.Settings Event");
    shell.setLayout(new GridLayout());
    Label label = new Label(shell, SWT.WRAP);
    label.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false));
    label.setText("Change a system setting and the table below will be updated.");
    Table table = new Table(shell, SWT.BORDER);
    table.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));
    TableColumn column = new TableColumn(table, SWT.NONE);
    column = new TableColumn(table, SWT.NONE);
    column.setWidth(150);
    column = new TableColumn(table, SWT.NONE);
    for (int i = 0; i < colorIds.length; i++) {
        TableItem item = new TableItem(table, SWT.NONE);
        Color color = display.getSystemColor(colorIds[i]);
        item.setText(0, colorNames[i]);
        item.setBackground(1, color);
        item.setText(2, color.toString());
    }
    TableColumn[] columns = table.getColumns();
    columns[0].pack();
    columns[2].pack();
    display.addListener(SWT.Settings, dgListener((Event event){
        for (int i = 0; i < colorIds.length; i++) {
            Color color = display.getSystemColor(colorIds[i]);
            TableItem item = table.getItem(i);
            item.setBackground(1, color);
        }
        TableColumn[] columns = table.getColumns();
        columns[0].pack();
        columns[2].pack();
    }));

    shell.pack();
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    display.dispose();
}
const int[19] colorIds = 
    [ 
    SWT.COLOR_INFO_BACKGROUND, 
    SWT.COLOR_INFO_FOREGROUND, 
    SWT.COLOR_LIST_BACKGROUND,
    SWT.COLOR_LIST_FOREGROUND,
    SWT.COLOR_LIST_SELECTION,
    SWT.COLOR_LIST_SELECTION_TEXT,
    SWT.COLOR_TITLE_BACKGROUND,
    SWT.COLOR_TITLE_BACKGROUND_GRADIENT,
    SWT.COLOR_TITLE_FOREGROUND,
    SWT.COLOR_TITLE_INACTIVE_BACKGROUND,
    SWT.COLOR_TITLE_INACTIVE_BACKGROUND_GRADIENT,
    SWT.COLOR_TITLE_INACTIVE_FOREGROUND,
    SWT.COLOR_WIDGET_BACKGROUND,
    SWT.COLOR_WIDGET_BORDER,
    SWT.COLOR_WIDGET_DARK_SHADOW,
    SWT.COLOR_WIDGET_FOREGROUND,
    SWT.COLOR_WIDGET_HIGHLIGHT_SHADOW,
    SWT.COLOR_WIDGET_LIGHT_SHADOW,
    SWT.COLOR_WIDGET_NORMAL_SHADOW,
    ];
const String[19] colorNames = 
    [
    "SWT.COLOR_INFO_BACKGROUND",
    "SWT.COLOR_INFO_FOREGROUND", 
    "SWT.COLOR_LIST_BACKGROUND",
    "SWT.COLOR_LIST_FOREGROUND",
    "SWT.COLOR_LIST_SELECTION",
    "SWT.COLOR_LIST_SELECTION_TEXT",
    "SWT.COLOR_TITLE_BACKGROUND",
    "SWT.COLOR_TITLE_BACKGROUND_GRADIENT",
    "SWT.COLOR_TITLE_FOREGROUND",
    "SWT.COLOR_TITLE_INACTIVE_BACKGROUND",
    "SWT.COLOR_TITLE_INACTIVE_BACKGROUND_GRADIENT",
    "SWT.COLOR_TITLE_INACTIVE_FOREGROUND",
    "SWT.COLOR_WIDGET_BACKGROUND",
    "SWT.COLOR_WIDGET_BORDER",
    "SWT.COLOR_WIDGET_DARK_SHADOW",
    "SWT.COLOR_WIDGET_FOREGROUND",
    "SWT.COLOR_WIDGET_HIGHLIGHT_SHADOW",
    "SWT.COLOR_WIDGET_LIGHT_SHADOW",
    "SWT.COLOR_WIDGET_NORMAL_SHADOW",
    ];
