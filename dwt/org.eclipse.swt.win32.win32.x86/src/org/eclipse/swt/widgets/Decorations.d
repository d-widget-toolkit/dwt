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
module org.eclipse.swt.widgets.Decorations;


import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Canvas;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.swt.widgets.Display;

import java.lang.all;

/**
 * Instances of this class provide the appearance and
 * behavior of <code>Shells</code>, but are not top
 * level shells or dialogs. Class <code>Shell</code>
 * shares a significant amount of code with this class,
 * and is a subclass.
 * <p>
 * IMPORTANT: This class was intended to be abstract and
 * should <em>never</em> be referenced or instantiated.
 * Instead, the class <code>Shell</code> should be used.
 * </p>
 * <p>
 * Instances are always displayed in one of the maximized,
 * minimized or normal states:
 * <ul>
 * <li>
 * When an instance is marked as <em>maximized</em>, the
 * window manager will typically resize it to fill the
 * entire visible area of the display, and the instance
 * is usually put in a state where it can not be resized
 * (even if it has style <code>RESIZE</code>) until it is
 * no longer maximized.
 * </li><li>
 * When an instance is in the <em>normal</em> state (neither
 * maximized or minimized), its appearance is controlled by
 * the style constants which were specified when it was created
 * and the restrictions of the window manager (see below).
 * </li><li>
 * When an instance has been marked as <em>minimized</em>,
 * its contents (client area) will usually not be visible,
 * and depending on the window manager, it may be
 * "iconified" (that is, replaced on the desktop by a small
 * simplified representation of itself), relocated to a
 * distinguished area of the screen, or hidden. Combinations
 * of these changes are also possible.
 * </li>
 * </ul>
 * </p>
 * Note: The styles supported by this class must be treated
 * as <em>HINT</em>s, since the window manager for the
 * desktop on which the instance is visible has ultimate
 * control over the appearance and behavior of decorations.
 * For example, some window managers only support resizable
 * windows and will always assume the RESIZE style, even if
 * it is not set.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>BORDER, CLOSE, MIN, MAX, NO_TRIM, RESIZE, TITLE, ON_TOP, TOOL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * Class <code>SWT</code> provides two "convenience constants"
 * for the most commonly required style combinations:
 * <dl>
 * <dt><code>SHELL_TRIM</code></dt>
 * <dd>
 * the result of combining the constants which are required
 * to produce a typical application top level shell: (that
 * is, <code>CLOSE | TITLE | MIN | MAX | RESIZE</code>)
 * </dd>
 * <dt><code>DIALOG_TRIM</code></dt>
 * <dd>
 * the result of combining the constants which are required
 * to produce a typical application dialog shell: (that
 * is, <code>TITLE | CLOSE | BORDER</code>)
 * </dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see #getMinimized
 * @see #getMaximized
 * @see Shell
 * @see SWT
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class Decorations : Canvas {

    alias Canvas.setBounds setBounds;
    alias Canvas.setParent setParent;
    alias Canvas.setSavedFocus setSavedFocus;
    alias Canvas.sort sort;
    alias Canvas.windowProc windowProc;

    Image image, smallImage, largeImage;
    Image [] images;
    Menu menuBar;
    Menu [] menus;
    Control savedFocus;
    Button defaultButton, saveDefault;
    int swFlags;
    HACCEL hAccel;
    int nAccel;
    bool moved, resized, opened;
    int oldX = OS.CW_USEDEFAULT, oldY = OS.CW_USEDEFAULT;
    int oldWidth = OS.CW_USEDEFAULT, oldHeight = OS.CW_USEDEFAULT;

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
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#BORDER
 * @see SWT#CLOSE
 * @see SWT#MIN
 * @see SWT#MAX
 * @see SWT#RESIZE
 * @see SWT#TITLE
 * @see SWT#NO_TRIM
 * @see SWT#SHELL_TRIM
 * @see SWT#DIALOG_TRIM
 * @see SWT#ON_TOP
 * @see SWT#TOOL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

void _setMaximized (bool maximized) {
    swFlags = maximized ? OS.SW_SHOWMAXIMIZED : OS.SW_RESTORE;
    static if (OS.IsWinCE) {
        /*
        * Note: WinCE does not support SW_SHOWMAXIMIZED and SW_RESTORE. The
        * workaround is to resize the window to fit the parent client area.
        */
        if (maximized) {
            RECT rect;
            OS.SystemParametersInfo (OS.SPI_GETWORKAREA, 0, &rect, 0);
            int width = rect.right - rect.left, height = rect.bottom - rect.top;
            if (OS.IsPPC) {
                /* Leave space for the menu bar */
                if (menuBar !is null) {
                    auto hwndCB = menuBar.hwndCB;
                    RECT rectCB;
                    OS.GetWindowRect (hwndCB, &rectCB);
                    height -= rectCB.bottom - rectCB.top;
                }
            }
            int flags = OS.SWP_NOZORDER | OS.SWP_DRAWFRAME | OS.SWP_NOACTIVATE;
            SetWindowPos (handle, null, rect.left, rect.top, width, height, flags);
        }
    } else {
        if (!OS.IsWindowVisible (handle)) return;
        if (maximized is OS.IsZoomed (handle)) return;
        OS.ShowWindow (handle, swFlags);
        OS.UpdateWindow (handle);
    }
}

void _setMinimized (bool minimized) {
    static if (OS.IsWinCE) return;
    swFlags = minimized ? OS.SW_SHOWMINNOACTIVE : OS.SW_RESTORE;
    if (!OS.IsWindowVisible (handle)) return;
    if (minimized is OS.IsIconic (handle)) return;
    int flags = swFlags;
    if (flags is OS.SW_SHOWMINNOACTIVE && handle is OS.GetActiveWindow ()) {
        flags = OS.SW_MINIMIZE;
    }
    OS.ShowWindow (handle, flags);
    OS.UpdateWindow (handle);
}

void addMenu (Menu menu) {
    if (menus is null) menus = new Menu [4];
    for (int i=0; i<menus.length; i++) {
        if (menus [i] is null) {
            menus [i] = menu;
            return;
        }
    }
    Menu [] newMenus = new Menu [menus.length + 4];
    newMenus [menus.length] = menu;
    System.arraycopy (menus, 0, newMenus, 0, menus.length);
    menus = newMenus;
}

void bringToTop () {
    /*
    * This code is intentionally commented.  On some platforms,
    * the ON_TOP style creates a shell that will stay on top
    * of every other shell on the desktop.  Using SetWindowPos ()
    * with HWND_TOP caused problems on Windows 98 so this code is
    * commented out until this functionality is specified and
    * the problems are fixed.
    */
//  if ((style & SWT.ON_TOP) !is 0) {
//      int flags = OS.SWP_NOSIZE | OS.SWP_NOMOVE | OS.SWP_NOACTIVATE;
//      OS.SetWindowPos (handle, OS.HWND_TOP, 0, 0, 0, 0, flags);
//  } else {
        OS.BringWindowToTop (handle);
        // widget could be disposed at this point
//  }
}

