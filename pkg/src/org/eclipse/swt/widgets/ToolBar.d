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

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.ImageList;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.ToolItem;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;

import java.lang.all;


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
    alias Composite.setBackgroundImage setBackgroundImage;
    alias Composite.setBounds setBounds;
    alias Composite.windowProc windowProc;

    int lastFocusId;
    ToolItem [] items;
    bool ignoreResize, ignoreMouse;
    ImageList imageList, disabledImageList, hotImageList;
    mixin(gshared!(`private static /+const+/ WNDPROC ToolBarProc;`));
    mixin(gshared!(`static const TCHAR[] ToolBarClass = OS.TOOLBARCLASSNAME;`));

    mixin(gshared!(`private static bool static_this_completed = false;`));
    private static void static_this() {
        if( static_this_completed ){
            return;
        }
        synchronized {
            if( static_this_completed ){
                return;
            }
            WNDCLASS lpWndClass;
            OS.GetClassInfo (null, ToolBarClass.ptr, &lpWndClass);
            ToolBarProc = lpWndClass.lpfnWndProc;
            static_this_completed = true;
        }
    }




    /*
    * From the Windows SDK for TB_SETBUTTONSIZE:
    *
    *   "If an application does not explicitly
    *   set the button size, the size defaults
    *   to 24 by 22 pixels".
    */
    static const int DEFAULT_WIDTH = 24;
    static const int DEFAULT_HEIGHT = 22;

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
    static_this();
    super (parent, checkStyle (style));
    /*
    * Ensure that either of HORIZONTAL or VERTICAL is set.
    * NOTE: HORIZONTAL and VERTICAL have the same values
    * as H_SCROLL and V_SCROLL so it is necessary to first
    * clear these bits to avoid scroll bars and then reset
    * the bits using the original style supplied by the
    * programmer.
    *
    * NOTE: The CCS_VERT style cannot be applied when the
    * widget is created because of this conflict.
    */
    if ((style & SWT.VERTICAL) !is 0) {
        this.style |= SWT.VERTICAL;
        int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        /*
        * Feature in Windows.  When a tool bar has the style
        * TBSTYLE_LIST and has a drop down item, Window leaves
        * too much padding around the button.  This affects
        * every button in the tool bar and makes the preferred
        * height too big.  The fix is to set the TBSTYLE_LIST
        * when the tool bar contains both text and images.
        *
        * NOTE: Tool bars with CCS_VERT must have TBSTYLE_LIST
        * set before any item is added or the tool bar does
        * not lay out properly.  The work around does not run
        * in this case.
        */
        if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
            if ((style & SWT.RIGHT) !is 0) bits |= OS.TBSTYLE_LIST;
        }
        OS.SetWindowLong (handle, OS.GWL_STYLE, bits | OS.CCS_VERT);
    } else {
        this.style |= SWT.HORIZONTAL;
    }
}

override .LRESULT callWindowProc (HWND hwnd, int msg, WPARAM wParam, LPARAM lParam) {
    if (handle is null) return 0;
    /*
    * Bug in Windows.  For some reason, during the processing
    * of WM_SYSCHAR, the tool bar window proc does not call the
    * default window proc causing mnemonics for the menu bar
    * to be ignored.  The fix is to always call the default
    * window proc for WM_SYSCHAR.
    */
    if (msg is OS.WM_SYSCHAR) {
        return OS.DefWindowProc (hwnd, msg, wParam, lParam);
    }
    return OS.CallWindowProc (ToolBarProc, hwnd, msg, wParam, lParam);
}

static int checkStyle (int style) {
    /*
    * On Windows, only flat tool bars can be traversed.
    */
    if ((style & SWT.FLAT) is 0) style |= SWT.NO_FOCUS;

    /*
    * A vertical tool bar cannot wrap because TB_SETROWS
    * fails when the toolbar has TBSTYLE_WRAPABLE.
    */
    if ((style & SWT.VERTICAL) !is 0) style &= ~SWT.WRAP;

    /*
    * Even though it is legal to create this widget
    * with scroll bars, they serve no useful purpose
    * because they do not automatically scroll the
    * widget's client area.  The fix is to clear
    * the SWT style.
    */
    return style & ~(SWT.H_SCROLL | SWT.V_SCROLL);
}

override void checkBuffered () {
    super.checkBuffered ();
    if (OS.COMCTL32_MAJOR >= 6) style |= SWT.DOUBLE_BUFFERED;
}

override protected void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    int width = 0, height = 0;
    if ((style & SWT.VERTICAL) !is 0) {
        RECT rect;
        TBBUTTON lpButton;
        auto count = OS.SendMessage (handle, OS.TB_BUTTONCOUNT, 0, 0);
        for (int i=0; i<count; i++) {
            OS.SendMessage (handle, OS.TB_GETITEMRECT, i, &rect);
            height = Math.max (height, rect.bottom);
            OS.SendMessage (handle, OS.TB_GETBUTTON, i, &lpButton);
            if ((lpButton.fsStyle & OS.BTNS_SEP) !is 0) {
                TBBUTTONINFO info;
                info.cbSize = TBBUTTONINFO.sizeof;
                info.dwMask = OS.TBIF_SIZE;
                OS.SendMessage (handle, OS.TB_GETBUTTONINFO, lpButton.idCommand, &info);
                width = Math.max (width, info.cx);
            } else {
                width = Math.max (width, rect.right);
            }
        }
    } else {
        RECT oldRect;
        OS.GetWindowRect (handle, &oldRect);
        int oldWidth = oldRect.right - oldRect.left;
        int oldHeight = oldRect.bottom - oldRect.top;
        int border = getBorderWidth ();
        int newWidth = wHint is SWT.DEFAULT ? 0x3FFF : wHint + border * 2;
        int newHeight = hHint is SWT.DEFAULT ? 0x3FFF : hHint + border * 2;
        bool redraw = drawCount is 0 && OS.IsWindowVisible (handle);
        ignoreResize = true;
        if (redraw) OS.UpdateWindow (handle);
        int flags = OS.SWP_NOACTIVATE | OS.SWP_NOMOVE | OS.SWP_NOREDRAW | OS.SWP_NOZORDER;
        SetWindowPos (handle, null, 0, 0, newWidth, newHeight, flags);
        auto count = OS.SendMessage (handle, OS.TB_BUTTONCOUNT, 0, 0);
        if (count !is 0) {
            RECT rect;
            OS.SendMessage (handle, OS.TB_GETITEMRECT, count - 1, &rect);
            width = Math.max (width, rect.right);
            height = Math.max (height, rect.bottom);
        }
        SetWindowPos (handle, null, 0, 0, oldWidth, oldHeight, flags);
        if (redraw) OS.ValidateRect (handle, null);
        ignoreResize = false;
    }

    /*
    * From the Windows SDK for TB_SETBUTTONSIZE:
    *
    *   "If an application does not explicitly
    *   set the button size, the size defaults
    *   to 24 by 22 pixels".
    */
    if (width is 0) width = DEFAULT_WIDTH;
    if (height is 0) height = DEFAULT_HEIGHT;
    if (wHint !is SWT.DEFAULT) width = wHint;
    if (hHint !is SWT.DEFAULT) height = hHint;
    Rectangle trim = computeTrim (0, 0, width, height);
    width = trim.width;  height = trim.height;
    return new Point (width, height);
}

