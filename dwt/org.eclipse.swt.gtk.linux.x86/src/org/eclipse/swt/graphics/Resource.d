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
module org.eclipse.swt.graphics.Resource;

import java.lang.all;

import org.eclipse.swt.SWT;

import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.internal.c.gdk;

/**
 * This class is the abstract superclass of all graphics resource objects.
 * Resources created by the application must be disposed.
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation. However, it has not been marked
 * final to allow those outside of the SWT development team to implement
 * patched versions of the class in order to get around specific
 * limitations in advance of when those limitations can be addressed
 * by the team.  Any class built using subclassing to access the internals
 * of this class will likely fail to compile or run between releases and
 * may be strongly platform specific. Subclassing should not be attempted
 * without an intimate and detailed understanding of the workings of the
 * hierarchy. No support is provided for user-written classes which are
 * implemented as subclasses of this class.
 * </p>
 *
 * @see #dispose
 * @see #isDisposed
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.1
 */
public abstract class Resource {

    /**
     * the device where this resource was created
     */
    Device device;

public this() {
}

this(Device device) {
    if (device is null) device = Device.getDevice();
    if (device is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    this.device = device;
}

void destroy() {
}

/**
 * Disposes of the operating system resources associated with
 * this resource. Applications must dispose of all resources
 * which they allocate.
 */
public void dispose() {
    if (device is null) return;
    if (device.isDisposed()) return;
    destroy();
    if (device.tracking) device.dispose_Object(this);
    device = null;
}

/**
 * Returns the <code>Device</code> where this resource was
 * created.
 *
 * @return <code>Device</code> the device of the receiver
 *
 * @since 3.2
 */
public Device getDevice() {
    Device device = this.device;
    if (device is null || isDisposed ()) SWT.error (SWT.ERROR_GRAPHIC_DISPOSED);
    return device;
}

void init_() {
    if (device.tracking) device.new_Object(this);
}

/**
 * Returns <code>true</code> if the resource has been disposed,
 * and <code>false</code> otherwise.
 * <p>
 * This method gets the dispose state for the resource.
 * When a resource has been disposed, it is an error to
 * invoke any other method using the resource.
 *
 * @return <code>true</code> when the resource is disposed and <code>false</code> otherwise
 */
public abstract bool isDisposed();

}
