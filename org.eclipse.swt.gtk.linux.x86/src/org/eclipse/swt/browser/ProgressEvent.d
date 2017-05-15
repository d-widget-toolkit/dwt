/*******************************************************************************
 * Copyright (c) 2003, 2004 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *      John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module org.eclipse.swt.browser.ProgressEvent;


import java.lang.all;

import org.eclipse.swt.events.TypedEvent;
import org.eclipse.swt.widgets.Widget;

/**
 * A <code>ProgressEvent</code> is sent by a {@link Browser} to
 * {@link ProgressListener}'s when a progress is made during the
 * loading of the current URL or when the loading of the current
 * URL has been completed.
 * 
 * @since 3.0
 */
public class ProgressEvent : TypedEvent {
    /** current value */
    public int current;
    /** total value */
    public int total;
    
    static const long serialVersionUID = 3977018427045393972L;

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
    return Format( "{} current = {}, total = {}}", 
        super.toString()[0 .. $-1], current, total );  
}
}
