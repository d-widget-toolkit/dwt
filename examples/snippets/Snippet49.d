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
module org.eclipse.swt.snippets.Snippet49;

/*
 * ToolBar example snippet: create tool bar (wrap on resize)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.ToolItem;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

void main () {
	Display display = new Display ();
	Shell shell = new Shell (display);
	ToolBar toolBar = new ToolBar (shell, SWT.WRAP);
	for (int i=0; i<12; i++) {
		ToolItem item = new ToolItem (toolBar, SWT.PUSH);
		item.setText ("Item " ~ to!(String)(i));
	}
	shell.addListener (SWT.Resize, new class Listener {
		void handleEvent (Event e) {
			Rectangle rect = shell.getClientArea ();
			Point size = toolBar.computeSize (rect.width, SWT.DEFAULT);
			toolBar.setSize (size);
		}
	});
	toolBar.pack ();
	shell.pack ();
	shell.open ();
	while (!shell.isDisposed ()) {
		if (!display.readAndDispatch ()) display.sleep ();
	}
	display.dispose ();
}

