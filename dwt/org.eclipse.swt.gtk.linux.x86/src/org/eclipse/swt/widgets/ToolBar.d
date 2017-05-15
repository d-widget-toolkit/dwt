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
module org.eclipse.swt.widgets.ToolBar;

import java.lang.all;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.ToolItem;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.ImageList;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Decorations;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.Event;

/**
 * Instances of this class support the layout of selectable
 * tool bar items.
 * <p>
 * The item children that may be added to instances of this class
 * must be of type <code>ToolItem</code>.
 * </p><p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add <code>Control</code> children to it,
 * or set a layout on it.
 * </p><p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>FLAT, WRAP, RIGHT, HORIZONTAL, VERTICAL, SHADOW_OUT</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles HORIZONTAL and VERTICAL may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#toolbar">ToolBar, ToolItem snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class ToolBar : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.createHandle createHandle;
    alias Composite.forceFocus forceFocus;
    alias Composite.mnemonicHit mnemonicHit;
    alias Composite.mnemonicMatch mnemonicMatch;
    alias Composite.setBounds setBounds;
    alias Composite.setForegroundColor setForegroundColor;
    alias Composite.setToolTipText setToolTipText;

    ToolItem lastFocus;
    ImageList imageList;

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
 * @see SWT#FLAT
 * @see SWT#WRAP
 * @see SWT#RIGHT
 * @see SWT#HORIZONTAL
 * @see SWT#SHADOW_OUT
 * @see SWT#VERTICAL
 * @see Widget#checkSubclass()
 * @see Widget#getStyle()
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
    /*
    * Ensure that either of HORIZONTAL or VERTICAL is set.
    * NOTE: HORIZONTAL and VERTICAL have the same values
    * as H_SCROLL and V_SCROLL so it is necessary to first
    * clear these bits to avoid scroll bars and then reset
    * the bits using the original style supplied by the
    * programmer.
    */
    if ((style & SWT.VERTICAL) !is 0) {
        this.style |= SWT.VERTICAL;
    } else {
        this.style |= SWT.HORIZONTAL;
    }
    int orientation = (style & SWT.VERTICAL) !is 0 ? OS.GTK_ORIENTATION_VERTICAL : OS.GTK_ORIENTATION_HORIZONTAL;
    OS.gtk_toolbar_set_orientation (handle, orientation);
}

