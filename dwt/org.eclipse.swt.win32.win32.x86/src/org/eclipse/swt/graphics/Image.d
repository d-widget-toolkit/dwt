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
module org.eclipse.swt.graphics.Image;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.gdip.Gdip;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.Drawable;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Resource;


import java.io.InputStream;
import java.lang.all;


/**
 * Instances of this class are graphics which have been prepared
 * for display on a specific device. That is, they are ready
 * to paint using methods such as <code>GC.drawImage()</code>
 * and display on widgets with, for example, <code>Button.setImage()</code>.
 * <p>
 * If loaded from a file format that supports it, an
 * <code>Image</code> may have transparency, meaning that certain
 * pixels are specified as being transparent when drawn. Examples
 * of file formats that support transparency are GIF and PNG.
 * </p><p>
 * There are two primary ways to use <code>Images</code>.
 * The first is to load a graphic file from disk and create an
 * <code>Image</code> from it. This is done using an <code>Image</code>
 * constructor, for example:
 * <pre>
 *    Image i = new Image(device, "C:\\graphic.bmp");
 * </pre>
 * A graphic file may contain a color table specifying which
 * colors the image was intended to possess. In the above example,
 * these colors will be mapped to the closest available color in
 * SWT. It is possible to get more control over the mapping of
 * colors as the image is being created, using code of the form:
 * <pre>
 *    ImageData data = new ImageData("C:\\graphic.bmp");
 *    RGB[] rgbs = data.getRGBs();
 *    // At this point, rgbs contains specifications of all
 *    // the colors contained within this image. You may
 *    // allocate as many of these colors as you wish by
 *    // using the Color constructor Color(RGB), then
 *    // create the image:
 *    Image i = new Image(device, data);
 * </pre>
 * <p>
 * Applications which require even greater control over the image
 * loading process should use the support provided in class
 * <code>ImageLoader</code>.
 * </p><p>
 * Application code must explicitly invoke the <code>Image.dispose()</code>
 * method to release the operating system resources managed by each instance
 * when those instances are no longer required.
 * </p>
 *
 * @see Color
 * @see ImageData
 * @see ImageLoader
 * @see <a href="http://www.eclipse.org/swt/snippets/#image">Image snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Examples: GraphicsExample, ImageAnalyzer</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public final class Image : Resource, Drawable {

    alias Resource.init_ init_;

    /**
     * specifies whether the receiver is a bitmap or an icon
     * (one of <code>SWT.BITMAP</code>, <code>SWT.ICON</code>)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public int type;

    /**
     * the handle to the OS image resource
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public HGDIOBJ handle;

    /**
     * specifies the transparent pixel
     */
    int transparentPixel = -1, transparentColor = -1;

    /**
     * the GC which is drawing on the image
     */
    GC memGC;

    /**
     * the alpha data for the image
     */
    byte[] alphaData;

    /**
     * the global alpha value to be used for every pixel
     */
    int alpha = -1;

    /**
     * the image data used to create this image if it is a
     * icon. Used only in WinCE
     */
    ImageData data;

    /**
     * width of the image
     */
    int width = -1;

    /**
     * height of the image
     */
    int height = -1;

    /**
     * specifies the default scanline padding
     */
    static const int DEFAULT_SCANLINE_PAD = 4;

/**
 * Prevents uninitialized instances from being created outside the package.
 */
this (Device device) {
    super(device);
}

/**
 * Constructs an empty instance of this class with the
 * specified width and height. The result may be drawn upon
 * by creating a GC and using any of its drawing operations,
 * as shown in the following example:
 * <pre>
 *    Image i = new Image(device, width, height);
 *    GC gc = new GC(i);
 *    gc.drawRectangle(0, 0, 50, 50);
 *    gc.dispose();
 * </pre>
 * <p>
 * Note: Some platforms may have a limitation on the size
 * of image that can be created (size depends on width, height,
 * and depth). For example, Windows 95, 98, and ME do not allow
 * images larger than 16M.
 * </p>
 *
 * @param device the device on which to create the image
 * @param width the width of the new image
 * @param height the height of the new image
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_INVALID_ARGUMENT - if either the width or height is negative or zero</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for image creation</li>
 * </ul>
 */
public this(Device device, int width, int height) {
    super(device);
    init_(width, height);
    init_();
}

/**
 * Constructs a new instance of this class based on the
 * provided image, with an appearance that varies depending
 * on the value of the flag. The possible flag values are:
 * <dl>
 * <dt><b>{@link SWT#IMAGE_COPY}</b></dt>
 * <dd>the result is an identical copy of srcImage</dd>
 * <dt><b>{@link SWT#IMAGE_DISABLE}</b></dt>
 * <dd>the result is a copy of srcImage which has a <em>disabled</em> look</dd>
 * <dt><b>{@link SWT#IMAGE_GRAY}</b></dt>
 * <dd>the result is a copy of srcImage which has a <em>gray scale</em> look</dd>
 * </dl>
 *
 * @param device the device on which to create the image
 * @param srcImage the image to use as the source
 * @param flag the style, either <code>IMAGE_COPY</code>, <code>IMAGE_DISABLE</code> or <code>IMAGE_GRAY</code>
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if srcImage is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the flag is not one of <code>IMAGE_COPY</code>, <code>IMAGE_DISABLE</code> or <code>IMAGE_GRAY</code></li>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_INVALID_IMAGE - if the image is not a bitmap or an icon, or is otherwise in an invalid state</li>
 *    <li>ERROR_UNSUPPORTED_DEPTH - if the depth of the image is not supported</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for image creation</li>
 * </ul>
 */
