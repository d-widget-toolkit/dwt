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
module org.eclipse.swt.custom.CCombo;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.accessibility.ACC;
import org.eclipse.swt.accessibility.AccessibleAdapter;
import org.eclipse.swt.accessibility.AccessibleControlAdapter;
import org.eclipse.swt.accessibility.AccessibleControlEvent;
import org.eclipse.swt.accessibility.AccessibleEvent;
import org.eclipse.swt.accessibility.AccessibleTextAdapter;
import org.eclipse.swt.accessibility.AccessibleTextEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.VerifyListener;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Layout;
import org.eclipse.swt.widgets.List;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Widget;

import java.lang.all;
import java.nonstandard.UnsafeUtf;

/**
 * The CCombo class represents a selectable user interface object
 * that combines a text field and a list and issues notification
 * when an item is selected from the list.
 * <p>
 * CCombo was written to work around certain limitations in the native
 * combo box. Specifically, on win32, the height of a CCombo can be set;
 * attempts to set the height of a Combo are ignored. CCombo can be used
 * anywhere that having the increased flexibility is more important than
 * getting native L&F, but the decision should not be taken lightly.
 * There is no is no strict requirement that CCombo look or behave
 * the same as the native combo box.
 * </p>
 * <p>
 * Note that although this class is a subclass of <code>Composite</code>,
 * it does not make sense to add children to it, or set a layout on it.
 * </p>
 * <dl>
 * <dt><b>Styles:</b>
 * <dd>BORDER, READ_ONLY, FLAT</dd>
 * <dt><b>Events:</b>
 * <dd>DefaultSelection, Modify, Selection, Verify</dd>
 * </dl>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#ccombo">CCombo snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: CustomControlExample</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class CCombo : Composite {

    alias Composite.computeSize computeSize;

    Text text;
    List list;
    int visibleItemCount = 5;
    Shell popup;
    Button arrow;
    bool hasFocus;
    Listener listener, filter;
    Color foreground, background;
    Font font;

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
 * @param parent a widget which will be the parent of the new instance (cannot be null)
 * @param style the style of widget to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 * </ul>
 *
 * @see SWT#BORDER
 * @see SWT#READ_ONLY
 * @see SWT#FLAT
 * @see Widget#getStyle()
 */
public this (Composite parent, int style) {
    super (parent, style = checkStyle (style));

    int textStyle = SWT.SINGLE;
    if ((style & SWT.READ_ONLY) !is 0) textStyle |= SWT.READ_ONLY;
    if ((style & SWT.FLAT) !is 0) textStyle |= SWT.FLAT;
    text = new Text (this, textStyle);
    int arrowStyle = SWT.ARROW | SWT.DOWN;
    if ((style & SWT.FLAT) !is 0) arrowStyle |= SWT.FLAT;
    arrow = new Button (this, arrowStyle);

    listener = new class() Listener {
        public void handleEvent (Event event) {
            if (popup is event.widget) {
                popupEvent (event);
                return;
            }
            if (text is event.widget) {
                textEvent (event);
                return;
            }
            if (list is event.widget) {
                listEvent (event);
                return;
            }
            if (arrow is event.widget) {
                arrowEvent (event);
                return;
            }
            if (this.outer is event.widget) {
                comboEvent (event);
                return;
            }
            if (getShell () is event.widget) {
                getDisplay().asyncExec(new class() Runnable {
                    public void run() {
                        if (isDisposed()) return;
                        handleFocus (SWT.FocusOut);
                    }
                });
            }
        }
    };
    filter = new class() Listener {
        public void handleEvent(Event event) {
            Shell shell = (cast(Control)event.widget).getShell ();
            if (shell is this.outer.getShell ()) {
                handleFocus (SWT.FocusOut);
            }
        }
    };

    int [] comboEvents = [SWT.Dispose, SWT.FocusIn, SWT.Move, SWT.Resize];
    for (int i=0; i<comboEvents.length; i++) this.addListener (comboEvents [i], listener);

    int [] textEvents = [SWT.DefaultSelection, SWT.KeyDown, SWT.KeyUp, SWT.MenuDetect, SWT.Modify, SWT.MouseDown, SWT.MouseUp, SWT.MouseDoubleClick, SWT.MouseWheel, SWT.Traverse, SWT.FocusIn, SWT.Verify];
    for (int i=0; i<textEvents.length; i++) text.addListener (textEvents [i], listener);

    int [] arrowEvents = [SWT.MouseDown, SWT.MouseUp, SWT.Selection, SWT.FocusIn];
    for (int i=0; i<arrowEvents.length; i++) arrow.addListener (arrowEvents [i], listener);

    createPopup(null, -1);
    initAccessible();
}
static int checkStyle (int style) {
    int mask = SWT.BORDER | SWT.READ_ONLY | SWT.FLAT | SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT;
    return SWT.NO_FOCUS | (style & mask);
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
    //if (string is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    list.add (string);
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
    //if (string is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    list.add (string, index);
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
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Modify, typedListener);
}
/**
 * Adds the listener to the collection of listeners who will
 * be notified when the user changes the receiver's selection, by sending
 * it one of the messages defined in the <code>SelectionListener</code>
 * interface.
 * <p>
 * <code>widgetSelected</code> is called when the combo's list selection changes.
 * <code>widgetDefaultSelected</code> is typically called when ENTER is pressed the combo's text area.
 * </p>
 *
 * @param listener the listener which should be notified when the user changes the receiver's selection
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
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
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
 * @since 3.3
 */
