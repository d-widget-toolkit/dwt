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
module org.eclipse.swt.dnd.DragSource;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.dnd.Transfer;
import org.eclipse.swt.dnd.DragSourceEffect;
import org.eclipse.swt.dnd.DragSourceListener;
import org.eclipse.swt.dnd.DND;
import org.eclipse.swt.dnd.TreeDragSourceEffect;
import org.eclipse.swt.dnd.TableDragSourceEffect;
import org.eclipse.swt.dnd.DNDListener;
import org.eclipse.swt.dnd.DNDEvent;
import org.eclipse.swt.dnd.TransferData;
import java.lang.all;

import java.lang.Thread;

/**
 *
 * <code>DragSource</code> defines the source object for a drag and drop transfer.
 *
 * <p>IMPORTANT: This class is <em>not</em> intended to be subclassed.</p>
 *
 * <p>A drag source is the object which originates a drag and drop operation. For the specified widget,
 * it defines the type of data that is available for dragging and the set of operations that can
 * be performed on that data.  The operations can be any bit-wise combination of DND.MOVE, DND.COPY or
 * DND.LINK.  The type of data that can be transferred is specified by subclasses of Transfer such as
 * TextTransfer or FileTransfer.  The type of data transferred can be a predefined system type or it
 * can be a type defined by the application.  For instructions on how to define your own transfer type,
 * refer to <code>ByteArrayTransfer</code>.</p>
 *
 * <p>You may have several DragSources in an application but you can only have one DragSource
 * per Control.  Data dragged from this DragSource can be dropped on a site within this application
 * or it can be dropped on another application such as an external Text editor.</p>
 *
 * <p>The application supplies the content of the data being transferred by implementing the
 * <code>DragSourceListener</code> and associating it with the DragSource via DragSource#addDragListener.</p>
 *
 * <p>When a successful move operation occurs, the application is required to take the appropriate
 * action to remove the data from its display and remove any associated operating system resources or
 * internal references.  Typically in a move operation, the drop target makes a copy of the data
 * and the drag source deletes the original.  However, sometimes copying the data can take a long
 * time (such as copying a large file).  Therefore, on some platforms, the drop target may actually
 * move the data in the operating system rather than make a copy.  This is usually only done in
 * file transfers.  In this case, the drag source is informed in the DragEnd event that a
 * DROP_TARGET_MOVE was performed.  It is the responsibility of the drag source at this point to clean
 * up its displayed information.  No action needs to be taken on the operating system resources.</p>
 *
 * <p> The following example shows a Label widget that allows text to be dragged from it.</p>
 *
 * <code><pre>
 *  // Enable a label as a Drag Source
 *  Label label = new Label(shell, SWT.NONE);
 *  // This example will allow text to be dragged
 *  Transfer[] types = new Transfer[] {TextTransfer.getInstance()};
 *  // This example will allow the text to be copied or moved to the drop target
 *  int operations = DND.DROP_MOVE | DND.DROP_COPY;
 *
 *  DragSource source = new DragSource(label, operations);
 *  source.setTransfer(types);
 *  source.addDragListener(new DragSourceListener() {
 *      public void dragStart(DragSourceEvent e) {
 *          // Only start the drag if there is actually text in the
 *          // label - this text will be what is dropped on the target.
 *          if (label.getText().length() is 0) {
 *              event.doit = false;
 *          }
 *      };
 *      public void dragSetData(DragSourceEvent event) {
 *          // A drop has been performed, so provide the data of the
 *          // requested type.
 *          // (Checking the type of the requested data is only
 *          // necessary if the drag source supports more than
 *          // one data type but is shown here as an example).
 *          if (TextTransfer.getInstance().isSupportedType(event.dataType)){
 *              event.data = label.getText();
 *          }
 *      }
 *      public void dragFinished(DragSourceEvent event) {
 *          // A Move operation has been performed so remove the data
 *          // from the source
 *          if (event.detail is DND.DROP_MOVE)
 *              label.setText("");
 *      }
 *  });
 * </pre></code>
 *
 *
 * <dl>
 *  <dt><b>Styles</b></dt> <dd>DND.DROP_NONE, DND.DROP_COPY, DND.DROP_MOVE, DND.DROP_LINK</dd>
 *  <dt><b>Events</b></dt> <dd>DND.DragStart, DND.DragSetData, DND.DragEnd</dd>
 * </dl>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#dnd">Drag and Drop snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: DNDExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class DragSource : Widget {

    // info for registering as a drag source
    Control control;
    Listener controlListener;
    Transfer[] transferAgents;
    DragSourceEffect dragEffect;

    void* targetList;

    //workaround - remember action performed for DragEnd
    bool moveData = false;

    static const String DEFAULT_DRAG_SOURCE_EFFECT = "DEFAULT_DRAG_SOURCE_EFFECT"; //$NON-NLS-1$

//     static Callback DragGetData;
//     static Callback DragEnd;
//     static Callback DragDataDelete;
//     static this() {
//         DragGetData = new Callback(DragSource.class, "DragGetData", 5);  //$NON-NLS-1$
//         if (DragGetData.getAddress() is 0) SWT.error(SWT.ERROR_NO_MORE_CALLBACKS);
//         DragEnd = new Callback(DragSource.class, "DragEnd", 2); //$NON-NLS-1$
//         if (DragEnd.getAddress() is 0) SWT.error(SWT.ERROR_NO_MORE_CALLBACKS);
//         DragDataDelete = new Callback(DragSource.class, "DragDataDelete", 2); //$NON-NLS-1$
//         if (DragDataDelete.getAddress() is 0) SWT.error(SWT.ERROR_NO_MORE_CALLBACKS);
//     }

/**
 * Creates a new <code>DragSource</code> to handle dragging from the specified <code>Control</code>.
 * Creating an instance of a DragSource may cause system resources to be allocated depending on the platform.
 * It is therefore mandatory that the DragSource instance be disposed when no longer required.
 *
 * @param control the <code>Control</code> that the user clicks on to initiate the drag
 * @param style the bitwise OR'ing of allowed operations; this may be a combination of any of
 *                  DND.DROP_NONE, DND.DROP_COPY, DND.DROP_MOVE, DND.DROP_LINK
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_CANNOT_INIT_DRAG - unable to initiate drag source; this will occur if more than one
 *        drag source is created for a control or if the operating system will not allow the creation
 *        of the drag source</li>
 * </ul>
 *
 * <p>NOTE: ERROR_CANNOT_INIT_DRAG should be an SWTException, since it is a
 * recoverable error, but can not be changed due to backward compatibility.</p>
 *
 * @see Widget#dispose
 * @see DragSource#checkSubclass
 * @see DND#DROP_NONE
 * @see DND#DROP_COPY
 * @see DND#DROP_MOVE
 * @see DND#DROP_LINK
 */
