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
module org.eclipse.swt.accessibility.AccessibleEvent;


import org.eclipse.swt.internal.SWTEventObject;
import java.lang.all;

/**
 * Instances of this class are sent as a result of
 * accessibility clients sending messages to controls
 * asking for information about the control instance.
 * <p>
 * Note: The meaning of the result field depends
 * on the message that was sent.
 * </p>
 *
 * @see AccessibleListener
 * @see AccessibleAdapter
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 2.0
 */
public class AccessibleEvent : SWTEventObject {
    /**
     * The value of this field is set by an accessibility client
     * before the accessible listener method is called.
     * ChildID can be CHILDID_SELF, representing the control itself,
     * or a 0-based integer representing a specific child of the control.
     */
    public int childID;

    /**
     * The value of this field must be set in the accessible listener
     * method before returning.
     * What to set it to depends on the listener method called, and
     * the childID specified by the client.
     */
    public String result;

    //static final long serialVersionUID = 3257567304224026934L;

/**
 * Constructs a new instance of this class.
 *
 * @param source the object that fired the event
 */
public this(Object source) {
    super(source);
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the event
 */
override public String toString () {
    return Format( "AccessibleEvent {{childID={} result={}}", childID, result );
}
}
