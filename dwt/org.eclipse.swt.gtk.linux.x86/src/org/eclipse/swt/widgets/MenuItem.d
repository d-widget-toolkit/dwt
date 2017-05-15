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
module org.eclipse.swt.widgets.MenuItem;


import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.Decorations;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.ImageList;
import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.events.ArmListener;
import org.eclipse.swt.events.HelpListener;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Display;

import java.lang.all;

/**
 * Instances of this class represent a selectable user interface object
 * that issues notification when pressed and released.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>CHECK, CASCADE, PUSH, RADIO, SEPARATOR</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Arm, Help, Selection</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles CHECK, CASCADE, PUSH, RADIO and SEPARATOR
 * may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class MenuItem : Item {
    Menu parent, menu;
    GtkAccelGroup* groupHandle;
    int accelerator;

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Menu</code>) and a style value
 * describing its behavior and appearance. The item is added
 * to the end of the items maintained by its parent.
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
 * @param parent a menu control which will be the parent of the new instance (cannot be null)
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
 * @see SWT#CHECK
 * @see SWT#CASCADE
 * @see SWT#PUSH
 * @see SWT#RADIO
 * @see SWT#SEPARATOR
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Menu parent, int style) {
    super (parent, checkStyle (style));
    this.parent = parent;
    createWidget (parent.getItemCount ());
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Menu</code>), a style value
 * describing its behavior and appearance, and the index
 * at which to place it in the items maintained by its parent.
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
 * @param parent a menu control which will be the parent of the new instance (cannot be null)
 * @param style the style of control to construct
 * @param index the zero-relative index to store the receiver in its parent
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the parent (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#CHECK
 * @see SWT#CASCADE
 * @see SWT#PUSH
 * @see SWT#RADIO
 * @see SWT#SEPARATOR
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Menu parent, int style, int index) {
    super (parent, checkStyle (style));
    this.parent = parent;
    int count = parent.getItemCount ();
    if (!(0 <= index && index <= count)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    createWidget (index);
}

void addAccelerator (GtkAccelGroup* accelGroup) {
    updateAccelerator (accelGroup, true);
}

void addAccelerators (GtkAccelGroup* accelGroup) {
    addAccelerator (accelGroup);
    if (menu !is null) menu.addAccelerators (accelGroup);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the arm events are generated for the control, by sending
 * it one of the messages defined in the <code>ArmListener</code>
 * interface.
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
 * @see ArmListener
 * @see #removeArmListener
 */
