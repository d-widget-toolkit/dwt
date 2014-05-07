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
 *     yidabu at gmail dot com  ( D China http://www.d-programming-language-china.org/ )
 *******************************************************************************/

module org.eclipse.swt.snippets.Snippet213;
/*
 * SWT StyledText snippet: use indent, alignment and justify.
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.2
 */

import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.custom.StyleRange;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;
version(JIVE){
    import jive.stacktrace;
}

void main() {
    static String text =
        "The first paragraph has an indentation of fifty pixels. Indentation is the amount of white space in front of the first line of a paragraph. If this paragraph wraps to several lines you should see the indentation only on the first line.\n\n"
        "The second paragraph is center aligned. Alignment only works when the StyledText is using word wrap. Alignment, as with all other line attributes, can be set for the whole widget or just for a set of lines.\n\n"
        "The third paragraph is justified. Like alignment, justify only works when the StyledText is using word wrap. If the paragraph wraps to several lines, the justification is performed on all lines but the last one.\n\n"
        "The last paragraph is justified and right aligned. In this case, the alignment is only noticeable in the final line.";


    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());
    StyledText styledText = new StyledText(shell, SWT.WRAP | SWT.BORDER);
    styledText.setText(text);
    styledText.setLineIndent(0, 1, 50);
    styledText.setLineAlignment(2, 1, SWT.CENTER);
    styledText.setLineJustify(4, 1, true);
    styledText.setLineAlignment(6, 1, SWT.RIGHT);
    styledText.setLineJustify(6, 1, true);

    shell.setSize(300, 400);
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    display.dispose();

}
