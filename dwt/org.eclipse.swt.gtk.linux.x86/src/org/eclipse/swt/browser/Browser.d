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
module org.eclipse.swt.browser.Browser;

import java.lang.all;

import java.lang.Thread;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Widget;

import org.eclipse.swt.browser.Mozilla;
import org.eclipse.swt.browser.WebBrowser;
import org.eclipse.swt.browser.CloseWindowListener;
import org.eclipse.swt.browser.LocationListener;
import org.eclipse.swt.browser.OpenWindowListener;
import org.eclipse.swt.browser.ProgressListener;
import org.eclipse.swt.browser.StatusTextListener;
import org.eclipse.swt.browser.TitleListener;
import org.eclipse.swt.browser.VisibilityWindowListener;
/**
 * Instances of this class implement the browser user interface
 * metaphor.  It allows the user to visualize and navigate through
 * HTML documents.
 * <p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to set a layout on it.
 * </p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>MOZILLA</dd>
 * <dt><b>Events:</b></dt>
 * <dd>CloseWindowListener, LocationListener, OpenWindowListener, ProgressListener, StatusTextListener, TitleListener, VisibilityWindowListener</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 * 
 * @since 3.0
 */

public class Browser : Composite {
    WebBrowser webBrowser;
    int userStyle;

    static const String PACKAGE_PREFIX = "org.eclipse.swt.browser."; //$NON-NLS-1$
    static const String NO_INPUT_METHOD = "org.eclipse.swt.internal.gtk.noInputMethod"; //$NON-NLS-1$

/**
 * Constructs a new instance of this class given its parent
 * and a style value describing its behavior and appearance.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>SWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together 
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>SWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 * </p>
 *
 * @param parent a widget which will be the parent of the new instance (cannot be null)
 * @param style the style of widget to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 * @exception SWTError <ul>
 *    <li>ERROR_NO_HANDLES if a handle could not be obtained for browser creation</li>
 * </ul>
 * 
 * @see Widget#getStyle
 * 
 * @since 3.0
 */
public this (Composite parent, int style) {
    super (checkParent (parent), checkStyle (style));
    userStyle = style;

    String platform = SWT.getPlatform ();
    Display display = parent.getDisplay ();
    if ("gtk" == platform) display.setData (NO_INPUT_METHOD, null); //$NON-NLS-1$
    /*
    String className = null;
    if ((style & SWT.MOZILLA) !is 0) {
        className = "org.eclipse.swt.browser.Mozilla"; //$NON-NLS-1$
    } else {
        dispose();
        SWT.error(SWT.ERROR_NO_HANDLES);
    }
    */
    webBrowser = new Mozilla;
    if (webBrowser is null) {
        dispose ();
        SWT.error (SWT.ERROR_NO_HANDLES);
    }

    webBrowser.setBrowser (this);
    webBrowser.create (parent, style);
}

static Composite checkParent (Composite parent) {
    String platform = SWT.getPlatform ();
    if (!("gtk" == platform)) return parent; //$NON-NLS-1$

    /*
    * Note.  Mozilla provides all IM support needed for text input in web pages.
    * If SWT creates another input method context for the widget it will cause
    * indeterminate results to happen (hangs and crashes). The fix is to prevent 
    * SWT from creating an input method context for the  Browser widget.
    */
    if (parent !is null && !parent.isDisposed ()) {
        Display display = parent.getDisplay ();
        if (display !is null) {
            if (display.getThread () is Thread.currentThread ()) {
                display.setData (NO_INPUT_METHOD, stringcast("true")); //$NON-NLS-1$
            }
        }
    }
    return parent;
}

static int checkStyle(int style) {
    String platform = SWT.getPlatform ();
    if ((style & SWT.MOZILLA) !is 0) {
        if ("carbon" == platform) return style | SWT.EMBEDDED; //$NON-NLS-1$
        if ("motif" == platform) return style | SWT.EMBEDDED; //$NON-NLS-1$
        return style;
    }

    if ("win32" == platform) { //$NON-NLS-1$
        /*
        * For IE on win32 the border is supplied by the embedded browser, so remove
        * the style so that the parent Composite will not draw a second border.
        */
        return style & ~SWT.BORDER;
    } else if ("motif" == platform) { //$NON-NLS-1$
        return style | SWT.EMBEDDED;
    }
    return style;
}

/**
 * Clears all session cookies from all current Browser instances.
 * 
 * @since 3.2
 */
public static void clearSessions () {
    WebBrowser.clearSessions ();
}

/**  
 * Adds the listener to the collection of listeners who will be
 * notified when the window hosting the receiver should be closed.
 * <p>
 * This notification occurs when a javascript command such as
 * <code>window.close</code> gets executed by a <code>Browser</code>.
 * </p>
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void addCloseWindowListener (CloseWindowListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    webBrowser.addCloseWindowListener (listener);
}

/**  
 * Adds the listener to the collection of listeners who will be
 * notified when the current location has changed or is about to change.
 * <p>
 * This notification typically occurs when the application navigates
 * to a new location with {@link #setUrl(String)} or when the user
 * activates a hyperlink.
 * </p>
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void addLocationListener (LocationListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    webBrowser.addLocationListener (listener);
}

/**  
 * Adds the listener to the collection of listeners who will be
 * notified when a new window needs to be created.
 * <p>
 * This notification occurs when a javascript command such as
 * <code>window.open</code> gets executed by a <code>Browser</code>.
 * </p>
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void addOpenWindowListener (OpenWindowListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    webBrowser.addOpenWindowListener (listener);
}

/**  
 * Adds the listener to the collection of listeners who will be
 * notified when a progress is made during the loading of the current 
 * URL or when the loading of the current URL has been completed.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void addProgressListener (ProgressListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    webBrowser.addProgressListener (listener);
}

/**  
 * Adds the listener to the collection of listeners who will be
 * notified when the status text is changed.
 * <p>
 * The status text is typically displayed in the status bar of
 * a browser application.
 * </p>
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void addStatusTextListener (StatusTextListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    webBrowser.addStatusTextListener (listener);
}

/**  
 * Adds the listener to the collection of listeners who will be
 * notified when the title of the current document is available
 * or has changed.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void addTitleListener (TitleListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    webBrowser.addTitleListener (listener);
}

/**  
 * Adds the listener to the collection of listeners who will be
 * notified when a window hosting the receiver needs to be displayed
 * or hidden.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void addVisibilityWindowListener (VisibilityWindowListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    webBrowser.addVisibilityWindowListener (listener);
}

/**
 * Navigate to the previous session history item.
 *
 * @return <code>true</code> if the operation was successful and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @see #forward
 * 
 * @since 3.0
 */
public bool back () {
    checkWidget();
    return webBrowser.back ();
}

protected void checkSubclass () {
    String name = this.classinfo.name;
    name = name.substring(0, name.lastIndexOf('.'));
    int index = name.lastIndexOf('.');
    if (!name.substring (0, index + 1).equals (PACKAGE_PREFIX)) {
        getDwtLogger().info( __FILE__, __LINE__, "name: {} == {}", name.substring(0, index + 1), PACKAGE_PREFIX);
        SWT.error (SWT.ERROR_INVALID_SUBCLASS);
    }
}

/**
 * Execute the specified script.
 *
 * <p>
 * Execute a script containing javascript commands in the context of the current document. 
 * 
 * @param script the script with javascript commands
 *  
 * @return <code>true</code> if the operation was successful and <code>false</code> otherwise
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the script is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @since 3.1
 */
public bool execute (String script) {
    checkWidget();
    if (script is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    return webBrowser.execute (script);
}

/**
 * Navigate to the next session history item.
 *
 * @return <code>true</code> if the operation was successful and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 * 
 * @see #back
 * 
 * @since 3.0
 */
public bool forward () {
    checkWidget();
    return webBrowser.forward ();
}

public int getStyle () {
    /*
    * If SWT.BORDER was specified at creation time then getStyle() should answer
    * it even though it is removed for IE on win32 in checkStyle().
    */
    return super.getStyle () | (userStyle & SWT.BORDER);
}

/**
 * Returns a string with HTML that represents the content of the current page.
 *
 * @return HTML representing the current page or an empty <code>String</code>
 * if this is empty
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @since 3.4
 */
public String getText () {
    checkWidget();
    return webBrowser.getText ();
}

/**
 * Returns the current URL.
 *
 * @return the current URL or an empty <code>String</code> if there is no current URL
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @see #setUrl
 * 
 * @since 3.0
 */
public String getUrl () {
    checkWidget();
    return webBrowser.getUrl ();
}

/**
 * Returns the JavaXPCOM <code>nsIWebBrowser</code> for the receiver, or <code>null</code>
 * if it is not available.  In order for an <code>nsIWebBrowser</code> to be returned all
 * of the following must be true: <ul>
 *    <li>the receiver's style must be <code>SWT.MOZILLA</code></li>
 *    <li>the classes from JavaXPCOM &gt;= 1.8.1.2 must be resolvable at runtime</li>
 *    <li>the version of the underlying XULRunner must be &gt;= 1.8.1.2</li>
 * </ul> 
 *
 * @return the receiver's JavaXPCOM <code>nsIWebBrowser</code> or <code>null</code>
 * 
 * @since 3.3
 */
public Object getWebBrowser () {
    checkWidget();
    return webBrowser.getWebBrowser ();
}

/**
 * Returns <code>true</code> if the receiver can navigate to the 
 * previous session history item, and <code>false</code> otherwise.
 *
 * @return the receiver's back command enabled state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @see #back
 */
public bool isBackEnabled () {
    checkWidget();
    return webBrowser.isBackEnabled ();
}

public bool isFocusControl () {
    checkWidget();
    if (webBrowser.isFocusControl ()) return true;
    return super.isFocusControl ();
}

/**
 * Returns <code>true</code> if the receiver can navigate to the 
 * next session history item, and <code>false</code> otherwise.
 *
 * @return the receiver's forward command enabled state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @see #forward
 */
public bool isForwardEnabled () {
    checkWidget();
    return webBrowser.isForwardEnabled ();
}

/**
 * Refresh the current page.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void refresh () {
    checkWidget();
    webBrowser.refresh ();
}

/**  
 * Removes the listener from the collection of listeners who will
 * be notified when the window hosting the receiver should be closed.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 * 
 * @since 3.0
 */
public void removeCloseWindowListener (CloseWindowListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    webBrowser.removeCloseWindowListener (listener);
}

/**  
 * Removes the listener from the collection of listeners who will
 * be notified when the current location is changed or about to be changed.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 * 
 * @since 3.0
 */
public void removeLocationListener (LocationListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    webBrowser.removeLocationListener (listener);
}

/**  
 * Removes the listener from the collection of listeners who will
 * be notified when a new window needs to be created.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 * 
 * @since 3.0
 */
public void removeOpenWindowListener (OpenWindowListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    webBrowser.removeOpenWindowListener (listener);
}

/**  
 * Removes the listener from the collection of listeners who will
 * be notified when a progress is made during the loading of the current 
 * URL or when the loading of the current URL has been completed.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 * 
 * @since 3.0
 */
public void removeProgressListener (ProgressListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    webBrowser.removeProgressListener (listener);
}

/**  
 * Removes the listener from the collection of listeners who will
 * be notified when the status text is changed.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 * 
 * @since 3.0
 */
public void removeStatusTextListener (StatusTextListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    webBrowser.removeStatusTextListener (listener);
}

/**  
 * Removes the listener from the collection of listeners who will
 * be notified when the title of the current document is available
 * or has changed.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 * 
 * @since 3.0
 */
public void removeTitleListener (TitleListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    webBrowser.removeTitleListener (listener);
}

/**  
 * Removes the listener from the collection of listeners who will
 * be notified when a window hosting the receiver needs to be displayed
 * or hidden.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 * 
 * @since 3.0
 */
public void removeVisibilityWindowListener (VisibilityWindowListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    webBrowser.removeVisibilityWindowListener (listener);
}

/**
 * Renders HTML.
 * 
 * <p>
 * The html parameter is Unicode encoded since it is a java <code>String</code>.
 * As a result, the HTML meta tag charset should not be set. The charset is implied
 * by the <code>String</code> itself.
 * 
 * @param html the HTML content to be rendered
 *
 * @return true if the operation was successful and false otherwise.
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the html is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *  
 * @see #setUrl
 * 
 * @since 3.0
 */
public bool setText (String html) {
    checkWidget();
    if (html is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    return webBrowser.setText (html);
}

/**
 * Loads a URL.
 * 
 * @param url the URL to be loaded
 *
 * @return true if the operation was successful and false otherwise.
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the url is null</li>
 * </ul>
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *  
 * @see #getUrl
 * 
 * @since 3.0
 */
public bool setUrl (String url) {
    checkWidget();
    if (url is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    return webBrowser.setUrl (url);
}

/**
 * Stop any loading and rendering activity.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS when called from the wrong thread</li>
 *    <li>ERROR_WIDGET_DISPOSED when the widget has been disposed</li>
 * </ul>
 *
 * @since 3.0
 */
public void stop () {
    checkWidget();
    webBrowser.stop ();
}
}
