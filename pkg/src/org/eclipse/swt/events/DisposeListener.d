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
module org.eclipse.swt.events.DisposeListener;


public import org.eclipse.swt.internal.SWTEventListener;
public import org.eclipse.swt.events.DisposeEvent;

/**
 * Classes which implement this interface provide a method
 * that deals with the event that is generated when a widget
 * is disposed.
 * <p>
 * After creating an instance of a class that :
 * this interface it can be added to a widget using the
 * <code>addDisposeListener</code> method and removed using
 * the <code>removeDisposeListener</code> method. When a
 * widget is disposed, the widgetDisposed method will
 * be invoked.
 * </p>
 *
 * @see DisposeEvent
 */
public interface DisposeListener : SWTEventListener {

/**
 * Sent when the widget is disposed.
 *
 * @param e an event containing information about the dispose
 */
public void widgetDisposed(DisposeEvent e);
}
