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
module org.eclipse.swt.snippets.Snippet122;
/*
 * Clipboard example snippet: enable/disable menu depending on clipboard content availability
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.0
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.dnd.Clipboard;
import org.eclipse.swt.dnd.TextTransfer;
import org.eclipse.swt.dnd.Transfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.events.MenuAdapter;
import org.eclipse.swt.events.MenuEvent;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;

import java.lang.all;

void main() {
    Display display = new Display();
    Clipboard cb = new Clipboard(display);
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());
    Text text = new Text(shell, SWT.BORDER | SWT.MULTI | SWT.WRAP);
    Menu menu = new Menu(shell, SWT.POP_UP);
    MenuItem copyItem = new MenuItem(menu, SWT.PUSH);
    copyItem.setText("Copy");
    copyItem.addSelectionListener(new class SelectionAdapter{
        override
        public void widgetSelected(SelectionEvent e) {
            String selection = text.getSelectionText();
            if (selection.length == 0) return;
            Object[] data = [ new ArrayWrapperString(selection) ];
            Transfer[] types = [ TextTransfer.getInstance() ];
            cb.setContents(data, types);
        }
    });
    MenuItem pasteItem = new MenuItem(menu, SWT.PUSH);
    pasteItem.setText ("Paste");
    pasteItem.addSelectionListener(new class SelectionAdapter{
        override
        public void widgetSelected(SelectionEvent e) {
            String string = stringcast(cb.getContents(TextTransfer.getInstance()));
            if (string !is null) text.insert(string);
        }
    });
    menu.addMenuListener(new class MenuAdapter{
        override
        public void menuShown(MenuEvent e) {
            // is copy valid?
            String selection = text.getSelectionText();
            copyItem.setEnabled(selection.length > 0);
            // is paste valid?
            TransferData[] available = cb.getAvailableTypes();
            bool enabled = false;
            for (int i = 0; i < available.length; i++) {
                if (TextTransfer.getInstance().isSupportedType(available[i])) {
                    enabled = true;
                    break;
                }
            }
            pasteItem.setEnabled(enabled);
        }
    });

    text.setMenu (menu);
    shell.setSize(200, 200);
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    cb.dispose();
    display.dispose();
}
