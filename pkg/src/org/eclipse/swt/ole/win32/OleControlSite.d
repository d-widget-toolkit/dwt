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
module org.eclipse.swt.ole.win32.OleControlSite;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.FontData;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.COMTYPES;
import org.eclipse.swt.internal.ole.win32.extras;
import org.eclipse.swt.internal.ole.win32.ifs;
import org.eclipse.swt.internal.ole.win32.OAIDL;
import org.eclipse.swt.internal.ole.win32.OBJIDL;
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;

import org.eclipse.swt.ole.win32.OleClientSite;
import org.eclipse.swt.ole.win32.OleEventSink;
import org.eclipse.swt.ole.win32.OlePropertyChangeSink;
import org.eclipse.swt.ole.win32.OleListener;
import org.eclipse.swt.ole.win32.OleAutomation;
import org.eclipse.swt.ole.win32.Variant;
import org.eclipse.swt.ole.win32.OLE;

import java.lang.all;

/**
 * OleControlSite provides a site to manage an embedded ActiveX Control within a container.
 *
 * <p>In addition to the behaviour provided by OleClientSite, this object provides the following:
 * <ul>
 *  <li>events from the ActiveX control
 *  <li>notification of property changes from the ActiveX control
 *  <li>simplified access to well known properties of the ActiveX Control (e.g. font, background color)
 *  <li>expose ambient properties of the container to the ActiveX Control
 * </ul>
 *
 * <p>This object implements the OLE Interfaces IOleControlSite, IDispatch, and IPropertyNotifySink.
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
public class OleControlSite : OleClientSite
{
    // interfaces for this container
    private _IOleControlSiteImpl iOleControlSite;
    private _IDispatchImpl       iDispatch;

    // supporting Property Change attributes
    private OlePropertyChangeSink olePropertyChangeSink;

    // supporting Event Sink attributes
    private OleEventSink[] oleEventSink;
    private GUID*[] oleEventSinkGUID;
    private IUnknown[] oleEventSinkIUnknown;

    // supporting information for the Control COM object
    private CONTROLINFO* currentControlInfo;
    private int[] sitePropertyIds;
    private Variant[] sitePropertyValues;

    // work around for IE destroying the caret
    static int SWT_RESTORECARET;

    alias OleClientSite.AddRef AddRef;

/**
 * Create an OleControlSite child widget using style bits
 * to select a particular look or set of properties.
 *
 * @param parent a composite widget; must be an OleFrame
 * @param style the bitwise OR'ing of widget styles
 * @param progId the unique program identifier which has been registered for this ActiveX Control;
 *               the value of the ProgID key or the value of the VersionIndependentProgID key specified
 *               in the registry for this Control (for example, the VersionIndependentProgID for
 *               Internet Explorer is Shell.Explorer)
 *
 * @exception IllegalArgumentException <ul>
 *     <li>ERROR_NULL_ARGUMENT when the parent is null
 *</ul>
 * @exception SWTException <ul>
 *     <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread
 *     <li>ERROR_INVALID_CLASSID when the progId does not map to a registered CLSID
 *     <li>ERROR_CANNOT_CREATE_OBJECT when failed to create OLE Object
 *     <li>ERROR_CANNOT_ACCESS_CLASSFACTORY when Class Factory could not be found
 *     <li>ERROR_CANNOT_CREATE_LICENSED_OBJECT when failed to create a licensed OLE Object
 * </ul>
 */
