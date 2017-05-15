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

module org.eclipse.swt.ole.win32.OleClientSite;



import java.io.File;

import java.io.FileInputStream;

import java.io.FileOutputStream;

import java.lang.all;



import org.eclipse.swt.SWT;

import org.eclipse.swt.SWTException;

import org.eclipse.swt.graphics.Point;

import org.eclipse.swt.graphics.Rectangle;

import org.eclipse.swt.internal.Compatibility;

// import org.eclipse.swt.internal.ole.win32.CAUUID;

// import org.eclipse.swt.internal.ole.win32.COM;

// import org.eclipse.swt.internal.ole.win32.COMObject;

// import org.eclipse.swt.internal.ole.win32.GUID;

// import org.eclipse.swt.internal.ole.win32.IDispatch;

// import org.eclipse.swt.internal.ole.win32.IMoniker;

// import org.eclipse.swt.internal.ole.win32.IOleCommandTarget;

// import org.eclipse.swt.internal.ole.win32.IOleDocument;

// import org.eclipse.swt.internal.ole.win32.IOleDocumentView;

// import org.eclipse.swt.internal.ole.win32.IOleInPlaceObject;

// import org.eclipse.swt.internal.ole.win32.IOleLink;

// import org.eclipse.swt.internal.ole.win32.IOleObject;

// import org.eclipse.swt.internal.ole.win32.IPersist;

// import org.eclipse.swt.internal.ole.win32.IPersistStorage;

// import org.eclipse.swt.internal.ole.win32.ISpecifyPropertyPages;

// import org.eclipse.swt.internal.ole.win32.IStorage;

// import org.eclipse.swt.internal.ole.win32.IStream;

// import org.eclipse.swt.internal.ole.win32.IUnknown;

// import org.eclipse.swt.internal.ole.win32.IViewObject2;

// import org.eclipse.swt.internal.ole.win32.OLECMD;

// import org.eclipse.swt.internal.ole.win32.OLEINPLACEFRAMEINFO;

import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.internal.ole.win32.extras;

import org.eclipse.swt.internal.ole.win32.OAIDL;

import org.eclipse.swt.internal.ole.win32.OLEIDL;

import org.eclipse.swt.internal.ole.win32.OBJIDL;

import org.eclipse.swt.internal.ole.win32.DOCOBJ;

import org.eclipse.swt.internal.ole.win32.COM;

import org.eclipse.swt.internal.ole.win32.ifs;



import org.eclipse.swt.widgets.Composite;

import org.eclipse.swt.widgets.Event;

import org.eclipse.swt.widgets.Listener;

import org.eclipse.swt.widgets.Menu;

import org.eclipse.swt.widgets.Shell;



import org.eclipse.swt.ole.win32.OleFrame;

import org.eclipse.swt.ole.win32.Variant;

import org.eclipse.swt.ole.win32.OLE;





/**

 * OleClientSite provides a site to manage an embedded OLE Document within a container.

 *

 * <p>The OleClientSite provides the following capabilities:

 * <ul>

 *  <li>creates the in-place editor for a blank document or opening an existing OLE Document

 *  <li>lays the editor out

 *  <li>provides a mechanism for activating and deactivating the Document

 *  <li>provides a mechanism for saving changes made to the document

 * </ul>

 *

 * <p>This object implements the OLE Interfaces IUnknown, IOleClientSite, IAdviseSink,

 * IOleInPlaceSite

 *

 * <p>Note that although this class is a subclass of <code>Composite</code>,

 * it does not make sense to add <code>Control</code> children to it,

 * or set a layout on it.

 * </p><p>

 * <dl>

 *  <dt><b>Styles</b> <dd>BORDER

 *  <dt><b>Events</b> <dd>Dispose, Move, Resize

 * </dl>

 *

 * @see <a href="http://www.eclipse.org/swt/snippets/#ole">OLE and ActiveX snippets</a>

 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Examples: OLEExample, OleWebBrowser</a>

 */

public class OleClientSite : Composite {



    // Interfaces for this Ole Client Container

    private _IUnknownImpl          iUnknown;

    private _IOleClientSiteImpl    iOleClientSite;

    private _IAdviseSinkImpl       iAdviseSink;

    private _IOleInPlaceSiteImpl   iOleInPlaceSite;

    private _IOleDocumentSiteImpl  iOleDocumentSite;



    protected GUID* appClsid;

    private GUID* objClsid;

    private int  refCount;



    // References to the associated Frame.

    package OleFrame frame;



    // Access to the embedded/linked Ole Object

    protected IUnknown              objIUnknown;

    protected IOleObject            objIOleObject;

    protected IViewObject2          objIViewObject2;

    protected IOleInPlaceObject     objIOleInPlaceObject;

    protected IOleCommandTarget     objIOleCommandTarget;

    protected IOleDocumentView      objDocumentView;



    // Related storage information

    protected IStorage tempStorage;     // IStorage interface of the receiver



    // Internal state and style information

    private int     aspect;    // the display aspect of the embedded object, e.g., DvaspectContent or DvaspectIcon

    private int     type;      // Indicates the type of client that can be supported inside this container

    private bool isStatic;  // Indicates item's display is static, i.e., a bitmap, metafile, etc.



    private RECT borderWidths;

    private RECT indent;

    private bool inUpdate = false;

    private bool inInit = true;

    private bool inDispose = false;



    private static const String WORDPROGID = "Word.Document"; //$NON-NLS-1$



    private Listener listener;



    enum{

        STATE_NONE = 0,

        STATE_RUNNING = 1,

        STATE_INPLACEACTIVE = 2,

        STATE_UIACTIVE = 3,

        STATE_ACTIVE = 4,

    }

