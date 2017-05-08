/*******************************************************************************
 * Copyright (c) 2007, 2008 IBM Corporation and others.
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
module org.eclipse.swt.dnd.TreeDragSourceEffect;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.swt.widgets.TreeItem;

import org.eclipse.swt.dnd.DragSourceEffect;
import org.eclipse.swt.dnd.DragSourceEvent;

import java.lang.all;

/**
 * This class provides default implementations to display a source image
 * when a drag is initiated from a <code>Tree</code>.
 *
 * <p>Classes that wish to provide their own source image for a <code>Tree</code> can
 * extend <code>TreeDragSourceEffect</code> class and override the <code>TreeDragSourceEffect.dragStart</code>
 * method and set the field <code>DragSourceEvent.image</code> with their own image.</p>
 *
 * Subclasses that override any methods of this class must call the corresponding
 * <code>super</code> method to get the default drag under effect implementation.
 *
 * @see DragSourceEffect
 * @see DragSourceEvent
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.3
 */
public class TreeDragSourceEffect : DragSourceEffect {
    Image dragSourceImage = null;

    /**
     * Creates a new <code>TreeDragSourceEffect</code> to handle drag effect
     * from the specified <code>Tree</code>.
     *
     * @param tree the <code>Tree</code> that the user clicks on to initiate the drag
     */
    public this(Tree tree) {
        super(tree);
    }

    /**
     * This implementation of <code>dragFinished</code> disposes the image
     * that was created in <code>TreeDragSourceEffect.dragStart</code>.
     *
     * Subclasses that override this method should call <code>super.dragFinished(event)</code>
     * to dispose the image in the default implementation.
     *
     * @param event the information associated with the drag finished event
     */
    override
    public void dragFinished(DragSourceEvent event) {
        if (dragSourceImage !is null) dragSourceImage.dispose();
        dragSourceImage = null;
    }

    /**
     * This implementation of <code>dragStart</code> will create a default
     * image that will be used during the drag. The image should be disposed
     * when the drag is completed in the <code>TreeDragSourceEffect.dragFinished</code>
     * method.
     *
     * Subclasses that override this method should call <code>super.dragStart(event)</code>
     * to use the image from the default implementation.
     *
     * @param event the information associated with the drag start event
     */
    override
    public void dragStart(DragSourceEvent event) {
        event.image = getDragSourceImage(event);
    }

