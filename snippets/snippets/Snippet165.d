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
 * 	 Jesse Phillips <Jesse.K.Phillips+D> gmail.com
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet165;

/*
 * Create a CTabFolder with min and max buttons, as well as close button and 
 * image only on selected tab.
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 * 
 * @since 3.0
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.CTabFolder;
import org.eclipse.swt.custom.CTabFolder2Adapter ;
import org.eclipse.swt.custom.CTabFolderEvent ;
import org.eclipse.swt.custom.CTabItem;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;
import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

void main () {
    auto display = new Display ();
    auto image = new Image(display, 16, 16);
    auto gc = new GC(image);
    gc.setBackground(display.getSystemColor(SWT.COLOR_BLUE));
    gc.fillRectangle(0, 0, 16, 16);
    gc.setBackground(display.getSystemColor(SWT.COLOR_YELLOW));
    gc.fillRectangle(3, 3, 10, 10);
    gc.dispose();
    auto shell = new Shell (display);
    shell.setLayout(new GridLayout());
    auto folder = new CTabFolder(shell, SWT.BORDER);
    folder.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, false));
    folder.setSimple(false);
    folder.setUnselectedImageVisible(false);
    folder.setUnselectedCloseVisible(false);
    for (int i = 0; i < 8; i++) {
        CTabItem item = new CTabItem(folder, SWT.CLOSE);
        item.setText("Item " ~ to!(String)(i));
        item.setImage(image);
        Text text = new Text(folder, SWT.MULTI | SWT.V_SCROLL | SWT.H_SCROLL);
        text.setText("Text for item " ~ to!(String)(i) ~
                     "\n\none, two, three\n\nabcdefghijklmnop");
        item.setControl(text);
    }
    folder.setMinimizeVisible(true);
    folder.setMaximizeVisible(true);
    folder.addCTabFolder2Listener(new class CTabFolder2Adapter {
        override
        public void minimize(CTabFolderEvent event) {
            folder.setMinimized(true);
            shell.layout(true);
        }
        override
        public void maximize(CTabFolderEvent event) {
            folder.setMaximized(true);
            folder.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));
            shell.layout(true);
        }
        override
        public void restore(CTabFolderEvent event) {
            folder.setMinimized(false);
            folder.setMaximized(false);
            folder.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, false));
            shell.layout(true);
        }
    });
    shell.setSize(300, 300);
    shell.open ();
    while (!shell.isDisposed ()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    image.dispose();
    display.dispose ();
}