public void addVerifyListener (VerifyListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener (SWT.Verify,typedListener);
}
void arrowEvent (Event event) {
    switch (event.type) {
        case SWT.FocusIn: {
            handleFocus (SWT.FocusIn);
            break;
        }
        case SWT.MouseDown: {
            Event mouseEvent = new Event ();
            mouseEvent.button = event.button;
            mouseEvent.count = event.count;
            mouseEvent.stateMask = event.stateMask;
            mouseEvent.time = event.time;
            mouseEvent.x = event.x; mouseEvent.y = event.y;
            notifyListeners (SWT.MouseDown, mouseEvent);
            event.doit = mouseEvent.doit;
            break;
        }
        case SWT.MouseUp: {
            Event mouseEvent = new Event ();
            mouseEvent.button = event.button;
            mouseEvent.count = event.count;
            mouseEvent.stateMask = event.stateMask;
            mouseEvent.time = event.time;
            mouseEvent.x = event.x; mouseEvent.y = event.y;
            notifyListeners (SWT.MouseUp, mouseEvent);
            event.doit = mouseEvent.doit;
            break;
        }
        case SWT.Selection: {
            text.setFocus();
            dropDown (!isDropped ());
            break;
        }
        default:
    }
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
    checkWidget ();
    text.clearSelection ();
    list.deselectAll ();
}
void comboEvent (Event event) {
    switch (event.type) {
        case SWT.Dispose:
            if (popup !is null && !popup.isDisposed ()) {
                list.removeListener (SWT.Dispose, listener);
                popup.dispose ();
            }
            Shell shell = getShell ();
            shell.removeListener (SWT.Deactivate, listener);
            Display display = getDisplay ();
            display.removeFilter (SWT.FocusIn, filter);
            popup = null;
            text = null;
            list = null;
            arrow = null;
            break;
        case SWT.FocusIn:
            Control focusControl = getDisplay ().getFocusControl ();
            if (focusControl is arrow || focusControl is list) return;
            if (isDropped()) {
                list.setFocus();
            } else {
                text.setFocus();
            }
            break;
        case SWT.Move:
            dropDown (false);
            break;
        case SWT.Resize:
            internalLayout (false);
            break;
        default:
    }
}

public override Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = 0, height = 0;
    String[] items = list.getItems ();
    GC gc = new GC (text);
    int spacer = gc.stringExtent (" ").x; //$NON-NLS-1$
    int textWidth = gc.stringExtent (text.getText ()).x;
    for (int i = 0; i < items.length; i++) {
        textWidth = Math.max (gc.stringExtent (items[i]).x, textWidth);
    }
    gc.dispose ();
    Point textSize = text.computeSize (SWT.DEFAULT, SWT.DEFAULT, changed);
    Point arrowSize = arrow.computeSize (SWT.DEFAULT, SWT.DEFAULT, changed);
    Point listSize = list.computeSize (SWT.DEFAULT, SWT.DEFAULT, changed);
    int borderWidth = getBorderWidth ();

    height = Math.max (textSize.y, arrowSize.y);
    width = Math.max (textWidth + 2*spacer + arrowSize.x + 2*borderWidth, listSize.x);
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    return new Point (width + 2*borderWidth, height + 2*borderWidth);
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
 * @since 3.3
 */