override public Rectangle computeTrim (int x, int y, int width, int height) {
    checkWidget ();
    Rectangle trim = super.computeTrim (x, y, width, height);
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    if ((bits & OS.CCS_NODIVIDER) is 0) trim.height += 2;
    return trim;
}

override void createHandle () {
    super.createHandle ();
    state &= ~CANVAS;

    /*
    * Feature in Windows.  When TBSTYLE_FLAT is used to create
    * a flat toolbar, for some reason TBSTYLE_TRANSPARENT is
    * also set.  This causes the toolbar to flicker when it is
    * moved or resized.  The fix is to clear TBSTYLE_TRANSPARENT.
    *
    * NOTE:  This work around is unnecessary on XP.  There is no
    * flickering and clearing the TBSTYLE_TRANSPARENT interferes
    * with the XP theme.
    */
    if ((style & SWT.FLAT) !is 0) {
        if (OS.COMCTL32_MAJOR < 6 || !OS.IsAppThemed ()) {
            int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
            bits &= ~OS.TBSTYLE_TRANSPARENT;
            OS.SetWindowLong (handle, OS.GWL_STYLE, bits);
        }
    }

    /*
    * Feature in Windows.  Despite the fact that the
    * tool tip text contains \r\n, the tooltip will
    * not honour the new line unless TTM_SETMAXTIPWIDTH
    * is set.  The fix is to set TTM_SETMAXTIPWIDTH to
    * a large value.
    */
    /*
    * These lines are intentionally commented.  The tool
    * bar currently sets this value to 300 so it is not
    * necessary to set TTM_SETMAXTIPWIDTH.
    */
//  auto hwndToolTip = OS.SendMessage (handle, OS.TB_GETTOOLTIPS, 0, 0);
//  OS.SendMessage (hwndToolTip, OS.TTM_SETMAXTIPWIDTH, 0, 0x7FFF);

    /*
    * Feature in Windows.  When the control is created,
    * it does not use the default system font.  A new HFONT
    * is created and destroyed when the control is destroyed.
    * This means that a program that queries the font from
    * this control, uses the font in another control and then
    * destroys this control will have the font unexpectedly
    * destroyed in the other control.  The fix is to assign
    * the font ourselves each time the control is created.
    * The control will not destroy a font that it did not
    * create.
    */
    HFONT hFont = OS.GetStockObject (OS.SYSTEM_FONT);
    OS.SendMessage (handle, OS.WM_SETFONT, hFont, 0);

    /* Set the button struct, bitmap and button sizes */
    OS.SendMessage (handle, OS.TB_BUTTONSTRUCTSIZE, TBBUTTON.sizeof, 0);
    OS.SendMessage (handle, OS.TB_SETBITMAPSIZE, 0, 0);
    OS.SendMessage (handle, OS.TB_SETBUTTONSIZE, 0, 0);

    /* Set the extended style bits */
    int bits = OS.TBSTYLE_EX_DRAWDDARROWS | OS.TBSTYLE_EX_MIXEDBUTTONS | OS.TBSTYLE_EX_HIDECLIPPEDBUTTONS;
    if (OS.COMCTL32_MAJOR >= 6) bits |= OS.TBSTYLE_EX_DOUBLEBUFFER;
    OS.SendMessage (handle, OS.TB_SETEXTENDEDSTYLE, 0, bits);
}

void createItem (ToolItem item, int index) {
    auto count = OS.SendMessage (handle, OS.TB_BUTTONCOUNT, 0, 0);
    if (!(0 <= index && index <= count)) error (SWT.ERROR_INVALID_RANGE);
    int id = 0;
    while (id < items.length && items [id] !is null) id++;
    if (id is items.length) {
        ToolItem [] newItems = new ToolItem [items.length + 4];
        System.arraycopy (items, 0, newItems, 0, items.length);
        items = newItems;
    }
    int bits = item.widgetStyle ();
    TBBUTTON lpButton;
    lpButton.idCommand = id;
    lpButton.fsStyle = cast(byte) bits;
    lpButton.fsState = cast(byte) OS.TBSTATE_ENABLED;

    /*
    * Bug in Windows.  Despite the fact that the image list
    * index has never been set for the item, Windows always
    * assumes that the image index for the item is valid.
    * When an item is inserted, the image index is zero.
    * Therefore, when the first image is inserted and is
    * assigned image index zero, every item draws with this
    * image.  The fix is to set the image index to none
    * when the item is created.  This is not necessary in
    * the case when the item has the BTNS_SEP style because
    * separators cannot show images.
    */
    if ((bits & OS.BTNS_SEP) is 0) lpButton.iBitmap = OS.I_IMAGENONE;
    if (OS.SendMessage (handle, OS.TB_INSERTBUTTON, index, &lpButton) is 0) {
        error (SWT.ERROR_ITEM_NOT_ADDED);
    }
    items [item.id = id] = item;
    if ((style & SWT.VERTICAL) !is 0) setRowCount (cast(int)/*64bit*/count + 1);
    layoutItems ();
}

