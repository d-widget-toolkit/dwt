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

import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.cairo.Cairo : Cairo;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
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

version(Tango){
import tango.stdc.string;
} else { // Phobos
}

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
     * The handle to the OS pixmap resource.
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public GdkDrawable* pixmap;

    /**
     * The handle to the OS mask resource.
     * (Warning: This field is platform dependent)
     * <p>
     * <b>IMPORTANT:</b> This field is <em>not</em> part of the SWT
     * public API. It is marked public only so that it can be shared
     * within the packages provided by SWT. It is not available on all
     * platforms and should never be accessed from application code.
     * </p>
     */
    public GdkDrawable* mask;

    org.eclipse.swt.internal.gtk.OS.cairo_surface_t* surface;
    org.eclipse.swt.internal.gtk.OS.cairo_surface_t* surfaceData;

    /**
     * specifies the transparent pixel
     */
    int transparentPixel = -1;

    /**
     * The GC the image is currently selected in.
     */
    GC memGC;

    /**
     * The alpha data of the image.
     */
    byte[] alphaData;

    /**
     * The global alpha value to be used for every pixel.
     */
    int alpha = -1;

    /**
     * The width of the image.
     */
    int width = -1;

    /**
     * The height of the image.
     */
    int height = -1;

    /**
     * Specifies the default scanline padding.
     */
    static const int DEFAULT_SCANLINE_PAD = 4;

