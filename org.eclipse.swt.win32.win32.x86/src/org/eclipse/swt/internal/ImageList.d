/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
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
module org.eclipse.swt.internal.ImageList;


import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.win32.OS;

import java.lang.all;
import java.lang.System;

public class ImageList {
    HIMAGELIST handle;
    int style, refCount;
    Image [] images;

public this (int style) {
    this.style = style;
    int flags = OS.ILC_MASK;
    static if (OS.IsWinCE) {
        flags |= OS.ILC_COLOR;
    } else {
        if (OS.COMCTL32_MAJOR >= 6) {
            flags |= OS.ILC_COLOR32;
        } else {
            auto hDC = OS.GetDC (null);
            auto bits = OS.GetDeviceCaps (hDC, OS.BITSPIXEL);
            auto planes = OS.GetDeviceCaps (hDC, OS.PLANES);
            OS.ReleaseDC (null, hDC);
            int depth = bits * planes;
            switch (depth) {
                case 4: flags |= OS.ILC_COLOR4; break;
                case 8: flags |= OS.ILC_COLOR8; break;
                case 16: flags |= OS.ILC_COLOR16; break;
                case 24: flags |= OS.ILC_COLOR24; break;
                case 32: flags |= OS.ILC_COLOR32; break;
                default: flags |= OS.ILC_COLOR; break;
            }
        }
    }
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) flags |= OS.ILC_MIRROR;
    handle = OS.ImageList_Create (32, 32, flags, 16, 16);
    images = new Image [4];
}

public int add (Image image) {
    int count = OS.ImageList_GetImageCount (handle);
    int index = 0;
    while (index < count) {
        if (images [index] !is null) {
            if (images [index].isDisposed ()) images [index] = null;
        }
        if (images [index] is null) break;
        index++;
    }
    if (count is 0) {
        Rectangle rect = image.getBounds ();
        OS.ImageList_SetIconSize (handle, rect.width, rect.height);
    }
    set (index, image, count);
    if (index is images.length) {
        Image [] newImages = new Image [images.length + 4];
        System.arraycopy (images, 0, newImages, 0, images.length);
        images = newImages;
    }
    images [index] = image;
    return index;
}

public int addRef() {
    return ++refCount;
}

