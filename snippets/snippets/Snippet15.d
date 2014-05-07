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
module org.eclipse.swt.snippets.Snippet15;
 
/*
 * Tree example snippet: create a tree
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.TreeItem;
import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

void main () {
    auto display = new Display ();
    auto shell = new Shell (display);
    shell.setLayout(new FillLayout());
    auto tree = new Tree (shell, SWT.BORDER);
    for (int i=0; i<4; i++) {
        auto iItem = new TreeItem (tree, 0);
        iItem.setText ("TreeItem (0) -" ~ to!(String)(i));
        for (int j=0; j<4; j++) {
            TreeItem jItem = new TreeItem (iItem, 0);
            jItem.setText ("TreeItem (1) -" ~ to!(String)(j));
            for (int k=0; k<4; k++) {
                TreeItem kItem = new TreeItem (jItem, 0);
                kItem.setText ("TreeItem (2) -" ~ to!(String)(k));
                for (int l=0; l<4; l++) {
                    TreeItem lItem = new TreeItem (kItem, 0);
                    lItem.setText ("TreeItem (3) -" ~ to!(String)(l));
                }
            }
        }
    }
    shell.setSize (200, 200);
    shell.open ();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
