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
module org.eclipse.swt.widgets.Label;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;

import java.lang.all;

/**
 * Instances of this class represent a non-selectable
 * user interface object that displays a string or image.
 * When SEPARATOR is specified, displays a single
 * vertical or horizontal line.
 * <p>
 * Shadow styles are hints and may not be honoured
 * by the platform.  To create a separator label
 * with the default shadow style for the platform,
 * do not specify a shadow style.
 * </p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>SEPARATOR, HORIZONTAL, VERTICAL</dd>
 * <dd>SHADOW_IN, SHADOW_OUT, SHADOW_NONE</dd>
 * <dd>CENTER, LEFT, RIGHT, WRAP</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: Only one of SHADOW_IN, SHADOW_OUT and SHADOW_NONE may be specified.
 * SHADOW_NONE is a HINT. Only one of HORIZONTAL and VERTICAL may be specified.
 * Only one of CENTER, LEFT and RIGHT may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#label">Label snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Label : Control {

    alias Control.computeSize computeSize;
    alias Control.windowProc windowProc;

    String text = "";
    Image image;
    static const int MARGIN = 4;
    static const bool IMAGE_AND_TEXT = false;
    mixin(gshared!(`private static /+const+/ WNDPROC LabelProc;`));
    static const TCHAR[] LabelClass = "STATIC\0";

    mixin(gshared!(`private static bool static_this_completed = false;`));
    private static void static_this() {
        if( static_this_completed ){
            return;
        }
        synchronized {
            if( static_this_completed ){
                return;
            }
            WNDCLASS lpWndClass;
            OS.GetClassInfo (null, LabelClass.ptr, &lpWndClass);
            LabelProc = lpWndClass.lpfnWndProc;
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
 * @see SWT#SEPARATOR
 * @see SWT#HORIZONTAL
 * @see SWT#VERTICAL
 * @see SWT#SHADOW_IN
 * @see SWT#SHADOW_OUT
 * @see SWT#SHADOW_NONE
 * @see SWT#CENTER
 * @see SWT#LEFT
 * @see SWT#RIGHT
 * @see SWT#WRAP
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    static_this();
    super (parent, checkStyle (style));
}

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    return OS.CallWindowProc (LabelProc, hwnd, msg, wParam, lParam);
}

static int checkStyle (int style) {
    style |= SWT.NO_FOCUS;
    if ((style & SWT.SEPARATOR) !is 0) {
        style = checkBits (style, SWT.VERTICAL, SWT.HORIZONTAL, 0, 0, 0, 0);
        return checkBits (style, SWT.SHADOW_OUT, SWT.SHADOW_IN, SWT.SHADOW_NONE, 0, 0, 0);
    }
    return checkBits (style, SWT.LEFT, SWT.CENTER, SWT.RIGHT, 0, 0, 0);
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = 0, height = 0, border = getBorderWidth ();
    if ((style & SWT.SEPARATOR) !is 0) {
        int lineWidth = OS.GetSystemMetrics (OS.SM_CXBORDER);
        if ((style & SWT.HORIZONTAL) !is 0) {
            width = DEFAULT_WIDTH;  height = lineWidth * 2;
        } else {
            width = lineWidth * 2; height = DEFAULT_HEIGHT;
        }
        if (wHint !is SWT.DEFAULT) width = wHint;
        if (hHint !is SWT.DEFAULT) height = hHint;
        width += border * 2; height += border * 2;
        return new Point (width, height);
    }
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    bool drawText = true;
    bool drawImage = (bits & OS.SS_OWNERDRAW) is OS.SS_OWNERDRAW;
    if (drawImage) {
        if (image !is null) {
            Rectangle rect = image.getBounds();
            width += rect.width;
            height += rect.height;
            if (IMAGE_AND_TEXT) {
                if (text.length !is 0) width += MARGIN;
            } else {
                drawText = false;
            }
        }
    }
    if (drawText) {
        auto hDC = OS.GetDC (handle);
        auto newFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
        auto oldFont = OS.SelectObject (hDC, newFont);
        int length = OS.GetWindowTextLength (handle);
        if (length is 0) {
            TEXTMETRIC tm;
            OS.GetTextMetrics (hDC, &tm);
            height = Math.max (height, tm.tmHeight);
        } else {
            RECT rect;
            int flags = OS.DT_CALCRECT | OS.DT_EDITCONTROL | OS.DT_EXPANDTABS;
            if ((style & SWT.WRAP) !is 0 && wHint !is SWT.DEFAULT) {
                flags |= OS.DT_WORDBREAK;
                rect.right = Math.max (0, wHint - width);
            }
            TCHAR[] buffer = new TCHAR [/+getCodePage (),+/ length + 1];
            OS.GetWindowText (handle, buffer.ptr, length + 1);
            OS.DrawText (hDC, buffer.ptr, length, &rect, flags);
            width += rect.right - rect.left;
            height = Math.max (height, rect.bottom - rect.top);
        }
        if (newFont !is null) OS.SelectObject (hDC, oldFont);
        OS.ReleaseDC (handle, hDC);
    }
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    width += border * 2;
    height += border * 2;
    /*
    * Feature in WinCE PPC.  Text labels have a trim
    * of one pixel wide on the right and left side.
    * The fix is to increase the width to include
    * this trim.
    */
    if (OS.IsWinCE && !drawImage) width += 2;
    return new Point (width, height);
}

