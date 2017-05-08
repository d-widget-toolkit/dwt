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
module org.eclipse.swt.widgets.Button;

import java.lang.all;

import org.eclipse.swt.widgets.Control;

import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.ImageList;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Decorations;


/**
 * Instances of this class represent a selectable user interface object that
 * issues notification when pressed and released.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>ARROW, CHECK, PUSH, RADIO, TOGGLE, FLAT</dd>
 * <dd>UP, DOWN, LEFT, RIGHT, CENTER</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles ARROW, CHECK, PUSH, RADIO, and TOGGLE
 * may be specified.
 * </p><p>
 * Note: Only one of the styles LEFT, RIGHT, and CENTER may be specified.
 * </p><p>
 * Note: Only one of the styles UP, DOWN, LEFT, and RIGHT may be specified
 * when the ARROW style is specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 * 
 * @see <a href="http://www.eclipse.org/swt/snippets/#button">Button snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Button : Control {

    alias Control.computeSize computeSize;
    alias Control.mnemonicHit mnemonicHit;
    alias Control.mnemonicMatch mnemonicMatch;
    alias Control.setBackgroundColor setBackgroundColor;
    alias Control.setForegroundColor setForegroundColor;

    GtkWidget* boxHandle, labelHandle, imageHandle, arrowHandle, groupHandle;
    bool selected, grayed;
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
 * @see SWT#ARROW
 * @see SWT#CHECK
 * @see SWT#PUSH
 * @see SWT#RADIO
 * @see SWT#TOGGLE
 * @see SWT#FLAT
 * @see SWT#LEFT
 * @see SWT#RIGHT
 * @see SWT#CENTER
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

static int checkStyle (int style) {
    style = checkBits (style, SWT.PUSH, SWT.ARROW, SWT.CHECK, SWT.RADIO, SWT.TOGGLE, 0);
    if ((style & (SWT.PUSH | SWT.TOGGLE)) !is 0) {
        return checkBits (style, SWT.CENTER, SWT.LEFT, SWT.RIGHT, 0, 0, 0);
    }
    if ((style & (SWT.CHECK | SWT.RADIO)) !is 0) {
        return checkBits (style, SWT.LEFT, SWT.RIGHT, SWT.CENTER, 0, 0, 0);
    }
    if ((style & SWT.ARROW) !is 0) {
        style |= SWT.NO_FOCUS;
        return checkBits (style, SWT.UP, SWT.DOWN, SWT.LEFT, SWT.RIGHT, 0, 0);
    }
    return style;
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
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    if (wHint !is SWT.DEFAULT && wHint < 0) wHint = 0;
    if (hHint !is SWT.DEFAULT && hHint < 0) hHint = 0;
    /*
    * Feature in GTK, GtkCheckButton and GtkRadioButton allocate
    * only the minimum size necessary for its child. This causes the child
    * alignment to fail. The fix is to set the child size to the size
    * of the button.
    */
    forceResize ();
    int reqWidth = -1, reqHeight = -1;
    if ((style & (SWT.CHECK | SWT.RADIO)) !is 0) {
        OS.gtk_widget_get_size_request (boxHandle, &reqWidth, &reqHeight);
        OS.gtk_widget_set_size_request (boxHandle, -1, -1);
    }
    Point size = computeNativeSize (handle, wHint, hHint, changed);
    if ((style & (SWT.CHECK | SWT.RADIO)) !is 0) {
        OS.gtk_widget_set_size_request (boxHandle, reqWidth, reqHeight);
    }
    if (wHint !is SWT.DEFAULT || hHint !is SWT.DEFAULT) {
        if ((OS.GTK_WIDGET_FLAGS (handle) & OS.GTK_CAN_DEFAULT) !is 0) {
            GtkBorder border;
            GtkBorder* buffer;
            OS.gtk_widget_style_get1 (handle, OS.default_border.ptr, cast(int*)&buffer );
            if (buffer !is null) {
                border = *buffer;
            } else {
                /* Use the GTK+ default value of 1 for each. */
                border.left = border.right = border.top = border.bottom = 1;
            }
            if (wHint !is SWT.DEFAULT) size.x += border.left + border.right;
            if (hHint !is SWT.DEFAULT) size.y += border.top + border.bottom;
        }
    }
    return size;
}