public this(Composite parent, int style, String progId) {
    super(parent, style);
    try {

        // check for licensing
        appClsid = getClassID(progId);
        if (appClsid is null) OLE.error(__FILE__, __LINE__, OLE.ERROR_INVALID_CLASSID);

        BSTR licinfo = getLicenseInfo(appClsid);
        if (licinfo is null) {

            // Open a storage object
            tempStorage = createTempStorage();

            // Create ole object with storage object
            HRESULT result = COM.OleCreate(appClsid, &COM.IIDIUnknown, COM.OLERENDER_DRAW, null, null, tempStorage, cast(void**)&objIUnknown);
            if (result !is COM.S_OK)
                OLE.error(__FILE__, __LINE__, OLE.ERROR_CANNOT_CREATE_OBJECT, result);

        } else {
            // Prepare the ClassFactory
            try {
                IClassFactory2 classFactory;
                HRESULT result = COM.CoGetClassObject(appClsid, COM.CLSCTX_INPROC_HANDLER | COM.CLSCTX_INPROC_SERVER, null, &COM.IIDIClassFactory2, cast(void**)&classFactory);
                if (result !is COM.S_OK) {
                    OLE.error(__FILE__, __LINE__, OLE.ERROR_CANNOT_ACCESS_CLASSFACTORY, result);
                }
                // Create Com Object
                result = classFactory.CreateInstanceLic(null, null, &COM.IIDIUnknown, licinfo, cast(void**)&objIUnknown);
                classFactory.Release();
                if (result !is COM.S_OK)
                    OLE.error(__FILE__, __LINE__, OLE.ERROR_CANNOT_CREATE_LICENSED_OBJECT, result);
            } finally {
                COM.SysFreeString(licinfo);
            }

            // Prepare a storage medium
            IPersistStorage persist;
            if (objIUnknown.QueryInterface(&COM.IIDIPersistStorage, cast(void**)&persist) is COM.S_OK) {
                tempStorage = createTempStorage();
                persist.InitNew(tempStorage);
                persist.Release();
            }
        }

        // Init sinks
        addObjectReferences();

        // Init site properties
        setSiteProperty(COM.DISPID_AMBIENT_USERMODE, new Variant(true));
        setSiteProperty(COM.DISPID_AMBIENT_UIDEAD, new Variant(false));

        if (COM.OleRun(objIUnknown) is OLE.S_OK) state= STATE_RUNNING;

    } catch (SWTError e) {
        dispose();
        disposeCOMInterfaces();
        throw e;
    }
}
/**
 * Adds the listener to receive events.
 *
 * @param eventID the id of the event
 *
 * @param listener the listener
 *
 * @exception IllegalArgumentException <ul>
 *      <li>ERROR_NULL_ARGUMENT when listener is null</li>
 * </ul>
 */