override void createHandle () {
    super.createHandle ();
    state |= THEME_BACKGROUND;
}

/**
 * Returns a value which describes the position of the
 * text or image in the receiver. The value will be one of
 * <code>LEFT</code>, <code>RIGHT</code> or <code>CENTER</code>
 * unless the receiver is a <code>SEPARATOR</code> label, in
 * which case, <code>NONE</code> is returned.
 *
 * @return the alignment
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getAlignment () {
    checkWidget ();
    if ((style & SWT.SEPARATOR) !is 0) return 0;
    if ((style & SWT.LEFT) !is 0) return SWT.LEFT;
    if ((style & SWT.CENTER) !is 0) return SWT.CENTER;
    if ((style & SWT.RIGHT) !is 0) return SWT.RIGHT;
    return SWT.LEFT;
}

/**
 * Returns the receiver's image if it has one, or null
 * if it does not.
 *
 * @return the receiver's image
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Image getImage () {
    checkWidget ();
    return image;
}

override String getNameText () {
    return getText ();
}

/**
 * Returns the receiver's text, which will be an empty
 * string if it has never been set or if the receiver is
 * a <code>SEPARATOR</code> label.
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
    if ((style & SWT.SEPARATOR) !is 0) return "";
    return text;
}

override bool mnemonicHit (wchar key) {
    Composite control = this.parent;
    while (control !is null) {
        Control [] children = control._getChildren ();
        int index = 0;
        while (index < children.length) {
            if (children [index] is this) break;
            index++;
        }
        index++;
        if (index < children.length) {
            if (children [index].setFocus ()) return true;
        }
        control = control.parent;
    }
    return false;
}

override bool mnemonicMatch (wchar key) {
    wchar mnemonic = findMnemonic (getText ());
    if (mnemonic is '\0') return false;
    return CharacterToUpper (key) is CharacterToUpper (mnemonic);
}

override void releaseWidget () {
    super.releaseWidget ();
    text = null;
    image = null;
}

/**
 * Controls how text and images will be displayed in the receiver.
 * The argument should be one of <code>LEFT</code>, <code>RIGHT</code>
 * or <code>CENTER</code>.  If the receiver is a <code>SEPARATOR</code>
 * label, the argument is ignored and the alignment is not changed.
 *
 * @param alignment the new alignment
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setAlignment (int alignment) {
    checkWidget ();
    if ((style & SWT.SEPARATOR) !is 0) return;
    if ((alignment & (SWT.LEFT | SWT.RIGHT | SWT.CENTER)) is 0) return;
    style &= ~(SWT.LEFT | SWT.RIGHT | SWT.CENTER);
    style |= alignment & (SWT.LEFT | SWT.RIGHT | SWT.CENTER);
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    if ((bits & OS.SS_OWNERDRAW) !is OS.SS_OWNERDRAW) {
        bits &= ~(OS.SS_LEFTNOWORDWRAP | OS.SS_CENTER | OS.SS_RIGHT);
        if ((style & SWT.LEFT) !is 0) {
            if ((style & SWT.WRAP) !is 0) {
                bits |= OS.SS_LEFT;
            } else {
                bits |= OS.SS_LEFTNOWORDWRAP;
            }
        }
        if ((style & SWT.CENTER) !is 0) bits |= OS.SS_CENTER;
        if ((style & SWT.RIGHT) !is 0) bits |= OS.SS_RIGHT;
        OS.SetWindowLong (handle, OS.GWL_STYLE, bits);
    }
    OS.InvalidateRect (handle, null, true);
}

/**
 * Sets the receiver's image to the argument, which may be
 * null indicating that no image should be displayed.
 *
 * @param image the image to display on the receiver (may be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setImage (Image image) {
    checkWidget ();
    if ((style & SWT.SEPARATOR) !is 0) return;
    if (image !is null && image.isDisposed()) error(SWT.ERROR_INVALID_ARGUMENT);
    this.image = image;
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    if ((bits & OS.SS_OWNERDRAW) !is OS.SS_OWNERDRAW) {
        bits &= ~(OS.SS_LEFTNOWORDWRAP | OS.SS_CENTER | OS.SS_RIGHT);
        bits |= OS.SS_OWNERDRAW;
        OS.SetWindowLong (handle, OS.GWL_STYLE, bits);
    }
    OS.InvalidateRect (handle, null, true);
}

/**
 * Sets the receiver's text.
 * <p>
 * This method sets the widget label.  The label may include
 * the mnemonic character and line delimiters.
 * </p>
 * <p>
 * Mnemonics are indicated by an '&amp;' that causes the next
 * character to be the mnemonic.  When the user presses a
 * key sequence that matches the mnemonic, focus is assigned
 * to the control that follows the label. On most platforms,
 * the mnemonic appears underlined but may be emphasised in a
 * platform specific manner.  The mnemonic indicator character
 * '&amp;' can be escaped by doubling it in the string, causing
 * a single '&amp;' to be displayed.
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
    // SWT extensions allow null argument
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if ((style & SWT.SEPARATOR) !is 0) return;
    /*
    * Feature in Windows.  For some reason, SetWindowText() for
    * static controls redraws the control, even when the text has
    * has not changed.  The fix is to check for this case and do
    * nothing.
    */
    if (string.equals(text)) return;
    text = string;
    if (image is null || !IMAGE_AND_TEXT) {
        int oldBits = OS.GetWindowLong (handle, OS.GWL_STYLE), newBits = oldBits;
        newBits &= ~OS.SS_OWNERDRAW;
        if ((style & SWT.LEFT) !is 0) {
            if ((style & SWT.WRAP) !is 0) {
                newBits |= OS.SS_LEFT;
            } else {
                newBits |= OS.SS_LEFTNOWORDWRAP;
            }
        }
        if ((style & SWT.CENTER) !is 0) newBits |= OS.SS_CENTER;
        if ((style & SWT.RIGHT) !is 0) newBits |= OS.SS_RIGHT;
        if (oldBits !is newBits) OS.SetWindowLong (handle, OS.GWL_STYLE, newBits);
    }
    string = Display.withCrLf (string);
    LPCTSTR buffer = StrToTCHARz ( getCodePage (), string);
    OS.SetWindowText (handle, buffer);
    /*
    * Bug in Windows.  For some reason, the HBRUSH that
    * is returned from WM_CTRLCOLOR is misaligned when
    * the label uses it to draw.  If the brush is a solid
    * color, this does not matter.  However, if the brush
    * contains an image, the image is misaligned.  The
    * fix is to draw the background in WM_ERASEBKGND.
    */
    if (OS.COMCTL32_MAJOR < 6) {
        if (findImageControl () !is null) OS.InvalidateRect (handle, null, true);
    }
}

