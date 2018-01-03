#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet276"
    dependency "dwt" path="../../../../../../"
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
 * Copyright (c) 2000, 2007 IBM Corporation and others.
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
module org.eclipse.swt.snippets.Snippet276;

/*
 * Display snippet: map from control-relative to display-relative coordinates
 * 
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;

import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;
version(Tango){
    import tango.io.Stdout;
} else { // Phobos
    import std.stdio;
}

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    shell.setBounds (200, 200, 400, 400);
    Label label = new Label (shell, SWT.NONE);
    label.setText ("click in shell to print display-relative coordinate");
    Listener listener = dgListener( (Event event) {
        Point point = new Point (event.x, event.y);
        version(Tango){
            Stdout(display.map (cast(Control)event.widget, null, point)).newline().flush();
        } else { // Phobos
            writeln(display.map (cast(Control)event.widget, null, point));
        }
    });
    shell.addListener (SWT.MouseDown, listener);
    label.addListener (SWT.MouseDown, listener);
    label.pack ();
    shell.open ();
    while (!shell.isDisposed ()){
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}

