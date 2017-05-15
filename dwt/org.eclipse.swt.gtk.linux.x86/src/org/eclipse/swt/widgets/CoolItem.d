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
module org.eclipse.swt.widgets.CoolItem;

import java.lang.all;
import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.CoolBar;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.ToolItem;
import org.eclipse.swt.widgets.Listener;

/**
 * Instances of this class are selectable user interface
 * objects that represent the dynamically positionable
 * areas of a <code>CoolBar</code>.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>DROP_DOWN</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 * 
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class CoolItem : Item {
    Control control;
    CoolBar parent;
    bool ideal;
    int preferredWidth, preferredHeight, minimumWidth, minimumHeight, requestedWidth;
    Rectangle itemBounds;

    static const int MARGIN_WIDTH = 4;
    static const int GRABBER_WIDTH = 2;
    static const int MINIMUM_WIDTH = (2 * MARGIN_WIDTH) + GRABBER_WIDTH;

    private int CHEVRON_HORIZONTAL_TRIM = -1;           //platform dependent values
    private int CHEVRON_VERTICAL_TRIM = -1;
    private static const int CHEVRON_LEFT_MARGIN = 2;
    private static const int CHEVRON_IMAGE_WIDTH = 8;   //Width to draw the double arrow

    ToolBar chevron;
    bool wrap;
    Image arrowImage = null;

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>CoolBar</code>) and a style value
 * describing its behavior and appearance. The item is added
 * to the end of the items maintained by its parent.
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
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#DROP_DOWN
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (CoolBar parent, int style) {
    super(parent, style);
    itemBounds = new Rectangle(0, 0, 0, 0);
    this.parent = parent;
    parent.createItem (this, parent.getItemCount());
    calculateChevronTrim ();
}
/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>CoolBar</code>), a style value
 * describing its behavior and appearance, and the index
 * at which to place it in the items maintained by its parent.
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
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 * @param index the zero-relative index at which to store the receiver in its parent
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the parent (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#DROP_DOWN
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (CoolBar parent, int style, int index) {
    super(parent, style);
    itemBounds = new Rectangle(0, 0, 0, 0);
    this.parent = parent;
    parent.createItem (this, index);
    calculateChevronTrim ();
}
/**
 * Adds the listener to the collection of listeners that will
 * be notified when the control is selected by the user, by sending it one
 * of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * If <code>widgetSelected</code> is called when the mouse is over
 * the drop-down arrow (or 'chevron') portion of the cool item,
 * the event object detail field contains the value <code>SWT.ARROW</code>,
 * and the x and y fields in the event object represent the point at
 * the bottom left of the chevron, where the menu should be popped up.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
 *
 * @param listener the listener which should be notified when the control is selected by the user
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SelectionListener
 * @see #removeSelectionListener
 * @see SelectionEvent
 *
 * @since 2.0
 */
public void addSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
}
protected override void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}
/*
 * Find the trim size of the Toolbar widget in the current platform.
 */
void calculateChevronTrim () {
    ToolBar tb = new ToolBar (parent, SWT.FLAT);
    ToolItem ti = new ToolItem (tb, SWT.PUSH);
    Image image = new Image (display, 1, 1);
    ti.setImage (image);
    Point size = tb.computeSize (SWT.DEFAULT, SWT.DEFAULT);
    size = parent.fixPoint(size.x, size.y);
    CHEVRON_HORIZONTAL_TRIM = size.x - 1;
    CHEVRON_VERTICAL_TRIM = size.y - 1;
    tb.dispose ();
    ti.dispose ();
    image.dispose ();
}
/**
 * Returns the preferred size of the receiver.
 * <p>
 * The <em>preferred size</em> of a <code>CoolItem</code> is the size that
 * it would best be displayed at. The width hint and height hint arguments
 * allow the caller to ask the instance questions such as "Given a particular
 * width, how high does it need to be to show all of the contents?"
 * To indicate that the caller does not wish to constrain a particular
 * dimension, the constant <code>SWT.DEFAULT</code> is passed for the hint.
 * </p>
 *
 * @param wHint the width hint (can be <code>SWT.DEFAULT</code>)
 * @param hHint the height hint (can be <code>SWT.DEFAULT</code>)
 * @return the preferred size
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Layout
 * @see #getBounds
 * @see #getSize
 * @see Control#getBorderWidth
 * @see Scrollable#computeTrim
 * @see Scrollable#getClientArea
 */
