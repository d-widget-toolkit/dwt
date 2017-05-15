/*******************************************************************************
 * Copyright (c) 2003, 2008 IBM Corporation and others.
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
module org.eclipse.swt.browser.PromptService2;

version(Tango){
    static import tango.stdc.stdlib;
} else { // Phobos
    static import std.c.stdlib;
}

import java.lang.all;

import org.eclipse.swt.SWT;

import org.eclipse.swt.internal.Compatibility;

import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsEmbedString;
import org.eclipse.swt.internal.mozilla.nsIAuthInformation;
import org.eclipse.swt.internal.mozilla.nsIChannel;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIDOMWindow;
import org.eclipse.swt.internal.mozilla.nsIEmbeddingSiteWindow;
import org.eclipse.swt.internal.mozilla.nsIMemory;
import org.eclipse.swt.internal.mozilla.nsIPromptService;
import org.eclipse.swt.internal.mozilla.nsIPromptService2;
import org.eclipse.swt.internal.mozilla.nsIServiceManager;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIURI;
import org.eclipse.swt.internal.mozilla.nsIWebBrowserChrome;
import org.eclipse.swt.internal.mozilla.nsIWindowWatcher;
import org.eclipse.swt.internal.mozilla.nsIAuthPromptCallback;
import org.eclipse.swt.internal.mozilla.nsICancelable;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

import org.eclipse.swt.widgets.MessageBox;
import org.eclipse.swt.widgets.Shell;

import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.browser.Mozilla;
import org.eclipse.swt.browser.PromptDialog;

class PromptService2 : nsIPromptService2 {
    int refCount = 0;

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
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIPromptService.IID) {
        *ppvObject = cast(void*)cast(nsIPromptService)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIPromptService2.IID) {
        *ppvObject = cast(void*)cast(nsIPromptService2)this;
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

extern(D)
Browser getBrowser (nsIDOMWindow aDOMWindow) {
    if (aDOMWindow is null) return null;

    //ptrdiff_t[] result = new ptrdiff_t[1];
    nsIServiceManager serviceManager;
    auto rc = XPCOM.NS_GetServiceManager (&serviceManager);
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
    if (serviceManager is null) Mozilla.error (XPCOM.NS_NOINTERFACE);
    
    //nsIServiceManager serviceManager = new nsIServiceManager (result[0]);
    //result[0] = 0;
    //byte[] aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_WINDOWWATCHER_CONTRACTID, true);
    nsIWindowWatcher windowWatcher;
    rc = serviceManager.GetServiceByContractID (XPCOM.NS_WINDOWWATCHER_CONTRACTID.ptr, &nsIWindowWatcher.IID, cast(void**)&windowWatcher);
    if (rc !is XPCOM.NS_OK) Mozilla.error(rc);
    if (windowWatcher is null) Mozilla.error (XPCOM.NS_NOINTERFACE);       
    serviceManager.Release ();
    
    //nsIWindowWatcher windowWatcher = new nsIWindowWatcher (result[0]);
    //result[0] = 0;
    /* the chrome will only be answered for the top-level nsIDOMWindow */
    //nsIDOMWindow window = new nsIDOMWindow (aDOMWindow);
    nsIDOMWindow top;
    rc = aDOMWindow.GetTop (&top);
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
    if (top is null) Mozilla.error (XPCOM.NS_NOINTERFACE);
    //aDOMWindow = result[0];
    //result[0] = 0;
    nsIWebBrowserChrome webBrowserChrome;
    rc = windowWatcher.GetChromeForWindow (top, &webBrowserChrome);
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
    if (webBrowserChrome is null) Mozilla.error (XPCOM.NS_NOINTERFACE);       
    windowWatcher.Release ();   
    
    //nsIWebBrowserChrome webBrowserChrome = new nsIWebBrowserChrome (result[0]);
    //result[0] = 0;
    nsIEmbeddingSiteWindow embeddingSiteWindow;
    rc = webBrowserChrome.QueryInterface (&nsIEmbeddingSiteWindow.IID, cast(void**)&embeddingSiteWindow);
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
    if (embeddingSiteWindow is null) Mozilla.error (XPCOM.NS_NOINTERFACE);       
    webBrowserChrome.Release ();
    
    //nsIEmbeddingSiteWindow embeddingSiteWindow = new nsIEmbeddingSiteWindow (result[0]);
    //result[0] = 0;
    
    void* result;
    rc = embeddingSiteWindow.GetSiteWindow (&result);
    if (rc !is XPCOM.NS_OK) Mozilla.error (rc);
    if (result is null) Mozilla.error (XPCOM.NS_NOINTERFACE);       
    embeddingSiteWindow.Release ();
    
    return Mozilla.findBrowser (result); 
}

