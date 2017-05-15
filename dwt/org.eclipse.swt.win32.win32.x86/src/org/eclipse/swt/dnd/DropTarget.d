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
module org.eclipse.swt.dnd.DropTarget;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.C;
import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.extras;
import org.eclipse.swt.internal.ole.win32.OBJIDL;
import org.eclipse.swt.internal.ole.win32.OLEIDL;
import org.eclipse.swt.internal.ole.win32.ifs;
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.Widget;

import org.eclipse.swt.dnd.Transfer;
import org.eclipse.swt.dnd.DropTargetEffect;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.dnd.DropTargetListener;
import org.eclipse.swt.dnd.DNDListener;
import org.eclipse.swt.dnd.DNDEvent;
import org.eclipse.swt.dnd.DND;
import org.eclipse.swt.dnd.TableDropTargetEffect;
import org.eclipse.swt.dnd.TreeDropTargetEffect;

import java.lang.all;

/**
 *
 * Class <code>DropTarget</code> defines the target object for a drag and drop transfer.
 *
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 *
 * <p>This class identifies the <code>Control</code> over which the user must position the cursor
 * in order to drop the data being transferred.  It also specifies what data types can be dropped on
 * this control and what operations can be performed.  You may have several DropTragets in an
 * application but there can only be a one to one mapping between a <code>Control</code> and a <code>DropTarget</code>.
 * The DropTarget can receive data from within the same application or from other applications
 * (such as text dragged from a text editor like Word).</p>
 *
 * <code><pre>
 *  int operations = DND.DROP_MOVE | DND.DROP_COPY | DND.DROP_LINK;
 *  Transfer[] types = new Transfer[] {TextTransfer.getInstance()};
 *  DropTarget target = new DropTarget(label, operations);
 *  target.setTransfer(types);
 * </code></pre>
 *
 * <p>The application is notified of data being dragged over this control and of when a drop occurs by
 * implementing the interface <code>DropTargetListener</code> which uses the class
 * <code>DropTargetEvent</code>.  The application can modify the type of drag being performed
 * on this Control at any stage of the drag by modifying the <code>event.detail</code> field or the
 * <code>event.currentDataType</code> field.  When the data is dropped, it is the responsibility of
 * the application to copy this data for its own purposes.
 *
 * <code><pre>
 *  target.addDropListener (new DropTargetListener() {
 *      public void dragEnter(DropTargetEvent event) {};
 *      public void dragOver(DropTargetEvent event) {};
 *      public void dragLeave(DropTargetEvent event) {};
 *      public void dragOperationChanged(DropTargetEvent event) {};
 *      public void dropAccept(DropTargetEvent event) {}
 *      public void drop(DropTargetEvent event) {
 *          // A drop has occurred, copy over the data
 *          if (event.data is null) { // no data to copy, indicate failure in event.detail
 *              event.detail = DND.DROP_NONE;
 *              return;
 *          }
 *          label.setText ((String) event.data); // data copied to label text
 *      }
 *  });
 * </pre></code>
 *
 * <dl>
 *  <dt><b>Styles</b></dt> <dd>DND.DROP_NONE, DND.DROP_COPY, DND.DROP_MOVE, DND.DROP_LINK</dd>
 *  <dt><b>Events</b></dt> <dd>DND.DragEnter, DND.DragLeave, DND.DragOver, DND.DragOperationChanged,
 *                             DND.DropAccept, DND.Drop </dd>
 * </dl>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#dnd">Drag and Drop snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: DNDExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class DropTarget : Widget {

    Control control;
    Listener controlListener;
    Transfer[] transferAgents;
    DropTargetEffect dropEffect;

    // Track application selections
    TransferData selectedDataType;
    int selectedOperation;

    // workaround - There is no event for "operation changed" so track operation based on key state
    int keyOperation = -1;

    // workaround - The dataobject address is only passed as an argument in drag enter and drop.
    // To allow applications to query the data values during the drag over operations,
    // maintain a reference to it.
    IDataObject iDataObject;

    // interfaces
    _IDropTargetImpl iDropTarget;
    int refCount;

    static const String DEFAULT_DROP_TARGET_EFFECT = "DEFAULT_DROP_TARGET_EFFECT"; //$NON-NLS-1$

/**
 * Creates a new <code>DropTarget</code> to allow data to be dropped on the specified
 * <code>Control</code>.
 * Creating an instance of a DropTarget may cause system resources to be allocated
 * depending on the platform.  It is therefore mandatory that the DropTarget instance
 * be disposed when no longer required.
 *
 * @param control the <code>Control</code> over which the user positions the cursor to drop the data
 * @param style the bitwise OR'ing of allowed operations; this may be a combination of any of
 *         DND.DROP_NONE, DND.DROP_COPY, DND.DROP_MOVE, DND.DROP_LINK
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_CANNOT_INIT_DROP - unable to initiate drop target; this will occur if more than one
 *        drop target is created for a control or if the operating system will not allow the creation
 *        of the drop target</li>
 * </ul>
 *
 * <p>NOTE: ERROR_CANNOT_INIT_DROP should be an SWTException, since it is a
 * recoverable error, but can not be changed due to backward compatibility.</p>
 *
 * @see Widget#dispose
 * @see DropTarget#checkSubclass
 * @see DND#DROP_NONE
 * @see DND#DROP_COPY
 * @see DND#DROP_MOVE
 * @see DND#DROP_LINK
 */
