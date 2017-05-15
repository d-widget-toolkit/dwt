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
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.ImageList;

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
    alias Control.mnemonicHit mnemonicHit;
    alias Control.mnemonicMatch mnemonicMatch;
    alias Control.setBackgroundColor setBackgroundColor;
    alias Control.setBounds setBounds;
    alias Control.setForegroundColor setForegroundColor;

    GtkWidget* frameHandle, labelHandle, imageHandle;
    ImageList imageList;
    Image image;
    String text;

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
    super (parent, checkStyle (style));
}

static int checkStyle (int style) {
    style |= SWT.NO_FOCUS;
    if ((style & SWT.SEPARATOR) !is 0) {
        style = checkBits (style, SWT.VERTICAL, SWT.HORIZONTAL, 0, 0, 0, 0);
        return checkBits (style, SWT.SHADOW_OUT, SWT.SHADOW_IN, SWT.SHADOW_NONE, 0, 0, 0);
    }
    return checkBits (style, SWT.LEFT, SWT.CENTER, SWT.RIGHT, 0, 0, 0);
}

override void addRelation (Control control) {
    if (!control.isDescribedByLabel ()) return;
    if (labelHandle is null) return;
    auto accessible = OS.gtk_widget_get_accessible (labelHandle);
    auto controlAccessible = OS.gtk_widget_get_accessible (control.handle);
    if (accessible !is null && controlAccessible !is null) {
        OS.atk_object_add_relationship (controlAccessible, OS.ATK_RELATION_LABELLED_BY, accessible);
    }
}

public override Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    if (wHint !is SWT.DEFAULT && wHint < 0) wHint = 0;
    if (hHint !is SWT.DEFAULT && hHint < 0) hHint = 0;
    if ((style & SWT.SEPARATOR) !is 0) {
        if ((style & SWT.HORIZONTAL) !is 0) {
            if (wHint is SWT.DEFAULT) wHint = DEFAULT_WIDTH;
        } else {
            if (hHint is SWT.DEFAULT) hHint = DEFAULT_HEIGHT;
        }
    }
    bool fixWrap = labelHandle !is null && (style & SWT.WRAP) !is 0;
    if (fixWrap || frameHandle !is null) forceResize ();
    int labelWidth, labelHeight;
    if (fixWrap) {
        OS.gtk_widget_get_size_request (labelHandle, &labelWidth, &labelHeight);
        OS.gtk_widget_set_size_request (labelHandle, wHint, hHint);
    }
    Point size;
    if (frameHandle !is null) {
        int reqWidth, reqHeight;
        OS.gtk_widget_get_size_request (handle, &reqWidth, &reqHeight);
        OS.gtk_widget_set_size_request (handle, wHint, hHint);
        size = computeNativeSize (frameHandle, -1, -1, changed);
        OS.gtk_widget_set_size_request (handle, reqWidth, reqHeight);
    } else {
        size = computeNativeSize (handle, wHint, hHint, changed);
    }
    if (fixWrap) {
        OS.gtk_widget_set_size_request (labelHandle, labelWidth, labelHeight);
    }
    /*
    * Feature in GTK.  Instead of using the font height to determine
    * the preferred height of the widget, GTK uses the text metrics.
    * The fix is to ensure that the preferred height is at least as
    * tall as the font height.
    *
    * NOTE: This work around does not fix the case when there are
    * muliple lines of text.
    */
    if (hHint is SWT.DEFAULT && labelHandle !is null) {
        auto layout = OS.gtk_label_get_layout (cast(GtkLabel*)labelHandle);
        auto context = OS.pango_layout_get_context (layout);
        auto lang = OS.pango_context_get_language (context);
        auto font = getFontDescription ();
        auto metrics = OS.pango_context_get_metrics (context, font, lang);
        int ascent = OS.PANGO_PIXELS (OS.pango_font_metrics_get_ascent (metrics));
        int descent = OS.PANGO_PIXELS (OS.pango_font_metrics_get_descent (metrics));
        OS.pango_font_metrics_unref (metrics);
        int fontHeight = ascent + descent;
        int  buffer;
        OS.g_object_get1 (labelHandle, OS.ypad.ptr, &buffer);
        fontHeight += 2 * buffer;
        if (frameHandle !is null) {
            auto style = OS.gtk_widget_get_style (frameHandle);
            fontHeight += 2 * OS.gtk_style_get_ythickness (style);
            fontHeight += 2 * OS.gtk_container_get_border_width (cast(GtkContainer*)frameHandle);
        }
        size.y = Math.max (size.y, fontHeight);
    }
    return size;
}