String getLabel (int buttonFlag, int index, PRUnichar* buttonTitle) {
    String label = null;
    int flag = (buttonFlag & (0xff * index)) / index;
    switch (flag) {
        // TODO: implement with SWT.getMessage - JJR
        case nsIPromptService.BUTTON_TITLE_CANCEL : label = "Cancel"; break; //$NON-NLS-1$
        case nsIPromptService.BUTTON_TITLE_NO : label = "No"; break; //$NON-NLS-1$
        case nsIPromptService.BUTTON_TITLE_OK : label = "OK"; break; //$NON-NLS-1$
        case nsIPromptService.BUTTON_TITLE_SAVE : label = "Save"; break; //$NON-NLS-1$
        case nsIPromptService.BUTTON_TITLE_YES : label = "Yes"; break; //$NON-NLS-1$
        case nsIPromptService.BUTTON_TITLE_IS_STRING : {
            auto span = XPCOM.strlen_PRUnichar (buttonTitle);
            //char[] dest = new char[length];
            //XPCOM.memmove (dest, buttonTitle, length * 2);
            label = String_valueOf (buttonTitle[0 .. span]);
        }
    }
    return label;
}

/* nsIPromptService */

extern(System)
nsresult Alert (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText) {
    Browser browser = getBrowser (aParent);
    
    int span = XPCOM.strlen_PRUnichar (aDialogTitle);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, aDialogTitle, length * 2);
    String titleLabel = String_valueOf (aDialogTitle[0 .. span]);

    span = XPCOM.strlen_PRUnichar (aText);
    //dest = new char[length];
    //XPCOM.memmove (dest, aText, length * 2);
    String textLabel = String_valueOf (aText[0 .. span]);

    Shell shell = browser is null ? new Shell () : browser.getShell (); 
    MessageBox messageBox = new MessageBox (shell, SWT.OK | SWT.ICON_WARNING);
    messageBox.setText (titleLabel);
    messageBox.setMessage (textLabel);
    messageBox.open ();
    return XPCOM.NS_OK;
}

extern(System)
nsresult AlertCheck (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRUnichar* aCheckMsg, PRBool* aCheckState) {
    Browser browser = getBrowser (aParent);
    
    int span = XPCOM.strlen_PRUnichar (aDialogTitle);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, aDialogTitle, length * 2);
    String titleLabel = String_valueOf (aDialogTitle[0 .. span]);

    span = XPCOM.strlen_PRUnichar (aText);
    //dest = new char[length];
    //XPCOM.memmove (dest, aText, length * 2);
    String textLabel = String_valueOf (aText[0 .. span]);

    span = XPCOM.strlen_PRUnichar (aCheckMsg);
    //dest = new char[length];
    //XPCOM.memmove (dest, aCheckMsg, length * 2);
    String checkLabel = String_valueOf (aCheckMsg[0..span]);

    Shell shell = browser is null ? new Shell () : browser.getShell ();
    PromptDialog dialog = new PromptDialog (shell);
    int check;
    if (aCheckState !is null) check = *aCheckState; /* PRBool */
    dialog.alertCheck (titleLabel, textLabel, checkLabel, /*ref*/ check);
    if (aCheckState !is null) *aCheckState = check; /* PRBool */
    return XPCOM.NS_OK;
}

