/*******************************************************************************
 * Copyright (c) 2017 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     alice <stigma@disroot.org>
 *******************************************************************************/
module org.eclipse.swt.internal.DPIUtil;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.ImageDataProvider;
import org.eclipse.swt.graphics.PaletteData;

import java.lang.Math;
import java.lang.System;
import java.lang.String;
import java.lang.util : Format;

/**
 * This class hold common constants and utility functions w.r.t. to SWT high DPI
 * functionality.
 * <p>
 * The {@code autoScaleUp(..)} methods convert from API coordinates (in
 * SWT points) to internal high DPI coordinates (in pixels) that interface with
 * native widgets.
 * </p>
 * <p>
 * The {@code autoScaleDown(..)} convert from high DPI pixels to API coordinates
 * (in SWT points).
 * </p>
 *
 * @since 3.105
 */
public class DPIUtil {
package(org.eclipse.swt.internal):

    private static const int DPI_ZOOM_100 = 96;

    private static int deviceZoom = 100;
    private static int nativeDeviceZoom = 100;

    private static enum AutoScaleMethod { AUTO, NEAREST, SMOOTH }
    private static AutoScaleMethod autoScaleMethodSetting = AutoScaleMethod.AUTO;
    private static AutoScaleMethod autoScaleMethod = AutoScaleMethod.NEAREST;

    /**
     * System property that controls the autoScale functionality.
     * <ul>
     * <li><b>false</b>: deviceZoom is set to 100%</li>
     * <li><b>integer</b>: deviceZoom depends on the current display resolution,
     *     but only uses integer multiples of 100%. The detected native zoom is
     *     generally rounded down (e.g. at 150%, will use 100%), unless close to
     *     the next integer multiple (currently at 175%, will use 200%).</li>
     * <li><b>integer200</b>: like <b>integer</b>, but the maximal zoom level is 200%.</li>
     * <li><b>quarter</b>: deviceZoom depends on the current display resolution,
     *     but only uses integer multiples of 25%. The detected native zoom is
     *     rounded to the closest permissible value.</li>
     * <li><b>exact</b>: deviceZoom uses the native zoom (with 1% as minimal
     *     step).</li>
     * <li><i>&lt;value&gt;</i>: deviceZoom uses the given integer value in
     *     percent as zoom level.</li>
     * </ul>
     * The current default is "integer200".
     */
    private static const String SWT_AUTOSCALE = "swt.autoScale";

    /**
     * System property that controls the method for scaling images:
     * <ul>
     * <li>"nearest": nearest-neighbor interpolation, may look jagged</li>
     * <li>"smooth": smooth edges, may look blurry</li>
     * </ul>
     * The current default is to use "nearest", except on
     * GTK when the deviceZoom is not an integer multiple of 100%.
     * The smooth strategy currently doesn't work on Win32 and Cocoa, see
     * <a href="https://bugs.eclipse.org/493455">bug 493455</a>.
     */
    private static const String SWT_AUTOSCALE_METHOD = "swt.autoScale.method";
    static this() {
        String value = System.getProperty (SWT_AUTOSCALE_METHOD);
        if (value !is null) {
            if (AutoScaleMethod.NEAREST.stringof.equalsIgnoreCase(value)) {
                autoScaleMethod = autoScaleMethodSetting = AutoScaleMethod.NEAREST;
            } else if (AutoScaleMethod.SMOOTH.stringof.equalsIgnoreCase(value)) {
                autoScaleMethod = autoScaleMethodSetting = AutoScaleMethod.SMOOTH;
            }
        }
    }

/**
 * Auto-scale image with ImageData
 */
public static ImageData autoScaleImageData (Device device, ImageData imageData, int targetZoom, int currentZoom) {
    if (imageData is null || targetZoom == currentZoom || (device !is null && !device.isAutoScalable ())) return imageData;
    float scaleFactor = cast(float)targetZoom / cast(float)currentZoom;
    return autoScaleImageData (device, imageData, scaleFactor);
}

private static ImageData autoScaleImageData (Device device, ImageData imageData, float scaleFactor) {
    // Guards are already implemented in callers: if (deviceZoom == 100 || imageData == null || scaleFactor == 1.0f) return imageData;
    int width = imageData.width;
    int height = imageData.height;
    int scaledWidth = Math.round (cast(float) width * scaleFactor);
    int scaledHeight = Math.round (cast(float) height * scaleFactor);
    switch (autoScaleMethod) {
    case AutoScaleMethod.SMOOTH:
        // DWT TODO: Port Image.this(Device device, ImageDataProvider provider)
        // Image original = new Image (device, (ImageDataProvider) zoom -> imageData);

        /* Create a 24 bit image data with alpha channel */
        ImageData resultData = new ImageData (scaledWidth, scaledHeight, 24, new PaletteData (0xFF, 0xFF00, 0xFF0000));
        resultData.alphaData = new byte [scaledWidth * scaledHeight];

        /+ DWT TODO: Port Image.this(Device device, ImageDataProvider provider)
        Image resultImage = new Image (device, (ImageDataProvider) zoom -> resultData);
        GC gc = new GC (resultImage);
        gc.setAntialias (SWT.ON);
        gc.drawImage (original, 0, 0, DPIUtil.autoScaleDown (width), DPIUtil.autoScaleDown (height),
                /* E.g. destWidth here is effectively DPIUtil.autoScaleDown (scaledWidth), but avoiding rounding errors.
                 * Nevertheless, we still have some rounding errors due to the point-based API GC#drawImage(..).
                 */
                0, 0, Math.round (DPIUtil.autoScaleDown ((float) width * scaleFactor)), Math.round (DPIUtil.autoScaleDown ((float) height * scaleFactor)));
        gc.dispose ();
        original.dispose ();
        ImageData result = resultImage.getImageData (DPIUtil.getDeviceZoom ());
        resultImage.dispose ();
        return result;+/
        // DWT TODO: Remove this when the above secions are not commented out
        return null;
    case AutoScaleMethod.NEAREST:
    default:
        return imageData.scaledTo (scaledWidth, scaledHeight);
    }
}

/**
 * Auto-scale up ImageData
 */
public static ImageData autoScaleUp (Device device, ImageData imageData) {
    if (deviceZoom == 100 || imageData is null || (device !is null && !device.isAutoScalable())) return imageData;
    float scaleFactor = getScalingFactor ();
    return autoScaleImageData(device, imageData, scaleFactor);
}

/**
 * Returns Scaling factor from the display
 * @return float scaling factor
 */
private static float getScalingFactor () {
    return deviceZoom / 100f;
}

/**
 * Gets Image data at specified zoom level, if image is missing then
 * fall-back to 100% image. If provider or fall-back image is not available,
 * throw error.
 */
public static ImageData validateAndGetImageDataAtZoom (ImageDataProvider provider, int zoom, bool[] found) {
    if (provider is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    ImageData data = provider.getImageData (zoom);
    found [0] = (data !is null);
    /* If image is null when  (zoom != 100%), fall-back to image at 100% zoom */
    if (zoom != 100 && !found [0]) data = provider.getImageData (100);
    if (data is null) SWT.error (SWT.ERROR_INVALID_ARGUMENT, null, Format(": ImageDataProvider [{}] returns null ImageData at 100% zoom.", provider));
    return data;
}

public static int getDeviceZoom() {
    return deviceZoom;
}
}