static int checkStyle (int style) {
    if ((style & SWT.NO_TRIM) !is 0) {
        style &= ~(SWT.CLOSE | SWT.TITLE | SWT.MIN | SWT.MAX | SWT.RESIZE | SWT.BORDER);
    }
    static if (OS.IsWinCE) {
        /*
        * Feature in WinCE PPC.  WS_MINIMIZEBOX or WS_MAXIMIZEBOX
        * are not supposed to be used.  If they are, the result
        * is a button which does not repaint correctly.  The fix
        * is to remove this style.
        */
        if ((style & SWT.MIN) !is 0) style &= ~SWT.MIN;
        if ((style & SWT.MAX) !is 0) style &= ~SWT.MAX;
        return style;
    }
    if ((style & (SWT.MENU | SWT.MIN | SWT.MAX | SWT.CLOSE)) !is 0) {
        style |= SWT.TITLE;
    }

    /*
    * If either WS_MINIMIZEBOX or WS_MAXIMIZEBOX are set,
    * we must also set WS_SYSMENU or the buttons will not
    * appear.
    */
    if ((style & (SWT.MIN | SWT.MAX)) !is 0) style |= SWT.CLOSE;

    /*
    * Both WS_SYSMENU and WS_CAPTION must be set in order
    * to for the system menu to appear.
    */
    if ((style & SWT.CLOSE) !is 0) style |= SWT.TITLE;

    /*
    * Bug in Windows.  The WS_CAPTION style must be
    * set when the window is resizable or it does not
    * draw properly.
    */
    /*
    * This code is intentionally commented.  It seems
    * that this problem originally in Windows 3.11,
    * has been fixed in later versions.  Because the
    * exact nature of the drawing problem is unknown,
    * keep the commented code around in case it comes
    * back.
    */
//  if ((style & SWT.RESIZE) !is 0) style |= SWT.TITLE;

    return style;
}

override void checkBorder () {
    /* Do nothing */
}

void checkComposited (Composite parent) {
    /* Do nothing */
}

override void checkOpened () {
    if (!opened) resized = false;
}

override protected void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    return OS.DefMDIChildProc (hwnd, msg, wParam, lParam);
}

void closeWidget () {
    Event event = new Event ();
    sendEvent (SWT.Close, event);
    if (event.doit && !isDisposed ()) dispose ();
}

int compare (ImageData data1, ImageData data2, int width, int height, int depth) {
    int value1 = Math.abs (data1.width - width), value2 = Math.abs (data2.width - width);
    if (value1 is value2) {
        int transparent1 = data1.getTransparencyType ();
        int transparent2 = data2.getTransparencyType ();
        if (transparent1 is transparent2) {
            if (data1.depth is data2.depth) return 0;
            return data1.depth > data2.depth && data1.depth <= depth ? -1 : 1;
        }
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (5, 1)) {
            if (transparent1 is SWT.TRANSPARENCY_ALPHA) return -1;
            if (transparent2 is SWT.TRANSPARENCY_ALPHA) return 1;
        }
        if (transparent1 is SWT.TRANSPARENCY_MASK) return -1;
        if (transparent2 is SWT.TRANSPARENCY_MASK) return 1;
        if (transparent1 is SWT.TRANSPARENCY_PIXEL) return -1;
        if (transparent2 is SWT.TRANSPARENCY_PIXEL) return 1;
        return 0;
    }
    return value1 < value2 ? -1 : 1;
}

override Control computeTabGroup () {
    return this;
}

override Control computeTabRoot () {
    return this;
}

override public Rectangle computeTrim (int x, int y, int width, int height) {
    checkWidget ();

    /* Get the size of the trimmings */
    RECT rect;
    OS.SetRect (&rect, x, y, x + width, y + height);
    int bits1 = OS.GetWindowLong (handle, OS.GWL_STYLE);
    int bits2 = OS.GetWindowLong (handle, OS.GWL_EXSTYLE);
    bool hasMenu = OS.IsWinCE ? false : OS.GetMenu (handle) !is null;
    OS.AdjustWindowRectEx (&rect, bits1, hasMenu, bits2);

    /* Get the size of the scroll bars */
    if (horizontalBar !is null) rect.bottom += OS.GetSystemMetrics (OS.SM_CYHSCROLL);
    if (verticalBar !is null) rect.right += OS.GetSystemMetrics (OS.SM_CXVSCROLL);

    /* Compute the height of the menu bar */
    if (hasMenu) {
        RECT testRect;
        OS.SetRect (&testRect, 0, 0, rect.right - rect.left, rect.bottom - rect.top);
        OS.SendMessage (handle, OS.WM_NCCALCSIZE, 0, &testRect);
        while ((testRect.bottom - testRect.top) < height) {
            if (testRect.bottom - testRect.top is 0) break;
            rect.top -= OS.GetSystemMetrics (OS.SM_CYMENU) - OS.GetSystemMetrics (OS.SM_CYBORDER);
            OS.SetRect (&testRect, 0, 0, rect.right - rect.left, rect.bottom - rect.top);
            OS.SendMessage (handle, OS.WM_NCCALCSIZE, 0, &testRect);
        }
    }
    return new Rectangle (rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top);
}

void createAccelerators () {
    hAccel = null;
    nAccel = 0;
    int maxAccel = 0;
    MenuItem [] items = display.items;
    if (menuBar is null || items is null) {
        if (!OS.IsPPC) return;
        maxAccel = 1;
    } else {
        maxAccel = OS.IsPPC ? cast(int)/*64bit*/items.length + 1 : cast(int)/*64bit*/items.length;
    }
    ACCEL accel;
    byte [] buffer1 = new byte [ACCEL.sizeof];
    byte [] buffer2 = new byte [maxAccel * ACCEL.sizeof];
    if (menuBar !is null && items !is null) {
        for (int i=0; i<items.length; i++) {
            MenuItem item = items [i];
            if (item !is null && item.accelerator !is 0) {
                Menu menu = item.parent;
                if (menu.parent is this) {
                    while (menu !is null && menu !is menuBar) {
                        menu = menu.getParentMenu ();
                    }
                    if (menu is menuBar && item.fillAccel (&accel)) {
                        *cast(ACCEL*)buffer1.ptr = accel;
                        //OS.MoveMemory (buffer1, accel, ACCEL.sizeof);
                        System.arraycopy (buffer1, 0, buffer2, nAccel * ACCEL.sizeof, ACCEL.sizeof);
                        nAccel++;
                    }
                }
            }
        }
    }
    if (OS.IsPPC) {
        /*
        * Note on WinCE PPC.  Close the shell when user taps CTRL-Q.
        * IDOK represents the "Done Button" which also closes the shell.
        */
        accel.fVirt = cast(byte) (OS.FVIRTKEY | OS.FCONTROL);
        accel.key = cast(short) 'Q';
        accel.cmd = cast(short) OS.IDOK;
        *cast(ACCEL*)buffer1.ptr = accel;
        //OS.MoveMemory (buffer1, accel, ACCEL.sizeof);
        System.arraycopy (buffer1, 0, buffer2, nAccel * ACCEL.sizeof, ACCEL.sizeof);
        nAccel++;
    }
    if (nAccel !is 0) hAccel = OS.CreateAcceleratorTable ( cast(ACCEL*)buffer2.ptr, nAccel);
}

override void createHandle () {
    super.createHandle ();
    if (parent !is null || ((style & SWT.TOOL) !is 0)) {
        setParent ();
        setSystemMenu ();
    }
}

override void createWidget () {
    super.createWidget ();
    swFlags = OS.IsWinCE ? OS.SW_SHOWMAXIMIZED : OS.SW_SHOWNOACTIVATE;
    hAccel = cast(HACCEL)-1;
}

