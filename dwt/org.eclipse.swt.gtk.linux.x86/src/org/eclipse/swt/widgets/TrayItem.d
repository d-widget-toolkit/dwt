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

module org.eclipse.swt.widgets.TrayItem;



import java.lang.all;



import org.eclipse.swt.SWT;

import org.eclipse.swt.widgets.Tray;

import org.eclipse.swt.widgets.ToolTip;

import org.eclipse.swt.widgets.ImageList;

import org.eclipse.swt.widgets.Item;

import org.eclipse.swt.events.SelectionListener;

import org.eclipse.swt.events.SelectionEvent;

import org.eclipse.swt.events.MenuDetectListener;

import org.eclipse.swt.widgets.TypedListener;

import org.eclipse.swt.graphics.Image;

import org.eclipse.swt.graphics.Rectangle;

import org.eclipse.swt.graphics.Region;

import org.eclipse.swt.internal.gtk.OS;



version(Tango){

    import tango.util.Convert;

} else { // Phobos

    import std.conv;

}



/**

 * Instances of this class represent icons that can be placed on the

 * system tray or task bar status area.

 * <p>

 * <dl>

 * <dt><b>Styles:</b></dt>

 * <dd>(none)</dd>

 * <dt><b>Events:</b></dt>

 * <dd>DefaultSelection, MenuDetect, Selection</dd>

 * </dl>

 * </p><p>

 * IMPORTANT: This class is <em>not</em> intended to be subclassed.

 * </p>

 *

 * @see <a href="http://www.eclipse.org/swt/snippets/#tray">Tray, TrayItem snippets</a>

 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>

 *

 * @since 3.0

 */

public class TrayItem : Item {

    Tray parent;

    ToolTip toolTip;

    String toolTipText;

    GtkWidget* imageHandle;

    GtkWidget* tooltipsHandle;

    ImageList imageList;



/**

 * Constructs a new instance of this class given its parent

 * (which must be a <code>Tray</code>) and a style value

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

public this (Tray parent, int style) {

    super (parent, style);

    this.parent = parent;

    createWidget (parent.getItemCount ());

}



/**

 * Adds the listener to the collection of listeners who will

 * be notified when the platform-specific context menu trigger

 * has occurred, by sending it one of the messages defined in

 * the <code>MenuDetectListener</code> interface.

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

 * @see MenuDetectListener

 * @see #removeMenuDetectListener

 *

 * @since 3.3

 */

public void addMenuDetectListener (MenuDetectListener listener) {

    checkWidget ();

    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);

    TypedListener typedListener = new TypedListener (listener);

    addListener (SWT.MenuDetect, typedListener);

}



/**

 * Adds the listener to the collection of listeners who will

 * be notified when the receiver is selected by the user, by sending

 * it one of the messages defined in the <code>SelectionListener</code>

 * interface.

 * <p>

 * <code>widgetSelected</code> is called when the receiver is selected

 * <code>widgetDefaultSelected</code> is called when the receiver is double-clicked

 * </p>

 *

 * @param listener the listener which should be notified when the receiver is selected by the user

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

public void addSelectionListener(SelectionListener listener) {

    checkWidget ();

    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);

    TypedListener typedListener = new TypedListener (listener);

    addListener (SWT.Selection, typedListener);

    addListener (SWT.DefaultSelection, typedListener);

}



protected override void checkSubclass () {

    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);

}



override void createWidget (int index) {

    super.createWidget (index);

    parent.createItem (this, index);

}



override void createHandle (int index) {

    state |= HANDLE;

    handle = OS.gtk_plug_new (null);

    if (handle is null) error (SWT.ERROR_NO_HANDLES);

    imageHandle = OS.gtk_image_new ();

    if (imageHandle is null) error (SWT.ERROR_NO_HANDLES);

    OS.gtk_container_add (cast(GtkContainer*)handle, imageHandle);

    OS.gtk_widget_show (handle);

    OS.gtk_widget_show (imageHandle);

    auto id = OS.gtk_plug_get_id (cast(GtkPlug*)handle);

    int monitor = 0;

    auto screen = OS.gdk_screen_get_default ();

    if (screen !is null) {

        monitor = OS.gdk_screen_get_number (screen);

    }

    auto trayAtom = OS.gdk_atom_intern (toStringz("_NET_SYSTEM_TRAY_S" ~ to!(String)(monitor)), true);

    auto xTrayAtom = OS.gdk_x11_atom_to_xatom (trayAtom);

    auto xDisplay = OS.GDK_DISPLAY ();

    auto trayWindow = OS.XGetSelectionOwner (xDisplay, xTrayAtom);

    auto messageAtom = OS.gdk_atom_intern (toStringz("_NET_SYSTEM_TRAY_OPCODE"), true);

    auto xMessageAtom = OS.gdk_x11_atom_to_xatom (messageAtom);

    XClientMessageEvent* event = cast(XClientMessageEvent*)OS.g_malloc (XClientMessageEvent.sizeof);

    event.type = OS.ClientMessage;

    event.window = trayWindow;

    event.message_type = xMessageAtom;

    event.format = 32;

    event.data.l [0] = OS.GDK_CURRENT_TIME;

    event.data.l [1] = OS.SYSTEM_TRAY_REQUEST_DOCK;

    event.data.l [2] = id;

    OS.XSendEvent (xDisplay, trayWindow, false, OS.NoEventMask, cast(XEvent*) event);

    OS.g_free (event);

}



override void deregister () {

    super.deregister ();

    display.removeWidget (imageHandle);

}



override void destroyWidget () {

    parent.destroyItem (this);

    releaseHandle ();

}



/**

 * Returns the receiver's parent, which must be a <code>Tray</code>.

 *

 * @return the receiver's parent

 *

 * @exception SWTException <ul>

 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>

 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>

 * </ul>

 *

 * @since 3.2

 */