public this(Control control, int style) {
    super (control, checkStyle(style));
    this.control = control;
//     if (DragGetData is null || DragEnd is null || DragDataDelete is null) {
//         DND.error(DND.ERROR_CANNOT_INIT_DRAG);
//     }
    if (control.getData(DND.DRAG_SOURCE_KEY) !is null) {
        DND.error(DND.ERROR_CANNOT_INIT_DRAG);
    }
    control.setData(DND.DRAG_SOURCE_KEY, this);

    OS.g_signal_connect(control.handle, OS.drag_data_get.ptr, cast(GCallback)&DragGetData, null);
    OS.g_signal_connect(control.handle, OS.drag_end.ptr, cast(GCallback)&DragEnd, null);
    OS.g_signal_connect(control.handle, OS.drag_data_delete.ptr, cast(GCallback)&DragDataDelete, null);

    controlListener = new class() Listener {
        public void handleEvent (Event event) {
            if (event.type is SWT.Dispose) {
                if (!this.outer.isDisposed()) {
                    this.outer.dispose();
                }
            }
            if (event.type is SWT.DragDetect) {
                if (!this.outer.isDisposed()) {
                    this.outer.drag(event);
                }
            }
        }
    };
    control.addListener (SWT.Dispose, controlListener);
    control.addListener (SWT.DragDetect, controlListener);

    Object effect = control.getData(DEFAULT_DRAG_SOURCE_EFFECT);
    if ( auto de = cast(DragSourceEffect)effect ) {
        dragEffect = de;
    } else if ( auto tree = cast(Tree)control) {
        dragEffect = new TreeDragSourceEffect(tree);
    } else if ( auto table = cast(Table)control ) {
        dragEffect = new TableDragSourceEffect(table);
    }

    this.addListener(SWT.Dispose, new class() Listener {
        public void handleEvent(Event e) {
            onDispose();
        }
    });
}

