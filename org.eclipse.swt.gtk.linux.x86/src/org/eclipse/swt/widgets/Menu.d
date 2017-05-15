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
module org.eclipse.swt.widgets.Menu;

import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.events.MenuListener;
import org.eclipse.swt.events.HelpListener;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.ImageList;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Decorations;
import org.eclipse.swt.widgets.Shell;
import java.lang.all;

/**
 * Instances of this class are user interface objects that contain
 * menu items.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>BAR, DROP_DOWN, POP_UP, NO_RADIO_GROUP</dd>
 * <dd>LEFT_TO_RIGHT, RIGHT_TO_LEFT</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Help, Hide, Show </dd>
 * </dl>
 * <p>
 * Note: Only one of BAR, DROP_DOWN and POP_UP may be specified.
 * Only one of LEFT_TO_RIGHT or RIGHT_TO_LEFT may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#menu">Menu snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Menu : Widget {
    int x, y;
    bool hasLocation;
    MenuItem cascade, selectedItem;
    Decorations parent;
    GtkWidget* imItem;
    GtkWidget* imSeparator;
    GtkIMContext* imHandle;
    ImageList imageList;

/**
 * Constructs a new instance of this class given its parent,
 * and sets the style for the instance so that the instance
 * will be a popup menu on the given parent's shell.
 * <p>
 * After constructing a menu, it can be set into its parent
 * using <code>parent.setMenu(menu)</code>.  In this case, the parent may
 * be any control in the same widget tree as the parent.
 * </p>
 *
 * @param parent a control which will be the parent of the new instance (cannot be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#POP_UP
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Control parent) {
    this (checkNull (parent).menuShell (), SWT.POP_UP);
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Decorations</code>) and a style value
 * describing its behavior and appearance.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>SWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>SWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 * </p><p>
 * After constructing a menu or menuBar, it can be set into its parent
 * using <code>parent.setMenu(menu)</code> or <code>parent.setMenuBar(menuBar)</code>.
 * </p>
 *
 * @param parent a decorations control which will be the parent of the new instance (cannot be null)
 * @param style the style of menu to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#BAR
 * @see SWT#DROP_DOWN
 * @see SWT#POP_UP
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Decorations parent, int style) {
    super (parent, checkStyle (style));
    this.parent = parent;
    createWidget (0);
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Menu</code>) and sets the style
 * for the instance so that the instance will be a drop-down
 * menu on the given parent's parent.
 * <p>
 * After constructing a drop-down menu, it can be set into its parentMenu
 * using <code>parentMenu.setMenu(menu)</code>.
 * </p>
 *
 * @param parentMenu a menu which will be the parent of the new instance (cannot be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#DROP_DOWN
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Menu parentMenu) {
    this (checkNull (parentMenu).parent, SWT.DROP_DOWN);
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>MenuItem</code>) and sets the style
 * for the instance so that the instance will be a drop-down
 * menu on the given parent's parent menu.
 * <p>
 * After constructing a drop-down menu, it can be set into its parentItem
 * using <code>parentItem.setMenu(menu)</code>.
 * </p>
 *
 * @param parentItem a menu item which will be the parent of the new instance (cannot be null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#DROP_DOWN
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (MenuItem parentItem) {
    this (checkNull (parentItem).parent);
}

static Control checkNull (Control control) {
    if (control is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    return control;
}

static Menu checkNull (Menu menu) {
    if (menu is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    return menu;
}

static MenuItem checkNull (MenuItem item) {
    if (item is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    return item;
}

static int checkStyle (int style) {
    return checkBits (style, SWT.POP_UP, SWT.BAR, SWT.DROP_DOWN, 0, 0, 0);
}

void _setVisible (bool visible) {
    if (visible is OS.GTK_WIDGET_MAPPED (handle)) return;
    if (visible) {
        sendEvent (SWT.Show);
        if (getItemCount () !is 0) {
            if ((OS.GTK_VERSION >=  OS.buildVERSION (2, 8, 0))) {
                /*
                * Feature in GTK. ON_TOP shells will send out
                * SWT.Deactivate whenever a context menu is shown.
                * The fix is to prevent the menu from taking focus
                * when it is being shown in an ON_TOP shell.
                */
                if ((parent._getShell ().style & SWT.ON_TOP) !is 0) {
                    OS.gtk_menu_shell_set_take_focus (cast(GtkMenuShell*)handle, false);
                }
            }
            /*
            * Bug in GTK.  The timestamp passed into gtk_menu_popup is used
            * to perform an X pointer grab.  It cannot be zero, else the grab
            * will fail.  The fix is to ensure that the timestamp of the last
            * event processed is used.
            */
            getDisplay().doMenuPositionProc( cast(GtkMenu*)handle, hasLocation );
        } else {
            sendEvent (SWT.Hide);
        }
    } else {
        OS.gtk_menu_popdown (cast(GtkMenu*)handle);
    }
}