public void addArmListener (ArmListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Arm, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the help events are generated for the control, by sending
 * it one of the messages defined in the <code>HelpListener</code>
 * interface.
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
 * @see HelpListener
 * @see #removeHelpListener
 */
public void addHelpListener (HelpListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Help, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the menu item is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * When <code>widgetSelected</code> is called, the stateMask field of the event object is valid.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
 *
 * @param listener the listener which should be notified when the menu item is selected by the user
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
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener(listener);
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
}

static int checkStyle (int style) {
    return checkBits (style, SWT.PUSH, SWT.CHECK, SWT.RADIO, SWT.SEPARATOR, SWT.CASCADE, 0);
}

protected override void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

override void createHandle (int index) {
    state |= HANDLE;
    String buffer = "\0";
    int bits = SWT.CHECK | SWT.RADIO | SWT.PUSH | SWT.SEPARATOR;
    switch (style & bits) {
        case SWT.SEPARATOR:
            handle = OS.gtk_separator_menu_item_new ();
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
            groupHandle = cast(GtkAccelGroup*) OS.gtk_radio_menu_item_new (null);
            if (groupHandle is null) error (SWT.ERROR_NO_HANDLES);
            OS.g_object_ref (groupHandle);
            OS.gtk_object_sink (cast(GtkObject*)groupHandle);
            auto group = OS.gtk_radio_menu_item_get_group (cast(GtkRadioMenuItem*) groupHandle);
            handle = OS.gtk_radio_menu_item_new_with_label (group, buffer.ptr);
            break;
        case SWT.CHECK:
            handle = OS.gtk_check_menu_item_new_with_label (buffer.ptr);
            break;
        case SWT.PUSH:
        default:
            handle = OS.gtk_image_menu_item_new_with_label (buffer.ptr);
            break;
    }
    if (handle is null) error (SWT.ERROR_NO_HANDLES);
    if ((style & SWT.SEPARATOR) is 0) {
        auto label = OS.gtk_bin_get_child (cast(GtkBin*)handle);
        OS.gtk_accel_label_set_accel_widget (cast(GtkAccelLabel*)label, null);
    }
    auto parentHandle = parent.handle;
    bool enabled = OS.GTK_WIDGET_SENSITIVE (parentHandle);
    if (!enabled) OS.GTK_WIDGET_SET_FLAGS (parentHandle, OS.GTK_SENSITIVE);
    OS.gtk_menu_shell_insert (cast(GtkMenuShell*)parentHandle, handle, index);
    if (!enabled) OS.GTK_WIDGET_UNSET_FLAGS (parentHandle, OS.GTK_SENSITIVE);
    OS.gtk_widget_show (handle);
}

void fixMenus (Decorations newParent) {
    if (menu !is null) menu.fixMenus (newParent);
}

/**
 * Returns the widget accelerator.  An accelerator is the bit-wise
 * OR of zero or more modifier masks and a key. Examples:
 * <code>SWT.CONTROL | SWT.SHIFT | 'T', SWT.ALT | SWT.F2</code>.
 * The default value is zero, indicating that the menu item does
 * not have an accelerator.
 *
 * @return the accelerator or 0
 *
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getAccelerator () {
    checkWidget();
    return accelerator;
}

GtkAccelGroup* getAccelGroup () {
    Menu menu = parent;
    while (menu !is null && menu.cascade !is null) {
        menu = menu.cascade.parent;
    }
    if (menu is null) return null;
    Decorations shell = menu.parent;
    return shell.menuBar is menu ? shell.accelGroup : null;
}

/*public*/ Rectangle getBounds () {
    checkWidget();
    if (!OS.GTK_WIDGET_MAPPED (handle)) {
        return new Rectangle (0, 0, 0, 0);
    }
    int x = OS.GTK_WIDGET_X (handle);
    int y = OS.GTK_WIDGET_Y (handle);
    int width = OS.GTK_WIDGET_WIDTH (handle);
    int height = OS.GTK_WIDGET_HEIGHT (handle);
    return new Rectangle (x, y, width, height);
}

/**
 * Returns <code>true</code> if the receiver is enabled, and
 * <code>false</code> otherwise. A disabled menu item is typically
 * not selectable from the user interface and draws with an
 * inactive or "grayed" look.
 *
 * @return the receiver's enabled state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #isEnabled
 */
public bool getEnabled () {
    checkWidget();
    return OS.GTK_WIDGET_SENSITIVE (handle);
}

/**
 * Returns the receiver's cascade menu if it has one or null
 * if it does not. Only <code>CASCADE</code> menu items can have
 * a pull down menu. The sequence of key strokes, button presses
 * and/or button releases that are used to request a pull down
 * menu is platform specific.
 *
 * @return the receiver's menu
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Menu getMenu () {
    checkWidget();
    return menu;
}

override
String getNameText () {
    if ((style & SWT.SEPARATOR) !is 0) return "|";
    return super.getNameText ();
}

/**
 * Returns the receiver's parent, which must be a <code>Menu</code>.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Menu getParent () {
    checkWidget();
    return parent;
}

/**
 * Returns <code>true</code> if the receiver is selected,
 * and false otherwise.
 * <p>
 * When the receiver is of type <code>CHECK</code> or <code>RADIO</code>,
 * it is selected when it is checked.
 *
 * @return the selection state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getSelection () {
    checkWidget();
    if ((style & (SWT.CHECK | SWT.RADIO)) is 0) return false;
    return cast(bool)OS.gtk_check_menu_item_get_active(cast(GtkCheckMenuItem*)handle);
}

override int gtk_activate (GtkWidget* widget) {
    if ((style & SWT.CASCADE) !is 0 && menu !is null) return 0;
    /*
    * Bug in GTK.  When an ancestor menu is disabled and
    * the user types an accelerator key, GTK delivers the
    * the activate signal even though the menu item cannot
    * be invoked using the mouse.  The fix is to ignore
    * activate signals when an ancestor menu is disabled.
    */
    if (!isEnabled ()) return 0;
    Event event = new Event ();
    auto ptr = OS.gtk_get_current_event ();
    if (ptr !is null) {
        GdkEvent* gdkEvent = ptr;
        switch (gdkEvent.type) {
            case OS.GDK_KEY_PRESS:
            case OS.GDK_KEY_RELEASE:
            case OS.GDK_BUTTON_PRESS:
            case OS.GDK_2BUTTON_PRESS:
            case OS.GDK_BUTTON_RELEASE: {
                int state;
                OS.gdk_event_get_state (ptr, &state);
                setInputState (event, state);
                break;
            }
            default:
        }
        OS.gdk_event_free (ptr);
    }
    if ((style & SWT.RADIO) !is 0) {
        if ((parent.getStyle () & SWT.NO_RADIO_GROUP) is 0) {
            selectRadio ();
        }
    }
    postEvent (SWT.Selection, event);
    return 0;
}