static int checkStyle (int style) {
    if (style is SWT.NONE) return DND.DROP_MOVE;
    return style;
}

private static extern(C) void DragDataDelete(
    GtkWidget      *widget,
    GdkDragContext *drag_context,
    void*           user_data )
{
    DragSource source = FindDragSource(widget);
    if (source is null) return;
    source.dragDataDelete(widget, drag_context);
    return;
}

private static extern(C) void DragEnd (
    GtkWidget      *widget,
    GdkDragContext *drag_context,
    void*           user_data)
{
    DragSource source = FindDragSource(widget);
    if (source is null) return;
    source.dragEnd(widget, drag_context);
    return;
}

private static extern(C) void DragGetData(
    GtkWidget        *widget,
    GdkDragContext   *context,
    GtkSelectionData *selection_data,
    uint              info,
    uint              time,
    void*             user_data )
{
    DragSource source = FindDragSource(widget);
    if (source is null) return;
    source.dragGetData(widget, context, selection_data, info, time);
    return;
}

static DragSource FindDragSource(GtkWidget* handle) {
    Display display = Display.findDisplay(Thread.currentThread());
    if (display is null || display.isDisposed()) return null;
    Widget widget = display.findWidget(handle);
    if (widget is null) return null;
    return cast(DragSource)widget.getData(DND.DRAG_SOURCE_KEY);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when a drag and drop operation is in progress, by sending
 * it one of the messages defined in the <code>DragSourceListener</code>
 * interface.
 *
 * <p><ul>
 * <li><code>dragStart</code> is called when the user has begun the actions required to drag the widget.
 * This event gives the application the chance to decide if a drag should be started.
 * <li><code>dragSetData</code> is called when the data is required from the drag source.
 * <li><code>dragFinished</code> is called when the drop has successfully completed (mouse up
 * over a valid target) or has been terminated (such as hitting the ESC key). Perform cleanup
 * such as removing data from the source side on a successful move operation.
 * </ul></p>
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DragSourceListener
 * @see #getDragListeners
 * @see #removeDragListener
 * @see DragSourceEvent
 */
public void addDragListener(DragSourceListener listener) {
    if (listener is null) DND.error (SWT.ERROR_NULL_ARGUMENT);
    DNDListener typedListener = new DNDListener (listener);
    typedListener.dndWidget = this;
    addListener (DND.DragStart, typedListener);
    addListener (DND.DragSetData, typedListener);
    addListener (DND.DragEnd, typedListener);
}

protected override void checkSubclass () {
    String name = this.classinfo.name;
    String validName = DragSource.classinfo.name;
    if ( validName !=/*eq*/ name ) {
        DND.error (SWT.ERROR_INVALID_SUBCLASS);
    }
}

void drag(Event dragEvent) {
    moveData = false;
    DNDEvent event = new DNDEvent();
    event.widget = this;
    event.x = dragEvent.x;
    event.y = dragEvent.y;
    event.time = dragEvent.time;
    event.doit = true;
    notifyListeners(DND.DragStart, event);
    if (!event.doit || transferAgents is null || transferAgents.length is 0) return;
    if (targetList is null) return;

    int actions = opToOsOp(getStyle());
    Image image = event.image;
    auto context = OS.gtk_drag_begin(control.handle, targetList, actions, 1, null);
    if (context !is null && image !is null) {
        auto pixbuf = createPixbuf(image);
        OS.gtk_drag_set_icon_pixbuf(context, pixbuf, 0, 0);
        OS.g_object_unref(pixbuf);
    }
}

void dragEnd(
    GtkWidget      *widget,
    GdkDragContext *context )
{
    /*
     * Bug in GTK.  If a drag is initiated using gtk_drag_begin and the
     * mouse is released immediately, the mouse and keyboard remain
     * grabbed.  The fix is to release the grab on the mouse and keyboard
     * whenever the drag is terminated.
     *
     * NOTE: We believe that it is never an error to ungrab when
     * a drag is finished.
     */
    OS.gdk_pointer_ungrab(OS.GDK_CURRENT_TIME);
    OS.gdk_keyboard_ungrab(OS.GDK_CURRENT_TIME);

    int operation = DND.DROP_NONE;
    if (context !is null) {
        GdkDragContext* gdkDragContext = context;
        if (gdkDragContext.dest_window !is null) { //NOTE: if dest_window is 0, drag was aborted
            if (moveData) {
                operation = DND.DROP_MOVE;
            } else {
                operation = osOpToOp(gdkDragContext.action);
                if (operation is DND.DROP_MOVE) operation = DND.DROP_NONE;
            }
        }
    }

    DNDEvent event = new DNDEvent();
    event.widget = this;
    //event.time = ???
    event.doit = operation !is 0;
    event.detail = operation;
    notifyListeners(DND.DragEnd, event);
    moveData = false;
}

void dragGetData(
    GtkWidget        *widget,
    GdkDragContext   *context,
    GtkSelectionData *gtkSelectionData,
    uint              info,
    uint              time )
{
    if (gtkSelectionData is null) return;
    if (gtkSelectionData.target is null) return;

    TransferData transferData = new TransferData();
    transferData.type = gtkSelectionData.target;
    transferData.pValue = gtkSelectionData.data;
    transferData.length = gtkSelectionData.length;
    transferData.format = gtkSelectionData.format;

    DNDEvent event = new DNDEvent();
    event.widget = this;
    event.time = time;
    event.dataType = transferData;
    notifyListeners(DND.DragSetData, event);

    Transfer transfer = null;
    for (int i = 0; i < transferAgents.length; i++) {
        Transfer transferAgent = transferAgents[i];
        if (transferAgent !is null && transferAgent.isSupportedType(transferData)) {
            transfer = transferAgent;
            break;
        }
    }
    if (transfer is null) return;
    transfer.javaToNative(event.data, transferData);
    if (transferData.result !is 1) return;
    OS.gtk_selection_data_set(gtkSelectionData, transferData.type, transferData.format, transferData.pValue, transferData.length);
    OS.g_free(transferData.pValue);
    return;
}

void dragDataDelete(
    GtkWidget      *widget,
    GdkDragContext *drag_context)
{
    moveData = true;
}

/**
 * Returns the Control which is registered for this DragSource.  This is the control that the
 * user clicks in to initiate dragging.
 *
 * @return the Control which is registered for this DragSource
 */
public Control getControl () {
    return control;
}

/**
 * Returns an array of listeners who will be notified when a drag and drop
 * operation is in progress, by sending it one of the messages defined in
 * the <code>DragSourceListener</code> interface.
 *
 * @return the listeners who will be notified when a drag and drop
 * operation is in progress
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DragSourceListener
 * @see #addDragListener
 * @see #removeDragListener
 * @see DragSourceEvent
 *
 * @since 3.4
 */
public DragSourceListener[] getDragListeners() {
    Listener[] listeners = getListeners(DND.DragStart);
    auto length = listeners.length;
    DragSourceListener[] dragListeners = new DragSourceListener[length];
    int count = 0;
    for (typeof(length) i = 0; i < length; i++) {
        Listener listener = listeners[i];
        if ( auto l = cast(DNDListener)listener ) {
            dragListeners[count] = cast(DragSourceListener) (l.getEventListener());
            count++;
        }
    }
    if (count is length) return dragListeners;
    DragSourceListener[] result = new DragSourceListener[count];
    SimpleType!(DragSourceListener).arraycopy(dragListeners, 0, result, 0, count);
    return result;
}

/**
 * Returns the drag effect that is registered for this DragSource.  This drag
 * effect will be used during a drag and drop operation.
 *
 * @return the drag effect that is registered for this DragSource
 *
 * @since 3.3
 */
public DragSourceEffect getDragSourceEffect() {
    return dragEffect;
}

/**
 * Returns the list of data types that can be transferred by this DragSource.
 *
 * @return the list of data types that can be transferred by this DragSource
 */
public Transfer[] getTransfer(){
    return transferAgents;
}

void onDispose() {
    if (control is null) return;
    if (targetList !is null) {
        OS.gtk_target_list_unref(targetList);
    }
    targetList = null;
    if (controlListener !is null) {
        control.removeListener(SWT.Dispose, controlListener);
        control.removeListener(SWT.DragDetect, controlListener);
    }
    controlListener = null;
    control.setData(DND.DRAG_SOURCE_KEY, null);
    control = null;
    transferAgents = null;
}

int opToOsOp(int operation){
    int osOperation = 0;

    if ((operation & DND.DROP_COPY) is DND.DROP_COPY)
        osOperation |= OS.GDK_ACTION_COPY;
    if ((operation & DND.DROP_MOVE) is DND.DROP_MOVE)
        osOperation |= OS.GDK_ACTION_MOVE;
    if ((operation & DND.DROP_LINK) is DND.DROP_LINK)
        osOperation |= OS.GDK_ACTION_LINK;

    return osOperation;
}

int osOpToOp(ptrdiff_t osOperation){
    int operation = DND.DROP_NONE;

    if ((osOperation & OS.GDK_ACTION_COPY) is OS.GDK_ACTION_COPY)
        operation |= DND.DROP_COPY;
    if ((osOperation & OS.GDK_ACTION_MOVE) is OS.GDK_ACTION_MOVE)
        operation |= DND.DROP_MOVE;
    if ((osOperation & OS.GDK_ACTION_LINK) is OS.GDK_ACTION_LINK)
        operation |= DND.DROP_LINK;

    return operation;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when a drag and drop operation is in progress.
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
 * @see DragSourceListener
 * @see #addDragListener
 * @see #getDragListeners
 */
public void removeDragListener(DragSourceListener listener) {
    if (listener is null) DND.error (SWT.ERROR_NULL_ARGUMENT);
    removeListener (DND.DragStart, listener);
    removeListener (DND.DragSetData, listener);
    removeListener (DND.DragEnd, listener);
}

/**
 * Specifies the drag effect for this DragSource.  This drag effect will be
 * used during a drag and drop operation.
 *
 * @param effect the drag effect that is registered for this DragSource
 *
 * @since 3.3
 */
public void setDragSourceEffect(DragSourceEffect effect) {
    dragEffect = effect;
}

/**
 * Specifies the list of data types that can be transferred by this DragSource.
 * The application must be able to provide data to match each of these types when
 * a successful drop has occurred.
 *
 * @param transferAgents a list of Transfer objects which define the types of data that can be
 * dragged from this source
 */
public void setTransfer(Transfer[] transferAgents){
    if (targetList !is null) {
        OS.gtk_target_list_unref(targetList);
        targetList = null;
    }
    this.transferAgents = transferAgents;
    if (transferAgents is null || transferAgents.length is 0) return;

    GtkTargetEntry*[] targets;
    for (int i = 0; i < transferAgents.length; i++) {
        Transfer transfer = transferAgents[i];
        if (transfer !is null) {
            int[] typeIds = transfer.getTypeIds();
            String[] typeNames = transfer.getTypeNames();
            for (int j = 0; j < typeIds.length; j++) {
                GtkTargetEntry* entry = new GtkTargetEntry();
                String type = typeNames[j];
                entry.target = cast(char*)OS.g_malloc(type.length+1);
                entry.target[ 0 .. type.length ] = type[];
                entry.target[ type.length ] = '\0';
                entry.info = typeIds[j];
                GtkTargetEntry*[] newTargets = new GtkTargetEntry*[targets.length + 1];
                SimpleType!(GtkTargetEntry*).arraycopy(targets, 0, newTargets,
                                             0, targets.length);
                newTargets[targets.length] = entry;
                targets = newTargets;
            }
        }
    }

    void* pTargets = OS.g_malloc(targets.length * GtkTargetEntry.sizeof);
    for (int i = 0; i < targets.length; i++) {
        OS.memmove(pTargets + i*GtkTargetEntry.sizeof, targets[i], GtkTargetEntry.sizeof);
    }
    targetList = OS.gtk_target_list_new(pTargets, cast(int)/*64bit*/targets.length);

    for (int i = 0; i < targets.length; i++) {
        OS.g_free(targets[i].target);
    }
}

static GdkDrawable* createPixbuf(Image image) {
    int w, h;
    OS.gdk_drawable_get_size (image.pixmap, &w, &h);
    auto colormap = OS.gdk_colormap_get_system ();
    void* pixbuf;
    bool hasMask = image.mask !is null && OS.gdk_drawable_get_depth (image.mask) is 1;
    if (hasMask) {
        pixbuf = OS.gdk_pixbuf_new (OS.GDK_COLORSPACE_RGB, true, 8, w, h);
        if (pixbuf is null) SWT.error (SWT.ERROR_NO_HANDLES);
        OS.gdk_pixbuf_get_from_drawable (pixbuf, image.pixmap, colormap, 0, 0, 0, 0, w , h);
        auto maskPixbuf = OS.gdk_pixbuf_new(OS.GDK_COLORSPACE_RGB, false, 8, w , h );
        if (maskPixbuf is null) SWT.error (SWT.ERROR_NO_HANDLES);
        OS.gdk_pixbuf_get_from_drawable(maskPixbuf, image.mask, null, 0, 0, 0, 0, w , h );
        ptrdiff_t stride = OS.gdk_pixbuf_get_rowstride(pixbuf);
        auto pixels = OS.gdk_pixbuf_get_pixels(pixbuf);
        byte[] line = new byte[stride];
        ptrdiff_t maskStride = OS.gdk_pixbuf_get_rowstride(maskPixbuf);
        auto maskPixels = OS.gdk_pixbuf_get_pixels(maskPixbuf);
        byte[] maskLine = new byte[maskStride];
        for (int y=0; y<h; y++) {
            auto offset = pixels + (y * stride);
            OS.memmove(line.ptr, offset, stride);
            auto maskOffset = maskPixels + (y * maskStride);
            OS.memmove(maskLine.ptr, maskOffset, maskStride);
            for (int x=0; x<w; x++) {
                if (maskLine[x * 3] is 0) {
                    line[x * 4 + 3] = 0;
                }
            }
            OS.memmove(offset, line.ptr, stride);
        }
        OS.g_object_unref(maskPixbuf);
    } else {
        ImageData data = image.getImageData ();
        bool hasAlpha = data.getTransparencyType () is SWT.TRANSPARENCY_ALPHA;
        pixbuf = OS.gdk_pixbuf_new (OS.GDK_COLORSPACE_RGB, hasAlpha, 8, w , h );
        if (pixbuf is null) SWT.error (SWT.ERROR_NO_HANDLES);
        OS.gdk_pixbuf_get_from_drawable (pixbuf, image.pixmap, colormap, 0, 0, 0, 0, w , h );
        if (hasAlpha) {
            byte [] alpha = data.alphaData;
            ptrdiff_t stride = OS.gdk_pixbuf_get_rowstride (pixbuf);
            auto pixels = OS.gdk_pixbuf_get_pixels (pixbuf);
            byte [] line = new byte [stride];
            for (int y = 0; y < h ; y++) {
                auto offset = pixels + (y * stride);
                OS.memmove (line.ptr, offset, stride);
                for (int x = 0; x < w ; x++) {
                    line [x*4+3] = alpha [y*w +x];
                }
                OS.memmove (offset, line.ptr, stride);
            }
        }
    }
    return cast(GdkDrawable*)pixbuf;
}
}
