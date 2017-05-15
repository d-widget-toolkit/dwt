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
module org.eclipse.swt.widgets.FontDialog;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.FontData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Dialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Display;

import java.lang.all;

/**
 * Instances of this class allow the user to select a font
 * from all available fonts in the system.
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
public class FontDialog : Dialog {
    FontData fontData;
    RGB rgb;
/**
 * Constructs a new instance of this class given only its parent.
 *
 * @param parent a shell which will be the parent of the new instance
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
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
 * @param parent a shell which will be the parent of the new instance
 * @param style the style of dialog to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
public this (Shell parent, int style) {
    super (parent, checkStyle (parent, style));
    checkSubclass ();
}

/**
 * Returns a FontData object describing the font that was
 * selected in the dialog, or null if none is available.
 *
 * @return the FontData for the selected font, or null
 * @deprecated use #getFontList ()
 */
public FontData getFontData () {
    return fontData;
}

/**
 * Returns a FontData set describing the font that was
 * selected in the dialog, or null if none is available.
 *
 * @return the FontData for the selected font, or null
 * @since 2.1.1
 */
public FontData [] getFontList () {
    if (fontData is null) return null;
    FontData [] result = new FontData [1];
    result [0] = fontData;
    return result;
}

/**
 * Returns an RGB describing the color that was selected
 * in the dialog, or null if none is available.
 *
 * @return the RGB value for the selected color, or null
 *
 * @see PaletteData#getRGBs
 *
 * @since 2.1
 */
public RGB getRGB () {
    return rgb;
}

/**
 * Makes the dialog visible and brings it to the front
 * of the display.
 *
 * @return a FontData object describing the font that was selected,
 *         or null if the dialog was cancelled or an error occurred
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the dialog has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the dialog</li>
 * </ul>
 */
public FontData open () {
    GtkWidget* handle;
    char* titleBytes;
    titleBytes = toStringz(title);
    Display display = parent !is null ? parent.getDisplay (): Display.getCurrent ();
    handle = OS.gtk_font_selection_dialog_new (titleBytes);
    if (parent !is null) {
        auto shellHandle = parent.topHandle ();
        OS.gtk_window_set_transient_for(handle, shellHandle);
        auto pixbufs = OS.gtk_window_get_icon_list (shellHandle);
        if (pixbufs !is null) {
            OS.gtk_window_set_icon_list (handle, pixbufs);
            OS.g_list_free (pixbufs);
        }
    }
    if (fontData !is null) {
        Font font = new Font (display, fontData);
        auto fontName = OS.pango_font_description_to_string (font.handle);
        font.dispose();
        OS.gtk_font_selection_dialog_set_font_name (handle, fontName);
        OS.g_free (fontName);
    }
    display.addIdleProc ();
    Dialog oldModal = null;
    if (OS.gtk_window_get_modal (handle)) {
        oldModal = display.getModalDialog ();
        display.setModalDialog (this);
    }
    int signalId = 0;
    ptrdiff_t hookId = 0;
    CallbackData emissionData;
    emissionData.display = display;
    emissionData.data = handle;
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        signalId = OS.g_signal_lookup (OS.map.ptr, OS.GTK_TYPE_WIDGET());
        hookId = OS.g_signal_add_emission_hook (signalId, 0, &Display.emissionFunc, &emissionData, null);
    }
    int response = OS.gtk_dialog_run (handle);
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        OS.g_signal_remove_emission_hook (signalId, hookId);
    }
    if (OS.gtk_window_get_modal (handle)) {
        display.setModalDialog (oldModal);
    }
    bool success = response is OS.GTK_RESPONSE_OK;
    if (success) {
        auto fontName = OS.gtk_font_selection_dialog_get_font_name (handle);
        auto fontDesc = OS.pango_font_description_from_string (fontName);
        OS.g_free (fontName);
        Font font = Font.gtk_new (display, fontDesc);
        fontData = font.getFontData () [0];
        OS.pango_font_description_free (fontDesc);
    }
    display.removeIdleProc ();
    OS.gtk_widget_destroy(handle);
    if (!success) return null;
    return fontData;
}
/**
 * Sets a FontData object describing the font to be
 * selected by default in the dialog, or null to let
 * the platform choose one.
 *
 * @param fontData the FontData to use initially, or null
 * @deprecated use #setFontList (FontData [])
 */
public void setFontData (FontData fontData) {
    this.fontData = fontData;
}

/**
 * Sets the set of FontData objects describing the font to
 * be selected by default in the dialog, or null to let
 * the platform choose one.
 *
 * @param fontData the set of FontData objects to use initially, or null
 *        to let the platform select a default when open() is called
 *
 * @see Font#getFontData
 *
 * @since 2.1.1
 */
public void setFontList (FontData [] fontData) {
    if (fontData !is null && fontData.length > 0) {
        this.fontData = fontData [0];
    } else {
        this.fontData = null;
    }
}
/**
 * Sets the RGB describing the color to be selected by default
 * in the dialog, or null to let the platform choose one.
 *
 * @param rgb the RGB value to use initially, or null to let
 *        the platform select a default when open() is called
 *
 * @see PaletteData#getRGBs
 *
 * @since 2.1
 */
public void setRGB (RGB rgb) {
    this.rgb = rgb;
}
}
