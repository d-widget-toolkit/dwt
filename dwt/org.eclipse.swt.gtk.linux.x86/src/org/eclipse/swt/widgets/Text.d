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
module org.eclipse.swt.widgets.Text;

import java.lang.all;


import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.VerifyListener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Scrollable;
import org.eclipse.swt.widgets.Composite;

version(Tango){
static import tango.stdc.string;
} else { // Phobos
}

/**
 * Instances of this class are selectable user interface
 * objects that allow the user to enter and modify text.
 * Text controls can be either single or multi-line.
 * When a text control is created with a border, the
 * operating system includes a platform specific inset
 * around the contents of the control.  When created
 * without a border, an effort is made to remove the
 * inset such that the preferred size of the control
 * is the same size as the contents.
 * <p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>CANCEL, CENTER, LEFT, MULTI, PASSWORD, SEARCH, SINGLE, RIGHT, READ_ONLY, WRAP</dd>
 * <dt><b>Events:</b></dt>
 * <dd>DefaultSelection, Modify, Verify</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles MULTI and SINGLE may be specified,
 * and only one of the styles LEFT, CENTER, and RIGHT may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#text">Text snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Text : Scrollable {

    alias Scrollable.computeSize computeSize;
    alias Scrollable.dragDetect dragDetect;
    alias Scrollable.setBackgroundColor setBackgroundColor;
    alias Scrollable.setCursor setCursor;
    alias Scrollable.setOrientation setOrientation;
    alias Scrollable.translateTraversal translateTraversal;

    GtkTextBuffer* bufferHandle;
    int tabs = 8, lastEventTime = 0;
    GdkEventKey* gdkEventKey;
    int fixStart = -1, fixEnd = -1;
    bool doubleClick;
    String message = "";

    static const int INNER_BORDER = 2;
    //static const int ITER_SIZEOF = GtkTextIter.sizeof;

    /**
    * The maximum number of characters that can be entered
    * into a text widget.
    * <p>
    * Note that this value is platform dependent, based upon
    * the native widget implementation.
    * </p>
    */
    public const static int LIMIT = 0x7FFFFFFF;
    /**
    * The delimiter used by multi-line text widgets.  When text
    * is queried and from the widget, it will be delimited using
    * this delimiter.
    */
    public const static String DELIMITER = "\n";
    /*
    * These values can be different on different platforms.
    * Therefore they are not initialized in the declaration
    * to stop the compiler from inlining.
    */
    // <keinfarbton> avoid static ctor
    //static {
    //    LIMIT = 0x7FFFFFFF;
    //    DELIMITER = "\n";
    //}

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
 * @see SWT#SINGLE
 * @see SWT#MULTI
 * @see SWT#READ_ONLY
 * @see SWT#WRAP
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

static int checkStyle (int style) {
    if ((style & SWT.SEARCH) !is 0) {
        style |= SWT.SINGLE | SWT.BORDER;
        style &= ~SWT.PASSWORD;
    }
    style &= ~SWT.SEARCH;
    if ((style & SWT.SINGLE) !is 0 && (style & SWT.MULTI) !is 0) {
        style &= ~SWT.MULTI;
    }
    style = checkBits (style, SWT.LEFT, SWT.CENTER, SWT.RIGHT, 0, 0, 0);
    if ((style & SWT.SINGLE) !is 0) style &= ~(SWT.H_SCROLL | SWT.V_SCROLL | SWT.WRAP);
    if ((style & SWT.WRAP) !is 0) {
        style |= SWT.MULTI;
        style &= ~SWT.H_SCROLL;
    }
    if ((style & SWT.MULTI) !is 0) style &= ~SWT.PASSWORD;
    if ((style & (SWT.SINGLE | SWT.MULTI)) !is 0) return style;
    if ((style & (SWT.H_SCROLL | SWT.V_SCROLL)) !is 0) return style | SWT.MULTI;
    return style | SWT.SINGLE;
}

override void createHandle (int index) {
    state |= HANDLE | MENU;
    fixedHandle = cast(GtkWidget*) OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (fixedHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_fixed_set_has_window (cast(GtkFixed*)fixedHandle, true);
    if ((style & SWT.SINGLE) !is 0) {
        handle = OS.gtk_entry_new ();
        if (handle is null) error (SWT.ERROR_NO_HANDLES);
        OS.gtk_container_add (cast(GtkContainer*)fixedHandle, handle);
        OS.gtk_editable_set_editable (cast(GtkEditable*)handle, (style & SWT.READ_ONLY) is 0);
        OS.gtk_entry_set_has_frame (cast(GtkEntry*)handle, (style & SWT.BORDER) !is 0);
        OS.gtk_entry_set_visibility (cast(GtkEntry*)handle, (style & SWT.PASSWORD) is 0);
        float alignment = 0.0f;
        if ((style & SWT.CENTER) !is 0) alignment = 0.5f;
        if ((style & SWT.RIGHT) !is 0) alignment = 1.0f;
        if (alignment > 0.0f) {
            OS.gtk_entry_set_alignment (cast(GtkEntry*)handle, alignment);
        }
    } else {
        scrolledHandle = cast(GtkWidget*) OS.gtk_scrolled_window_new (null, null);
        if (scrolledHandle is null) error (SWT.ERROR_NO_HANDLES);
        handle = OS.gtk_text_view_new ();
        if (handle is null) error (SWT.ERROR_NO_HANDLES);
        bufferHandle = OS.gtk_text_view_get_buffer (cast(GtkTextView*)handle);
        if (bufferHandle is null) error (SWT.ERROR_NO_HANDLES);
        OS.gtk_container_add (cast(GtkContainer*)fixedHandle, scrolledHandle);
        OS.gtk_container_add (cast(GtkContainer*)scrolledHandle, handle);
        OS.gtk_text_view_set_editable (cast(GtkTextView*)handle, (style & SWT.READ_ONLY) is 0);
        if ((style & SWT.WRAP) !is 0) OS.gtk_text_view_set_wrap_mode (cast(GtkTextView*)handle, OS.GTK_WRAP_WORD_CHAR);
        int hsp = (style & SWT.H_SCROLL) !is 0 ? OS.GTK_POLICY_ALWAYS : OS.GTK_POLICY_NEVER;
        int vsp = (style & SWT.V_SCROLL) !is 0 ? OS.GTK_POLICY_ALWAYS : OS.GTK_POLICY_NEVER;
        OS.gtk_scrolled_window_set_policy (cast(GtkScrolledWindow*)scrolledHandle, hsp, vsp);
        if ((style & SWT.BORDER) !is 0) {
            OS.gtk_scrolled_window_set_shadow_type (cast(GtkScrolledWindow*)scrolledHandle, OS.GTK_SHADOW_ETCHED_IN);
        }
        int just = OS.GTK_JUSTIFY_LEFT;
        if ((style & SWT.CENTER) !is 0) just = OS.GTK_JUSTIFY_CENTER;
        if ((style & SWT.RIGHT) !is 0) just = OS.GTK_JUSTIFY_RIGHT;
        OS.gtk_text_view_set_justification (cast(GtkTextView*)handle, just);
    }
}

override void createWidget (int index) {
    super.createWidget (index);
    doubleClick = true;
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
 * <code>widgetDefaultSelected</code> is typically called when ENTER is pressed in a single-line text,
 * or when ENTER is pressed in a search text. If the receiver has the <code>SWT.SEARCH | SWT.CANCEL</code> style
 * and the user cancels the search, the event object detail field contains the value <code>SWT.CANCEL</code>.
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
public void addVerifyListener (VerifyListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Verify, typedListener);
}

/**
 * Appends a string.
 * <p>
 * The new text is appended to the text at
 * the end of the widget.
 * </p>
 *
 * @param string the string to be appended
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void append (String string) {
    checkWidget ();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if ((style & SWT.SINGLE) !is 0) {
        int dummy = -1;
        OS.gtk_editable_insert_text (cast(GtkEditable*)handle, string.ptr, cast(int)/*64bit*/string.length, &dummy );
        OS.gtk_editable_set_position (cast(GtkEditable*)handle, -1);
    } else {
        GtkTextIter position;
        OS.gtk_text_buffer_get_end_iter (bufferHandle, &position);
        OS.gtk_text_buffer_insert (bufferHandle, &position, string.ptr, cast(int)/*64bit*/string.length);
        OS.gtk_text_buffer_place_cursor (bufferHandle, &position);
        auto mark = OS.gtk_text_buffer_get_insert (bufferHandle);
        OS.gtk_text_view_scroll_mark_onscreen (cast(GtkTextView*)handle, mark);
    }
}

