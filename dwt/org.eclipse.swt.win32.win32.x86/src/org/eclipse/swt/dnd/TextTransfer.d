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
module org.eclipse.swt.dnd.TextTransfer;

import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.OBJIDL;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.dnd.ByteArrayTransfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.dnd.DND;

import java.lang.all;

/**
 * The class <code>TextTransfer</code> provides a platform specific mechanism
 * for converting plain text represented as a java <code>String</code>
 * to a platform specific representation of the data and vice versa.
 *
 * <p>An example of a java <code>String</code> containing plain text is shown
 * below:</p>
 *
 * <code><pre>
 *     String textData = "Hello World";
 * </code></pre>
 *
 * @see Transfer
 */
public class TextTransfer : ByteArrayTransfer {

    private static TextTransfer _instance;
    private static const String CF_UNICODETEXT = "CF_UNICODETEXT"; //$NON-NLS-1$
    private static const String CF_TEXT = "CF_TEXT"; //$NON-NLS-1$
    private static const int CF_UNICODETEXTID = COM.CF_UNICODETEXT;
    private static const int CF_TEXTID = COM.CF_TEXT;

private this() {}

/**
 * Returns the singleton instance of the TextTransfer class.
 *
 * @return the singleton instance of the TextTransfer class
 */
public static TextTransfer getInstance () {
    if( _instance is null ){
        synchronized {
            if( _instance is null ){
                _instance = new TextTransfer();
            }
        }
    }
    return _instance;
}

/**
 * This implementation of <code>javaToNative</code> converts plain text
 * represented by a java <code>String</code> to a platform specific representation.
 *
 * @param object a java <code>String</code> containing text
 * @param transferData an empty <code>TransferData</code> object that will
 *      be filled in on return with the platform specific format of the data
 *
 * @see Transfer#nativeToJava
 */
override
public void javaToNative (Object object, TransferData transferData){
    if (!checkText(object) || !isSupportedType(transferData)) {
        DND.error(DND.ERROR_INVALID_DATA);
    }
    transferData.result = COM.E_FAIL;
    String string = stringcast(object);
    switch (transferData.type) {
        case COM.CF_UNICODETEXT: {
            String16 chars = StrToWCHARs(0,string, true);
            int charCount = cast(int)/*64bit*/chars.length;
            int byteCount = cast(int)/*64bit*/chars.length * 2;
            auto newPtr = OS.GlobalAlloc(COM.GMEM_FIXED | COM.GMEM_ZEROINIT, byteCount);
            OS.MoveMemory(newPtr, chars.ptr, byteCount);
            transferData.stgmedium = new STGMEDIUM();
            transferData.stgmedium.tymed = COM.TYMED_HGLOBAL;
            transferData.stgmedium.unionField = newPtr;
            transferData.stgmedium.pUnkForRelease = null;
            transferData.result = COM.S_OK;
            break;
        }
        case COM.CF_TEXT: {
            String16 chars = StrToWCHARs(0,string, true);
            int count = cast(int)/*64bit*/chars.length;
            int codePage = OS.GetACP();
            int cchMultiByte = OS.WideCharToMultiByte(codePage, 0, chars.ptr, -1, null, 0, null, null);
            if (cchMultiByte is 0) {
                transferData.stgmedium = new STGMEDIUM();
                transferData.result = COM.DV_E_STGMEDIUM;
                return;
            }
            auto lpMultiByteStr = cast(CHAR*)OS.GlobalAlloc(COM.GMEM_FIXED | COM.GMEM_ZEROINIT, cchMultiByte);
            OS.WideCharToMultiByte(codePage, 0, chars.ptr, -1, lpMultiByteStr, cchMultiByte, null, null);
            transferData.stgmedium = new STGMEDIUM();
            transferData.stgmedium.tymed = COM.TYMED_HGLOBAL;
            transferData.stgmedium.unionField = lpMultiByteStr;
            transferData.stgmedium.pUnkForRelease = null;
            transferData.result = COM.S_OK;
            break;
        }
        default:
    }
    return;
}

/**
 * This implementation of <code>nativeToJava</code> converts a platform specific
 * representation of plain text to a java <code>String</code>.
 *
 * @param transferData the platform specific representation of the data to be converted
 * @return a java <code>String</code> containing text if the conversion was successful; otherwise null
 *
 * @see Transfer#javaToNative
 */
override
public Object nativeToJava(TransferData transferData){
    if (!isSupportedType(transferData) || transferData.pIDataObject is null) return null;

    IDataObject data = transferData.pIDataObject;
    data.AddRef();
    FORMATETC* formatetc = transferData.formatetc;
    STGMEDIUM* stgmedium = new STGMEDIUM();
    stgmedium.tymed = COM.TYMED_HGLOBAL;
    transferData.result = getData(data, formatetc, stgmedium);
    data.Release();
    if (transferData.result !is COM.S_OK) return null;
    auto hMem = stgmedium.unionField;
    try {
        switch (transferData.type) {
            case CF_UNICODETEXTID: {
                /* Ensure byteCount is a multiple of 2 bytes */
                auto size = OS.GlobalSize(hMem) / 2 * 2;
                if (size is 0) return null;
                wchar[] chars = new wchar[size/2];
                auto ptr = OS.GlobalLock(hMem);
                if (ptr is null) return null;
                try {
                    OS.MoveMemory(chars.ptr, ptr, size);
                    int length_ = cast(int)/*64bit*/chars.length;
                    for (int i=0; i<chars.length; i++) {
                        if (chars [i] is '\0') {
                            length_ = i;
                            break;
                        }
                    }
                    return new ArrayWrapperString (WCHARsToStr(chars[ 0 .. length_]));
                } finally {
                    OS.GlobalUnlock(hMem);
                }
            }
            case CF_TEXTID: {
                auto lpMultiByteStr = cast(CHAR*)OS.GlobalLock(hMem);
                if (lpMultiByteStr is null) return null;
                try {
                    int codePage = OS.GetACP();
                    int cchWideChar = OS.MultiByteToWideChar (codePage, OS.MB_PRECOMPOSED, lpMultiByteStr, -1, null, 0);
                    if (cchWideChar is 0) return null;
                    wchar[] lpWideCharStr = new wchar [cchWideChar - 1];
                    OS.MultiByteToWideChar (codePage, OS.MB_PRECOMPOSED, lpMultiByteStr, -1, lpWideCharStr.ptr, cast(int)/*64bit*/lpWideCharStr.length);
                    return new ArrayWrapperString( WCHARzToStr(lpWideCharStr.ptr));
                } finally {
                    OS.GlobalUnlock(hMem);
                }
            }
            default:
        }
    } finally {
        OS.GlobalFree(hMem);
    }
    return null;
}

override
protected int[] getTypeIds(){
    return [CF_UNICODETEXTID, CF_TEXTID];
}

override
protected String[] getTypeNames(){
    return [CF_UNICODETEXT, CF_TEXT];
}

bool checkText(Object object) {
    if( auto s = cast(ArrayWrapperString)object ){
        return s.array.length > 0;
    }
    return false;
}

override
protected bool validate(Object object) {
    return checkText(object);
}
}