HBITMAP copyBitmap (HBITMAP hImage, int width, int height) {
    BITMAP bm;
    OS.GetObject (hImage, BITMAP.sizeof, &bm);
    auto hDC = OS.GetDC (null);
    auto hdc1 = OS.CreateCompatibleDC (hDC);
    OS.SelectObject (hdc1, hImage);
    auto hdc2 = OS.CreateCompatibleDC (hDC);
    /*
    * Feature in Windows.  If a bitmap has a 32-bit depth and any
    * pixel has an alpha value different than zero, common controls
    * version 6.0 assumes that the bitmap should be alpha blended.
    * AlphaBlend() composes the alpha channel of a destination 32-bit
    * depth image with the alpha channel of the source image. This
    * may cause opaque images to draw transparently.  The fix is
    * remove the alpha channel of opaque images by down sampling
    * it to 24-bit depth.
    */
    HBITMAP hBitmap;
    if (bm.bmBitsPixel is 32 && OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
        BITMAPINFOHEADER bmiHeader;
        bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
        bmiHeader.biWidth = width;
        bmiHeader.biHeight = -height;
        bmiHeader.biPlanes = 1;
        bmiHeader.biBitCount = cast(short)24;
        static if (OS.IsWinCE) bmiHeader.biCompression = OS.BI_BITFIELDS;
        else bmiHeader.biCompression = OS.BI_RGB;
        byte[] bmi = new byte[BITMAPINFOHEADER.sizeof + (OS.IsWinCE ? 12 : 0)];
        *cast(BITMAPINFOHEADER*)bmi.ptr = bmiHeader;
        //OS.MoveMemory(bmi, bmiHeader, BITMAPINFOHEADER.sizeof);
        /* Set the rgb colors into the bitmap info */
        static if (OS.IsWinCE) {
            int redMask = 0xFF00;
            int greenMask = 0xFF0000;
            int blueMask = 0xFF000000;
            /* big endian */
            int offset = BITMAPINFOHEADER.sizeof;
            bmi[offset] = cast(byte)((redMask & 0xFF000000) >> 24);
            bmi[offset + 1] = cast(byte)((redMask & 0xFF0000) >> 16);
            bmi[offset + 2] = cast(byte)((redMask & 0xFF00) >> 8);
            bmi[offset + 3] = cast(byte)((redMask & 0xFF) >> 0);
            bmi[offset + 4] = cast(byte)((greenMask & 0xFF000000) >> 24);
            bmi[offset + 5] = cast(byte)((greenMask & 0xFF0000) >> 16);
            bmi[offset + 6] = cast(byte)((greenMask & 0xFF00) >> 8);
            bmi[offset + 7] = cast(byte)((greenMask & 0xFF) >> 0);
            bmi[offset + 8] = cast(byte)((blueMask & 0xFF000000) >> 24);
            bmi[offset + 9] = cast(byte)((blueMask & 0xFF0000) >> 16);
            bmi[offset + 10] = cast(byte)((blueMask & 0xFF00) >> 8);
            bmi[offset + 11] = cast(byte)((blueMask & 0xFF) >> 0);
        }
        void* pBits;
        hBitmap = OS.CreateDIBSection(null, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS, &pBits, null, 0);
    } else {
        hBitmap = OS.CreateCompatibleBitmap (hDC, width, height);
    }
    OS.SelectObject (hdc2, hBitmap);
    if (width !is bm.bmWidth || height !is bm.bmHeight) {
        static if (!OS.IsWinCE) OS.SetStretchBltMode(hdc2, OS.COLORONCOLOR);
        OS.StretchBlt (hdc2, 0, 0, width, height, hdc1, 0, 0, bm.bmWidth, bm.bmHeight, OS.SRCCOPY);
    } else {
        OS.BitBlt (hdc2, 0, 0, width, height, hdc1, 0, 0, OS.SRCCOPY);
    }
    OS.DeleteDC (hdc1);
    OS.DeleteDC (hdc2);
    OS.ReleaseDC (null, hDC);
    return hBitmap;
}

HBITMAP copyIcon (HBITMAP hImage, int width, int height) {
    static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
    auto hIcon = OS.CopyImage (hImage, OS.IMAGE_ICON, width, height, 0);
    return hIcon !is null ? hIcon : hImage;
}

