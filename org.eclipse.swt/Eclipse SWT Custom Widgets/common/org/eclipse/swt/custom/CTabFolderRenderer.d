/*******************************************************************************
 * Copyright (c) 2000, 2016 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Lars Vogel <Lars.Vogel@vogella.com> - Bug 455263
 * Port to the D programming language:
 *     alice <stigma@disroot.org>
 *******************************************************************************/
module org.eclipse.swt.custom.CTabFolderRenderer;

import java.lang.String;
import java.lang.Math;

import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.CTabFolder;
import org.eclipse.swt.custom.CTabItem;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.RGB;

/**
 * Instances of this class provide all of the measuring and drawing functionality
 * required by <code>CTabFolder</code>. This class can be subclassed in order to
 * customize the look of a CTabFolder.
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * @since 3.6
 */
public class CTabFolderRenderer {
package(org.eclipse.swt.custom):

    protected CTabFolder parent;

    int[] curve;
    int[] topCurveHighlightStart;
    int[] topCurveHighlightEnd;
    int curveWidth = 0;
    int curveIndent = 0;
    int lastTabHeight = -1;

    Color fillColor;
    /* Selected item appearance */
    Color selectionHighlightGradientBegin = null;  //null == no highlight
    //Although we are given new colours all the time to show different states (active, etc),
    //some of which may have a highlight and some not, we'd like to retain the highlight colours
    //as a cache so that we can reuse them if we're again told to show the highlight.
    //We are relying on the fact that only one tab state usually gets a highlight, so only
    //a single cache is required. If that happens to not be true, cache simply becomes less effective,
    //but we don't leak colours.
    Color[] selectionHighlightGradientColorsCache = null;  //null is a legal value, check on access
    /* Colors for anti-aliasing */
    Color selectedOuterColor = null;
    Color selectedInnerColor = null;
    Color tabAreaColor = null;
    /*
     * Border color that was used in computing the cached anti-alias Colors.
     * We have to recompute the colors if the border color changes
     */
    Color lastBorderColor = null;

    //TOP_LEFT_CORNER_HILITE is laid out in reverse (ie. top to bottom)
    //so can fade in same direction as right swoop curve
    static const int[] TOP_LEFT_CORNER_HILITE = [5,2, 4,2, 3,3, 2,4, 2,5, 1,6];

    static const int[] TOP_LEFT_CORNER = [0,6, 1,5, 1,4, 4,1, 5,1, 6,0];
    static const int[] TOP_RIGHT_CORNER = [-6,0, -5,1, -4,1, -1,4, -1,5, 0,6];
    static const int[] BOTTOM_LEFT_CORNER = [0,-6, 1,-5, 1,-4, 4,-1, 5,-1, 6,0];
    static const int[] BOTTOM_RIGHT_CORNER = [-6,0, -5,-1, -4,-1, -1,-4, -1,-5, 0,-6];

    static const int[] SIMPLE_TOP_LEFT_CORNER = [0,2, 1,1, 2,0];
    static const int[] SIMPLE_TOP_RIGHT_CORNER = [-2,0, -1,1, 0,2];
    static const int[] SIMPLE_BOTTOM_LEFT_CORNER = [0,-2, 1,-1, 2,0];
    static const int[] SIMPLE_BOTTOM_RIGHT_CORNER = [-2,0, -1,-1, 0,-2];
    static const int[] SIMPLE_UNSELECTED_INNER_CORNER = [0,0];

    static const int[] TOP_LEFT_CORNER_BORDERLESS = [0,6, 1,5, 1,4, 4,1, 5,1, 6,0];
    static const int[] TOP_RIGHT_CORNER_BORDERLESS = [-7,0, -6,1, -5,1, -2,4, -2,5, -1,6];
    static const int[] BOTTOM_LEFT_CORNER_BORDERLESS = [0,-6, 1,-6, 1,-5, 2,-4, 4,-2, 5,-1, 6,-1, 6,0];
    static const int[] BOTTOM_RIGHT_CORNER_BORDERLESS = [-7,0, -7,-1, -6,-1, -5,-2, -3,-4, -2,-5, -2,-6, -1,-6];

