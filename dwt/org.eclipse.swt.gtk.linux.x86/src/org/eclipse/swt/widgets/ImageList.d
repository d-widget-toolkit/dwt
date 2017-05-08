/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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
module org.eclipse.swt.widgets.ImageList;

import java.lang.all;


import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Display;


class ImageList {
    GdkPixbuf* [] pixbufs;
    int width = -1, height = -1;
    Image [] images;

public this() {
    images = new Image [4];
    pixbufs = new GdkPixbuf*[4];
}

public int add (Image image) {
    int index = 0;
    while (index < images.length) {
        if (images [index] !is null) {
            if (images [index].isDisposed ()) {
                OS.g_object_unref (pixbufs [index]);
                images [index] = null;
                pixbufs [index] = null;
            }
        }
        if (images [index] is null) break;
        index++;
    }
    if (index is images.length) {
        Image [] newImages = new Image [images.length + 4];
        System.arraycopy (images, 0, newImages, 0, images.length);
        images = newImages;
        pixbufs.length = pixbufs.length + 4;
    }
    set (index, image);
    return index;
}

public void dispose () {
    if (pixbufs is null) return;
    for (int index=0; index<pixbufs.length; index++) {
        if (pixbufs [index] !is null) OS.g_object_unref (pixbufs [index]);
    }
    images = null;
    pixbufs = null;
}

public Image get (int index) {
    return images [index];
}

GdkPixbuf* getPixbuf (int index) {
    return pixbufs [index];
}

public int indexOf (Image image) {
    if (image is null) return -1;
    for (int index=0; index<images.length; index++) {
        if (image is images [index]) return index;
    }
    return -1;
}

int indexOf (GdkPixbuf* pixbuf) {
    if (pixbuf is null) return -1;
    for (int index=0; index<images.length; index++) {
        if (pixbuf is pixbufs [index]) return index;
    }
    return -1;
}

public bool isDisposed () {
    return images is null;
}

public void put (int index, Image image) {
    ptrdiff_t count = images.length;
    if (!(0 <= index && index < count)) return;
    if (image !is null) {
        set (index, image);
    } else {
        images [index] = null;
        if (pixbufs [index] !is null) OS.g_object_unref (pixbufs [index]);
        pixbufs [index] = null;
    }
}

public void remove (Image image) {
    if (image is null) return;
    for (int index=0; index<images.length; index++) {
        if (image is images [index]){
            OS.g_object_unref (pixbufs [index]);
            images [index] = null;
            pixbufs [index] = null;
        }
    }
}

void set (int index, Image image) {
    int w, h;
    OS.gdk_drawable_get_size (image.pixmap, &w, &h);
    auto pixbuf = Display.createPixbuf (image);
    if (width is -1 || height is -1) {
        width = w;
        height = h;
    }
    if (w !is width || h !is height) {
        auto scaledPixbuf = OS.gdk_pixbuf_scale_simple(pixbuf, width, height, OS.GDK_INTERP_BILINEAR);
        OS.g_object_unref (pixbuf);
        pixbuf = scaledPixbuf;
    }
    auto oldPixbuf = pixbufs [index];
    if (oldPixbuf !is null) {
        if (images [index] is image) {
            OS.gdk_pixbuf_copy_area (pixbuf, 0, 0, width, height, oldPixbuf, 0, 0);
            OS.g_object_unref (pixbuf);
            pixbuf = oldPixbuf;
        } else {
            OS.g_object_unref (oldPixbuf);
        }
    }
    pixbufs [index] = pixbuf;
    images [index] = image;
}

public int size () {
    int result = 0;
    for (int index=0; index<images.length; index++) {
        if (images [index] !is null) {
            if (images [index].isDisposed ()) {
                OS.g_object_unref (pixbufs [index]);
                images [index] = null;
                pixbufs [index] = null;
            }
            if (images [index] !is null) result++;
        }
    }
    return result;
}

}
