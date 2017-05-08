/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet45;

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Scale;

import java.lang.all;


void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    Scale scale = new Scale (shell, SWT.BORDER);
    scale.setSize (200, 64);
    scale.setMaximum (40);
    scale.setPageIncrement (5);
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}

