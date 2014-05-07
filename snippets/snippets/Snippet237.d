/*******************************************************************************
 * Copyright (c) 2000, 2006 IBM Corporation and others.
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
module org.eclipse.swt.snippets.Snippet237;
/*
 * Composite Snippet: inherit a background color or image
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.2
 */

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.List;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;

import java.lang.all;


void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setText("Composite.setBackgroundMode()");
    shell.setLayout(new RowLayout(SWT.VERTICAL));

    Color color = display.getSystemColor(SWT.COLOR_CYAN);

    Group group = new Group(shell, SWT.NONE);
    group.setText("SWT.INHERIT_NONE");
    group.setBackground(color);
    group.setBackgroundMode(SWT.INHERIT_NONE);
    createChildren(group);

    group = new Group(shell, SWT.NONE);
    group.setBackground(color);
    group.setText("SWT.INHERIT_DEFAULT");
    group.setBackgroundMode(SWT.INHERIT_DEFAULT);
    createChildren(group);

    group = new Group(shell, SWT.NONE);
    group.setBackground(color);
    group.setText("SWT.INHERIT_FORCE");
    group.setBackgroundMode(SWT.INHERIT_FORCE);
    createChildren(group);

    shell.pack();
    shell.open();
    while(!shell.isDisposed()) {
        if(!display.readAndDispatch()) display.sleep();
    }
    display.dispose();
}

void createChildren(Composite parent) {
    parent.setLayout(new RowLayout());
    List list = new List(parent, SWT.BORDER | SWT.MULTI);
    list.add("List item 1");
    list.add("List item 2");
    Label label = new Label(parent, SWT.NONE);
    label.setText("Label");
    Button button = new Button(parent, SWT.RADIO);
    button.setText("Radio Button");
    button = new Button(parent, SWT.CHECK);
    button.setText("Check box Button");
    button = new Button(parent, SWT.PUSH);
    button.setText("Push Button");
    Text text = new Text(parent, SWT.BORDER);
    text.setText("Text");
}
