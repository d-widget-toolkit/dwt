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
module org.eclipse.swt.dnd.Clipboard;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.OBJIDL;
import org.eclipse.swt.internal.ole.win32.extras;
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.widgets.Display;

import org.eclipse.swt.dnd.Transfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.dnd.OleEnumFORMATETC;
import org.eclipse.swt.dnd.DND;

import java.lang.all;
import java.lang.Thread;

/**
 * The <code>Clipboard</code> provides a mechanism for transferring data from one
 * application to another or within an application.
 *
 * <p>IMPORTANT: This class is <em>not</em> intended to be subclassed.</p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#clipboard">Clipboard snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ClipboardExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Clipboard {

    private Display display;

    // ole interfaces
    private _IDataObjectImpl iDataObject;
    private int refCount;
    private Transfer[] transferAgents;
    private Object[] data;
    private int CFSTR_PREFERREDDROPEFFECT;

/**
 * Constructs a new instance of this class.  Creating an instance of a Clipboard
 * may cause system resources to be allocated depending on the platform.  It is therefore
 * mandatory that the Clipboard instance be disposed when no longer required.
 *
 * @param display the display on which to allocate the clipboard
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see Clipboard#dispose
 * @see Clipboard#checkSubclass
 */
public this(Display display) {
    checkSubclass ();
    if (display is null) {
        display = Display.getCurrent();
        if (display is null) {
            display = Display.getDefault();
        }
    }
    if (display.getThread() !is Thread.currentThread()) {
        DND.error(SWT.ERROR_THREAD_INVALID_ACCESS);
    }
    this.display = display;
    LPCTSTR chFormatName = StrToTCHARz(0, "Preferred DropEffect"); //$NON-NLS-1$
    CFSTR_PREFERREDDROPEFFECT = OS.RegisterClipboardFormat(chFormatName);
    createCOMInterfaces();
    this.AddRef();
}

/**
 * Checks that this class can be subclassed.
 * <p>
 * The SWT class library is intended to be subclassed
 * only at specific, controlled points. This method enforces this
 * rule unless it is overridden.
 * </p><p>
 * <em>IMPORTANT:</em> By providing an implementation of this
 * method that allows a subclass of a class which does not
 * normally allow subclassing to be created, the implementer
 * agrees to be fully responsible for the fact that any such
 * subclass will likely fail between SWT releases and will be
 * strongly platform specific. No support is provided for
 * user-written classes which are implemented in this fashion.
 * </p><p>
 * The ability to subclass outside of the allowed SWT classes
 * is intended purely to enable those not on the SWT development
 * team to implement patches in order to get around specific
 * limitations in advance of when those limitations can be
 * addressed by the team. Subclassing should not be attempted
 * without an intimate and detailed understanding of the hierarchy.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
protected void checkSubclass () {
    String name = this.classinfo.name;
    String validName = Clipboard.classinfo.name;
    if (validName!=/*eq*/name) {
        DND.error (SWT.ERROR_INVALID_SUBCLASS);
    }
}

/**
 * Throws an <code>SWTException</code> if the receiver can not
 * be accessed by the caller. This may include both checks on
 * the state of the receiver and more generally on the entire
 * execution context. This method <em>should</em> be called by
 * widget implementors to enforce the standard SWT invariants.
 * <p>
 * Currently, it is an error to invoke any method (other than
 * <code>isDisposed()</code>) on a widget that has had its
 * <code>dispose()</code> method called. It is also an error
 * to call widget methods from any thread that is different
 * from the thread that created the widget.
 * </p><p>
 * In future releases of SWT, there may be more or fewer error
 * checks and exceptions may be thrown for different reasons.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
protected void checkWidget () {
    Display display = this.display;
    if (display is null) DND.error (SWT.ERROR_WIDGET_DISPOSED);
    if (display.getThread() !is Thread.currentThread ()) DND.error (SWT.ERROR_THREAD_INVALID_ACCESS);
    if (display.isDisposed()) DND.error(SWT.ERROR_WIDGET_DISPOSED);
}

/**
 * If this clipboard is currently the owner of the data on the system clipboard,
 * clear the contents.  If this clipboard is not the owner, then nothing is done.
 * Note that there are clipboard assistant applications that take ownership of
 * data or make copies of data when it is placed on the clipboard.  In these
 * cases, it may not be possible to clear the clipboard.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void clearContents() {
    clearContents(DND.CLIPBOARD);
}

/**
 * If this clipboard is currently the owner of the data on the specified
 * clipboard, clear the contents.  If this clipboard is not the owner, then
 * nothing is done.
 *
 * <p>Note that there are clipboard assistant applications that take ownership
 * of data or make copies of data when it is placed on the clipboard.  In these
 * cases, it may not be possible to clear the clipboard.</p>
 *
 * <p>The clipboards value is either one of the clipboard constants defined in
 * class <code>DND</code>, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>DND</code> clipboard constants.</p>
 *
 * @param clipboards to be cleared
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see DND#CLIPBOARD
 * @see DND#SELECTION_CLIPBOARD
 *
 * @since 3.1
 */
