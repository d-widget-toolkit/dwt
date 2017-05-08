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
 *     Bill Baxter <wbaxter@gmail.com>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet111;

/*
 * TreeEditor example snippet: edit the text of a tree item (in place, fancy)
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.TreeItem;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.custom.TreeEditor;

import java.lang.all;

version(JIVE){
    import jive.stacktrace;
}

void main () {

    Tree tree;
    Color black;
    void handleResize (Event e, Composite composite, Text text, int inset ) {
        Rectangle rect = composite.getClientArea ();
        text.setBounds (rect.x + inset, rect.y + inset, rect.width - inset * 2, rect.height - inset * 2);
    }
    void handleTextEvent (Event e, Composite composite, TreeItem item, TreeEditor editor,Text text, int inset ) {
        switch (e.type) {
        case SWT.FocusOut: {
            item.setText (text.getText ());
            composite.dispose ();
        }
        break;
        case SWT.Verify: {
            String newText = text.getText ();
            String leftText = newText.substring (0, e.start);
            String rightText = newText.substring (e.end, cast(int)newText.length);
            GC gc = new GC (text);
            Point size = gc.textExtent (leftText ~ e.text ~ rightText);
            gc.dispose ();
            size = text.computeSize (size.x, SWT.DEFAULT);
            editor.horizontalAlignment = SWT.LEFT;
            Rectangle itemRect = item.getBounds (), rect = tree.getClientArea ();
            editor.minimumWidth = Math.max (size.x, itemRect.width) + inset* 2;
            int left = itemRect.x, right = rect.x + rect.width;
            editor.minimumWidth = Math.min (editor.minimumWidth, right - left);
            editor.minimumHeight = size.y + inset* 2;
            editor.layout ();
        }
        break;
        case SWT.Traverse: {
            switch (e.detail) {
            case SWT.TRAVERSE_RETURN:
                item.setText (text.getText ());
                goto case SWT.TRAVERSE_ESCAPE;
            case SWT.TRAVERSE_ESCAPE:
                composite.dispose ();
                e.doit = false;
                break;
            default:
                //no-op
                break;
            }
            break;
        }
        default:
        // no-op
        }
    }
    void handleSelection (Event event, TreeItem[] lastItem, TreeEditor editor ) {
        TreeItem item = cast(TreeItem) event.item;
        if (item !is null && item is lastItem [0]) {
            bool showBorder = true;
            Composite composite = new Composite (tree, SWT.NONE);
            if (showBorder) composite.setBackground (black);
            Text text = new Text (composite, SWT.NONE);
            int inset = showBorder ? 1 : 0;
            composite.addListener (SWT.Resize, dgListener( &handleResize, composite, text, inset ));
            Listener textListener = dgListener( &handleTextEvent, composite, item, editor, text, inset);
            text.addListener (SWT.FocusOut, textListener);
            text.addListener (SWT.Traverse, textListener);
            text.addListener (SWT.Verify, textListener);
            editor.setEditor (composite, item);
            text.setText (item.getText ());
            text.selectAll ();
            text.setFocus ();
        }
        lastItem [0] = item;
    }

    Display display = new Display ();
    black = display.getSystemColor (SWT.COLOR_BLACK);
    Shell shell = new Shell (display);
    shell.setLayout (new FillLayout ());
    tree = new Tree (shell, SWT.BORDER);
    for (int i=0; i<16; i++) {
        TreeItem itemI = new TreeItem (tree, SWT.NONE);
        itemI.setText (Format("Item {}", i));
        for (int j=0; j<16; j++) {
            TreeItem itemJ = new TreeItem (itemI, SWT.NONE);
            itemJ.setText ( Format("Item {}", j) );
        }
    }
    TreeItem [] lastItem = new TreeItem [1];
    TreeEditor editor = new TreeEditor (tree);
    tree.addListener (SWT.Selection, dgListener( &handleSelection, lastItem, editor ));
    shell.pack ();
    shell.open ();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch ()) display.sleep ();
    }
    display.dispose ();
}


