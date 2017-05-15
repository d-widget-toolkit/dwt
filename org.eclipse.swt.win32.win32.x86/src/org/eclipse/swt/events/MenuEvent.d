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
module org.eclipse.swt.events.MenuEvent;


import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.events.TypedEvent;

/**
 * Instances of this class are sent as a result of
 * menus being shown and hidden.
 *
 * @see MenuListener
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public final class MenuEvent : TypedEvent {

    //static const long serialVersionUID = 3258132440332383025L;

/**
 * Constructs a new instance of this class based on the
 * information in the given untyped event.
 *
 * @param e the untyped event containing the information
 */
public this(Event e) {
    super(e);
}

}

