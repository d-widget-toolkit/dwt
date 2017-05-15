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
module org.eclipse.swt.widgets.Combo;


import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.VerifyListener;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.TypedListener;

import java.lang.all;

/**
 * Instances of this class are controls that allow the user
 * to choose an item from a list of items, or optionally
 * enter a new value by typing it into an editable text
 * field. Often, <code>Combo</code>s are used in the same place
 * where a single selection <code>List</code> widget could
 * be used but space is limited. A <code>Combo</code> takes
 * less space than a <code>List</code> widget and shows
 * similar information.
 * <p>
 * Note: Since <code>Combo</code>s can contain both a list
 * and an editable text field, it is possible to confuse methods
 * which access one versus the other (compare for example,
 * <code>clearSelection()</code> and <code>deselectAll()</code>).
 * The API documentation is careful to indicate either "the
 * receiver's list" or the "the receiver's text field" to
 * distinguish between the two cases.
 * </p><p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add children to it, or set a layout on it.
 * </p>
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>DROP_DOWN, READ_ONLY, SIMPLE</dd>
 * <dt><b>Events:</b></dt>
 * <dd>DefaultSelection, Modify, Selection, Verify</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles DROP_DOWN and SIMPLE may be specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see List
 * @see <a href="http://www.eclipse.org/swt/snippets/#combo">Combo snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Combo : Composite {

    alias Composite.computeSize computeSize;
    alias Composite.createHandle createHandle;
    alias Composite.dragDetect dragDetect;
    alias Composite.gtk_button_press_event gtk_button_press_event;
    alias Composite.setBackgroundColor setBackgroundColor;
    alias Composite.setBounds setBounds;
    alias Composite.setForegroundColor setForegroundColor;
    alias Composite.setToolTipText setToolTipText;
    alias Composite.translateTraversal translateTraversal;

    GtkWidget* buttonHandle, entryHandle, listHandle, textRenderer, cellHandle, popupHandle;
    int lastEventTime, visibleCount = 5;
    GdkEventKey* gdkEventKey;
    int fixStart = -1, fixEnd = -1;
    String[] items;
    bool ignoreSelect, lockText;

    static const int INNER_BORDER = 2;

    /**
     * the operating system limit for the number of characters
     * that the text field in an instance of this class can hold
     */
    public const static int LIMIT = 0xFFFF;

    /*
    * These values can be different on different platforms.
    * Therefore they are not initialized in the declaration
    * to stop the compiler from inlining.
    */
    //static {
    //    LIMIT = 0xFFFF;
    //}

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
 * @see SWT#DROP_DOWN
 * @see SWT#READ_ONLY
 * @see SWT#SIMPLE
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

/**
 * Adds the argument to the end of the receiver's list.
 *
 * @param string the new item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #add(String,int)
 */
public void add (String string) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    add (string, cast(int)/*64bit*/items.length);
}

/**
 * Adds the argument to the receiver's list at the given
 * zero-relative index.
 * <p>
 * Note: To add an item at the end of the list, use the
 * result of calling <code>getItemCount()</code> as the
 * index or use <code>add(String)</code>.
 * </p>
 *
 * @param string the new item
 * @param index the index for the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #add(String)
 */
public void add (String string, int index) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (!(0 <= index && index <= items.length)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    String [] newItems = new String[]( items.length + 1 );
    System.arraycopy (items, 0, newItems, 0, index);
    newItems [index] = string;
    System.arraycopy (items, index, newItems, index + 1, items.length - index);
    items = newItems;
    char* buffer = string.toStringzValidPtr();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        OS.gtk_combo_box_insert_text (handle, index, buffer);
        if ((style & SWT.RIGHT_TO_LEFT) !is 0 && popupHandle !is null) {
            display.doSetDirectionProc( popupHandle, OS.GTK_TEXT_DIR_RTL);
        }
    } else {
        /*
        * Feature in GTK. When the list is empty and the first item
        * is added, the combo box selects that item replacing the
        * text in the entry field.  The fix is to avoid this by
        * stopping the "delete" and "insert_text" signal emission.
        */
        ignoreSelect = lockText = true;
        auto item = OS.gtk_list_item_new_with_label (buffer);
        auto label = OS.gtk_bin_get_child (item);
        setForegroundColor (label, getForegroundColor ());
        OS.gtk_widget_modify_font (label, getFontDescription ());
        OS.gtk_widget_set_direction (label, OS.gtk_widget_get_direction (handle));
        OS.gtk_widget_show (item);
        auto items = OS.g_list_append (null, item);
        OS.gtk_list_insert_items (listHandle, items, index);
        ignoreSelect = lockText = false;
    }
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the receiver's text is modified, by sending
 * it one of the messages defined in the <code>ModifyListener</code>
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
 * @see ModifyListener
 * @see #removeModifyListener
 */
public void addModifyListener (ModifyListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Modify, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the user changes the receiver's selection, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the user changes the combo's list selection.
 * <code>widgetDefaultSelected</code> is typically called when ENTER is pressed the combo's text area.
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
public void addSelectionListener(SelectionListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Selection,typedListener);
    addListener (SWT.DefaultSelection,typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when the receiver's text is verified, by sending
 * it one of the messages defined in the <code>VerifyListener</code>
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
 * @see VerifyListener
 * @see #removeVerifyListener
 *
 * @since 3.1
 */
public void addVerifyListener (VerifyListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Verify, typedListener);
}

static int checkStyle (int style) {
    /*
    * Feature in Windows.  It is not possible to create
    * a combo box that has a border using Windows style
    * bits.  All combo boxes draw their own border and
    * do not use the standard Windows border styles.
    * Therefore, no matter what style bits are specified,
    * clear the BORDER bits so that the SWT style will
    * match the Windows widget.
    *
    * The Windows behavior is currently implemented on
    * all platforms.
    */
    style &= ~SWT.BORDER;

    /*
    * Even though it is legal to create this widget
    * with scroll bars, they serve no useful purpose
    * because they do not automatically scroll the
    * widget's client area.  The fix is to clear
    * the SWT style.
    */
    style &= ~(SWT.H_SCROLL | SWT.V_SCROLL);
    style = checkBits (style, SWT.DROP_DOWN, SWT.SIMPLE, 0, 0, 0, 0);
    if ((style & SWT.SIMPLE) !is 0) return style & ~SWT.READ_ONLY;
    return style;
}

protected override void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

/**
 * Sets the selection in the receiver's text field to an empty
 * selection starting just before the first character. If the
 * text field is editable, this has the effect of placing the
 * i-beam at the start of the text.
 * <p>
 * Note: To clear the selected items in the receiver's list,
 * use <code>deselectAll()</code>.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #deselectAll
 */
public void clearSelection () {
    checkWidget();
    if (entryHandle !is null) {
        int position = OS.gtk_editable_get_position (entryHandle);
        OS.gtk_editable_select_region (entryHandle, position, position);
    }
}

void clearText () {
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
        if ((style & SWT.READ_ONLY) !is 0) {
            int index = OS.gtk_combo_box_get_active (handle);
            if (index !is -1) {
                auto modelHandle = OS.gtk_combo_box_get_model (handle);
                char* ptr;
                GtkTreeIter iter;
                OS.gtk_tree_model_iter_nth_child (modelHandle, &iter, null, index);
                OS.gtk_tree_model_get1 (modelHandle, &iter, 0, cast(void**)&ptr );
                if (fromStringz(ptr).length > 0) postEvent (SWT.Modify);
                OS.g_free (ptr);
            }
        } else {
            char dummy = '\0';
            OS.gtk_entry_set_text (entryHandle, &dummy );
        }
        OS.gtk_combo_box_set_active (handle, -1);
        OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    }
}