public Tray getParent () {

    checkWidget ();

    return parent;

}



/**

 * Returns the receiver's tool tip, or null if it has

 * not been set.

 *

 * @return the receiver's tool tip text

 *

 * @exception SWTException <ul>

 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>

 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>

 * </ul>

 *

 * @since 3.2

 */

public ToolTip getToolTip () {

    checkWidget ();

    return toolTip;

}



/**

 * Returns the receiver's tool tip text, or null if it has

 * not been set.

 *

 * @return the receiver's tool tip text

 *

 * @exception SWTException <ul>

 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>

 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>

 * </ul>

 */

public String getToolTipText () {

    checkWidget ();

    return toolTipText;

}



override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* event) {

    if (event.type is OS.GDK_3BUTTON_PRESS) return 0;

    if (event.button is 3 && event.type is OS.GDK_BUTTON_PRESS) {

        sendEvent (SWT.MenuDetect);

        return 0;

    }

    if (event.type is OS.GDK_2BUTTON_PRESS) {

        postEvent (SWT.DefaultSelection);

    } else {

        postEvent (SWT.Selection);

    }

    return 0;

}



override int gtk_size_allocate (GtkWidget* widget, ptrdiff_t allocation) {

    if (image !is null && image.mask !is null) {

        if (OS.gdk_drawable_get_depth (image.mask) is 1) {

            int xoffset = cast(int) Math.floor (OS.GTK_WIDGET_X (widget) + ((OS.GTK_WIDGET_WIDTH (widget) - OS.GTK_WIDGET_REQUISITION_WIDTH (widget)) * 0.5) + 0.5);

            int yoffset = cast(int) Math.floor (OS.GTK_WIDGET_Y (widget) + ((OS.GTK_WIDGET_HEIGHT (widget) - OS.GTK_WIDGET_REQUISITION_HEIGHT (widget)) * 0.5) + 0.5);

            Rectangle b = image.getBounds();

            auto gdkImage = OS.gdk_drawable_get_image (image.mask, 0, 0, b.width, b.height);

            if (gdkImage is null) SWT.error(SWT.ERROR_NO_HANDLES);

            byte[] maskData = (cast(byte*)gdkImage.mem)[ 0 .. gdkImage.bpl * gdkImage.height].dup;

            Region region = new Region (display);

            for (int y = 0; y < b.height; y++) {

                for (int x = 0; x < b.width; x++) {

                    int index = (y * gdkImage.bpl) + (x >> 3);

                    int theByte = maskData [index] & 0xFF;

                    int mask = 1 << (x & 0x7);

                    if ((theByte & mask) !is 0) {

                        region.add (xoffset + x, yoffset + y, 1, 1);

                    }

                }

            }

            OS.g_object_unref (gdkImage);

            OS.gtk_widget_realize (handle);

            auto window = OS.GTK_WIDGET_WINDOW (handle);

            OS.gdk_window_shape_combine_region (window, region.handle, 0, 0);

            region.dispose ();

        }

    }

    return 0;

}



override void hookEvents () {

    int eventMask = OS.GDK_BUTTON_PRESS_MASK;

    OS.gtk_widget_add_events (handle, eventMask);

    OS.g_signal_connect_closure_by_id (handle, display.signalIds [BUTTON_PRESS_EVENT], 0, display.closures [BUTTON_PRESS_EVENT], false);

    OS.g_signal_connect_closure_by_id (imageHandle, display.signalIds [SIZE_ALLOCATE], 0, display.closures [SIZE_ALLOCATE], false);

 }



/**

 * Returns <code>true</code> if the receiver is visible and

 * <code>false</code> otherwise.

 *

 * @return the receiver's visibility

 *

 * @exception SWTException <ul>

 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>

 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>

 * </ul>

 */

