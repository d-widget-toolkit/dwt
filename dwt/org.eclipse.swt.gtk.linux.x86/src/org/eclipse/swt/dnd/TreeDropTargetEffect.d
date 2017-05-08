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
module org.eclipse.swt.dnd.TreeDropTargetEffect;

import java.lang.all;


import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.dnd.DropTargetEffect;
import org.eclipse.swt.dnd.DropTargetEvent;
import org.eclipse.swt.dnd.DND;

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
    static const int SCROLL_HYSTERESIS = 150; // milli seconds
    static const int EXPAND_HYSTERESIS = 1000; // milli seconds

    int scrollIndex = -1;
    long scrollBeginTime;

    int expandIndex = -1;
    long expandBeginTime;

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
    public override void dragEnter(DropTargetEvent event) {
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
    public override void dragLeave(DropTargetEvent event) {
        Tree tree = cast(Tree) control;
        auto handle = tree.handle;
        OS.gtk_tree_view_set_drag_dest_row(handle, null, OS.GTK_TREE_VIEW_DROP_BEFORE);

        scrollBeginTime = 0;
        scrollIndex = -1;
        expandBeginTime = 0;
        expandIndex = -1;
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
    public override void dragOver(DropTargetEvent event) {
        Tree tree = cast(Tree) control;
        int effect = checkEffect(event.feedback);

        auto handle = tree.handle;
        Point coordinates = new Point(event.x, event.y);
        coordinates = tree.toControl(coordinates);
        void* path;
        OS.gtk_tree_view_get_path_at_pos (handle, coordinates.x, coordinates.y, &path, null, null, null);
        int index = -1;
        if (path !is null) {
            auto indices = OS.gtk_tree_path_get_indices(path);
            if (indices !is null) {
                ptrdiff_t depth = OS.gtk_tree_path_get_depth(path);
                index = indices[depth - 1];
            }
        }
        if ((effect & DND.FEEDBACK_SCROLL) is 0) {
            scrollBeginTime = 0;
            scrollIndex = -1;
        } else {
            if (index !is -1 && scrollIndex is index && scrollBeginTime !is 0) {
                if (System.currentTimeMillis() >= scrollBeginTime) {
                    GdkRectangle cellRect;
                    OS.gtk_tree_view_get_cell_area (handle, path, null, &cellRect);
                    if (cellRect.y < cellRect.height) {
                        int tx, ty;
                        OS.gtk_tree_view_widget_to_tree_coords(handle, cellRect.x, cellRect.y - cellRect.height, &tx, &ty);
                        OS.gtk_tree_view_scroll_to_point (handle, -1, ty);
                    } else {
                        //scroll down
                        OS.gtk_tree_view_get_path_at_pos (handle, coordinates.x, coordinates.y + cellRect.height, &path, null, null, null);
                        if (path !is null) {
                            OS.gtk_tree_view_scroll_to_cell(handle, path, null, false, 0, 0);
                            OS.gtk_tree_path_free(path);
                            path = null;
                        }
                        OS.gtk_tree_view_get_path_at_pos (handle, coordinates.x, coordinates.y, &path, null, null, null);
                    }
                    scrollBeginTime = 0;
                    scrollIndex = -1;
                }
            } else {
                scrollBeginTime = System.currentTimeMillis() + SCROLL_HYSTERESIS;
                scrollIndex = index;
            }
        }
        if ((effect & DND.FEEDBACK_EXPAND) is 0) {
            expandBeginTime = 0;
            expandIndex = -1;
        } else {
            if (index !is -1 && expandIndex is index && expandBeginTime !is 0) {
                if (System.currentTimeMillis() >= expandBeginTime) {
                    OS.gtk_tree_view_expand_row (handle, path, false);
                    expandBeginTime = 0;
                    expandIndex = -1;
                }
            } else {
                expandBeginTime = System.currentTimeMillis() + EXPAND_HYSTERESIS;
                expandIndex = index;
            }
        }
        if (path !is null) {
            int position = -1;
            if ((effect & DND.FEEDBACK_SELECT) !is 0) position = OS.GTK_TREE_VIEW_DROP_INTO_OR_BEFORE;
            if ((effect & DND.FEEDBACK_INSERT_BEFORE) !is 0) position = OS.GTK_TREE_VIEW_DROP_BEFORE;
            if ((effect & DND.FEEDBACK_INSERT_AFTER) !is 0) position = OS.GTK_TREE_VIEW_DROP_AFTER;
            if (position !is -1) {
                OS.gtk_tree_view_set_drag_dest_row(handle, path, position);
            } else {
                OS.gtk_tree_view_set_drag_dest_row(handle, null, OS.GTK_TREE_VIEW_DROP_BEFORE);
            }
        } else {
            OS.gtk_tree_view_set_drag_dest_row(handle, null, OS.GTK_TREE_VIEW_DROP_BEFORE);
        }

        if (path !is null) OS.gtk_tree_path_free (path );
    }

}