public override Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        return computeNativeSize (handle, wHint, hHint, changed);
    }
    if (wHint !is SWT.DEFAULT && wHint < 0) wHint = 0;
    if (hHint !is SWT.DEFAULT && hHint < 0) hHint = 0;
    int w, h;
    OS.gtk_widget_realize (entryHandle);
    auto layout = OS.gtk_entry_get_layout (entryHandle);
    OS.pango_layout_get_size (layout, &w, &h);
    int xborder = INNER_BORDER, yborder = INNER_BORDER;
    auto style = OS.gtk_widget_get_style (entryHandle);
    xborder += OS.gtk_style_get_xthickness (style);
    yborder += OS.gtk_style_get_ythickness (style);
    int property;
    OS.gtk_widget_style_get1 (entryHandle, OS.interior_focus.ptr, &property);
    if (property is 0) {
        OS.gtk_widget_style_get1 (entryHandle, OS.focus_line_width.ptr, &property);
        xborder += property ;
        yborder += property ;
    }
    int width = OS.PANGO_PIXELS (w ) + xborder  * 2;
    int height = OS.PANGO_PIXELS (h ) + yborder  * 2;

    GtkRequisition arrowRequesition;
    OS.gtk_widget_size_request (buttonHandle, &arrowRequesition);
    GtkRequisition listRequesition;
    auto listParent = OS.gtk_widget_get_parent (listHandle);
    OS.gtk_widget_size_request (listParent !is null ? listParent : listHandle, &listRequesition);

    width = (Math.max (listRequesition.width, width) + arrowRequesition.width + 4);
    width = wHint is SWT.DEFAULT ? width : wHint;
    height = hHint is SWT.DEFAULT ? height : hHint;
    return new Point (width, height);
}

/**
 * Copies the selected text.
 * <p>
 * The current selection is copied to the clipboard.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1
 */
public void copy () {
    checkWidget ();
    if (entryHandle !is null) OS.gtk_editable_copy_clipboard (entryHandle);
}

override void createHandle (int index) {
    state |= HANDLE | MENU;
    fixedHandle = cast(GtkWidget*)OS.g_object_new (display.gtk_fixed_get_type (), null);
    if (fixedHandle is null) error (SWT.ERROR_NO_HANDLES);
    OS.gtk_fixed_set_has_window (fixedHandle, true);
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        auto oldList = OS.gtk_window_list_toplevels ();
        if ((style & SWT.READ_ONLY) !is 0) {
            handle = OS.gtk_combo_box_new_text ();
            if (handle is null) error (SWT.ERROR_NO_HANDLES);
            cellHandle = OS.gtk_bin_get_child (handle);
            if (cellHandle is null) error (SWT.ERROR_NO_HANDLES);
        } else {
            handle = OS.gtk_combo_box_entry_new_text ();
            if (handle is null) error (SWT.ERROR_NO_HANDLES);
            entryHandle = OS.gtk_bin_get_child (handle);
            if (entryHandle is null) error (SWT.ERROR_NO_HANDLES);
        }
        popupHandle = findPopupHandle (oldList);
        OS.gtk_container_add (fixedHandle, handle);
        textRenderer = cast(GtkWidget*)OS.gtk_cell_renderer_text_new ();
        if (textRenderer is null) error (SWT.ERROR_NO_HANDLES);
        /*
        * Feature in GTK. In order to make a read only combo box the same
        * height as an editable combo box the ypad must be set to 0. In
        * versions 2.4.x of GTK, a pad of 0 will clip some letters. The
        * fix is to set the pad to 1.
        */
        int pad = 0;
        if (OS.GTK_VERSION < OS.buildVERSION(2, 6, 0)) pad = 1;
        OS.g_object_set1 (textRenderer, OS.ypad.ptr, pad);
        /*
        * Feature in GTK.  In version 2.4.9 of GTK, a warning is issued
        * when a call to gtk_cell_layout_clear() is made. The fix is to hide
        * the warning.
        */
        bool warnings = display.getWarnings ();
        display.setWarnings (false);
        OS.gtk_cell_layout_clear (handle);
        display.setWarnings (warnings);
        OS.gtk_cell_layout_pack_start (handle, textRenderer, true);
        OS.gtk_cell_layout_set_attributes1 (handle, textRenderer, OS.text.ptr, null);

        /*
        * Feature in GTK.  There is no API to query the button
        * handle from a combo box although it is possible to get the
        * text field.  The button handle is needed to hook events.  The
        * fix is to walk the combo tree and find the first child that is
        * an instance of button.
        */
        display.allChildrenCollect (handle, 0);
        if (display.allChildren !is null) {
            auto list = display.allChildren;
            while (list !is null) {
                auto widget = OS.g_list_data (list);
                if (OS.GTK_IS_BUTTON (cast(GTypeInstance*)widget)) {
                    buttonHandle = cast(GtkWidget*)widget;
                    break;
                }
                list = OS.g_list_next (list);
            }
            OS.g_list_free (display.allChildren);
            display.allChildren = null;
        }
        /*
        * Feature in GTK. By default, read only combo boxes
        * process the RETURN key rather than allowing the
        * default button to process the key. The fix is to
        * clear the GTK_RECEIVES_DEFAULT flag.
        */
        if ((style & SWT.READ_ONLY) !is 0 && buttonHandle !is null) {
            OS.GTK_WIDGET_UNSET_FLAGS (buttonHandle, OS.GTK_RECEIVES_DEFAULT);
        }
    } else {
        handle = OS.gtk_combo_new ();
        if (handle is null) error (SWT.ERROR_NO_HANDLES);
        OS.gtk_container_add (fixedHandle, handle);
        GtkCombo* combo = cast(GtkCombo*)handle;
        entryHandle = combo.entry;
        listHandle = combo.list;

        if (OS.GTK_VERSION < OS.buildVERSION (2, 4, 0)) {
            GtkWidget* parentHandle = null;
            auto temp = listHandle;
            while ((temp = OS.gtk_widget_get_parent(temp)) !is null) {
                parentHandle = temp;
            }
            popupHandle = parentHandle;
            if (popupHandle !is null) {
                GtkWidget* modalGroup = getShell().modalGroup;
                if (modalGroup !is null) {
                    OS.gtk_window_group_add_window (modalGroup, popupHandle);
                }
            }
        }
        /*
        * Feature in GTK.  There is no API to query the arrow
        * handle from a combo box although it is possible to
        * get the list and text field.  The arrow handle is needed
        * to hook events.  The fix is to find the first child that is
        * not the entry or list and assume this is the arrow handle.
        */
        auto list = OS.gtk_container_get_children (handle);
        if (list !is null) {
            int i = 0, count = OS.g_list_length (list);
            while (i<count) {
                auto childHandle = OS.g_list_nth_data (list, i);
                if (childHandle !is entryHandle && childHandle !is listHandle) {
                    buttonHandle = cast(GtkWidget*)childHandle;
                    break;
                }
                i++;
            }
            OS.g_list_free (list);
        }

        bool editable = (style & SWT.READ_ONLY) is 0;
        OS.gtk_editable_set_editable (entryHandle, editable);
        OS.gtk_combo_disable_activate (handle);
        OS.gtk_combo_set_case_sensitive (handle, true);
    }
}

/**
 * Cuts the selected text.
 * <p>
 * The current selection is first copied to the
 * clipboard and then deleted from the widget.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1
 */
public void cut () {
    checkWidget ();
    if (entryHandle !is null) OS.gtk_editable_cut_clipboard (entryHandle);
}

override void deregister () {
    super.deregister ();
    if (buttonHandle !is null) display.removeWidget (buttonHandle);
    if (entryHandle !is null) display.removeWidget (entryHandle);
    if (listHandle !is null) display.removeWidget (listHandle);
    auto imContext = imContext ();
    if (imContext !is null) display.removeWidget (cast(GtkWidget*)imContext);
}

override bool filterKey (int keyval, GdkEventKey* event) {
    int time = OS.gdk_event_get_time (cast(GdkEvent*)event);
    if (time !is lastEventTime) {
        lastEventTime = time;
        auto imContext = imContext ();
        if (imContext !is null) {
            return cast(bool)OS.gtk_im_context_filter_keypress (imContext, event);
        }
    }
    gdkEventKey = event;
    return false;
}