override int widgetExtStyle () {
    int bits = super.widgetExtStyle () & ~OS.WS_EX_CLIENTEDGE;
    if ((style & SWT.BORDER) !is 0) return bits | OS.WS_EX_STATICEDGE;
    return bits;
}

override int widgetStyle () {
    int bits = super.widgetStyle () | OS.SS_NOTIFY;
    if ((style & SWT.SEPARATOR) !is 0) return bits | OS.SS_OWNERDRAW;
    if (OS.WIN32_VERSION >= OS.VERSION (5, 0)) {
        if ((style & SWT.WRAP) !is 0) bits |= OS.SS_EDITCONTROL;
    }
    if ((style & SWT.CENTER) !is 0) return bits | OS.SS_CENTER;
    if ((style & SWT.RIGHT) !is 0) return bits | OS.SS_RIGHT;
    if ((style & SWT.WRAP) !is 0) return bits | OS.SS_LEFT;
    return bits | OS.SS_LEFTNOWORDWRAP;
}

override String windowClass () {
    return TCHARsToStr( LabelClass );
}

override ptrdiff_t windowProc () {
    return cast(ptrdiff_t) LabelProc;
}

override LRESULT WM_ERASEBKGND (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_ERASEBKGND (wParam, lParam);
    if (result !is null) return result;
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    if ((bits & OS.SS_OWNERDRAW) is OS.SS_OWNERDRAW) {
        return LRESULT.ONE;
    }
    /*
    * Bug in Windows.  For some reason, the HBRUSH that
    * is returned from WM_CTRLCOLOR is misaligned when
    * the label uses it to draw.  If the brush is a solid
    * color, this does not matter.  However, if the brush
    * contains an image, the image is misaligned.  The
    * fix is to draw the background in WM_ERASEBKGND.
    */
    if (OS.COMCTL32_MAJOR < 6) {
        if (findImageControl () !is null) {
            drawBackground (cast(HANDLE)wParam);
            return LRESULT.ONE;
        }
    }
    return result;
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SIZE (wParam, lParam);
    if (isDisposed ()) return result;
    if ((style & SWT.SEPARATOR) !is 0) {
        OS.InvalidateRect (handle, null, true);
        return result;
    }
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    if ((bits & OS.SS_OWNERDRAW) is OS.SS_OWNERDRAW) {
        OS.InvalidateRect (handle, null, true);
        return result;
    }
    /*
    * Bug in Windows.  For some reason, a label with
    * style SS_LEFT, SS_CENTER or SS_RIGHT does not
    * redraw the text in the new position when resized.
    * Note that SS_LEFTNOWORDWRAP does not have the
    * problem.  The fix is to force the redraw.
    */
    if ((bits & OS.SS_LEFTNOWORDWRAP) !is OS.SS_LEFTNOWORDWRAP) {
        OS.InvalidateRect (handle, null, true);
        return result;
    }
    return result;
}

