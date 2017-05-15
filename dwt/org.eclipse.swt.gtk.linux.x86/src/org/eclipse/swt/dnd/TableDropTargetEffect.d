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
module org.eclipse.swt.dnd.TableDropTargetEffect;

import java.lang.all;


import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.dnd.DropTargetEffect;
import org.eclipse.swt.dnd.DropTargetEvent;
import org.eclipse.swt.dnd.DND;


/**
 * This class provides a default drag under effect (eg. select, insert and scroll)
 * when a drag occurs over a <code>Table</code>.
 *
 * <p>Classes that wish to provide their own drag under effect for a <code>Table</code>
 * can extend the <code>TableDropTargetEffect</code> and override any applicable methods
 * in <code>TableDropTargetEffect</code> to display their own drag under effect.</p>
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
public class TableDropTargetEffect : DropTargetEffect {
    static const int SCROLL_HYSTERESIS = 150; // milli seconds

    int scrollIndex;
    long scrollBeginTime;

    /**
     * Creates a new <code>TableDropTargetEffect</code> to handle the drag under effect on the specified
     * <code>Table</code>.
     *
     * @param table the <code>Table</code> over which the user positions the cursor to drop the data
     */
    public this(Table table) {
        super(table);
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
        Table table = cast(Table) control;
        auto handle = table.handle;
        OS.gtk_tree_view_set_drag_dest_row(handle, null, OS.GTK_TREE_VIEW_DROP_BEFORE);

        scrollBeginTime = 0;
        scrollIndex = -1;
    }

    /**
     * This implementation of <code>dragOver</code> provides a default drag under effect
     * for the feedback specified in <code>event.feedback</code>. The class description
     * lists the FEEDBACK constants that are applicable to the class.
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
        Table table = cast(Table) control;
        auto handle = table.handle;
        int effect = checkEffect(event.feedback);
        Point coordinates = new Point(event.x, event.y);
        coordinates = table.toControl(coordinates);
        void* path;
        OS.gtk_tree_view_get_path_at_pos (handle, coordinates.x, coordinates.y, &path, null, null, null);
        int index = -1;
        if (path !is null) {
            auto indices = OS.gtk_tree_path_get_indices (path);
            if (indices !is null) {
                index = indices[0];
            }
        }
        if ((effect & DND.FEEDBACK_SCROLL) is 0) {
            scrollBeginTime = 0;
            scrollIndex = -1;
        } else {
            if (index !is -1 && scrollIndex is index && scrollBeginTime !is 0) {
                if (System.currentTimeMillis() >= scrollBeginTime) {
                    if (coordinates.y < table.getItemHeight()) {
                        OS.gtk_tree_path_prev(path);
                    } else {
                        OS.gtk_tree_path_next(path);
                    }
                    if (path !is null) {
                        OS.gtk_tree_view_scroll_to_cell(handle, path, null, false, 0, 0);
                        OS.gtk_tree_path_free(path);
                        path = null;
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
        if (path !is null) {
            ptrdiff_t position = 0;
            if ((effect & DND.FEEDBACK_SELECT) !is 0) position = OS.GTK_TREE_VIEW_DROP_INTO_OR_BEFORE;
            //if ((effect & DND.FEEDBACK_INSERT_BEFORE) !is 0) position = OS.GTK_TREE_VIEW_DROP_BEFORE;
            //if ((effect & DND.FEEDBACK_INSERT_AFTER) !is 0) position = OS.GTK_TREE_VIEW_DROP_AFTER;
            if (position !is 0) {
                OS.gtk_tree_view_set_drag_dest_row(handle, path, OS.GTK_TREE_VIEW_DROP_INTO_OR_BEFORE);
            } else {
                OS.gtk_tree_view_set_drag_dest_row(handle, null, OS.GTK_TREE_VIEW_DROP_BEFORE);
            }
        } else {
            OS.gtk_tree_view_set_drag_dest_row(handle, null, OS.GTK_TREE_VIEW_DROP_BEFORE);
        }
        if (path !is null) OS.gtk_tree_path_free (path );
    }
}
