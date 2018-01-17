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
module org.eclipse.swt.events.PaintEvent;


import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.graphics.GC;

import org.eclipse.swt.events.TypedEvent;

import java.lang.all;

/**
 * Instances of this class are sent as a result of
 * visible areas of controls requiring re-painting.
 *
 * @see PaintListener
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public final class PaintEvent : TypedEvent {

    /**
     * the graphics context to use when painting
     * that is configured to use the colors, font and
     * damaged region of the control.  It is valid
     * only during the paint and must not be disposed
     */
    public GC gc;

    /**
     * the x offset of the bounding rectangle of the
     * region that requires painting
     */
    public int x;

    /**
     * the y offset of the bounding rectangle of the
     * region that requires painting
     */
    public int y;

    /**
     * the width of the bounding rectangle of the
     * region that requires painting
     */
    public int width;

    /**
     * the height of the bounding rectangle of the
     * region that requires painting
     */
    public int height;

    /**
     * the number of following paint events which
     * are pending which may always be zero on
     * some platforms
     */
    public int count;

    //static const long serialVersionUID = 3256446919205992497L;

/**
 * Constructs a new instance of this class based on the
 * information in the given untyped event.
 *
 * @param e the untyped event containing the information
 */
public this(Event e) {
    super(e);
    this.gc = e.gc;
    this.x = e.x;
    this.y = e.y;
    this.width = e.width;
    this.height = e.height;
    this.count = e.count;
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the event
 */
public override String toString() {
    return Format( "{} gc={} x={} y={} width={} height={} count={}}",
        super.toString[ 0 .. $-1 ],
        gc is null ? "null" : gc.toString,
        x,
        y,
        width,
        height,
        count );
}
}

