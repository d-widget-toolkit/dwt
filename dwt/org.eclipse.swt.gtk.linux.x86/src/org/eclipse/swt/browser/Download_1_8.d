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
module org.eclipse.swt.browser.Download_1_8;

import java.lang.all;

import org.eclipse.swt.SWT;

import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.prtime;
import org.eclipse.swt.internal.mozilla.nsICancelable;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIDownload_1_8;
import org.eclipse.swt.internal.mozilla.nsIProgressDialog_1_8;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIURI;
import org.eclipse.swt.internal.mozilla.nsIWebProgressListener;
import org.eclipse.swt.internal.mozilla.nsIMIMEInfo;
import org.eclipse.swt.internal.mozilla.nsIObserver;
import org.eclipse.swt.internal.mozilla.nsIDOMWindow;
import org.eclipse.swt.internal.mozilla.nsIWebProgress;
import org.eclipse.swt.internal.mozilla.nsIRequest;
import org.eclipse.swt.internal.mozilla.nsILocalFile;
import org.eclipse.swt.internal.mozilla.nsStringAPI;
import org.eclipse.swt.internal.mozilla.nsEmbedString;

import org.eclipse.swt.browser.Mozilla;

import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;

class Download_1_8 : nsIProgressDialog_1_8 {
    nsICancelable cancelable;
    int refCount = 0;

    Shell shell;
    Label status;
    Button cancel;

