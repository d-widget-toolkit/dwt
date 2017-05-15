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
module org.eclipse.swt.custom.StyledTextDropTargetEffect;


import org.eclipse.swt.SWT;
import org.eclipse.swt.dnd.DND;
import org.eclipse.swt.dnd.DropTargetAdapter;
import org.eclipse.swt.dnd.DropTargetEffect;
import org.eclipse.swt.dnd.DropTargetEvent;
import org.eclipse.swt.graphics.FontMetrics;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.custom.StyledTextContent;

import java.lang.all;

/**
 * This adapter class provides a default drag under effect (eg. select and scroll)
 * when a drag occurs over a <code>StyledText</code>.
 *
 * <p>Classes that wish to provide their own drag under effect for a <code>StyledText</code>
 * can extend this class, override the <code>StyledTextDropTargetEffect.dragOver</code>
 * method and override any other applicable methods in <code>StyledTextDropTargetEffect</code> to
 * display their own drag under effect.</p>
 *
 * Subclasses that override any methods of this class should call the corresponding
 * <code>super</code> method to get the default drag under effect implementation.
 *
 * <p>The feedback value is either one of the FEEDBACK constants defined in
 * class <code>DND</code> which is applicable to instances of this class,
 * or it must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>DND</code> effect constants.
 * </p>
 * <p>
 * <dl>
 * <dt><b>Feedback:</b></dt>
 * <dd>FEEDBACK_SELECT, FEEDBACK_SCROLL</dd>
 * </dl>
 * </p>
 *
 * @see DropTargetAdapter
 * @see DropTargetEvent
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.3
 */
public class StyledTextDropTargetEffect : DropTargetEffect {
    static const int CARET_WIDTH = 2;
    static const int SCROLL_HYSTERESIS = 100; // milli seconds
    static const int SCROLL_TOLERANCE = 20; // pixels

    int currentOffset = -1;
    long scrollBeginTime;
    int scrollX = -1, scrollY = -1;
    Listener paintListener;

    /**
     * Creates a new <code>StyledTextDropTargetEffect</code> to handle the drag under effect on the specified
     * <code>StyledText</code>.
     *
     * @param styledText the <code>StyledText</code> over which the user positions the cursor to drop the data
     */
    public this(StyledText styledText) {
        super(styledText);
        paintListener = new class() Listener {
            public void handleEvent (Event event) {
                if (currentOffset !is -1) {
                    StyledText text = cast(StyledText) getControl();
                    Point position = text.getLocationAtOffset(currentOffset);
                    int height = text.getLineHeight(currentOffset);
                    event.gc.setBackground(event.display.getSystemColor (SWT.COLOR_BLACK));
                    event.gc.fillRectangle(position.x, position.y, CARET_WIDTH, height);
                }
            }
        };
    }

    /**
     * This implementation of <code>dragEnter</code> provides a default drag under effect
     * for the feedback specified in <code>event.feedback</code>.
     *
     * For additional information see <code>DropTargetAdapter.dragEnter</code>.
     *
     * Subclasses that override this method should call <code>super.dragEnter(event)</code>
     * to get the default drag under effect implementation.
     *
     * @param event  the information associated with the drag start event
     *
     * @see DropTargetAdapter
     * @see DropTargetEvent
     */
    public override void dragEnter(DropTargetEvent event) {
        currentOffset = -1;
        scrollBeginTime = 0;
        scrollX = -1;
        scrollY = -1;
        getControl().removeListener(SWT.Paint, paintListener);
        getControl().addListener (SWT.Paint, paintListener);
    }

    /**
     * This implementation of <code>dragLeave</code> provides a default drag under effect
     * for the feedback specified in <code>event.feedback</code>.
     *
     * For additional information see <code>DropTargetAdapter.dragLeave</code>.
     *
     * Subclasses that override this method should call <code>super.dragLeave(event)</code>
     * to get the default drag under effect implementation.
     *
     * @param event  the information associated with the drag leave event
     *
     * @see DropTargetAdapter
     * @see DropTargetEvent
     */
    public override void dragLeave(DropTargetEvent event) {
        StyledText text = cast(StyledText) getControl();
        if (currentOffset !is -1) {
            refreshCaret(text, currentOffset, -1);
        }
        text.removeListener(SWT.Paint, paintListener);
        scrollBeginTime = 0;
        scrollX = -1;
        scrollY = -1;
    }

