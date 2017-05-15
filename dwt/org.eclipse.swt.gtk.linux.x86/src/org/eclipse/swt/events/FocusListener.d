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
module org.eclipse.swt.events.FocusListener;


public import org.eclipse.swt.internal.SWTEventListener;
public import org.eclipse.swt.events.FocusEvent;

/**
 * Classes which implement this interface provide methods
 * that deal with the events that are generated as controls
 * gain and lose focus.
 * <p>
 * After creating an instance of a class that :
 * this interface it can be added to a control using the
 * <code>addFocusListener</code> method and removed using
 * the <code>removeFocusListener</code> method. When a
 * control gains or loses focus, the appropriate method
 * will be invoked.
 * </p>
 *
 * @see FocusAdapter
 * @see FocusEvent
 */
public interface FocusListener : SWTEventListener {

/**
 * Sent when a control gets focus.
 *
 * @param e an event containing information about the focus change
 */
public void focusGained(FocusEvent e);

/**
 * Sent when a control loses focus.
 *
 * @param e an event containing information about the focus change
 */
public void focusLost(FocusEvent e);
}