    //static const bool is32 = C.PTR_SIZEOF is 4; //determine if 32 or 64 bit platform?

this () {
}

extern(System)
nsrefcnt AddRef () {
    refCount++;
    return refCount;
}

extern(System)
nsresult QueryInterface ( in cnsID* riid, void** ppvObject) {
    if (riid is null || ppvObject is null) return XPCOM.NS_ERROR_NO_INTERFACE;
   
    if (*riid == nsISupports.IID) {
        *ppvObject = cast(void*)cast(nsISupports)this;
        AddRef();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIDownload_1_8.IID) {
        *ppvObject = cast(void*)cast(nsIDownload_1_8)this;
        AddRef();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIProgressDialog_1_8.IID) {
        *ppvObject = cast(void*)cast(nsIProgressDialog_1_8)this;
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
    if (refCount is 0) return 0;
    return refCount;
}

/* nsIDownload */

/* Note. The argument startTime is defined as a PRInt64. This translates into two java ints. */
extern(System)
nsresult Init_32 (nsIURI aSource, nsIURI aTarget, nsAString* aDisplayName, nsIMIMEInfo aMIMEInfo, PRInt32 startTime1, PRInt32 startTime2, nsILocalFile aTempFile, nsICancelable aCancelable) {
    long startTime = (startTime2 << 32) + startTime1;
    return Init (aSource, aTarget, aDisplayName, aMIMEInfo, startTime, aTempFile, aCancelable);
}

// FIXME: I've hardcoded the string values in place of Compatibility.getMessage calls in 
// the Init method; this will need fixing in future releases. -JJR
extern(System)
nsresult Init (nsIURI aSource, nsIURI aTarget, nsAString* aDisplayName, nsIMIMEInfo aMIMEInfo, PRTime startTime, nsILocalFile aTempFile, nsICancelable aCancelable) {
    cancelable = aCancelable;
    // nsIURI source = new nsIURI (aSource);
    scope auto aSpec = new nsEmbedCString;
    int rc = aSource.GetHost (cast(nsACString*)aSpec);
    if (rc !is XPCOM.NS_OK) Mozilla.error(rc,__FILE__,__LINE__);
    //int length = XPCOM.nsEmbedCString_Length (aSpec);
    //ptrdiff_t buffer = XPCOM.nsEmbedCString_get (aSpec);
    //byte[] dest = new byte[length];
    //XPCOM.memmove (dest, buffer, length);
    //XPCOM.nsEmbedCString_delete (aSpec);
    String url = aSpec.toString;

    //nsIURI target = new nsIURI (aTarget);
    scope auto aPath = new nsEmbedCString;
    rc = aTarget.GetPath (cast(nsACString*)aPath);
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
    //length = XPCOM.nsEmbedCString_Length (aPath);
    //buffer = XPCOM.nsEmbedCString_get (aPath);
    //dest = new byte[length];
    //XPCOM.memmove (dest, buffer, length);
    //XPCOM.nsEmbedCString_delete (aPath);
    String filename = aPath.toString;
    //int separator = locatePrior(filename, System.getProperty ("file.separator"));
    int separator = filename.lastIndexOf (System.getProperty ("file.separator"));   //$NON-NLS-1$
    // NOTE: Not sure if this is correct; watch out for bugs here. -JJR
    filename = filename.substring (separator + 1);

    Listener listener = new class() Listener {
        public void handleEvent (Event event) {
            if (event.widget is cancel) {
                shell.close ();
            }
            if (cancelable !is null) {
                int rc = cancelable.Cancel (XPCOM.NS_BINDING_ABORTED);
                if (rc !is XPCOM.NS_OK) Mozilla.error (rc,__FILE__,__LINE__);
            }
            shell = null;
            cancelable = null;
        }
    };
    shell = new Shell (SWT.DIALOG_TRIM);
// FIXME: A working Compatibility.getMessage has not been ported yet
// Strings hardcoded for now.
    //String msg = Compatibility.getMessage ("SWT_Download_File", new Object[] {filename}); //$NON-NLS-1$
    shell.setText ("Download: " ~ filename);
    GridLayout gridLayout = new GridLayout ();
    gridLayout.marginHeight = 15;
    gridLayout.marginWidth = 15;
    gridLayout.verticalSpacing = 20;
    shell.setLayout (gridLayout);
    //msg = Compatibility.getMessage ("SWT_Download_Location", new Object[] {filename, url}); //$NON-NLS-1$
    auto lbl = new Label (shell, SWT.SIMPLE);
    lbl.setText ("Saving " ~ filename ~ " from " ~ url );
    status = new Label (shell, SWT.SIMPLE);
    //msg = Compatibility.getMessage ("SWT_Download_Started"); //$NON-NLS-1$
    status.setText ("Downloading...");
    GridData data = new GridData ();
    data.grabExcessHorizontalSpace = true;
    data.grabExcessVerticalSpace = true;
    status.setLayoutData (data);
    
    cancel = new Button (shell, SWT.PUSH);
    cancel.setText( "Cancel" ); 
    //cancel.setText (SWT.getMessage ("SWT_Cancel")); //$NON-NLS-1$
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
nsresult GetAmountTransferred (PRUint64* arg0) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetCancelable (nsICancelable* arg0) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetDisplayName (PRUnichar** aDisplayName) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetMIMEInfo (nsIMIMEInfo* aMIMEInfo) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetPercentComplete (PRInt32* aPercentComplete) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetSize (PRUint64* arg0) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetSource (nsIURI* aSource) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetStartTime (PRInt64* aStartTime) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetTarget (nsIURI* aTarget) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetTargetFile (nsILocalFile* arg0) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

/* nsIProgressDialog */

extern(System)
nsresult GetCancelDownloadOnClose (PRBool* aCancelDownloadOnClose) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetDialog (nsIDOMWindow* aDialog) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult GetObserver (nsIObserver* aObserver) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult Open (nsIDOMWindow aParent) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult SetCancelDownloadOnClose (PRBool aCancelDownloadOnClose) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult SetDialog (nsIDOMWindow aDialog) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult SetObserver (nsIObserver aObserver) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

/* nsIWebProgressListener */

extern(System)
nsresult OnLocationChange (nsIWebProgress aWebProgress, nsIRequest aRequest, nsIURI aLocation) {
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnProgressChange (nsIWebProgress aWebProgress, nsIRequest aRequest, PRInt32 aCurSelfProgress, PRInt32 aMaxSelfProgress, PRInt32 aCurTotalProgress, PRInt32 aMaxTotalProgress) {
    return OnProgressChange64 (aWebProgress, aRequest, aCurSelfProgress, aMaxSelfProgress, aCurTotalProgress, aMaxTotalProgress);
}
/++
/* Note. The last 4 args in the original interface are defined as PRInt64. These each translate into two java ints. */
nsresult OnProgressChange64_32 (ptrdiff_t aWebProgress, ptrdiff_t aRequest, ptrdiff_t aCurSelfProgress1, ptrdiff_t aCurSelfProgress2, ptrdiff_t aMaxSelfProgress1, ptrdiff_t aMaxSelfProgress2, ptrdiff_t aCurTotalProgress1, ptrdiff_t aCurTotalProgress2, ptrdiff_t aMaxTotalProgress1, ptrdiff_t aMaxTotalProgress2) {
    long aCurSelfProgress = (aCurSelfProgress2 << 32) + aCurSelfProgress1;
    long aMaxSelfProgress = (aMaxSelfProgress2 << 32) + aMaxSelfProgress1;
    long aCurTotalProgress = (aCurTotalProgress2 << 32) + aCurTotalProgress1;
    long aMaxTotalProgress = (aMaxTotalProgress2 << 32) + aMaxTotalProgress1;
    return OnProgressChange64 (aWebProgress, aRequest, aCurSelfProgress, aMaxSelfProgress, aCurTotalProgress, aMaxTotalProgress);
}
++/
extern(System)
nsresult OnProgressChange64 (nsIWebProgress aWebProgress, nsIRequest aRequest, PRInt64 aCurSelfProgress, PRInt64 aMaxSelfProgress, PRInt64 aCurTotalProgress, PRInt64 aMaxTotalProgress) {
    long currentKBytes = aCurTotalProgress / 1024;
    long totalKBytes = aMaxTotalProgress / 1024;
    if (shell !is null && !shell.isDisposed ()) {
        //Object[] arguments = {new Long (currentKBytes), new Long (totalKBytes)};
        //String statusMsg = Compatibility.getMessage ("SWT_Download_Status", arguments); //$NON-NLS-1$
        String statusMsg = Format("Download:  {0} KB of {1} KB", currentKBytes, totalKBytes); 
        status.setText (statusMsg);
        shell.layout (true);
        shell.getDisplay ().update ();
    }
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnSecurityChange (nsIWebProgress aWebProgress, nsIRequest aRequest, PRUint32 state) {
    return XPCOM.NS_OK;
}

extern(System)
nsresult OnStateChange (nsIWebProgress aWebProgress, nsIRequest aRequest, PRUint32 aStateFlags, nsresult aStatus) {
    if ((aStateFlags & nsIWebProgressListener.STATE_STOP) !is 0) {
        cancelable = null;
        if (shell !is null && !shell.isDisposed ()) shell.dispose ();
        shell = null;
    }
    return XPCOM.NS_OK;
}   

extern(System)
nsresult OnStatusChange (nsIWebProgress aWebProgress, nsIRequest aRequest, nsresult aStatus, PRUnichar* aMessage) {
    return XPCOM.NS_OK;
}       
}
