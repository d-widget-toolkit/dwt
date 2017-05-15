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
module org.eclipse.swt.widgets.Link;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.accessibility.ACC;
import org.eclipse.swt.accessibility.Accessible;
import org.eclipse.swt.accessibility.AccessibleAdapter;
import org.eclipse.swt.accessibility.AccessibleControlAdapter;
import org.eclipse.swt.accessibility.AccessibleControlEvent;
import org.eclipse.swt.accessibility.AccessibleEvent;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.TextLayout;
import org.eclipse.swt.graphics.TextStyle;
import org.eclipse.swt.internal.gtk.OS;

import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;
import java.lang.all;
import java.nonstandard.UnsafeUtf;

/**
 * Instances of this class represent a selectable
 * user interface object that displays a text with
 * links.
 * <p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#link">Link snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 * 
 * @since 3.1
 */
public class Link : Control {

    alias Control.computeSize computeSize;
    alias Control.fixStyle fixStyle;
    alias Control.setBounds setBounds;

    String text;
    TextLayout layout;
    Color linkColor, disabledColor;
    Point [] offsets;
    Point selection;
    String [] ids;
    int [] mnemonics;
    int focusIndex;

    static RGB LINK_FOREGROUND;
    static RGB LINK_DISABLED_FOREGROUND;

    static void static_this(){
        if( LINK_FOREGROUND is null ){
            LINK_FOREGROUND = new RGB (0, 51, 153);
        }
        if( LINK_DISABLED_FOREGROUND is null ){
            LINK_DISABLED_FOREGROUND = new RGB (172, 168, 153);
        }
    }

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
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    static_this();
    super (parent, style);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the control is selected by the user.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
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
 * @see SelectionListener
 * @see #removeSelectionListener
 * @see SelectionEvent
 */
public void addSelectionListener (SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection, typedListener);
    addListener (SWT.DefaultSelection, typedListener);
}

public override Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    if (wHint !is SWT.DEFAULT && wHint < 0) wHint = 0;
    if (hHint !is SWT.DEFAULT && hHint < 0) hHint = 0;
    int width, height;
    int layoutWidth = layout.getWidth ();
    //TEMPORARY CODE
    if (wHint is 0) {
        layout.setWidth (1);
        Rectangle rect = layout.getBounds ();
        width = 0;
        height = rect.height;
    } else {
        layout.setWidth (wHint);
        Rectangle rect = layout.getBounds ();
        width = rect.width;
        height = rect.height;
    }
    layout.setWidth (layoutWidth);
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    int border = getBorderWidth ();
    width += border * 2;
    height += border * 2;
    return new Point (width, height);
}

override void createHandle(int index) {
    state |= HANDLE | THEME_BACKGROUND;
    handle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (handle is null) SWT.error (SWT.ERROR_NO_HANDLES);
    OS.gtk_fixed_set_has_window (handle, true);
    OS.GTK_WIDGET_SET_FLAGS (handle, OS.GTK_CAN_FOCUS);
    layout = new TextLayout (display);
    layout.setOrientation((style & SWT.RIGHT_TO_LEFT) !is 0? SWT.RIGHT_TO_LEFT : SWT.LEFT_TO_RIGHT);
    linkColor = new Color (display, LINK_FOREGROUND);
    disabledColor = new Color (display, LINK_DISABLED_FOREGROUND);
    offsets = null;
    ids = null;
    mnemonics = null;
    selection = new Point (-1, -1);
    focusIndex = -1;
}

override void createWidget (int index) {
    super.createWidget (index);
    layout.setFont (getFont ());
    text = "";
    initAccessible ();
}

override void enableWidget (bool enabled) {
    super.enableWidget (enabled);
    if (isDisposed ()) return;
    TextStyle linkStyle = new TextStyle (null, enabled ? linkColor : disabledColor, null);
    linkStyle.underline = true;
    for (int i = 0; i < offsets.length; i++) {
        Point point = offsets [i];
        layout.setStyle (linkStyle, point.x, point.y);
    }
    redraw ();
}

override void fixStyle () {
    fixStyle (handle);
}