override void createHandle (int index) {
    state |= HANDLE | THEME_BACKGROUND;
    fixedHandle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (fixedHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_fixed_set_has_window (cast(GtkFixed*)fixedHandle, true);
    if ((style & SWT.SEPARATOR) !is 0) {
        if ((style & SWT.HORIZONTAL)!is 0) {
            handle = OS.gtk_hseparator_new ();
        } else {
            handle = OS.gtk_vseparator_new ();
        }
        if (handle is null) error (SWT.ERROR_NO_HANDLES);
    } else {
        handle = OS.gtk_hbox_new (false, 0);
        if (handle is null) error (SWT.ERROR_NO_HANDLES);
        labelHandle = OS.gtk_label_new_with_mnemonic (null);
        if (labelHandle is null) error (SWT.ERROR_NO_HANDLES);
        imageHandle = OS.gtk_image_new ();
        if (imageHandle is null) error (SWT.ERROR_NO_HANDLES);
        OS.gtk_container_add (cast(GtkContainer*)handle, labelHandle);
        OS.gtk_container_add (cast(GtkContainer*)handle, imageHandle);
    }
    if ((style & SWT.BORDER) !is 0) {
        frameHandle = OS.gtk_frame_new (null);
        if (frameHandle is null) error (SWT.ERROR_NO_HANDLES);
        OS.gtk_container_add (cast(GtkContainer*)fixedHandle, frameHandle);
        OS.gtk_container_add (cast(GtkContainer*)frameHandle, handle);
        OS.gtk_frame_set_shadow_type (cast(GtkFrame*)frameHandle, OS.GTK_SHADOW_ETCHED_IN);
    } else {
        OS.gtk_container_add (cast(GtkContainer*)fixedHandle, handle);
    }
    if ((style & SWT.SEPARATOR) !is 0) return;
    if ((style & SWT.WRAP) !is 0) {
        OS.gtk_label_set_line_wrap (labelHandle, true);
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 10, 0)) {
            OS.gtk_label_set_line_wrap_mode (labelHandle, OS.PANGO_WRAP_WORD_CHAR);
        }
    }
    setAlignment ();
}

override void createWidget (int index) {
    super.createWidget (index);
    text = "";
}

override void deregister () {
    super.deregister ();
    if (frameHandle !is null) display.removeWidget (frameHandle);
    if (labelHandle !is null) display.removeWidget (labelHandle);
    if (imageHandle !is null) display.removeWidget (imageHandle);
}

override GtkWidget* eventHandle () {
    return fixedHandle;
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

public override int getBorderWidth () {
    checkWidget();
    if (frameHandle !is null) {
        return OS.gtk_style_get_xthickness (OS.gtk_widget_get_style (frameHandle));
    }
    return 0;
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

override void hookEvents () {
    super.hookEvents();
    if (labelHandle !is null) {
        OS.g_signal_connect_closure_by_id (labelHandle, display.signalIds [MNEMONIC_ACTIVATE], 0, display.closures [MNEMONIC_ACTIVATE], false);
    }
}

override bool isDescribedByLabel () {
    return false;
}

override bool mnemonicHit (wchar key) {
    if (labelHandle is null) return false;
    bool result = super.mnemonicHit (labelHandle, key);
    if (result) {
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
                if (children [index].setFocus ()) return result;
            }
            control = control.parent;
        }
    }
    return result;
}

override bool mnemonicMatch (wchar key) {
    if (labelHandle is null) return false;
    return mnemonicMatch (labelHandle, key);
}

override void register () {
    super.register ();
    if (frameHandle !is null) display.addWidget (frameHandle, this);
    if (labelHandle !is null) display.addWidget (labelHandle, this);
    if (imageHandle !is null) display.addWidget (imageHandle, this);
}

override void releaseHandle () {
    super.releaseHandle ();
    frameHandle = imageHandle = labelHandle = null;
}

override void releaseWidget () {
    super.releaseWidget ();
    if (imageList !is null) imageList.dispose ();
    imageList = null;
    image = null;
    text = null;
}

override void resizeHandle (int width, int height) {
    OS.gtk_widget_set_size_request (fixedHandle, width, height);
    OS.gtk_widget_set_size_request (frameHandle !is null ? frameHandle : handle, width, height);
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
    setAlignment ();
}

void setAlignment () {
    bool isRTL = (style & SWT.RIGHT_TO_LEFT) !is 0;
    if (text !is null && text.length !is 0) {
        if (OS.GTK_VERSION >= OS.buildVERSION(2, 4, 0)) {
            auto layout = OS.gtk_label_get_layout (labelHandle);
            auto linePtr = OS.pango_layout_get_line (layout, 0);
            int resolved_dir = OS.pango_layout_line_get_resolved_dir (linePtr);
            if (resolved_dir is OS.PANGO_DIRECTION_RTL) {
                isRTL = !isRTL;
            }
        }
    }
    if ((style & SWT.LEFT) !is 0) {
        OS.gtk_misc_set_alignment (cast(GtkMisc*)labelHandle, 0.0f, 0.0f);
        OS.gtk_label_set_justify (cast(GtkLabel*)labelHandle, isRTL ? OS.GTK_JUSTIFY_RIGHT : OS.GTK_JUSTIFY_LEFT);
        OS.gtk_misc_set_alignment (cast(GtkMisc*)imageHandle, 0.0f, 0.5f);
        return;
    }
    if ((style & SWT.CENTER) !is 0) {
        OS.gtk_misc_set_alignment (cast(GtkMisc*)labelHandle, 0.5f, 0.0f);
        OS.gtk_label_set_justify (cast(GtkLabel*)labelHandle, OS.GTK_JUSTIFY_CENTER);
        OS.gtk_misc_set_alignment (cast(GtkMisc*)imageHandle, 0.5f, 0.5f);
        return;
    }
    if ((style & SWT.RIGHT) !is 0) {
        OS.gtk_misc_set_alignment (cast(GtkMisc*)labelHandle, 1.0f, 0.0f);
        OS.gtk_label_set_justify (cast(GtkLabel*)labelHandle, isRTL ? OS.GTK_JUSTIFY_LEFT : OS.GTK_JUSTIFY_RIGHT);
        OS.gtk_misc_set_alignment (cast(GtkMisc*)imageHandle, 1.0f, 0.5f);
        return;
    }
}

