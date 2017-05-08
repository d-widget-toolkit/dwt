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
module org.eclipse.swt.snippets.Snippet224;

/*
 * implement radio behavior for setSelection()
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.2
 */

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.layout.RowLayout;

import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    shell.setLayout (new RowLayout (SWT.VERTICAL));
    for (int i=0; i<8; i++) {
        Button button = new Button (shell, SWT.RADIO);
        button.setText ("B" ~ to!(String)(i));
        if (i == 0) button.setSelection (true);
    }
    Button button = new Button (shell, SWT.PUSH);
    button.setText ("Set Selection to B4");
    button.addListener (SWT.Selection, new class Listener{
        public void handleEvent (Event event) {
            Control [] children = shell.getChildren ();
            Button newButton = cast(Button) children [4];
            for (int i=0; i<children.length; i++) {
                Control child = children [i];
                if ( cast(Button)child !is null && (child.getStyle () & SWT.RADIO) != 0) {
                    (cast(Button)child).setSelection (false);
                }
            }
            newButton.setSelection (true);
        }
    });
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
