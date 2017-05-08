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
 *     Jesse Phillips <Jesse.K.Phillips+D> gmail.com
 *******************************************************************************/

module org.eclipse.swt.snippets.Snippet41;

/*
 * Tool Tips example snippet: create tool tips for a tab item, tool item, and shell
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.TabFolder;
import org.eclipse.swt.widgets.TabItem;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.ToolItem;

void main () {
    auto string = "This is a string\nwith a new line.";
    auto display = new Display ();
    auto shell = new Shell (display);

    TabFolder folder = new TabFolder (shell, SWT.BORDER);

    folder.setSize (200, 200);
    auto item0 = new TabItem (folder, 0);
    item0.setText( "Text" );
    item0.setToolTipText ("TabItem toolTip: " ~ string);

    auto bar = new ToolBar (shell, SWT.BORDER);
    bar.setBounds (0, 200, 200, 64);

    ToolItem item1 = new ToolItem (bar, 0);
    item1.setText( "Text" );
    item1.setToolTipText ("ToolItem toolTip: " ~ string);
    shell.setToolTipText ("Shell toolTip: " ~ string);

    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
