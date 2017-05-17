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
module org.eclipse.swt.events.SelectionListener;


public import org.eclipse.swt.internal.SWTEventListener;
public import org.eclipse.swt.events.SelectionEvent;

version(Tango){
    import tango.core.Traits;
    import tango.core.Tuple;
} else { // Phobos
    import std.traits;
    import std.typetuple;
}

/**
 * Classes which implement this interface provide methods
 * that deal with the events that are generated when selection
 * occurs in a control.
 * <p>
 * After creating an instance of a class that :
 * this interface it can be added to a control using the
 * <code>addSelectionListener</code> method and removed using
 * the <code>removeSelectionListener</code> method. When
 * selection occurs in a control the appropriate method
 * will be invoked.
 * </p>
 *
 * @see SelectionAdapter
 * @see SelectionEvent
 */
public interface SelectionListener : SWTEventListener {

    public enum {
        SELECTION,
        DEFAULTSELECTION
    }
/**
 * Sent when selection occurs in the control.
 * <p>
 * For example, selection occurs in a List when the user selects
 * an item or items with the keyboard or mouse.  On some platforms,
 * the event occurs when a mouse button or key is pressed.  On others,
 * it happens when the mouse or key is released.  The exact key or
 * mouse gesture that causes this event is platform specific.
 * </p>
 *
 * @param e an event containing information about the selection
 */
public void widgetSelected(SelectionEvent e);

/**
 * Sent when default selection occurs in the control.
 * <p>
 * For example, on some platforms default selection occurs in a List
 * when the user double-clicks an item or types return in a Text.
 * On some platforms, the event occurs when a mouse button or key is
 * pressed.  On others, it happens when the mouse or key is released.
 * The exact key or mouse gesture that causes this event is platform
 * specific.
 * </p>
 *
 * @param e an event containing information about the default selection
 */
public void widgetDefaultSelected(SelectionEvent e);
}


/// SWT extension
private class _DgSelectionListenerT(Dg,T...) : SelectionListener {

    version(Tango){
        alias ParameterTupleOf!(Dg) DgArgs;
        static assert( is(DgArgs == Tuple!(SelectionEvent,T)),
                "Delegate args not correct: "~DgArgs.stringof~" vs. (Event,"~T.stringof~")" );
    } else { // Phobos
        alias ParameterTypeTuple!(Dg) DgArgs;
        static assert( is(DgArgs == TypeTuple!(SelectionEvent,T)),
                "Delegate args not correct: "~DgArgs.stringof~" vs. (Event,"~T.stringof~")" );
    }

    Dg dg;
    T  t;
    int type;

    private this( int type, Dg dg, T t ){
        this.type = type;
        this.dg = dg;
        static if( T.length > 0 ){
            this.t = t;
        }
    }

    public void widgetSelected(SelectionEvent e){
        if( type is SelectionListener.SELECTION ){
            dg(e,t);
        }
    }
    public void widgetDefaultSelected(SelectionEvent e){
        if( type is SelectionListener.DEFAULTSELECTION ){
            dg(e,t);
        }
    }
}

SelectionListener dgSelectionListener( Dg, T... )( int type, Dg dg, T args ){
    return new _DgSelectionListenerT!( Dg, T )( type, dg, args );
}

SelectionListener dgSelectionListenerWidgetSelected( Dg, T... )( Dg dg, T args ){
    return dgSelectionListener( SelectionListener.SELECTION, dg, args );
}
SelectionListener dgSelectionListenerWidgetDefaultSelected( Dg, T... )( Dg dg, T args ){
    return dgSelectionListener( SelectionListener.DEFAULTSELECTION, dg, args );
}