public this(Device device, Image srcImage, int flag) {
    super(device);
    device = this.device;
    if (srcImage is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (srcImage.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    Rectangle rect = srcImage.getBounds();
    this.type = srcImage.type;
    switch (flag) {
        case SWT.IMAGE_COPY: {
            switch (type) {
                case SWT.BITMAP:
                    /* Get the HDC for the device */
                    auto hDC = device.internal_new_GC(null);

                    /* Copy the bitmap */
                    auto hdcSource = OS.CreateCompatibleDC(hDC);
                    auto hdcDest = OS.CreateCompatibleDC(hDC);
                    auto hOldSrc = OS.SelectObject(hdcSource, srcImage.handle);
                    BITMAP bm;
                    OS.GetObject(srcImage.handle, BITMAP.sizeof, &bm);
                    handle = OS.CreateCompatibleBitmap(hdcSource, rect.width, bm.bmBits !is null ? -rect.height : rect.height);
                    if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
                    auto hOldDest = OS.SelectObject(hdcDest, handle);
                    OS.BitBlt(hdcDest, 0, 0, rect.width, rect.height, hdcSource, 0, 0, OS.SRCCOPY);
                    OS.SelectObject(hdcSource, hOldSrc);
                    OS.SelectObject(hdcDest, hOldDest);
                    OS.DeleteDC(hdcSource);
                    OS.DeleteDC(hdcDest);

                    /* Release the HDC for the device */
                    device.internal_dispose_GC(hDC, null);

                    transparentPixel = srcImage.transparentPixel;
                    alpha = srcImage.alpha;
                    if (srcImage.alphaData !is null) {
                        alphaData = new byte[srcImage.alphaData.length];
                        System.arraycopy(srcImage.alphaData, 0, alphaData, 0, alphaData.length);
                    }
                    break;
                case SWT.ICON:
                    static if (OS.IsWinCE) {
                        init_(srcImage.data);
                    } else {
                        handle = OS.CopyImage(srcImage.handle, OS.IMAGE_ICON, rect.width, rect.height, 0);
                        if (handle is null) SWT.error(SWT.ERROR_NO_HANDLES);
                    }
                    break;
                default:
                    SWT.error(SWT.ERROR_INVALID_IMAGE);
            }
            break;
        }
        case SWT.IMAGE_DISABLE: {
            ImageData data = srcImage.getImageData();
            PaletteData palette = data.palette;
            RGB[] rgbs = new RGB[3];
            rgbs[0] = device.getSystemColor(SWT.COLOR_BLACK).getRGB();
            rgbs[1] = device.getSystemColor(SWT.COLOR_WIDGET_NORMAL_SHADOW).getRGB();
            rgbs[2] = device.getSystemColor(SWT.COLOR_WIDGET_BACKGROUND).getRGB();
            ImageData newData = new ImageData(rect.width, rect.height, 8, new PaletteData(rgbs));
            newData.alpha = data.alpha;
            newData.alphaData = data.alphaData;
            newData.maskData = data.maskData;
            newData.maskPad = data.maskPad;
            if (data.transparentPixel !is -1) newData.transparentPixel = 0;

            /* Convert the pixels. */
            int[] scanline = new int[rect.width];
            int[] maskScanline = null;
            ImageData mask = null;
            if (data.maskData !is null) mask = data.getTransparencyMask();
            if (mask !is null) maskScanline = new int[rect.width];
            int redMask = palette.redMask;
            int greenMask = palette.greenMask;
            int blueMask = palette.blueMask;
            int redShift = palette.redShift;
            int greenShift = palette.greenShift;
            int blueShift = palette.blueShift;
            for (int y=0; y<rect.height; y++) {
                int offset = y * newData.bytesPerLine;
                data.getPixels(0, y, rect.width, scanline, 0);
                if (mask !is null) mask.getPixels(0, y, rect.width, maskScanline, 0);
                for (int x=0; x<rect.width; x++) {
                    int pixel = scanline[x];
                    if (!((data.transparentPixel !is -1 && pixel is data.transparentPixel) || (mask !is null && maskScanline[x] is 0))) {
                        int red, green, blue;
                        if (palette.isDirect) {
                            red = pixel & redMask;
                            red = (redShift < 0) ? red >>> -redShift : red << redShift;
                            green = pixel & greenMask;
                            green = (greenShift < 0) ? green >>> -greenShift : green << greenShift;
                            blue = pixel & blueMask;
                            blue = (blueShift < 0) ? blue >>> -blueShift : blue << blueShift;
                        } else {
                            red = palette.colors[pixel].red;
                            green = palette.colors[pixel].green;
                            blue = palette.colors[pixel].blue;
                        }
                        int intensity = red * red + green * green + blue * blue;
                        if (intensity < 98304) {
                            newData.data[offset] = cast(byte)1;
                        } else {
                            newData.data[offset] = cast(byte)2;
                        }
                    }
                    offset++;
                }
            }
            init_ (newData);
            break;
        }
        case SWT.IMAGE_GRAY: {
            ImageData data = srcImage.getImageData();
            PaletteData palette = data.palette;
            ImageData newData = data;
            if (!palette.isDirect) {
                /* Convert the palette entries to gray. */
                RGB [] rgbs = palette.getRGBs();
                for (int i=0; i<rgbs.length; i++) {
                    if (data.transparentPixel !is i) {
                        RGB color = rgbs [i];
                        int red = color.red;
                        int green = color.green;
                        int blue = color.blue;
                        int intensity = (red+red+green+green+green+green+green+blue) >> 3;
                        color.red = color.green = color.blue = intensity;
                    }
                }
                newData.palette = new PaletteData(rgbs);
            } else {
                /* Create a 8 bit depth image data with a gray palette. */
                RGB[] rgbs = new RGB[256];
                for (int i=0; i<rgbs.length; i++) {
                    rgbs[i] = new RGB(i, i, i);
                }
                newData = new ImageData(rect.width, rect.height, 8, new PaletteData(rgbs));
                newData.alpha = data.alpha;
                newData.alphaData = data.alphaData;
                newData.maskData = data.maskData;
                newData.maskPad = data.maskPad;
                if (data.transparentPixel !is -1) newData.transparentPixel = 254;

                /* Convert the pixels. */
                int[] scanline = new int[rect.width];
                int redMask = palette.redMask;
                int greenMask = palette.greenMask;
                int blueMask = palette.blueMask;
                int redShift = palette.redShift;
                int greenShift = palette.greenShift;
                int blueShift = palette.blueShift;
                for (int y=0; y<rect.height; y++) {
                    int offset = y * newData.bytesPerLine;
                    data.getPixels(0, y, rect.width, scanline, 0);
                    for (int x=0; x<rect.width; x++) {
                        int pixel = scanline[x];
                        if (pixel !is data.transparentPixel) {
                            int red = pixel & redMask;
                            red = (redShift < 0) ? red >>> -redShift : red << redShift;
                            int green = pixel & greenMask;
                            green = (greenShift < 0) ? green >>> -greenShift : green << greenShift;
                            int blue = pixel & blueMask;
                            blue = (blueShift < 0) ? blue >>> -blueShift : blue << blueShift;
                            int intensity = (red+red+green+green+green+green+green+blue) >> 3;
                            if (newData.transparentPixel is intensity) intensity = 255;
                            newData.data[offset] = cast(byte)intensity;
                        } else {
                            newData.data[offset] = cast(byte)254;
                        }
                        offset++;
                    }
                }
            }
            init_ (newData);
            break;
        }
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    init_();
}

/**
 * Constructs an empty instance of this class with the
 * width and height of the specified rectangle. The result
 * may be drawn upon by creating a GC and using any of its
 * drawing operations, as shown in the following example:
 * <pre>
 *    Image i = new Image(device, boundsRectangle);
 *    GC gc = new GC(i);
 *    gc.drawRectangle(0, 0, 50, 50);
 *    gc.dispose();
 * </pre>
 * <p>
 * Note: Some platforms may have a limitation on the size
 * of image that can be created (size depends on width, height,
 * and depth). For example, Windows 95, 98, and ME do not allow
 * images larger than 16M.
 * </p>
 *
 * @param device the device on which to create the image
 * @param bounds a rectangle specifying the image's width and height (must not be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the bounds rectangle is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if either the rectangle's width or height is negative</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for image creation</li>
 * </ul>
 */
public this(Device device, Rectangle bounds) {
    super(device);
    if (bounds is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    init_(bounds.width, bounds.height);
    init_();
}

/**
 * Constructs an instance of this class from the given
 * <code>ImageData</code>.
 *
 * @param device the device on which to create the image
 * @param data the image data to create the image from (must not be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the image data is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_UNSUPPORTED_DEPTH - if the depth of the ImageData is not supported</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for image creation</li>
 * </ul>
 */
public this(Device device, ImageData data) {
    super(device);
    init_(data);
    init_();
}

/**
 * Constructs an instance of this class, whose type is
 * <code>SWT.ICON</code>, from the two given <code>ImageData</code>
 * objects. The two images must be the same size. Pixel transparency
 * in either image will be ignored.
 * <p>
 * The mask image should contain white wherever the icon is to be visible,
 * and black wherever the icon is to be transparent. In addition,
 * the source image should contain black wherever the icon is to be
 * transparent.
 * </p>
 *
 * @param device the device on which to create the icon
 * @param source the color data for the icon
 * @param mask the mask data for the icon
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if either the source or mask is null </li>
 *    <li>ERROR_INVALID_ARGUMENT - if source and mask are different sizes</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for image creation</li>
 * </ul>
 */
public this(Device device, ImageData source, ImageData mask) {
    super(device);
    if (source is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (mask is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (source.width !is mask.width || source.height !is mask.height) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    mask = ImageData.convertMask(mask);
    init__(this.device, this, source, mask);
    init_();
}

/**
 * Constructs an instance of this class by loading its representation
 * from the specified input stream. Throws an error if an error
 * occurs while loading the image, or if the result is an image
 * of an unsupported type.  Application code is still responsible
 * for closing the input stream.
 * <p>
 * This constructor is provided for convenience when loading a single
 * image only. If the stream contains multiple images, only the first
 * one will be loaded. To load multiple images, use
 * <code>ImageLoader.load()</code>.
 * </p><p>
 * This constructor may be used to load a resource as follows:
 * </p>
 * <pre>
 *     static Image loadImage (Display display, Class clazz, String string) {
 *          InputStream stream = clazz.getResourceAsStream (string);
 *          if (stream is null) return null;
 *          Image image = null;
 *          try {
 *               image = new Image (display, stream);
 *          } catch (SWTException ex) {
 *          } finally {
 *               try {
 *                    stream.close ();
 *               } catch (IOException ex) {}
 *          }
 *          return image;
 *     }
 * </pre>
 *
 * @param device the device on which to create the image
 * @param stream the input stream to load the image from
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the stream is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_IO - if an IO error occurs while reading from the stream</li>
 *    <li>ERROR_INVALID_IMAGE - if the image stream contains invalid data </li>
 *    <li>ERROR_UNSUPPORTED_DEPTH - if the image stream describes an image with an unsupported depth</li>
 *    <li>ERROR_UNSUPPORTED_FORMAT - if the image stream contains an unrecognized format</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for image creation</li>
 * </ul>
 */
public this (Device device, InputStream stream) {
    super(device);
    init_(new ImageData(stream));
    init_();
}

/**
 * Constructs an instance of this class by loading its representation
 * from the file with the specified name. Throws an error if an error
 * occurs while loading the image, or if the result is an image
 * of an unsupported type.
 * <p>
 * This constructor is provided for convenience when loading
 * a single image only. If the specified file contains
 * multiple images, only the first one will be used.
 *
 * @param device the device on which to create the image
 * @param filename the name of the file to load the image from
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if device is null and there is no current device</li>
 *    <li>ERROR_NULL_ARGUMENT - if the file name is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_IO - if an IO error occurs while reading from the file</li>
 *    <li>ERROR_INVALID_IMAGE - if the image file contains invalid data </li>
 *    <li>ERROR_UNSUPPORTED_DEPTH - if the image file describes an image with an unsupported depth</li>
 *    <li>ERROR_UNSUPPORTED_FORMAT - if the image file contains an unrecognized format</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for image creation</li>
 * </ul>
 */
public this (Device device, String filename) {
    super(device);
    device = this.device;
    if (filename is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    bool gdip = true;
    try {
        device.checkGDIP();
    } catch (SWTException e) {
        gdip = false;
    }
    /*
    * Bug in GDI+.  For some reason, Bitmap.LockBits() segment faults
    * when loading GIF files in 64-bit Windows.  The fix is to not use
    * GDI+ image loading in this case.
    */
    if (gdip && (void*).sizeof is 8 && filename.toLowerCase().endsWith(".gif")) gdip = false;
    if (gdip) {
        int length = cast(int)/*64bit*/filename.length;
        char[] chars = new char[length+1];
        filename.getChars(0, length, chars, 0);
        auto bitmap = Gdip.Bitmap_new( .StrToWCHARz( filename ), false);
        if (bitmap !is null) {
            int error = SWT.ERROR_NO_HANDLES;
            int status = Gdip.Image_GetLastStatus(cast(Gdip.Image)bitmap);
            if (status is 0) {
                if (filename.toLowerCase().endsWith(".ico")) {
                    this.type = SWT.ICON;
                    HICON hicon;
                    Gdip.Bitmap_GetHICON(bitmap, hicon);
                    this.handle = hicon;
                } else {
                    this.type = SWT.BITMAP;
                    int width = Gdip.Image_GetWidth(cast(Gdip.Image)bitmap);
                    int height = Gdip.Image_GetHeight(cast(Gdip.Image)bitmap);
                    int pixelFormat = Gdip.Image_GetPixelFormat(cast(Gdip.Image)bitmap);
                    switch (pixelFormat) {
                        case Gdip.PixelFormat16bppRGB555:
                        case Gdip.PixelFormat16bppRGB565:
                            this.handle = createDIB(width, height, 16);
                            break;
                        case Gdip.PixelFormat24bppRGB:
                            this.handle = createDIB(width, height, 24);
                            break;
                        case Gdip.PixelFormat32bppRGB:
                        // These will loose either precision or transparency
                        case Gdip.PixelFormat16bppGrayScale:
                        case Gdip.PixelFormat48bppRGB:
                        case Gdip.PixelFormat32bppPARGB:
                        case Gdip.PixelFormat64bppARGB:
                        case Gdip.PixelFormat64bppPARGB:
                            this.handle = createDIB(width, height, 32);
                            break;
                        default:
                    }
                    if (this.handle !is null) {
                        /*
                        * This performs better than getting the bits with Bitmap.LockBits(),
                        * but it cannot be used when there is transparency.
                        */
                        auto hDC = device.internal_new_GC(null);
                        auto srcHDC = OS.CreateCompatibleDC(hDC);
                        auto oldSrcBitmap = OS.SelectObject(srcHDC, this.handle);
                        auto graphics = Gdip.Graphics_new(srcHDC);
                        if (graphics !is null) {
                            Gdip.Rect rect;
                            rect.Width = width;
                            rect.Height = height;
                            status = Gdip.Graphics_DrawImage(graphics, cast(Gdip.Image)bitmap, rect, 0, 0, width, height, Gdip.UnitPixel, null, null, null);
                            if (status !is 0) {
                                error = SWT.ERROR_INVALID_IMAGE;
                                OS.DeleteObject(handle);
                                this.handle = null;
                            }
                            Gdip.Graphics_delete(graphics);
                        }
                        OS.SelectObject(srcHDC, oldSrcBitmap);
                        OS.DeleteDC(srcHDC);
                        device.internal_dispose_GC(hDC, null);
                    } else {
                        auto lockedBitmapData = Gdip.BitmapData_new();
                        if (lockedBitmapData !is null) {
                            Gdip.Bitmap_LockBits(bitmap, null, 0, pixelFormat, lockedBitmapData);
                            //BitmapData bitmapData = new BitmapData();
                            //Gdip.MoveMemory(bitmapData, lockedBitmapData);
                            auto stride = lockedBitmapData.Stride;
                            auto pixels = lockedBitmapData.Scan0;
                            int depth = 0, scanlinePad = 4, transparentPixel = -1;
                            switch (lockedBitmapData.PixelFormat) {
                                case Gdip.PixelFormat1bppIndexed: depth = 1; break;
                                case Gdip.PixelFormat4bppIndexed: depth = 4; break;
                                case Gdip.PixelFormat8bppIndexed: depth = 8; break;
                                case Gdip.PixelFormat16bppARGB1555:
                                case Gdip.PixelFormat16bppRGB555:
                                case Gdip.PixelFormat16bppRGB565: depth = 16; break;
                                case Gdip.PixelFormat24bppRGB: depth = 24; break;
                                case Gdip.PixelFormat32bppRGB:
                                case Gdip.PixelFormat32bppARGB: depth = 32; break;
                                default:
                            }
                            if (depth !is 0) {
                                PaletteData paletteData = null;
                                switch (lockedBitmapData.PixelFormat) {
                                    case Gdip.PixelFormat1bppIndexed:
                                    case Gdip.PixelFormat4bppIndexed:
                                    case Gdip.PixelFormat8bppIndexed:
                                        int paletteSize = Gdip.Image_GetPaletteSize(cast(Gdip.Image)bitmap);
                                        auto hHeap = OS.GetProcessHeap();
                                        auto palette = cast(Gdip.ColorPalette*) OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, paletteSize);
                                        if (palette is null) SWT.error(SWT.ERROR_NO_HANDLES);
                                        Gdip.Image_GetPalette(cast(Gdip.Image)bitmap, palette, paletteSize);
                                        Gdip.ColorPalette* colorPalette = palette;
                                        //Gdip.MoveMemory(colorPalette, palette, ColorPalette.sizeof);
                                        //int[] entries = new int[colorPalette.Count];
                                        //OS.MoveMemory(entries, palette + 8, entries.length * 4);

                                        //PORTING_COMMENT: moved down
                                        //OS.HeapFree(hHeap, 0, palette);
                                        RGB[] rgbs = new RGB[colorPalette.Count];
                                        paletteData = new PaletteData(rgbs);
                                        for (int i = 0; i < colorPalette.Count; i++) {
                                            // DWT: access palette.Entries without array bounds checking
                                            if (((*(palette.Entries.ptr + i) >> 24) & 0xFF) is 0 && (colorPalette.Flags & Gdip.PaletteFlagsHasAlpha) !is 0) {
                                                transparentPixel = i;
                                            }
                                            rgbs[i] = new RGB(((*(palette.Entries.ptr + i) & 0xFF0000) >> 16), ((*(palette.Entries.ptr + i) & 0xFF00) >> 8), ((*(palette.Entries.ptr + i) & 0xFF) >> 0));
                                        }
                                        OS.HeapFree(hHeap, 0, palette);
                                        break;
                                    case Gdip.PixelFormat16bppARGB1555:
                                    case Gdip.PixelFormat16bppRGB555: paletteData = new PaletteData(0x7C00, 0x3E0, 0x1F); break;
                                    case Gdip.PixelFormat16bppRGB565: paletteData = new PaletteData(0xF800, 0x7E0, 0x1F); break;
                                    case Gdip.PixelFormat24bppRGB: paletteData = new PaletteData(0xFF, 0xFF00, 0xFF0000); break;
                                    case Gdip.PixelFormat32bppRGB:
                                    case Gdip.PixelFormat32bppARGB: paletteData = new PaletteData(0xFF00, 0xFF0000, 0xFF000000); break;
                                    default:
                                }
                                byte[] data = new byte[ stride * height ], alphaData = null;
                                OS.MoveMemory(data.ptr, pixels, data.length);
                                switch (lockedBitmapData.PixelFormat) {
                                    case Gdip.PixelFormat16bppARGB1555:
                                        alphaData = new byte[width * height];
                                        for (int i = 1, j = 0; i < data.length; i += 2, j++) {
                                            alphaData[j] = cast(byte)((data[i] & 0x80) !is 0 ? 255 : 0);
                                        }
                                        break;
                                    case Gdip.PixelFormat32bppARGB:
                                        alphaData = new byte[width * height];
                                        for (int i = 3, j = 0; i < data.length; i += 4, j++) {
                                            alphaData[j] = data[i];
                                        }
                                        break;
                                    default:
                                }
                                Gdip.Bitmap_UnlockBits(bitmap, lockedBitmapData);
                                Gdip.BitmapData_delete(lockedBitmapData);
                                ImageData img = new ImageData(width, height, depth, paletteData, scanlinePad, data);
                                img.transparentPixel = transparentPixel;
                                img.alphaData = alphaData;
                                init_(img);
                            }
                        }
                    }
                }
            }
            Gdip.Bitmap_delete(bitmap);
            if (status is 0) {
                if (this.handle is null) SWT.error(error);
                return;
            }
        }
    }
    init_(new ImageData(filename));
    init_();
}

/**
 * Create a DIB from a DDB without using GetDIBits. Note that
 * the DDB should not be selected into a HDC.
 */
HBITMAP createDIBFromDDB(HDC hDC, HBITMAP hBitmap, int width, int height) {

    /* Determine the DDB depth */
    int bits = OS.GetDeviceCaps (hDC, OS.BITSPIXEL);
    int planes = OS.GetDeviceCaps (hDC, OS.PLANES);
    int depth = bits * planes;

    /* Determine the DIB palette */
    bool isDirect = depth > 8;
    RGB[] rgbs = null;
    if (!isDirect) {
        int numColors = 1 << depth;
        byte[] logPalette = new byte[4 * numColors];
        OS.GetPaletteEntries(device.hPalette, 0, numColors, cast(PALETTEENTRY*)logPalette.ptr);
        rgbs = new RGB[numColors];
        for (int i = 0; i < numColors; i++) {
            rgbs[i] = new RGB(logPalette[i] & 0xFF, logPalette[i + 1] & 0xFF, logPalette[i + 2] & 0xFF);
        }
    }

    bool useBitfields = OS.IsWinCE && (depth is 16 || depth is 32);
    BITMAPINFOHEADER bmiHeader;
    bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
    bmiHeader.biWidth = width;
    bmiHeader.biHeight = -height;
    bmiHeader.biPlanes = 1;
    bmiHeader.biBitCount = cast(short)depth;
    if (useBitfields) bmiHeader.biCompression = OS.BI_BITFIELDS;
    else bmiHeader.biCompression = OS.BI_RGB;
    byte[] bmi;
    if (isDirect) bmi = new byte[BITMAPINFOHEADER.sizeof + (useBitfields ? 12 : 0)];
    else  bmi = new byte[BITMAPINFOHEADER.sizeof + rgbs.length * 4];
    OS.MoveMemory(bmi.ptr, &bmiHeader, BITMAPINFOHEADER.sizeof);

    /* Set the rgb colors into the bitmap info */
    int offset = BITMAPINFOHEADER.sizeof;
    if (isDirect) {
        if (useBitfields) {
            int redMask = 0;
            int greenMask = 0;
            int blueMask = 0;
            switch (depth) {
                case 16:
                    redMask = 0x7C00;
                    greenMask = 0x3E0;
                    blueMask = 0x1F;
                    /* little endian */
                    bmi[offset] = cast(byte)((redMask & 0xFF) >> 0);
                    bmi[offset + 1] = cast(byte)((redMask & 0xFF00) >> 8);
                    bmi[offset + 2] = cast(byte)((redMask & 0xFF0000) >> 16);
                    bmi[offset + 3] = cast(byte)((redMask & 0xFF000000) >> 24);
                    bmi[offset + 4] = cast(byte)((greenMask & 0xFF) >> 0);
                    bmi[offset + 5] = cast(byte)((greenMask & 0xFF00) >> 8);
                    bmi[offset + 6] = cast(byte)((greenMask & 0xFF0000) >> 16);
                    bmi[offset + 7] = cast(byte)((greenMask & 0xFF000000) >> 24);
                    bmi[offset + 8] = cast(byte)((blueMask & 0xFF) >> 0);
                    bmi[offset + 9] = cast(byte)((blueMask & 0xFF00) >> 8);
                    bmi[offset + 10] = cast(byte)((blueMask & 0xFF0000) >> 16);
                    bmi[offset + 11] = cast(byte)((blueMask & 0xFF000000) >> 24);
                    break;
                case 32:
                    redMask = 0xFF00;
                    greenMask = 0xFF0000;
                    blueMask = 0xFF000000;
                    /* big endian */
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
                    break;
                default:
                    SWT.error(SWT.ERROR_UNSUPPORTED_DEPTH);
            }
        }
    } else {
        for (int j = 0; j < rgbs.length; j++) {
            bmi[offset] = cast(byte)rgbs[j].blue;
            bmi[offset + 1] = cast(byte)rgbs[j].green;
            bmi[offset + 2] = cast(byte)rgbs[j].red;
            bmi[offset + 3] = 0;
            offset += 4;
        }
    }
    void* pBits;
    HBITMAP hDib = OS.CreateDIBSection(null, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS, &pBits, null, 0);
    if (hDib is null) SWT.error(SWT.ERROR_NO_HANDLES);

    /* Bitblt DDB into DIB */
    auto hdcSource = OS.CreateCompatibleDC(hDC);
    auto hdcDest = OS.CreateCompatibleDC(hDC);
    auto hOldSrc = OS.SelectObject(hdcSource, hBitmap);
    auto hOldDest = OS.SelectObject(hdcDest, hDib);
    OS.BitBlt(hdcDest, 0, 0, width, height, hdcSource, 0, 0, OS.SRCCOPY);
    OS.SelectObject(hdcSource, hOldSrc);
    OS.SelectObject(hdcDest, hOldDest);
    OS.DeleteDC(hdcSource);
    OS.DeleteDC(hdcDest);

    return hDib;
}

// FIXME: Potential crash site in D:  createGdipImage casts pointers to int before
// returning them in an int[].  Since the D GC does not and cannot scan int's for
// pointers, there is potential that the pointer's object could be collected while still
// active, even though it might be unlikely given the short span of time that the
// function has them stored in the int array.

ptrdiff_t [] createGdipImage() {
    switch (type) {
        case SWT.BITMAP: {
            if (alpha !is -1 || alphaData !is null || transparentPixel !is -1) {
                BITMAP bm;
                OS.GetObject(handle, BITMAP.sizeof, &bm);
                int imgWidth = bm.bmWidth;
                int imgHeight = bm.bmHeight;
                auto hDC = device.internal_new_GC(null);
                auto srcHdc = OS.CreateCompatibleDC(hDC);
                auto oldSrcBitmap = OS.SelectObject(srcHdc, handle);
                auto memHdc = OS.CreateCompatibleDC(hDC);
                auto memDib = createDIB(imgWidth, imgHeight, 32);
                if (memDib is null) SWT.error(SWT.ERROR_NO_HANDLES);
                auto oldMemBitmap = OS.SelectObject(memHdc, memDib);
                BITMAP dibBM;
                OS.GetObject(memDib, BITMAP.sizeof, &dibBM);
                int sizeInBytes = dibBM.bmWidthBytes * dibBM.bmHeight;
                OS.BitBlt(memHdc, 0, 0, imgWidth, imgHeight, srcHdc, 0, 0, OS.SRCCOPY);
                ubyte red = 0, green = 0, blue = 0;
                if (transparentPixel !is -1) {
                    if (bm.bmBitsPixel <= 8)  {
                        ubyte[] color = new ubyte[4];
                        OS.GetDIBColorTable(srcHdc, transparentPixel, 1, cast(RGBQUAD*)color.ptr);
                        blue = color[0];
                        green = color[1];
                        red = color[2];
                    } else {
                        switch (bm.bmBitsPixel) {
                            case 16:
                                int blueMask = 0x1F;
                                int blueShift = ImageData.getChannelShift(blueMask);
                                byte[] blues = ImageData.ANY_TO_EIGHT[ImageData.getChannelWidth(blueMask, blueShift)];
                                blue = blues[(transparentPixel & blueMask) >> blueShift];
                                int greenMask = 0x3E0;
                                int greenShift = ImageData.getChannelShift(greenMask);
                                byte[] greens = ImageData.ANY_TO_EIGHT[ImageData.getChannelWidth(greenMask, greenShift)];
                                green = greens[(transparentPixel & greenMask) >> greenShift];
                                int redMask = 0x7C00;
                                int redShift = ImageData.getChannelShift(redMask);
                                byte[] reds = ImageData.ANY_TO_EIGHT[ImageData.getChannelWidth(redMask, redShift)];
                                red = reds[(transparentPixel & redMask) >> redShift];
                                break;
                            case 24:
                                blue = cast(ubyte)((transparentPixel & 0xFF0000) >> 16);
                                green = cast(ubyte)((transparentPixel & 0xFF00) >> 8);
                                red = cast(ubyte)(transparentPixel & 0xFF);
                                break;
                            case 32:
                                blue = cast(ubyte)((transparentPixel & 0xFF000000) >>> 24);
                                green = cast(ubyte)((transparentPixel & 0xFF0000) >> 16);
                                red = cast(ubyte)((transparentPixel & 0xFF00) >> 8);
                                break;
                            default:
                        }
                    }
                }
                OS.SelectObject(srcHdc, oldSrcBitmap);
                OS.SelectObject(memHdc, oldMemBitmap);
                OS.DeleteObject(srcHdc);
                OS.DeleteObject(memHdc);
                ubyte[] srcData = new ubyte[sizeInBytes];
                OS.MoveMemory(srcData.ptr, dibBM.bmBits, sizeInBytes);
                OS.DeleteObject(memDib);
                device.internal_dispose_GC(hDC, null);
                if (alpha !is -1) {
                    for (int y = 0, dp = 0; y < imgHeight; ++y) {
                        for (int x = 0; x < imgWidth; ++x) {
                            srcData[dp + 3] = cast(ubyte)alpha;
                            dp += 4;
                        }
                    }
                } else if (alphaData !is null) {
                    for (int y = 0, dp = 0, ap = 0; y < imgHeight; ++y) {
                        for (int x = 0; x < imgWidth; ++x) {
                            srcData[dp + 3] = alphaData[ap++];
                            dp += 4;
                        }
                    }
                } else if (transparentPixel !is -1) {
                    for (int y = 0, dp = 0; y < imgHeight; ++y) {
                        for (int x = 0; x < imgWidth; ++x) {
                            if (srcData[dp] is blue && srcData[dp + 1] is green && srcData[dp + 2] is red) {
                                srcData[dp + 3] = cast(ubyte)0;
                            } else {
                                srcData[dp + 3] = cast(ubyte)0xFF;
                            }
                            dp += 4;
                        }
                    }
                }
                auto hHeap = OS.GetProcessHeap();
                auto pixels = cast(ubyte*)OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, srcData.length);
                if (pixels is null) SWT.error(SWT.ERROR_NO_HANDLES);
                OS.MoveMemory(pixels, srcData.ptr, sizeInBytes);
                return [cast(ptrdiff_t)Gdip.Bitmap_new(imgWidth, imgHeight, dibBM.bmWidthBytes, Gdip.PixelFormat32bppARGB, pixels), cast(ptrdiff_t)pixels];
            }
            return [cast(ptrdiff_t)Gdip.Bitmap_new(handle, null), 0];
        }
        case SWT.ICON: {
            /*
            * Bug in GDI+. Creating a new GDI+ Bitmap from a HICON segment faults
            * when the icon width is bigger than the icon height.  The fix is to
            * detect this and create a PixelFormat32bppARGB image instead.
            */
            ICONINFO iconInfo;
            static if (OS.IsWinCE) {
                GetIconInfo(this, &iconInfo);
            } else {
                OS.GetIconInfo(handle, &iconInfo);
            }
            auto hBitmap = iconInfo.hbmColor;
            if (hBitmap is null) hBitmap = iconInfo.hbmMask;
            BITMAP bm;
            OS.GetObject(hBitmap, BITMAP.sizeof, &bm);
            int imgWidth = bm.bmWidth;
            int imgHeight = hBitmap is iconInfo.hbmMask ? bm.bmHeight / 2 : bm.bmHeight;
            Gdip.Bitmap img;
            ubyte* pixels;
            /*
            * Bug in GDI+.  Bitmap_new() segments fault if the image width
            * is greater than the image height.
            *
            * Note that it also fails to generated an appropriate alpha
            * channel when the icon depth is 32.
            */
            if (imgWidth > imgHeight || bm.bmBitsPixel is 32) {
                auto hDC = device.internal_new_GC(null);
                auto srcHdc = OS.CreateCompatibleDC(hDC);
                auto oldSrcBitmap = OS.SelectObject(srcHdc, hBitmap);
                auto memHdc = OS.CreateCompatibleDC(hDC);
                auto memDib = createDIB(imgWidth, imgHeight, 32);
                if (memDib is null) SWT.error(SWT.ERROR_NO_HANDLES);
                auto oldMemBitmap = OS.SelectObject(memHdc, memDib);
                BITMAP dibBM;
                OS.GetObject(memDib, BITMAP.sizeof, &dibBM);
                OS.BitBlt(memHdc, 0, 0, imgWidth, imgHeight, srcHdc, 0, hBitmap is iconInfo.hbmMask ? imgHeight : 0, OS.SRCCOPY);
                OS.SelectObject(memHdc, oldMemBitmap);
                OS.DeleteObject(memHdc);
                ubyte[] srcData = new ubyte[dibBM.bmWidthBytes * dibBM.bmHeight];
                OS.MoveMemory(srcData.ptr, dibBM.bmBits, srcData.length);
                OS.DeleteObject(memDib);
                OS.SelectObject(srcHdc, iconInfo.hbmMask);
                for (int y = 0, dp = 3; y < imgHeight; ++y) {
                    for (int x = 0; x < imgWidth; ++x) {
                        if (srcData[dp] is 0) {
                            if (OS.GetPixel(srcHdc, x, y) !is 0) {
                            srcData[dp] = cast(ubyte)0;
                            } else {
                            srcData[dp] = cast(ubyte)0xFF;
                            }
                        }
                        dp += 4;
                    }
                }
                OS.SelectObject(srcHdc, oldSrcBitmap);
                OS.DeleteObject(srcHdc);
                device.internal_dispose_GC(hDC, null);
                auto hHeap = OS.GetProcessHeap();
                pixels = cast(ubyte*) OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, srcData.length);
                if (pixels is null) SWT.error(SWT.ERROR_NO_HANDLES);
                OS.MoveMemory(pixels, srcData.ptr, srcData.length);
                img = Gdip.Bitmap_new(imgWidth, imgHeight, dibBM.bmWidthBytes, Gdip.PixelFormat32bppARGB, pixels);
            } else {
                img = Gdip.Bitmap_new(handle);
            }
            if (iconInfo.hbmColor !is null) OS.DeleteObject(iconInfo.hbmColor);
            if (iconInfo.hbmMask !is null) OS.DeleteObject(iconInfo.hbmMask);
            return [ cast(ptrdiff_t)img, cast(ptrdiff_t)pixels ];
        }
        default: SWT.error(SWT.ERROR_INVALID_IMAGE);
    }
    return null;
}

override
void destroy () {
    if (memGC !is null) memGC.dispose();
    if (type is SWT.ICON) {
        static if (OS.IsWinCE) data = null;
        OS.DestroyIcon (handle);
    } else {
        OS.DeleteObject (handle);
    }
    handle = null;
    memGC = null;
}

/**
 * Compares the argument to the receiver, and returns true
 * if they represent the <em>same</em> object using a class
 * specific comparison.
 *
 * @param object the object to compare with this object
 * @return <code>true</code> if the object is the same as this object and <code>false</code> otherwise
 *
 * @see #hashCode
 */
override public equals_t opEquals (Object object) {
    if (object is this) return true;
    if (!(cast(Image)object)) return false;
    Image image = cast(Image) object;
    return device is image.device && handle is image.handle;
}

/**
 * Returns the color to which to map the transparent pixel, or null if
 * the receiver has no transparent pixel.
 * <p>
 * There are certain uses of Images that do not support transparency
 * (for example, setting an image into a button or label). In these cases,
 * it may be desired to simulate transparency by using the background
 * color of the widget to paint the transparent pixels of the image.
 * Use this method to check which color will be used in these cases
 * in place of transparency. This value may be set with setBackground().
 * <p>
 *
 * @return the background color of the image, or null if there is no transparency in the image
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public Color getBackground() {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (transparentPixel is -1) return null;

    /* Get the HDC for the device */
    auto hDC = device.internal_new_GC(null);

    /* Compute the background color */
    BITMAP bm;
    OS.GetObject(handle, BITMAP.sizeof, &bm);
    auto hdcMem = OS.CreateCompatibleDC(hDC);
    auto hOldObject = OS.SelectObject(hdcMem, handle);
    int red = 0, green = 0, blue = 0;
    if (bm.bmBitsPixel <= 8)  {
        static if (OS.IsWinCE) {
            byte[1] pBits;
            OS.MoveMemory(pBits.ptr, bm.bmBits, 1);
            byte oldValue = pBits[0];
            int mask = (0xFF << (8 - bm.bmBitsPixel)) & 0x00FF;
            pBits[0] = cast(byte)((transparentPixel << (8 - bm.bmBitsPixel)) | (pBits[0] & ~mask));
            OS.MoveMemory(bm.bmBits, pBits.ptr, 1);
            int color = OS.GetPixel(hdcMem, 0, 0);
            pBits[0] = oldValue;
            OS.MoveMemory(bm.bmBits, pBits.ptr, 1);
            blue = (color & 0xFF0000) >> 16;
            green = (color & 0xFF00) >> 8;
            red = color & 0xFF;
        } else {
            RGBQUAD color;
            OS.GetDIBColorTable(hdcMem, transparentPixel, 1, &color);
            blue = color.rgbBlue;
            green = color.rgbGreen;
            red = color.rgbRed;
        }
    } else {
        switch (bm.bmBitsPixel) {
            case 16:
                blue = (transparentPixel & 0x1F) << 3;
                green = (transparentPixel & 0x3E0) >> 2;
                red = (transparentPixel & 0x7C00) >> 7;
                break;
            case 24:
                blue = (transparentPixel & 0xFF0000) >> 16;
                green = (transparentPixel & 0xFF00) >> 8;
                red = transparentPixel & 0xFF;
                break;
            case 32:
                blue = (transparentPixel & 0xFF000000) >>> 24;
                green = (transparentPixel & 0xFF0000) >> 16;
                red = (transparentPixel & 0xFF00) >> 8;
                break;
            default:
                return null;
        }
    }
    OS.SelectObject(hdcMem, hOldObject);
    OS.DeleteDC(hdcMem);

    /* Release the HDC for the device */
    device.internal_dispose_GC(hDC, null);
    return Color.win32_new(device, (blue << 16) | (green << 8) | red);
}

/**
 * Returns the bounds of the receiver. The rectangle will always
 * have x and y values of 0, and the width and height of the
 * image.
 *
 * @return a rectangle specifying the image's bounds
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_INVALID_IMAGE - if the image is not a bitmap or an icon</li>
 * </ul>
 */
public Rectangle getBounds() {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (width !is -1 && height !is -1) {
        return new Rectangle(0, 0, width, height);
    }
    switch (type) {
        case SWT.BITMAP:
            BITMAP bm;
            OS.GetObject(handle, BITMAP.sizeof, &bm);
            return new Rectangle(0, 0, width = bm.bmWidth, height = bm.bmHeight);
        case SWT.ICON:
            static if (OS.IsWinCE) {
                return new Rectangle(0, 0, width = data.width, height = data.height);
            } else {
                ICONINFO info;
                OS.GetIconInfo(handle, &info);
                auto hBitmap = info.hbmColor;
                if (hBitmap is null) hBitmap = info.hbmMask;
                BITMAP bm;
                OS.GetObject(hBitmap, BITMAP.sizeof, &bm);
                if (hBitmap is info.hbmMask) bm.bmHeight /= 2;
                if (info.hbmColor !is null) OS.DeleteObject(info.hbmColor);
                if (info.hbmMask !is null) OS.DeleteObject(info.hbmMask);
                return new Rectangle(0, 0, width = bm.bmWidth, height = bm.bmHeight);
            }
        default:
            SWT.error(SWT.ERROR_INVALID_IMAGE);
            return null;
    }
}

/**
 * Returns an <code>ImageData</code> based on the receiver
 * Modifications made to this <code>ImageData</code> will not
 * affect the Image.
 *
 * @return an <code>ImageData</code> containing the image's data and attributes
 *
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_INVALID_IMAGE - if the image is not a bitmap or an icon</li>
 * </ul>
 *
 * @see ImageData
 */
public ImageData getImageData() {
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    BITMAP bm;
    int depth, width, height;
    switch (type) {
        case SWT.ICON: {
            static if (OS.IsWinCE) return data;
            ICONINFO info;
            static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
            OS.GetIconInfo(handle, &info);
            /* Get the basic BITMAP information */
            auto hBitmap = info.hbmColor;
            if (hBitmap is null) hBitmap = info.hbmMask;
            OS.GetObject(hBitmap, BITMAP.sizeof, &bm);
            depth = bm.bmPlanes * bm.bmBitsPixel;
            width = bm.bmWidth;
            if (hBitmap is info.hbmMask) bm.bmHeight /= 2;
            height = bm.bmHeight;
            int numColors = 0;
            if (depth <= 8) numColors = 1 << depth;
            /* Create the BITMAPINFO */
            BITMAPINFOHEADER bmiHeader;
            bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
            bmiHeader.biWidth = width;
            bmiHeader.biHeight = -height;
            bmiHeader.biPlanes = 1;
            bmiHeader.biBitCount = cast(short)depth;
            bmiHeader.biCompression = OS.BI_RGB;
            byte[] bmi = new byte[BITMAPINFOHEADER.sizeof + numColors * 4];
            OS.MoveMemory(bmi.ptr, &bmiHeader, BITMAPINFOHEADER.sizeof);

            /* Get the HDC for the device */
            auto hDC = device.internal_new_GC(null);

            /* Create the DC and select the bitmap */
            auto hBitmapDC = OS.CreateCompatibleDC(hDC);
            auto hOldBitmap = OS.SelectObject(hBitmapDC, hBitmap);
            /* Select the palette if necessary */
            HPALETTE oldPalette;
            if (depth <= 8) {
                auto hPalette = device.hPalette;
                if (hPalette !is null) {
                    oldPalette = OS.SelectPalette(hBitmapDC, hPalette, false);
                    OS.RealizePalette(hBitmapDC);
                }
            }
            /* Find the size of the image and allocate data */
            int imageSize;
            /* Call with null lpBits to get the image size */
            static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
            OS.GetDIBits(hBitmapDC, hBitmap, 0, height, null, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS);
            OS.MoveMemory(&bmiHeader, bmi.ptr, BITMAPINFOHEADER.sizeof);
            imageSize = bmiHeader.biSizeImage;
            byte[] data = new byte[imageSize];
            /* Get the bitmap data */
            auto hHeap = OS.GetProcessHeap();
            auto lpvBits = cast(byte*) OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, imageSize);
            if (lpvBits is null) SWT.error(SWT.ERROR_NO_HANDLES);
            static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
            OS.GetDIBits(hBitmapDC, hBitmap, 0, height, lpvBits, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS);
            OS.MoveMemory(data.ptr, lpvBits, imageSize);
            /* Calculate the palette */
            PaletteData palette = null;
            if (depth <= 8) {
                RGB[] rgbs = new RGB[numColors];
                int srcIndex = 40;
                for (int i = 0; i < numColors; i++) {
                    rgbs[i] = new RGB(bmi[srcIndex + 2] & 0xFF, bmi[srcIndex + 1] & 0xFF, bmi[srcIndex] & 0xFF);
                    srcIndex += 4;
                }
                palette = new PaletteData(rgbs);
            } else if (depth is 16) {
                palette = new PaletteData(0x7C00, 0x3E0, 0x1F);
            } else if (depth is 24) {
                palette = new PaletteData(0xFF, 0xFF00, 0xFF0000);
            } else if (depth is 32) {
                palette = new PaletteData(0xFF00, 0xFF0000, 0xFF000000);
            } else {
                SWT.error(SWT.ERROR_UNSUPPORTED_DEPTH);
            }

            /* Do the mask */
            byte [] maskData = null;
            if (info.hbmColor is null) {
                /* Do the bottom half of the mask */
                static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
                OS.GetDIBits(hBitmapDC, hBitmap, height, height, lpvBits, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS);
                OS.MoveMemory(maskData.ptr, lpvBits, imageSize);
            } else {
                /* Do the entire mask */
                /* Create the BITMAPINFO */
                bmiHeader = BITMAPINFOHEADER.init;
                bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
                bmiHeader.biWidth = width;
                bmiHeader.biHeight = -height;
                bmiHeader.biPlanes = 1;
                bmiHeader.biBitCount = 1;
                bmiHeader.biCompression = OS.BI_RGB;
                bmi = new byte[BITMAPINFOHEADER.sizeof + 8];
                OS.MoveMemory(bmi.ptr, &bmiHeader, BITMAPINFOHEADER.sizeof);

                /* First color black, second color white */
                int offset = BITMAPINFOHEADER.sizeof;
                bmi[offset + 4] = bmi[offset + 5] = bmi[offset + 6] = cast(byte)0xFF;
                bmi[offset + 7] = 0;
                OS.SelectObject(hBitmapDC, info.hbmMask);
                /* Call with null lpBits to get the image size */
                static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
                OS.GetDIBits(hBitmapDC, info.hbmMask, 0, height, null, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS);
                OS.MoveMemory(&bmiHeader, bmi.ptr, BITMAPINFOHEADER.sizeof);
                imageSize = bmiHeader.biSizeImage;
                maskData = new byte[imageSize];
                auto lpvMaskBits = OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, imageSize);
                if (lpvMaskBits is null) SWT.error(SWT.ERROR_NO_HANDLES);
                static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
                OS.GetDIBits(hBitmapDC, info.hbmMask, 0, height, lpvMaskBits, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS);
                OS.MoveMemory(maskData.ptr, lpvMaskBits, imageSize);
                OS.HeapFree(hHeap, 0, lpvMaskBits);
                /* Loop to invert the mask */
                for (int i = 0; i < maskData.length; i++) {
                    maskData[i] ^= -1;
                }
                /* Make sure mask scanlinePad is 2 */
                int maskPad;
                int bpl = imageSize / height;
                for (maskPad = 1; maskPad < 128; maskPad++) {
                    int calcBpl = (((width + 7) / 8) + (maskPad - 1)) / maskPad * maskPad;
                    if (calcBpl is bpl) break;
                }
                maskData = ImageData.convertPad(maskData, width, height, 1, maskPad, 2);
            }
            /* Clean up */
            OS.HeapFree(hHeap, 0, lpvBits);
            OS.SelectObject(hBitmapDC, hOldBitmap);
            if (oldPalette !is null) {
                OS.SelectPalette(hBitmapDC, oldPalette, false);
                OS.RealizePalette(hBitmapDC);
            }
            OS.DeleteDC(hBitmapDC);

            /* Release the HDC for the device */
            device.internal_dispose_GC(hDC, null);

            if (info.hbmColor !is null) OS.DeleteObject(info.hbmColor);
            if (info.hbmMask !is null) OS.DeleteObject(info.hbmMask);
            /* Construct and return the ImageData */
            ImageData imageData = new ImageData(width, height, depth, palette, 4, data);
            imageData.maskData = maskData;
            imageData.maskPad = 2;
            return imageData;
        }
        case SWT.BITMAP: {
            /* Get the basic BITMAP information */
            bm = BITMAP.init;
            OS.GetObject(handle, BITMAP.sizeof, &bm);
            depth = bm.bmPlanes * bm.bmBitsPixel;
            width = bm.bmWidth;
            height = bm.bmHeight;
            /* Find out whether this is a DIB or a DDB. */
            bool isDib = (bm.bmBits !is null);
            /* Get the HDC for the device */
            auto hDC = device.internal_new_GC(null);

            /*
            * Feature in WinCE.  GetDIBits is not available in WinCE.  The
            * workaround is to create a temporary DIB from the DDB and use
            * the bmBits field of DIBSECTION to retrieve the image data.
            */
            auto handle = this.handle;
            static if (OS.IsWinCE) {
                if (!isDib) {
                    bool mustRestore = false;
                    if (memGC !is null && !memGC.isDisposed()) {
                        memGC.flush ();
                        mustRestore = true;
                        GCData data = memGC.data;
                        if (data.hNullBitmap !is null) {
                            OS.SelectObject(memGC.handle, data.hNullBitmap);
                            data.hNullBitmap = null;
                        }
                    }
                    handle = createDIBFromDDB(hDC, this.handle, width, height);
                    if (mustRestore) {
                        auto hOldBitmap = OS.SelectObject(memGC.handle, this.handle);
                        memGC.data.hNullBitmap = hOldBitmap;
                    }
                    isDib = true;
                }
            }
            DIBSECTION dib;
            if (isDib) {
                OS.GetObject(handle, DIBSECTION.sizeof, &dib);
            }
            /* Calculate number of colors */
            int numColors = 0;
            if (depth <= 8) {
                if (isDib) {
                    numColors = dib.dsBmih.biClrUsed;
                } else {
                    numColors = 1 << depth;
                }
            }
            /* Create the BITMAPINFO */
            byte[] bmi = null;
            BITMAPINFOHEADER bmiHeader;
            if (!isDib) {
                bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
                bmiHeader.biWidth = width;
                bmiHeader.biHeight = -height;
                bmiHeader.biPlanes = 1;
                bmiHeader.biBitCount = cast(short)depth;
                bmiHeader.biCompression = OS.BI_RGB;
                bmi = new byte[BITMAPINFOHEADER.sizeof + numColors * 4];
                OS.MoveMemory(bmi.ptr, &bmiHeader, BITMAPINFOHEADER.sizeof);
            }

            /* Create the DC and select the bitmap */
            auto hBitmapDC = OS.CreateCompatibleDC(hDC);
            auto hOldBitmap = OS.SelectObject(hBitmapDC, handle);
            /* Select the palette if necessary */
            HPALETTE oldPalette;
            if (!isDib && depth <= 8) {
                auto hPalette = device.hPalette;
                if (hPalette !is null) {
                    oldPalette = OS.SelectPalette(hBitmapDC, hPalette, false);
                    OS.RealizePalette(hBitmapDC);
                }
            }
            /* Find the size of the image and allocate data */
            int imageSize;
            if (isDib) {
                imageSize = dib.dsBmih.biSizeImage;
            } else {
                /* Call with null lpBits to get the image size */
                static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
                OS.GetDIBits(hBitmapDC, handle, 0, height, null, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS);
                OS.MoveMemory(&bmiHeader, bmi.ptr, BITMAPINFOHEADER.sizeof);
                imageSize = bmiHeader.biSizeImage;
            }
            byte[] data = new byte[imageSize];
            /* Get the bitmap data */
            if (isDib) {
                if (OS.IsWinCE) {
                    if (this.handle !is handle) {
                        /* get image data from the temporary DIB */
                        OS.MoveMemory(data.ptr, dib.dsBm.bmBits, imageSize);
                    }
                } else {
                    OS.MoveMemory(data.ptr, bm.bmBits, imageSize);
                }
            } else {
                auto hHeap = OS.GetProcessHeap();
                auto lpvBits = OS.HeapAlloc(hHeap, OS.HEAP_ZERO_MEMORY, imageSize);
                if (lpvBits is null) SWT.error(SWT.ERROR_NO_HANDLES);
                static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
                OS.GetDIBits(hBitmapDC, handle, 0, height, lpvBits, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS);
                OS.MoveMemory(data.ptr, lpvBits, imageSize);
                OS.HeapFree(hHeap, 0, lpvBits);
            }
            /* Calculate the palette */
            PaletteData palette = null;
            if (depth <= 8) {
                RGB[] rgbs = new RGB[numColors];
                if (isDib) {
                    static if (OS.IsWinCE) {
                        /*
                        * Feature on WinCE.  GetDIBColorTable is not supported.
                        * The workaround is to set a pixel to the desired
                        * palette index and use getPixel to get the corresponding
                        * RGB value.
                        */
                        int red = 0, green = 0, blue = 0;
                        byte[1] pBits;
                        OS.MoveMemory(pBits.ptr, bm.bmBits, 1);
                        byte oldValue = pBits[0];
                        int mask = (0xFF << (8 - bm.bmBitsPixel)) & 0x00FF;
                        for (int i = 0; i < numColors; i++) {
                            pBits[0] = cast(byte)((i << (8 - bm.bmBitsPixel)) | (pBits[0] & ~mask));
                            OS.MoveMemory(bm.bmBits, pBits.ptr, 1);
                            int color = OS.GetPixel(hBitmapDC, 0, 0);
                            blue = (color & 0xFF0000) >> 16;
                            green = (color & 0xFF00) >> 8;
                            red = color & 0xFF;
                            rgbs[i] = new RGB(red, green, blue);
                        }
                        pBits[0] = oldValue;
                        OS.MoveMemory(bm.bmBits, pBits.ptr, 1);
                    } else {
                        byte[] colors = new byte[numColors * 4];
                        OS.GetDIBColorTable(hBitmapDC, 0, numColors, cast(RGBQUAD*)colors.ptr);
                        int colorIndex = 0;
                        for (int i = 0; i < rgbs.length; i++) {
                            rgbs[i] = new RGB(colors[colorIndex + 2] & 0xFF, colors[colorIndex + 1] & 0xFF, colors[colorIndex] & 0xFF);
                            colorIndex += 4;
                        }
                    }
                } else {
                    int srcIndex = BITMAPINFOHEADER.sizeof;
                    for (int i = 0; i < numColors; i++) {
                        rgbs[i] = new RGB(bmi[srcIndex + 2] & 0xFF, bmi[srcIndex + 1] & 0xFF, bmi[srcIndex] & 0xFF);
                        srcIndex += 4;
                    }
                }
                palette = new PaletteData(rgbs);
            } else if (depth is 16) {
                palette = new PaletteData(0x7C00, 0x3E0, 0x1F);
            } else if (depth is 24) {
                palette = new PaletteData(0xFF, 0xFF00, 0xFF0000);
            } else if (depth is 32) {
                palette = new PaletteData(0xFF00, 0xFF0000, 0xFF000000);
            } else {
                SWT.error(SWT.ERROR_UNSUPPORTED_DEPTH);
            }
            /* Clean up */
            OS.SelectObject(hBitmapDC, hOldBitmap);
            if (oldPalette !is null) {
                OS.SelectPalette(hBitmapDC, oldPalette, false);
                OS.RealizePalette(hBitmapDC);
            }
            static if (OS.IsWinCE) {
                if (handle !is this.handle) {
                    /* free temporary DIB */
                    OS.DeleteObject (handle);
                }
            }
            OS.DeleteDC(hBitmapDC);

            /* Release the HDC for the device */
            device.internal_dispose_GC(hDC, null);

            /* Construct and return the ImageData */
            ImageData imageData = new ImageData(width, height, depth, palette, 4, data);
            imageData.transparentPixel = this.transparentPixel;
            imageData.alpha = alpha;
            if (alpha is -1 && alphaData !is null) {
                imageData.alphaData = new byte[alphaData.length];
                System.arraycopy(alphaData, 0, imageData.alphaData, 0, alphaData.length);
            }
            return imageData;
        }
        default:
            SWT.error(SWT.ERROR_INVALID_IMAGE);
            return null;
    }
}

/**
 * Returns an integer hash code for the receiver. Any two
 * objects that return <code>true</code> when passed to
 * <code>equals</code> must return the same value for this
 * method.
 *
 * @return the receiver's hash
 *
 * @see #equals
 */
override public hash_t toHash () {
    return cast(hash_t)handle;
}

void init_(int width, int height) {
    if (width <= 0 || height <= 0) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    type = SWT.BITMAP;
    auto hDC = device.internal_new_GC(null);
    handle = OS.CreateCompatibleBitmap(hDC, width, height);
    /*
    * Feature in Windows.  CreateCompatibleBitmap() may fail
    * for large images.  The fix is to create a DIB section
    * in that case.
    */
    if (handle is null) {
        int bits = OS.GetDeviceCaps(hDC, OS.BITSPIXEL);
        int planes = OS.GetDeviceCaps(hDC, OS.PLANES);
        int depth = bits * planes;
        if (depth < 16) depth = 16;
        handle = createDIB(width, height, depth);
    }
    if (handle !is null) {
        auto memDC = OS.CreateCompatibleDC(hDC);
        auto hOldBitmap = OS.SelectObject(memDC, handle);
        OS.PatBlt(memDC, 0, 0, width, height, OS.PATCOPY);
        OS.SelectObject(memDC, hOldBitmap);
        OS.DeleteDC(memDC);
    }
    device.internal_dispose_GC(hDC, null);
    if (handle is null) {
        SWT.error(SWT.ERROR_NO_HANDLES, null, device.getLastError());
    }
}

static HGDIOBJ createDIB(int width, int height, int depth) {
    BITMAPINFOHEADER bmiHeader;
    bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
    bmiHeader.biWidth = width;
    bmiHeader.biHeight = -height;
    bmiHeader.biPlanes = 1;
    bmiHeader.biBitCount = cast(short)depth;
    static if (OS.IsWinCE) bmiHeader.biCompression = OS.BI_BITFIELDS;
    else bmiHeader.biCompression = OS.BI_RGB;
    byte[] bmi = new byte[BITMAPINFOHEADER.sizeof + (OS.IsWinCE ? 12 : 0)];
    OS.MoveMemory(bmi.ptr, &bmiHeader, BITMAPINFOHEADER.sizeof);
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
    return OS.CreateDIBSection(null, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS, &pBits, null, 0);
}

/**
 * Feature in WinCE.  GetIconInfo is not available in WinCE.
 * The workaround is to cache the object ImageData for images
 * of type SWT.ICON. The bitmaps hbmMask and hbmColor can then
 * be reconstructed by using our version of getIconInfo.
 * This function takes an ICONINFO object and sets the fields
 * hbmMask and hbmColor with the corresponding bitmaps it has
 * created.
 * Note.  These bitmaps must be freed - as they would have to be
 * if the regular GetIconInfo had been used.
 */
static void GetIconInfo(Image image, ICONINFO* info) {
    ptrdiff_t[] result = init_(image.device, null, image.data);
    info.hbmColor = cast(HBITMAP)result[0];
    info.hbmMask = cast(HBITMAP)result[1];
}

static ptrdiff_t[] init_(Device device, Image image, ImageData i) {

    /*
     * BUG in Windows 98:
     * A monochrome DIBSection will display as solid black
     * on Windows 98 machines, even though it contains the
     * correct data. The fix is to convert 1-bit ImageData
     * into 4-bit ImageData before creating the image.
     */
    /* Windows does not support 2-bit images. Convert to 4-bit image. */
    if ((OS.IsWin95 && i.depth is 1 && i.getTransparencyType() !is SWT.TRANSPARENCY_MASK) || i.depth is 2) {
        ImageData img = new ImageData(i.width, i.height, 4, i.palette);
        ImageData.blit(ImageData.BLIT_SRC,
            i.data, i.depth, i.bytesPerLine, i.getByteOrder(), 0, 0, i.width, i.height, null, null, null,
            ImageData.ALPHA_OPAQUE, null, 0, 0, 0,
            img.data, img.depth, img.bytesPerLine, i.getByteOrder(), 0, 0, img.width, img.height, null, null, null,
            false, false);
        img.transparentPixel = i.transparentPixel;
        img.maskPad = i.maskPad;
        img.maskData = i.maskData;
        img.alpha = i.alpha;
        img.alphaData = i.alphaData;
        i = img;
    }
    /*
     * Windows supports 16-bit mask of (0x7C00, 0x3E0, 0x1F),
     * 24-bit mask of (0xFF0000, 0xFF00, 0xFF) and 32-bit mask
     * (0x00FF0000, 0x0000FF00, 0x000000FF) as documented in
     * MSDN BITMAPINFOHEADER.  Make sure the image is
     * Windows-supported.
     */
    /*
    * Note on WinCE.  CreateDIBSection requires the biCompression
    * field of the BITMAPINFOHEADER to be set to BI_BITFIELDS for
    * 16 and 32 bit direct images (see MSDN for CreateDIBSection).
    * In this case, the color mask can be set to any value.  For
    * consistency, it is set to the same mask used by non WinCE
    * platforms in BI_RGB mode.
    */
    if (i.palette.isDirect) {
        PaletteData palette = i.palette;
        int redMask = palette.redMask;
        int greenMask = palette.greenMask;
        int blueMask = palette.blueMask;
        int newDepth = i.depth;
        int newOrder = ImageData.MSB_FIRST;
        PaletteData newPalette = null;

        switch (i.depth) {
            case 8:
                newDepth = 16;
                newOrder = ImageData.LSB_FIRST;
                newPalette = new PaletteData(0x7C00, 0x3E0, 0x1F);
                break;
            case 16:
                newOrder = ImageData.LSB_FIRST;
                if (!(redMask is 0x7C00 && greenMask is 0x3E0 && blueMask is 0x1F)) {
                    newPalette = new PaletteData(0x7C00, 0x3E0, 0x1F);
                }
                break;
            case 24:
                if (!(redMask is 0xFF && greenMask is 0xFF00 && blueMask is 0xFF0000)) {
                    newPalette = new PaletteData(0xFF, 0xFF00, 0xFF0000);
                }
                break;
            case 32:
                if (!(redMask is 0xFF00 && greenMask is 0xFF0000 && blueMask is 0xFF000000)) {
                    newPalette = new PaletteData(0xFF00, 0xFF0000, 0xFF000000);
                }
                break;
            default:
                SWT.error(SWT.ERROR_UNSUPPORTED_DEPTH);
        }
        if (newPalette !is null) {
            ImageData img = new ImageData(i.width, i.height, newDepth, newPalette);
            ImageData.blit(ImageData.BLIT_SRC,
                    i.data, i.depth, i.bytesPerLine, i.getByteOrder(), 0, 0, i.width, i.height, redMask, greenMask, blueMask,
                    ImageData.ALPHA_OPAQUE, null, 0, 0, 0,
                    img.data, img.depth, img.bytesPerLine, newOrder, 0, 0, img.width, img.height, newPalette.redMask, newPalette.greenMask, newPalette.blueMask,
                    false, false);
            if (i.transparentPixel !is -1) {
                img.transparentPixel = newPalette.getPixel(palette.getRGB(i.transparentPixel));
            }
            img.maskPad = i.maskPad;
            img.maskData = i.maskData;
            img.alpha = i.alpha;
            img.alphaData = i.alphaData;
            i = img;
        }
    }
    /* Construct bitmap info header by hand */
    RGB[] rgbs = i.palette.getRGBs();
    bool useBitfields = OS.IsWinCE && (i.depth is 16 || i.depth is 32);
    BITMAPINFOHEADER bmiHeader;
    bmiHeader.biSize = BITMAPINFOHEADER.sizeof;
    bmiHeader.biWidth = i.width;
    bmiHeader.biHeight = -i.height;
    bmiHeader.biPlanes = 1;
    bmiHeader.biBitCount = cast(short)i.depth;
    if (useBitfields) bmiHeader.biCompression = OS.BI_BITFIELDS;
    else bmiHeader.biCompression = OS.BI_RGB;
    bmiHeader.biClrUsed = rgbs is null ? 0 : cast(int)/*64bit*/rgbs.length;
    byte[] bmi;
    if (i.palette.isDirect)
        bmi = new byte[BITMAPINFOHEADER.sizeof + (useBitfields ? 12 : 0)];
    else
        bmi = new byte[BITMAPINFOHEADER.sizeof + rgbs.length * 4];
    OS.MoveMemory(bmi.ptr, &bmiHeader, BITMAPINFOHEADER.sizeof);
    /* Set the rgb colors into the bitmap info */
    int offset = BITMAPINFOHEADER.sizeof;
    if (i.palette.isDirect) {
        if (useBitfields) {
            PaletteData palette = i.palette;
            int redMask = palette.redMask;
            int greenMask = palette.greenMask;
            int blueMask = palette.blueMask;
            /*
             * The color masks must be written based on the
             * endianness of the ImageData.
             */
            if (i.getByteOrder() is ImageData.LSB_FIRST) {
                bmi[offset] = cast(byte)((redMask & 0xFF) >> 0);
                bmi[offset + 1] = cast(byte)((redMask & 0xFF00) >> 8);
                bmi[offset + 2] = cast(byte)((redMask & 0xFF0000) >> 16);
                bmi[offset + 3] = cast(byte)((redMask & 0xFF000000) >> 24);
                bmi[offset + 4] = cast(byte)((greenMask & 0xFF) >> 0);
                bmi[offset + 5] = cast(byte)((greenMask & 0xFF00) >> 8);
                bmi[offset + 6] = cast(byte)((greenMask & 0xFF0000) >> 16);
                bmi[offset + 7] = cast(byte)((greenMask & 0xFF000000) >> 24);
                bmi[offset + 8] = cast(byte)((blueMask & 0xFF) >> 0);
                bmi[offset + 9] = cast(byte)((blueMask & 0xFF00) >> 8);
                bmi[offset + 10] = cast(byte)((blueMask & 0xFF0000) >> 16);
                bmi[offset + 11] = cast(byte)((blueMask & 0xFF000000) >> 24);
            } else {
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
        }
    } else {
        for (int j = 0; j < rgbs.length; j++) {
            bmi[offset] = cast(byte)rgbs[j].blue;
            bmi[offset + 1] = cast(byte)rgbs[j].green;
            bmi[offset + 2] = cast(byte)rgbs[j].red;
            bmi[offset + 3] = 0;
            offset += 4;
        }
    }
    void* pBits;
    auto hDib = OS.CreateDIBSection(null, cast(BITMAPINFO*)bmi.ptr, OS.DIB_RGB_COLORS, &pBits, null, 0);
    if (hDib is null) SWT.error(SWT.ERROR_NO_HANDLES);
    /* In case of a scanline pad other than 4, do the work to convert it */
    byte[] data = i.data;
    if (i.scanlinePad !is 4 && (i.bytesPerLine % 4 !is 0)) {
        data = ImageData.convertPad(data, i.width, i.height, i.depth, i.scanlinePad, 4);
    }
    OS.MoveMemory(pBits, data.ptr, data.length);

    ptrdiff_t [] result = null;
    if (i.getTransparencyType() is SWT.TRANSPARENCY_MASK) {
        /* Get the HDC for the device */
        auto hDC = device.internal_new_GC(null);

        /* Create the color bitmap */
        auto hdcSrc = OS.CreateCompatibleDC(hDC);
        OS.SelectObject(hdcSrc, hDib);
        auto hBitmap = OS.CreateCompatibleBitmap(hDC, i.width, i.height);
        if (hBitmap is null) SWT.error(SWT.ERROR_NO_HANDLES);
        auto hdcDest = OS.CreateCompatibleDC(hDC);
        OS.SelectObject(hdcDest, hBitmap);
        OS.BitBlt(hdcDest, 0, 0, i.width, i.height, hdcSrc, 0, 0, OS.SRCCOPY);

        /* Release the HDC for the device */
        device.internal_dispose_GC(hDC, null);

        /* Create the mask. Windows requires icon masks to have a scanline pad of 2. */
        byte[] maskData = ImageData.convertPad(i.maskData, i.width, i.height, 1, i.maskPad, 2);
        auto hMask = OS.CreateBitmap(i.width, i.height, 1, 1, maskData.ptr);
        if (hMask is null) SWT.error(SWT.ERROR_NO_HANDLES);
        OS.SelectObject(hdcSrc, hMask);
        OS.PatBlt(hdcSrc, 0, 0, i.width, i.height, OS.DSTINVERT);
        OS.DeleteDC(hdcSrc);
        OS.DeleteDC(hdcDest);
        OS.DeleteObject(hDib);

        if (image is null) {
            result = [cast(ptrdiff_t)hBitmap, cast(ptrdiff_t)hMask];
        } else {
            /* Create the icon */
            ICONINFO info;
            info.fIcon = true;
            info.hbmColor = hBitmap;
            info.hbmMask = hMask;
            auto hIcon = OS.CreateIconIndirect(&info);
            if (hIcon is null) SWT.error(SWT.ERROR_NO_HANDLES);
            OS.DeleteObject(hBitmap);
            OS.DeleteObject(hMask);
            image.handle = hIcon;
            image.type = SWT.ICON;
            static if (OS.IsWinCE) image.data = i;
        }
    } else {
        if (image is null) {
            result = [cast(ptrdiff_t)hDib];
        } else {
            image.handle = hDib;
            image.type = SWT.BITMAP;
            image.transparentPixel = i.transparentPixel;
            if (image.transparentPixel is -1) {
                image.alpha = i.alpha;
                if (i.alpha is -1 && i.alphaData !is null) {
                    int length = cast(int)/*64bit*/i.alphaData.length;
                    image.alphaData = new byte[length];
                    System.arraycopy(i.alphaData, 0, image.alphaData, 0, length);
                }
            }
        }
    }
    return result;
}

static ptrdiff_t[] init__(Device device, Image image, ImageData source, ImageData mask) {
    /* Create a temporary image and locate the black pixel */
    ImageData imageData;
    int blackIndex = 0;
    if (source.palette.isDirect) {
        imageData = new ImageData(source.width, source.height, source.depth, source.palette);
    } else {
        RGB black = new RGB(0, 0, 0);
        RGB[] rgbs = source.getRGBs();
        if (source.transparentPixel !is -1) {
            /*
             * The source had transparency, so we can use the transparent pixel
             * for black.
             */
            RGB[] newRGBs = new RGB[rgbs.length];
            System.arraycopy(rgbs, 0, newRGBs, 0, rgbs.length);
            if (source.transparentPixel >= newRGBs.length) {
                /* Grow the palette with black */
                rgbs = new RGB[source.transparentPixel + 1];
                System.arraycopy(newRGBs, 0, rgbs, 0, newRGBs.length);
                for (auto i = newRGBs.length; i <= source.transparentPixel; i++) {
                    rgbs[i] = new RGB(0, 0, 0);
                }
            } else {
                newRGBs[source.transparentPixel] = black;
                rgbs = newRGBs;
            }
            blackIndex = source.transparentPixel;
            imageData = new ImageData(source.width, source.height, source.depth, new PaletteData(rgbs));
        } else {
            while (blackIndex < rgbs.length) {
                if (rgbs[blackIndex] ==/*eq*/ black) break;
                blackIndex++;
            }
            if (blackIndex is rgbs.length) {
                /*
                 * We didn't find black in the palette, and there is no transparent
                 * pixel we can use.
                 */
                if ((1 << source.depth) > rgbs.length) {
                    /* We can grow the palette and add black */
                    RGB[] newRGBs = new RGB[rgbs.length + 1];
                    System.arraycopy(rgbs, 0, newRGBs, 0, rgbs.length);
                    newRGBs[rgbs.length] = black;
                    rgbs = newRGBs;
                } else {
                    /* No room to grow the palette */
                    blackIndex = -1;
                }
            }
            imageData = new ImageData(source.width, source.height, source.depth, new PaletteData(rgbs));
        }
    }
    if (blackIndex is -1) {
        /* There was no black in the palette, so just copy the data over */
        System.arraycopy(source.data, 0, imageData.data, 0, imageData.data.length);
    } else {
        /* Modify the source image to contain black wherever the mask is 0 */
        int[] imagePixels = new int[imageData.width];
        int[] maskPixels = new int[mask.width];
        for (int y = 0; y < imageData.height; y++) {
            source.getPixels(0, y, imageData.width, imagePixels, 0);
            mask.getPixels(0, y, mask.width, maskPixels, 0);
            for (int i = 0; i < imagePixels.length; i++) {
                if (maskPixels[i] is 0) imagePixels[i] = blackIndex;
            }
            imageData.setPixels(0, y, source.width, imagePixels, 0);
        }
    }
    imageData.maskPad = mask.scanlinePad;
    imageData.maskData = mask.data;
    return init_(device, image, imageData);
}
void init_(ImageData i) {
    if (i is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    init_(device, this, i);
}

/**
 * Invokes platform specific functionality to allocate a new GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Image</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param data the platform specific GC data
 * @return the platform specific GC handle
 */
public HDC internal_new_GC (GCData data) {
    if (handle is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    /*
    * Create a new GC that can draw into the image.
    * Only supported for bitmaps.
    */
    if (type !is SWT.BITMAP || memGC !is null) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }

    /* Create a compatible HDC for the device */
    auto hDC = device.internal_new_GC(null);
    auto imageDC = OS.CreateCompatibleDC(hDC);
    device.internal_dispose_GC(hDC, null);
    if (imageDC is null) SWT.error(SWT.ERROR_NO_HANDLES);

    if (data !is null) {
        /* Set the GCData fields */
        int mask = SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT;
        if ((data.style & mask) !is 0) {
            data.layout = (data.style & SWT.RIGHT_TO_LEFT) !is 0 ? OS.LAYOUT_RTL : 0;
        } else {
            data.style |= SWT.LEFT_TO_RIGHT;
        }
        data.device = device;
        data.image = this;
        data.font = device.systemFont;
    }
    return imageDC;
}

/**
 * Invokes platform specific functionality to dispose a GC handle.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Image</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param hDC the platform specific GC handle
 * @param data the platform specific GC data
 */
public void internal_dispose_GC (HDC hDC, GCData data) {
    OS.DeleteDC(hDC);
}

/**
 * Returns <code>true</code> if the image has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the image.
 * When an image has been disposed, it is an error to
 * invoke any other method using the image.
 *
 * @return <code>true</code> when the image is disposed and <code>false</code> otherwise
 */
override public bool isDisposed() {
    return handle is null;
}

/**
 * Sets the color to which to map the transparent pixel.
 * <p>
 * There are certain uses of <code>Images</code> that do not support
 * transparency (for example, setting an image into a button or label).
 * In these cases, it may be desired to simulate transparency by using
 * the background color of the widget to paint the transparent pixels
 * of the image. This method specifies the color that will be used in
 * these cases. For example:
 * <pre>
 *    Button b = new Button();
 *    image.setBackground(b.getBackground());
 *    b.setImage(image);
 * </pre>
 * </p><p>
 * The image may be modified by this operation (in effect, the
 * transparent regions may be filled with the supplied color).  Hence
 * this operation is not reversible and it is not legal to call
 * this function twice or with a null argument.
 * </p><p>
 * This method has no effect if the receiver does not have a transparent
 * pixel value.
 * </p>
 *
 * @param color the color to use when a transparent pixel is specified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the color is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the color has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_GRAPHIC_DISPOSED - if the receiver has been disposed</li>
 * </ul>
 */
public void setBackground(Color color) {
    /*
    * Note.  Not implemented on WinCE.
    */
    static if (OS.IsWinCE) return;
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (color is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (color.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (transparentPixel is -1) return;
    transparentColor = -1;

    /* Get the HDC for the device */
    auto hDC = device.internal_new_GC(null);

    /* Change the background color in the image */
    BITMAP bm;
    OS.GetObject(handle, BITMAP.sizeof, &bm);
    auto hdcMem = OS.CreateCompatibleDC(hDC);
    OS.SelectObject(hdcMem, handle);
    int maxColors = 1 << bm.bmBitsPixel;
    byte[] colors = new byte[maxColors * 4];
    static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
    int numColors = OS.GetDIBColorTable(hdcMem, 0, maxColors, cast(RGBQUAD*)colors.ptr);
    int offset = transparentPixel * 4;
    colors[offset] = cast(byte)color.getBlue();
    colors[offset + 1] = cast(byte)color.getGreen();
    colors[offset + 2] = cast(byte)color.getRed();
    static if (OS.IsWinCE) SWT.error(SWT.ERROR_NOT_IMPLEMENTED);
    OS.SetDIBColorTable(hdcMem, 0, numColors, cast(RGBQUAD*)colors.ptr);
    OS.DeleteDC(hdcMem);

    /* Release the HDC for the device */
    device.internal_dispose_GC(hDC, null);
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the receiver
 */
override public String toString () {
    if (isDisposed()) return "Image {*DISPOSED*}";
    return Format( "Image {{{}}", handle );
}

/**
 * Invokes platform specific functionality to allocate a new image.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Image</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param device the device on which to allocate the color
 * @param type the type of the image (<code>SWT.BITMAP</code> or <code>SWT.ICON</code>)
 * @param handle the OS handle for the image
 * @return a new image object containing the specified device, type and handle
 */
public static Image win32_new(Device device, int type, HGDIOBJ handle) {
    Image image = new Image(device);
    image.disposeChecking = false;
    image.type = type;
    image.handle = handle;
    return image;
}

}
