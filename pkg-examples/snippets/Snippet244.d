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

module org.eclipse.swt.snippets.Snippet244;
/*
 * StyledText snippet: Draw a box around text.
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
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Point;

import java.lang.all;
version(JIVE){
    import jive.stacktrace;
}

void main() {
    const String SEARCH_STRING = "box";
    Display display = new Display();
    Color RED = display.getSystemColor(SWT.COLOR_RED);
    Shell shell = new Shell(display);
    shell.setBounds(10,10,250,250);
    StyledText text = new StyledText(shell, SWT.NONE);
    text.setBounds(10,10,200,200);

    void onPaint(Event event) {
        String contents = text.getText();
        int stringWidth = event.gc.stringExtent(SEARCH_STRING).x;
        int lineHeight = text.getLineHeight();
        event.gc.setForeground(RED);
        int index = contents.indexOf(SEARCH_STRING);
        while (index != -1) {
            Point topLeft = text.getLocationAtOffset(index);
            event.gc.drawRectangle(topLeft.x - 1, topLeft.y, stringWidth + 1, lineHeight - 1);
            index = contents.indexOf(SEARCH_STRING, index + 1);
        }
    }

    text.addListener(SWT.Paint, dgListener(&onPaint));

    text.setText("This demonstrates drawing a box\naround every occurrence of the word\nbox in the StyledText");
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}
