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
module org.eclipse.swt.widgets.Spinner;


import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.VerifyListener;

import java.lang.all;
version(Tango){
    import tango.util.Convert;
} else { // Phobos
    import std.conv;
}

/**
 * Instances of this class are selectable user interface
 * objects that allow the user to enter and modify numeric
 * values.
 * <p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add children to it, or set a layout on it.
 * </p><p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>READ_ONLY, WRAP</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection, Modify, Verify</dd>
 * </dl>
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#spinner">Spinner snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * 
 * @since 3.1
 */
public class Spinner : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.createHandle createHandle;
    alias Composite.setBackgroundColor setBackgroundColor;
    alias Composite.setCursor setCursor;
    alias Composite.translateTraversal translateTraversal;

    static const int INNER_BORDER = 2;
    static const int MIN_ARROW_WIDTH = 6;
    int lastEventTime = 0;
    GdkEventKey* gdkEventKey;
    int fixStart = -1, fixEnd = -1;

    /**
     * the operating system limit for the number of characters
     * that the text field in an instance of this class can hold
     * 
     * @since 3.4
     */
    public const static int LIMIT = 0x7FFFFFFF;

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
 * @see SWT#READ_ONLY
 * @see SWT#WRAP
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the receiver's text is modified, by sending
 * it one of the messages defined in the <code>ModifyListener</code>
 * interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see ModifyListener
 * @see #removeModifyListener
 */
