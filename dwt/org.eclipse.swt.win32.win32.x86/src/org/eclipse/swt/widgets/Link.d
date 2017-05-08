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
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;

import java.lang.all;

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
    alias Control.windowProc windowProc;

    String text;
    TextLayout layout;
    Color linkColor, disabledColor;
    Point [] offsets;
    Point selection;
    String [] ids;
    int [] mnemonics;
    int focusIndex, mouseDownIndex;
    HFONT font;
    mixin(gshared!(`static /+const+/ RGB LINK_FOREGROUND;`));
    mixin(gshared!(`static /+const+/ WNDPROC LinkProc;`));
    mixin(gshared!(`static const TCHAR[] LinkClass = OS.WC_LINK;`));

    mixin(gshared!(`private static bool static_this_completed = false;`));
    private static void static_this() {
        if( static_this_completed ){
            return;
        }
        synchronized {
            if( static_this_completed ){
                return;
            }
            LINK_FOREGROUND = new RGB (0, 51, 153);
            if (OS.COMCTL32_MAJOR >= 6) {
                WNDCLASS lpWndClass;
                OS.GetClassInfo (null, LinkClass.ptr, &lpWndClass);
                LinkProc = lpWndClass.lpfnWndProc;
            /*
            * Feature in Windows.  The SysLink window class
            * does not include CS_DBLCLKS.  This means that these
            * controls will not get double click messages such as
            * WM_LBUTTONDBLCLK.  The fix is to register a new
            * window class with CS_DBLCLKS.
            *
            * NOTE:  Screen readers look for the exact class name
            * of the control in order to provide the correct kind
            * of assistance.  Therefore, it is critical that the
            * new window class have the same name.  It is possible
            * to register a local window class with the same name
            * as a global class.  Since bits that affect the class
            * are being changed, it is possible that other native
            * code, other than SWT, could create a control with
            * this class name, and fail unexpectedly.
            */
            auto hInstance = OS.GetModuleHandle (null);
            auto hHeap = OS.GetProcessHeap ();
            lpWndClass.hInstance = hInstance;
            lpWndClass.style &= ~OS.CS_GLOBALCLASS;
            lpWndClass.style |= OS.CS_DBLCLKS;
            auto byteCount = LinkClass.length * TCHAR.sizeof;
            auto lpszClassName = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
            OS.MoveMemory (lpszClassName, LinkClass.ptr, byteCount);
            lpWndClass.lpszClassName = lpszClassName;
            OS.RegisterClass (&lpWndClass);
            OS.HeapFree (hHeap, 0, lpszClassName);
            } else {
                LinkProc = null;
            }
            static_this_completed = true;
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

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    if (LinkProc !is null) {
        /*
        * Feature in Windows.  By convention, native Windows controls
        * check for a non-NULL wParam, assume that it is an HDC and
        * paint using that device.  The SysLink control does not.
        * The fix is to check for an HDC and use WM_PRINTCLIENT.
        */
        switch (msg) {
            case OS.WM_PAINT:
                if (wParam !is 0) {
                    OS.SendMessage (hwnd, OS.WM_PRINTCLIENT, wParam, 0);
                    return 0;
                }
                break;
            default:
        }
        return OS.CallWindowProc (LinkProc, hwnd, msg, wParam, lParam);
    }
    return OS.DefWindowProc (hwnd, msg, wParam, lParam);
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    if (wHint !is SWT.DEFAULT && wHint < 0) wHint = 0;
    if (hHint !is SWT.DEFAULT && hHint < 0) hHint = 0;
    int width, height;
    if (OS.COMCTL32_MAJOR >= 6) {
        auto hDC = OS.GetDC (handle);
        auto newFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
        auto oldFont = OS.SelectObject (hDC, newFont);
        if (text.length > 0) {
            StringT buffer = StrToTCHARs (getCodePage (), parse (text));
            RECT rect;
            int flags = OS.DT_CALCRECT | OS.DT_NOPREFIX;
            if (wHint !is SWT.DEFAULT) {
                flags |= OS.DT_WORDBREAK;
                rect.right = wHint;
            }
            OS.DrawText (hDC, buffer.ptr, cast(int)/*64bit*/buffer.length, &rect, flags);
            width = rect.right - rect.left;
            height = rect.bottom;
        } else {
            TEXTMETRIC lptm;
            OS.GetTextMetrics (hDC, &lptm);
            width = 0;
            height = lptm.tmHeight;
        }
        if (newFont !is null) OS.SelectObject (hDC, oldFont);
        OS.ReleaseDC (handle, hDC);
    } else {
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
    }
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    int border = getBorderWidth ();
    width += border * 2;
    height += border * 2;
    return new Point (width, height);
}

override void createHandle () {
    super.createHandle ();
    state |= THEME_BACKGROUND;
    if (OS.COMCTL32_MAJOR < 6) {
        layout = new TextLayout (display);
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (4, 10)) {
            linkColor = Color.win32_new (display, OS.GetSysColor (OS.COLOR_HOTLIGHT));
        } else {
            linkColor = new Color (display, LINK_FOREGROUND);
        }
        disabledColor = Color.win32_new (display, OS.GetSysColor (OS.COLOR_GRAYTEXT));
        offsets = new Point [0];
        ids = new String [0];
        mnemonics = new int [0];
        selection = new Point (-1, -1);
        focusIndex = mouseDownIndex = -1;
    }
}