override void createWidget () {
    super.createWidget ();
    items = new ToolItem [4];
    lastFocusId = -1;
}

override int defaultBackground () {
    static if (OS.IsWinCE) return OS.GetSysColor (OS.COLOR_BTNFACE);
    return super.defaultBackground ();
}

void destroyItem (ToolItem item) {
    TBBUTTONINFO info;
    info.cbSize = TBBUTTONINFO.sizeof;
    info.dwMask = OS.TBIF_IMAGE | OS.TBIF_STYLE;
    auto index = OS.SendMessage (handle, OS.TB_GETBUTTONINFO, item.id, &info);
    /*
    * Feature in Windows.  For some reason, a tool item that has
    * the style BTNS_SEP does not return I_IMAGENONE when queried
    * for an image index, despite the fact that no attempt has been
    * made to assign an image to the item.  As a result, operations
    * on an image list that use the wrong index cause random results.
    * The fix is to ensure that the tool item is not a separator
    * before using the image index.  Since separators cannot have
    * an image and one is never assigned, this is not a problem.
    */
    if ((info.fsStyle & OS.BTNS_SEP) is 0 && info.iImage !is OS.I_IMAGENONE) {
        if (imageList !is null) imageList.put (info.iImage, null);
        if (hotImageList !is null) hotImageList.put (info.iImage, null);
        if (disabledImageList !is null) disabledImageList.put (info.iImage, null);
    }
    OS.SendMessage (handle, OS.TB_DELETEBUTTON, index, 0);
    if (item.id is lastFocusId) lastFocusId = -1;
    items [item.id] = null;
    item.id = -1;
    auto count = OS.SendMessage (handle, OS.TB_BUTTONCOUNT, 0, 0);
    if (count is 0) {
        if (imageList !is null) {
            OS.SendMessage (handle, OS.TB_SETIMAGELIST, 0, 0);
            display.releaseToolImageList (imageList);
        }
        if (hotImageList !is null) {
            OS.SendMessage (handle, OS.TB_SETHOTIMAGELIST, 0, 0);
            display.releaseToolHotImageList (hotImageList);
        }
        if (disabledImageList !is null) {
            OS.SendMessage (handle, OS.TB_SETDISABLEDIMAGELIST, 0, 0);
            display.releaseToolDisabledImageList (disabledImageList);
        }
        imageList = hotImageList = disabledImageList = null;
        items = new ToolItem [4];
    }
    if ((style & SWT.VERTICAL) !is 0) setRowCount (cast(int)/*64bit*/count - 1);
    layoutItems ();
}

override void enableWidget (bool enabled) {
    super.enableWidget (enabled);
    /*
    * Bug in Windows.  When a tool item with the style
    * BTNS_CHECK or BTNS_CHECKGROUP is selected and then
    * disabled, the item does not draw using the disabled
    * image.  The fix is to use the disabled image in all
    * image lists for the item.
    *
    * Feature in Windows.  When a tool bar is disabled,
    * the text draws disabled but the images do not.
    * The fix is to use the disabled image in all image
    * lists for all items.
    */
    for (int i=0; i<items.length; i++) {
        ToolItem item = items [i];
        if (item !is null) {
            if ((item.style & SWT.SEPARATOR) is 0) {
                item.updateImages (enabled && item.getEnabled ());
            }
        }
    }
}

ImageList getDisabledImageList () {
    return disabledImageList;
}

ImageList getHotImageList () {
    return hotImageList;
}

ImageList getImageList () {
    return imageList;
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
    checkWidget ();
    auto count = OS.SendMessage (handle, OS.TB_BUTTONCOUNT, 0, 0);
    if (!(0 <= index && index < count)) error (SWT.ERROR_INVALID_RANGE);
    TBBUTTON lpButton;
    auto result = OS.SendMessage (handle, OS.TB_GETBUTTON, index, &lpButton);
    if (result is 0) error (SWT.ERROR_CANNOT_GET_ITEM);
    return items [lpButton.idCommand];
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
    checkWidget ();
    if (point is null) error (SWT.ERROR_NULL_ARGUMENT);
    ToolItem [] items = getItems ();
    for (int i=0; i<items.length; i++) {
        Rectangle rect = items [i].getBounds ();
        if (rect.contains (point)) return items [i];
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
    checkWidget ();
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.TB_BUTTONCOUNT, 0, 0);
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
    checkWidget ();
    auto count = OS.SendMessage (handle, OS.TB_BUTTONCOUNT, 0, 0);
    TBBUTTON lpButton;
    ToolItem [] result = new ToolItem [count];
    for (int i=0; i<count; i++) {
        OS.SendMessage (handle, OS.TB_GETBUTTON, i, &lpButton);
        result [i] = items [lpButton.idCommand];
    }
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
    checkWidget ();
    if ((style & SWT.VERTICAL) !is 0) {
        return cast(int)/*64bit*/OS.SendMessage (handle, OS.TB_BUTTONCOUNT, 0, 0);
    }
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.TB_GETROWS, 0, 0);
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
    checkWidget ();
    if (item is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (item.isDisposed()) error(SWT.ERROR_INVALID_ARGUMENT);
    return cast(int)/*64bit*/OS.SendMessage (handle, OS.TB_COMMANDTOINDEX, item.id, 0);
}

