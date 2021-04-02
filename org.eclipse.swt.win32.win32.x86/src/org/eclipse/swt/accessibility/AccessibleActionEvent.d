/*******************************************************************************
 * Copyright (c) 2009, 2017 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     alice <stigma@disroot.org>
 *******************************************************************************/
module org.eclipse.swt.accessibility.AccessibleActionEvent;

import java.lang.all;
import java.util.EventObject;

/**
 * Instances of this class are sent as a result of accessibility clients
 * sending AccessibleAction messages to an accessible object.
 *
 * @see AccessibleActionListener
 * @see AccessibleActionAdapter
 *
 * @since 3.6
 */
public class AccessibleActionEvent : EventObject {

    /**
     * The value of this field must be set in the accessible action listener method
     * before returning. What to set it to depends on the listener method called.
     */
    public String result;
    public int count;
    public int index;
    public bool localized;

    // static const long serialVersionUID = 2849066792640153087L;

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
override
public String toString() const {
    return Format("AccessibleActionEvent {{string={} count={} index={}}",
        result,
        count,
        index);
}
}
