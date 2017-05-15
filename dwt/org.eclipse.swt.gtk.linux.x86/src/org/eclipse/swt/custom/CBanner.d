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
module org.eclipse.swt.custom.CBanner;

import java.lang.all;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Layout;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.custom.CBannerLayout;



/**
 * Instances of this class implement a Composite that lays out its
 * children and allows programmatic control of the layout. It draws
 * a separator between the left and right children which can be dragged
 * to resize the right control.
 * CBanner is used in the workbench to layout the toolbar area and
 * perspective switching toolbar.
 * <p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to set a layout on it.
 * </p><p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>NONE</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(None)</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.0
 */

public class CBanner : Composite {

    Control left;
    Control right;
    Control bottom;

    bool simple = true;

    int[] curve;
    int curveStart = 0;
    Rectangle curveRect;
    int curve_width = 5;
    int curve_indent = -2;

    int rightWidth = SWT.DEFAULT;
    int rightMinWidth = 0;
    int rightMinHeight = 0;
    Cursor resizeCursor;
    bool dragging = false;
    int rightDragDisplacement = 0;

    static const int OFFSCREEN = -200;
    static const int BORDER_BOTTOM = 2;
    static const int BORDER_TOP = 3;
    static const int BORDER_STRIPE = 1;
    static const int CURVE_TAIL = 200;
    static const int BEZIER_RIGHT = 30;
    static const int BEZIER_LEFT = 30;
    static const int MIN_LEFT = 10;
    static int BORDER1 = SWT.COLOR_WIDGET_HIGHLIGHT_SHADOW;


/**
 * Constructs a new instance of this class given its parent
 * and a style value describing its behavior and appearance.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>SWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>SWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 * </p>
 *
 * @param parent a widget which will be the parent of the new instance (cannot be null)
 * @param style the style of widget to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 *
 */
public this(Composite parent, int style) {
    curveRect = new Rectangle(0, 0, 0, 0);
    super(parent, checkStyle(style));
    super.setLayout(new CBannerLayout());
    resizeCursor = new Cursor(getDisplay(), SWT.CURSOR_SIZEWE);

    Listener listener = new class() Listener {
        public void handleEvent(Event e) {
            switch (e.type) {
                case SWT.Dispose:
                    onDispose(); break;
                case SWT.MouseDown:
                    onMouseDown (e.x, e.y); break;
                case SWT.MouseExit:
                    onMouseExit(); break;
                case SWT.MouseMove:
                    onMouseMove(e.x, e.y); break;
                case SWT.MouseUp:
                    onMouseUp(); break;
                case SWT.Paint:
                    onPaint(e.gc); break;
                case SWT.Resize:
                    onResize(); break;
                default:
            }
        }
    };
    int[] events = [SWT.Dispose, SWT.MouseDown, SWT.MouseExit, SWT.MouseMove, SWT.MouseUp, SWT.Paint, SWT.Resize];
    for (int i = 0; i < events.length; i++) {
        addListener(events[i], listener);
    }
}
static int[] bezier(int x0, int y0, int x1, int y1, int x2, int y2, int x3, int y3, int count) {
    // The parametric equations for a Bezier curve for x[t] and y[t] where  0 <= t <=1 are:
    // x[t] = x0+3(x1-x0)t+3(x0+x2-2x1)t^2+(x3-x0+3x1-3x2)t^3
    // y[t] = y0+3(y1-y0)t+3(y0+y2-2y1)t^2+(y3-y0+3y1-3y2)t^3
    double a0 = x0;
    double a1 = 3*(x1 - x0);
    double a2 = 3*(x0 + x2 - 2*x1);
    double a3 = x3 - x0 + 3*x1 - 3*x2;
    double b0 = y0;
    double b1 = 3*(y1 - y0);
    double b2 = 3*(y0 + y2 - 2*y1);
    double b3 = y3 - y0 + 3*y1 - 3*y2;

    int[] polygon = new int[2*count + 2];
    for (int i = 0; i <= count; i++) {
        double t = cast(double)i / cast(double)count;
        polygon[2*i] = cast(int)(a0 + a1*t + a2*t*t + a3*t*t*t);
        polygon[2*i + 1] = cast(int)(b0 + b1*t + b2*t*t + b3*t*t*t);
    }
    return polygon;
}
static int checkStyle (int style) {
    return SWT.NONE;
}
/**
* Returns the Control that appears on the bottom side of the banner.
*
* @return the control that appears on the bottom side of the banner or null
*
* @exception SWTException <ul>
*    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
*    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
* </ul>
*
* @since 3.0
*/
public Control getBottom() {
    checkWidget();
    return bottom;
}
public override Rectangle getClientArea() {
    return new Rectangle(0, 0, 0, 0);
}

/**
* Returns the Control that appears on the left side of the banner.
*
* @return the control that appears on the left side of the banner or null
*
* @exception SWTException <ul>
*    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
*    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
* </ul>
*
* @since 3.0
*/
public Control getLeft() {
    checkWidget();
    return left;
}

/**
* Returns the Control that appears on the right side of the banner.
*
* @return the control that appears on the right side of the banner or null
*
* @exception SWTException <ul>
*    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
*    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
* </ul>
*
* @since 3.0
*/
public Control getRight() {
    checkWidget();
    return right;
}
/**
 * Returns the minimum size of the control that appears on the right of the banner.
 *
 * @return the minimum size of the control that appears on the right of the banner
 *
 * @since 3.1
 */
public Point getRightMinimumSize() {
    checkWidget();
    return new Point(rightMinWidth, rightMinHeight);
}
/**
 * Returns the width of the control that appears on the right of the banner.
 *
 * @return the width of the control that appears on the right of the banner
 *
 * @since 3.0
 */
public int getRightWidth() {
    checkWidget();
    if (right is null) return 0;
    if (rightWidth is SWT.DEFAULT) {
        Point size = right.computeSize(SWT.DEFAULT, SWT.DEFAULT, false);
        return size.x;
    }
    return rightWidth;
}
/**
 * Returns <code>true</code> if the CBanner is rendered
 * with a simple, traditional shape.
 *
 * @return <code>true</code> if the CBanner is rendered with a simple shape
 *
 * @since 3.0
 */
public bool getSimple() {
    checkWidget();
    return simple;
}
void onDispose() {
    if (resizeCursor !is null) resizeCursor.dispose();
    resizeCursor = null;
    left = null;
    right = null;
    bottom = null;
}
void onMouseDown (int x, int y) {
    if (curveRect.contains(x, y)) {
        dragging = true;
        rightDragDisplacement = curveStart - x + curve_width - curve_indent;
    }
}
void onMouseExit() {
    if (!dragging) setCursor(null);
}
void onMouseMove(int x, int y) {
    if (dragging) {
        Point size = getSize();
        if (!(0 < x && x < size.x)) return;
        rightWidth = Math.max(0, size.x - x - rightDragDisplacement);
        if (rightMinWidth is SWT.DEFAULT) {
            Point minSize = right.computeSize(rightMinWidth, rightMinHeight);
            rightWidth = Math.max(minSize.x, rightWidth);
        } else {
            rightWidth = Math.max(rightMinWidth, rightWidth);
        }
        layout(false);
        return;
    }
    if (curveRect.contains(x, y)) {
        setCursor(resizeCursor);
    } else {
        setCursor(null);
    }
}
void onMouseUp () {
    dragging = false;
}
void onPaint(GC gc) {
//   Useful for debugging paint problems
//  {
//  Point size = getSize();
//  gc.setBackground(getDisplay().getSystemColor(SWT.COLOR_GREEN));
//  gc.fillRectangle(-10, -10, size.x+20, size.y+20);
//  }
    if (left is null && right is null) return;
    Point size = getSize();
    Color border1 = getDisplay().getSystemColor(BORDER1);
    if (bottom !is null) {
        int y = bottom.getBounds().y - BORDER_STRIPE - 1;
        gc.setForeground(border1);
        gc.drawLine(0, y, size.x, y);
    }
    if (left is null || right is null) return;
    int[] line1 = new int[curve.length+6];
    int index = 0;
    int x = curveStart;
    line1[index++] = x + 1;
    line1[index++] = size.y - BORDER_STRIPE;
    for (int i = 0; i < curve.length/2; i++) {
        line1[index++]=x+curve[2*i];
        line1[index++]=curve[2*i+1];
    }
    line1[index++] = x + curve_width;
    line1[index++] = 0;
    line1[index++] = size.x;
    line1[index++] = 0;

    Color background = getBackground();

    if (getDisplay().getDepth() >= 15) {
        // Anti- aliasing
        int[] line2 = new int[line1.length];
        index = 0;
        for (int i = 0; i < line1.length/2; i++) {
            line2[index] = line1[index++]  - 1;
            line2[index] = line1[index++];
        }
        int[] line3 = new int[line1.length];
        index = 0;
        for (int i = 0; i < line1.length/2; i++) {
            line3[index] = line1[index++] + 1;
            line3[index] = line1[index++];
        }
        RGB from = border1.getRGB();
        RGB to = background.getRGB();
        int red = from.red + 3*(to.red - from.red)/4;
        int green = from.green + 3*(to.green - from.green)/4;
        int blue = from.blue + 3*(to.blue - from.blue)/4;
        Color color = new Color(getDisplay(), red, green, blue);
        gc.setForeground(color);
        gc.drawPolyline(line2);
        gc.drawPolyline(line3);
        color.dispose();

        // draw tail fading to background
        int x1 = Math.max(0, curveStart - CURVE_TAIL);
        gc.setForeground(background);
        gc.setBackground(border1);
        gc.fillGradientRectangle(x1, size.y - BORDER_STRIPE, curveStart-x1+1, 1, false);
    } else {
        // draw solid tail
        int x1 = Math.max(0, curveStart - CURVE_TAIL);
        gc.setForeground(border1);
        gc.drawLine(x1, size.y - BORDER_STRIPE, curveStart+1, size.y - BORDER_STRIPE);
    }

    // draw border
    gc.setForeground(border1);
    gc.drawPolyline(line1);
}

void onResize() {
    updateCurve(getSize().y);
}
/**
* Set the control that appears on the bottom side of the banner.
* The bottom control is optional.  Setting the bottom control to null will remove it from
* the banner - however, the creator of the control must dispose of the control.
*
* @param control the control to be displayed on the bottom or null
*
* @exception SWTException <ul>
*    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
*    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
*    <li>ERROR_INVALID_ARGUMENT - if the bottom control was not created as a child of the receiver</li>
* </ul>
*
* @since 3.0
*/
public void setBottom(Control control) {
    checkWidget();
    if (control !is null && control.getParent() !is this) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    if (bottom !is null && !bottom.isDisposed()) {
        Point size = bottom.getSize();
        bottom.setLocation(OFFSCREEN - size.x, OFFSCREEN - size.y);
    }
    bottom = control;
    layout(false);
}
/**
 * Sets the layout which is associated with the receiver to be
 * the argument which may be null.
 * <p>
 * Note: No Layout can be set on this Control because it already
 * manages the size and position of its children.
 * </p>
 *
 * @param layout the receiver's new layout or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public override void setLayout (Layout layout) {
    checkWidget();
    return;
}

/**
* Set the control that appears on the left side of the banner.
* The left control is optional.  Setting the left control to null will remove it from
* the banner - however, the creator of the control must dispose of the control.
*
* @param control the control to be displayed on the left or null
*
* @exception SWTException <ul>
*    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
*    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
*    <li>ERROR_INVALID_ARGUMENT - if the left control was not created as a child of the receiver</li>
* </ul>
*
* @since 3.0
*/
public void setLeft(Control control) {
    checkWidget();
    if (control !is null && control.getParent() !is this) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    if (left !is null && !left.isDisposed()) {
        Point size = left.getSize();
        left.setLocation(OFFSCREEN - size.x, OFFSCREEN - size.y);
    }
    left = control;
    layout(false);
}
/**
* Set the control that appears on the right side of the banner.
* The right control is optional.  Setting the right control to null will remove it from
* the banner - however, the creator of the control must dispose of the control.
*
* @param control the control to be displayed on the right or null
*
* @exception SWTException <ul>
*    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
*    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
*    <li>ERROR_INVALID_ARGUMENT - if the right control was not created as a child of the receiver</li>
* </ul>
*
* @since 3.0
*/
public void setRight(Control control) {
    checkWidget();
    if (control !is null && control.getParent() !is this) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    if (right !is null && !right.isDisposed()) {
        Point size = right.getSize();
        right.setLocation(OFFSCREEN - size.x, OFFSCREEN - size.y);
    }
    right = control;
    layout(false);
}
/**
 * Set the minimum height of the control that appears on the right side of the banner.
 *
 * @param size the minimum size of the control on the right
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the size is null or the values of size are less than SWT.DEFAULT</li>
 * </ul>
 *
 * @since 3.1
 */
public void setRightMinimumSize(Point size) {
    checkWidget();
    if (size is null || size.x < SWT.DEFAULT || size.y < SWT.DEFAULT) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    rightMinWidth = size.x;
    rightMinHeight = size.y;
    layout(false);
}
/**
 * Set the width of the control that appears on the right side of the banner.
 *
 * @param width the width of the control on the right
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 *    <li>ERROR_INVALID_ARGUMENT - if width is less than SWT.DEFAULT</li>
 * </ul>
 *
 * @since 3.0
 */
public void setRightWidth(int width) {
    checkWidget();
    if (width < SWT.DEFAULT) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    rightWidth = width;
    layout(false);
}
/**
 * Sets the shape that the CBanner will use to render itself.
 *
 * @param simple <code>true</code> if the CBanner should render itself in a simple, traditional style
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setSimple(bool simple) {
    checkWidget();
    if (this.simple !is simple) {
        this.simple = simple;
        if (simple) {
            curve_width = 5;
            curve_indent = -2;
        } else {
            curve_width = 50;
            curve_indent = 5;
        }
        updateCurve(getSize().y);
        layout(false);
        redraw();
    }
}
void updateCurve(int height) {
    int h = height - BORDER_STRIPE;
    if (simple) {
        curve = [0,h, 1,h, 2,h-1, 3,h-2,
                                   3,2, 4,1, 5,0];
    } else {
        curve = bezier(0, h+1, BEZIER_LEFT, h+1,
                             curve_width-BEZIER_RIGHT, 0, curve_width, 0,
                             curve_width);
    }
}
}
