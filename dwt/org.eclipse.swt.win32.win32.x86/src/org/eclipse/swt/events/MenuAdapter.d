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
module org.eclipse.swt.events.MenuAdapter;

import org.eclipse.swt.events.MenuListener;

/**
 * This adapter class provides default implementations for the
 * methods described by the <code>MenuListener</code> interface.
 * <p>
 * Classes that wish to deal with <code>MenuEvent</code>s can
 * extend this class and override only the methods which they are
 * interested in.
 * </p>
 *
 * @see MenuListener
 * @see MenuEvent
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public abstract class MenuAdapter : MenuListener {

/**
 * Sent when a menu is hidden.
 * The default behavior is to do nothing.
 *
 * @param e an event containing information about the menu operation
 */
public void menuHidden(MenuEvent e) {
}

/**
 * Sent when a menu is shown.
 * The default behavior is to do nothing.
 *
 * @param e an event containing information about the menu operation
 */
public void menuShown(MenuEvent e) {
}
}
