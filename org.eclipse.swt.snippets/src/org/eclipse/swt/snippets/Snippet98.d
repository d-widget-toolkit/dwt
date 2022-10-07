#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet98"
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
module org.eclipse.swt.snippets.Snippet98;

/*
 * Composite example snippet: create and dispose children of a composite
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableItem;

import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

void main() {
    int pageNum = 0;
    Composite pageComposite;

    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new GridLayout());
    Button button = new Button(shell, SWT.PUSH);
    button.setText("Push");
    pageComposite = new Composite(shell, SWT.NONE);
    pageComposite.setLayout(new GridLayout());
    pageComposite.setLayoutData(new GridData());

    button.addListener(SWT.Selection, new class Listener{
        public void handleEvent(Event event) {
            if ((pageComposite !is null) && (!pageComposite.isDisposed())) {
                pageComposite.dispose();
            }
            pageComposite = new Composite(shell, SWT.NONE);
            pageComposite.setLayout(new GridLayout());
            pageComposite.setLayoutData(new GridData());
            if (pageNum++ % 2 == 0) {
                Table table = new Table(pageComposite, SWT.BORDER);
                table.setLayoutData(new GridData());
                for (int i = 0; i < 5; i++) {
                    (new TableItem(table, SWT.NONE)).setText("table item " ~ to!(String)(i));
                }
            } else {
                (new Button(pageComposite, SWT.RADIO)).setText("radio");
            }
            shell.layout(true);
        }
    });

    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    display.dispose();
}
