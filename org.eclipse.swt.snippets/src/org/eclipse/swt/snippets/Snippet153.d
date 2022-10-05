#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet153"
    dependency "dwt" path="../../../../../../"
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
module org.eclipse.swt.snippets.Snippet153;

/*
 * ToolBar example snippet: update a status line when the pointer enters a ToolItem
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseMoveListener;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.ToolItem;
import org.eclipse.swt.widgets.Label;
import java.lang.all;

void main() {
    String statusText = "";
    
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setBounds(10, 10, 200, 200);
    ToolBar bar = new ToolBar(shell, SWT.BORDER);
    bar.setBounds(10, 10, 170, 50);
    Label statusLine = new Label(shell, SWT.BORDER);
    statusLine.setBounds(10, 90, 170, 30);
    (new ToolItem(bar, SWT.NONE)).setText("item 1");
    (new ToolItem(bar, SWT.NONE)).setText("item 2");
    (new ToolItem(bar, SWT.NONE)).setText("item 3");
    bar.addMouseMoveListener(new class MouseMoveListener {
        void mouseMove(MouseEvent e) {
            ToolItem item = bar.getItem(new Point(e.x, e.y));
            String name = "";
            if (item !is null) {
                name = item.getText();
            }
            if (statusText != name) {
                statusLine.setText(name);
                statusText = name;
            }
        }
    });
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}

