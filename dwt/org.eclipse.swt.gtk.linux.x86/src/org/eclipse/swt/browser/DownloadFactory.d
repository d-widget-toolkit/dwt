/*******************************************************************************
 * Copyright (c) 2003, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module org.eclipse.swt.browser.DownloadFactory;

import java.lang.all;

//import org.eclipse.swt.internal.C;
import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;
import org.eclipse.swt.internal.mozilla.Common;
//import org.eclipse.swt.internal.mozilla.XPCOMObject;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIFactory;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.browser.Download;

class DownloadFactory : nsIFactory {
    int refCount = 0;

this () {}

extern(System)
nsrefcnt AddRef () {
    refCount++;
    return refCount;
}

extern(System)
nsresult QueryInterface (in cnsID* riid, void** ppvObject) {
    if (riid is null || ppvObject is null) return XPCOM.NS_ERROR_NO_INTERFACE;
    
    if (*riid == nsISupports.IID) {
        *ppvObject = cast(void*)cast(nsISupports)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIFactory.IID) {
        *ppvObject = cast(void*)cast(nsIFactory)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    
    *ppvObject = null;
    return XPCOM.NS_ERROR_NO_INTERFACE;
}

extern(System)
nsrefcnt Release () {
    refCount--;
    //if (refCount is 0) disposeCOMInterfaces ();
    return refCount;
}
    
/* nsIFactory */

extern(System)
nsresult CreateInstance (nsISupports aOuter, nsID* iid, void** result) {
    if (result is null) 
        return XPCOM.NS_ERROR_INVALID_ARG;
    auto download = new Download();
    nsresult rv = download.QueryInterface( iid, result );
    if (XPCOM.NS_FAILED(rv)) {
        *result = null;
        delete download;
    }
    return rv;
}

extern(System)
nsresult LockFactory (int lock) {
    return XPCOM.NS_OK;
}
}
