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
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.internal.ImageList;
import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.OLEIDL;
import org.eclipse.swt.internal.ole.win32.OBJIDL;
import org.eclipse.swt.internal.ole.win32.ifs;
import org.eclipse.swt.internal.ole.win32.extras;
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.Widget;

import org.eclipse.swt.dnd.DragSourceEffect;
import org.eclipse.swt.dnd.DragSourceListener;
import org.eclipse.swt.dnd.Transfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.dnd.DND;
import org.eclipse.swt.dnd.DNDListener;
import org.eclipse.swt.dnd.DNDEvent;
import org.eclipse.swt.dnd.TreeDragSourceEffect;
import org.eclipse.swt.dnd.TableDragSourceEffect;
import org.eclipse.swt.dnd.OleEnumFORMATETC;

import java.lang.all;

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
    Composite topControl;
    HWND hwndDrag;

    // ole interfaces
    _IDropSourceImpl iDropSource;
    _IDataObjectImpl iDataObject;
    int refCount;

    //workaround - track the operation performed by the drop target for DragEnd event
    int dataEffect = DND.DROP_NONE;

    static const String DEFAULT_DRAG_SOURCE_EFFECT = "DEFAULT_DRAG_SOURCE_EFFECT"; //$NON-NLS-1$
    mixin(gshared!(`static const int CFSTR_PERFORMEDDROPEFFECT;`));
    static const TCHAR[] WindowClass = "#32770\0";
    mixin(sharedStaticThis!(`{
        CFSTR_PERFORMEDDROPEFFECT  = Transfer.registerType("Performed DropEffect");     //$NON-NLS-1$
    }`));
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
    super(control, checkStyle(style));
    this.control = control;
    if (control.getData(DND.DRAG_SOURCE_KEY) !is null) {
        DND.error(DND.ERROR_CANNOT_INIT_DRAG);
    }
    control.setData(DND.DRAG_SOURCE_KEY, this);
    createCOMInterfaces();
    this.AddRef();

    controlListener = new class() Listener {
        public void handleEvent(Event event) {
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
    control.addListener(SWT.Dispose, controlListener);
    control.addListener(SWT.DragDetect, controlListener);

    this.addListener(SWT.Dispose, new class() Listener {
        public void handleEvent(Event e) {
            this.outer.onDispose();
        }
    });

    Object effect = control.getData(DEFAULT_DRAG_SOURCE_EFFECT);
    if ( auto dse = cast(DragSourceEffect)effect ) {
        dragEffect = dse;
    } else if ( auto tree = cast(Tree)control ) {
        dragEffect = new TreeDragSourceEffect(tree);
    } else if ( auto table = cast(Table)control ) {
        dragEffect = new TableDragSourceEffect(table);
    }
}

static int checkStyle(int style) {
    if (style is SWT.NONE) return DND.DROP_MOVE;
    return style;
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
    if (listener is null) DND.error(SWT.ERROR_NULL_ARGUMENT);
    DNDListener typedListener = new DNDListener(listener);
    typedListener.dndWidget = this;
    addListener(DND.DragStart, typedListener);
    addListener(DND.DragSetData, typedListener);
    addListener(DND.DragEnd, typedListener);
}

private int AddRef() {
    refCount++;
    return refCount;
}

private void createCOMInterfaces() {
    // register each of the interfaces that this object implements
    iDropSource = new _IDropSourceImpl(this);
    iDataObject = new _IDataObjectImpl(this);
}

override
protected void checkSubclass() {
    String name = this.classinfo.name;
    String validName = DragSource.classinfo.name;
    if (validName!=/*eq*/name) {
        DND.error(SWT.ERROR_INVALID_SUBCLASS);
    }
}

private void disposeCOMInterfaces() {
    iDropSource = null;
    iDataObject = null;
}

private void drag(Event dragEvent) {
    DNDEvent event = new DNDEvent();
    event.widget = this;
    event.x = dragEvent.x;
    event.y = dragEvent.y;
    event.time = OS.GetMessageTime();
    event.doit = true;
    notifyListeners(DND.DragStart,event);
    if (!event.doit || transferAgents is null || transferAgents.length is 0 ) return;

    uint[1] pdwEffect;
    int operations = opToOs(getStyle());
    Display display = control.getDisplay();
    String key = "org.eclipse.swt.internal.win32.runMessagesInIdle"; //$NON-NLS-1$
    Object oldValue = display.getData(key);
    display.setData(key, new Boolean(true));
    ImageList imagelist = null;
    Image image = event.image;
    hwndDrag = null;
    topControl = null;
    if (image !is null) {
        imagelist = new ImageList(SWT.NONE);
        imagelist.add(image);
        topControl = control.getShell();
        /*
         * Bug in Windows. The image is inverted if the shell is RIGHT_TO_LEFT.
         * The fix is to create a transparent window that covers the shell client
         * area and use it during the drag to prevent the image from being inverted.
         * On XP if the shell is RTL, the image is not displayed.
         */
        int offset = event.x - dragEvent.x;
        hwndDrag = topControl.handle;
        if ((topControl.getStyle() & SWT.RIGHT_TO_LEFT) !is 0) {
            offset = image.getBounds().width - offset;
            RECT rect;
            OS.GetClientRect (topControl.handle, &rect);
            hwndDrag = OS.CreateWindowEx (
                OS.WS_EX_TRANSPARENT | OS.WS_EX_NOINHERITLAYOUT,
                WindowClass.ptr,
                null,
                OS.WS_CHILD | OS.WS_CLIPSIBLINGS,
                0, 0,
                rect.right - rect.left, rect.bottom - rect.top,
                topControl.handle,
                null,
                OS.GetModuleHandle (null),
                null);
            OS.ShowWindow (hwndDrag, OS.SW_SHOW);
        }
        OS.ImageList_BeginDrag(imagelist.getHandle(), 0, offset, event.y - dragEvent.y);
        /*
        * Feature in Windows. When ImageList_DragEnter() is called,
        * it takes a snapshot of the screen  If a drag is started
        * when another window is in front, then the snapshot will
        * contain part of the other window, causing pixel corruption.
        * The fix is to force all paints to be delivered before
        * calling ImageList_DragEnter().
        */
        if (OS.IsWinCE) {
            OS.UpdateWindow (topControl.handle);
        } else {
            int flags = OS.RDW_UPDATENOW | OS.RDW_ALLCHILDREN;
            OS.RedrawWindow (topControl.handle, null, null, flags);
        }
        POINT pt;
        pt.x = dragEvent.x;
        pt.y = dragEvent.y;
        OS.MapWindowPoints (control.handle, null, &pt, 1);
        RECT rect;
        OS.GetWindowRect (hwndDrag, &rect);
        OS.ImageList_DragEnter(hwndDrag, pt.x - rect.left, pt.y - rect.top);
    }
    int result = COM.DRAGDROP_S_CANCEL;
    try {
        result = COM.DoDragDrop(iDataObject, iDropSource, operations, pdwEffect.ptr);
    } finally {
        // ensure that we don't leave transparent window around
        if (hwndDrag !is null) {
            OS.ImageList_DragLeave(hwndDrag);
            OS.ImageList_EndDrag();
            imagelist.dispose();
            if (hwndDrag !is topControl.handle) OS.DestroyWindow(hwndDrag);
            hwndDrag = null;
            topControl = null;
        }
        display.setData(key, oldValue);
    }
    int operation = osToOp(pdwEffect[0]);
    if (dataEffect is DND.DROP_MOVE) {
        operation = (operation is DND.DROP_NONE || operation is DND.DROP_COPY) ? DND.DROP_TARGET_MOVE : DND.DROP_MOVE;
    } else {
        if (dataEffect !is DND.DROP_NONE) {
            operation = dataEffect;
        }
    }
    event = new DNDEvent();
    event.widget = this;
    event.time = OS.GetMessageTime();
    event.doit = (result is COM.DRAGDROP_S_DROP);
    event.detail = operation;
    notifyListeners(DND.DragEnd,event);
    dataEffect = DND.DROP_NONE;
}
/*
 * EnumFormatEtc([in] dwDirection, [out] ppenumFormatetc)
 * Ownership of ppenumFormatetc transfers from callee to caller so reference count on ppenumFormatetc
 * must be incremented before returning.  Caller is responsible for releasing ppenumFormatetc.
 */
private int EnumFormatEtc(int dwDirection, IEnumFORMATETC* ppenumFormatetc) {
    // only allow getting of data - SetData is not currently supported
    if (dwDirection is COM.DATADIR_SET) return COM.E_NOTIMPL;

    // what types have been registered?
    TransferData[] allowedDataTypes = new TransferData[0];
    for (int i = 0; i < transferAgents.length; i++){
        Transfer transferAgent = transferAgents[i];
        if (transferAgent !is null) {
            TransferData[] formats = transferAgent.getSupportedTypes();
            TransferData[] newAllowedDataTypes = new TransferData[allowedDataTypes.length + formats.length];
            System.arraycopy(allowedDataTypes, 0, newAllowedDataTypes, 0, allowedDataTypes.length);
            System.arraycopy(formats, 0, newAllowedDataTypes, allowedDataTypes.length, formats.length);
            allowedDataTypes = newAllowedDataTypes;
        }
    }

    OleEnumFORMATETC enumFORMATETC = new OleEnumFORMATETC();
    enumFORMATETC.AddRef();

    FORMATETC*[] formats = new FORMATETC*[allowedDataTypes.length];
    for (int i = 0; i < formats.length; i++){
        formats[i] = allowedDataTypes[i].formatetc;
    }
    enumFORMATETC.setFormats(formats);

    *ppenumFormatetc = enumFORMATETC.getAddress();
    return COM.S_OK;
}
/**
 * Returns the Control which is registered for this DragSource.  This is the control that the
 * user clicks in to initiate dragging.
 *
 * @return the Control which is registered for this DragSource
 */
public Control getControl() {
    return control;
}

HRESULT GetData(FORMATETC *pFormatetc, STGMEDIUM *pmedium) {
    /* Called by a data consumer to obtain data from a source data object.
       The GetData method renders the data described in the specified FORMATETC
       structure and transfers it through the specified STGMEDIUM structure.
       The caller then assumes responsibility for releasing the STGMEDIUM structure.
    */
    if (pFormatetc is null || pmedium is null) return COM.E_INVALIDARG;

    if (QueryGetData(pFormatetc) !is COM.S_OK) return COM.DV_E_FORMATETC;

    TransferData transferData = new TransferData();
    transferData.formatetc = new FORMATETC();
    COM.MoveMemory(transferData.formatetc, pFormatetc, FORMATETC.sizeof);
    transferData.type = transferData.formatetc.cfFormat;
    transferData.stgmedium = new STGMEDIUM();
    transferData.result = COM.E_FAIL;

    DNDEvent event = new DNDEvent();
    event.widget = this;
    event.time = OS.GetMessageTime();
    event.dataType = transferData;
    notifyListeners(DND.DragSetData,event);

    // get matching transfer agent to perform conversion
    Transfer transfer = null;
    for (int i = 0; i < transferAgents.length; i++){
        Transfer transferAgent = transferAgents[i];
        if (transferAgent !is null && transferAgent.isSupportedType(transferData)){
            transfer = transferAgent;
            break;
        }
    }

    if (transfer is null) return COM.DV_E_FORMATETC;
    transfer.javaToNative(event.data, transferData);
    if (transferData.result !is COM.S_OK) return transferData.result;
    COM.MoveMemory(pmedium, transferData.stgmedium, STGMEDIUM.sizeof);
    return transferData.result;
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
    int length = cast(int)/*64bit*/listeners.length;
    DragSourceListener[] dragListeners = new DragSourceListener[length];
    int count = 0;
    for (int i = 0; i < length; i++) {
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

package .HRESULT GiveFeedback(DWORD dwEffect) {
    return COM.DRAGDROP_S_USEDEFAULTCURSORS;
}

package .HRESULT QueryContinueDrag(int fEscapePressed, DWORD grfKeyState) {
    if (topControl !is null && topControl.isDisposed()) return COM.DRAGDROP_S_CANCEL;
    if (fEscapePressed !is 0){
        if (hwndDrag !is null) OS.ImageList_DragLeave(hwndDrag);
        return COM.DRAGDROP_S_CANCEL;
    }
    /*
    * Bug in Windows.  On some machines that do not have XBUTTONs,
    * the MK_XBUTTON1 and OS.MK_XBUTTON2 bits are sometimes set,
    * causing mouse capture to become stuck.  The fix is to test
    * for the extra buttons only when they exist.
    */
    int mask = OS.MK_LBUTTON | OS.MK_MBUTTON | OS.MK_RBUTTON;
//  if (display.xMouse) mask |= OS.MK_XBUTTON1 | OS.MK_XBUTTON2;
    if ((grfKeyState & mask) is 0) {
        if (hwndDrag !is null) OS.ImageList_DragLeave(hwndDrag);
        return COM.DRAGDROP_S_DROP;
    }

    if (hwndDrag !is null) {
        POINT pt;
        OS.GetCursorPos (&pt);
        RECT rect;
        OS.GetWindowRect (hwndDrag, &rect);
        OS.ImageList_DragMove (pt.x - rect.left, pt.y - rect.top);
    }
    return COM.S_OK;
}

private void onDispose() {
    if (control is null) return;
    this.Release();
    if (controlListener !is null){
        control.removeListener(SWT.Dispose, controlListener);
        control.removeListener(SWT.DragDetect, controlListener);
    }
    controlListener = null;
    control.setData(DND.DRAG_SOURCE_KEY, null);
    control = null;
    transferAgents = null;
}

private int opToOs(int operation) {
    int osOperation = 0;
    if ((operation & DND.DROP_COPY) !is 0){
        osOperation |= COM.DROPEFFECT_COPY;
    }
    if ((operation & DND.DROP_LINK) !is 0) {
        osOperation |= COM.DROPEFFECT_LINK;
    }
    if ((operation & DND.DROP_MOVE) !is 0) {
        osOperation |= COM.DROPEFFECT_MOVE;
    }
    return osOperation;
}

private int osToOp(int osOperation){
    int operation = 0;
    if ((osOperation & COM.DROPEFFECT_COPY) !is 0){
        operation |= DND.DROP_COPY;
    }
    if ((osOperation & COM.DROPEFFECT_LINK) !is 0) {
        operation |= DND.DROP_LINK;
    }
    if ((osOperation & COM.DROPEFFECT_MOVE) !is 0) {
        operation |= DND.DROP_MOVE;
    }
    return operation;
}

private HRESULT QueryGetData(FORMATETC* pFormatetc) {
    if (transferAgents is null) return COM.E_FAIL;
    TransferData transferData = new TransferData();
    transferData.formatetc = new FORMATETC();
    COM.MoveMemory(transferData.formatetc, pFormatetc, FORMATETC.sizeof);
    transferData.type = transferData.formatetc.cfFormat;

    // is this type supported by the transfer agent?
    for (int i = 0; i < transferAgents.length; i++){
        Transfer transfer = transferAgents[i];
        if (transfer !is null && transfer.isSupportedType(transferData))
            return COM.S_OK;
    }

    return COM.DV_E_FORMATETC;
}

/* QueryInterface([in] riid, [out] ppvObject)
 * Ownership of ppvObject transfers from callee to caller so reference count on ppvObject
 * must be incremented before returning.  Caller is responsible for releasing ppvObject.
 */
private HRESULT QueryInterface(REFCIID riid, void** ppvObject) {
    if (riid is null || ppvObject is null)
        return COM.E_INVALIDARG;

    if (COM.IsEqualGUID(riid, &COM.IIDIUnknown) || COM.IsEqualGUID(riid, &COM.IIDIDropSource)) {
        *ppvObject = cast(void*)cast(IUnknown) iDropSource;
        AddRef();
        return COM.S_OK;
    }

    if (COM.IsEqualGUID(riid, &COM.IIDIDataObject) ) {
        *ppvObject = cast(void*)cast(IDataObject) iDataObject;
        AddRef();
        return COM.S_OK;
    }

    *ppvObject = null;
    return COM.E_NOINTERFACE;
}

private ULONG Release() {
    refCount--;
    if (refCount is 0) {
        disposeCOMInterfaces();
        COM.CoFreeUnusedLibraries();
    }
    return refCount;
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
    if (listener is null) DND.error(SWT.ERROR_NULL_ARGUMENT);
    removeListener(DND.DragStart, listener);
    removeListener(DND.DragSetData, listener);
    removeListener(DND.DragEnd, listener);
}

HRESULT SetData(FORMATETC* pFormatetc, STGMEDIUM* pmedium, int fRelease) {
    if (pFormatetc is null || pmedium is null) return COM.E_INVALIDARG;
    FORMATETC* formatetc = new FORMATETC();
    COM.MoveMemory(formatetc, pFormatetc, FORMATETC.sizeof);
    if (formatetc.cfFormat is CFSTR_PERFORMEDDROPEFFECT && formatetc.tymed is COM.TYMED_HGLOBAL) {
        STGMEDIUM* stgmedium = new STGMEDIUM();
        COM.MoveMemory(stgmedium, pmedium,STGMEDIUM.sizeof);
        //TODO - this should be GlobalLock()
        int[1] ptrEffect;
        OS.MoveMemory(ptrEffect.ptr, stgmedium.unionField,4);
        int[1] effect;
        OS.MoveMemory(effect.ptr, ptrEffect[0],4);
        dataEffect = osToOp(effect[0]);
    }
    if (fRelease is 1) {
        COM.ReleaseStgMedium(pmedium);
    }
    return COM.S_OK;
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
    this.transferAgents = transferAgents;
}

}


private class _IDropSourceImpl : IDropSource {

    DragSource  parent;
    this(DragSource p) { parent = p; }
extern (Windows):
    // interface of IUnknown
    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }
    ULONG AddRef()  { return parent.AddRef(); }
    ULONG Release() { return parent.Release(); }

    // interface of IDropSource
    HRESULT QueryContinueDrag(BOOL fEscapePressed, DWORD grfKeyState) { return parent.QueryContinueDrag(fEscapePressed, grfKeyState); }
    HRESULT GiveFeedback(DWORD dwEffect) { return parent.GiveFeedback(dwEffect);}
}

private class _IDataObjectImpl : IDataObject {

    DragSource  parent;
    this(DragSource p) { parent = p; }
extern (Windows):
    // interface of IUnknown
    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }
    ULONG AddRef()  { return parent.AddRef(); }
    ULONG Release() { return parent.Release(); }


    // interface IDataObject
    HRESULT GetData( FORMATETC *pFormatetc, STGMEDIUM *pmedium) { return parent.GetData(pFormatetc, pmedium); }
    HRESULT GetDataHere(FORMATETC * pFormatetc, STGMEDIUM * pmedium) { return COM.E_NOTIMPL; }
    HRESULT QueryGetData(FORMATETC* pFormatetc) { return parent.QueryGetData(pFormatetc); }
    HRESULT GetCanonicalFormatEtc(FORMATETC* pFormatetcIn, FORMATETC* pFormatetcOut) { return COM.E_NOTIMPL; }
    HRESULT SetData(FORMATETC* pFormatetc, STGMEDIUM * pmedium, BOOL fRelease) { return parent.SetData(pFormatetc, pmedium, fRelease); }
    HRESULT EnumFormatEtc(DWORD dwDirection, IEnumFORMATETC * ppenumFormatetc) { return parent.EnumFormatEtc(dwDirection, ppenumFormatetc); }
    HRESULT DAdvise(FORMATETC* pFormatetc, DWORD advf, IAdviseSink pAdvSink, DWORD* pdwConnection) { return COM.E_NOTIMPL; }
    HRESULT DUnadvise(DWORD dwConnection) { return COM.E_NOTIMPL; }
    HRESULT EnumDAdvise(IEnumSTATDATA * ppenumAdvise) { return COM.E_NOTIMPL; }
}