public void copy () {
    checkWidget ();
    text.copy ();
}
void createPopup(String[] items, int selectionIndex) {
    // create shell and list
    popup = new Shell (getShell (), SWT.NO_TRIM | SWT.ON_TOP);
    int style = getStyle ();
    int listStyle = SWT.SINGLE | SWT.V_SCROLL;
    if ((style & SWT.FLAT) !is 0) listStyle |= SWT.FLAT;
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) listStyle |= SWT.RIGHT_TO_LEFT;
    if ((style & SWT.LEFT_TO_RIGHT) !is 0) listStyle |= SWT.LEFT_TO_RIGHT;
    list = new List (popup, listStyle);
    if (font !is null) list.setFont (font);
    if (foreground !is null) list.setForeground (foreground);
    if (background !is null) list.setBackground (background);

    int [] popupEvents = [SWT.Close, SWT.Paint, SWT.Deactivate];
    for (int i=0; i<popupEvents.length; i++) popup.addListener (popupEvents [i], listener);
    int [] listEvents = [SWT.MouseUp, SWT.Selection, SWT.Traverse, SWT.KeyDown, SWT.KeyUp, SWT.FocusIn, SWT.Dispose];
    for (int i=0; i<listEvents.length; i++) list.addListener (listEvents [i], listener);

    if (items !is null) list.setItems (items);
    if (selectionIndex !is -1) list.setSelection (selectionIndex);
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
 * @since 3.3
 */