GtkWidget* findPopupHandle (GList* oldList) {
    GtkWidget* hdl = null;
    GList* currentList = OS.gtk_window_list_toplevels();
    GList* oldFromList = oldList;
    GList* newFromList = currentList;
    bool isFound;
    while (newFromList !is null) {
        void* newToplevel = OS.g_list_data(newFromList);
        isFound = false;
        oldFromList = oldList;
        while (oldFromList !is null) {
            void* oldToplevel = OS.g_list_data(oldFromList);
            if (newToplevel is oldToplevel) {
                isFound = true;
                break;
            }
            oldFromList = OS.g_list_next(oldFromList);
        }
        if (!isFound) {
            hdl = cast(GtkWidget*)newToplevel;
            break;
        }
        newFromList = OS.g_list_next(newFromList);
    }
    OS.g_list_free(oldList);
    OS.g_list_free(currentList);
    return hdl;
}

override void fixModal (GtkWidget* group, GtkWidget* modalGroup) {
    if (popupHandle !is null) {
        if (group !is null) {
            OS.gtk_window_group_add_window (group, popupHandle);
        } else {
            if (modalGroup !is null) {
                OS.gtk_window_group_remove_window (modalGroup, popupHandle);
            }
        }
    }
}

void fixIM () {
    /*
    *  The IM filter has to be called one time for each key press event.
    *  When the IM is open the key events are duplicated. The first event
    *  is filtered by SWT and the second event is filtered by GTK.  In some
    *  cases the GTK handler does not run (the widget is destroyed, the
    *  application code consumes the event, etc), for these cases the IM
    *  filter has to be called by SWT.
    */
    if (gdkEventKey !is null && gdkEventKey !is cast(GdkEventKey*)-1) {
        auto imContext = imContext ();
        if (imContext !is null) {
            OS.gtk_im_context_filter_keypress (imContext, gdkEventKey);
            gdkEventKey = cast(GdkEventKey*)-1;
            return;
        }
    }
    gdkEventKey = null;
}

override GtkWidget* fontHandle () {
    if (entryHandle !is null) return entryHandle;
    return super.fontHandle ();
}

override GtkWidget* focusHandle () {
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        if ((style & SWT.READ_ONLY) !is 0 && buttonHandle !is null) return buttonHandle;
    }
    if (entryHandle !is null) return entryHandle;
    return super.focusHandle ();
}

override bool hasFocus () {
    if (super.hasFocus ()) return true;
    if (entryHandle !is null && OS.GTK_WIDGET_HAS_FOCUS (entryHandle)) return true;
    if (listHandle !is null && OS.GTK_WIDGET_HAS_FOCUS (listHandle)) return true;
    return false;
}

override void hookEvents () {
    super.hookEvents ();
    if (OS.GTK_VERSION >= OS.buildVERSION(2, 4, 0)) {
        OS.g_signal_connect_closure (handle, OS.changed.ptr, display.closures [CHANGED], true);
    }

    if (entryHandle !is null) {
        OS.g_signal_connect_closure (entryHandle, OS.changed.ptr, display.closures [CHANGED], true);
        OS.g_signal_connect_closure (entryHandle, OS.insert_text.ptr, display.closures [INSERT_TEXT], false);
        OS.g_signal_connect_closure (entryHandle, OS.delete_text.ptr, display.closures [DELETE_TEXT], false);
        OS.g_signal_connect_closure (entryHandle, OS.activate.ptr, display.closures [ACTIVATE], false);
        OS.g_signal_connect_closure (entryHandle, OS.populate_popup.ptr, display.closures [POPULATE_POPUP], false);
    }
    int eventMask = OS.GDK_POINTER_MOTION_MASK | OS.GDK_BUTTON_PRESS_MASK |
        OS.GDK_BUTTON_RELEASE_MASK;
    GtkWidget*[] handles = [ buttonHandle, entryHandle, listHandle ];
    for (int i=0; i<handles.length; i++) {
        auto eventHandle = handles [i];
        if (eventHandle !is null) {
            /* Connect the mouse signals */
            OS.gtk_widget_add_events (eventHandle, eventMask);
            OS.g_signal_connect_closure_by_id (eventHandle, display.signalIds [BUTTON_PRESS_EVENT], 0, display.closures [BUTTON_PRESS_EVENT], false);
            OS.g_signal_connect_closure_by_id (eventHandle, display.signalIds [BUTTON_RELEASE_EVENT], 0, display.closures [BUTTON_RELEASE_EVENT], false);
            OS.g_signal_connect_closure_by_id (eventHandle, display.signalIds [MOTION_NOTIFY_EVENT], 0, display.closures [MOTION_NOTIFY_EVENT], false);
            /*
            * Feature in GTK.  Events such as mouse move are propagated up
            * the widget hierarchy and are seen by the parent.  This is the
            * correct GTK behavior but not correct for SWT.  The fix is to
            * hook a signal after and stop the propagation using a negative
            * event number to distinguish this case.
            */
            OS.g_signal_connect_closure_by_id (eventHandle, display.signalIds [BUTTON_PRESS_EVENT], 0, display.closures [BUTTON_PRESS_EVENT_INVERSE], true);
            OS.g_signal_connect_closure_by_id (eventHandle, display.signalIds [BUTTON_RELEASE_EVENT], 0, display.closures [BUTTON_RELEASE_EVENT_INVERSE], true);
            OS.g_signal_connect_closure_by_id (eventHandle, display.signalIds [MOTION_NOTIFY_EVENT], 0, display.closures [MOTION_NOTIFY_EVENT_INVERSE], true);

            /* Connect the event_after signal for both key and mouse */
            if (eventHandle !is focusHandle ()) {
                OS.g_signal_connect_closure_by_id (eventHandle, display.signalIds [EVENT_AFTER], 0, display.closures [EVENT_AFTER], false);
            }
        }
    }
    auto imContext = imContext ();
    if (imContext !is null) {
        OS.g_signal_connect_closure (imContext, OS.commit.ptr, display.closures [COMMIT], false);
        int id = OS.g_signal_lookup (OS.commit.ptr, OS.gtk_im_context_get_type ());
        int blockMask =  OS.G_SIGNAL_MATCH_DATA | OS.G_SIGNAL_MATCH_ID;
        OS.g_signal_handlers_block_matched (imContext, blockMask, id, 0, null, null, entryHandle);
    }
}

GtkIMContext* imContext () {
    return entryHandle !is null ? OS.GTK_ENTRY_IM_CONTEXT (entryHandle) : null;
}

/**
 * Deselects the item at the given zero-relative index in the receiver's
 * list.  If the item at the index was already deselected, it remains
 * deselected. Indices that are out of range are ignored.
 *
 * @param index the index of the item to deselect
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void deselect (int index) {
    checkWidget();
    if (index < 0 || index >= items.length) return;
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        if (OS.gtk_combo_box_get_active (handle) is index) {
            clearText ();
        }
    } else {
        ignoreSelect = true;
        auto children = OS.gtk_container_get_children (listHandle);
        auto item = OS.g_list_nth_data (children, index);
        bool selected = OS.GTK_WIDGET_STATE (item) is OS.GTK_STATE_SELECTED;
        if (selected) {
            OS.gtk_list_unselect_all (listHandle);
            OS.gtk_entry_set_text (entryHandle, "".ptr );
        }
        OS.g_list_free (children);
        ignoreSelect = false;
    }
}

/**
 * Deselects all selected items in the receiver's list.
 * <p>
 * Note: To clear the selection in the receiver's text field,
 * use <code>clearSelection()</code>.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #clearSelection
 */
public void deselectAll () {
    checkWidget();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        clearText ();
    } else {
        ignoreSelect = true;
        OS.gtk_list_unselect_all (listHandle);
        OS.gtk_entry_set_text (entryHandle, "".ptr );
        ignoreSelect = false;
    }
}