override void createWidget () {
    super.createWidget ();
    text = "";
    if (OS.COMCTL32_MAJOR < 6) {
        if ((style & SWT.MIRRORED) !is 0) {
            layout.setOrientation (SWT.RIGHT_TO_LEFT);
        }
        initAccessible ();
    }
}

void drawWidget (GC gc, RECT* rect) {
    drawBackground (gc.handle, rect);
    int selStart = selection.x;
    int selEnd = selection.y;
    if (selStart > selEnd) {
        selStart = selection.y;
        selEnd = selection.x;
    }
    // temporary code to disable text selection
    selStart = selEnd = -1;
    if (!OS.IsWindowEnabled (handle)) gc.setForeground (disabledColor);
    layout.draw (gc, 0, 0, selStart, selEnd, null, null);
    if (hasFocus () && focusIndex !is -1) {
        Rectangle [] rects = getRectangles (focusIndex);
        for (int i = 0; i < rects.length; i++) {
            Rectangle rectangle = rects [i];
            gc.drawFocus (rectangle.x, rectangle.y, rectangle.width, rectangle.height);
        }
    }
    if (hooks (SWT.Paint) || filters (SWT.Paint)) {
        Event event = new Event ();
        event.gc = gc;
        event.x = rect.left;
        event.y = rect.top;
        event.width = rect.right - rect.left;
        event.height = rect.bottom - rect.top;
        sendEvent (SWT.Paint, event);
        event.gc = null;
    }
}

override void enableWidget (bool enabled) {
    if (OS.COMCTL32_MAJOR >= 6) {
        LITEM item;
        item.mask = OS.LIF_ITEMINDEX | OS.LIF_STATE;
        item.stateMask = OS.LIS_ENABLED;
        item.state = enabled ? OS.LIS_ENABLED : 0;
        while (OS.SendMessage (handle, OS.LM_SETITEM, 0, &item) !is 0) {
            item.iLink++;
        }
    } else {
        TextStyle linkStyle = new TextStyle (null, enabled ? linkColor : disabledColor, null);
        linkStyle.underline = true;
        for (int i = 0; i < offsets.length; i++) {
            Point point = offsets [i];
            layout.setStyle (linkStyle, point.x, point.y);
        }
        redraw ();
    }
    /*
    * Feature in Windows.  For some reason, setting
    * LIS_ENABLED state using LM_SETITEM causes the
    * SysLink to become enabled.  To be specific,
    * calling IsWindowEnabled() returns true.  The
    * fix is disable the SysLink after LM_SETITEM.
    */
    super.enableWidget (enabled);
}