HBITMAP copyWithAlpha (HBITMAP hBitmap, int background, byte[] alphaData, int destWidth, int destHeight) {
    BITMAP bm;
    OS.GetObject (hBitmap, BITMAP.sizeof, &bm);
    int srcWidth = bm.bmWidth;
    int srcHeight = bm.bmHeight;

    /* Create resources */
    auto hdc = OS.GetDC (null);
    auto srcHdc = OS.CreateCompatibleDC (hdc);
    auto oldSrcBitmap = OS.SelectObject (srcHdc, hBitmap);
    auto memHdc = OS.CreateCompatibleDC (hdc);
    BITMAPINFOHEADER bmiHeader;
    bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
    bmiHeader.biWidth = srcWidth;
    bmiHeader.biHeight = -srcHeight;
    bmiHeader.biPlanes = 1;
    bmiHeader.biBitCount = 32;
    bmiHeader.biCompression = OS.BI_RGB;
    byte [] bmi = new byte[BITMAPINFOHEADER.sizeof];
    *cast(BITMAPINFOHEADER*)bmi.ptr = bmiHeader;
    //OS.MoveMemory (bmi, bmiHeader, BITMAPINFOHEADER.sizeof);
    void* pBits;
    auto memDib = OS.CreateDIBSection (null, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS, &pBits, null, 0);
    if (memDib is null) SWT.error (SWT.ERROR_NO_HANDLES);
    auto oldMemBitmap = OS.SelectObject (memHdc, memDib);

    BITMAP dibBM;
    OS.GetObject (memDib, BITMAP.sizeof, &dibBM);
    int sizeInBytes = dibBM.bmWidthBytes * dibBM.bmHeight;

    /* Get the foreground pixels */
    OS.BitBlt (memHdc, 0, 0, srcWidth, srcHeight, srcHdc, 0, 0, OS.SRCCOPY);
    byte[] srcData = (cast(byte*)dibBM.bmBits)[ 0 .. sizeInBytes].dup;
    //OS.MoveMemory (srcData, dibBM.bmBits, sizeInBytes);

    /* Merge the alpha channel in place */
    if (alphaData !is null) {
        int spinc = dibBM.bmWidthBytes - srcWidth * 4;
        int ap = 0, sp = 3;
        for (int y = 0; y < srcHeight; ++y) {
            for (int x = 0; x < srcWidth; ++x) {
                srcData [sp] = alphaData [ap++];
                sp += 4;
            }
            sp += spinc;
        }
    } else {
        byte transRed = cast(byte)(background & 0xFF);
        byte transGreen = cast(byte)((background >> 8) & 0xFF);
        byte transBlue = cast(byte)((background >> 16) & 0xFF);
        int spinc = dibBM.bmWidthBytes - srcWidth * 4;
        int sp = 3;
        for (int y = 0; y < srcHeight; ++y) {
            for (int x = 0; x < srcWidth; ++x) {
                srcData [sp] = (srcData[sp-1] is transRed && srcData[sp-2] is transGreen && srcData[sp-3] is transBlue) ? 0 : cast(byte)255;
                sp += 4;
            }
            sp += spinc;
        }
    }
    (cast(byte*)dibBM.bmBits)[ 0 .. sizeInBytes] = srcData;
    //OS.MoveMemory (dibBM.bmBits, srcData, sizeInBytes);

    /* Stretch and free resources */
    if (srcWidth !is destWidth || srcHeight !is destHeight) {
        BITMAPINFOHEADER bmiHeader2;
        bmiHeader2.biSize = BITMAPINFOHEADER.sizeof;
        bmiHeader2.biWidth = destWidth;
        bmiHeader2.biHeight = -destHeight;
        bmiHeader2.biPlanes = 1;
        bmiHeader2.biBitCount = 32;
        bmiHeader2.biCompression = OS.BI_RGB;
        byte [] bmi2 = new byte[BITMAPINFOHEADER.sizeof];
        *cast(BITMAPINFOHEADER*)bmi2.ptr = bmiHeader2;
        //OS.MoveMemory (bmi2, bmiHeader2, BITMAPINFOHEADER.sizeof);
        void* pBits2;
        auto memDib2 = OS.CreateDIBSection (null, cast(BITMAPINFO*)bmi2.ptr, OS.DIB_RGB_COLORS, &pBits2, null, 0);
        auto memHdc2 = OS.CreateCompatibleDC (hdc);
        auto oldMemBitmap2 = OS.SelectObject (memHdc2, memDib2);
        static if (!OS.IsWinCE) OS.SetStretchBltMode(memHdc2, OS.COLORONCOLOR);
        OS.StretchBlt (memHdc2, 0, 0, destWidth, destHeight, memHdc, 0, 0, srcWidth, srcHeight, OS.SRCCOPY);
        OS.SelectObject (memHdc2, oldMemBitmap2);
        OS.DeleteDC (memHdc2);
        OS.SelectObject (memHdc, oldMemBitmap);
        OS.DeleteDC (memHdc);
        OS.DeleteObject (memDib);
        memDib = memDib2;
    } else {
        OS.SelectObject (memHdc, oldMemBitmap);
        OS.DeleteDC (memHdc);
    }
    OS.SelectObject (srcHdc, oldSrcBitmap);
    OS.DeleteDC (srcHdc);
    OS.ReleaseDC (null, hdc);
    return memDib;
}

