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
module org.eclipse.swt.browser.DownloadFactory_1_8;

import java.lang.all;

//import org.eclipse.swt.internal.C;
import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;
import org.eclipse.swt.internal.mozilla.Common;
//import org.eclipse.swt.internal.mozilla.XPCOMObject;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIFactory;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.browser.Download_1_8;

class DownloadFactory_1_8 : nsIFactory {
    //XPCOMObject supports;
    //XPCOMObject factory;
    int refCount = 0;

this () {
    //createCOMInterfaces ();
}

extern(System)
nsrefcnt AddRef () {
    refCount++;
    return refCount;
}

extern(System)
nsresult QueryInterface (in nsIID* riid, void** ppvObject) {
    if (riid is null || ppvObject is null) return XPCOM.NS_ERROR_NO_INTERFACE;
    //nsID guid = new nsID ();
    //XPCOM.memmove (guid, riid, nsID.sizeof);
    
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
nsresult CreateInstance (nsISupports aOuter, nsIID* iid, void** result) {
    if (result is null) 
        return XPCOM.NS_ERROR_INVALID_ARG;
    auto download = new Download_1_8;
    nsresult rv = download.QueryInterface( iid, result );
    if (XPCOM.NS_FAILED(rv)) {
        *result = null;
        delete download;
    }
    return rv;
}

extern(System)
nsresult LockFactory (PRBool lock) {
    return XPCOM.NS_OK;
}
}
