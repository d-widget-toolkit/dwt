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
module org.eclipse.swt.widgets.TableColumn;

import java.lang.all;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.ControlListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.swt.widgets.ImageList;


/**
 * Instances of this class represent a column in a table widget.
 * <p><dl>
 * <dt><b>Styles:</b></dt>
 * <dd>LEFT, RIGHT, CENTER</dd>
 * <dt><b>Events:</b></dt>
 * <dd> Move, Resize, Selection</dd>
 * </dl>
 * </p><p>
 * Note: Only one of the styles LEFT, RIGHT and CENTER may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#table">Table, TableItem, TableColumn snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class TableColumn : Item {
    GtkWidget* labelHandle, imageHandle, buttonHandle;
    Table parent;
    int modelIndex, lastButton, lastTime, lastX, lastWidth;
    bool customDraw, useFixedWidth;
    String toolTipText;

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Table</code>) and a style value
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
 * @see SWT#LEFT
 * @see SWT#RIGHT
 * @see SWT#CENTER
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Table parent, int style) {
    super (parent, checkStyle (style));
    this.parent = parent;
    createWidget (parent.getColumnCount ());
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>Table</code>), a style value
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
 * <p>
 * Note that due to a restriction on some platforms, the first column
 * is always left aligned.
 * </p>
 * @param parent a composite control which will be the parent of the new instance (cannot be null)
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
 * @see SWT#LEFT
 * @see SWT#RIGHT
 * @see SWT#CENTER
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Table parent, int style, int index) {
    super (parent, checkStyle (style));
    this.parent = parent;
    createWidget (index);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is moved or resized, by sending
 * it one of the messages defined in the <code>ControlListener</code>
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
 * @see ControlListener
 * @see #removeControlListener
 */
public void addControlListener(ControlListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Resize,typedListener);
    addListener (SWT.Move,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the control is selected by the user, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the column header is selected.
 * <code>widgetDefaultSelected</code> is not called.
 * </p>
 *
 * @param listener the listener which should be notified when the control is selected by the user
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
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
}

static int checkStyle (int style) {
    return checkBits (style, SWT.LEFT, SWT.CENTER, SWT.RIGHT, 0, 0, 0);
}

protected override void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

override void createWidget (int index) {
    parent.createItem (this, index);
    setOrientation ();
    hookEvents ();
    register ();
    text = "";
}

override void deregister() {
    super.deregister ();
    display.removeWidget (handle);
    if (buttonHandle !is null) display.removeWidget (buttonHandle);
    if (labelHandle !is null) display.removeWidget (labelHandle);
}

override void destroyWidget () {
    parent.destroyItem (this);
    releaseHandle ();
}

/**
 * Returns a value which describes the position of the
 * text or image in the receiver. The value will be one of
 * <code>LEFT</code>, <code>RIGHT</code> or <code>CENTER</code>.
 *
 * @return the alignment
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getAlignment () {
    checkWidget();
    if ((style & SWT.LEFT) !is 0) return SWT.LEFT;
    if ((style & SWT.CENTER) !is 0) return SWT.CENTER;
    if ((style & SWT.RIGHT) !is 0) return SWT.RIGHT;
    return SWT.LEFT;
}

/**
 * Gets the moveable attribute. A column that is
 * not moveable cannot be reordered by the user
 * by dragging the header but may be reordered
 * by the programmer.
 *
 * @return the moveable attribute
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Table#getColumnOrder()
 * @see Table#setColumnOrder(int[])
 * @see TableColumn#setMoveable(bool)
 * @see SWT#Move
 *
 * @since 3.1
 */
public bool getMoveable() {
    checkWidget();
    return cast(bool)OS.gtk_tree_view_column_get_reorderable (handle);
}

/**
 * Returns the receiver's parent, which must be a <code>Table</code>.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Table getParent () {
    checkWidget();
    return parent;
}

/**
 * Gets the resizable attribute. A column that is
 * not resizable cannot be dragged by the user but
 * may be resized by the programmer.
 *
 * @return the resizable attribute
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getResizable () {
    checkWidget();
    return cast(bool)OS.gtk_tree_view_column_get_resizable (handle);
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
 *
 * @since 3.2
 */
public String getToolTipText () {
    checkWidget();
    return toolTipText;
}

