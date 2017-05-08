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
module org.eclipse.swt.snippets.Snippet142;

/*
 * UI Automation (for testing tools) snippet: post mouse events
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.0
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;

version(Tango){
    //import tango.core.Thread;
    import tango.io.Stdout;
    void writeln(in char[] line) {
        Stdout(line)("\n").flush();
    }
} else { // Phobos
    import std.stdio;
}

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    Button button = new Button(shell,SWT.NONE);
    button.setSize(100,100);
    button.setText("Click");
    shell.pack();
    shell.open();
    button.addListener(SWT.MouseDown, dgListener( (Event e){
        writeln(Format("Mouse Down  (Button: {} x: {} y: {})", e.button, e.x, e.y));
    }));
    Point pt = display.map(shell, null, 50, 50);
    Thread thread = new Thread({
        Event event;
        try {
            Thread.sleep(300);
        } catch (InterruptedException e) {}
        event = new Event();
        event.type = SWT.MouseMove;
        event.x = pt.x;
        event.y = pt.y;
        display.syncExec(new class Runnable {
            override void run() {
                display.post(event);
            }
        });
        try {
            Thread.sleep(300);
        } catch (InterruptedException e) {}
        event.type = SWT.MouseDown;
        event.button = 1;
        display.syncExec(new class Runnable {
            override void run() {
                display.post(event);
            }
        });
        try {
            Thread.sleep(300);
        } catch (InterruptedException e) {}
        event.type = SWT.MouseUp;
        display.syncExec(new class Runnable {
            override void run() {
                display.post(event);
            }
        });
    });
    thread.start();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}

