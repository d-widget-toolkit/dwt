/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
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
module org.eclipse.swt.ole.win32.OleEventSink;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.extras;
import org.eclipse.swt.internal.ole.win32.OAIDL;
import org.eclipse.swt.internal.ole.win32.ifs;

import org.eclipse.swt.ole.win32.OleControlSite;
import org.eclipse.swt.ole.win32.OleEventTable;
import org.eclipse.swt.ole.win32.OleListener;
import org.eclipse.swt.ole.win32.OleEvent;
import org.eclipse.swt.ole.win32.OLE;
import org.eclipse.swt.ole.win32.Variant;

final class OleEventSink
{
    private OleControlSite widget;

    private _DispatchImpl iDispatch;
    private int refCount;

    private IUnknown objIUnknown;
    private int  eventCookie;
    private GUID* eventGuid;

    private OleEventTable eventTable;

this(OleControlSite widget, IUnknown iUnknown, GUID* riid) {

    this.widget = widget;
    this.eventGuid = riid;
    this.objIUnknown = iUnknown;

    createCOMInterfaces();
}

void connect () {
    IConnectionPointContainer cpc;
    if (objIUnknown.QueryInterface(&COM.IIDIConnectionPointContainer, cast(void**)&cpc) is COM.S_OK) {
        IConnectionPoint cp;
        if (cpc.FindConnectionPoint(eventGuid, &cp) is COM.S_OK) {
            uint pCookie;
            if (cp.Advise(iDispatch, &pCookie) is COM.S_OK)
                eventCookie = pCookie;
            cp.Release();
        }
        cpc.Release();
    }
}
void addListener(int eventID, OleListener listener) {
    if (listener is null) OLE.error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) eventTable = new OleEventTable ();
    eventTable.hook(eventID, listener);
}
int AddRef() {
    refCount++;
    return refCount;
}
private void createCOMInterfaces() {
    iDispatch = new _DispatchImpl(this);
}
void disconnect() {
    // disconnect event sink
    if (eventCookie !is 0 && objIUnknown !is null) {
        IConnectionPointContainer cpc;
        if (objIUnknown.QueryInterface(&COM.IIDIConnectionPointContainer, cast(void**)&cpc) is COM.S_OK) {
            IConnectionPoint cp;
            if (cpc.FindConnectionPoint(eventGuid, &cp) is COM.S_OK) {
                if (cp.Unadvise(eventCookie) is COM.S_OK) {
                    eventCookie = 0;
                }
                cp.Release();
            }
            cpc.Release();
        }
    }
}
private void disposeCOMInterfaces() {
    iDispatch = null;
}

private HRESULT Invoke(DISPID dispIdMember,REFIID riid,LCID lcid,WORD wFlags,DISPPARAMS* pDispParams,VARIANT* pVarResult,EXCEPINFO* pExcepInfo,UINT* puArgErr)
{
    if (eventTable is null || !eventTable.hooks(dispIdMember)) return COM.S_OK;

    // Construct an array of the parameters that are passed in
    // Note: parameters are passed in reverse order - here we will correct the order
    Variant[] eventInfo = null;
    if (pDispParams !is null) {
        DISPPARAMS* dispParams = new DISPPARAMS();
        COM.MoveMemory(dispParams, pDispParams, DISPPARAMS.sizeof);
        eventInfo = new Variant[dispParams.cArgs];
        int size = Variant.sizeof;
        int offset = (dispParams.cArgs - 1) * size;

        for (int j = 0; j < dispParams.cArgs; j++){
            eventInfo[j] = new Variant();
            eventInfo[j].setData(dispParams.rgvarg + offset);
            offset = offset - size;
        }
    }

    OleEvent event = new OleEvent();
    event.arguments = eventInfo;
    notifyListener(dispIdMember,event);
    return COM.S_OK;
}
/**
* Notify listeners of an event.
* <p>
*   This method notifies all listeners that an event
* has occurred.
*
* @param eventType the desired SWT event
* @param event the event data
*
* @exception IllegalArgumentException <ul>
*       <li>ERROR_NULL_ARGUMENT when handler is null</li>
* </ul>
* @exception SWTException <ul>
*       <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
*       <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
*   </ul>
*/
private void notifyListener (int eventType, OleEvent event) {
    if (event is null) OLE.error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    event.type = eventType;
    event.widget = widget;
    eventTable.sendEvent (event);
}

private HRESULT QueryInterface(REFCIID riid, void ** ppvObject) {

    if (riid is null || ppvObject is null)
        return COM.E_INVALIDARG;

    if ( COM.IsEqualGUID(riid, &COM.IIDIUnknown) || COM.IsEqualGUID(riid, &COM.IIDIDispatch) ||
            COM.IsEqualGUID(riid, eventGuid)) {
        *ppvObject = cast(void*)cast(IDispatch)iDispatch;
        AddRef();
        return OLE.S_OK;
    }

    *ppvObject = null;
    return COM.E_NOINTERFACE;
}
int Release() {
    refCount--;
    if (refCount is 0) {
        disposeCOMInterfaces();
    }

    return refCount;
}
void removeListener(int eventID, OleListener listener) {
    if (listener is null) OLE.error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (eventID, listener);
}
bool hasListeners() {
    return eventTable.hasEntries();
}
}

private class _DispatchImpl : IDispatch {

    OleEventSink parent;
    this(OleEventSink sink) { parent = sink;}
extern (Windows) :
    HRESULT QueryInterface(REFCIID riid, void ** ppvObject){
        return parent.QueryInterface(riid, ppvObject);
    }
    ULONG AddRef()  { return parent.AddRef(); }
    ULONG Release() { return parent.Release(); }
    HRESULT GetTypeInfoCount(UINT * pctinfo) { return COM.E_NOTIMPL; }
    HRESULT GetTypeInfo(UINT iTInfo, LCID lcid, ITypeInfo * ppTInfo) { return COM.E_NOTIMPL; }
    HRESULT GetIDsOfNames(REFCIID riid, LPCOLESTR * rgszNames, UINT cNames, LCID lcid, DISPID * rgDispId) { return COM.E_NOTIMPL; }
    HRESULT Invoke(DISPID dispIdMember,REFIID riid,LCID lcid,WORD wFlags,DISPPARAMS* pDispParams,VARIANT* pVarResult,EXCEPINFO* pExcepInfo,UINT* puArgErr){
        return parent.Invoke(dispIdMember, riid, lcid, wFlags, pDispParams, pVarResult, pExcepInfo, puArgErr);
    }
}