void initAccessible () {
    Accessible accessible = getAccessible ();
    accessible.addAccessibleListener (new class () AccessibleAdapter {
        override
        public void getName (AccessibleEvent e) {
            e.result = parse (text);
        }
    });

    accessible.addAccessibleControlListener (new class () AccessibleControlAdapter {
        override
        public void getChildAtPoint (AccessibleControlEvent e) {
            e.childID = ACC.CHILDID_SELF;
        }

        override
        public void getLocation (AccessibleControlEvent e) {
            Rectangle rect = display.map (getParent (), null, getBounds ());
            e.x = rect.x;
            e.y = rect.y;
            e.width = rect.width;
            e.height = rect.height;
        }

        override
        public void getChildCount (AccessibleControlEvent e) {
            e.detail = 0;
        }

        override
        public void getRole (AccessibleControlEvent e) {
            e.detail = ACC.ROLE_LINK;
        }

        override
        public void getState (AccessibleControlEvent e) {
            e.detail = ACC.STATE_FOCUSABLE;
            if (hasFocus ()) e.detail |= ACC.STATE_FOCUSED;
        }

        override
        public void getDefaultAction (AccessibleControlEvent e) {
            e.result = SWT.getMessage ("SWT_Press"); //$NON-NLS-1$
        }

        override
        public void getSelection (AccessibleControlEvent e) {
            if (hasFocus ()) e.childID = ACC.CHILDID_SELF;
        }

        override
        public void getFocus (AccessibleControlEvent e) {
            if (hasFocus ()) e.childID = ACC.CHILDID_SELF;
        }
    });
}

override String getNameText () {
    return getText ();
}

Rectangle [] getRectangles (int linkIndex) {
    int lineCount = layout.getLineCount ();
    Rectangle [] rects = new Rectangle [lineCount];
    int [] lineOffsets = layout.getLineOffsets ();
    Point point = offsets [linkIndex];
    int lineStart = 1;
    while (point.x > lineOffsets [lineStart]) lineStart++;
    int lineEnd = 1;
    while (point.y > lineOffsets [lineEnd]) lineEnd++;
    int index = 0;
    if (lineStart is lineEnd) {
        rects [index++] = layout.getBounds (point.x, point.y);
    } else {
        rects [index++] = layout.getBounds (point.x, lineOffsets [lineStart]-1);
        rects [index++] = layout.getBounds (lineOffsets [lineEnd-1], point.y);
        if (lineEnd - lineStart > 1) {
            for (int i = lineStart; i < lineEnd - 1; i++) {
                rects [index++] = layout.getLineBounds (i);
            }
        }
    }
    if (rects.length !is index) {
        Rectangle [] tmp = new Rectangle [index];
        System.arraycopy (rects, 0, tmp, 0, index);
        rects = tmp;
    }
    return rects;
}

override
int getClientWidth () {
    return (state & ZERO_WIDTH) !is 0 ? 0 : OS.GTK_WIDGET_WIDTH (handle);
}

