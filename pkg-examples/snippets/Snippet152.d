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
module org.eclipse.swt.snippets.Snippet152;

/*
 * Control example snippet: update a status line when an item is armed
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 * 
 * @since 3.0
 */

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.swt.layout.FormLayout;
import org.eclipse.swt.layout.FormData;
import org.eclipse.swt.layout.FormAttachment;
import java.lang.all;

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    FormLayout layout = new FormLayout();
    shell.setLayout(layout);
    Label label = new Label(shell, SWT.BORDER);
    Listener armListener = new class Listener {
        public void handleEvent(Event event) {
            MenuItem item = cast(MenuItem) event.widget;
            label.setText(item.getText());
            label.update();
        }
    };
    Listener showListener = new class Listener {
        public void handleEvent(Event event) {
            Menu menu = cast(Menu) event.widget;
            MenuItem item = menu.getParentItem();
            if (item !is null) {
                label.setText(item.getText());
                label.update();
            }
        }
    };
    Listener hideListener = new class Listener {
        public void handleEvent(Event event) {
            label.setText("");
            label.update();
        }
    };
    FormData labelData = new FormData();
    labelData.left = new FormAttachment(0);
    labelData.right = new FormAttachment(100);
    labelData.bottom = new FormAttachment(100);
    label.setLayoutData(labelData);
    Menu menuBar = new Menu(shell, SWT.BAR);
    shell.setMenuBar(menuBar);
    MenuItem fileItem = new MenuItem(menuBar, SWT.CASCADE);
    fileItem.setText("File");
    fileItem.addListener(SWT.Arm, armListener);
    MenuItem editItem = new MenuItem(menuBar, SWT.CASCADE);
    editItem.setText("Edit");
    editItem.addListener(SWT.Arm, armListener);
    Menu fileMenu = new Menu(shell, SWT.DROP_DOWN);
    fileMenu.addListener(SWT.Hide, hideListener);
    fileMenu.addListener(SWT.Show, showListener);
    fileItem.setMenu(fileMenu);
    String[] fileStrings = [ "New", "Close", "Exit" ];
    for (int i = 0; i < fileStrings.length; i++) {
        MenuItem item = new MenuItem(fileMenu, SWT.PUSH);
        item.setText(fileStrings[i]);
        item.addListener(SWT.Arm, armListener);
    }
    Menu editMenu = new Menu(shell, SWT.DROP_DOWN);
    editMenu.addListener(SWT.Hide, hideListener);
    editMenu.addListener(SWT.Show, showListener);
    String[] editStrings = [ "Cut", "Copy", "Paste" ];
    editItem.setMenu(editMenu);
    for (int i = 0; i < editStrings.length; i++) {
        MenuItem item = new MenuItem(editMenu, SWT.PUSH);
        item.setText(editStrings[i]);
        item.addListener(SWT.Arm, armListener);
    }
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}
