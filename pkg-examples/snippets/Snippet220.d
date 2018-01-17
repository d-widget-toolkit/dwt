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
 *     Bill Baxter <wbaxter@gmail.com>
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet220;

/*
 * Tree example snippet: Images on the right side of the TreeItem
 *
 * For a detailed explanation of this snippet see
 * http://www.eclipse.org/articles/Article-CustomDrawingTableAndTreeItems/customDraw.htm#_example5
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 *
 * @since 3.2
 */

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.TreeItem;
import java.lang.all;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

version(JIVE){
    import jive.stacktrace;
}

void main() {
    const int IMAGE_MARGIN = 2;
    void handleEventMeasureItem(Event event) {
        TreeItem item = cast(TreeItem)event.item;
        Image trailingImage = cast(Image)item.getData();
        if (trailingImage !is null) {
            int w1 = event.width;
            event.width += trailingImage.getBounds().width + IMAGE_MARGIN;
            int w2 = event.width;
        }
    }
    void handleEventPaintItem(Event event, Tree tree ) {
        TreeItem item = cast(TreeItem)event.item;
        Image trailingImage = cast(Image)item.getData();
        if (trailingImage !is null) {
            int x = event.x + event.width + IMAGE_MARGIN;
            int itemHeight = tree.getItemHeight();
            int imageHeight = trailingImage.getBounds().height;
            int y = event.y + (itemHeight - imageHeight) / 2;
            event.gc.drawImage(trailingImage, x, y);
        }
    }
    Display display = new Display();
    Shell shell = new Shell(display);
    shell.setBounds(10, 10, 350, 200);
    Image xImage = new Image (display, 16, 16);
    GC gc = new GC(xImage);
    gc.setForeground(display.getSystemColor(SWT.COLOR_RED));
    gc.drawLine(1, 1, 14, 14);
    gc.drawLine(1, 14, 14, 1);
    gc.drawOval(2, 2, 11, 11);
    gc.dispose();
    Tree tree = new Tree(shell, SWT.CHECK);
    tree.setBounds(10, 10, 300, 150);
    TreeItem item = new TreeItem(tree, SWT.NONE);
    item.setText("root item");
    for (int i = 0; i < 4; i++) {
        TreeItem newItem = new TreeItem(item, SWT.NONE);
        newItem.setText("descendent " ~ to!(String)(i));
        if (i % 2 == 0) newItem.setData(xImage);
        item.setExpanded(true);
        item = newItem;
    }

    /*
     * NOTE: MeasureItem and PaintItem are called repeatedly.  Therefore it is
     * critical for performance that these methods be as efficient as possible.
     */
    tree.addListener(SWT.MeasureItem, dgListener( &handleEventMeasureItem ));
    tree.addListener(SWT.PaintItem,dgListener( &handleEventPaintItem, tree ));

    shell.open();
    while (!shell.isDisposed()) {
        if (!display.readAndDispatch()) display.sleep();
    }
    xImage.dispose();
    display.dispose();
}