/**
 * Gets the width of the receiver.
 *
 * @return the width
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getWidth () {
    checkWidget();
    if (!OS.gtk_tree_view_column_get_visible (handle)) {
        return 0;
    }
    if (useFixedWidth) return OS.gtk_tree_view_column_get_fixed_width (handle);
    return OS.gtk_tree_view_column_get_width (handle);
}

override int gtk_clicked (GtkWidget* widget) {
    /*
    * There is no API to get a double click on a table column.  Normally, when
    * the mouse is double clicked, this is indicated by GDK_2BUTTON_PRESS
    * but the table column sends the click signal on button release.  The fix is to
    * test for double click by remembering the last click time and mouse button
    * and testing for the double click interval.
    */
    bool doubleClick = false;
    bool postEvent_ = true;
    auto eventPtr = OS.gtk_get_current_event ();
    if (eventPtr !is null) {
        GdkEventButton* gdkEvent = cast(GdkEventButton*)eventPtr;
        switch (gdkEvent.type) {
            case OS.GDK_BUTTON_RELEASE: {
                int clickTime = display.getDoubleClickTime ();
                int eventTime = gdkEvent.time, eventButton = gdkEvent.button;
                if (lastButton is eventButton && lastTime !is 0 && Math.abs (lastTime - eventTime) <= clickTime) {
                    doubleClick = true;
                }
                lastTime = eventTime is 0 ? 1: eventTime;
                lastButton = eventButton;
                break;
            }
            case OS.GDK_MOTION_NOTIFY: {
                /*
                * Bug in GTK.  Dragging a column in a GtkTreeView causes a clicked
                * signal to be emitted even though the mouse button was never released.
                * The fix to ignore the signal if the current GDK event is a motion notify.
                * The GTK bug was fixed in version 2.6
                */
                if (OS.GTK_VERSION < OS.buildVERSION (2, 6, 0)) postEvent_ = false;
                break;
            }
            default:
        }
        OS.gdk_event_free (eventPtr);
    }
    if (postEvent_) postEvent (doubleClick ? SWT.DefaultSelection : SWT.Selection);
    return 0;
}

override int gtk_mnemonic_activate (GtkWidget* widget, ptrdiff_t arg1) {
    return parent.gtk_mnemonic_activate (widget, arg1);
}

override int gtk_size_allocate (GtkWidget* widget, ptrdiff_t allocation) {
    useFixedWidth = false;
    int x = OS.GTK_WIDGET_X (widget);
    int width = OS.GTK_WIDGET_WIDTH (widget);
    if (x !is lastX) {
        lastX = x;
        sendEvent (SWT.Move);
    }
    if (width !is lastWidth) {
        lastWidth = width;
        sendEvent (SWT.Resize);
    }
    return 0;
}

override void hookEvents () {
    super.hookEvents ();
    OS.g_signal_connect_closure (handle, OS.clicked.ptr, display.closures [CLICKED], false);
    if (buttonHandle !is null) OS.g_signal_connect_closure_by_id (buttonHandle, display.signalIds [SIZE_ALLOCATE], 0, display.closures [SIZE_ALLOCATE], false);
    if (labelHandle !is null) OS.g_signal_connect_closure_by_id (labelHandle, display.signalIds [MNEMONIC_ACTIVATE], 0, display.closures [MNEMONIC_ACTIVATE], false);
}

/**
 * Causes the receiver to be resized to its preferred size.
 * For a composite, this involves computing the preferred size
 * from its layout, if there is one.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 */
public void pack () {
    checkWidget();
    int width = 0;
    if (buttonHandle !is null) {
        GtkRequisition requisition;
        OS.gtk_widget_size_request (buttonHandle, &requisition);
        width = requisition.width;
    }
    if ((parent.style & SWT.VIRTUAL) !is 0) {
        for (int i=0; i<parent.items.length; i++) {
            TableItem item = parent.items [i];
            if (item !is null && item.cached) {
                width = Math.max (width, parent.calculateWidth ( cast(GtkTreeViewColumn*)handle, cast(GtkTreeIter*)item.handle));
            }
        }
    } else {
        GtkTreeIter iter;
        if (OS.gtk_tree_model_get_iter_first (parent.modelHandle, &iter)) {
            do {
                width = Math.max (width, parent.calculateWidth (cast(GtkTreeViewColumn*)handle, &iter));
            } while (OS.gtk_tree_model_iter_next(parent.modelHandle, &iter));
        }
    }
    setWidth(width);
}

override void register () {
    super.register ();
    display.addWidget (handle, this);
    if (buttonHandle !is null) display.addWidget (buttonHandle, this);
    if (labelHandle !is null) display.addWidget (labelHandle, this);
}

override void releaseHandle () {
    super.releaseHandle ();
    handle = buttonHandle = labelHandle = imageHandle = null;
    modelIndex = -1;
    parent = null;
}

override void releaseParent () {
    super.releaseParent ();
    if (parent.sortColumn is this) {
        parent.sortColumn = null;
    }
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control is moved or resized.
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
 * @see ControlListener
 * @see #addControlListener
 */
public void removeControlListener (ControlListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Move, listener);
    eventTable.unhook (SWT.Resize, listener);
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
public void removeSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Selection, listener);
    eventTable.unhook (SWT.DefaultSelection,listener);
}

