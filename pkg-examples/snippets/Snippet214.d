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
 *     Thomas Demmer <t_demmer AT web DOT de>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet214;

/*
 * Control example snippet: set a background image (a dynamic gradient)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.2
 */
import org.eclipse.swt.SWT;

import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.layout.RowLayout;

import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

void main(String [] args) {
    Image oldImage;
    
    Display display = new Display ();
    Shell shell = new Shell (display);
    shell.setBackgroundMode (SWT.INHERIT_DEFAULT);
    FillLayout layout1 = new FillLayout (SWT.VERTICAL);
    layout1.marginWidth = layout1.marginHeight = 10;
    shell.setLayout (layout1);
    Group group = new Group (shell, SWT.NONE);
    group.setText ("Group ");
    RowLayout layout2 = new RowLayout (SWT.VERTICAL);
    layout2.marginWidth = layout2.marginHeight = layout2.spacing = 10;
    group.setLayout (layout2);
    for (int i=0; i<8; i++) {
        Button button = new Button (group, SWT.RADIO);
        button.setText ("Button " ~ to!(String)(i));
    }
    shell.addListener (SWT.Resize, new class Listener {
       public void handleEvent (Event event) {
           Rectangle rect = shell.getClientArea ();
           Image newImage = new Image (display, Math.max (1, rect.width), 1);
           GC gc = new GC (newImage);
           gc.setForeground (display.getSystemColor (SWT.COLOR_WHITE));
           gc.setBackground (display.getSystemColor (SWT.COLOR_BLUE));
           gc.fillGradientRectangle (rect.x, rect.y, rect.width, 1, false);
           gc.dispose ();
           shell.setBackgroundImage (newImage);
           if (oldImage !is null) oldImage.dispose ();
           oldImage = newImage;
       }
    });
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    if (oldImage !is null) oldImage.dispose ();
    display.dispose ();
}

