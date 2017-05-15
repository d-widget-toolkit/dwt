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
module org.eclipse.swt.widgets.Slider;

import java.lang.all;

import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.events.SelectionListener;

/**
 * Instances of this class are selectable user interface
 * objects that represent a range of positive, numeric values.
 * <p>
 * At any given moment, a given slider will have a
 * single 'selection' that is considered to be its
 * value, which is constrained to be within the range of
 * values the slider represents (that is, between its
 * <em>minimum</em> and <em>maximum</em> values).
 * </p><p>
 * Typically, sliders will be made up of five areas:
 * <ol>
 * <li>an arrow button for decrementing the value</li>
 * <li>a page decrement area for decrementing the value by a larger amount</li>
 * <li>a <em>thumb</em> for modifying the value by mouse dragging</li>
 * <li>a page increment area for incrementing the value by a larger amount</li>
 * <li>an arrow button for incrementing the value</li>
 * </ol>
 * Based on their style, sliders are either <code>HORIZONTAL</code>
 * (which have a left facing button for decrementing the value and a
 * right facing button for incrementing it) or <code>VERTICAL</code>
 * (which have an upward facing button for decrementing the value
 * and a downward facing buttons for incrementing it).
 * </p><p>
 * On some platforms, the size of the slider's thumb can be
 * varied relative to the magnitude of the range of values it
 * represents (that is, relative to the difference between its
 * maximum and minimum values). Typically, this is used to
 * indicate some proportional value such as the ratio of the
 * visible area of a document to the total amount of space that
 * it would take to display it. SWT supports setting the thumb
 * size even if the underlying platform does not, but in this
 * case the appearance of the slider will not change.
 * </p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>HORIZONTAL, VERTICAL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles HORIZONTAL and VERTICAL may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see ScrollBar
 * @see <a href="http://www.eclipse.org/swt/snippets/#slider">Slider snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Slider : Control {

    alias Control.computeSize computeSize;

    int detail;
    bool dragSent;
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
 * @see SWT#HORIZONTAL
 * @see SWT#VERTICAL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the user changes the receiver's value, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * When <code>widgetSelected</code> is called, the event object detail field contains one of the following values:
 * <code>SWT.NONE</code> - for the end of a drag.
 * <code>SWT.DRAG</code>.
 * <code>SWT.HOME</code>.
 * <code>SWT.END</code>.
 * <code>SWT.ARROW_DOWN</code>.
 * <code>SWT.ARROW_UP</code>.
 * <code>SWT.PAGE_DOWN</code>.
 * <code>SWT.PAGE_UP</code>.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
 *
 * @param listener the listener which should be notified when the user changes the receiver's value
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SelectionListener
 * @see #removeSelectionListener
 * @see SelectionEvent
 */
public void addSelectionListener (SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
}

static int checkStyle (int style) {
    return checkBits (style, SWT.HORIZONTAL, SWT.VERTICAL, 0, 0, 0, 0);
}

override void createHandle (int index) {
    state |= HANDLE;
    fixedHandle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (fixedHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_fixed_set_has_window (fixedHandle, true);
    auto hAdjustment = OS.gtk_adjustment_new (0, 0, 100, 1, 10, 10);
    if (hAdjustment is null) error (SWT.ERROR_NO_HANDLES);
    if ((style & SWT.HORIZONTAL) !is 0) {
        handle = cast(GtkWidget*)OS.gtk_hscrollbar_new (hAdjustment);
    } else {
        handle = cast(GtkWidget*)OS.gtk_vscrollbar_new (hAdjustment);
    }
    if (handle is null) error (SWT.ERROR_NO_HANDLES);
    /*
    * Bug in GTK. In GTK 2.10, the buttons on either end of
    * a horizontal slider are created taller then the slider bar
    * when the GTK_CAN_FOCUS flag is set. The fix is not to set
    * the flag for horizontal bars in all versions of 2.10. Note
    * that a bug has been logged with GTK about this issue.
    * (http://bugzilla.gnome.org/show_bug.cgi?id=475909)
    */
    if (OS.GTK_VERSION < OS.buildVERSION (2, 10, 0) || (style & SWT.VERTICAL) !is 0) {
        OS.GTK_WIDGET_SET_FLAGS (handle, OS.GTK_CAN_FOCUS);
    }
    OS.gtk_container_add (fixedHandle, handle);
}

override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* event) {
    auto result = super.gtk_button_press_event (widget, event);
    if (result !is 0) return result;
    detail = OS.GTK_SCROLL_NONE;
    dragSent = false;
    return result;
}

override int gtk_change_value (GtkWidget* widget, int scroll, double value1, void* user_data) {
    detail = scroll;
    return 0;
}