    int state = STATE_NONE;



protected this(Composite parent, int style) {

    /*

     * NOTE: this constructor should never be used by itself because it does

     * not create an Ole Object

     */

    super(parent, style);



    createCOMInterfaces();



    // install the Ole Frame for this Client Site

    while (parent !is null) {

        if ( auto aframe = cast(OleFrame)parent){

            frame = aframe;

            break;

        }

        parent = parent.getParent();

    }

    if (frame is null) OLE.error (__FILE__, __LINE__, SWT.ERROR_INVALID_ARGUMENT);

    frame.AddRef();



    aspect   = COM.DVASPECT_CONTENT;

    type     = COM.OLEEMBEDDED;

    isStatic = false;



    listener = new class() Listener {

        public void handleEvent(Event e) {

            switch (e.type) {

            case SWT.Resize :

            case SWT.Move :    onResize(e); break;

            case SWT.Dispose : onDispose(e); break;

            case SWT.FocusIn:  onFocusIn(e); break;

            case SWT.FocusOut:  onFocusOut(e); break;

            case SWT.Paint:    onPaint(e); break;

            case SWT.Traverse: onTraverse(e); break;

            case SWT.KeyDown: /* required for traversal */ break;

            default :

                OLE.error (__FILE__, __LINE__, SWT.ERROR_NOT_IMPLEMENTED);

            }

        }

    };



    frame.addListener(SWT.Resize, listener);

    frame.addListener(SWT.Move, listener);

    addListener(SWT.Dispose, listener);

    addListener(SWT.FocusIn, listener);

    addListener(SWT.FocusOut, listener);

    addListener(SWT.Paint, listener);

    addListener(SWT.Traverse, listener);

    addListener(SWT.KeyDown, listener);

}

/**

 * Create an OleClientSite child widget using the OLE Document type associated with the

 * specified file.  The OLE Document type is determined either through header information in the file

 * or through a Registry entry for the file extension. Use style bits to select a particular look

 * or set of properties.

 *

 * @param parent a composite widget; must be an OleFrame

 * @param style the bitwise OR'ing of widget styles

 * @param file the file that is to be opened in this OLE Document

 *

 * @exception IllegalArgumentException

 * <ul><li>ERROR_NULL_ARGUMENT when the parent is null

 *     <li>ERROR_INVALID_ARGUMENT when the parent is not an OleFrame</ul>

 * @exception SWTException

 * <ul><li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread

 *     <li>ERROR_CANNOT_CREATE_OBJECT when failed to create OLE Object

 *     <li>ERROR_CANNOT_OPEN_FILE when failed to open file

 *     <li>ERROR_INTERFACE_NOT_FOUND when unable to create callbacks for OLE Interfaces

 *     <li>ERROR_INVALID_CLASSID

 * </ul>

 */

public this(Composite parent, int style, File file) {

    this(parent, style);

    try {



        if (file is null || file.isDirectory() || !file.exists())

            OLE.error (__FILE__, __LINE__, OLE.ERROR_INVALID_ARGUMENT);



        // Is there an associated CLSID?

        appClsid = new GUID();

        LPCTSTR fileName = StrToTCHARz( 0, file.getAbsolutePath() );

        int result = COM.GetClassFile(fileName, appClsid);

        if (result !is COM.S_OK)

            OLE.error (__FILE__, __LINE__, OLE.ERROR_INVALID_CLASSID, result);

        // associated CLSID may not be installed on this machine

        if (getProgramID() is null)

            OLE.error (__FILE__, __LINE__, OLE.ERROR_INVALID_CLASSID, result);



        // Open a temporary storage object

        tempStorage = createTempStorage();



        // Create ole object with storage object

        result = COM.OleCreateFromFile(appClsid, fileName, &COM.IIDIUnknown, COM.OLERENDER_DRAW, null, null, tempStorage, cast(void**)&objIUnknown);

        if (result !is COM.S_OK)

            OLE.error (__FILE__, __LINE__, OLE.ERROR_CANNOT_CREATE_OBJECT, result);



        // Init sinks

        addObjectReferences();



        if (COM.OleRun(objIUnknown) is OLE.S_OK) state = STATE_RUNNING;

    } catch (SWTException e) {

        dispose();

        disposeCOMInterfaces();

        throw e;

    }

}

/**

 * Create an OleClientSite child widget to edit a blank document using the specified OLE Document

 * application.  Use style bits to select a particular look or set of properties.

 *

 * @param parent a composite widget; must be an OleFrame

 * @param style the bitwise OR'ing of widget styles

 * @param progId the unique program identifier of am OLE Document application;

 *               the value of the ProgID key or the value of the VersionIndependentProgID key specified

 *               in the registry for the desired OLE Document (for example, the VersionIndependentProgID

 *               for Word is Word.Document)

 *

 * @exception IllegalArgumentException

 *<ul>

 *     <li>ERROR_NULL_ARGUMENT when the parent is null

 *     <li>ERROR_INVALID_ARGUMENT when the parent is not an OleFrame

 *</ul>

 * @exception SWTException

 * <ul><li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread

 *     <li>ERROR_INVALID_CLASSID when the progId does not map to a registered CLSID

 *     <li>ERROR_CANNOT_CREATE_OBJECT when failed to create OLE Object

 * </ul>

 */

public this(Composite parent, int style, String progId) {

    this(parent, style);

    try {

        appClsid = getClassID(progId);

        if (appClsid is null)

            OLE.error (__FILE__, __LINE__, OLE.ERROR_INVALID_CLASSID);



        // Open a temporary storage object

        tempStorage = createTempStorage();



        // Create ole object with storage object

        HRESULT result = COM.OleCreate(appClsid, &COM.IIDIUnknown, COM.OLERENDER_DRAW, null, null, tempStorage, cast(void**)&objIUnknown);

        if (result !is COM.S_OK)

            OLE.error (__FILE__, __LINE__, OLE.ERROR_CANNOT_CREATE_OBJECT, result);



        // Init sinks

        addObjectReferences();



        if (COM.OleRun(objIUnknown) is OLE.S_OK) state = STATE_RUNNING;



    } catch (SWTException e) {

        dispose();

        disposeCOMInterfaces();

        throw e;

    }

}

/**

 * Create an OleClientSite child widget to edit the specified file using the specified OLE Document

 * application.  Use style bits to select a particular look or set of properties.

 * <p>

 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public

 * API for <code>OleClientSite</code>. It is marked public only so that it

 * can be shared within the packages provided by SWT. It is not

 * available on all platforms, and should never be called from

 * application code.

 * </p>

 * @param parent a composite widget; must be an OleFrame

 * @param style the bitwise OR'ing of widget styles

 * @param progId the unique program identifier of am OLE Document application;

 *               the value of the ProgID key or the value of the VersionIndependentProgID key specified

 *               in the registry for the desired OLE Document (for example, the VersionIndependentProgID

 *               for Word is Word.Document)

 * @param file the file that is to be opened in this OLE Document

 *

 * @exception IllegalArgumentException

 * <ul><li>ERROR_NULL_ARGUMENT when the parent is null

 *     <li>ERROR_INVALID_ARGUMENT when the parent is not an OleFrame</ul>

 * @exception SWTException

 * <ul><li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread

 *     <li>ERROR_INVALID_CLASSID when the progId does not map to a registered CLSID

 *     <li>ERROR_CANNOT_CREATE_OBJECT when failed to create OLE Object

 *     <li>ERROR_CANNOT_OPEN_FILE when failed to open file

 * </ul>

 */

public this(Composite parent, int style, String progId, File file) {

    this(parent, style);

    try {

        if (file is null || file.isDirectory() || !file.exists()) OLE.error (__FILE__, __LINE__, OLE.ERROR_INVALID_ARGUMENT);

        appClsid = getClassID(progId);

        if (appClsid is null) OLE.error (__FILE__, __LINE__, OLE.ERROR_INVALID_CLASSID);



        // Are we opening this file with the preferred OLE object?

        LPCTSTR fileName = StrToWCHARz(file.getAbsolutePath());

        GUID* fileClsid = new GUID();

        COM.GetClassFile(fileName, fileClsid);



        if (COM.IsEqualGUID(appClsid, fileClsid)){

            // Using the same application that created file, therefore, use default mechanism.

            tempStorage = createTempStorage();

            // Create ole object with storage object

            HRESULT result = COM.OleCreateFromFile(appClsid, fileName, &COM.IIDIUnknown, COM.OLERENDER_DRAW, null, null, tempStorage, cast(void**)&objIUnknown);

            if (result !is COM.S_OK) OLE.error (__FILE__, __LINE__, OLE.ERROR_CANNOT_CREATE_OBJECT, result);

        } else {

            // Not using the same application that created file, therefore, copy from original file to a new storage file

            IStorage storage = null;

            if (COM.StgIsStorageFile(fileName) is COM.S_OK) {

                int mode = COM.STGM_READ | COM.STGM_TRANSACTED | COM.STGM_SHARE_EXCLUSIVE;

                HRESULT result = COM.StgOpenStorage(fileName, null, mode, null, 0, &storage); //Does an AddRef if successful

                if (result !is COM.S_OK) OLE.error (__FILE__, __LINE__, OLE.ERROR_CANNOT_OPEN_FILE, result);

            } else {

                // Original file is not a Storage file so copy contents to a stream in a new storage file

                int mode = COM.STGM_READWRITE | COM.STGM_DIRECT | COM.STGM_SHARE_EXCLUSIVE | COM.STGM_CREATE;

                HRESULT result = COM.StgCreateDocfile(null, mode | COM.STGM_DELETEONRELEASE, 0, &storage); // Increments ref count if successful

                if (result !is COM.S_OK) OLE.error (__FILE__, __LINE__, OLE.ERROR_CANNOT_OPEN_FILE, result);

                // Create a stream on the storage object.

                // Word does not follow the standard and does not use "CONTENTS" as the name of

                // its primary stream

                LPCTSTR streamName = StrToWCHARz("CONTENTS"); //$NON-NLS-1$

                GUID* wordGUID = getClassID(WORDPROGID);

                if (wordGUID !is null && COM.IsEqualGUID(appClsid, wordGUID)) streamName = StrToWCHARz("WordDocument"); //$NON-NLS-1$

                IStream stream;

                result = storage.CreateStream(streamName, mode, 0, 0, &stream); // Increments ref count if successful

                if (result !is COM.S_OK) {

                    storage.Release();

                    OLE.error (__FILE__, __LINE__, OLE.ERROR_CANNOT_OPEN_FILE, result);

                }

                try {

                    // Copy over data in file to named stream

                    FileInputStream fileInput = new FileInputStream(file);

                    int increment = 1024*4;

                    byte[] buffer = new byte[increment];

                    int count = 0;

                    while((count = fileInput.read(buffer)) > 0){

                        auto pv = COM.CoTaskMemAlloc(count);

                        OS.MoveMemory(pv, buffer.ptr, count);

                        result = stream.Write(pv, count, null) ;

                        COM.CoTaskMemFree(pv);

                        if (result !is COM.S_OK) {

                            fileInput.close();

                            stream.Release();

                            storage.Release();

                            OLE.error (__FILE__, __LINE__, OLE.ERROR_CANNOT_OPEN_FILE, result);

                        }

                    }

                    fileInput.close();

                    stream.Commit(COM.STGC_DEFAULT);

                    stream.Release();

                } catch (IOException err) {

                    stream.Release();

                    storage.Release();

                    OLE.error (__FILE__, __LINE__, OLE.ERROR_CANNOT_OPEN_FILE);

                }

            }



            // Open a temporary storage object

            tempStorage = createTempStorage();

            // Copy over contents of file

            HRESULT result = storage.CopyTo(0, null, null, tempStorage);

            storage.Release();

            if (result !is COM.S_OK) OLE.error (__FILE__, __LINE__, OLE.ERROR_CANNOT_OPEN_FILE, result);



            // create ole client

            result = COM.CoCreateInstance(appClsid, null, COM.CLSCTX_INPROC_HANDLER | COM.CLSCTX_INPROC_SERVER, &COM.IIDIUnknown, cast(void**)&objIUnknown);

            if (result !is COM.S_OK) OLE.error (__FILE__, __LINE__, OLE.ERROR_CANNOT_CREATE_OBJECT, result);

            // get the persistent storage of the ole client

            IPersistStorage iPersistStorage;

            result = objIUnknown.QueryInterface(&COM.IIDIPersistStorage, cast(void**)&iPersistStorage);

            if (result !is COM.S_OK) OLE.error (__FILE__, __LINE__, OLE.ERROR_CANNOT_CREATE_OBJECT, result);

            // load the contents of the file into the ole client site

            result = iPersistStorage.Load(tempStorage);

            iPersistStorage.Release();

            if (result !is COM.S_OK)OLE.error (__FILE__, __LINE__, OLE.ERROR_CANNOT_CREATE_OBJECT, result);

        }



        // Init sinks

        addObjectReferences();



        if (COM.OleRun(objIUnknown) is OLE.S_OK) state = STATE_RUNNING;



    } catch (SWTException e) {

        dispose();

        disposeCOMInterfaces();

        throw e;

    }

}

protected void addObjectReferences() {

    //

    IPersist objIPersist;

    if (objIUnknown.QueryInterface(&COM.IIDIPersist, cast(void**)&objIPersist) is COM.S_OK) {

        GUID* tempid = new GUID();

        if (objIPersist.GetClassID(tempid) is COM.S_OK)

            objClsid = tempid;

        objIPersist.Release();

    }



    //

    HRESULT result = objIUnknown.QueryInterface(&COM.IIDIViewObject2, cast(void**)&objIViewObject2);

    if (result !is COM.S_OK)

        OLE.error (__FILE__, __LINE__, OLE.ERROR_INTERFACE_NOT_FOUND, result);

    objIViewObject2.SetAdvise(aspect, 0, iAdviseSink);



    //

    result = objIUnknown.QueryInterface(&COM.IIDIOleObject, cast(void**)&objIOleObject);

    if (result !is COM.S_OK)

        OLE.error (__FILE__, __LINE__, OLE.ERROR_INTERFACE_NOT_FOUND, result);

    objIOleObject.SetClientSite(iOleClientSite);

    uint pdwConnection;

    objIOleObject.Advise(iAdviseSink, &pdwConnection);

    objIOleObject.SetHostNames("main", "main");  //$NON-NLS-1$ //$NON-NLS-2$



    // Notify the control object that it is embedded in an OLE container

    COM.OleSetContainedObject(objIUnknown, true);



    // Is OLE object linked or embedded?

    IOleLink objIOleLink;

    if (objIUnknown.QueryInterface(&COM.IIDIOleLink, cast(void**)&objIOleLink) is COM.S_OK) {

        IMoniker objIMoniker;

        if (objIOleLink.GetSourceMoniker(&objIMoniker) is COM.S_OK) {

            objIMoniker.Release();

            type = COM.OLELINKED;

            objIOleLink.BindIfRunning();

        } else {

            isStatic = true;

        }

        objIOleLink.Release();

    }

}

protected int AddRef() {

    refCount++;

    return refCount;

}

private int CanInPlaceActivate() {

    if (aspect is COM.DVASPECT_CONTENT && type is COM.OLEEMBEDDED)

        return COM.S_OK;



    return COM.S_FALSE;

}

private int ContextSensitiveHelp(int fEnterMode) {

    return COM.S_OK;

}

protected void createCOMInterfaces() {

    iUnknown = new _IUnknownImpl(this);

    iOleClientSite = new _IOleClientSiteImpl(this);

    iAdviseSink = new _IAdviseSinkImpl(this);

    iOleInPlaceSite = new _IOleInPlaceSiteImpl(this);

    iOleDocumentSite = new _IOleDocumentSiteImpl(this);

}

protected IStorage createTempStorage() {

    IStorage tmpStorage;

    int grfMode = COM.STGM_READWRITE | COM.STGM_SHARE_EXCLUSIVE | COM.STGM_DELETEONRELEASE;

    HRESULT result = COM.StgCreateDocfile(null, grfMode, 0, &tmpStorage);

    if (result !is COM.S_OK) OLE.error(__FILE__, __LINE__, OLE.ERROR_CANNOT_CREATE_FILE, result);

    return (tmpStorage);

}

/**

 * Deactivates an active in-place object and discards the object's undo state.

 */

public void deactivateInPlaceClient() {

    if (objIOleInPlaceObject !is null) {

        objIOleInPlaceObject.InPlaceDeactivate();

    }

}

private void deleteTempStorage() {

    //Destroy this item's contents in the temp root IStorage.

    if (tempStorage !is null){

        tempStorage.Release();

    }

    tempStorage = null;

}

protected void disposeCOMInterfaces() {

    iUnknown = null;

    iOleClientSite = null;

    iAdviseSink = null;

    iOleInPlaceSite = null;

    iOleDocumentSite = null;

}

/**

 * Requests that the OLE Document or ActiveX Control perform an action; actions are almost always

 * changes to the activation state.

 *

 * @param verb the operation that is requested.  This is one of the OLE.OLEIVERB_ values

 *

 * @return an HRESULT value indicating the success of the operation request; OLE.S_OK indicates

 *         success

 */

public int doVerb(int verb) {

    // Not all OLE clients (for example PowerPoint) can be set into the running state in the constructor.

    // The fix is to ensure that the client is in the running state before invoking any verb on it.

    if (state is STATE_NONE) {

        if (COM.OleRun(objIUnknown) is OLE.S_OK) state = STATE_RUNNING;

    }

    if (state is STATE_NONE || isStatic)

        return COM.E_FAIL;



    // See PR: 1FV9RZW

    RECT rect;

    OS.GetClientRect(handle, &rect);

    int result = objIOleObject.DoVerb(verb, null, iOleClientSite, 0, handle, &rect);



    if (state !is STATE_RUNNING && inInit) {

        updateStorage();

        inInit = false;

    }

    return result;

}

/**

 * Asks the OLE Document or ActiveX Control to execute a command from a standard

 * list of commands. The OLE Document or ActiveX Control must support the IOleCommandTarget

 * interface.  The OLE Document or ActiveX Control does not have to support all the commands

 * in the standard list.  To check if a command is supported, you can call queryStatus with

 * the cmdID.

 *

 * @param cmdID the ID of a command; these are the OLE.OLECMDID_ values - a small set of common

 *              commands

 * @param options the optional flags; these are the OLE.OLECMDEXECOPT_ values

 * @param in the argument for the command

 * @param out the return value of the command

 *

 * @return an HRESULT value; OLE.S_OK is returned if successful

 *

 */

public int exec(int cmdID, int options, Variant pvaIn, Variant pvaOut) {



    if (objIOleCommandTarget is null) {

        if (objIUnknown.QueryInterface(&COM.IIDIOleCommandTarget, cast(void**)&objIOleCommandTarget) !is COM.S_OK)

            return OLE.ERROR_INTERFACE_NOT_FOUND;

    }



    VARIANT* pIn = null;

    VARIANT* pOut = null;



    if(pvaIn){

        pIn = new VARIANT();

        pvaIn.getData(pIn);

    }

    if(pvaOut){

        pOut = new VARIANT();

        pvaOut.getData(pOut);

    }



    HRESULT result = objIOleCommandTarget.Exec(null, cmdID, options, pIn, pOut);



    if(pIn) {

        COM.VariantClear(pIn);

    }



    if(pOut) {

        pvaOut.setData(pOut);

        COM.VariantClear(pOut);

    }



    return result;

}

IDispatch getAutomationObject() {

    IDispatch ppvObject;

    if (objIUnknown.QueryInterface(&COM.IIDIDispatch, cast(void**)&ppvObject) !is COM.S_OK)

        return null;

    return ppvObject;

}

protected GUID* getClassID(String clientName) {

    // create a GUID struct to hold the result

    GUID* guid = new GUID();



    // create a null terminated array of char

    LPCTSTR buffer = null;

    if (clientName !is null) {

        buffer = StrToWCHARz(clientName);

    }

    if (COM.CLSIDFromProgID(buffer, guid) !is COM.S_OK){

        HRESULT result = COM.CLSIDFromString(buffer, guid);

        if (result !is COM.S_OK) return null;

    }

    return guid;

}



private HRESULT GetContainer(IOleContainer* ppContainer) {

    /* Simple containers that do not support links to their embedded

     * objects probably do not need to implement this method. Instead,

     * they can return E_NOINTERFACE and set ppContainer to NULL.

     */

    if (ppContainer !is null)

        *ppContainer = null;

    return COM.E_NOINTERFACE;

}



private SIZE* getExtent() {

    SIZE* sizel = new SIZE();

    // get the current size of the embedded OLENatives object

    if (objIOleObject !is null) {

        if ( objIViewObject2 !is null && !COM.OleIsRunning(objIOleObject)) {

            objIViewObject2.GetExtent(aspect, -1, null, sizel);

        } else {

            objIOleObject.GetExtent(aspect, sizel);

        }

    }

    return xFormHimetricToPixels(sizel);

}

/**

 * Returns the indent value that would be used to compute the clipping area

 * of the active X object.

 * 

 * NOTE: The indent value is no longer being used by the client site.

 * 

 * @return the rectangle representing the indent

 */

public Rectangle getIndent() {

    return new Rectangle(indent.left, indent.right, indent.top, indent.bottom);

}

/**

 * Returns the program ID of the OLE Document or ActiveX Control.

 *

 * @return the program ID of the OLE Document or ActiveX Control

 */

public String getProgramID(){

    if (appClsid !is null){

        wchar* hMem;

        if (COM.ProgIDFromCLSID(appClsid, &hMem) is COM.S_OK) {

            auto length = OS.GlobalSize(hMem);

            auto ptr = OS.GlobalLock(hMem);

            wchar[] buffer = new wchar[length];

            COM.MoveMemory(buffer.ptr, ptr, length);

            OS.GlobalUnlock(hMem);

            OS.GlobalFree(hMem);



            String result = WCHARzToStr(buffer.ptr);

            // remove null terminator

            //int index = result.indexOf("\0");

            return result;//.substring(0, index);

        }

    }

    return null;

}

int ActivateMe(IOleDocumentView pViewToActivate) {

    if (pViewToActivate is null) {

        void* ppvObject;

        if (objIUnknown.QueryInterface(&COM.IIDIOleDocument, &ppvObject) !is COM.S_OK) return COM.E_FAIL;

        IOleDocument objOleDocument = cast(IOleDocument)ppvObject;

        if (objOleDocument.CreateView(iOleInPlaceSite, null, 0, &objDocumentView) !is COM.S_OK) return COM.E_FAIL;

        objOleDocument.Release();

    } else {

        objDocumentView = pViewToActivate;

        objDocumentView.AddRef();

        objDocumentView.SetInPlaceSite(iOleInPlaceSite);

    }

    objDocumentView.UIActivate(1);//TRUE

    RECT* rect = getRect();

    objDocumentView.SetRect(rect);

    objDocumentView.Show(1);//TRUE

    return COM.S_OK;

}

protected HRESULT GetWindow(HWND* phwnd) {

    if (phwnd is null)

        return COM.E_INVALIDARG;

    if (frame is null) {

        *phwnd = null;

        return COM.E_NOTIMPL;

    }



    // Copy the Window's handle into the memory passed in

    *phwnd = frame.handle;

    return COM.S_OK;

}

RECT* getRect() {

    Point location = this.getLocation();

    Rectangle area = frame.getClientArea();

    RECT* rect = new RECT();

    rect.left   = location.x;

    rect.top    = location.y;

    rect.right  = location.x + area.width - borderWidths.left - borderWidths.right;

    rect.bottom = location.y + area.height - borderWidths.top - borderWidths.bottom;

    return rect;

}



private int GetWindowContext(IOleInPlaceFrame* ppFrame, IOleInPlaceUIWindow* ppDoc, LPRECT lprcPosRect, LPRECT lprcClipRect, LPOLEINPLACEFRAMEINFO lpFrameInfo) {

    if (frame is null || ppFrame is null)

        return COM.E_NOTIMPL;



    // fill in frame handle

    auto iOleInPlaceFrame = frame.getIOleInPlaceFrame();

    *ppFrame = iOleInPlaceFrame;

    frame.AddRef();



    // null out document handle

    if (ppDoc !is null) *ppDoc = null;



    // fill in position and clipping info

    RECT* rect = getRect();

    if (lprcPosRect !is null) OS.MoveMemory(lprcPosRect, rect, RECT.sizeof);

    if (lprcClipRect !is null) OS.MoveMemory(lprcClipRect, rect, RECT.sizeof);



    // get frame info

    OLEINPLACEFRAMEINFO* frameInfo = new OLEINPLACEFRAMEINFO();

    frameInfo.cb = OLEINPLACEFRAMEINFO.sizeof;

    frameInfo.fMDIApp = 0;

    frameInfo.hwndFrame = frame.handle;

    Shell shell = getShell();

    Menu menubar = shell.getMenuBar();

    if (menubar !is null && !menubar.isDisposed()) {

        auto hwnd = shell.handle;

        auto cAccel = cast(uint)/*64bit*/OS.SendMessage(hwnd, OS.WM_APP, 0, 0);

        if (cAccel !is 0) {

            auto hAccel = cast(HACCEL) OS.SendMessage(hwnd, OS.WM_APP+1, 0, 0);

            if (hAccel !is null) {

                frameInfo.cAccelEntries = cAccel;

                frameInfo.haccel = hAccel;

            }

        }

    }

    COM.MoveMemory(lpFrameInfo, frameInfo, OLEINPLACEFRAMEINFO.sizeof);



    return COM.S_OK;

}

/**

 * Returns whether ole document is dirty by checking whether the content 

 * of the file representing the document is dirty.

 * 

 * @return <code>true</code> if the document has been modified,

 *         <code>false</code> otherwise.

 * @since 3.1

 */

public bool isDirty() {

    /*

     *  Note: this method must return true unless it is absolutely clear that the

     * contents of the Ole Document do not differ from the contents in the file

     * on the file system.

     */



    // Get access to the persistent storage mechanism

    IPersistStorage permStorage;

    if (objIOleObject.QueryInterface(&COM.IIDIPersistFile, cast(void**)&permStorage) !is COM.S_OK)

        return true;

    // Are the contents of the permanent storage different from the file?

    auto result = permStorage.IsDirty();

    permStorage.Release();

    if (result is COM.S_FALSE) return false;

    return true;

}

override

public bool isFocusControl () {

    checkWidget ();

    auto focusHwnd = OS.GetFocus();

    if (objIOleInPlaceObject is null) return (handle is focusHwnd);

    HWND phwnd;

    objIOleInPlaceObject.GetWindow(&phwnd);

    while (focusHwnd !is null) {

        if (phwnd is focusHwnd) return true;

        focusHwnd = OS.GetParent(focusHwnd);

    }

    return false;

}

private int OnClose() {

    return COM.S_OK;

}

private int OnDataChange(int pFormatetc, int pStgmed) {

    return COM.S_OK;

}

private void onDispose(Event e) {

    inDispose = true;

    if (state !is STATE_NONE)

        doVerb(OLE.OLEIVERB_DISCARDUNDOSTATE);

    deactivateInPlaceClient();

    releaseObjectInterfaces(); // Note, must release object interfaces before releasing frame

    deleteTempStorage();



    // remove listeners

    removeListener(SWT.Dispose, listener);

    removeListener(SWT.FocusIn, listener);

    removeListener(SWT.Paint, listener);

    removeListener(SWT.Traverse, listener);

    removeListener(SWT.KeyDown, listener);

    frame.removeListener(SWT.Resize, listener);

    frame.removeListener(SWT.Move, listener);



    frame.Release();

    frame = null;

}

void onFocusIn(Event e) {

    if (inDispose) return;

    if (state !is STATE_UIACTIVE) doVerb(OLE.OLEIVERB_SHOW);

    if (objIOleInPlaceObject is null) return;

    if (isFocusControl()) return;

    HWND phwnd;

    objIOleInPlaceObject.GetWindow(&phwnd);

    if (phwnd is null) return;

    OS.SetFocus(phwnd);

}

void onFocusOut(Event e) {

}

private int OnInPlaceActivate() {

    state = STATE_INPLACEACTIVE;

    frame.setCurrentDocument(this);

    if (objIOleObject is null)

        return COM.S_OK;

    int[] ppvObject = new int[1];

    if (objIOleObject.QueryInterface(&COM.IIDIOleInPlaceObject, cast(void**)&objIOleInPlaceObject) is COM.S_OK) {

        //objIOleInPlaceObject = new IOleInPlaceObject(ppvObject[0]);

    }

    return COM.S_OK;

}

private int OnInPlaceDeactivate() {

    if (objIOleInPlaceObject !is null) objIOleInPlaceObject.Release();

    objIOleInPlaceObject = null;

    state = STATE_RUNNING;

    redraw();

    Shell shell = getShell();

    if (isFocusControl() || frame.isFocusControl()) {

        shell.traverse(SWT.TRAVERSE_TAB_NEXT);

    }

    return COM.S_OK;

}

private int OnPosRectChange(LPRECT lprcPosRect) {

    Point size = getSize();

    setExtent(size.x, size.y);

    return COM.S_OK;

}

private void onPaint(Event e) {

    if (state is STATE_RUNNING || state is STATE_INPLACEACTIVE) {

        SIZE* size = getExtent();

        Rectangle area = getClientArea();

        RECT* rect = new RECT();

        if (getProgramID().startsWith("Excel.Sheet")) { //$NON-NLS-1$

            rect.left = area.x; rect.right = area.x + (area.height * size.cx / size.cy);

            rect.top = area.y; rect.bottom = area.y + area.height;

        } else {

            rect.left = area.x; rect.right = area.x + size.cx;

            rect.top = area.y; rect.bottom = area.y + size.cy;

        }



        auto pArea = cast(RECT*)OS.GlobalAlloc(COM.GMEM_FIXED | COM.GMEM_ZEROINIT, RECT.sizeof);

        OS.MoveMemory(pArea, rect, RECT.sizeof);

        COM.OleDraw(objIUnknown, aspect, e.gc.handle, pArea);

        OS.GlobalFree(pArea);

    }

}

private void onResize(Event e) {

    Rectangle area = frame.getClientArea();

    setBounds(borderWidths.left,

              borderWidths.top,

              area.width - borderWidths.left - borderWidths.right,

              area.height - borderWidths.top - borderWidths.bottom);



    setObjectRects();

}

private void OnSave() {

}

private int OnShowWindow(int fShow) {

    return COM.S_OK;

}

private int OnUIActivate() {

    if (objIOleInPlaceObject is null) return COM.E_FAIL;

    state = STATE_UIACTIVE;

    HWND phwnd;

    if (objIOleInPlaceObject.GetWindow(&phwnd) is COM.S_OK) {

        OS.SetWindowPos(phwnd, cast(HWND)OS.HWND_TOP, 0, 0, 0, 0, OS.SWP_NOSIZE | OS.SWP_NOMOVE);

    }

    return COM.S_OK;

}

private int OnUIDeactivate(int fUndoable) {

    // currently, we are ignoring the fUndoable flag

    if (frame is null || frame.isDisposed()) return COM.S_OK;

    state = STATE_INPLACEACTIVE;

    frame.SetActiveObject(null, null);

    redraw();

    Shell shell = getShell();

    if (isFocusControl() || frame.isFocusControl()) {

        shell.traverse(SWT.TRAVERSE_TAB_NEXT);

    }

    Menu menubar = shell.getMenuBar();

    if (menubar is null || menubar.isDisposed())

        return COM.S_OK;



    auto shellHandle = shell.handle;

    OS.SetMenu(shellHandle, menubar.handle);

    return COM.OleSetMenuDescriptor(null, shellHandle, null, null, null);

}

private void onTraverse(Event event) {

    switch (event.detail) {

        case SWT.TRAVERSE_ESCAPE:

        case SWT.TRAVERSE_RETURN:

        case SWT.TRAVERSE_TAB_NEXT:

        case SWT.TRAVERSE_TAB_PREVIOUS:

        case SWT.TRAVERSE_PAGE_NEXT:

        case SWT.TRAVERSE_PAGE_PREVIOUS:

        case SWT.TRAVERSE_MNEMONIC:

            event.doit = true;

            break;

        default:

    }

}

private int OnViewChange(int dwAspect, int lindex) {

    return COM.S_OK;

}

protected HRESULT QueryInterface(REFCIID riid, void ** ppvObject) {



    if (riid is null || ppvObject is null)

        return COM.E_NOINTERFACE;

    GUID oGuid = *riid;

    GUID* guid = &oGuid;

    //COM.MoveMemory(guid, riid, GUID.sizeof);



    if (COM.IsEqualGUID(guid, &COM.IIDIUnknown)) {

        *ppvObject = cast(void*)cast(IUnknown)iUnknown;

        AddRef();

        return COM.S_OK;

    }

    if (COM.IsEqualGUID(guid, &COM.IIDIAdviseSink)) {

        *ppvObject = cast(void*)cast(IAdviseSink)iAdviseSink;

        AddRef();

        return COM.S_OK;

    }

    if (COM.IsEqualGUID(guid, &COM.IIDIOleClientSite)) {

        *ppvObject = cast(void*)cast(IOleClientSite)iOleClientSite;

        AddRef();

        return COM.S_OK;

    }

    if (COM.IsEqualGUID(guid, &COM.IIDIOleInPlaceSite)) {

        *ppvObject = cast(void*)cast(IOleInPlaceSite)iOleInPlaceSite;

        AddRef();

        return COM.S_OK;

    }

    if (COM.IsEqualGUID(guid, &COM.IIDIOleDocumentSite )) {

        String progID = getProgramID();

        if (!progID.startsWith("PowerPoint")) { //$NON-NLS-1$

            *ppvObject = cast(void*)cast(IOleDocumentSite)iOleDocumentSite;

            AddRef();

            return COM.S_OK;

        }

    }

    *ppvObject = null;

    return COM.E_NOINTERFACE;

}

/**

 * Returns the status of the specified command.  The status is any bitwise OR'd combination of

 * SWTOLE.OLECMDF_SUPPORTED, SWTOLE.OLECMDF_ENABLED, SWTOLE.OLECMDF_LATCHED, SWTOLE.OLECMDF_NINCHED.

 * You can query the status of a command before invoking it with OleClientSite.exec.  The

 * OLE Document or ActiveX Control must support the IOleCommandTarget to make use of this method.

 *

 * @param cmd the ID of a command; these are the OLE.OLECMDID_ values - a small set of common

 *            commands

 *

 * @return the status of the specified command or 0 if unable to query the OLE Object; these are the

 *            OLE.OLECMDF_ values

 */

public int queryStatus(int cmd) {



    if (objIOleCommandTarget is null) {

        if (objIUnknown.QueryInterface(&COM.IIDIOleCommandTarget, cast(void**)&objIOleCommandTarget) !is COM.S_OK)

            return 0;

    }



    OLECMD* olecmd = new OLECMD();

    olecmd.cmdID = cmd;



    auto result = objIOleCommandTarget.QueryStatus(null, 1, olecmd, null);



    if (result !is COM.S_OK) return 0;



    return olecmd.cmdf;

}

protected int Release() {

    refCount--;



    if (refCount is 0) {

        disposeCOMInterfaces();

    }

    return refCount;

}

protected void releaseObjectInterfaces() {



    if (objIOleInPlaceObject !is null)

        objIOleInPlaceObject.Release();

    objIOleInPlaceObject = null;



    if (objIOleObject !is null) {

        objIOleObject.Close(COM.OLECLOSE_NOSAVE);

        objIOleObject.Release();

    }

    objIOleObject = null;



    if (objDocumentView !is null){

        objDocumentView.Release();

    }

    objDocumentView = null;



    if (objIViewObject2 !is null) {

        objIViewObject2.SetAdvise(aspect, 0, null);

        objIViewObject2.Release();

    }

    objIViewObject2 = null;



    if (objIOleCommandTarget !is null)

        objIOleCommandTarget.Release();

    objIOleCommandTarget = null;



    if (objIUnknown !is null){

        objIUnknown.Release();

    }

    objIUnknown = null;



    COM.CoFreeUnusedLibraries();

}

/**

 * Saves the document to the specified file and includes OLE specific information if specified.  

 * This method must <b>only</b> be used for files that have an OLE Storage format.  For example, 

 * a word file edited with Word.Document should be saved using this method because there is 

 * formating information that should be stored in the OLE specific Storage format.

 *

 * @param file the file to which the changes are to be saved

 * @param includeOleInfo the flag to indicate whether OLE specific information should be saved.

 *

 * @return true if the save was successful

 */

public bool save(File file, bool includeOleInfo) {

    if (includeOleInfo)

        return saveToStorageFile(file);

    return saveToTraditionalFile(file);

}

private bool saveFromContents(IStream address, File file) {



    bool success = false;



    IStream tempContents = address;

    tempContents.AddRef();



    try {

        FileOutputStream writer = new FileOutputStream(file);



        int increment = 1024 * 4;

        LPVOID pv = COM.CoTaskMemAlloc(increment);

        uint pcbWritten;

        while (tempContents.Read(pv, increment, &pcbWritten) is COM.S_OK && pcbWritten > 0) {

            byte[] buffer = new byte[ pcbWritten];

            OS.MoveMemory(buffer.ptr, pv, pcbWritten);

            writer.write(buffer); // Note: if file does not exist, this will create the file the

                                  // first time it is called

            success = true;

        }

        COM.CoTaskMemFree(pv);



        writer.close();



    } catch (IOException err) {

    }



    tempContents.Release();



    return success;

}

private bool saveFromOle10Native(IStream address, File file) {



    bool success = false;



    IStream tempContents = address;

    tempContents.AddRef();



    // The "\1Ole10Native" stream contains a DWORD header whose value is the length

    // of the native data that follows.

    LPVOID pv = COM.CoTaskMemAlloc(4);

    uint size;

    auto rc = tempContents.Read(pv, 4, null);

    OS.MoveMemory(&size, pv, 4);

    COM.CoTaskMemFree(pv);

    if (rc is COM.S_OK && size > 0) {



        // Read the data

        byte[] buffer = new byte[size];

        pv = COM.CoTaskMemAlloc(size);

        rc = tempContents.Read(pv, size, null);

        OS.MoveMemory(buffer.ptr, pv, size);

        COM.CoTaskMemFree(pv);



        // open the file and write data into it

        try {

            FileOutputStream writer = new FileOutputStream(file);

            writer.write(buffer); // Note: if file does not exist, this will create the file

            writer.close();



            success = true;

        } catch (IOException err) {

        }

    }

    tempContents.Release();



    return success;

}

private int SaveObject() {



    updateStorage();



    return COM.S_OK;

}

/**

 * Saves the document to the specified file and includes OLE specific information.  This method

 * must <b>only</b> be used for files that have an OLE Storage format.  For example, a word file

 * edited with Word.Document should be saved using this method because there is formating information

 * that should be stored in the OLE specific Storage format.

 *

 * @param file the file to which the changes are to be saved

 *

 * @return true if the save was successful

 */

private bool saveToStorageFile(File file) {

    // The file will be saved using the formating of the current application - this

    // may not be the format of the application that was originally used to create the file

    // e.g. if an Excel file is opened in Word, the Word application will save the file in the

    // Word format

    // Note: if the file already exists, some applications will not overwrite the file

    // In these cases, you should delete the file first (probably save the contents of the file in case the

    // save fails)

    if (file is null || file.isDirectory()) return false;

    if (!updateStorage()) return false;



    // get access to the persistent storage mechanism

    IPersistStorage permStorage;

    if (objIOleObject.QueryInterface(&COM.IIDIPersistStorage, cast(void**)&permStorage) !is COM.S_OK) return false;

    try {

        IStorage storage;

        LPCTSTR path = StrToWCHARz(file.getAbsolutePath());

        int mode = COM.STGM_TRANSACTED | COM.STGM_READWRITE | COM.STGM_SHARE_EXCLUSIVE | COM.STGM_CREATE;

        int result = COM.StgCreateDocfile(path, mode, 0, &storage); //Does an AddRef if successful

        if (result !is COM.S_OK) return false;

        try {

            if (COM.OleSave(permStorage, storage, false) is COM.S_OK) {

                if (storage.Commit(COM.STGC_DEFAULT) is COM.S_OK) {

                    return true;

                }

            }

        } finally {

            storage.Release();

        }

    } finally {

        permStorage.Release();

    }

    return false;

}

/**

 * Saves the document to the specified file.  This method must be used for

 * files that do not have an OLE Storage format.  For example, a bitmap file edited with MSPaint

 * should be saved using this method because bitmap is a standard format that does not include any

 * OLE specific data.

 *

 * @param file the file to which the changes are to be saved

 *

 * @return true if the save was successful

 */

private bool saveToTraditionalFile(File file) {

    // Note: if the file already exists, some applications will not overwrite the file

    // In these cases, you should delete the file first (probably save the contents of the file in case the

    // save fails)

    if (file is null || file.isDirectory())

        return false;

    if (!updateStorage())

        return false;



    IStream stream;

    // Look for a CONTENTS stream

    if (tempStorage.OpenStream(("CONTENTS"w).ptr, null, COM.STGM_DIRECT | COM.STGM_READ | COM.STGM_SHARE_EXCLUSIVE, 0, &stream) is COM.S_OK) //$NON-NLS-1$

        return saveFromContents(stream, file);



    // Look for Ole 1.0 object stream

    if (tempStorage.OpenStream(("\1Ole10Native"w).ptr, null, COM.STGM_DIRECT | COM.STGM_READ | COM.STGM_SHARE_EXCLUSIVE, 0, &stream) is COM.S_OK) //$NON-NLS-1$

        return saveFromOle10Native(stream, file);



    return false;

}

private int Scroll(int scrollExtant) {

    return COM.S_OK;

}

void setBorderSpace(RECT* newBorderwidth) {

    borderWidths = *newBorderwidth;

    // readjust size and location of client site

    Rectangle area = frame.getClientArea();

    setBounds(borderWidths.left, borderWidths.top,

                area.width - borderWidths.left - borderWidths.right,

                area.height - borderWidths.top - borderWidths.bottom);

    setObjectRects();

}

private void setExtent(int width, int height){

    // Resize the width and height of the embedded/linked OLENatives object

    // to the specified values.



    if (objIOleObject is null || isStatic || inUpdate) return;

    SIZE* currentExtent = getExtent();

    if (width is currentExtent.cx && height is currentExtent.cy) return;



    SIZE* newExtent = new SIZE();

    newExtent.cx = width; newExtent.cy = height;

    newExtent = xFormPixelsToHimetric(newExtent);



   // Get the server running first, then do a SetExtent, then show it

    bool alreadyRunning = cast(bool) COM.OleIsRunning(objIOleObject);

    if (!alreadyRunning)

        COM.OleRun(objIOleObject);



    if (objIOleObject.SetExtent(aspect, newExtent) is COM.S_OK){

        inUpdate = true;

        objIOleObject.Update();

        inUpdate = false;

        if (!alreadyRunning)

            // Close server if it wasn't already running upon entering this method.

            objIOleObject.Close(COM.OLECLOSE_SAVEIFDIRTY);

    }

}

/**

 * The indent value is no longer being used by the client site.

 * 

 * @param newIndent the rectangle representing the indent amount

 */

public void setIndent(Rectangle newIndent) {

    indent.left = newIndent.x;

    indent.right = newIndent.width;

    indent.top = newIndent.y;

    indent.bottom = newIndent.height;

}

private void setObjectRects() {

    if (objIOleInPlaceObject is null) return;

    // size the object to fill the available space

    // leave a border

    RECT* rect = getRect();

    objIOleInPlaceObject.SetObjectRects(rect, rect);

}



private int ShowObject() {

    /* Tells the container to position the object so it is visible to

     * the user. This method ensures that the container itself is

     * visible and not minimized.

     */

    return COM.S_OK;

}

/**

 * Displays a dialog with the property information for this OLE Object.  The OLE Document or

 * ActiveX Control must support the ISpecifyPropertyPages interface.

 *

 * @param title the name that will appear in the titlebar of the dialog

 */

public void showProperties(String title) {



    // Get the Property Page information from the OLE Object

    ISpecifyPropertyPages objISPP;

    if (objIUnknown.QueryInterface(&COM.IIDISpecifyPropertyPages, cast(void**)&objISPP) !is COM.S_OK) return;

    CAUUID* caGUID = new CAUUID();

    auto result = objISPP.GetPages(caGUID);

    objISPP.Release();

    if (result !is COM.S_OK) return;



    // create a frame in which to display the pages

    LPCTSTR chTitle = null;

    if (title !is null) {

        chTitle = StrToWCHARz(title);

    }

    result = COM.OleCreatePropertyFrame(frame.handle, 10, 10, chTitle, 1, &objIUnknown, caGUID.cElems, caGUID.pElems, COM.LOCALE_USER_DEFAULT, 0, null);



    // free the property page information

    COM.CoTaskMemFree(caGUID.pElems);

}

private bool updateStorage() {



    if (tempStorage is null) return false;



    IPersistStorage iPersistStorage;

    if (objIUnknown.QueryInterface(&COM.IIDIPersistStorage, cast(void**)&iPersistStorage) !is COM.S_OK) return false;



    auto result = COM.OleSave(iPersistStorage, tempStorage, true);



    if (result !is COM.S_OK){

        // OleSave will fail for static objects, so do what OleSave does.

        COM.WriteClassStg(tempStorage, objClsid);

        result = iPersistStorage.Save(tempStorage, true);

    }



    tempStorage.Commit(COM.STGC_DEFAULT);

    result = iPersistStorage.SaveCompleted(null);

    iPersistStorage.Release();



    return true;

}

private SIZE* xFormHimetricToPixels(SIZE* aSize) {

    // Return a new Size which is the pixel transformation of a

    // size in HIMETRIC units.



    auto hDC = OS.GetDC(null);

    int xppi = OS.GetDeviceCaps(hDC, 88); // logical pixels/inch in x

    int yppi = OS.GetDeviceCaps(hDC, 90); // logical pixels/inch in y

    OS.ReleaseDC(null, hDC);

    int cx = Compatibility.round(aSize.cx * xppi, 2540); // 2540 HIMETRIC units per inch

    int cy = Compatibility.round(aSize.cy * yppi, 2540);

    SIZE* size = new SIZE();

    size.cx = cx;

    size.cy = cy;

    return size;

}

private SIZE* xFormPixelsToHimetric(SIZE* aSize) {

    // Return a new size which is the HIMETRIC transformation of a

    // size in pixel units.



    auto hDC = OS.GetDC(null);

    int xppi = OS.GetDeviceCaps(hDC, 88); // logical pixels/inch in x

    int yppi = OS.GetDeviceCaps(hDC, 90); // logical pixels/inch in y

    OS.ReleaseDC(null, hDC);

    int cx = Compatibility.round(aSize.cx * 2540, xppi); // 2540 HIMETRIC units per inch

    int cy = Compatibility.round(aSize.cy * 2540, yppi);

    SIZE* size = new SIZE();

    size.cx = cx;

    size.cy = cy;

    return size;

}

}



