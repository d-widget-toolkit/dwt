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
module org.eclipse.swt.ole.win32.OlePropertyChangeSink;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.extras;
import org.eclipse.swt.internal.ole.win32.ifs;

import org.eclipse.swt.ole.win32.OleControlSite;
import org.eclipse.swt.ole.win32.OleEventTable;
import org.eclipse.swt.ole.win32.OleListener;
import org.eclipse.swt.ole.win32.OleEvent;
import org.eclipse.swt.ole.win32.OleEventTable;
import org.eclipse.swt.ole.win32.OLE;

final class OlePropertyChangeSink {

    private OleControlSite controlSite;
    //private IUnknown objIUnknown;

    //private COMObject iUnknown;
    private _IPropertyNotifySinkImpl iPropertyNotifySink;

    private int refCount;

    private int propertyCookie;

    private OleEventTable eventTable;

this(OleControlSite controlSite) {

    this.controlSite = controlSite;

    createCOMInterfaces();
}
void addListener(int propertyID, OleListener listener) {
    if (listener is null) OLE.error (__FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) eventTable = new OleEventTable ();
    eventTable.hook(propertyID, listener);
}
int AddRef() {
    refCount++;
    return refCount;
}
void connect(IUnknown objIUnknown) {

    // Set up property change notification sink
    IConnectionPointContainer cpc;
    if (objIUnknown.QueryInterface(&COM.IIDIConnectionPointContainer, cast(void**)&cpc) is COM.S_OK) {
        IConnectionPoint cp;
        if (cpc.FindConnectionPoint(&COM.IIDIPropertyNotifySink, &cp) is COM.S_OK) {
            uint cookie;
            if (cp.Advise(iPropertyNotifySink, &cookie) is COM.S_OK) {
                propertyCookie = cookie;
            }
            cp.Release();
        }
        cpc.Release();
    }
}
protected void createCOMInterfaces() {
    // register each of the interfaces that this object implements
    iPropertyNotifySink = new _IPropertyNotifySinkImpl(this);
}
void disconnect(IUnknown objIUnknown) {

    // disconnect property notification sink
    if (propertyCookie !is 0 && objIUnknown !is null) {
        IConnectionPointContainer cpc;
        if (objIUnknown.QueryInterface(&COM.IIDIConnectionPointContainer, cast(void**)&cpc) is COM.S_OK) {
            IConnectionPoint cp;
            if (cpc.FindConnectionPoint(&COM.IIDIPropertyNotifySink, &cp) is COM.S_OK) {
                if (cp.Unadvise(propertyCookie) is COM.S_OK) {
                    propertyCookie = 0;
                }
                cp.Release();
            }
            cpc.Release();
        }
    }
}
private void disposeCOMInterfaces() {
    iPropertyNotifySink = null;
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
    if (event is null) OLE.error (__FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    event.type = eventType;
    event.widget = controlSite;
    eventTable.sendEvent (event);
}
package int OnChanged(int dispID) {
    if (eventTable is null || !eventTable.hooks(dispID)) return COM.S_OK;
    OleEvent event = new OleEvent();
    event.detail = OLE.PROPERTY_CHANGED;
    notifyListener(dispID,event);
    return COM.S_OK;
}
package int OnRequestEdit(int dispID) {
    if (eventTable is null || !eventTable.hooks(dispID)) return COM.S_OK;
    OleEvent event = new OleEvent();
    event.doit = true;
    event.detail = OLE.PROPERTY_CHANGING;
    notifyListener(dispID,event);
    return (event.doit) ? COM.S_OK : COM.S_FALSE;
}
protected HRESULT QueryInterface(REFCIID riid, void ** ppvObject) {
    if (riid is null || ppvObject is null)
        return COM.E_INVALIDARG;

    if (COM.IsEqualGUID(riid, &COM.IIDIPropertyNotifySink)) {
        *ppvObject = cast(void*)cast(IPropertyNotifySink)iPropertyNotifySink;
        AddRef();
        return COM.S_OK;
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
void removeListener(int propertyID, OleListener listener) {
    if (listener is null) OLE.error (__FILE__, __LINE__, SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (propertyID, listener);
}
}


private class _IPropertyNotifySinkImpl : IPropertyNotifySink {

    OlePropertyChangeSink   parent;
    this(OlePropertyChangeSink  p) { parent = p; }
extern (Windows):
    // interface of IUnknown
    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }
    ULONG AddRef()  { return parent.AddRef(); }
    ULONG Release() { return parent.Release(); }

    // interface of IPropertyNotifySink
    int OnChanged(int dispID) { return parent.OnChanged(dispID); }
    int OnRequestEdit(int dispID) { return parent.OnRequestEdit(dispID); }
}




