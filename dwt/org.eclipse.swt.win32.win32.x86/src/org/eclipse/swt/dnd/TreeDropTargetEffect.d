/*******************************************************************************
 * Copyright (c) 2007, 2008 IBM Corporation and others.
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
module org.eclipse.swt.dnd.TreeDropTargetEffect;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.TreeItem;

import org.eclipse.swt.dnd.DropTargetEffect;
import org.eclipse.swt.dnd.DropTargetEvent;
import org.eclipse.swt.dnd.DND;

import java.lang.all;

/**
 * This class provides a default drag under effect (eg. select, insert, scroll and expand)
 * when a drag occurs over a <code>Tree</code>.
 *
 * <p>Classes that wish to provide their own drag under effect for a <code>Tree</code>
 * can extend the <code>TreeDropTargetEffect</code> class and override any applicable methods
 * in <code>TreeDropTargetEffect</code> to display their own drag under effect.</p>
 *
 * Subclasses that override any methods of this class must call the corresponding
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
 * <dd>FEEDBACK_SELECT, FEEDBACK_INSERT_BEFORE, FEEDBACK_INSERT_AFTER, FEEDBACK_EXPAND, FEEDBACK_SCROLL</dd>
 * </dl>
 * </p><p>
 * Note: Only one of the styles FEEDBACK_SELECT, FEEDBACK_INSERT_BEFORE or
 * FEEDBACK_INSERT_AFTER may be specified.
 * </p>
 *
 * @see DropTargetAdapter
 * @see DropTargetEvent
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.3
 */
public class TreeDropTargetEffect : DropTargetEffect {
    static const int SCROLL_HYSTERESIS = 200; // milli seconds
    static const int EXPAND_HYSTERESIS = 1000; // milli seconds

    ptrdiff_t dropIndex;
    ptrdiff_t scrollIndex;
    long scrollBeginTime;
    ptrdiff_t expandIndex;
    long expandBeginTime;
    TreeItem insertItem;
    bool insertBefore;

    /**
     * Creates a new <code>TreeDropTargetEffect</code> to handle the drag under effect on the specified
     * <code>Tree</code>.
     *
     * @param tree the <code>Tree</code> over which the user positions the cursor to drop the data
     */
    public this(Tree tree) {
        super(tree);
    }

