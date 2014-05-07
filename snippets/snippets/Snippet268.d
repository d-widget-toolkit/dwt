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
module org.eclipse.swt.snippets.Snippet268;
  
/*
 * UI Automation (for testing tools) snippet: post mouse wheel events to a styled text
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 * 
 * @since 3.0
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;

import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.layout.FillLayout;

version(Tango){
    import tango.io.Stdout;
    import tango.util.Convert;
} else { // Phobos
    import std.stdio;
    import std.conv;
}

void main(String[] args) {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());
    StyledText styledText = new StyledText(shell, SWT.V_SCROLL);
    String multiLineString = "";
    for (int i = 0; i < 200; i++) {
        multiLineString ~= "This is line number " ~ to!(String)(i) ~
            " in the multi-line string.\n";
    }
    styledText.setText(multiLineString);
    shell.setSize(styledText.computeSize(SWT.DEFAULT, 400));
    shell.open();
    styledText.addListener(SWT.MouseWheel, dgListener( (Event e){
        version(Tango){
            Stdout.formatln("Mouse Wheel event {}\n", e);
            Stdout.flush();
        } else {
            writefln("Mouse Wheel event %s", e);
        }
    }));
    Point pt = display.map(shell, null, 50, 50);
    Thread thread = new Thread({
        Event event;
        for (int i = 0; i < 50; i++) {
            event = new Event();
            event.type = SWT.MouseWheel;
            event.detail = SWT.SCROLL_LINE;
            event.x = pt.x;
            event.y = pt.y;
            event.count = -2;
            display.post(event);
            try {
                Thread.sleep(400);
            } catch (InterruptedException e) {}
        }
        version(Tango){
            Stdout("Thread done\n").flush(); 
        } else {
            writeln("Thread done");
        }
    });
  
    thread.start();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}