class _IAdviseSinkImpl : IAdviseSink {



    OleClientSite   parent;

    this(OleClientSite  p) { parent = p; }

extern (Windows):

    // interface of IUnknown

    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }

    ULONG AddRef()  { return parent.AddRef(); }

    ULONG Release() { return parent.Release(); }



    // interface of IAdviseSink

    void OnDataChange(FORMATETC *pFormatetc,STGMEDIUM *pStgmed) { }

    void OnViewChange(DWORD dwAspect, LONG lindex) { }

    void OnRename(IMoniker pmk) { }

    void OnSave() { }

    void OnClose() { }

}



class _IOleClientSiteImpl : IOleClientSite {



    OleClientSite   parent;

    this(OleClientSite  p) { parent = p; }

extern (Windows):

    // interface of IUnknown

    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }

    ULONG AddRef()  { return parent.AddRef(); }

    ULONG Release() { return parent.Release(); }



    // interface of IOleClientSite

    HRESULT SaveObject() {  if(parent) parent.updateStorage(); return COM.S_OK; }

    HRESULT GetMoniker( DWORD dwAssign, DWORD dwWhichMoniker, IMoniker * ppmk ) {return COM.E_NOTIMPL; }

    HRESULT GetContainer( IOleContainer* ppContainer ) { return parent.GetContainer(ppContainer);}

    HRESULT ShowObject() {

        /* Tells the container to position the object so it is visible to

         * the user. This method ensures that the container itself is

         * visible and not minimized.

         */

        return COM.S_OK;

    }

    HRESULT OnShowWindow(BOOL fShow ) {return COM.S_OK; }

    HRESULT RequestNewObjectLayout() {return COM.E_NOTIMPL; }

}



