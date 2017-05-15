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
module org.eclipse.swt.custom.LineBackgroundEvent;

import java.lang.all;


import org.eclipse.swt.events.TypedEvent;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.custom.StyledTextEvent;

/**
 * This event is sent when a line is about to be drawn.
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class LineBackgroundEvent : TypedEvent {

    /**
     * line start offset
     */
    public int lineOffset;

    /**
     * line text
     */
    public String lineText;

    /**
     * line background color
     */
    public Color lineBackground;

    static const long serialVersionUID = 3978711687853324342L;

/**
 * Constructs a new instance of this class based on the
 * information in the given event.
 *
 * @param e the event containing the information
 */
public this(StyledTextEvent e) {
    super(cast(Object)e);
    lineOffset = e.detail;
    lineText = e.text;
    lineBackground = e.lineBackground;
}
}


