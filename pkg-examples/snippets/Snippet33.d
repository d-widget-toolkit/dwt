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
module org.eclipse.swt.snippets.Snippet33;

/*
 * DirectoryDialog example snippet: prompt for a directory
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */

import org.eclipse.swt.widgets.DirectoryDialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import java.lang.all;

version(Tango){
    import tango.sys.Environment;
    import tango.io.Stdout;
    void writeln(in char[] line) {
        Stdout(line)("\n").flush();
    }
    import tango.util.Convert;
} else { // Phobos
    import std.file;
    import std.stdio;
    import std.conv;
}

void main () {
    auto display = new Display ();
    auto shell = new Shell (display);
    shell.open ();
    auto dialog = new DirectoryDialog (shell);
    version(Tango){
        dialog.setFilterPath (Environment.cwd());
    } else {
        dialog.setFilterPath (getcwd());
    }
    writeln("RESULT=" ~ to!(String)(dialog.open()));
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