/**
 * Clears the selection.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void clearSelection () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        int position = OS.gtk_editable_get_position (cast(GtkEditable*)handle);
        OS.gtk_editable_select_region (cast(GtkEditable*)handle, position, position);
    } else {
        GtkTextIter position;
        auto insertMark = OS.gtk_text_buffer_get_insert (bufferHandle);
        auto selectionMark = OS.gtk_text_buffer_get_selection_bound (bufferHandle);
        OS.gtk_text_buffer_get_iter_at_mark (bufferHandle, &position, insertMark);
        OS.gtk_text_buffer_move_mark (bufferHandle, selectionMark, &position);
        OS.gtk_text_buffer_move_mark (bufferHandle, insertMark, &position);
    }
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    if (wHint !is SWT.DEFAULT && wHint < 0) wHint = 0;
    if (hHint !is SWT.DEFAULT && hHint < 0) hHint = 0;
    int w , h;
    if ((style & SWT.SINGLE) !is 0) {
        OS.gtk_widget_realize (handle);
        auto layout = OS.gtk_entry_get_layout (cast(GtkEntry*)handle);
        OS.pango_layout_get_size (layout, &w, &h);
    } else {
        GtkTextIter start;
        GtkTextIter end;
        OS.gtk_text_buffer_get_bounds (bufferHandle, &start, &end);
        auto text = OS.gtk_text_buffer_get_text (bufferHandle, &start, &end, true);
        auto layout = OS.gtk_widget_create_pango_layout (handle, text);
        OS.g_free (text);
        OS.pango_layout_set_width (layout, wHint * OS.PANGO_SCALE);
        OS.pango_layout_get_size (layout, &w, &h);
        OS.g_object_unref (layout);
    }
    int width = OS.PANGO_PIXELS (w);
    int height = OS.PANGO_PIXELS (h);
    //This code is intentionally commented
//  if ((style & SWT.SEARCH) !is 0 && message.length () !is 0) {
//      GC gc = new GC (this);
//      Point size = gc.stringExtent (message);
//      width = Math.max (width, size.x);
//      gc.dispose ();
//  }
    if (width is 0) width = DEFAULT_WIDTH;
    if (height is 0) height = DEFAULT_HEIGHT;
    width = wHint is SWT.DEFAULT ? width : wHint;
    height = hHint is SWT.DEFAULT ? height : hHint;
    Rectangle trim = computeTrim (0, 0, width, height);
    return new Point (trim.width, trim.height);
}

override public Rectangle computeTrim (int x, int y, int width, int height) {
    checkWidget ();
    Rectangle trim = super.computeTrim (x, y, width, height);
    int xborder = 0, yborder = 0;
    if ((style & SWT.SINGLE) !is 0) {
        if ((style & SWT.BORDER) !is 0) {
            auto style = OS.gtk_widget_get_style (handle);
            xborder += OS.gtk_style_get_xthickness (style);
            yborder += OS.gtk_style_get_ythickness (style);
        }
        xborder += INNER_BORDER;
        yborder += INNER_BORDER;
    } else {
        int borderWidth = OS.gtk_container_get_border_width (cast(GtkContainer*)handle);
        xborder += borderWidth;
        yborder += borderWidth;
    }
    int property;
    OS.gtk_widget_style_get1 (handle, OS.interior_focus.ptr, &property);
    if (property is 0) {
        OS.gtk_widget_style_get1 (handle, OS.focus_line_width.ptr, &property);
        xborder += property;
        yborder += property;
    }
    trim.x -= xborder;
    trim.y -= yborder;
    trim.width += 2 * xborder;
    trim.height += 2 * yborder;
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
    if ((style & SWT.SINGLE) !is 0) {
        OS.gtk_editable_copy_clipboard (cast(GtkEditable*)handle);
    } else {
        auto clipboard = OS.gtk_clipboard_get (cast(void*)OS.GDK_NONE);
        OS.gtk_text_buffer_copy_clipboard (bufferHandle, clipboard);
    }
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
    if ((style & SWT.SINGLE) !is 0) {
        OS.gtk_editable_cut_clipboard (cast(GtkEditable*)handle);
    } else {
        auto clipboard = OS.gtk_clipboard_get (cast(void*)OS.GDK_NONE);
        OS.gtk_text_buffer_cut_clipboard (bufferHandle, clipboard, OS.gtk_text_view_get_editable (cast(GtkTextView*)handle));
    }
}

override void deregister () {
    super.deregister ();
    if (bufferHandle !is null) display.removeWidget (cast(GtkWidget*)bufferHandle);
    auto imContext = imContext ();
    if (imContext !is null) display.removeWidget (cast(GtkWidget*)imContext);
}

override bool dragDetect (int x, int y, bool filter, bool* consume) {
    if (filter) {
        int start = 0, end = 0;
        if ((style & SWT.SINGLE) !is 0) {
            int s, e;
            OS.gtk_editable_get_selection_bounds (cast(GtkEditable*)handle, &s, &e);
            start = s;
            end = e;
        } else {
            GtkTextIter s;
            GtkTextIter e;
            OS.gtk_text_buffer_get_selection_bounds (bufferHandle, &s, &e);
            start = OS.gtk_text_iter_get_offset (&s);
            end = OS.gtk_text_iter_get_offset (&e);
        }
        if (start !is end) {
            if (end < start) {
                int temp = end;
                end = start;
                start = temp;
            }
            ptrdiff_t position = -1;
            if ((style & SWT.SINGLE) !is 0) {
                int index;
                int trailing;
                auto layout = OS.gtk_entry_get_layout (cast(GtkEntry*)handle);
                OS.pango_layout_xy_to_index (layout, x * OS.PANGO_SCALE, y * OS.PANGO_SCALE, &index, &trailing);
                auto ptr = OS.pango_layout_get_text (layout);
                position = OS.g_utf8_pointer_to_offset (ptr, ptr + index) + trailing;
            } else {
                GtkTextIter p;
                OS.gtk_text_view_get_iter_at_location (cast(GtkTextView*)handle, &p, x, y);
                position = OS.gtk_text_iter_get_offset (&p);
            }
            if (start <= position && position < end) {
                if (super.dragDetect (x, y, filter, consume)) {
                    if (consume !is null) consume [0] = true;
                    return true;
                }
            }
        }
        return false;
    }
    return super.dragDetect (x, y, filter, consume);
}

override GdkDrawable* eventWindow () {
    return paintWindow ();
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
    if ((style & SWT.MULTI) !is 0) return super.getBorderWidth ();
    auto style = OS.gtk_widget_get_style (handle);
    if ((this.style & SWT.BORDER) !is 0) {
         return OS.gtk_style_get_xthickness (style);
    }
    return 0;
}

/**
 * Returns the line number of the caret.
 * <p>
 * The line number of the caret is returned.
 * </p>
 *
 * @return the line number
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getCaretLineNumber () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) return 1;
    GtkTextIter position;
    auto mark = OS.gtk_text_buffer_get_insert (bufferHandle);
    OS.gtk_text_buffer_get_iter_at_mark (bufferHandle, &position, mark);
    return OS.gtk_text_iter_get_line (&position);
}

/**
 * Returns a point describing the receiver's location relative
 * to its parent (or its display if its parent is null).
 * <p>
 * The location of the caret is returned.
 * </p>
 *
 * @return a point, the location of the caret
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getCaretLocation () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        int index = OS.gtk_editable_get_position (cast(GtkEditable*)handle);
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 6, 0)) {
            index = OS.gtk_entry_text_index_to_layout_index (cast(GtkEntry*)handle, index);
        }
        int offset_x, offset_y;
        OS.gtk_entry_get_layout_offsets (cast(GtkEntry*)handle, &offset_x, &offset_y);
        auto layout = OS.gtk_entry_get_layout (cast(GtkEntry*)handle);
        PangoRectangle pos;
        OS.pango_layout_index_to_pos (layout, index, &pos);
        int x = offset_x + OS.PANGO_PIXELS (pos.x) - getBorderWidth ();
        int y = offset_y + OS.PANGO_PIXELS (pos.y);
        return new Point (x, y);
    }
    GtkTextIter position;
    auto mark = OS.gtk_text_buffer_get_insert (bufferHandle);
    OS.gtk_text_buffer_get_iter_at_mark (bufferHandle, &position, mark);
    GdkRectangle rect;
    OS.gtk_text_view_get_iter_location (cast(GtkTextView*)handle, &position, &rect);
    int x;
    int y;
    OS.gtk_text_view_buffer_to_window_coords (cast(GtkTextView*)handle, OS.GTK_TEXT_WINDOW_TEXT, rect.x, rect.y, &x, &y);
    return new Point (x, y);
}

/**
 * Returns the character position of the caret.
 * <p>
 * Indexing is zero based.
 * </p>
 *
 * @return the position of the caret
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getCaretPosition () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0)  {
        return OS.gtk_editable_get_position (cast(GtkEditable*)handle);
    }
    GtkTextIter position;
    auto mark = OS.gtk_text_buffer_get_insert (bufferHandle);
    OS.gtk_text_buffer_get_iter_at_mark (bufferHandle, &position, mark);
    return OS.gtk_text_iter_get_offset (&position);
}

/**
 * Returns the number of characters.
 *
 * @return number of characters in the widget
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getCharCount () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        auto ptr = OS.gtk_entry_get_text (cast(GtkEntry*)handle);
        return cast(int)/*64bit*/OS.g_utf8_strlen (ptr, -1);
    }
    return OS.gtk_text_buffer_get_char_count (bufferHandle);
}