    static const int[] SIMPLE_TOP_LEFT_CORNER_BORDERLESS = [0,2, 1,1, 2,0];
    static const int[] SIMPLE_TOP_RIGHT_CORNER_BORDERLESS= [-3,0, -2,1, -1,2];
    static const int[] SIMPLE_BOTTOM_LEFT_CORNER_BORDERLESS = [0,-3, 1,-2, 2,-1, 3,0];
    static const int[] SIMPLE_BOTTOM_RIGHT_CORNER_BORDERLESS = [-4,0, -3,-1, -2,-2, -1,-3];

    static const RGB CLOSE_FILL = new RGB(252, 160, 160);

    static const int BUTTON_SIZE = 16;
    static const int BUTTON_TRIM = 1;

    static const int BUTTON_BORDER = SWT.COLOR_WIDGET_DARK_SHADOW;
    static const int BUTTON_FILL = SWT.COLOR_LIST_BACKGROUND;
    static const int BORDER1_COLOR = SWT.COLOR_WIDGET_NORMAL_SHADOW;

    static const int ITEM_TOP_MARGIN = 2;
    static const int ITEM_BOTTOM_MARGIN = 2;
    static const int ITEM_LEFT_MARGIN = 4;
    static const int ITEM_RIGHT_MARGIN = 4;
    static const int INTERNAL_SPACING = 4;
    static const int FLAGS = SWT.DRAW_TRANSPARENT | SWT.DRAW_MNEMONIC;
    static const String ELLIPSIS = "..."; //$NON-NLS-1$

    //Part constants
    /**
     * Part constant indicating the body of the tab folder. The body is the
     * underlying container for all of the tab folder and all other parts are
     * drawn on top of it. (value is -1).
     *
     * @see #computeSize(int, int, GC, int, int)
     * @see #computeTrim(int, int, int, int, int, int)
     * @see #draw(int, int, Rectangle, GC)
     */
    public static const int PART_BODY = -1;
    /**
     * Part constant indicating the tab header of the folder (value is -2). The
     * header is drawn on top of the body and provides an area for the tabs and
     * other tab folder buttons to be rendered.
     *
     * @see #computeSize(int, int, GC, int, int)
     * @see #computeTrim(int, int, int, int, int, int)
     * @see #draw(int, int, Rectangle, GC)
     */
    public static const int PART_HEADER = -2;
    /**
     * Part constant indicating the border of the tab folder. (value is -3). The
     * border is drawn around the body and is part of the body trim.
     *
     * @see #computeSize(int, int, GC, int, int)
     * @see #computeTrim(int, int, int, int, int, int)
     * @see #draw(int, int, Rectangle, GC)
     */
    public static const int PART_BORDER = -3;
    /**
     * Part constant indicating the background of the tab folder. (value is -4).
     *
     * @see #computeSize(int, int, GC, int, int)
     * @see #computeTrim(int, int, int, int, int, int)
     * @see #draw(int, int, Rectangle, GC)
     */
    public static const int PART_BACKGROUND = -4;
    /**
     * Part constant indicating the maximize button of the tab folder. (value is
     * -5).
     *
     * @see #computeSize(int, int, GC, int, int)
     * @see #computeTrim(int, int, int, int, int, int)
     * @see #draw(int, int, Rectangle, GC)
     */
    public static const int PART_MAX_BUTTON = -5;
    /**
     * Part constant indicating the minimize button of the tab folder. (value is
     * -6).
     *
     * @see #computeSize(int, int, GC, int, int)
     * @see #computeTrim(int, int, int, int, int, int)
     * @see #draw(int, int, Rectangle, GC)
     */
    public static const int PART_MIN_BUTTON = -6;
    /**
     * Part constant indicating the chevron button of the tab folder. (value is
     * -7).
     *
     * @see #computeSize(int, int, GC, int, int)
     * @see #computeTrim(int, int, int, int, int, int)
     * @see #draw(int, int, Rectangle, GC)
     */
    public static const int PART_CHEVRON_BUTTON = -7;
    /**
     * Part constant indicating the close button of a tab item. (value is -8).
     *
     * @see #computeSize(int, int, GC, int, int)
     * @see #computeTrim(int, int, int, int, int, int)
     * @see #draw(int, int, Rectangle, GC)
     */
    public static const int PART_CLOSE_BUTTON = -8;

