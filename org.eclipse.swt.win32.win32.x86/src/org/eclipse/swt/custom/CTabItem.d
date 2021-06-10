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
module org.eclipse.swt.custom.CTabItem;

import java.lang.all;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.TextLayout;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.custom.CTabFolder;

version(Tango){
    import tango.text.convert.Utf;
} else {
    import std.conv;
    alias to!(string) toString;
    alias to!(dstring) toString32;
}

/**
 * Instances of this class represent a selectable user interface object
 * that represent a page in a notebook widget.
 *
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>SWT.CLOSE</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#ctabfolder">CTabFolder, CTabItem snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class CTabItem : Item {
    CTabFolder parent;
    int x,y,width,height = 0;
    Control control; // the tab page

    String toolTipText;
    String shortenedText;
    int shortenedTextWidth;

    // Appearance
    Font font;
    Image disabledImage;

    Rectangle closeRect;
    int closeImageState = CTabFolder.NONE;
    bool showClose = false;
    bool showing = false;

    // internal constants
    static const int TOP_MARGIN = 2;
    static const int BOTTOM_MARGIN = 2;
    static const int LEFT_MARGIN = 4;
    static const int RIGHT_MARGIN = 4;
    static const int INTERNAL_SPACING = 4;
    static const int FLAGS = SWT.DRAW_TRANSPARENT | SWT.DRAW_MNEMONIC;
    static const String ELLIPSIS = "..."; //$NON-NLS-1$ // could use the ellipsis glyph on some platforms "\u2026"

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>CTabFolder</code>) and a style value
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
 * @param parent a CTabFolder which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 *
 * @see SWT
 * @see Widget#getStyle()
 */
