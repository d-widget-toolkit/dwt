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
module org.eclipse.swt.snippets.Snippet68;
 
/*
 * Display example snippet: stop a repeating timer when a button is pressed
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;

import org.eclipse.swt.layout.RowData;
import org.eclipse.swt.layout.RowLayout;

void main () {
    Display display = new Display ();
    Color red = display.getSystemColor (SWT.COLOR_RED);
    Color blue = display.getSystemColor (SWT.COLOR_BLUE);
    Shell shell = new Shell (display);
    shell.setLayout (new RowLayout ());
    Button button = new Button (shell, SWT.PUSH);
    button.setText ("Stop Timer");
    Label label = new Label (shell, SWT.BORDER);
    label.setBackground (red);
    int time = 500;
    Runnable timer;
    timer = dgRunnable({
        if (label.isDisposed ()) return;
        Color color = label.getBackground ().opEquals (red) ? blue : red;
        label.setBackground (color);
        display.timerExec (time, timer);
    });
    display.timerExec (time, timer);
    button.addListener (SWT.Selection, dgListener( (Event event) {
       display.timerExec (-1, timer);
    }));
    button.pack ();
    label.setLayoutData (new RowData (button.getSize ()));
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}