public Point computeSize (int wHint, int hHint) {
    checkWidget();
    int width = wHint, height = hHint;
    if (wHint is SWT.DEFAULT) width = 32;
    if (hHint is SWT.DEFAULT) height = 32;
    if ((parent.style & SWT.VERTICAL) !is 0) {
        height += MINIMUM_WIDTH;
    } else {
        width += MINIMUM_WIDTH;
    }
    return new Point (width, height);
}
public override void dispose () {
    if (isDisposed()) return;

    /*
     * Must call parent.destroyItem() before super.dispose(), since it needs to
     * query the bounds to properly remove the item.
     */
    parent.destroyItem(this);
    super.dispose ();
    parent = null;
    control = null;

    /*
     * Although the parent for the chevron is the CoolBar (CoolItem can not be the parent)
     * it has to be disposed with the item
     */
    if (chevron !is null && !chevron.isDisposed()) chevron.dispose();
    chevron = null;
    if (arrowImage !is null && !arrowImage.isDisposed()) arrowImage.dispose();
    arrowImage = null;
}

Image createArrowImage (int width, int height) {
    Point point = parent.fixPoint(width, height);
    width = point.x;
    height = point.y;
    Color foreground = parent.getForeground ();
    Color black = display.getSystemColor (SWT.COLOR_BLACK);
    Color background = parent.getBackground ();

    PaletteData palette = new PaletteData ( [foreground.getRGB(), background.getRGB(), black.getRGB() ] );
    ImageData imageData = new ImageData (width, height, 4, palette);
    imageData.transparentPixel = 1;
    Image image = new Image (display, imageData);

    GC gc = new GC (image, parent.getStyle() & SWT.RIGHT_TO_LEFT);
    gc.setBackground (background);
    gc.fillRectangle (0, 0, width, height);
    gc.setForeground (black);

    int startX = 0 ;
    if ((parent.style & SWT.VERTICAL) !is 0) {
        startX = width - CHEVRON_IMAGE_WIDTH;
    }
    int startY = height / 6;
    int step = 2;
    gc.drawLine (startX, startY, startX + step, startY + step);
    gc.drawLine (startX, startY + (2 * step), startX + step, startY + step);
    startX++;
    gc.drawLine (startX, startY, startX + step, startY + step);
    gc.drawLine (startX, startY + (2 * step), startX + step, startY + step);
    startX += 3;
    gc.drawLine (startX, startY, startX + step, startY + step);
    gc.drawLine (startX, startY + (2 * step), startX + step, startY + step);
    startX++;
    gc.drawLine (startX, startY, startX + step, startY + step);
    gc.drawLine (startX, startY + (2 * step), startX + step, startY + step);
    gc.dispose ();
    return image;
}
/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent.
 *
 * @return the receiver's bounding rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Rectangle getBounds () {
    checkWidget();
    return parent.fixRectangle(itemBounds.x, itemBounds.y, itemBounds.width, itemBounds.height);
}
Rectangle internalGetBounds () {
    return new Rectangle(itemBounds.x, itemBounds.y, itemBounds.width, itemBounds.height);
}
/**
 * Returns the control that is associated with the receiver.
 *
 * @return the control that is contained by the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Control getControl () {
    checkWidget();
    return control;
}
/**
 * Returns the minimum size that the cool item can
 * be resized to using the cool item's gripper.
 *
 * @return a point containing the minimum width and height of the cool item, in pixels
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 */
public Point getMinimumSize () {
    checkWidget();
    return parent.fixPoint(minimumWidth, minimumHeight);
}
/**
 * Returns the receiver's parent, which must be a <code>CoolBar</code>.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public CoolBar getParent () {
    checkWidget();
    return parent;
}
/**
 * Returns a point describing the receiver's ideal size.
 * The x coordinate of the result is the ideal width of the receiver.
 * The y coordinate of the result is the ideal height of the receiver.
 *
 * @return the receiver's ideal size
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getPreferredSize () {
    checkWidget();
    return parent.fixPoint(preferredWidth, preferredHeight);
}
/**
 * Returns a point describing the receiver's size. The
 * x coordinate of the result is the width of the receiver.
 * The y coordinate of the result is the height of the
 * receiver.
 *
 * @return the receiver's size
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getSize () {
    checkWidget();
    return parent.fixPoint(itemBounds.width, itemBounds.height);
}
int internalGetMinimumWidth () {
    int width = minimumWidth + MINIMUM_WIDTH;
    if ((style & SWT.DROP_DOWN) !is 0 && width < preferredWidth) {
        width += CHEVRON_IMAGE_WIDTH + CHEVRON_HORIZONTAL_TRIM + CHEVRON_LEFT_MARGIN;
    }
    return width;
}
/*
 *  Called when the chevron is selected.
 */