public void cut () {
    checkWidget ();
    text.cut ();
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
    checkWidget ();
    if (0 <= index && index < list.getItemCount () &&
            index is list.getSelectionIndex() &&
            text.getText().equals(list.getItem(index))) {
        text.setText("");  //$NON-NLS-1$
        list.deselect (index);
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
    checkWidget ();
    text.setText("");  //$NON-NLS-1$
    list.deselectAll ();
}
void dropDown (bool drop) {
    if (drop is isDropped ()) return;
    if (!drop) {
        popup.setVisible (false);
        if (!isDisposed () && isFocusControl()) {
            text.setFocus();
        }
        return;
    }
    if (!isVisible()) return;
    if (getShell() !is popup.getParent ()) {
        String[] items = list.getItems ();
        int selectionIndex = list.getSelectionIndex ();
        list.removeListener (SWT.Dispose, listener);
        popup.dispose();
        popup = null;
        list = null;
        createPopup (items, selectionIndex);
    }

    Point size = getSize ();
    int itemCount = list.getItemCount ();
    itemCount = (itemCount is 0) ? visibleItemCount : Math.min(visibleItemCount, itemCount);
    int itemHeight = list.getItemHeight () * itemCount;
    Point listSize = list.computeSize (SWT.DEFAULT, itemHeight, false);
    list.setBounds (1, 1, Math.max (size.x - 2, listSize.x), listSize.y);

    int index = list.getSelectionIndex ();
    if (index !is -1) list.setTopIndex (index);
    Display display = getDisplay ();
    Rectangle listRect = list.getBounds ();
    Rectangle parentRect = display.map (getParent (), null, getBounds ());
    Point comboSize = getSize ();
    Rectangle displayRect = getMonitor ().getClientArea ();
    int width = Math.max (comboSize.x, listRect.width + 2);
    int height = listRect.height + 2;
    int x = parentRect.x;
    int y = parentRect.y + comboSize.y;
    if (y + height > displayRect.y + displayRect.height) y = parentRect.y - height;
    if (x + width > displayRect.x + displayRect.width) x = displayRect.x + displayRect.width - listRect.width;
    popup.setBounds (x, y, width, height);
    popup.setVisible (true);
    if (isFocusControl()) list.setFocus ();
}
/*
 * Return the lowercase of the first non-'&' character following
 * an '&' character in the given string. If there are no '&'
 * characters in the given string, return '\0'.
 */
dchar _findMnemonic (String str) {
    if (str is null) return '\0';
    int index = 0;
    auto length = str.length;
    do {
        while (index < length && str[index] !is '&') index++;
        if (++index >= length) return '\0';
        if (str[index] !is '&') return Character.toLowerCase( str.dcharAt(index) );
        index++;
    } while (index < length);
    return '\0';
}
/*
 * Return the Label immediately preceding the receiver in the z-order,
 * or null if none.
 */
Label getAssociatedLabel () {
    Control[] siblings = getParent ().getChildren ();
    for (int i = 0; i < siblings.length; i++) {
        if (siblings [i] is this) {
            if (i > 0 && ( null !is cast(Label)siblings [i-1] )) {
                return cast(Label) siblings [i-1];
            }
        }
    }
    return null;
}
public override Control [] getChildren () {
    checkWidget();
    return new Control [0];
}
/**
 * Gets the editable state.
 *
 * @return whether or not the receiver is editable
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public bool getEditable () {
    checkWidget ();
    return text.getEditable();
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
    return list.getItem (index);
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
    checkWidget ();
    return list.getItemCount ();
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
    checkWidget ();
    return list.getItemHeight ();
}
/**
 * Returns an array of <code>String</code>s which are the items
 * in the receiver's list.
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
    checkWidget ();
    return list.getItems ();
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
    return isDropped();
}
public override Menu getMenu() {
    return text.getMenu();
}
/**
 * Returns a <code>Point</code> whose x coordinate is the start
 * of the selection in the receiver's text field, and whose y
 * coordinate is the end of the selection. The returned values
 * are zero-relative. An "empty" selection as indicated by
 * the the x and y coordinates having the same value.
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
    return text.getSelection ();
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
    checkWidget ();
    return list.getSelectionIndex ();
}
public override int getStyle () {
    int style = super.getStyle ();
    style &= ~SWT.READ_ONLY;
    if (!text.getEditable()) style |= SWT.READ_ONLY;
    return style;
}
/**
 * Returns a string containing a copy of the contents of the
 * receiver's text field.
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
    return text.getText ();
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
    checkWidget ();
    return text.getLineHeight ();
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
 */
public int getTextLimit () {
    checkWidget ();
    return text.getTextLimit ();
}
/**
 * Gets the number of items that are visible in the drop
 * down portion of the receiver's list.
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
    return visibleItemCount;
}
void handleFocus (int type) {
    if (isDisposed ()) return;
    switch (type) {
        case SWT.FocusIn: {
            if (hasFocus) return;
            if (getEditable ()) text.selectAll ();
            hasFocus = true;
            Shell shell = getShell ();
            shell.removeListener (SWT.Deactivate, listener);
            shell.addListener (SWT.Deactivate, listener);
            Display display = getDisplay ();
            display.removeFilter (SWT.FocusIn, filter);
            display.addFilter (SWT.FocusIn, filter);
            Event e = new Event ();
            notifyListeners (SWT.FocusIn, e);
            break;
        }
        case SWT.FocusOut: {
            if (!hasFocus) return;
            Control focusControl = getDisplay ().getFocusControl ();
            if (focusControl is arrow || focusControl is list || focusControl is text) return;
            hasFocus = false;
            Shell shell = getShell ();
            shell.removeListener(SWT.Deactivate, listener);
            Display display = getDisplay ();
            display.removeFilter (SWT.FocusIn, filter);
            Event e = new Event ();
            notifyListeners (SWT.FocusOut, e);
            break;
        }
        default:
    }
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
    checkWidget ();
    // SWT extension: allow null for zero length string
    //if (string is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    return list.indexOf (string);
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
    checkWidget ();
    // SWT extension: allow null for zero length string
    //if (string is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    return list.indexOf (string, start);
}

void initAccessible() {
    AccessibleAdapter accessibleAdapter = new class() AccessibleAdapter {
        override
        public void getName (AccessibleEvent e) {
            String name = null;
            Label label = getAssociatedLabel ();
            if (label !is null) {
                name = stripMnemonic (label.getText());
            }
            e.result = name;
        }
        override
        public void getKeyboardShortcut(AccessibleEvent e) {
            String shortcut = null;
            Label label = getAssociatedLabel ();
            if (label !is null) {
                String text = label.getText ();
                if (text !is null) {
                    dchar mnemonic = _findMnemonic (text);
                    if (mnemonic !is '\0') {
                        shortcut = Format( "Alt+{}", mnemonic ); //$NON-NLS-1$
                    }
                }
            }
            e.result = shortcut;
        }
        override
        public void getHelp (AccessibleEvent e) {
            e.result = getToolTipText ();
        }
    };
    getAccessible ().addAccessibleListener (accessibleAdapter);
    text.getAccessible ().addAccessibleListener (accessibleAdapter);
    list.getAccessible ().addAccessibleListener (accessibleAdapter);

    arrow.getAccessible ().addAccessibleListener (new class() AccessibleAdapter {
        override
        public void getName (AccessibleEvent e) {
            e.result = isDropped () ? SWT.getMessage ("SWT_Close") : SWT.getMessage ("SWT_Open"); //$NON-NLS-1$ //$NON-NLS-2$
        }
        override
        public void getKeyboardShortcut (AccessibleEvent e) {
            e.result = "Alt+Down Arrow"; //$NON-NLS-1$
        }
        override
        public void getHelp (AccessibleEvent e) {
            e.result = getToolTipText ();
        }
    });

    getAccessible().addAccessibleTextListener (new class() AccessibleTextAdapter {
        override
        public void getCaretOffset (AccessibleTextEvent e) {
            e.offset = text.getCaretPosition ();
        }
        override
        public void getSelectionRange(AccessibleTextEvent e) {
            Point sel = text.getSelection();
            e.offset = sel.x;
            e.length = sel.y - sel.x;
        }
    });

    getAccessible().addAccessibleControlListener (new class() AccessibleControlAdapter {
        override
        public void getChildAtPoint (AccessibleControlEvent e) {
            Point testPoint = toControl (e.x, e.y);
            if (getBounds ().contains (testPoint)) {
                e.childID = ACC.CHILDID_SELF;
            }
        }

        override
        public void getLocation (AccessibleControlEvent e) {
            Rectangle location = getBounds ();
            Point pt = getParent().toDisplay (location.x, location.y);
            e.x = pt.x;
            e.y = pt.y;
            e.width = location.width;
            e.height = location.height;
        }

        override
        public void getChildCount (AccessibleControlEvent e) {
            e.detail = 0;
        }

        override
        public void getRole (AccessibleControlEvent e) {
            e.detail = ACC.ROLE_COMBOBOX;
        }

        override
        public void getState (AccessibleControlEvent e) {
            e.detail = ACC.STATE_NORMAL;
        }

        override
        public void getValue (AccessibleControlEvent e) {
            e.result = getText ();
        }
    });

    text.getAccessible ().addAccessibleControlListener (new class() AccessibleControlAdapter {
        override
        public void getRole (AccessibleControlEvent e) {
            e.detail = text.getEditable () ? ACC.ROLE_TEXT : ACC.ROLE_LABEL;
        }
    });

    arrow.getAccessible ().addAccessibleControlListener (new class() AccessibleControlAdapter {
        override
        public void getDefaultAction (AccessibleControlEvent e) {
            e.result = isDropped () ? SWT.getMessage ("SWT_Close") : SWT.getMessage ("SWT_Open"); //$NON-NLS-1$ //$NON-NLS-2$
        }
    });
}
bool isDropped () {
    return popup.getVisible ();
}
public override bool isFocusControl () {
    checkWidget();
    if (text.isFocusControl () || arrow.isFocusControl () || list.isFocusControl () || popup.isFocusControl ()) {
        return true;
    }
    return super.isFocusControl ();
}
void internalLayout (bool changed) {
    if (isDropped ()) dropDown (false);
    Rectangle rect = getClientArea ();
    int width = rect.width;
    int height = rect.height;
    Point arrowSize = arrow.computeSize (SWT.DEFAULT, height, changed);
    text.setBounds (0, 0, width - arrowSize.x, height);
    arrow.setBounds (width - arrowSize.x, 0, arrowSize.x, arrowSize.y);
}
void listEvent (Event event) {
    switch (event.type) {
        case SWT.Dispose:
            if (getShell () !is popup.getParent ()) {
                String[] items = list.getItems ();
                int selectionIndex = list.getSelectionIndex ();
                popup = null;
                list = null;
                createPopup (items, selectionIndex);
            }
            break;
        case SWT.FocusIn: {
            handleFocus (SWT.FocusIn);
            break;
        }
        case SWT.MouseUp: {
            if (event.button !is 1) return;
            dropDown (false);
            break;
        }
        case SWT.Selection: {
            int index = list.getSelectionIndex ();
            if (index is -1) return;
            text.setText (list.getItem (index));
            text.selectAll ();
            list.setSelection (index);
            Event e = new Event ();
            e.time = event.time;
            e.stateMask = event.stateMask;
            e.doit = event.doit;
            notifyListeners (SWT.Selection, e);
            event.doit = e.doit;
            break;
        }
        case SWT.Traverse: {
            switch (event.detail) {
                case SWT.TRAVERSE_RETURN:
                case SWT.TRAVERSE_ESCAPE:
                case SWT.TRAVERSE_ARROW_PREVIOUS:
                case SWT.TRAVERSE_ARROW_NEXT:
                    event.doit = false;
                    break;
                case SWT.TRAVERSE_TAB_NEXT:
                case SWT.TRAVERSE_TAB_PREVIOUS:
                    event.doit = text.traverse(event.detail);
                    event.detail = SWT.TRAVERSE_NONE;
                    if (event.doit) dropDown(false);
                    return;
                default:
            }
            Event e = new Event ();
            e.time = event.time;
            e.detail = event.detail;
            e.doit = event.doit;
            e.character = event.character;
            e.keyCode = event.keyCode;
            notifyListeners (SWT.Traverse, e);
            event.doit = e.doit;
            event.detail = e.detail;
            break;
        }
        case SWT.KeyUp: {
            Event e = new Event ();
            e.time = event.time;
            e.character = event.character;
            e.keyCode = event.keyCode;
            e.stateMask = event.stateMask;
            notifyListeners (SWT.KeyUp, e);
            break;
        }
        case SWT.KeyDown: {
            if (event.character is SWT.ESC) {
                // Escape key cancels popup list
                dropDown (false);
            }
            if ((event.stateMask & SWT.ALT) !is 0 && (event.keyCode is SWT.ARROW_UP || event.keyCode is SWT.ARROW_DOWN)) {
                dropDown (false);
            }
            if (event.character is SWT.CR) {
                // Enter causes default selection
                dropDown (false);
                Event e = new Event ();
                e.time = event.time;
                e.stateMask = event.stateMask;
                notifyListeners (SWT.DefaultSelection, e);
            }
            // At this point the widget may have been disposed.
            // If so, do not continue.
            if (isDisposed ()) break;
            Event e = new Event();
            e.time = event.time;
            e.character = event.character;
            e.keyCode = event.keyCode;
            e.stateMask = event.stateMask;
            notifyListeners(SWT.KeyDown, e);
            break;

        }
        default:
    }
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
 * @since 3.3
 */
public void paste () {
    checkWidget ();
    text.paste ();
}
void popupEvent(Event event) {
    switch (event.type) {
        case SWT.Paint:
            // draw black rectangle around list
            Rectangle listRect = list.getBounds();
            Color black = getDisplay().getSystemColor(SWT.COLOR_BLACK);
            event.gc.setForeground(black);
            event.gc.drawRectangle(0, 0, listRect.width + 1, listRect.height + 1);
            break;
        case SWT.Close:
            event.doit = false;
            dropDown (false);
            break;
        case SWT.Deactivate:
            /*
             * Bug in GTK. When the arrow button is pressed the popup control receives a
             * deactivate event and then the arrow button receives a selection event. If
             * we hide the popup in the deactivate event, the selection event will show
             * it again. To prevent the popup from showing again, we will let the selection
             * event of the arrow button hide the popup.
             * In Windows, hiding the popup during the deactivate causes the deactivate
             * to be called twice and the selection event to be disappear.
             */
            if ("carbon" != (SWT.getPlatform())) {
                Point point = arrow.toControl(getDisplay().getCursorLocation());
                Point size = arrow.getSize();
                Rectangle rect = new Rectangle(0, 0, size.x, size.y);
                if (!rect.contains(point)) dropDown (false);
            } else {
                dropDown(false);
            }
            break;
        default:
    }
}
public override void redraw () {
    super.redraw();
    text.redraw();
    arrow.redraw();
    if (popup.isVisible()) list.redraw();
}
public override void redraw (int x, int y, int width, int height, bool all) {
    super.redraw(x, y, width, height, true);
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
    list.remove (index);
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
    list.remove (start, end);
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
    //if (string is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    list.remove (string);
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
    text.setText (""); //$NON-NLS-1$
    list.removeAll ();
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
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    removeListener(SWT.Modify, listener);
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
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    removeListener(SWT.Selection, listener);
    removeListener(SWT.DefaultSelection,listener);
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
 * @since 3.3
 */
public void removeVerifyListener (VerifyListener listener) {
    checkWidget();
    if (listener is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    removeListener(SWT.Verify, listener);
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
    if (index is -1) {
        list.deselectAll ();
        text.setText (""); //$NON-NLS-1$
        return;
    }
    if (0 <= index && index < list.getItemCount()) {
        if (index !is getSelectionIndex()) {
            text.setText (list.getItem (index));
            text.selectAll ();
            list.select (index);
            list.showSelection ();
        }
    }
}
public override void setBackground (Color color) {
    super.setBackground(color);
    background = color;
    if (text !is null) text.setBackground(color);
    if (list !is null) list.setBackground(color);
    if (arrow !is null) arrow.setBackground(color);
}
/**
 * Sets the editable state.
 *
 * @param editable the new editable state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setEditable (bool editable) {
    checkWidget ();
    text.setEditable(editable);
}
public override void setEnabled (bool enabled) {
    super.setEnabled(enabled);
    if (popup !is null) popup.setVisible (false);
    if (text !is null) text.setEnabled(enabled);
    if (arrow !is null) arrow.setEnabled(enabled);
}
public override bool setFocus () {
    checkWidget();
    if (!isEnabled () || !isVisible ()) return false;
    if (isFocusControl ()) return true;
    return text.setFocus ();
}
public override void setFont (Font font) {
    super.setFont (font);
    this.font = font;
    text.setFont (font);
    list.setFont (font);
    internalLayout (true);
}
public override void setForeground (Color color) {
    super.setForeground(color);
    foreground = color;
    if (text !is null) text.setForeground(color);
    if (list !is null) list.setForeground(color);
    if (arrow !is null) arrow.setForeground(color);
}
/**
 * Sets the text of the item in the receiver's list at the given
 * zero-relative index to the string argument. This is equivalent
 * to <code>remove</code>'ing the old item at the index, and then
 * <code>add</code>'ing the new item at that index.
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
    list.setItem (index, string);
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
    checkWidget ();
    list.setItems (items);
    if (!text.getEditable ()) text.setText (""); //$NON-NLS-1$
}
/**
 * Sets the layout which is associated with the receiver to be
 * the argument which may be null.
 * <p>
 * Note: No Layout can be set on this Control because it already
 * manages the size and position of its children.
 * </p>
 *
 * @param layout the receiver's new layout or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public override void setLayout (Layout layout) {
    checkWidget ();
    return;
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
    dropDown(visible);
}
public override void setMenu(Menu menu) {
    text.setMenu(menu);
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
    if (selection is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    text.setSelection (selection.x, selection.y);
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
    //if (string is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    int index = list.indexOf (string);
    if (index is -1) {
        list.deselectAll ();
        text.setText (string);
        return;
    }
    text.setText (string);
    text.selectAll ();
    list.setSelection (index);
    list.showSelection ();
}
/**
 * Sets the maximum number of characters that the receiver's
 * text field is capable of holding to be the argument.
 *
 * @param limit new text limit
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_CANNOT_BE_ZERO - if the limit is zero</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setTextLimit (int limit) {
    checkWidget();
    text.setTextLimit (limit);
}

public override void setToolTipText (String string) {
    checkWidget();
    super.setToolTipText(string);
    arrow.setToolTipText (string);
    text.setToolTipText (string);
}

public override void setVisible (bool visible) {
    super.setVisible(visible);
    /*
     * At this point the widget may have been disposed in a FocusOut event.
     * If so then do not continue.
     */
    if (isDisposed ()) return;
    // TEMPORARY CODE
    if (popup is null || popup.isDisposed ()) return;
    if (!visible) popup.setVisible (false);
}
/**
 * Sets the number of items that are visible in the drop
 * down portion of the receiver's list.
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
    visibleItemCount = count;
}
String stripMnemonic (String string) {
    int index = 0;
    int length_ = cast(int)/*64bit*/string.length;
    do {
        while ((index < length_) && (string[index] !is '&')) index++;
        if (++index >= length_) return string;
        if (string[index] !is '&') {
            return string[0 .. index-1] ~ string[index .. length_];
        }
        index++;
    } while (index < length_);
    return string;
}
void textEvent (Event event) {
    switch (event.type) {
        case SWT.FocusIn: {
            handleFocus (SWT.FocusIn);
            break;
        }
        case SWT.DefaultSelection: {
            dropDown (false);
            Event e = new Event ();
            e.time = event.time;
            e.stateMask = event.stateMask;
            notifyListeners (SWT.DefaultSelection, e);
            break;
        }
        case SWT.KeyDown: {
            Event keyEvent = new Event ();
            keyEvent.time = event.time;
            keyEvent.character = event.character;
            keyEvent.keyCode = event.keyCode;
            keyEvent.stateMask = event.stateMask;
            notifyListeners (SWT.KeyDown, keyEvent);
            if (isDisposed ()) break;
            event.doit = keyEvent.doit;
            if (!event.doit) break;
            if (event.keyCode is SWT.ARROW_UP || event.keyCode is SWT.ARROW_DOWN) {
                event.doit = false;
                if ((event.stateMask & SWT.ALT) !is 0) {
                    bool dropped = isDropped ();
                    text.selectAll ();
                    if (!dropped) setFocus ();
                    dropDown (!dropped);
                    break;
                }

                int oldIndex = getSelectionIndex ();
                if (event.keyCode is SWT.ARROW_UP) {
                    select (Math.max (oldIndex - 1, 0));
                } else {
                    select (Math.min (oldIndex + 1, getItemCount () - 1));
                }
                if (oldIndex !is getSelectionIndex ()) {
                    Event e = new Event();
                    e.time = event.time;
                    e.stateMask = event.stateMask;
                    notifyListeners (SWT.Selection, e);
                }
                if (isDisposed ()) break;
            }

            // Further work : Need to add support for incremental search in
            // pop up list as characters typed in text widget
            break;
        }
        case SWT.KeyUp: {
            Event e = new Event ();
            e.time = event.time;
            e.character = event.character;
            e.keyCode = event.keyCode;
            e.stateMask = event.stateMask;
            notifyListeners (SWT.KeyUp, e);
            event.doit = e.doit;
            break;
        }
        case SWT.MenuDetect: {
            Event e = new Event ();
            e.time = event.time;
            notifyListeners (SWT.MenuDetect, e);
            break;
        }
        case SWT.Modify: {
            list.deselectAll ();
            Event e = new Event ();
            e.time = event.time;
            notifyListeners (SWT.Modify, e);
            break;
        }
        case SWT.MouseDown: {
            Event mouseEvent = new Event ();
            mouseEvent.button = event.button;
            mouseEvent.count = event.count;
            mouseEvent.stateMask = event.stateMask;
            mouseEvent.time = event.time;
            mouseEvent.x = event.x; mouseEvent.y = event.y;
            notifyListeners (SWT.MouseDown, mouseEvent);
            if (isDisposed ()) break;
            event.doit = mouseEvent.doit;
            if (!event.doit) break;
            if (event.button !is 1) return;
            if (text.getEditable ()) return;
            bool dropped = isDropped ();
            text.selectAll ();
            if (!dropped) setFocus ();
            dropDown (!dropped);
            break;
        }
        case SWT.MouseUp: {
            Event mouseEvent = new Event ();
            mouseEvent.button = event.button;
            mouseEvent.count = event.count;
            mouseEvent.stateMask = event.stateMask;
            mouseEvent.time = event.time;
            mouseEvent.x = event.x; mouseEvent.y = event.y;
            notifyListeners (SWT.MouseUp, mouseEvent);
            if (isDisposed ()) break;
            event.doit = mouseEvent.doit;
            if (!event.doit) break;
            if (event.button !is 1) return;
            if (text.getEditable ()) return;
            text.selectAll ();
            break;
        }
        case SWT.MouseDoubleClick: {
            Event mouseEvent = new Event ();
            mouseEvent.button = event.button;
            mouseEvent.count = event.count;
            mouseEvent.stateMask = event.stateMask;
            mouseEvent.time = event.time;
            mouseEvent.x = event.x; mouseEvent.y = event.y;
            notifyListeners (SWT.MouseDoubleClick, mouseEvent);
            break;
        }
        case SWT.MouseWheel: {
            Event keyEvent = new Event ();
            keyEvent.time = event.time;
            keyEvent.keyCode = event.count > 0 ? SWT.ARROW_UP : SWT.ARROW_DOWN;
            keyEvent.stateMask = event.stateMask;
            notifyListeners (SWT.KeyDown, keyEvent);
            if (isDisposed ()) break;
            event.doit = keyEvent.doit;
            if (!event.doit) break;
            if (event.count !is 0) {
                event.doit = false;
                int oldIndex = getSelectionIndex ();
                if (event.count > 0) {
                    select (Math.max (oldIndex - 1, 0));
                } else {
                    select (Math.min (oldIndex + 1, getItemCount () - 1));
                }
                if (oldIndex !is getSelectionIndex ()) {
                    Event e = new Event();
                    e.time = event.time;
                    e.stateMask = event.stateMask;
                    notifyListeners (SWT.Selection, e);
                }
                if (isDisposed ()) break;
            }
            break;
        }
        case SWT.Traverse: {
            switch (event.detail) {
                case SWT.TRAVERSE_ARROW_PREVIOUS:
                case SWT.TRAVERSE_ARROW_NEXT:
                    // The enter causes default selection and
                    // the arrow keys are used to manipulate the list contents so
                    // do not use them for traversal.
                    event.doit = false;
                    break;
                case SWT.TRAVERSE_TAB_PREVIOUS:
                    event.doit = traverse(SWT.TRAVERSE_TAB_PREVIOUS);
                    event.detail = SWT.TRAVERSE_NONE;
                    return;
                default:
            }
            Event e = new Event ();
            e.time = event.time;
            e.detail = event.detail;
            e.doit = event.doit;
            e.character = event.character;
            e.keyCode = event.keyCode;
            notifyListeners (SWT.Traverse, e);
            event.doit = e.doit;
            event.detail = e.detail;
            break;
        }
        case SWT.Verify: {
            Event e = new Event ();
            e.text = event.text;
            e.start = event.start;
            e.end = event.end;
            e.character = event.character;
            e.keyCode = event.keyCode;
            e.stateMask = event.stateMask;
            notifyListeners (SWT.Verify, e);
            event.doit = e.doit;
            break;
        }
        default:
    }
}
}
