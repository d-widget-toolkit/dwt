#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet1"
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
 * Copyright (c) 2000, 2012 IBM Corporation and others.
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
module org.eclipse.swt.snippets.Snippet1;

/*
 * example snippet: Hello World
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;

void main(string[] args) {
    Display display = new Display;
    Shell shell = new Shell(display);
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}