public void addModifyListener (ModifyListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Modify, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is not called for texts.
 * <code>widgetDefaultSelected</code> is typically called when ENTER is pressed in a single-line text.
 * </p>
 *
 * @param listener the listener which should be notified when the control is selected by the user
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
public void addSelectionListener(SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener(listener);
    addListener(SWT.Selection,typedListener);
    addListener(SWT.DefaultSelection,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the receiver's text is verified, by sending
 * it one of the messages defined in the <code>VerifyListener</code>
 * interface.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see VerifyListener
 * @see #removeVerifyListener
 */
void addVerifyListener (VerifyListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Verify, typedListener);
}

static int checkStyle (int style) {
    /*
    * Even though it is legal to create this widget
    * with scroll bars, they serve no useful purpose
    * because they do not automatically scroll the
    * widget's client area.  The fix is to clear
    * the SWT style.
    */
    return style & ~(SWT.H_SCROLL | SWT.V_SCROLL);
}

protected override void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

public override Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    if (wHint !is SWT.DEFAULT && wHint < 0) wHint = 0;
    if (hHint !is SWT.DEFAULT && hHint < 0) hHint = 0;
    int[1] w, h;
    OS.gtk_widget_realize (handle);
    auto layout = OS.gtk_entry_get_layout (cast(GtkEntry*)handle);
    auto adjustment = OS.gtk_spin_button_get_adjustment (cast(GtkSpinButton*)handle);
    int digits = OS.gtk_spin_button_get_digits (cast(GtkSpinButton*)handle);
    for (int i = 0; i < digits; i++) adjustment.upper *= 10;
    String string = to!(String)( (cast(int) adjustment.upper) );
    if (digits > 0) {
        //PROTING_TODO: Efficiency
        String buffer = string ~ getDecimalSeparator ();
        ptrdiff_t count = digits - string.length;
        while (count >= 0) {
            buffer ~= "0";
            count--;
        }
        string = buffer;
    }
    auto buffer1 = string;
    auto ptr = OS.pango_layout_get_text (layout);
    String buffer2 = fromStringz( ptr )._idup();
    OS.pango_layout_set_text (layout, buffer1.ptr, cast(int)/*64bit*/buffer1.length);
    OS.pango_layout_get_size (layout, w.ptr, h.ptr);
    OS.pango_layout_set_text (layout, buffer2.ptr, cast(int)/*64bit*/buffer2.length);
    int width = OS.PANGO_PIXELS (w [0]);
    int height = OS.PANGO_PIXELS (h [0]);
    width = wHint is SWT.DEFAULT ? width : wHint;
    height = hHint is SWT.DEFAULT ? height : hHint;
    Rectangle trim = computeTrim (0, 0, width, height);
    return new Point (trim.width, trim.height);
}

override public Rectangle computeTrim (int x, int y, int width, int height) {
    checkWidget ();
    int xborder = 0, yborder = 0;
    auto style = OS.gtk_widget_get_style (handle);
    if ((this.style & SWT.BORDER) !is 0) {
        xborder += OS.gtk_style_get_xthickness (style);
        yborder += OS.gtk_style_get_ythickness (style);
    }
    xborder += INNER_BORDER;
    yborder += INNER_BORDER;
    int property;
    OS.gtk_widget_style_get1 (handle, OS.interior_focus.ptr, &property);
    if (property is 0) {
        OS.gtk_widget_style_get1 (handle, OS.focus_line_width.ptr, &property);
        xborder += property;
        yborder += property;
    }
    auto fontDesc = OS.gtk_style_get_font_desc (style);
    int fontSize = OS.pango_font_description_get_size (fontDesc);
    int arrowSize = Math.max (OS.PANGO_PIXELS (fontSize), MIN_ARROW_WIDTH);
    arrowSize = arrowSize - arrowSize % 2;
    Rectangle trim = super.computeTrim (x, y, width, height);
    trim.x -= xborder;
    trim.y -= yborder;
    trim.width += 2 * xborder;
    trim.height += 2 * yborder;
    trim.width += arrowSize + (2 * OS.gtk_style_get_xthickness (style));
    return new Rectangle (trim.x, trim.y, trim.width, trim.height);
}

/**
 * Copies the selected text.
 * <p>
 * The current selection is copied to the clipboard.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void copy () {
    checkWidget ();
    OS.gtk_editable_copy_clipboard (cast(GtkEditable*)handle);
}

override void createHandle (int index) {
    state |= HANDLE | MENU;
    fixedHandle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (fixedHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_fixed_set_has_window (cast(GtkFixed*)fixedHandle, true);
    auto adjustment = OS.gtk_adjustment_new (0, 0, 100, 1, 10, 0);
    if (adjustment is null) error (SWT.ERROR_NO_HANDLES);
    handle = cast(GtkWidget*)OS.gtk_spin_button_new (cast(GtkAdjustment*)adjustment, 1, 0);
    if (handle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_container_add (cast(GtkContainer*)fixedHandle, handle);
    OS.gtk_editable_set_editable (cast(GtkEditable*)handle, (style & SWT.READ_ONLY) is 0);
    OS.gtk_entry_set_has_frame (cast(GtkEntry*)handle, (style & SWT.BORDER) !is 0);
    OS.gtk_spin_button_set_wrap (cast(GtkSpinButton*)handle, (style & SWT.WRAP) !is 0);
}

/**
 * Cuts the selected text.
 * <p>
 * The current selection is first copied to the
 * clipboard and then deleted from the widget.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void cut () {
    checkWidget ();
    OS.gtk_editable_cut_clipboard (cast(GtkEditable*)handle);
}

override void deregister () {
    super.deregister ();
    auto imContext = imContext ();
    if (imContext !is null) display.removeWidget (cast(GtkWidget*)imContext);
}

override GdkDrawable* eventWindow () {
    return paintWindow ();
}

override GtkWidget* enterExitHandle () {
    return fixedHandle;
}

override bool filterKey (int keyval, GdkEventKey* event) {
    int time = OS.gdk_event_get_time (cast(GdkEvent*)event);
    if (time !is lastEventTime) {
        lastEventTime = time;
        auto imContext = imContext ();
        if (imContext !is null) {
            return cast(bool)OS.gtk_im_context_filter_keypress (imContext, event);
        }
    }
    gdkEventKey = event;
    return false;
}

void fixIM () {
    /*
    *  The IM filter has to be called one time for each key press event.
    *  When the IM is open the key events are duplicated. The first event
    *  is filtered by SWT and the second event is filtered by GTK.  In some
    *  cases the GTK handler does not run (the widget is destroyed, the
    *  application code consumes the event, etc), for these cases the IM
    *  filter has to be called by SWT.
    */
    if (gdkEventKey !is null && gdkEventKey !is cast(GdkEventKey*)-1) {
        auto imContext = imContext ();
        if (imContext !is null) {
            OS.gtk_im_context_filter_keypress (imContext, gdkEventKey);
            gdkEventKey = cast(GdkEventKey*)-1;
            return;
        }
    }
    gdkEventKey = null;
}