override void setBackgroundColor (GdkColor* color) {
    super.setBackgroundColor (color);
    setBackgroundColor(fixedHandle, color);
    if (labelHandle !is null) setBackgroundColor(labelHandle, color);
    if (imageHandle !is null) setBackgroundColor(imageHandle, color);
}

override int setBounds (int x, int y, int width, int height, bool move, bool resize) {
    /*
    * Bug in GTK.  For some reason, when the label is
    * wrappable and its container is resized, it does not
    * cause the label to be wrapped.  The fix is to
    * determine the size that will wrap the label
    * and expilictly set that size to force the label
    * to wrap.
    *
    * This part of the fix causes the label to be
    * resized to the preferred size but it still
    * won't draw properly.
    */
    bool fixWrap = resize && labelHandle !is null && (style & SWT.WRAP) !is 0;
    if (fixWrap) OS.gtk_widget_set_size_request (labelHandle, -1, -1);
    int result = super.setBounds (x, y, width, height, move, resize);
    /*
    * Bug in GTK.  For some reason, when the label is
    * wrappable and its container is resized, it does not
    * cause the label to be wrapped.  The fix is to
    * determine the size that will wrap the label
    * and expilictly set that size to force the label
    * to wrap.
    *
    * This part of the fix forces the label to be
    * resized so that it will draw wrapped.
    */
    if (fixWrap) {
        int labelWidth = OS.GTK_WIDGET_WIDTH (handle);
        int labelHeight = OS.GTK_WIDGET_HEIGHT (handle);
        OS.gtk_widget_set_size_request (labelHandle, labelWidth, labelHeight);
        /*
        * Bug in GTK.  Setting the size request should invalidate the label's
        * layout, but it does not.  The fix is to resize the label directly.
        */
        GtkRequisition requisition;
        OS.gtk_widget_size_request (labelHandle, &requisition);
        GtkAllocation allocation;
        allocation.x = OS.GTK_WIDGET_X (labelHandle);
        allocation.y = OS.GTK_WIDGET_Y (labelHandle);
        allocation.width = labelWidth;
        allocation.height = labelHeight;
        OS.gtk_widget_size_allocate (labelHandle, &allocation);
    }
    return result;
}

override void setFontDescription (PangoFontDescription* font) {
    super.setFontDescription (font);
    if (labelHandle !is null) OS.gtk_widget_modify_font (labelHandle, font);
    if (imageHandle !is null) OS.gtk_widget_modify_font (imageHandle, font);
}

override void setForegroundColor (GdkColor* color) {
    super.setForegroundColor (color);
    setForegroundColor (fixedHandle, color);
    if (labelHandle !is null) setForegroundColor (labelHandle, color);
    if (imageHandle !is null) setForegroundColor (imageHandle, color);
}

override void setOrientation () {
    super.setOrientation ();
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        if (labelHandle !is null) OS.gtk_widget_set_direction (labelHandle, OS.GTK_TEXT_DIR_RTL);
        if (imageHandle !is null) OS.gtk_widget_set_direction (imageHandle, OS.GTK_TEXT_DIR_RTL);
    }
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
    this.image = image;
    if (imageList !is null) imageList.dispose ();
    imageList = null;
    if (image !is null) {
        imageList = new ImageList ();
        int imageIndex = imageList.add (image);
        auto pixbuf = imageList.getPixbuf (imageIndex);
        OS.gtk_image_set_from_pixbuf (cast(GtkImage*)imageHandle, pixbuf);
        OS.gtk_widget_hide (labelHandle);
        OS.gtk_widget_show (imageHandle);
    } else {
        OS.gtk_image_set_from_pixbuf (cast(GtkImage*)imageHandle, null);
        OS.gtk_widget_show (labelHandle);
        OS.gtk_widget_hide (imageHandle);
    }
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
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if ((style & SWT.SEPARATOR) !is 0) return;
    text = string;
    char [] chars = fixMnemonic (string);
    OS.gtk_label_set_text_with_mnemonic (cast(GtkLabel*)labelHandle, chars.toStringzValidPtr());
    OS.gtk_widget_hide (imageHandle);
    OS.gtk_widget_show (labelHandle);
    setAlignment ();
}

override void showWidget () {
    super.showWidget ();
    if (frameHandle !is null) OS.gtk_widget_show (frameHandle);
    if (labelHandle !is null) OS.gtk_widget_show (labelHandle);
}
}
