/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * D Port:
 *     Bill Baxter <wbaxter> at gmail com
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet275;

/*
 * Canvas snippet: update a portion of a Canvas frequently
 * 
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Canvas;

import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

void main () {
    String value;
	int INTERVAL = 888;
	Display display = new Display ();
	Image image = new Image (display, 750, 750);
	GC gc = new GC (image);
	gc.setBackground (display.getSystemColor (SWT.COLOR_RED));
	gc.fillRectangle (image.getBounds ());
	gc.dispose ();

	Shell shell = new Shell (display);
	shell.setBounds (10, 10, 790, 790);
	Canvas canvas = new Canvas (shell, SWT.NONE);
	canvas.setBounds (10, 10, 750, 750);

    void onPaint (Event event) {
        value = to!(String)(System.currentTimeMillis ());
        event.gc.drawImage (image, 0, 0);
        event.gc.drawString (value, 10, 10, true);
    }
	canvas.addListener (SWT.Paint, dgListener(&onPaint));

	display.timerExec (INTERVAL, new class Runnable {
        void run () {
			if (canvas.isDisposed ()) return;
			// canvas.redraw (); // <-- bad, damages more than is needed
			GC gc = new GC (canvas);
			Point extent = gc.stringExtent (value ~ '0');
			gc.dispose ();
			canvas.redraw (10, 10, extent.x, extent.y, false);
			display.timerExec (INTERVAL, this);
		}
	});
	shell.open ();
	while (!shell.isDisposed ()){
		if (!display.readAndDispatch ()) display.sleep ();
	}
	image.dispose ();
	display.dispose ();
}