override LRESULT WM_UPDATEUISTATE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_UPDATEUISTATE (wParam, lParam);
    if (result !is null) return result;
    /*
    * Feature in Windows.  When WM_UPDATEUISTATE is sent to
    * a static control, it sends WM_CTLCOLORSTATIC to get the
    * foreground and background.  If any drawing happens in
    * WM_CTLCOLORSTATIC, it overwrites the contents of the control.
    * The fix is draw the static without drawing the background
    * and avoid the static window proc.
    */
    bool redraw = findImageControl () !is null;
    if (!redraw) {
        if ((state & THEME_BACKGROUND) !is 0) {
            if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
                redraw = findThemeControl () !is null;
            }
        }
    }
    if (redraw) {
        OS.InvalidateRect (handle, null, false);
        auto code = OS.DefWindowProc (handle, OS.WM_UPDATEUISTATE, wParam, lParam);
        return new LRESULT (code);
    }
    return result;
}

override LRESULT wmColorChild (WPARAM wParam, LPARAM lParam) {
    /*
    * Bug in Windows.  For some reason, the HBRUSH that
    * is returned from WM_CTRLCOLOR is misaligned when
    * the label uses it to draw.  If the brush is a solid
    * color, this does not matter.  However, if the brush
    * contains an image, the image is misaligned.  The
    * fix is to draw the background in WM_ERASEBKGND.
    */
    LRESULT result = super.wmColorChild (wParam, lParam);
    if (OS.COMCTL32_MAJOR < 6) {
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        if ((bits & OS.SS_OWNERDRAW) !is OS.SS_OWNERDRAW) {
            if (findImageControl () !is null) {
                OS.SetBkMode ( cast(HANDLE) wParam, OS.TRANSPARENT);
                return new LRESULT (OS.GetStockObject (OS.NULL_BRUSH));
            }
        }
    }
    return result;
}