/**
 * Returns the receiver's text, which will be an empty
 * string if it has never been set.
 *
 * @return the receiver's text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText () {
    checkWidget ();
    return text;
}

override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* gdkEvent) {
    int result = super.gtk_button_press_event (widget, gdkEvent);
    if (result !is 0) return result;
    if (gdkEvent.button is 1 && gdkEvent.type is OS.GDK_BUTTON_PRESS) {
        if (focusIndex !is -1) setFocus ();
        int x = cast(int) gdkEvent.x;
        int y = cast(int) gdkEvent.y;
        if ((style & SWT.MIRRORED) !is 0) x = getClientWidth () - x;
        int offset = layout.getOffset (x, y, null);
        int oldSelectionX = selection.x;
        int oldSelectionY = selection.y;
        selection.x = offset;
        selection.y = -1;
        if (oldSelectionX !is -1 && oldSelectionY !is -1) {
            if (oldSelectionX > oldSelectionY) {
                int temp = oldSelectionX;
                oldSelectionX = oldSelectionY;
                oldSelectionY = temp;
            }
            Rectangle rect = layout.getBounds (oldSelectionX, oldSelectionY);
            redraw (rect.x, rect.y, rect.width, rect.height, false);
        }
        for (int j = 0; j < offsets.length; j++) {
            Rectangle [] rects = getRectangles (j);
            for (int i = 0; i < rects.length; i++) {
                Rectangle rect = rects [i];
                if (rect.contains (x, y)) {
                    focusIndex = j;
                    redraw ();
                    return result;
                }
            }
        }
    }
    return result;
}

override int gtk_button_release_event (GtkWidget* widget, GdkEventButton* gdkEvent) {
    int result = super.gtk_button_release_event (widget, gdkEvent);
    if (result !is 0) return result;
    if (focusIndex is -1) return result;
    if (gdkEvent.button is 1) {
        int x = cast(int) gdkEvent.x;
        int y = cast(int) gdkEvent.y;
        if ((style & SWT.MIRRORED) !is 0) x = getClientWidth () - x;
        Rectangle [] rects = getRectangles (focusIndex);
        for (int i = 0; i < rects.length; i++) {
            Rectangle rect = rects [i];
            if (rect.contains (x, y)) {
                Event ev = new Event ();
                ev.text = ids [focusIndex];
                sendEvent (SWT.Selection, ev);
                return result;
            }
        }
    }
    return result;
}

override int gtk_event_after (GtkWidget* widget, GdkEvent* event) {
    int result = super.gtk_event_after (widget, event);
    switch (event.type) {
        case OS.GDK_FOCUS_CHANGE:
            redraw ();
            break;
        default:
    }
    return result;
}

override int gtk_expose_event (GtkWidget* widget, GdkEventExpose* gdkEvent) {
    if ((state & OBSCURED) !is 0) return 0;
    GCData data = new GCData ();
    data.damageRgn = gdkEvent.region;
    GC gc = GC.gtk_new (this, data);
    OS.gdk_gc_set_clip_region (gc.handle, gdkEvent.region);
    int selStart = selection.x;
    int selEnd = selection.y;
    if (selStart > selEnd) {
        selStart = selection.y;
        selEnd = selection.x;
    }
    // temporary code to disable text selection
    selStart = selEnd = -1;
    if ((state & DISABLED) !is 0) gc.setForeground (disabledColor);
    layout.draw (gc, 0, 0, selStart, selEnd, null, null);
    if (hasFocus () && focusIndex !is -1) {
        Rectangle [] rects = getRectangles (focusIndex);
        for (int i = 0; i < rects.length; i++) {
            Rectangle rect = rects [i];
            gc.drawFocus (rect.x, rect.y, rect.width, rect.height);
        }
    }
    if (hooks (SWT.Paint) || filters (SWT.Paint)) {
        Event event = new Event ();
        event.count = gdkEvent.count;
        event.x = gdkEvent.area.x;
        event.y = gdkEvent.area.y;
        event.width = gdkEvent.area.width;
        event.height = gdkEvent.area.height;
        if ((style & SWT.MIRRORED) !is 0) event.x = getClientWidth () - event.width - event.x;
        event.gc = gc;
        sendEvent (SWT.Paint, event);
        event.gc = null;
    }
    gc.dispose ();
    return 0;
}

override int gtk_key_press_event (GtkWidget* widget, GdkEventKey* gdkEvent) {
    int result = super.gtk_key_press_event (widget, gdkEvent);
    if (result !is 0) return result;
    if (focusIndex is -1) return result;
    switch (gdkEvent.keyval) {
        case OS.GDK_Return:
        case OS.GDK_KP_Enter:
        case OS.GDK_space:
            Event event = new Event ();
            event.text = ids [focusIndex];
            sendEvent (SWT.Selection, event);
            break;
        case OS.GDK_Tab:
            if (focusIndex < offsets.length - 1) {
                focusIndex++;
                redraw ();
            }
            break;
        case OS.GDK_ISO_Left_Tab:
            if (focusIndex > 0) {
                focusIndex--;
                redraw ();
            }
            break;
        default:
    }
    return result;
}

override int gtk_motion_notify_event (GtkWidget* widget, GdkEventMotion* gdkEvent) {
    int result = super.gtk_motion_notify_event (widget, gdkEvent);
    if (result !is 0) return result;
    int x = cast(int) gdkEvent.x;
    int y = cast(int) gdkEvent.y;
    if ((style & SWT.MIRRORED) !is 0) x = getClientWidth () - x;
    if ((gdkEvent.state & OS.GDK_BUTTON1_MASK) !is 0) {
        int oldSelection = selection.y;
        selection.y = layout.getOffset (x, y, null);
        if (selection.y !is oldSelection) {
            int newSelection = selection.y;
            if (oldSelection > newSelection) {
                int temp = oldSelection;
                oldSelection = newSelection;
                newSelection = temp;
            }
            Rectangle rect = layout.getBounds (oldSelection, newSelection);
            redraw (rect.x, rect.y, rect.width, rect.height, false);
        }
    } else {
        for (int j = 0; j < offsets.length; j++) {
            Rectangle [] rects = getRectangles (j);
            for (int i = 0; i < rects.length; i++) {
                Rectangle rect = rects [i];
                if (rect.contains (x, y)) {
                    setCursor (display.getSystemCursor (SWT.CURSOR_HAND));
                    return result;
                }
            }
        }
        setCursor (null);
    }
    return result;
}

override void releaseWidget () {
    super.releaseWidget ();
    if (layout !is null) layout.dispose ();
    layout = null;
    if (linkColor !is null)  linkColor.dispose ();
    linkColor = null;
    if (disabledColor !is null) disabledColor.dispose ();
    disabledColor = null;
    offsets = null;
    ids = null;
    mnemonics = null;
    text = null;
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
public void removeSelectionListener (SelectionListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Selection, listener);
    eventTable.unhook (SWT.DefaultSelection, listener);
}

String parse (String string) {
    ptrdiff_t length_ = string.length;
    offsets = new Point[]( length_ / 4 );
    ids = new String[]( length_ / 4 );
    mnemonics = new int[] ( length_ / 4 + 1 );
    StringBuffer result = new StringBuffer ();
    char [] buffer = string.dup;

    int index = 0, state = 0, linkIndex = 0;
    int start = 0, tagStart = 0, linkStart = 0, endtagStart = 0, refStart = 0;
    while (index < length_) {
        ptrdiff_t increment;
        dchar c = Character.toLowerCase (buffer.dcharAt (index, increment));

        switch (state) {
            case 0:
                if (c is '<') {
                    tagStart = index;
                    state++;
                }
                break;
            case 1:
                if (c is 'a') state++;
                break;
            case 2:
                switch (c) {
                    case 'h':
                        state = 7;
                        break;
                    case '>':
                        linkStart = index  + 1;
                        state++;
                        break;
                    default:
                        if (Character.isWhitespace(c)) break;
                        else state = 13;
                }
                break;
            case 3:
                if (c is '<') {
                    endtagStart = index;
                    state++;
                }
                break;
            case 4:
                state = c is '/' ? state + 1 : 3;
                break;
            case 5:
                state = c is 'a' ? state + 1 : 3;
                break;
            case 6:
                if (c is '>') {
                    mnemonics [linkIndex] = parseMnemonics (buffer, start, tagStart, result);
                    int offset = result.length ();
                    parseMnemonics (buffer, linkStart, endtagStart, result);
                    offsets [linkIndex] = new Point (offset, result.length () - 1);
                    if (ids [linkIndex] is null) {
                        ids [linkIndex] = buffer[ linkStart .. endtagStart ]._idup();
                    }
                    linkIndex++;
                    start = tagStart = linkStart = endtagStart = refStart = index + 1;
                    state = 0;
                } else {
                    state = 3;
                }
                break;
            case 7:
                state = c is 'r' ? state + 1 : 0;
                break;
            case 8:
                state = c is 'e' ? state + 1 : 0;
                break;
            case 9:
                state = c is 'f' ? state + 1 : 0;
                break;
            case 10:
                state = c is '=' ? state + 1 : 0;
                break;
            case 11:
                if (c is '"') {
                    state++;
                    refStart = index + 1;
                } else {
                    state = 0;
                }
                break;
            case 12:
                if (c is '"') {
                    ids[linkIndex] = buffer[ refStart .. index ]._idup();
                    state = 2;
                }
                break;
            case 13:
                if (Character.isWhitespace (c)) {
                    state = 0;
                } else if (c is '='){
                    state++;
                }
                break;
            case 14:
                state = c is '"' ? state + 1 : 0;
                break;
            case 15:
                if (c is '"') state = 2;
                break;
            default:
                state = 0;
                break;
        }
        index+=increment;
    }
    if (start < length_) {
        int tmp = parseMnemonics (buffer, start, tagStart, result);
        int mnemonic = parseMnemonics (buffer, Math.max (tagStart, linkStart), cast(int)/*64bit*/length_, result);
        if (mnemonic is -1) mnemonic = tmp;
        mnemonics [linkIndex] = mnemonic;
    } else {
        mnemonics [linkIndex] = -1;
    }
    if (offsets.length !is linkIndex) {
        Point [] newOffsets = new Point [linkIndex];
        System.arraycopy (offsets, 0, newOffsets, 0, linkIndex);
        offsets = newOffsets;
        String [] newIDs = new String [linkIndex];
        System.arraycopy (ids, 0, newIDs, 0, linkIndex);
        ids = newIDs;
        int [] newMnemonics = new int [linkIndex + 1];
        System.arraycopy (mnemonics, 0, newMnemonics, 0, linkIndex + 1);
        mnemonics = newMnemonics;
    }
    return result.toString ();
}

