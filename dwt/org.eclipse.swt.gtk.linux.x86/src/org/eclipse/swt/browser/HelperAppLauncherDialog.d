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
module org.eclipse.swt.browser.HelperAppLauncherDialog;

import java.lang.all;

import org.eclipse.swt.SWT;

import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsEmbedString;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIHelperAppLauncher;
import org.eclipse.swt.internal.mozilla.nsIHelperAppLauncherDialog;
import org.eclipse.swt.internal.mozilla.nsIHelperAppLauncher_1_8;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsILocalFile;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

import org.eclipse.swt.browser.Mozilla;

import org.eclipse.swt.widgets.FileDialog;
import org.eclipse.swt.widgets.Shell;

/**
 * This class implements the HelperAppLauncherDialog interface for mozilla
 * versions 1.4 - 1.8.x.  For mozilla versions >= 1.9 this interface is
 * implemented by class HelperAppLauncherDialog_1_9.  HelperAppLauncherDialogFactory
 * determines at runtime which of these classes to instantiate. 
 */

class HelperAppLauncherDialog : nsIHelperAppLauncherDialog {
    int refCount = 0;

this() {
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
    if (*riid == nsIHelperAppLauncherDialog.IID) {
        *ppvObject = cast(void*)cast(nsIHelperAppLauncherDialog)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    
    *ppvObject = null;
    return XPCOM.NS_ERROR_NO_INTERFACE;
}

extern(System)
nsrefcnt Release () {
    refCount--;
    /*
    * Note.  This instance lives as long as the download it is binded to.
    * Its reference count is expected to go down to 0 when the download
    * has completed or when it has been cancelled. E.g. when the user
    * cancels the File Dialog, cancels or closes the Download Dialog
    * and when the Download Dialog goes away after the download is completed.
    */
    if (refCount is 0) return 0;
    return refCount;
}

/* nsIHelperAppLauncherDialog */

extern(System)
nsresult Show(nsIHelperAppLauncher aLauncher, nsISupports aContext, PRUint32 aReason) {
     /*
     * The interface for nsIHelperAppLauncher changed as of mozilla 1.8.  Query the received
     * nsIHelperAppLauncher for the new interface, and if it is not found then fall back to
     * the old interface. 
     */

    nsISupports supports = cast(nsISupports)aLauncher;
    nsIHelperAppLauncher_1_8 helperAppLauncher;
    nsresult rc = supports.QueryInterface (&nsIHelperAppLauncher_1_8.IID, cast(void**)&helperAppLauncher);
    if (rc is 0) {
        rc = helperAppLauncher.SaveToDisk (null, 0);
        helperAppLauncher.Release ();
        return rc;
    }

    /* < 1.8 */
    return aLauncher.SaveToDisk (null, 0);
    // no Release for this? -JJR
}

extern(System)
nsresult PromptForSaveToFile (nsIHelperAppLauncher aLauncher, nsISupports aWindowContext, PRUnichar* aDefaultFile, PRUnichar* aSuggestedFileExtension, nsILocalFile* _retval) {
    bool hasLauncher = false;

    /*
    * The interface for nsIHelperAppLauncherDialog changed as of mozilla 1.5 when an
    * extra argument was added to the PromptForSaveToFile method (this resulted in all
    * subsequent arguments shifting right).  The workaround is to provide an XPCOMObject 
    * that fits the newer API, and to use the first argument's type to infer whether
    * the old or new nsIHelperAppLauncherDialog interface is being used (and by extension
    * the ordering of the arguments).  In mozilla >= 1.5 the first argument is an
    * nsIHelperAppLauncher. 
    */
    /*
     * The interface for nsIHelperAppLauncher changed as of mozilla 1.8, so the first
     * argument must be queried for both the old and new nsIHelperAppLauncher interfaces. 
     */
    bool using_1_8 = false;
    nsISupports support = cast(nsISupports)aLauncher; 
    
    if (aLauncher is null)
        assert(0);

    nsIHelperAppLauncher_1_8 helperAppLauncher1;
    int rc = support.QueryInterface (&nsIHelperAppLauncher_1_8.IID, cast(void**)&helperAppLauncher1);
    if (rc is XPCOM.NS_OK) {
        using_1_8 = true;
        hasLauncher = true;
        helperAppLauncher1.Release ();
    } else {
        nsIHelperAppLauncher helperAppLauncher;
        rc = support.QueryInterface (&nsIHelperAppLauncher.IID, cast(void**)&helperAppLauncher);
        if (rc is XPCOM.NS_OK) {
            hasLauncher = true;
            helperAppLauncher.Release;
        }
    }

/+
    // In D port, no suppport for version >1.4 yet
    if (hasLauncher) {  /* >= 1.5 */
        aDefaultFile = arg2;
        aSuggestedFileExtension = arg3;
        _retval = arg4;
    } else {            /* 1.4 */  
    // This call conversion probablywon't work for non-Java
    // and shouldn't get called; fix it later. -JJR
        aDefaultFile = arg1;
        aSuggestedFileExtension = arg2;
        _retval = arg3;
    }
+/
    //int span = XPCOM.strlen_PRUnichar (aDefaultFile);
    // XPCOM.memmove (dest, aDefaultFile, length * 2);
    String defaultFile = String_valueOf(fromString16z(aDefaultFile));

    //span = XPCOM.strlen_PRUnichar (aSuggestedFileExtension);
    //dest = new char[length];
    //XPCOM.memmove (dest, aSuggestedFileExtension, length * 2);
    String suggestedFileExtension =  String_valueOf(fromString16z(aSuggestedFileExtension));

    Shell shell = new Shell ();
    FileDialog fileDialog = new FileDialog (shell, SWT.SAVE);
    fileDialog.setFileName (defaultFile);
    String[] tmp;
    tmp ~= suggestedFileExtension; 
    fileDialog.setFilterExtensions (tmp);
    String name = fileDialog.open ();
    shell.close ();
    if (name is null) {
        if (hasLauncher) {
            if (using_1_8) {
                rc = (cast(nsIHelperAppLauncher_1_8)aLauncher).Cancel (XPCOM.NS_BINDING_ABORTED);
            } else {
                rc = aLauncher.Cancel ();
            }
            if (rc !is XPCOM.NS_OK) Mozilla.error (rc,__FILE__,__LINE__); 
            return XPCOM.NS_OK;
        }
        return XPCOM.NS_ERROR_FAILURE;
    }
    scope auto path = new nsEmbedString (name.toWCharArray());
    nsILocalFile localFile;
    rc = XPCOM.NS_NewLocalFile (cast(nsAString*)path, 1, &localFile);
    //path.dispose ();
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc,__FILE__,__LINE__);
    if (localFile is null) Mozilla.error (XPCOM.NS_ERROR_NULL_POINTER,__FILE__,__LINE__);
    /* Our own nsIDownload has been registered during the Browser initialization. It will be invoked by Mozilla. */
    *_retval = localFile; 
    //XPCOM.memmove (_retval, result, C.PTR_SIZEOF);  
    return XPCOM.NS_OK;
}
}
