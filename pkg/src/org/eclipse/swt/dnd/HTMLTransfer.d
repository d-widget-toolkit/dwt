/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module org.eclipse.swt.dnd.HTMLTransfer;

import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.OBJIDL;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.dnd.ByteArrayTransfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.dnd.DND;

import java.lang.all;

/**
 * The class <code>HTMLTransfer</code> provides a platform specific mechanism
 * for converting text in HTML format represented as a java <code>String</code>
 * to a platform specific representation of the data and vice versa.
 *
 * <p>An example of a java <code>String</code> containing HTML text is shown
 * below:</p>
 *
 * <code><pre>
 *     String htmlData = "<p>This is a paragraph of text.</p>";
 * </code></pre>
 *
 * @see Transfer
 */
public class HTMLTransfer : ByteArrayTransfer {

    static HTMLTransfer _instance;
    static const String HTML_FORMAT = "HTML Format"; //$NON-NLS-1$
    mixin(gshared!(`static const int HTML_FORMATID;`));
    static const String NUMBER = "00000000"; //$NON-NLS-1$
    static const String HEADER = "Version:0.9\r\nStartHTML:"~NUMBER~"\r\nEndHTML:"~NUMBER~"\r\nStartFragment:"~NUMBER~"\r\nEndFragment:"~NUMBER~"\r\n";
    static const String PREFIX = "<html><body><!--StartFragment-->"; //$NON-NLS-1$
    static const String SUFFIX = "<!--EndFragment--></body></html>"; //$NON-NLS-1$
    static const String StartFragment = "StartFragment:"; //$NON-NLS-1$
    static const String EndFragment = "EndFragment:"; //$NON-NLS-1$

mixin(sharedStaticThis!(`{
    HTML_FORMATID = registerType(HTML_FORMAT);
}`));

private this() {}

/**
 * Returns the singleton instance of the HTMLTransfer class.
 *
 * @return the singleton instance of the HTMLTransfer class
 */
public static HTMLTransfer getInstance () {
    if( _instance is null ){
        synchronized {
            if( _instance is null ){
                _instance = new HTMLTransfer();
            }
        }
    }
    return _instance;
}

/**
 * This implementation of <code>javaToNative</code> converts HTML-formatted text
 * represented by a java <code>String</code> to a platform specific representation.
 *
 * @param object a java <code>String</code> containing HTML text
 * @param transferData an empty <code>TransferData</code> object that will
 *      be filled in on return with the platform specific format of the data
 * 
 * @see Transfer#nativeToJava
 */
override
public void javaToNative (Object object, TransferData transferData){
    if (!checkHTML(object) || !isSupportedType(transferData)) {
        DND.error(DND.ERROR_INVALID_DATA);
    }
    String string = stringcast(object );
    /* NOTE: CF_HTML uses UTF-8 encoding. */
    int cchMultiByte = OS.WideCharToMultiByte(OS.CP_UTF8, 0, StrToTCHARz(string), -1, null, 0, null, null);
    if (cchMultiByte is 0) {
        transferData.stgmedium = new STGMEDIUM();
        transferData.result = COM.DV_E_STGMEDIUM;
        return;
    }
    int startHTML = cast(int)/*64bit*/HEADER.length;
    int startFragment = startHTML + cast(int)/*64bit*/PREFIX.length;
    int endFragment = startFragment + cchMultiByte - 1;
    int endHTML = endFragment + cast(int)/*64bit*/SUFFIX.length;

    StringBuffer buffer = new StringBuffer(HEADER);
    int maxLength = cast(int)/*64bit*/NUMBER.length;
    //startHTML
    int start = buffer.toString().indexOf(NUMBER);
    String temp = Integer.toString(startHTML);
    buffer.replace(start + maxLength-temp.length(), start + maxLength, temp);

    //endHTML
    start = buffer.toString().indexOf(NUMBER, start);
    temp = Integer.toString(endHTML);
    buffer.replace(start + maxLength-temp.length(), start + maxLength, temp);

    //startFragment
    start = buffer.toString().indexOf(NUMBER, start);
    temp = Integer.toString(startFragment);
    buffer.replace(start + maxLength-temp.length(), start + maxLength, temp);
    //endFragment
    start = buffer.toString().indexOf(NUMBER, start);
    temp = Integer.toString(endFragment);
    buffer.replace(start + maxLength-temp.length(), start + maxLength, temp);

    buffer.append(PREFIX);
    buffer.append(string);
    buffer.append(SUFFIX);

    auto wstrz = StrToTCHARz(OS.CP_UTF8,buffer.toString);
    cchMultiByte = OS.WideCharToMultiByte(OS.CP_UTF8, 0, wstrz, -1, null, 0, null, null);
    auto lpMultiByteStr = cast(PCHAR) OS.GlobalAlloc(OS.GMEM_FIXED | OS.GMEM_ZEROINIT, cchMultiByte);
    OS.WideCharToMultiByte(OS.CP_UTF8, 0, wstrz, -1, lpMultiByteStr, cchMultiByte, null, null);
    transferData.stgmedium = new STGMEDIUM();
    transferData.stgmedium.tymed = COM.TYMED_HGLOBAL;
    transferData.stgmedium.unionField = lpMultiByteStr;
    transferData.stgmedium.pUnkForRelease = null;
    transferData.result = COM.S_OK;
    return;
}

/**
 * This implementation of <code>nativeToJava</code> converts a platform specific
 * representation of HTML text to a java <code>String</code>.
 *
 * @param transferData the platform specific representation of the data to be converted
 * @return a java <code>String</code> containing HTML text if the conversion was successful;
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
        auto lpMultiByteStr = cast(PCHAR) OS.GlobalLock(hMem);
        if (lpMultiByteStr is null) return null;
        try {
            /* NOTE: CF_HTML uses UTF-8 encoding.
             * The MSDN documentation for MultiByteToWideChar states that dwFlags must be set to 0 for UTF-8.
             * Otherwise, the function fails with ERROR_INVALID_FLAGS. */
            auto cchWideChar  = OS.MultiByteToWideChar (OS.CP_UTF8, 0, lpMultiByteStr, -1, null, 0);
            if (cchWideChar is 0) return null;
            wchar[] lpWideCharStr = new wchar [cchWideChar - 1];
            OS.MultiByteToWideChar (OS.CP_UTF8, 0, lpMultiByteStr, -1, lpWideCharStr.ptr, cast(int)/*64bit*/lpWideCharStr.length);
            String string = WCHARzToStr(lpWideCharStr.ptr);
            int fragmentStart = 0, fragmentEnd = 0;
            int start = string.indexOf(StartFragment) + cast(int)/*64bit*/StartFragment.length;
            int end = start + 1;
            while (end < string.length) {
                String s = string.substring(start, end);
                try {
                    fragmentStart = Integer.parseInt(s);
                    end++;
                } catch (NumberFormatException e) {
                    break;
                }
            }
            start = string.indexOf(EndFragment) + cast(int)/*64bit*/EndFragment.length;
            end = start + 1;
            while (end < string.length) {
                String s = string.substring(start, end);
                try {
                    fragmentEnd = Integer.parseInt(s);
                    end++;
                } catch (NumberFormatException e) {
                    break;
                }
            }
            if (fragmentEnd <= fragmentStart || fragmentEnd > OS.strlen(lpMultiByteStr)) return null;
            cchWideChar = OS.MultiByteToWideChar (OS.CP_UTF8, 0, lpMultiByteStr+fragmentStart, fragmentEnd - fragmentStart, lpWideCharStr.ptr, cast(int)/*64bit*/lpWideCharStr.length);
            if (cchWideChar is 0) return null;
            String s = TCHARsToStr( lpWideCharStr[ 0 .. cchWideChar ] );
            /*
             * Firefox includes <!--StartFragment --> in the fragment, so remove it.
             */
            String foxStart = "<!--StartFragment -->\r\n"; //$NON-NLS-1$
            int prefix = s.indexOf(foxStart);
            if (prefix !is -1) {
                prefix += foxStart.length;
                s = s.substring(prefix);
            }
            return new ArrayWrapperString(s);
        } finally {
            OS.GlobalUnlock(hMem);
        }
    } finally {
        OS.GlobalFree(hMem);
    }
}
override
protected int[] getTypeIds(){
    return [HTML_FORMATID];
}
override
protected String[] getTypeNames(){
    return [HTML_FORMAT];
}
bool checkHTML(Object object) {
    if( auto ws = cast(ArrayWrapperString)object ){
        return ws.array.length > 0;
    }
    return false;
}
override
protected bool validate(Object object) {
    return checkHTML(object);
}
}