/**
 * Returns the double click enabled flag.
 * <p>
 * The double click flag enables or disables the
 * default action of the text widget when the user
 * double clicks.
 * </p>
 *
 * @return whether or not double click is enabled
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getDoubleClickEnabled () {
    checkWidget ();
    return doubleClick;
}

/**
 * Returns the echo character.
 * <p>
 * The echo character is the character that is
 * displayed when the user enters text or the
 * text is changed by the programmer.
 * </p>
 *
 * @return the echo character
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setEchoChar
 */
public char getEchoChar () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        if (!OS.gtk_entry_get_visibility (cast(GtkEntry*)handle)) {
            return cast(char) OS.gtk_entry_get_invisible_char (cast(GtkEntry*)handle);
        }
    }
    return '\0';
}

/**
 * Returns the editable state.
 *
 * @return whether or not the receiver is editable
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getEditable () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        return cast(bool)OS.gtk_editable_get_editable (cast(GtkEditable*)handle);
    }
    return cast(bool)OS.gtk_text_view_get_editable (cast(GtkTextView*)handle);
}

override GdkColor* getForegroundColor () {
    return getTextColor ();
}

/**
 * Returns the number of lines.
 *
 * @return the number of lines in the widget
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getLineCount () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) return 1;
    return OS.gtk_text_buffer_get_line_count (bufferHandle);
}

/**
 * Returns the line delimiter.
 *
 * @return a string that is the line delimiter
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #DELIMITER
 */
public String getLineDelimiter () {
    checkWidget ();
    return "\n";
}

/**
 * Returns the height of a line.
 *
 * @return the height of a row of text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getLineHeight () {
    checkWidget ();
    return fontHeight (getFontDescription (), handle);
}

/**
 * Returns the widget message. When the widget is created
 * with the style <code>SWT.SEARCH</code>, the message text
 * is displayed as a hint for the user, indicating the
 * purpose of the field.
 * <p>
 * Note: This operation is a <em>HINT</em> and is not
 * supported on platforms that do not have this concept.
 * </p>
 *
 * @return the widget message
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.3
 */
