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
module org.eclipse.swt.widgets.Canvas;

import org.eclipse.swt.widgets.Composite;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.widgets.Caret;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.IME;

import java.lang.all;

/**
 * Instances of this class provide a surface for drawing
 * arbitrary graphics.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * This class may be subclassed by custom control implementors
 * who are building controls that are <em>not</em> constructed
 * from aggregates of other controls. That is, they are either
 * painted using SWT graphics calls or are handled by native
 * methods.
 * </p>
 *
 * @see Composite
 * @see <a href="http://www.eclipse.org/swt/snippets/#canvas">Canvas snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class Canvas : Composite {

    alias Composite.drawBackground drawBackground;
    alias Composite.windowProc windowProc;

    Caret caret;
    IME ime;

/**
 * Prevents uninitialized instances from being created outside the package.
 */
this () {
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
 * </ul>
 *
 * @see SWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, style);
}

void clearArea (int x, int y, int width, int height) {
    checkWidget ();
    if (OS.IsWindowVisible (handle)) {
        RECT rect;
        OS.SetRect (&rect, x, y, x + width, y + height);
        auto hDC = OS.GetDCEx (handle, null, OS.DCX_CACHE | OS.DCX_CLIPCHILDREN | OS.DCX_CLIPSIBLINGS);
        drawBackground (hDC, &rect);
        OS.ReleaseDC (handle, hDC);
    }
}

/**
 * Fills the interior of the rectangle specified by the arguments,
 * with the receiver's background.
 *
 * @param gc the gc where the rectangle is to be filled
 * @param x the x coordinate of the rectangle to be filled
 * @param y the y coordinate of the rectangle to be filled
 * @param width the width of the rectangle to be filled
 * @param height the height of the rectangle to be filled
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the gc is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the gc has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void drawBackground (GC gc, int x, int y, int width, int height) {
    checkWidget ();
    if (gc is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
    RECT rect;
    OS.SetRect (&rect, x, y, x + width, y + height);
    auto hDC = gc.handle;
    int pixel = background is -1 ? gc.getBackground ().handle : -1;
    drawBackground (hDC, &rect, pixel);
}

/**
 * Returns the caret.
 * <p>
 * The caret for the control is automatically hidden
 * and shown when the control is painted or resized,
 * when focus is gained or lost and when an the control
 * is scrolled.  To avoid drawing on top of the caret,
 * the programmer must hide and show the caret when
 * drawing in the window any other time.
 * </p>
 *
 * @return the caret for the receiver, may be null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Caret getCaret () {
    checkWidget ();
    return caret;
}

/**
 * Returns the IME.
 *
 * @return the IME
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public IME getIME () {
    checkWidget ();
    return ime;
}

override
void releaseChildren (bool destroy) {
    if (caret !is null) {
        caret.release (false);
        caret = null;
    }
    if (ime !is null) {
        ime.release (false);
        ime = null;
    }
    super.releaseChildren (destroy);
}

/**
 * Scrolls a rectangular area of the receiver by first copying
 * the source area to the destination and then causing the area
 * of the source which is not covered by the destination to
 * be repainted. Children that intersect the rectangle are
 * optionally moved during the operation. In addition, outstanding
 * paint events are flushed before the source area is copied to
 * ensure that the contents of the canvas are drawn correctly.
 *
 * @param destX the x coordinate of the destination
 * @param destY the y coordinate of the destination
 * @param x the x coordinate of the source
 * @param y the y coordinate of the source
 * @param width the width of the area
 * @param height the height of the area
 * @param all <code>true</code>if children should be scrolled, and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void scroll (int destX, int destY, int x, int y, int width, int height, bool all) {
    checkWidget ();
    forceResize ();
    bool isFocus = caret !is null && caret.isFocusCaret ();
    if (isFocus) caret.killFocus ();
    RECT sourceRect;
    OS.SetRect (&sourceRect, x, y, x + width, y + height);
    RECT clientRect;
    OS.GetClientRect (handle, &clientRect);
    if (OS.IntersectRect (&clientRect, &sourceRect, &clientRect)) {
        static if (OS.IsWinCE) {
            OS.UpdateWindow (handle);
        } else {
            int flags = OS.RDW_UPDATENOW | OS.RDW_ALLCHILDREN;
            OS.RedrawWindow (handle, null, null, flags);
        }
    }
    int deltaX = destX - x, deltaY = destY - y;
    if (findImageControl () !is null) {
        static if (OS.IsWinCE) {
            OS.InvalidateRect (handle, &sourceRect, true);
        } else {
            { // scope for flags
            int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE;
            if (all) flags |= OS.RDW_ALLCHILDREN;
            OS.RedrawWindow (handle, &sourceRect, null, flags);
            }
        }
        OS.OffsetRect (&sourceRect, deltaX, deltaY);
        static if (OS.IsWinCE) {
            OS.InvalidateRect (handle, &sourceRect, true);
        } else {
            int flags = OS.RDW_ERASE | OS.RDW_FRAME | OS.RDW_INVALIDATE;
            if (all) flags |= OS.RDW_ALLCHILDREN;
            OS.RedrawWindow (handle, &sourceRect, null, flags);
        }
    } else {
        int flags = OS.SW_INVALIDATE | OS.SW_ERASE;
        /*
        * Feature in Windows.  If any child in the widget tree partially
        * intersects the scrolling rectangle, Windows moves the child
        * and copies the bits that intersect the scrolling rectangle but
        * does not redraw the child.
        *
        * Feature in Windows.  When any child in the widget tree does not
        * intersect the scrolling rectangle but the parent does intersect,
        * Windows does not move the child.  This is the documented (but
        * strange) Windows behavior.
        *
        * The fix is to not use SW_SCROLLCHILDREN and move the children
        * explicitly after scrolling.
        */
