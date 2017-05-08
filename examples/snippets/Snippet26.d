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
 *     Jesse Phillips <Jesse.K.Phillips+D> gmail.com
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet26;

/*
 * Combo example snippet: create a combo box (non-editable)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Combo;
import java.lang.all;

String[] content = ["A", "B", "C"];

void main () {
    auto display = new Display ();
    auto shell = new Shell (display);
    auto combo = new Combo (shell, SWT.READ_ONLY);
    combo.setItems (content);
    combo.setSize (200, 200);

    shell.pack ();
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