extern(System)
nsresult AsyncPromptAuth(nsIDOMWindow aParent, nsIChannel aChannel, nsIAuthPromptCallback aCallback, nsISupports aContext, PRUint32 level, nsIAuthInformation authInfo, PRUnichar* checkboxLabel, PRBool* checkValue, nsICancelable* _retval) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult Confirm (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRBool* _retval) {
    Browser browser = getBrowser (aParent);
    
    int span = XPCOM.strlen_PRUnichar (aDialogTitle);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, aDialogTitle, length * 2);
    String titleLabel = String_valueOf (aDialogTitle[0 .. span]);

    span = XPCOM.strlen_PRUnichar (aText);
    //dest = new char[length];
    //XPCOM.memmove (dest, aText, length * 2);
    String textLabel = String_valueOf (aText[0 .. span]);

    Shell shell = browser is null ? new Shell () : browser.getShell ();
    MessageBox messageBox = new MessageBox (shell, SWT.OK | SWT.CANCEL | SWT.ICON_QUESTION);
    messageBox.setText (titleLabel);
    messageBox.setMessage (textLabel);
    int id = messageBox.open ();
    int result = id is SWT.OK ? 1 : 0;
    *_retval = result;
    return XPCOM.NS_OK;
}

extern(System)
nsresult ConfirmCheck (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRUnichar* aCheckMsg, PRBool* aCheckState, PRBool* _retval) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult ConfirmEx (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRUint32 aButtonFlags, PRUnichar* aButton0Title, PRUnichar* aButton1Title, PRUnichar* aButton2Title, PRUnichar* aCheckMsg, PRBool* aCheckState, PRInt32* _retval) {
    Browser browser = getBrowser (aParent);
    
    int span = XPCOM.strlen_PRUnichar (aDialogTitle);
    //char[] dest = new char[length];
    //XPCOM.memmove (dest, aDialogTitle, length * 2);
    String titleLabel = String_valueOf (aDialogTitle[0 .. span]);

    span = XPCOM.strlen_PRUnichar (aText);
    //dest = new char[length];
    //XPCOM.memmove (dest, aText, length * 2);
    String textLabel = String_valueOf (aText[0 .. span]);
    
    String checkLabel = null;
    if (aCheckMsg !is null) {
        span = XPCOM.strlen_PRUnichar (aCheckMsg);
        //dest = new char[length];
        //XPCOM.memmove (dest, aCheckMsg, length * 2);
        checkLabel = String_valueOf (aCheckMsg[0 .. span]);
    }
    
    String button0Label = getLabel (aButtonFlags, nsIPromptService.BUTTON_POS_0, aButton0Title);
    String button1Label = getLabel (aButtonFlags, nsIPromptService.BUTTON_POS_1, aButton1Title);
    String button2Label = getLabel (aButtonFlags, nsIPromptService.BUTTON_POS_2, aButton2Title);
    
    int defaultIndex = 0;
    if ((aButtonFlags & nsIPromptService.BUTTON_POS_1_DEFAULT) !is 0) {
        defaultIndex = 1;
    } else if ((aButtonFlags & nsIPromptService.BUTTON_POS_2_DEFAULT) !is 0) {
        defaultIndex = 2;
    }
    
    Shell shell = browser is null ? new Shell () : browser.getShell ();
    PromptDialog dialog = new PromptDialog (shell);
    int check, result;
    if (aCheckState !is null) check = *aCheckState;
    dialog.confirmEx (titleLabel, textLabel, checkLabel, button0Label, button1Label, button2Label, defaultIndex, /*ref*/check, /*ref*/result);
    if (aCheckState !is null) *aCheckState = check;
    *_retval = result;
    return XPCOM.NS_OK;
}

