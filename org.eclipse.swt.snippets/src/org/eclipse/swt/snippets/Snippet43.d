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
 *     Thomas Demmer <t_demmer AT web DOT de>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet43;
/*
 * Caret example snippet: create a caret (using an image)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;

import org.eclipse.swt.widgets.Caret;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;

import java.lang.all;

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    Caret caret = new Caret (shell, SWT.NONE);
    Color white = display.getSystemColor (SWT.COLOR_WHITE);
    Color black = display.getSystemColor (SWT.COLOR_BLACK);
    Image image = new Image (display, 20, 20);
    GC gc = new GC (image);
    gc.setBackground (black);
    gc.fillRectangle (0, 0, 20, 20);
    gc.setForeground (white);
    gc.drawLine (0, 0, 19, 19);
    gc.drawLine (19, 0, 0, 19);
    gc.dispose ();
    caret.setLocation (10, 10);
    caret.setImage (image);
    caret.setVisible (true);
    shell.addListener(SWT.Paint, new class Listener {
        public void handleEvent(Event event) {
            GC gc = event.gc;
            gc.drawImage (image, 10, 64);
            gc.drawString ("Test", 12, 12);
        }
    });
    shell.open ();
     
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    image.dispose ();
    display.dispose ();
}
