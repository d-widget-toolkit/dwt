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
module org.eclipse.swt.dnd.TableDragSourceEffect;

import java.lang.all;


import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.dnd.DragSourceEffect;
import org.eclipse.swt.dnd.DragSourceEvent;


/**
 * This class provides default implementations to display a source image
 * when a drag is initiated from a <code>Table</code>.
 *
 * <p>Classes that wish to provide their own source image for a <code>Table</code> can
 * extend the <code>TableDragSourceEffect</code> class, override the
 * <code>TableDragSourceEffect.dragStart</code> method and set the field
 * <code>DragSourceEvent.image</code> with their own image.</p>
 *
 * Subclasses that override any methods of this class must call the corresponding
 * <code>super</code> method to get the default drag source effect implementation.
 *
 * @see DragSourceEffect
 * @see DragSourceEvent
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.3
 */
public class TableDragSourceEffect : DragSourceEffect {
    Image dragSourceImage = null;

    /**
     * Creates a new <code>TableDragSourceEffect</code> to handle drag effect
     * from the specified <code>Table</code>.
     *
     * @param table the <code>Table</code> that the user clicks on to initiate the drag
     */
    public this(Table table) {
        super(table);
    }

    /**
     * This implementation of <code>dragFinished</code> disposes the image
     * that was created in <code>TableDragSourceEffect.dragStart</code>.
     *
     * Subclasses that override this method should call <code>super.dragFinished(event)</code>
     * to dispose the image in the default implementation.
     *
     * @param event the information associated with the drag finished event
     */
    public override void dragFinished(DragSourceEvent event) {
        if (dragSourceImage !is null) dragSourceImage.dispose();
        dragSourceImage = null;
    }

    /**
     * This implementation of <code>dragStart</code> will create a default
     * image that will be used during the drag. The image should be disposed
     * when the drag is completed in the <code>TableDragSourceEffect.dragFinished</code>
     * method.
     *
     * Subclasses that override this method should call <code>super.dragStart(event)</code>
     * to use the image from the default implementation.
     *
     * @param event the information associated with the drag start event
     */
    public override void dragStart(DragSourceEvent event) {
        event.image = getDragSourceImage(event);
    }

    Image getDragSourceImage(DragSourceEvent event) {
        if (dragSourceImage !is null) dragSourceImage.dispose();
        dragSourceImage = null;

        Table table = cast(Table) control;
        if (OS.GTK_VERSION < OS.buildVERSION (2, 2, 0)) return null;
        //TEMPORARY CODE
        if (table.isListening(SWT.EraseItem) || table.isListening (SWT.PaintItem)) return null;
        /*
        * Bug in GTK.  gtk_tree_selection_get_selected_rows() segmentation faults
        * in versions smaller than 2.2.4 if the model is NULL.  The fix is
        * to give a valid pointer instead.
        */
        auto handle = table.handle;
        auto selection = OS.gtk_tree_view_get_selection (handle);
        int dummy;
        void* model = OS.GTK_VERSION < OS.buildVERSION (2, 2, 4) ? &dummy : null;
        auto list = OS.gtk_tree_selection_get_selected_rows (selection, &model);
        if (list is null) return null;
        ptrdiff_t count = Math.min(10, OS.g_list_length (list));

        Display display = table.getDisplay();
        if (count is 1) {
            auto path = OS.g_list_nth_data (list, 0);
            auto pixmap = OS.gtk_tree_view_create_row_drag_icon(handle, path);
            dragSourceImage =  Image.gtk_new(display, SWT.ICON, pixmap, null);
        } else {
            int width = 0, height = 0;
            int w, h;
            int[] yy, hh; yy.length = count; hh.length = count;
            GdkDrawable*[] pixmaps; pixmaps.length = count;
            GdkRectangle rect;
            for (int i=0; i<count; i++) {
                auto path = OS.g_list_nth_data (list, i);
                OS.gtk_tree_view_get_cell_area (handle, path, null, &rect);
                pixmaps[i] = OS.gtk_tree_view_create_row_drag_icon(handle, path);
                OS.gdk_drawable_get_size(pixmaps[i], &w, &h);
                width = Math.max(width, w);
                height = rect.y + h - yy[0];
                yy[i] = rect.y;
                hh[i] = h;
            }
            auto source = OS.gdk_pixmap_new(OS.GDK_ROOT_PARENT(), width, height, -1);
            auto gcSource = OS.gdk_gc_new(source);
            auto mask = OS.gdk_pixmap_new(OS.GDK_ROOT_PARENT(), width, height, 1);
            auto gcMask = OS.gdk_gc_new(mask);
            GdkColor color;
            color.pixel = 0;
            OS.gdk_gc_set_foreground(gcMask, &color);
            OS.gdk_draw_rectangle(mask, gcMask, 1, 0, 0, width, height);
            color.pixel = 1;
            OS.gdk_gc_set_foreground(gcMask, &color);
            for (int i=0; i<count; i++) {
                OS.gdk_draw_drawable(source, gcSource, pixmaps[i], 0, 0, 0, yy[i] - yy[0], -1, -1);
                OS.gdk_draw_rectangle(mask, gcMask, 1, 0, yy[i] - yy[0], width, hh[i]);
                OS.g_object_unref(pixmaps[i]);
            }
            OS.g_object_unref(gcSource);
            OS.g_object_unref(gcMask);
            dragSourceImage  = Image.gtk_new(display, SWT.ICON, source, mask);
        }
        OS.g_list_free (list);

        return dragSourceImage;
}
}