void destroyAccelerators () {
    if (hAccel !is null && hAccel !is cast(HACCEL)-1) OS.DestroyAcceleratorTable (hAccel);
    hAccel = cast(HACCEL)-1;
}

override public void dispose () {
    if (isDisposed()) return;
    if (!isValidThread ()) error (SWT.ERROR_THREAD_INVALID_ACCESS);
    if (!(cast(Shell)this)) {
        if (!traverseDecorations (true)) {
            Shell shell = getShell ();
            shell.setFocus ();
        }
        setVisible (false);
    }
    super.dispose ();
}

Menu findMenu (HMENU hMenu) {
    if (menus is null) return null;
    for (int i=0; i<menus.length; i++) {
        Menu menu = menus [i];
        if (menu !is null && hMenu is menu.handle) return menu;
    }
    return null;
}

void fixDecorations (Decorations newDecorations, Control control, Menu [] menus) {
    if (this is newDecorations) return;
    if (control is savedFocus) savedFocus = null;
    if (control is defaultButton) defaultButton = null;
    if (control is saveDefault) saveDefault = null;
    if (menus is null) return;
    Menu menu = control.menu;
    if (menu !is null) {
        int index = 0;
        while (index <menus.length) {
            if (menus [index] is menu) {
                control.setMenu (null);
                return;
            }
            index++;
        }
        menu.fixMenus (newDecorations);
        destroyAccelerators ();
        newDecorations.destroyAccelerators ();
    }
}

override public Rectangle getBounds () {
    checkWidget ();
    static if (!OS.IsWinCE) {
        if (OS.IsIconic (handle)) {
            WINDOWPLACEMENT lpwndpl;
            lpwndpl.length = WINDOWPLACEMENT.sizeof;
            OS.GetWindowPlacement (handle, &lpwndpl);
            int width = lpwndpl.rcNormalPosition.right - lpwndpl.rcNormalPosition.left;
            int height = lpwndpl.rcNormalPosition.bottom - lpwndpl.rcNormalPosition.top;
            return new Rectangle (lpwndpl.rcNormalPosition.left, lpwndpl.rcNormalPosition.top, width, height);
        }
    }
    return super.getBounds ();
}

override public Rectangle getClientArea () {
    checkWidget ();
    /*
    * Note: The CommandBar is part of the client area,
    * not the trim.  Applications don't expect this so
    * subtract the height of the CommandBar.
    */
    static if (OS.IsHPC) {
        Rectangle rect = super.getClientArea ();
        if (menuBar !is null) {
            auto hwndCB = menuBar.hwndCB;
            int height = OS.CommandBar_Height (hwndCB);
            rect.y += height;
            rect.height = Math.max (0, rect.height - height);
        }
        return rect;
    }
    static if (!OS.IsWinCE) {
        if (OS.IsIconic (handle)) {
            WINDOWPLACEMENT lpwndpl;
            lpwndpl.length = WINDOWPLACEMENT.sizeof;
            OS.GetWindowPlacement (handle, &lpwndpl);
            int width = lpwndpl.rcNormalPosition.right - lpwndpl.rcNormalPosition.left;
            int height = lpwndpl.rcNormalPosition.bottom - lpwndpl.rcNormalPosition.top;
            /*
            * Feature in Windows.  For some reason WM_NCCALCSIZE does
            * not compute the client area when the window is minimized.
            * The fix is to compute it using AdjustWindowRectEx() and
            * GetSystemMetrics().
            *
            * NOTE: This code fails to compute the correct client area
            * for a minimized window where the menu bar would wrap were
            * the window restored.  There is no fix for this problem at
            * this time.
            */
            if (horizontalBar !is null) width -= OS.GetSystemMetrics (OS.SM_CYHSCROLL);
            if (verticalBar !is null) height -= OS.GetSystemMetrics (OS.SM_CXVSCROLL);
            RECT rect;
            int bits1 = OS.GetWindowLong (handle, OS.GWL_STYLE);
            int bits2 = OS.GetWindowLong (handle, OS.GWL_EXSTYLE);
            bool hasMenu = OS.IsWinCE ? false : OS.GetMenu (handle) !is null;
            OS.AdjustWindowRectEx (&rect, bits1, hasMenu, bits2);
            width = Math.max (0, width - (rect.right - rect.left));
            height = Math.max (0, height - (rect.bottom - rect.top));
            return new Rectangle (0, 0, width, height);
        }
    }
    return super.getClientArea ();
}

/**
 * Returns the receiver's default button if one had
 * previously been set, otherwise returns null.
 *
 * @return the default button or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setDefaultButton(Button)
 */
public Button getDefaultButton () {
    checkWidget ();
    return defaultButton;
}

/**
 * Returns the receiver's image if it had previously been
 * set using <code>setImage()</code>. The image is typically
 * displayed by the window manager when the instance is
 * marked as iconified, and may also be displayed somewhere
 * in the trim when the instance is in normal or maximized
 * states.
 * <p>
 * Note: This method will return null if called before
 * <code>setImage()</code> is called. It does not provide
 * access to a window manager provided, "default" image
 * even if one exists.
 * </p>
 *
 * @return the image
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

/**
 * Returns the receiver's images if they had previously been
 * set using <code>setImages()</code>. Images are typically
 * displayed by the window manager when the instance is
 * marked as iconified, and may also be displayed somewhere
 * in the trim when the instance is in normal or maximized
 * states. Depending where the icon is displayed, the platform
 * chooses the icon with the "best" attributes.  It is expected
 * that the array will contain the same icon rendered at different
 * sizes, with different depth and transparency attributes.
 *
 * <p>
 * Note: This method will return an empty array if called before
 * <code>setImages()</code> is called. It does not provide
 * access to a window manager provided, "default" image
 * even if one exists.
 * </p>
 *
 * @return the images
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public Image [] getImages () {
    checkWidget ();
    if (images is null) return new Image [0];
    Image [] result = new Image [images.length];
    System.arraycopy (images, 0, result, 0, images.length);
    return result;
}

override public Point getLocation () {
    checkWidget ();
    static if (!OS.IsWinCE) {
        if (OS.IsIconic (handle)) {
            WINDOWPLACEMENT lpwndpl;
            lpwndpl.length = WINDOWPLACEMENT.sizeof;
            OS.GetWindowPlacement (handle, &lpwndpl);
            return new Point (lpwndpl.rcNormalPosition.left, lpwndpl.rcNormalPosition.top);
        }
    }
    return super.getLocation ();
}

/**
 * Returns <code>true</code> if the receiver is currently
 * maximized, and false otherwise.
 * <p>
 *
 * @return the maximized state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setMaximized
 */
public bool getMaximized () {
    checkWidget ();
    static if (OS.IsWinCE) return swFlags is OS.SW_SHOWMAXIMIZED;
    if (OS.IsWindowVisible (handle)) return cast(bool) OS.IsZoomed (handle);
    return swFlags is OS.SW_SHOWMAXIMIZED;
}

/**
 * Returns the receiver's menu bar if one had previously
 * been set, otherwise returns null.
 *
 * @return the menu bar or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Menu getMenuBar () {
    checkWidget ();
    return menuBar;
}

/**
 * Returns <code>true</code> if the receiver is currently
 * minimized, and false otherwise.
 * <p>
 *
 * @return the minimized state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setMinimized
 */
