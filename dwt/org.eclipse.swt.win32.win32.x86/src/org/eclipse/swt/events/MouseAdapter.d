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
module org.eclipse.swt.events.MouseAdapter;

import org.eclipse.swt.events.MouseListener;

/**
 * This adapter class provides default implementations for the
 * methods described by the <code>MouseListener</code> interface.
 * <p>
 * Classes that wish to deal with <code>MouseEvent</code>s
 * which occur as mouse buttons are pressed and released can
 * extend this class and override only the methods which they are
 * interested in.
 * </p>
 *
 * @see MouseListener
 * @see MouseEvent
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public abstract class MouseAdapter : MouseListener {

/**
 * Sent when a mouse button is pressed twice within the
 * (operating system specified) double click period.
 * The default behavior is to do nothing.
 *
 * @param e an event containing information about the mouse double click
 *
 * @see org.eclipse.swt.widgets.Display#getDoubleClickTime()
 */
public void mouseDoubleClick(MouseEvent e) {
}

/**
 * Sent when a mouse button is pressed.
 * The default behavior is to do nothing.
 *
 * @param e an event containing information about the mouse button press
 */
public void mouseDown(MouseEvent e) {
}

/**
 * Sent when a mouse button is released.
 * The default behavior is to do nothing.
 *
 * @param e an event containing information about the mouse button release
 */
public void mouseUp(MouseEvent e) {
}
}