int parseMnemonics (char[] buffer, int start, int end, StringBuffer result) {
    int mnemonic = -1, index = start;
    while (index < end) {
        ptrdiff_t incr = 1;
        if ( buffer[index] is '&') {
            if (index + 1 < end && buffer [index + 1] is '&') {
                result.append (buffer [index]);
                index++;
            } else {
                mnemonic = result.length();
            }
        } else {
            result.append (buffer.dcharAsStringAt(index, incr));
        }
        index+=incr;
    }
    return mnemonic;
}

override int setBounds(int x, int y, int width, int height, bool move, bool resize) {
    int result = super.setBounds (x, y, width,height, move, resize);
    if ((result & RESIZED) !is 0) {
        layout.setWidth (width > 0 ? width : -1);
        redraw ();
    }
    return result;
}

override void setFontDescription (PangoFontDescription* font) {
    super.setFontDescription (font);
    layout.setFont (Font.gtk_new (display, font));
}

/**
 * Sets the receiver's text.
 * <p>
 * The string can contain both regular text and hyperlinks.  A hyperlink
 * is delimited by an anchor tag, &lt;A&gt; and &lt;/A&gt;.  Within an
 * anchor, a single HREF attribute is supported.  When a hyperlink is
 * selected, the text field of the selection event contains either the
 * text of the hyperlink or the value of its HREF, if one was specified.
 * In the rare case of identical hyperlinks within the same string, the
 * HREF tag can be used to distinguish between them.  The string may
 * include the mnemonic character and line delimiters.
 * </p>
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
    if (string.equals(text)) return;
    text = string;
    layout.setText (parse (string));
    focusIndex = offsets.length > 0 ? 0 : -1;
    selection.x = selection.y = -1;
    bool enabled = (state & DISABLED) is 0;
    TextStyle linkStyle = new TextStyle (null, enabled ? linkColor : disabledColor, null);
    linkStyle.underline = true;
    int [] bidiSegments = new int [offsets.length*2];
    for (int i = 0; i < offsets.length; i++) {
        Point point = offsets [i];
        layout.setStyle (linkStyle, point.x, point.y);
        bidiSegments[i*2] = point.x;
        bidiSegments[i*2+1] = point.y+1;
    }
    layout.setSegments (bidiSegments);
    TextStyle mnemonicStyle = new TextStyle (null, null, null);
    mnemonicStyle.underline = true;
    for (int i = 0; i < mnemonics.length; i++) {
        int mnemonic  = mnemonics [i];
        if (mnemonic !is -1) {
            layout.setStyle (mnemonicStyle, mnemonic, mnemonic);
        }
    }
    redraw ();
}

override void showWidget () {
    super.showWidget ();
    fixStyle (handle);
}

override int traversalCode (int key, GdkEventKey* event) {
    if (offsets.length is 0) return 0;
    int bits = super.traversalCode (key, event);
    if (key is OS.GDK_Tab && focusIndex < offsets.length - 1) {
        return bits & ~SWT.TRAVERSE_TAB_NEXT;
    }
    if (key is OS.GDK_ISO_Left_Tab && focusIndex > 0) {
        return bits & ~SWT.TRAVERSE_TAB_PREVIOUS;
    }
    return bits;
}
}
