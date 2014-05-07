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
 *     Bill Baxter <wbaxter> at gmail com
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet21;

/*
 * Canvas example snippet: implement tab traversal (behave like a tab group)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.Canvas;

version(Tango){
    import tango.io.Stdout;
    void writeln(in char[] line) {
        Stdout(line)("\n").flush();
    }
} else { // Phobos
    import std.stdio;
}

import java.lang.all;

void main () {
	Display display = new Display ();
	Color red = display.getSystemColor (SWT.COLOR_RED);
	Color blue = display.getSystemColor (SWT.COLOR_BLUE);
	Shell shell = new Shell (display);
	Button b = new Button (shell, SWT.PUSH);
	b.setBounds (10, 10, 100, 32);
	b.setText ("Button");
	shell.setDefaultButton (b);
	Canvas c = new Canvas (shell, SWT.BORDER);
	c.setBounds (10, 50, 100, 32);

    void onTraverse(Event e, Canvas c) {
        switch (e.detail) {
            /* Do tab group traversal */
        case SWT.TRAVERSE_ESCAPE:
        case SWT.TRAVERSE_RETURN:
        case SWT.TRAVERSE_TAB_NEXT:	
        case SWT.TRAVERSE_TAB_PREVIOUS:
        case SWT.TRAVERSE_PAGE_NEXT:	
        case SWT.TRAVERSE_PAGE_PREVIOUS:
            e.doit = true;
        default:
        }
    }

    void onFocusIn(Event e, Canvas c) {
        c.setBackground (red);
    }

    void onFocusOut(Event e, Canvas c) {
        c.setBackground (blue);
    }

    void onKeyDown (Event e, Canvas c) {
        writeln("KEY");
        for (int i=0; i<64; i++) {
            Color c1 = red, c2 = blue;
            if (c.isFocusControl ()) {
                c1 = blue;  c2 = red;
            }
            c.setBackground (c1);
            c.update ();
            c.setBackground (c2);
        }
    }

	c.addListener (SWT.Traverse, dgListener(&onTraverse, c));
	c.addListener (SWT.FocusIn, dgListener(&onFocusIn, c));
	c.addListener (SWT.FocusOut, dgListener(&onFocusOut, c));
	c.addListener (SWT.KeyDown, dgListener(&onKeyDown, c));

	Text t = new Text (shell, SWT.SINGLE | SWT.BORDER);
	t.setBounds (10, 85, 100, 32);

	Text r = new Text (shell, SWT.MULTI | SWT.BORDER);
	r.setBounds (10, 120, 100, 32);
	
	c.setFocus ();
	shell.setSize (200, 200);
	shell.open ();
	while (!shell.isDisposed()) {
		if (!display.readAndDispatch ()) display.sleep ();
	}
	display.dispose ();
}
