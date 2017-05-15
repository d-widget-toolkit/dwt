/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module org.eclipse.swt.snippets.Snippet293;

/*
 * create a tri-state button.
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Button;

void main() {
    auto display = new Display();
    auto shell = new Shell(display);
    shell.setLayout(new GridLayout());

    auto b1 = new Button (shell, SWT.CHECK);
    b1.setText("State 1");
    b1.setSelection(true);

    auto b2 = new Button (shell, SWT.CHECK);
    b2.setText("State 2");
    b2.setSelection(false);

    auto b3 = new Button (shell, SWT.CHECK);
    b3.setText("State 3");
    b3.setSelection(true);

    // This function does not appear in the api for swt 3.3
    b3.setGrayed(true);

    shell.pack();
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    display.dispose();
}