void layoutItems () {
    /*
    * Feature in Windows.  When a tool bar has the style
    * TBSTYLE_LIST and has a drop down item, Window leaves
    * too much padding around the button.  This affects
    * every button in the tool bar and makes the preferred
    * height too big.  The fix is to set the TBSTYLE_LIST
    * when the tool bar contains both text and images.
    *
    * NOTE: Tool bars with CCS_VERT must have TBSTYLE_LIST
    * set before any item is added or the tool bar does
    * not lay out properly.  The work around does not run
    * in this case.
    */
    if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
        if ((style & SWT.RIGHT) !is 0 && (style & SWT.VERTICAL) is 0) {
            bool hasText = false, hasImage = false;
            for (int i=0; i<items.length; i++) {
                ToolItem item = items [i];
                if (item !is null) {
                    if (!hasText) hasText = item.text.length !is 0;
                    if (!hasImage) hasImage = item.image !is null;
                    if (hasText && hasImage) break;
                }
            }
            int oldBits = OS.GetWindowLong (handle, OS.GWL_STYLE), newBits = oldBits;
            if (hasText && hasImage) {
                newBits |= OS.TBSTYLE_LIST;
            } else {
                newBits &= ~OS.TBSTYLE_LIST;
            }
            if (newBits !is oldBits) {
                setDropDownItems (false);
                OS.SetWindowLong (handle, OS.GWL_STYLE, newBits);
                /*
                * Feature in Windows.  For some reason, when the style
                * is changed to TBSTYLE_LIST, Windows does not lay out
                * the tool items.  The fix is to use WM_SETFONT to force
                * the tool bar to redraw and lay out.
                */
                auto hFont = cast(HFONT) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0);
                OS.SendMessage (handle, OS.WM_SETFONT, hFont, 0);
                setDropDownItems (true);
            }
        }
    }

    if ((style & SWT.WRAP) !is 0) {
        OS.SendMessage (handle, OS.TB_AUTOSIZE, 0, 0);
    }
    /*
    *  When the tool bar is vertical, make the width of each button
    *  be the width of the widest button in the tool bar.  Note that
    *  when the tool bar contains a drop down item, it needs to take
    *  into account extra padding.
    */
    if ((style & SWT.VERTICAL) !is 0) {
        TBBUTTONINFO info;
        info.cbSize = TBBUTTONINFO.sizeof;
        info.dwMask = OS.TBIF_SIZE;
        auto size = OS.SendMessage (handle, OS.TB_GETBUTTONSIZE, 0, 0);
        info.cx = cast(short) OS.LOWORD (size);
        int index = 0;
        while (index < items.length) {
            ToolItem item = items [index];
            if (item !is null && (item.style & SWT.DROP_DOWN) !is 0) break;
            index++;
        }
        if (index < items.length) {
            auto padding = OS.SendMessage (handle, OS.TB_GETPADDING, 0, 0);
            info.cx += OS.LOWORD (padding) * 2;
        }
        for (int i=0; i<items.length; i++) {
            ToolItem item = items [i];
            if (item !is null && (item.style & SWT.SEPARATOR) is 0) {
                OS.SendMessage (handle, OS.TB_SETBUTTONINFO, item.id, &info);
            }
        }
    }
    for (int i=0; i<items.length; i++) {
        ToolItem item = items [i];
        if (item !is null) item.resizeControl ();
    }
}

override bool mnemonicHit (wchar ch) {
    int key = Display.wcsToMbcs (ch, 0);
    int id;
    if (OS.SendMessage (handle, OS.TB_MAPACCELERATOR, key, &id) is 0) {
        return false;
    }
    if ((style & SWT.FLAT) !is 0 && !setTabGroupFocus ()) return false;
    auto index = OS.SendMessage (handle, OS.TB_COMMANDTOINDEX, id, 0);
    if (index is -1) return false;
    OS.SendMessage (handle, OS.TB_SETHOTITEM, index, 0);
    items [id].click (false);
    return true;
}

override bool mnemonicMatch (wchar ch) {
    int key = Display.wcsToMbcs (ch, 0);
    int id;
    if (OS.SendMessage (handle, OS.TB_MAPACCELERATOR, key, &id) is 0) {
        return false;
    }
    /*
    * Feature in Windows.  TB_MAPACCELERATOR matches either the mnemonic
    * character or the first character in a tool item.  This behavior is
    * undocumented and unwanted.  The fix is to ensure that the tool item
    * contains a mnemonic when TB_MAPACCELERATOR returns true.
    */
    auto index = OS.SendMessage (handle, OS.TB_COMMANDTOINDEX, id, 0);
    if (index is -1) return false;
    return findMnemonic (items [id].text) !is '\0';
}

override void releaseChildren (bool destroy) {
    if (items !is null) {
        for (int i=0; i<items.length; i++) {
            ToolItem item = items [i];
            if (item !is null && !item.isDisposed ()) {
                item.release (false);
            }
        }
        items = null;
    }
    super.releaseChildren (destroy);
}

override void releaseWidget () {
    super.releaseWidget ();
    if (imageList !is null) {
        OS.SendMessage (handle, OS.TB_SETIMAGELIST, 0, 0);
        display.releaseToolImageList (imageList);
    }
    if (hotImageList !is null) {
        OS.SendMessage (handle, OS.TB_SETHOTIMAGELIST, 0, 0);
        display.releaseToolHotImageList (hotImageList);
    }
    if (disabledImageList !is null) {
        OS.SendMessage (handle, OS.TB_SETDISABLEDIMAGELIST, 0, 0);
        display.releaseToolDisabledImageList (disabledImageList);
    }
    imageList = hotImageList = disabledImageList = null;
}

override void removeControl (Control control) {
    super.removeControl (control);
    for (int i=0; i<items.length; i++) {
        ToolItem item = items [i];
        if (item !is null && item.control is control) {
            item.setControl (null);
        }
    }
}

override void setBackgroundImage (HBITMAP hBitmap) {
    super.setBackgroundImage (hBitmap);
    setBackgroundTransparent (hBitmap !is null);
}

override void setBackgroundPixel (int pixel) {
    super.setBackgroundPixel (pixel);
    setBackgroundTransparent (pixel !is -1);
}

void setBackgroundTransparent (bool transparent) {
    /*
    * Feature in Windows.  When TBSTYLE_TRANSPARENT is set
    * in a tool bar that is drawing a background, images in
    * the image list that include transparency information
    * do not draw correctly.  The fix is to clear and set
    * TBSTYLE_TRANSPARENT depending on the background color.
    *
    * NOTE:  This work around is unnecessary on XP.  The
    * TBSTYLE_TRANSPARENT style is never cleared on that
    * platform.
    */
    if ((style & SWT.FLAT) !is 0) {
        if (OS.COMCTL32_MAJOR < 6 || !OS.IsAppThemed ()) {
            int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
            if (!transparent && findBackgroundControl () is null) {
                bits &= ~OS.TBSTYLE_TRANSPARENT;
            } else {
                bits |= OS.TBSTYLE_TRANSPARENT;
            }
            OS.SetWindowLong (handle, OS.GWL_STYLE, bits);
        }
    }
}

