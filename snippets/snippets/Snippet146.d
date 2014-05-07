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
module org.eclipse.swt.snippets.Snippet146;
  
/*
 * UI Automation (for testing tools) snippet: post key events
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 * 
 * @since 3.0
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;

import java.lang.all;

version(Tango){
    //import tango.core.Thread;
    import tango.text.Unicode;
} else {
    import std.string;
    import std.uni;
}

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    Text text = new Text(shell, SWT.BORDER);
    text.setSize(text.computeSize(150, SWT.DEFAULT));
    shell.pack();
    shell.open();
    Thread thread = new Thread({
        String string = "Love the method.";
        String lstring;
        version(Tango){
            lstring. length = string.length;
            toLower(string, lstring);
        } else {
            lstring = toLower(string);
        }
        for (int i = 0; i < string.length; i++) {
            char ch = string.charAt(i);
            bool shift = cast(bool) isUpper(ch);
            ch = lstring.charAt(i);
            if (shift) {
                Event event = new Event();
                event.type = SWT.KeyDown;
                event.keyCode = SWT.SHIFT;
                display.post(event);    
            }
            Event event = new Event();
            event.type = SWT.KeyDown;
            event.character = ch;
            display.post(event);
            try {
                Thread.sleep(10);
            } catch (InterruptedException e) {}
            event.type = SWT.KeyUp;
            display.post(event);
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {}
            if (shift) {
                event = new Event();
                event.type = SWT.KeyUp;
                event.keyCode = SWT.SHIFT;
                display.post(event);    
            }
        }
    });
    thread.start();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}

