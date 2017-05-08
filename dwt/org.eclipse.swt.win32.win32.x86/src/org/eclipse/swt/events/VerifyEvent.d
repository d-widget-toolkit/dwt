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
module org.eclipse.swt.events.VerifyEvent;


import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.events.KeyEvent;

import java.lang.all;

/**
 * Instances of this class are sent as a result of
 * widgets handling keyboard events
 *
 * @see VerifyListener
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public final class VerifyEvent : KeyEvent {

    /**
     * the range of text being modified.
     * Setting these fields has no effect.
     */
    public int start, end;

    /**
     * the new text that will be inserted.
     * Setting this field will change the text that is about to
     * be inserted or deleted.
     */
    public String text;

    //static const long serialVersionUID = 3257003246269577014L;

/**
 * Constructs a new instance of this class based on the
 * information in the given untyped event.
 *
 * @param e the untyped event containing the information
 */
public this(Event e) {
    super(e);
    this.start = e.start;
    this.end = e.end;
    this.text = e.text;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the event
 */
public override String toString() {
    return Format( "{} start={} end={} text={}}", super.toString[ 0 .. $-1 ], start, end, text );
}
}
