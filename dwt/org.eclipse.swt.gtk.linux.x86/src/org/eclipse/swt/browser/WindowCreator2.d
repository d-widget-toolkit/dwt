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
module org.eclipse.swt.browser.WindowCreator2;

import java.lang.all;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;

import org.eclipse.swt.internal.Platform;
import org.eclipse.swt.internal.mozilla.Common;

import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;

import org.eclipse.swt.internal.mozilla.nsIBaseWindow;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIURI;
import org.eclipse.swt.internal.mozilla.nsIWebBrowser;
import org.eclipse.swt.internal.mozilla.nsIWebBrowserChrome;
import org.eclipse.swt.internal.mozilla.nsIWindowCreator;
import org.eclipse.swt.internal.mozilla.nsIWindowCreator2;
import org.eclipse.swt.internal.mozilla.nsStringAPI;
import org.eclipse.swt.internal.mozilla.nsEmbedString;

import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.widgets.Shell;

import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.browser.Mozilla;
import org.eclipse.swt.browser.VisibilityWindowListener;
import org.eclipse.swt.browser.CloseWindowListener;
import org.eclipse.swt.browser.WindowEvent;

class WindowCreator2 : nsIWindowCreator2 {
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
    //nsID guid = new nsID ();
    //XPCOM.memmove (guid, riid, nsID.sizeof);
    
