#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet7"
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
 *     Thomas Demmer <t_demmer AT web DOT de>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet7;

/*
 * example snippet: create a table (lazy)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableItem;

import java.lang.all;

import T = core.thread;
import std.conv;

void main () {
    Display display = new Display ();
    Image image = new Image (display, 16, 16);
    GC gc = new GC (image);
    gc.setBackground (display.getSystemColor (SWT.COLOR_RED));
    gc.fillRectangle (image.getBounds ());
    gc.dispose ();

    Shell shell = new Shell (display);
    shell.setText ("Lazy Table");
    shell.setLayout (new FillLayout ());
    Table table = new Table (shell, SWT.BORDER | SWT.MULTI);
    table.setSize (200, 200);
    T.Thread thread = new T.Thread({
        for(int i=0; i< 20000; i++){
            if (table.isDisposed ()) return;

            int [] index =  [i];
            display.syncExec (new class Runnable{
                public void run () {
                    if (table.isDisposed ()) return;
                    TableItem item = new TableItem (table, SWT.NONE);
                    item.setText ("Table Item " ~ to!(String)(index [0]));
                    item.setImage (image);
                }
        });
        }
    });

    thread.start ();
    shell.setSize (200, 200);
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    image.dispose ();
    display.dispose ();
}
