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
module org.eclipse.swt.custom.CTabFolderAdapter;
import org.eclipse.swt.custom.CTabFolderEvent;
import org.eclipse.swt.custom.CTabFolderListener;


/**
 * This adapter class provides a default implementation for the
 * method described by the <code>CTabFolderListener</code> interface.
 * 
 * @see CTabFolderListener
 * @see CTabFolderEvent
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class CTabFolderAdapter : CTabFolderListener {
    public void itemClosed(CTabFolderEvent event){}
}
