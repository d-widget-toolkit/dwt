#!/usr/bin/env dub
/+
dub.sdl:
    name "snippet290"
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
 * Copyright (c) 2000, 2006 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * D Port:
 *     Bill Baxter <wbaxter> at gmail com
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet290;

/* 
 * Canvas snippet: ignore 2nd mouse up event after double-click
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */

import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseAdapter;

version(Tango){
    import tango.io.Stdout;
} else { // Phobos
    import std.stdio;
}

void main() {
	Display display = new Display();
	Shell shell = new Shell(display);
	shell.addMouseListener(new class MouseAdapter {
		override
		public void mouseUp(MouseEvent e) {
			if (e.count == 1) {
				version(Tango){
					Stdout("Mouse up").newline;
				} else { // Phobos
					writeln("Mouse up");
				}
			}
		}
		override
		public void mouseDoubleClick(MouseEvent e) {
			version(Tango){
				Stdout("Double-click").newline;
			} else { // Phobos
				writeln("Double-click");
			}
		}
	});
	shell.setBounds(10, 10, 200, 200);
	shell.open ();
	while (!shell.isDisposed()) {
		if (!display.readAndDispatch()) display.sleep();
	}
	display.dispose();
}

