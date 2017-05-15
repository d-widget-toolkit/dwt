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
module org.eclipse.swt.widgets.EventTable;

import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.internal.SWTEventListener;
import java.lang.System;
import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.SWTEventListener;

/**
 * Instances of this class implement a simple
 * look up mechanism that maps an event type
 * to a listener.  Multiple listeners for the
 * same event type are supported.
 */

class EventTable {
    int [] types;
    Listener [] listeners;
    int level;
    static const int GROW_SIZE = 4;
    
public Listener [] getListeners (int eventType) {
    if (types is null) return new Listener [0];
    int count = 0;
    for (int i=0; i<types.length; i++) {
        if (types [i] is eventType) count++;
    }
    if (count is 0) return new Listener [0];
    Listener [] result = new Listener [count];
    count = 0;
    for (int i=0; i<types.length; i++) {
        if (types [i] is eventType) {
            result [count++] = listeners [i];
        }
    }
    return result;
}

public void hook (int eventType, Listener listener) {
    if (types is null) types = new int [GROW_SIZE];
    if (listeners is null) listeners = new Listener [GROW_SIZE];
    int length = cast(int)/*64bit*/types.length, index = length - 1;
    while (index >= 0) {
        if (types [index] !is 0) break;
        --index;
    }
    index++;
    if (index is length) {
        int [] newTypes = new int [length + GROW_SIZE];
        System.arraycopy (types, 0, newTypes, 0, length);
        types = newTypes;
        Listener [] newListeners = new Listener [length + GROW_SIZE];
        SimpleType!(Listener).arraycopy (listeners, 0, newListeners, 0, length);
        listeners = newListeners;
    }
    types [index] = eventType;
    listeners [index] = listener;
}

public bool hooks (int eventType) {
    if (types is null) return false;
    for (int i=0; i<types.length; i++) {
        if (types [i] is eventType) return true;
    }
    return false;
}

public void sendEvent (Event event) {
    if (types is null) return;
    level += level >= 0 ? 1 : -1;
    try {
        for (int i=0; i<types.length; i++) {
            if (event.type is SWT.None) return;
            if (types [i] is event.type) {
                Listener listener = listeners [i];
                if (listener !is null) listener.handleEvent (event);
            }
        }
    } finally {
        bool compact = level < 0;
        level -= level >= 0 ? 1 : -1;
        if (compact && level is 0) {
            int index = 0;
            for (int i=0; i<types.length; i++) {
                if (types [i] !is 0) {
                    types [index] = types [i];
                    listeners [index] = listeners [i];
                    index++;
                }
            }
            for (int i=index; i<types.length; i++) {
                types [i] = 0;
                listeners [i] = null;
            }
        }
    }
}

public int size () {
    if (types is null) return 0;
    int count = 0;
    for (int i=0; i<types.length; i++) {
        if (types [i] !is 0) count++;
    }
    return count;
}

void remove (int index) {
    if (level is 0) {
        int end = cast(int)/*64bit*/types.length - 1;
        System.arraycopy (types, index + 1, types, index, end - index);
        SimpleType!(Listener).arraycopy (listeners, index + 1, listeners, index, end - index);
        index = end;
    } else {
        if (level > 0) level = -level;
    }
    types [index] = 0;
    listeners [index] = null;
}

public void unhook (int eventType, Listener listener) {
    if (types is null) return;
    for (int i=0; i<types.length; i++) {
        if (types [i] is eventType && listeners [i] is listener) {
            remove (i);
            return;
        }
    }
}

public void unhook (int eventType, SWTEventListener listener) {
    if (types is null) return;
    for (int i=0; i<types.length; i++) {
        if (types [i] is eventType) {
            if ( auto typedListener = cast(TypedListener) listeners [i] ) {
                if (typedListener.getEventListener () is listener) {
                    remove (i);
                    return;
                }
            }
        }
    }
}

}