    /**
     * This implementation of <code>dragOver</code> provides a default drag under effect
     * for the feedback specified in <code>event.feedback</code>.
     *
     * For additional information see <code>DropTargetAdapter.dragOver</code>.
     *
     * Subclasses that override this method should call <code>super.dragOver(event)</code>
     * to get the default drag under effect implementation.
     *
     * @param event  the information associated with the drag over event
     *
     * @see DropTargetAdapter
     * @see DropTargetEvent
     * @see DND#FEEDBACK_SELECT
     * @see DND#FEEDBACK_SCROLL
     */
    public override void dragOver(DropTargetEvent event) {
        int effect = event.feedback;
        StyledText text = cast(StyledText) getControl();

        Point pt = text.getDisplay().map(null, text, event.x, event.y);
        if ((effect & DND.FEEDBACK_SCROLL) is 0) {
            scrollBeginTime = 0;
            scrollX = scrollY = -1;
        } else {
            if (text.getCharCount() is 0) {
                scrollBeginTime = 0;
                scrollX = scrollY = -1;
            } else {
                if (scrollX !is -1 && scrollY !is -1 && scrollBeginTime !is 0 &&
                    (pt.x >= scrollX && pt.x <= (scrollX + SCROLL_TOLERANCE) ||
                     pt.y >= scrollY && pt.y <= (scrollY + SCROLL_TOLERANCE))) {
                    if (System.currentTimeMillis() >= scrollBeginTime) {
                        Rectangle area = text.getClientArea();
                        GC gc = new GC(text);
                        FontMetrics fm = gc.getFontMetrics();
                        gc.dispose();
                        int charWidth = fm.getAverageCharWidth();
                        int scrollAmount = 10*charWidth;
                        if (pt.x < area.x + 3*charWidth) {
                            int leftPixel = text.getHorizontalPixel();
                            text.setHorizontalPixel(leftPixel - scrollAmount);
                        }
                        if (pt.x > area.width - 3*charWidth) {
                            int leftPixel = text.getHorizontalPixel();
                            text.setHorizontalPixel(leftPixel + scrollAmount);
                        }
                        int lineHeight = text.getLineHeight();
                        if (pt.y < area.y + lineHeight) {
                            int topPixel = text.getTopPixel();
                            text.setTopPixel(topPixel - lineHeight);
                        }
                        if (pt.y > area.height - lineHeight) {
                            int topPixel = text.getTopPixel();
                            text.setTopPixel(topPixel + lineHeight);
                        }
                        scrollBeginTime = 0;
                        scrollX = scrollY = -1;
                    }
                } else {
                    scrollBeginTime = System.currentTimeMillis() + SCROLL_HYSTERESIS;
                    scrollX = pt.x;
                    scrollY = pt.y;
                }
            }
        }

        if ((effect & DND.FEEDBACK_SELECT) !is 0) {
            int[] trailing = new int [1];
            int newOffset = text.getOffsetAtPoint(pt.x, pt.y, trailing, false);
            newOffset += trailing [0];
            if (newOffset !is currentOffset) {
                refreshCaret(text, currentOffset, newOffset);
                currentOffset = newOffset;
            }
        }
    }

    void refreshCaret(StyledText text, int oldOffset, int newOffset) {
        if (oldOffset !is newOffset) {
            if (oldOffset !is -1) {
                Point oldPos = text.getLocationAtOffset(oldOffset);
                int oldHeight = text.getLineHeight(oldOffset);
                text.redraw (oldPos.x, oldPos.y, CARET_WIDTH, oldHeight, false);
            }
            if (newOffset !is -1) {
                Point newPos = text.getLocationAtOffset(newOffset);
                int newHeight = text.getLineHeight(newOffset);
                text.redraw (newPos.x, newPos.y, CARET_WIDTH, newHeight, false);
            }
        }
    }

    /**
     * This implementation of <code>dropAccept</code> provides a default drag under effect
     * for the feedback specified in <code>event.feedback</code>.
     *
     * For additional information see <code>DropTargetAdapter.dropAccept</code>.
     *
     * Subclasses that override this method should call <code>super.dropAccept(event)</code>
     * to get the default drag under effect implementation.
     *
     * @param event  the information associated with the drop accept event
     *
     * @see DropTargetAdapter
     * @see DropTargetEvent
     */
    public override void dropAccept(DropTargetEvent event) {
        if (currentOffset !is -1) {
            StyledText text = cast(StyledText) getControl();
            text.setSelection(currentOffset);
            currentOffset = -1;
        }
    }
}