void addAccelerators (GtkAccelGroup* accelGroup) {
    MenuItem [] items = getItems ();
    for (int i = 0; i < items.length; i++) {
        MenuItem item = items[i];
        item.addAccelerators (accelGroup);
    }
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when menus are hidden or shown, by sending it
 * one of the messages defined in the <code>MenuListener</code>
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
 * @see MenuListener
 * @see #removeMenuListener
 */
public void addMenuListener (MenuListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Hide,typedListener);
    addListener (SWT.Show,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when help events are generated for the control,
 * by sending it one of the messages defined in the
 * <code>HelpListener</code> interface.
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

override void createHandle (int index) {
    state |= HANDLE;
    if ((style & SWT.BAR) !is 0) {
        handle = OS.gtk_menu_bar_new ();
        if (handle is null) error (SWT.ERROR_NO_HANDLES);
        auto vboxHandle = parent.vboxHandle;
        OS.gtk_container_add (cast(GtkContainer*)vboxHandle, handle);
        OS.gtk_box_set_child_packing (cast(GtkBox*)vboxHandle, handle, false, true, 0, OS.GTK_PACK_START);
    } else {
        handle = OS.gtk_menu_new ();
        if (handle is null) error (SWT.ERROR_NO_HANDLES);
    }
}

void createIMMenu (GtkIMContext* imHandle) {
    if (this.imHandle is imHandle) return;
    this.imHandle = imHandle;
    if (imHandle is null) {
        if (imItem !is null) {
            OS.gtk_widget_destroy (imItem);
            imItem = null;
        }
        if (imSeparator !is null) {
            OS.gtk_widget_destroy (imSeparator);
            imSeparator = null;
        }
        return;
    }
    if (imSeparator is null) {
        imSeparator = OS.gtk_separator_menu_item_new ();
        OS.gtk_widget_show (imSeparator);
        OS.gtk_menu_shell_insert (cast(GtkMenuShell*)handle, imSeparator, -1);
    }
    if (imItem is null) {
        char* buffer = toStringz( SWT.getMessage("SWT_InputMethods"));
        imItem = OS.gtk_image_menu_item_new_with_label (buffer);
        OS.gtk_widget_show (imItem);
        OS.gtk_menu_shell_insert (cast(GtkMenuShell*)handle, imItem, -1);
    }
    auto imSubmenu = OS.gtk_menu_new ();
    OS.gtk_im_multicontext_append_menuitems (cast(GtkIMMulticontext*)imHandle, cast(GtkMenuShell*)imSubmenu);
    OS.gtk_menu_item_set_submenu (cast(GtkMenuItem*)imItem, imSubmenu);
}

override void createWidget (int index) {
    checkOrientation (parent);
    super.createWidget (index);
    parent.addMenu (this);
}

void fixMenus (Decorations newParent) {
    MenuItem [] items = getItems ();
    for (int i=0; i<items.length; i++) {
        items [i].fixMenus (newParent);
    }
    parent.removeMenu (this);
    newParent.addMenu (this);
    this.parent = newParent;
}

/*public*/ Rectangle getBounds () {
    checkWidget();
    if (!OS.GTK_WIDGET_MAPPED (handle)) {
        return new Rectangle (0, 0, 0, 0);
    }
    auto window = OS.GTK_WIDGET_WINDOW (handle);
    int origin_x, origin_y;
    OS.gdk_window_get_origin (window, &origin_x, &origin_y);
    int x = origin_x + OS.GTK_WIDGET_X (handle);
    int y = origin_y + OS.GTK_WIDGET_Y (handle);
    int width = OS.GTK_WIDGET_WIDTH (handle);
    int height = OS.GTK_WIDGET_HEIGHT (handle);
    return new Rectangle (x, y, width, height);
}

/**
 * Returns the default menu item or null if none has
 * been previously set.
 *
 * @return the default menu item.
 *
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public MenuItem getDefaultItem () {
    checkWidget();
    return null;
}

/**
 * Returns <code>true</code> if the receiver is enabled, and
 * <code>false</code> otherwise. A disabled menu is typically
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
 * Returns the item at the given, zero-relative index in the
 * receiver. Throws an exception if the index is out of range.
 *
 * @param index the index of the item to return
 * @return the item at the given index
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public MenuItem getItem (int index) {
    checkWidget();
    auto list = OS.gtk_container_get_children (cast(GtkContainer*)handle);
    if (list is null) error (SWT.ERROR_CANNOT_GET_ITEM);
    int count = OS.g_list_length (list);
    if (imSeparator !is null) count--;
    if (imItem !is null) count--;
    if (!(0 <= index && index < count)) error (SWT.ERROR_INVALID_RANGE);
    auto data = cast(GtkWidget*)OS.g_list_nth_data (list, index);
    OS.g_list_free (list);
    if (data is null) error (SWT.ERROR_CANNOT_GET_ITEM);
    return cast(MenuItem) display.getWidget (data);
}

/**
 * Returns the number of items contained in the receiver.
 *
 * @return the number of items
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getItemCount () {
    checkWidget();
    auto list = OS.gtk_container_get_children (cast(GtkContainer*)handle);
    if (list is null) return 0;
    int count = OS.g_list_length (list);
    OS.g_list_free (list);
    if (imSeparator !is null) count--;
    if (imItem !is null) count--;
    return count;
}

/**
 * Returns a (possibly empty) array of <code>MenuItem</code>s which
 * are the items in the receiver.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the items in the receiver
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public MenuItem [] getItems () {
    checkWidget();
    auto list = OS.gtk_container_get_children (cast(GtkContainer*)handle);
    if (list is null) return new MenuItem [0];
    int count = OS.g_list_length (list);
    if (imSeparator !is null) count--;
    if (imItem !is null) count--;
    MenuItem [] items = new MenuItem [count];
    int index = 0;
    for (int i=0; i<count; i++) {
        auto data = cast(GtkWidget*)OS.g_list_nth_data (list, i);
        MenuItem item = cast(MenuItem) display.getWidget (data);
        if (item !is null) items [index++] = item;
    }
    OS.g_list_free (list);
    if (index !is items.length) {
        MenuItem [] newItems = new MenuItem[index];
        System.arraycopy(items, 0, newItems, 0, index);
        items = newItems;
    }
    return items;
}

override String getNameText () {
    String result = "";
    MenuItem [] items = getItems ();
    ptrdiff_t length_ = items.length;
    if (length_ > 0) {
        for (int i=0; i<length_-1; i++) {
            result = result ~ items [i].getNameText() ~ ", ";
        }
        result = result ~ items [length_-1].getNameText ();
    }
    return result;
}

/**
 * Returns the receiver's parent, which must be a <code>Decorations</code>.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Decorations getParent () {
    checkWidget();
    return parent;
}

/**
 * Returns the receiver's parent item, which must be a
 * <code>MenuItem</code> or null when the receiver is a
 * root.
 *
 * @return the receiver's parent item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public MenuItem getParentItem () {
    checkWidget();
    return cascade;
}

/**
 * Returns the receiver's parent item, which must be a
 * <code>Menu</code> or null when the receiver is a
 * root.
 *
 * @return the receiver's parent item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Menu getParentMenu () {
    checkWidget();
    if (cascade is null) return null;
    return cascade.getParent ();
}

/**
 * Returns the receiver's shell. For all controls other than
 * shells, this simply returns the control's nearest ancestor
 * shell. Shells return themselves, even if they are children
 * of other shells.
 *
 * @return the receiver's shell
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #getParent
 */
public Shell getShell () {
    checkWidget();
    return parent.getShell ();
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
    if ((style & SWT.POP_UP) !is 0) {
        Menu [] popups = display.popups;
        if (popups !is null) {
            for (int i=0; i<popups.length; i++) {
                if (popups [i] is this) return true;
            }
        }
    }
    return OS.GTK_WIDGET_MAPPED (handle);
}

override int gtk_hide (GtkWidget* widget) {
    if ((style & SWT.POP_UP) !is 0) {
        display.activeShell = getShell ();
    }
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 6, 0)) {
        sendEvent (SWT.Hide);
    } else {
        /*
        * Bug in GTK.  In GTK 2.4 and earlier
        * a crash could occur if a menu item
        * was disposed within gtk_hide.  The
        * workaroud is to post the event instead
        * of send it on these platforms
        */
        postEvent (SWT.Hide);
    }
    return 0;
}