public bool getMinimized () {
    checkWidget ();
    static if (OS.IsWinCE) return false;
    if (OS.IsWindowVisible (handle)) return cast(bool) OS.IsIconic (handle);
    return swFlags is OS.SW_SHOWMINNOACTIVE;
}

override String getNameText () {
    return getText ();
}

override public Point getSize () {
    checkWidget ();
    static if (!OS.IsWinCE) {
        if (OS.IsIconic (handle)) {
            WINDOWPLACEMENT lpwndpl;
            lpwndpl.length = WINDOWPLACEMENT.sizeof;
            OS.GetWindowPlacement (handle, &lpwndpl);
            int width = lpwndpl.rcNormalPosition.right - lpwndpl.rcNormalPosition.left;
            int height = lpwndpl.rcNormalPosition.bottom - lpwndpl.rcNormalPosition.top;
            return new Point (width, height);
        }
    }
    return super.getSize ();
}

/**
 * Returns the receiver's text, which is the string that the
 * window manager will typically display as the receiver's
 * <em>title</em>. If the text has not previously been set,
 * returns an empty string.
 *
 * @return the text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText () {
    checkWidget ();
    int length = OS.GetWindowTextLength (handle);
    if (length is 0) return "";
    /* Use the character encoding for the default locale */
    TCHAR[] buffer;
    buffer.length = length + 1;
    OS.GetWindowText (handle, buffer.ptr, length + 1);
    return TCHARsToStr( buffer );
}

override public bool isReparentable () {
    checkWidget ();
    /*
    * Feature in Windows.  Calling SetParent() for a shell causes
    * a kind of fake MDI to happen.  It doesn't work well on Windows
    * and is not supported on the other platforms.  The fix is to
    * disallow the SetParent().
    */
    return false;
}

override bool isTabGroup () {
    /*
    * Can't test WS_TAB bits because they are the same as WS_MAXIMIZEBOX.
    */
    return true;
}

override bool isTabItem () {
    /*
    * Can't test WS_TAB bits because they are the same as WS_MAXIMIZEBOX.
    */
    return false;
}

override Decorations menuShell () {
    return this;
}

override void releaseChildren (bool destroy) {
    if (menuBar !is null) {
        menuBar.release (false);
        menuBar = null;
    }
    super.releaseChildren (destroy);
    if (menus !is null) {
        for (int i=0; i<menus.length; i++) {
            Menu menu = menus [i];
            if (menu !is null && !menu.isDisposed ()) {
                menu.dispose ();
            }
        }
        menus = null;
    }
}

override void releaseWidget () {
    super.releaseWidget ();
    if (smallImage !is null) smallImage.dispose ();
    if (largeImage !is null) largeImage.dispose ();
    smallImage = largeImage = image = null;
    images = null;
    savedFocus = null;
    defaultButton = saveDefault = null;
    if (hAccel !is null && hAccel !is cast(HACCEL)-1) OS.DestroyAcceleratorTable (hAccel);
    hAccel = cast(HACCEL)-1;
}

void removeMenu (Menu menu) {
    if (menus is null) return;
    for (int i=0; i<menus.length; i++) {
        if (menus [i] is menu) {
            menus [i] = null;
            return;
        }
    }
}

bool restoreFocus () {
    if (display.ignoreRestoreFocus) return true;
    if (savedFocus !is null && savedFocus.isDisposed ()) savedFocus = null;
    if (savedFocus !is null && savedFocus.setSavedFocus ()) return true;
    /*
    * This code is intentionally commented.  When no widget
    * has been given focus, some platforms give focus to the
    * default button.  Windows doesn't do this.
    */
//  if (defaultButton !is null && !defaultButton.isDisposed ()) {
//      if (defaultButton.setFocus ()) return true;
//  }
    return false;
}

void saveFocus () {
    Control control = display._getFocusControl ();
    if (control !is null && control !is this && this is control.menuShell ()) {
        setSavedFocus (control);
    }
}

override void setBounds (int x, int y, int width, int height, int flags, bool defer) {
    static if (OS.IsWinCE) {
        swFlags = OS.SW_RESTORE;
    } else {
        if (OS.IsIconic (handle)) {
            setPlacement (x, y, width, height, flags);
            return;
        }
    }
    forceResize ();
    RECT rect;
    OS.GetWindowRect (handle, &rect);
    bool sameOrigin = true;
    if ((OS.SWP_NOMOVE & flags) is 0) {
        sameOrigin = rect.left is x && rect.top is y;
        if (!sameOrigin) moved = true;
    }
    bool sameExtent = true;
    if ((OS.SWP_NOSIZE & flags) is 0) {
        sameExtent = rect.right - rect.left is width && rect.bottom - rect.top is height;
        if (!sameExtent) resized = true;
    }
    static if (!OS.IsWinCE) {
        if (OS.IsZoomed (handle)) {
            if (sameOrigin && sameExtent) return;
            setPlacement (x, y, width, height, flags);
            _setMaximized (false);
            return;
        }
    }
    super.setBounds (x, y, width, height, flags, defer);
}

/**
 * If the argument is not null, sets the receiver's default
 * button to the argument, and if the argument is null, sets
 * the receiver's default button to the first button which
 * was set as the receiver's default button (called the
 * <em>saved default button</em>). If no default button had
 * previously been set, or the saved default button was
 * disposed, the receiver's default button will be set to
 * null.
 * <p>
 * The default button is the button that is selected when
 * the receiver is active and the user presses ENTER.
 * </p>
 *
 * @param button the new default button
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the button has been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if the control is not in the same widget tree</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setDefaultButton (Button button) {
    checkWidget ();
    if (button !is null) {
        if (button.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
        if (button.menuShell () !is this) error(SWT.ERROR_INVALID_PARENT);
    }
    setDefaultButton (button, true);
}

void setDefaultButton (Button button, bool save) {
    if (button is null) {
        if (defaultButton is saveDefault) {
            if (save) saveDefault = null;
            return;
        }
    } else {
        if ((button.style & SWT.PUSH) is 0) return;
        if (button is defaultButton) return;
    }
    if (defaultButton !is null) {
        if (!defaultButton.isDisposed ()) defaultButton.setDefault (false);
    }
    if ((defaultButton = button) is null) defaultButton = saveDefault;
    if (defaultButton !is null) {
        if (!defaultButton.isDisposed ()) defaultButton.setDefault (true);
    }
    if (save) saveDefault = defaultButton;
    if (saveDefault !is null && saveDefault.isDisposed ()) saveDefault = null;
}

/**
 * Sets the receiver's image to the argument, which may
 * be null. The image is typically displayed by the window
 * manager when the instance is marked as iconified, and
 * may also be displayed somewhere in the trim when the
 * instance is in normal or maximized states.
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
    checkWidget ();
    if (image !is null && image.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
    this.image = image;
    setImages (image, null);
}

void setImages (Image image, Image [] images) {
    /*
    * Feature in WinCE.  WM_SETICON and WM_GETICON set the icon
    * for the window class, not the window instance.  This means
    * that it is possible to set an icon into a window and then
    * later free the icon, thus freeing the icon for every window.
    * The fix is to avoid the API.
    *
    * On WinCE PPC, icons in windows are not displayed.
    */
    static if (OS.IsWinCE) return;
    if (smallImage !is null) smallImage.dispose ();
    if (largeImage !is null) largeImage.dispose ();
    smallImage = largeImage = null;
    HICON hSmallIcon, hLargeIcon;
    Image smallIcon = null, largeIcon = null;
    if (image !is null) {
        smallIcon = largeIcon = image;
    } else {
        if (images !is null && images.length > 0) {
            int depth = display.getIconDepth ();
            ImageData [] datas = null;
            if (images.length > 1) {
                Image [] bestImages = new Image [images.length];
                System.arraycopy (images, 0, bestImages, 0, images.length);
                datas = new ImageData [images.length];
                for (int i=0; i<datas.length; i++) {
                    datas [i] = images [i].getImageData ();
                }
                images = bestImages;
                sort (images, datas, OS.GetSystemMetrics (OS.SM_CXSMICON), OS.GetSystemMetrics (OS.SM_CYSMICON), depth);
            }
            smallIcon = images [0];
            if (images.length > 1) {
                sort (images, datas, OS.GetSystemMetrics (OS.SM_CXICON), OS.GetSystemMetrics (OS.SM_CYICON), depth);
            }
            largeIcon = images [0];
        }
    }
    if (smallIcon !is null) {
        switch (smallIcon.type) {
            case SWT.BITMAP:
                smallImage = Display.createIcon (smallIcon);
                hSmallIcon = smallImage.handle;
                break;
            case SWT.ICON:
                hSmallIcon = smallIcon.handle;
                break;
            default:
        }
    }
    OS.SendMessage (handle, OS.WM_SETICON, OS.ICON_SMALL, hSmallIcon);
    if (largeIcon !is null) {
        switch (largeIcon.type) {
            case SWT.BITMAP:
                largeImage = Display.createIcon (largeIcon);
                hLargeIcon = largeImage.handle;
                break;
            case SWT.ICON:
                hLargeIcon = largeIcon.handle;
                break;
            default:
        }
    }
    OS.SendMessage (handle, OS.WM_SETICON, OS.ICON_BIG, hLargeIcon);

    /*
    * Bug in Windows.  When WM_SETICON is used to remove an
    * icon from the window trimmings for a window with the
    * extended style bits WS_EX_DLGMODALFRAME, the window
    * trimmings do not redraw to hide the previous icon.
    * The fix is to force a redraw.
    */
    static if (!OS.IsWinCE) {
        if (hSmallIcon is null && hLargeIcon is null && (style & SWT.BORDER) !is 0) {
            int flags = OS.RDW_FRAME | OS.RDW_INVALIDATE;
            OS.RedrawWindow (handle, null, null, flags);
        }
    }
}

