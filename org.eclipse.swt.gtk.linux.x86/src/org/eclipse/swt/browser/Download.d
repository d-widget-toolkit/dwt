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
module org.eclipse.swt.browser.Download;

version(Tango){
import Util = tango.text.Util;
} else { // Phobos
}
import java.lang.all;

import org.eclipse.swt.SWT;

import org.eclipse.swt.browser.Mozilla;

import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;

import org.eclipse.swt.internal.mozilla.prtime;
import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIDownload;
import org.eclipse.swt.internal.mozilla.nsIHelperAppLauncher;
import org.eclipse.swt.internal.mozilla.nsILocalFile;
import org.eclipse.swt.internal.mozilla.nsIProgressDialog;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIURI;
import org.eclipse.swt.internal.mozilla.nsIWebProgressListener;
import org.eclipse.swt.internal.mozilla.nsIMIMEInfo;
import org.eclipse.swt.internal.mozilla.nsIObserver;
import org.eclipse.swt.internal.mozilla.nsIDOMWindow;
import org.eclipse.swt.internal.mozilla.nsIWebProgress;
import org.eclipse.swt.internal.mozilla.nsIRequest;
import org.eclipse.swt.internal.mozilla.nsStringAPI;
import org.eclipse.swt.internal.mozilla.nsEmbedString;

import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;

class Download : nsIProgressDialog {
    nsIHelperAppLauncher helperAppLauncher;
    int refCount = 0;

    Shell shell;
    Label status;
    Button cancel;
    
this () {
}

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
        AddRef();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIDownload.IID) {
        *ppvObject = cast(void*)cast(nsIDownload)this;
        AddRef();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIProgressDialog.IID) {
        *ppvObject = cast(void*)cast(nsIProgressDialog)this;
        AddRef();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIWebProgressListener.IID) {
        *ppvObject = cast(void*)cast(nsIWebProgressListener)this;
        AddRef();
        return XPCOM.NS_OK;
    }
    *ppvObject = null;
    return XPCOM.NS_ERROR_NO_INTERFACE;
}

extern(System)
nsrefcnt Release () {
    refCount--;
    if (refCount is 0) return 0; // nonsensical condition: will fix later -JJR
    return refCount;
}

/* nsIDownload */

/* Note. The argument startTime is defined as a PRInt64. This translates into two java ints. */
/* EXCEPTION: not for D */

extern(System)
nsresult Init (nsIURI aSource, nsIURI aTarget, nsAString* aDisplayName, nsIMIMEInfo aMIMEInfo, PRTime startTime, PRBool aPersist) {
    //nsIURI source = new nsIURI (aSource);
    scope auto aSpec = new nsEmbedCString;
    int rc = aSource.GetHost (cast(nsACString*)aSpec);
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
    //int length = XPCOM.nsEmbedCString_Length (aSpec);
    //ptrdiff_t buffer = XPCOM.nsEmbedCString_get (aSpec);
    //byte[] dest = new byte[length];
    //XPCOM.memmove (dest, buffer, length);
    //XPCOM.nsEmbedCString_delete (aSpec);
    String url = aSpec.toString;

    /*
    * As of mozilla 1.7 the second argument of the nsIDownload interface's 
    * Init function changed from nsILocalFile to nsIURI.  Detect which of
    * these interfaces the second argument implements and act accordingly.  
    */
    String filename = null;
    nsISupports supports = cast(nsISupports)aTarget;
    nsIURI target;
    rc = supports.QueryInterface (&nsIURI.IID, cast(void**)&target);
    if (rc is 0) {  /* >= 1.7 */
        //result[0] = 0;
        //ptrdiff_t aPath = XPCOM.nsEmbedCString_new ();
        scope auto aPath = new nsEmbedCString;
        rc = target.GetPath (cast(nsACString*)aPath);
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc,__FILE__,__LINE__);
        //length = XPCOM.nsEmbedCString_Length (aPath);
        //buffer = XPCOM.nsEmbedCString_get (aPath);
        //dest = new byte[length];
        //XPCOM.memmove (dest, buffer, length);
        //XPCOM.nsEmbedCString_delete (aPath);
        filename = aPath.toString;
        int separator = filename.lastIndexOf (System.getProperty ("file.separator"));   //$NON-NLS-1$
        filename = filename.substring (separator + 1);
        target.Release ();
    } else {    /* < 1.7 */
        nsILocalFile target2 = cast(nsILocalFile) aTarget;
        scope auto aNativeTarget = new nsEmbedCString;
        rc = target2.GetNativeLeafName (cast(nsACString*)aNativeTarget);
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc,__FILE__,__LINE__);
        //length = XPCOM.nsEmbedCString_Length (aNativeTarget);
        //buffer = XPCOM.nsEmbedCString_get (aNativeTarget);
        //dest = new byte[length];
        //XPCOM.memmove (dest, buffer, length);
        //XPCOM.nsEmbedCString_delete (aNativeTarget);
        filename = aNativeTarget.toString;
    }

    Listener listener = new class() Listener  {
        public void handleEvent (Event event) {
            if (event.widget is cancel) {
                shell.close ();
            }
            if (helperAppLauncher !is null) {
                helperAppLauncher.Cancel ();
                helperAppLauncher.Release ();
            }
            shell = null;
            helperAppLauncher = null;
        }
    };
    shell = new Shell (SWT.DIALOG_TRIM);
    //String msg = Compatibility.getMessage ("SWT_Download_File", new Object[] {filename}); //$NON-NLS-1$
    shell.setText ("Download: " ~ filename);
    GridLayout gridLayout = new GridLayout ();
    gridLayout.marginHeight = 15;
    gridLayout.marginWidth = 15;
    gridLayout.verticalSpacing = 20;
    shell.setLayout(gridLayout);
    //msg = Compatibility.getMessage ("SWT_Download_Location", new Object[] {filename, url}); //$NON-NLS-1$
    auto lbl = new Label (shell, SWT.SIMPLE);
    lbl.setText ("Saving " ~ filename ~ " from " ~ url);
    status = new Label (shell, SWT.SIMPLE);
    //msg = Compatibility.getMessage ("SWT_Download_Started"); //$NON-NLS-1$
    status.setText ("Downloading...");
    GridData data = new GridData ();
    data.grabExcessHorizontalSpace = true;
    data.grabExcessVerticalSpace = true;
    status.setLayoutData (data);

    cancel = new Button (shell, SWT.PUSH);
    cancel.setText ("Cancel"); //$NON-NLS-1$
    data = new GridData ();
    data.horizontalAlignment = GridData.CENTER;
    cancel.setLayoutData (data);
    cancel.addListener (SWT.Selection, listener);
    shell.addListener (SWT.Close, listener);
    shell.pack ();
    shell.open ();
    return XPCOM.NS_OK;
}

