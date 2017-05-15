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
module org.eclipse.swt.layout.RowData;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Control;

import java.lang.all;

/**
 * Each control controlled by a <code>RowLayout</code> can have its initial
 * width and height specified by setting a <code>RowData</code> object
 * into the control.
 * <p>
 * The following code uses a <code>RowData</code> object to change the initial
 * size of a <code>Button</code> in a <code>Shell</code>:
 * <pre>
 *      Display display = new Display();
 *      Shell shell = new Shell(display);
 *      shell.setLayout(new RowLayout());
 *      Button button1 = new Button(shell, SWT.PUSH);
 *      button1.setText("Button 1");
 *      button1.setLayoutData(new RowData(50, 40));
 * </pre>
 * </p>
 *
 * @see RowLayout
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class RowData {
    /**
     * width specifies the desired width in pixels. This value
     * is the wHint passed into Control.computeSize(int, int, bool)
     * to determine the preferred size of the control.
     *
     * The default value is SWT.DEFAULT.
     *
     * @see org.eclipse.swt.widgets.Control#computeSize(int, int, bool)
     */
    public int width = SWT.DEFAULT;
    /**
     * height specifies the preferred height in pixels. This value
     * is the hHint passed into Control.computeSize(int, int, bool)
     * to determine the preferred size of the control.
     *
     * The default value is SWT.DEFAULT.
     *
     * @see org.eclipse.swt.widgets.Control#computeSize(int, int, bool)
     */
    public int height = SWT.DEFAULT;

    /**
     * exclude informs the layout to ignore this control when sizing
     * and positioning controls.  If this value is <code>true</code>,
     * the size and position of the control will not be managed by the
     * layout.  If this value is <code>false</code>, the size and
     * position of the control will be computed and assigned.
     *
     * The default value is <code>false</code>.
     *
     * @since 3.1
     */
    public bool exclude = false;

/**
 * Constructs a new instance of RowData using
 * default values.
 */
public this () {
}

/**
 * Constructs a new instance of RowData according to the parameters.
 * A value of SWT.DEFAULT indicates that no minimum width or
 * no minimum height is specified.
 *
 * @param width a minimum width for the control
 * @param height a minimum height for the control
 */
public this (int width, int height) {
    this.width = width;
    this.height = height;
}

/**
 * Constructs a new instance of RowData according to the parameter.
 * A value of SWT.DEFAULT indicates that no minimum width or
 * no minimum height is specified.
 *
 * @param point a point whose x coordinate specifies a minimum width for the control
 * and y coordinate specifies a minimum height for the control
 */
public this (Point point) {
    this (point.x, point.y);
}

String getName () {
    String string = this.classinfo.name;
    int index = string.lastIndexOf('.');
    if (index is -1 ) return string;
    return string[ index + 1 .. string.length ];
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the RowData object
 */
override public String toString () {
    String string = getName ()~" {";
    if (width !is SWT.DEFAULT) string ~= "width="~String_valueOf(width)~" ";
    if (height !is SWT.DEFAULT) string ~= "height="~String_valueOf(height)~" ";
    if (exclude) string ~= "exclude="~String_valueOf(exclude)~" ";
    string = string.trim();
    string ~= "}";
    return string;
}
}
