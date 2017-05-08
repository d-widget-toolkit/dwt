/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet107;
/*
 * Sash example snippet: implement a simple splitter (with a 20 pixel limit)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.layout.FormAttachment;
import org.eclipse.swt.layout.FormData;
import org.eclipse.swt.layout.FormLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Sash;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;

void main () {
    auto display = new Display ();
    auto shell = new Shell (display);
    auto button1 = new Button (shell, SWT.PUSH);
    button1.setText ("Button 1");
    auto sash = new Sash (shell, SWT.VERTICAL);
    auto button2 = new Button (shell, SWT.PUSH);
    button2.setText ("Button 2");
    
    auto form = new FormLayout ();
    shell.setLayout (form);
    
    auto button1Data = new FormData ();
    button1Data.left = new FormAttachment (0, 0);
    button1Data.right = new FormAttachment (sash, 0);
    button1Data.top = new FormAttachment (0, 0);
    button1Data.bottom = new FormAttachment (100, 0);
    button1.setLayoutData (button1Data);

    int limit = 20, percent = 50;
    auto sashData = new FormData ();
    sashData.left = new FormAttachment (percent, 0);
    sashData.top = new FormAttachment (0, 0);
    sashData.bottom = new FormAttachment (100, 0);
    sash.setLayoutData (sashData);
    sash.addListener (SWT.Selection, new class Listener {
        public void handleEvent (Event e) {
            auto sashRect = sash.getBounds ();
            auto shellRect = shell.getClientArea ();
            int right = shellRect.width - sashRect.width - limit;
            e.x = Math.max (Math.min (e.x, right), limit);
            if (e.x !is sashRect.x)  {
                sashData.left = new FormAttachment (0, e.x);
                shell.layout ();
            }
        }
    });
    
    auto button2Data = new FormData ();
    button2Data.left = new FormAttachment (sash, 0);
    button2Data.right = new FormAttachment (100, 0);
    button2Data.top = new FormAttachment (0, 0);
    button2Data.bottom = new FormAttachment (100, 0);
    button2.setLayoutData (button2Data);
    
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}