/**
 * Sets the receiver's images to the argument, which may
 * be an empty array. Images are typically displayed by the
 * window manager when the instance is marked as iconified,
 * and may also be displayed somewhere in the trim when the
 * instance is in normal or maximized states. Depending where
 * the icon is displayed, the platform chooses the icon with
 * the "best" attributes. It is expected that the array will
 * contain the same icon rendered at different sizes, with
 * different depth and transparency attributes.
 *
 * @param images the new image array
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if one of the images is null or has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setImages (Image [] images) {
    checkWidget ();
    // SWT extension: allow null array
    //if (images is null) error (SWT.ERROR_INVALID_ARGUMENT);
    for (int i = 0; i < images.length; i++) {
        if (images [i] is null || images [i].isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
    }
    this.images = images;
    setImages (null, images);
}

/**
 * Sets the maximized state of the receiver.
 * If the argument is <code>true</code> causes the receiver
 * to switch to the maximized state, and if the argument is
 * <code>false</code> and the receiver was previously maximized,
 * causes the receiver to switch back to either the minimized
 * or normal states.
 * <p>
 * Note: The result of intermixing calls to <code>setMaximized(true)</code>
 * and <code>setMinimized(true)</code> will vary by platform. Typically,
 * the behavior will match the platform user's expectations, but not
 * always. This should be avoided if possible.
 * </p>
 *
 * @param maximized the new maximized state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setMinimized
 */
public void setMaximized (bool maximized) {
    checkWidget ();
    Display.lpStartupInfo = null;
    _setMaximized (maximized);
}

/**
 * Sets the receiver's menu bar to the argument, which
 * may be null.
 *
 * @param menu the new menu bar
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the menu has been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if the menu is not in the same widget tree</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMenuBar (Menu menu) {
    checkWidget ();
    if (menuBar is menu) return;
    if (menu !is null) {
        if (menu.isDisposed()) error(SWT.ERROR_INVALID_ARGUMENT);
        if ((menu.style & SWT.BAR) is 0) error (SWT.ERROR_MENU_NOT_BAR);
        if (menu.parent !is this) error (SWT.ERROR_INVALID_PARENT);
    }
    static if (OS.IsWinCE) {
        if (OS.IsHPC) {
            bool resize = menuBar !is menu;
            if (menuBar !is null) OS.CommandBar_Show (menuBar.hwndCB, false);
            menuBar = menu;
            if (menuBar !is null) OS.CommandBar_Show (menuBar.hwndCB, true);
            if (resize) {
                sendEvent (SWT.Resize);
                if (isDisposed ()) return;
                if (layout !is null) {
                    markLayout (false, false);
                    updateLayout (true, false);
                }
            }
        } else {
            if (OS.IsPPC) {
                /*
                * Note in WinCE PPC.  The menu bar is a separate popup window.
                * If the shell is full screen, resize its window to leave
                * space for the menu bar.
                */
                bool resize = getMaximized () && menuBar !is menu;
                if (menuBar !is null) OS.ShowWindow (menuBar.hwndCB, OS.SW_HIDE);
                menuBar = menu;
                if (menuBar !is null) OS.ShowWindow (menuBar.hwndCB, OS.SW_SHOW);
                if (resize) _setMaximized (true);
            }
            if (OS.IsSP) {
                if (menuBar !is null) OS.ShowWindow (menuBar.hwndCB, OS.SW_HIDE);
                menuBar = menu;
                if (menuBar !is null) OS.ShowWindow (menuBar.hwndCB, OS.SW_SHOW);
            }
        }
    } else {
        if (menu !is null) display.removeBar (menu);
        menuBar = menu;
        auto hMenu = menuBar !is null ? menuBar.handle: null;
        OS.SetMenu (handle, hMenu);
    }
    destroyAccelerators ();
}

/**
 * Sets the minimized stated of the receiver.
 * If the argument is <code>true</code> causes the receiver
 * to switch to the minimized state, and if the argument is
 * <code>false</code> and the receiver was previously minimized,
 * causes the receiver to switch back to either the maximized
 * or normal states.
 * <p>
 * Note: The result of intermixing calls to <code>setMaximized(true)</code>
 * and <code>setMinimized(true)</code> will vary by platform. Typically,
 * the behavior will match the platform user's expectations, but not
 * always. This should be avoided if possible.
 * </p>
 *
 * @param minimized the new maximized state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setMaximized
 */
public void setMinimized (bool minimized) {
    checkWidget ();
    Display.lpStartupInfo = null;
    _setMinimized (minimized);
}