override bool dragDetect(int x, int y, bool filter, bool* consume) {
    if (filter && entryHandle !is null) {
        int index;
        int trailing;
        auto layout = OS.gtk_entry_get_layout (entryHandle);
        OS.pango_layout_xy_to_index (layout, x * OS.PANGO_SCALE, y * OS.PANGO_SCALE, &index, &trailing);
        auto ptr = OS.pango_layout_get_text (layout);
        auto position = OS.g_utf8_pointer_to_offset (ptr, ptr + index) + trailing;
        Point selection = getSelection ();
        if (selection.x <= position && position < selection.y) {
            if (super.dragDetect (x, y, filter, consume)) {
                if (consume !is null) *consume = true;
                return true;
            }
        }
        return false;
    }
    return super.dragDetect (x, y, filter, consume);
}

override GtkWidget* enterExitHandle () {
    return fixedHandle;
}

override GdkDrawable* eventWindow () {
    return paintWindow ();
}

override GdkColor* getBackgroundColor () {
    return getBaseColor ();
}

override GdkColor* getForegroundColor () {
    return getTextColor ();
}

/**
 * Returns the item at the given, zero-relative index in the
 * receiver's list. Throws an exception if the index is out
 * of range.
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
public String getItem (int index) {
    checkWidget();
    if (!(0 <= index && index < items.length)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    return items [index];
}

/**
 * Returns the number of items contained in the receiver's list.
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
    return cast(int)/*64bit*/items.length;
}

/**
 * Returns the height of the area which would be used to
 * display <em>one</em> of the items in the receiver's list.
 *
 * @return the height of one item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getItemHeight () {
    checkWidget();
    return fontHeight (getFontDescription (), listHandle !is null ? listHandle : handle);
}

/**
 * Returns a (possibly empty) array of <code>String</code>s which are
 * the items in the receiver's list.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of items, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return the items in the receiver's list
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String [] getItems () {
    checkWidget();
    String [] result = new String[](items.length);
    System.arraycopy (items, 0, result, 0, items.length);
    return result;
}

/**
 * Returns <code>true</code> if the receiver's list is visible,
 * and <code>false</code> otherwise.
 * <p>
 * If one of the receiver's ancestors is not visible or some
 * other condition makes the receiver not visible, this method
 * may still indicate that it is considered visible even though
 * it may not actually be showing.
 * </p>
 *
 * @return the receiver's list's visibility state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public bool getListVisible () {
    checkWidget ();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        return popupHandle !is null && OS.GTK_WIDGET_VISIBLE (popupHandle);
    }
    return false;
}

override
String getNameText () {
    return getText ();
}

/**
 * Returns the orientation of the receiver.
 *
 * @return the orientation style
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1.2
 */
public int getOrientation () {
    checkWidget();
    return style & (SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT);
}

/**
 * Returns a <code>Point</code> whose x coordinate is the
 * character position representing the start of the selection
 * in the receiver's text field, and whose y coordinate is the
 * character position representing the end of the selection.
 * An "empty" selection is indicated by the x and y coordinates
 * having the same value.
 * <p>
 * Indexing is zero based.  The range of a selection is from
 * 0..N where N is the number of characters in the widget.
 * </p>
 *
 * @return a point representing the selection start and end
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Point getSelection () {
    checkWidget ();
    if ((style & SWT.READ_ONLY) !is 0) {
        size_t length = 0;
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
            int index = OS.gtk_combo_box_get_active (handle);
            if (index !is -1) length = getItem (index).length;
        } else {
            auto str = OS.gtk_entry_get_text (entryHandle);
            if (str !is null) length = OS.g_utf8_strlen (str, -1);
        }
        return new Point (0, cast(int)/*64bit*/length);
    }
    int start;
    int end;
    if (entryHandle !is null) {
        OS.gtk_editable_get_selection_bounds (entryHandle, &start, &end);
    }
    return new Point(start, end);
}

/**
 * Returns the zero-relative index of the item which is currently
 * selected in the receiver's list, or -1 if no item is selected.
 *
 * @return the index of the selected item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getSelectionIndex () {
    checkWidget();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        return OS.gtk_combo_box_get_active (handle);
    }
    int index = 0, result = -1;
    auto children = OS.gtk_container_get_children (listHandle);
    auto temp = children;
    while (temp !is null) {
        auto item = OS.g_list_data (temp);
        if (OS.GTK_WIDGET_STATE (item) is OS.GTK_STATE_SELECTED) {
            result = index;
            break;
        }
        index++;
        temp = OS.g_list_next (temp);
    }
    OS.g_list_free (children);
    return result;
}

/**
 * Returns a string containing a copy of the contents of the
 * receiver's text field, or an empty string if there are no
 * contents.
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
    if (entryHandle !is null) {
        auto str = OS.gtk_entry_get_text (entryHandle);
        if (str is null) return "";
        return fromStringz(str)._idup();
    } else {
        int index = OS.gtk_combo_box_get_active (handle);
        return index !is -1 ? getItem (index) : "";
    }
}

String getText (int start, int stop) {
    /*
    * NOTE: The current implementation uses substring ()
    * which can reference a potentially large character
    * array.
    */
    return getText ()[ start .. stop - 1];
}

/**
 * Returns the height of the receivers's text field.
 *
 * @return the text height
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int getTextHeight () {
    checkWidget();
    GtkRequisition requisition;
    gtk_widget_size_request (handle, &requisition);
    return OS.GTK_WIDGET_REQUISITION_HEIGHT (handle);
}

/**
 * Returns the maximum number of characters that the receiver's
 * text field is capable of holding. If this has not been changed
 * by <code>setTextLimit()</code>, it will be the constant
 * <code>Combo.LIMIT</code>.
 *
 * @return the text limit
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #LIMIT
 */
public int getTextLimit () {
    checkWidget();
    int limit = entryHandle !is null ? OS.gtk_entry_get_max_length (entryHandle) : 0;
    return limit is 0 ? LIMIT : limit;
}

/**
 * Gets the number of items that are visible in the drop
 * down portion of the receiver's list.
 * <p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept.
 * </p>
 *
 * @return the number of items that are visible
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public int getVisibleItemCount () {
    checkWidget ();
    return visibleCount;
}

override int gtk_activate (GtkWidget* widget) {
    postEvent (SWT.DefaultSelection);
    return 0;
}

override int gtk_button_press_event (GtkWidget* widget, GdkEventButton* event) {
    /*
    * Feature in GTK. Depending on where the user clicks, GTK prevents
    * the left mouse button event from being propagated. The fix is to
    * send the mouse event from the event_after handler.
    */
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        GdkEventButton* gdkEvent = event;
        if (gdkEvent.type is OS.GDK_BUTTON_PRESS && gdkEvent.button is 1 && (style & SWT.READ_ONLY) !is 0) {
            return gtk_button_press_event(widget, event, false);
        }

    }
    return super.gtk_button_press_event (widget, event);
}

