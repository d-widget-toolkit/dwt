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
module org.eclipse.swt.events.ExpandAdapter;

import org.eclipse.swt.events.ExpandListener;

/**
 * This adapter class provides default implementations for the
 * methods described by the <code>ExpandListener</code> interface.
 * <p>
 * Classes that wish to deal with <code>ExpandEvent</code>s can
 * extend this class and override only the methods which they are
 * interested in.
 * </p>
 *
 * @see ExpandListener
 * @see ExpandEvent
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.2
 */
public abstract class ExpandAdapter : ExpandListener {

/**
 * Sent when an item is collapsed.
 * The default behavior is to do nothing.
 *
 * @param e an event containing information about the operation
 */
public void itemCollapsed(ExpandEvent e) {
}

/**
 * Sent when an item is expanded.
 * The default behavior is to do nothing.
 *
 * @param e an event containing information about the operation
 */
public void itemExpanded(ExpandEvent e) {
}
}