class  _IOleDocumentSiteImpl : IOleDocumentSite {



    OleClientSite   parent;

    this(OleClientSite  p) { parent = p; }

extern (Windows):

    // interface of IUnknown

    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }

    ULONG AddRef()  { return parent.AddRef(); }

    ULONG Release() { return parent.Release(); }



    // interface of IOleDocumentSite

    HRESULT ActivateMe(IOleDocumentView pViewToActivate) { return parent.ActivateMe(pViewToActivate);}

}



class _IOleInPlaceSiteImpl : IOleInPlaceSite {

    OleClientSite   parent;

    this(OleClientSite  p) { parent = p; }

extern (Windows):

    // interface of IUnknown

    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }

    ULONG AddRef()  { return parent.AddRef(); }

    ULONG Release() { return parent.Release(); }



    // interface of IOleWindow

    HRESULT GetWindow( HWND*  phwnd ) { return parent.GetWindow(phwnd); }

    HRESULT ContextSensitiveHelp( BOOL fEnterMode ) {return COM.S_OK; }



    // interface of IOleInPlaceSite

    HRESULT CanInPlaceActivate() { return parent.CanInPlaceActivate();}

    HRESULT OnInPlaceActivate() { return parent.OnInPlaceActivate(); }

    HRESULT OnUIActivate() { return parent.OnUIActivate(); }

    HRESULT GetWindowContext( IOleInPlaceFrame * ppFrame, IOleInPlaceUIWindow * ppDoc, LPRECT lprcPosRect, LPRECT lprcClipRect, LPOLEINPLACEFRAMEINFO lpFrameInfo ) {

        return parent.GetWindowContext(ppFrame, ppDoc, lprcPosRect, lprcClipRect, lpFrameInfo);

    }

    HRESULT Scroll( SIZE scrollExtant ) {return COM.S_OK; }

    HRESULT OnUIDeactivate( BOOL fUndoable ) { return parent.OnUIDeactivate(fUndoable);}

    HRESULT OnInPlaceDeactivate() { return parent.OnInPlaceDeactivate();}

    HRESULT DiscardUndoState() {return COM.E_NOTIMPL; }

    HRESULT DeactivateAndUndo() {return COM.E_NOTIMPL; }

    HRESULT OnPosRectChange( LPCRECT lprcPosRect) { return parent.OnPosRectChange(lprcPosRect);}

}



class _IUnknownImpl : IUnknown

{



    OleClientSite   parent;

    this(OleClientSite  p) { parent = p; }

extern (Windows):

    // interface of IUnknown

    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }

    ULONG AddRef()  { return parent.AddRef(); }

    ULONG Release() { return parent.Release(); }

}









