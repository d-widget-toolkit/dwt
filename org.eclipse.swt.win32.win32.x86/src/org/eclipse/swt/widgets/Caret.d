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
module org.eclipse.swt.widgets.Caret;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.Canvas;
import org.eclipse.swt.widgets.IME;

import java.lang.all;

/**
 * Instances of this class provide an i-beam that is typically used
 * as the insertion point for text.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 * 
 * @see <a href="http://www.eclipse.org/swt/snippets/#caret">Caret snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample, Canvas tab</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class Caret : Widget {
    Canvas parent;
    int x, y, width, height;
    bool moved, resized;
    bool isVisible_;
    Image image;
    Font font;
    LOGFONT* oldFont;

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
 * @see SWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Canvas parent, int style) {
    super (parent, style);
    this.parent = parent;
    createWidget ();
}

void createWidget () {
    isVisible_ = true;
    if (parent.getCaret () is null) {
        parent.setCaret (this);
    }
}

HFONT defaultFont () {
    auto hwnd = parent.handle;
    auto hwndIME = OS.ImmGetDefaultIMEWnd (hwnd);
    HFONT hFont;
    if (hwndIME !is null) {
        hFont = cast(HFONT) OS.SendMessage (hwndIME, OS.WM_GETFONT, 0, 0);
    }
    if (hFont is null) {
        hFont = cast(HFONT) OS.SendMessage (hwnd, OS.WM_GETFONT, 0, 0);
    }
    if (hFont is null) return parent.defaultFont ();
    return hFont;
}

/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent (or its display if its parent is null).
 *
 * @return the receiver's bounding rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Rectangle getBounds () {
    checkWidget();
    if (image !is null) {
        Rectangle rect = image.getBounds ();
        return new Rectangle (x, y, rect.width, rect.height);
    } else {
        if (!OS.IsWinCE && width is 0) {
            int buffer;
            if (OS.SystemParametersInfo (OS.SPI_GETCARETWIDTH, 0, &buffer, 0)) {
                return new Rectangle (x, y, buffer, height);
            }
        }
    }
    return new Rectangle (x, y, width, height);
}

/**
 * Returns the font that the receiver will use to paint textual information.
 *
 * @return the receiver's font
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Font getFont () {
    checkWidget();
    if (font is null) {
        HFONT hFont = defaultFont ();
        return Font.win32_new (display, hFont);
    }
    return font;
}

/**
 * Returns the image that the receiver will use to paint the caret.
 *
 * @return the receiver's image
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Image getImage () {
    checkWidget();
    return image;
}

/**
 * Returns a point describing the receiver's location relative
 * to its parent (or its display if its parent is null).
 *
 * @return the receiver's location
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getLocation () {
    checkWidget();
    return new Point (x, y);
}

/**
 * Returns the receiver's parent, which must be a <code>Canvas</code>.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Canvas getParent () {
    checkWidget();
    return parent;
}

/**
 * Returns a point describing the receiver's size.
 *
 * @return the receiver's size
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getSize () {
    checkWidget();
    if (image !is null) {
        Rectangle rect = image.getBounds ();
        return new Point (rect.width, rect.height);
    } else {
        if (!OS.IsWinCE && width is 0) {
            int buffer;
            if (OS.SystemParametersInfo (OS.SPI_GETCARETWIDTH, 0, &buffer, 0)) {
                return new Point (buffer, height);
            }
        }
    }
    return new Point (width, height);
}

/**
 * Returns <code>true</code> if the receiver is visible, and
 * <code>false</code> otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, this method
 * may still indicate that it is considered visible even though
 * it may not actually be showing.
 * </p>
 *
 * @return the receiver's visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getVisible () {
    checkWidget();
    return isVisible_;
}

bool hasFocus () {
    return parent.handle is OS.GetFocus ();
}

bool isFocusCaret () {
    return parent.caret is this && hasFocus ();
}

/**
 * Returns <code>true</code> if the receiver is visible and all
 * of the receiver's ancestors are visible and <code>false</code>
 * otherwise.
 *
 * @return the receiver's visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getVisible
 */
public bool isVisible () {
    checkWidget();
    return isVisible_ && parent.isVisible () && hasFocus ();
}

