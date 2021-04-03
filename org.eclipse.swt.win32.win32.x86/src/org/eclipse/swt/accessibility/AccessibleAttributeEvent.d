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
module org.eclipse.swt.accessibility.AccessibleAttributeEvent;

import java.lang.all;
import java.util.EventObject;

/**
 * Instances of this class are sent as a result of accessibility clients
 * sending AccessibleAttribute messages to an accessible object.
 *
 * @see AccessibleAttributeListener
 * @see AccessibleAttributeAdapter
 *
 * @since 3.6
 */
public class AccessibleAttributeEvent : EventObject {

    /**
     * [out] the top margin in pixels
     *
     * @see AccessibleAttributeListener#getAttributes
     */
    public int topMargin;

    /**
     * [out] the bottom margin in pixels
     *
     * @see AccessibleAttributeListener#getAttributes
     */
    public int bottomMargin;

    /**
     * [out] the left margin in pixels
     *
     * @see AccessibleAttributeListener#getAttributes
     */
    public int leftMargin;

    /**
     * [out] the right margin in pixels
     *
     * @see AccessibleAttributeListener#getAttributes
     */
    public int rightMargin;

    /**
     * [out] an array of pixel locations representing tab stops
     *
     * @see AccessibleAttributeListener#getAttributes
     */
    public int[] tabStops;

    /**
     * [out] whether or not to justify the text
     *
     * @see AccessibleAttributeListener#getAttributes
     */
    public bool justify;

    /**
     * [out] the alignment, which is one of SWT#LEFT, SWT#RIGHT or SWT#CENTER
     *
     * @see AccessibleAttributeListener#getAttributes
     */
    public int alignment;

    /**
     * [out] the indent in pixels
     *
     * @see AccessibleAttributeListener#getAttributes
     */
    public int indent;

    /**
     * [out] the 1-based level of this accessible in its group
     *  (0 means "not applicable")
     *
     * @see AccessibleAttributeListener#getAttributes
     * @since 3.102
     */
    public int groupLevel;
    /**
     * [out] the 1-based number of similar children in this accessible's group,
     * including this accessible (0 means "not applicable")
     *
     * @see AccessibleAttributeListener#getAttributes
     * @since 3.102
     */
    public int groupCount;
    /**
     * [out] the 1-based index of this accessible in its group
     *  (0 means "not applicable")
     *
     * @see AccessibleAttributeListener#getAttributes
     * @since 3.102
     */
    public int groupIndex;

    /**
     * [out] an array of alternating key and value Strings which
     * represent additional (i.e. non predefined) attributes
     *
     * @see AccessibleAttributeListener#getAttributes
     */
    public String [] attributes;

    // static const long serialVersionUID = -2894665777259297851L;

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
string toString() const {
    return Format("AccessibleAttributeEvent {{ topMargin={} bottomMargin={} leftMargin={} rightMargin={}" ~
        " tabStops={} justify={} alignment={} indent={} groupLevel={} groupCount={} groupIndex={}}",
        topMargin, bottomMargin, leftMargin, rightMargin, tabStops, justify, alignment, indent, groupLevel,
        groupCount, groupIndex);
}
}
