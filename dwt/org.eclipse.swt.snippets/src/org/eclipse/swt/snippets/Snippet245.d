/*******************************************************************************
 * Copyright (c) 2000, 2006 IBM Corporation and others.
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
module org.eclipse.swt.snippets.Snippet245;

/* 
 * Canvas snippet: paint a circle in a canvas
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */

import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.events.PaintListener;
import org.eclipse.swt.events.PaintEvent;

void main() 
{
	Display display = new Display();
	Shell shell = new Shell(display);
	shell.addPaintListener(new class PaintListener {
        public void paintControl(PaintEvent event) {
            Rectangle rect = shell.getClientArea();
            event.gc.drawOval(0, 0, rect.width - 1, rect.height - 1);
        }
    });
	shell.setBounds(10, 10, 200, 200);
	shell.open ();
	while (!shell.isDisposed()) {
		if (!display.readAndDispatch()) display.sleep();
	}
	display.dispose();
}