void killFocus () {
    OS.DestroyCaret ();
    restoreIMEFont ();
}

void move () {
    moved = false;
    if (!OS.SetCaretPos (x, y)) return;
    resizeIME ();
}

void resizeIME () {
    if (!OS.IsDBLocale) return;
    POINT ptCurrentPos;
    if (!OS.GetCaretPos (&ptCurrentPos)) return;
    auto hwnd = parent.handle;
    auto hIMC = OS.ImmGetContext (hwnd);
    IME ime = parent.getIME ();
    if (ime !is null && ime.isInlineEnabled ()) {
        Point size = getSize ();
        CANDIDATEFORM lpCandidate;
        lpCandidate.dwStyle = OS.CFS_EXCLUDE;
        lpCandidate.ptCurrentPos = ptCurrentPos;
        //lpCandidate.rcArea = new RECT ();
        OS.SetRect (&lpCandidate.rcArea, ptCurrentPos.x, ptCurrentPos.y, ptCurrentPos.x + size.x, ptCurrentPos.y + size.y);
        OS.ImmSetCandidateWindow (hIMC, &lpCandidate);
    } else {
        RECT rect;
        OS.GetClientRect (hwnd, &rect);
        COMPOSITIONFORM lpCompForm;
        lpCompForm.dwStyle = OS.CFS_RECT;
        lpCompForm.ptCurrentPos.x = ptCurrentPos.x;
        lpCompForm.ptCurrentPos.y = ptCurrentPos.y;
        lpCompForm.rcArea.left = rect.left;
        lpCompForm.rcArea.right = rect.right;
        lpCompForm.rcArea.top = rect.top;
        lpCompForm.rcArea.bottom = rect.bottom;
        OS.ImmSetCompositionWindow (hIMC, &lpCompForm);
    }
    OS.ImmReleaseContext (hwnd, hIMC);
}

override void releaseParent () {
    super.releaseParent ();
    if (this is parent.getCaret ()) parent.setCaret (null);
}

override void releaseWidget () {
    super.releaseWidget ();
    parent = null;
    image = null;
    font = null;
    oldFont = null;
}

void resize () {
    resized = false;
    auto hwnd = parent.handle;
    OS.DestroyCaret ();
    auto hBitmap = image !is null ? image.handle : null;
    int width = this.width;
    if (!OS.IsWinCE && image is null && width is 0) {
        int buffer;
        if (OS.SystemParametersInfo (OS.SPI_GETCARETWIDTH, 0, &buffer, 0)) {
            width = buffer;
        }
    }
    OS.CreateCaret (hwnd, hBitmap, width, height);
    OS.SetCaretPos (x, y);
    OS.ShowCaret (hwnd);
    move ();
}

void restoreIMEFont () {
    if (!OS.IsDBLocale) return;
    if (oldFont is null) return;
    auto hwnd = parent.handle;
    auto hIMC = OS.ImmGetContext (hwnd);
    OS.ImmSetCompositionFont (hIMC, oldFont);
    OS.ImmReleaseContext (hwnd, hIMC);
    oldFont = null;
}