override void setBounds (int x, int y, int width, int height, int flags) {
    /*
    * Feature in Windows.  For some reason, when a tool bar is
    * repositioned more than once using DeferWindowPos () into
    * the same HDWP, the toolbar redraws more than once, defeating
    * the purpose of DeferWindowPos ().  The fix is to end the
    * deferred positioning before the next tool bar is added,
    * ensuring that only one tool bar position is deferred at
    * any given time.
    */
    if (parent.lpwp !is null) {
        if (drawCount is 0 && OS.IsWindowVisible (handle)) {
            parent.setResizeChildren (false);
            parent.setResizeChildren (true);
        }
    }
    super.setBounds (x, y, width, height, flags);
}

override void setDefaultFont () {
    super.setDefaultFont ();
    OS.SendMessage (handle, OS.TB_SETBITMAPSIZE, 0, 0);
    OS.SendMessage (handle, OS.TB_SETBUTTONSIZE, 0, 0);
}

void setDropDownItems (bool set) {
    /*
    * Feature in Windows.  When the first button in a tool bar
    * is a drop down item, Window leaves too much padding around
    * the button.  This affects every button in the tool bar and
    * makes the preferred height too big.  The fix is clear the
    * BTNS_DROPDOWN before Windows lays out the tool bar and set
    * the bit afterwards.
    *
    * NOTE:  This work around only runs when the tool bar contains
    * both text and images.
    */
    if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
        bool hasText = false, hasImage = false;
        for (int i=0; i<items.length; i++) {
            ToolItem item = items [i];
            if (item !is null) {
                if (!hasText) hasText = item.text.length !is 0;
                if (!hasImage) hasImage = item.image !is null;
                if (hasText && hasImage) break;
            }
        }
        if (hasImage && !hasText) {
            for (int i=0; i<items.length; i++) {
                ToolItem item = items [i];
                if (item !is null && (item.style & SWT.DROP_DOWN) !is 0) {
                    TBBUTTONINFO info;
                    info.cbSize = TBBUTTONINFO.sizeof;
                    info.dwMask = OS.TBIF_STYLE;
                    OS.SendMessage (handle, OS.TB_GETBUTTONINFO, item.id, &info);
                    if (set) {
                        info.fsStyle |= OS.BTNS_DROPDOWN;
                    } else {
                        info.fsStyle &= ~OS.BTNS_DROPDOWN;
                    }
                    OS.SendMessage (handle, OS.TB_SETBUTTONINFO, item.id, &info);
                }
            }
        }
    }
}

void setDisabledImageList (ImageList imageList) {
    if (disabledImageList is imageList) return;
    HBITMAP hImageList;
    if ((disabledImageList = imageList) !is null) {
        hImageList = disabledImageList.getHandle ();
    }
    setDropDownItems (false);
    OS.SendMessage (handle, OS.TB_SETDISABLEDIMAGELIST, 0, hImageList);
    setDropDownItems (true);
}

override public void setFont (Font font) {
    checkWidget ();
    setDropDownItems (false);
    super.setFont (font);
    setDropDownItems (true);
    /*
    * Bug in Windows.  When WM_SETFONT is sent to a tool bar
    * that contains only separators, causes the bitmap and button
    * sizes to be set.  The fix is to reset these sizes after the font
    * has been changed when the tool bar contains only separators.
    */
    int index = 0;
    int mask = SWT.PUSH | SWT.CHECK | SWT.RADIO | SWT.DROP_DOWN;
    while (index < items.length) {
        ToolItem item = items [index];
        if (item !is null && (item.style & mask) !is 0) break;
        index++;
    }
    if (index is items.length) {
        OS.SendMessage (handle, OS.TB_SETBITMAPSIZE, 0, 0);
        OS.SendMessage (handle, OS.TB_SETBUTTONSIZE, 0, 0);
    }
    layoutItems ();
}

void setHotImageList (ImageList imageList) {
    if (hotImageList is imageList) return;
    HBITMAP hImageList;
    if ((hotImageList = imageList) !is null) {
        hImageList = hotImageList.getHandle ();
    }
    setDropDownItems (false);
    OS.SendMessage (handle, OS.TB_SETHOTIMAGELIST, 0, hImageList);
    setDropDownItems (true);
}

void setImageList (ImageList imageList) {
    if (this.imageList is imageList) return;
    HBITMAP hImageList;
    if ((this.imageList = imageList) !is null) {
        hImageList = imageList.getHandle ();
    }
    setDropDownItems (false);
    OS.SendMessage (handle, OS.TB_SETIMAGELIST, 0, hImageList);
    setDropDownItems (true);
}

override public bool setParent (Composite parent) {
    checkWidget ();
    if (!super.setParent (parent)) return false;
    OS.SendMessage (handle, OS.TB_SETPARENT, parent.handle, 0);
    return true;
}

override public void setRedraw (bool redraw) {
    checkWidget ();
    setDropDownItems (false);
    super.setRedraw (redraw);
    setDropDownItems (true);
}

void setRowCount (int count) {
    if ((style & SWT.VERTICAL) !is 0) {
        /*
        * Feature in Windows.  When the TB_SETROWS is used to set the
        * number of rows in a tool bar, the tool bar is resized to show
        * the items.  This is unexpected.  The fix is to save and restore
        * the current size of the tool bar.
        */
        RECT rect;
        OS.GetWindowRect (handle, &rect);
        OS.MapWindowPoints (null, parent.handle, cast(POINT*) &rect, 2);
        ignoreResize = true;
        /*
        * Feature in Windows.  When the last button in a tool bar has the
        * style BTNS_SEP and TB_SETROWS is used to set the number of rows
        * in the tool bar, depending on the number of buttons, the toolbar
        * will wrap items with the style BTNS_CHECK, even when the fLarger
        * flags is used to force the number of rows to be larger than the
        * number of items.  The fix is to set the number of rows to be two
        * larger than the actual number of rows in the tool bar.  When items
        * are being added, as long as the number of rows is at least one
        * item larger than the count, the tool bar is laid out properly.
        * When items are being removed, setting the number of rows to be
        * one more than the item count has no effect.  The number of rows
        * is already one more causing TB_SETROWS to do nothing.  Therefore,
        * choosing two instead of one as the row increment fixes both cases.
        */
        count += 2;
        OS.SendMessage (handle, OS.TB_SETROWS, OS.MAKEWPARAM (count, 1), 0);
        int flags = OS.SWP_NOACTIVATE | OS.SWP_NOMOVE | OS.SWP_NOZORDER;
        SetWindowPos (handle, null, 0, 0, rect.right - rect.left, rect.bottom - rect.top, flags);
        ignoreResize = false;
    }
}