override int gtk_value_changed (int adjustment) {
    Event event = new Event ();
    dragSent = detail is OS.GTK_SCROLL_JUMP;
    switch (detail) {
        case OS.GTK_SCROLL_NONE:            event.detail = SWT.NONE; break;
        case OS.GTK_SCROLL_JUMP:            event.detail = SWT.DRAG; break;
        case OS.GTK_SCROLL_START:           event.detail = SWT.HOME; break;
        case OS.GTK_SCROLL_END:             event.detail = SWT.END; break;
        case OS.GTK_SCROLL_PAGE_DOWN:
        case OS.GTK_SCROLL_PAGE_RIGHT:
        case OS.GTK_SCROLL_PAGE_FORWARD:    event.detail = SWT.PAGE_DOWN; break;
        case OS.GTK_SCROLL_PAGE_UP:
        case OS.GTK_SCROLL_PAGE_LEFT:
        case OS.GTK_SCROLL_PAGE_BACKWARD:   event.detail = SWT.PAGE_UP; break;
        case OS.GTK_SCROLL_STEP_DOWN:
        case OS.GTK_SCROLL_STEP_RIGHT:
        case OS.GTK_SCROLL_STEP_FORWARD:    event.detail = SWT.ARROW_DOWN; break;
        case OS.GTK_SCROLL_STEP_UP:
        case OS.GTK_SCROLL_STEP_LEFT:
        case OS.GTK_SCROLL_STEP_BACKWARD:   event.detail = SWT.ARROW_UP; break;
        default:
    }
    if (!dragSent) detail = OS.GTK_SCROLL_NONE;
    postEvent (SWT.Selection, event);
    return 0;
}

override int gtk_event_after (GtkWidget* widget, GdkEvent* gdkEvent) {
    GdkEventButton* gdkEventButton = null;
    switch (gdkEvent.type) {
        case OS.GDK_BUTTON_RELEASE: {
            gdkEventButton = cast(GdkEventButton*)gdkEvent;
            if (gdkEventButton.button is 1 && detail is SWT.DRAG) {
                if (!dragSent) {
                    Event event = new Event ();
                    event.detail = SWT.DRAG;
                    postEvent (SWT.Selection, event);
                }
                postEvent (SWT.Selection);
            }
            detail = OS.GTK_SCROLL_NONE;
            dragSent = false;
            break;
        default:
        }
    }
    return super.gtk_event_after (widget, gdkEvent);
}

override void hookEvents () {
    super.hookEvents ();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 6, 0)) {
        OS.g_signal_connect_closure (handle, OS.change_value.ptr, display.closures [CHANGE_VALUE], false);
    }
    OS.g_signal_connect_closure (handle, OS.value_changed.ptr, display.closures [VALUE_CHANGED], false);
}

override void register () {
    super.register ();
    auto hAdjustment = OS.gtk_range_get_adjustment (cast(GtkRange*)handle);
    display.addWidget (cast(GtkWidget*)hAdjustment, this);
}

override void deregister () {
    super.deregister ();
    auto hAdjustment = OS.gtk_range_get_adjustment (cast(GtkRange*)handle);
    display.removeWidget (cast(GtkWidget*)hAdjustment);
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget();
    if (wHint !is SWT.DEFAULT && wHint < 0) wHint = 0;
    if (hHint !is SWT.DEFAULT && hHint < 0) hHint = 0;
    Point size = computeNativeSize(handle, wHint, hHint, changed);
    if ((style & SWT.HORIZONTAL) !is 0) {
        if (wHint is SWT.DEFAULT) size.x = 2 * size.x;
    } else {
        if (hHint is SWT.DEFAULT) size.y = 2 * size.y;
    }
    return size;
}

/**
 * Returns the amount that the receiver's value will be
 * modified by when the up/down (or right/left) arrows
 * are pressed.
 *
 * @return the increment
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getIncrement () {
    checkWidget ();
    auto hAdjustment = OS.gtk_range_get_adjustment (cast(GtkRange*)handle);
    return cast(int) hAdjustment.step_increment;
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
    auto hAdjustment = OS.gtk_range_get_adjustment (cast(GtkRange*)handle);
    return cast(int) hAdjustment.upper;
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
    auto hAdjustment = OS.gtk_range_get_adjustment (cast(GtkRange*)handle);
    return cast(int) hAdjustment.lower;
}

/**
 * Returns the amount that the receiver's value will be
 * modified by when the page increment/decrement areas
 * are selected.
 *
 * @return the page increment
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getPageIncrement () {
    checkWidget ();
    auto hAdjustment = OS.gtk_range_get_adjustment (cast(GtkRange*)handle);
    return cast(int) hAdjustment.page_increment;
}

/**
 * Returns the 'selection', which is the receiver's value.
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
    auto hAdjustment = OS.gtk_range_get_adjustment (cast(GtkRange*)handle);
    return cast(int) hAdjustment.value;
}

/**
 * Returns the size of the receiver's thumb relative to the
 * difference between its maximum and minimum values.
 *
 * @return the thumb value
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getThumb () {
    checkWidget ();
    auto hAdjustment = OS.gtk_range_get_adjustment (cast(GtkRange*)handle);
    return cast(int) hAdjustment.page_size;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the user changes the receiver's value.
 *
 * @param listener the listener which should no longer be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SelectionListener
 * @see #addSelectionListener
 */
