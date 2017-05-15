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
module org.eclipse.swt.dnd.OleEnumFORMATETC;

import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.OBJIDL;
import org.eclipse.swt.internal.ole.win32.extras;
import org.eclipse.swt.internal.win32.OS;

final class OleEnumFORMATETC {

    private _IEnumFORMATETCImpl iEnumFORMATETC;

    private int refCount;
    private int index;

    private FORMATETC*[] formats;

this() {

    createCOMInterfaces();

}
int AddRef() {
    refCount++;
    return refCount;
}
private void createCOMInterfaces() {
    // register each of the interfaces that this object implements
    iEnumFORMATETC = new _IEnumFORMATETCImpl( this );
}
private void disposeCOMInterfaces() {
    iEnumFORMATETC = null;
}
IEnumFORMATETC getAddress() {
    return iEnumFORMATETC;
}
private FORMATETC*[] getNextItems(int numItems){

    if (formats is null || numItems < 1) return null;

    int endIndex = index + numItems - 1;
    if (endIndex > (formats.length - 1)) endIndex = cast(int)/*64bit*/formats.length - 1;
    if (index > endIndex) return null;

    FORMATETC*[] items =  new FORMATETC*[endIndex - index + 1];
    for (int i = 0; i < items.length; i++){
        items[i] = formats[index];
        index++;
    }

    return items;
}

package HRESULT Next(ULONG celt, FORMATETC *rgelt, ULONG *pceltFetched) {
    /* Retrieves the next celt items in the enumeration sequence.
       If there are fewer than the requested number of elements left in the sequence,
       it retrieves the remaining elements.
       The number of elements actually retrieved is returned through pceltFetched
       (unless the caller passed in NULL for that parameter).
    */

    if (rgelt is null) return COM.E_INVALIDARG;
    if (pceltFetched is null && celt !is 1) return COM.E_INVALIDARG;

    FORMATETC*[] nextItems = getNextItems(celt);
    if (nextItems !is null) {
        for (int i = 0; i < nextItems.length; i++) {
            rgelt[i] = *nextItems[i];
        }

        if (pceltFetched !is null)
            *pceltFetched = cast(int)/*64bit*/nextItems.length;

        if (nextItems.length is celt) return COM.S_OK;

    } else {
        if (pceltFetched !is null)
            *pceltFetched = 0;
        FORMATETC fInit;
        COM.MoveMemory(rgelt, & fInit, FORMATETC.sizeof);

    }
    return COM.S_FALSE;
}
private HRESULT QueryInterface(REFCIID riid, void** ppvObject) {

    if (riid is null || ppvObject is null) return COM.E_NOINTERFACE;

    if (COM.IsEqualGUID(riid, &COM.IIDIUnknown)) {
        *ppvObject = cast(void*)cast(IUnknown)iEnumFORMATETC;
        AddRef();
        return COM.S_OK;
    }
    if (COM.IsEqualGUID(riid, &COM.IIDIEnumFORMATETC)) {
        *ppvObject = cast(void*)cast(IEnumFORMATETC)iEnumFORMATETC;
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
        COM.CoFreeUnusedLibraries();
    }

    return refCount;
}
private int Reset() {
    //Resets the enumeration sequence to the beginning.
    index = 0;
    return COM.S_OK;
}
void setFormats(FORMATETC*[] newFormats) {
    formats = newFormats;
    index = 0;
}
private int Skip(int celt) {
    //Skips over the next specified number of elements in the enumeration sequence.
    if (celt < 1 ) return COM.E_INVALIDARG;

    index += celt;
    if (index > (formats.length - 1)){
        index = cast(int)/*64bit*/formats.length - 1;
        return COM.S_FALSE;
    }
    return COM.S_OK;
}
}

class _IEnumFORMATETCImpl : IEnumFORMATETC {


    OleEnumFORMATETC    parent;
    this(OleEnumFORMATETC   p) { parent = p; }
extern (Windows):
    // interface of IUnknown
    HRESULT QueryInterface(REFCIID riid, void ** ppvObject) { return parent.QueryInterface(riid, ppvObject); }
    ULONG AddRef()  { return parent.AddRef(); }
    ULONG Release() { return parent.Release(); }

    // interface of IEnumFORMATETC
    HRESULT Next(ULONG celt, FORMATETC *rgelt, ULONG *pceltFetched) {
        return parent.Next(celt, rgelt, pceltFetched);
    }
    HRESULT Skip(ULONG celt) { return parent.Skip(celt); }
    HRESULT Reset() { return parent.Reset(); }
    HRESULT Clone(IEnumFORMATETC * ppenum) { return COM.E_NOTIMPL;}
}


