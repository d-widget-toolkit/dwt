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
module org.eclipse.swt.snippets.Snippet72;

/*
 * FileDialog example snippet: prompt for a file name (to save)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.FileDialog;

import java.lang.all;

version(Tango){
    import tango.io.Stdout;
    void writeln(in char[] line) {
        Stdout(line)("\n").flush();
    }
} else { // Phobos
    import std.stdio;
}

void main () {
    Display display = new Display ();
    Shell shell = new Shell (display);
    shell.open ();
    FileDialog dialog = new FileDialog (shell, SWT.SAVE);
    version(Windows) {
        dialog.setFilterNames (["Batch Files", "All Files (*.*)"]);
        dialog.setFilterExtensions (["*.bat", "*.*"]); //Windows wild cards
        dialog.setFilterPath ("c:\\"); //Windows path
        dialog.setFileName ("fred.bat");
    } else {
        dialog.setFilterNames (["Shell Script", "All Files (*.*)"]);
        dialog.setFilterExtensions (["*.sh", "*.*"]); //Posix wild cards
        dialog.setFilterPath ("/"); //Posix path
        dialog.setFileName ("fred.sh");
    }
    writeln ( Format("Save to: {}", dialog.open ()) );
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}