override int gtk_select (int item) {
    parent.selectedItem = this;
    sendEvent (SWT.Arm);
    return 0;
}

override int gtk_show_help (GtkWidget* widget, ptrdiff_t helpType) {
    bool handled = hooks (SWT.Help);
    if (handled) {
        postEvent (SWT.Help);
    } else {
        handled = parent.sendHelpEvent (helpType);
    }
    if (handled) {
        OS.gtk_menu_shell_deactivate (cast(GtkMenuShell*)parent.handle);
        return 1;
    }
    return 0;
}

override void hookEvents () {
    super.hookEvents ();
    OS.g_signal_connect_closure (handle, OS.activate.ptr, display.closures [ACTIVATE], false);
    OS.g_signal_connect_closure (handle, OS.select.ptr, display.closures [SELECT], false);
    OS.g_signal_connect_closure_by_id (handle, display.signalIds [SHOW_HELP], 0, display.closures [SHOW_HELP], false);
}

/**
 * Returns <code>true</code> if the receiver is enabled and all
 * of the receiver's ancestors are enabled, and <code>false</code>
 * otherwise. A disabled menu item is typically not selectable from the
 * user interface and draws with an inactive or "grayed" look.
 *
 * @return the receiver's enabled state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getEnabled
 */
public bool isEnabled () {
    return getEnabled () && parent.isEnabled ();
}

override void releaseChildren (bool destroy) {
    if (menu !is null) {
        menu.release (false);
        menu = null;
    }
    super.releaseChildren (destroy);
}

override void releaseParent () {
    super.releaseParent ();
    if (menu !is null) {
        if (menu.selectedItem is this) menu.selectedItem = null;
        menu.dispose ();
    }
    menu = null;
}

override void releaseWidget () {
    super.releaseWidget ();
    auto accelGroup = getAccelGroup ();
    if (accelGroup !is null) removeAccelerator (accelGroup);
    if (groupHandle !is null) OS.g_object_unref (groupHandle);
    groupHandle = null;
    accelerator = 0;
    parent = null;
}

void removeAccelerator (GtkAccelGroup* accelGroup) {
    updateAccelerator (accelGroup, false);
}

