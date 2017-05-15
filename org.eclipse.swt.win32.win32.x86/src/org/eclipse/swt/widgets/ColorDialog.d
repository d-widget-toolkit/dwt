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
module org.eclipse.swt.widgets.ColorDialog;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.internal.win32.OS;


import org.eclipse.swt.widgets.Dialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Display;


/**
 * Instances of this class allow the user to select a color
 * from a predefined set of available colors.
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
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample, Dialog tab</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class ColorDialog : Dialog {
    Display display;
    int width, height;
    RGB rgb;
    private static ColorDialog sThis;

/**
 * Constructs a new instance of this class given only its parent.
 *
 * @param parent a composite control which will be the parent of the new instance
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
public this (Shell parent) {
    this (parent, SWT.APPLICATION_MODAL);
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
 * @see SWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Shell parent, int style) {
    super (parent, checkStyle (parent, style));
    checkSubclass ();
}

private static extern(Windows) UINT_PTR CCHookFunc (HWND hdlg, uint uiMsg, WPARAM lParam, LPARAM lpData) {
    return sThis.CCHookProc( hdlg, uiMsg, lParam );
}

int CCHookProc (HWND hdlg, WPARAM uiMsg, LPARAM lParam ) {
    switch (uiMsg) {
        case OS.WM_INITDIALOG: {
            RECT rect;
            OS.GetWindowRect (hdlg, &rect);
            width = rect.right - rect.left;
            height = rect.bottom - rect.top;
            if (title !is null && title.length !is 0) {
                /* Use the character encoding for the default locale */
                OS.SetWindowText (hdlg, StrToTCHARz(title));
            }
            break;
        }
        case OS.WM_DESTROY: {
            RECT rect;
            OS.GetWindowRect (hdlg, &rect);
            int newWidth = rect.right - rect.left;
            int newHeight = rect.bottom - rect.top;
            if (newWidth < width || newHeight < height) {
                //display.fullOpen = false;
            } else {
                if (newWidth > width || newHeight > height) {
                    //display.fullOpen = true;
                }
            }
            break;
        }
        default:
    }
    return 0;
}

/**
 * Returns the currently selected color in the receiver.
 *
 * @return the RGB value for the selected color, may be null
 *
 * @see PaletteData#getRGBs
 */
public RGB getRGB () {
    return rgb;
}

/**
 * Makes the receiver visible and brings it to the front
 * of the display.
 *
 * @return the selected color, or null if the dialog was
 *         cancelled, no color was selected, or an error
 *         occurred
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public RGB open () {

    /* Get the owner HWND for the dialog */
    auto hwndOwner = parent.handle;
    auto hwndParent = parent.handle;

    /*
    * Feature in Windows.  There is no API to set the orientation of a
    * color dialog.  It is always inherited from the parent.  The fix is
    * to create a hidden parent and set the orientation in the hidden
    * parent for the dialog to inherit.
    */
    bool enabled = false;
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION(4, 10)) {
        int dialogOrientation = style & (SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT);
        int parentOrientation = parent.style & (SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT);
        if (dialogOrientation !is parentOrientation) {
            int exStyle = OS.WS_EX_NOINHERITLAYOUT;
            if (dialogOrientation is SWT.RIGHT_TO_LEFT) exStyle |= OS.WS_EX_LAYOUTRTL;
            hwndOwner = OS.CreateWindowEx (
                exStyle,
                Shell.DialogClass.ptr,
                null,
                0,
                OS.CW_USEDEFAULT, 0, OS.CW_USEDEFAULT, 0,
                hwndParent,
                null,
                OS.GetModuleHandle (null),
                null);
            enabled = OS.IsWindowEnabled (hwndParent) !is 0;
            if (enabled) OS.EnableWindow (hwndParent, false);
        }
    }

    /* Create the CCHookProc */
    //Callback callback = new Callback (this, "CCHookProc", 4); //$NON-NLS-1$
    //int lpfnHook = callback.getAddress ();
    //if (lpfnHook is 0) SWT.error(SWT.ERROR_NO_MORE_CALLBACKS);

    /* Allocate the Custom Colors */
    display = parent.display;
    if (display.lpCustColors is null) {
        auto hHeap = OS.GetProcessHeap ();
        display.lpCustColors = cast(uint*)OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, 16 * 4);
    }

    /* Open the dialog */
    CHOOSECOLOR lpcc;
    lpcc.lCustData = cast(ptrdiff_t)cast(void*)this;
    lpcc.lStructSize = CHOOSECOLOR.sizeof;
    lpcc.Flags = OS.CC_ANYCOLOR | OS.CC_ENABLEHOOK;
    //if (display.fullOpen) lpcc.Flags |= OS.CC_FULLOPEN;
    lpcc.lpfnHook = &CCHookFunc;
    lpcc.hwndOwner = hwndOwner;
    lpcc.lpCustColors = display.lpCustColors;
    if (rgb !is null) {
        lpcc.Flags |= OS.CC_RGBINIT;
        int red = rgb.red & 0xFF;
        int green = (rgb.green << 8) & 0xFF00;
        int blue = (rgb.blue << 16) & 0xFF0000;
        lpcc.rgbResult = red | green | blue;
    }

    /* Make the parent shell be temporary modal */
    Dialog oldModal = null;
    if ((style & (SWT.APPLICATION_MODAL | SWT.SYSTEM_MODAL)) !is 0) {
        oldModal = display.getModalDialog ();
        display.setModalDialog (this);
    }

    /* Open the dialog */
    bool success;
    synchronized {
        sThis = this;
        success = cast(bool) OS.ChooseColor (&lpcc);
        sThis = null;
    }

    /* Clear the temporary dialog modal parent */
    if ((style & (SWT.APPLICATION_MODAL | SWT.SYSTEM_MODAL)) !is 0) {
        display.setModalDialog (oldModal);
    }

    if (success) {
        int red = lpcc.rgbResult & 0xFF;
        int green = (lpcc.rgbResult >> 8) & 0xFF;
        int blue = (lpcc.rgbResult >> 16) & 0xFF;
        rgb = new RGB (red, green, blue);
    }

    /* Free the CCHookProc */
    //callback.dispose ();

    /* Free the Custom Colors */
    /*
    * This code is intentionally commented.  Currently,
    * there is exactly one set of custom colors per display.
    * The memory associated with these colors is released
    * when the display is disposed.
    */
//  if (lpCustColors !is 0) OS.HeapFree (hHeap, 0, lpCustColors);

    /* Destroy the BIDI orientation window */
    if (hwndParent !is hwndOwner) {
        if (enabled) OS.EnableWindow (hwndParent, true);
        OS.SetActiveWindow (hwndParent);
        OS.DestroyWindow (hwndOwner);
    }

    /*
    * This code is intentionally commented.  On some
    * platforms, the owner window is repainted right
    * away when a dialog window exits.  This behavior
    * is currently unspecified.
    */
//  if (hwndOwner !is 0) OS.UpdateWindow (hwndOwner);

    display = null;
    if (!success) return null;
    return rgb;
}

/**
 * Sets the receiver's selected color to be the argument.
 *
 * @param rgb the new RGB value for the selected color, may be
 *        null to let the platform select a default when
 *        open() is called
 * @see PaletteData#getRGBs
 */
public void setRGB (RGB rgb) {
    this.rgb = rgb;
}

}