public void addEventListener(int eventID, OleListener listener) {
    if (listener is null) OLE.error (__FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
    GUID* riid = getDefaultEventSinkGUID(objIUnknown);
    if (riid !is null) {
        addEventListener(objIUnknown, riid, eventID, listener);
    }
}


static GUID* getDefaultEventSinkGUID(IUnknown unknown) {
    // get Event Sink I/F from IProvideClassInfo2
    IProvideClassInfo2 pci2;
    if (unknown.QueryInterface(&COM.IIDIProvideClassInfo2, cast(void**)&pci2) is COM.S_OK) {
        GUID* riid = new GUID();
        HRESULT result = pci2.GetGUID(COM.GUIDKIND_DEFAULT_SOURCE_DISP_IID, riid);
        pci2.Release();
        if (result is COM.S_OK) return riid;
    }

    // get Event Sink I/F from IProvideClassInfo
    IProvideClassInfo pci;
    if (unknown.QueryInterface(&COM.IIDIProvideClassInfo, cast(void**)&pci) is COM.S_OK) {
        ITypeInfo classInfo;
        ITypeInfo eventInfo;
        HRESULT result = pci.GetClassInfo(&classInfo);
        pci.Release();

        if (result is COM.S_OK && classInfo !is null) {
            TYPEATTR* typeAttribute;
            result = classInfo.GetTypeAttr(&typeAttribute);
            if (result is COM.S_OK  && typeAttribute !is null) {
                int implMask = COM.IMPLTYPEFLAG_FDEFAULT | COM.IMPLTYPEFLAG_FSOURCE | COM.IMPLTYPEFLAG_FRESTRICTED;
                int implBits = COM.IMPLTYPEFLAG_FDEFAULT | COM.IMPLTYPEFLAG_FSOURCE;

                for (uint i = 0; i < typeAttribute.cImplTypes; i++) {
                    int pImplTypeFlags;
                    if (classInfo.GetImplTypeFlags(i, &pImplTypeFlags) is COM.S_OK) {
                        if ((pImplTypeFlags & implMask) is implBits) {
                            uint pRefType;
                            if (classInfo.GetRefTypeOfImplType(i, &pRefType) is COM.S_OK) {
                                classInfo.GetRefTypeInfo(pRefType, &eventInfo);
                            }
                        }
                    }
                }
                classInfo.ReleaseTypeAttr(typeAttribute);
            }
            classInfo.Release();

            if (eventInfo !is null) {
                TYPEATTR* ppTypeAttr;
                result = eventInfo.GetTypeAttr(&ppTypeAttr);
                GUID* riid = null;
                if (result is COM.S_OK && ppTypeAttr !is null) {
                    riid = new GUID();
                    *riid = ppTypeAttr.guid;
                    eventInfo.ReleaseTypeAttr(ppTypeAttr);
                }
                eventInfo.Release();
                return riid;
            }
        }
    }
    return null;
}

/**
 * Adds the listener to receive events.
 *
 * @since 2.0
 *
 * @param automation the automation object that provides the event notification
 * @param eventID the id of the event
 * @param listener the listener
 *
 * @exception IllegalArgumentException <ul>
 *     <li>ERROR_NULL_ARGUMENT when listener is null</li>
 * </ul>
 */
public void addEventListener(OleAutomation automation, int eventID, OleListener listener) {
    if (listener is null || automation is null) OLE.error (__FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
    IUnknown unknown = automation.getAddress();
    GUID* riid = getDefaultEventSinkGUID(unknown);
    if (riid !is null) {
        addEventListener(unknown, riid, eventID, listener);
    }

}
/**
 * Adds the listener to receive events.
 *
 * @since 3.2
 *
 * @param automation the automation object that provides the event notification
 * @param eventSinkId the GUID of the event sink
 * @param eventID the id of the event
 * @param listener the listener
 *
 * @exception IllegalArgumentException <ul>
 *     <li>ERROR_NULL_ARGUMENT when listener is null</li>
 * </ul>
 */
public void addEventListener(OleAutomation automation, String eventSinkId, int eventID, OleListener listener) {
    if (listener is null || automation is null || eventSinkId is null) OLE.error (__FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
    auto address = automation.getAddress();
    if (address is null) return;
    String16 buffer = StrToWCHARs(0,eventSinkId,true);
    GUID* guid = new GUID();
    if (COM.IIDFromString(buffer.ptr, guid) !is COM.S_OK) return;
    addEventListener(address, guid, eventID, listener);
}

void addEventListener(IUnknown iunknown, GUID* guid, int eventID, OleListener listener) {
    if (listener is null || iunknown is null || guid is null) OLE.error (__FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
    // have we connected to this kind of event sink before?
    int index = -1;
    for (int i = 0; i < oleEventSinkGUID.length; i++) {
        if (COM.IsEqualGUID(oleEventSinkGUID[i], guid)) {
            if (iunknown is oleEventSinkIUnknown[i]) {
                index = i;
                break;
            }
        }
    }
    if (index !is -1) {
        oleEventSink[index].addListener(eventID, listener);
    } else {
        int oldLength = cast(int)/*64bit*/oleEventSink.length;

        oleEventSink ~= new OleEventSink(this, iunknown, guid);
        oleEventSinkGUID ~= guid;
        oleEventSinkIUnknown ~= iunknown;

        oleEventSink[oldLength].AddRef();
        oleEventSink[oldLength].connect();
        oleEventSink[oldLength].addListener(eventID, listener);

    }
}
override
protected void addObjectReferences() {

    super.addObjectReferences();

    // Get property change notification from control
    connectPropertyChangeSink();

    // Get access to the Control object
    IOleControl objIOleControl;
    if (objIUnknown.QueryInterface(&COM.IIDIOleControl, cast(void**)&objIOleControl) is COM.S_OK) {
        // ask the control for its info in case users
        // need to act on it
        currentControlInfo = new CONTROLINFO();
        objIOleControl.GetControlInfo(currentControlInfo);
        objIOleControl.Release();
    }
}
/**
 * Adds the listener to receive events.
 *
 * @param propertyID the identifier of the property
 * @param listener the listener
 *
 * @exception IllegalArgumentException <ul>
 *      <li>ERROR_NULL_ARGUMENT when listener is null</li>
 * </ul>
 */
public void addPropertyListener(int propertyID, OleListener listener) {
    if (listener is null) SWT.error (__FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
    olePropertyChangeSink.addListener(propertyID, listener);
}

private void connectPropertyChangeSink() {
    olePropertyChangeSink = new OlePropertyChangeSink(this);
    olePropertyChangeSink.AddRef();
    olePropertyChangeSink.connect(objIUnknown);
}
override
protected void createCOMInterfaces () {
    super.createCOMInterfaces();
    iOleControlSite = new _IOleControlSiteImpl(this);
    iDispatch = new _IDispatchImpl(this);
}
private void disconnectEventSinks() {

    for (int i = 0; i < oleEventSink.length; i++) {
        OleEventSink sink = oleEventSink[i];
        sink.disconnect();
        sink.Release();
    }
    oleEventSink = null;
    oleEventSinkGUID = null;
    oleEventSinkIUnknown = null;
}
private void disconnectPropertyChangeSink() {

    if (olePropertyChangeSink !is null) {
        olePropertyChangeSink.disconnect(objIUnknown);
        olePropertyChangeSink.Release();
    }
    olePropertyChangeSink = null;
}
override
protected void disposeCOMInterfaces() {
    super.disposeCOMInterfaces();
    iOleControlSite = null;
    iDispatch = null;
}
override
public Color getBackground () {

    if (objIUnknown !is null) {
        // !! We are getting the OLE_COLOR - should we change this to the COLORREF value?
        OleAutomation oleObject= new OleAutomation(this);
        Variant varBackColor = oleObject.getProperty(COM.DISPID_BACKCOLOR);
        oleObject.dispose();

        if (varBackColor !is null){
            COLORREF colorRef;
            if (COM.OleTranslateColor(varBackColor.getInt(), getDisplay().hPalette, &colorRef) is COM.S_OK)
                return Color.win32_new(getDisplay(), colorRef);
        }
    }

    return super.getBackground();
}
override
public Font getFont () {

    if (objIUnknown !is null) {
        OleAutomation oleObject= new OleAutomation(this);
        Variant varDispFont = oleObject.getProperty(COM.DISPID_FONT);
        oleObject.dispose();

        if (varDispFont !is null){
            OleAutomation iDispFont = varDispFont.getAutomation();
            Variant lfFaceName = iDispFont.getProperty(COM.DISPID_FONT_NAME);
            Variant lfHeight   = iDispFont.getProperty(COM.DISPID_FONT_SIZE);
            Variant lfItalic   = iDispFont.getProperty(COM.DISPID_FONT_ITALIC);
            //Variant lfCharSet  = iDispFont.getProperty(COM.DISPID_FONT_CHARSET);
            Variant lfBold     = iDispFont.getProperty(COM.DISPID_FONT_BOLD);
            iDispFont.dispose();

            if (lfFaceName !is null &&
                lfHeight !is null &&
                lfItalic !is null &&
                lfBold !is null){
                int style = 3 * lfBold.getInt() + 2 * lfItalic.getInt();
                Device dev = getShell().getDisplay();
                Font font = new Font(dev, lfFaceName.getString(), lfHeight.getInt(), style);
                return font;
            }
        }
    }

    return super.getFont();
}
override
public Color getForeground () {

    if (objIUnknown !is null) {
        // !! We are getting the OLE_COLOR - should we change this to the COLORREF value?
        OleAutomation oleObject= new OleAutomation(this);
        Variant varForeColor = oleObject.getProperty(COM.DISPID_FORECOLOR);
        oleObject.dispose();

        if (varForeColor !is null){
            COLORREF colorRef;
            if (COM.OleTranslateColor(varForeColor.getInt(), getDisplay().hPalette, &colorRef) is COM.S_OK)
                return Color.win32_new(getDisplay(), colorRef);
        }
    }

    return super.getForeground();
}
protected BSTR getLicenseInfo(GUID* clsid) {
    IClassFactory2 classFactory;
    if (COM.CoGetClassObject(clsid, COM.CLSCTX_INPROC_HANDLER | COM.CLSCTX_INPROC_SERVER, null, &COM.IIDIClassFactory2, cast(void**)&classFactory) !is COM.S_OK) {
        return null;
    }
    LICINFO licinfo;
    if (classFactory.GetLicInfo(&licinfo) !is COM.S_OK) {
        classFactory.Release();
        return null;
    }
    BSTR pBstrKey;
    if (licinfo.fRuntimeKeyAvail) {
        if (classFactory.RequestLicKey(0, &pBstrKey) is COM.S_OK) {
            classFactory.Release();
            return pBstrKey;
        }
    }
    classFactory.Release();
    return null;
}
/**
 *
 * Get the control site property specified by the dispIdMember, or
 * <code>null</code> if the dispId is not recognised.
 *
 * @param dispId the dispId
 *
 * @return the property value or <code>null</code>
 * 
 * @since 2.1
 */
public Variant getSiteProperty(int dispId){
    for (int i = 0; i < sitePropertyIds.length; i++) {
        if (sitePropertyIds[i] is dispId) {
            return sitePropertyValues[i];
        }
    }
    return null;
}
override
protected HRESULT GetWindow(HWND* phwnd) {

    if (phwnd is null)
        return COM.E_INVALIDARG;
    if (frame is null) {
        *phwnd = null;
        return COM.E_NOTIMPL;
    }

    // Copy the Window's handle into the memory passed in
    *phwnd = handle;
    return COM.S_OK;
}

private HRESULT Invoke(DISPID dispIdMember,REFIID riid,LCID lcid,WORD dwFlags, DISPPARAMS* pDispParams, VARIANT* pVarResult,EXCEPINFO* pExcepInfo,UINT* pArgErr) {
    int nullv = 0;
    if (pVarResult is null || dwFlags !is COM.DISPATCH_PROPERTYGET) {
        if (pExcepInfo !is null) COM.MoveMemory(pExcepInfo, &nullv, 4);
        if (pArgErr !is null) COM.MoveMemory(pArgErr, &nullv, 4);
        return COM.DISP_E_MEMBERNOTFOUND;
    }
    Variant result = getSiteProperty(dispIdMember);
    if (result !is null) {
        if (pVarResult !is null) result.getData(pVarResult);
        return COM.S_OK;
    }
    switch (dispIdMember) {
            // indicate a false result
        case COM.DISPID_AMBIENT_SUPPORTSMNEMONICS :
        case COM.DISPID_AMBIENT_SHOWGRABHANDLES :
        case COM.DISPID_AMBIENT_SHOWHATCHING :
            if (pVarResult !is null) COM.MoveMemory(pVarResult, &nullv, 4);
            if (pExcepInfo !is null) COM.MoveMemory(pExcepInfo, &nullv, 4);
            if (pArgErr !is null) COM.MoveMemory(pArgErr, &nullv, 4);
            return COM.S_FALSE;

            // not implemented
        case COM.DISPID_AMBIENT_OFFLINEIFNOTCONNECTED :
        case COM.DISPID_AMBIENT_BACKCOLOR :
        case COM.DISPID_AMBIENT_FORECOLOR :
        case COM.DISPID_AMBIENT_FONT :
        case COM.DISPID_AMBIENT_LOCALEID :
        case COM.DISPID_AMBIENT_SILENT :
        case COM.DISPID_AMBIENT_MESSAGEREFLECT :
            if (pVarResult !is null) COM.MoveMemory(pVarResult, &nullv, 4);
            if (pExcepInfo !is null) COM.MoveMemory(pExcepInfo, &nullv, 4);
            if (pArgErr !is null) COM.MoveMemory(pArgErr, &nullv, 4);
            return COM.E_NOTIMPL;

        default :
            if (pVarResult !is null) COM.MoveMemory(pVarResult, &nullv, 4);
            if (pExcepInfo !is null) COM.MoveMemory(pExcepInfo, &nullv, 4);
            if (pArgErr !is null) COM.MoveMemory(pArgErr, &nullv, 4);
            return COM.DISP_E_MEMBERNOTFOUND;
    }
}
private int OnControlInfoChanged() {
    IOleControl objIOleControl;
    if (objIUnknown.QueryInterface(&COM.IIDIOleControl, cast(void**)&objIOleControl ) is COM.S_OK) {
        // ask the control for its info in case users
        // need to act on it
        currentControlInfo = new CONTROLINFO();
        objIOleControl.GetControlInfo(currentControlInfo);
        objIOleControl.Release();
    }
    return COM.S_OK;
}
override
void onFocusIn(Event e) {
    if (objIOleInPlaceObject is null) return;
    doVerb(OLE.OLEIVERB_UIACTIVATE);
    if (isFocusControl()) return;
    HWND phwnd;
    objIOleInPlaceObject.GetWindow(&phwnd);
    if (phwnd is null) return;
    OS.SetFocus(phwnd);
}
override
void onFocusOut(Event e) {
    if (objIOleInPlaceObject !is null) {
        /*
        * Bug in Windows.  When IE7 loses focus and UIDeactivate()
        * is called, IE destroys the caret even though it is
        * no longer owned by IE.  If focus has moved to a control
        * that shows a caret then the caret disappears.  The fix
        * is to detect this case and restore the caret.
        */
        auto threadId = OS.GetCurrentThreadId();
        GUITHREADINFO* lpgui1 = new GUITHREADINFO();
        lpgui1.cbSize = GUITHREADINFO.sizeof;
        OS.GetGUIThreadInfo(threadId, lpgui1);
        objIOleInPlaceObject.UIDeactivate();
        if (lpgui1.hwndCaret !is null) {
            GUITHREADINFO* lpgui2 = new GUITHREADINFO();
            lpgui2.cbSize = GUITHREADINFO.sizeof;
            OS.GetGUIThreadInfo(threadId, lpgui2);
            if (lpgui2.hwndCaret is null && lpgui1.hwndCaret is OS.GetFocus()) {
                if (SWT_RESTORECARET is 0) {
                    SWT_RESTORECARET = OS.RegisterWindowMessage (StrToTCHARz (0, "SWT_RESTORECARET"));
                }
                /*
                * If the caret was not restored by SWT, put it back using
                * the information from GUITHREADINFO.  Note that this will
                * not be correct when the caret has a bitmap.  There is no
                * API to query the bitmap that the caret is using.
                */
                if (OS.SendMessage (lpgui1.hwndCaret, SWT_RESTORECARET, 0, 0) is 0) {
                    int width = lpgui1.rcCaret.right - lpgui1.rcCaret.left;
                    int height = lpgui1.rcCaret.bottom - lpgui1.rcCaret.top;
                    OS.CreateCaret (lpgui1.hwndCaret, null, width, height);
                    OS.SetCaretPos (lpgui1.rcCaret.left, lpgui1.rcCaret.top);
                    OS.ShowCaret (lpgui1.hwndCaret);
                }
            }
        }
    }
}
private int OnFocus(int fGotFocus) {
    return COM.S_OK;
}
protected int OnUIDeactivate(int fUndoable) {
    // controls don't need to do anything for
    // border space or menubars
    state = STATE_INPLACEACTIVE;
    return COM.S_OK;
}
override protected HRESULT QueryInterface(REFCIID riid, void ** ppvObject) {
    int nullv = 0;
    int result = super.QueryInterface(riid, ppvObject);
    if (result is COM.S_OK)
        return result;
    if (riid is null || ppvObject is null)
        return COM.E_INVALIDARG;
    GUID oGuid = *riid;
    GUID* guid = &oGuid;
    //COM.MoveMemory(&guid, riid, GUID.sizeof);
    if (COM.IsEqualGUID(guid, &COM.IIDIOleControlSite)) {
        *ppvObject = cast(void*)cast(IOleControlSite)iOleControlSite;
        AddRef();
        return COM.S_OK;
    }
    if (COM.IsEqualGUID(guid, &COM.IIDIDispatch)) {
        *ppvObject = cast(void*)cast(IDispatch)iDispatch;
        AddRef();
        return COM.S_OK;
    }
    *ppvObject = null;
    return COM.E_NOINTERFACE;
}
override
protected int Release() {
    int result = super.Release();
    if (result is 0) {
        for (int i = 0; i < sitePropertyIds.length; i++) {
            sitePropertyValues[i].dispose();
        }
        sitePropertyIds = null;
        sitePropertyValues = null;
    }
    return result;
}
override
protected void releaseObjectInterfaces() {

    disconnectEventSinks();

    disconnectPropertyChangeSink();

    super.releaseObjectInterfaces();
}
/**
 * Removes the listener.
 *
 * @param eventID the event identifier
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *      <li>ERROR_NULL_ARGUMENT when listener is null</li>
 * </ul>
 */
public void removeEventListener(int eventID, OleListener listener) {
    checkWidget();
    if (listener is null) SWT.error (__FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);

    GUID* riid = getDefaultEventSinkGUID(objIUnknown);
    if (riid !is null) {
        removeEventListener(objIUnknown, riid, eventID, listener);
    }
}
/**
 * Removes the listener.
 *
 * @since 2.0
 * @deprecated - use OleControlSite.removeEventListener(OleAutomation, int, OleListener)
 *
 * @param automation the automation object that provides the event notification
 *
 * @param guid the identifier of the events COM interface
 *
 * @param eventID the event identifier
 *
 * @param listener the listener
 *
 * @exception IllegalArgumentException <ul>
 *      <li>ERROR_NULL_ARGUMENT when listener is null</li>
 * </ul>
 */
public void removeEventListener(OleAutomation automation, GUID* guid, int eventID, OleListener listener) {
    checkWidget();
    if (automation is null || listener is null || guid is null) SWT.error ( __FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
    removeEventListener(automation.getAddress(), guid, eventID, listener);
}
/**
 * Removes the listener.
 *
 * @param automation the automation object that provides the event notification
 * @param eventID the event identifier
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *      <li>ERROR_NULL_ARGUMENT when listener is null</li>
 * </ul>
 * 
 * @since 2.0
 */
public void removeEventListener(OleAutomation automation, int eventID, OleListener listener) {
    checkWidget();
    if (automation is null || listener is null) SWT.error ( __FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
    auto unknown = automation.getAddress();
    GUID* riid = getDefaultEventSinkGUID(unknown);
    if (riid !is null) {
        removeEventListener(unknown, riid, eventID, listener);
    }
}
void removeEventListener(IUnknown iunknown, GUID* guid, int eventID, OleListener listener) {
    if (listener is null || guid is null) SWT.error ( __FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
    for (int i = 0; i < oleEventSink.length; i++) {
        if (COM.IsEqualGUID(oleEventSinkGUID[i], guid)) {
            if (iunknown is oleEventSinkIUnknown[i]) {
                oleEventSink[i].removeListener(eventID, listener);
                if (!oleEventSink[i].hasListeners()) {
                    //free resources associated with event sink
                    oleEventSink[i].disconnect();
                    oleEventSink[i].Release();
                    int oldLength = cast(int)/*64bit*/oleEventSink.length;
                    if (oldLength is 1) {
                        oleEventSink = null;
                        oleEventSinkGUID = null;
                        oleEventSinkIUnknown = null;
                    } else {
                        OleEventSink[] newOleEventSink = new OleEventSink[oldLength - 1];
                        System.arraycopy(oleEventSink, 0, newOleEventSink, 0, i);
                        System.arraycopy(oleEventSink, i + 1, newOleEventSink, i, oldLength - i - 1);
                        oleEventSink = newOleEventSink;

                        GUID*[] newOleEventSinkGUID = new GUID*[oldLength - 1];
                        SimpleType!(GUID*).arraycopy(oleEventSinkGUID, 0, newOleEventSinkGUID, 0, i);
                        SimpleType!(GUID*).arraycopy(oleEventSinkGUID, i + 1, newOleEventSinkGUID, i, oldLength - i - 1);
                        oleEventSinkGUID = newOleEventSinkGUID;

                        IUnknown[] newOleEventSinkIUnknown = new IUnknown[oldLength - 1];
                        SimpleType!(IUnknown).arraycopy(oleEventSinkIUnknown, 0, newOleEventSinkIUnknown, 0, i);
                        SimpleType!(IUnknown).arraycopy(oleEventSinkIUnknown, i + 1, newOleEventSinkIUnknown, i, oldLength - i - 1);
                        oleEventSinkIUnknown = newOleEventSinkIUnknown;
                    }
                }
                return;
            }
        }
    }
}
/**
 * Removes the listener.
 *
 * @param propertyID the identifier of the property
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *      <li>ERROR_NULL_ARGUMENT when listener is null</li>
 * </ul>
 */
public void removePropertyListener(int propertyID, OleListener listener) {
    if (listener is null) SWT.error (__FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
    olePropertyChangeSink.removeListener(propertyID, listener);
}
override
public void setBackground (Color color) {

    super.setBackground(color);

    //set the background of the ActiveX Control
    if (objIUnknown !is null) {
        OleAutomation oleObject= new OleAutomation(this);
        oleObject.setProperty(COM.DISPID_BACKCOLOR, new Variant(color.handle));
        oleObject.dispose();
    }
}
override
public void setFont (Font font) {

    super.setFont(font);

    //set the font of the ActiveX Control
    if (objIUnknown !is null) {

        OleAutomation oleObject= new OleAutomation(this);
        Variant varDispFont = oleObject.getProperty(COM.DISPID_FONT);
        oleObject.dispose();

        if (varDispFont !is null){
            OleAutomation iDispFont = varDispFont.getAutomation();
            FontData[] fdata = font.getFontData();
            iDispFont.setProperty(COM.DISPID_FONT_NAME,   new Variant(fdata[0].getName()));
            iDispFont.setProperty(COM.DISPID_FONT_SIZE,   new Variant(fdata[0].getHeight()));
            iDispFont.setProperty(COM.DISPID_FONT_ITALIC, new Variant(fdata[0].getStyle() & SWT.ITALIC));
            //iDispFont.setProperty(COM.DISPID_FONT_CHARSET, new Variant(fdata[0].getCharset));
            iDispFont.setProperty(COM.DISPID_FONT_BOLD,   new Variant((fdata[0].getStyle() & SWT.BOLD)));
            iDispFont.dispose();
        }
    }

    return;
}
override
public void setForeground (Color color) {

    super.setForeground(color);

    //set the foreground of the ActiveX Control
    if (objIUnknown !is null) {
        OleAutomation oleObject= new OleAutomation(this);
        oleObject.setProperty(COM.DISPID_FORECOLOR, new Variant(color.handle));
        oleObject.dispose();
    }
}
/**
 * Sets the control site property specified by the dispIdMember to a new value.
 * The value will be disposed by the control site when it is no longer required
 * using Variant.dispose.  Passing a value of null will clear the dispId value.
 *
 * @param dispId the ID of the property as specified by the IDL of the ActiveX Control
 * @param value The new value for the property as expressed in a Variant.
 *
 * @since 2.1
 */
public void setSiteProperty(int dispId, Variant value){
    for (int i = 0; i < sitePropertyIds.length; i++) {
        if (sitePropertyIds[i] is dispId) {
            if (sitePropertyValues[i] !is null) {
                sitePropertyValues[i].dispose();
            }
            if (value !is null) {
                sitePropertyValues[i] = value;
            } else {
                int oldLength = cast(int)/*64bit*/sitePropertyIds.length;
                int[] newSitePropertyIds = new int[oldLength - 1];
                Variant[] newSitePropertyValues = new Variant[oldLength - 1];
                System.arraycopy(sitePropertyIds, 0, newSitePropertyIds, 0, i);
                System.arraycopy(sitePropertyIds, i + 1, newSitePropertyIds, i, oldLength - i - 1);
                System.arraycopy(sitePropertyValues, 0, newSitePropertyValues, 0, i);
                System.arraycopy(sitePropertyValues, i + 1, newSitePropertyValues, i, oldLength - i - 1);
                sitePropertyIds = newSitePropertyIds;
                sitePropertyValues = newSitePropertyValues;
            }
            return;
        }
    }
    int oldLength = cast(int)/*64bit*/sitePropertyIds.length;
    int[] newSitePropertyIds = new int[oldLength + 1];
    Variant[] newSitePropertyValues = new Variant[oldLength + 1];
    System.arraycopy(sitePropertyIds, 0, newSitePropertyIds, 0, oldLength);
    System.arraycopy(sitePropertyValues, 0, newSitePropertyValues, 0, oldLength);
    newSitePropertyIds[oldLength] = dispId;
    newSitePropertyValues[oldLength] = value;
    sitePropertyIds = newSitePropertyIds;
    sitePropertyValues = newSitePropertyValues;
}
}

class _IDispatchImpl : IDispatch {

    OleControlSite  parent;
    this(OleControlSite p) { parent = p; }
extern (Windows):
    // interface of IUnknown
    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }
    ULONG AddRef()  { return parent.AddRef(); }
    ULONG Release() { return parent.Release(); }

    // interface of IDispatch : IUnknown
    HRESULT GetTypeInfoCount(UINT * pctinfo) { return COM.E_NOTIMPL; }
    HRESULT GetTypeInfo(UINT iTInfo, LCID lcid, ITypeInfo * ppTInfo) { return COM.E_NOTIMPL; }
    HRESULT GetIDsOfNames(REFCIID riid, LPCOLESTR * rgszNames, UINT cNames, LCID lcid, DISPID * rgDispId) { return COM.E_NOTIMPL; }
    // Note : <Shawn> one argument is short !!!
    HRESULT Invoke(DISPID dispIdMember,REFIID riid,LCID lcid,WORD wFlags,DISPPARAMS* pDispParams,VARIANT* pVarResult,EXCEPINFO* pExcepInfo,UINT* puArgErr) {
        return parent.Invoke(dispIdMember, riid, lcid, wFlags, pDispParams, pVarResult, pExcepInfo, puArgErr);
    }
}

class _IOleControlSiteImpl : IOleControlSite {

    OleControlSite  parent;
    this(OleControlSite p) { parent = p; }
extern (Windows):
    // interface of IUnknown
    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }
    ULONG AddRef()  { return parent.AddRef(); }
    ULONG Release() { return parent.Release(); }

    // interface IOleControlSite : IUnknown
    HRESULT OnControlInfoChanged() { return parent.OnControlInfoChanged();}
    HRESULT LockInPlaceActive(BOOL fLock) { return COM.E_NOTIMPL; }
    HRESULT GetExtendedControl(LPDISPATCH* ppDisp) { return COM.E_NOTIMPL; }
    HRESULT TransformCoords(
      POINTL* pPtlHimetric ,  //Address of POINTL structure
      POINTF* pPtfContainer ,  //Address of POINTF structure
      DWORD dwFlags           //Flags indicating the exact conversion
    ) { return COM.E_NOTIMPL; }
    HRESULT TranslateAccelerator(
      LPMSG pMsg ,        //Pointer to the structure
      DWORD grfModifiers  //Flags describing the state of the keys
    )
    { return COM.E_NOTIMPL; }
    HRESULT OnFocus(
      BOOL fGotFocus  //Indicates whether the control gained focus
    )
    { return COM.S_OK; }
    HRESULT ShowPropertyFrame() { return COM.E_NOTIMPL; }
}



