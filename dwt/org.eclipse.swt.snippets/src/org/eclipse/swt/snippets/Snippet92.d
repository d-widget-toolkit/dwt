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
module org.eclipse.swt.snippets.Snippet92;

/*
 * Cursor example snippet: create a cursor from a source and a mask
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.PaintEvent;
import org.eclipse.swt.events.PaintListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;


void main () {
    Display display = new Display();
    Color white = display.getSystemColor (SWT.COLOR_WHITE);
    Color black = display.getSystemColor (SWT.COLOR_BLACK);

    //Create a source ImageData of depth 1 (monochrome)
    PaletteData palette = new PaletteData ([white.getRGB(), black.getRGB()]);
    ImageData sourceData = new ImageData (20, 20, 1, palette);
    for (int i = 0; i < 10; i ++) {
        for (int j = 0; j < 20; j++) {
            sourceData.setPixel(i, j, 1);
        }
    }

    //Create a mask ImageData of depth 1 (monochrome)
    palette = new PaletteData ([white.getRGB(), black.getRGB()]);
    ImageData maskData = new ImageData (20, 20, 1, palette);
    for (int i = 0; i < 20; i ++) {
        for (int j = 0; j < 10; j++) {
            maskData.setPixel(i, j, 1);
        }
    }
    //Create cursor
    Cursor cursor = new Cursor(display, sourceData, maskData, 10, 10);

    Shell shell = new Shell(display);
    Image source = new Image (display,sourceData);
    Image mask = new Image (display, maskData);
    //Draw source and mask just to show what they look like
    shell.addPaintListener(new class PaintListener{
        void paintControl(PaintEvent e) {
            GC gc = e.gc;
            gc.drawString("source: ", 10, 10);
            gc.drawImage(source, 0, 0, 20, 20, 60, 10, 20, 20);
            gc.drawString("mask: ",10, 40);
            gc.drawImage(mask, 0, 0, 20, 20, 60, 40, 20, 20);
        }
    });
    shell.setSize(150, 150);
    shell.open();
    shell.setCursor(cursor);

    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    cursor.dispose();
    source.dispose();
    mask.dispose();
    display.dispose();
}