    int checkEffect(int effect) {
        // Some effects are mutually exclusive.  Make sure that only one of the mutually exclusive effects has been specified.
        if ((effect & DND.FEEDBACK_SELECT) !is 0) effect = effect & ~DND.FEEDBACK_INSERT_AFTER & ~DND.FEEDBACK_INSERT_BEFORE;
        if ((effect & DND.FEEDBACK_INSERT_BEFORE) !is 0) effect = effect & ~DND.FEEDBACK_INSERT_AFTER;
        return effect;
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
     * @param event  the information associated with the drag enter event
     *
     * @see DropTargetAdapter
     * @see DropTargetEvent
     */
    override
    public void dragEnter(DropTargetEvent event) {
        dropIndex = -1;
        insertItem = null;
        expandBeginTime = 0;
        expandIndex = -1;
        scrollBeginTime = 0;
        scrollIndex = -1;
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
    override
    public void dragLeave(DropTargetEvent event) {
        Tree tree = cast(Tree) control;
        auto handle = tree.handle;
        if (dropIndex !is -1) {
            TVITEM tvItem;
            tvItem.hItem = cast(HTREEITEM) dropIndex;
            tvItem.mask = OS.TVIF_STATE;
            tvItem.stateMask = OS.TVIS_DROPHILITED;
            tvItem.state = 0;
            OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
            dropIndex = -1;
        }
        if (insertItem !is null) {
            tree.setInsertMark(null, false);
            insertItem = null;
        }
        expandBeginTime = 0;
        expandIndex = -1;
        scrollBeginTime = 0;
        scrollIndex = -1;
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
     * @see DND#FEEDBACK_INSERT_BEFORE
     * @see DND#FEEDBACK_INSERT_AFTER
     * @see DND#FEEDBACK_SCROLL
     */
    override
    public void dragOver(DropTargetEvent event) {
        Tree tree = cast(Tree) getControl();
        int effect = checkEffect(event.feedback);
        auto handle = tree.handle;
        Point coordinates = new Point(event.x, event.y);
        coordinates = tree.toControl(coordinates);
        TVHITTESTINFO lpht;
        lpht.pt.x = coordinates.x;
        lpht.pt.y = coordinates.y;
        OS.SendMessage (handle, OS.TVM_HITTEST, 0, &lpht);
        auto hItem = cast(ptrdiff_t)lpht.hItem;
        if ((effect & DND.FEEDBACK_SCROLL) is 0) {
            scrollBeginTime = 0;
            scrollIndex = -1;
        } else {
            if (hItem !is -1 && scrollIndex is hItem && scrollBeginTime !is 0) {
                if (System.currentTimeMillis() >= scrollBeginTime) {
                    auto topItem = cast(HTREEITEM)OS.SendMessage(handle, OS.TVM_GETNEXTITEM, OS.TVGN_FIRSTVISIBLE, 0);
                    auto nextItem = cast(HTREEITEM)OS.SendMessage(handle, OS.TVM_GETNEXTITEM, cast(HTREEITEM)hItem is topItem ? OS.TVGN_PREVIOUSVISIBLE : OS.TVGN_NEXTVISIBLE, hItem);
                    bool scroll = true;
                    if (cast(HTREEITEM)hItem is topItem) {
                        scroll = nextItem !is null;
                    } else {
                        RECT itemRect;
                        if (OS.TreeView_GetItemRect (handle, nextItem, &itemRect, true)) {
                            RECT rect;
                            OS.GetClientRect (handle, &rect);
                            POINT pt;
                            pt.x = itemRect.left;
                            pt.y = itemRect.top;
                            if (OS.PtInRect (&rect, pt)) {
                                pt.y = itemRect.bottom;
                                if (OS.PtInRect (&rect, pt)) scroll = false;
                            }
                        }
                    }
                    if (scroll) {
                        OS.SendMessage (handle, OS.TVM_ENSUREVISIBLE, 0, nextItem);
                        tree.redraw();
                    }
                    scrollBeginTime = 0;
                    scrollIndex = -1;
                }
            } else {
                scrollBeginTime = System.currentTimeMillis() + SCROLL_HYSTERESIS;
                scrollIndex = hItem;
            }
        }
        if ((effect & DND.FEEDBACK_EXPAND) is 0) {
            expandBeginTime = 0;
            expandIndex = -1;
        } else {
            if (hItem !is -1 && expandIndex is hItem && expandBeginTime !is 0) {
                if (System.currentTimeMillis() >= expandBeginTime) {
                    if (OS.SendMessage (handle, OS.TVM_GETNEXTITEM, OS.TVGN_CHILD, hItem) !is 0) {
                        TreeItem item = cast(TreeItem)tree.getDisplay().findWidget(tree.handle, hItem);
                        if (item !is null && !item.getExpanded()) {
                            item.setExpanded(true);
                            tree.redraw();
                            Event expandEvent = new Event ();
                            expandEvent.item = item;
                            tree.notifyListeners(SWT.Expand, expandEvent);
                        }
                    }
                    expandBeginTime = 0;
                    expandIndex = -1;
                }
            } else {
                expandBeginTime = System.currentTimeMillis() + EXPAND_HYSTERESIS;
                expandIndex = hItem;
            }
        }
        if (dropIndex !is -1 && (dropIndex !is hItem || (effect & DND.FEEDBACK_SELECT) is 0)) {
            TVITEM tvItem;
            tvItem.hItem = cast(HTREEITEM) dropIndex;
            tvItem.mask = OS.TVIF_STATE;
            tvItem.stateMask = OS.TVIS_DROPHILITED;
            tvItem.state = 0;
            OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
            dropIndex = -1;
        }
        if (hItem !is -1 && hItem !is dropIndex && (effect & DND.FEEDBACK_SELECT) !is 0) {
            TVITEM tvItem;
            tvItem.hItem = cast(HTREEITEM) hItem;
            tvItem.mask = OS.TVIF_STATE;
            tvItem.stateMask = OS.TVIS_DROPHILITED;
            tvItem.state = OS.TVIS_DROPHILITED;
            OS.SendMessage (handle, OS.TVM_SETITEM, 0, &tvItem);
            dropIndex = hItem;
        }
        if ((effect & DND.FEEDBACK_INSERT_BEFORE) !is 0 || (effect & DND.FEEDBACK_INSERT_AFTER) !is 0) {
            bool before = (effect & DND.FEEDBACK_INSERT_BEFORE) !is 0;
            /*
            * Bug in Windows.  When TVM_SETINSERTMARK is used to set
            * an insert mark for a tree and an item is expanded or
            * collapsed near the insert mark, the tree does not redraw
            * the insert mark properly.  The fix is to hide and show
            * the insert mark whenever an item is expanded or collapsed.
            * Since the insert mark can not be queried from the tree,
            * use the Tree API rather than calling the OS directly.
            */
            TreeItem item = cast(TreeItem)tree.getDisplay().findWidget(tree.handle, hItem);
            if (item !is null) {
                if (item !is insertItem || before !is insertBefore) {
                    tree.setInsertMark(item, before);
                }
                insertItem = item;
                insertBefore = before;
            } else {
                if (insertItem !is null) {
                    tree.setInsertMark(null, false);
                }
                insertItem = null;
            }
        } else {
            if (insertItem !is null) {
                tree.setInsertMark(null, false);
            }
            insertItem = null;
        }
    }
}
