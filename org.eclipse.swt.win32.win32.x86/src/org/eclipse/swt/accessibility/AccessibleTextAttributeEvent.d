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
module org.eclipse.swt.accessibility.AccessibleTextAttributeEvent;

import java.lang.all;

import org.eclipse.swt.internal.SWTEventObject;

import org.eclipse.swt.graphics.all;

import std.conv : to;

/**
 * Instances of this class are sent as a result of accessibility clients
 * sending AccessibleAttribute or AccessibleEditableText messages to an
 * accessible object.
 *
 * @see AccessibleAttributeListener
 * @see AccessibleAttributeAdapter
 * @see AccessibleEditableTextListener
 * @see AccessibleEditableTextAdapter
 *
 * @since 3.6
 */
public class AccessibleTextAttributeEvent : SWTEventObject {

    /**
     * [in] the 0-based text offset for which to return attribute information
     *
     * @see AccessibleAttributeListener#getTextAttributes
     */
    public int offset;

    /**
     * [in/out] the starting and ending offsets of the character range
     *
     * @see AccessibleAttributeListener#getTextAttributes
     * @see AccessibleEditableTextListener#setTextAttributes
     */
    public int start, end;

    /**
     * [in/out] the TextStyle of the character range
     *
     * @see AccessibleAttributeListener#getTextAttributes
     * @see AccessibleEditableTextListener#setTextAttributes
     */
    public TextStyle textStyle;

    /**
     * [in/out] an array of alternating key and value Strings
     * that represent attributes that do not correspond to TextStyle fields
     *
     * @see AccessibleAttributeListener#getTextAttributes
     * @see AccessibleEditableTextListener#setTextAttributes
     */
    public String [] attributes;

    /**
     * [out] Set this field to {@link ACC#OK} if the operation
     * was completed successfully, and null otherwise.
     *
     * @see AccessibleEditableTextListener#setTextAttributes
     *
     * @since 3.7
     */
    public String result;

    // static const long serialVersionUID = 7131825608864332802L;

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
public String toString () const {
    return Format("AccessibleAttributeEvent {{ offset={} start={} end={} textStyle={} attributes={} result={}}",
        offset,
        start,
        end,
        textStyle.toString(),
        attributes,
        result);
}

package String toAttributeString(String [] attributes) {
    if (attributes == null || attributes.length == 0) return to!String(attributes);   //$NON-NLS-1$
    StringBuffer attributeString = new StringBuffer();
    for (int i = 0; i < attributes.length; i++) {
        attributeString.append(attributes[i]);
        attributeString.append((i % 2 == 0) ? ":" : ";");   //$NON-NLS-1$   //$NON-NLS-2$
    }
    return attributeString.toString();
}
}
