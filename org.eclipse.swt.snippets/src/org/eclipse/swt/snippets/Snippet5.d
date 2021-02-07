#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet5"
    dependency "dwt" path="../../../../../../" version="*"
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
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module org.eclipse.swt.snippets.Snippet5;

/*
 * ScrolledComposite example snippet: scroll a control in a scrolled composite
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.all;
import org.eclipse.swt.custom.all;
import org.eclipse.swt.layout.all;
import org.eclipse.swt.widgets.all;

void main(string[] args) {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());

    // this button is always 400 x 400. Scrollbars appear if the window is resized to be
    // too small to show part of the button
    ScrolledComposite c1 = new ScrolledComposite(shell, SWT.BORDER | SWT.H_SCROLL | SWT.V_SCROLL);
    Button b1 = new Button(c1, SWT.PUSH);
    b1.setText("fixed size button");
    b1.setSize(400, 400);
    c1.setContent(b1);

    // this button has a minimum size of 400 x 400. If the window is resized to be big
    // enough to show more than 400 x 400, the button will grow in size. If the window
    // is made too small to show 400 x 400, scrollbars will appear.
    ScrolledComposite c2 = new ScrolledComposite(shell, SWT.BORDER | SWT.H_SCROLL | SWT.V_SCROLL);
    Button b2 = new Button(c2, SWT.PUSH);
    b2.setText("expanding button");
    c2.setContent(b2);
    c2.setExpandHorizontal(true);
    c2.setExpandVertical(true);
    c2.setMinSize(400, 400);

    shell.setSize(600, 300);
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}