public void removeSelectionListener (SelectionListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Selection, listener);
    eventTable.unhook (SWT.DefaultSelection,listener);
}

/**
 * Sets the amount that the receiver's value will be
 * modified by when the up/down (or right/left) arrows
 * are pressed to the argument, which must be at least
 * one.
 *
 * @param value the new increment (must be greater than zero)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setIncrement (int value) {
    checkWidget ();
    if (value < 1) return;
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
    OS.gtk_range_set_increments (cast(GtkRange*)handle, value, getPageIncrement ());
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
}

/**
 * Sets the maximum. If this value is negative or less than or
 * equal to the minimum, the value is ignored. If necessary, first
 * the thumb and then the selection are adjusted to fit within the
 * new range.
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
    auto adjustment = OS.gtk_range_get_adjustment (cast(GtkRange*)handle);
    int minimum = cast(int) adjustment.lower;
    if (value <= minimum) return;
    adjustment.upper = value;
    adjustment.page_size = Math.min (cast(int)adjustment.page_size, value - minimum);
    adjustment.value = Math.min (cast(int)adjustment.value, cast(int)(value - adjustment.page_size));
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
    OS.gtk_adjustment_changed (adjustment);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
}

/**
 * Sets the minimum value. If this value is negative or greater
 * than or equal to the maximum, the value is ignored. If necessary,
 * first the thumb and then the selection are adjusted to fit within
 * the new range.
 *
 * @param value the new minimum
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMinimum (int value) {
    checkWidget ();
    if (value < 0) return;
    auto adjustment = OS.gtk_range_get_adjustment (cast(GtkRange*)handle);
    int maximum = cast(int) adjustment.upper;
    if (value >= maximum) return;
    adjustment.lower = value;
    adjustment.page_size = Math.min (cast(int)adjustment.page_size, maximum - value);
    adjustment.value = Math.max (cast(int)adjustment.value, value);
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
    OS.gtk_adjustment_changed (adjustment);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
}

override void setOrientation () {
    super.setOrientation ();
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        if ((style & SWT.HORIZONTAL) !is 0) {
            OS.gtk_range_set_inverted (cast(GtkRange*)handle, true);
        }
    }
}

/**
 * Sets the amount that the receiver's value will be
 * modified by when the page increment/decrement areas
 * are selected to the argument, which must be at least
 * one.
 *
 * @param value the page increment (must be greater than zero)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setPageIncrement (int value) {
    checkWidget ();
    if (value < 1) return;
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
    OS.gtk_range_set_increments (cast(GtkRange*)handle, getIncrement (), value);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
}

/**
 * Sets the 'selection', which is the receiver's
 * value, to the argument which must be greater than or equal
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
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
    OS.gtk_range_set_value (cast(GtkRange*)handle, value);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
}

/**
 * Sets the size of the receiver's thumb relative to the
 * difference between its maximum and minimum values.  This new
 * value will be ignored if it is less than one, and will be
 * clamped if it exceeds the receiver's current range.
 *
 * @param value the new thumb value, which must be at least one and not
 * larger than the size of the current range
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setThumb (int value) {
    checkWidget ();
    if (value < 1) return;
    auto adjustment = OS.gtk_range_get_adjustment (cast(GtkRange*)handle);
    value = cast(int) Math.min (value, cast(int)(adjustment.upper - adjustment.lower));
    adjustment.page_size = cast(double) value;
    adjustment.value = Math.min (cast(int)adjustment.value, cast(int)(adjustment.upper - value));
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
    OS.gtk_adjustment_changed (adjustment);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
}

/**
 * Sets the receiver's selection, minimum value, maximum
 * value, thumb, increment and page increment all at once.
 * <p>
 * Note: This is similar to setting the values individually
 * using the appropriate methods, but may be implemented in a
 * more efficient fashion on some platforms.
 * </p>
 *
 * @param selection the new selection value
 * @param minimum the new minimum value
 * @param maximum the new maximum value
 * @param thumb the new thumb value
 * @param increment the new increment value
 * @param pageIncrement the new pageIncrement value
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setValues (int selection, int minimum, int maximum, int thumb, int increment, int pageIncrement) {
    checkWidget ();
    if (minimum < 0) return;
    if (maximum < 0) return;
    if (thumb < 1) return;
    if (increment < 1) return;
    if (pageIncrement < 1) return;
    thumb = Math.min (thumb, maximum - minimum);
    auto adjustment = OS.gtk_range_get_adjustment (cast(GtkRange*)handle);
    adjustment.value = Math.min (Math.max (selection, minimum), maximum - thumb);
    adjustment.lower = cast(double) minimum;
    adjustment.upper = cast(double) maximum;
    adjustment.page_size = cast(double) thumb;
    adjustment.step_increment = cast(double) increment;
    adjustment.page_increment = cast(double) pageIncrement;
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
    OS.gtk_adjustment_changed (adjustment);
    OS.gtk_adjustment_value_changed (adjustment);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
}

}
