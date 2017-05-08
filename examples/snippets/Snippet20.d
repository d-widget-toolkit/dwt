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
 *     Jesse Phillips <Jesse.K.Phillips+D> gmail.com
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet20;

/*
 * CoolBar example snippet: create a cool bar
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.CoolBar;
import org.eclipse.swt.widgets.CoolItem;
import org.eclipse.swt.widgets.Shell;
import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

void main () {
    auto display = new Display ();
    auto shell = new Shell (display);
    auto bar = new CoolBar (shell, SWT.BORDER);
    for (int i=0; i<2; i++) {
        auto item = new CoolItem (bar, SWT.NONE);
        auto button = new Button (bar, SWT.PUSH);
        button.setText ("Button " ~ to!(String)(i));
        auto size = button.computeSize (SWT.DEFAULT, SWT.DEFAULT);
        item.setPreferredSize (item.computeSize (size.x, size.y));
        item.setControl (button);
    }
    bar.pack ();
	 shell.setSize(300, 100);
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
