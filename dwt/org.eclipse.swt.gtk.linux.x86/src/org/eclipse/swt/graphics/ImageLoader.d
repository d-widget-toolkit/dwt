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
module org.eclipse.swt.graphics.ImageLoader;

import java.lang.all;
import java.util.Vector;


public import org.eclipse.swt.graphics.ImageLoaderListener;
public import org.eclipse.swt.graphics.ImageLoaderEvent;
public import org.eclipse.swt.graphics.ImageData;

import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.Compatibility;
import org.eclipse.swt.internal.image.FileFormat;

version(Tango){
import tango.core.Array;
} else { // Phobos
}


/**
 * Instances of this class are used to load images from,
 * and save images to, a file or stream.
 * <p>
 * Currently supported image formats are:
 * </p><ul>
 * <li>BMP (Windows or OS/2 Bitmap)</li>
 * <li>ICO (Windows Icon)</li>
 * <li>JPEG</li>
 * <li>GIF</li>
 * <li>PNG</li>
 * <li>TIFF</li>
 * </ul>
 * <code>ImageLoaders</code> can be used to:
 * <ul>
 * <li>load/save single images in all formats</li>
 * <li>load/save multiple images (GIF/ICO/TIFF)</li>
 * <li>load/save animated GIF images</li>
 * <li>load interlaced GIF/PNG images</li>
 * <li>load progressive JPEG images</li>
 * </ul>
 *
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ImageAnalyzer</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class ImageLoader {

    /**
     * the array of ImageData objects in this ImageLoader.
     * This array is read in when the load method is called,
     * and it is written out when the save method is called
     */
    public ImageData[] data;

    /**
     * the width of the logical screen on which the images
     * reside, in pixels (this corresponds to the GIF89a
     * Logical Screen Width value)
     */
    public int logicalScreenWidth;

    /**
     * the height of the logical screen on which the images
     * reside, in pixels (this corresponds to the GIF89a
     * Logical Screen Height value)
     */
    public int logicalScreenHeight;

    /**
     * the background pixel for the logical screen (this
     * corresponds to the GIF89a Background Color Index value).
     * The default is -1 which means 'unspecified background'
     *
     */
    public int backgroundPixel;

    /**
     * the number of times to repeat the display of a sequence
     * of animated images (this corresponds to the commonly-used
     * GIF application extension for "NETSCAPE 2.0 01").
     * The default is 1. A value of 0 means 'display repeatedly'
     */
    public int repeatCount;

    /*
     * the set of ImageLoader event listeners, created on demand
     */
    Vector imageLoaderListeners;

/**
 * Construct a new empty ImageLoader.
 */
public this() {
    imageLoaderListeners = new Vector();
    reset();
}

/**
 * Resets the fields of the ImageLoader, except for the
 * <code>imageLoaderListeners</code> field.
 */
void reset() {
    data = null;
    logicalScreenWidth = 0;
    logicalScreenHeight = 0;
    backgroundPixel = -1;
    repeatCount = 1;
}

/**
 * Loads an array of <code>ImageData</code> objects from the
 * specified input stream. Throws an error if either an error
 * occurs while loading the images, or if the images are not
 * of a supported type. Returns the loaded image data array.
 *
 * @param stream the input stream to load the images from
 * @return an array of <code>ImageData</code> objects loaded from the specified input stream
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the stream is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_IO - if an IO error occurs while reading from the stream</li>
 *    <li>ERROR_INVALID_IMAGE - if the image stream contains invalid data</li>
 *    <li>ERROR_UNSUPPORTED_FORMAT - if the image stream contains an unrecognized format</li>
 * </ul>
 */