HBITMAP createMaskFromAlpha (ImageData data, int destWidth, int destHeight) {
    int srcWidth = data.width;
    int srcHeight = data.height;
    ImageData mask = ImageData.internal_new (srcWidth, srcHeight, 1,
            new PaletteData([new RGB (0, 0, 0), new RGB (0xff, 0xff, 0xff)]),
            2, null, 1, null, null, -1, -1, -1, 0, 0, 0, 0);
    int ap = 0;
    for (int y = 0; y < mask.height; y++) {
        for (int x = 0; x < mask.width; x++) {
            mask.setPixel (x, y, (data.alphaData [ap++] & 0xff) <= 127 ? 1 : 0);
        }
    }
    auto hMask = OS.CreateBitmap (srcWidth, srcHeight, 1, 1, mask.data.ptr);
    if (srcWidth !is destWidth || srcHeight !is destHeight) {
        auto hdc = OS.GetDC (null);
        auto hdc1 = OS.CreateCompatibleDC (hdc);
        OS.SelectObject (hdc1, hMask);
        auto hdc2 = OS.CreateCompatibleDC (hdc);
        auto hMask2 = OS.CreateBitmap (destWidth, destHeight, 1, 1, null);
        OS.SelectObject (hdc2, hMask2);
        static if (!OS.IsWinCE) OS.SetStretchBltMode(hdc2, OS.COLORONCOLOR);
        OS.StretchBlt (hdc2, 0, 0, destWidth, destHeight, hdc1, 0, 0, srcWidth, srcHeight, OS.SRCCOPY);
        OS.DeleteDC (hdc1);
        OS.DeleteDC (hdc2);
        OS.ReleaseDC (null, hdc);
        OS.DeleteObject(hMask);
        hMask = hMask2;
    }
    return hMask;
}

HBITMAP createMask (HBITMAP hBitmap, int destWidth, int destHeight, int background, int transparentPixel) {
    BITMAP bm;
    OS.GetObject (hBitmap, BITMAP.sizeof, &bm);
    int srcWidth = bm.bmWidth;
    int srcHeight = bm.bmHeight;
    auto hMask = OS.CreateBitmap (destWidth, destHeight, 1, 1, null);
    auto hDC = OS.GetDC (null);
    auto hdc1 = OS.CreateCompatibleDC (hDC);
    if (background !is -1) {
        OS.SelectObject (hdc1, hBitmap);

        /*
        * If the image has a palette with multiple entries having
        * the same color and one of those entries is the transparentPixel,
        * only the first entry becomes transparent. To avoid this
        * problem, temporarily change the image palette to a palette
        * where the transparentPixel is white and everything else is
        * black.
        */
        bool isDib = bm.bmBits !is null;
        byte[] originalColors = null;
        if (!OS.IsWinCE && transparentPixel !is -1 && isDib && bm.bmBitsPixel <= 8) {
            int maxColors = 1 << bm.bmBitsPixel;
            byte[] oldColors = new byte[maxColors * 4];
            OS.GetDIBColorTable(hdc1, 0, maxColors, cast(RGBQUAD*)oldColors.ptr);
            int offset = transparentPixel * 4;
            byte[] newColors = new byte[oldColors.length];
            newColors[offset] = cast(byte)0xFF;
            newColors[offset+1] = cast(byte)0xFF;
            newColors[offset+2] = cast(byte)0xFF;
            OS.SetDIBColorTable(hdc1, 0, maxColors, cast(RGBQUAD*)newColors.ptr);
            originalColors = oldColors;
            OS.SetBkColor (hdc1, 0xFFFFFF);
        } else {
            OS.SetBkColor (hdc1, background);
        }

        auto hdc2 = OS.CreateCompatibleDC (hDC);
        OS.SelectObject (hdc2, hMask);
        if (destWidth !is srcWidth || destHeight !is srcHeight) {
            static if (!OS.IsWinCE) OS.SetStretchBltMode (hdc2, OS.COLORONCOLOR);
            OS.StretchBlt (hdc2, 0, 0, destWidth, destHeight, hdc1, 0, 0, srcWidth, srcHeight, OS.SRCCOPY);
        } else {
            OS.BitBlt (hdc2, 0, 0, destWidth, destHeight, hdc1, 0, 0, OS.SRCCOPY);
        }
        OS.DeleteDC (hdc2);

        /* Put back the original palette */
        if (originalColors !is null) OS.SetDIBColorTable(hdc1, 0, 1 << bm.bmBitsPixel, cast(RGBQUAD*)originalColors.ptr);
    } else {
        auto hOldBitmap = OS.SelectObject (hdc1, hMask);
        OS.PatBlt (hdc1, 0, 0, destWidth, destHeight, OS.BLACKNESS);
        OS.SelectObject (hdc1, hOldBitmap);
    }
    OS.ReleaseDC (null, hDC);
    OS.DeleteDC (hdc1);
    return hMask;
}

