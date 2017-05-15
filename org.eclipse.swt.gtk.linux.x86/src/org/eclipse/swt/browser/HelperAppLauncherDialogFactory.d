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
module org.eclipse.swt.browser.HelperAppLauncherDialogFactory;

import java.lang.all;

import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIFactory;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.browser.HelperAppLauncherDialog;
import org.eclipse.swt.browser.HelperAppLauncherDialog_1_9;

class HelperAppLauncherDialogFactory : nsIFactory {
    int refCount = 0;
    bool isPre_1_9 = true;


this () {
}

extern(System)
nsrefcnt AddRef () {
    refCount++;
    return refCount;
}

extern(System)
nsresult QueryInterface (in nsID* riid, void** ppvObject) {
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
    if (refCount is 0) return 0;
    return refCount;
}

/* nsIFactory */

extern(System)
nsresult CreateInstance (nsISupports aOuter, nsID* iid, void** result) { 
    if (isPre_1_9) {
        if (result is null) 
            return XPCOM.NS_ERROR_INVALID_ARG;
        auto helperAppLauncherDialog = new HelperAppLauncherDialog;
        nsresult rv = helperAppLauncherDialog.QueryInterface( iid, result );
        if (XPCOM.NS_FAILED(rv)) {
            *result = null;
            delete helperAppLauncherDialog;
        } else {
            if (result is null) 
                return XPCOM.NS_ERROR_INVALID_ARG;
            auto helperAppLauncherDialog19 = new HelperAppLauncherDialog_1_9;
            rv = helperAppLauncherDialog19.QueryInterface( iid, result );
            if (XPCOM.NS_FAILED(rv)) {
                *result = null;
                delete helperAppLauncherDialog19;
            }
            return rv;
        }
    }

    return XPCOM.NS_OK; // Not sure about this
}

extern(System)
nsresult LockFactory (PRBool lock) {
    return XPCOM.NS_OK;
}
}
