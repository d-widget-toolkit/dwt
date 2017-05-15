/*******************************************************************************
 * Copyright (c) 2007 IBM Corporation and others.
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

module org.eclipse.swt.snippets.Snippet258;

/*
 * Create a search text control
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.3
 */
import org.eclipse.swt.SWT;
import java.io.ByteArrayInputStream;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.ToolItem;

version(Tango){
    import tango.io.Stdout;
} else { // Phobos
    import std.stdio;
}

void main() {
    auto display = new Display();
    auto shell = new Shell(display);
    shell.setLayout(new GridLayout(2, false));

    auto text = new Text(shell, SWT.SEARCH | SWT.CANCEL);
    Image image = null;
    if ((text.getStyle() & SWT.CANCEL) == 0) {
        image = new Image (display, new ImageData(new ByteArrayInputStream( cast(byte[]) import("links_obj.gif" ))));
        auto toolBar = new ToolBar (shell, SWT.FLAT);
        auto item = new ToolItem (toolBar, SWT.PUSH);
        item.setImage (image);
        item.addSelectionListener(new class SelectionAdapter {
            override
            public void widgetSelected(SelectionEvent e) {
                text.setText("");
                version(Tango){
                    Stdout("Search cancelled").newline;
                } else { // Phobos
                    writeln("Search cancelled");
                }
            }
        });
    }
    text.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
    text.setText("Search text");
    text.addSelectionListener(new class SelectionAdapter {
        override
        public void widgetDefaultSelected(SelectionEvent e) {
            version(Tango){
                if (e.detail == SWT.CANCEL) {
                    Stdout("Search cancelled").newline;
                } else {
                    Stdout("Searching for: ")(text.getText())("...").newline;
                }
            } else { // Phobos
                if (e.detail == SWT.CANCEL) {
                    writeln("Search cancelled");
                } else {
                    writeln("Searching for: " ~ text.getText() ~ "...");
                }
            }
        }
    });

    shell.pack();
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    if (image !is null) image.dispose();
    display.dispose();
}
