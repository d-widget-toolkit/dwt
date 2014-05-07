/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html37
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * D Port:
 *     Thomas Demmer <t_demmer AT web DOT de>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet269;

/*
 * Combo example snippet: set the caret position within a Combo's text
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.layout.FillLayout;

import java.lang.all;

void main() {
    Display display = new Display ();
    Shell shell = new Shell (display);
    shell.setLayout (new FillLayout ());
    Combo combo = new Combo (shell, SWT.NONE);
    combo.add ("item");
    combo.select (0);
    shell.pack ();
    shell.open ();
    int stringLength = combo.getText().length;
    combo.setSelection (new Point (stringLength, stringLength));
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
