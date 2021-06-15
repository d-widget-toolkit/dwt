/*******************************************************************************
 * Copyright (c) 2015 IBM Corporation and others.
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
module org.eclipse.swt.graphics.ImageDataProvider;

import org.eclipse.swt.graphics.ImageData;

/**
 * Interface to provide a callback mechanism to get information about images
 * when the application is moved from a low DPI monitor to a high DPI monitor.
 * This provides API which will be called by SWT during the image rendering.
 *
 * This interface needs to be implemented by client code to provide the
 * image information on demand.
 *
 * @since 3.104
 */
public interface ImageDataProvider {


    /**
     * Returns the image data for the given zoom level.
     * <p>
     * If no image is available for a particular zoom level, this method should
     * return <code>null</code>. For <code>zoom == 100</code>, returning
     * <code>null</code> in not allowed, and SWT will throw an exception.
     *
     * @param zoom
     *            The zoom level in % of the standard resolution (which is 1
     *            physical monitor pixel == 1 SWT logical pixel). Typically 100,
     *            150, or 200.
     * @return the image data, or <code>null</code> if <code>zoom != 100</code>
     *         and no image is available for the given zoom level.
     * @since 3.104
     */
    public ImageData getImageData (int zoom);

}
