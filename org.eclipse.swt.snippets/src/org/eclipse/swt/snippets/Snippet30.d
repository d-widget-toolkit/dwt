#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet30"
    dependency "dwt" path="../../../../../../"
    lflags "/subsystem:console:4" platform="x86_omf"
    libs \
        "atk-1.0" \
        "fontconfig" \
        "gdk-x11-2.0" \
        "gio-2.0" \
        "glib-2.0" \
        "gobject-2.0" \
        "gthread-2.0" \
        "gtk-x11-2.0" \
        "pango" \
        "X11" \
        "Xrender" \
        "Xtst" \
        platform="linux"
+/
/*******************************************************************************
 * Copyright (c) 2000, 2009 IBM Corporation and others.
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
module org.eclipse.swt.snippets.Snippet30;

/*
 * Program example snippet: invoke the system editor on a new file.
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.program.all;
import org.eclipse.swt.widgets.all;

void main(string[] args) {
    Display display = new Display();
    Program p = Program.findProgram(".txt");
    if (p !is null) p.execute("newfile");
    display.dispose();
}