public this(Control control, int style) {
    super (control, checkStyle(style));
    this.control = control;
    if (control.getData(DND.DROP_TARGET_KEY) !is null) {
        DND.error(DND.ERROR_CANNOT_INIT_DROP);
    }
    control.setData(DND.DROP_TARGET_KEY, this);
    createCOMInterfaces();
    this.AddRef();

    if (COM.CoLockObjectExternal(iDropTarget, true, true) !is COM.S_OK)
        DND.error(DND.ERROR_CANNOT_INIT_DROP);
    if (COM.RegisterDragDrop( control.handle, iDropTarget) !is COM.S_OK)
        DND.error(DND.ERROR_CANNOT_INIT_DROP);

    controlListener = new class() Listener {
        public void handleEvent (Event event) {
            if (!this.outer.isDisposed()){
                this.outer.dispose();
            }
        }
    };
    control.addListener (SWT.Dispose, controlListener);

    this.addListener(SWT.Dispose, new class() Listener {
        public void handleEvent (Event event) {
            onDispose();
        }
    });

    Object effect = control.getData(DEFAULT_DROP_TARGET_EFFECT);
    if ( auto dte = cast(DropTargetEffect) effect ) {
        dropEffect = dte;
    } else if ( auto table = cast(Table)control ) {
        dropEffect = new TableDropTargetEffect(table);
    } else if ( auto tree = cast(Tree)control ) {
        dropEffect = new TreeDropTargetEffect(tree);
    }
}

