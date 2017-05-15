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
module org.eclipse.swt.layout.FormData;


import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.layout.FormAttachment;

import java.lang.all;

/**
 * Instances of this class are used to define the attachments
 * of a control in a <code>FormLayout</code>.
 * <p>
 * To set a <code>FormData</code> object into a control, you use the
 * <code>setLayoutData ()</code> method. To define attachments for the
 * <code>FormData</code>, set the fields directly, like this:
 * <pre>
 *      FormData data = new FormData();
 *      data.left = new FormAttachment(0,5);
 *      data.right = new FormAttachment(100,-5);
 *      button.setLayoutData(formData);
 * </pre>
 * </p>
 * <p>
 * <code>FormData</code> contains the <code>FormAttachments</code> for
 * each edge of the control that the <code>FormLayout</code> uses to
 * determine the size and position of the control. <code>FormData</code>
 * objects also allow you to set the width and height of controls within
 * a <code>FormLayout</code>.
 * </p>
 *
 * @see FormLayout
 * @see FormAttachment
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 2.0
 */
public final class FormData {
    /**
     * width specifies the preferred width in pixels. This value
     * is the wHint passed into Control.computeSize(int, int, bool)
     * to determine the preferred size of the control.
     *
     * The default value is SWT.DEFAULT.
     *
     * @see Control#computeSize(int, int, bool)
     */
    public int width = SWT.DEFAULT;
    /**
     * height specifies the preferred height in pixels. This value
     * is the hHint passed into Control.computeSize(int, int, bool)
     * to determine the preferred size of the control.
     *
     * The default value is SWT.DEFAULT.
     *
     * @see Control#computeSize(int, int, bool)
     */
    public int height = SWT.DEFAULT;
    /**
     * left specifies the attachment of the left side of
     * the control.
     */
    public FormAttachment left;
    /**
     * right specifies the attachment of the right side of
     * the control.
     */
    public FormAttachment right;
    /**
     * top specifies the attachment of the top of the control.
     */
    public FormAttachment top;
    /**
     * bottom specifies the attachment of the bottom of the
     * control.
     */
    public FormAttachment bottom;

