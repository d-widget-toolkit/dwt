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
module org.eclipse.swt.dnd.ImageTransfer;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.OBJIDL;

import org.eclipse.swt.dnd.ByteArrayTransfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.dnd.DND;

import java.lang.all;

/**
 * The class <code>ImageTransfer</code> provides a platform specific mechanism
 * for converting an Image represented as a java <code>ImageData</code> to a 
 * platform specific representation of the data and vice versa.
 *
 * <p>An example of a java <code>ImageData</code> is shown below:</p>
 *
 * <code><pre>
 *     Image image = new Image(display, "C:\temp\img1.gif");
 *     ImageData imgData = image.getImageData();
 * </code></pre>
 *
 * @see Transfer
 * 
 * @since 3.4
 */
public class ImageTransfer : ByteArrayTransfer {

    mixin(gshared!(`private static ImageTransfer _instance;`));
    private static const String CF_DIB = "CF_DIB"; //$NON-NLS-1$
    private static const int CF_DIBID = COM.CF_DIB;

mixin(sharedStaticThis!(`{
     _instance = new ImageTransfer();
}`));

private this() {
}

/**
 * Returns the singleton instance of the ImageTransfer class.
 *
 * @return the singleton instance of the ImageTransfer class
 */
public static ImageTransfer getInstance () {
    return _instance;
}

/**
 * This implementation of <code>javaToNative</code> converts an ImageData object represented
 * by java <code>ImageData</code> to a platform specific representation.
 *
 * @param object a java <code>ImageData</code> containing the ImageData to be converted
 * @param transferData an empty <code>TransferData</code> object that will
 *      be filled in on return with the platform specific format of the data
 * 
 * @see Transfer#nativeToJava
 */
override
public void javaToNative(Object object, TransferData transferData) {
    if (!checkImage(object) || !isSupportedType(transferData)) {
        DND.error(DND.ERROR_INVALID_DATA);
    }
    ImageData imgData = cast(ImageData)object;
    if (imgData is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);

    int imageSize = cast(int)/*64bit*/imgData.data.length;
    int imageHeight = imgData.height;
    int bytesPerLine = imgData.bytesPerLine;

    BITMAPINFOHEADER bmiHeader;
    bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
    bmiHeader.biSizeImage = imageSize;
    bmiHeader.biWidth = imgData.width;
    bmiHeader.biHeight = imageHeight;
    bmiHeader.biPlanes = 1;
    bmiHeader.biBitCount = cast(short)imgData.depth;
    bmiHeader.biCompression = OS.DIB_RGB_COLORS;

    int colorSize = 0;
    if (bmiHeader.biBitCount <= 8) {
        colorSize += (1 << bmiHeader.biBitCount) * 4;
    }
    byte[] bmi = new byte[BITMAPINFOHEADER.sizeof + colorSize];
    OS.MoveMemory(bmi.ptr, &bmiHeader, BITMAPINFOHEADER.sizeof);

    RGB[] rgbs = imgData.palette.getRGBs();
    if (rgbs !is null && colorSize > 0) {
        int offset = BITMAPINFOHEADER.sizeof;
        for (int j = 0; j < rgbs.length; j++) {
            bmi[offset] = cast(byte)rgbs[j].blue;
            bmi[offset + 1] = cast(byte)rgbs[j].green;
            bmi[offset + 2] = cast(byte)rgbs[j].red;
            bmi[offset + 3] = 0;
            offset += 4;
        }
    }
    auto newPtr = OS.GlobalAlloc(OS.GMEM_FIXED | OS.GMEM_ZEROINIT, BITMAPINFOHEADER.sizeof + colorSize + imageSize);
    OS.MoveMemory(newPtr, bmi.ptr, bmi.length);
    auto pBitDest = newPtr + BITMAPINFOHEADER.sizeof + colorSize;

    if (imageHeight <= 0) {
        OS.MoveMemory(pBitDest, imgData.data.ptr, imageSize);
    } else {
        int offset = 0;
        pBitDest += bytesPerLine * (imageHeight - 1);
        byte[] scanline = new byte[bytesPerLine];
        for (int i = 0; i < imageHeight; i++) {
            System.arraycopy(imgData.data, offset, scanline, 0, bytesPerLine);
            OS.MoveMemory(pBitDest, scanline.ptr, bytesPerLine);
            offset += bytesPerLine;
            pBitDest -= bytesPerLine;
        }
    }
    transferData.stgmedium = new STGMEDIUM();
    transferData.stgmedium.tymed = COM.TYMED_HGLOBAL;
    transferData.stgmedium.unionField = newPtr;
    transferData.stgmedium.pUnkForRelease = null;
    transferData.result = COM.S_OK;
}


/**
 * This implementation of <code>nativeToJava</code> converts a platform specific
 * representation of an image to java <code>ImageData</code>.
 *
 * @param transferData the platform specific representation of the data to be converted
 * @return a java <code>ImageData</code> of the image if the conversion was successful;
 *      otherwise null
 * 
 * @see Transfer#javaToNative
 */
override
public Object nativeToJava(TransferData transferData) {
    if (!isSupportedType(transferData) || transferData.pIDataObject is null) return null;
    IDataObject dataObject = cast(IDataObject)(transferData.pIDataObject);
    dataObject.AddRef();
    FORMATETC* formatetc = new FORMATETC();
    formatetc.cfFormat = COM.CF_DIB;
    formatetc.ptd = null;
    formatetc.dwAspect = COM.DVASPECT_CONTENT;
    formatetc.lindex = -1;
    formatetc.tymed = COM.TYMED_HGLOBAL;
    STGMEDIUM* stgmedium = new STGMEDIUM();
    stgmedium.tymed = COM.TYMED_HGLOBAL;
    transferData.result = getData(dataObject, formatetc, stgmedium);

    if (transferData.result !is COM.S_OK) return null;
    HANDLE hMem = stgmedium.unionField;
    dataObject.Release();
    try {
        auto ptr = OS.GlobalLock(hMem);
        if (ptr is null) return null;
        try {
            BITMAPINFOHEADER bmiHeader;
            OS.MoveMemory(&bmiHeader, ptr, BITMAPINFOHEADER.sizeof);
            void* pBits;
            auto memDib = OS.CreateDIBSection(null,  cast(BITMAPINFO*)ptr, OS.DIB_RGB_COLORS, &pBits, null, 0);
            if (memDib is null) SWT.error(SWT.ERROR_NO_HANDLES);
            void* bits = ptr + bmiHeader.biSize;
            if (bmiHeader.biBitCount <= 8) {
                bits += (1 << bmiHeader.biBitCount) * 4;
            } else if (bmiHeader.biCompression is OS.BI_BITFIELDS) {
                bits += 12;
            }
            if (bmiHeader.biHeight < 0) {
                OS.MoveMemory(pBits, bits, bmiHeader.biSizeImage);
            } else {
                DIBSECTION dib;
                OS.GetObject(memDib, DIBSECTION.sizeof, &dib);
                int biHeight = dib.dsBmih.biHeight;
                int scanline = dib.dsBmih.biSizeImage / biHeight;
                auto pDestBits = pBits;
                auto pSourceBits = bits + scanline * (biHeight - 1);
                for (int i = 0; i < biHeight; i++) {
                    OS.MoveMemory(pDestBits, pSourceBits, scanline);
                    pDestBits += scanline;
                    pSourceBits -= scanline;
                }
            }
            Image image = Image.win32_new(null, SWT.BITMAP, memDib);
            ImageData data = image.getImageData();
            OS.DeleteObject(memDib);
            image.dispose();
            return data;
        } finally {
            OS.GlobalUnlock(hMem);
        }
    } finally {
        OS.GlobalFree(hMem);
    }
}

override
protected int[] getTypeIds(){
    return [CF_DIBID];
}

override
protected String[] getTypeNames(){
    return [CF_DIB];
}
bool checkImage(Object object) {
    if (object is null || !(null !is cast(ImageData)object ))  return false;
    return true;
}

override
protected bool validate(Object object) {
    return checkImage(object);
}
}

