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

import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.OBJIDL;
import org.eclipse.swt.internal.win32.OS;

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
    private static const String CF_HDROP = "CF_HDROP "; //$NON-NLS-1$
    private static const int CF_HDROPID = COM.CF_HDROP;
    private static const String CF_HDROP_SEPARATOR = "\0"; //$NON-NLS-1$

private this() {}

/**
 * Returns the singleton instance of the FileTransfer class.
 *
 * @return the singleton instance of the FileTransfer class
 */
public static FileTransfer getInstance () {
    if( _instance is null ){
        synchronized {
            if( _instance is null ){
                _instance = new FileTransfer();
            }
        }
    }
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
override
public void javaToNative(Object object, TransferData transferData) {
    if (!checkFile(object) || !isSupportedType(transferData)) {
        DND.error(DND.ERROR_INVALID_DATA);
    }
    String[] fileNames;
    if( auto strs = cast(ArrayWrapperString2) object ){
        fileNames = strs.array;
    }
    StringBuffer allFiles = new StringBuffer();
    for (int i = 0; i < fileNames.length; i++) {
        allFiles.append(fileNames[i]);
        allFiles.append(CF_HDROP_SEPARATOR); // each name is null terminated
    }
    StringT buffer = StrToTCHARs(0, allFiles.toString(), true); // there is an extra null terminator at the very end
    DROPFILES dropfiles;
    dropfiles.pFiles = DROPFILES.sizeof;
    dropfiles.pt.x = dropfiles.pt.y = 0;
    dropfiles.fNC = 0;
    dropfiles.fWide = OS.IsUnicode ? 1 : 0;
    // Allocate the memory because the caller (DropTarget) has not handed it in
    // The caller of this method must release the data when it is done with it.
    auto byteCount = buffer.length * TCHAR.sizeof;
    auto newPtr = OS.GlobalAlloc(COM.GMEM_FIXED | COM.GMEM_ZEROINIT, DROPFILES.sizeof + byteCount);
    OS.MoveMemory(newPtr, &dropfiles, DROPFILES.sizeof);
    OS.MoveMemory(newPtr + DROPFILES.sizeof, buffer.ptr, byteCount);
    transferData.stgmedium = new STGMEDIUM();
    transferData.stgmedium.tymed = COM.TYMED_HGLOBAL;
    transferData.stgmedium.unionField = newPtr;
    transferData.stgmedium.pUnkForRelease = null;
    transferData.result = COM.S_OK;
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
override
public Object nativeToJava(TransferData transferData) {
    if (!isSupportedType(transferData) || transferData.pIDataObject is null)  return null;

    // get file names from IDataObject
    IDataObject dataObject = transferData.pIDataObject;
    dataObject.AddRef();
    FORMATETC* formatetc = new FORMATETC();
    formatetc.cfFormat = COM.CF_HDROP;
    formatetc.ptd = null;
    formatetc.dwAspect = COM.DVASPECT_CONTENT;
    formatetc.lindex = -1;
    formatetc.tymed = COM.TYMED_HGLOBAL;
    STGMEDIUM* stgmedium = new STGMEDIUM();
    stgmedium.tymed = COM.TYMED_HGLOBAL;
    transferData.result = getData(dataObject, formatetc, stgmedium);
    dataObject.Release();
    if (transferData.result !is COM.S_OK) return null;
    // How many files are there?
    int count = OS.DragQueryFile(stgmedium.unionField, cast(TCHAR*)-1, null, 0);
    String[] fileNames = new String[](count);
    for (int i = 0; i < count; i++) {
        // How long is the name ?
        int size = OS.DragQueryFile(stgmedium.unionField, i, null, 0) + 1;
        TCHAR[] lpszFile = NewTCHARs(0, size);
        // Get file name and append it to string
        OS.DragQueryFile(stgmedium.unionField, i, lpszFile.ptr, size);
        fileNames[i] = TCHARzToStr(lpszFile.ptr);
    }
    OS.DragFinish(stgmedium.unionField); // frees data associated with HDROP data
    return new ArrayWrapperString2(fileNames);
}

override
protected int[] getTypeIds(){
    return [CF_HDROPID];
}

override
protected String[] getTypeNames(){
    return [CF_HDROP];
}
bool checkFile(Object object) {
    String[] strings;
    if( auto strs = cast(ArrayWrapperString2)object ){
        strings = strs.array;
    }
    if (!strings) return false;
    for (int i = 0; i < strings.length; i++) {
        if (strings[i] is null || strings[i].length is 0) return false;
    }
    return true;
}

override
protected bool validate(Object object) {
    return checkFile(object);
}
}
