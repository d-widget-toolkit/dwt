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
module org.eclipse.swt.widgets.ProgressBar;

import java.lang.all;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.gtk.OS;

import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;


/**
 * Instances of the receiver represent an unselectable
 * user interface object that is used to display progress,
 * typically in the form of a bar.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>SMOOTH, HORIZONTAL, VERTICAL, INDETERMINATE</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles HORIZONTAL and VERTICAL may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#progressbar">ProgressBar snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class ProgressBar : Control {
    CallbackData callbackData;
    int timerId, minimum = 0, maximum = 100, selection = 0;
    static const int DELAY = 100;

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
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#SMOOTH
 * @see SWT#HORIZONTAL
 * @see SWT#VERTICAL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle(style));
}

static int checkStyle (int style) {
    style |= SWT.NO_FOCUS;
    return checkBits (style, SWT.HORIZONTAL, SWT.VERTICAL, 0, 0, 0, 0);
}

override void createHandle (int index) {
    state |= HANDLE;
    fixedHandle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (fixedHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_fixed_set_has_window (fixedHandle, true);
    handle = OS.gtk_progress_bar_new ();
    if (handle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_container_add (fixedHandle, handle);
    int orientation = ((style & SWT.VERTICAL) !is 0 ) ? OS.GTK_PROGRESS_BOTTOM_TO_TOP : OS.GTK_PROGRESS_LEFT_TO_RIGHT;
    OS.gtk_progress_bar_set_orientation (handle, orientation);
    if ((style & SWT.INDETERMINATE) !is 0) {
        timerId = display.doWindowTimerAdd( &callbackData, DELAY, handle );
    }
}

/**
 * Returns the maximum value which the receiver will allow.
 *
 * @return the maximum
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getMaximum () {
    checkWidget ();
    return maximum;
}

/**
 * Returns the minimum value which the receiver will allow.
 *
 * @return the minimum
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getMinimum () {
    checkWidget ();
    return minimum;
}

/**
 * Returns the single 'selection' that is the receiver's position.
 *
 * @return the selection
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSelection () {
    checkWidget ();
    return selection;
}

/**
 * Returns the state of the receiver. The value will be one of:
 * <ul>
 *  <li>{@link SWT#NORMAL}</li>
 *  <li>{@link SWT#ERROR}</li>
 *  <li>{@link SWT#PAUSED}</li>
 * </ul>
 *
 * @return the state 
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.4
 */
public int getState () {
    checkWidget ();
    return SWT.NORMAL;
}

override int gtk_realize (GtkWidget* widget) {
    int result = super.gtk_realize (widget);
    if (result !is 0) return result;
    /*
    * Bug in GTK.  When a progress bar has been unrealized after being
    * realized at least once, gtk_progress_bar_set_fraction() GP's.  The
    * fix is to update the progress bar state only when realized and restore
    * the state when the progress bar becomes realized.
    */
    updateBar (selection, minimum, maximum);
    return 0;
}

override void releaseWidget () {
    super.releaseWidget ();
    if (timerId !is 0) OS.gtk_timeout_remove (timerId);
    timerId = 0;
}

override void setParentBackground () {
    /*
    * Bug in GTK.  For some reason, some theme managers will crash
    * when the progress bar is inheriting the background from a parent.
    * The fix is to stop inheriting the background. This is acceptable
    * since progress bars do not use the inherited background.
    */
}

/**
 * Sets the maximum value that the receiver will allow.  This new
 * value will be ignored if it is not greater than the receiver's current
 * minimum value.  If the new maximum is applied then the receiver's
 * selection value will be adjusted if necessary to fall within its new range.
 *
 * @param value the new maximum, which must be greater than the current minimum
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMaximum (int value) {
    checkWidget ();
    if (value <= minimum) return;
    maximum = value;
    selection = Math.min (selection, maximum);
    updateBar (selection, minimum, maximum);
}

/**
 * Sets the minimum value that the receiver will allow.  This new
 * value will be ignored if it is negative or is not less than the receiver's
 * current maximum value.  If the new minimum is applied then the receiver's
 * selection value will be adjusted if necessary to fall within its new range.
 *
 * @param value the new minimum, which must be nonnegative and less than the current maximum
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMinimum (int value) {
    checkWidget ();
    if (value < 0 || value >= maximum) return;
    minimum = value;
    selection = Math.max (selection, minimum);
    updateBar (selection, minimum, maximum);
}

/**
 * Sets the single 'selection' that is the receiver's
 * position to the argument which must be greater than or equal
 * to zero.
 *
 * @param value the new selection (must be zero or greater)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (int value) {
    checkWidget ();
    selection = Math.max (minimum, Math.min (maximum, value));
    updateBar (selection, minimum, maximum);
}

/**
 * Sets the state of the receiver. The state must be one of these values:
 * <ul>
 *  <li>{@link SWT#NORMAL}</li>
 *  <li>{@link SWT#ERROR}</li>
 *  <li>{@link SWT#PAUSED}</li>
 * </ul>
 *
 * @param state the new state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.4
 */
public void setState (int state) {
    checkWidget ();
    //NOT IMPLEMENTED
}

override int timerProc (GtkWidget* widget) {
    if (isVisible ()) OS.gtk_progress_bar_pulse (handle);
    return 1;
}

void updateBar (int selection, int minimum, int maximum) {
   /*
    * Bug in GTK.  When a progress bar has been unrealized after being
    * realized at least once, gtk_progress_bar_set_fraction() GP's.  The
    * fix is to update the progress bar state only when realized and restore
    * the state when the progress bar becomes realized.
    */
    if ((OS.GTK_WIDGET_FLAGS (handle) & OS.GTK_REALIZED) is 0) return;

    double fraction = minimum is maximum ? 1 : cast(double)(selection - minimum) / (maximum - minimum);
    OS.gtk_progress_bar_set_fraction (handle, fraction);
    /*
    * Feature in GTK.  The progress bar does
    * not redraw right away when a value is
    * changed.  This is not strictly incorrect
    * but unexpected.  The fix is to force all
    * outstanding redraws to be delivered.
    */
    auto window = paintWindow ();
    OS.gdk_window_process_updates (window, false);
    OS.gdk_flush ();
}
}
