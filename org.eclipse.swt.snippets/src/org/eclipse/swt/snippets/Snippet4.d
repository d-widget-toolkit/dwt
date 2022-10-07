#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet4"
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
 *     Lars Vogel <Lars.Vogel@vogella.com> - Bug 502845
 * D Port:
 *     alice <stigma@disroot.org>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet4;

/*
 * Shell example snippet: prevent escape from closing a dialog
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.events.SelectionAdapter;

import org.eclipse.swt.all;
import org.eclipse.swt.graphics.all;
import org.eclipse.swt.widgets.all;

void main(string[] args) {
    Display display = new Display();
    Shell shell = new Shell(display);
    Button b = new Button(shell, SWT.PUSH);
    b.setText("Open Dialog ...");
    b.pack();
    Rectangle clientArea = shell.getClientArea();
    b.setLocation(clientArea.x + 10, clientArea.y + 10);
    b.addSelectionListener(new class SelectionAdapter {
        override void widgetSelected(SelectionEvent e) {
            Shell dialog = new Shell(shell, SWT.DIALOG_TRIM);
            dialog.addTraverseListener(new class TraverseListener {
                override void keyTraversed(TraverseEvent t) {
                    if (t.detail == SWT.TRAVERSE_ESCAPE) {
                        t.doit = false;
                    }
                }
            });
            dialog.open();
        }
        override void widgetDefaultSelected(SelectionEvent e) {}
    });
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}
