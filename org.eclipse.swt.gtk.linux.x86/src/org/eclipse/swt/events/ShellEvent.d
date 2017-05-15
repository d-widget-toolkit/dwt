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
module org.eclipse.swt.events.ShellEvent;


import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.events.TypedEvent;

import java.lang.all;

/**
 * Instances of this class are sent as a result of
 * operations being performed on shells.
 *
 * @see ShellListener
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public final class ShellEvent : TypedEvent {

    /**
     * A flag indicating whether the operation should be allowed.
     * Setting this field to <code>false</code> will cancel the operation.
     */
    public bool doit;

    //static const long serialVersionUID = 3257569490479888441L;

/**
 * Constructs a new instance of this class based on the
 * information in the given untyped event.
 *
 * @param e the untyped event containing the information
 */
public this(Event e) {
    super(e);
    this.doit = e.doit;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the event
 */
public override String toString() {
    return Format( "{} doit={}}", super.toString[ 0 .. $-1 ], doit );
}
}

