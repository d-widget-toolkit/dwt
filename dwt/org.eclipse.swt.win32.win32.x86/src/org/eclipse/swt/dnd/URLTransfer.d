/*******************************************************************************
 * Copyright (c) 2000, 20007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module org.eclipse.swt.dnd.URLTransfer;

import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.OBJIDL;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.dnd.ByteArrayTransfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.dnd.DND;

import java.lang.all;

/**
 * The class <code>URLTransfer</code> provides a platform specific mechanism
 * for converting text in URL format represented as a java <code>String</code> 
 * to a platform specific representation of the data and vice versa. The string
 * must contain a fully specified url.
 *
 * <p>An example of a java <code>String</code> containing a URL is shown below:</p>
 *
 * <code><pre>
 *     String url = "http://www.eclipse.org";
 * </code></pre>
 *
 * @see Transfer
 */
public class URLTransfer : ByteArrayTransfer {

    static URLTransfer _instance;
    static const String CFSTR_INETURL = "UniformResourceLocator"; //$NON-NLS-1$
    mixin(gshared!(`static const int CFSTR_INETURLID;`));

mixin(sharedStaticThis!(`{
    CFSTR_INETURLID = registerType(CFSTR_INETURL);
}`));

private this() {}

/**
 * Returns the singleton instance of the URLTransfer class.
 *
 * @return the singleton instance of the URLTransfer class
 */
public static URLTransfer getInstance () {
    if( _instance is null ){
        synchronized {
            if( _instance is null ){
                _instance = new URLTransfer();
            }
        }
    }
    return _instance;
}

/**
 * This implementation of <code>javaToNative</code> converts a URL
 * represented by a java <code>String</code> to a platform specific representation.
 *
 * @param object a java <code>String</code> containing a URL
 * @param transferData an empty <code>TransferData</code> object that will
 *      be filled in on return with the platform specific format of the data
 * 
 * @see Transfer#nativeToJava
 */
override
public void javaToNative (Object object, TransferData transferData){
    if (!checkURL(object) || !isSupportedType(transferData)) {
        DND.error(DND.ERROR_INVALID_DATA);
    }
    transferData.result = COM.E_FAIL;
    // URL is stored as a null terminated byte array
    String url = stringcast(object);
    int codePage = OS.GetACP();
    String16 chars = StrToWCHARs(codePage, url, true );
    int cchMultiByte = OS.WideCharToMultiByte(codePage, 0, chars.ptr, -1, null, 0, null, null);
    if (cchMultiByte is 0) {
        transferData.stgmedium = new STGMEDIUM();
        transferData.result = COM.DV_E_STGMEDIUM;
        return;
    }
    auto lpMultiByteStr = cast(CHAR*)OS.GlobalAlloc(OS.GMEM_FIXED | OS.GMEM_ZEROINIT, cchMultiByte);
    OS.WideCharToMultiByte(codePage, 0, chars.ptr, -1, lpMultiByteStr, cchMultiByte, null, null);
    transferData.stgmedium = new STGMEDIUM();
    transferData.stgmedium.tymed = COM.TYMED_HGLOBAL;
    transferData.stgmedium.unionField = lpMultiByteStr;
    transferData.stgmedium.pUnkForRelease = null;
    transferData.result = COM.S_OK;
    return;
}

/**
 * This implementation of <code>nativeToJava</code> converts a platform 
 * specific representation of a URL to a java <code>String</code>.
 * 
 * @param transferData the platform specific representation of the data to be converted
 * @return a java <code>String</code> containing a URL if the conversion was successful;
 *      otherwise null
 * 
 * @see Transfer#javaToNative
 */
override
public Object nativeToJava(TransferData transferData){
    if (!isSupportedType(transferData) || transferData.pIDataObject is null) return null;
    IDataObject data = transferData.pIDataObject;
    data.AddRef();
    STGMEDIUM* stgmedium = new STGMEDIUM();
    FORMATETC* formatetc = transferData.formatetc;
    stgmedium.tymed = COM.TYMED_HGLOBAL;
    transferData.result = getData(data, formatetc, stgmedium);
    data.Release();
    if (transferData.result !is COM.S_OK) return null;
    auto hMem = stgmedium.unionField;
    try {
        auto lpMultiByteStr = cast(CHAR*)OS.GlobalLock(hMem);
        if (lpMultiByteStr is null) return null;
        try {
            int codePage = OS.GetACP();
            int cchWideChar  = OS.MultiByteToWideChar (codePage, OS.MB_PRECOMPOSED, lpMultiByteStr, -1, null, 0);
            if (cchWideChar is 0) return null;
            wchar[] lpWideCharStr = new wchar [cchWideChar - 1];
            OS.MultiByteToWideChar (codePage, OS.MB_PRECOMPOSED, lpMultiByteStr, -1, lpWideCharStr.ptr, cast(int)/*64bit*/lpWideCharStr.length);
            return new ArrayWrapperString( WCHARzToStr( lpWideCharStr.ptr) );
        } finally {
            OS.GlobalUnlock(hMem);
        }
    } finally {
        OS.GlobalFree(hMem);
    }
}

override
protected int[] getTypeIds(){
    return [CFSTR_INETURLID];
}

override
protected String[] getTypeNames(){
    return [CFSTR_INETURL];
}

bool checkURL(Object object) {
    return object !is null && (null !is cast(ArrayWrapperString)object) && (cast(ArrayWrapperString)object).array.length > 0;

}

override
protected bool validate(Object object) {
    return checkURL(object);
}
}