override int gtk_changed (GtkWidget* widget) {
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        if (widget is handle) {
            if (entryHandle is null) {
                sendEvent(SWT.Modify);
                if (isDisposed ()) return 0;
            }
            /*
            * Feature in GTK.  GTK emits a changed signal whenever
            * the contents of a combo box are altered by typing or
            * by selecting an item in the list, but the event should
            * only be sent when the list is selected. The fix is to
            * only send out a selection event when there is a selected
            * item.
            *
            * NOTE: This code relies on GTK clearing the selected
            * item and not matching the item as the user types.
            */
            int index = OS.gtk_combo_box_get_active (handle);
            if (index !is -1) postEvent (SWT.Selection);
            return 0;
        }
    } else {
        if (!ignoreSelect) {
            auto ptr = OS.gtk_entry_get_text (entryHandle);
            String text = fromStringz(ptr)._idup();
            for (int i = 0; i < items.length; i++) {
                if (items [i] ==/*eq*/ text) {
                    postEvent (SWT.Selection);
                    break;
                }
            }
        }
    }
    /*
    * Feature in GTK.  When the user types, GTK positions
    * the caret after sending the changed signal.  This
    * means that application code that attempts to position
    * the caret during a changed signal will fail.  The fix
    * is to post the modify event when the user is typing.
    */
    bool keyPress = false;
    auto eventPtr = OS.gtk_get_current_event ();
    if (eventPtr !is null) {
        GdkEventKey* gdkEvent = cast(GdkEventKey*)eventPtr;
        switch (gdkEvent.type) {
            case OS.GDK_KEY_PRESS:
                keyPress = true;
                break;
            default:
        }
        OS.gdk_event_free (eventPtr);
    }
    if (keyPress) {
        postEvent (SWT.Modify);
    } else {
        sendEvent (SWT.Modify);
    }
    return 0;
}

override int gtk_commit (GtkIMContext* imContext, char* text) {
    if (text is null) return 0;
    if (!OS.gtk_editable_get_editable (entryHandle)) return 0;
    char [] chars = fromStringz(text);
    if (chars.length is 0) return 0;
    char [] newChars = sendIMKeyEvent (SWT.KeyDown, null, chars);
    if (newChars is null) return 0;
    /*
    * Feature in GTK.  For a GtkEntry, during the insert-text signal,
    * GTK allows the programmer to change only the caret location,
    * not the selection.  If the programmer changes the selection,
    * the new selection is lost.  The fix is to detect a selection
    * change and set it after the insert-text signal has completed.
    */
    fixStart = fixEnd = -1;
    OS.g_signal_handlers_block_matched (imContext, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCOMMIT);
    int id = OS.g_signal_lookup (OS.commit.ptr, OS.gtk_im_context_get_type ());
    int mask =  OS.G_SIGNAL_MATCH_DATA | OS.G_SIGNAL_MATCH_ID;
    OS.g_signal_handlers_unblock_matched (imContext, mask, id, 0, null, null, entryHandle);
    if (newChars is chars) {
        OS.g_signal_emit_by_name1 (imContext, OS.commit.ptr, cast(int)text);
    } else {
        OS.g_signal_emit_by_name1 (imContext, OS.commit.ptr, cast(int)toStringz(newChars));
    }
    OS.g_signal_handlers_unblock_matched (imContext, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCOMMIT);
    OS.g_signal_handlers_block_matched (imContext, mask, id, 0, null, null, entryHandle);
    if (fixStart !is -1 && fixEnd !is -1) {
        OS.gtk_editable_set_position (entryHandle, fixStart);
        OS.gtk_editable_select_region (entryHandle, fixStart, fixEnd);
    }
    fixStart = fixEnd = -1;
    return 0;
}

override int gtk_delete_text (GtkWidget* widget, ptrdiff_t start_pos, ptrdiff_t end_pos) {
    if (lockText) {
        OS.gtk_list_unselect_item (listHandle, 0);
        OS.g_signal_stop_emission_by_name (entryHandle, OS.delete_text.ptr);
        return 0;
    }
    if (!hooks (SWT.Verify) && !filters (SWT.Verify)) return 0;
    String newText = verifyText ("", cast(int)/*64bit*/start_pos, cast(int)/*64bit*/end_pos);
    if (newText is null) {
        OS.g_signal_stop_emission_by_name (entryHandle, OS.delete_text.ptr);
    } else {
        if (newText.length > 0) {
            int pos;
            pos = cast(int)/*64bit*/end_pos;
            OS.g_signal_handlers_block_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
            OS.g_signal_handlers_block_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udINSERT_TEXT);
            OS.gtk_editable_insert_text (entryHandle, newText.ptr, cast(int)/*64bit*/newText.length, &pos);
            OS.g_signal_handlers_unblock_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udINSERT_TEXT);
            OS.g_signal_handlers_unblock_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
            OS.gtk_editable_set_position (entryHandle, pos );
        }
    }
    return 0;
}

override int gtk_event_after (GtkWidget* widget, GdkEvent* event) {
    /*
    * Feature in GTK. Depending on where the user clicks, GTK prevents
    * the left mouse button event from being propagated. The fix is to
    * send the mouse event from the event_after handler.
    *
    * Feature in GTK. When the user clicks anywhere in an editable
    * combo box, a single focus event should be issued, despite the
    * fact that focus might switch between the drop down button and
    * the text field. The fix is to use gtk_combo_box_set_focus_on_click ()
    * to eat all focus events while focus is in the combo box. When the
    * user clicks on the drop down button focus is assigned to the text
    * field.
    */
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        switch (event.type) {
            case OS.GDK_BUTTON_PRESS: {
                GdkEventButton* gdkEventButton = cast(GdkEventButton*)event;
                if (gdkEventButton.button is 1) {
                    if ((style & SWT.READ_ONLY) !is 0 && !sendMouseEvent (SWT.MouseDown, gdkEventButton.button, display.clickCount, 0, false, gdkEventButton.time, gdkEventButton.x_root, gdkEventButton.y_root, false, gdkEventButton.state)) {
                        return 1;
                    }
                    if (OS.GTK_VERSION >= OS.buildVERSION (2, 6, 0)) {
                        if ((style & SWT.READ_ONLY) is 0 && widget is buttonHandle) {
                            OS.gtk_widget_grab_focus (entryHandle);
                        }
                    }
                }
                break;
            }
            case OS.GDK_FOCUS_CHANGE: {
                if (OS.GTK_VERSION >= OS.buildVERSION (2, 6, 0)) {
                    if ((style & SWT.READ_ONLY) is 0) {
                        GdkEventFocus* gdkEventFocus = cast(GdkEventFocus*)event;
                        if (gdkEventFocus.in_ !is 0) {
                            OS.gtk_combo_box_set_focus_on_click (handle, false);
                        } else {
                            OS.gtk_combo_box_set_focus_on_click (handle, true);
                        }
                    }
                }
                break;
            }
            default:
        }
    }
    return super.gtk_event_after(widget, event);
}

override int gtk_focus_out_event (GtkWidget* widget, GdkEventFocus* event) {
    fixIM ();
    return super.gtk_focus_out_event (widget, event);
}

override int gtk_insert_text (GtkEditable* widget, char* new_text, ptrdiff_t new_text_length, ptrdiff_t position) {
    if (lockText) {
        OS.gtk_list_unselect_item (listHandle, 0);
        OS.g_signal_stop_emission_by_name (entryHandle, OS.insert_text.ptr);
        return 0;
    }
    if (!hooks (SWT.Verify) && !filters (SWT.Verify)) return 0;
    if (new_text is null || new_text_length is 0) return 0;
    String oldText = new_text[0..new_text_length]._idup();
    int pos;
    pos = cast(int)/*64bit*/position;
    if (pos is -1) {
        auto ptr = OS.gtk_entry_get_text (entryHandle);
        pos = cast(int)/*64bit*/fromStringz(ptr).length;
    }
    String newText = verifyText (oldText, pos, pos);
    if (newText !is oldText) {
        int newStart, newEnd;
        OS.gtk_editable_get_selection_bounds (entryHandle, &newStart, &newEnd);
        if (newText !is null) {
            if (newStart !is newEnd) {
                OS.g_signal_handlers_block_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udDELETE_TEXT);
                OS.g_signal_handlers_block_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
                OS.gtk_editable_delete_selection (entryHandle);
                OS.g_signal_handlers_unblock_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udDELETE_TEXT);
                OS.g_signal_handlers_unblock_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
            }
            OS.g_signal_handlers_block_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udINSERT_TEXT);
            OS.gtk_editable_insert_text (entryHandle, newText.ptr, cast(int)/*64bit*/newText.length, &pos);
            OS.g_signal_handlers_unblock_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udINSERT_TEXT);
            newStart = newEnd = pos;
        }
        pos = newEnd;
        if (newStart !is newEnd) {
            fixStart = newStart;
            fixEnd = newEnd;
        }
        position = pos;
        OS.g_signal_stop_emission_by_name (entryHandle, OS.insert_text.ptr);
    }
    return 0;
}

