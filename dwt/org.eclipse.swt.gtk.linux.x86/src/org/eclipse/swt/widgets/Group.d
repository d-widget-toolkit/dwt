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
module org.eclipse.swt.widgets.Group;

import java.lang.all;


import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Composite;


/**
 * Instances of this class provide an etched border
 * with an optional title.
 * <p>
 * Shadow styles are hints and may not be honoured
 * by the platform.  To create a group with the
 * default shadow style for the platform, do not
 * specify a shadow style.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>SHADOW_ETCHED_IN, SHADOW_ETCHED_OUT, SHADOW_IN, SHADOW_OUT, SHADOW_NONE</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: Only one of the above styles may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 * 
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Group : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.createHandle createHandle;
    alias Composite.mnemonicHit mnemonicHit;
    alias Composite.mnemonicMatch mnemonicMatch;
    alias Composite.setBackgroundColor setBackgroundColor;
    alias Composite.setForegroundColor setForegroundColor;

    GtkWidget* clientHandle_, labelHandle;
    String text = "";

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
 * @see SWT#SHADOW_ETCHED_IN
 * @see SWT#SHADOW_ETCHED_OUT
 * @see SWT#SHADOW_IN
 * @see SWT#SHADOW_OUT
 * @see SWT#SHADOW_NONE
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

static int checkStyle (int style) {
    style |= SWT.NO_FOCUS;
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

override GtkWidget* clientHandle () {
    return clientHandle_;
}

public override Point computeSize (int wHint, int hHint, bool changed) {
    Point size = super.computeSize(wHint, hHint, changed);
    int width = computeNativeSize (handle, SWT.DEFAULT, SWT.DEFAULT, false).x;
    size.x = Math.max (size.x, width);
    return size;
}
public override Rectangle computeTrim (int x, int y, int width, int height) {
    checkWidget();
    forceResize ();
    ptrdiff_t clientX = OS.GTK_WIDGET_X (clientHandle_);
    ptrdiff_t clientY = OS.GTK_WIDGET_Y (clientHandle_);
    x -= clientX;
    y -= clientY;
    width += clientX + clientX;
    height += clientX + clientY;
    return new Rectangle (x, y, width, height);
}

override void createHandle(int index) {
    state |= HANDLE | THEME_BACKGROUND;
    fixedHandle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (fixedHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_fixed_set_has_window (cast(GtkFixed*)fixedHandle, true);
    handle = OS.gtk_frame_new (null);
    if (handle is null) error (SWT.ERROR_NO_HANDLES);
    labelHandle = cast(GtkWidget*)OS.gtk_label_new (null);
    if (labelHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.g_object_ref (labelHandle);
    OS.gtk_object_sink (cast(GtkObject*)labelHandle);
    clientHandle_ = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (clientHandle_ is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_container_add (cast(GtkContainer*)fixedHandle, handle);
    OS.gtk_container_add (cast(GtkContainer*)handle, clientHandle_);
    if ((style & SWT.SHADOW_IN) !is 0) {
        OS.gtk_frame_set_shadow_type (cast(GtkFrame*)handle, OS.GTK_SHADOW_IN);
    }
    if ((style & SWT.SHADOW_OUT) !is 0) {
        OS.gtk_frame_set_shadow_type (cast(GtkFrame*)handle, OS.GTK_SHADOW_OUT);
    }
    if ((style & SWT.SHADOW_ETCHED_IN) !is 0) {
        OS.gtk_frame_set_shadow_type (cast(GtkFrame*)handle, OS.GTK_SHADOW_ETCHED_IN);
    }
    if ((style & SWT.SHADOW_ETCHED_OUT) !is 0) {
        OS.gtk_frame_set_shadow_type (cast(GtkFrame*)handle, OS.GTK_SHADOW_ETCHED_OUT);
    }
}

override void deregister () {
    super.deregister ();
    display.removeWidget (clientHandle_);
    display.removeWidget (labelHandle);
}

override void enableWidget (bool enabled) {
    OS.gtk_widget_set_sensitive (labelHandle, enabled);
}

override GtkWidget* eventHandle () {
    return fixedHandle;
}

override String getNameText () {
    return getText ();
}

/**
 * Returns the receiver's text, which is the string that the
 * is used as the <em>title</em>. If the text has not previously
 * been set, returns an empty string.
 *
 * @return the text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText () {
    checkWidget();
    return text;
}

override void hookEvents () {
    super.hookEvents();
    if (labelHandle !is null) {
        OS.g_signal_connect_closure_by_id (labelHandle, display.signalIds [MNEMONIC_ACTIVATE], 0, display.closures [MNEMONIC_ACTIVATE], false);
    }
}

override bool mnemonicHit (wchar key) {
    if (labelHandle is null) return false;
    bool result = super.mnemonicHit (labelHandle, key);
    if (result) setFocus ();
    return result;
}

override bool mnemonicMatch (wchar key) {
    if (labelHandle is null) return false;
    return mnemonicMatch (labelHandle, key);
}

override GtkWidget* parentingHandle() {
    return fixedHandle;
}

override void register () {
    super.register ();
    display.addWidget (clientHandle_, this);
    display.addWidget (labelHandle, this);
}

override void releaseHandle () {
    super.releaseHandle ();
    clientHandle_ = labelHandle = null;
}

override void releaseWidget () {
    super.releaseWidget ();
    if (labelHandle !is null) OS.g_object_unref (labelHandle);
    text = null;
}

override void setBackgroundColor (GdkColor* color) {
    super.setBackgroundColor (color);
    setBackgroundColor(fixedHandle, color);
}

override void setFontDescription (PangoFontDescription* font) {
    super.setFontDescription (font);
    OS.gtk_widget_modify_font (labelHandle, font);
}

override void setForegroundColor (GdkColor* color) {
    super.setForegroundColor (color);
    setForegroundColor (labelHandle, color);
}

override void setOrientation () {
    super.setOrientation ();
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        OS.gtk_widget_set_direction (labelHandle, OS.GTK_TEXT_DIR_RTL);
    }
}

/**
 * Sets the receiver's text, which is the string that will
 * be displayed as the receiver's <em>title</em>, to the argument,
 * which may not be null. The string may include the mnemonic character.
 * </p>
 * Mnemonics are indicated by an '&amp;' that causes the next
 * character to be the mnemonic.  When the user presses a
 * key sequence that matches the mnemonic, focus is assigned
 * to the first child of the group. On most platforms, the
 * mnemonic appears underlined but may be emphasised in a
 * platform specific manner.  The mnemonic indicator character
 * '&amp;' can be escaped by doubling it in the string, causing
 * a single '&amp;' to be displayed.
 * </p>
 * @param string the new text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setText (String string) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    text = string;
    char [] chars = fixMnemonic (string);
    OS.gtk_label_set_text_with_mnemonic (cast(GtkLabel*)labelHandle, chars.toStringzValidPtr());
    if (string.length !is 0) {
        if (OS.gtk_frame_get_label_widget (cast(GtkFrame*)handle) is null) {
            OS.gtk_frame_set_label_widget (cast(GtkFrame*)handle, labelHandle);
        }
    } else {
        OS.gtk_frame_set_label_widget (cast(GtkFrame*)handle, null);
    }
}

override void showWidget () {
    super.showWidget ();
    if (clientHandle_ !is null) OS.gtk_widget_show (clientHandle_);
    if (labelHandle !is null) OS.gtk_widget_show (labelHandle);
}
}