static int checkStyle (int style) {
    if (style is SWT.NONE) return DND.DROP_MOVE;
    return style;
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when a drag and drop operation is in progress, by sending
 * it one of the messages defined in the <code>DropTargetListener</code>
 * interface.
 *
 * <p><ul>
 * <li><code>dragEnter</code> is called when the cursor has entered the drop target boundaries
 * <li><code>dragLeave</code> is called when the cursor has left the drop target boundaries and just before
 * the drop occurs or is cancelled.
 * <li><code>dragOperationChanged</code> is called when the operation being performed has changed
 * (usually due to the user changing the selected modifier key(s) while dragging)
 * <li><code>dragOver</code> is called when the cursor is moving over the drop target
 * <li><code>dropAccept</code> is called just before the drop is performed.  The drop target is given
 * the chance to change the nature of the drop or veto the drop by setting the <code>event.detail</code> field
 * <li><code>drop</code> is called when the data is being dropped
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
 * @see DropTargetListener
 * @see #getDropListeners
 * @see #removeDropListener
 * @see DropTargetEvent
 */
public void addDropListener(DropTargetListener listener) {
    if (listener is null) DND.error (SWT.ERROR_NULL_ARGUMENT);
    DNDListener typedListener = new DNDListener (listener);
    typedListener.dndWidget = this;
    addListener (DND.DragEnter, typedListener);
    addListener (DND.DragLeave, typedListener);
    addListener (DND.DragOver, typedListener);
    addListener (DND.DragOperationChanged, typedListener);
    addListener (DND.Drop, typedListener);
    addListener (DND.DropAccept, typedListener);
}

ULONG AddRef() {
    refCount++;
    return refCount;
}

override
protected void checkSubclass () {
    String name = this.classinfo.name;
    String validName = DropTarget.classinfo.name;
    if (validName!=/*eq*/name) {
        DND.error (SWT.ERROR_INVALID_SUBCLASS);
    }
}

void createCOMInterfaces() {
    // register each of the interfaces that this object implements
    iDropTarget = new _IDropTargetImpl(this);
}

void disposeCOMInterfaces() {
    iDropTarget = null;
}

int DragEnter_64(IDataObject pDataObject, DWORD grfKeyState, long pt, DWORD* pdwEffect) {
    POINTL point;
    OS.MoveMemory( &point, &pt, 8);
    return DragEnter(pDataObject, grfKeyState, point, pdwEffect);
}

HRESULT DragEnter(IDataObject pDataObject, DWORD grfKeyState, POINTL pt, DWORD* pdwEffect) {
    selectedDataType = null;
    selectedOperation = DND.DROP_NONE;
    if (iDataObject !is null) iDataObject.Release();
    iDataObject = null;

    DNDEvent event = new DNDEvent();
    if (!setEventData(event, pDataObject, grfKeyState, pt, pdwEffect)) {
        *pdwEffect = COM.DROPEFFECT_NONE;
        return COM.S_FALSE;
    }

    // Remember the iDataObject because it is not passed into the DragOver callback
    iDataObject = pDataObject;
    iDataObject.AddRef();

    int allowedOperations = event.operations;
    TransferData[] allowedDataTypes = new TransferData[event.dataTypes.length];
    System.arraycopy(event.dataTypes, 0, allowedDataTypes, 0, allowedDataTypes.length);
    notifyListeners(DND.DragEnter, event);
    refresh();
    if (event.detail is DND.DROP_DEFAULT) {
        event.detail = (allowedOperations & DND.DROP_MOVE) !is 0 ? DND.DROP_MOVE : DND.DROP_NONE;
    }

    selectedDataType = null;
    for (int i = 0; i < allowedDataTypes.length; i++) {
        if (TransferData.sameType(allowedDataTypes[i], event.dataType)){
            selectedDataType = allowedDataTypes[i];
            break;
        }
    }

    selectedOperation = DND.DROP_NONE;
    if (selectedDataType !is null && ((allowedOperations & event.detail) !is 0)) {
        selectedOperation = event.detail;
    }

    *pdwEffect = opToOs(selectedOperation);
    return COM.S_OK;
}

HRESULT DragLeave() {
    keyOperation = -1;

    if (iDataObject is null) return COM.S_FALSE;

    DNDEvent event = new DNDEvent();
    event.widget = this;
    event.time = OS.GetMessageTime();
    event.detail = DND.DROP_NONE;
    notifyListeners(DND.DragLeave, event);
    refresh();

    iDataObject.Release();
    iDataObject = null;
    return COM.S_OK;
}

int DragOver_64(int grfKeyState, long pt, DWORD* pdwEffect) {
    POINTL point;
    OS.MoveMemory(&point, &pt, 8);
    return DragOver(grfKeyState, point, pdwEffect);
}

HRESULT DragOver(int grfKeyState, POINTL pt, DWORD* pdwEffect) {
    if (iDataObject is null) return COM.S_FALSE;
    int oldKeyOperation = keyOperation;

    DNDEvent event = new DNDEvent();
    if (!setEventData(event, iDataObject, grfKeyState, pt, pdwEffect)) {
        keyOperation = -1;
        *pdwEffect = COM.DROPEFFECT_NONE;
        return COM.S_FALSE;
    }

    int allowedOperations = event.operations;
    TransferData[] allowedDataTypes = new TransferData[event.dataTypes.length];
    System.arraycopy(event.dataTypes, 0, allowedDataTypes, 0, allowedDataTypes.length);

    if (keyOperation is oldKeyOperation) {
        event.type = DND.DragOver;
        event.dataType = selectedDataType;
        event.detail = selectedOperation;
    } else {
        event.type = DND.DragOperationChanged;
        event.dataType = selectedDataType;
    }
    notifyListeners(event.type, event);
    refresh();
    if (event.detail is DND.DROP_DEFAULT) {
        event.detail = (allowedOperations & DND.DROP_MOVE) !is 0 ? DND.DROP_MOVE : DND.DROP_NONE;
    }

    selectedDataType = null;
    for (int i = 0; i < allowedDataTypes.length; i++) {
        if (TransferData.sameType(allowedDataTypes[i], event.dataType)){
            selectedDataType = allowedDataTypes[i];
            break;
        }
    }

    selectedOperation = DND.DROP_NONE;
    if (selectedDataType !is null && ((allowedOperations & event.detail) is event.detail)) {
        selectedOperation = event.detail;
    }

    *pdwEffect = opToOs(selectedOperation);
    return COM.S_OK;
}

int Drop_64(IDataObject pDataObject, int grfKeyState, long pt, DWORD* pdwEffect) {
    POINTL point;
    OS.MoveMemory(&point, &pt, 8);
    return Drop(pDataObject, grfKeyState, point, pdwEffect);
}

HRESULT Drop(IDataObject pDataObject, int grfKeyState, POINTL pt, DWORD* pdwEffect) {
    DNDEvent event = new DNDEvent();
    event.widget = this;
    event.time = OS.GetMessageTime();
    if (dropEffect !is null) {
        event.item = dropEffect.getItem(pt.x, pt.y);
    }
    event.detail = DND.DROP_NONE;
    notifyListeners(DND.DragLeave, event);
    refresh();

    event = new DNDEvent();
    if (!setEventData(event, pDataObject, grfKeyState, pt, pdwEffect)) {
        keyOperation = -1;
        *pdwEffect = COM.DROPEFFECT_NONE;
        return COM.S_FALSE;
    }
    keyOperation = -1;
    int allowedOperations = event.operations;
    TransferData[] allowedDataTypes = new TransferData[event.dataTypes.length];
    System.arraycopy(event.dataTypes, 0, allowedDataTypes, 0, allowedDataTypes.length);
    event.dataType = selectedDataType;
    event.detail = selectedOperation;
    notifyListeners(DND.DropAccept,event);
    refresh();

    selectedDataType = null;
    for (int i = 0; i < allowedDataTypes.length; i++) {
        if (TransferData.sameType(allowedDataTypes[i], event.dataType)){
            selectedDataType = allowedDataTypes[i];
            break;
        }
    }
    selectedOperation = DND.DROP_NONE;
    if (selectedDataType !is null && (allowedOperations & event.detail) is event.detail) {
        selectedOperation = event.detail;
    }

    if (selectedOperation is DND.DROP_NONE){
        *pdwEffect = COM.DROPEFFECT_NONE;
        return COM.S_OK;
    }

    // Get Data in a Java format
    Object object = null;
    for (int i = 0; i < transferAgents.length; i++){
        Transfer transfer = transferAgents[i];
        if (transfer !is null && transfer.isSupportedType(selectedDataType)){
            object = transfer.nativeToJava(selectedDataType);
            break;
        }
    }
    if (object is null){
        selectedOperation = DND.DROP_NONE;
    }

    event.detail = selectedOperation;
    event.dataType = selectedDataType;
    event.data = object;
    OS.ImageList_DragShowNolock(false);
    try {
        notifyListeners(DND.Drop,event);
    } finally {
        OS.ImageList_DragShowNolock(true);
    }
    refresh();
    selectedOperation = DND.DROP_NONE;
    if ((allowedOperations & event.detail) is event.detail) {
        selectedOperation = event.detail;
    }
    //notify source of action taken
    *pdwEffect = opToOs(selectedOperation);
    return COM.S_OK;
}

/**
 * Returns the Control which is registered for this DropTarget.  This is the control over which the
 * user positions the cursor to drop the data.
 *
 * @return the Control which is registered for this DropTarget
 */
public Control getControl () {
    return control;
}

/**
 * Returns an array of listeners who will be notified when a drag and drop
 * operation is in progress, by sending it one of the messages defined in
 * the <code>DropTargetListener</code> interface.
 *
 * @return the listeners who will be notified when a drag and drop 
 * operation is in progress
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DropTargetListener
 * @see #addDropListener
 * @see #removeDropListener
 * @see DropTargetEvent
 *
 * @since 3.4
 */
public DropTargetListener[] getDropListeners() {
    Listener[] listeners = getListeners(DND.DragEnter);
    int length = cast(int)/*64bit*/listeners.length;
    DropTargetListener[] dropListeners = new DropTargetListener[length];
    int count = 0;
    for (int i = 0; i < length; i++) {
        Listener listener = listeners[i];
        if (auto l = cast(DNDListener)listener ) {
            dropListeners[count] = cast(DropTargetListener) (l.getEventListener());
            count++;
        }
    }
    if (count is length) return dropListeners;
    DropTargetListener[] result = new DropTargetListener[count];
    SimpleType!(DropTargetListener).arraycopy(dropListeners, 0, result, 0, count);
    return result;
}

/**
 * Returns the drop effect for this DropTarget.  This drop effect will be
 * used during a drag and drop to display the drag under effect on the
 * target widget.
 *
 * @return the drop effect that is registered for this DropTarget
 *
 * @since 3.3
 */
public DropTargetEffect getDropTargetEffect() {
    return dropEffect;
}

int getOperationFromKeyState(int grfKeyState) {
    bool ctrl = (grfKeyState & OS.MK_CONTROL) !is 0;
    bool shift = (grfKeyState & OS.MK_SHIFT) !is 0;
    bool alt = (grfKeyState & OS.MK_ALT) !is 0;
    if (alt) {
        if (ctrl || shift) return DND.DROP_DEFAULT;
        return DND.DROP_LINK;
    }
    if (ctrl && shift) return DND.DROP_LINK;
    if (ctrl)return DND.DROP_COPY;
    if (shift)return DND.DROP_MOVE;
    return DND.DROP_DEFAULT;
}

/**
 * Returns a list of the data types that can be transferred to this DropTarget.
 *
 * @return a list of the data types that can be transferred to this DropTarget
 */
public Transfer[] getTransfer() {
    return transferAgents;
}

void onDispose () {
    if (control is null) return;

    COM.RevokeDragDrop(control.handle);

    if (controlListener !is null)
        control.removeListener(SWT.Dispose, controlListener);
    controlListener = null;
    control.setData(DND.DROP_TARGET_KEY, null);
    transferAgents = null;
    control = null;

    COM.CoLockObjectExternal(iDropTarget, false, true);

    this.Release();

    COM.CoFreeUnusedLibraries();
}

int opToOs(int operation) {
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

int osToOp(int osOperation){
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

/* QueryInterface([in] iid, [out] ppvObject)
 * Ownership of ppvObject transfers from callee to caller so reference count on ppvObject
 * must be incremented before returning.  Caller is responsible for releasing ppvObject.
 */
HRESULT QueryInterface(REFCIID riid, void ** ppvObject) {

    if (riid is null || ppvObject is null)
        return COM.E_INVALIDARG;
    if (COM.IsEqualGUID(riid, &COM.IIDIUnknown) || COM.IsEqualGUID(riid, &COM.IIDIDropTarget)) {
        *ppvObject = cast(void*)cast(IDropTarget) iDropTarget;
        AddRef();
        return COM.S_OK;
    }

    *ppvObject = null;
    return COM.E_NOINTERFACE;
}

ULONG Release() {
    refCount--;

    if (refCount is 0) {
        disposeCOMInterfaces();
        COM.CoFreeUnusedLibraries();
    }

    return refCount;
}

void refresh() {
    if (control is null || control.isDisposed()) return;
    auto handle = control.handle;
    RECT lpRect;
    if (OS.GetUpdateRect(handle, &lpRect, false)) {
        OS.ImageList_DragShowNolock(false);
        OS.RedrawWindow(handle, &lpRect, null, OS.RDW_UPDATENOW | OS.RDW_INVALIDATE);
        OS.ImageList_DragShowNolock(true);
    }
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
 * @see DropTargetListener
 * @see #addDropListener
 * @see #getDropListeners
 */
public void removeDropListener(DropTargetListener listener) {
    if (listener is null) DND.error (SWT.ERROR_NULL_ARGUMENT);
    removeListener (DND.DragEnter, listener);
    removeListener (DND.DragLeave, listener);
    removeListener (DND.DragOver, listener);
    removeListener (DND.DragOperationChanged, listener);
    removeListener (DND.Drop, listener);
    removeListener (DND.DropAccept, listener);
}

/**
 * Specifies the drop effect for this DropTarget.  This drop effect will be
 * used during a drag and drop to display the drag under effect on the
 * target widget.
 *
 * @param effect the drop effect that is registered for this DropTarget
 *
 * @since 3.3
 */
public void setDropTargetEffect(DropTargetEffect effect) {
    dropEffect = effect;
}

bool setEventData(DNDEvent event, IDataObject pDataObject, int grfKeyState, POINTL pt, DWORD* pdwEffect) {
    if (pDataObject is null || pdwEffect is null) return false;

    // get allowed operations
    int style = getStyle();
    int[1] operations;
    OS.MoveMemory(operations.ptr, pdwEffect, 4);
    operations[0] = osToOp(operations[0]) & style;
    if (operations[0] is DND.DROP_NONE) return false;

    // get current operation
    int operation = getOperationFromKeyState(grfKeyState);
    keyOperation = operation;
    if (operation is DND.DROP_DEFAULT) {
        if ((style & DND.DROP_DEFAULT) is 0) {
            operation = (operations[0] & DND.DROP_MOVE) !is 0 ? DND.DROP_MOVE : DND.DROP_NONE;
        }
    } else {
        if ((operation & operations[0]) is 0) operation = DND.DROP_NONE;
    }

    // Get allowed transfer types
    TransferData[] dataTypes = new TransferData[0];
    IDataObject dataObject = pDataObject;
    dataObject.AddRef();
    try {
        IEnumFORMATETC[1] address;
        if (dataObject.EnumFormatEtc(COM.DATADIR_GET, address.ptr) !is COM.S_OK) {
            return false;
        }
        IEnumFORMATETC enumFormatetc = address[0];
        try {
            // Loop over enumerator and save any types that match what we are looking for
            auto rgelt = cast(FORMATETC*) OS.GlobalAlloc(OS.GMEM_FIXED | OS.GMEM_ZEROINIT, FORMATETC.sizeof);
            try {
                uint[1] pceltFetched;
                enumFormatetc.Reset();
                while (enumFormatetc.Next(1, rgelt, pceltFetched.ptr) is COM.S_OK && pceltFetched[0] is 1) {
                    TransferData transferData = new TransferData();
                    transferData.formatetc = new FORMATETC();
                    COM.MoveMemory(transferData.formatetc, rgelt, FORMATETC.sizeof);
                    transferData.type = transferData.formatetc.cfFormat;
                    transferData.pIDataObject = pDataObject;
                    for (int i = 0; i < transferAgents.length; i++){
                        Transfer transfer = transferAgents[i];
                        if (transfer !is null && transfer.isSupportedType(transferData)){
                            TransferData[] newDataTypes = new TransferData[dataTypes.length + 1];
                            System.arraycopy(dataTypes, 0, newDataTypes, 0, dataTypes.length);
                            newDataTypes[dataTypes.length] = transferData;
                            dataTypes = newDataTypes;
                            break;
                        }
                    }
                }
            } finally {
                OS.GlobalFree(rgelt);
            }
        } finally {
            enumFormatetc.Release();
        }
    } finally {
        dataObject.Release();
    }
    if (dataTypes.length is 0) return false;

    event.widget = this;
    event.x = pt.x;
    event.y = pt.y;
    event.time = OS.GetMessageTime();
    event.feedback = DND.FEEDBACK_SELECT;
    event.dataTypes = dataTypes;
    event.dataType = dataTypes[0];
    if (dropEffect !is null) {
        event.item = dropEffect.getItem(pt.x, pt.y);
    }
    event.operations = operations[0];
    event.detail = operation;
    return true;
}

/**
 * Specifies the data types that can be transferred to this DropTarget.  If data is
 * being dragged that does not match one of these types, the drop target will be notified of
 * the drag and drop operation but the currentDataType will be null and the operation
 * will be DND.NONE.
 *
 * @param transferAgents a list of Transfer objects which define the types of data that can be
 *                       dropped on this target
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if transferAgents is null</li>
 * </ul>
 */
public void setTransfer(Transfer[] transferAgents){
    if (transferAgents is null) DND.error(SWT.ERROR_NULL_ARGUMENT);
    this.transferAgents = transferAgents;
}
}

class _IDropTargetImpl : IDropTarget {

    DropTarget  parent;
    this(DropTarget p) { parent = p; }
extern (Windows):
    // interface of IUnknown
    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }
    ULONG AddRef()  { return parent.AddRef(); }
    ULONG Release() { return parent.Release(); }

    HRESULT DragEnter( IDataObject pDataObj, DWORD grfKeyState, POINTL pt, DWORD *pdwEffect ) {
        return parent.DragEnter(pDataObj, grfKeyState, pt, pdwEffect);
    }
    HRESULT DragOver( DWORD grfKeyState, POINTL pt, DWORD *pdwEffect ) {
        return parent.DragOver(grfKeyState, pt, pdwEffect);
    }
    HRESULT DragLeave(){ return parent.DragLeave(); }
    HRESULT Drop(IDataObject pDataObj,DWORD grfKeyState,POINTL pt,DWORD *pdwEffect){
        return parent.Drop(pDataObj, grfKeyState, pt, pdwEffect);
    }
}


