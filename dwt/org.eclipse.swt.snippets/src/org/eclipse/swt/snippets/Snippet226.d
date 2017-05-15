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
module org.eclipse.swt.snippets.Snippet226;

/* 
 * Tree example snippet: Draw a custom gradient selection
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 * 
 * @since 3.3
 */
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Region;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.TreeItem;
import org.eclipse.swt.widgets.TreeColumn;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Event;

version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

import java.lang.all;

void main() 
{
	Display display = new Display();
	Shell shell = new Shell(display);
	shell.setText("Custom gradient selection for Tree");
	shell.setLayout(new FillLayout());
	Tree tree = new Tree(shell, SWT.MULTI | SWT.FULL_SELECTION);
	tree.setHeaderVisible(true);
	tree.setLinesVisible(true);
	int columnCount = 4;
	for (int i=0; i<columnCount; i++) {
        auto istr = to!(String)(i);
		TreeColumn column = new TreeColumn(tree, SWT.NONE);
		column.setText("Column " ~ istr);	
	}
	int itemCount = 3;
	for (int i=0; i<itemCount; i++) {
        auto istr = to!(String)(i);
		TreeItem item1 = new TreeItem(tree, SWT.NONE);
		item1.setText("item "~istr);
		for (int c=1; c < columnCount; c++) {
            auto cstr = to!(String)(c);
			item1.setText(c, "item ["~istr~"-"~cstr~"]");
		}
		for (int j=0; j<itemCount; j++) {
            auto jstr = to!(String)(j);
			TreeItem item2 = new TreeItem(item1, SWT.NONE);
			item2.setText("item ["~istr~" "~jstr~"]");
			for (int c=1; c<columnCount; c++) {
                auto cstr = to!(String)(c);
				item2.setText(c, "item ["~istr~" "~jstr~"-"~cstr~"]");
			}
			for (int k=0; k<itemCount; k++) {
                auto kstr = to!(String)(k);
				TreeItem item3 = new TreeItem(item2, SWT.NONE);
				item3.setText("item ["~istr~" "~jstr~" "~kstr~"]");
				for (int c=1; c<columnCount; c++) {
                    auto cstr = to!(String)(c);
					item3.setText(c, "item ["~istr~" "~jstr~" "~kstr~"-"~cstr~"]");
				}
			}
		}
	}

	/*
	 * NOTE: MeasureItem, PaintItem and EraseItem are called repeatedly.
	 * Therefore, it is critical for performance that these methods be
	 * as efficient as possible.
	 */
	tree.addListener(SWT.EraseItem, new class Listener {
		public void handleEvent(Event event) {
			event.detail &= ~SWT.HOT;
			if ((event.detail & SWT.SELECTED) != 0) {
				GC gc = event.gc;
				Rectangle area = tree.getClientArea();
				/*
				 * If you wish to paint the selection beyond the end of
				 * last column, you must change the clipping region.
				 */
				int columnCount = tree.getColumnCount();
				if (event.index == columnCount - 1 || columnCount == 0) {
					int width = area.x + area.width - event.x;
					if (width > 0) {
						Region region = new Region();
						gc.getClipping(region);
						region.add(event.x, event.y, width, event.height); 
						gc.setClipping(region);
						region.dispose();
					}
				}
				gc.setAdvanced(true);
				if (gc.getAdvanced()) gc.setAlpha(127);								
				Rectangle rect = event.getBounds();
				Color foreground = gc.getForeground();
				Color background = gc.getBackground();
				gc.setForeground(display.getSystemColor(SWT.COLOR_RED));
				gc.setBackground(display.getSystemColor(SWT.COLOR_LIST_BACKGROUND));
				gc.fillGradientRectangle(0, rect.y, 500, rect.height, false);
				// restore colors for subsequent drawing
				gc.setForeground(foreground);
				gc.setBackground(background);
				event.detail &= ~SWT.SELECTED;					
			}						
		}
	});		
	for (int i=0; i<columnCount; i++) {
		tree.getColumn(i).pack();
	}	
	tree.setSelection(tree.getItem(0));
	shell.setSize(500, 200);
	shell.open();
	while (!shell.isDisposed()) {
		if (!display.readAndDispatch()) display.sleep();
	}
	display.dispose();	
}