override bool setTabItemFocus () {
    int index = 0;
    while (index < items.length) {
        ToolItem item = items [index];
        if (item !is null && (item.style & SWT.SEPARATOR) is 0) {
            if (item.getEnabled ()) break;
        }
        index++;
    }
    if (index is items.length) return false;
    return super.setTabItemFocus ();
}

override String toolTipText (NMTTDISPINFO* hdr) {
    if ((hdr.uFlags & OS.TTF_IDISHWND) !is 0) {
        return null;
    }
    /*
    * Bug in Windows.  On Windows XP, when TB_SETHOTITEM is
    * used to set the hot item, the tool bar control attempts
    * to display the tool tip, even when the cursor is not in
    * the hot item.  The fix is to detect this case and fail to
    * provide the string, causing no tool tip to be displayed.
    */
    if (!hasCursor ()) return ""; //$NON-NLS-1$
    auto index = hdr.hdr.idFrom;
    auto hwndToolTip = cast(HWND) OS.SendMessage (handle, OS.TB_GETTOOLTIPS, 0, 0);
    if (hwndToolTip is hdr.hdr.hwndFrom) {
        /*
        * Bug in Windows. For some reason the reading order
        * in NMTTDISPINFO is sometimes set incorrectly.  The
        * reading order seems to change every time the mouse
        * enters the control from the top edge.  The fix is
        * to explicitly set TTF_RTLREADING.
        */
        if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
            hdr.uFlags |= OS.TTF_RTLREADING;
        } else {
            hdr.uFlags &= ~OS.TTF_RTLREADING;
        }
        if (toolTipText_ !is null) return ""; //$NON-NLS-1$
        if (0 <= index && index < items.length) {
            ToolItem item = items [index];
            if (item !is null) return item.toolTipText;
        }
    }
    return super.toolTipText (hdr);
}

override int widgetStyle () {
    int bits = super.widgetStyle () | OS.CCS_NORESIZE | OS.TBSTYLE_TOOLTIPS | OS.TBSTYLE_CUSTOMERASE;
    if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) bits |= OS.TBSTYLE_TRANSPARENT;
    if ((style & SWT.SHADOW_OUT) is 0) bits |= OS.CCS_NODIVIDER;
    if ((style & SWT.WRAP) !is 0) bits |= OS.TBSTYLE_WRAPABLE;
    if ((style & SWT.FLAT) !is 0) bits |= OS.TBSTYLE_FLAT;
    /*
    * Feature in Windows.  When a tool bar has the style
    * TBSTYLE_LIST and has a drop down item, Window leaves
    * too much padding around the button.  This affects
    * every button in the tool bar and makes the preferred
    * height too big.  The fix is to set the TBSTYLE_LIST
    * when the tool bar contains both text and images.
    *
    * NOTE: Tool bars with CCS_VERT must have TBSTYLE_LIST
    * set before any item is added or the tool bar does
    * not lay out properly.  The work around does not run
    * in this case.
    */
    if (OS.COMCTL32_MAJOR < 6 || !OS.IsAppThemed ()) {
        if ((style & SWT.RIGHT) !is 0) bits |= OS.TBSTYLE_LIST;
    }
    return bits;
}

override String windowClass () {
    return TCHARsToStr(ToolBarClass);
}

override ptrdiff_t windowProc () {
    return cast(ptrdiff_t)ToolBarProc;
}

override LRESULT WM_CAPTURECHANGED (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_CAPTURECHANGED (wParam, lParam);
    if (result !is null) return result;
    /*
    * Bug in Windows.  When the tool bar loses capture while an
    * item is pressed, the item remains pressed.  The fix is
    * unpress all items using TB_SETSTATE and TBSTATE_PRESSED.
    */
    for (int i=0; i<items.length; i++) {
        ToolItem item = items [i];
        if (item !is null) {
            auto fsState = OS.SendMessage (handle, OS.TB_GETSTATE, item.id, 0);
            if ((fsState & OS.TBSTATE_PRESSED) !is 0) {
                fsState &= ~OS.TBSTATE_PRESSED;
                OS.SendMessage (handle, OS.TB_SETSTATE, item.id, fsState);
            }
        }
    }
    return result;
}

override LRESULT WM_CHAR (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_CHAR (wParam, lParam);
    if (result !is null) return result;
    switch (wParam) {
        case ' ':
            auto index = OS.SendMessage (handle, OS.TB_GETHOTITEM, 0, 0);
            if (index !is -1) {
                TBBUTTON lpButton;
                auto code = OS.SendMessage (handle, OS.TB_GETBUTTON, index, &lpButton);
                if (code !is 0) {
                    items [lpButton.idCommand].click (false);
                    return LRESULT.ZERO;
                }
            }
            break;
        default:
            break;
    }
    return result;
}

override LRESULT WM_COMMAND (WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  When the toolbar window
    * proc processes WM_COMMAND, it forwards this
    * message to its parent.  This is done so that
    * children of this control that send this message
    * type to their parent will notify not only
    * this control but also the parent of this control,
    * which is typically the application window and
    * the window that is looking for the message.
    * If the control did not forward the message,
    * applications would have to subclass the control
    * window to see the message. Because the control
    * window is subclassed by SWT, the message
    * is delivered twice, once by SWT and once when
    * the message is forwarded by the window proc.
    * The fix is to avoid calling the window proc
    * for this control.
    */
    LRESULT result = super.WM_COMMAND (wParam, lParam);
    if (result !is null) return result;
    return LRESULT.ZERO;
}