//      if (all) flags |= OS.SW_SCROLLCHILDREN;
        OS.ScrollWindowEx (handle, deltaX, deltaY, &sourceRect, null, null, null, flags);
    }
    if (all) {
        Control [] children = _getChildren ();
        for (int i=0; i<children.length; i++) {
            Control child = children [i];
            Rectangle rect = child.getBounds ();
            if (Math.min (x + width, rect.x + rect.width) >= Math.max (x, rect.x) &&
                Math.min (y + height, rect.y + rect.height) >= Math.max (y, rect.y)) {
                    child.setLocation (rect.x + deltaX, rect.y + deltaY);
            }
        }
    }
    if (isFocus) caret.setFocus ();
}

/**
 * Sets the receiver's caret.
 * <p>
 * The caret for the control is automatically hidden
 * and shown when the control is painted or resized,
 * when focus is gained or lost and when an the control
 * is scrolled.  To avoid drawing on top of the caret,
 * the programmer must hide and show the caret when
 * drawing in the window any other time.
 * </p>
 * @param caret the new caret for the receiver, may be null
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the caret has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setCaret (Caret caret) {
    checkWidget ();
    Caret newCaret = caret;
    Caret oldCaret = this.caret;
    this.caret = newCaret;
    if (hasFocus ()) {
        if (oldCaret !is null) oldCaret.killFocus ();
        if (newCaret !is null) {
            if (newCaret.isDisposed()) error(SWT.ERROR_INVALID_ARGUMENT);
            newCaret.setFocus ();
        }
    }
}

override public void setFont (Font font) {
    checkWidget ();
    if (caret !is null) caret.setFont (font);
    super.setFont (font);
}

/**
 * Sets the receiver's IME.
 *
 * @param ime the new IME for the receiver, may be null
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the IME has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public void setIME (IME ime) {
    checkWidget ();
    if (ime !is null && ime.isDisposed()) error(SWT.ERROR_INVALID_ARGUMENT);
    this.ime = ime;
}

override .LRESULT windowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (msg is Display.SWT_RESTORECARET) {
        if ((state & CANVAS) !is 0) {
            if (caret !is null) {
                caret.killFocus ();
                caret.setFocus ();
                return 1;
            }
        }
    }
    return super.windowProc (hwnd, msg, wParam, lParam);
}

override LRESULT WM_CHAR (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_CHAR (wParam, lParam);
    if (result !is null) return result;
    if (caret !is null) {
        switch (wParam) {
            case SWT.DEL:
            case SWT.BS:
            case SWT.ESC:
                break;
            default: {
                if (OS.GetKeyState (OS.VK_CONTROL) >= 0) {
                    int value;
                    if (OS.SystemParametersInfo (OS.SPI_GETMOUSEVANISH, 0, &value, 0)) {
                        if (value !is 0) OS.SetCursor (null);
                    }
                }
            }
        }
    }
    return result;
}

override LRESULT WM_IME_COMPOSITION (WPARAM wParam, LPARAM lParam) {
    if (ime !is null) {
        LRESULT result = ime.WM_IME_COMPOSITION (wParam, lParam);
        if (result !is null) return result;
    }

    /*
    * Bug in Windows.  On Korean Windows XP, the IME window
    * for the Korean Input System (MS-IME 2002) always opens
    * in the top left corner of the screen, despite the fact
    * that ImmSetCompositionWindow() was called to position
    * the IME when focus is gained.  The fix is to position
    * the IME on every WM_IME_COMPOSITION message.
    */
    if (!OS.IsWinCE && OS.WIN32_VERSION is OS.VERSION (5, 1)) {
        if (OS.IsDBLocale) {
            short langID = OS.GetSystemDefaultUILanguage ();
            short primaryLang = cast(short) OS.PRIMARYLANGID (langID);
            if (primaryLang is OS.LANG_KOREAN) {
                if (caret !is null && caret.isFocusCaret ()) {
                    POINT ptCurrentPos;
                    if (OS.GetCaretPos (&ptCurrentPos)) {
                        COMPOSITIONFORM lpCompForm;
                        lpCompForm.dwStyle = OS.CFS_POINT;
                        lpCompForm.ptCurrentPos.x = ptCurrentPos.x;
                        lpCompForm.ptCurrentPos.y = ptCurrentPos.y;
                        auto hIMC = OS.ImmGetContext (handle);
                        OS.ImmSetCompositionWindow (hIMC, &lpCompForm);
                        OS.ImmReleaseContext (handle, hIMC);
                    }
                }
            }
        }
    }
    return super.WM_IME_COMPOSITION (wParam, lParam);
}