void removeAccelerators (GtkAccelGroup* accelGroup) {
    removeAccelerator (accelGroup);
    if (menu !is null) menu.removeAccelerators (accelGroup);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the arm events are generated for the control.
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
 * @see ArmListener
 * @see #addArmListener
 */
public void removeArmListener (ArmListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Arm, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the help events are generated for the control.
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
 * @see HelpListener
 * @see #addHelpListener
 */
public void removeHelpListener (HelpListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Help, listener);
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
void selectRadio () {
    int index = 0;
    MenuItem [] items = parent.getItems ();
    while (index < items.length && items [index] !is this) index++;
    int i = index - 1;
    while (i >= 0 && items [i].setRadioSelection (false)) --i;
    int j = index + 1;
    while (j < items.length && items [j].setRadioSelection (false)) j++;
    setSelection (true);
}
/**
 * Sets the widget accelerator.  An accelerator is the bit-wise
 * OR of zero or more modifier masks and a key. Examples:
 * <code>SWT.MOD1 | SWT.MOD2 | 'T', SWT.MOD3 | SWT.F2</code>.
 * <code>SWT.CONTROL | SWT.SHIFT | 'T', SWT.ALT | SWT.F2</code>.
 * The default value is zero, indicating that the menu item does
 * not have an accelerator.
 *
 * @param accelerator an integer that is the bit-wise OR of masks and a key
 *
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setAccelerator (int accelerator) {
    checkWidget();
    if (this.accelerator is accelerator) return;
    auto accelGroup = getAccelGroup ();
    if (accelGroup !is null) removeAccelerator (accelGroup);
    this.accelerator = accelerator;
    if (accelGroup !is null) addAccelerator (accelGroup);
}

/**
 * Enables the receiver if the argument is <code>true</code>,
 * and disables it otherwise. A disabled menu item is typically
 * not selectable from the user interface and draws with an
 * inactive or "grayed" look.
 *
 * @param enabled the new enabled state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setEnabled (bool enabled) {
    checkWidget();
    if (OS.GTK_WIDGET_SENSITIVE (handle) is enabled) return;
    auto accelGroup = getAccelGroup ();
    if (accelGroup !is null) removeAccelerator (accelGroup);
    OS.gtk_widget_set_sensitive (handle, enabled);
    if (accelGroup !is null) addAccelerator (accelGroup);
}

/**
 * Sets the image the receiver will display to the argument.
 * <p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept (for example, Windows NT).
 * </p>
 *
 * @param image the image to display
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public override void setImage (Image image) {
    checkWidget();
    if ((style & SWT.SEPARATOR) !is 0) return;
    super.setImage (image);
    if (!OS.GTK_IS_IMAGE_MENU_ITEM (cast(GTypeInstance*)handle)) return;
    if (image !is null) {
        ImageList imageList = parent.imageList;
        if (imageList is null) imageList = parent.imageList = new ImageList ();
        int imageIndex = imageList.indexOf (image);
        if (imageIndex is -1) {
            imageIndex = imageList.add (image);
        } else {
            imageList.put (imageIndex, image);
        }
        auto pixbuf = imageList.getPixbuf (imageIndex);
        auto imageHandle = OS.gtk_image_new_from_pixbuf (pixbuf);
        OS.gtk_image_menu_item_set_image (cast(GtkImageMenuItem*)handle, imageHandle);
        OS.gtk_widget_show (imageHandle);
    } else {
        OS.gtk_image_menu_item_set_image (cast(GtkImageMenuItem*)handle, null);
    }
}

/**
 * Sets the receiver's pull down menu to the argument.
 * Only <code>CASCADE</code> menu items can have a
 * pull down menu. The sequence of key strokes, button presses
 * and/or button releases that are used to request a pull down
 * menu is platform specific.
 * <p>
 * Note: Disposing of a menu item that has a pull down menu
 * will dispose of the menu.  To avoid this behavior, set the
 * menu to null before the menu item is disposed.
 * </p>
 *
 * @param menu the new pull down menu
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_MENU_NOT_DROP_DOWN - if the menu is not a drop down menu</li>
 *    <li>ERROR_MENUITEM_NOT_CASCADE - if the menu item is not a <code>CASCADE</code></li>
 *    <li>ERROR_INVALID_ARGUMENT - if the menu has been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if the menu is not in the same widget tree</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMenu (Menu menu) {
    checkWidget ();

    /* Check to make sure the new menu is valid */
    if ((style & SWT.CASCADE) is 0) {
        error (SWT.ERROR_MENUITEM_NOT_CASCADE);
    }
    if (menu !is null) {
        if ((menu.style & SWT.DROP_DOWN) is 0) {
            error (SWT.ERROR_MENU_NOT_DROP_DOWN);
        }
        if (menu.parent !is parent.parent) {
            error (SWT.ERROR_INVALID_PARENT);
        }
    }

    /* Assign the new menu */
    Menu oldMenu = this.menu;
    if (oldMenu is menu) return;
    auto accelGroup = getAccelGroup ();
    if (accelGroup !is null) removeAccelerators (accelGroup);
    if (oldMenu !is null) {
        oldMenu.cascade = null;
        /*
        * Add a reference to the menu we are about
        * to replace or GTK will destroy it.
        */
        OS.g_object_ref (oldMenu.handle);
        OS.gtk_menu_item_remove_submenu (cast(GtkMenuItem*)handle);
    }
    if ((this.menu = menu) !is null) {
        menu.cascade = this;
        OS.gtk_menu_item_set_submenu (cast(GtkMenuItem*)handle, menu.handle);
    }
    if (accelGroup !is null) addAccelerators (accelGroup);
}

override void setOrientation() {
    if ((parent.style & SWT.RIGHT_TO_LEFT) !is 0) {
        if (handle !is null) {
            OS.gtk_widget_set_direction (handle, OS.GTK_TEXT_DIR_RTL);
            OS.gtk_container_forall (cast(GtkContainer*)handle, cast(GtkCallback)&Display.setDirectionProcFunc, cast(void*)OS.GTK_TEXT_DIR_RTL);
        }
    }
}

bool setRadioSelection (bool value) {
    if ((style & SWT.RADIO) is 0) return false;
    if (getSelection () !is value) {
        setSelection (value);
        postEvent (SWT.Selection);
    }
    return true;
}

/**
 * Sets the selection state of the receiver.
 * <p>
 * When the receiver is of type <code>CHECK</code> or <code>RADIO</code>,
 * it is selected when it is checked.
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
    if ((style & (SWT.CHECK | SWT.RADIO)) is 0) return;
    OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udACTIVATE);
    OS.gtk_check_menu_item_set_active (cast(GtkCheckMenuItem*)handle, selected);
    if ((style & SWT.RADIO) !is 0) OS.gtk_check_menu_item_set_active (cast(GtkCheckMenuItem*)groupHandle, !selected);
    OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udACTIVATE);
}

/**
 * Sets the receiver's text. The string may include
 * the mnemonic character and accelerator text.
 * <p>
 * Mnemonics are indicated by an '&amp;' that causes the next
 * character to be the mnemonic.  When the user presses a
 * key sequence that matches the mnemonic, a selection
 * event occurs. On most platforms, the mnemonic appears
 * underlined but may be emphasised in a platform specific
 * manner.  The mnemonic indicator character '&amp;' can be
 * escaped by doubling it in the string, causing a single
 * '&amp;' to be displayed.
 * </p>
 * <p>
 * Accelerator text is indicated by the '\t' character.
 * On platforms that support accelerator text, the text
 * that follows the '\t' character is displayed to the user,
 * typically indicating the key stroke that will cause
 * the item to become selected.  On most platforms, the
 * accelerator text appears right aligned in the menu.
 * Setting the accelerator text does not install the
 * accelerator key sequence. The accelerator key sequence
 * is installed using #setAccelerator.
 * </p>
 *
 * @param string the new text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setAccelerator
 */
public override void setText (String string) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if ((style & SWT.SEPARATOR) !is 0) return;
    if (text.equals(string)) return;
    super.setText (string);
    String accelString = "";
    int index = string.indexOf ('\t');
    if (index !is -1) {
        bool isRTL = (parent.style & SWT.RIGHT_TO_LEFT) !is 0;
        accelString = (isRTL? "" : "  ") ~ string.substring (index+1, cast(int)/*64bit*/string.length) ~ (isRTL? "  " : "");
        string = string.substring (0, index);
    }
    char [] chars = fixMnemonic (string);
    auto label = OS.gtk_bin_get_child (cast(GtkBin*)handle);
    OS.gtk_label_set_text_with_mnemonic (cast(GtkLabel*)label, chars.toStringzValidPtr() );

    auto ptr = cast(char*)OS.g_malloc (accelString.length + 1);
    ptr[ 0 .. accelString.length ] = accelString;
    ptr[ accelString.length ] = '\0';

    auto oldPtr = OS.GTK_ACCEL_LABEL_GET_ACCEL_STRING (cast(GtkAccelLabel*)label);
    OS.GTK_ACCEL_LABEL_SET_ACCEL_STRING (cast(GtkAccelLabel*)label, ptr);
    if (oldPtr !is null) OS.g_free (oldPtr);
}