override LRESULT WM_ERASEBKGND (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_ERASEBKGND (wParam, lParam);
    /*
    * Bug in Windows.  For some reason, NM_CUSTOMDRAW with
    * CDDS_PREERASE and CDDS_POSTERASE is never sent for
    * versions of Windows earlier than XP.  The fix is to
    * draw the background in WM_ERASEBKGND;
    */
    if (findBackgroundControl () !is null) {
        if (OS.COMCTL32_MAJOR < 6) {
            drawBackground (cast(HANDLE) wParam);
            return LRESULT.ONE;
        }
    }
    return result;
}

override LRESULT WM_GETDLGCODE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_GETDLGCODE (wParam, lParam);
    /*
    * Return DLGC_BUTTON so that mnemonics will be
    * processed without needing to press the ALT key
    * when the widget has focus.
    */
    if (result !is null) return result;
    return new LRESULT (OS.DLGC_BUTTON);
}

override LRESULT WM_KEYDOWN (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_KEYDOWN (wParam, lParam);
    if (result !is null) return result;
    switch (wParam) {
        case OS.VK_SPACE:
            /*
            * Ensure that the window proc does not process VK_SPACE
            * so that it can be handled in WM_CHAR.  This allows the
            * application the opportunity to cancel the operation.
            */
            return LRESULT.ZERO;
        default:
    }
    return result;
}

override LRESULT WM_KILLFOCUS (WPARAM wParam, LPARAM lParam) {
    auto index = OS.SendMessage (handle, OS.TB_GETHOTITEM, 0, 0);
    TBBUTTON lpButton;
    auto code = OS.SendMessage (handle, OS.TB_GETBUTTON, index, &lpButton);
    if (code !is 0) lastFocusId = lpButton.idCommand;
    return super.WM_KILLFOCUS (wParam, lParam);
}

override LRESULT WM_LBUTTONDOWN (WPARAM wParam, LPARAM lParam) {
    if (ignoreMouse) return null;
    return super.WM_LBUTTONDOWN (wParam, lParam);
}

override LRESULT WM_LBUTTONUP (WPARAM wParam, LPARAM lParam) {
    if (ignoreMouse) return null;
    return super.WM_LBUTTONUP (wParam, lParam);
}

override LRESULT WM_MOUSELEAVE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_MOUSELEAVE (wParam, lParam);
    if (result !is null) return result;
    /*
    * Bug in Windows.  On XP, when a tooltip is
    * hidden due to a time out or mouse press,
    * the tooltip remains active although no
    * longer visible and won't show again until
    * another tooltip becomes active.  If there
    * is only one tooltip in the window,  it will
    * never show again.  The fix is to remove the
    * current tooltip and add it again every time
    * the mouse leaves the control.
    */
    if (OS.COMCTL32_MAJOR >= 6) {
        TOOLINFO lpti;
        lpti.cbSize = OS.TOOLINFO_sizeof;
        auto hwndToolTip = cast(HWND) OS.SendMessage (handle, OS.TB_GETTOOLTIPS, 0, 0);
        if (OS.SendMessage (hwndToolTip, OS.TTM_GETCURRENTTOOL, 0, &lpti) !is 0) {
            if ((lpti.uFlags & OS.TTF_IDISHWND) is 0) {
                OS.SendMessage (hwndToolTip, OS.TTM_DELTOOL, 0, &lpti);
                OS.SendMessage (hwndToolTip, OS.TTM_ADDTOOL, 0, &lpti);
            }
        }
    }
    return result;
}

override LRESULT WM_NOTIFY (WPARAM wParam, LPARAM lParam) {
    /*
    * Feature in Windows.  When the toolbar window
    * proc processes WM_NOTIFY, it forwards this
    * message to its parent.  This is done so that
    * children of this control that send this message
    * type to their parent will notify not only
    * this control but also the parent of this control,
    * which is typically the application window and
    * the window that is looking for the message.
    * If the control did not forward the message,
    * applications would have to subclass the control
    * window to see the message. Because the control
    * window is subclassed by SWT, the message
    * is delivered twice, once by SWT and once when
    * the message is forwarded by the window proc.
    * The fix is to avoid calling the window proc
    * for this control.
    */
    LRESULT result = super.WM_NOTIFY (wParam, lParam);
    if (result !is null) return result;
    return LRESULT.ZERO;
}

override LRESULT WM_SETFOCUS (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SETFOCUS (wParam, lParam);
    if (lastFocusId !is -1 && handle is OS.GetFocus ()) {
        auto index = OS.SendMessage (handle, OS.TB_COMMANDTOINDEX, lastFocusId, 0);
        OS.SendMessage (handle, OS.TB_SETHOTITEM, index, 0);
    }
    return result;
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    if (ignoreResize) {
        auto code = callWindowProc (handle, OS.WM_SIZE, wParam, lParam);
        if (code is 0) return LRESULT.ZERO;
        return new LRESULT (code);
    }
    LRESULT result = super.WM_SIZE (wParam, lParam);
    if (isDisposed ()) return result;
    /*
    * Bug in Windows.  The code in Windows that determines
    * when tool items should wrap seems to use the window
    * bounds rather than the client area.  Unfortunately,
    * tool bars with the style TBSTYLE_EX_HIDECLIPPEDBUTTONS
    * use the client area.  This means that buttons which
    * overlap the border are hidden before they are wrapped.
    * The fix is to compute TBSTYLE_EX_HIDECLIPPEDBUTTONS
    * and set it each time the tool bar is resized.
    */
    if ((style & SWT.BORDER) !is 0 && (style & SWT.WRAP) !is 0) {
        RECT windowRect;
        OS.GetWindowRect (handle, &windowRect);
        int index = 0, border = getBorderWidth () * 2;
        RECT rect;
        auto count = OS.SendMessage (handle, OS.TB_BUTTONCOUNT, 0, 0);
        while (index < count) {
            OS.SendMessage (handle, OS.TB_GETITEMRECT, index, &rect);
            OS.MapWindowPoints (handle, null, cast(POINT*) &rect, 2);
            if (rect.right > windowRect.right - border * 2) break;
            index++;
        }
        auto bits = OS.SendMessage (handle, OS.TB_GETEXTENDEDSTYLE, 0, 0);
        if (index is count) {
            bits |= OS.TBSTYLE_EX_HIDECLIPPEDBUTTONS;
        } else {
            bits &= ~OS.TBSTYLE_EX_HIDECLIPPEDBUTTONS;
        }
        OS.SendMessage (handle, OS.TB_SETEXTENDEDSTYLE, 0, bits);
    }
    layoutItems ();
    return result;
}

