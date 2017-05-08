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
module org.eclipse.swt.snippets.Snippet60;

/*
 * Display example snippet: create two one shot timers (5000 ms, 2000 ms)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;

version(Tango){
    import tango.io.Stdout;
    void writeln(in char[] line) {
        Stdout(line)("\n").flush();
    }
} else { // Phobos
    import std.stdio;
}

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    shell.setSize (200, 200);
    shell.open ();
    display.timerExec (5000, dgRunnable({
        writeln("5000");
    }));
    display.timerExec (2000, dgRunnable({
        writeln("2000");
    }));
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}