void initAccessible () {
    Accessible accessible = getAccessible ();
    accessible.addAccessibleListener (new class() AccessibleAdapter {
        override
        public void getName (AccessibleEvent e) {
            e.result = parse (text);
        }
    });

    accessible.addAccessibleControlListener (new class() AccessibleControlAdapter {
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

String parse (String string) {
    int length_ = cast(int)/*64bit*/string.length;
    offsets = new Point [length_ / 4];
    ids = new String [length_ / 4];
    mnemonics = new int [length_ / 4 + 1];
    StringBuffer result = new StringBuffer ();
    char [] buffer = new char [length_];
    string.getChars (0, cast(int)/*64bit*/string.length, buffer, 0);
    int index = 0, state = 0, linkIndex = 0;
    int start = 0, tagStart = 0, linkStart = 0, endtagStart = 0, refStart = 0;

    while (index < length_) {

        // instead Character.toLower
        // only needed for the control symbols, which are always ascii
        char c = buffer[index];
        if( c >= 'A' && c <= 'Z' ){
            c -= ( 'A' - 'a' );
        }

        // only simple ascii whitespace needed
        bool isWhitespace(char w ){
            switch(w){
                case ' ': return true;
                default : return false;
            }
        }

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
                        if (isWhitespace(c)) break;
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
                    int offset = cast(int)/*64bit*/result.length;
                    parseMnemonics (buffer, linkStart, endtagStart, result);
                    offsets [linkIndex] = new Point (offset, cast(int)/*64bit*/result.length - 1);
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
                if (isWhitespace (c)) {
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
        index++;
    }
    if (start < length_) {
        int tmp = parseMnemonics (buffer, start, tagStart, result);
        int mnemonic = parseMnemonics (buffer, Math.max (tagStart, linkStart), length_, result);
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
        if (buffer [index] is '&') {
            if (index + 1 < end && buffer [index + 1] is '&') {
                result.append (buffer [index]);
                index++;
            } else {
                mnemonic = result.length();
            }
        } else {
            result.append (buffer [index]);
        }
        index++;
    }
    return mnemonic;
}

override void releaseWidget () {
    super.releaseWidget ();
    if (layout !is null) layout.dispose ();
    layout = null;
    if (linkColor !is null) linkColor.dispose ();
    linkColor = null;
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
    // SWT extension: allow null string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (string.equals (text)) return;
    text = string;
    if (OS.COMCTL32_MAJOR >= 6) {
        bool enabled = cast(bool) OS.IsWindowEnabled (handle);
        /*
        * Bug in Windows.  For some reason, when SetWindowText()
        * is used to set the text of a link control to the empty
        * string, the old text remains.  The fix is to set the
        * text to a space instead.
        */
        if (string.length is 0) string = " ";  //$NON-NLS-1$
        LPCTSTR buffer = StrToTCHARz (getCodePage (), string);
        OS.SetWindowText (handle, buffer);
        parse (text);
        enableWidget (enabled);
    } else {
        layout.setText (parse (text));
        focusIndex = offsets.length > 0 ? 0 : -1;
        selection.x = selection.y = -1;
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        if (offsets.length > 0) {
            bits |= OS.WS_TABSTOP;
        } else {
            bits &= ~OS.WS_TABSTOP;
        }
        OS.SetWindowLong (handle, OS.GWL_STYLE, bits);
        bool enabled = cast(bool) OS.IsWindowEnabled (handle);
        TextStyle linkStyle = new TextStyle (null, enabled ? linkColor : disabledColor, null);
        linkStyle.underline = true;
        for (int i = 0; i < offsets.length; i++) {
            Point point = offsets [i];
            layout.setStyle (linkStyle, point.x, point.y);
        }
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
}

override int widgetStyle () {
    int bits = super.widgetStyle ();
    return bits | OS.WS_TABSTOP;
}

override String windowClass () {
    return OS.COMCTL32_MAJOR >= 6 ? TCHARsToStr(LinkClass) : display.windowClass();
}

override ptrdiff_t windowProc () {
    return LinkProc !is null ? cast(ptrdiff_t)LinkProc : display.windowProc();
}

override LRESULT WM_CHAR (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_CHAR (wParam, lParam);
    if (result !is null) return result;
    if (OS.COMCTL32_MAJOR < 6) {
        if (focusIndex is -1) return result;
        switch (wParam) {
            case ' ':
            case SWT.CR:
                Event event = new Event ();
                event.text = ids [focusIndex];
                sendEvent (SWT.Selection, event);
                break;
            case SWT.TAB:
                bool next = OS.GetKeyState (OS.VK_SHIFT) >= 0;
                if (next) {
                    if (focusIndex < offsets.length - 1) {
                        focusIndex++;
                        redraw ();
                    }
                } else {
                    if (focusIndex > 0) {
                        focusIndex--;
                        redraw ();
                    }
                }
                break;
            default:
        }
    } else {
        switch (wParam) {
            case ' ':
            case SWT.CR:
            case SWT.TAB:
                /*
                * NOTE: Call the window proc with WM_KEYDOWN rather than WM_CHAR
                * so that the key that was ignored during WM_KEYDOWN is processed.
                * This allows the application to cancel an operation that is normally
                * performed in WM_KEYDOWN from WM_CHAR.
                */
                auto code = callWindowProc (handle, OS.WM_KEYDOWN, wParam, lParam);
                return new LRESULT (code);
            default:
        }

    }
    return result;
}

override LRESULT WM_GETDLGCODE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_GETDLGCODE (wParam, lParam);
    if (result !is null) return result;
    int index, count;
    .LRESULT code = 0;
    if (OS.COMCTL32_MAJOR >= 6) {
        LITEM item;
        item.mask = OS.LIF_ITEMINDEX | OS.LIF_STATE;
        item.stateMask = OS.LIS_FOCUSED;
        index = 0;
        while (OS.SendMessage (handle, OS.LM_GETITEM, 0, &item) !is 0) {
            if ((item.state & OS.LIS_FOCUSED) !is 0) {
                index = item.iLink;
            }
            item.iLink++;
        }
        count = item.iLink;
        code = callWindowProc (handle, OS.WM_GETDLGCODE, wParam, lParam);
    } else {
        index = focusIndex;
        count = cast(int)/*64bit*/offsets.length;
    }
    if (count is 0) {
        return new LRESULT (code | OS.DLGC_STATIC);
    }
    bool next = OS.GetKeyState (OS.VK_SHIFT) >= 0;
    if (next && index < count - 1) {
        return new LRESULT (code | OS.DLGC_WANTTAB);
    }
    if (!next && index > 0) {
        return new LRESULT (code | OS.DLGC_WANTTAB);
    }
    return result;
}

override LRESULT WM_GETFONT (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_GETFONT (wParam, lParam);
    if (result !is null) return result;
    auto code = callWindowProc (handle, OS.WM_GETFONT, wParam, lParam);
    if (code !is 0) return new LRESULT (code);
    if (font is null) font = defaultFont ();
    return new LRESULT (font);
}

override LRESULT WM_KEYDOWN (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_KEYDOWN (wParam, lParam);
    if (result !is null) return result;
    if (OS.COMCTL32_MAJOR >= 6) {
        switch (wParam) {
            case OS.VK_SPACE:
            case OS.VK_RETURN:
            case OS.VK_TAB:
                /*
                * Ensure that the window proc does not process VK_SPACE,
                * VK_RETURN or VK_TAB so that it can be handled in WM_CHAR.
                * This allows the application to cancel an operation that
                * is normally performed in WM_KEYDOWN from WM_CHAR.
                */
                return LRESULT.ZERO;
            default:
        }
    }
    return result;
}

override LRESULT WM_KILLFOCUS (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_KILLFOCUS (wParam, lParam);
    if (OS.COMCTL32_MAJOR < 6) redraw ();
    return result;
}

override LRESULT WM_LBUTTONDOWN (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_LBUTTONDOWN (wParam, lParam);
    if (result is LRESULT.ZERO) return result;
    if (OS.COMCTL32_MAJOR < 6) {
        if (focusIndex !is -1) setFocus ();
        int x = OS.GET_X_LPARAM (lParam);
        int y = OS.GET_Y_LPARAM (lParam);
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
                    if (j !is focusIndex) {
                        redraw ();
                    }
                    focusIndex = mouseDownIndex = j;
                    return result;
                }
            }
        }
    }
    return result;
}

override LRESULT WM_LBUTTONUP (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_LBUTTONUP (wParam, lParam);
    if (result is LRESULT.ZERO) return result;
    if (OS.COMCTL32_MAJOR < 6) {
        if (mouseDownIndex is -1) return result;
        int x = OS.GET_X_LPARAM (lParam);
        int y = OS.GET_Y_LPARAM (lParam);
        Rectangle [] rects = getRectangles (mouseDownIndex);
        for (int i = 0; i < rects.length; i++) {
            Rectangle rect = rects [i];
            if (rect.contains (x, y)) {
                Event event = new Event ();
                event.text = ids [mouseDownIndex];
                sendEvent (SWT.Selection, event);
                break;
            }
        }
    }
    mouseDownIndex = -1;
    return result;
}

override LRESULT WM_NCHITTEST (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_NCHITTEST (wParam, lParam);
    if (result !is null) return result;

    /*
    * Feature in Windows. For WM_NCHITTEST, the Syslink window proc
    * returns HTTRANSPARENT when mouse is over plain text. The fix is
    * to always return HTCLIENT.
    */
    if (OS.COMCTL32_MAJOR >= 6) return new LRESULT (OS.HTCLIENT);

    return result;
}

override LRESULT WM_MOUSEMOVE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_MOUSEMOVE (wParam, lParam);
    if (OS.COMCTL32_MAJOR < 6) {
        int x = OS.GET_X_LPARAM (lParam);
        int y = OS.GET_Y_LPARAM (lParam);
        if (OS.GetKeyState (OS.VK_LBUTTON) < 0) {
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
    }
    return result;
}

override LRESULT WM_PAINT (WPARAM wParam, LPARAM lParam) {
    if (OS.COMCTL32_MAJOR >= 6) {
        return super.WM_PAINT (wParam, lParam);
    }
    PAINTSTRUCT ps;
    GCData data = new GCData ();
    data.ps = &ps;
    data.hwnd = handle;
    GC gc = new_GC (data);
    if (gc !is null) {
        int width = ps.rcPaint.right - ps.rcPaint.left;
        int height = ps.rcPaint.bottom - ps.rcPaint.top;
        if (width !is 0 && height !is 0) {
            RECT rect;
            OS.SetRect (&rect, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right, ps.rcPaint.bottom);
            drawWidget (gc, &rect);
        }
        gc.dispose ();
    }
    return LRESULT.ZERO;
}

override LRESULT WM_PRINTCLIENT (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_PRINTCLIENT (wParam, lParam);
    if (OS.COMCTL32_MAJOR < 6) {
        RECT rect;
        OS.GetClientRect (handle, &rect);
        GCData data = new GCData ();
        data.device = display;
        data.foreground = getForegroundPixel ();
        GC gc = GC.win32_new (cast(HANDLE)wParam, data);
        drawWidget (gc, &rect);
        gc.dispose ();
    }
    return result;
}

override LRESULT WM_SETFOCUS (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SETFOCUS (wParam, lParam);
    if (OS.COMCTL32_MAJOR < 6) redraw ();
    return result;
}

override LRESULT WM_SETFONT (WPARAM wParam, LPARAM lParam) {
    if (OS.COMCTL32_MAJOR < 6) {
        layout.setFont (Font.win32_new (display, cast(HANDLE)wParam));
    }
    if (lParam !is 0) OS.InvalidateRect (handle, null, true);
    font = cast(HFONT) wParam;
    return super.WM_SETFONT (wParam, lParam);
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SIZE (wParam, lParam);
    if (OS.COMCTL32_MAJOR < 6) {
        RECT rect;
        OS.GetClientRect (handle, &rect);
        layout.setWidth (rect.right > 0 ? rect.right : -1);
        redraw ();
    }
    return result;
}

override LRESULT wmColorChild (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.wmColorChild (wParam, lParam);
    /*
    * Feature in Windows.  When a SysLink is disabled, it does
    * not gray out the non-link portion of the text.  The fix
    * is to set the text color to the system gray color.
    */
    if (OS.COMCTL32_MAJOR >= 6) {
        if (!OS.IsWindowEnabled (handle)) {
            OS.SetTextColor (cast(HANDLE)wParam, OS.GetSysColor (OS.COLOR_GRAYTEXT));
            if (result is null) {
                int backPixel = getBackgroundPixel ();
                OS.SetBkColor (cast(HANDLE)wParam, backPixel);
                auto hBrush = findBrush (backPixel, OS.BS_SOLID);
                return new LRESULT (hBrush);
            }
        }
    }
    return result;
}

override LRESULT wmNotifyChild (NMHDR* hdr, WPARAM wParam, LPARAM lParam) {
    if (OS.COMCTL32_MAJOR >= 6) {
        switch (hdr.code) {
            case OS.NM_RETURN:
            case OS.NM_CLICK:
                NMLINK* item = cast(NMLINK*)lParam;
                //OS.MoveMemory (item, lParam, NMLINK.sizeof);
                Event event = new Event ();
                event.text = ids [item.item.iLink];
                sendEvent (SWT.Selection, event);
                break;
            default:
        }
    }
    return super.wmNotifyChild (hdr, wParam, lParam);
}
}