    int cacheWidth = -1, cacheHeight = -1;
    int defaultWhint, defaultHhint, defaultWidth = -1, defaultHeight = -1;
    int currentWhint, currentHhint, currentWidth = -1, currentHeight = -1;
    FormAttachment cacheLeft, cacheRight, cacheTop, cacheBottom;
    bool isVisited, needed;

/**
 * Constructs a new instance of FormData using
 * default values.
 */
public this () {
}

/**
 * Constructs a new instance of FormData according to the parameters.
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

void computeSize (Control control, int wHint, int hHint, bool flushCache_) {
    if (cacheWidth !is -1 && cacheHeight !is -1) return;
    if (wHint is this.width && hHint is this.height) {
        if (defaultWidth is -1 || defaultHeight is -1 || wHint !is defaultWhint || hHint !is defaultHhint) {
            Point size =  control.computeSize (wHint, hHint, flushCache_);
            defaultWhint = wHint;
            defaultHhint = hHint;
            defaultWidth = size.x;
            defaultHeight = size.y;
        }
        cacheWidth = defaultWidth;
        cacheHeight = defaultHeight;
        return;
    }
    if (currentWidth is -1 || currentHeight is -1 || wHint !is currentWhint || hHint !is currentHhint) {
        Point size =  control.computeSize (wHint, hHint, flushCache_);
        currentWhint = wHint;
        currentHhint = hHint;
        currentWidth = size.x;
        currentHeight = size.y;
    }
    cacheWidth = currentWidth;
    cacheHeight = currentHeight;
}

void flushCache () {
    cacheWidth = cacheHeight = -1;
    defaultHeight = defaultWidth = -1;
    currentHeight = currentWidth = -1;
}

int getWidth (Control control, bool flushCache) {
    needed = true;
    computeSize (control, width, height, flushCache);
    return cacheWidth;
}

int getHeight (Control control, bool flushCache) {
    computeSize (control, width, height, flushCache);
    return cacheHeight;
}

FormAttachment getBottomAttachment (Control control, int spacing, bool flushCache) {
    if (cacheBottom !is null) return cacheBottom;
    if (isVisited) return cacheBottom = new FormAttachment (0, getHeight (control, flushCache));
    if (bottom is null) {
        if (top is null) return cacheBottom = new FormAttachment (0, getHeight (control, flushCache));
        return cacheBottom = getTopAttachment (control, spacing, flushCache).plus (getHeight (control, flushCache));
    }
    Control bottomControl = bottom.control;
    if (bottomControl !is null) {
        if (bottomControl.isDisposed ()) {
            bottom.control = bottomControl = null;
        } else {
            if (bottomControl.getParent () !is control.getParent ()) {
                bottomControl = null;
            }
        }
    }
    if (bottomControl is null) return cacheBottom = bottom;
    isVisited = true;
    FormData bottomData = cast(FormData) bottomControl.getLayoutData ();
    FormAttachment bottomAttachment = bottomData.getBottomAttachment (bottomControl, spacing, flushCache);
    switch (bottom.alignment) {
        case SWT.BOTTOM:
            cacheBottom = bottomAttachment.plus (bottom.offset);
            break;
        case SWT.CENTER: {
            FormAttachment topAttachment = bottomData.getTopAttachment (bottomControl, spacing, flushCache);
            FormAttachment bottomHeight = bottomAttachment.minus (topAttachment);
            cacheBottom = bottomAttachment.minus (bottomHeight.minus (getHeight (control, flushCache)).divide (2));
            break;
        }
        default: {
            FormAttachment topAttachment = bottomData.getTopAttachment (bottomControl, spacing, flushCache);
            cacheBottom = topAttachment.plus (bottom.offset - spacing);
            break;
        }
    }
    isVisited = false;
    return cacheBottom;
}

FormAttachment getLeftAttachment (Control control, int spacing, bool flushCache) {
    if (cacheLeft !is null) return cacheLeft;
    if (isVisited) return cacheLeft = new FormAttachment (0, 0);
    if (left is null) {
        if (right is null) return cacheLeft = new FormAttachment (0, 0);
        return cacheLeft = getRightAttachment (control, spacing, flushCache).minus (getWidth (control, flushCache));
    }
    Control leftControl = left.control;
    if (leftControl !is null) {
        if (leftControl.isDisposed ()) {
            left.control = leftControl = null;
        } else {
            if (leftControl.getParent () !is control.getParent ()) {
                leftControl = null;
            }
        }
    }
    if (leftControl is null) return cacheLeft = left;
    isVisited = true;
    FormData leftData = cast(FormData) leftControl.getLayoutData ();
    FormAttachment leftAttachment = leftData.getLeftAttachment (leftControl, spacing, flushCache);
    switch (left.alignment) {
        case SWT.LEFT:
            cacheLeft = leftAttachment.plus (left.offset);
            break;
        case SWT.CENTER: {
            FormAttachment rightAttachment = leftData.getRightAttachment (leftControl, spacing, flushCache);
            FormAttachment leftWidth = rightAttachment.minus (leftAttachment);
            cacheLeft = leftAttachment.plus (leftWidth.minus (getWidth (control, flushCache)).divide (2));
            break;
        }
        default: {
            FormAttachment rightAttachment = leftData.getRightAttachment (leftControl, spacing, flushCache);
            cacheLeft = rightAttachment.plus (left.offset + spacing);
        }
    }
    isVisited = false;
    return cacheLeft;
}

String getName () {
    String string = this.classinfo.name;
    int index = string.lastIndexOf( '.');
    if (index is -1 ) return string;
    return string[ index + 1 .. string.length ];
}

FormAttachment getRightAttachment (Control control, int spacing, bool flushCache) {
    if (cacheRight !is null) return cacheRight;
    if (isVisited) return cacheRight = new FormAttachment (0, getWidth (control, flushCache));
    if (right is null) {
        if (left is null) return cacheRight = new FormAttachment (0, getWidth (control, flushCache));
        return cacheRight = getLeftAttachment (control, spacing, flushCache).plus (getWidth (control, flushCache));
    }
    Control rightControl = right.control;
    if (rightControl !is null) {
        if (rightControl.isDisposed ()) {
            right.control = rightControl = null;
        } else {
            if (rightControl.getParent () !is control.getParent ()) {
                rightControl = null;
            }
        }
    }
    if (rightControl is null) return cacheRight = right;
    isVisited = true;
    FormData rightData = cast(FormData) rightControl.getLayoutData ();
    FormAttachment rightAttachment = rightData.getRightAttachment (rightControl, spacing, flushCache);
    switch (right.alignment) {
        case SWT.RIGHT:
            cacheRight = rightAttachment.plus (right.offset);
            break;
        case SWT.CENTER: {
            FormAttachment leftAttachment = rightData.getLeftAttachment (rightControl, spacing, flushCache);
            FormAttachment rightWidth = rightAttachment.minus (leftAttachment);
            cacheRight = rightAttachment.minus (rightWidth.minus (getWidth (control, flushCache)).divide (2));
            break;
        }
        default: {
            FormAttachment leftAttachment = rightData.getLeftAttachment (rightControl, spacing, flushCache);
            cacheRight = leftAttachment.plus (right.offset - spacing);
            break;
        }
    }
    isVisited = false;
    return cacheRight;
}

FormAttachment getTopAttachment (Control control, int spacing, bool flushCache) {
    if (cacheTop !is null) return cacheTop;
    if (isVisited) return cacheTop = new FormAttachment (0, 0);
    if (top is null) {
        if (bottom is null) return cacheTop = new FormAttachment (0, 0);
        return cacheTop = getBottomAttachment (control, spacing, flushCache).minus (getHeight (control, flushCache));
    }
    Control topControl = top.control;
    if (topControl !is null) {
        if (topControl.isDisposed ()) {
            top.control = topControl = null;
        } else {
            if (topControl.getParent () !is control.getParent ()) {
                topControl = null;
            }
        }
    }
    if (topControl is null) return cacheTop = top;
    isVisited = true;
    FormData topData = cast(FormData) topControl.getLayoutData ();
    FormAttachment topAttachment = topData.getTopAttachment (topControl, spacing, flushCache);
    switch (top.alignment) {
        case SWT.TOP:
            cacheTop = topAttachment.plus (top.offset);
            break;
        case SWT.CENTER: {
            FormAttachment bottomAttachment = topData.getBottomAttachment (topControl, spacing, flushCache);
            FormAttachment topHeight = bottomAttachment.minus (topAttachment);
            cacheTop = topAttachment.plus (topHeight.minus (getHeight (control, flushCache)).divide (2));
            break;
        }
        default: {
            FormAttachment bottomAttachment = topData.getBottomAttachment (topControl, spacing, flushCache);
            cacheTop = bottomAttachment.plus (top.offset + spacing);
            break;
        }
    }
    isVisited = false;
    return cacheTop;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the FormData object
 */
override public String toString () {
    String string = getName()~" {";
    if (width !is SWT.DEFAULT) string ~= "width="~String_valueOf(width)~" ";
    if (height !is SWT.DEFAULT) string ~= "height="~String_valueOf(height)~" ";
    if (left !is null) string ~= "left="~String_valueOf(left)~" ";
    if (right !is null) string ~= "right="~String_valueOf(right)~" ";
    if (top !is null) string ~= "top="~String_valueOf(top)~" ";
    if (bottom !is null) string ~= "bottom="~String_valueOf(bottom)~" ";
    string = string.trim();
    string ~= "}";
    return string;
}

}