/**
 * Controls how text and images will be displayed in the receiver.
 * The argument should be one of <code>LEFT</code>, <code>RIGHT</code>
 * or <code>CENTER</code>.
 * <p>
 * Note that due to a restriction on some platforms, the first column
 * is always left aligned.
 * </p>
 * @param alignment the new alignment
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setAlignment (int alignment) {
    checkWidget();
    if ((alignment & (SWT.LEFT | SWT.RIGHT | SWT.CENTER)) is 0) return;
    int index = parent.indexOf (this);
    if (index is -1 || index is 0) return;
    style &= ~(SWT.LEFT | SWT.RIGHT | SWT.CENTER);
    style |= alignment & (SWT.LEFT | SWT.RIGHT | SWT.CENTER);
    parent.createRenderers ( cast(GtkTreeViewColumn*)handle, modelIndex, index is 0, style);
}

void setFontDescription (PangoFontDescription* font) {
    OS.gtk_widget_modify_font (labelHandle, font);
    OS.gtk_widget_modify_font (imageHandle, font);
}

public override void setImage (Image image) {
    checkWidget ();
    super.setImage (image);
    if (image !is null) {
        ImageList headerImageList = parent.headerImageList;
        if (headerImageList is null) {
            headerImageList = parent.headerImageList = new ImageList ();
        }
        int imageIndex = headerImageList.indexOf (image);
        if (imageIndex is -1) imageIndex = headerImageList.add (image);
        auto pixbuf = headerImageList.getPixbuf (imageIndex);
        OS.gtk_image_set_from_pixbuf (imageHandle, pixbuf);
        OS.gtk_widget_show (imageHandle);
    } else {
        OS.gtk_image_set_from_pixbuf (imageHandle, null);
        OS.gtk_widget_hide (imageHandle);
    }
}

/**
 * Sets the resizable attribute.  A column that is
 * resizable can be resized by the user dragging the
 * edge of the header.  A column that is not resizable
 * cannot be dragged by the user but may be resized
 * by the programmer.
 *
 * @param resizable the resize attribute
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setResizable (bool resizable) {
    checkWidget();
    OS.gtk_tree_view_column_set_resizable (handle, resizable);
}

/**
 * Sets the moveable attribute.  A column that is
 * moveable can be reordered by the user by dragging
 * the header. A column that is not moveable cannot be
 * dragged by the user but may be reordered
 * by the programmer.
 *
 * @param moveable the moveable attribute
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see Table#setColumnOrder(int[])
 * @see Table#getColumnOrder()
 * @see TableColumn#getMoveable()
 * @see SWT#Move
 *
 * @since 3.1
 */
public void setMoveable (bool moveable) {
    checkWidget();
    OS.gtk_tree_view_column_set_reorderable (handle, moveable);
}

override void setOrientation() {
    if ((parent.style & SWT.RIGHT_TO_LEFT) !is 0) {
        if (buttonHandle !is null) {
            OS.gtk_widget_set_direction (buttonHandle, OS.GTK_TEXT_DIR_RTL);
            display.doSetDirectionProc( buttonHandle, OS.GTK_TEXT_DIR_RTL);
        }
    }
}

public override void setText (String string) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    super.setText (string);
    char [] chars = fixMnemonic (string);
    OS.gtk_label_set_text_with_mnemonic (labelHandle, chars.toStringzValidPtr() );
    if (string.length !is 0) {
        OS.gtk_widget_show (labelHandle);
    } else {
        OS.gtk_widget_hide (labelHandle);
    }
}

/**
 * Sets the receiver's tool tip text to the argument, which
 * may be null indicating that no tool tip text should be shown.
 *
 * @param string the new tool tip text (or null)
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.2
 */
public void setToolTipText (String string) {
    checkWidget();
    Shell shell = parent._getShell ();
    setToolTipText (shell, string);
    toolTipText = string;
}

void setToolTipText (Shell shell, String newString) {
    shell.setToolTipText (buttonHandle, newString);
}

/**
 * Sets the width of the receiver.
 *
 * @param width the new width
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setWidth (int width) {
    checkWidget();
    if (width < 0) return;
    if (width is lastWidth) return;
    if (width > 0) {
        useFixedWidth = true;
        OS.gtk_tree_view_column_set_fixed_width (handle, width);
    }
    /*
     * Bug in GTK.  For some reason, calling gtk_tree_view_column_set_visible()
     * when the parent is not realized fails to show the column. The fix is to
     * ensure that the table has been realized.
     */
    if (width !is 0) OS.gtk_widget_realize (parent.handle);
    OS.gtk_tree_view_column_set_visible (handle, width !is 0);
    lastWidth = width;
    sendEvent (SWT.Resize);
}

}
