/*******************************************************************************
 * Copyright (c) 2003, 2007 IBM Corporation and others.
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
module org.eclipse.swt.browser.MozillaDelegate;

import java.lang.all;

version(Tango){
import tango.io.Console;
} else { // Phobos
}

import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Widget;

import org.eclipse.swt.browser.Browser;
import org.eclipse.swt.browser.Mozilla;

//import org.eclipse.swt.internal.c.glib_object;

class MozillaDelegate {
    Browser browser;
    gpointer mozillaHandle;
    GtkWidget* embedHandle;
    bool hasFocus;
    Listener listener;
    //static Callback eventCallback;
    // static ptrdiff_t eventProc;
    static const gpointer STOP_PROPOGATE = cast(gpointer)1;
    static bool IsLinux;

static this () {
    String osName = System.getProperty ("os.name").toLowerCase(); //$NON-NLS-1$
    IsLinux = osName.startsWith("linux"); //$NON-NLS-1$
}

this (Browser browser) {
    //super ();
    if (!IsLinux) {
        browser.dispose ();
        SWT.error (SWT.ERROR_NO_HANDLES, null, " [Unsupported platform]"); //$NON-NLS-1$
    }
    this.browser = browser;
}

static extern(System) int eventProc (GtkWidget* handle, GdkEvent* gdkEvent, gpointer pointer) {
    GtkWidget* parent = OS.gtk_widget_get_parent (handle);
    parent = OS.gtk_widget_get_parent (parent);
    if (parent is null) return 0;
    Widget widget = Display.getCurrent ().findWidget (parent);
    if (widget !is null && (cast(Browser)widget) !is null) {
        return (cast(Mozilla)(cast(Browser)widget).webBrowser).mozDelegate.gtk_event (handle, gdkEvent, pointer);
    }
    return 0;
}

static Browser findBrowser (GtkWidget* handle) {
    /*
    * Note.  On GTK, Mozilla is embedded into a GtkHBox handle
    * and not directly into the parent Composite handle.
    */
    GtkWidget* parent = OS.gtk_widget_get_parent (handle);
    Display display = Display.getCurrent ();
    return cast(Browser)display.findWidget (parent); 
}
/*
static char[] mbcsToWcs (String codePage, byte [] buffer) {
    return Converter.mbcsToWcs (codePage, buffer);
}

static byte[] wcsToMbcs (String codePage, String string, bool terminate) {
    return Converter.wcsToMbcs (codePage, string, terminate);
}
*/
GtkWidget* getHandle () {
    /*
    * Bug in Mozilla Linux GTK.  Embedding Mozilla into a GtkFixed
    * handle causes problems with some Mozilla plug-ins.  For some
    * reason, the Flash plug-in causes the child of the GtkFixed
    * handle to be resized to 1 when the Flash document is loaded.
    * That could be due to gtk_container_resize_children being called
    * by Mozilla - or one of its plug-ins - on the GtkFixed handle,
    * causing the child of the GtkFixed handle to be resized to 1.
    * The workaround is to embed Mozilla into a GtkHBox handle.
    */
    embedHandle = OS.gtk_hbox_new (false, 0);
    OS.gtk_container_add (browser.handle, embedHandle);
    OS.gtk_widget_show (embedHandle);
    return embedHandle;
}

String getLibraryName () {
    return "libxpcom.so"; //$NON-NLS-1$
}

/*
String getSWTInitLibraryName () {
    return "swt-xpcominit"; //$NON-NLS-1$
}
*/

int gtk_event (GtkWidget* handle, GdkEvent* event, gpointer pointer) {
    if (event.type is OS.GDK_BUTTON_PRESS) {
        if (!hasFocus) browser.setFocus ();
    }

    /* 
    * Stop the propagation of events that are not consumed by Mozilla, before
    * they reach the parent embedder.  These event have already been received.
    */
    if (pointer is STOP_PROPOGATE) return 1;
    return 0;
}

void handleFocus () {
    if (hasFocus) return;
    hasFocus = true;
    listener = new class() Listener {
        public void handleEvent (Event event) {
            if (event.widget is browser) return;
            (cast(Mozilla)(browser.webBrowser)).Deactivate ();
            hasFocus = false;
            browser.getDisplay ().removeFilter (SWT.FocusIn, this);
            browser.getShell ().removeListener (SWT.Deactivate, this);
            listener = null;
        }
    };
    browser.getDisplay ().addFilter (SWT.FocusIn, listener);
    browser.getShell ().addListener (SWT.Deactivate, listener);
}

void handleMouseDown () {
    int shellStyle = browser.getShell ().getStyle (); 
    if ((shellStyle & SWT.ON_TOP) !is 0 && (((shellStyle & SWT.NO_FOCUS) is 0) || ((browser.getStyle () & SWT.NO_FOCUS) is 0))) {
        browser.getDisplay ().asyncExec (new class() Runnable {
            public void run () {
                if (browser is null || browser.isDisposed ()) return;
                (cast(Mozilla)(browser.webBrowser)).Activate ();
            }
        });
    }
}

bool hookEnterExit () {
    return false;
}

void init () { /*
    if (eventCallback is null) {
        eventCallback = new Callback (getClass (), "eventProc", 3); //$NON-NLS-1$
        eventProc = eventCallback.getAddress ();
        if (eventProc is null) {
            browser.dispose ();
            Mozilla.error (SWT.ERROR_NO_MORE_CALLBACKS);
        }
    } */

    /*
    * Feature in Mozilla.  GtkEvents such as key down, key pressed may be consumed
    * by Mozilla and never be received by the parent embedder.  The workaround
    * is to find the top Mozilla gtk widget that receives all the Mozilla GtkEvents,
    * i.e. the first child of the parent embedder. Then hook event callbacks and
    * forward the event to the parent embedder before Mozilla received and consumed
    * them.
    */
    GList* list = OS.gtk_container_get_children (embedHandle);
    if (list !is null) {
        mozillaHandle = OS.g_list_data (list);
        OS.g_list_free (list);
        
        if (mozillaHandle !is null) {          
            /* Note. Callback to get events before Mozilla receives and consumes them. */
            OS.g_signal_connect (mozillaHandle, OS.event.toStringz(), cast(GCallback)&eventProc, null);
            
            /* 
            * Note.  Callback to get the events not consumed by Mozilla - and to block 
            * them so that they don't get propagated to the parent handle twice.  
            * This hook is set after Mozilla and is therefore called after Mozilla's 
            * handler because GTK dispatches events in their order of registration.
            */
            OS.g_signal_connect (mozillaHandle, OS.key_press_event.toStringz(), cast(GCallback)&eventProc, STOP_PROPOGATE);
            OS.g_signal_connect (mozillaHandle, OS.key_release_event.toStringz(), cast(GCallback)&eventProc, STOP_PROPOGATE);
            OS.g_signal_connect (mozillaHandle, OS.button_press_event.toStringz(), cast(GCallback)&eventProc, STOP_PROPOGATE);
        }
    }
}

bool needsSpinup () {
    return true;
}

void onDispose (GtkWidget* embedHandle) {
    if (listener !is null) {
        browser.getDisplay ().removeFilter (SWT.FocusIn, listener);
        browser.getShell ().removeListener (SWT.Deactivate, listener);
        listener = null;
    }
    browser = null;
}

void setSize (GtkWidget* embedHandle, int width, int height) {
    OS.gtk_widget_set_size_request (embedHandle, width, height);
}

}
