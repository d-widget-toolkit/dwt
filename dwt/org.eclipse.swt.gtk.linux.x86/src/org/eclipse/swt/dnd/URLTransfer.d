/*******************************************************************************
 * Copyright (c) 2007, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module org.eclipse.swt.dnd.URLTransfer;

import org.eclipse.swt.internal.gtk.OS;

import org.eclipse.swt.dnd.ByteArrayTransfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.dnd.DND;

import java.lang.all;

/**
 * The class <code>URLTransfer</code> provides a platform specific mechanism
 * for converting text in URL format represented as a java <code>String</code>
 * to a platform specific representation of the data and vice versa.  See
 * <code>Transfer</code> for additional information. The string
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
    private static const String TEXT_UNICODE = "text/unicode"; //$NON-NLS-1$
    private static const String TEXT_XMOZURL = "text/x-moz-url"; //$NON-NLS-1$
    private static int TEXT_UNICODE_ID;
    private static int TEXT_XMOZURL_ID;

static this(){
    TEXT_UNICODE_ID = registerType(TEXT_UNICODE);
    TEXT_XMOZURL_ID = registerType(TEXT_XMOZURL);
    _instance = new URLTransfer();
}

private this() {}

/**
 * Returns the singleton instance of the URLTransfer class.
 *
 * @return the singleton instance of the URLTransfer class
 */
public static URLTransfer getInstance () {
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
    transferData.result = 0;
    if (!checkURL(object) || !isSupportedType(transferData)) {
        DND.error(DND.ERROR_INVALID_DATA);
    }
    String16 string = stringcast(object).toWCharArray();
    auto byteCount = (string.length+1)*2;
    wchar* pValue = cast(wchar*)OS.g_malloc(byteCount);
    if (pValue is null) return;
    pValue[ 0 .. string.length ] = string[];
    pValue[ string.length ] = '\0';
    transferData.length = cast(int)/*64bit*/byteCount;
    transferData.format = 8;
    transferData.pValue = cast(char*)pValue;
    transferData.result = 1;
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
    if (!isSupportedType(transferData) ||  transferData.pValue is null) return null;
    /* Ensure byteCount is a multiple of 2 bytes */
    int size = (transferData.format * transferData.length / 8) / 2 * 2;
    if (size <= 0) return null;
    // The string can be terminated with NULL or it is as a maximum of length size
    for( int i = 0; i < size; i++ ){
        if( (cast(wchar*)transferData.pValue)[i] == '\0' ){
            size = i;
            break;
        }
    }
    String string = String_valueOf((cast(wchar*)transferData.pValue)[ 0 .. size ]);
    return new ArrayWrapperString( string );
}

override
protected int[] getTypeIds(){
    return [TEXT_XMOZURL_ID, TEXT_UNICODE_ID];
}

override
protected String[] getTypeNames(){
    return [TEXT_XMOZURL, TEXT_UNICODE];
}

bool checkURL(Object object) {
    return object !is null && (null !is cast(ArrayWrapperString)object) && (cast(ArrayWrapperString)object).array.length > 0;
}

override
protected bool validate(Object object) {
    return checkURL(object);
}
}