void setParent () {
    /*
    * In order for an MDI child window to support
    * a menu bar, setParent () is needed to reset
    * the parent.  Otherwise, the MDI child window
    * will appear as a separate shell.  This is an
    * undocumented and possibly dangerous Windows
    * feature.
    */
    auto hwndParent = parent.handle;
    display.lockActiveWindow = true;
    OS.SetParent (handle, hwndParent);
    if (!OS.IsWindowVisible (hwndParent)) {
        OS.ShowWindow (handle, OS.SW_SHOWNA);
    }
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    bits &= ~OS.WS_CHILD;
    OS.SetWindowLong (handle, OS.GWL_STYLE, bits | OS.WS_POPUP);
    OS.SetWindowLongPtr (handle, OS.GWLP_ID, 0);
    int flags = OS.SWP_NOSIZE | OS.SWP_NOMOVE | OS.SWP_NOACTIVATE;
    SetWindowPos (handle, cast(HWND)OS.HWND_BOTTOM, 0, 0, 0, 0, flags);
    display.lockActiveWindow = false;
}

void setPlacement (int x, int y, int width, int height, int flags) {
    WINDOWPLACEMENT lpwndpl;
    lpwndpl.length = WINDOWPLACEMENT.sizeof;
    OS.GetWindowPlacement (handle, &lpwndpl);
    lpwndpl.showCmd = OS.SW_SHOWNA;
    if (OS.IsIconic (handle)) {
        lpwndpl.showCmd = OS.SW_SHOWMINNOACTIVE;
    } else {
        if (OS.IsZoomed (handle)) {
            lpwndpl.showCmd = OS.SW_SHOWMAXIMIZED;
        }
    }
    bool sameOrigin = true;
    if ((flags & OS.SWP_NOMOVE) is 0) {
        sameOrigin = lpwndpl.rcNormalPosition.left !is x || lpwndpl.rcNormalPosition.top !is y;
        lpwndpl.rcNormalPosition.right = x + (lpwndpl.rcNormalPosition.right - lpwndpl.rcNormalPosition.left);
        lpwndpl.rcNormalPosition.bottom = y + (lpwndpl.rcNormalPosition.bottom - lpwndpl.rcNormalPosition.top);
        lpwndpl.rcNormalPosition.left = x;
        lpwndpl.rcNormalPosition.top = y;
    }
    bool sameExtent = true;
    if ((flags & OS.SWP_NOSIZE) is 0) {
        sameExtent = lpwndpl.rcNormalPosition.right - lpwndpl.rcNormalPosition.left !is width || lpwndpl.rcNormalPosition.bottom - lpwndpl.rcNormalPosition.top !is height;
        lpwndpl.rcNormalPosition.right = lpwndpl.rcNormalPosition.left + width;
        lpwndpl.rcNormalPosition.bottom = lpwndpl.rcNormalPosition.top + height;
    }
    OS.SetWindowPlacement (handle, &lpwndpl);
    if (OS.IsIconic (handle)) {
        if (sameOrigin) {
            moved = true;
            Point location = getLocation ();
            oldX = location.x;
            oldY = location.y;
            sendEvent (SWT.Move);
            if (isDisposed ()) return;
        }
        if (sameExtent) {
            resized = true;
            Rectangle rect = getClientArea ();
            oldWidth = rect.width;
            oldHeight = rect.height;
            sendEvent (SWT.Resize);
            if (isDisposed ()) return;
            if (layout_ !is null) {
                markLayout (false, false);
                updateLayout (true, false);
            }
        }
    }
}

void setSavedFocus (Control control) {
    savedFocus = control;
}

void setSystemMenu () {
    static if (OS.IsWinCE) return;
    auto hMenu = OS.GetSystemMenu (handle, false);
    if (hMenu is null) return;
    int oldCount = OS.GetMenuItemCount (hMenu);
    if ((style & SWT.RESIZE) is 0) {
        OS.DeleteMenu (hMenu, OS.SC_SIZE, OS.MF_BYCOMMAND);
    }
    if ((style & SWT.MIN) is 0) {
        OS.DeleteMenu (hMenu, OS.SC_MINIMIZE, OS.MF_BYCOMMAND);
    }
    if ((style & SWT.MAX) is 0) {
        OS.DeleteMenu (hMenu, OS.SC_MAXIMIZE, OS.MF_BYCOMMAND);
    }
    if ((style & (SWT.MIN | SWT.MAX)) is 0) {
        OS.DeleteMenu (hMenu, OS.SC_RESTORE, OS.MF_BYCOMMAND);
    }
    int newCount = OS.GetMenuItemCount (hMenu);
    if ((style & SWT.CLOSE) is 0 || newCount !is oldCount) {
        OS.DeleteMenu (hMenu, OS.SC_TASKLIST, OS.MF_BYCOMMAND);
        MENUITEMINFO info;
        info.cbSize = OS.MENUITEMINFO_sizeof;
        info.fMask = OS.MIIM_ID;
        int index = 0;
        while (index < newCount) {
            if (OS.GetMenuItemInfo (hMenu, index, true, &info)) {
                if (info.wID is OS.SC_CLOSE) break;
            }
            index++;
        }
        if (index !is newCount) {
            OS.DeleteMenu (hMenu, index - 1, OS.MF_BYPOSITION);
            if ((style & SWT.CLOSE) is 0) {
                OS.DeleteMenu (hMenu, OS.SC_CLOSE, OS.MF_BYCOMMAND);
            }
        }
    }
}

/**
 * Sets the receiver's text, which is the string that the
 * window manager will typically display as the receiver's
 * <em>title</em>, to the argument, which must not be null.
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
    /* Use the character encoding for the default locale */
    StringT buffer = StrToTCHARs (string, true);
    /* Ensure that the title appears in the task bar.*/
    if ((state & FOREIGN_HANDLE) !is 0) {
        auto hHeap = OS.GetProcessHeap ();
        auto byteCount = buffer.length * TCHAR.sizeof;
        auto pszText = OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
        OS.MoveMemory (pszText, buffer.ptr, byteCount);
        OS.DefWindowProc (handle, OS.WM_SETTEXT, 0, cast(ptrdiff_t)pszText);
        if (pszText !is null) OS.HeapFree (hHeap, 0, pszText);
    } else {
        OS.SetWindowText (handle, buffer.ptr);
    }
}

override public void setVisible (bool visible) {
    checkWidget ();
    if (drawCount !is 0) {
        if (((state & HIDDEN) is 0) is visible) return;
    } else {
        if (visible is OS.IsWindowVisible (handle)) return;
    }
    if (visible) {
        /*
        * It is possible (but unlikely), that application
        * code could have disposed the widget in the show
        * event.  If this happens, just return.
        */
        sendEvent (SWT.Show);
        if (isDisposed ()) return;
        static if (OS.IsHPC) {
            if (menuBar !is null) {
                auto hwndCB = menuBar.hwndCB;
                OS.CommandBar_DrawMenuBar (hwndCB, 0);
            }
        }
        if (drawCount !is 0) {
            state &= ~HIDDEN;
        } else {
            static if (OS.IsWinCE) {
                OS.ShowWindow (handle, OS.SW_SHOW);
            } else {
                if (menuBar !is null) {
                    display.removeBar (menuBar);
                    OS.DrawMenuBar (handle);
                }
                STARTUPINFO* lpStartUpInfo = Display.lpStartupInfo;
                if (lpStartUpInfo !is null && (lpStartUpInfo.dwFlags & OS.STARTF_USESHOWWINDOW) !is 0) {
                    OS.ShowWindow (handle, lpStartUpInfo.wShowWindow);
                } else {
                    OS.ShowWindow (handle, swFlags);
                }
            }
            if (isDisposed ()) return;
            opened = true;
            if (!moved) {
                moved = true;
                Point location = getLocation ();
                oldX = location.x;
                oldY = location.y;
            }
            if (!resized) {
                resized = true;
                Rectangle rect = getClientArea ();
                oldWidth = rect.width;
                oldHeight = rect.height;
            }
            /*
            * Bug in Windows.  On Vista using the Classic theme, 
            * when the window is hung and UpdateWindow() is called,
            * nothing is drawn, and outstanding WM_PAINTs are cleared.
            * This causes pixel corruption.  The fix is to avoid calling
            * update on hung windows.  
            */
            bool update = true;
            if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0) && !OS.IsAppThemed ()) {
                update = !OS.IsHungAppWindow (handle);
            }
            if (update) OS.UpdateWindow (handle);
        }
    } else {
        static if (!OS.IsWinCE) {
            if (OS.IsIconic (handle)) {
                swFlags = OS.SW_SHOWMINNOACTIVE;
            } else {
                if (OS.IsZoomed (handle)) {
                    swFlags = OS.SW_SHOWMAXIMIZED;
                } else {
                    swFlags = OS.SW_SHOWNOACTIVATE;
                }
            }
        }
        if (drawCount !is 0) {
            state |= HIDDEN;
        } else {
            OS.ShowWindow (handle, OS.SW_HIDE);
        }
        if (isDisposed ()) return;
        sendEvent (SWT.Hide);
    }
}