void onSelection (Event ev) {
    Rectangle bounds = chevron.getBounds();
    Event event = new Event();
    event.detail = SWT.ARROW;
    if ((parent.style & SWT.VERTICAL) !is 0) {
        event.x = bounds.x + bounds.width;
        event.y = bounds.y;
    } else {
        event.x = bounds.x;
        event.y = bounds.y + bounds.height;
    }
    postEvent (SWT.Selection, event);
}
/**
 * Removes the listener from the collection of listeners that
 * will be notified when the control is selected by the user.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SelectionListener
 * @see #addSelectionListener
 *
 * @since 2.0
 */
public void removeSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Selection, listener);
    eventTable.unhook (SWT.DefaultSelection,listener);
}
void setBounds (int x, int y, int width, int height) {
    itemBounds.x = x;
    itemBounds.y = y;
    itemBounds.width = width;
    itemBounds.height = height;
    if (control !is null) {
        int controlWidth = width - MINIMUM_WIDTH;
        if ((style & SWT.DROP_DOWN) !is 0 && width < preferredWidth) {
            controlWidth -= CHEVRON_IMAGE_WIDTH + CHEVRON_HORIZONTAL_TRIM + CHEVRON_LEFT_MARGIN;
        }
        control.setBounds (parent.fixRectangle(x + MINIMUM_WIDTH,   y, controlWidth, height));
    }
    updateChevron();
}
/**
 * Sets the control that is associated with the receiver
 * to the argument.
 *
 * @param control the new control that will be contained by the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the control has been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if the control is not in the same widget tree</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setControl (Control control) {
    checkWidget();
    if (control !is null) {
        if (control.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);
        if (control.parent !is parent) error (SWT.ERROR_INVALID_PARENT);
    }
    this.control = control;
    if (control !is null) {
        int controlWidth = itemBounds.width - MINIMUM_WIDTH;
        if ((style & SWT.DROP_DOWN) !is 0 && itemBounds.width < preferredWidth) {
            controlWidth -= CHEVRON_IMAGE_WIDTH + CHEVRON_HORIZONTAL_TRIM + CHEVRON_LEFT_MARGIN;
        }
        control.setBounds (parent.fixRectangle(itemBounds.x + MINIMUM_WIDTH, itemBounds.y, controlWidth, itemBounds.height));
    }
}
/**
 * Sets the minimum size that the cool item can be resized to
 * using the cool item's gripper, to the point specified by the arguments.
 *
 * @param width the minimum width of the cool item, in pixels
 * @param height the minimum height of the cool item, in pixels
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 */
public void setMinimumSize (int width, int height) {
    checkWidget ();
    Point point = parent.fixPoint(width, height);
    minimumWidth = point.x;
    minimumHeight = point.y;
}
/**
 * Sets the minimum size that the cool item can be resized to
 * using the cool item's gripper, to the point specified by the argument.
 *
 * @param size a point representing the minimum width and height of the cool item, in pixels
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.0
 */
