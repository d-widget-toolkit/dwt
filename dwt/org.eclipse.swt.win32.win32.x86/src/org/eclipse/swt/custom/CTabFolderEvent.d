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
module org.eclipse.swt.custom.CTabFolderEvent;

import java.lang.all;



import org.eclipse.swt.events.TypedEvent;
import org.eclipse.swt.widgets.Widget;


/**
 * This event is sent when an event is generated in the CTabFolder.
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a> 
 */
public class CTabFolderEvent : TypedEvent {
    /**
     * The tab item for the operation.
     */
    public Widget item;

    /**
     * A flag indicating whether the operation should be allowed.
     * Setting this field to <code>false</code> will cancel the operation.
     * Applies to the close and showList events.
     */
    public bool doit;

    /**
     * The widget-relative, x coordinate of the chevron button
     * at the time of the event.  Applies to the showList event.
     *
     * @since 3.0
     */
    public int x;
    /**
     * The widget-relative, y coordinate of the chevron button
     * at the time of the event.  Applies to the showList event.
     *
     * @since 3.0
     */
    public int y;
    /**
     * The width of the chevron button at the time of the event.
     * Applies to the showList event.
     *
     * @since 3.0
     */
    public int width;
    /**
     * The height of the chevron button at the time of the event.
     * Applies to the showList event.
     *
     * @since 3.0
     */
    public int height;

    static const long serialVersionUID = 3760566386225066807L;

/**
 * Constructs a new instance of this class.
 *
 * @param w the widget that fired the event
 */
this(Widget w) {
    super(w);
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the event
 */
public override String toString() {
    String string = super.toString ();
    return string[0.. $ - 1] // remove trailing '}'
        ~ " item=" ~ String_valueOf(item)
        ~ " doit=" ~ String_valueOf(doit)
        ~ " x=" ~ String_valueOf(x)
        ~ " y=" ~ String_valueOf(y)
        ~ " width=" ~ String_valueOf(width)
        ~ " height=" ~ String_valueOf(height)
        ~ "}";
}
}