void sort (Image [] images, ImageData [] datas, int width, int height, int depth) {
    /* Shell Sort from K&R, pg 108 */
    int length = cast(int)/*64bit*/images.length;
    if (length <= 1) return;
    for (int gap=length/2; gap>0; gap/=2) {
        for (int i=gap; i<length; i++) {
            for (int j=i-gap; j>=0; j-=gap) {
                if (compare (datas [j], datas [j + gap], width, height, depth) >= 0) {
                    Image swap = images [j];
                    images [j] = images [j + gap];
                    images [j + gap] = swap;
                    ImageData swapData = datas [j];
                    datas [j] = datas [j + gap];
                    datas [j + gap] = swapData;
                }
            }
        }
    }
}

override bool translateAccelerator (MSG* msg) {
    if (!isEnabled () || !isActive ()) return false;
    if (menuBar !is null && !menuBar.isEnabled ()) return false;
    if (translateMDIAccelerator (msg) || translateMenuAccelerator (msg)) return true;
    Decorations decorations = parent.menuShell ();
    return decorations.translateAccelerator (msg);
}

bool translateMenuAccelerator (MSG* msg) {
    if (hAccel is cast(HACCEL)-1) createAccelerators ();
    return hAccel !is null && OS.TranslateAccelerator (handle, hAccel, msg) !is 0;
}

bool translateMDIAccelerator (MSG* msg) {
    if (!(cast(Shell)this)) {
        Shell shell = getShell ();
        auto hwndMDIClient = shell.hwndMDIClient_;
        if (hwndMDIClient !is null && OS.TranslateMDISysAccel (hwndMDIClient, msg)) {
            return true;
        }
        if (msg.message is OS.WM_KEYDOWN) {
            if (OS.GetKeyState (OS.VK_CONTROL) >= 0) return false;
            switch ((msg.wParam)) {
                case OS.VK_F4:
                    OS.PostMessage (handle, OS.WM_CLOSE, 0, 0);
                    return true;
                case OS.VK_F6:
                    if (traverseDecorations (true)) return true;
                    break;
                default:
                    break;
            }
            return false;
        }
        if (msg.message is OS.WM_SYSKEYDOWN) {
            switch ((msg.wParam)) {
                case OS.VK_F4:
                    OS.PostMessage (shell.handle, OS.WM_CLOSE, 0, 0);
                    return true;
                default:
            }
            return false;
        }
    }
    return false;
}

bool traverseDecorations (bool next) {
    Control [] children = parent._getChildren ();
    int length = cast(int)/*64bit*/children.length;
    int index = 0;
    while (index < length) {
        if (children [index] is this) break;
        index++;
    }
    /*
    * It is possible (but unlikely), that application
    * code could have disposed the widget in focus in
    * or out events.  Ensure that a disposed widget is
    * not accessed.
    */
    int start = index, offset = (next) ? 1 : -1;
    while ((index = (index + offset + length) % length) !is start) {
        Control child = children [index];
        if (!child.isDisposed () && ( null !is cast(Decorations)child)) {
            if (child.setFocus ()) return true;
        }
    }
    return false;
}

override bool traverseItem (bool next) {
    return false;
}

override bool traverseReturn () {
    if (defaultButton is null || defaultButton.isDisposed ()) return false;
    if (!defaultButton.isVisible () || !defaultButton.isEnabled ()) return false;
    defaultButton.click ();
    return true;
}

override CREATESTRUCT* widgetCreateStruct () {
    return new CREATESTRUCT ();
}

override int widgetExtStyle () {
    int bits = super.widgetExtStyle () | OS.WS_EX_MDICHILD;
    bits &= ~OS.WS_EX_CLIENTEDGE;
    if ((style & SWT.NO_TRIM) !is 0) return bits;
    if (OS.IsPPC) {
        if ((style & SWT.CLOSE) !is 0) bits |= OS.WS_EX_CAPTIONOKBTN;
    }
    if ((style & SWT.RESIZE) !is 0) return bits;
    if ((style & SWT.BORDER) !is 0) bits |= OS.WS_EX_DLGMODALFRAME;
    return bits;
}

override HWND widgetParent () {
    Shell shell = getShell ();
    return shell.hwndMDIClient ();
}

override int widgetStyle () {
    /*
    * Clear WS_VISIBLE and WS_TABSTOP.  NOTE: In Windows, WS_TABSTOP
    * has the same value as WS_MAXIMIZEBOX so these bits cannot be
    * used to control tabbing.
    */
    int bits = super.widgetStyle () & ~(OS.WS_TABSTOP | OS.WS_VISIBLE);

    /* Set the title bits and no-trim bits */
    bits &= ~OS.WS_BORDER;
    if ((style & SWT.NO_TRIM) !is 0) return bits;
    if ((style & SWT.TITLE) !is 0) bits |= OS.WS_CAPTION;

    /* Set the min and max button bits */
    if ((style & SWT.MIN) !is 0) bits |= OS.WS_MINIMIZEBOX;
    if ((style & SWT.MAX) !is 0) bits |= OS.WS_MAXIMIZEBOX;

    /* Set the resize, dialog border or border bits */
    if ((style & SWT.RESIZE) !is 0) {
        /*
        * Note on WinCE PPC.  SWT.RESIZE is used to resize
        * the Shell according to the state of the IME.
        * It does not set the WS_THICKFRAME style.
        */
        if (!OS.IsPPC) bits |= OS.WS_THICKFRAME;
    } else {
        if ((style & SWT.BORDER) is 0) bits |= OS.WS_BORDER;
    }

    /* Set the system menu and close box bits */
    if (!OS.IsPPC && !OS.IsSP) {
        if ((style & SWT.CLOSE) !is 0) bits |= OS.WS_SYSMENU;
    }

    return bits;
}

override .LRESULT windowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
        case Display.SWT_GETACCEL:
        case Display.SWT_GETACCELCOUNT:
            if (hAccel is cast(HACCEL)-1) createAccelerators ();
            return msg is Display.SWT_GETACCELCOUNT ? nAccel : cast(.LRESULT)hAccel;
        default:
    }
    return super.windowProc (hwnd, msg, wParam, lParam);
}