public void setMinimumSize (Point size) {
    checkWidget ();
    if (size is null) error(SWT.ERROR_NULL_ARGUMENT);
    setMinimumSize(size.x, size.y);
}
/**
 * Sets the receiver's ideal size to the point specified by the arguments.
 *
 * @param width the new ideal width for the receiver
 * @param height the new ideal height for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setPreferredSize (int width, int height) {
    checkWidget();
    ideal = true;
    Point point = parent.fixPoint(width, height);
    preferredWidth = Math.max (point.x, MINIMUM_WIDTH);
    preferredHeight = point.y;
}
/**
 * Sets the receiver's ideal size to the point specified by the argument.
 *
 * @param size the new ideal size for the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setPreferredSize (Point size) {
    checkWidget();
    if (size is null) error(SWT.ERROR_NULL_ARGUMENT);
    setPreferredSize(size.x, size.y);
}
/**
 * Sets the receiver's size to the point specified by the arguments.
 * <p>
 * Note: Attempting to set the width or height of the
 * receiver to a negative number will cause that
 * value to be set to zero instead.
 * </p>
 *
 * @param width the new width for the receiver
 * @param height the new height for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSize (int width, int height) {
    checkWidget();
    Point point = parent.fixPoint(width, height);
    width = Math.max(point.x, minimumWidth + MINIMUM_WIDTH);
    height = point.y;
    if (!ideal) {
        preferredWidth = width;
        preferredHeight = height;
    }
    itemBounds.width = requestedWidth = width;
    itemBounds.height = height;
    if (control !is null) {
        int controlWidth = width - MINIMUM_WIDTH;
        if ((style & SWT.DROP_DOWN) !is 0 && width < preferredWidth) {
            controlWidth -= CHEVRON_IMAGE_WIDTH + CHEVRON_HORIZONTAL_TRIM + CHEVRON_LEFT_MARGIN;
        }
        control.setSize(parent.fixPoint(controlWidth, height));
    }
    parent.relayout();
    updateChevron();
}
/**
 * Sets the receiver's size to the point specified by the argument.
 * <p>
 * Note: Attempting to set the width or height of the
 * receiver to a negative number will cause them to be
 * set to zero instead.
 * </p>
 *
 * @param size the new size for the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSize (Point size) {
    checkWidget();
    if (size is null) error (SWT.ERROR_NULL_ARGUMENT);
    setSize (size.x, size.y);
}
void updateChevron() {
    if (control !is null) {
        int width = itemBounds.width;
        if ((style & SWT.DROP_DOWN) !is 0 && width < preferredWidth) {
            if (chevron is null) {
                chevron = new ToolBar (parent, SWT.FLAT | SWT.NO_FOCUS);
                ToolItem toolItem = new ToolItem (chevron, SWT.PUSH);
                toolItem.addListener (SWT.Selection, new class () Listener {
                    public void handleEvent (Event event) {
                        this.outer.onSelection (event);
                    }
                });
            }
            int controlHeight, currentImageHeight = 0;
            if ((parent.style & SWT.VERTICAL) !is 0) {
                controlHeight = control.getSize ().x;
                if (arrowImage !is null) currentImageHeight = arrowImage.getBounds().width;
            } else {
                controlHeight = control.getSize ().y;
                if (arrowImage !is null) currentImageHeight = arrowImage.getBounds().height;
            }
            int height = Math.min (controlHeight, itemBounds.height);
            int imageHeight = Math.max(1, height - CHEVRON_VERTICAL_TRIM);
            if (currentImageHeight !is imageHeight) {
                Image image = createArrowImage (CHEVRON_IMAGE_WIDTH, imageHeight);
                chevron.getItem (0).setImage (image);
                if (arrowImage !is null) arrowImage.dispose ();
                arrowImage = image;
            }
            chevron.setBackground (parent.getBackground());
            chevron.setBounds (parent.fixRectangle (
                itemBounds.x + width - CHEVRON_LEFT_MARGIN - CHEVRON_IMAGE_WIDTH - CHEVRON_HORIZONTAL_TRIM,
                itemBounds.y,
                CHEVRON_IMAGE_WIDTH + CHEVRON_HORIZONTAL_TRIM,
                height));
            chevron.setVisible(true);
        } else {
            if (chevron !is null) {
                chevron.setVisible(false);
            }
        }
    }
}
}