void updateAccelerator (GtkAccelGroup* accelGroup, bool add) {
    if (accelerator is 0 || !getEnabled ()) return;
    if ((accelerator & SWT.COMMAND) !is 0) return;
    int mask = 0;
    if ((accelerator & SWT.ALT) !is 0) mask |= OS.GDK_MOD1_MASK;
    if ((accelerator & SWT.SHIFT) !is 0) mask |= OS.GDK_SHIFT_MASK;
    if ((accelerator & SWT.CONTROL) !is 0) mask |= OS.GDK_CONTROL_MASK;
    int keysym = accelerator & SWT.KEY_MASK;
    int newKey = Display.untranslateKey (keysym);
    if (newKey !is 0) {
        keysym = newKey;
    } else {
        switch (keysym) {
            case '\r': keysym = OS.GDK_Return; break;
            default: keysym = Display.wcsToMbcs (cast(char) keysym);
        }
    }
    /* When accel_key is zero, it causes GTK warnings */
    if (keysym !is 0) {
        if (add) {
            OS.gtk_widget_add_accelerator (handle, OS.activate.ptr, accelGroup, keysym, mask, OS.GTK_ACCEL_VISIBLE);
        } else {
            OS.gtk_widget_remove_accelerator (handle, accelGroup, keysym, mask);
        }
    }
}
}