override LRESULT WM_PAINT (WPARAM wParam, LPARAM lParam) {
    static if (OS.IsWinCE) {
        bool drawImage = image !is null;
        bool drawSeparator = (style & SWT.SEPARATOR) !is 0 && (style & SWT.SHADOW_NONE) is 0;
        if (drawImage || drawSeparator) {
            LRESULT result = null;
            PAINTSTRUCT ps;
            GCData data = new GCData ();
            data.ps = &ps;
            data.hwnd = handle;
            GC gc = new_GC (data);
            if (gc !is null) {
                drawBackground (gc.handle);
                RECT clientRect;
                OS.GetClientRect (handle, &clientRect);
                if (drawSeparator) {
                    RECT rect;
                    int lineWidth = OS.GetSystemMetrics (OS.SM_CXBORDER);
                    int flags = (style & SWT.SHADOW_IN) !is 0 ? OS.EDGE_SUNKEN : OS.EDGE_ETCHED;
                    if ((style & SWT.HORIZONTAL) !is 0) {
                        int bottom = clientRect.top + Math.max (lineWidth * 2, (clientRect.bottom - clientRect.top) / 2);
                        OS.SetRect (&rect, clientRect.left, clientRect.top, clientRect.right, bottom);
                        OS.DrawEdge (gc.handle, &rect, flags, OS.BF_BOTTOM);
                    } else {
                        int right = clientRect.left + Math.max (lineWidth * 2, (clientRect.right - clientRect.left) / 2);
                        OS.SetRect (&rect, clientRect.left, clientRect.top, right, clientRect.bottom);
                        OS.DrawEdge (gc.handle, &rect, flags, OS.BF_RIGHT);
                    }
                    result = LRESULT.ONE;
                }
                if (drawImage) {
                    Rectangle imageBounds = image.getBounds ();
                    int x = 0;
                    if ((style & SWT.CENTER) !is 0) {
                        x = Math.max (0, (clientRect.right - imageBounds.width) / 2);
                    } else {
                        if ((style & SWT.RIGHT) !is 0) {
                            x = Math.max (0, (clientRect.right - imageBounds.width));
                        }
                    }
                    gc.drawImage (image, x, Math.max (0, (clientRect.bottom - imageBounds.height) / 2));
                    result = LRESULT.ONE;
                }
                int width = ps.rcPaint.right - ps.rcPaint.left;
                int height = ps.rcPaint.bottom - ps.rcPaint.top;
                if (width !is 0 && height !is 0) {
                    Event event = new Event ();
                    event.gc = gc;
                    event.x = ps.rcPaint.left;
                    event.y = ps.rcPaint.top;
                    event.width = width;
                    event.height = height;
                    sendEvent (SWT.Paint, event);
                    // widget could be disposed at this point
                    event.gc = null;
                }
                gc.dispose ();
            }
            return result;
        }
    }
    return super.WM_PAINT(wParam, lParam);
}

