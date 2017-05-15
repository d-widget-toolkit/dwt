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
module org.eclipse.swt.widgets.TabItem;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.TabFolder;
import org.eclipse.swt.widgets.Control;

import java.lang.all;

/**
 * Instances of this class represent a selectable user interface object
 * corresponding to a tab for a page in a tab folder.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#tabfolder">TabFolder, TabItem snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class TabItem : Item {
    TabFolder parent;
    Control control;
    String toolTipText;

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>TabFolder</code>) and a style value
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
public this (TabFolder parent, int style) {
    super (parent, style);
    this.parent = parent;
    parent.createItem (this, parent.getItemCount ());
}

/**
 * Constructs a new instance of this class given its parent
 * (which must be a <code>TabFolder</code>), a style value
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
 * @see SWT
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (TabFolder parent, int style, int index) {
    super (parent, style);
    this.parent = parent;
    parent.createItem (this, index);
}

void _setText (int index, String string) {
    /*
    * Bug in Windows.  In version 6.00 of COMCTL32.DLL, tab
    * items with an image and a label that includes '&' cause
    * the tab to draw incorrectly (even when doubled '&&').
    * The image overlaps the label.  The fix is to remove
    * all '&' characters from the string.
    */
    if (OS.COMCTL32_MAJOR >= 6 && image !is null) {
        if (string.indexOf ('&') !is -1) {
            int length_ = cast(int)/*64bit*/string.length ;
            char[] text = new char [length_];
            string.getChars ( 0, length_, text, 0);
            int i = 0, j = 0;
            for (i=0; i<length_; i++) {
                if (text[i] !is '&') text [j++] = text [i];
            }
            if (j < i) string = text[ 0 .. j ]._idup();
        }
    }
    auto hwnd = parent.handle;
    auto hHeap = OS.GetProcessHeap ();
    StringT buffer = StrToTCHARs (parent.getCodePage (), string, true);
    auto byteCount = buffer.length  * TCHAR.sizeof;
    auto pszText = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
    OS.MoveMemory (pszText, buffer.ptr, byteCount);
    TCITEM tcItem;
    tcItem.mask = OS.TCIF_TEXT;
    tcItem.pszText = pszText;
    OS.SendMessage (hwnd, OS.TCM_SETITEM, index, &tcItem);
    OS.HeapFree (hHeap, 0, pszText);
}

override protected void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

override void destroyWidget () {
    parent.destroyItem (this);
    releaseHandle ();
}

/**
 * Returns the control that is used to fill the client area of
 * the tab folder when the user selects the tab item.  If no
 * control has been set, return <code>null</code>.
 * <p>
 * @return the control
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Control getControl () {
    checkWidget();
    return control;
}

/**
 * Returns a rectangle describing the receiver's size and location
 * relative to its parent.
 *
 * @return the receiver's bounding rectangle
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.4
 */
public Rectangle getBounds() {
    checkWidget();
    int index = parent.indexOf(this);
    if (index is -1) return new Rectangle (0, 0, 0, 0);
    RECT itemRect;
    OS.SendMessage (parent.handle, OS.TCM_GETITEMRECT, index, &itemRect);
    return new Rectangle(itemRect.left, itemRect.top, itemRect.right - itemRect.left, itemRect.bottom - itemRect.top);
}

/**
 * Returns the receiver's parent, which must be a <code>TabFolder</code>.
 *
 * @return the receiver's parent
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public TabFolder getParent () {
    checkWidget();
    return parent;
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
    checkWidget();
    return toolTipText;
}

override void releaseHandle () {
    super.releaseHandle ();
    parent = null;
}

override void releaseParent () {
    super.releaseParent ();
    int index = parent.indexOf (this);
    if (index is parent.getSelectionIndex ()) {
        if (control !is null) control.setVisible (false);
    }
}

override void releaseWidget () {
    super.releaseWidget ();
    control = null;
}

/**
 * Sets the control that is used to fill the client area of
 * the tab folder when the user selects the tab item.
 * <p>
 * @param control the new control (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the control has been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if the control is not in the same widget tree</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setControl (Control control) {
    checkWidget();
    if (control !is null) {
        if (control.isDisposed()) error (SWT.ERROR_INVALID_ARGUMENT);
        if (control.parent !is parent) error (SWT.ERROR_INVALID_PARENT);
    }
    if (this.control !is null && this.control.isDisposed ()) {
        this.control = null;
    }
    Control oldControl = this.control, newControl = control;
    this.control = control;
    int index = parent.indexOf (this);
    if (index !is parent.getSelectionIndex ()) {
        if (newControl !is null) newControl.setVisible (false);
        return;
    }
    if (newControl !is null) {
        newControl.setBounds (parent.getClientArea ());
        newControl.setVisible (true);
    }
    if (oldControl !is null) oldControl.setVisible (false);
}

override public void setImage (Image image) {
    checkWidget();
    int index = parent.indexOf (this);
    if (index is -1) return;
    super.setImage (image);
    /*
    * Bug in Windows.  In version 6.00 of COMCTL32.DLL, tab
    * items with an image and a label that includes '&' cause
    * the tab to draw incorrectly (even when doubled '&&').
    * The image overlaps the label.  The fix is to remove
    * all '&' characters from the string and set the text
    * whenever the image or text is changed.
    */
    if (OS.COMCTL32_MAJOR >= 6) {
        if (text.indexOf ('&') !is -1) _setText (index, text);
    }
    auto hwnd = parent.handle;
    TCITEM tcItem;
    tcItem.mask = OS.TCIF_IMAGE;
    tcItem.iImage = parent.imageIndex (image);
    OS.SendMessage (hwnd, OS.TCM_SETITEM, index, &tcItem);
}
/**
 * Sets the receiver's text.  The string may include
 * the mnemonic character.
 * </p>
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
 *
 * @param string the new text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 */
override public void setText (String string) {
    checkWidget();
    // SWT extension: allow null string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (string ==/*eq*/text ) return;
    int index = parent.indexOf (this);
    if (index is -1) return;
    super.setText (string);
    _setText (index, string);
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
 */
public void setToolTipText (String string) {
    checkWidget();
    toolTipText = string;
}

}