public String getMessage () {
    checkWidget ();
    return message;
}

/**
 * Returns the orientation of the receiver, which will be one of the
 * constants <code>SWT.LEFT_TO_RIGHT</code> or <code>SWT.RIGHT_TO_LEFT</code>.
 *
 * @return the orientation style
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1.2
 */
public int getOrientation () {
    checkWidget();
    return style & (SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT);
}

/*public*/ int getPosition (Point point) {
    checkWidget ();
    if (point is null) error (SWT.ERROR_NULL_ARGUMENT);
    ptrdiff_t position = -1;
    if ((style & SWT.SINGLE) !is 0) {
        int index;
        int trailing;
        auto layout = OS.gtk_entry_get_layout (cast(GtkEntry*)handle);
        OS.pango_layout_xy_to_index (layout, point.x * OS.PANGO_SCALE, point.y * OS.PANGO_SCALE, &index, &trailing);
        auto ptr = OS.pango_layout_get_text (layout);
        position = OS.g_utf8_pointer_to_offset (ptr, ptr + index) + trailing;
    } else {
        GtkTextIter p;
        OS.gtk_text_view_get_iter_at_location (cast(GtkTextView*)handle, &p, point.x, point.y);
        position = OS.gtk_text_iter_get_offset (&p);
    }
    return cast(int)/*64bit*/position;
}

/**
 * Returns a <code>Point</code> whose x coordinate is the
 * character position representing the start of the selected
 * text, and whose y coordinate is the character position
 * representing the end of the selection. An "empty" selection
 * is indicated by the x and y coordinates having the same value.
 * <p>
 * Indexing is zero based.  The range of a selection is from
 * 0..N where N is the number of characters in the widget.
 * </p>
 *
 * @return a point representing the selection start and end
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getSelection () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        int start;
        int end;
        OS.gtk_editable_get_selection_bounds (cast(GtkEditable*)handle, &start, &end);
        return new Point (start, end);
    }
    GtkTextIter start;
    GtkTextIter end;
    OS.gtk_text_buffer_get_selection_bounds (bufferHandle, &start, &end);
    return new Point (OS.gtk_text_iter_get_offset (&start), OS.gtk_text_iter_get_offset (&end));
}

/**
 * Returns the number of selected characters.
 *
 * @return the number of selected characters.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSelectionCount () {
    checkWidget ();
    Point selection = getSelection ();
    return Math.abs (selection.y - selection.x);
}

/**
 * Gets the selected text, or an empty string if there is no current selection.
 *
 * @return the selected text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getSelectionText () {
    checkWidget ();
    Point selection = getSelection ();
    return getText ()[ selection.x .. selection.y ];
}

/**
 * Returns the number of tabs.
 * <p>
 * Tab stop spacing is specified in terms of the
 * space (' ') character.  The width of a single
 * tab stop is the pixel width of the spaces.
 * </p>
 *
 * @return the number of tab characters
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getTabs () {
    checkWidget ();
    return tabs;
}

int getTabWidth (int tabs) {
    auto layout = OS.gtk_widget_create_pango_layout (handle, " ".ptr );
    int width;
    int height;
    OS.pango_layout_get_size (layout, &width, &height);
    OS.g_object_unref (layout);
    return width * tabs;
}

/**
 * Returns the widget text.
 * <p>
 * The text for a text widget is the characters in the widget, or
 * an empty string if this has never been set.
 * </p>
 *
 * @return the widget text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText () {
    checkWidget ();
    char* address;
    if ((style & SWT.SINGLE) !is 0) {
        address = OS.gtk_entry_get_text (cast(GtkEntry*)handle);
    } else {
        GtkTextIter start;
        GtkTextIter end;
        OS.gtk_text_buffer_get_bounds (bufferHandle, &start, &end);
        address = OS.gtk_text_buffer_get_text (bufferHandle, &start, &end, true);
    }
    if (address is null) return "";
    String res = fromStringz( address )._idup();
    if ((style & SWT.MULTI) !is 0) OS.g_free (address);
    return res;
}

/**
 * Returns a range of text.  Returns an empty string if the
 * start of the range is greater than the end.
 * <p>
 * Indexing is zero based.  The range of
 * a selection is from 0..N-1 where N is
 * the number of characters in the widget.
 * </p>
 *
 * @param start the start of the range
 * @param end the end of the range
 * @return the range of text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText (int start, int end) {
    checkWidget ();
    if (!(start <= end && 0 <= end)) return "";
    start = Math.max (0, start);
    char* address;
    if ((style & SWT.SINGLE) !is 0) {
        address = OS.gtk_editable_get_chars (cast(GtkEditable*)handle, start, end + 1);
    } else {
        int length = OS.gtk_text_buffer_get_char_count (bufferHandle);
        end = Math.min (end, length - 1);
        GtkTextIter startIter;
        GtkTextIter endIter;
        OS.gtk_text_buffer_get_iter_at_offset (bufferHandle, &startIter, start);
        OS.gtk_text_buffer_get_iter_at_offset (bufferHandle, &endIter, end + 1);
        address = OS.gtk_text_buffer_get_text (bufferHandle, &startIter, &endIter, true);
    }
    if (address is null) error (SWT.ERROR_CANNOT_GET_TEXT);
    String res = fromStringz( address )._idup();
    OS.g_free (address);
    return res;
}

/**
 * Returns the maximum number of characters that the receiver is capable of holding.
 * <p>
 * If this has not been changed by <code>setTextLimit()</code>,
 * it will be the constant <code>Text.LIMIT</code>.
 * </p>
 *
 * @return the text limit
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #LIMIT
 */
public int getTextLimit () {
    checkWidget ();
    if ((style & SWT.MULTI) !is 0) return LIMIT;
    int limit = OS.gtk_entry_get_max_length (cast(GtkEntry*)handle);
    return limit is 0 ? 0xFFFF : limit;
}

