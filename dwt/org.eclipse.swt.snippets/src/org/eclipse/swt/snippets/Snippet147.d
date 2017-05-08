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
module org.eclipse.swt.snippets.Snippet147;
/*
 * Combo example snippet: stop CR from going to the default button
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.TraverseListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Combo;
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

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new GridLayout());
    Combo combo = new Combo(shell, SWT.NONE);
    combo.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
    combo.setText("Here is some text");
    combo.addSelectionListener(new class SelectionAdapter{
        override
        public void widgetDefaultSelected(SelectionEvent e) {
            writeln("Combo default selected (overrides default button)");
        }
    });
    combo.addTraverseListener(new class TraverseListener{
        public void keyTraversed(TraverseEvent e) {
            if (e.detail == SWT.TRAVERSE_RETURN) {
                e.doit = false;
                e.detail = SWT.TRAVERSE_NONE;
            }
        }
    });
    Button button = new Button(shell, SWT.PUSH);
    button.setText("Ok");
    button.addSelectionListener(new class SelectionAdapter{
        override
        public void widgetSelected(SelectionEvent e) {
            writeln("Button selected");
        }
    });
    shell.setDefaultButton(button);
    shell.pack();
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    display.dispose();
}

