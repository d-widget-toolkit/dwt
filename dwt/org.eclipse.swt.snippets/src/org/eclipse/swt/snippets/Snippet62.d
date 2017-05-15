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
 module control.Snippet62;

 /*
  * Control example snippet: print mouse state and button (down, move, up)
  *
  * For a list of all SWT example snippets see
  * http://www.eclipse.org/swt/snippets/
  * 
  * @since 3.1
  */
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Event;
import java.lang.all;

version(Tango){
    import tango.io.Stdout;
    void writeln(in char[] line) {
        Stdout(line)("\n").flush();
    }
    import tango.util.Convert;
} else { // Phobos
    import std.stdio;
    import std.conv;
}

String stateMask (int stateMask) {
    String str = "";
    if ((stateMask & SWT.CTRL) != 0) str ~= " CTRL";
    if ((stateMask & SWT.ALT) != 0) str ~= " ALT";
    if ((stateMask & SWT.SHIFT) != 0) str ~= " SHIFT";
    if ((stateMask & SWT.COMMAND) != 0) str ~= " COMMAND";
    return str;
}

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    Listener listener = new class Listener {
        public void handleEvent (Event e) {
            String str = "Unknown";
            switch (e.type) {
            case SWT.MouseDown: str = "DOWN"; break;
            case SWT.MouseMove: str = "MOVE"; break;
            case SWT.MouseUp: str = "UP"; break;
            default:
            }
            str ~= Format(": button: {}, stateMask=0x{:x}{}, x={}, y={}",
                e.button, e.stateMask, stateMask (e.stateMask), e.x, e.y);
            if ((e.stateMask & SWT.BUTTON1) != 0) str ~= " BUTTON1";
            if ((e.stateMask & SWT.BUTTON2) != 0) str ~= " BUTTON2";
            if ((e.stateMask & SWT.BUTTON3) != 0) str ~= " BUTTON3";
            if ((e.stateMask & SWT.BUTTON4) != 0) str ~= " BUTTON4";
            if ((e.stateMask & SWT.BUTTON5) != 0) str ~= " BUTTON5";
            writeln(str);
        }
    };
    shell.addListener (SWT.MouseDown, listener);
    shell.addListener (SWT.MouseMove, listener);
    shell.addListener (SWT.MouseUp, listener);
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}