override void createHandle (int index) {
    state |= HANDLE;
    if ((style & (SWT.PUSH | SWT.TOGGLE)) is 0) state |= THEME_BACKGROUND;
    int bits = SWT.ARROW | SWT.TOGGLE | SWT.CHECK | SWT.RADIO | SWT.PUSH;
    fixedHandle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (fixedHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_fixed_set_has_window (cast(GtkFixed*)fixedHandle, true);
    switch (style & bits) {
        case SWT.ARROW:
            int arrow_type = OS.GTK_ARROW_UP;
            if ((style & SWT.UP) !is 0) arrow_type = OS.GTK_ARROW_UP;
            if ((style & SWT.DOWN) !is 0) arrow_type = OS.GTK_ARROW_DOWN;
            if ((style & SWT.LEFT) !is 0) arrow_type = OS.GTK_ARROW_LEFT;
            if ((style & SWT.RIGHT) !is 0) arrow_type = OS.GTK_ARROW_RIGHT;
            handle = OS.gtk_button_new ();
            if (handle is null) error (SWT.ERROR_NO_HANDLES);
            arrowHandle = OS.gtk_arrow_new (arrow_type, OS.GTK_SHADOW_OUT);
            if (arrowHandle is null) error (SWT.ERROR_NO_HANDLES);
            break;
        case SWT.TOGGLE:
            handle = OS.gtk_toggle_button_new ();
            if (handle is null) error (SWT.ERROR_NO_HANDLES);
            break;
        case SWT.CHECK:
            handle = OS.gtk_check_button_new ();
            if (handle is null) error (SWT.ERROR_NO_HANDLES);
            break;
        case SWT.RADIO:
            /*
            * Feature in GTK.  In GTK, radio button must always be part of
            * a radio button group.  In a GTK radio group, one button is always
            * selected.  This means that it is not possible to have a single
            * radio button that is unselected.  This is necessary to allow
            * applications to implement their own radio behavior or use radio
            * buttons outside of radio groups.  The fix is to create a hidden
            * radio button for each radio button we create and add them
            * to the same group.  This allows the visible button to be
            * unselected.
            */
            groupHandle = cast(GtkWidget*)OS.gtk_radio_button_new (null);
            if (groupHandle is null) error (SWT.ERROR_NO_HANDLES);
            OS.g_object_ref (groupHandle);
            OS.gtk_object_sink (cast(GtkObject*)groupHandle);
            handle = OS.gtk_radio_button_new ( OS.gtk_radio_button_get_group (cast(GtkRadioButton*)groupHandle));
            if (handle is null) error (SWT.ERROR_NO_HANDLES);
            break;
        case SWT.PUSH:
        default:
            handle = OS.gtk_button_new ();
            if (handle is null) error (SWT.ERROR_NO_HANDLES);
            OS.GTK_WIDGET_SET_FLAGS(handle, OS.GTK_CAN_DEFAULT);
            break;
    }
    if ((style & SWT.ARROW) !is 0) {
        OS.gtk_container_add (cast(GtkContainer*)handle, arrowHandle);
    } else {
        boxHandle = OS.gtk_hbox_new (false, 4);
        if (boxHandle is null) error (SWT.ERROR_NO_HANDLES);
        labelHandle = OS.gtk_label_new_with_mnemonic (null);
        if (labelHandle is null) error (SWT.ERROR_NO_HANDLES);
        imageHandle = OS.gtk_image_new ();
        if (imageHandle is null) error (SWT.ERROR_NO_HANDLES);
        OS.gtk_container_add (cast(GtkContainer*)handle, boxHandle);
        OS.gtk_container_add (cast(GtkContainer*)boxHandle, imageHandle);
        OS.gtk_container_add (cast(GtkContainer*)boxHandle, labelHandle);
    }
    OS.gtk_container_add (cast(GtkContainer*)fixedHandle, handle);

    if ((style & SWT.ARROW) !is 0) return;
    _setAlignment (style & (SWT.LEFT | SWT.CENTER | SWT.RIGHT));
}

override void createWidget (int index) {
    super.createWidget (index);
    text = "";
}

override void deregister () {
    super.deregister ();
    if (boxHandle !is null) display.removeWidget (boxHandle);
    if (labelHandle !is null) display.removeWidget (labelHandle);
    if (imageHandle !is null) display.removeWidget (imageHandle);
    if (arrowHandle !is null) display.removeWidget (arrowHandle);
}

override GtkWidget* fontHandle () {
    if (labelHandle !is null) return labelHandle;
    return super.fontHandle ();
}

/**
 * Returns a value which describes the position of the
 * text or image in the receiver. The value will be one of
 * <code>LEFT</code>, <code>RIGHT</code> or <code>CENTER</code>
 * unless the receiver is an <code>ARROW</code> button, in
 * which case, the alignment will indicate the direction of
 * the arrow (one of <code>LEFT</code>, <code>RIGHT</code>,
 * <code>UP</code> or <code>DOWN</code>).
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
    if ((style & SWT.ARROW) !is 0) {
        if ((style & SWT.UP) !is 0) return SWT.UP;
        if ((style & SWT.DOWN) !is 0) return SWT.DOWN;
        if ((style & SWT.LEFT) !is 0) return SWT.LEFT;
        if ((style & SWT.RIGHT) !is 0) return SWT.RIGHT;
        return SWT.UP;
    }
    if ((style & SWT.LEFT) !is 0) return SWT.LEFT;
    if ((style & SWT.CENTER) !is 0) return SWT.CENTER;
    if ((style & SWT.RIGHT) !is 0) return SWT.RIGHT;
    return SWT.LEFT;
}

/**
 * Returns <code>true</code> if the receiver is grayed,
 * and false otherwise. When the widget does not have
 * the <code>CHECK</code> style, return false.
 *
 * @return the grayed state of the checkbox
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.4
 */
public bool getGrayed () {
    checkWidget();
    if ((style & SWT.CHECK) is 0) return false;
    return grayed;
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
 * Returns <code>true</code> if the receiver is selected,
 * and false otherwise.
 * <p>
 * When the receiver is of type <code>CHECK</code> or <code>RADIO</code>,
 * it is selected when it is checked. When it is of type <code>TOGGLE</code>,
 * it is selected when it is pushed in. If the receiver is of any other type,
 * this method returns false.
 *
 * @return the selection state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getSelection () {
    checkWidget ();
    if ((style & (SWT.CHECK | SWT.RADIO | SWT.TOGGLE)) is 0) return false;
    return cast(bool)OS.gtk_toggle_button_get_active (cast(GtkToggleButton*)handle);
}

/**
 * Returns the receiver's text, which will be an empty
 * string if it has never been set or if the receiver is
 * an <code>ARROW</code> button.
 *
 * @return the receiver's text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText () {
    checkWidget();
    if ((style & SWT.ARROW) !is 0) return "";
    return text;
}

override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* event) {
    auto result = super.gtk_button_press_event (widget, event);
    if (result !is 0) return result;
    if ((style & SWT.RADIO) !is 0) selected  = getSelection ();
    return result;
}

override int gtk_clicked (GtkWidget* widget) {
    if ((style & SWT.RADIO) !is 0) {
        if ((parent.getStyle () & SWT.NO_RADIO_GROUP) !is 0) {
            setSelection (!selected);
        } else {
            selectRadio ();
        }
    } else {
        if ((style & SWT.CHECK) !is 0) {
            if (grayed) {
                if (OS.gtk_toggle_button_get_active (handle)) {
                    OS.gtk_toggle_button_set_inconsistent (handle, true);
                } else {
                    OS.gtk_toggle_button_set_inconsistent (handle, false);
                }
            }
        }
    }
    postEvent (SWT.Selection);
    return 0;
}

override int gtk_focus_in_event (GtkWidget* widget, GdkEventFocus* event) {
    auto result = super.gtk_focus_in_event (widget, event);
    // widget could be disposed at this point
    if (handle is null) return 0;
    if ((style & SWT.PUSH) !is 0 && OS.GTK_WIDGET_HAS_DEFAULT (handle)) {
        Decorations menuShell = menuShell ();
        menuShell.defaultButton = this;
    }
    return result;
}

override int gtk_focus_out_event (GtkWidget* widget, GdkEventFocus* event) {
    auto result = super.gtk_focus_out_event (widget, event);
    // widget could be disposed at this point
    if (handle is null) return 0;
    if ((style & SWT.PUSH) !is 0 && !OS.GTK_WIDGET_HAS_DEFAULT (handle)) {
        Decorations menuShell = menuShell ();
        if (menuShell.defaultButton is this) {
            menuShell.defaultButton = null;
        }
    }
    return result;
}

override int gtk_key_press_event (GtkWidget* widget, GdkEventKey* event) {
    auto result = super.gtk_key_press_event (widget, event);
    if (result !is 0) return result;
    if ((style & SWT.RADIO) !is 0) selected  = getSelection ();
    return result;
}

override void hookEvents () {
    super.hookEvents();
    OS.g_signal_connect_closure (handle, OS.clicked.ptr, display.closures [CLICKED], false);
    if (labelHandle !is null) {
        OS.g_signal_connect_closure_by_id (cast(void*)labelHandle, display.signalIds [MNEMONIC_ACTIVATE], 0, display.closures [MNEMONIC_ACTIVATE], false);
    }
}

override bool isDescribedByLabel () {
    return false;
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

override void register () {
    super.register ();
    if (boxHandle !is null) display.addWidget (boxHandle, this);
    if (labelHandle !is null) display.addWidget (labelHandle, this);
    if (imageHandle !is null) display.addWidget (imageHandle, this);
    if (arrowHandle !is null) display.addWidget (arrowHandle, this);
}

override void releaseHandle () {
    super.releaseHandle ();
    boxHandle = imageHandle = labelHandle = arrowHandle = null;
}

override void releaseWidget () {
    super.releaseWidget ();
    if (groupHandle !is null) OS.g_object_unref (groupHandle);
    groupHandle = null;
    if (imageList !is null) imageList.dispose ();
    imageList = null;
    image = null;
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
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Selection, listener);
    eventTable.unhook (SWT.DefaultSelection,listener);
}

override void resizeHandle (int width, int height) {
    super.resizeHandle (width, height);
    /*
    * Feature in GTK, GtkCheckButton and GtkRadioButton allocate
    * only the minimum size necessary for its child. This causes the child
    * alignment to fail. The fix is to set the child size to the size
    * of the button.
    */
    if ((style & (SWT.CHECK | SWT.RADIO)) !is 0) {
        OS.gtk_widget_set_size_request (boxHandle, width, -1);
    }
}

void selectRadio () {
    /*
    * This code is intentionally commented.  When two groups
    * of radio buttons with the same parent are separated by
    * another control, the correct behavior should be that
    * the two groups act independently.  This is consistent
    * with radio tool and menu items.  The commented code
    * implements this behavior.
    */
//  int index = 0;
//  Control [] children = parent._getChildren ();
//  while (index < children.length && children [index] !is this) index++;
//  int i = index - 1;
//  while (i >= 0 && children [i].setRadioSelection (false)) --i;
//  int j = index + 1;
//  while (j < children.length && children [j].setRadioSelection (false)) j++;
//  setSelection (true);
    Control [] children = parent._getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        if (this !is child) child.setRadioSelection (false);
    }
    setSelection (true);
}

