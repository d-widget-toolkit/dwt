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
module org.eclipse.swt.custom.ExtendedModifyEvent;

import java.lang.all;

import org.eclipse.swt.events.TypedEvent;
import org.eclipse.swt.custom.StyledTextEvent;

/**
 * This event is sent after a text change occurs.
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class ExtendedModifyEvent : TypedEvent {
    /** start offset of the new text */
    public int start;
    /** length of the new text */
    public int length;
    /** replaced text or empty string if no text was replaced */
    public String replacedText;

    static const long serialVersionUID = 3258696507027830832L;

/**
 * Constructs a new instance of this class based on the
 * information in the given event.
 *
 * @param e the event containing the information
 */
public this(StyledTextEvent e) {
    super(cast(Object)e);
    start = e.start;
    length = e.end - e.start;
    replacedText = e.text;
}
}