public this (CTabFolder parent, int style) {
    this(parent, style, parent.getItemCount());
}
/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>CTabFolder</code>), a style value
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
 * @param parent a CTabFolder which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 * @param index the zero-relative index to store the receiver in its parent
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the parent (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 *
 * @see SWT
 * @see Widget#getStyle()
 */
public this (CTabFolder parent, int style, int index) {
    closeRect = new Rectangle(0, 0, 0, 0);
    super (parent, style);
    showClose = (style & SWT.CLOSE) !is 0;
    parent.createItem (this, index);
}

/*
 * Return whether to use ellipses or just truncate labels
 */
bool useEllipses() {
    return parent.simple;
}

String shortenText(GC gc, String text, int width) {
    return useEllipses()
        ? shortenText(gc, text, width, ELLIPSIS)
        : shortenText(gc, text, width, ""); //$NON-NLS-1$
}

String shortenText(GC gc, String text, int width, String ellipses) {
    if (gc.textExtent(text, FLAGS).x <= width) return text;
    int ellipseWidth = gc.textExtent(ellipses, FLAGS).x;
    int length = cast(int)/*64bit*/text.length;
    TextLayout layout = new TextLayout(getDisplay());
    layout.setText(text);
    int end = layout.getPreviousOffset(length, SWT.MOVEMENT_CLUSTER);
    while (end > 0) {
        text = text[ 0 .. end ];
        int l = gc.textExtent(text, FLAGS).x;
        if (l + ellipseWidth <= width) {
            break;
        }
        end = layout.getPreviousOffset(end, SWT.MOVEMENT_CLUSTER);
    }
    layout.dispose();
    return end is 0 ? .toString(toString32(text)[0 .. 1]) : text ~ ellipses;
}

public override void dispose() {
    if (isDisposed ()) return;
    //if (!isValidThread ()) error (SWT.ERROR_THREAD_INVALID_ACCESS);
    parent.destroyItem(this);
    super.dispose();
    parent = null;
    control = null;
    toolTipText = null;
    shortenedText = null;
    font = null;
}
void drawClose(GC gc) {
    if (closeRect.width is 0 || closeRect.height is 0) return;
    Display display = getDisplay();

    // draw X 9x9
    int indent = Math.max(1, (CTabFolder.BUTTON_SIZE-9)/2);
    int x = closeRect.x + indent;
    int y = closeRect.y + indent;
    y += parent.onBottom ? -1 : 1;

    Color closeBorder = display.getSystemColor(CTabFolder.BUTTON_BORDER);
    switch (closeImageState) {
        case CTabFolder.NORMAL: {
            int[] shape = [x,y, x+2,y, x+4,y+2, x+5,y+2, x+7,y, x+9,y,
                                     x+9,y+2, x+7,y+4, x+7,y+5, x+9,y+7, x+9,y+9,
                                     x+7,y+9, x+5,y+7, x+4,y+7, x+2,y+9, x,y+9,
                                     x,y+7, x+2,y+5, x+2,y+4, x,y+2];
            gc.setBackground(display.getSystemColor(CTabFolder.BUTTON_FILL));
            gc.fillPolygon(shape);
            gc.setForeground(closeBorder);
            gc.drawPolygon(shape);
            break;
        }
        case CTabFolder.HOT: {
            int[] shape = [x,y, x+2,y, x+4,y+2, x+5,y+2, x+7,y, x+9,y,
                                     x+9,y+2, x+7,y+4, x+7,y+5, x+9,y+7, x+9,y+9,
                                     x+7,y+9, x+5,y+7, x+4,y+7, x+2,y+9, x,y+9,
                                     x,y+7, x+2,y+5, x+2,y+4, x,y+2];
            Color fill = new Color(display, CTabFolder.CLOSE_FILL);
            gc.setBackground(fill);
            gc.fillPolygon(shape);
            fill.dispose();
            gc.setForeground(closeBorder);
            gc.drawPolygon(shape);
            break;
        }
        case CTabFolder.SELECTED: {
            int[] shape = [x+1,y+1, x+3,y+1, x+5,y+3, x+6,y+3, x+8,y+1, x+10,y+1,
                                     x+10,y+3, x+8,y+5, x+8,y+6, x+10,y+8, x+10,y+10,
                                     x+8,y+10, x+6,y+8, x+5,y+8, x+3,y+10, x+1,y+10,
                                     x+1,y+8, x+3,y+6, x+3,y+5, x+1,y+3];
            Color fill = new Color(display, CTabFolder.CLOSE_FILL);
            gc.setBackground(fill);
            gc.fillPolygon(shape);
            fill.dispose();
            gc.setForeground(closeBorder);
            gc.drawPolygon(shape);
            break;
        }
        case CTabFolder.NONE: {
            int[] shape = [x,y, x+10,y, x+10,y+10, x,y+10];
            if (parent.gradientColors !is null && !parent.gradientVertical) {
                parent.drawBackground(gc, shape, false);
            } else {
                Color defaultBackground = parent.getBackground();
                Image image = parent.bgImage;
                Color[] colors = parent.gradientColors;
                int[] percents = parent.gradientPercents;
                bool vertical = parent.gradientVertical;
                parent.drawBackground(gc, shape, x, y, 10, 10, defaultBackground, image, colors, percents, vertical);
            }
            break;
        }
        default:
    }
}
void drawSelected(GC gc ) {
    Point size = parent.getSize();
    int rightEdge = Math.min (x + width, parent.getRightItemEdge());

    //   Draw selection border across all tabs
    int xx = parent.borderLeft;
    int yy = parent.onBottom ? size.y - parent.borderBottom - parent.tabHeight - parent.highlight_header : parent.borderTop + parent.tabHeight + 1;
    int ww = size.x - parent.borderLeft - parent.borderRight;
    int hh = parent.highlight_header - 1;
    int[] shape = [xx,yy, xx+ww,yy, xx+ww,yy+hh, xx,yy+hh];
    if (parent.selectionGradientColors !is null && !parent.selectionGradientVertical) {
        parent.drawBackground(gc, shape, true);
    } else {
        gc.setBackground(parent.selectionBackground);
        gc.fillRectangle(xx, yy, ww, hh);
    }

    if (parent.single) {
        if (!showing) return;
    } else {
        // if selected tab scrolled out of view or partially out of view
        // just draw bottom line
        if (!showing){
            int x1 = Math.max(0, parent.borderLeft - 1);
            int y1 = (parent.onBottom) ? y - 1 : y + height;
            int x2 = size.x - parent.borderRight;
            gc.setForeground(CTabFolder.borderColor);
            gc.drawLine(x1, y1, x2, y1);
            return;
        }

        // draw selected tab background and outline
        shape = null;
        if (this.parent.onBottom) {
            TryConst!(int)[] left = parent.simple ? CTabFolder.SIMPLE_BOTTOM_LEFT_CORNER : CTabFolder.BOTTOM_LEFT_CORNER;
            TryConst!(int[]) right = parent.simple ? CTabFolder.SIMPLE_BOTTOM_RIGHT_CORNER : parent.curve;
            if (parent.borderLeft is 0 && parent.indexOf(this) is parent.firstIndex) {
                left = [x, y+height];
            }
            shape = new int[left.length+right.length+8];
            int index = 0;
            shape[index++] = x; // first point repeated here because below we reuse shape to draw outline
            shape[index++] = y - 1;
            shape[index++] = x;
            shape[index++] = y - 1;
            for (int i = 0; i < left.length/2; i++) {
                shape[index++] = x + left[2*i];
                shape[index++] = y + height + left[2*i+1] - 1;
            }
            for (int i = 0; i < right.length/2; i++) {
                shape[index++] = parent.simple ? rightEdge - 1 + right[2*i] : rightEdge - parent.curveIndent + right[2*i];
                shape[index++] = parent.simple ? y + height + right[2*i+1] - 1 : y + right[2*i+1] - 2;
            }
            shape[index++] = parent.simple ? rightEdge - 1 : rightEdge + parent.curveWidth - parent.curveIndent;
            shape[index++] = y - 1;
            shape[index++] = parent.simple ? rightEdge - 1 : rightEdge + parent.curveWidth - parent.curveIndent;
            shape[index++] = y - 1;
        } else {
            TryConst!(int)[] left = parent.simple ? CTabFolder.SIMPLE_TOP_LEFT_CORNER : CTabFolder.TOP_LEFT_CORNER;
            TryConst!(int[]) right = parent.simple ? CTabFolder.SIMPLE_TOP_RIGHT_CORNER : parent.curve;
            if (parent.borderLeft is 0 && parent.indexOf(this) is parent.firstIndex) {
                left = [x, y];
            }
            shape = new int[left.length+right.length+8];
            int index = 0;
            shape[index++] = x; // first point repeated here because below we reuse shape to draw outline
            shape[index++] = y + height + 1;
            shape[index++] = x;
            shape[index++] = y + height + 1;
            for (int i = 0; i < left.length/2; i++) {
                shape[index++] = x + left[2*i];
                shape[index++] = y + left[2*i+1];
            }
            for (int i = 0; i < right.length/2; i++) {
                shape[index++] = parent.simple ? rightEdge - 1 + right[2*i] : rightEdge - parent.curveIndent + right[2*i];
                shape[index++] = y + right[2*i+1];
            }
            shape[index++] = parent.simple ? rightEdge - 1 : rightEdge + parent.curveWidth - parent.curveIndent;
            shape[index++] = y + height + 1;
            shape[index++] = parent.simple ? rightEdge - 1 : rightEdge + parent.curveWidth - parent.curveIndent;
            shape[index++] = y + height + 1;
        }

        Rectangle clipping = gc.getClipping();
        Rectangle bounds = getBounds();
        bounds.height += 1;
        if (parent.onBottom) bounds.y -= 1;
        bool tabInPaint = clipping.intersects(bounds);

        if (tabInPaint) {
            // fill in tab background
            if (parent.selectionGradientColors !is null && !parent.selectionGradientVertical) {
                parent.drawBackground(gc, shape, true);
            } else {
                Color defaultBackground = parent.selectionBackground;
                Image image = parent.selectionBgImage;
                Color[] colors = parent.selectionGradientColors;
                int[] percents = parent.selectionGradientPercents;
                bool vertical = parent.selectionGradientVertical;
                xx = x;
                yy = parent.onBottom ? y -1 : y + 1;
                ww = width;
                hh = height;
                if (!parent.single && !parent.simple) ww += parent.curveWidth - parent.curveIndent;
                parent.drawBackground(gc, shape, xx, yy, ww, hh, defaultBackground, image, colors, percents, vertical);
            }
        }

        //Highlight MUST be drawn before the outline so that outline can cover it in the right spots (start of swoop)
        //otherwise the curve looks jagged
        drawHighlight(gc, rightEdge);

        // draw outline
        shape[0] = Math.max(0, parent.borderLeft - 1);
        if (parent.borderLeft is 0 && parent.indexOf(this) is parent.firstIndex) {
            shape[1] = parent.onBottom ? y + height - 1 : y;
            shape[5] = shape[3] = shape[1];
        }
        shape[shape.length - 2] = size.x - parent.borderRight + 1;
        for (int i = 0; i < shape.length/2; i++) {
            if (shape[2*i + 1] is y + height + 1) shape[2*i + 1] -= 1;
        }
        RGB inside = parent.selectionBackground.getRGB();
        if (parent.selectionBgImage !is null ||
            (parent.selectionGradientColors !is null && parent.selectionGradientColors.length > 1)) {
            inside = null;
        }
        RGB outside = parent.getBackground().getRGB();
        if (parent.bgImage !is null ||
            (parent.gradientColors !is null && parent.gradientColors.length > 1)) {
            outside = null;
        }
        parent.antialias(shape, CTabFolder.borderColor.getRGB(), inside, outside, gc);
        gc.setForeground(CTabFolder.borderColor);
        gc.drawPolyline(shape);

        if (!tabInPaint) return;
    }

    // draw Image
    int xDraw = x + LEFT_MARGIN;
    if (parent.single && (parent.showClose || showClose)) xDraw += CTabFolder.BUTTON_SIZE;
    Image image = getImage();
    if (image !is null) {
        Rectangle imageBounds = image.getBounds();
        // only draw image if it won't overlap with close button
        int maxImageWidth = rightEdge - xDraw - RIGHT_MARGIN;
        if (!parent.single && closeRect.width > 0) maxImageWidth -= closeRect.width + INTERNAL_SPACING;
        if (imageBounds.width < maxImageWidth) {
            int imageX = xDraw;
            int imageY = y + (height - imageBounds.height) / 2;
            imageY += parent.onBottom ? -1 : 1;
            gc.drawImage(image, imageX, imageY);
            xDraw += imageBounds.width + INTERNAL_SPACING;
        }
    }

    // draw Text
    int textWidth = rightEdge - xDraw - RIGHT_MARGIN;
    if (!parent.single && closeRect.width > 0) textWidth -= closeRect.width + INTERNAL_SPACING;
    if (textWidth > 0) {
        Font gcFont = gc.getFont();
        gc.setFont(font is null ? parent.getFont() : font);

        if (shortenedText is null || shortenedTextWidth !is textWidth) {
            shortenedText = shortenText(gc, getText(), textWidth);
            shortenedTextWidth = textWidth;
        }
        Point extent = gc.textExtent(shortenedText, FLAGS);
        int textY = y + (height - extent.y) / 2;
        textY += parent.onBottom ? -1 : 1;

        gc.setForeground(parent.selectionForeground);
        gc.drawText(shortenedText, xDraw, textY, FLAGS);
        gc.setFont(gcFont);

        // draw a Focus rectangle
        if (parent.isFocusControl()) {
            Display display = getDisplay();
            if (parent.simple || parent.single) {
                gc.setBackground(display.getSystemColor(SWT.COLOR_BLACK));
                gc.setForeground(display.getSystemColor(SWT.COLOR_WHITE));
                gc.drawFocus(xDraw-1, textY-1, extent.x+2, extent.y+2);
            } else {
                gc.setForeground(display.getSystemColor(CTabFolder.BUTTON_BORDER));
                gc.drawLine(xDraw, textY+extent.y+1, xDraw+extent.x+1, textY+extent.y+1);
            }
        }
    }
    if (parent.showClose || showClose) drawClose(gc);
}

/*
 * Draw a highlight effect along the left, top, and right edges of the tab.
 * Only for curved tabs, on top.
 * Do not draw if insufficient colors.
 */
void drawHighlight(GC gc, int rightEdge) {
    //only draw for curvy tabs and only draw for top tabs
    if(parent.simple || this.parent.onBottom)
        return;

    if(parent.selectionHighlightGradientBegin is null)
        return;

    Color[] gradients = parent.selectionHighlightGradientColorsCache;
    if(gradients is null)
        return;
    int gradientsSize = cast(int)/*64bit*/gradients.length;
    if(gradientsSize is 0)
        return;     //shouldn't happen but just to be tidy

    gc.setForeground(gradients[0]);

    //draw top horizontal line
    gc.drawLine(
            CTabFolder.TOP_LEFT_CORNER_HILITE[0] + x + 1, //rely on fact that first pair is top/right of curve
            1 + y,
            rightEdge - parent.curveIndent,
            1 + y);

    const int[] leftHighlightCurve = CTabFolder.TOP_LEFT_CORNER_HILITE;

    int d = parent.tabHeight - cast(int)/*64bit*/parent.topCurveHighlightEnd.length /2;

    int lastX = 0;
    int lastY = 0;
    int lastColorIndex = 0;

    //draw upper left curve highlight
    for (int i = 0; i < leftHighlightCurve.length /2; i++) {
        int rawX = leftHighlightCurve[i * 2];
        int rawY = leftHighlightCurve[i * 2 + 1];
        lastX = rawX + x;
        lastY = rawY + y;
        lastColorIndex = rawY - 1;
        gc.setForeground(gradients[lastColorIndex]);
        gc.drawPoint(lastX, lastY);
    }
    //draw left vertical line highlight
    for(int i = lastColorIndex; i < gradientsSize; i++) {
        gc.setForeground(gradients[i]);
        gc.drawPoint(lastX, 1 + lastY++);
    }

    int rightEdgeOffset = rightEdge - parent.curveIndent;

    //draw right swoop highlight up to diagonal portion
    for (int i = 0; i < parent.topCurveHighlightStart.length /2; i++) {
        int rawX = parent.topCurveHighlightStart[i * 2];
        int rawY = parent.topCurveHighlightStart[i * 2 + 1];
        lastX = rawX + rightEdgeOffset;
        lastY = rawY + y;
        lastColorIndex = rawY - 1;
        if(lastColorIndex >= gradientsSize)
            break;  //can happen if tabs are unusually short and cut off the curve
        gc.setForeground(gradients[lastColorIndex]);
        gc.drawPoint(lastX, lastY);
    }
    //draw right diagonal line highlight
    for(int i = lastColorIndex; i < lastColorIndex + d; i++) {
        if(i >= gradientsSize)
            break;  //can happen if tabs are unusually short and cut off the curve
        gc.setForeground(gradients[i]);
        gc.drawPoint(1 + lastX++, 1 + lastY++);
    }

    //draw right swoop highlight from diagonal portion to end
    for (int i = 0; i < parent.topCurveHighlightEnd.length /2; i++) {
        int rawX = parent.topCurveHighlightEnd[i * 2]; //d is already encoded in this value
        int rawY = parent.topCurveHighlightEnd[i * 2 + 1]; //d already encoded
        lastX = rawX + rightEdgeOffset;
        lastY = rawY + y;
        lastColorIndex = rawY - 1;
        if(lastColorIndex >= gradientsSize)
            break;  //can happen if tabs are unusually short and cut off the curve
        gc.setForeground(gradients[lastColorIndex]);
        gc.drawPoint(lastX, lastY);
    }
}

/*
 * Draw the unselected border for the receiver on the right.
 *
 * @param gc
 */
void drawRightUnselectedBorder(GC gc) {

    int[] shape = null;
    int startX = x + width - 1;

    if (this.parent.onBottom) {
        TryConst!(int[]) right = parent.simple
            ? CTabFolder.SIMPLE_UNSELECTED_INNER_CORNER
            : CTabFolder.BOTTOM_RIGHT_CORNER;

        shape = new int[right.length + 2];
        int index = 0;

        for (int i = 0; i < right.length / 2; i++) {
            shape[index++] = startX + right[2 * i];
            shape[index++] = y + height + right[2 * i + 1] - 1;
        }
        shape[index++] = startX;
        shape[index++] = y - 1;
    } else {
        TryConst!(int[]) right = parent.simple
            ? CTabFolder.SIMPLE_UNSELECTED_INNER_CORNER
            : CTabFolder.TOP_RIGHT_CORNER;

        shape = new int[right.length + 2];
        int index = 0;

        for (int i = 0; i < right.length / 2; i++) {
            shape[index++] = startX + right[2 * i];
            shape[index++] = y + right[2 * i + 1];
        }

        shape[index++] = startX;
        shape[index++] = y + height;

    }

    drawBorder(gc, shape);

}

/*
 * Draw the border of the tab
 *
 * @param gc
 * @param shape
 */
void drawBorder(GC gc, int[] shape) {

    gc.setForeground(CTabFolder.borderColor);
    gc.drawPolyline(shape);
}

/*
 * Draw the unselected border for the receiver on the left.
 *
 * @param gc
 */
void drawLeftUnselectedBorder(GC gc) {

    int[] shape = null;
    if (this.parent.onBottom) {
        TryConst!(int[]) left = parent.simple
            ? CTabFolder.SIMPLE_UNSELECTED_INNER_CORNER
            : CTabFolder.BOTTOM_LEFT_CORNER;

        shape = new int[left.length + 2];
        int index = 0;
        shape[index++] = x;
        shape[index++] = y - 1;
        for (int i = 0; i < left.length / 2; i++) {
            shape[index++] = x + left[2 * i];
            shape[index++] = y + height + left[2 * i + 1] - 1;
        }
    } else {
        TryConst!(int[]) left = parent.simple
            ? CTabFolder.SIMPLE_UNSELECTED_INNER_CORNER
            : CTabFolder.TOP_LEFT_CORNER;

        shape = new int[left.length + 2];
        int index = 0;
        shape[index++] = x;
        shape[index++] = y + height;
        for (int i = 0; i < left.length / 2; i++) {
            shape[index++] = x + left[2 * i];
            shape[index++] = y + left[2 * i + 1];
        }

    }

    drawBorder(gc, shape);
}

void drawUnselected(GC gc) {
    // Do not draw partial items
    if (!showing) return;

    Rectangle clipping = gc.getClipping();
    Rectangle bounds = getBounds();
    if (!clipping.intersects(bounds)) return;

    // draw border
    int index = parent.indexOf(this);

    if (index > 0 && index < parent.selectedIndex)
        drawLeftUnselectedBorder(gc);
    // If it is the last one then draw a line
    if (index > parent.selectedIndex)
        drawRightUnselectedBorder(gc);

    // draw Image
    int xDraw = x + LEFT_MARGIN;
    Image image = getImage();
    if (image !is null && parent.showUnselectedImage) {
        Rectangle imageBounds = image.getBounds();
        // only draw image if it won't overlap with close button
        int maxImageWidth = x + width - xDraw - RIGHT_MARGIN;
        if (parent.showUnselectedClose && (parent.showClose || showClose)) {
            maxImageWidth -= closeRect.width + INTERNAL_SPACING;
        }
        if (imageBounds.width < maxImageWidth) {
            int imageX = xDraw;
            int imageHeight = imageBounds.height;
            int imageY = y + (height - imageHeight) / 2;
            imageY += parent.onBottom ? -1 : 1;
            int imageWidth = imageBounds.width * imageHeight / imageBounds.height;
            gc.drawImage(image,
                         imageBounds.x, imageBounds.y, imageBounds.width, imageBounds.height,
                         imageX, imageY, imageWidth, imageHeight);
            xDraw += imageWidth + INTERNAL_SPACING;
        }
    }
    // draw Text
    int textWidth = x + width - xDraw - RIGHT_MARGIN;
    if (parent.showUnselectedClose && (parent.showClose || showClose)) {
        textWidth -= closeRect.width + INTERNAL_SPACING;
    }
    if (textWidth > 0) {
        Font gcFont = gc.getFont();
        gc.setFont(font is null ? parent.getFont() : font);
        if (shortenedText is null || shortenedTextWidth !is textWidth) {
            shortenedText = shortenText(gc, getText(), textWidth);
            shortenedTextWidth = textWidth;
        }
        Point extent = gc.textExtent(shortenedText, FLAGS);
        int textY = y + (height - extent.y) / 2;
        textY += parent.onBottom ? -1 : 1;
        gc.setForeground(parent.getForeground());
        gc.drawText(shortenedText, xDraw, textY, FLAGS);
        gc.setFont(gcFont);
    }
    // draw close
    if (parent.showUnselectedClose && (parent.showClose || showClose)) drawClose(gc);
}
/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent.
 *
 * @return the receiver's bounding column rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Rectangle getBounds () {
    //checkWidget();
    int w = width;
    if (!parent.simple && !parent.single && parent.indexOf(this) is parent.selectedIndex) w += parent.curveWidth - parent.curveIndent;
    return new Rectangle(x, y, w, height);
}
/**
* Gets the control that is displayed in the content area of the tab item.
*
* @return the control
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
 * Get the image displayed in the tab if the tab is disabled.
 *
 * @return the disabled image or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @deprecated the disabled image is not used
 */
