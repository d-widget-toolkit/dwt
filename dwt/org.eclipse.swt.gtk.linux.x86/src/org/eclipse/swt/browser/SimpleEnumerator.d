/*******************************************************************************
 * Copyright (c) 2003, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *      John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module org.eclipse.swt.browser.SimpleEnumerator;

//import java.lang.all;

//import org.eclipse.swt.internal.C;
import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISimpleEnumerator;
import org.eclipse.swt.internal.mozilla.nsISupports;

class SimpleEnumerator : nsISimpleEnumerator{
    int refCount = 0;
    nsISupports[] values;
    int index = 0;

this (nsISupports[] values) {
    this.values = values;
    for (int i = 0; i < values.length; i++) {
        values[i].AddRef ();
    }
}

extern(System)
nsrefcnt AddRef () {
    refCount++;
    return refCount;
}

extern(System)
nsresult QueryInterface (in nsID* riid, void** ppvObject) {
    if (riid is null || ppvObject is null) return XPCOM.NS_ERROR_NO_INTERFACE;
    //nsID guid = new nsID ();
    //XPCOM.memmove (guid, riid, nsID.sizeof);

    if (*riid == nsISupports.IID) {
        *ppvObject = cast(void*)cast(nsISupports)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsISimpleEnumerator.IID) {
        *ppvObject = cast(void*)cast(nsISimpleEnumerator)this;
        AddRef ();
        return XPCOM.NS_OK;
    }

    *ppvObject = null;
    return XPCOM.NS_ERROR_NO_INTERFACE;
}

extern(System)
nsresult Release () {
    refCount--;
    //if (refCount is 0) disposeCOMInterfaces ();
    return refCount;
}

extern(System)
nsresult HasMoreElements (PRBool* _retval) {
    bool more = values !is null && index < values.length;
    *_retval = more ? 1 : 0; /*PRBool */
    return XPCOM.NS_OK;
}

extern(System)
nsresult GetNext (nsISupports* _retval) {
    if (values is null || index is values.length) return XPCOM.NS_ERROR_UNEXPECTED;
    nsISupports value = values[index++];
    value.AddRef ();
    *_retval = value;
    return XPCOM.NS_OK;
}       
}

