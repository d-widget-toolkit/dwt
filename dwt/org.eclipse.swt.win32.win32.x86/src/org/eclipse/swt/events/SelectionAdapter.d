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
module org.eclipse.swt.events.SelectionAdapter;

import org.eclipse.swt.events.SelectionListener;

/**
 * This adapter class provides default implementations for the
 * methods described by the <code>SelectionListener</code> interface.
 * <p>
 * Classes that wish to deal with <code>SelectionEvent</code>s can
 * extend this class and override only the methods which they are
 * interested in.
 * </p>
 *
 * @see SelectionListener
 * @see SelectionEvent
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public abstract class SelectionAdapter : SelectionListener {

/**
 * Sent when selection occurs in the control.
 * The default behavior is to do nothing.
 *
 * @param e an event containing information about the selection
 */
public void widgetSelected(SelectionEvent e) {
}

/**
 * Sent when default selection occurs in the control.
 * The default behavior is to do nothing.
 *
 * @param e an event containing information about the default selection
 */
public void widgetDefaultSelected(SelectionEvent e) {
}
}