public void clearContents(int clipboards) {
    checkWidget();
    if ((clipboards & DND.CLIPBOARD) !is 0) {
        /* OleIsCurrentClipboard([in] pDataObject)
         * The argument pDataObject is owned by the caller so reference count does not
         * need to be incremented.
         */
        if (COM.OleIsCurrentClipboard(this.iDataObject) is COM.S_OK) {
            /* OleSetClipboard([in] pDataObject)
             * The argument pDataObject is owned by the caller so reference count does not
             * need to be incremented.
             */
            COM.OleSetClipboard(null);
        }
    }
}

/**
 * Disposes of the operating system resources associated with the clipboard.
 * The data will still be available on the system clipboard after the dispose
 * method is called.
 *
 * <p>NOTE: On some platforms the data will not be available once the application
 * has exited or the display has been disposed.</p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 */
public void dispose () {
    if (isDisposed()) return;
    if (display.getThread() !is Thread.currentThread ()) DND.error(SWT.ERROR_THREAD_INVALID_ACCESS);
    /* OleIsCurrentClipboard([in] pDataObject)
     * The argument pDataObject is owned by the caller so reference count does not
     * need to be incremented.
     */
    if (COM.OleIsCurrentClipboard(this.iDataObject) is COM.S_OK) {
        COM.OleFlushClipboard();
    }
    this.Release();
    display = null;
}

/**
 * Retrieve the data of the specified type currently available on the system
 * clipboard.  Refer to the specific subclass of <code>Transfer</code> to
 * determine the type of object returned.
 *
 * <p>The following snippet shows text and RTF text being retrieved from the
 * clipboard:</p>
 *
 *    <code><pre>
 *    Clipboard clipboard = new Clipboard(display);
 *    TextTransfer textTransfer = TextTransfer.getInstance();
 *    String textData = (String)clipboard.getContents(textTransfer);
 *    if (textData !is null) System.out.println("Text is "+textData);
 *    RTFTransfer rtfTransfer = RTFTransfer.getInstance();
 *    String rtfData = (String)clipboard.getContents(rtfTransfer);
 *    if (rtfData !is null) System.out.println("RTF Text is "+rtfData);
 *    clipboard.dispose();
 *    </code></pre>
 *
 * @param transfer the transfer agent for the type of data being requested
 * @return the data obtained from the clipboard or null if no data of this type is available
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if transfer is null</li>
 * </ul>
 *
 * @see Transfer
 */
public Object getContents(Transfer transfer) {
    return getContents(transfer, DND.CLIPBOARD);
}
/**
 * Retrieve the data of the specified type currently available on the specified
 * clipboard.  Refer to the specific subclass of <code>Transfer</code> to
 * determine the type of object returned.
 *
 * <p>The following snippet shows text and RTF text being retrieved from the
 * clipboard:</p>
 *
 *    <code><pre>
 *    Clipboard clipboard = new Clipboard(display);
 *    TextTransfer textTransfer = TextTransfer.getInstance();
 *    String textData = (String)clipboard.getContents(textTransfer);
 *    if (textData !is null) System.out.println("Text is "+textData);
 *    RTFTransfer rtfTransfer = RTFTransfer.getInstance();
 *    String rtfData = (String)clipboard.getContents(rtfTransfer, DND.CLIPBOARD);
 *    if (rtfData !is null) System.out.println("RTF Text is "+rtfData);
 *    clipboard.dispose();
 *    </code></pre>
 *
 * <p>The clipboards value is either one of the clipboard constants defined in
 * class <code>DND</code>, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>DND</code> clipboard constants.</p>
 *
 * @param transfer the transfer agent for the type of data being requested
 * @param clipboards on which to look for data
 *
 * @return the data obtained from the clipboard or null if no data of this type is available
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if transfer is null</li>
 * </ul>
 *
 * @see Transfer
 * @see DND#CLIPBOARD
 * @see DND#SELECTION_CLIPBOARD
 *
 * @since 3.1
 */