extern(System)
nsresult Prompt (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRUnichar** aValue, PRUnichar* aCheckMsg, PRBool* aCheckState, PRBool* _retval) {
    Browser browser = getBrowser (aParent);
    String titleLabel = null;
    String textLabel = null, checkLabel = null;
    String valueLabel;
    //char[] dest;
    int span;
    if (aDialogTitle !is null) {
        span = XPCOM.strlen_PRUnichar (aDialogTitle);
        //dest = new char[length];
        //XPCOM.memmove (dest, aDialogTitle, length * 2);
        titleLabel = String_valueOf (aDialogTitle[0 .. span]);
    }
    
    span = XPCOM.strlen_PRUnichar (aText);
    //dest = new char[length];
    //XPCOM.memmove (dest, aText, length * 2);
    textLabel = String_valueOf (aText[0 .. span]);
    
    //ptrdiff_t[] valueAddr = new ptrdiff_t[1];
    //XPCOM.memmove (valueAddr, aValue, C.PTR_SIZEOF);
    auto valueAddr = aValue;
    if (valueAddr[0] !is null) {
        span = XPCOM.strlen_PRUnichar (valueAddr[0]);
        //dest = new char[length];
        //XPCOM.memmove (dest, valueAddr[0], length * 2);
        valueLabel = String_valueOf ((valueAddr[0])[0 .. span]);
    }
    
    if (aCheckMsg !is null) {
        span = XPCOM.strlen_PRUnichar (aCheckMsg);
        if (span > 0) {
            //dest = new char[length];
            //XPCOM.memmove (dest, aCheckMsg, length * 2);
            checkLabel = String_valueOf (aCheckMsg[0 .. span]);
        }
    }

    Shell shell = browser is null ? new Shell () : browser.getShell ();
    PromptDialog dialog = new PromptDialog (shell);
    int check, result;
    if (aCheckState !is null) check = *aCheckState;
    dialog.prompt (titleLabel, textLabel, checkLabel, /*ref*/valueLabel,/*ref*/ check,/*ref*/ result);
    *_retval = result;
    if (result is 1) {
        /* 
        * User selected OK. User name and password are returned as PRUnichar values. Any default
        * value that we override must be freed using the nsIMemory service.
        */
        int size;
        void* ptr;
        String16 buffer;
        nsIServiceManager serviceManager;
        if (valueLabel !is null) {
            //cnt = valueLabel.length;
            //buffer = new wchar[cnt + 1];
            //valueLabel.getChars (0, cnt, buffer, 0);
            buffer = valueLabel.toWCharArray();
            size = buffer.length * 2;
            version(Tango){
                ptr = tango.stdc.stdlib.malloc (size);
            } else { // Phobos
                ptr = std.c.stdlib.malloc (size);
            }
            (cast(wchar*)ptr)[0 .. buffer.length] = buffer[0 .. $];
            //XPCOM.memmove (ptr, buffer, size);
            //XPCOM.memmove (aValue, new ptrdiff_t[] {ptr}, C.PTR_SIZEOF);
            *aValue = cast(PRUnichar*)ptr;

            if (valueAddr[0] !is null) {
                int rc = XPCOM.NS_GetServiceManager (&serviceManager);
                if (rc !is XPCOM.NS_OK) SWT.error (rc);
                if (serviceManager is null) SWT.error (XPCOM.NS_NOINTERFACE);
            
                //nsIServiceManager serviceManager = new nsIServiceManager (result2[0]);
                //result2[0] = 0;
                nsIMemory memory;
                //byte[] aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_MEMORY_CONTRACTID, true);
                rc = serviceManager.GetServiceByContractID (XPCOM.NS_MEMORY_CONTRACTID.ptr, &nsIMemory.IID, cast(void**)&memory);
                if (rc !is XPCOM.NS_OK) SWT.error (rc);
                if (memory is null) SWT.error (XPCOM.NS_NOINTERFACE);      
                serviceManager.Release ();
                
                //nsIMemory memory = new nsIMemory (result2[0]);
                //result2[0] = 0;
                memory.Free (valueAddr[0]);
                memory.Release ();
            }
        }
    }
    if (aCheckState !is null) *aCheckState = check;
    return XPCOM.NS_OK;
}

