/*******************************************************************************
 * Copyright (c) 2000, 2003 IBM Corporation and others.
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
module org.eclipse.swt.events.MouseMoveListener;


public import org.eclipse.swt.internal.SWTEventListener;
public import org.eclipse.swt.events.MouseEvent;

/**
 * Classes which implement this interface provide a method
 * that deals with the events that are generated as the mouse
 * pointer moves.
 * <p>
 * After creating an instance of a class that :
 * this interface it can be added to a control using the
 * <code>addMouseMoveListener</code> method and removed using
 * the <code>removeMouseMoveListener</code> method. As the
 * mouse moves, the mouseMove method will be invoked.
 * </p>
 *
 * @see MouseEvent
 */
public interface MouseMoveListener : SWTEventListener {

/**
 * Sent when the mouse moves.
 *
 * @param e an event containing information about the mouse move
 */
public void mouseMove(MouseEvent e);
}
