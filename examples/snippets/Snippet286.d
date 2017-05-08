/*******************************************************************************
 * Copyright (c) 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet286;

/*
 * use a menu item's armListener to update a status line.
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ArmEvent;
import org.eclipse.swt.events.ArmListener;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Canvas;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MenuItem;
import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}


void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new GridLayout());
		
    Canvas blankCanvas = new Canvas(shell, SWT.BORDER);
    blankCanvas.setLayoutData(new GridData(200, 200));
    Label statusLine = new Label(shell, SWT.NONE);
    statusLine.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false));

    Menu bar = new Menu (shell, SWT.BAR);
    shell.setMenuBar (bar);
		
    MenuItem menuItem = new MenuItem (bar, SWT.CASCADE);
    menuItem.setText ("Test");
    Menu menu = new Menu(bar);
    menuItem.setMenu (menu);
		
    for (int i = 0; i < 5; i++) {
        MenuItem item = new MenuItem (menu, SWT.PUSH);
        item.setText ("Item " ~ to!(String)(i));
        item.addArmListener(new class ArmListener {
            public void widgetArmed(ArmEvent e) {
                statusLine.setText((cast(MenuItem)e.getSource()).getText());
            }
        });
    }
		
    shell.pack();
    shell.open();
		
    while(!shell.isDisposed()) {
        if(!display.readAndDispatch()) display.sleep();
    }
}