extern(System)
nsresult PromptAuth(nsIDOMWindow aParent, nsIChannel aChannel, PRUint32 level, nsIAuthInformation authInfo, PRUnichar* checkboxLabel, PRBool* checkboxValue, PRBool* _retval) {
    Browser browser = getBrowser (aParent);
    String checkLabel = null;
    //int[] checkValue = new int[1];
    //String[] userLabel = new String[1], passLabel = new String[1];
    int checkValue;
    String userLabel, passLabel;
    //String title = SWT.getMessage ("SWT_Authentication_Required"); //$NON-NLS-1$
    String title = "Authentication Required";

    if (checkboxLabel !is null && checkboxValue !is null) {
        //int span = XPCOM.strlen_PRUnichar (checkboxLabel);
        //char[] dest = new char[length];
        //XPCOM.memmove (dest, checkboxLabel, length * 2);
        checkLabel = String_valueOf (fromString16z(checkboxLabel));
        checkValue = *checkboxValue; /* PRBool */
    }

    /* get initial username and password values */

    //nsIAuthInformation auth = new nsIAuthInformation (authInfo);

    scope auto ptr1 = new nsEmbedString;
    int rc = authInfo.GetUsername (cast(nsAString*)ptr1);
    if (rc !is XPCOM.NS_OK) SWT.error (rc);
    //int length = XPCOM.nsEmbedString_Length (ptr);
    //ptrdiff_t buffer = XPCOM.nsEmbedString_get (ptr);
    //char[] chars = new char[length];
    //XPCOM.memmove (chars, buffer, length * 2);
    userLabel = ptr1.toString;
    //XPCOM.nsEmbedString_delete (ptr);

    scope auto ptr2 = new nsEmbedString;
    rc = authInfo.GetPassword (cast(nsAString*)ptr2);
    if (rc !is XPCOM.NS_OK) SWT.error (rc);
    //length = XPCOM.nsEmbedString_Length (ptr);
    //buffer = XPCOM.nsEmbedString_get (ptr);
    //chars = new char[length];
    //XPCOM.memmove (chars, buffer, length * 2);
    passLabel = ptr2.toString;
    //XPCOM.nsEmbedString_delete (ptr);

    /* compute the message text */

    scope auto ptr3 = new nsEmbedString;
    rc = authInfo.GetRealm (cast(nsAString*)ptr3);
    if (rc !is XPCOM.NS_OK) SWT.error (rc);
    //length = XPCOM.nsEmbedString_Length (ptr);
    //buffer = XPCOM.nsEmbedString_get (ptr);
    //chars = new char[length];
    //XPCOM.memmove (chars, buffer, length * 2);
    String realm = ptr3.toString;
    //XPCOM.nsEmbedString_delete (ptr);

    //nsIChannel channel = new nsIChannel (aChannel);
    nsIURI uri;
    rc = aChannel.GetURI (&uri);
    if (rc !is XPCOM.NS_OK) SWT.error (rc);
    if (uri is null) Mozilla.error (XPCOM.NS_NOINTERFACE);

    //nsIURI nsURI = new nsIURI (uri[0]);
    scope auto aSpec = new nsEmbedCString;
    rc = uri.GetHost (cast(nsACString*)aSpec);
    if (rc !is XPCOM.NS_OK) SWT.error (rc);
    //length = XPCOM.nsEmbedCString_Length (aSpec);
    //buffer = XPCOM.nsEmbedCString_get (aSpec);
    //byte[] bytes = new byte[length];
    //XPCOM.memmove (bytes, buffer, length);
    //XPCOM.nsEmbedCString_delete (aSpec);
    String host = aSpec.toString;
    uri.Release ();

    String message;
    if (realm.length () > 0 && host.length () > 0) {
        //message = Compatibility.getMessage ("SWT_Enter_Username_and_Password", new String[] {realm, host}); //$NON-NLS-1$
        message = Format("Enter user name and password for {0} at {1}",realm, host);
    } else {
        message = ""; //$NON-NLS-1$
    }

    /* open the prompter */
    Shell shell = browser is null ? new Shell () : browser.getShell ();
    PromptDialog dialog = new PromptDialog (shell);
    int result;
    dialog.promptUsernameAndPassword (title, message, checkLabel, userLabel, passLabel, checkValue, result);

    //XPCOM.memmove (_retval, result, 4); /* PRBool */
    *_retval = result;
    if (result is 1) {   /* User selected OK */
        scope auto string1 = new nsEmbedString (toWCharArray(userLabel));
        rc = authInfo.SetUsername(cast(nsAString*)string1);
        if (rc !is XPCOM.NS_OK) SWT.error (rc);
        //string.dispose ();
        
        scope auto string2 = new nsEmbedString (toWCharArray(passLabel));
        rc = authInfo.SetPassword(cast(nsAString*)string2);
        if (rc !is XPCOM.NS_OK) SWT.error (rc);
        //string.dispose ();
    }

    if (checkboxValue !is null) *checkboxValue = checkValue; /* PRBool */
    return XPCOM.NS_OK;
}