override GdkColor* getBackgroundColor () {
    return getBaseColor ();
}

public override int getBorderWidth () {
    checkWidget();
    auto style = OS.gtk_widget_get_style (handle);
    if ((this.style & SWT.BORDER) !is 0) {
         return OS.gtk_style_get_xthickness (style);
    }
    return 0;
}

override GdkColor* getForegroundColor () {
    return getTextColor ();
}

/**
 * Returns the amount that the receiver's value will be
 * modified by when the up/down arrows are pressed.
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
    auto adjustment = OS.gtk_spin_button_get_adjustment (cast(GtkSpinButton*)handle);
    int digits = OS.gtk_spin_button_get_digits (cast(GtkSpinButton*)handle);
    auto value = adjustment.step_increment;
    for (int i = 0; i < digits; i++) value *= 10;
    return cast(int) (value > 0 ? value + 0.5 : value - 0.5);
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
    auto adjustment = OS.gtk_spin_button_get_adjustment (cast(GtkSpinButton*)handle);
    int digits = OS.gtk_spin_button_get_digits (cast(GtkSpinButton*)handle);
    auto value = adjustment.upper;
    for (int i = 0; i < digits; i++) value *= 10;
    return cast(int) (value > 0 ? value + 0.5 : value - 0.5);
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
    auto adjustment = OS.gtk_spin_button_get_adjustment (cast(GtkSpinButton*)handle);
    int digits = OS.gtk_spin_button_get_digits (cast(GtkSpinButton*)handle);
    auto value = adjustment.lower;
    for (int i = 0; i < digits; i++) value *= 10;
    return cast(int) (value > 0 ? value + 0.5 : value - 0.5);
}

/**
 * Returns the amount that the receiver's position will be
 * modified by when the page up/down keys are pressed.
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
    auto adjustment = OS.gtk_spin_button_get_adjustment (cast(GtkSpinButton*)handle);
    int digits = OS.gtk_spin_button_get_digits (cast(GtkSpinButton*)handle);
    auto value = adjustment.page_increment;
    for (int i = 0; i < digits; i++) value *= 10;
    return cast(int) (value > 0 ? value + 0.5 : value - 0.5);
}

/**
 * Returns the <em>selection</em>, which is the receiver's position.
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
    auto adjustment = OS.gtk_spin_button_get_adjustment (cast(GtkSpinButton*)handle);
    int digits = OS.gtk_spin_button_get_digits (cast(GtkSpinButton*)handle);
    auto value = adjustment.value;
    for (int i = 0; i < digits; i++) value *= 10;
    return cast(int) (value > 0 ? value + 0.5 : value - 0.5);
}

/**
 * Returns a string containing a copy of the contents of the
 * receiver's text field, or an empty string if there are no
 * contents.
 *
 * @return the receiver's text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.4
 */
public String getText () {
    checkWidget ();
    auto str = OS.gtk_entry_get_text (handle);
    return fromStringz(str)._idup();
}

/**
 * Returns the maximum number of characters that the receiver's
 * text field is capable of holding. If this has not been changed
 * by <code>setTextLimit()</code>, it will be the constant
 * <code>Spinner.LIMIT</code>.
 * 
 * @return the text limit
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #LIMIT
 * 
 * @since 3.4
 */
public int getTextLimit () {
    checkWidget ();
    int limit = OS.gtk_entry_get_max_length (handle);
    return limit is 0 ? 0xFFFF : limit;
}

