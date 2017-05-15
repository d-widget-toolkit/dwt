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
 *     Thomas Demmer <t_demmer AT web DOT de>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet247;

/*
 * Control example snippet: allow a multi-line text to process the default button
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.TraverseEvent;
import org.eclipse.swt.events.TraverseListener;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.layout.RowLayout;

import java.lang.all;

version(Tango){
    import tango.io.Stdout;
} else { // Phobos
    import std.stdio;
}

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    shell.setLayout(new RowLayout());
    Text text = new Text(shell, SWT.MULTI | SWT.BORDER);
    String modifier = SWT.MOD1 == SWT.CTRL ? "Ctrl" : "Command";
    text.setText("Hit " ~ modifier ~ "+Return\nto see\nthe default button\nrun");
    text.addTraverseListener(new class TraverseListener{
        public void keyTraversed(TraverseEvent e) {
          switch (e.detail) {
          case SWT.TRAVERSE_RETURN:
              if ((e.stateMask & SWT.MOD1) != 0) e.doit = true;
              break;
          default:
              break;
          }
        }
    });
    Button button = new Button (shell, SWT.PUSH);
    button.pack();
    button.setText("OK");
    button.addSelectionListener(new class SelectionAdapter{
        override
        public void widgetSelected(SelectionEvent e) {
            version(Tango){
                Stdout("OK selected\n");
                Stdout.flush();
            } else {
                writeln("OK selected");
            }
        }
    });
    shell.setDefaultButton(button);
    shell.pack ();
    shell.open();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
