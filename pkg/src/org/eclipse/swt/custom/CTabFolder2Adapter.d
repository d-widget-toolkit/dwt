﻿/*******************************************************************************
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
module org.eclipse.swt.custom.CTabFolder2Adapter;
import org.eclipse.swt.custom.CTabFolder2Listener;
import org.eclipse.swt.custom.CTabFolderEvent;

/**
 * This adapter class provides default implementations for the
 * methods described by the <code>CTabFolder2Listener</code> interface.
 * <p>
 * Classes that wish to deal with <code>CTabFolderEvent</code>s can
 * extend this class and override only the methods which they are
 * interested in.
 * </p>
 *
 * @see CTabFolder2Listener
 * @see CTabFolderEvent
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.0
 */
public class CTabFolder2Adapter : CTabFolder2Listener {

/**
 * Sent when the user clicks on the close button of an item in the CTabFolder.  The item being closed is specified
 * in the event.item field. Setting the event.doit field to false will stop  the CTabItem from closing.
 * When the CTabItem is closed, it is disposed.  The contents of the CTabItem (see CTabItem#setControl) will be
 * made not visible when the CTabItem is closed.
 * <p>
 * The default behaviour is to close the CTabItem.
 * </p>
 *
 * @param event an event indicating the item being closed
 */
public void close(CTabFolderEvent event){}

/**
 * Sent when the user clicks on the minimize button of a CTabFolder.
 * <p>
 * The default behaviour is to do nothing.
 * </p>
 *
 * @param event an event containing information about the minimize
 */
public void minimize(CTabFolderEvent event){}

/**
 * Sent when the user clicks on the maximize button of a CTabFolder.
 * <p>
 * The default behaviour is to do nothing.
 * </p>
 *
 * @param event an event containing information about the maximize
 */
public void maximize(CTabFolderEvent event){}

/**
 * Sent when the user clicks on the restore button of a CTabFolder.
 * <p>
 * The default behaviour is to do nothing.
 * </p>
 *
 * @param event an event containing information about the restore
 */
public void restore(CTabFolderEvent event){}

/**
 * Sent when the user clicks on the chevron button of a CTabFolder.
 * <p>
 * The default behaviour is to show a list of items that are not currently
 * visible and to change the selection based on the item selected from the list.
 * </p>
 *
 * @param event an event containing information about the show list
 */
public void showList(CTabFolderEvent event){}
}