/**
 * Returns the number of decimal places used by the receiver.
 *
 * @return the digits
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getDigits () {
    checkWidget ();
    return OS.gtk_spin_button_get_digits (cast(GtkSpinButton*)handle);
}

String getDecimalSeparator () {
    auto ptr = OS.localeconv_decimal_point ();
    return fromStringz( ptr )._idup();
}

override int gtk_activate (GtkWidget* widget) {
    postEvent (SWT.DefaultSelection);
    return 0;
}

override int gtk_changed (GtkWidget* widget) {
    auto str = OS.gtk_entry_get_text (cast(GtkEntry*)handle);
    int length = OS.strlen (str);
    if (length > 0) {
        char* endptr;
        double value = OS.g_strtod (str, &endptr);
        if (endptr is str + length) {
            auto adjustment = OS.gtk_spin_button_get_adjustment (cast(GtkSpinButton*)handle);
            if (value !is adjustment.value && adjustment.lower <= value && value <= adjustment.upper) {
                OS.gtk_spin_button_update (cast(GtkSpinButton*)handle);
            }
        }
    }

    /*
    * Feature in GTK.  When the user types, GTK positions
    * the caret after sending the changed signal.  This
    * means that application code that attempts to position
    * the caret during a changed signal will fail.  The fix
    * is to post the modify event when the user is typing.
    */
    bool keyPress = false;
    auto eventPtr = OS.gtk_get_current_event ();
    if (eventPtr !is null) {
        GdkEventKey* gdkEvent = cast(GdkEventKey*)eventPtr;
        switch (gdkEvent.type) {
            case OS.GDK_KEY_PRESS:
                keyPress = true;
                break;
            default:
        }
        OS.gdk_event_free (eventPtr);
    }
    if (keyPress) {
        postEvent (SWT.Modify);
    } else {
        sendEvent (SWT.Modify);
    }
    return 0;
}

override
int gtk_commit (GtkIMContext* imContext, char* text) {
    if (text is null) return 0;
    if (!OS.gtk_editable_get_editable (cast(GtkEditable*)handle)) return 0;
    char [] chars = fromStringz( text ).dup;
    if (chars.length is 0) return 0;
    char [] newChars = sendIMKeyEvent (SWT.KeyDown, null, chars);
    if (newChars is null) return 0;
    /*
    * Feature in GTK.  For a GtkEntry, during the insert-text signal,
    * GTK allows the programmer to change only the caret location,
    * not the selection.  If the programmer changes the selection,
    * the new selection is lost.  The fix is to detect a selection
    * change and set it after the insert-text signal has completed.
    */
    fixStart = fixEnd = -1;
    OS.g_signal_handlers_block_matched (imContext, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCOMMIT);
    int id = OS.g_signal_lookup (OS.commit.ptr, OS.gtk_im_context_get_type ());
    int mask =  OS.G_SIGNAL_MATCH_DATA | OS.G_SIGNAL_MATCH_ID;
    OS.g_signal_handlers_unblock_matched (imContext, mask, id, 0, null, null, cast(void*)handle);
    if (newChars is chars) {
        OS.g_signal_emit_by_name1 (imContext, OS.commit.ptr, cast(int)text);
    } else {
        OS.g_signal_emit_by_name1 (imContext, OS.commit.ptr, cast(int)toStringz(newChars));
    }
    OS.g_signal_handlers_unblock_matched (imContext, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCOMMIT);
    OS.g_signal_handlers_block_matched (imContext, mask, id, 0, null, null, cast(void*)handle);
    if (fixStart !is -1 && fixEnd !is -1) {
        OS.gtk_editable_set_position (cast(GtkEditable*)handle, fixStart);
        OS.gtk_editable_select_region (cast(GtkEditable*)handle, fixStart, fixEnd);
    }
    fixStart = fixEnd = -1;
    return 0;
}