public void dispose () {
    if (handle !is null) OS.ImageList_Destroy (handle);
    handle = null;
    images = null;
}

public Image get (int index) {
    return images [index];
}

public int getStyle () {
    return style;
}

public HIMAGELIST getHandle () {
    return handle;
}

public Point getImageSize() {
    int cx, cy;
    OS.ImageList_GetIconSize (handle, &cx, &cy);
    return new Point (cx, cy);
}

public int indexOf (Image image) {
    int count = OS.ImageList_GetImageCount (handle);
    for (int i=0; i<count; i++) {
        if (images [i] !is null) {
            if (images [i].isDisposed ()) images [i] = null;
            if (images [i] !is null && images [i]==/*eq*/image) return i;
        }
    }
    return -1;
}

public void put (int index, Image image) {
    int count = OS.ImageList_GetImageCount (handle);
    if (!(0 <= index && index < count)) return;
    if (image !is null) set(index, image, count);
    images [index] = image;
}

public void remove (int index) {
    int count = OS.ImageList_GetImageCount (handle);
    if (!(0 <= index && index < count)) return;
    OS.ImageList_Remove (handle, index);
    System.arraycopy (images, index + 1, images, index, --count - index);
    images [index] = null;
}

public int removeRef() {
    return --refCount;
}

void set (int index, Image image, int count) {
    auto hImage = image.handle;
    int cx , cy ;
    OS.ImageList_GetIconSize (handle, &cx, &cy);
    switch (image.type) {
        case SWT.BITMAP: {
            /*
            * Note that the image size has to match the image list icon size.
            */
            HBITMAP hBitmap, hMask;
            ImageData data = image.getImageData ();
            switch (data.getTransparencyType ()) {
                case SWT.TRANSPARENCY_ALPHA:
                    if (OS.COMCTL32_MAJOR >= 6) {
                        hBitmap = copyWithAlpha (hImage, -1, data.alphaData, cx, cy);
                    } else {
                        hBitmap = copyBitmap (hImage, cx, cy);
                        hMask = createMaskFromAlpha (data, cx, cy);
                    }
                    break;
                case SWT.TRANSPARENCY_PIXEL:
                    int background = -1;
                    Color color = image.getBackground ();
                    if (color !is null) background = color.handle;
                    hBitmap = copyBitmap (hImage, cx, cy);
                    hMask = createMask (hImage, cx, cy, background, data.transparentPixel);
                    break;
                case SWT.TRANSPARENCY_NONE:
                default:
                    hBitmap = copyBitmap (hImage, cx, cy);
                    if (index !is count) hMask = createMask (hImage, cx, cy, -1, -1);
                    break;
            }
            if (index is count) {
                OS.ImageList_Add (handle, hBitmap, hMask);
            } else {
                /* Note that the mask must always be replaced even for TRANSPARENCY_NONE */
                OS.ImageList_Replace (handle, index, hBitmap, hMask);
            }
            if (hMask !is null) OS.DeleteObject (hMask);
            if (hBitmap !is hImage) OS.DeleteObject (hBitmap);
            break;
        }
        case SWT.ICON: {
            static if (OS.IsWinCE) {
                OS.ImageList_ReplaceIcon (handle, index is count ? -1 : index, hImage);
            } else {
                auto hIcon = copyIcon (hImage, cx, cy);
                OS.ImageList_ReplaceIcon (handle, index is count ? -1 : index, hIcon);
                OS.DestroyIcon (hIcon);
            }
            break;
        }
        default:
    }
}

public int size () {
    int result = 0;
    int count = OS.ImageList_GetImageCount (handle);
    for (int i=0; i<count; i++) {
        if (images [i] !is null) {
            if (images [i].isDisposed ()) images [i] = null;
            if (images [i] !is null) result++;
        }
    }
    return result;
}

}