extern(System)
nsresult GetSource (nsIURI* aSource) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetTarget (nsIURI* aTarget) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetPersist (PRBool* aPersist) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetPercentComplete (PRInt32* aPercentComplete) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetDisplayName (PRUnichar** aDisplayName) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult SetDisplayName (PRUnichar* aDisplayName) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetStartTime (PRInt64* aStartTime) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetMIMEInfo (nsIMIMEInfo* aMIMEInfo) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetListener (nsIWebProgressListener* aListener) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult SetListener (nsIWebProgressListener aListener) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetObserver (nsIObserver* aObserver) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult SetObserver (nsIObserver aObserver) {
    if (aObserver !is null) {
        // nsISupports supports = new nsISupports (aObserver);
        nsIHelperAppLauncher result;
        int rc = aObserver.QueryInterface (&nsIHelperAppLauncher.IID, cast(void**)&result);
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
        if (result is null) Mozilla.error (XPCOM.NS_ERROR_NO_INTERFACE);
        helperAppLauncher = result;
    }
    return XPCOM.NS_OK;
}

/* nsIProgressDialog */

extern(System)
nsresult Open (nsIDOMWindow aParent) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetCancelDownloadOnClose (PRBool* aCancelDownloadOnClose) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult SetCancelDownloadOnClose (PRBool aCancelDownloadOnClose) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetDialog (nsIDOMWindow* aDialog) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult SetDialog (nsIDOMWindow aDialog) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

/* nsIWebProgressListener */

extern(System)
nsresult OnStateChange (nsIWebProgress aWebProgress, nsIRequest aRequest, PRUint32 aStateFlags, nsresult aStatus) {
    if ((aStateFlags & nsIWebProgressListener.STATE_STOP) !is 0) {
        if (helperAppLauncher !is null) helperAppLauncher.Release ();
        helperAppLauncher = null;
        if (shell !is null && !shell.isDisposed ()) shell.dispose ();
        shell = null;
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnProgressChange (nsIWebProgress aWebProgress, nsIRequest aRequest, PRInt32 aCurSelfProgress, PRInt32 aMaxSelfProgress, PRInt32 aCurTotalProgress, PRInt32 aMaxTotalProgress) {
    int currentKBytes = aCurTotalProgress / 1024;
    int totalKBytes = aMaxTotalProgress / 1024;
    if (shell !is null && !shell.isDisposed ()) {
        //Object[] arguments = {new Integer (currentKBytes), new Integer (totalKBytes)};
        //String statusMsg = Compatibility.getMessage ("SWT_Download_Status", arguments); //$NON-NLS-1$
        status.setText (Format("Download: {0} KB of {1} KB", currentKBytes, totalKBytes));
        shell.layout (true);
        shell.getDisplay ().update ();
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnLocationChange (nsIWebProgress aWebProgress, nsIRequest aRequest, nsIURI aLocation) {
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnStatusChange (nsIWebProgress aWebProgress, nsIRequest aRequest, nsresult aStatus, PRUnichar* aMessage) {
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnSecurityChange (nsIWebProgress aWebProgress, nsIRequest aRequest, PRUint32 state) {
    return XPCOM.NS_OK;
}
}
