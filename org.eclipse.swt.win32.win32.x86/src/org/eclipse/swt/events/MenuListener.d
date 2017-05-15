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
module org.eclipse.swt.events.MenuListener;


public import org.eclipse.swt.internal.SWTEventListener;
public import org.eclipse.swt.events.MenuEvent;

/**
 * Classes which implement this interface provide methods
 * that deal with the hiding and showing of menus.
 * <p>
 * After creating an instance of a class that :
 * this interface it can be added to a menu using the
 * <code>addMenuListener</code> method and removed using
 * the <code>removeMenuListener</code> method. When the
 * menu is hidden or shown, the appropriate method will
 * be invoked.
 * </p>
 *
 * @see MenuAdapter
 * @see MenuEvent
 */
public interface MenuListener : SWTEventListener {

/**
 * Sent when a menu is hidden.
 *
 * @param e an event containing information about the menu operation
 */
public void menuHidden(MenuEvent e);

/**
 * Sent when a menu is shown.
 *
 * @param e an event containing information about the menu operation
 */
public void menuShown(MenuEvent e);
}