/**
 * Sets the receiver's size and location to the rectangular
 * area specified by the arguments. The <code>x</code> and
 * <code>y</code> arguments are relative to the receiver's
 * parent (or its display if its parent is null).
 *
 * @param x the new x coordinate for the receiver
 * @param y the new y coordinate for the receiver
 * @param width the new width for the receiver
 * @param height the new height for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setBounds (int x, int y, int width, int height) {
    checkWidget();
    bool samePosition = this.x is x && this.y is y;
    bool sameExtent = this.width is width && this.height is height;
    if (samePosition && sameExtent) return;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    if (sameExtent) {
        moved = true;
        if (isVisible_ && hasFocus ()) move ();
    } else {
        resized = true;
        if (isVisible_ && hasFocus ()) resize ();
    }
}

/**
 * Sets the receiver's size and location to the rectangular
 * area specified by the argument. The <code>x</code> and
 * <code>y</code> fields of the rectangle are relative to
 * the receiver's parent (or its display if its parent is null).
 *
 * @param rect the new bounds for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setBounds (Rectangle rect) {
    if (rect is null) error (SWT.ERROR_NULL_ARGUMENT);
    setBounds (rect.x, rect.y, rect.width, rect.height);
}

void setFocus () {
    auto hwnd = parent.handle;
    HBITMAP hBitmap;
    if (image !is null) hBitmap = image.handle;
    int width = this.width;
    if (!OS.IsWinCE && image is null && width is 0) {
        int buffer;
        if (OS.SystemParametersInfo (OS.SPI_GETCARETWIDTH, 0, &buffer, 0)) {
            width = buffer;
        }
    }
    OS.CreateCaret (hwnd, hBitmap, width, height);
    move ();
    setIMEFont ();
    if (isVisible_) OS.ShowCaret (hwnd);
}

/**
 * Sets the font that the receiver will use to paint textual information
 * to the font specified by the argument, or to the default font for that
 * kind of control if the argument is null.
 *
 * @param font the new font (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the font has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setFont (Font font) {
    checkWidget();
    if (font !is null && font.isDisposed ()) {
        error (SWT.ERROR_INVALID_ARGUMENT);
    }
    this.font = font;
    if (hasFocus ()) setIMEFont ();
}

/**
 * Sets the image that the receiver will use to paint the caret
 * to the image specified by the argument, or to the default
 * which is a filled rectangle if the argument is null
 *
 * @param image the new image (or null)
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
    checkWidget();
    if (image !is null && image.isDisposed ()) {
        error (SWT.ERROR_INVALID_ARGUMENT);
    }
    this.image = image;
    if (isVisible_ && hasFocus ()) resize ();
}

void setIMEFont () {
    if (!OS.IsDBLocale) return;
    HFONT hFont;
    if (font !is null) hFont = font.handle;
    if (hFont is null) hFont = defaultFont ();
    auto hwnd = parent.handle;
    auto hIMC = OS.ImmGetContext (hwnd);
    /* Save the current IME font */
    if (oldFont is null) {
        oldFont = new LOGFONT;
        if (!OS.ImmGetCompositionFont (hIMC, oldFont)) oldFont = null;
    }
    /* Set new IME font */
    LOGFONT logFont;
    if (OS.GetObject (hFont, LOGFONT.sizeof, &logFont) !is 0) {
        OS.ImmSetCompositionFont (hIMC, &logFont);
    }
    OS.ImmReleaseContext (hwnd, hIMC);
}

/**
 * Sets the receiver's location to the point specified by
 * the arguments which are relative to the receiver's
 * parent (or its display if its parent is null).
 *
 * @param x the new x coordinate for the receiver
 * @param y the new y coordinate for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLocation (int x, int y) {
    checkWidget();
    if (this.x is x && this.y is y) return;
    this.x = x;  this.y = y;
    moved = true;
    if (isVisible_ && hasFocus ()) move ();
}

/**
 * Sets the receiver's location to the point specified by
 * the argument which is relative to the receiver's
 * parent (or its display if its parent is null).
 *
 * @param location the new location for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLocation (Point location) {
    checkWidget();
    if (location is null) error (SWT.ERROR_NULL_ARGUMENT);
    setLocation (location.x, location.y);
}

/**
 * Sets the receiver's size to the point specified by the arguments.
 *
 * @param width the new width for the receiver
 * @param height the new height for the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSize (int width, int height) {
    checkWidget();
    if (this.width is width && this.height is height) return;
    this.width = width;  this.height = height;
    resized = true;
    if (isVisible_ && hasFocus ()) resize ();
}

/**
 * Sets the receiver's size to the point specified by the argument.
 *
 * @param size the new extent for the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSize (Point size) {
    checkWidget();
    if (size is null) error (SWT.ERROR_NULL_ARGUMENT);
    setSize (size.x, size.y);
}

/**
 * Marks the receiver as visible if the argument is <code>true</code>,
 * and marks it invisible otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, marking
 * it visible may not actually cause it to be displayed.
 * </p>
 *
 * @param visible the new visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setVisible (bool visible) {
    checkWidget();
    if (visible is isVisible_) return;
    isVisible_ = visible;
    auto hwnd = parent.handle;
    if (OS.GetFocus () !is hwnd) return;
    if (!isVisible_) {
        OS.HideCaret (hwnd);
    } else {
        if (resized) {
            resize ();
        } else {
            if (moved) move ();
        }
        OS.ShowCaret (hwnd);
    }
}

}
