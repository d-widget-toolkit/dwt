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
module org.eclipse.swt.snippets.Snippet94;
/*
 * Clipboard example snippet: copy and paste data with the clipboard
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.dnd.Clipboard;
import org.eclipse.swt.dnd.Transfer;
import org.eclipse.swt.dnd.TextTransfer;

import org.eclipse.swt.layout.FormAttachment;
import org.eclipse.swt.layout.FormData;
import org.eclipse.swt.layout.FormLayout;

import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;

import java.lang.all;


void main() {
    Display display = new Display ();
    Clipboard cb = new Clipboard(display);
    Shell shell = new Shell (display);
    shell.setLayout(new FormLayout());
    Text text = new Text(shell, SWT.BORDER | SWT.MULTI | SWT.V_SCROLL | SWT.H_SCROLL);

    Button copy = new Button(shell, SWT.PUSH);
    copy.setText("Copy");
    copy.addListener (SWT.Selection, new class Listener {
        public void handleEvent (Event e) {
            String textData = text.getSelectionText();
            if (textData.length > 0) {
                TextTransfer textTransfer = TextTransfer.getInstance();
                // this is ugly, but works.
                Transfer[] xfer = [ textTransfer];
                Object[] td = [ new ArrayWrapperString(textData) ];
                cb.setContents(td,xfer);
            }
        }
    });

    Button paste = new Button(shell, SWT.PUSH);
    paste.setText("Paste");
    paste.addListener (SWT.Selection, new class Listener {
        public void handleEvent (Event e) {
            TextTransfer transfer = TextTransfer.getInstance();
            String data = stringcast(cb.getContents(transfer));
            if (data !is null) {
                text.insert(data);
            }
        }
    });

    FormData data = new FormData();
    data.left = new FormAttachment(paste, 0, SWT.LEFT);
    data.right = new FormAttachment(100, -5);
    data.top = new FormAttachment(0, 5);
    copy.setLayoutData(data);

    data = new FormData();
    data.right = new FormAttachment(100, -5);
    data.top = new FormAttachment(copy, 5);
    paste.setLayoutData(data);

    data = new FormData();
    data.left = new FormAttachment(0, 5);
    data.top = new FormAttachment(0, 5);
    data.right = new FormAttachment(paste, -5);
    data.bottom = new FormAttachment(100, -5);
    text.setLayoutData(data);

    shell.setSize(200, 200);
    shell.open();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    cb.dispose();
    display.dispose();
}
