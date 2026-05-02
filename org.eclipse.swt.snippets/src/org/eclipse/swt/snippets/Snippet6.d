#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet6"
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
module org.eclipse.swt.snippets.Snippet6;

/*
 * GridLayout example snippet: insert widgets into a grid layout
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.all;
import org.eclipse.swt.layout.all;
import org.eclipse.swt.widgets.all;

void main(string[] args) {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new GridLayout());
    Composite c = new Composite(shell, SWT.NONE);
    GridLayout layout = new GridLayout();
    layout.numColumns = 3;
    c.setLayout(layout);
    for (int i = 0; i < 10; i++) {
        Button b = new Button(c, SWT.PUSH);
        b.setText("Button " ~ i.toString);
    }

    Button b = new Button(shell, SWT.PUSH);
    b.setText("add a new button at row 2 column 1");
    int[] index = new int[1];
    b.addListener(SWT.Selection, new class Listener {
        override void handleEvent (Event e) {
            Button s = new Button(c, SWT.PUSH);
            s.setText("Special " ~ index[0].toString);
            index[0]++;
            Control[] children = c.getChildren();
            s.moveAbove(children[3]);
            shell.layout([s]);
        }
    });

    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}
