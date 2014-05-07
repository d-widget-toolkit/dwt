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

module org.eclipse.swt.snippets.Snippet218;
/*
 * SWT StyledText snippet: use gradient background.
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
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.graphics.FontData;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;

import java.lang.all;

version(Tango){
    import Math = tango.math.Math;
} else { // Phobos
    import Math = std.algorithm;
}

version(JIVE){
    import jive.stacktrace;
}

void main() {
    static String text = "Plans do not materialize out of nowhere, nor are they entirely static. To ensure the planning process is "
        "transparent and open to the entire Eclipse community, we (the Eclipse PMC) post plans in an embryonic "
        "form and revise them throughout the release cycle. \n"
        "The first part of the plan deals with the important matters of release deliverables, release milestones, target "
        "operating environments, and release-to-release compatibility. These are all things that need to be clear for "
        "any release, even if no features were to change.  \n";
    static Image oldImage;


    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());
    StyledText styledText = new StyledText(shell, SWT.WRAP | SWT.BORDER);
    styledText.setText(text);
    FontData data = display.getSystemFont().getFontData()[0];
    Font font = new Font(display, data.getName(), 16f, SWT.BOLD);
    styledText.setFont(font);
    styledText.setForeground(display.getSystemColor (SWT.COLOR_BLUE));

    void onResize (Event event) {
        Rectangle rect = styledText.getClientArea ();
        Image newImage = new Image (display, 1, Math.max (1, rect.height));
        GC gc = new GC (newImage);
        gc.setForeground (display.getSystemColor (SWT.COLOR_WHITE));
        gc.setBackground (display.getSystemColor (SWT.COLOR_YELLOW));
        gc.fillGradientRectangle (rect.x, rect.y, 1, rect.height, true);
        gc.dispose ();
        styledText.setBackgroundImage (newImage);
        if (oldImage !is null) oldImage.dispose ();
        oldImage = newImage;
    }

    styledText.addListener (SWT.Resize, dgListener(&onResize));

    shell.setSize(700, 400);
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    if (oldImage !is null) oldImage.dispose ();
    font.dispose();
    display.dispose();
}