override int gtk_show (GtkWidget* widget) {
    if ((style & SWT.POP_UP) !is 0) {
        display.activeShell = getShell ();
        return 0;
    }
    sendEvent (SWT.Show);
    return 0;
}


override int gtk_show_help (GtkWidget* widget, ptrdiff_t helpType) {
    if (sendHelpEvent (helpType)) {
        OS.gtk_menu_shell_deactivate (cast(GtkMenuShell*)handle);
        return 1;
    }
    return 0;
}

override void hookEvents () {
    super.hookEvents ();
    OS.g_signal_connect_closure_by_id (handle, display.signalIds [SHOW], 0, display.closures [SHOW], false);
    OS.g_signal_connect_closure_by_id (handle, display.signalIds [HIDE], 0, display.closures [HIDE], false);
    OS.g_signal_connect_closure_by_id (handle, display.signalIds [SHOW_HELP], 0, display.closures [SHOW_HELP], false);
}

/**
 * Searches the receiver's list starting at the first item
 * (index 0) until an item is found that is equal to the
 * argument, and returns the index of that item. If no item
 * is found, returns -1.
 *
 * @param item the search item
 * @return the index of the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the item is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (MenuItem item) {
    checkWidget();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    MenuItem [] items = getItems ();
    for (int i=0; i<items.length; i++) {
        if (items [i] is item) return i;
    }
    return -1;
}

/**
 * Returns <code>true</code> if the receiver is enabled and all
 * of the receiver's ancestors are enabled, and <code>false</code>
 * otherwise. A disabled menu is typically not selectable from the
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
    checkWidget();
    Menu parentMenu = getParentMenu ();
    if (parentMenu is null) {
        return getEnabled () && parent.isEnabled ();
    }
    return getEnabled () && parentMenu.isEnabled ();
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
    return getVisible ();
}

override void menuPositionProc (GtkMenu* menu, int* x, int* y, int* push_in, void* user_data) {
    /*
    * Feature in GTK.  The menu position function sets the position of the
    * top-left pixel of the menu.  If the menu would be off-screen, GTK will
    * add a scroll arrow at the bottom and position the first menu entry at
    * the specified position.  The fix is to flip the menu location to be
    * completely inside the screen.
    *
    * NOTE: This code doesn't work for multiple monitors.
    */
    GtkRequisition requisition;
    OS.gtk_widget_size_request (cast(GtkWidget*)menu, &requisition);
    int screenHeight = OS.gdk_screen_height ();
    int reqy = this.y;
    if (reqy + requisition.height > screenHeight) {
        reqy = Math.max (0, reqy - requisition.height);
    }
    int screenWidth = OS.gdk_screen_width ();
    int reqx = this.x;
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        if (reqx - requisition.width >= 0) reqx -= requisition.width;
    } else {
        if (reqx + requisition.width > screenWidth) reqx -= requisition.width;
    }
    if (x !is null) *x = reqx;
    if (y !is null) *y = reqy;
    if (push_in !is null) *push_in = 1;
}