override int gtk_delete_text (GtkWidget* widget, ptrdiff_t start_pos, ptrdiff_t end_pos) {
    if (!hooks (SWT.Verify) && !filters (SWT.Verify)) return 0;
    String newText = verifyText ("", cast(int)/*64bit*/start_pos, cast(int)/*64bit*/end_pos);
    if (newText is null) {
        OS.g_signal_stop_emission_by_name (handle, OS.delete_text.ptr);
    } else {
        if (newText.length > 0) {
            int pos;
            pos = cast(int)/*64bit*/end_pos;
            OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
            OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udINSERT_TEXT);
            OS.gtk_editable_insert_text (cast(GtkEditable*)handle, newText.ptr, cast(int)/*64bit*/newText.length, &pos);
            OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udINSERT_TEXT);
            OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
            OS.gtk_editable_set_position (cast(GtkEditable*)handle, pos);
        }
    }
    return 0;
}

override int gtk_event_after (GtkWidget* widget, GdkEvent* gdkEvent) {
    if (cursor !is null) gtk_setCursor (cursor.handle);
    return super.gtk_event_after (widget, gdkEvent);
}

override int gtk_focus_out_event (GtkWidget* widget, GdkEventFocus* event) {
    fixIM ();
    return super.gtk_focus_out_event (widget, event);
}

override int gtk_insert_text (GtkEditable* widget, char* new_text, ptrdiff_t new_text_length, ptrdiff_t position) {
//  if (!hooks (SWT.Verify) && !filters (SWT.Verify)) return 0;
    if (new_text is null || new_text_length is 0) return 0;
    String oldText = new_text[ 0 .. new_text_length ]._idup();
    int pos;
    pos = *(cast(int*)position);
    if (pos is -1) {
        auto ptr = OS.gtk_entry_get_text (cast(GtkEntry*)handle);
        pos = cast(int)/*64bit*/OS.g_utf8_strlen (ptr, -1);
    }
    String newText = verifyText (oldText, pos, pos);
    if (newText !is oldText) {
        int newStart, newEnd;
        OS.gtk_editable_get_selection_bounds (cast(GtkEditable*)handle, &newStart, &newEnd);
        if (newText !is null) {
            if (newStart !is newEnd) {
                OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udDELETE_TEXT);
                OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
                OS.gtk_editable_delete_selection (cast(GtkEditable*)handle);
                OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udDELETE_TEXT);
                OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
            }
            OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udINSERT_TEXT);
            OS.gtk_editable_insert_text (cast(GtkEditable*)handle, newText.ptr, cast(int)/*64bit*/newText.length, &pos);
            OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udINSERT_TEXT);
            newStart = newEnd = pos;
        }
        pos = newEnd;
        if (newStart !is newEnd ) {
            fixStart = newStart ;
            fixEnd = newEnd ;
        }
        *(cast(int*)position) = pos;
        OS.g_signal_stop_emission_by_name (handle, OS.insert_text.ptr);
    }
    return 0;
}

override int gtk_key_press_event (GtkWidget* widget, GdkEventKey* event) {
    auto result = super.gtk_key_press_event (widget, event);
    if (result !is 0) fixIM ();
    if (gdkEventKey is cast(GdkEventKey*)-1) result = 1;
    gdkEventKey = null;
    return result;
}

override int gtk_populate_popup (GtkWidget* widget, GtkWidget* menu) {
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        OS.gtk_widget_set_direction (menu, OS.GTK_TEXT_DIR_RTL);
        display.doSetDirectionProc( menu, OS.GTK_TEXT_DIR_RTL);
    }
    return 0;
}

override int gtk_value_changed (int  adjustment) {
    postEvent (SWT.Selection);
    return 0;
}