override LRESULT WM_WINDOWPOSCHANGING (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_WINDOWPOSCHANGING (wParam, lParam);
    if (result !is null) return result;
    if (ignoreResize) return result;
    /*
    * Bug in Windows.  When a flat tool bar is wrapped,
    * Windows draws a horizontal separator between the
    * rows.  The tool bar does not draw the first or
    * the last two pixels of this separator.  When the
    * toolbar is resized to be bigger, only the new
    * area is drawn and the last two pixels, which are
    * blank are drawn over by separator.  This leaves
    * garbage on the screen.  The fix is to damage the
    * pixels.
    */
    if (drawCount !is 0) return result;
    if ((style & SWT.WRAP) is 0) return result;
    if (!OS.IsWindowVisible (handle)) return result;
    if (OS.SendMessage (handle, OS.TB_GETROWS, 0, 0) is 1) {
        return result;
    }
    WINDOWPOS* lpwp = cast(WINDOWPOS*)lParam;
    //OS.MoveMemory (lpwp, lParam, WINDOWPOS.sizeof);
    if ((lpwp.flags & (OS.SWP_NOSIZE | OS.SWP_NOREDRAW)) !is 0) {
        return result;
    }
    RECT oldRect;
    OS.GetClientRect (handle, &oldRect);
    RECT newRect;
    OS.SetRect (&newRect, 0, 0, lpwp.cx, lpwp.cy);
    OS.SendMessage (handle, OS.WM_NCCALCSIZE, 0, &newRect);
    int oldWidth = oldRect.right - oldRect.left;
    int newWidth = newRect.right - newRect.left;
    if (newWidth > oldWidth) {
        RECT rect;
        int newHeight = newRect.bottom - newRect.top;
        OS.SetRect (&rect, oldWidth - 2, 0, oldWidth, newHeight);
        OS.InvalidateRect (handle, &rect, false);
    }
    return result;
}

override LRESULT wmCommandChild (WPARAM wParam, LPARAM lParam) {
    ToolItem child = items [OS.LOWORD (wParam)];
    if (child is null) return null;
    return child.wmCommandChild (wParam, lParam);
}

override LRESULT wmNotifyChild (NMHDR* hdr, WPARAM wParam, LPARAM lParam) {
    switch (hdr.code) {
        case OS.TBN_DROPDOWN:
            NMTOOLBAR* lpnmtb = cast(NMTOOLBAR*)lParam;
            //OS.MoveMemory (lpnmtb, lParam, NMTOOLBAR.sizeof);
            ToolItem child = items [lpnmtb.iItem];
            if (child !is null) {
                Event event = new Event ();
                event.detail = SWT.ARROW;
                auto index = OS.SendMessage (handle, OS.TB_COMMANDTOINDEX, lpnmtb.iItem, 0);
                RECT rect;
                OS.SendMessage (handle, OS.TB_GETITEMRECT, index, &rect);
                event.x = rect.left;
                event.y = rect.bottom;
                child.postEvent (SWT.Selection, event);
            }
            break;
        case OS.NM_CUSTOMDRAW:
            if (OS.COMCTL32_MAJOR < 6) break;
            /*
            * Bug in Windows.  For some reason, under the XP Silver
            * theme, tool bars continue to draw using the gray color
            * from the default Blue theme.  The fix is to draw the
            * background.
            */
            NMCUSTOMDRAW* nmcd = cast(NMCUSTOMDRAW*)lParam;
            //OS.MoveMemory (nmcd, lParam, NMCUSTOMDRAW.sizeof);
//          if (drawCount !is 0 || !OS.IsWindowVisible (handle)) {
//              if (!OS.IsWinCE && OS.WindowFromDC (nmcd.hdc) is handle) break;
//          }
            switch (nmcd.dwDrawStage) {
                case OS.CDDS_PREERASE: {
                    /*
                    * Bug in Windows.  When a tool bar does not have the style
                    * TBSTYLE_FLAT, the rectangle to be erased in CDDS_PREERASE
                    * is empty.  The fix is to draw the whole client area.
                    */
                    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
                    if ((bits & OS.TBSTYLE_FLAT) is 0) {
                        drawBackground (nmcd.hdc);
                    } else {
                        RECT rect;
                        OS.SetRect (&rect, nmcd.rc.left, nmcd.rc.top, nmcd.rc.right, nmcd.rc.bottom);
                        drawBackground (nmcd.hdc, &rect);
                    }
                    return new LRESULT (OS.CDRF_SKIPDEFAULT);
                }
                default:
            }
            break;
        case OS.TBN_HOTITEMCHANGE:
            static if (!OS.IsWinCE) {
                auto lpnmhi = cast(NMTBHOTITEM*)lParam;
                //OS.MoveMemory (lpnmhi, lParam, NMTBHOTITEM.sizeof);
                switch (lpnmhi.dwFlags) {
                    case OS.HICF_ARROWKEYS:
                        RECT client;
                        OS.GetClientRect (handle, &client);
                        auto index = OS.SendMessage (handle, OS.TB_COMMANDTOINDEX, lpnmhi.idNew, 0);
                        RECT rect;
                        OS.SendMessage (handle, OS.TB_GETITEMRECT, index, &rect);
                        if (rect.right > client.right || rect.bottom > client.bottom) {
                            return LRESULT.ONE;
                        }
                        break;
                    default:
                }
            }
            break;
        default:
    }
    return super.wmNotifyChild (hdr, wParam, lParam);
}

}

