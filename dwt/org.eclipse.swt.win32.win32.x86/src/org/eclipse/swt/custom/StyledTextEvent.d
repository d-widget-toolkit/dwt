/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
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
module org.eclipse.swt.custom.StyledTextEvent;


import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.custom.StyleRange;
import org.eclipse.swt.custom.Bullet;
import org.eclipse.swt.custom.StyledTextContent;

/**
 *
 */
class StyledTextEvent : Event {
    // used by LineStyleEvent
    int[] ranges;
    StyleRange[] styles;
    int alignment;
    int indent;
    bool justify;
    Bullet bullet;
    int bulletIndex;
    // used by LineBackgroundEvent
    Color lineBackground;
    // used by BidiSegmentEvent
    int[] segments;
    // used by TextChangedEvent
    int replaceCharCount;
    int newCharCount;
    int replaceLineCount;
    int newLineCount;
    // used by PaintObjectEvent
    int x;
    int y;
    int ascent;
    int descent;
    StyleRange style;

this (StyledTextContent content) {
    data = cast(Object)content;
}
}