public Object getContents(Transfer transfer, int clipboards) {
    checkWidget();
    if (transfer is null) DND.error(SWT.ERROR_NULL_ARGUMENT);
    if ((clipboards & DND.CLIPBOARD) is 0) return null;
    /*
    * Bug in Windows. When a new application takes control
    * of the clipboard, other applications may open the
    * clipboard to determine if they want to record the
    * clipboard updates.  When this happens, the clipboard
    * can not be accessed until the other application is
    * finished.  To allow the other applications to release
    * the clipboard, use PeekMessage() to enable cross thread
    * message sends.
    */
    IDataObject dataObject;
    int retryCount = 0;
    /* OleGetClipboard([out] ppDataObject).
     * AddRef has already been called on ppDataObject by the callee and must be released by the caller.
     */
    int result = COM.OleGetClipboard(&dataObject);
    while (result !is COM.S_OK && retryCount++ < 10) {
        try {Thread.sleep(50);} catch (Exception t) {}
        MSG msg;
        OS.PeekMessage(&msg, null, 0, 0, OS.PM_NOREMOVE | OS.PM_NOYIELD);
        result = COM.OleGetClipboard(&dataObject);
    }
    if (result !is COM.S_OK) return null;
    try {
        TransferData[] allowed = transfer.getSupportedTypes();
        for (int i = 0; i < allowed.length; i++) {
            if (dataObject.QueryGetData(allowed[i].formatetc) is COM.S_OK) {
                TransferData data = allowed[i];
                data.pIDataObject = dataObject;
                return transfer.nativeToJava(data);
            }
        }
    } finally {
        dataObject.Release();
    }
    return null; // No data available for this transfer
}
/**
 * Returns <code>true</code> if the clipboard has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the clipboard.
 * When a clipboard has been disposed, it is an error to
 * invoke any other method using the clipboard.
 * </p>
 *
 * @return <code>true</code> when the widget is disposed and <code>false</code> otherwise
 *
 * @since 3.0
 */
public bool isDisposed () {
    return (display is null);
}

/**
 * Place data of the specified type on the system clipboard.  More than one type
 * of data can be placed on the system clipboard at the same time.  Setting the
 * data clears any previous data from the system clipboard, regardless of type.
 *
 * <p>NOTE: On some platforms, the data is immediately copied to the system
 * clipboard but on other platforms it is provided upon request.  As a result,
 * if the application modifies the data object it has set on the clipboard, that
 * modification may or may not be available when the data is subsequently
 * requested.</p>
 *
 * <p>The following snippet shows text and RTF text being set on the copy/paste
 * clipboard:
 * </p>
 *
 * <code><pre>
 *  Clipboard clipboard = new Clipboard(display);
 *  String textData = "Hello World";
 *  String rtfData = "{\\rtf1\\b\\i Hello World}";
 *  TextTransfer textTransfer = TextTransfer.getInstance();
 *  RTFTransfer rtfTransfer = RTFTransfer.getInstance();
 *  Transfer[] transfers = new Transfer[]{textTransfer, rtfTransfer};
 *  Object[] data = new Object[]{textData, rtfData};
 *  clipboard.setContents(data, transfers);
 *  clipboard.dispose();
 * </code></pre>
 *
 * @param data the data to be set in the clipboard
 * @param dataTypes the transfer agents that will convert the data to its
 * platform specific format; each entry in the data array must have a
 * corresponding dataType
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if data is null or datatypes is null
 *          or the length of data is not the same as the length of dataTypes</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *  @exception SWTError <ul>
 *    <li>ERROR_CANNOT_SET_CLIPBOARD - if the clipboard is locked or otherwise unavailable</li>
 * </ul>
 *
 * <p>NOTE: ERROR_CANNOT_SET_CLIPBOARD should be an SWTException, since it is a
 * recoverable error, but can not be changed due to backward compatibility.</p>
 */
