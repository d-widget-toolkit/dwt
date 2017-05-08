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
module org.eclipse.swt.browser.LocationEvent;


import org.eclipse.swt.events.TypedEvent;
import org.eclipse.swt.widgets.Widget;
import java.lang.all;

/**
 * A <code>LocationEvent</code> is sent by a {@link Browser} to
 * {@link LocationListener}'s when the <code>Browser</code>
 * navigates to a different URL. This notification typically 
 * occurs when the application navigates to a new location with 
 * {@link Browser#setUrl(String)} or when the user activates a
 * hyperlink.
 * 
 * @since 3.0
 */
public class LocationEvent : TypedEvent {
    /** current location */
    public String location;
    
    /**
     * A flag indicating whether the location opens in the top frame
     * or not.
     */
    public bool top;
    
    /**
     * A flag indicating whether the location loading should be allowed.
     * Setting this field to <code>false</code> will cancel the operation.
     */
    public bool doit;

    static const long serialVersionUID = 3906644198244299574L;
    
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
    return Format( "{} location = {}, top = {}, doit = {}}", 
        super.toString()[0 .. $-1], location, top, doit );  
}
}
