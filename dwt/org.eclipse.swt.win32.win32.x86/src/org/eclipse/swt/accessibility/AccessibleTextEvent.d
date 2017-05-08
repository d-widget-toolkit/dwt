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
module org.eclipse.swt.accessibility.AccessibleTextEvent;


import org.eclipse.swt.internal.SWTEventObject;
import java.lang.all;

/**
 * Instances of this class are sent as a result of
 * accessibility clients sending messages to controls
 * asking for detailed information about the implementation
 * of the control instance. Typically, only implementors
 * of custom controls need to listen for this event.
 * <p>
 * Note: The meaning of each field depends on the
 * message that was sent.
 * </p>
 *
 * @see AccessibleTextListener
 * @see AccessibleTextAdapter
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.0
 */
public class AccessibleTextEvent : SWTEventObject {
    public int childID;             // IN
    public int offset, length;      // OUT

    //static final long serialVersionUID = 3977019530868308275L;

/**
 * Constructs a new instance of this class.
 *
 * @param source the object that fired the event
 */
public this (Object source) {
    super (source);
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the event
 */
override public String toString () {
    return Format( "AccessibleTextEvent {{childID={} offset={} length={}}",
        childID,
        offset,
        length);
}
}