public Image getDisabledImage(){
    checkWidget();
    return disabledImage;
}
/**
 * Returns the font that the receiver will use to paint textual information.
 *
 * @return the receiver's font
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 *  @since 3.0
 */
public Font getFont() {
    checkWidget();
    if (font !is null) return font;
    return parent.getFont();
}
/**
 * Returns the receiver's parent, which must be a <code>CTabFolder</code>.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public CTabFolder getParent () {
    //checkWidget();
    return parent;
}
/**
 * Returns <code>true</code> to indicate that the receiver's close button should be shown.
 * Otherwise return <code>false</code>. The initial value is defined by the style (SWT.CLOSE)
 * that was used to create the receiver.
 *
 * @return <code>true</code> if the close button should be shown
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public bool getShowClose() {
    checkWidget();
    return showClose;
}
/**
 * Returns the receiver's tool tip text, or null if it has
 * not been set.
 *
 * @return the receiver's tool tip text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getToolTipText () {
    checkWidget();
    if (toolTipText is null && shortenedText !is null) {
        String text = getText();
        if (shortenedText!=text) return text;
    }
    return toolTipText;
}
/**
* Returns <code>true</code> if the item will be rendered in the visible area of the CTabFolder. Returns false otherwise.
*
*  @return <code>true</code> if the item will be rendered in the visible area of the CTabFolder. Returns false otherwise.
*
*  @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
* @since 3.0
*/
public bool isShowing () {
    checkWidget();
    return showing;
}
void onPaint(GC gc, bool isSelected) {
    if (width is 0 || height is 0) return;
    if (isSelected) {
        drawSelected(gc);
    } else {
        drawUnselected(gc);
    }
}
int preferredHeight(GC gc) {
    Image image = getImage();
    int h = (image is null) ? 0 : image.getBounds().height;
    String text = getText();
    if (font is null) {
        h = Math.max(h, gc.textExtent(text, FLAGS).y);
    } else {
        Font gcFont = gc.getFont();
        gc.setFont(font);
        h = Math.max(h, gc.textExtent(text, FLAGS).y);
        gc.setFont(gcFont);
    }
    return h + TOP_MARGIN + BOTTOM_MARGIN;
}
int preferredWidth(GC gc, bool isSelected, bool minimum) {
    // NOTE: preferred width does not include the "dead space" caused
    // by the curve.
    if (isDisposed()) return 0;
    int w = 0;
    Image image = getImage();
    if (image !is null && (isSelected || parent.showUnselectedImage)) {
        w += image.getBounds().width;
    }
    String text = null;
    if (minimum) {
        int minChars = parent.minChars;
        text = minChars is 0 ? null : getText();
        if (text !is null && toString32(text).length > minChars) {
            if (useEllipses()) {
                int end = minChars < cast(int)/*64bit*/ELLIPSIS.length + 1 ? minChars : minChars - cast(int)/*64bit*/ELLIPSIS.length;
                text = .toString(toString32(text)[ 0 .. end ]);
                if (minChars > ELLIPSIS.length + 1) text ~= ELLIPSIS;
            } else {
                int end = minChars;
                text = .toString(toString32(text)[ 0 .. end ]);
            }
        }
    } else {
        text = getText();
    }
    if (text !is null) {
        if (w > 0) w += INTERNAL_SPACING;
        if (font is null) {
            w += gc.textExtent(text, FLAGS).x;
        } else {
            Font gcFont = gc.getFont();
            gc.setFont(font);
            w += gc.textExtent(text, FLAGS).x;
            gc.setFont(gcFont);
        }
    }
    if (parent.showClose || showClose) {
        if (isSelected || parent.showUnselectedClose) {
            if (w > 0) w += INTERNAL_SPACING;
            w += CTabFolder.BUTTON_SIZE;
        }
    }
    return w + LEFT_MARGIN + RIGHT_MARGIN;
}
/**
 * Sets the control that is used to fill the client area of
 * the tab folder when the user selects the tab item.
 *
 * @param control the new control (or null)
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
        if (control.isDisposed()) SWT.error (SWT.ERROR_INVALID_ARGUMENT);
        if (control.getParent() !is parent) SWT.error (SWT.ERROR_INVALID_PARENT);
    }
    if (this.control !is null && !this.control.isDisposed()) {
        this.control.setVisible(false);
    }
    this.control = control;
    if (this.control !is null) {
        int index = parent.indexOf (this);
        if (index is parent.getSelectionIndex ()){
            this.control.setBounds(parent.getClientArea ());
            this.control.setVisible(true);
        } else {
            this.control.setVisible(false);
        }
    }
}
/**
 * Sets the image that is displayed if the tab item is disabled.
 * Null will clear the image.
 *
 * @param image the image to be displayed when the item is disabled or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @deprecated This image is not used
 */