override int gtk_key_press_event (GtkWidget* widget, GdkEventKey* event) {
    auto result = super.gtk_key_press_event (widget, event);
    if (result !is 0) fixIM ();
    if (gdkEventKey is cast(GdkEventKey*)-1) result = 1;
    gdkEventKey = null;
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0) && (style & SWT.READ_ONLY) is 0) {
        GdkEventKey* keyEvent = cast(GdkEventKey*)event;
        int oldIndex = OS.gtk_combo_box_get_active (handle);
        int newIndex = oldIndex;
        int key = keyEvent.keyval;
        switch (key) {
            case OS.GDK_Down:
            case OS.GDK_KP_Down:
                 if (oldIndex !is (items.length - 1)) {
                    newIndex = oldIndex + 1;
                 }
                 break;
            case OS.GDK_Up:
            case OS.GDK_KP_Up:
                if (oldIndex !is -1 && oldIndex !is 0) {
                    newIndex = oldIndex - 1;
                }
                break;
            /*
            * Feature in GTK. In gtk_combo_box, the PageUp and PageDown keys
            * go the first and last items in the list rather than scrolling
            * a page at a time. The fix is to emulate this behavior for
            * gtk_combo_box_entry.
            */
            case OS.GDK_Page_Up:
            case OS.GDK_KP_Page_Up:
                newIndex = 0;
                break;
            case OS.GDK_Page_Down:
            case OS.GDK_KP_Page_Down:
                newIndex = cast(int)/*64bit*/items.length - 1;
                break;
            default:
        }
        if (newIndex !is oldIndex) {
            OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
            OS.gtk_combo_box_set_active (handle, newIndex);
            OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
            return 1;
        }
    }
    return result;
}

override int gtk_populate_popup (GtkWidget* widget, GtkWidget* menu) {
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        OS.gtk_widget_set_direction (menu, OS.GTK_TEXT_DIR_RTL);
        display.doSetDirectionProc(menu, OS.GTK_TEXT_DIR_RTL);
    }
    return 0;
}

/**
 * Searches the receiver's list starting at the first item
 * (index 0) until an item is found that is equal to the
 * argument, and returns the index of that item. If no item
 * is found, returns -1.
 *
 * @param string the search item
 * @return the index of the item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (String string) {
    checkWidget();
    return indexOf (string, 0);
}

/**
 * Searches the receiver's list starting at the given,
 * zero-relative index until an item is found that is equal
 * to the argument, and returns the index of that item. If
 * no item is found or the starting index is out of range,
 * returns -1.
 *
 * @param string the search item
 * @param start the zero-relative index at which to begin the search
 * @return the index of the item
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public int indexOf (String string, int start) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (!(0 <= start && start < items.length)) return -1;
    for (int i=start; i<items.length; i++) {
        if (string.equals (items [i])) return i;
    }
    return -1;
}

override bool isFocusHandle(GtkWidget* widget) {
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        if (buttonHandle !is null && widget is buttonHandle) return true;
        if (entryHandle !is null && widget is entryHandle) return true;
    }
    return super.isFocusHandle (widget);
}

override GdkDrawable* paintWindow () {
    auto childHandle =  entryHandle !is null ? entryHandle : handle;
    OS.gtk_widget_realize (childHandle);
    auto window = OS.GTK_WIDGET_WINDOW (childHandle);
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        if ((style & SWT.READ_ONLY) !is 0) return window;
    }
    auto children = OS.gdk_window_get_children (window);
    if (children !is null) window = cast(GdkDrawable*)OS.g_list_data (children);
    OS.g_list_free (children);
    return window;
}

/**
 * Pastes text from clipboard.
 * <p>
 * The selected text is deleted from the widget
 * and new text inserted from the clipboard.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1
 */
public void paste () {
    checkWidget ();
    if (entryHandle !is null) OS.gtk_editable_paste_clipboard (entryHandle);
}

override GtkWidget* parentingHandle() {
    return fixedHandle;
}

override void register () {
    super.register ();
    if (buttonHandle !is null) display.addWidget (buttonHandle, this);
    if (entryHandle !is null) display.addWidget (entryHandle, this);
    if (listHandle !is null) display.addWidget (listHandle, this);
    auto imContext = imContext ();
    if (imContext !is null) display.addWidget (cast(GtkWidget*)imContext, this);
}

override void releaseHandle () {
    super.releaseHandle ();
    buttonHandle = entryHandle = listHandle = null;
}

override void releaseWidget () {
    super.releaseWidget ();
    textRenderer = null;
    fixIM ();
}

/**
 * Removes the item from the receiver's list at the given
 * zero-relative index.
 *
 * @param index the index for the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void remove (int index) {
    checkWidget();
    if (!(0 <= index && index < items.length)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    String [] oldItems = items;
    String [] newItems = new String[]( oldItems.length - 1 );
    System.arraycopy (oldItems, 0, newItems, 0, index);
    System.arraycopy (oldItems, index + 1, newItems, index, oldItems.length - index - 1);
    items = newItems;
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        if (OS.gtk_combo_box_get_active (handle) is index) clearText ();
        OS.gtk_combo_box_remove_text (handle, index);
    } else {
        ignoreSelect = true;
        auto children = OS.gtk_container_get_children (listHandle);
        auto item = OS.g_list_nth_data (children, index);
        bool selected = OS.GTK_WIDGET_STATE (item) is OS.GTK_STATE_SELECTED;
        auto items = OS.g_list_append (null, item);
        OS.gtk_list_remove_items (listHandle, items);
        OS.g_list_free (items);
        OS.g_list_free (children);
        if (selected) {
            OS.gtk_entry_set_text (entryHandle, "".ptr);
        }
        ignoreSelect = false;
    }
}

/**
 * Removes the items from the receiver's list which are
 * between the given zero-relative start and end
 * indices (inclusive).
 *
 * @param start the start of the range
 * @param end the end of the range
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if either the start or end are not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void remove (int start, int end) {
    checkWidget();
    if (start > end) return;
    if (!(0 <= start && start <= end && end < items.length)) {
        error (SWT.ERROR_INVALID_RANGE);
    }
    String [] oldItems = items;
    String [] newItems = new String[](oldItems.length - (end - start + 1));
    System.arraycopy (oldItems, 0, newItems, 0, start);
    System.arraycopy (oldItems, end + 1, newItems, start, oldItems.length - end - 1);
    items = newItems;
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        int index = OS.gtk_combo_box_get_active (handle);
        if (start <= index && index <= end) clearText();
        for (int i = end; i >= start; i--) {
            OS.gtk_combo_box_remove_text (handle, i);
        }
    } else {
        bool selected = false;
        ignoreSelect = true;
        GList* items;
        auto children = OS.gtk_container_get_children (listHandle);
        for (int i = start; i <= end; i++) {
            auto item = OS.g_list_nth_data (children, i);
            selected |= OS.GTK_WIDGET_STATE (item) is OS.GTK_STATE_SELECTED;
            items = OS.g_list_append (items, item);
        }
        OS.gtk_list_remove_items (listHandle, items);
        OS.g_list_free (items);
        OS.g_list_free (children);
        if (selected) {
            OS.gtk_entry_set_text (entryHandle, "".ptr );
        }
        ignoreSelect = false;
    }
}

/**
 * Searches the receiver's list starting at the first item
 * until an item is found that is equal to the argument,
 * and removes that item from the list.
 *
 * @param string the item to remove
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the string is not found in the list</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void remove (String string) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    int index = indexOf (string, 0);
    if (index is -1) error (SWT.ERROR_INVALID_ARGUMENT);
    remove (index);
}

/**
 * Removes all of the items from the receiver's list and clear the
 * contents of receiver's text field.
 * <p>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void removeAll () {
    checkWidget();
    auto count = items.length;
    items = null;
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        clearText ();
        for (ptrdiff_t i = count - 1; i >= 0; i--) {
            OS.gtk_combo_box_remove_text (handle, cast(int)/*64bit*/i);
        }
    } else {
        ignoreSelect = true;
        OS.gtk_list_clear_items (listHandle, 0, -1);
        OS.gtk_entry_set_text (entryHandle, "".ptr);
        ignoreSelect = false;
    }
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the receiver's text is modified.
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
 * @see ModifyListener
 * @see #addModifyListener
 */