override LRESULT WM_IME_COMPOSITION_START (WPARAM wParam, LPARAM lParam) {
    if (ime !is null) {
        LRESULT result = ime.WM_IME_COMPOSITION_START (wParam, lParam);
        if (result !is null) return result;
    }
    return super.WM_IME_COMPOSITION_START (wParam, lParam);
}

override LRESULT WM_IME_ENDCOMPOSITION (WPARAM wParam, LPARAM lParam) {
    if (ime !is null) {
        LRESULT result = ime.WM_IME_ENDCOMPOSITION (wParam, lParam);
        if (result !is null) return result;
    }
    return super.WM_IME_ENDCOMPOSITION (wParam, lParam);
}

override LRESULT WM_INPUTLANGCHANGE (WPARAM wParam, LPARAM lParam) {
    LRESULT result  = super.WM_INPUTLANGCHANGE (wParam, lParam);
    if (caret !is null && caret.isFocusCaret ()) {
        caret.setIMEFont ();
        caret.resizeIME ();
    }
    return result;
}

override LRESULT WM_KILLFOCUS (WPARAM wParam, LPARAM lParam) {
    if (ime !is null) {
        LRESULT result = ime.WM_KILLFOCUS (wParam, lParam);
        if (result !is null) return result;
    }
    LRESULT result  = super.WM_KILLFOCUS (wParam, lParam);
    if (caret !is null) caret.killFocus ();
    return result;
}

override LRESULT WM_LBUTTONDOWN (WPARAM wParam, LPARAM lParam) {
    if (ime !is null) {
        LRESULT result = ime.WM_LBUTTONDOWN (wParam, lParam);
        if (result !is null) return result;
    }
    return super.WM_LBUTTONDOWN (wParam, lParam);
}

override LRESULT WM_SETFOCUS (WPARAM wParam, LPARAM lParam) {
    LRESULT result  = super.WM_SETFOCUS (wParam, lParam);
    if (caret !is null) caret.setFocus ();
    return result;
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    LRESULT result  = super.WM_SIZE (wParam, lParam);
    if (caret !is null && caret.isFocusCaret ()) caret.resizeIME ();
    return result;
}

override LRESULT WM_WINDOWPOSCHANGED (WPARAM wParam, LPARAM lParam) {
    LRESULT result  = super.WM_WINDOWPOSCHANGED (wParam, lParam);
    //if (result !is null) return result;
    /*
    * Bug in Windows.  When a window with style WS_EX_LAYOUTRTL
    * that contains a caret is resized, Windows does not move the
    * caret in relation to the mirrored origin in the top right.
    * The fix is to hide the caret in WM_WINDOWPOSCHANGING and
    * show the caret in WM_WINDOWPOSCHANGED.
    */
    bool isFocus = (style & SWT.RIGHT_TO_LEFT) !is 0 && caret !is null && caret.isFocusCaret ();
    if (isFocus) caret.setFocus ();
    return result;
}

override LRESULT WM_WINDOWPOSCHANGING (WPARAM wParam, LPARAM lParam) {
    LRESULT result  = super.WM_WINDOWPOSCHANGING (wParam, lParam);
    if (result !is null) return result;
    /*
    * Bug in Windows.  When a window with style WS_EX_LAYOUTRTL
    * that contains a caret is resized, Windows does not move the
    * caret in relation to the mirrored origin in the top right.
    * The fix is to hide the caret in WM_WINDOWPOSCHANGING and
    * show the caret in WM_WINDOWPOSCHANGED.
    */
    bool isFocus = (style & SWT.RIGHT_TO_LEFT) !is 0 && caret !is null && caret.isFocusCaret ();
    if (isFocus) caret.killFocus ();
    return result;
}

}
