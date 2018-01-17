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
module org.eclipse.swt.snippets.Snippet119;

/*
 * Cursor example snippet: create a color cursor from a source and a mask
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.0
 */
import org.eclipse.swt.SWT;
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



auto srcData = [
        cast(byte)0x11, cast(byte)0x11, cast(byte)0x11, cast(byte)0x00, cast(byte)0x00, cast(byte)0x11, cast(byte)0x11, cast(byte)0x11,
        cast(byte)0x11, cast(byte)0x10, cast(byte)0x00, cast(byte)0x01, cast(byte)0x10, cast(byte)0x00, cast(byte)0x01, cast(byte)0x11,
        cast(byte)0x11, cast(byte)0x00, cast(byte)0x22, cast(byte)0x01, cast(byte)0x10, cast(byte)0x33, cast(byte)0x00, cast(byte)0x11,
        cast(byte)0x10, cast(byte)0x02, cast(byte)0x22, cast(byte)0x01, cast(byte)0x10, cast(byte)0x33, cast(byte)0x30, cast(byte)0x01,
        cast(byte)0x10, cast(byte)0x22, cast(byte)0x22, cast(byte)0x01, cast(byte)0x10, cast(byte)0x33, cast(byte)0x33, cast(byte)0x01,
        cast(byte)0x10, cast(byte)0x22, cast(byte)0x22, cast(byte)0x01, cast(byte)0x10, cast(byte)0x33, cast(byte)0x33, cast(byte)0x01,
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0x01, cast(byte)0x11, cast(byte)0x11, cast(byte)0x01, cast(byte)0x10, cast(byte)0x11, cast(byte)0x11, cast(byte)0x10,
        cast(byte)0x01, cast(byte)0x11, cast(byte)0x11, cast(byte)0x01, cast(byte)0x10, cast(byte)0x11, cast(byte)0x11, cast(byte)0x10,
        cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00, cast(byte)0x00,
        cast(byte)0x10, cast(byte)0x44, cast(byte)0x44, cast(byte)0x01, cast(byte)0x10, cast(byte)0x55, cast(byte)0x55, cast(byte)0x01,
        cast(byte)0x10, cast(byte)0x44, cast(byte)0x44, cast(byte)0x01, cast(byte)0x10, cast(byte)0x55, cast(byte)0x55, cast(byte)0x01,
        cast(byte)0x10, cast(byte)0x04, cast(byte)0x44, cast(byte)0x01, cast(byte)0x10, cast(byte)0x55, cast(byte)0x50, cast(byte)0x01,
        cast(byte)0x11, cast(byte)0x00, cast(byte)0x44, cast(byte)0x01, cast(byte)0x10, cast(byte)0x55, cast(byte)0x00, cast(byte)0x11,
        cast(byte)0x11, cast(byte)0x10, cast(byte)0x00, cast(byte)0x01, cast(byte)0x10, cast(byte)0x00, cast(byte)0x01, cast(byte)0x11,
        cast(byte)0x11, cast(byte)0x11, cast(byte)0x11, cast(byte)0x00, cast(byte)0x00, cast(byte)0x11, cast(byte)0x11, cast(byte)0x11,
];

auto mskData = [
        cast(byte)0x03, cast(byte)0xc0,
        cast(byte)0x1f, cast(byte)0xf8,
        cast(byte)0x3f, cast(byte)0xfc,
        cast(byte)0x7f, cast(byte)0xfe,
        cast(byte)0x7f, cast(byte)0xfe,
        cast(byte)0x7f, cast(byte)0xfe,
        cast(byte)0xff, cast(byte)0xff,
        cast(byte)0xfe, cast(byte)0x7f,
        cast(byte)0xfe, cast(byte)0x7f,
        cast(byte)0xff, cast(byte)0xff,
        cast(byte)0x7f, cast(byte)0xfe,
        cast(byte)0x7f, cast(byte)0xfe,
        cast(byte)0x7f, cast(byte)0xfe,
        cast(byte)0x3f, cast(byte)0xfc,
        cast(byte)0x1f, cast(byte)0xf8,
        cast(byte)0x03, cast(byte)0xc0
];

void main (String [] args) {
    Display display = new Display();
    Color white = display.getSystemColor (SWT.COLOR_WHITE);
    Color black = display.getSystemColor (SWT.COLOR_BLACK);
    Color yellow = display.getSystemColor (SWT.COLOR_YELLOW);
    Color red = display.getSystemColor (SWT.COLOR_RED);
    Color green = display.getSystemColor (SWT.COLOR_GREEN);
    Color blue = display.getSystemColor (SWT.COLOR_BLUE);

    //Create a source ImageData of depth 4
    PaletteData palette = new PaletteData ([black.getRGB(), white.getRGB(), yellow.getRGB(),
                                            red.getRGB(), blue.getRGB(), green.getRGB()]);
    ImageData sourceData = new ImageData (16, 16, 4, palette, 1, srcData[]);

    //Create a mask ImageData of depth 1 (monochrome)
    palette = new PaletteData ([black.getRGB(), white.getRGB()]);
    ImageData maskData = new ImageData (16, 16, 1, palette, 1, mskData[]);

    //Set mask
    sourceData.maskData = maskData.data;
    sourceData.maskPad = maskData.scanlinePad;

    //Create cursor
    Cursor cursor = new Cursor(display, sourceData, 10, 10);

    //Remove mask to draw them separately just to show what they look like
    sourceData.maskData = null;
    sourceData.maskPad = -1;

    Shell shell = new Shell(display);
    Image source = new Image (display,sourceData);
    Image mask = new Image (display, maskData);
    shell.addPaintListener(new class PaintListener{
        public void paintControl(PaintEvent e) {
            GC gc = e.gc;
            int x = 10, y = 10;
            String stringSource = "source: ";
            String stringMask = "mask: ";
            gc.drawString(stringSource, x, y);
            gc.drawString(stringMask, x, y + 30);
            x += Math.max(gc.stringExtent(stringSource).x, gc.stringExtent(stringMask).x);
            gc.drawImage(source, x, y);
            gc.drawImage(mask, x, y + 30);
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