public void removeModifyListener (ModifyListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Modify, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the user changes the receiver's selection.
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

/**
 * Removes the listener from the collection of listeners who will
 * be notified when the control is verified.
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
 * @see VerifyListener
 * @see #addVerifyListener
 *
 * @since 3.1
 */
public void removeVerifyListener (VerifyListener listener) {
    checkWidget ();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.Verify, listener);
}

/**
 * Selects the item at the given zero-relative index in the receiver's
 * list.  If the item at the index was already selected, it remains
 * selected. Indices that are out of range are ignored.
 *
 * @param index the index of the item to select
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void select (int index) {
    checkWidget();
    if (index < 0 || index >= items.length) return;
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
        OS.gtk_combo_box_set_active (handle, index);
        OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
        if ((style & SWT.READ_ONLY) !is 0) {
            /*
            * Feature in GTK. Read Only combo boxes do not get a chance to send out a
            * Modify event in the gtk_changed callback. The fix is to send a Modify event
            * here.
            */
            sendEvent (SWT.Modify);
        }
    } else {
        ignoreSelect = true;
        OS.gtk_list_select_item (listHandle, index);
        ignoreSelect = false;
    }
}

override void setBackgroundColor (GdkColor* color) {
    super.setBackgroundColor (color);
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        if (entryHandle !is null) OS.gtk_widget_modify_base (entryHandle, 0, color);
        OS.g_object_set1 (textRenderer, OS.background_gdk.ptr, cast(int)color);
    } else {
        OS.gtk_widget_modify_base (entryHandle, 0, color);
        if (listHandle !is null) OS.gtk_widget_modify_base (listHandle, 0, color);
    }
}

override int setBounds (int x, int y, int width, int height, bool move, bool resize) {
    int newHeight = height;
    if (resize) newHeight = Math.max (getTextHeight (), height);
    return super.setBounds (x, y, width, newHeight, move, resize);
}

override void setFontDescription (PangoFontDescription* font) {
    super.setFontDescription (font);
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        if (entryHandle !is null) OS.gtk_widget_modify_font (entryHandle, font);
        OS.g_object_set1 (textRenderer, OS.font_desc.ptr, cast(int)font);
        if ((style & SWT.READ_ONLY) !is 0) {
            /*
            * Bug in GTK.  Setting the font can leave the combo box with an
            * invalid minimum size.  The fix is to temporarily change the
            * selected item to force the combo box to resize.
            */
            int index = OS.gtk_combo_box_get_active (handle);
            OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
            OS.gtk_combo_box_set_active (handle, -1);
            OS.gtk_combo_box_set_active (handle, index);
            OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
        }
    } else {
        OS.gtk_widget_modify_font (entryHandle, font);
        if (listHandle !is null) {
            OS.gtk_widget_modify_font (listHandle, font);
            auto itemsList = OS.gtk_container_get_children (listHandle);
            if (itemsList !is null) {
                int count = OS.g_list_length (itemsList);
                for (int i=count - 1; i>=0; i--) {
                    auto widget = OS.gtk_bin_get_child (OS.g_list_nth_data (itemsList, i));
                    OS.gtk_widget_modify_font (widget, font);
                }
                OS.g_list_free (itemsList);
            }
        }
    }
}

override void setForegroundColor (GdkColor* color) {
    super.setForegroundColor (color);
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        if (entryHandle !is null) setForegroundColor (entryHandle, color);
        OS.g_object_set1 (textRenderer, OS.foreground_gdk.ptr, cast(int)color);
    } else {
        setForegroundColor (entryHandle, color);
        if (listHandle !is null) {
            setForegroundColor (listHandle, color);
            auto itemsList = OS.gtk_container_get_children (listHandle);
            if (itemsList !is null) {
                int count = OS.g_list_length (itemsList);
                for (int i=count - 1; i>=0; i--) {
                    auto widget = OS.gtk_bin_get_child (OS.g_list_nth_data (itemsList, i));
                    setForegroundColor (widget, color);
                }
                OS.g_list_free (itemsList);
            }
        }
    }
}

/**
 * Sets the text of the item in the receiver's list at the given
 * zero-relative index to the string argument.
 *
 * @param index the index for the item
 * @param string the new text for the item
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the index is not between 0 and the number of elements in the list minus 1 (inclusive)</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setItem (int index, String string) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (!(0 <= index && index < items.length)) {
        error (SWT.ERROR_INVALID_ARGUMENT);
    }
    items [index] = string;
    char* buffer = string.toStringzValidPtr();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        OS.gtk_combo_box_remove_text (handle, index);
        OS.gtk_combo_box_insert_text (handle, index, buffer);
        if ((style & SWT.RIGHT_TO_LEFT) !is 0 && popupHandle !is null) {
            display.doSetDirectionProc(popupHandle, OS.GTK_TEXT_DIR_RTL);
        }
    } else {
        ignoreSelect = true;
        auto children = OS.gtk_container_get_children (listHandle);
        auto item = OS.g_list_nth_data (children, index);
        auto label = OS.gtk_bin_get_child (item);
        OS.gtk_label_set_text (label, buffer);
        OS.g_list_free (children);
        ignoreSelect = false;
    }
}

/**
 * Sets the receiver's list to be the given array of items.
 *
 * @param items the array of items
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if an item in the items array is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setItems (String [] items) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (items is null) error (SWT.ERROR_NULL_ARGUMENT);
    for (int i=0; i<items.length; i++) {
        if (items [i] is null) error (SWT.ERROR_INVALID_ARGUMENT);
    }
    auto count = this.items.length;
    this.items = new String[](items.length);
    System.arraycopy (items, 0, this.items, 0, items.length);
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        clearText ();
        for (ptrdiff_t i = count - 1; i >= 0; i--) {
            OS.gtk_combo_box_remove_text (handle, cast(int)/*64bit*/i);
        }
        for (ptrdiff_t i = 0; i < items.length; i++) {
            String string = items [i];
            char* buffer = string.toStringzValidPtr();
            OS.gtk_combo_box_insert_text (handle, cast(int)/*64bit*/i, buffer);
            if ((style & SWT.RIGHT_TO_LEFT) !is 0 && popupHandle !is null) {
                display.doSetDirectionProc(popupHandle, OS.GTK_TEXT_DIR_RTL);
            }
        }
    } else {
        lockText = ignoreSelect = true;
        OS.gtk_list_clear_items (listHandle, 0, -1);
        auto font = getFontDescription ();
        GdkColor* color = getForegroundColor ();
        int direction = OS.gtk_widget_get_direction (handle);
        int i = 0;
        while (i < items.length) {
            String string = items [i];
            char * buffer = string.toStringzValidPtr();
            auto item = OS.gtk_list_item_new_with_label (buffer);
            auto label = OS.gtk_bin_get_child (item);
            setForegroundColor (label, color);
            OS.gtk_widget_modify_font (label, font);
            OS.gtk_widget_set_direction (label, direction);
            OS.gtk_container_add (listHandle, item);
            OS.gtk_widget_show (item);
            i++;
        }
        lockText = ignoreSelect = false;
        OS.gtk_entry_set_text (entryHandle, "".ptr);
    }
}

/**
 * Marks the receiver's list as visible if the argument is <code>true</code>,
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
 *
 * @since 3.4
 */
