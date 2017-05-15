/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Ported to the D Programming Language
 *     John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module Snippet136;

/*
 * Browser example snippet: render HTML from memory
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 * 
 * @since 3.0
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.SWTException;

import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.layout.FillLayout;

import java.lang.all;

version(Tango){
    import tango.io.Console;
} else { // Phobos
    import std.stdio;
}

version(linux) {
    version(build)
    {
    pragma(link, "stdc++");
    pragma(link, "xpcomglue");
    }
}

void main() {
		String html = "<HTML><HEAD><TITLE>HTML Test</TITLE></HEAD><BODY>";
		for (int i = 0; i < 100; i++) html ~= "<P>This is line </P>";
		html ~= "</BODY></HTML>";

		Display display = new Display();
		Shell shell = new Shell(display);
		shell.setLayout(new FillLayout());
		Browser browser;
		try {
			browser = new Browser(shell, SWT.NONE);
		} catch (SWTError e) {
			version(Tango){
				Cout("Could not instatiate Browser.").newline;
			} else { // Phobos
				writeln("Could not instatiate Browser.");
			}
			return;
		}
		browser.setText(html);
		shell.open();
		while (!shell.isDisposed()) {
			if (!display.readAndDispatch())
				display.sleep();
		}
		display.dispose();
}