/**
 * Returns the zero-relative index of the line which is currently
 * at the top of the receiver.
 * <p>
 * This index can change when lines are scrolled or new lines are added or removed.
 * </p>
 *
 * @return the index of the top line
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getTopIndex () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) return 0;
    GtkTextIter position;
    GdkRectangle rect;
    OS.gtk_text_view_get_visible_rect (cast(GtkTextView*)handle, &rect);
    OS.gtk_text_view_get_line_at_y (cast(GtkTextView*)handle, &position, rect.y, null);
    return OS.gtk_text_iter_get_line (&position);
}

/**
 * Returns the top pixel.
 * <p>
 * The top pixel is the pixel position of the line
 * that is currently at the top of the widget.  On
 * some platforms, a text widget can be scrolled by
 * pixels instead of lines so that a partial line
 * is displayed at the top of the widget.
 * </p><p>
 * The top pixel changes when the widget is scrolled.
 * The top pixel does not include the widget trimming.
 * </p>
 *
 * @return the pixel position of the top line
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getTopPixel () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) return 0;
    GtkTextIter position;
    GdkRectangle rect;
    OS.gtk_text_view_get_visible_rect (cast(GtkTextView*)handle, &rect);
    int lineTop;
    OS.gtk_text_view_get_line_at_y (cast(GtkTextView*)handle, &position, rect.y, &lineTop);
    return lineTop;
}

override int gtk_activate (GtkWidget* widget) {
    postEvent (SWT.DefaultSelection);
    return 0;
}

override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* gdkEvent) {
    auto result = super.gtk_button_press_event (widget, gdkEvent);
    if (result !is 0) return result;
    if (!doubleClick) {
        switch (gdkEvent.type) {
            case OS.GDK_2BUTTON_PRESS:
            case OS.GDK_3BUTTON_PRESS:
                return 1;
            default:
        }
    }
    return result;
}


override int gtk_changed (GtkWidget* widget) {
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

override int gtk_commit (GtkIMContext* imcontext, char* text) {
    if (text is null) return 0;
    if ((style & SWT.SINGLE) !is 0) {
        if (!OS.gtk_editable_get_editable (cast(GtkEditable*)handle)) return 0;
    }
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
        OS.g_signal_emit_by_name1 (imContext, OS.commit.ptr, cast(int)toStringz(newChars) );
    }
    OS.g_signal_handlers_unblock_matched (imContext, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCOMMIT );
    OS.g_signal_handlers_block_matched (imContext, mask, id, 0, null, null, cast(void*)handle);
    if ((style & SWT.SINGLE) !is 0) {
        if (fixStart !is -1 && fixEnd !is -1) {
            OS.gtk_editable_set_position (cast(GtkEditable*)handle, fixStart);
            OS.gtk_editable_select_region (cast(GtkEditable*)handle, fixStart, fixEnd);
        }
    }
    fixStart = fixEnd = -1;
    return 0;
}

override int gtk_delete_range (GtkWidget* widget, ptrdiff_t iter1, ptrdiff_t iter2) {
    if (!hooks (SWT.Verify) && !filters (SWT.Verify)) return 0;
    GtkTextIter startIter = *cast(GtkTextIter*)iter1;
    GtkTextIter endIter = *cast(GtkTextIter*)iter2;
    int start = OS.gtk_text_iter_get_offset (&startIter);
    int end = OS.gtk_text_iter_get_offset (&endIter);
    String newText = verifyText ("", start, end);
    if (newText is null) {
        /* Remember the selection when the text was deleted */
        OS.gtk_text_buffer_get_selection_bounds (bufferHandle, &startIter, &endIter);
        start = OS.gtk_text_iter_get_offset (&startIter);
        end = OS.gtk_text_iter_get_offset (&endIter);
        if (start !is end) {
            fixStart = start;
            fixEnd = end;
        }
        OS.g_signal_stop_emission_by_name (bufferHandle, OS.delete_range.ptr);
    } else {
        if (newText.length > 0) {
            OS.g_signal_handlers_block_matched (bufferHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
            OS.g_signal_handlers_block_matched (bufferHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udDELETE_RANGE);
            OS.gtk_text_buffer_delete (bufferHandle, &startIter, &endIter);
            OS.g_signal_handlers_unblock_matched (bufferHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udDELETE_RANGE);
            OS.g_signal_handlers_unblock_matched (bufferHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
            OS.g_signal_handlers_block_matched (bufferHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udTEXT_BUFFER_INSERT_TEXT);
            OS.gtk_text_buffer_insert (bufferHandle, &startIter, newText.ptr, cast(int)/*64bit*/newText.length);
            OS.g_signal_handlers_unblock_matched (bufferHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udTEXT_BUFFER_INSERT_TEXT);
            OS.g_signal_stop_emission_by_name (bufferHandle, OS.delete_range.ptr);
        }
    }
    return 0;
}

override int gtk_delete_text (GtkWidget* widget, ptrdiff_t start_pos, ptrdiff_t end_pos) {
    if (!hooks (SWT.Verify) && !filters (SWT.Verify)) return 0;
    String newText = verifyText ("", cast(int)/*64bit*/start_pos, cast(int)/*64bit*/end_pos);
    if (newText is null) {
        /* Remember the selection when the text was deleted */
        int newStart, newEnd;
        OS.gtk_editable_get_selection_bounds (cast(GtkEditable*)handle, &newStart, &newEnd);
        if (newStart !is newEnd) {
            fixStart = newStart;
            fixEnd = newEnd;
        }
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

override int gtk_event_after (GtkWidget* widget, GdkEvent* event) {
    if (cursor !is null) gtk_setCursor (cursor.handle);
    /*
    * Feature in GTK.  The gtk-entry-select-on-focus property is a global
    * setting.  Return it to its default value after the GtkEntry has done
    * its focus in processing so that other widgets (such as the combo)
    * use the correct value.
    */
    if ((style & SWT.SINGLE) !is 0 && display.entrySelectOnFocus) {
        switch (event.type) {
            case OS.GDK_FOCUS_CHANGE:
                GdkEventFocus* gdkEventFocus = cast(GdkEventFocus*)event;
                if (gdkEventFocus.in_ is 0) {
                    auto settings = OS.gtk_settings_get_default ();
                    OS.g_object_set1 (settings, OS.gtk_entry_select_on_focus.ptr, true );
                }
                break;
            default:
        }
    }
    return super.gtk_event_after (widget, event);
}

override int gtk_focus_out_event (GtkWidget* widget, GdkEventFocus* event) {
    fixIM ();
    return super.gtk_focus_out_event (widget, event);
}

override int gtk_grab_focus (GtkWidget* widget) {
    auto result = super.gtk_grab_focus (widget);
    /*
    * Feature in GTK.  GtkEntry widgets select their text on focus in,
    * clearing the previous selection.  This behavior is controlled by
    * the gtk-entry-select-on-focus property.  The fix is to disable
    * this property when a GtkEntry is given focus and restore it after
    * the entry has done focus in processing.
    */
    if ((style & SWT.SINGLE) !is 0 && display.entrySelectOnFocus) {
        auto settings = OS.gtk_settings_get_default ();
        OS.g_object_set1 (settings, OS.gtk_entry_select_on_focus.ptr, false );
    }
    return result;
}

override int gtk_insert_text (GtkEditable* widget, char* new_text, ptrdiff_t new_text_length, ptrdiff_t position) {
    if (!hooks (SWT.Verify) && !filters (SWT.Verify)) return 0;
    if (new_text is null || new_text_length is 0) return 0;
    String oldText = (cast(char*)new_text)[ 0 .. new_text_length ]._idup();
    int pos;
    pos = *cast(int*)position;
    if (pos is -1) {
        auto ptr = OS.gtk_entry_get_text (cast(GtkEntry*)handle);
        pos = cast(int)/*64bit*/OS.g_utf8_strlen (ptr, -1);
    }
    /* Use the selection when the text was deleted */
    int start = pos, end = pos;
    if (fixStart !is -1 && fixEnd !is -1) {
        start = pos = fixStart;
        end = fixEnd;
        fixStart = fixEnd = -1;
    }
    String newText = verifyText (oldText, start, end);
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
        pos  = newEnd;
        if (newStart !is newEnd) {
            fixStart = newStart;
            fixEnd = newEnd;
        }
        *cast(int*)position = pos;
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
        display.doSetDirectionProc (menu, OS.GTK_TEXT_DIR_RTL);
    }
    return 0;
}

override int gtk_text_buffer_insert_text (GtkTextBuffer *widget, GtkTextIter *iter, char *text, ptrdiff_t len) {
    if (!hooks (SWT.Verify) && !filters (SWT.Verify)) return 0;
    GtkTextIter position = *iter;
    /* Use the selection when the text was deleted */
    int start = OS.gtk_text_iter_get_offset (&position), end = start;
    if (fixStart !is -1 && fixEnd !is -1) {
        start = fixStart;
        end = fixEnd;
        fixStart = fixEnd = -1;
    }
    String oldText = cast(String)text[ 0 .. len ];
    String newText = verifyText (oldText, start, end);
    if (newText is null) {
        OS.g_signal_stop_emission_by_name (bufferHandle, OS.insert_text.ptr);
    } else {
        if (newText !is oldText) {
            OS.g_signal_handlers_block_matched (bufferHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udTEXT_BUFFER_INSERT_TEXT);
            OS.gtk_text_buffer_insert (bufferHandle, iter, newText.ptr, cast(int)/*64bit*/newText.length);
            OS.g_signal_handlers_unblock_matched (bufferHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udTEXT_BUFFER_INSERT_TEXT);
            OS.g_signal_stop_emission_by_name (bufferHandle, OS.insert_text.ptr);
        }
    }
    return 0;
}

override void hookEvents () {
    super.hookEvents();
    if ((style & SWT.SINGLE) !is 0) {
        OS.g_signal_connect_closure (handle, OS.changed.ptr, display.closures [CHANGED], true);
        OS.g_signal_connect_closure (handle, OS.insert_text.ptr, display.closures [INSERT_TEXT], false);
        OS.g_signal_connect_closure (handle, OS.delete_text.ptr, display.closures [DELETE_TEXT], false);
        OS.g_signal_connect_closure (handle, OS.activate.ptr, display.closures [ACTIVATE], false);
        OS.g_signal_connect_closure (handle, OS.grab_focus.ptr, display.closures [GRAB_FOCUS], false);
        OS.g_signal_connect_closure (handle, OS.populate_popup.ptr, display.closures [POPULATE_POPUP], false);
    } else {
        OS.g_signal_connect_closure (bufferHandle, OS.changed.ptr, display.closures [CHANGED], false);
        OS.g_signal_connect_closure (bufferHandle, OS.insert_text.ptr, display.closures [TEXT_BUFFER_INSERT_TEXT], false);
        OS.g_signal_connect_closure (bufferHandle, OS.delete_range.ptr, display.closures [DELETE_RANGE], false);
        OS.g_signal_connect_closure (handle, OS.populate_popup.ptr, display.closures [POPULATE_POPUP], false);
    }
    auto imContext = imContext ();
    if (imContext !is null) {
        OS.g_signal_connect_closure (imContext, OS.commit.ptr, display.closures [COMMIT], false);
        int id = OS.g_signal_lookup (OS.commit.ptr, OS.gtk_im_context_get_type ());
        int mask =  OS.G_SIGNAL_MATCH_DATA | OS.G_SIGNAL_MATCH_ID;
        OS.g_signal_handlers_block_matched (imContext, mask, id, 0, null, null, cast(void*)handle);
    }
}

GtkIMContext* imContext () {
    if ((style & SWT.SINGLE) !is 0) {
        return OS.gtk_editable_get_editable (handle) ? OS.GTK_ENTRY_IM_CONTEXT (handle) : null;
    }
    return OS.GTK_TEXTVIEW_IM_CONTEXT (cast(GtkTextView*)handle);
}

/**
 * Inserts a string.
 * <p>
 * The old selection is replaced with the new text.
 * </p>
 *
 * @param string the string
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void insert (String string) {
    checkWidget ();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if ((style & SWT.SINGLE) !is 0) {
        int start, end;
        OS.gtk_editable_get_selection_bounds (cast(GtkEditable*)handle, &start, &end);
        OS.gtk_editable_delete_selection (cast(GtkEditable*)handle);
        OS.gtk_editable_insert_text (cast(GtkEditable*)handle, string.ptr, cast(int)/*64bit*/string.length, &start);
        OS.gtk_editable_set_position (cast(GtkEditable*)handle, start);
    } else {
        GtkTextIter start;
        GtkTextIter end;
        if (OS.gtk_text_buffer_get_selection_bounds (bufferHandle, &start, &end)) {
            OS.gtk_text_buffer_delete (bufferHandle, &start, &end);
        }
        OS.gtk_text_buffer_insert (bufferHandle, &start, string.ptr, cast(int)/*64bit*/string.length);
        OS.gtk_text_buffer_place_cursor (bufferHandle, &start);
        auto mark = OS.gtk_text_buffer_get_insert (bufferHandle);
        OS.gtk_text_view_scroll_mark_onscreen (cast(GtkTextView*)handle, mark);
    }
}