    if (*riid == nsISupports.IID) {
        *ppvObject = cast(void*)cast(nsISupports)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIWindowCreator.IID) {
        *ppvObject = cast(void*)cast(nsIWindowCreator)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIWindowCreator2.IID) {
        *ppvObject = cast(void*)cast(nsIWindowCreator2)this;
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

/* nsIWindowCreator */

extern(System)
nsresult CreateChromeWindow (nsIWebBrowserChrome parent, PRUint32 chromeFlags, nsIWebBrowserChrome* _retval) {
    return CreateChromeWindow2 (parent, chromeFlags, 0, null, null, _retval);
}

/* nsIWindowCreator2 */

extern(System)
nsresult CreateChromeWindow2 (nsIWebBrowserChrome parent, PRUint32 chromeFlags, PRUint32 contextFlags, nsIURI uri, PRBool* cancel, nsIWebBrowserChrome* _retval) {
    if (parent is null && (chromeFlags & nsIWebBrowserChrome.CHROME_OPENAS_CHROME) is 0) {
        return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
    }
    Browser src = null; 
    if (parent !is null) {
        //nsIWebBrowserChrome browserChromeParent = new nsIWebBrowserChrome (parent);
        nsIWebBrowser webBrowser;
        int rc = parent.GetWebBrowser (&webBrowser);
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
        if (webBrowser is null) Mozilla.error (XPCOM.NS_ERROR_NO_INTERFACE);

        //nsIWebBrowser webBrowser = new nsIWebBrowser (aWebBrowser[0]);
        nsIBaseWindow baseWindow;
        rc = webBrowser.QueryInterface (&nsIBaseWindow.IID, cast(void**)&baseWindow);
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
        if (baseWindow is null) Mozilla.error (XPCOM.NS_ERROR_NO_INTERFACE);
        webBrowser.Release ();

        //nsIBaseWindow baseWindow = new nsIBaseWindow (result[0]);
        //result[0] = 0;
        nativeWindow aParentNativeWindow;  // nativeWindow is "void*" (represents GtkWidget*)
        rc = baseWindow.GetParentNativeWindow (&aParentNativeWindow);
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
        if (aParentNativeWindow is null) Mozilla.error (XPCOM.NS_ERROR_NO_INTERFACE);
        baseWindow.Release ();

        src = Mozilla.findBrowser (aParentNativeWindow);
    }
    Browser browser;
    bool doit = true;
    if ((chromeFlags & nsIWebBrowserChrome.CHROME_OPENAS_CHROME) !is 0) {
        /*
        * Mozilla will request a new Browser in a modal window in order to emulate a native
        * dialog that is not available to it (eg.- a print dialog on Linux).  For this
        * reason modal requests are handled here so that the user is not exposed to them.
        */
        int style = SWT.DIALOG_TRIM;
        if ((chromeFlags & nsIWebBrowserChrome.CHROME_MODAL) !is 0) style |= SWT.APPLICATION_MODAL; 
        Shell shell = src is null ?
            new Shell (style) :
            new Shell (src.getShell(), style);
        shell.setLayout (new FillLayout ());
        browser = new Browser (shell, src is null ? SWT.MOZILLA : src.getStyle () & SWT.MOZILLA);
        browser.addVisibilityWindowListener (new class(shell) VisibilityWindowListener {
            Shell sh;
            this (Shell shell) { this.sh = shell; }
            public void hide (WindowEvent event) {
            }
            public void show (WindowEvent event) {
                if (event.location !is null) sh.setLocation (event.location);
                if (event.size !is null) {
                    Point size = event.size;
                    sh.setSize (sh.computeSize (size.x, size.y));
                }
                shell.open ();
            }
        });
        browser.addCloseWindowListener (new class(shell) CloseWindowListener {
            Shell sh;
            this (Shell shell) { this.sh = shell; }
            public void close (WindowEvent event) {
                sh.close ();
            }
        });
        if (uri !is null) {
            //nsIURI location = new nsIURI (uri);
            scope auto aSpec = new nsEmbedCString;
            if (uri.GetSpec (cast(nsACString*)aSpec) is XPCOM.NS_OK) {
                int span = aSpec.toString().length;
                if (span > 0) {
                    //ptrdiff_t buffer = XPCOM.nsEmbedCString_get (aSpec);
                    // byte[] dest = new byte[length];
                    //XPCOM.memmove (dest, buffer, length);
                    browser.setUrl (aSpec.toString);
                }
            }
            //XPCOM.nsEmbedCString_delete (aSpec);
        }
    } else {
        WindowEvent event = new WindowEvent (src);
        event.display = src.getDisplay ();
        event.widget = src;
        event.required = true;
        for (int i = 0; i < src.webBrowser.openWindowListeners.length; i++) {
            src.webBrowser.openWindowListeners[i].open (event);
        }
        browser = event.browser;

        /* Ensure that the Browser provided by the client is valid for use */ 
        doit = browser !is null && !browser.isDisposed ();
        if (doit) {
            String platform = Platform.PLATFORM;
            bool isMozillaNativePlatform = platform == "gtk" || platform == "motif"; //$NON-NLS-1$ //$NON-NLS-2$
            doit = isMozillaNativePlatform || (browser.getStyle () & SWT.MOZILLA) !is 0;
        }
    }
    if (doit) {
        // STRANGE but TRUE:  browser.webBrowser is always instantiated as Mozilla (on this platform),
        // so it can be cast back to the subclass Mozilla safely.  Looks very dangerous, though... 
        // considering the next few lines of code that cast the Mozilla class to the interface, 
        // nsIWebBrowserChrome.
        // This is an ugly D conversion hack because interfaces are implemented differently than 
        // in the Java SWT version.  Watch this code section carefully for errors/bugs. -JJR
        Mozilla mozilla = cast(Mozilla)browser.webBrowser;
        mozilla.isChild = true;
        // And since Mozilla class implements the nsIWebBrowserChrome interface....
        nsIWebBrowserChrome chrome;
        nsresult rc = mozilla.QueryInterface( &nsIWebBrowserChrome.IID, cast(void**)&chrome);
        if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
        //nsIWebBrowserChrome webBrowserChrome = new nsIWebBrowserChrome (chromePtr);
        chrome.SetChromeFlags (chromeFlags);
        //chrome.AddRef ();
        //XPCOM.memmove (_retval, new ptrdiff_t[] {chromePtr}, C.PTR_SIZEOF);
        *_retval = chrome;
    } else {
        if (cancel !is null) {
            *cancel = 1;   /* PRBool */
        }
    }
    return doit ? XPCOM.NS_OK : XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}
}
