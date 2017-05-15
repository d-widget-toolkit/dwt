/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Jesse Phillips <Jesse.K.Phillips+D> gmail.com
 *******************************************************************************/

module org.eclipse.swt.snippets.Snippet163;

/*
 * Setting the font style, foreground and background colors of StyledText
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.custom.StyleRange;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;

version(JIVE){
    import jive.stacktrace;
}

void main() {
    auto display = new Display();
    auto shell = new Shell(display);
    shell.setLayout(new FillLayout());
    auto text = new StyledText (shell, SWT.BORDER);
    text.setText("0123456789 ABCDEFGHIJKLM NOPQRSTUVWXYZ");
    // make 0123456789 appear bold
    auto style1 = new StyleRange();
    style1.start = 0;
    style1.length = 10;
    style1.fontStyle = SWT.BOLD;
    text.setStyleRange(style1);
    // make ABCDEFGHIJKLM have a red font
    auto style2 = new StyleRange();
    style2.start = 11;
    style2.length = 13;
    style2.foreground = display.getSystemColor(SWT.COLOR_RED);
    text.setStyleRange(style2);
    // make NOPQRSTUVWXYZ have a blue background
    auto style3 = new StyleRange();
    style3.start = 25;
    style3.length = 13;
    style3.background = display.getSystemColor(SWT.COLOR_BLUE);
    text.setStyleRange(style3);

    shell.pack();
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    display.dispose();
}
