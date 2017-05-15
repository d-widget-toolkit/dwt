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
module org.eclipse.swt.custom.LineStyleEvent;

import java.lang.all;

import org.eclipse.swt.events.TypedEvent;
import org.eclipse.swt.custom.StyleRange;
import org.eclipse.swt.custom.Bullet;
import org.eclipse.swt.custom.StyledTextEvent;

/**
 * This event is sent when a line is about to be drawn.
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class LineStyleEvent : TypedEvent {

    /**
     * line start offset (input)
     */
    public int lineOffset;

    /**
     * line text (input)
     */
    public String lineText;

    /**
     * line ranges (output)
     *
     * @since 3.2
     */
    public int[] ranges;

    /**
     * line styles (output)
     *
     * Note: Because a StyleRange includes the start and length, the
     * same instance cannot occur multiple times in the array of styles.
     * If the same style attributes, such as font and color, occur in
     * multiple StyleRanges, <code>ranges</code> can be used to share
     * styles and reduce memory usage.
     */
    public StyleRange[] styles;

    /**
     * line alignment (input, output)
     *
     * @since 3.2
     */
    public int alignment;

    /**
     * line indent (input, output)
     *
     * @since 3.2
     */
    public int indent;

    /**
     * line justification (input, output)
     *
     * @since 3.2
     */
    public bool justify;

    /**
     * line bullet (output)
     * @since 3.2
     */
    public Bullet bullet;

    /**
     * line bullet index (output)
     * @since 3.2
     */
    public int bulletIndex;

    static const long serialVersionUID = 3906081274027192884L;

/**
 * Constructs a new instance of this class based on the
 * information in the given event.
 *
 * @param e the event containing the information
 */
public this(StyledTextEvent e) {
    super(cast(Object)e);
    styles = e.styles;
    ranges = e.ranges;
    lineOffset = e.detail;
    lineText = e.text;
    alignment = e.alignment;
    justify = e.justify;
    indent = e.indent;
    bullet = e.bullet;
    bulletIndex = e.bulletIndex;
}
}
