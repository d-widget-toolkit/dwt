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
module org.eclipse.swt.events.ShellAdapter;

import org.eclipse.swt.events.ShellListener;

/**
 * This adapter class provides default implementations for the
 * methods described by the <code>ShellListener</code> interface.
 * <p>
 * Classes that wish to deal with <code>ShellEvent</code>s can
 * extend this class and override only the methods which they are
 * interested in.
 * </p>
 *
 * @see ShellListener
 * @see ShellEvent
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public abstract class ShellAdapter : ShellListener {

/**
 * Sent when a shell becomes the active window.
 * The default behavior is to do nothing.
 *
 * @param e an event containing information about the activation
 */
public void shellActivated(ShellEvent e) {
}

/**
 * Sent when a shell is closed.
 * The default behavior is to do nothing.
 *
 * @param e an event containing information about the close
 */
public void shellClosed(ShellEvent e) {
}

/**
 * Sent when a shell stops being the active window.
 * The default behavior is to do nothing.
 *
 * @param e an event containing information about the deactivation
 */
public void shellDeactivated(ShellEvent e) {
}

/**
 * Sent when a shell is un-minimized.
 * The default behavior is to do nothing.
 *
 * @param e an event containing information about the un-minimization
 */
public void shellDeiconified(ShellEvent e) {
}

/**
 * Sent when a shell is minimized.
 * The default behavior is to do nothing.
 *
 * @param e an event containing information about the minimization
 */
public void shellIconified(ShellEvent e) {
}
}

class ShellDelegator : ShellAdapter {
    alias void delegate(ShellEvent) DFunc;
    DFunc delShellActivated;
    DFunc delShellClosed;
    DFunc delShellDeactivated;
    DFunc delShellDeiconified;
    DFunc delShellIconified;

private this(
    DFunc delShellActivated,
    DFunc delShellClosed,
    DFunc delShellDeactivated,
    DFunc delShellDeiconified,
    DFunc delShellIconified )
{
    this.delShellActivated = delShellActivated;
    this.delShellClosed = delShellClosed;
    this.delShellDeactivated = delShellDeactivated;
    this.delShellDeiconified = delShellDeiconified;
    this.delShellIconified = delShellIconified;
}

static ShellDelegator createShellActivated( DFunc del ){
    return new ShellDelegator( del, null, null, null, null );
}
static ShellDelegator createShellClosed( DFunc del ){
    return new ShellDelegator( null, del, null, null, null );
}

override
public void shellActivated(ShellEvent e) {
    if( delShellActivated !is null ) delShellActivated(e);
}
override
public void shellClosed(ShellEvent e) {
    if( delShellClosed !is null ) delShellClosed(e);
}
override
public void shellDeactivated(ShellEvent e) {
    if( delShellDeactivated !is null ) delShellDeactivated(e);
}
override
public void shellDeiconified(ShellEvent e) {
    if( delShellDeiconified !is null ) delShellDeiconified(e);
}
override
public void shellIconified(ShellEvent e) {
    if( delShellIconified !is null ) delShellIconified(e);
}
}