public void setListVisible (bool visible) {
    checkWidget ();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        if (visible) {
            OS.gtk_combo_box_popup (handle);
        } else {
            OS.gtk_combo_box_popdown (handle);
        }
    }
}

override void setOrientation() {
    super.setOrientation();
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        if (listHandle !is null) OS.gtk_widget_set_direction (listHandle, OS.GTK_TEXT_DIR_RTL);
        if (entryHandle !is null) OS.gtk_widget_set_direction (entryHandle, OS.GTK_TEXT_DIR_RTL);
        if (cellHandle !is null) OS.gtk_widget_set_direction (cellHandle, OS.GTK_TEXT_DIR_RTL);
    }
}

/**
 * Sets the orientation of the receiver, which must be one
 * of the constants <code>SWT.LEFT_TO_RIGHT</code> or <code>SWT.RIGHT_TO_LEFT</code>.
 * <p>
 *
 * @param orientation new orientation style
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 2.1.2
 */
public void setOrientation (int orientation) {
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        checkWidget();
        int flags = SWT.RIGHT_TO_LEFT | SWT.LEFT_TO_RIGHT;
        if ((orientation & flags) is 0 || (orientation & flags) is flags) return;
        style &= ~flags;
        style |= orientation & flags;
        int dir = (orientation & SWT.RIGHT_TO_LEFT) !is 0 ? OS.GTK_TEXT_DIR_RTL : OS.GTK_TEXT_DIR_LTR;
        OS.gtk_widget_set_direction (fixedHandle, dir);
        OS.gtk_widget_set_direction (handle, dir);
    	if (entryHandle !is null) OS.gtk_widget_set_direction (entryHandle, dir);
    	if (listHandle !is null) {
            OS.gtk_widget_set_direction (listHandle, dir);
            auto itemsList = OS.gtk_container_get_children (listHandle);
            if (itemsList !is null) {
                int count = OS.g_list_length (itemsList);
                for (int i=count - 1; i>=0; i--) {
                    auto widget = OS.gtk_bin_get_child (OS.g_list_nth_data (itemsList, i));
                    OS.gtk_widget_set_direction (widget, dir);
                }
                OS.g_list_free (itemsList);
            }
        }
        if (cellHandle !is null) OS.gtk_widget_set_direction (cellHandle, dir);
        if (popupHandle !is null) display.doSetDirectionProc (popupHandle, dir);
    }
}

/**
 * Sets the selection in the receiver's text field to the
 * range specified by the argument whose x coordinate is the
 * start of the selection and whose y coordinate is the end
 * of the selection.
 *
 * @param selection a point representing the new selection start and end
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the point is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setSelection (Point selection) {
    checkWidget();
    if (selection is null) error (SWT.ERROR_NULL_ARGUMENT);
    if ((style & SWT.READ_ONLY) !is 0) return;
    if (entryHandle !is null) {
        OS.gtk_editable_set_position (entryHandle, selection.x);
        OS.gtk_editable_select_region (entryHandle, selection.x, selection.y);
    }
}

/**
 * Sets the contents of the receiver's text field to the
 * given string.
 * <p>
 * Note: The text field in a <code>Combo</code> is typically
 * only capable of displaying a single line of text. Thus,
 * setting the text to a string containing line breaks or
 * other special characters will probably cause it to
 * display incorrectly.
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
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if ((style & SWT.READ_ONLY) !is 0) {
        int index = indexOf (string);
        if (index is -1) return;
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
            OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
            OS.gtk_combo_box_set_active (handle, index);
            OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
            /*
            * Feature in GTK. Read Only combo boxes do not get a chance to send out a
            * Modify event in the gtk_changed callback. The fix is to send a Modify event
            * here.
            */
            sendEvent (SWT.Modify);
            return;
        }
    }
    /*
    * Feature in gtk.  When text is set in gtk, separate events are fired for the deletion and
    * insertion of the text.  This is not wrong, but is inconsistent with other platforms.  The
    * fix is to block the firing of these events and fire them ourselves in a consistent manner.
    */
    if (hooks (SWT.Verify) || filters (SWT.Verify)) {
        auto ptr = OS.gtk_entry_get_text (entryHandle);
        string = verifyText (string, 0, cast(int)/*64bit*/OS.g_utf8_strlen (ptr, -1));
        if (string is null) return;
    }
    auto buffer = string.toStringzValidPtr();
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        OS.g_signal_handlers_block_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    }
    OS.g_signal_handlers_block_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    OS.g_signal_handlers_block_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udDELETE_TEXT);
    OS.g_signal_handlers_block_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udINSERT_TEXT);
    OS.gtk_entry_set_text (entryHandle, buffer);
    if (OS.GTK_VERSION >= OS.buildVERSION (2, 4, 0)) {
        OS.g_signal_handlers_unblock_matched (handle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    }
    OS.g_signal_handlers_unblock_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udCHANGED);
    OS.g_signal_handlers_unblock_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udDELETE_TEXT);
    OS.g_signal_handlers_unblock_matched (entryHandle, OS.G_SIGNAL_MATCH_DATA, 0, 0, null, null, udINSERT_TEXT);
    sendEvent (SWT.Modify);
}

/**
 * Sets the maximum number of characters that the receiver's
 * text field is capable of holding to be the argument.
 * <p>
 * To reset this value to the default, use <code>setTextLimit(Combo.LIMIT)</code>.
 * Specifying a limit value larger than <code>Combo.LIMIT</code> sets the
 * receiver's limit to <code>Combo.LIMIT</code>.
 * </p>
 * @param limit new text limit
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_CANNOT_BE_ZERO - if the limit is zero</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #LIMIT
 */
public void setTextLimit (int limit) {
    checkWidget();
    if (limit is 0) error (SWT.ERROR_CANNOT_BE_ZERO);
    if (entryHandle !is null) OS.gtk_entry_set_max_length (entryHandle, limit);
}

override void setToolTipText (Shell shell, String newString) {
    if (entryHandle !is null) shell.setToolTipText (entryHandle, newString);
    if (buttonHandle !is null) shell.setToolTipText (buttonHandle, newString);
}

/**
 * Sets the number of items that are visible in the drop
 * down portion of the receiver's list.
 * <p>
 * Note: This operation is a hint and is not supported on
 * platforms that do not have this concept.
 * </p>
 *
 * @param count the new number of items to be visible
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setVisibleItemCount (int count) {
    checkWidget ();
    if (count < 0) return;
    visibleCount = count;
}

override bool translateTraversal (GdkEventKey* keyEvent) {
    int key = keyEvent.keyval;
    switch (key) {
        case OS.GDK_KP_Enter:
        case OS.GDK_Return: {
            auto imContext = imContext ();
            if (imContext !is null) {
                char* preeditString;
                OS.gtk_im_context_get_preedit_string (imContext, &preeditString, null, null);
                if (preeditString !is null) {
                    auto length = fromStringz(preeditString).length;
                    OS.g_free (preeditString);
                    if (length !is 0) return false;
                }
            }
            break;
        }
        default:
            break;
    }
    return super.translateTraversal (keyEvent);
}

String verifyText (String string, int start, int end) {
    if (string.length is 0 && start is end) return null;
    Event event = new Event ();
    event.text = string;
    event.start = start;
    event.end = end;
    auto eventPtr = OS.gtk_get_current_event ();
    if (eventPtr !is null) {
        GdkEventKey* gdkEvent = cast(GdkEventKey*)eventPtr;
        switch (gdkEvent.type) {
            case OS.GDK_KEY_PRESS:
                setKeyState (event, gdkEvent);
                break;
            default:
        }
        OS.gdk_event_free (eventPtr);
    }
    /*
     * It is possible (but unlikely), that application
     * code could have disposed the widget in the verify
     * event.  If this happens, answer null to cancel
     * the operation.
     */
    sendEvent (SWT.Verify, event);
    if (!event.doit || isDisposed ()) return null;
    return event.text;
}

}