public ImageData[] load(InputStream stream) {
    if (stream is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    reset();
    data = FileFormat.load(stream, this);
    return data;
}

/**
 * Loads an array of <code>ImageData</code> objects from the
 * file with the specified name. Throws an error if either
 * an error occurs while loading the images, or if the images are
 * not of a supported type. Returns the loaded image data array.
 *
 * @param filename the name of the file to load the images from
 * @return an array of <code>ImageData</code> objects loaded from the specified file
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the file name is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_IO - if an IO error occurs while reading from the file</li>
 *    <li>ERROR_INVALID_IMAGE - if the image file contains invalid data</li>
 *    <li>ERROR_UNSUPPORTED_FORMAT - if the image file contains an unrecognized format</li>
 * </ul>
 */
public ImageData[] load(String filename) {
    if (filename is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    InputStream stream = null;
    void close(){
        try {
            if( stream !is null ) stream.close();
        } catch (IOException e) {
            // Ignore error
        }
    }
    try {
        stream = Compatibility.newFileInputStream(filename);
        scope(exit) close();

        return load(stream);
    } catch (IOException e) {
        SWT.error(SWT.ERROR_IO, e);
    }
    return null;
}

/**
 * Saves the image data in this ImageLoader to the specified stream.
 * The format parameter can have one of the following values:
 * <dl>
 * <dt><code>IMAGE_BMP</code></dt>
 * <dd>Windows BMP file format, no compression</dd>
 * <dt><code>IMAGE_BMP_RLE</code></dt>
 * <dd>Windows BMP file format, RLE compression if appropriate</dd>
 * <dt><code>IMAGE_GIF</code></dt>
 * <dd>GIF file format</dd>
 * <dt><code>IMAGE_ICO</code></dt>
 * <dd>Windows ICO file format</dd>
 * <dt><code>IMAGE_JPEG</code></dt>
 * <dd>JPEG file format</dd>
 * <dt><code>IMAGE_PNG</code></dt>
 * <dd>PNG file format</dd>
 * </dl>
 *
 * @param stream the output stream to write the images to
 * @param format the format to write the images in
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the stream is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_IO - if an IO error occurs while writing to the stream</li>
 *    <li>ERROR_INVALID_IMAGE - if the image data contains invalid data</li>
 *    <li>ERROR_UNSUPPORTED_FORMAT - if the image data cannot be saved to the requested format</li>
 * </ul>
 */
public void save(OutputStream stream, int format) {
    if (stream is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    FileFormat.save(stream, format, this);
}

/**
 * Saves the image data in this ImageLoader to a file with the specified name.
 * The format parameter can have one of the following values:
 * <dl>
 * <dt><code>IMAGE_BMP</code></dt>
 * <dd>Windows BMP file format, no compression</dd>
 * <dt><code>IMAGE_BMP_RLE</code></dt>
 * <dd>Windows BMP file format, RLE compression if appropriate</dd>
 * <dt><code>IMAGE_GIF</code></dt>
 * <dd>GIF file format</dd>
 * <dt><code>IMAGE_ICO</code></dt>
 * <dd>Windows ICO file format</dd>
 * <dt><code>IMAGE_JPEG</code></dt>
 * <dd>JPEG file format</dd>
 * <dt><code>IMAGE_PNG</code></dt>
 * <dd>PNG file format</dd>
 * </dl>
 *
 * @param filename the name of the file to write the images to
 * @param format the format to write the images in
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the file name is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_IO - if an IO error occurs while writing to the file</li>
 *    <li>ERROR_INVALID_IMAGE - if the image data contains invalid data</li>
 *    <li>ERROR_UNSUPPORTED_FORMAT - if the image data cannot be saved to the requested format</li>
 * </ul>
 */
public void save(String filename, int format) {
    if (filename is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    OutputStream stream = null;
    try {
        stream = Compatibility.newFileOutputStream(filename);
    } catch (IOException e) {
        SWT.error(SWT.ERROR_IO, e);
    }
    save(stream, format);
    try {
        stream.close();
    } catch (IOException e) {
    }
}

/**
 * Adds the listener to the collection of listeners who will be
 * notified when image data is either partially or completely loaded.
 * <p>
 * An ImageLoaderListener should be added before invoking
 * one of the receiver's load methods. The listener's
 * <code>imageDataLoaded</code> method is called when image
 * data has been partially loaded, as is supported by interlaced
 * GIF/PNG or progressive JPEG images.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 *
 * @see ImageLoaderListener
 * @see ImageLoaderEvent
 */
public void addImageLoaderListener(ImageLoaderListener listener) {
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    imageLoaderListeners.addElement(cast(Object)listener);
}

/**
 * Removes the listener from the collection of listeners who will be
 * notified when image data is either partially or completely loaded.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 *
 * @see #addImageLoaderListener(ImageLoaderListener)
 */
public void removeImageLoaderListener(ImageLoaderListener listener) {
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    if (imageLoaderListeners is null ) return;
    imageLoaderListeners.removeElement( cast(Object)listener );
}

/**
 * Returns <code>true</code> if the receiver has image loader
 * listeners, and <code>false</code> otherwise.
 *
 * @return <code>true</code> if there are <code>ImageLoaderListener</code>s, and <code>false</code> otherwise
 *
 * @see #addImageLoaderListener(ImageLoaderListener)
 * @see #removeImageLoaderListener(ImageLoaderListener)
 */
public bool hasListeners() {
    if( imageLoaderListeners is null ) return false;
    return imageLoaderListeners.size() > 0;
}

/**
 * Notifies all image loader listeners that an image loader event
 * has occurred. Pass the specified event object to each listener.
 *
 * @param event the <code>ImageLoaderEvent</code> to send to each <code>ImageLoaderListener</code>
 */
public void notifyListeners(ImageLoaderEvent event) {
    if (!hasListeners()) return;
    auto size = imageLoaderListeners.size();
    for (int i = 0; i < size; i++) {
        ImageLoaderListener listener = cast(ImageLoaderListener) imageLoaderListeners.elementAt(i);
        listener.imageDataLoaded(event);
    }
}

}