public void setContents(Object[] data, Transfer[] dataTypes) {
    setContents(data, dataTypes, DND.CLIPBOARD);
}

/**
 * Place data of the specified type on the specified clipboard.  More than one
 * type of data can be placed on the specified clipboard at the same time.
 * Setting the data clears any previous data from the specified
 * clipboard, regardless of type.
 *
 * <p>NOTE: On some platforms, the data is immediately copied to the specified
 * clipboard but on other platforms it is provided upon request.  As a result,
 * if the application modifies the data object it has set on the clipboard, that
 * modification may or may not be available when the data is subsequently
 * requested.</p>
 *
 * <p>The clipboards value is either one of the clipboard constants defined in
 * class <code>DND</code>, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>DND</code> clipboard constants.</p>
 *
 * <p>The following snippet shows text and RTF text being set on the copy/paste
 * clipboard:
 * </p>
 *
 * <code><pre>
 *  Clipboard clipboard = new Clipboard(display);
 *  String textData = "Hello World";
 *  String rtfData = "{\\rtf1\\b\\i Hello World}";
 *  TextTransfer textTransfer = TextTransfer.getInstance();
 *  RTFTransfer rtfTransfer = RTFTransfer.getInstance();
 *  Transfer[] transfers = new Transfer[]{textTransfer, rtfTransfer};
 *  Object[] data = new Object[]{textData, rtfData};
 *  clipboard.setContents(data, transfers, DND.CLIPBOARD);
 *  clipboard.dispose();
 * </code></pre>
 *
 * @param data the data to be set in the clipboard
 * @param dataTypes the transfer agents that will convert the data to its
 * platform specific format; each entry in the data array must have a
 * corresponding dataType
 * @param clipboards on which to set the data
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if data is null or datatypes is null
 *          or the length of data is not the same as the length of dataTypes</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *  @exception SWTError <ul>
 *    <li>ERROR_CANNOT_SET_CLIPBOARD - if the clipboard is locked or otherwise unavailable</li>
 * </ul>
 *
 * <p>NOTE: ERROR_CANNOT_SET_CLIPBOARD should be an SWTException, since it is a
 * recoverable error, but can not be changed due to backward compatibility.</p>
 *
 * @see DND#CLIPBOARD
 * @see DND#SELECTION_CLIPBOARD
 *
 * @since 3.1
 */
