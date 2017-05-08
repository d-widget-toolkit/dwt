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
module org.eclipse.swt.snippets.Snippet250;

/*
 * DateTime example snippet: create a DateTime calendar and a DateTime time.
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.DateTime;
import org.eclipse.swt.widgets.Display;
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
    shell.setLayout (new RowLayout ());

    DateTime calendar = new DateTime (shell, SWT.CALENDAR);
    calendar.addSelectionListener (new class SelectionAdapter{
        override
        void widgetSelected (SelectionEvent e) {
            version(Tango){
                Stdout("calendar date changed\n");
                Stdout.flush();
            } else { // Phobos
                writeln("calendar date changed");
            }
        }
    });

    DateTime time = new DateTime (shell, SWT.TIME);
    time.addSelectionListener (new class SelectionAdapter{
        override
        void widgetSelected (SelectionEvent e) {
            version(Tango){
                Stdout("time changed\n");
                Stdout.flush();
            } else { // Phobos
                writeln("time changed");
            }
        }
    });

    shell.pack ();
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}

