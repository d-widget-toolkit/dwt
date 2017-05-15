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
module org.eclipse.swt.snippets.Snippet118;

/*
 * Cursor example snippet: create a color cursor from an image file
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.0
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.FileDialog;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;

void main () {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setSize(150, 150);
    Cursor[1] cursor;
    Button button = new Button(shell, SWT.PUSH);
    button.setText("Change cursor");
    Point size = button.computeSize(SWT.DEFAULT, SWT.DEFAULT);
    button.setSize(size);
    button.addListener(SWT.Selection, new class Listener{
        public void handleEvent(Event e) {
            FileDialog dialog = new FileDialog(shell);
            dialog.setFilterExtensions(["*.ico", "*.gif", "*.*"]);
            String name = dialog.open();
            if (name is null) return;
            ImageData image = new ImageData(name);
            Cursor oldCursor = cursor[0];
            cursor[0] = new Cursor(display, image, 0, 0);
            shell.setCursor(cursor[0]);
            if (oldCursor !is null) oldCursor.dispose();
        }
    });
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    if (cursor[0] !is null) cursor[0].dispose();
    display.dispose();
}