this(Device device) {
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
    if (srcImage is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (srcImage.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    switch (flag) {
        case SWT.IMAGE_COPY:
        case SWT.IMAGE_DISABLE:
        case SWT.IMAGE_GRAY:
            break;
        default:
            SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    device = this.device;
    this.type = srcImage.type;

    /* Get source image size */
    int w, h;
    OS.gdk_drawable_get_size(srcImage.pixmap, &w, &h);
    int width = w;
    int height = h;

    /* Copy the mask */
    if ((srcImage.type is SWT.ICON && srcImage.mask !is null ) || srcImage.transparentPixel !is -1) {
        /* Generate the mask if necessary. */
        if (srcImage.transparentPixel !is -1) srcImage.createMask();
        //PORTING_FIXME cast
        GdkDrawable* mask = cast(GdkDrawable*) OS.gdk_pixmap_new( null, width, height, 1);
        if (mask is null ) SWT.error(SWT.ERROR_NO_HANDLES);
        auto gdkGC = OS.gdk_gc_new(mask);
        if (gdkGC is null) SWT.error(SWT.ERROR_NO_HANDLES);
        OS.gdk_draw_drawable(mask, gdkGC, srcImage.mask, 0, 0, 0, 0, width, height);
        OS.g_object_unref(gdkGC);
        this.mask = mask;
        /* Destroy the image mask if the there is a GC created on the image */
        if (srcImage.transparentPixel !is -1 && srcImage.memGC !is null) srcImage.destroyMask();
    }

    /* Copy transparent pixel and alpha data */
    if (flag !is SWT.IMAGE_DISABLE) transparentPixel = srcImage.transparentPixel;
    alpha = srcImage.alpha;
    if (srcImage.alphaData !is null) {
        alphaData = new byte[srcImage.alphaData.length];
        System.arraycopy(srcImage.alphaData, 0, alphaData, 0, alphaData.length);
    }
    createAlphaMask(width, height);

    /* Create the new pixmap */
    auto pixmap = cast(GdkDrawable*) OS.gdk_pixmap_new (cast(GdkDrawable*)OS.GDK_ROOT_PARENT(), width, height, -1);
    if (pixmap is null) SWT.error(SWT.ERROR_NO_HANDLES);
    auto gdkGC = OS.gdk_gc_new(pixmap);
    if (gdkGC is null) SWT.error(SWT.ERROR_NO_HANDLES);
    this.pixmap = pixmap;

    if (flag is SWT.IMAGE_COPY) {
        OS.gdk_draw_drawable(pixmap, gdkGC, srcImage.pixmap, 0, 0, 0, 0, width, height);
        OS.g_object_unref(gdkGC);
    } else {

        /* Retrieve the source pixmap data */
        auto pixbuf = OS.gdk_pixbuf_new(OS.GDK_COLORSPACE_RGB, false, 8, width, height);
        if (pixbuf is null) SWT.error(SWT.ERROR_NO_HANDLES);
        auto colormap = OS.gdk_colormap_get_system();
        OS.gdk_pixbuf_get_from_drawable(pixbuf, srcImage.pixmap, colormap, 0, 0, 0, 0, width, height);
        int stride = OS.gdk_pixbuf_get_rowstride(pixbuf);
        auto pixels = OS.gdk_pixbuf_get_pixels(pixbuf);

        /* Apply transformation */
        switch (flag) {
            case SWT.IMAGE_DISABLE: {
                Color zeroColor = device.getSystemColor(SWT.COLOR_WIDGET_NORMAL_SHADOW);
                RGB zeroRGB = zeroColor.getRGB();
                byte zeroRed = cast(byte)zeroRGB.red;
                byte zeroGreen = cast(byte)zeroRGB.green;
                byte zeroBlue = cast(byte)zeroRGB.blue;
                Color oneColor = device.getSystemColor(SWT.COLOR_WIDGET_BACKGROUND);
                RGB oneRGB = oneColor.getRGB();
                byte oneRed = cast(byte)oneRGB.red;
                byte oneGreen = cast(byte)oneRGB.green;
                byte oneBlue = cast(byte)oneRGB.blue;
                byte[] line = new byte[stride];
                for (int y=0; y<height; y++) {
                    OS.memmove(line.ptr, pixels + (y * stride), stride);
                    for (int x=0; x<width; x++) {
                        int offset = x*3;
                        int red = line[offset] & 0xFF;
                        int green = line[offset+1] & 0xFF;
                        int blue = line[offset+2] & 0xFF;
                        int intensity = red * red + green * green + blue * blue;
                        if (intensity < 98304) {
                            line[offset] = zeroRed;
                            line[offset+1] = zeroGreen;
                            line[offset+2] = zeroBlue;
                        } else {
                            line[offset] = oneRed;
                            line[offset+1] = oneGreen;
                            line[offset+2] = oneBlue;
                        }
                    }
                    OS.memmove(pixels + (y * stride), line.ptr, stride);
                }
                break;
            }
            case SWT.IMAGE_GRAY: {
                byte[] line = new byte[stride];
                for (int y=0; y<height; y++) {
                OS.memmove(line.ptr, pixels + (y * stride), stride);
                    for (int x=0; x<width; x++) {
                        int offset = x*3;
                        int red = line[offset] & 0xFF;
                        int green = line[offset+1] & 0xFF;
                        int blue = line[offset+2] & 0xFF;
                        byte intensity = cast(byte)((red+red+green+green+green+green+green+blue) >> 3);
                        line[offset] = line[offset+1] = line[offset+2] = intensity;
                    }
                    OS.memmove(pixels + (y * stride), line.ptr, stride);
                }
                break;
            }
        default:
        }

        /* Copy data back to destination pixmap */
        OS.gdk_pixbuf_render_to_drawable(pixbuf, pixmap, gdkGC, 0, 0, 0, 0, width, height, OS.GDK_RGB_DITHER_NORMAL, 0, 0);

        /* Free resources */
        OS.g_object_unref(pixbuf);
        OS.g_object_unref(gdkGC);
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
    mask = ImageData.convertMask (mask);
    ImageData image = new ImageData(source.width, source.height, source.depth, source.palette, source.scanlinePad, source.data);
    image.maskPad = mask.scanlinePad;
    image.maskData = mask.data;
    init_(image);
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
public this(Device device, InputStream stream) {
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
public this(Device device, String filename) {
    super(device);
    if (filename is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    try {
        auto length = filename.length;
        auto pixbuf = OS.gdk_pixbuf_new_from_file(toStringz(filename), null);
        if (pixbuf !is null) {
            bool hasAlpha = cast(bool)OS.gdk_pixbuf_get_has_alpha(pixbuf);
            if (hasAlpha) {
                /*
                * Bug in GTK. Depending on the image (seems to affect images that have
                * some degree of transparency all over the image), gdk_pixbuff_render_pixmap_and_mask()
                * will return a corrupt pixmap. To avoid this, read in and store the alpha channel data
                * for the image and then set it to 0xFF to prevent any possible corruption from
                * gdk_pixbuff_render_pixmap_and_mask().
                */
                int width = OS.gdk_pixbuf_get_width(pixbuf);
                int height = OS.gdk_pixbuf_get_height(pixbuf);
                int stride = OS.gdk_pixbuf_get_rowstride(pixbuf);
                auto pixels = OS.gdk_pixbuf_get_pixels(pixbuf);
                byte[] line = new byte[stride];
                alphaData = new byte[width * height];
                for (int y = 0; y < height; y++) {
                    OS.memmove(line.ptr, pixels + (y * stride), stride);
                    for (int x = 0; x < width; x++) {
                        alphaData[y*width+x] = line[x*4 + 3];
                        line[x*4 + 3] = cast(byte) 0xFF;
                    }
                    OS.memmove(pixels + (y * stride), line.ptr, stride);
                }
                createAlphaMask(width, height);
            }
            GdkPixmap* pixmap_return;
            OS.gdk_pixbuf_render_pixmap_and_mask(pixbuf, &pixmap_return, null, 0);
            this.type = SWT.BITMAP;
            this.pixmap = cast(GdkDrawable*)pixmap_return;
            if (pixmap is null) SWT.error(SWT.ERROR_NO_HANDLES);
            OS.g_object_unref (pixbuf);
            return;
        }
    } catch (SWTException e) {}
    init_(new ImageData(filename));
    init_();
}

void createAlphaMask (int width, int height) {
    if (device.useXRender && (alpha !is -1 || alphaData !is null)) {
        mask = cast(GdkDrawable*)OS.gdk_pixmap_new(null, alpha !is -1 ? 1 : width, alpha !is -1 ? 1 : height, 8);
        if (mask is null) SWT.error(SWT.ERROR_NO_HANDLES);
        auto gc = OS.gdk_gc_new(mask);
        if (alpha !is -1) {
            GdkColor* color = new GdkColor();
            color.pixel = (alpha & 0xFF) << 8 | (alpha & 0xFF);
            OS.gdk_gc_set_foreground(gc, color);
            OS.gdk_draw_rectangle(mask, gc, 1, 0, 0, 1, 1);
        } else {
            GdkImage* imagePtr = OS.gdk_drawable_get_image(mask, 0, 0, width, height);
            if (imagePtr is null) SWT.error(SWT.ERROR_NO_HANDLES);
            GdkImage* gdkImage = new GdkImage();
            *gdkImage = *imagePtr;
            if (gdkImage.bpl is width) {
                OS.memmove(gdkImage.mem, alphaData.ptr,
                           alphaData.length);
            } else {
                byte[] line = new byte[gdkImage.bpl];
                for (int y = 0; y < height; y++) {
                    System.arraycopy(alphaData, width * y, line, 0, width);
                    OS.memmove(gdkImage.mem + (gdkImage.bpl * y), line.ptr, gdkImage.bpl);
                }
            }
            OS.gdk_draw_image(mask, gc, imagePtr, 0, 0, 0, 0, width, height);
            OS.g_object_unref(imagePtr);
        }
        OS.g_object_unref(gc);
    }
}

/**
 * Create the receiver's mask if necessary.
 */
void createMask() {
    if (mask !is null ) return;
    mask = createMask(getImageData(), false);
    if (mask is null ) SWT.error(SWT.ERROR_NO_HANDLES);
}

GdkDrawable* createMask(ImageData image, bool copy) {
    ImageData mask = image.getTransparencyMask();
    byte[] data = mask.data;
    byte[] maskData = copy ? new byte[data.length] : data;
    for (int i = 0; i < maskData.length; i++) {
        byte s = data[i];
        maskData[i] = cast(byte)(((s & 0x80) >> 7) | ((s & 0x40) >> 5) |
            ((s & 0x20) >> 3) | ((s & 0x10) >> 1) | ((s & 0x08) << 1) |
            ((s & 0x04) << 3) | ((s & 0x02) << 5) | ((s & 0x01) << 7));
    }
    maskData = ImageData.convertPad(maskData, mask.width, mask.height, mask.depth, mask.scanlinePad, 1);
    return cast(GdkDrawable*)OS.gdk_bitmap_create_from_data(null, cast(char*)maskData.ptr, mask.width, mask.height);
}

void createSurface() {
    if (surface !is null ) return;
    /* Generate the mask if necessary. */
    if (transparentPixel !is -1) createMask();
    int w, h;
    OS.gdk_drawable_get_size(pixmap, &w, &h);
    int width = w, height = h;
    if (mask !is null || alpha !is -1 || alphaData !is null) {
        auto pixbuf = OS.gdk_pixbuf_new( OS.GDK_COLORSPACE_RGB, true, 8, width, height);
        if (pixbuf is null) SWT.error(SWT.ERROR_NO_HANDLES);
        auto colormap = OS.gdk_colormap_get_system();
        OS.gdk_pixbuf_get_from_drawable(pixbuf, pixmap, colormap, 0, 0, 0, 0, width, height);
        int stride = OS.gdk_pixbuf_get_rowstride(pixbuf);
        auto pixels = OS.gdk_pixbuf_get_pixels(pixbuf);
        byte[] line = new byte[stride];
        if (mask !is null && OS.gdk_drawable_get_depth(mask) is 1) {
            auto maskPixbuf = OS.gdk_pixbuf_new(OS.GDK_COLORSPACE_RGB, false, 8, width, height);
            if (maskPixbuf is null) SWT.error(SWT.ERROR_NO_HANDLES);
            OS.gdk_pixbuf_get_from_drawable(maskPixbuf, mask, null, 0, 0, 0, 0, width, height);
            int maskStride = OS.gdk_pixbuf_get_rowstride(maskPixbuf);
            auto maskPixels = OS.gdk_pixbuf_get_pixels(maskPixbuf);
            byte[] maskLine = new byte[maskStride];
            auto offset = pixels, maskOffset = maskPixels;
            for (int y=0; y<height; y++) {
                OS.memmove(line.ptr, offset, stride);
                OS.memmove(maskLine.ptr, maskOffset, maskStride);
                for (int x=0, offset1=0; x<width; x++, offset1 += 4) {
                    if (maskLine[x * 3] is 0) {
                        line[offset1 + 0] = line[offset1 + 1] = line[offset1 + 2] = line[offset1 + 3] = 0;
                    }
                    byte temp = line[offset1];
                    line[offset1] = line[offset1 + 2];
                    line[offset1 + 2] = temp;
                }
                OS.memmove(offset, line.ptr, stride);
                offset += stride;
                maskOffset += maskStride;
            }
            OS.g_object_unref(maskPixbuf);
        } else if (alpha !is -1) {
            auto offset = pixels;
            for (int y=0; y<height; y++) {
                OS.memmove(line.ptr, offset, stride);
                for (int x=0, offset1=0; x<width; x++, offset1 += 4) {
                    line[offset1+3] = cast(byte)alpha;
                    /* pre-multiplied alpha */
                    int r = ((line[offset1 + 0] & 0xFF) * alpha) + 128;
                    r = (r + (r >> 8)) >> 8;
                    int g = ((line[offset1 + 1] & 0xFF) * alpha) + 128;
                    g = (g + (g >> 8)) >> 8;
                    int b = ((line[offset1 + 2] & 0xFF) * alpha) + 128;
                    b = (b + (b >> 8)) >> 8;
                    line[offset1 + 0] = cast(byte)b;
                    line[offset1 + 1] = cast(byte)g;
                    line[offset1 + 2] = cast(byte)r;
                }
                OS.memmove(offset, line.ptr, stride);
                offset += stride;
            }
        } else if (alphaData !is null) {
            auto offset = pixels;
            for (int y = 0; y < h; y++) {
                OS.memmove (line.ptr, offset, stride);
                for (int x=0, offset1=0; x<width; x++, offset1 += 4) {
                    int alpha = alphaData [y*w+x] & 0xFF;
                    line[offset1+3] = cast(byte)alpha;
                    /* pre-multiplied alpha */
                    int r = ((line[offset1 + 0] & 0xFF) * alpha) + 128;
                    r = (r + (r >> 8)) >> 8;
                    int g = ((line[offset1 + 1] & 0xFF) * alpha) + 128;
                    g = (g + (g >> 8)) >> 8;
                    int b = ((line[offset1 + 2] & 0xFF) * alpha) + 128;
                    b = (b + (b >> 8)) >> 8;
                    line[offset1 + 0] = cast(byte)b;
                    line[offset1 + 1] = cast(byte)g;
                    line[offset1 + 2] = cast(byte)r;
                }
                OS.memmove (offset, line.ptr, stride);
                offset += stride;
            }
        } else {
            auto offset = pixels;
            for (int y = 0; y < h; y++) {
                OS.memmove (line.ptr, offset, stride);
                for (int x=0, offset1=0; x<width; x++, offset1 += 4) {
                    line[offset1+3] = cast(byte)0xFF;
                    byte temp = line[offset1];
                    line[offset1] = line[offset1 + 2];
                    line[offset1 + 2] = temp;
                }
                OS.memmove (offset, line.ptr, stride);
                offset += stride;
            }
        }
        surfaceData = cast(org.eclipse.swt.internal.gtk.OS.cairo_surface_t*) OS.g_malloc(stride * height);
        OS.memmove(surfaceData, pixels, stride * height);
        surface = Cairo.cairo_image_surface_create_for_data(cast(char*)surfaceData, Cairo.CAIRO_FORMAT_ARGB32, width, height, stride);
        OS.g_object_unref(pixbuf);
    } else {
        auto xDisplay = OS.GDK_DISPLAY();
        auto xDrawable = OS.GDK_PIXMAP_XID(pixmap);
        auto xVisual = OS.gdk_x11_visual_get_xvisual(OS.gdk_visual_get_system());
        // PORTING_FIXME  cast and types not good
        surface = Cairo.cairo_xlib_surface_create(cast(void*)xDisplay, xDrawable, xVisual, width, height);
    }
    /* Destroy the image mask if the there is a GC created on the image */
    if (transparentPixel !is -1 && memGC !is null) destroyMask();
}

/**
 * Destroy the receiver's mask if it exists.
 */
void destroyMask() {
    if (mask is null) return;
    OS.g_object_unref(mask);
    mask = null;
}

override
void destroy() {
    if (memGC !is null) memGC.dispose();
    if (pixmap !is null) OS.g_object_unref(pixmap);
    if (mask !is null) OS.g_object_unref(mask);
    if (surface !is null) Cairo.cairo_surface_destroy(surface);
    if (surfaceData !is null) OS.g_free(surfaceData);
    surfaceData = null;
    surface = null;
    pixmap = null;
    mask = null;
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
public override equals_t opEquals (Object object) {
    if (object is this) return true;
    if ( auto image = cast(Image)object ){
        return device is image.device && pixmap is image.pixmap;
    }
    return false;
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
    //NOT DONE
    return null;
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
    int w, h;
    OS.gdk_drawable_get_size(pixmap, &w, &h);
    return new Rectangle(0, 0, width = w, height = h);
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

    int w, h;
    OS.gdk_drawable_get_size(pixmap, &w, &h);
    int width = w, height = h;
    auto pixbuf = OS.gdk_pixbuf_new(OS.GDK_COLORSPACE_RGB, false, 8, width, height);
    if (pixbuf is null) SWT.error(SWT.ERROR_NO_HANDLES);
    auto colormap = OS.gdk_colormap_get_system();
    OS.gdk_pixbuf_get_from_drawable(pixbuf, pixmap, colormap, 0, 0, 0, 0, width, height);
    int stride = OS.gdk_pixbuf_get_rowstride(pixbuf);
    auto pixels = OS.gdk_pixbuf_get_pixels(pixbuf);
    byte[] srcData = new byte[stride * height];
    OS.memmove(srcData.ptr, pixels, srcData.length);
    OS.g_object_unref(pixbuf);

    PaletteData palette = new PaletteData(0xFF0000, 0xFF00, 0xFF);
    ImageData data = new ImageData(width, height, 24, palette);
    data.data = srcData;
    data.bytesPerLine = stride;

    if (transparentPixel is -1 && type is SWT.ICON && mask !is null) {
        /* Get the icon mask data */
        auto gdkImagePtr = OS.gdk_drawable_get_image(mask, 0, 0, width, height);
        if (gdkImagePtr is null) SWT.error(SWT.ERROR_NO_HANDLES);
        GdkImage* gdkImage = new GdkImage();
        OS.memmove(gdkImage, gdkImagePtr, GdkImage.sizeof );
        byte[] maskData = new byte[gdkImage.bpl * gdkImage.height];
        OS.memmove(maskData.ptr, gdkImage.mem, maskData.length);
        OS.g_object_unref(gdkImagePtr);
        int maskPad;
        for (maskPad = 1; maskPad < 128; maskPad++) {
            int bpl = ((((width + 7) / 8) + (maskPad - 1)) / maskPad * maskPad);
            if (gdkImage.bpl is bpl) break;
        }
        /* Make mask scanline pad equals to 2 */
        data.maskPad = 2;
        maskData = ImageData.convertPad(maskData, width, height, 1, maskPad, data.maskPad);
        /* Bit swap the mask data if necessary */
        if (gdkImage.byte_order is OS.GDK_LSB_FIRST) {
            for (int i = 0; i < maskData.length; i++) {
                byte b = maskData[i];
                maskData[i] = cast(byte)(((b & 0x01) << 7) | ((b & 0x02) << 5) |
                    ((b & 0x04) << 3) | ((b & 0x08) << 1) | ((b & 0x10) >> 1) |
                    ((b & 0x20) >> 3) | ((b & 0x40) >> 5) | ((b & 0x80) >> 7));
            }
        }
        data.maskData = maskData;
    }
    data.transparentPixel = transparentPixel;
    data.alpha = alpha;
    if (alpha is -1 && alphaData !is null) {
        data.alphaData = new byte[alphaData.length];
        System.arraycopy(alphaData, 0, data.alphaData, 0, alphaData.length);
    }
    return data;
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
 * @param pixmap the OS handle for the image
 * @param mask the OS handle for the image mask
 *
 * @private
 */
public static Image gtk_new(Device device, int type, GdkDrawable* pixmap, GdkDrawable* mask) {
    Image image = new Image(device);
    image.type = type;
    image.pixmap = cast(GdkDrawable*)pixmap;
    image.mask = cast(GdkDrawable*)mask;
    return image;
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
public override hash_t toHash () {
    return cast(hash_t)pixmap;
}

void init_(int width, int height) {
    if (width <= 0 || height <= 0) {
        SWT.error (SWT.ERROR_INVALID_ARGUMENT);
    }
    this.type = SWT.BITMAP;

    /* Create the pixmap */
    this.pixmap = cast(GdkDrawable*) OS.gdk_pixmap_new(cast(GdkDrawable*)OS.GDK_ROOT_PARENT(), width, height, -1);
    if (pixmap is null) SWT.error(SWT.ERROR_NO_HANDLES);
    /* Fill the bitmap with white */
    GdkColor* white = new GdkColor();
    white.red = 0xFFFF;
    white.green = 0xFFFF;
    white.blue = 0xFFFF;
    auto colormap = OS.gdk_colormap_get_system();
    OS.gdk_colormap_alloc_color(colormap, white, true, true);
    auto gdkGC = OS.gdk_gc_new(pixmap);
    OS.gdk_gc_set_foreground(gdkGC, white);
    OS.gdk_draw_rectangle(pixmap, gdkGC, 1, 0, 0, width, height);
    OS.g_object_unref(gdkGC);
    OS.gdk_colormap_free_colors(colormap, white, 1);
}

void init_(ImageData image) {
    if (image is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    int width = image.width;
    int height = image.height;
    PaletteData palette = image.palette;
    if (!(((image.depth is 1 || image.depth is 2 || image.depth is 4 || image.depth is 8) && !palette.isDirect) ||
        ((image.depth is 8) || (image.depth is 16 || image.depth is 24 || image.depth is 32) && palette.isDirect)))
            SWT.error (SWT.ERROR_UNSUPPORTED_DEPTH);
    auto pixbuf = OS.gdk_pixbuf_new( OS.GDK_COLORSPACE_RGB, false, 8, width, height);
    if (pixbuf is null) SWT.error(SWT.ERROR_NO_HANDLES);
    int stride = OS.gdk_pixbuf_get_rowstride(pixbuf);
    auto data = OS.gdk_pixbuf_get_pixels(pixbuf);
    byte[] buffer = image.data;
    if (!palette.isDirect || image.depth !is 24 || stride !is image.bytesPerLine || palette.redMask !is 0xFF0000 || palette.greenMask !is 0xFF00 || palette.blueMask !is 0xFF) {
        buffer = new byte[stride * height];
        if (palette.isDirect) {
            ImageData.blit(ImageData.BLIT_SRC,
                image.data, image.depth, image.bytesPerLine, image.getByteOrder(), 0, 0, width, height, palette.redMask, palette.greenMask, palette.blueMask,
                ImageData.ALPHA_OPAQUE, null, 0, 0, 0,
                buffer, 24, stride, ImageData.MSB_FIRST, 0, 0, width, height, 0xFF0000, 0xFF00, 0xFF,
                false, false);
        } else {
            RGB[] rgbs = palette.getRGBs();
            auto length = rgbs.length;
            byte[] srcReds = new byte[length];
            byte[] srcGreens = new byte[length];
            byte[] srcBlues = new byte[length];
            for (ptrdiff_t i = 0; i < rgbs.length; i++) {
                RGB rgb = rgbs[i];
                if (rgb is null) continue;
                srcReds[i] = cast(byte)rgb.red;
                srcGreens[i] = cast(byte)rgb.green;
                srcBlues[i] = cast(byte)rgb.blue;
            }
            ImageData.blit(ImageData.BLIT_SRC,
                image.data, image.depth, image.bytesPerLine, image.getByteOrder(), 0, 0, width, height, srcReds, srcGreens, srcBlues,
                ImageData.ALPHA_OPAQUE, null, 0, 0, 0,
                buffer, 24, stride, ImageData.MSB_FIRST, 0, 0, width, height, 0xFF0000, 0xFF00, 0xFF,
                false, false);
        }
    }
    OS.memmove(data, buffer.ptr, stride * height);
    auto pixmap = cast(GdkDrawable*) OS.gdk_pixmap_new (cast(GdkDrawable*) OS.GDK_ROOT_PARENT(), width, height, -1);
    if (pixmap is null) SWT.error(SWT.ERROR_NO_HANDLES);
    auto gdkGC = OS.gdk_gc_new(pixmap);
    if (gdkGC is null) SWT.error(SWT.ERROR_NO_HANDLES);
    OS.gdk_pixbuf_render_to_drawable(pixbuf, pixmap, gdkGC, 0, 0, 0, 0, width, height, OS.GDK_RGB_DITHER_NORMAL, 0, 0);
    OS.g_object_unref(gdkGC);
    OS.g_object_unref(pixbuf);

    bool isIcon = image.getTransparencyType() is SWT.TRANSPARENCY_MASK;
    if (isIcon || image.transparentPixel !is -1) {
        if (image.transparentPixel !is -1) {
            RGB rgb = null;
            if (palette.isDirect) {
                rgb = palette.getRGB(image.transparentPixel);
            } else {
                if (image.transparentPixel < palette.colors.length) {
                    rgb = palette.getRGB(image.transparentPixel);
                }
            }
            if (rgb !is null) {
                transparentPixel = rgb.red << 16 | rgb.green << 8 | rgb.blue;
            }
        }
        auto mask = createMask(image, isIcon);
        if (mask is null) SWT.error(SWT.ERROR_NO_HANDLES);
        this.mask = mask;
        if (isIcon) {
            this.type = SWT.ICON;
        } else {
            this.type = SWT.BITMAP;
        }
    } else {
        this.type = SWT.BITMAP;
        this.mask = null;
        this.alpha = image.alpha;
        if (image.alpha is -1 && image.alphaData !is null) {
            this.alphaData = new byte[image.alphaData.length];
            System.arraycopy(image.alphaData, 0, this.alphaData, 0, alphaData.length);
        }
        createAlphaMask(width, height);
    }
    this.pixmap = pixmap;
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
public GdkGC* internal_new_GC (GCData data) {
    if (pixmap is null) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (type !is SWT.BITMAP || memGC !is null) {
        SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    }
    auto gdkGC = OS.gdk_gc_new(pixmap);
    if (data !is null) {
        int mask = SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT;
        if ((data.style & mask) is 0) {
            data.style |= SWT.LEFT_TO_RIGHT;
        } else {
            if ((data.style & SWT.RIGHT_TO_LEFT) !is 0) {
                data.style |= SWT.MIRRORED;
            }
        }
        data.device = device;
        data.drawable = pixmap;
        data.background = device.COLOR_WHITE.handle;
        data.foreground = device.COLOR_BLACK.handle;
        data.font = device.systemFont;
        data.image = this;
    }
    return gdkGC;
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
public void internal_dispose_GC ( GdkGC* gdkGC, GCData data) {
    OS.g_object_unref(gdkGC);
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
public override bool isDisposed() {
    return pixmap is null;
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
    if (isDisposed()) SWT.error(SWT.ERROR_GRAPHIC_DISPOSED);
    if (color is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (color.isDisposed()) SWT.error(SWT.ERROR_INVALID_ARGUMENT);
    if (transparentPixel is -1) return;
    //NOT DONE
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
    import tango.core.Exception;
 *
 * @return a string representation of the receiver
 */
public override String toString () {
    if (isDisposed()) return "Image {*DISPOSED*}";
    return Format( "Image {{{}}", pixmap);
}

}

