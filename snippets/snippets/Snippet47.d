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
 *     Bill Baxter <bill@billbaxter.com>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet47;

/*
 * ToolBar example snippet: create tool bar (normal, hot and disabled images)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.ToolItem;

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);

    Image image = new Image (display, 20, 20);
    Color color = display.getSystemColor (SWT.COLOR_BLUE);
    GC gc = new GC (image);
    gc.setBackground (color);
    gc.fillRectangle (image.getBounds ());
    gc.dispose ();
    
    Image disabledImage = new Image (display, 20, 20);
    color = display.getSystemColor (SWT.COLOR_GREEN);
    gc = new GC (disabledImage);
    gc.setBackground (color);
    gc.fillRectangle (disabledImage.getBounds ());
    gc.dispose ();
    
    Image hotImage = new Image (display, 20, 20);
    color = display.getSystemColor (SWT.COLOR_RED);
    gc = new GC (hotImage);
    gc.setBackground (color);
    gc.fillRectangle (hotImage.getBounds ());
    gc.dispose ();
    
    ToolBar bar = new ToolBar (shell, SWT.BORDER | SWT.FLAT);
    bar.setSize (200, 32);
    for (int i=0; i<12; i++) {
        ToolItem item = new ToolItem (bar, 0);
        item.setImage (image);
        item.setDisabledImage (disabledImage);
        item.setHotImage (hotImage);
        if (i % 3 == 0) item.setEnabled (false);
    }
    
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    image.dispose ();
    disabledImage.dispose ();
    hotImage.dispose ();
    display.dispose ();
}

