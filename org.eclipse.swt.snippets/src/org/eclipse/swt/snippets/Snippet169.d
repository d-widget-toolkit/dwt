#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet169"
    dependency "dwt" path="../../../../../../"
    lflags "/subsystem:console:4" platform="x86_omf"
    libs \
      "atk-1.0" \
      "cairo" \
      "dl" \
      "fontconfig" \
      "gdk-x11-2.0" \
      "gdk_pixbuf-2.0" \
      "glib-2.0" \
      "gmodule-2.0" \
      "gnomeui-2" \
      "gnomevfs-2" \
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
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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
module org.eclipse.swt.snippets.Snippet169;

/*
 * Make a toggle button have radio behavior
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * Port OK.
 */

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.layout.FillLayout;

import java.lang.all;
version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    shell.setLayout (new FillLayout ());
    Listener listener = new class Listener {
        public void handleEvent (Event e) {
            Control [] children = shell.getChildren ();
            for (int i=0; i<children.length; i++) {
                Control child = children [i];
                if (e.widget !is child && cast(Button)child !is null && (child.getStyle () & SWT.TOGGLE) != 0) {
                    (cast(Button) child).setSelection (false);
                }
            }
            (cast(Button) e.widget).setSelection (true);
        }
    };
    for (int i=0; i<20; i++) {
        Button button = new Button (shell, SWT.TOGGLE);
        button.setText ("B" ~to!(String)(i));
        button.addListener (SWT.Selection, listener);
        if (i == 0) button.setSelection (true);
    }
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