override void hookEvents () {
    super.hookEvents();
    OS.g_signal_connect_closure (handle, OS.changed.ptr, display.closures [CHANGED], true);
    OS.g_signal_connect_closure (handle, OS.insert_text.ptr, display.closures [INSERT_TEXT], false);
    OS.g_signal_connect_closure (handle, OS.delete_text.ptr, display.closures [DELETE_TEXT], false);
    OS.g_signal_connect_closure (handle, OS.value_changed.ptr, display.closures [VALUE_CHANGED], false);
    OS.g_signal_connect_closure (handle, OS.activate.ptr, display.closures [ACTIVATE], false);
    OS.g_signal_connect_closure (handle, OS.populate_popup.ptr, display.closures [POPULATE_POPUP], false);
    auto imContext = imContext ();
    if (imContext !is null) {
        OS.g_signal_connect_closure (imContext, OS.commit.ptr, display.closures [COMMIT], false);
        int id = OS.g_signal_lookup (OS.commit.ptr, OS.gtk_im_context_get_type ());
        int mask =  OS.G_SIGNAL_MATCH_DATA | OS.G_SIGNAL_MATCH_ID;
        OS.g_signal_handlers_block_matched (imContext, mask, id, 0, null, null, cast(void*)handle);
    }
}

GtkIMContext* imContext () {
    return OS.GTK_ENTRY_IM_CONTEXT (cast(GtkEntry*)handle);
}

override GdkDrawable* paintWindow () {
    auto window = super.paintWindow ();
    auto children = OS.gdk_window_get_children (window);
    if (children !is null) window = cast(GdkDrawable*)OS.g_list_data (children);
    OS.g_list_free (children);
    return window;
}

/**
 * Pastes text from clipboard.
 * <p>
 * The selected text is deleted from the widget
 * and new text inserted from the clipboard.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void paste () {
    checkWidget ();
    OS.gtk_editable_paste_clipboard (cast(GtkEditable*)handle);
}

override void register () {
    super.register ();
    auto imContext = imContext ();
    if (imContext !is null) display.addWidget (cast(GtkWidget*)imContext, this);
}

override void releaseWidget () {
    super.releaseWidget ();
    fixIM ();
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the receiver's text is modified.
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
 * @see ModifyListener
 * @see #addModifyListener
 */
