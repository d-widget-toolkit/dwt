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
module org.eclipse.swt.snippets.Snippet108;
/*
 * Button example snippet: set the default button
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.layout.RowData;

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
    Label label = new Label (shell, SWT.NONE);
    label.setText ("Enter your name:");
    Text text = new Text (shell, SWT.BORDER);
    text.setLayoutData (new RowData (100, SWT.DEFAULT));
    Button ok = new Button (shell, SWT.PUSH);
    ok.setText ("OK");
    ok.addSelectionListener(new class SelectionAdapter {
        override
        public void widgetSelected(SelectionEvent e) {
            writeln("OK");
        }
    });
    Button cancel = new Button (shell, SWT.PUSH);
    cancel.setText ("Cancel");
    cancel.addSelectionListener(new class SelectionAdapter {
        override
        public void widgetSelected(SelectionEvent e) {
            writeln("Cancel");
        }
    });
    shell.setDefaultButton (cancel);
    shell.setLayout (new RowLayout ());
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}

