/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module org.eclipse.swt.custom.StackLayout;

import java.lang.all;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Layout;

/**
 * This Layout stacks all the controls one on top of the other and resizes all controls
 * to have the same size and location.
 * The control specified in topControl is visible and all other controls are not visible.
 * Users must set the topControl value to flip between the visible items and then call
 * layout() on the composite which has the StackLayout.
 *
 * <p> Here is an example which places ten buttons in a stack layout and
 * flips between them:
 *
 * <pre><code>
 *  public static void main(String[] args) {
 *      Display display = new Display();
 *      Shell shell = new Shell(display);
 *      shell.setLayout(new GridLayout());
 *
 *      final Composite parent = new Composite(shell, SWT.NONE);
 *      parent.setLayoutData(new GridData(GridData.FILL_BOTH));
 *      final StackLayout layout = new StackLayout();
 *      parent.setLayout(layout);
 *      final Button[] bArray = new Button[10];
 *      for (int i = 0; i &lt; 10; i++) {
 *          bArray[i] = new Button(parent, SWT.PUSH);
 *          bArray[i].setText("Button "+i);
 *      }
 *      layout.topControl = bArray[0];
 *
 *      Button b = new Button(shell, SWT.PUSH);
 *      b.setText("Show Next Button");
 *      final int[] index = new int[1];
 *      b.addListener(SWT.Selection, new Listener(){
 *          public void handleEvent(Event e) {
 *              index[0] = (index[0] + 1) % 10;
 *              layout.topControl = bArray[index[0]];
 *              parent.layout();
 *          }
 *      });
 *
 *      shell.open();
 *      while (shell !is null && !shell.isDisposed()) {
 *          if (!display.readAndDispatch())
 *              display.sleep();
 *      }
 *  }
 * </code></pre>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#stacklayout">StackLayout snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: LayoutExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class StackLayout : Layout {

    /**
     * marginWidth specifies the number of pixels of horizontal margin
     * that will be placed along the left and right edges of the layout.
     *
     * The default value is 0.
     */
    public int marginWidth = 0;
    /**
     * marginHeight specifies the number of pixels of vertical margin
     * that will be placed along the top and bottom edges of the layout.
     *
     * The default value is 0.
     */
    public int marginHeight = 0;

    /**
     * topControl the Control that is displayed at the top of the stack.
     * All other controls that are children of the parent composite will not be visible.
     */
    public Control topControl;

protected override Point computeSize(Composite composite, int wHint, int hHint, bool flushCache) {
    Control[] children = composite.getChildren();
    int maxWidth = 0;
    int maxHeight = 0;
    for (int i = 0; i < children.length; i++) {
        Point size = children[i].computeSize(wHint, hHint, flushCache);
        maxWidth = Math.max(size.x, maxWidth);
        maxHeight = Math.max(size.y, maxHeight);
    }
    int width = maxWidth + 2 * marginWidth;
    int height = maxHeight + 2 * marginHeight;
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    return new Point(width, height);
}

protected override bool flushCache(Control control) {
    return true;
}

protected override void layout(Composite composite, bool flushCache) {
    Control[] children = composite.getChildren();
    Rectangle rect = composite.getClientArea();
    rect.x += marginWidth;
    rect.y += marginHeight;
    rect.width -= 2 * marginWidth;
    rect.height -= 2 * marginHeight;
    for (int i = 0; i < children.length; i++) {
        children[i].setBounds(rect);
        children[i].setVisible(children[i] is topControl);

    }
}

String getName () {
    String string = this.classinfo.name;
    int index = string.lastIndexOf ('.');
    if (index is -1 ) return string;
    return string[ index + 1 .. $ ];
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the layout
 */
public override String toString () {
    String string = getName ()~" {";
    if (marginWidth !is 0) string ~= "marginWidth="~String_valueOf(marginWidth)~" ";
    if (marginHeight !is 0) string ~= "marginHeight="~String_valueOf(marginHeight)~" ";
    if (topControl !is null) string ~= "topControl="~String_valueOf(topControl)~" ";
    string = string.trim();
    string ~= "}";
    return string;
}
}