override LRESULT WM_ACTIVATE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_ACTIVATE (wParam, lParam);
    if (result !is null) return result;
    /*
    * Feature in AWT.  When an AWT Window is activated,
    * for some reason, it seems to forward the WM_ACTIVATE
    * message to the parent.  Normally, the parent is an
    * AWT Frame.  When AWT is embedded in SWT, the SWT
    * shell gets the WM_ACTIVATE and assumes that it came
    * from Windows.  When an SWT shell is activated it
    * restores focus to the last control that had focus.
    * If this control is an embedded composite, it takes
    * focus from the AWT Window.  The fix is to ignore
    * WM_ACTIVATE messages that come from AWT Windows.
    */
    if (OS.GetParent ( cast(HWND)lParam) is handle) {
        TCHAR[128] buffer = 0;
        OS.GetClassName (cast(HWND)lParam, buffer.ptr, buffer.length );
        String className = TCHARzToStr( buffer.ptr );
        if (className == Display.AWT_WINDOW_CLASS) {
            return LRESULT.ZERO;
        }
    }
    if (OS.LOWORD (wParam) !is 0) {
        /*
        * When the high word of wParam is non-zero, the activation
        * state of the window is being changed while the window is
        * minimized. If this is the case, do not report activation
        * events or restore the focus.
        */
        if (OS.HIWORD (wParam) !is 0) return result;
        Control control = display.findControl (cast(HWND)lParam);
        if (control is null || (null !is cast(Shell)control)) {
            if (cast(Shell)this) {
                sendEvent (SWT.Activate);
                if (isDisposed ()) return LRESULT.ZERO;
            }
        }
        if (restoreFocus ()) return LRESULT.ZERO;
    } else {
        Display display = this.display;
        bool lockWindow = display.isXMouseActive ();
        if (lockWindow) display.lockActiveWindow = true;
        Control control = display.findControl (cast(HWND)lParam);
        if (control is null || (null !is cast(Shell)control)) {
            if (cast(Shell)this) {
                sendEvent (SWT.Deactivate);
                if (!isDisposed ()) {
                    Shell shell = getShell ();
                    shell.setActiveControl (null);
                    // widget could be disposed at this point
                }
            }
        }
        if (lockWindow) display.lockActiveWindow = false;
        if (isDisposed ()) return LRESULT.ZERO;
        saveFocus ();
    }
    return result;
}

override LRESULT WM_CLOSE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_CLOSE (wParam, lParam);
    if (result !is null) return result;
    if (isEnabled () && isActive ()) closeWidget ();
    return LRESULT.ZERO;
}

override LRESULT WM_HOTKEY (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_HOTKEY (wParam, lParam);
    if (result !is null) return result;
    static if( OS.IsWinCE ){
        if (OS.IsSP) {
            /*
            * Feature on WinCE SP.  The Back key is either used to close
            * the foreground Dialog or used as a regular Back key in an EDIT
            * control. The article 'Back Key' in MSDN for Smartphone
            * describes how an application should handle it.  The
            * workaround is to override the Back key when creating
            * the menubar and handle it based on the style of the Shell.
            * If the Shell has the SWT.CLOSE style, close the Shell.
            * Otherwise, send the Back key to the window with focus.
            */
        if (OS.HIWORD (lParam) is OS.VK_ESCAPE) {
                if ((style & SWT.CLOSE) !is 0) {
                    OS.PostMessage (handle, OS.WM_CLOSE, 0, 0);
                } else {
                    OS.SHSendBackToFocusWindow (OS.WM_HOTKEY, wParam, lParam);
                }
                return LRESULT.ZERO;
            }
        }
    }
    return result;
}

override LRESULT WM_KILLFOCUS (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_KILLFOCUS (wParam, lParam);
    saveFocus ();
    return result;
}

override LRESULT WM_MOVE (WPARAM wParam, LPARAM lParam) {
    if (moved) {
        Point location = getLocation ();
        if (location.x is oldX && location.y is oldY) {
            return null;
        }
        oldX = location.x;
        oldY = location.y;
    }
    return super.WM_MOVE (wParam, lParam);
}

override LRESULT WM_NCACTIVATE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_NCACTIVATE (wParam, lParam);
    if (result !is null) return result;
    if (wParam is 0) {
        if (display.lockActiveWindow) return LRESULT.ZERO;
        Control control = display.findControl (cast(HANDLE)lParam);
        if (control !is null) {
            Shell shell = getShell ();
            Decorations decorations = control.menuShell ();
            if (decorations.getShell () is shell) {
                if (cast(Shell)this) return LRESULT.ONE;
                if (display.ignoreRestoreFocus) {
                    if (display.lastHittest !is OS.HTCLIENT) {
                        result = LRESULT.ONE;
                    }
                }
            }
        }
    }
    if (!(cast(Shell)this)) {
        auto hwndShell = getShell().handle;
        OS.SendMessage (hwndShell, OS.WM_NCACTIVATE, wParam, lParam);
    }
    return result;
}

override LRESULT WM_QUERYOPEN (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_QUERYOPEN (wParam, lParam);
    if (result !is null) return result;
    sendEvent (SWT.Deiconify);
    // widget could be disposed at this point
    return result;
}

override LRESULT WM_SETFOCUS (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SETFOCUS (wParam, lParam);
    if (savedFocus !is this) restoreFocus ();
    return result;
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = null;
    bool changed = true;
    if (resized) {
        int newWidth = 0, newHeight = 0;
        switch (wParam) {
            case OS.SIZE_RESTORED:
            case OS.SIZE_MAXIMIZED:
                newWidth = OS.LOWORD (lParam);
                newHeight = OS.HIWORD (lParam);
                break;
            case OS.SIZE_MINIMIZED:
                Rectangle rect = getClientArea ();
                newWidth = rect.width;
                newHeight = rect.height;
                break;
            default:
        }
        changed = newWidth !is oldWidth || newHeight !is oldHeight;
        if (changed) {
            oldWidth = newWidth;
            oldHeight = newHeight;
        }
    }
    if (changed) {
        result = super.WM_SIZE (wParam, lParam);
        if (isDisposed ()) return result;
    }
    if (wParam is OS.SIZE_MINIMIZED) {
        sendEvent (SWT.Iconify);
        // widget could be disposed at this point
    }
    return result;
}

override LRESULT WM_SYSCOMMAND (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SYSCOMMAND (wParam, lParam);
    if (result !is null) return result;
    if (!(cast(Shell)this)) {
        int cmd = wParam & 0xFFF0;
        switch (cmd) {
            case OS.SC_CLOSE: {
                OS.PostMessage (handle, OS.WM_CLOSE, 0, 0);
                return LRESULT.ZERO;
            }
            case OS.SC_NEXTWINDOW: {
                traverseDecorations (true);
                return LRESULT.ZERO;
            }
            default:
        }
    }
    return result;
}

override LRESULT WM_WINDOWPOSCHANGING (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_WINDOWPOSCHANGING (wParam, lParam);
    if (result !is null) return result;
    if (display.lockActiveWindow) {
        WINDOWPOS* lpwp = cast(WINDOWPOS*)lParam;
        //OS.MoveMemory (lpwp, lParam, WINDOWPOS.sizeof);
        lpwp.flags |= OS.SWP_NOZORDER;
        //OS.MoveMemory (lParam, &lpwp, WINDOWPOS.sizeof);
    }
    return result;
}

}