override GdkDrawable* paintWindow () {
    if ((style & SWT.SINGLE) !is 0) {
        auto window = super.paintWindow ();
        auto children = OS.gdk_window_get_children (window);
        if (children !is null) window = cast(GdkDrawable*) OS.g_list_data (children);
        OS.g_list_free (children);
        return window;
    }
    OS.gtk_widget_realize (handle);
    return OS.gtk_text_view_get_window (cast(GtkTextView*)handle, OS.GTK_TEXT_WINDOW_TEXT);
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
    if ((style & SWT.SINGLE) !is 0) {
        OS.gtk_editable_paste_clipboard (cast(GtkEditable*)handle);
    } else {
        auto clipboard = OS.gtk_clipboard_get (cast(void*)OS.GDK_NONE);
        OS.gtk_text_buffer_paste_clipboard (bufferHandle, clipboard, null, OS.gtk_text_view_get_editable (cast(GtkTextView*)handle));
    }
}

override void register () {
    super.register ();
    if (bufferHandle !is null) display.addWidget (cast(GtkWidget*)bufferHandle, this);
    auto imContext = imContext ();
    if (imContext !is null) display.addWidget (cast(GtkWidget*)imContext, this);
}

override void releaseWidget () {
    super.releaseWidget ();
    fixIM ();
    if (OS.GTK_VERSION < OS.buildVERSION (2, 6, 0)) {
        /*
        * Bug in GTK.  Any text copied into the clipboard will be lost when
        * the GtkTextView is destroyed.  The fix is to paste the contents as
        * the widget is being destroyed to reference the text buffer, keeping
        * it around until ownership of the clipboard is lost.
        */
        if ((style & SWT.MULTI) !is 0) {
            auto clipboard = OS.gtk_clipboard_get (cast(void*)OS.GDK_NONE);
            OS.gtk_text_buffer_paste_clipboard (bufferHandle, clipboard, null, OS.gtk_text_view_get_editable (cast(GtkTextView*)handle));
        }
    }
    message = null;
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
 * @see VerifyListener
 * @see #addVerifyListener
 */
public void removeVerifyListener (VerifyListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Verify, listener);
}

