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
module org.eclipse.swt.snippets.Snippet82;

/*
 * CTabFolder example snippet: prevent an item from closing
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.0
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.CTabFolder;
import org.eclipse.swt.custom.CTabFolder2Adapter;
import org.eclipse.swt.custom.CTabFolderEvent;
import org.eclipse.swt.custom.CTabItem;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;

import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

void main() {
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setLayout(new FillLayout());
    CTabFolder folder = new CTabFolder(shell, SWT.BORDER);
    for (int i = 0; i < 4; i++) {
        CTabItem item = new CTabItem(folder, SWT.CLOSE);
        item.setText("Item " ~ to!(String)(i) );
        Text text = new Text(folder, SWT.MULTI);
        text.setText("Content for Item "~ to!(String)(i));
        item.setControl(text);
    }

    CTabItem specialItem = new CTabItem(folder, SWT.CLOSE);
    specialItem.setText("Don't Close Me");
    Text text = new Text(folder, SWT.MULTI);
    text.setText("This tab can never be closed");
    specialItem.setControl(text);

    folder.addCTabFolder2Listener(new class CTabFolder2Adapter {
        override
        public void close(CTabFolderEvent event) {
            if (event.item == specialItem) {
                event.doit = false;
            }
        }
    });

    CTabItem noCloseItem = new CTabItem(folder, SWT.NONE);
    noCloseItem.setText("No Close Button");
    Text text2 = new Text(folder, SWT.MULTI);
    text2.setText("This tab does not have a close button");
    noCloseItem.setControl(text2);

    shell.pack();
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch())
            display.sleep();
    }
    display.dispose();
}