override LRESULT wmDrawChild (WPARAM wParam, LPARAM lParam) {
    DRAWITEMSTRUCT* struct_ = cast(DRAWITEMSTRUCT*)lParam;
    drawBackground (struct_.hDC);
    if ((style & SWT.SEPARATOR) !is 0) {
        if ((style & SWT.SHADOW_NONE) !is 0) return null;
        RECT rect;
        int lineWidth = OS.GetSystemMetrics (OS.SM_CXBORDER);
        int flags = (style & SWT.SHADOW_IN) !is 0 ? OS.EDGE_SUNKEN : OS.EDGE_ETCHED;
        if ((style & SWT.HORIZONTAL) !is 0) {
            int bottom = struct_.rcItem.top + Math.max (lineWidth * 2, (struct_.rcItem.bottom - struct_.rcItem.top) / 2);
            OS.SetRect (&rect, struct_.rcItem.left, struct_.rcItem.top, struct_.rcItem.right, bottom);
            OS.DrawEdge (struct_.hDC, &rect, flags, OS.BF_BOTTOM);
        } else {
            int right = struct_.rcItem.left + Math.max (lineWidth * 2, (struct_.rcItem.right - struct_.rcItem.left) / 2);
            OS.SetRect (&rect, struct_.rcItem.left, struct_.rcItem.top, right, struct_.rcItem.bottom);
            OS.DrawEdge (struct_.hDC, &rect, flags, OS.BF_RIGHT);
        }
    } else {
        int width = struct_.rcItem.right - struct_.rcItem.left;
        int height = struct_.rcItem.bottom - struct_.rcItem.top;
        if (width !is 0 && height !is 0) {
            bool drawImage = image !is null;
            bool drawText = IMAGE_AND_TEXT && text.length !is 0;
            int margin = drawText && drawImage ? MARGIN : 0;
            int imageWidth = 0, imageHeight = 0;
            if (drawImage) {
                Rectangle rect = image.getBounds ();
                imageWidth = rect.width;
                imageHeight = rect.height;
            }
            RECT rect;
            LPCTSTR buffer = null;
            int textWidth = 0, textHeight = 0, flags = 0;
            if (drawText) {
                //rect = new RECT ();
                flags = OS.DT_CALCRECT | OS.DT_EDITCONTROL | OS.DT_EXPANDTABS;
                if ((style & SWT.LEFT) !is 0) flags |= OS.DT_LEFT;
                if ((style & SWT.CENTER) !is 0) flags |= OS.DT_CENTER;
                if ((style & SWT.RIGHT) !is 0) flags |= OS.DT_RIGHT;
                if ((style & SWT.WRAP) !is 0) {
                    flags |= OS.DT_WORDBREAK;
                    rect.right = Math.max (0, width - imageWidth - margin);
                }
                buffer = StrToTCHARz (/+getCodePage (),+/ text);
                OS.DrawText (struct_.hDC, buffer, -1, &rect, flags);
                textWidth = rect.right - rect.left;
                textHeight = rect.bottom - rect.top;
            }
            int x = 0;
            if ((style & SWT.CENTER) !is 0) {
                x = Math.max (0, (width - imageWidth - textWidth - margin) / 2);
            } else {
                if ((style & SWT.RIGHT) !is 0) {
                    x = width - imageWidth - textWidth - margin;
                }
            }
            if (drawImage) {
                GCData data = new GCData();
                data.device = display;
                GC gc = GC.win32_new (struct_.hDC, data);
                Image image = getEnabled () ? this.image : new Image (display, this.image, SWT.IMAGE_DISABLE);
                gc.drawImage (image, x, Math.max (0, (height - imageHeight) / 2));
                if (image !is this.image) image.dispose ();
                gc.dispose ();
                x += imageWidth + margin;
            }
            if (drawText) {
                flags &= ~OS.DT_CALCRECT;
                rect.left = x;
                rect.right += rect.left;
                rect.top = Math.max (0, (height - textHeight) / 2);
                rect.bottom += rect.top;
                OS.DrawText (struct_.hDC, buffer, -1, &rect, flags);
            }
        }
    }
    return null;
}

}