static int checkStyle (int style) {
    /*
    * Feature in GTK.  It is not possible to create
    * a toolbar that wraps.  Therefore, no matter what
    * style bits are specified, clear the WRAP bits so
    * that the style matches the behavior.
    */
    if ((style & SWT.WRAP) !is 0) style &= ~SWT.WRAP;
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

override void createHandle (int index) {
    state |= HANDLE | THEME_BACKGROUND;
    fixedHandle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (fixedHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_fixed_set_has_window (fixedHandle, true);
    handle = cast(GtkWidget*)OS.gtk_toolbar_new ();
    if (handle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_container_add (fixedHandle, handle);
    if ((style & SWT.FLAT) !is 0) {
        OS.gtk_widget_set_name (handle, "swt-toolbar-flat".ptr );
    }
}

public override Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    if (wHint !is SWT.DEFAULT && wHint < 0) wHint = 0;
    if (hHint !is SWT.DEFAULT && hHint < 0) hHint = 0;
    return computeNativeSize (handle, wHint, hHint, changed);
}

override GtkWidget* eventHandle () {
    return fixedHandle;
}

override GtkWidget* enterExitHandle() {
    return handle;
}

override void fixChildren (Shell newShell, Shell oldShell, Decorations newDecorations, Decorations oldDecorations, Menu [] menus) {
    super.fixChildren (newShell, oldShell, newDecorations, oldDecorations, menus);
    ToolItem [] items = getItems ();
    if (toolTipText is null) {
        for (int i = 0; i < items.length; i++) {
            ToolItem item = items [i];
            if (item.toolTipText !is null) {
                item.setToolTipText(oldShell, null);
                item.setToolTipText(newShell, item.toolTipText);
            }
        }
    }
}

override bool forceFocus (GtkWidget* focusHandle) {
    if (lastFocus !is null && lastFocus.setFocus ()) return true;
    ToolItem [] items = getItems ();
    for (int i = 0; i < items.length; i++) {
        ToolItem item = items [i];
        if (item.setFocus ()) return true;
    }
    return super.forceFocus (focusHandle);
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
public ToolItem getItem (int index) {
    checkWidget();
    if (!(0 <= index && index < getItemCount())) error (SWT.ERROR_INVALID_RANGE);
    return getItems()[index];
}

/**
 * Returns the item at the given point in the receiver
 * or null if no such item exists. The point is in the
 * coordinate system of the receiver.
 *
 * @param point the point used to locate the item
 * @return the item at the given point
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public ToolItem getItem (Point point) {
    checkWidget();
    if (point is null) error (SWT.ERROR_NULL_ARGUMENT);
    ToolItem[] items = getItems();
    for (int i=0; i<items.length; i++) {
        if (items[i].getBounds().contains(point)) return items[i];
    }
    return null;
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
    auto list = OS.gtk_container_get_children (handle);
    if (list is null) return 0;
    int itemCount = OS.g_list_length (list);
    OS.g_list_free (list);
    return itemCount;
}

/**
 * Returns an array of <code>ToolItem</code>s which are the items
 * in the receiver.
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
public ToolItem [] getItems () {
    checkWidget();
    auto list = OS.gtk_container_get_children (handle);
    if (list is null) return new ToolItem [0];
    int count = OS.g_list_length (list);
    ToolItem [] result = new ToolItem [count];
    for (int i=0; i<count; i++) {
        auto data = OS.g_list_nth_data (list, i);
        Widget widget = display.getWidget (cast(GtkWidget*)data);
        result [i] = cast(ToolItem) widget;
    }
    OS.g_list_free (list);
    return result;
}

/**
 * Returns the number of rows in the receiver. When
 * the receiver has the <code>WRAP</code> style, the
 * number of rows can be greater than one.  Otherwise,
 * the number of rows is always one.
 *
 * @return the number of items
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getRowCount () {
    checkWidget();
     /* On GTK, toolbars cannot wrap */
    return 1;
}

override int gtk_key_press_event (GtkWidget* widget, GdkEventKey* gdkEvent) {
    if (!hasFocus ()) return 0;
    auto result = super.gtk_key_press_event (widget, gdkEvent);
    if (result !is 0) return result;
    ToolItem [] items = getItems ();
    ptrdiff_t length = items.length;
    ptrdiff_t index = 0;
    while (index < length) {
        if (items [index].hasFocus ()) break;
        index++;
    }
    bool next = false;
    switch (gdkEvent.keyval) {
        case OS.GDK_Up:
        case OS.GDK_Left: next = false; break;
        case OS.GDK_Down: {
            if (0 <= index && index < length) {
                ToolItem item = items [index];
                if ((item.style & SWT.DROP_DOWN) !is 0) {
                    Event event = new Event ();
                    event.detail = SWT.ARROW;
                    auto topHandle = item.topHandle ();
                    event.x = OS.GTK_WIDGET_X (topHandle);
                    event.y = (OS.GTK_WIDGET_Y (topHandle) + OS.GTK_WIDGET_HEIGHT (topHandle));
                    if ((style & SWT.MIRRORED) !is 0) event.x = getClientWidth() - OS.GTK_WIDGET_WIDTH(topHandle) - event.x;
                    item.postEvent (SWT.Selection, event);
                    return result;
                }
            }
            goto case OS.GDK_Right;
        }
        case OS.GDK_Right: next = true; break;
        default: return result;
    }
    if ((style & SWT.MIRRORED) !is 0) next= !next;
    ptrdiff_t start = index, offset = next ? 1 : -1;
    while ((index = (index + offset + length) % length) !is start) {
        ToolItem item = items [index];
        if (item.setFocus ()) return result;
    }
    return result;
}

override bool hasFocus () {
    ToolItem [] items = getItems ();
    for (int i=0; i<items.length; i++) {
        ToolItem item = items [i];
        if (item.hasFocus ()) return true;
    }
    return super.hasFocus();
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
 *    <li>ERROR_NULL_ARGUMENT - if the tool item is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the tool item has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (ToolItem item) {
    checkWidget();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    ToolItem [] items = getItems ();
    for (int i=0; i<items.length; i++) {
        if (item is items[i]) return i;
    }
    return -1;
}

override bool mnemonicHit (wchar key) {
    ToolItem [] items = getItems ();
    for (int i=0; i<items.length; i++) {
        auto labelHandle = items [i].labelHandle;
        if (labelHandle !is null && mnemonicHit (labelHandle, key)) return true;
    }
    return false;
}

override bool mnemonicMatch (wchar key) {
    ToolItem [] items = getItems ();
    for (int i=0; i<items.length; i++) {
        auto labelHandle = items [i].labelHandle;
        if (labelHandle !is null && mnemonicMatch (labelHandle, key)) return true;
    }
    return false;
}

void relayout () {
    ToolItem [] items = getItems ();
    for (int i=0; i<items.length; i++) {
        ToolItem item = items [i];
        if (item !is null) item.resizeControl ();
    }
}

override void releaseChildren (bool destroy) {
    ToolItem [] items = getItems ();
    for (int i=0; i<items.length; i++) {
        ToolItem item = items [i];
        if (item !is null && !item.isDisposed ()) {
            item.release (false);
        }
    }
    super.releaseChildren (destroy);
}

override void releaseWidget () {
    super.releaseWidget ();
    if (imageList !is null) imageList.dispose ();
    imageList = null;
}

override void removeControl (Control control) {
    super.removeControl (control);
    ToolItem [] items = getItems ();
    for (int i=0; i<items.length; i++) {
        ToolItem item = items [i];
        if (item.control is control) item.setControl (null);
    }
}

override int setBounds (int x, int y, int width, int height, bool move, bool resize) {
    int result = super.setBounds (x, y, width, height, move, resize);
    if ((result & RESIZED) !is 0) relayout ();
    return result;
}

override void setFontDescription (PangoFontDescription* font) {
    super.setFontDescription (font);
    ToolItem [] items = getItems ();
    for (int i = 0; i < items.length; i++) {
        items[i].setFontDescription (font);
    }
    relayout ();
}

override void setForegroundColor (GdkColor* color) {
    super.setForegroundColor (color);
    ToolItem [] items = getItems ();
    for (int i = 0; i < items.length; i++) {
        items[i].setForegroundColor (color);
    }
}

public override void setToolTipText (String string) {
    checkWidget();
    super.setToolTipText (string);
    Shell shell = _getShell ();
    ToolItem [] items = getItems ();
    for (int i = 0; i < items.length; i++) {
        String newString = string !is null ? null : items [i].toolTipText;
        shell.setToolTipText (items [i].handle, newString);
    }
}

}