    public static const int MINIMUM_SIZE = 1 << 24; //TODO: Should this be a state?

    /**
     * Constructs a new instance of this class given its parent.
     *
     * @param parent CTabFolder
     *
     * @exception IllegalArgumentException <ul>
     *    <li>ERROR_INVALID_ARGUMENT - if the parent is disposed</li>
     * </ul>
     *
     * @see Widget#getStyle
     */
    // DWT: Needs to be public since it can't be accessed in other classes if protected
    public this(CTabFolder parent) {
        if (parent is null) return;
        if (parent.isDisposed ()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
        this.parent = parent;
    }

    void antialias (int[] shape, Color innerColor, Color outerColor, GC gc){
        // Don't perform anti-aliasing on Mac because the platform
        // already does it.  The simple style also does not require anti-aliasing.
        if (parent.simple) return;
        String platform = SWT.getPlatform();
        if ("cocoa" == platform) return; //$NON-NLS-1$
        // Don't perform anti-aliasing on low resolution displays
        if (parent.getDisplay().getDepth() < 15) return;
        if (outerColor !is null) {
            int index = 0;
            bool left = true;
            int oldY = parent.onBottom ? 0 : parent.getSize().y;
            int[] outer = new int[shape.length];
            for (int i = 0; i < shape.length/2; i++) {
                if (left && (index + 3 < shape.length)) {
                    left = parent.onBottom ? oldY <= shape[index+3] : oldY >= shape[index+3];
                    oldY = shape[index+1];
                }
                outer[index] = shape[index++] + (left ? -1 : +1);
                outer[index] = shape[index++];
            }
            gc.setForeground(outerColor);
            gc.drawPolyline(outer);
        }
    }

    /**
     * Returns the preferred size of a part.
     * <p>
     * The <em>preferred size</em> of a part is the size that it would
     * best be displayed at. The width hint and height hint arguments
     * allow the caller to ask a control questions such as "Given a particular
     * width, how high does the part need to be to show all of the contents?"
     * To indicate that the caller does not wish to constrain a particular
     * dimension, the constant <code>SWT.DEFAULT</code> is passed for the hint.
     * </p><p>
     * The <code>part</code> value indicated what component the preferred size is
     * to be calculated for. Valid values are any of the part constants:
     * <ul>
     * <li>PART_BODY</li>
     * <li>PART_HEADER</li>
     * <li>PART_BORDER</li>
     * <li>PART_BACKGROUND</li>
     * <li>PART_MAX_BUTTON</li>
     * <li>PART_MIN_BUTTON</li>
     * <li>PART_CHEVRON_BUTTON</li>
     * <li>PART_CLOSE_BUTTON</li>
     * <li>A positive integer which is the index of an item in the CTabFolder.</li>
     * </ul>
     * </p>
     * <p>
     * The <code>state</code> parameter may be one of the following:
     * <ul>
     * <li>SWT.NONE</li>
     * <li>SWT.SELECTED - whether the part is selected</li>
     * </ul>
     * </p>
     * @param part a part constant
     * @param state current state
     * @param gc the gc to use for measuring
     * @param wHint the width hint (can be <code>SWT.DEFAULT</code>)
     * @param hHint the height hint (can be <code>SWT.DEFAULT</code>)
     * @return the preferred size of the part
     *
     * @since 3.6
     */
    // DWT: Needs to be public since it can't be accessed in other classes if protected
    public Point computeSize (int part, int state, GC gc, int wHint, int hHint) {
        int width = 0, height = 0;
        switch (part) {
            case PART_HEADER:
                if (parent.fixedTabHeight != SWT.DEFAULT) {
                    height = parent.fixedTabHeight == 0 ? 0 : parent.fixedTabHeight + 1; // +1 for line drawn across top of tab
                } else {
                    CTabItem[] items = parent.items;
                    if (items.length == 0) {
                        height = gc.textExtent("Default", FLAGS).y + ITEM_TOP_MARGIN + ITEM_BOTTOM_MARGIN; //$NON-NLS-1$
                    } else {
                        for (int i=0; i < items.length; i++) {
                            height = Math.max(height, computeSize(i, SWT.NONE, gc, wHint, hHint).y);
                        }
                    }
                    gc.dispose();
                }
                break;
            case PART_MAX_BUTTON:
            case PART_MIN_BUTTON:
            case PART_CLOSE_BUTTON:
                width = height = BUTTON_SIZE;
                break;
            case PART_CHEVRON_BUTTON:
                width = (3 * BUTTON_SIZE) / 2;
                height = BUTTON_SIZE;
                break;
            default:
                if (0 <= part && part < parent.getItemCount()) {
                    updateCurves();
                    CTabItem item = parent.items[part];
                    if (item.isDisposed()) return new Point(0,0);
                    Image image = item.getImage();
                    if (image !is null && !image.isDisposed()) {
                        Rectangle bounds = image.getBounds();
                        if ((state & SWT.SELECTED) != 0 || parent.showUnselectedImage) {
                            width += bounds.width;
                        }
                        height =  bounds.height;
                    }
                    String text = null;
                    if ((state & MINIMUM_SIZE) != 0) {
                        int minChars = parent.minChars;
                        text = minChars == 0 ? null : item.getText();
                        if (text !is null && text.length() > minChars) {
                            if (useEllipses()) {
                                int end = minChars < ELLIPSIS.length() + 1 ? minChars : minChars - ELLIPSIS.length();
                                text = text.substring(0, end);
                                if (minChars > ELLIPSIS.length() + 1) text ~= ELLIPSIS;
                            } else {
                                int end = minChars;
                                text = text.substring(0, end);
                            }
                        }
                    } else {
                        text = item.getText();
                    }
                    if (text !is null) {
                        if (width > 0) width += INTERNAL_SPACING;
                        if (item.font is null) {
                            Point size = gc.textExtent(text, FLAGS);
                            width += size.x;
                            height = Math.max(height, size.y);
                        } else {
                            Font gcFont = gc.getFont();
                            gc.setFont(item.font);
                            Point size = gc.textExtent(text, FLAGS);
                            width += size.x;
                            height = Math.max(height, size.y);
                            gc.setFont(gcFont);
                        }
                    }
                    if (parent.showClose || item.showClose) {
                        if ((state & SWT.SELECTED) != 0 || parent.showUnselectedClose) {
                            if (width > 0) width += INTERNAL_SPACING;
                            width += computeSize(PART_CLOSE_BUTTON, SWT.NONE, gc, SWT.DEFAULT, SWT.DEFAULT).x;
                        }
                    }
                }
                break;
        }
        Rectangle trim = computeTrim(part, state, 0, 0, width, height);
        width = trim.width;
        height = trim.height;
        return new Point(width, height);
    }

    /**
     * Given a desired <em>client area</em> for the part
     * (as described by the arguments), returns the bounding
     * rectangle which would be required to produce that client
     * area.
     * <p>
     * In other words, it returns a rectangle such that, if the
     * part's bounds were set to that rectangle, the area
     * of the part which is capable of displaying data
     * (that is, not covered by the "trimmings") would be the
     * rectangle described by the arguments (relative to the
     * receiver's parent).
     * </p>
     *
     * @param part one of the part constants
     * @param state the state of the part
     * @param x the desired x coordinate of the client area
     * @param y the desired y coordinate of the client area
     * @param width the desired width of the client area
     * @param height the desired height of the client area
     * @return the required bounds to produce the given client area
     *
     * @see CTabFolderRenderer#computeSize(int, int, GC, int, int) valid part and state values
     *
     * @since 3.6
     */
    // DWT: Needs to be public since it can't be accessed in other classes if protected
    public Rectangle computeTrim (int part, int state, int x, int y, int width, int height) {
        int borderLeft = parent.borderVisible ? 1 : 0;
        int borderRight = borderLeft;
        int borderTop = parent.onBottom ? borderLeft : 0;
        int borderBottom = parent.onBottom ? 0 : borderLeft;
        int tabHeight = parent.tabHeight;
        switch (part) {
            case PART_BODY:
                int style = parent.getStyle();
                int highlight_header = (style & SWT.FLAT) != 0 ? 1 : 3;
                int highlight_margin = (style & SWT.FLAT) != 0 ? 0 : 2;
                if (parent.fixedTabHeight == 0 && (style & SWT.FLAT) != 0 && (style & SWT.BORDER) == 0) {
                    highlight_header = 0;
                }
                int marginWidth = parent.marginWidth;
                int marginHeight = parent.marginHeight;
                x = x - marginWidth - highlight_margin - borderLeft;
                width = width + borderLeft + borderRight + 2*marginWidth + 2*highlight_margin;
                if (parent.minimized) {
                    y = parent.onBottom ? y - borderTop : y - highlight_header - tabHeight - borderTop;
                    height = borderTop + borderBottom + tabHeight + highlight_header;
                } else {
                    y = parent.onBottom ? y - marginHeight - highlight_margin - borderTop : y - marginHeight - highlight_header - tabHeight - borderTop;
                    height = height + borderTop + borderBottom + 2*marginHeight + tabHeight + highlight_header + highlight_margin;
                }
                break;
            case PART_HEADER:
                //no trim
                break;
            case PART_MAX_BUTTON:
            case PART_MIN_BUTTON:
            case PART_CLOSE_BUTTON:
            case PART_CHEVRON_BUTTON:
                x -= BUTTON_TRIM;
                y -= BUTTON_TRIM;
                width += BUTTON_TRIM*2;
                height += BUTTON_TRIM*2;
                break;
            case PART_BORDER:
                x = x - borderLeft;
                width = width + borderLeft + borderRight;
                if (!parent.simple) width += 2; // TOP_RIGHT_CORNER needs more space
                y = y - borderTop;
                height = height + borderTop + borderBottom;
                break;
            default:
                if (0 <= part && part < parent.getItemCount()) {
                    updateCurves();
                    x = x - ITEM_LEFT_MARGIN;
                    width = width + ITEM_LEFT_MARGIN + ITEM_RIGHT_MARGIN;
                    if (!parent.simple && !parent.single && (state & SWT.SELECTED) != 0) {
                        width += curveWidth - curveIndent;
                    }
                    y = y - ITEM_TOP_MARGIN;
                    height = height + ITEM_TOP_MARGIN + ITEM_BOTTOM_MARGIN;
                }
                break;
        }
        return new Rectangle(x, y, width, height);
    }

    void updateCurves() {
        //Temp fix for Bug 384743
        if (this.classinfo.name == "org.eclipse.e4.ui.workbench.renderers.swt.CTabRendering") return;
        int tabHeight = parent.tabHeight;
        if (tabHeight == lastTabHeight) return;
        if (parent.onBottom) {
            int d = tabHeight - 12;
            curve = [0,13+d, 0,12+d, 2,12+d, 3,11+d, 5,11+d, 6,10+d, 7,10+d, 9,8+d, 10,8+d,
                             11,7+d, 11+d,7,
                                     12+d,6, 13+d,6, 15+d,4, 16+d,4, 17+d,3, 19+d,3, 20+d,2, 22+d,2, 23+d,1];
            curveWidth = 26+d;
            curveIndent = curveWidth/3;
        } else {
            int d = tabHeight - 12;
            curve = [0,0, 0,1, 2,1, 3,2, 5,2, 6,3, 7,3, 9,5, 10,5,
                        11,6, 11+d,6+d,
                        12+d,7+d, 13+d,7+d, 15+d,9+d, 16+d,9+d, 17+d,10+d, 19+d,10+d, 20+d,11+d, 22+d,11+d, 23+d,12+d];
            curveWidth = 26+d;
            curveIndent = curveWidth/3;

            //this could be static but since values depend on curve, better to keep in one place
            topCurveHighlightStart = [
                    0, 2,  1, 2,  2, 2,
                    3, 3,  4, 3,  5, 3,
                    6, 4,  7, 4,
                    8, 5,
                    9, 6, 10, 6];

            //also, by adding in 'd' here we save some math cost when drawing the curve
            topCurveHighlightEnd = [
                    10+d, 6+d,
                    11+d, 7+d,
                    12+d, 8+d,  13+d, 8+d,
                    14+d, 9+d,
                    15+d, 10+d,  16+d, 10+d,
                    17+d, 11+d,  18+d, 11+d,  19+d, 11+d,
                    20+d, 12+d, 21+d, 12+d, 22+d, 12+d ];
        }
    }

    /*
     * Return whether to use ellipses or just truncate labels
     */
    bool useEllipses() {
        return parent.simple;
    }
}
