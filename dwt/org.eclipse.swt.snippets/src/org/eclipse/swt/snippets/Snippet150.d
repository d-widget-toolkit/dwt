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
 *     Bill Baxter
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet150;

/*
 * CoolBar example snippet: create a coolbar (relayout when resized)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.0
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.CoolBar;
import org.eclipse.swt.widgets.CoolItem;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.ToolItem;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.layout.FormLayout;
import org.eclipse.swt.layout.FormData;
import org.eclipse.swt.layout.FormAttachment;
import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

int itemCount;
CoolItem createItem(CoolBar coolBar, int count) {
    ToolBar toolBar = new ToolBar(coolBar, SWT.FLAT);
    for (int i = 0; i < count; i++) {
        ToolItem item = new ToolItem(toolBar, SWT.PUSH);
        item.setText(to!(String)(itemCount++));
    }
    toolBar.pack();
    Point size = toolBar.getSize();
    CoolItem item = new CoolItem(coolBar, SWT.NONE);
    item.setControl(toolBar);
    Point preferred = item.computeSize(size.x, size.y);
    item.setPreferredSize(preferred);
    return item;
}

void main () {

    Display display = new Display();
    Shell shell = new Shell(display);
    CoolBar coolBar = new CoolBar(shell, SWT.NONE);
    createItem(coolBar, 3);
    createItem(coolBar, 2);
    createItem(coolBar, 3);
    createItem(coolBar, 4);
    int style = SWT.BORDER | SWT.H_SCROLL | SWT.V_SCROLL;
    Text text = new Text(shell, style);
    FormLayout layout = new FormLayout();
    shell.setLayout(layout);
    FormData coolData = new FormData();
    coolData.left = new FormAttachment(0);
    coolData.right = new FormAttachment(100);
    coolData.top = new FormAttachment(0);
    coolBar.setLayoutData(coolData);
    coolBar.addListener(SWT.Resize, new class Listener {
        void handleEvent(Event event) {
            shell.layout();
        }
    });
    FormData textData = new FormData();
    textData.left = new FormAttachment(0);
    textData.right = new FormAttachment(100);
    textData.top = new FormAttachment(coolBar);
    textData.bottom = new FormAttachment(100);
    text.setLayoutData(textData);
    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    display.dispose();

}