public bool getVisible () {

    checkWidget ();

    return OS.GTK_WIDGET_VISIBLE (handle);

}



override void register () {

    super.register ();

    display.addWidget (imageHandle, this);

}



override void releaseHandle () {

    if (handle !is null) OS.gtk_widget_destroy (handle);

    handle = imageHandle = null;

    super.releaseHandle ();

    parent = null;

}



override void releaseWidget () {

    super.releaseWidget ();

    if (tooltipsHandle !is null) OS.g_object_unref (tooltipsHandle);

    tooltipsHandle = null;

    if (imageList !is null) imageList.dispose ();

    imageList = null;

    toolTipText = null;

}



/**

 * Removes the listener from the collection of listeners who will

 * be notified when the platform-specific context menu trigger has

 * occurred.

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

 * @see MenuDetectListener

 * @see #addMenuDetectListener

 *

 * @since 3.3

 */

public void removeMenuDetectListener (MenuDetectListener listener) {

    checkWidget ();

    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);

    if (eventTable is null) return;

    eventTable.unhook (SWT.MenuDetect, listener);

}



/**

 * Removes the listener from the collection of listeners who will

 * be notified when the receiver is selected by the user.

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

    checkWidget ();

    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);

    if (eventTable is null) return;

    eventTable.unhook (SWT.Selection, listener);

    eventTable.unhook (SWT.DefaultSelection, listener);

}



/**

 * Sets the receiver's image.

 *

 * @param image the new image

 *

 * @exception IllegalArgumentException <ul>

 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>

 * </ul>

 * @exception SWTException <ul>

 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>

 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>

 * </ul>

 */

public override void setImage (Image image) {

    checkWidget ();

    if (image !is null && image.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);

    this.image = image;

    if (image !is null) {

        Rectangle rect = image.getBounds ();

        OS.gtk_widget_set_size_request (handle, rect.width, rect.height);

        if (imageList is null) imageList = new ImageList ();

        int imageIndex = imageList.indexOf (image);

        if (imageIndex is -1) {

            imageIndex = imageList.add (image);

        } else {

            imageList.put (imageIndex, image);

        }

        auto pixbuf = imageList.getPixbuf (imageIndex);

        OS.gtk_image_set_from_pixbuf (cast(GtkImage*)imageHandle, pixbuf);

        OS.gtk_widget_show (imageHandle);

    } else {

        OS.gtk_widget_set_size_request (handle, 1, 1);

        OS.gtk_image_set_from_pixbuf (cast(GtkImage*)imageHandle, null);

        OS.gtk_widget_hide (imageHandle);

    }

}



/**

 * Sets the receiver's tool tip to the argument, which

 * may be null indicating that no tool tip should be shown.

 *

 * @param toolTip the new tool tip (or null)

 *

 * @exception SWTException <ul>

 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>

 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>

 * </ul>

 *

 * @since 3.2

 */

public void setToolTip (ToolTip toolTip) {

    checkWidget ();

    ToolTip oldTip = this.toolTip, newTip = toolTip;

    if (oldTip !is null) oldTip.item = null;

    this.toolTip = newTip;

    if (newTip !is null) newTip.item = this;

}



/**

 * Sets the receiver's tool tip text to the argument, which

 * may be null indicating that no tool tip text should be shown.

 *

 * @param value the new tool tip text (or null)

 *

 * @exception SWTException <ul>

 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>

 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>

 * </ul>

 */

public void setToolTipText (String string) {

    checkWidget ();

    toolTipText = string;

    char* buffer = null;

    if (string !is null && string.length > 0) {

        buffer = toStringz( string );

    }

    if (tooltipsHandle is null) {

        tooltipsHandle = cast(GtkWidget*)OS.gtk_tooltips_new ();

        if (tooltipsHandle is null) error (SWT.ERROR_NO_HANDLES);

        OS.g_object_ref (cast(GObject*)tooltipsHandle);

        OS.gtk_object_sink (cast(GtkObject*)tooltipsHandle);

    }

    OS.gtk_tooltips_set_tip (cast(GtkTooltips*)tooltipsHandle, handle, buffer, null);

}



/**

 * Makes the receiver visible if the argument is <code>true</code>,

 * and makes it invisible otherwise.

 *

 * @param visible the new visibility state

 *

 * @exception SWTException <ul>

 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>

 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>

 * </ul>

 */

public void setVisible (bool visible) {

    checkWidget ();

    if (OS.GTK_WIDGET_VISIBLE (handle) is visible) return;

    if (visible) {

        /*

        * It is possible (but unlikely), that application

        * code could have disposed the widget in the show

        * event.  If this happens, just return.

        */

        sendEvent (SWT.Show);

        if (isDisposed ()) return;

        OS.gtk_widget_show (handle);

    } else {

        OS.gtk_widget_hide (handle);

        sendEvent (SWT.Hide);

    }

}

}

