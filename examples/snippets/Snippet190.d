/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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
module org.eclipse.swt.snippets.Snippet190;

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Spinner;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.GridLayout;

version(Tango){
    import Math = tango.math.Math;
    import tango.io.Stdout;
} else { // Phobos
    import Math = std.math;
    import std.stdio;
}

/*
 * Floating point values in Spinner
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.1
 */

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    shell.setText("Spinner with float values");
    shell.setLayout(new GridLayout());
    Spinner spinner = new Spinner(shell, SWT.NONE);
    // allow 3 decimal places
    spinner.setDigits(3);
    // set the minimum value to 0.001
    spinner.setMinimum(1);
    // set the maximum value to 20
    spinner.setMaximum(20000);
    // set the increment value to 0.010
    spinner.setIncrement(10);
    // set the seletion to 3.456
    spinner.setSelection(3456);
    spinner.addSelectionListener(new class SelectionAdapter {
        override
        public void widgetSelected(SelectionEvent e) {
            int selection = spinner.getSelection();
            float digits = spinner.getDigits();
            version(Tango){
                Stdout.formatln("Selection is {}", selection / Math.pow(10.f, digits));
            } else { // Phobos
                writefln("Selection is %s", selection / Math.pow(10f, digits));
            }
        }
    });
    shell.setSize(200, 200);
    shell.open();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
