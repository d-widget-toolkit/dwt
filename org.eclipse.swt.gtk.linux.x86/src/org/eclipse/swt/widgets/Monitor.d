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
module org.eclipse.swt.widgets.Monitor;

import java.lang.all;

import org.eclipse.swt.graphics.Rectangle;

/**
 * Instances of this class are descriptions of monitors.
 *
 * @see Display
 * @see <a href="http://www.eclipse.org/swt/snippets/#monitor">Monitor snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.0
 */
public final class Monitor {
    ptrdiff_t handle;
    int x, y, width, height;
    int clientX, clientY, clientWidth, clientHeight;

/**
 * Prevents uninitialized instances from being created outside the package.
 */
this () {
}

/**
 * Compares the argument to the receiver, and returns true
 * if they represent the <em>same</em> object using a class
 * specific comparison.
 *
 * @param object the object to compare with this object
 * @return <code>true</code> if the object is the same as this object and <code>false</code> otherwise
 *
 * @see #hashCode()
 */
public override equals_t opEquals (Object object) {
    if (object is this) return true;
    if ( auto mon = cast(org.eclipse.swt.widgets.Monitor.Monitor)object ){
       return handle is mon.handle;
    }
    return false;
}

/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its device. Note that on multi-monitor systems the
 * origin can be negative.
 *
 * @return the receiver's bounding rectangle
 */
public Rectangle getBounds () {
    return new Rectangle (x, y, width, height);
}

/**
 * Returns a rectangle which describes the area of the
 * receiver which is capable of displaying data.
 *
 * @return the client area
 */
public Rectangle getClientArea () {
    return new Rectangle (clientX, clientY, clientWidth, clientHeight);
}

/**
 * Returns an integer hash code for the receiver. Any two
 * objects that return <code>true</code> when passed to
 * <code>equals</code> must return the same value for this
 * method.
 *
 * @return the receiver's hash
 *
 * @see #equals(Object)
 */
public override hash_t toHash() {
    return cast(hash_t)handle;
}

}
