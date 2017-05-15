/*******************************************************************************
 * Copyright (c) 2003, 2005 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *      John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module org.eclipse.swt.browser.StatusTextListener;

import org.eclipse.swt.browser.StatusTextEvent;
//import java.lang.all;

import org.eclipse.swt.internal.SWTEventListener;

/**
 * This listener interface may be implemented in order to receive
 * a {@link StatusTextEvent} notification when the status text for
 * a {@link Browser} is changed.
 * 
 * @see Browser#addStatusTextListener(StatusTextListener)
 * @see Browser#removeStatusTextListener(StatusTextListener)
 * 
 * @since 3.0
 */
public interface StatusTextListener : SWTEventListener {

/**
 * This method is called when the status text is changed. The
 * status text is typically displayed in the status bar of a browser 
 * application. 
 * <p>
 *
 * <p>The following fields in the <code>StatusTextEvent</code> apply:
 * <ul>
 * <li>(in) text the modified status text
 * <li>(in) widget the <code>Browser</code> whose status text is changed
 * </ul>
 * 
 * @param event the <code>StatusTextEvent</code> that contains the updated
 * status description of a <code>Browser</code>
 * 
 * @since 3.0
 */
public void changed(StatusTextEvent event);
}