    Image getDragSourceImage(DragSourceEvent event) {
        if (dragSourceImage !is null) dragSourceImage.dispose();
        dragSourceImage = null;
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (5, 1)) {
            SHDRAGIMAGE shdi;
            int DI_GETDRAGIMAGE = OS.RegisterWindowMessage ("ShellGetDragImage"w.ptr); //$NON-NLS-1$
            if (OS.SendMessage (control.handle, DI_GETDRAGIMAGE, 0, &shdi) !is 0) {
                if ((control.getStyle() & SWT.MIRRORED) !is 0) {
                    event.x += shdi.sizeDragImage.cx - shdi.ptOffset.x;
                } else {
                    event.x += shdi.ptOffset.x;
                }
                event.y += shdi.ptOffset.y;
                auto hImage = shdi.hbmpDragImage;
                if (hImage !is null) {
                    BITMAP bm;
                    OS.GetObject (hImage, BITMAP.sizeof, &bm);
                    int srcWidth = bm.bmWidth;
                    int srcHeight = bm.bmHeight;

                    /* Create resources */
                    auto hdc = OS.GetDC (null);
                    auto srcHdc = OS.CreateCompatibleDC (hdc);
                    auto oldSrcBitmap = OS.SelectObject (srcHdc, hImage);
                    auto memHdc = OS.CreateCompatibleDC (hdc);
                    BITMAPINFOHEADER bmiHeader;
                    bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
                    bmiHeader.biWidth = srcWidth;
                    bmiHeader.biHeight = -srcHeight;
                    bmiHeader.biPlanes = 1;
                    bmiHeader.biBitCount = 32;
                    bmiHeader.biCompression = OS.BI_RGB;
                    void* pBits;
                    auto memDib = OS.CreateDIBSection (null, cast(BITMAPINFO*)&bmiHeader, OS.DIB_RGB_COLORS, &pBits, null, 0);
                    if (memDib is null) SWT.error (SWT.ERROR_NO_HANDLES);
                    auto oldMemBitmap = OS.SelectObject (memHdc, memDib);

                    BITMAP dibBM;
                    OS.GetObject (memDib, BITMAP.sizeof, &dibBM);
                    int sizeInBytes = dibBM.bmWidthBytes * dibBM.bmHeight;

                    /* Get the foreground pixels */
                    OS.BitBlt (memHdc, 0, 0, srcWidth, srcHeight, srcHdc, 0, 0, OS.SRCCOPY);
                    byte[] srcData = (cast(byte*)dibBM.bmBits)[ 0 .. sizeInBytes ];

                    PaletteData palette = new PaletteData(0xFF00, 0xFF0000, 0xFF000000);
                    ImageData data = new ImageData(srcWidth, srcHeight, bm.bmBitsPixel, palette, bm.bmWidthBytes, srcData);
                    if (shdi.crColorKey is -1) {
                        byte[] alphaData = new byte[srcWidth * srcHeight];
                        int spinc = dibBM.bmWidthBytes - srcWidth * 4;
                        int ap = 0, sp = 3;
                        for (int y = 0; y < srcHeight; ++y) {
                            for (int x = 0; x < srcWidth; ++x) {
                                alphaData [ap++] = srcData [sp];
                                sp += 4;
                            }
                            sp += spinc;
                        }
                        data.alphaData = alphaData;
                    } else {
                        data.transparentPixel = shdi.crColorKey << 8;
                    }
                    dragSourceImage = new Image (control.getDisplay (), data);
                    OS.SelectObject (memHdc, oldMemBitmap);
                    OS.DeleteDC (memHdc);
                    OS.DeleteObject (memDib);
                    OS.SelectObject (srcHdc, oldSrcBitmap);
                    OS.DeleteDC (srcHdc);
                    OS.ReleaseDC (null, hdc);
                    OS.DeleteObject (hImage);
                    return dragSourceImage;
                }
            }
            return null;
        }

        Tree tree = cast(Tree) control;
        //TEMPORARY CODE
        if (tree.isListening (SWT.EraseItem) || tree.isListening (SWT.PaintItem)) return null;
        TreeItem[] selection = tree.getSelection();
        if (selection.length is 0) return null;
        auto treeImageList = OS.SendMessage (tree.handle, OS.TVM_GETIMAGELIST, OS.TVSIL_NORMAL, 0);
        if (treeImageList !is 0) {
            int count = Math.min(cast(int)/*64bit*/selection.length, 10);
            Rectangle bounds = selection[0].getBounds(0);
            for (int i = 1; i < count; i++) {
                bounds = bounds.makeUnion(selection[i].getBounds(0));
            }
            auto hDC = OS.GetDC(tree.handle);
            auto hDC1 = OS.CreateCompatibleDC(hDC);
            auto bitmap = OS.CreateCompatibleBitmap(hDC, bounds.width, bounds.height);
            auto hOldBitmap = OS.SelectObject(hDC1, bitmap);
            RECT rect;
            rect.right = bounds.width;
            rect.bottom = bounds.height;
            auto hBrush = OS.GetStockObject(OS.WHITE_BRUSH);
            OS.FillRect(hDC1, &rect, hBrush);
            for (int i = 0; i < count; i++) {
                TreeItem selected = selection[i];
                Rectangle cell = selected.getBounds(0);
                HANDLE imageList = cast(HANDLE) OS.SendMessage(tree.handle, OS.TVM_CREATEDRAGIMAGE, 0, selected.handle);
                OS.ImageList_Draw(imageList, 0, hDC1, cell.x - bounds.x, cell.y - bounds.y, OS.ILD_SELECTED);
                OS.ImageList_Destroy(imageList);
            }
            OS.SelectObject(hDC1, hOldBitmap);
            OS.DeleteDC (hDC1);
            OS.ReleaseDC (tree.handle, hDC);
            Display display = tree.getDisplay();
            dragSourceImage = Image.win32_new(display, SWT.BITMAP, bitmap);
            return dragSourceImage;
        }
        return null;
    }
}
