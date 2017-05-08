/*******************************************************************************
 * Copyright (c) 2003, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Ported to the D Programming Language:
 *     John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module org.eclipse.swt.browser.HelperAppLauncherDialog_1_9;

import java.lang.all;

import org.eclipse.swt.SWT;

import org.eclipse.swt.internal.mozilla.Common;

import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;

import org.eclipse.swt.internal.mozilla.nsEmbedString;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIHelperAppLauncherDialog_1_9;
import org.eclipse.swt.internal.mozilla.nsIHelperAppLauncher_1_9;
import org.eclipse.swt.internal.mozilla.nsILocalFile;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsStringAPI;
import org.eclipse.swt.internal.mozilla.nsEmbedString;

import org.eclipse.swt.widgets.FileDialog;
import org.eclipse.swt.widgets.Shell;

import org.eclipse.swt.browser.Mozilla;

class HelperAppLauncherDialog_1_9 : nsIHelperAppLauncherDialog_1_9 {

    int refCount = 0;

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

    if (*riid is nsISupports.IID) {
        *ppvObject = cast(void*)cast(nsIHelperAppLauncherDialog_1_9)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid is nsIHelperAppLauncherDialog_1_9.IID) {
        *ppvObject = cast(void*)cast(nsIHelperAppLauncherDialog_1_9)this;
        AddRef ();
        return XPCOM.NS_OK;
    }

    *ppvObject = null;
    return XPCOM.NS_ERROR_NO_INTERFACE;
}

extern(System)          
nsresult Release () {
    refCount--;
    /*
    * Note.  This instance lives as long as the download it is bound to.
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
nsresult Show (nsIHelperAppLauncher_1_9 aLauncher, nsISupports aContext, PRUint32 aReason) {
    return aLauncher.SaveToDisk (null, 0);
}

extern(System)
nsresult PromptForSaveToFile (nsIHelperAppLauncher_1_9 aLauncher, nsISupports aWindowContext, PRUnichar* aDefaultFileName, PRUnichar* aSuggestedFileExtension, PRBool aForcePrompt, nsILocalFile* _retval) {
    //int length = XPCOM.strlen_PRUnichar (aDefaultFileName);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, aDefaultFileName, length * 2);
    String defaultFile = String_valueOf(fromString16z(aDefaultFileName));

    //length = XPCOM.strlen_PRUnichar (aSuggestedFileExtension);
    //dest = new char[length];
    //XPCOM.memmove (dest, aSuggestedFileExtension, length * 2);
    String suggestedFileExtension = String_valueOf(fromString16z(aSuggestedFileExtension));

    Shell shell = new Shell ();
    FileDialog fileDialog = new FileDialog (shell, SWT.SAVE);
    fileDialog.setFileName (defaultFile);
    String[] tmp;
    tmp ~= suggestedFileExtension; 
    fileDialog.setFilterExtensions (tmp);
    String name = fileDialog.open ();
    shell.close ();
    if (name is null) {
        //nsIHelperAppLauncher_1_9 launcher = new nsIHelperAppLauncher_1_9 (aLauncher);
        int rc = aLauncher.Cancel (XPCOM.NS_BINDING_ABORTED);
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc,__FILE__,__LINE__);
        return XPCOM.NS_ERROR_FAILURE;
    }
    scope auto path = new nsEmbedString (name.toWCharArray());
    
    nsILocalFile localFile;
    int rc = XPCOM.NS_NewLocalFile (cast(nsAString*)path, 1, &localFile);
    //path.dispose ();
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc,__FILE__,__LINE__);
    if (localFile is null) Mozilla.error (XPCOM.NS_ERROR_NULL_POINTER,__FILE__,__LINE__);
    /* Our own nsIDownload has been registered during the Browser initialization. It will be invoked by Mozilla. */
    *_retval = localFile; 
    //XPCOM.memmove (_retval, result, C.PTR_SIZEOF);  
    return XPCOM.NS_OK;
}
}