extern(System)
nsresult PromptUsernameAndPassword (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRUnichar** aUsername, PRUnichar** aPassword, PRUnichar* aCheckMsg, PRBool* aCheckState, PRBool* _retval) {
    Browser browser = getBrowser (aParent);
    String titleLabel, textLabel, checkLabel = null;
    String userLabel, passLabel;
    char[] dest;
    int span;
    if (aDialogTitle !is null) {
        //span = XPCOM.strlen_PRUnichar (aDialogTitle);
        //dest = new char[length];
        //XPCOM.memmove (dest, aDialogTitle, length * 2);
        titleLabel = String_valueOf (fromString16z(aDialogTitle));
    } else {
        //titleLabel = SWT.getMessage ("SWT_Authentication_Required");    //$NON-NLS-1$
        titleLabel = "Authentication Required";
    }
    
    //span = XPCOM.strlen_PRUnichar (aText);
    //dest = new char[length];
    //XPCOM.memmove (dest, aText, length * 2);
    textLabel = String_valueOf (fromString16z(aText));
    
    //ptrdiff_t[] userAddr = new ptrdiff_t[1];
    //XPCOM.memmove (userAddr, aUsername, C.PTR_SIZEOF);
    auto userAddr = *aUsername;
    if (*aUsername !is null) {
            //span = XPCOM.strlen_PRUnichar (userAddr[0]);
            //dest = new char[length];
            //XPCOM.memmove (dest, userAddr[0], length * 2);
            userLabel = String_valueOf(fromString16z(*aUsername));       
    }
    
    //ptrdiff_t[] passAddr = new ptrdiff_t[1];
    //XPCOM.memmove (passAddr, aPassword, C.PTR_SIZEOF);
    auto passAddr = *aPassword;
    if (*aPassword !is null) {
            //span = XPCOM.strlen_PRUnichar (passAddr[0]);
            //dest = new char[length];
            //XPCOM.memmove (dest, passAddr[0], length * 2);
            passLabel = String_valueOf(fromString16z(*aPassword));       
    }
    
    if (aCheckMsg !is null) {
        //span = XPCOM.strlen_PRUnichar (aCheckMsg);
        //if (span > 0) {
            //dest = new char[length];
            //XPCOM.memmove (dest, aCheckMsg, length * 2);
        checkLabel = String_valueOf (fromString16z(aCheckMsg));
        //}
    }

    Shell shell = browser is null ? new Shell () : browser.getShell ();
    PromptDialog dialog = new PromptDialog (shell);
    int check, result;
    if (aCheckState !is null) check = *aCheckState;   /* PRBool */
    dialog.promptUsernameAndPassword (titleLabel, textLabel, checkLabel, /*ref*/ userLabel, /*ref*/ passLabel, check, result);

    *_retval = result; /* PRBool */
    if (result is 1) {
        /* 
        * User selected OK. User name and password are returned as PRUnichar values. Any default
        * value that we override must be freed using the nsIMemory service.
        */
        int cnt, size;
        void* ptr;
        wchar[] buffer;
        ptrdiff_t[] result2 = new ptrdiff_t[1];
        if (userLabel !is null) {
            //cnt = userLabel[0].length ();
            //buffer = new char[cnt + 1];
            //buffer = toWCharArray(userLabel);
            //userLabel[0].getChars (0, cnt, buffer, 0);
            //size = buffer.length * 2;
            //ptr = tango.stdc.stdlib.malloc (size);
            //(cast(wchar*)ptr)[0 .. buffer.length] = buffer[0 .. $];
            //XPCOM.memmove (ptr, buffer, size);
            *aUsername = toString16z(toWCharArray(userLabel));
            //XPCOM.memmove (aUsername, new ptrdiff_t[] {ptr}, C.PTR_SIZEOF);
            nsIServiceManager serviceManager;
            
            if (userAddr !is null) {
                int rc = XPCOM.NS_GetServiceManager (&serviceManager);
                if (rc !is XPCOM.NS_OK) SWT.error (rc);
                if (serviceManager is null) SWT.error (XPCOM.NS_NOINTERFACE);
            
                //nsIServiceManager serviceManager = new nsIServiceManager (result2[0]);
                //result2[0] = 0;
                //byte[] aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_MEMORY_CONTRACTID, true);
                nsIMemory memory;
                rc = serviceManager.GetServiceByContractID (XPCOM.NS_MEMORY_CONTRACTID.ptr, &nsIMemory.IID, cast(void**)&memory);
                if (rc !is XPCOM.NS_OK) SWT.error (rc);
                if (memory is null) SWT.error (XPCOM.NS_NOINTERFACE);       
                serviceManager.Release ();
                
                //nsIMemory memory = new nsIMemory (result2[0]);
                //result2[0] = 0;
                memory.Free (userAddr);
                memory.Release ();
            }
        }
        if (passLabel !is null) {
            //cnt = passLabel[0].length ();
            //buffer = new char[cnt + 1];
            //buffer = toWCharArray( passLabel );
            //passLabel[0].getChars (0, cnt, buffer, 0);
            //size = buffer.length * 2;
            //ptr = tango.stdc.stdlib.malloc (size);
            //(cast(wchar*)ptr)[0 .. buffer.length] = buffer[0 .. $];
            //XPCOM.memmove (ptr, buffer, size);
            *aPassword = toString16z(toWCharArray(passLabel));
            //XPCOM.memmove (aPassword, new ptrdiff_t[] {ptr}, C.PTR_SIZEOF);
            
            nsIServiceManager serviceManager;
            if (passAddr !is null) {
                int rc = XPCOM.NS_GetServiceManager (&serviceManager);
                if (rc !is XPCOM.NS_OK) SWT.error (rc);
                if (serviceManager is null) SWT.error (XPCOM.NS_NOINTERFACE);

                //nsIServiceManager serviceManager = new nsIServiceManager (result2[0]);
                //result2[0] = 0;
                //byte[] aContractID = MozillaDelegate.wcsToMbcs (null, XPCOM.NS_MEMORY_CONTRACTID, true);
                nsIMemory memory;
                rc = serviceManager.GetServiceByContractID (XPCOM.NS_MEMORY_CONTRACTID.ptr, &nsIMemory.IID, cast(void**)&memory);
                if (rc !is XPCOM.NS_OK) SWT.error (rc);
                if (memory is null) SWT.error (XPCOM.NS_NOINTERFACE);      
                serviceManager.Release ();

                //nsIMemory memory = new nsIMemory (result2[0]);
                //result2[0] = 0;
                memory.Free (passAddr);
                memory.Release ();
            }
        }
    }
    if (aCheckState !is null) *aCheckState = check; /* PRBool */
    return XPCOM.NS_OK;
}

extern(System)
nsresult PromptPassword (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRUnichar** aPassword, PRUnichar* aCheckMsg, PRBool* aCheckState, PRBool* _retval) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

extern(System)
nsresult Select (nsIDOMWindow aParent, PRUnichar* aDialogTitle, PRUnichar* aText, PRUint32 aCount, PRUnichar** aSelectList, PRInt32* aOutSelection, PRBool* _retval) {
    return XPCOM.NS_ERROR_NOT_IMPLEMENTED;
}

}