public void setContents(Object[] data, Transfer[] dataTypes, int clipboards) {
    checkWidget();
    if (data is null || dataTypes is null || data.length !is dataTypes.length || data.length is 0) {
        DND.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    for (int i = 0; i < data.length; i++) {
        if (data[i] is null || dataTypes[i] is null || !dataTypes[i].validate(data[i])) {
            DND.error(SWT.ERROR_INVALID_ARGUMENT);
        }
    }
    if ((clipboards & DND.CLIPBOARD) is 0) return;
    this.data = data;
    this.transferAgents = dataTypes;
    /* OleSetClipboard([in] pDataObject)
     * The argument pDataObject is owned by the caller so the reference count does not
     * need to be incremented.
     */
    int result = COM.OleSetClipboard(iDataObject);

    /*
    * Bug in Windows. When a new application takes control
    * of the clipboard, other applications may open the
    * clipboard to determine if they want to record the
    * clipboard updates.  When this happens, the clipboard
    * can not be flushed until the other application is
    * finished.  To allow other applications to get the
    * data, use PeekMessage() to enable cross thread
    * message sends.
    */
    int retryCount = 0;
    while (result !is COM.S_OK && retryCount++ < 10) {
        try {Thread.sleep(50);} catch (Exception t) {}
        MSG msg;
        OS.PeekMessage(&msg, null, 0, 0, OS.PM_NOREMOVE | OS.PM_NOYIELD);
        result = COM.OleSetClipboard(iDataObject);
    }
    if (result !is COM.S_OK) {
        DND.error(DND.ERROR_CANNOT_SET_CLIPBOARD);
    }
}
private int AddRef() {
    refCount++;
    return refCount;
}
private void createCOMInterfaces() {
    // register each of the interfaces that this object implements
    iDataObject = new _IDataObjectImpl( this );
}
private void disposeCOMInterfaces() {
    iDataObject = null;
}
/*
 * EnumFormatEtc([in] dwDirection, [out] ppenumFormatetc)
 * Ownership of ppenumFormatetc transfers from callee to caller so reference count on ppenumFormatetc
 * must be incremented before returning.  Caller is responsible for releasing ppenumFormatetc.
 */
HRESULT EnumFormatEtc(int dwDirection, IEnumFORMATETC* ppenumFormatetc) {
    // only allow getting of data - SetData is not currently supported
    if (dwDirection is COM.DATADIR_SET) return COM.E_NOTIMPL;
    // what types have been registered?
    TransferData[] allowedDataTypes = new TransferData[0];
    for (int i = 0; i < transferAgents.length; i++){
        TransferData[] formats = transferAgents[i].getSupportedTypes();
        TransferData[] newAllowedDataTypes = new TransferData[allowedDataTypes.length + formats.length];
        System.arraycopy(allowedDataTypes, 0, newAllowedDataTypes, 0, allowedDataTypes.length);
        System.arraycopy(formats, 0, newAllowedDataTypes, allowedDataTypes.length, formats.length);
        allowedDataTypes = newAllowedDataTypes;
    }
    OleEnumFORMATETC enumFORMATETC = new OleEnumFORMATETC();
    enumFORMATETC.AddRef();
    FORMATETC*[] formats = new FORMATETC*[allowedDataTypes.length + 1];
    for (int i = 0; i < allowedDataTypes.length; i++){
        formats[i] = allowedDataTypes[i].formatetc;
    }
    // include the drop effect format to specify a copy operation
    FORMATETC* dropeffect = new FORMATETC();
    dropeffect.cfFormat = cast(ushort) CFSTR_PREFERREDDROPEFFECT;
    dropeffect.dwAspect = COM.DVASPECT_CONTENT;
    dropeffect.lindex = -1;
    dropeffect.tymed = COM.TYMED_HGLOBAL;
    formats[formats.length -1] = dropeffect;
    enumFORMATETC.setFormats(formats);

    // TODO: <shawn liu> do we need AddRef() here
    *ppenumFormatetc = enumFORMATETC.getAddress();
    return COM.S_OK;
}

private IDataObject getAddress(){
    return iDataObject;
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

    if (transferData.type is CFSTR_PREFERREDDROPEFFECT) {
        // specify that a copy operation is to be performed
        STGMEDIUM* stgmedium = new STGMEDIUM();
        stgmedium.tymed = COM.TYMED_HGLOBAL;
        stgmedium.unionField = OS.GlobalAlloc(COM.GMEM_FIXED | COM.GMEM_ZEROINIT, 4);
        //TODO - should call GlobalLock
        int[] intArr = [COM.DROPEFFECT_COPY];
        OS.MoveMemory(stgmedium.unionField, intArr.ptr, 4);
        stgmedium.pUnkForRelease = null;
        COM.MoveMemory(pmedium, stgmedium, STGMEDIUM.sizeof);
        return COM.S_OK;
    }

    // get matching transfer agent to perform conversion
    int transferIndex = -1;
    for (int i = 0; i < transferAgents.length; i++){
        if (transferAgents[i].isSupportedType(transferData)){
            transferIndex = i;
            break;
        }
    }
    if (transferIndex is -1) return COM.DV_E_FORMATETC;
    transferAgents[transferIndex].javaToNative(data[transferIndex], transferData);
    COM.MoveMemory(pmedium, transferData.stgmedium, STGMEDIUM.sizeof);
    return transferData.result;
}

HRESULT QueryGetData(FORMATETC * pFormatetc) {
    if (transferAgents is null) return COM.E_FAIL;
    TransferData transferData = new TransferData();
    transferData.formatetc = new FORMATETC();
    COM.MoveMemory(transferData.formatetc, pFormatetc, FORMATETC.sizeof);
    transferData.type = transferData.formatetc.cfFormat;
    if (transferData.type is CFSTR_PREFERREDDROPEFFECT) return COM.S_OK;
    // is this type supported by the transfer agent?
    for (int i = 0; i < transferAgents.length; i++){
        if (transferAgents[i].isSupportedType(transferData))
            return COM.S_OK;
    }

    return COM.DV_E_FORMATETC;
}
/* QueryInterface([in] iid, [out] ppvObject)
 * Ownership of ppvObject transfers from callee to caller so reference count on ppvObject
 * must be incremented before returning.  Caller is responsible for releasing ppvObject.
 */
HRESULT QueryInterface(REFCIID riid, void ** ppvObject) {
    if (riid is null || ppvObject is null) return COM.E_INVALIDARG;
    if (COM.IsEqualGUID(riid, &COM.IIDIUnknown) || COM.IsEqualGUID(riid, &COM.IIDIDataObject) ) {
        *ppvObject = cast(void*)cast(IUnknown)iDataObject;
        AddRef();
        return COM.S_OK;
    }
    *ppvObject = null;
    return COM.E_NOINTERFACE;
}
private ULONG Release() {
    refCount--;
    if (refCount is 0) {
        this.data = null;
        this.transferAgents = null;
        disposeCOMInterfaces();
        COM.CoFreeUnusedLibraries();
    }
    return refCount;
}

/**
 * Returns an array of the data types currently available on the system
 * clipboard. Use with Transfer.isSupportedType.
 *
 * @return array of data types currently available on the system clipboard
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Transfer#isSupportedType
 *
 * @since 3.0
 */
public TransferData[] getAvailableTypes() {
    return getAvailableTypes(DND.CLIPBOARD);
}

/**
 * Returns an array of the data types currently available on the specified
 * clipboard. Use with Transfer.isSupportedType.
 *
 * <p>The clipboards value is either one of the clipboard constants defined in
 * class <code>DND</code>, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>DND</code> clipboard constants.</p>
 *
 * @param clipboards from which to get the data types
 * @return array of data types currently available on the specified clipboard
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Transfer#isSupportedType
 * @see DND#CLIPBOARD
 * @see DND#SELECTION_CLIPBOARD
 *
 * @since 3.1
 */
public TransferData[] getAvailableTypes(int clipboards) {
    checkWidget();
    if ((clipboards & DND.CLIPBOARD) is 0) return null;
    FORMATETC*[] types = _getAvailableTypes();
    TransferData[] data = new TransferData[types.length];
    for (int i = 0; i < types.length; i++) {
        data[i] = new TransferData();
        data[i].type = types[i].cfFormat;
        data[i].formatetc = types[i];
    }
    return data;
}

/**
 * Returns a platform specific list of the data types currently available on the
 * system clipboard.
 *
 * <p>Note: <code>getAvailableTypeNames</code> is a utility for writing a Transfer
 * sub-class.  It should NOT be used within an application because it provides
 * platform specific information.</p>
 *
 * @return a platform specific list of the data types currently available on the
 * system clipboard
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String[] getAvailableTypeNames() {
    checkWidget();
    FORMATETC*[] types = _getAvailableTypes();
    String[] names = new String[](types.length);
    int maxSize = 128;
    for (int i = 0; i < types.length; i++){
        TCHAR[] buffer = NewTCHARs(0, maxSize);
        int size = OS.GetClipboardFormatName(types[i].cfFormat, buffer.ptr, maxSize);
        if (size !is 0) {
            names[i] = TCHARzToStr(buffer.ptr)[0..size];
        } else {
            switch (types[i].cfFormat) {
                case COM.CF_HDROP: names[i] = "CF_HDROP"; break; //$NON-NLS-1$
                case COM.CF_TEXT: names[i] = "CF_TEXT"; break; //$NON-NLS-1$
                case COM.CF_BITMAP: names[i] = "CF_BITMAP"; break; //$NON-NLS-1$
                case COM.CF_METAFILEPICT: names[i] = "CF_METAFILEPICT"; break; //$NON-NLS-1$
                case COM.CF_SYLK: names[i] = "CF_SYLK"; break; //$NON-NLS-1$
                case COM.CF_DIF: names[i] = "CF_DIF"; break; //$NON-NLS-1$
                case COM.CF_TIFF: names[i] = "CF_TIFF"; break; //$NON-NLS-1$
                case COM.CF_OEMTEXT: names[i] = "CF_OEMTEXT"; break; //$NON-NLS-1$
                case COM.CF_DIB: names[i] = "CF_DIB"; break; //$NON-NLS-1$
                case COM.CF_PALETTE: names[i] = "CF_PALETTE"; break; //$NON-NLS-1$
                case COM.CF_PENDATA: names[i] = "CF_PENDATA"; break; //$NON-NLS-1$
                case COM.CF_RIFF: names[i] = "CF_RIFF"; break; //$NON-NLS-1$
                case COM.CF_WAVE: names[i] = "CF_WAVE"; break; //$NON-NLS-1$
                case COM.CF_UNICODETEXT: names[i] = "CF_UNICODETEXT"; break; //$NON-NLS-1$
                case COM.CF_ENHMETAFILE: names[i] = "CF_ENHMETAFILE"; break; //$NON-NLS-1$
                case COM.CF_LOCALE: names[i] = "CF_LOCALE"; break; //$NON-NLS-1$
                case COM.CF_MAX: names[i] = "CF_MAX"; break; //$NON-NLS-1$
                default: names[i] = "UNKNOWN"; //$NON-NLS-1$
            }
        }
    }
    return names;
}

private FORMATETC*[] _getAvailableTypes() {
    FORMATETC*[] types = null;
    IDataObject dataObject;
    /* OleGetClipboard([out] ppDataObject).
     * AddRef has already been called on ppDataObject by the callee and must be released by the caller.
     */
    if (COM.OleGetClipboard(&dataObject) !is COM.S_OK) return types;
    IEnumFORMATETC enumFormatetc;
    /* EnumFormatEtc([in] dwDirection, [out] ppenumFormatetc)
     * AddRef has already been called on ppenumFormatetc by the callee and must be released by the caller.
     */
    int rc = dataObject.EnumFormatEtc(COM.DATADIR_GET, &enumFormatetc);
    dataObject.Release();
    if (rc !is COM.S_OK)return types;
    // Loop over enumerator and save any types that match what we are looking for
    //auto rgelt = OS.GlobalAlloc(OS.GMEM_FIXED | OS.GMEM_ZEROINIT, FORMATETC.sizeof);
    uint[1] pceltFetched;
    FORMATETC rgelt;
    enumFormatetc.Reset();
    while (enumFormatetc.Next(1, &rgelt, pceltFetched.ptr) is COM.S_OK && pceltFetched[0] is 1) {
        FORMATETC* formatetc = new FORMATETC();
        COM.MoveMemory(formatetc, &rgelt, FORMATETC.sizeof);
        FORMATETC*[] newTypes = new FORMATETC*[types.length + 1];
        SimpleType!(FORMATETC*).arraycopy(types, 0, newTypes, 0, types.length);
        newTypes[types.length] = formatetc;
        types = newTypes;
    }
    //OS.GlobalFree(rgelt);
    enumFormatetc.Release();
    return types;
}
}

private class _IDataObjectImpl : IDataObject {

    Clipboard   parent;
    this(Clipboard  p) { parent = p; }
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
    HRESULT SetData(FORMATETC* pFormatetc, STGMEDIUM * pmedium, BOOL fRelease) { return COM.E_NOTIMPL; }
    HRESULT EnumFormatEtc(DWORD dwDirection, IEnumFORMATETC * ppenumFormatetc) { return parent.EnumFormatEtc(dwDirection, ppenumFormatetc); }
    HRESULT DAdvise(FORMATETC* pFormatetc, DWORD advf, IAdviseSink pAdvSink, DWORD* pdwConnection) { return COM.E_NOTIMPL; }
    HRESULT DUnadvise(DWORD dwConnection) { return COM.E_NOTIMPL; }
    HRESULT EnumDAdvise(IEnumSTATDATA * ppenumAdvise) { return COM.E_NOTIMPL; }
}