public void setDisabledImage (Image image) {
    checkWidget();
    if (image !is null && image.isDisposed ()) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    this.disabledImage = image;
}
/**
 * Sets the font that the receiver will use to paint textual information
 * for this item to the font specified by the argument, or to the default font
 * for that kind of control if the argument is null.
 *
 * @param font the new font (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the argument has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setFont (Font font){
    checkWidget();
    if (font !is null && font.isDisposed ()) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    if (font is null && this.font is null) return;
    if (font !is null && font==this.font) return;
    this.font = font;
    if (!parent.updateTabHeight(false)) {
        parent.updateItems();
        parent.redrawTabs();
    }
}
public override void setImage (Image image) {
    checkWidget();
    if (image !is null && image.isDisposed ()) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    Image oldImage = getImage();
    if (image is null && oldImage is null) return;
    if (image !is null && image==oldImage) return;
    super.setImage(image);
    if (!parent.updateTabHeight(false)) {
        // If image is the same size as before,
        // redraw only the image
        if (oldImage !is null && image !is null) {
            Rectangle oldBounds = oldImage.getBounds();
            Rectangle bounds = image.getBounds();
            if (bounds.width is oldBounds.width && bounds.height is oldBounds.height) {
                if (showing) {
                    bool selected = parent.indexOf(this) is parent.selectedIndex;
                    if (selected || parent.showUnselectedImage) {
                        int imageX = x + LEFT_MARGIN, maxImageWidth;
                        if (selected) {
                            if (parent.single && (parent.showClose || showClose)) imageX += CTabFolder.BUTTON_SIZE;
                            int rightEdge = Math.min (x + width, parent.getRightItemEdge());
                            maxImageWidth = rightEdge - imageX - RIGHT_MARGIN;
                            if (!parent.single && closeRect.width > 0) maxImageWidth -= closeRect.width + INTERNAL_SPACING;
                        } else {
                            maxImageWidth = x + width - imageX - RIGHT_MARGIN;
                            if (parent.showUnselectedClose && (parent.showClose || showClose)) {
                                maxImageWidth -= closeRect.width + INTERNAL_SPACING;
                            }
                        }
                        if (bounds.width < maxImageWidth) {
                            int imageY = y + (height - bounds.height) / 2 + (parent.onBottom ? -1 : 1);
                            parent.redraw(imageX, imageY, bounds.width, bounds.height, false);
                        }
                    }
                }
                return;
            }
        }
        parent.updateItems();
        parent.redrawTabs();
    }
}
/**
 * Sets to <code>true</code> to indicate that the receiver's close button should be shown.
 * If the parent (CTabFolder) was created with SWT.CLOSE style, changing this value has
 * no effect.
 *
 * @param close the new state of the close button
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setShowClose(bool close) {
    checkWidget();
    if (showClose is close) return;
    showClose = close;
    parent.updateItems();
    parent.redrawTabs();
}
public override void setText (String string) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    if (string.equals (getText())) return;
    super.setText(string);
    shortenedText = null;
    shortenedTextWidth = 0;
    if (!parent.updateTabHeight(false)) {
        parent.updateItems();
        parent.redrawTabs();
    }
}
/**
 * Sets the receiver's tool tip text to the argument, which
 * may be null indicating that no tool tip text should be shown.
 *
 * @param string the new tool tip text (or null)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setToolTipText (String string) {
    checkWidget();
    toolTipText = string;
}

}
