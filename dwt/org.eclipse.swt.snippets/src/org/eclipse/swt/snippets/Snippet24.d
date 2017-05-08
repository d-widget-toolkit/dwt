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
module org.eclipse.swt.snippets.Snippet24;

/*
 * example snippet: detect CR in a text or combo control (default selection)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.layout.RowLayout;

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
    Display display = new Display ();
    Shell shell = new Shell (display);
    shell.setLayout (new RowLayout ());
    Combo combo = new Combo (shell, SWT.NONE);
    combo.setItems (["A-1", "B-1", "C-1"]);
    Text text = new Text (shell, SWT.SINGLE | SWT.BORDER);
    text.setText ("some text");
    combo.addListener (SWT.DefaultSelection, new class Listener{
        public void handleEvent (Event e) {
            writeln(e.widget.toString() ~ " - Default Selection");
        }
    });
    text.addListener (SWT.DefaultSelection, new class Listener{
        public void handleEvent (Event e) {
            writeln(e.widget.toString() ~ " - Default Selection");
        }
    });
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
