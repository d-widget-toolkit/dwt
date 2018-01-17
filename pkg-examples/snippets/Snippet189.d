/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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

module org.eclipse.swt.snippets.Snippet189;

/*
 * Text with underline and strike through
 * 
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 * 
 * @since 3.1
 */

import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.custom.StyleRange;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;

void main () {
    auto display = new Display ();
    auto shell = new Shell (display);
    shell.setText("StyledText with underline and strike through");
    shell.setLayout(new FillLayout());
    auto text = new StyledText (shell, SWT.BORDER);
    text.setText("0123456789 ABCDEFGHIJKLM NOPQRSTUVWXYZ");
    // make 0123456789 appear underlined
    auto style1 = new StyleRange();
    style1.start = 0;
    style1.length = 10;
    style1.underline = true;
    text.setStyleRange(style1);
    // make ABCDEFGHIJKLM have a strike through
    auto style2 = new StyleRange();
    style2.start = 11;
    style2.length = 13;
    style2.strikeout = true;
    text.setStyleRange(style2);
    // make NOPQRSTUVWXYZ appear underlined and have a strike through
    auto style3 = new StyleRange();
    style3.start = 25;
    style3.length = 13;
    style3.underline = true;
    style3.strikeout = true;
    text.setStyleRange(style3);
    shell.pack();
    shell.open();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