/**
 * Selects all the text in the receiver.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void selectAll () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        OS.gtk_editable_select_region (cast(GtkEditable*)handle, 0, -1);
    } else {
        GtkTextIter start;
        GtkTextIter end;
        OS.gtk_text_buffer_get_iter_at_offset (bufferHandle, &start, 0);
        OS.gtk_text_buffer_get_end_iter (bufferHandle, &end);
        auto insertMark = OS.gtk_text_buffer_get_insert (bufferHandle);
        auto selectionMark = OS.gtk_text_buffer_get_selection_bound (bufferHandle);
        OS.gtk_text_buffer_move_mark (bufferHandle, selectionMark, &start);
        OS.gtk_text_buffer_move_mark (bufferHandle, insertMark, &end);
    }
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

/**
 * Sets the double click enabled flag.
 * <p>
 * The double click flag enables or disables the
 * default action of the text widget when the user
 * double clicks.
 * </p><p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept.
 * </p>
 *
 * @param doubleClick the new double click flag
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setDoubleClickEnabled (bool doubleClick) {
    checkWidget ();
    this.doubleClick = doubleClick;
}

/**
 * Sets the echo character.
 * <p>
 * The echo character is the character that is
 * displayed when the user enters text or the
 * text is changed by the programmer. Setting
 * the echo character to '\0' clears the echo
 * character and redraws the original text.
 * If for any reason the echo character is invalid,
 * or if the platform does not allow modification
 * of the echo character, the default echo character
 * for the platform is used.
 * </p>
 *
 * @param echo the new echo character
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setEchoChar (char echo) {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        OS.gtk_entry_set_visibility (cast(GtkEntry*)handle, echo is '\0');
        OS.gtk_entry_set_invisible_char (cast(GtkEntry*)handle, echo);
    }
}

/**
 * Sets the editable state.
 *
 * @param editable the new editable state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setEditable (bool editable) {
    checkWidget ();
    style &= ~SWT.READ_ONLY;
    if (!editable) style |= SWT.READ_ONLY;
    if ((style & SWT.SINGLE) !is 0) {
        OS.gtk_editable_set_editable (cast(GtkEditable*)handle, editable);
    } else {
        OS.gtk_text_view_set_editable (cast(GtkTextView*)handle, editable);
    }
}

override void setFontDescription (PangoFontDescription* font) {
    super.setFontDescription (font);
    setTabStops (tabs);
}

/**
 * Sets the widget message. When the widget is created
 * with the style <code>SWT.SEARCH</code>, the message text
 * is displayed as a hint for the user, indicating the
 * purpose of the field.
 * <p>
 * Note: This operation is a <em>HINT</em> and is not
 * supported on platforms that do not have this concept.
 * </p>
 *
 * @param message the new message
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the message is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.3
 */
public void setMessage (String message) {
    checkWidget ();
    // SWT extension: allow null for zero length string
    //if (message is null) error (SWT.ERROR_NULL_ARGUMENT);
    this.message = message;
}

/**
 * Sets the orientation of the receiver, which must be one
 * of the constants <code>SWT.LEFT_TO_RIGHT</code> or <code>SWT.RIGHT_TO_LEFT</code>.
 * <p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept.
 * </p>
 *
 * @param orientation new orientation style
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1.2
 */
public void setOrientation (int orientation) {
    checkWidget();
}

