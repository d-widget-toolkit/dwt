/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Display;
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

    private static ImageTransfer _instance;

    private static const String JPEG = "image/jpge"; //$NON-NLS-1$
    private static int JPEG_ID;
    private static const String PNG = "image/png"; //$NON-NLS-1$
    private static int PNG_ID;
    private static const String BMP = "image/bmp"; //$NON-NLS-1$
    private static int BMP_ID;
    private static const String EPS = "image/eps"; //$NON-NLS-1$
    private static int EPS_ID;
    private static const String PCX = "image/pcx"; //$NON-NLS-1$
    private static int PCX_ID;
    private static const String PPM = "image/ppm"; //$NON-NLS-1$
    private static int PPM_ID;
    private static const String RGB = "image/ppm"; //$NON-NLS-1$
    private static int RGB_ID;
    private static const String TGA = "image/tga"; //$NON-NLS-1$
    private static int TGA_ID;
    private static const String XBM = "image/xbm"; //$NON-NLS-1$
    private static int XBM_ID;
    private static const String XPM = "image/xpm"; //$NON-NLS-1$
    private static int XPM_ID;
    private static const String XV = "image/xv"; //$NON-NLS-1$
    private static int XV_ID;

static this(){
    JPEG_ID = registerType(JPEG);
    PNG_ID = registerType(PNG);
    BMP_ID = registerType(BMP);
    EPS_ID = registerType(EPS);
    PCX_ID = registerType(PCX);
    PPM_ID = registerType(PPM);
    RGB_ID = registerType(RGB);
    TGA_ID = registerType(TGA);
    XBM_ID = registerType(XBM);
    XPM_ID = registerType(XPM);
    XV_ID = registerType(XV);
    _instance = new ImageTransfer();
}

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
    if (OS.GTK_VERSION < OS.buildVERSION (2, 4, 0)) return;

    ImageData imgData = cast(ImageData)object;
    if (imgData is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    Image image = new Image(Display.getCurrent(), imgData);
    auto pixmap = image.pixmap;
    int width = imgData.width;
    int height = imgData.height;
    auto pixbuf = OS.gdk_pixbuf_new(OS.GDK_COLORSPACE_RGB, true, 8, width, height);
    if (pixbuf is null) SWT.error(SWT.ERROR_NO_HANDLES);
    auto colormap = OS.gdk_colormap_get_system();
    OS.gdk_pixbuf_get_from_drawable(pixbuf, pixmap, colormap, 0, 0, 0, 0, width, height);

    String typeStr = "";
    if (transferData.type is  cast(void*)JPEG_ID) typeStr = "jpeg";
    if (transferData.type is  cast(void*)PNG_ID) typeStr = "png";
    if (transferData.type is  cast(void*)BMP_ID) typeStr = "bmp";
    if (transferData.type is  cast(void*)EPS_ID) typeStr = "eps";
    if (transferData.type is  cast(void*)PCX_ID) typeStr = "pcx";
    if (transferData.type is  cast(void*)PPM_ID) typeStr = "ppm";
    if (transferData.type is  cast(void*)RGB_ID) typeStr = "rgb";
    if (transferData.type is  cast(void*)TGA_ID) typeStr = "tga";
    if (transferData.type is  cast(void*)XBM_ID) typeStr = "xbm";
    if (transferData.type is  cast(void*)XPM_ID) typeStr = "xpm";
    if (transferData.type is  cast(void*)XV_ID) typeStr = "xv";
    auto type = typeStr.ptr;
    char* buffer;
    size_t len;
    if (type is null) return;
    OS.gdk_pixbuf_save_to_buffer0(pixbuf, &buffer, &len, type, null);
    OS.g_object_unref(pixbuf);
    image.dispose();
    transferData.pValue = buffer;
    transferData.length = cast(int)/*64bit*/((len + 3) / 4 * 4);
    transferData.result = 1;
    transferData.format = 32;
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
    ImageData imgData = null;
    if (transferData.length > 0)
    {
        auto loader = OS.gdk_pixbuf_loader_new();
        OS.gdk_pixbuf_loader_write(loader, transferData.pValue, transferData.length, null);
        OS.gdk_pixbuf_loader_close(loader, null);
        auto pixbuf = OS.gdk_pixbuf_loader_get_pixbuf(loader);
        if (pixbuf !is null) {
            OS.g_object_ref(pixbuf);
            GdkPixmap* pixmap_return;
            OS.gdk_pixbuf_render_pixmap_and_mask(pixbuf, &pixmap_return, null, 0);
            auto handle = pixmap_return;
            if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
            OS.g_object_unref(loader);
            Image img = Image.gtk_new(Display.getCurrent(), SWT.BITMAP, handle, null);
            imgData = img.getImageData();
            img.dispose();
        }
    }
    return imgData;
}

override
protected int[] getTypeIds(){
    return [JPEG_ID, PNG_ID, BMP_ID, EPS_ID, PCX_ID, PPM_ID, RGB_ID, TGA_ID, XBM_ID, XPM_ID, XV_ID];
}

override
protected String[] getTypeNames(){
    return [JPEG, PNG, BMP, EPS, PCX, PPM, RGB, TGA, XBM, XPM, XV];
}

bool checkImage(Object object) {
    if (object is null || !( null !is cast(ImageData)object )) return false;
    return true;
}

override
protected bool validate(Object object) {
    return checkImage(object);
}
}
