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
module org.eclipse.swt.custom.CTabFolderListener;

import org.eclipse.swt.internal.SWTEventListener;
import org.eclipse.swt.custom.CTabFolderEvent;

version(Tango){
    import tango.core.Traits;
    import tango.core.Tuple;
} else { // Phobos
    import std.traits;
    import std.typetuple;
}

/**
 * Classes which implement this interface provide a method
 * that deals with events generated in the CTabFolder.
 * <p>
 * After creating an instance of a class that :
 * this interface it can be added to a CTabFolder using the
 * <code>addCTabFolderListener</code> method and removed using
 * the <code>removeCTabFolderListener</code> method. When a
 * tab item is closed, the itemClosed method will be invoked.
 * </p>
 *
 * @see CTabFolderEvent
 */
public interface CTabFolderListener : SWTEventListener {

/**
 * Sent when the user clicks on the close button of an item in the CTabFolder.  The item being closed is specified
 * in the event.item field. Setting the event.doit field to false will stop the CTabItem from closing.
 * When the CTabItem is closed, it is disposed.  The contents of the CTabItem (see CTabItem.setControl) will be
 * made not visible when the CTabItem is closed.
 *
 * @param event an event indicating the item being closed
 *
 * @see CTabItem#setControl
 */
public void itemClosed(CTabFolderEvent event);
}



/// Helper class for the dgListener template function
private class _DgCTabFolderListenerT(Dg,T...) : CTabFolderListener {

    version(Tango){
        alias ParameterTupleOf!(Dg) DgArgs;
        static assert( is(DgArgs == Tuple!(CTabFolderEvent,T)),
                "Delegate args not correct" );
    } else { // Phobos
        alias ParameterTypeTuple!(Dg) DgArgs;
        static assert( is(DgArgs == TypeTuple!(CTabFolderEvent,T)),
                "Delegate args not correct" );
    }

    Dg dg;
    T  t;

    private this( Dg dg, T t ){
        this.dg = dg;
        static if( T.length > 0 ){
            this.t = t;
        }
    }

    void itemClosed( CTabFolderEvent e ){
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
CTabFolderListener dgCTabFolderListener( Dg, T... )( Dg dg, T args ){
    return new _DgCTabFolderListenerT!( Dg, T )( dg, args );
}



