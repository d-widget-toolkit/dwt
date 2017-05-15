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
module org.eclipse.swt.dnd.FileTransfer;

import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.dnd.ByteArrayTransfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.dnd.DND;
import java.lang.all;

/**
 * The class <code>FileTransfer</code> provides a platform specific mechanism
 * for converting a list of files represented as a java <code>String[]</code> to a
 * platform specific representation of the data and vice versa.
 * Each <code>String</code> in the array contains the absolute path for a single
 * file or directory.
 *
 * <p>An example of a java <code>String[]</code> containing a list of files is shown
 * below:</p>
 *
 * <code><pre>
 *     File file1 = new File("C:\temp\file1");
 *     File file2 = new File("C:\temp\file2");
 *     String[] fileData = new String[2];
 *     fileData[0] = file1.getAbsolutePath();
 *     fileData[1] = file2.getAbsolutePath();
 * </code></pre>
 *
 * @see Transfer
 */
public class FileTransfer : ByteArrayTransfer {

    private static FileTransfer _instance;
    private static const String URI_LIST = "text/uri-list"; //$NON-NLS-1$
    private static const int URI_LIST_ID;
    private static const String separator = "\r\n";

static this(){
    URI_LIST_ID = registerType(URI_LIST);
    _instance = new FileTransfer();
}

private this() {}

/**
 * Returns the singleton instance of the FileTransfer class.
 *
 * @return the singleton instance of the FileTransfer class
 */
public static FileTransfer getInstance () {
    return _instance;
}

/**
 * This implementation of <code>javaToNative</code> converts a list of file names
 * represented by a java <code>String[]</code> to a platform specific representation.
 * Each <code>String</code> in the array contains the absolute path for a single
 * file or directory.
 *
 * @param object a java <code>String[]</code> containing the file names to be converted
 * @param transferData an empty <code>TransferData</code> object that will
 *      be filled in on return with the platform specific format of the data
 *
 * @see Transfer#nativeToJava
 */
public override void javaToNative(Object object, TransferData transferData) {
    transferData.result = 0;
    if (!checkFile(object) || !isSupportedType(transferData)) {
        DND.error(DND.ERROR_INVALID_DATA);
    }
    String[] files = (cast(ArrayWrapperString2)object).array;
    char[] buffer;
    for (int i = 0; i < files.length; i++) {
        String string = files[i];
        if (string.ptr is null) continue;
        if (string.length is 0) continue;
        GError* error;
        auto localePtr = OS.g_filename_from_utf8(string.ptr, -1, null, null, &error);
        if (error !is null || localePtr is null) continue;
        auto uriPtr = OS.g_filename_to_uri(localePtr, null, &error);
        OS.g_free(localePtr);
        if (error !is null || uriPtr is null) continue;
        String temp = fromStringz( uriPtr )._idup();
        OS.g_free(uriPtr);
        size_t newLength = (i > 0) ? buffer.length+separator.length+temp.length :  temp.length;
        auto newBuffer = new char[newLength];
        size_t offset = 0;
        if (i > 0) {
            System.arraycopy(buffer, 0, newBuffer, 0, buffer.length);
            offset +=  buffer.length;
            System.arraycopy(separator, 0, newBuffer, offset, separator.length);
            offset += separator.length;
        }
        System.arraycopy(temp, 0, newBuffer, offset, temp.length);
        buffer = newBuffer;
    }
    if (buffer.length is 0) return;
    char* ptr = cast(char*)OS.g_malloc(buffer.length+1);
    ptr[ 0 .. buffer.length ] = buffer;
    ptr[ buffer.length ] = '\0';
    transferData.pValue = ptr;
    transferData.length = cast(int)/*64bit*/buffer.length;
    transferData.format = 8;
    transferData.result = 1;
}
/**
 * This implementation of <code>nativeToJava</code> converts a platform specific
 * representation of a list of file names to a java <code>String[]</code>.
 * Each String in the array contains the absolute path for a single file or directory.
 *
 * @param transferData the platform specific representation of the data to be converted
 * @return a java <code>String[]</code> containing a list of file names if the conversion
 *      was successful; otherwise null
 *
 * @see Transfer#javaToNative
 */
public override Object nativeToJava(TransferData transferData) {
    if ( !isSupportedType(transferData) ||  transferData.pValue is null ||  transferData.length <= 0 ) return null;
    auto temp = transferData.pValue[ 0 .. transferData.length ];
    char*[] files;
    int offset = 0;
    for (int i = 0; i < temp.length - 1; i++) {
        if (temp[i] is '\r' && temp[i+1] is '\n') {
            int size =  i - offset;
            char* file = cast(char*)OS.g_malloc(size + 1);
            file[ 0 .. size ] = temp[ offset .. offset+size ];
            file[ size ] = '\0';
            files ~= file;
            offset = i + 2;
        }
    }
    if (offset < temp.length - 2) {
        auto size =  temp.length - offset;
        char* file = cast(char*)OS.g_malloc(size + 1);
        file[ 0 .. size ] = temp[ offset .. offset+size ];
        file[ size ] = '\0';
        files ~= file;
    }
    String[] fileNames;
    for (int i = 0; i < files.length; i++) {
        GError* error;
        auto localePtr = OS.g_filename_from_uri(files[i], null, &error);
        OS.g_free(files[i]);
        if (error !is null || localePtr is null) continue;
        auto utf8Ptr = OS.g_filename_to_utf8(localePtr, -1, null, null, &error);
        OS.g_free(localePtr);
        if (error !is null || utf8Ptr is null) continue;
        String buffer = fromStringz( utf8Ptr )._idup();
        OS.g_free(utf8Ptr);
        String name = buffer;
        String[] newFileNames = new String[]( fileNames.length + 1 );
        System.arraycopy(fileNames, 0, newFileNames, 0, fileNames.length);
        newFileNames[fileNames.length] = name;
        fileNames = newFileNames;
    }
    if (fileNames.length is 0) return null;
    return new ArrayWrapperString2( fileNames );
}

protected override int[] getTypeIds(){
    return [URI_LIST_ID];
}

protected override String[] getTypeNames(){
    return [URI_LIST];
}

bool checkFile(Object object) {
    if( object is null ) return false;
    ArrayWrapperString2 arr = cast(ArrayWrapperString2)object;
    if( arr is null ) return false;
    if( arr.array.length is 0 ) return false;

    String[] strings = arr.array;
    for (int i = 0; i < strings.length; i++) {
        if (strings[i] is null || strings[i].length is 0) return false;
    }
    return true;
}

protected override bool validate(Object object) {
    return checkFile(object);
}
}
