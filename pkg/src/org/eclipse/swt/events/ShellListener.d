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
module org.eclipse.swt.events.ShellListener;


public import org.eclipse.swt.internal.SWTEventListener;
public import org.eclipse.swt.events.ShellEvent;

/**
 * Classes which implement this interface provide methods
 * that deal with changes in state of <code>Shell</code>s.
 * <p>
 * After creating an instance of a class that :
 * this interface it can be added to a shell using the
 * <code>addShellListener</code> method and removed using
 * the <code>removeShellListener</code> method. When the
 * state of the shell changes, the appropriate method will
 * be invoked.
 * </p>
 *
 * @see ShellAdapter
 * @see ShellEvent
 */
public interface ShellListener : SWTEventListener {

/**
 * Sent when a shell becomes the active window.
 *
 * @param e an event containing information about the activation
 */
public void shellActivated(ShellEvent e);

/**
 * Sent when a shell is closed.
 *
 * @param e an event containing information about the close
 */
public void shellClosed(ShellEvent e);

/**
 * Sent when a shell stops being the active window.
 *
 * @param e an event containing information about the deactivation
 */
public void shellDeactivated(ShellEvent e);

/**
 * Sent when a shell is un-minimized.
 *
 * @param e an event containing information about the un-minimization
 */
public void shellDeiconified(ShellEvent e);

/**
 * Sent when a shell is minimized.
 *
 * @param e an event containing information about the minimization
 */
public void shellIconified(ShellEvent e);
}