/**
 * Controls how text, images and arrows will be displayed
 * in the receiver. The argument should be one of
 * <code>LEFT</code>, <code>RIGHT</code> or <code>CENTER</code>
 * unless the receiver is an <code>ARROW</code> button, in
 * which case, the argument indicates the direction of
 * the arrow (one of <code>LEFT</code>, <code>RIGHT</code>,
 * <code>UP</code> or <code>DOWN</code>).
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
    _setAlignment (alignment);
}

void _setAlignment (int alignment) {
    if ((style & SWT.ARROW) !is 0) {
        if ((style & (SWT.UP | SWT.DOWN | SWT.LEFT | SWT.RIGHT)) is 0) return;
        style &= ~(SWT.UP | SWT.DOWN | SWT.LEFT | SWT.RIGHT);
        style |= alignment & (SWT.UP | SWT.DOWN | SWT.LEFT | SWT.RIGHT);
        int arrow_type = OS.GTK_ARROW_UP;
        bool isRTL = (style & SWT.RIGHT_TO_LEFT) !is 0;
        switch (alignment) {
            case SWT.UP: arrow_type = OS.GTK_ARROW_UP; break;
            case SWT.DOWN: arrow_type = OS.GTK_ARROW_DOWN; break;
            case SWT.LEFT: arrow_type = isRTL ? OS.GTK_ARROW_RIGHT : OS.GTK_ARROW_LEFT; break;
            case SWT.RIGHT: arrow_type = isRTL ? OS.GTK_ARROW_LEFT : OS.GTK_ARROW_RIGHT; break;
            default:
        }
        OS.gtk_arrow_set (cast(GtkArrow*)arrowHandle, arrow_type, OS.GTK_SHADOW_OUT);
        return;
    }
    if ((alignment & (SWT.LEFT | SWT.RIGHT | SWT.CENTER)) is 0) return;
    style &= ~(SWT.LEFT | SWT.RIGHT | SWT.CENTER);
    style |= alignment & (SWT.LEFT | SWT.RIGHT | SWT.CENTER);
    /* Alignment not honoured when image and text are visible */
    bool bothVisible = OS.GTK_WIDGET_VISIBLE (labelHandle) && OS.GTK_WIDGET_VISIBLE (imageHandle);
    if (bothVisible) {
        if ((style & (SWT.RADIO | SWT.CHECK)) !is 0) alignment = SWT.LEFT;
        if ((style & (SWT.PUSH | SWT.TOGGLE)) !is 0) alignment = SWT.CENTER;
    }
    if ((alignment & SWT.LEFT) !is 0) {
        if (bothVisible) {
            OS.gtk_box_set_child_packing (cast(GtkBox*)boxHandle, labelHandle, false, false, 0, OS.GTK_PACK_START);
            OS.gtk_box_set_child_packing (cast(GtkBox*)boxHandle, imageHandle, false, false, 0, OS.GTK_PACK_START);
        }
        OS.gtk_misc_set_alignment (cast(GtkMisc*)labelHandle, 0.0f, 0.5f);
        OS.gtk_label_set_justify (cast(GtkLabel*)labelHandle, OS.GTK_JUSTIFY_LEFT);
        OS.gtk_misc_set_alignment (cast(GtkMisc*)imageHandle, 0.0f, 0.5f);
        return;
    }
    if ((alignment & SWT.CENTER) !is 0) {
        if (bothVisible) {
            OS.gtk_box_set_child_packing (cast(GtkBox*)boxHandle, labelHandle, true, true, 0, OS.GTK_PACK_END);
            OS.gtk_box_set_child_packing (cast(GtkBox*)boxHandle, imageHandle, true, true, 0, OS.GTK_PACK_START);
            OS.gtk_misc_set_alignment (cast(GtkMisc*)labelHandle, 0f, 0.5f);
            OS.gtk_misc_set_alignment (cast(GtkMisc*)imageHandle, 1f, 0.5f);
        } else {
            OS.gtk_misc_set_alignment (cast(GtkMisc*)labelHandle, 0.5f, 0.5f);
            OS.gtk_label_set_justify (cast(GtkLabel*)labelHandle, OS.GTK_JUSTIFY_CENTER);
            OS.gtk_misc_set_alignment (cast(GtkMisc*)imageHandle, 0.5f, 0.5f);
        }
        return;
    }
    if ((alignment & SWT.RIGHT) !is 0) {
        if (bothVisible) {
            OS.gtk_box_set_child_packing (cast(GtkBox*)boxHandle, labelHandle, false, false, 0, OS.GTK_PACK_END);
            OS.gtk_box_set_child_packing (cast(GtkBox*)boxHandle, imageHandle, false, false, 0, OS.GTK_PACK_END);
        }
        OS.gtk_misc_set_alignment (cast(GtkMisc*)labelHandle, 1.0f, 0.5f);
        OS.gtk_label_set_justify (cast(GtkLabel*)labelHandle, OS.GTK_JUSTIFY_RIGHT);
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

override void setFontDescription (PangoFontDescription* font) {
    super.setFontDescription (font);
    if (labelHandle !is null) OS.gtk_widget_modify_font (labelHandle, font);
    if (imageHandle !is null) OS.gtk_widget_modify_font (imageHandle, font);
}

override bool setRadioSelection (bool value) {
    if ((style & SWT.RADIO) is 0) return false;
    if (getSelection () !is value) {
        setSelection (value);
        postEvent (SWT.Selection);
    }
    return true;
}

override void setForegroundColor (GdkColor* color) {
    super.setForegroundColor (color);
    setForegroundColor (fixedHandle, color);
    if (labelHandle !is null) setForegroundColor (labelHandle, color);
    if (imageHandle !is null) setForegroundColor (imageHandle, color);
}

/**
 * Sets the grayed state of the receiver.  This state change 
 * only applies if the control was created with the SWT.CHECK
 * style.
 *
 * @param grayed the new grayed state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 * 
 * @since 3.4
 */
public void setGrayed (bool grayed) {
    checkWidget();
    if ((style & SWT.CHECK) is 0) return;
    this.grayed = grayed;
    if (grayed && OS.gtk_toggle_button_get_active (handle)) {
        OS.gtk_toggle_button_set_inconsistent (handle, true);
    } else {
        OS.gtk_toggle_button_set_inconsistent (handle, false);
    }
}

/**
 * Sets the receiver's image to the argument, which may be
 * <code>null</code> indicating that no image should be displayed.
 * <p>
 * Note that a Button can display an image and text simultaneously
 * on Windows (starting with XP), GTK+ and OSX.  On other platforms,
 * a Button that has an image and text set into it will display the
 * image or text that was set most recently.
 * </p>
 * @param image the image to display on the receiver (may be <code>null</code>)
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
    if ((style & SWT.ARROW) !is 0) return;
    if (imageList !is null) imageList.dispose ();
    imageList = null;
    if (image !is null) {
        if (image.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);
        imageList = new ImageList ();
        int imageIndex = imageList.add (image);
        auto pixbuf = imageList.getPixbuf (imageIndex);
        OS.gtk_image_set_from_pixbuf (cast(GtkImage*)imageHandle, pixbuf);
        if (text.length is 0) OS.gtk_widget_hide (labelHandle);
        OS.gtk_widget_show (imageHandle);
    } else {
        OS.gtk_image_set_from_pixbuf (cast(GtkImage*)imageHandle, null);
        OS.gtk_widget_show (labelHandle);
        OS.gtk_widget_hide (imageHandle);
    }
    this.image = image;
    _setAlignment (style);
}

override void setOrientation () {
    super.setOrientation ();
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        if (boxHandle !is null) OS.gtk_widget_set_direction (boxHandle, OS.GTK_TEXT_DIR_RTL);
        if (labelHandle !is null) OS.gtk_widget_set_direction (labelHandle, OS.GTK_TEXT_DIR_RTL);
        if (imageHandle !is null) OS.gtk_widget_set_direction (imageHandle, OS.GTK_TEXT_DIR_RTL);
        if (arrowHandle !is null) {
            switch (style & (SWT.LEFT | SWT.RIGHT)) {
                case SWT.LEFT: OS.gtk_arrow_set (cast(GtkArrow*)arrowHandle, OS.GTK_ARROW_RIGHT, OS.GTK_SHADOW_OUT); break;
                case SWT.RIGHT: OS.gtk_arrow_set (cast(GtkArrow*)arrowHandle, OS.GTK_ARROW_LEFT, OS.GTK_SHADOW_OUT); break;
                default:
            }
        }
    }
}

/**
 * Sets the selection state of the receiver, if it is of type <code>CHECK</code>,
 * <code>RADIO</code>, or <code>TOGGLE</code>.
 *
 * <p>
 * When the receiver is of type <code>CHECK</code> or <code>RADIO</code>,
 * it is selected when it is checked. When it is of type <code>TOGGLE</code>,
 * it is selected when it is pushed in.
 *
 * @param selected the new selection state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (bool selected) {
    checkWidget();
    if ((style & (SWT.CHECK | SWT.RADIO | SWT.TOGGLE)) is 0) return;
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCLICKED);
    OS.gtk_toggle_button_set_active (cast(GtkToggleButton*)handle, selected);
    if ((style & SWT.CHECK) !is 0) {
        if (selected && grayed) {
            OS.gtk_toggle_button_set_inconsistent (handle, true);
        } else {
            OS.gtk_toggle_button_set_inconsistent (handle, false);
        }
    }
    if ((style & SWT.RADIO) !is 0) OS.gtk_toggle_button_set_active (cast(GtkToggleButton*)groupHandle, !selected);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCLICKED);
}

/**
 * Sets the receiver's text.
 * <p>
 * This method sets the button label.  The label may include
 * the mnemonic character but must not contain line delimiters.
 * </p>
 * <p>
 * Mnemonics are indicated by an '&amp;' that causes the next
 * character to be the mnemonic.  When the user presses a
 * key sequence that matches the mnemonic, a selection
 * event occurs. On most platforms, the mnemonic appears
 * underlined but may be emphasized in a platform specific
 * manner.  The mnemonic indicator character '&amp;' can be
 * escaped by doubling it in the string, causing a single
 * '&amp;' to be displayed.
 * </p><p>
 * Note that a Button can display an image and text simultaneously
 * on Windows (starting with XP), GTK+ and OSX.  On other platforms,
 * a Button that has an image and text set into it will display the
 * image or text that was set most recently.
 * </p>
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
    if ((style & SWT.ARROW) !is 0) return;
    text = string;
    char [] chars = fixMnemonic (string);
    OS.gtk_label_set_text_with_mnemonic (cast(GtkLabel*)labelHandle, chars.toStringzValidPtr() );
    if (image is null) OS.gtk_widget_hide (imageHandle);
    OS.gtk_widget_show (labelHandle);
    _setAlignment (style);
}

override void showWidget () {
    super.showWidget ();
    if (boxHandle !is null) OS.gtk_widget_show (boxHandle);
    if (labelHandle !is null) OS.gtk_widget_show (labelHandle);
    if (arrowHandle !is null) OS.gtk_widget_show (arrowHandle);
}

override int traversalCode (int key, GdkEventKey* event) {
    int code = super.traversalCode (key, event);
    if ((style & SWT.ARROW) !is 0) code &= ~(SWT.TRAVERSE_TAB_NEXT | SWT.TRAVERSE_TAB_PREVIOUS);
    if ((style & SWT.RADIO) !is 0) code |= SWT.TRAVERSE_ARROW_NEXT | SWT.TRAVERSE_ARROW_PREVIOUS;
    return code;
}

}