override void releaseChildren (bool destroy) {
    MenuItem [] items = getItems ();
    for (int i=0; i<items.length; i++) {
        MenuItem item = items [i];
        if (item !is null && !item.isDisposed ()) {
            item.release (false);
        }
    }
    super.releaseChildren (destroy);
}

override void releaseParent () {
    super.releaseParent ();
    if (cascade !is null) cascade.setMenu (null);
    if ((style & SWT.BAR) !is 0 && this is parent.menuBar) {
        parent.setMenuBar (null);
    }  else {
        if ((style & SWT.POP_UP) !is 0) {
            display.removePopup (this);
        }
    }
}

override void releaseWidget () {
    super.releaseWidget ();
    if (parent !is null) parent.removeMenu (this);
    parent = null;
    cascade = null;
    imItem = null;
    imSeparator = null;
    imHandle = null;
    if (imageList !is null) imageList.dispose ();
    imageList = null;
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the menu events are generated for the control.
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
 * @see MenuListener
 * @see #addMenuListener
 */
public void removeMenuListener (MenuListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Hide, listener);
    eventTable.unhook (SWT.Show, listener);
}

void removeAccelerators (GtkAccelGroup* accelGroup) {
    MenuItem [] items = getItems ();
    for (int i = 0; i < items.length; i++) {
        MenuItem item = items[i];
        item.removeAccelerators (accelGroup);
    }
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

bool sendHelpEvent (ptrdiff_t helpType) {
    if (selectedItem !is null && !selectedItem.isDisposed()) {
        if (selectedItem.hooks (SWT.Help)) {
            selectedItem.postEvent (SWT.Help);
            return true;
        }
    }
    if (hooks (SWT.Help)) {
        postEvent (SWT.Help);
        return true;
    }
    return parent.sendHelpEvent (helpType);
}

/**
 * Sets the default menu item to the argument or removes
 * the default emphasis when the argument is <code>null</code>.
 *
 * @param item the default menu item or null
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the menu item has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setDefaultItem (MenuItem item) {
    checkWidget();
}

/**
 * Enables the receiver if the argument is <code>true</code>,
 * and disables it otherwise. A disabled menu is typically
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
    if (enabled) {
        OS.GTK_WIDGET_SET_FLAGS (handle, OS.GTK_SENSITIVE);
    } else {
        OS.GTK_WIDGET_UNSET_FLAGS (handle, OS.GTK_SENSITIVE);
    }
}

/**
 * Sets the location of the receiver, which must be a popup,
 * to the point specified by the arguments which are relative
 * to the display.
 * <p>
 * Note that this is different from most widgets where the
 * location of the widget is relative to the parent.
 * </p><p>
 * Note that the platform window manager ultimately has control
 * over the location of popup menus.
 * </p>
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
    if ((style & (SWT.BAR | SWT.DROP_DOWN)) !is 0) return;
    this.x = x;
    this.y = y;
    hasLocation = true;
}

/**
 * Sets the location of the receiver, which must be a popup,
 * to the point specified by the argument which is relative
 * to the display.
 * <p>
 * Note that this is different from most widgets where the
 * location of the widget is relative to the parent.
 * </p><p>
 * Note that the platform window manager ultimately has control
 * over the location of popup menus.
 * </p>
 *
 * @param location the new location for the receiver
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1
 */
public void setLocation (Point location) {
    checkWidget();
    if (location is null) error (SWT.ERROR_NULL_ARGUMENT);
    setLocation (location.x, location.y);
}

override void setOrientation() {
    if ((parent.style & SWT.RIGHT_TO_LEFT) !is 0) {
        if (handle !is null) OS.gtk_widget_set_direction (handle, OS.GTK_TEXT_DIR_RTL);
    }
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
    if ((style & (SWT.BAR | SWT.DROP_DOWN)) !is 0) return;
    if (visible) {
        display.addPopup (this);
    } else {
        display.removePopup (this);
        _setVisible (false);
    }
}
}