/**
 * Sets the selection.
 * <p>
 * Indexing is zero based.  The range of
 * a selection is from 0..N where N is
 * the number of characters in the widget.
 * </p><p>
 * Text selections are specified in terms of
 * caret positions.  In a text widget that
 * contains N characters, there are N+1 caret
 * positions, ranging from 0..N.  This differs
 * from other functions that address character
 * position such as getText () that use the
 * regular array indexing rules.
 * </p>
 *
 * @param start new caret position
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (int start) {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        OS.gtk_editable_set_position (cast(GtkEditable*)handle, start);
    } else {
        GtkTextIter position;
        OS.gtk_text_buffer_get_iter_at_offset (bufferHandle, &position, start);
        OS.gtk_text_buffer_place_cursor (bufferHandle, &position);
        auto mark = OS.gtk_text_buffer_get_insert (bufferHandle);
        OS.gtk_text_view_scroll_mark_onscreen (cast(GtkTextView*)handle, mark);
    }
}

/**
 * Sets the selection to the range specified
 * by the given start and end indices.
 * <p>
 * Indexing is zero based.  The range of
 * a selection is from 0..N where N is
 * the number of characters in the widget.
 * </p><p>
 * Text selections are specified in terms of
 * caret positions.  In a text widget that
 * contains N characters, there are N+1 caret
 * positions, ranging from 0..N.  This differs
 * from other functions that address character
 * position such as getText () that use the
 * usual array indexing rules.
 * </p>
 *
 * @param start the start of the range
 * @param end the end of the range
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (int start, int end) {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) {
        OS.gtk_editable_set_position (cast(GtkEditable*)handle, start);
        OS.gtk_editable_select_region (cast(GtkEditable*)handle, start, end);
    } else {
        GtkTextIter startIter;
        GtkTextIter endIter;
        OS.gtk_text_buffer_get_iter_at_offset (bufferHandle, &startIter, start);
        OS.gtk_text_buffer_get_iter_at_offset (bufferHandle, &endIter, end);
        auto insertMark = OS.gtk_text_buffer_get_insert (bufferHandle);
        auto selectionMark = OS.gtk_text_buffer_get_selection_bound (bufferHandle);
        OS.gtk_text_buffer_move_mark (bufferHandle, selectionMark, &startIter);
        OS.gtk_text_buffer_move_mark (bufferHandle, insertMark, &endIter);
    }
}

/**
 * Sets the selection to the range specified
 * by the given point, where the x coordinate
 * represents the start index and the y coordinate
 * represents the end index.
 * <p>
 * Indexing is zero based.  The range of
 * a selection is from 0..N where N is
 * the number of characters in the widget.
 * </p><p>
 * Text selections are specified in terms of
 * caret positions.  In a text widget that
 * contains N characters, there are N+1 caret
 * positions, ranging from 0..N.  This differs
 * from other functions that address character
 * position such as getText () that use the
 * usual array indexing rules.
 * </p>
 *
 * @param selection the point
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (Point selection) {
    checkWidget ();
    if (selection is null) error (SWT.ERROR_NULL_ARGUMENT);
    setSelection (selection.x, selection.y);
}

/**
 * Sets the number of tabs.
 * <p>
 * Tab stop spacing is specified in terms of the
 * space (' ') character.  The width of a single
 * tab stop is the pixel width of the spaces.
 * </p>
 *
 * @param tabs the number of tabs
 *
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setTabs (int tabs) {
    checkWidget ();
    if (tabs < 0) return;
    setTabStops (this.tabs = tabs);
}

void setTabStops (int tabs) {
    if ((style & SWT.SINGLE) !is 0) return;
    int tabWidth = getTabWidth (tabs);
    auto tabArray = OS.pango_tab_array_new (1, false);
    OS.pango_tab_array_set_tab (tabArray, 0, OS.PANGO_TAB_LEFT, tabWidth);
    OS.gtk_text_view_set_tabs (cast(GtkTextView*)handle, tabArray);
    OS.pango_tab_array_free (tabArray);
}

/**
 * Sets the contents of the receiver to the given string. If the receiver has style
 * SINGLE and the argument contains multiple lines of text, the result of this
 * operation is undefined and may vary from platform to platform.
 *
 * @param string the new text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setText (String string) {
    checkWidget ();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    /*
    * Feature in gtk.  When text is set in gtk, separate events are fired for the deletion and
    * insertion of the text.  This is not wrong, but is inconsistent with other platforms.  The
    * fix is to block the firing of these events and fire them ourselves in a consistent manner.
    */
    if (hooks (SWT.Verify) || filters (SWT.Verify)) {
        string = verifyText (string, 0, getCharCount ());
        if (string is null) return;
    }
    if ((style & SWT.SINGLE) !is 0) {
        OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
        OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udDELETE_TEXT);
        OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udINSERT_TEXT);
        OS.gtk_entry_set_text (cast(GtkEntry*)handle, toStringz(string) );
        OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
        OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udDELETE_TEXT);
        OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udINSERT_TEXT);
    } else {
        GtkTextIter position;
        OS.g_signal_handlers_block_matched (bufferHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
        OS.g_signal_handlers_block_matched (bufferHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udDELETE_RANGE);
        OS.g_signal_handlers_block_matched (bufferHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udTEXT_BUFFER_INSERT_TEXT);
        OS.gtk_text_buffer_set_text (bufferHandle, string.ptr, cast(int)/*64bit*/string.length);
        OS.g_signal_handlers_unblock_matched (bufferHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
        OS.g_signal_handlers_unblock_matched (bufferHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udDELETE_RANGE);
        OS.g_signal_handlers_unblock_matched (bufferHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udTEXT_BUFFER_INSERT_TEXT);
        OS.gtk_text_buffer_get_iter_at_offset (bufferHandle, &position, 0);
        OS.gtk_text_buffer_place_cursor (bufferHandle, &position);
        auto mark = OS.gtk_text_buffer_get_insert (bufferHandle);
        OS.gtk_text_view_scroll_mark_onscreen (cast(GtkTextView*)handle, mark);
    }
    sendEvent (SWT.Modify);
}

/**
 * Sets the maximum number of characters that the receiver
 * is capable of holding to be the argument.
 * <p>
 * Instead of trying to set the text limit to zero, consider
 * creating a read-only text widget.
 * </p><p>
 * To reset this value to the default, use <code>setTextLimit(Text.LIMIT)</code>.
 * Specifying a limit value larger than <code>Text.LIMIT</code> sets the
 * receiver's limit to <code>Text.LIMIT</code>.
 * </p>
 *
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
 */
public void setTextLimit (int limit) {
    checkWidget ();
    if (limit is 0) error (SWT.ERROR_CANNOT_BE_ZERO);
    if ((style & SWT.SINGLE) !is 0) OS.gtk_entry_set_max_length (cast(GtkEntry*)handle, limit);
}

/**
 * Sets the zero-relative index of the line which is currently
 * at the top of the receiver. This index can change when lines
 * are scrolled or new lines are added and removed.
 *
 * @param index the index of the top item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setTopIndex (int index) {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) return;
    GtkTextIter position;
    OS.gtk_text_buffer_get_iter_at_line (bufferHandle, &position, index);
    OS.gtk_text_view_scroll_to_iter (cast(GtkTextView*)handle, &position, 0, true, 0, 0);
}

/**
 * Shows the selection.
 * <p>
 * If the selection is already showing
 * in the receiver, this method simply returns.  Otherwise,
 * lines are scrolled until the selection is visible.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void showSelection () {
    checkWidget ();
    if ((style & SWT.SINGLE) !is 0) return;
    auto mark = OS.gtk_text_buffer_get_selection_bound (bufferHandle);
    OS.gtk_text_view_scroll_mark_onscreen (cast(GtkTextView*)handle, mark);
    mark = OS.gtk_text_buffer_get_insert (bufferHandle);
    OS.gtk_text_view_scroll_mark_onscreen (cast(GtkTextView*)handle, mark);
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

override int traversalCode (int key, GdkEventKey* event) {
    int bits = super.traversalCode (key, event);
    if ((style & SWT.READ_ONLY) !is 0)  return bits;
    if ((style & SWT.MULTI) !is 0) {
        bits &= ~SWT.TRAVERSE_RETURN;
        if (key is OS.GDK_Tab && event !is null) {
            bool next = (event.state & OS.GDK_SHIFT_MASK) is 0;
            if (next && (event.state & OS.GDK_CONTROL_MASK) is 0) {
                bits &= ~(SWT.TRAVERSE_TAB_NEXT | SWT.TRAVERSE_TAB_PREVIOUS);
            }
        }
    }
    return bits;
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
