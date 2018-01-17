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
module org.eclipse.swt.snippets.Snippet251;

/*
 * DateTime example snippet: create a DateTime calendar, date, and time in a dialog.
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.DateTime;
import org.eclipse.swt.widgets.Dialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;

version(Tango){
    import tango.io.Stdout;
} else { // Phobos
    import std.stdio;
}

void main () {
    /* These cannot be local in the
     * listener, hence we put it here and not at the
     * constructor. (THD)
     * (dmd.1.028)
     */
    DateTime calendar, date, time;
    Shell dialog;

    Display display = new Display ();
    Shell shell = new Shell (display);
    shell.setLayout(new FillLayout());

    Button open = new Button (shell, SWT.PUSH);
    open.setText ("Open Dialog");
    open.addSelectionListener (new class SelectionAdapter{
        override
        public void widgetSelected (SelectionEvent e) {
            dialog = new Shell (shell, SWT.DIALOG_TRIM);
            dialog.setLayout (new GridLayout (3, false));

            calendar = new DateTime (dialog, SWT.CALENDAR | SWT.BORDER);
            date = new DateTime (dialog, SWT.DATE | SWT.SHORT);
            time = new DateTime (dialog, SWT.TIME | SWT.SHORT);

            new Label (dialog, SWT.NONE);
            new Label (dialog, SWT.NONE);
            Button ok = new Button (dialog, SWT.PUSH);
            ok.setText ("OK");
            ok.setLayoutData(new GridData (SWT.FILL, SWT.CENTER, false, false));
            ok.addSelectionListener (new class SelectionAdapter{
                override
                void widgetSelected (SelectionEvent e) {
                    version(Tango){
                        Stdout.formatln("Calendar date selected (MM/DD/YYYY) = {:d02}/{:d02}/{:d04}",
                                        (calendar.getMonth () + 1),calendar.getDay (),calendar.getYear ());
                        Stdout.formatln("Date selected (MM/YYYY)= {:d02}/{:d04}",
                                        (date.getMonth () + 1), date.getYear ());
                        Stdout.formatln("Time selected (HH:MM) = {:d02}:{:d02}",
                                        time.getHours(), time.getMinutes());
                        Stdout.flush();
                    } else { // Phobos
                        writefln("Calendar date selected (MM/DD/YYYY) = %02d/%02d/%04d",
                                 (calendar.getMonth () + 1),calendar.getDay (),calendar.getYear ());
                        writefln("Date selected (MM/YYYY)= %02d/%04d",
                                 (date.getMonth () + 1), date.getYear ());
                        writefln("Time selected (HH:MM) = %02d:%02d",
                                 time.getHours(), time.getMinutes());
                    }
                    dialog.close ();
                }
            });
            dialog.setDefaultButton (ok);
            dialog.pack ();
            dialog.open ();
        }
    });
    shell.pack ();
    shell.open ();

    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}

