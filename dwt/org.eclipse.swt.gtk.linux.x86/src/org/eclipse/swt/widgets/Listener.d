/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
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
module org.eclipse.swt.widgets.Listener;

import java.lang.all;

import org.eclipse.swt.widgets.Event;

version(Tango){
    import tango.core.Traits;
    import tango.core.Tuple;
} else { // Phobos
    import std.traits;
    import std.typetuple;
}

/**
 * Implementers of <code>Listener</code> provide a simple
 * <code>handleEvent()</code> method that is used internally
 * by SWT to dispatch events.
 * <p>
 * After creating an instance of a class that implements this interface
 * it can be added to a widget using the
 * <code>addListener(int eventType, Listener handler)</code> method and
 * removed using the
 * <code>removeListener (int eventType, Listener handler)</code> method.
 * When the specified event occurs, <code>handleEvent(...)</code> will
 * be sent to the instance.
 * </p>
 * <p>
 * Classes which implement this interface are described within SWT as
 * providing the <em>untyped listener</em> API. Typically, widgets will
 * also provide a higher-level <em>typed listener</em> API, that is based
 * on the standard <code>java.util.EventListener</code> pattern.
 * </p>
 * <p>
 * Note that, since all internal SWT event dispatching is based on untyped
 * listeners, it is simple to build subsets of SWT for use on memory
 * constrained, small footprint devices, by removing the classes and
 * methods which implement the typed listener API.
 * </p>
 *
 * @see Widget#addListener
 * @see java.util.EventListener
 * @see org.eclipse.swt.events
 */
public interface Listener {

/**
 * Sent when an event that the receiver has registered for occurs.
 *
 * @param event the event which occurred
 */
void handleEvent (Event event);
}


/// Helper class for the dgListener template function
private class _DgListenerT(Dg,T...) : Listener {

    version(Tango){
        alias ParameterTupleOf!(Dg) DgArgs;
        static assert( is(DgArgs == Tuple!(Event,T)),
            "Delegate args not correct: delegate args: ("~
            DgArgs.stringof~
            ") vs. passed args: ("~
            Tuple!(Event,T).stringof~")" );
    } else { // Phobos
        alias ParameterTypeTuple!(Dg) DgArgs;
        static assert( is(DgArgs == TypeTuple!(Event,T)),
            "Delegate args not correct: delegate args: ("~
            DgArgs.stringof~
            ") vs. passed args: ("~
            TypeTuple!(Event,T).stringof~")" );
    }


    Dg dg;
    T  t;

    private this( Dg dg, T t ){
        this.dg = dg;
        static if( T.length > 0 ){
            this.t = t;
        }
    }

    void handleEvent( Event e ){
        dg(e,t);
    }
}

/++
 + dgListener creates a class implementing the Listener interface and delegating the call to
 + handleEvent to the users delegate. This template function will store also additional parameters.
 +
 + Examle of usage:
 + ---
 + void handleTextEvent (Event e, int inset ) {
 +     // ...
 + }
 + text.addListener (SWT.FocusOut, dgListener( &handleTextEvent, inset ));
 + ---
 +/
Listener dgListener( Dg, T... )( Dg dg, T args ){
    return new _DgListenerT!( Dg, T )( dg, args );
}