public void removeModifyListener (ModifyListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Modify, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control is selected by the user.
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
public void removeSelectionListener(SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook(SWT.Selection, listener);
    eventTable.unhook(SWT.DefaultSelection,listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control is verified.
 *
 * @param listener the listener which should be notified
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the listener is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see VerifyListener
 * @see #addVerifyListener
 */
void removeVerifyListener (VerifyListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Verify, listener);
}

override void setBackgroundColor (GdkColor* color) {
    super.setBackgroundColor (color);
    OS.gtk_widget_modify_base (handle, 0, color);
}

override void gtk_setCursor (GdkCursor* cursor) {
    GdkCursor* defaultCursor;
    if (cursor is null) defaultCursor = OS.gdk_cursor_new (OS.GDK_XTERM);
    super.gtk_setCursor (cursor !is null ? cursor : defaultCursor);
    if (cursor is null) OS.gdk_cursor_destroy (defaultCursor);
}

override void setFontDescription (PangoFontDescription* font) {
    super.setFontDescription (font);
}

/**
 * Sets the amount that the receiver's value will be
 * modified by when the up/down arrows are pressed to
 * the argument, which must be at least one.
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
    auto adjustment = OS.gtk_spin_button_get_adjustment (cast(GtkSpinButton*)handle);
    double newValue = value;
    int digits = OS.gtk_spin_button_get_digits (cast(GtkSpinButton*)handle);
    for (int i = 0; i < digits; i++) newValue /= 10;
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
    OS.gtk_spin_button_set_increments (cast(GtkSpinButton*)handle, newValue, adjustment.page_increment);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
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
    auto adjustment = OS.gtk_spin_button_get_adjustment (cast(GtkSpinButton*)handle);
    double newValue = value;
    int digits = OS.gtk_spin_button_get_digits (cast(GtkSpinButton*)handle);
    for (int i = 0; i < digits; i++) newValue /= 10;
    if (newValue <= adjustment.lower) return;
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
    OS.gtk_spin_button_set_range (cast(GtkSpinButton*)handle, adjustment.lower, newValue);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
}

/**
 * Sets the minimum value that the receiver will allow.  This new
 * value will be ignored if it is not less than the receiver's
 * current maximum value.  If the new minimum is applied then the receiver's
 * selection value will be adjusted if necessary to fall within its new range.
 *
 * @param value the new minimum, which must be less than the current maximum
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMinimum (int value) {
    checkWidget ();
    auto adjustment = OS.gtk_spin_button_get_adjustment (cast(GtkSpinButton*)handle);
    double newValue = value;
    int digits = OS.gtk_spin_button_get_digits (cast(GtkSpinButton*)handle);
    for (int i = 0; i < digits; i++) newValue /= 10;
    if (newValue >= adjustment.upper) return;
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
    OS.gtk_spin_button_set_range (cast(GtkSpinButton*)handle, newValue, adjustment.upper);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
}

/**
 * Sets the amount that the receiver's position will be
 * modified by when the page up/down keys are pressed
 * to the argument, which must be at least one.
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
    auto adjustment = OS.gtk_spin_button_get_adjustment (cast(GtkSpinButton*)handle);
    double newValue = value;
    int digits = OS.gtk_spin_button_get_digits (cast(GtkSpinButton*)handle);
    for (int i = 0; i < digits; i++) newValue /= 10;
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
    OS.gtk_spin_button_set_increments (cast(GtkSpinButton*)handle, adjustment.step_increment, newValue);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
}

/**
 * Sets the <em>selection</em>, which is the receiver's
 * position, to the argument. If the argument is not within
 * the range specified by minimum and maximum, it will be
 * adjusted to fall within this range.
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
    double newValue = value;
    int digits = OS.gtk_spin_button_get_digits (cast(GtkSpinButton*)handle);
    for (int i = 0; i < digits; i++) newValue /= 10;
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
    OS.gtk_spin_button_set_value (cast(GtkSpinButton*)handle, newValue);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
}

/**
 * Sets the maximum number of characters that the receiver's
 * text field is capable of holding to be the argument.
 * <p>
 * To reset this value to the default, use <code>setTextLimit(Spinner.LIMIT)</code>.
 * Specifying a limit value larger than <code>Spinner.LIMIT</code> sets the
 * receiver's limit to <code>Spinner.LIMIT</code>.
 * </p>
 * @param limit new text limit
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_CANNOT_BE_ZERO - if the limit is zero</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @see #LIMIT
 * 
 * @since 3.4
 */
public void setTextLimit (int limit) {
    checkWidget ();
    if (limit is 0) error (SWT.ERROR_CANNOT_BE_ZERO);
    OS.gtk_entry_set_max_length (handle, limit);
}

/**
 * Sets the number of decimal places used by the receiver.
 * <p>
 * The digit setting is used to allow for floating point values in the receiver.
 * For example, to set the selection to a floating point value of 1.37 call setDigits() with
 * a value of 2 and setSelection() with a value of 137. Similarly, if getDigits() has a value
 * of 2 and getSelection() returns 137 this should be interpreted as 1.37. This applies to all
 * numeric APIs.
 * </p>
 *
 * @param value the new digits (must be greater than or equal to zero)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the value is less than zero</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setDigits (int value) {
    checkWidget ();
    if (value < 0) error (SWT.ERROR_INVALID_ARGUMENT);
    int digits = OS.gtk_spin_button_get_digits (cast(GtkSpinButton*)handle);
    if (value is digits) return;
    auto adjustment = OS.gtk_spin_button_get_adjustment (cast(GtkSpinButton*)handle);
    int diff = Math.abs (value - digits);
    int factor = 1;
    for (int i = 0; i < diff; i++) factor *= 10;
    if (digits > value) {
        adjustment.value *= factor;
        adjustment.upper *= factor;
        adjustment.lower *= factor;
        adjustment.step_increment *= factor;
        adjustment.page_increment *= factor;
    } else {
        adjustment.value /= factor;
        adjustment.upper /= factor;
        adjustment.lower /= factor;
        adjustment.step_increment /= factor;
        adjustment.page_increment /= factor;
    }
    OS.gtk_spin_button_set_digits (cast(GtkSpinButton*)handle, value);
}

/**
 * Sets the receiver's selection, minimum value, maximum
 * value, digits, increment and page increment all at once.
 * <p>
 * Note: This is similar to setting the values individually
 * using the appropriate methods, but may be implemented in a
 * more efficient fashion on some platforms.
 * </p>
 *
 * @param selection the new selection value
 * @param minimum the new minimum value
 * @param maximum the new maximum value
 * @param digits the new digits value
 * @param increment the new increment value
 * @param pageIncrement the new pageIncrement value
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setValues (int selection, int minimum, int maximum, int digits, int increment, int pageIncrement) {
    checkWidget ();
    if (maximum <= minimum) return;
    if (digits < 0) return;
    if (increment < 1) return;
    if (pageIncrement < 1) return;
    selection = Math.min (Math.max (minimum, selection), maximum);
    double factor = 1;
    for (int i = 0; i < digits; i++) factor *= 10;
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
    OS.gtk_spin_button_set_range (cast(GtkSpinButton*)handle, minimum / factor, maximum / factor);
    OS.gtk_spin_button_set_increments (cast(GtkSpinButton*)handle, increment / factor, pageIncrement / factor);
    OS.gtk_spin_button_set_value (cast(GtkSpinButton*)handle, selection / factor);
    OS.gtk_spin_button_set_digits (cast(GtkSpinButton*)handle, digits);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udVALUE_CHANGED);
}

override bool translateTraversal (GdkEventKey* keyEvent) {
    int key = keyEvent.keyval;
    GtkIMContext* imContext = null;
    switch (key) {
        case OS.GDK_KP_Enter:
        case OS.GDK_Return: {
            imContext =  this.imContext ();
            if (imContext !is null) {
                char* preeditString;
                OS.gtk_im_context_get_preedit_string (imContext, &preeditString, null, null);
                if (preeditString !is null) {
                    int length = OS.strlen (preeditString);
                    OS.g_free (preeditString);
                    if (length !is 0) return false;
                }
            }
        default:
        }
    }
    return super.translateTraversal (keyEvent);
}

String verifyText (String string, int start, int end) {
    if (string.length is 0 && start is end) return null;
    Event event = new Event ();
    event.text = string;
    event.start = start;
    event.end = end;
    auto eventPtr = OS.gtk_get_current_event ();
    if (eventPtr !is null) {
        GdkEventKey* gdkEvent = cast(GdkEventKey*)eventPtr;
        switch (gdkEvent.type) {
            case OS.GDK_KEY_PRESS:
                setKeyState (event, gdkEvent);
                break;
            default:
        }
        OS.gdk_event_free (eventPtr);
    }
    int index = 0;
    if (OS.gtk_spin_button_get_digits (cast(GtkSpinButton*)handle) > 0) {
        String decimalSeparator = getDecimalSeparator ();
        index = string.indexOf( decimalSeparator );
        if (index !is -1 ) {
            string = string.substring( 0, index ) ~ string.substring( index + 1 );
        }
        index = 0;
    }
    if (string.length  > 0) {
        auto adjustment = OS.gtk_spin_button_get_adjustment (handle);
        if (adjustment.lower < 0 && string.charAt (0) is '-') index++;
    }
    while (index < string.length) {
        if (!CharacterIsDigit (string.charAt(index))) break;
        index++;
    }
    event.doit = index is string.length;
    /*
     * It is possible (but unlikely), that application
     * code could have disposed the widget in the verify
     * event.  If this happens, answer null to cancel
     * the operation.
     */
    sendEvent (SWT.Verify, event);
    if (!event.doit || isDisposed ()) return null;
    return event.text;
}

}
