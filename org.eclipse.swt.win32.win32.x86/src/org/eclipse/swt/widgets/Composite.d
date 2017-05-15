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
module org.eclipse.swt.widgets.Composite;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.GC;
import org.eclipse.swt.graphics.GCData;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.widgets.Scrollable;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Layout;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Decorations;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.ToolTip;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Widget;

import java.lang.System;
import java.lang.all;

/**
 * Instances of this class are controls which are capable
 * of containing other controls.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>NO_BACKGROUND, NO_FOCUS, NO_MERGE_PAINTS, NO_REDRAW_RESIZE, NO_RADIO_GROUP, EMBEDDED, DOUBLE_BUFFERED</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: The <code>NO_BACKGROUND</code>, <code>NO_FOCUS</code>, <code>NO_MERGE_PAINTS</code>,
 * and <code>NO_REDRAW_RESIZE</code> styles are intended for use with <code>Canvas</code>.
 * They can be used with <code>Composite</code> if you are drawing your own, but their
 * behavior is undefined if they are used with subclasses of <code>Composite</code> other
 * than <code>Canvas</code>.
 * </p><p>
 * Note: The <code>CENTER</code> style, although undefined for composites, has the
 * same value as <code>EMBEDDED</code> (which is used to embed widgets from other
 * widget toolkits into SWT).  On some operating systems (GTK, Motif), this may cause
 * the children of this composite to be obscured.  The <code>EMBEDDED</code> style
 * is for use by other widget toolkits and should normally never be used.
 * </p><p>
 * This class may be subclassed by custom control implementors
 * who are building controls that are constructed from aggregates
 * of other controls.
 * </p>
 *
 * @see Canvas
 * @see <a href="http://www.eclipse.org/swt/snippets/#composite">Composite snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class Composite : Scrollable {

    alias Scrollable.setBounds setBounds;
    alias Scrollable.computeSize computeSize;
    alias Scrollable.translateMnemonic translateMnemonic;

    Layout layout_;
    WINDOWPOS* [] lpwp;
    Control [] tabList;
    int layoutCount, backgroundMode;

/**
 * Prevents uninitialized instances from being created outside the package.
 */
this () {
}

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
 * @see SWT#NO_BACKGROUND
 * @see SWT#NO_FOCUS
 * @see SWT#NO_MERGE_PAINTS
 * @see SWT#NO_REDRAW_RESIZE
 * @see SWT#NO_RADIO_GROUP
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, style);
}

Control [] _getChildren () {
    int count = 0;
    auto hwndChild = OS.GetWindow (handle, OS.GW_CHILD);
    if (hwndChild is null) return new Control [0];
    while (hwndChild !is null) {
        count++;
        hwndChild = OS.GetWindow (hwndChild, OS.GW_HWNDNEXT);
    }
    Control [] children = new Control [count];
    int index = 0;
    hwndChild = OS.GetWindow (handle, OS.GW_CHILD);
    while (hwndChild !is null) {
        Control control = display.getControl (hwndChild);
        if (control !is null && control !is this) {
            children [index++] = control;
        }
        hwndChild = OS.GetWindow (hwndChild, OS.GW_HWNDNEXT);
    }
    if (count is index) return children;
    Control [] newChildren = new Control [index];
    System.arraycopy (children, 0, newChildren, 0, index);
    return newChildren;
}

Control [] _getTabList () {
    if (tabList is null) return tabList;
    int count = 0;
    for (int i=0; i<tabList.length; i++) {
        if (!tabList [i].isDisposed ()) count++;
    }
    if (count is tabList.length) return tabList;
    Control [] newList = new Control [count];
    int index = 0;
    for (int i=0; i<tabList.length; i++) {
        if (!tabList [i].isDisposed ()) {
            newList [index++] = tabList [i];
        }
    }
    tabList = newList;
    return tabList;
}

/**
 * Clears any data that has been cached by a Layout for all widgets that
 * are in the parent hierarchy of the changed control up to and including the
 * receiver.  If an ancestor does not have a layout, it is skipped.
 *
 * @param changed an array of controls that changed state and require a recalculation of size
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the changed array is null any of its controls are null or have been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if any control in changed is not in the widget tree of the receiver</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void changed (Control[] changed) {
    checkWidget ();
    if (changed is null) error (SWT.ERROR_INVALID_ARGUMENT);
    for (int i=0; i<changed.length; i++) {
        Control control = changed [i];
        if (control is null) error (SWT.ERROR_INVALID_ARGUMENT);
        if (control.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
        bool ancestor = false;
        Composite composite = control.parent;
        while (composite !is null) {
            ancestor = composite is this;
            if (ancestor) break;
            composite = composite.parent;
        }
        if (!ancestor) error (SWT.ERROR_INVALID_PARENT);
    }
    for (int i=0; i<changed.length; i++) {
        Control child = changed [i];
        Composite composite = child.parent;
        while (child !is this) {
            if (composite.layout_ is null || !composite.layout_.flushCache (child)) {
                composite.state |= LAYOUT_CHANGED;
            }
            child = composite;
            composite = child.parent;
        }
    }
}

override void checkBuffered () {
    if (OS.IsWinCE || (state & CANVAS) is 0) {
        super.checkBuffered ();
    }
}

override void checkComposited () {
    if ((state & CANVAS) !is 0) {
        if ((style & SWT.TRANSPARENT) !is 0) {
            auto hwndParent = parent.handle;
            int bits = OS.GetWindowLong (hwndParent, OS.GWL_EXSTYLE);
            bits |= OS.WS_EX_COMPOSITED;
            OS.SetWindowLong (hwndParent, OS.GWL_EXSTYLE, bits);
        }
    }
}

override protected void checkSubclass () {
    /* Do nothing - Subclassing is allowed */
}

override Control [] computeTabList () {
    Control[] result = super.computeTabList ();
    if (result.length is 0) return result;
    Control [] list = tabList !is null ? _getTabList () : _getChildren ();
    for (int i=0; i<list.length; i++) {
        Control child = list [i];
        Control [] childList = child.computeTabList ();
        if (childList.length !is 0) {
            Control [] newResult = new Control [result.length + childList.length];
            System.arraycopy (result, 0, newResult, 0, result.length);
            System.arraycopy (childList, 0, newResult, result.length, childList.length);
            result = newResult;
        }
    }
    return result;
}

override public Point computeSize (int wHint, int hHint, bool changed) {
    checkWidget ();
    Point size;
    if (layout_ !is null) {
        if (wHint is SWT.DEFAULT || hHint is SWT.DEFAULT) {
            changed |= (state & LAYOUT_CHANGED) !is 0;
            state &= ~LAYOUT_CHANGED;
            size = layout_.computeSize (this, wHint, hHint, changed);
        } else {
            size = new Point (wHint, hHint);
        }
    } else {
        size = minimumSize (wHint, hHint, changed);
    }
    if (size.x is 0) size.x = DEFAULT_WIDTH;
    if (size.y is 0) size.y = DEFAULT_HEIGHT;
    if (wHint !is SWT.DEFAULT) size.x = wHint;
    if (hHint !is SWT.DEFAULT) size.y = hHint;
    Rectangle trim = computeTrim (0, 0, size.x, size.y);
    return new Point (trim.width, trim.height);
}

/**
 * Copies a rectangular area of the receiver at the specified
 * position using the gc.
 *
 * @param gc the gc where the rectangle is to be filled
 * @param x the x coordinate of the rectangle to be filled
 * @param y the y coordinate of the rectangle to be filled
 * @param width the width of the rectangle to be filled
 * @param height the height of the rectangle to be filled
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the gc is null</li>
 *    <li>ERROR_INVALID_ARGUMENT - if the gc has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
/*public*/ void copyArea (GC gc, int x, int y, int width, int height) {
    checkWidget ();
    if (gc is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (gc.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);

    //XP only, no GDI+
    //#define PW_CLIENTONLY 0x00000001
    //DCOrg() wrong
    //topHandle wrong for Tree?
    auto hDC = gc.handle;
    int nSavedDC = OS.SaveDC (hDC);
    OS.IntersectClipRect (hDC, 0, 0, width, height);

    //WRONG PARENT
    POINT lpPoint;
    auto hwndParent = OS.GetParent (handle);
    OS.MapWindowPoints (handle, hwndParent, &lpPoint, 1);
    RECT rect;
    OS.GetWindowRect (handle, &rect);
    POINT lpPoint1, lpPoint2;
    x = x + (lpPoint.x - rect.left);
    y = y + (lpPoint.y - rect.top);
    OS.SetWindowOrgEx (hDC, x, y, &lpPoint1);
    OS.SetBrushOrgEx (hDC, x, y, &lpPoint2);
    int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
    if ((bits & OS.WS_VISIBLE) is 0) {
        OS.DefWindowProc (handle, OS.WM_SETREDRAW, 1, 0);
    }
    //NECESSARY?
    OS.RedrawWindow (handle, null, null, OS.RDW_UPDATENOW | OS.RDW_ALLCHILDREN);
    OS.PrintWindow (handle, hDC, 0);//0x00000001);
    if ((bits & OS.WS_VISIBLE) is 0) {
        OS.DefWindowProc(handle, OS.WM_SETREDRAW, 0, 0);
    }
    OS.RestoreDC (hDC, nSavedDC);
}

override void createHandle () {
    super.createHandle ();
    state |= CANVAS;
    if ((style & (SWT.H_SCROLL | SWT.V_SCROLL)) is 0) {
        state |= THEME_BACKGROUND;
    }
    if ((style & SWT.TRANSPARENT) !is 0) {
        int bits = OS.GetWindowLong (handle, OS.GWL_EXSTYLE);
        bits |= OS.WS_EX_TRANSPARENT;
        OS.SetWindowLong (handle, OS.GWL_EXSTYLE, bits);
    }
}

Composite findDeferredControl () {
    return layoutCount > 0 ? this : parent.findDeferredControl ();
}

override Menu [] findMenus (Control control) {
    if (control is this) return new Menu [0];
    Menu[] result = super.findMenus (control);
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        Menu [] menuList = child.findMenus (control);
        if (menuList.length !is 0) {
            Menu [] newResult = new Menu [result.length + menuList.length];
            System.arraycopy (result, 0, newResult, 0, result.length);
            System.arraycopy (menuList, 0, newResult, result.length, menuList.length);
            result = newResult;
        }
    }
    return result;
}

override void fixChildren (Shell newShell, Shell oldShell, Decorations newDecorations, Decorations oldDecorations, Menu [] menus) {
    super.fixChildren (newShell, oldShell, newDecorations, oldDecorations, menus);
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        children [i].fixChildren (newShell, oldShell, newDecorations, oldDecorations, menus);
    }
}

void fixTabList (Control control) {
    if (tabList is null) return;
    int count = 0;
    for (int i=0; i<tabList.length; i++) {
        if (tabList [i] is control) count++;
    }
    if (count is 0) return;
    Control [] newList = null;
    int length = cast(int)/*64bit*/tabList.length - count;
    if (length !is 0) {
        newList = new Control [length];
        int index = 0;
        for (int i=0; i<tabList.length; i++) {
            if (tabList [i] !is control) {
                newList [index++] = tabList [i];
            }
        }
    }
    tabList = newList;
}

/**
 * Returns the receiver's background drawing mode. This
 * will be one of the following constants defined in class
 * <code>SWT</code>:
 * <code>INHERIT_NONE</code>, <code>INHERIT_DEFAULT</code>,
 * <code>INHERTIT_FORCE</code>.
 *
 * @return the background mode
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SWT
 *
 * @since 3.2
 */
public int getBackgroundMode () {
    checkWidget ();
    return backgroundMode;
}

/**
 * Returns a (possibly empty) array containing the receiver's children.
 * Children are returned in the order that they are drawn.  The topmost
 * control appears at the beginning of the array.  Subsequent controls
 * draw beneath this control and appear later in the array.
 * <p>
 * Note: This is not the actual structure used by the receiver
 * to maintain its list of children, so modifying the array will
 * not affect the receiver.
 * </p>
 *
 * @return an array of children
 *
 * @see Control#moveAbove
 * @see Control#moveBelow
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Control [] getChildren () {
    checkWidget ();
    return _getChildren ();
}

int getChildrenCount () {
    /*
    * NOTE: The current implementation will count
    * non-registered children.
    */
    int count = 0;
    auto hwndChild = OS.GetWindow (handle, OS.GW_CHILD);
    while (hwndChild !is null) {
        count++;
        hwndChild = OS.GetWindow (hwndChild, OS.GW_HWNDNEXT);
    }
    return count;
}

/**
 * Returns layout which is associated with the receiver, or
 * null if one has not been set.
 *
 * @return the receiver's layout or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Layout getLayout () {
    checkWidget ();
    return layout_;
}

/**
 * Gets the (possibly empty) tabbing order for the control.
 *
 * @return tabList the ordered list of controls representing the tab order
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setTabList
 */
public Control [] getTabList () {
    checkWidget ();
    Control [] tabList = _getTabList ();
    if (tabList is null) {
        int count = 0;
        Control [] list =_getChildren ();
        for (int i=0; i<list.length; i++) {
            if (list [i].isTabGroup ()) count++;
        }
        tabList = new Control [count];
        int index = 0;
        for (int i=0; i<list.length; i++) {
            if (list [i].isTabGroup ()) {
                tabList [index++] = list [i];
            }
        }
    }
    return tabList;
}

bool hooksKeys () {
    return hooks (SWT.KeyDown) || hooks (SWT.KeyUp);
}

/**
 * Returns <code>true</code> if the receiver has deferred
 * the performing of layout, and <code>false</code> otherwise.
 *
 * @return the receiver's deferred layout state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setLayoutDeferred(bool)
 * @see #isLayoutDeferred()
 *
 * @since 3.1
 */
public bool getLayoutDeferred () {
    checkWidget ();
    return layoutCount > 0 ;
}

/**
 * Returns <code>true</code> if the receiver or any ancestor
 * up to and including the receiver's nearest ancestor shell
 * has deferred the performing of layouts.  Otherwise, <code>false</code>
 * is returned.
 *
 * @return the receiver's deferred layout state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setLayoutDeferred(bool)
 * @see #getLayoutDeferred()
 *
 * @since 3.1
 */
public bool isLayoutDeferred () {
    checkWidget ();
    return findDeferredControl () !is null;
}

/**
 * If the receiver has a layout, asks the layout to <em>lay out</em>
 * (that is, set the size and location of) the receiver's children.
 * If the receiver does not have a layout, do nothing.
 * <p>
 * This is equivalent to calling <code>layout(true)</code>.
 * </p>
 * <p>
 * Note: Layout is different from painting. If a child is
 * moved or resized such that an area in the parent is
 * exposed, then the parent will paint. If no child is
 * affected, the parent will not paint.
 * </p>
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void layout () {
    checkWidget ();
    layout (true);
}

/**
 * If the receiver has a layout, asks the layout to <em>lay out</em>
 * (that is, set the size and location of) the receiver's children.
 * If the argument is <code>true</code> the layout must not rely
 * on any information it has cached about the immediate children. If it
 * is <code>false</code> the layout may (potentially) optimize the
 * work it is doing by assuming that none of the receiver's
 * children has changed state since the last layout.
 * If the receiver does not have a layout, do nothing.
 * <p>
 * If a child is resized as a result of a call to layout, the
 * resize event will invoke the layout of the child.  The layout
 * will cascade down through all child widgets in the receiver's widget
 * tree until a child is encountered that does not resize.  Note that
 * a layout due to a resize will not flush any cached information
 * (same as <code>layout(false)</code>).
 * </p>
 * <p>
 * Note: Layout is different from painting. If a child is
 * moved or resized such that an area in the parent is
 * exposed, then the parent will paint. If no child is
 * affected, the parent will not paint.
 * </p>
 *
 * @param changed <code>true</code> if the layout must flush its caches, and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void layout (bool changed) {
    checkWidget ();
    if (layout_ is null) return;
    layout (changed, false);
}

/**
 * If the receiver has a layout, asks the layout to <em>lay out</em>
 * (that is, set the size and location of) the receiver's children.
 * If the changed argument is <code>true</code> the layout must not rely
 * on any information it has cached about its children. If it
 * is <code>false</code> the layout may (potentially) optimize the
 * work it is doing by assuming that none of the receiver's
 * children has changed state since the last layout.
 * If the all argument is <code>true</code> the layout will cascade down
 * through all child widgets in the receiver's widget tree, regardless of
 * whether the child has changed size.  The changed argument is applied to
 * all layouts.  If the all argument is <code>false</code>, the layout will
 * <em>not</em> cascade down through all child widgets in the receiver's widget
 * tree.  However, if a child is resized as a result of a call to layout, the
 * resize event will invoke the layout of the child.  Note that
 * a layout due to a resize will not flush any cached information
 * (same as <code>layout(false)</code>).
 * </p>
 * <p>
 * Note: Layout is different from painting. If a child is
 * moved or resized such that an area in the parent is
 * exposed, then the parent will paint. If no child is
 * affected, the parent will not paint.
 * </p>
 *
 * @param changed <code>true</code> if the layout must flush its caches, and <code>false</code> otherwise
 * @param all <code>true</code> if all children in the receiver's widget tree should be laid out, and <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void layout (bool changed, bool all) {
    checkWidget ();
    if (layout_ is null && !all) return;
    markLayout (changed, all);
    updateLayout (true, all);
}

/**
 * Forces a lay out (that is, sets the size and location) of all widgets that
 * are in the parent hierarchy of the changed control up to and including the
 * receiver.  The layouts in the hierarchy must not rely on any information
 * cached about the changed control or any of its ancestors.  The layout may
 * (potentially) optimize the work it is doing by assuming that none of the
 * peers of the changed control have changed state since the last layout.
 * If an ancestor does not have a layout, skip it.
 * <p>
 * Note: Layout is different from painting. If a child is
 * moved or resized such that an area in the parent is
 * exposed, then the parent will paint. If no child is
 * affected, the parent will not paint.
 * </p>
 *
 * @param changed a control that has had a state change which requires a recalculation of its size
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the changed array is null any of its controls are null or have been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if any control in changed is not in the widget tree of the receiver</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.1
 */
public void layout (Control [] changed) {
    checkWidget ();
    if (changed is null) error (SWT.ERROR_INVALID_ARGUMENT);
    for (int i=0; i<changed.length; i++) {
        Control control = changed [i];
        if (control is null) error (SWT.ERROR_INVALID_ARGUMENT);
        if (control.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
        bool ancestor = false;
        Composite composite = control.parent;
        while (composite !is null) {
            ancestor = composite is this;
            if (ancestor) break;
            composite = composite.parent;
        }
        if (!ancestor) error (SWT.ERROR_INVALID_PARENT);
    }
    int updateCount = 0;
    Composite [] update = new Composite [16];
    for (int i=0; i<changed.length; i++) {
        Control child = changed [i];
        Composite composite = child.parent;
        while (child !is this) {
            if (composite.layout_ !is null) {
                composite.state |= LAYOUT_NEEDED;
                if (!composite.layout_.flushCache (child)) {
                    composite.state |= LAYOUT_CHANGED;
                }
            }
            if (updateCount is update.length) {
                Composite [] newUpdate = new Composite [update.length + 16];
                System.arraycopy (update, 0, newUpdate, 0, update.length);
                update = newUpdate;
            }
            child = update [updateCount++] = composite;
            composite = child.parent;
        }
    }
    for (int i=updateCount-1; i>=0; i--) {
        update [i].updateLayout (true, false);
    }
}

override void markLayout (bool changed, bool all) {
    if (layout_ !is null) {
        state |= LAYOUT_NEEDED;
        if (changed) state |= LAYOUT_CHANGED;
    }
    if (all) {
        Control [] children = _getChildren ();
        for (int i=0; i<children.length; i++) {
            children [i].markLayout (changed, all);
        }
    }
}

Point minimumSize (int wHint, int hHint, bool changed) {
    Control [] children = _getChildren ();
    int width = 0, height = 0;
    for (int i=0; i<children.length; i++) {
        Rectangle rect = children [i].getBounds ();
        width = Math.max (width, rect.x + rect.width);
        height = Math.max (height, rect.y + rect.height);
    }
    return new Point (width, height);
}

override bool redrawChildren () {
    if (!super.redrawChildren ()) return false;
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        children [i].redrawChildren ();
    }
    return true;
}

override void releaseParent () {
    super.releaseParent ();
    if ((state & CANVAS) !is 0) {
        if ((style & SWT.TRANSPARENT) !is 0) {
            auto hwndParent = parent.handle;
            auto hwndChild = OS.GetWindow (hwndParent, OS.GW_CHILD);
            while (hwndChild !is null) {
                if (hwndChild !is handle) {
                    int bits = OS.GetWindowLong (hwndParent, OS.GWL_EXSTYLE);
                    if ((bits & OS.WS_EX_TRANSPARENT) !is 0) return;
                }
                hwndChild = OS.GetWindow (hwndChild, OS.GW_HWNDNEXT);
            }
            int bits = OS.GetWindowLong (hwndParent, OS.GWL_EXSTYLE);
            bits &= ~OS.WS_EX_COMPOSITED;
            OS.SetWindowLong (hwndParent, OS.GWL_EXSTYLE, bits);
        }
    }
}

override void releaseChildren (bool destroy) {
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        if (child !is null && !child.isDisposed ()) {
            child.release (false);
        }
    }
    super.releaseChildren (destroy);
}

override void releaseWidget () {
    super.releaseWidget ();
    if ((state & CANVAS) !is 0 && (style & SWT.EMBEDDED) !is 0) {
        auto hwndChild = OS.GetWindow (handle, OS.GW_CHILD);
        if (hwndChild !is null) {
            int threadId = OS.GetWindowThreadProcessId (hwndChild, null);
            if (threadId !is OS.GetCurrentThreadId ()) {
                OS.ShowWindow (hwndChild, OS.SW_HIDE);
                OS.SetParent (hwndChild, null);
            }
        }
    }
    layout_ = null;
    tabList = null;
    lpwp = null;
}

void removeControl (Control control) {
    fixTabList (control);
    resizeChildren ();
}

void resizeChildren () {
    if (lpwp is null) return;
    do {
        WINDOWPOS* [] currentLpwp = lpwp;
        lpwp = null;
        if (!resizeChildren (true, currentLpwp)) {
            resizeChildren (false, currentLpwp);
        }
    } while (lpwp !is null);
}

bool resizeChildren (bool defer, WINDOWPOS* [] pwp) {
    if (pwp is null) return true;
    HDWP hdwp;
    if (defer) {
        hdwp = OS.BeginDeferWindowPos (cast(int)/*64bit*/pwp.length);
        if (hdwp is null) return false;
    }
    for (int i=0; i<pwp.length; i++) {
        WINDOWPOS* wp = pwp [i];
        if (wp !is null) {
            /*
            * This code is intentionally commented.  All widgets that
            * are created by SWT have WS_CLIPSIBLINGS to ensure that
            * application code does not draw outside of the control.
            */
//          int count = parent.getChildrenCount ();
//          if (count > 1) {
//              int bits = OS.GetWindowLong (handle, OS.GWL_STYLE);
//              if ((bits & OS.WS_CLIPSIBLINGS) is 0) wp.flags |= OS.SWP_NOCOPYBITS;
//          }
            if (defer) {
                hdwp = DeferWindowPos (hdwp, wp._hwnd, null, wp.x, wp.y, wp.cx, wp.cy, wp.flags);
                if (hdwp is null) return false;
            } else {
                SetWindowPos (wp._hwnd, null, wp.x, wp.y, wp.cx, wp.cy, wp.flags);
            }
        }
    }
    if (defer) return cast(bool)OS.EndDeferWindowPos (hdwp);
    return true;
}

void resizeEmbeddedHandle(HANDLE embeddedHandle, int width, int height) {
    if (embeddedHandle is null) return;
    uint processID;
    int threadId = OS.GetWindowThreadProcessId (embeddedHandle, &processID);
    if (threadId !is OS.GetCurrentThreadId ()) {
        if (processID is OS.GetCurrentProcessId ()) {
            if (display.msgHook is null) {
                static if (!OS.IsWinCE) {
                    //display.getMsgCallback = new Callback (display, "getMsgProc", 3);
                    //display.getMsgProc = display.getMsgCallback.getAddress ();
                    //if (display.getMsgProc is 0) error (SWT.ERROR_NO_MORE_CALLBACKS);
                    display.msgHook = OS.SetWindowsHookEx (OS.WH_GETMESSAGE, &Display.getMsgFunc, OS.GetLibraryHandle(), threadId);
                    OS.PostThreadMessage (threadId, OS.WM_NULL, 0, 0);
                }
            }
        }
        int flags = OS.SWP_NOZORDER | OS.SWP_DRAWFRAME | OS.SWP_NOACTIVATE | OS.SWP_ASYNCWINDOWPOS;
        OS.SetWindowPos (embeddedHandle, null, 0, 0, width, height, flags);
    }
}

override void sendResize () {
    setResizeChildren (false);
    super.sendResize ();
    if (isDisposed ()) return;
    if (layout_ !is null) {
        markLayout (false, false);
        updateLayout (false, false);
    }
    setResizeChildren (true);
}

/**
 * Sets the background drawing mode to the argument which should
 * be one of the following constants defined in class <code>SWT</code>:
 * <code>INHERIT_NONE</code>, <code>INHERIT_DEFAULT</code>,
 * <code>INHERIT_FORCE</code>.
 *
 * @param mode the new background mode
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see SWT
 *
 * @since 3.2
 */
public void setBackgroundMode (int mode) {
    checkWidget ();
    backgroundMode = mode;
    Control [] children = _getChildren ();
    for (int i = 0; i < children.length; i++) {
        children [i].updateBackgroundMode ();
    }
}

override void setBounds (int x, int y, int width, int height, int flags, bool defer) {
    if (display.resizeCount > Display.RESIZE_LIMIT) {
        defer = false;
    }
    if (!defer && (state & CANVAS) !is 0) {
        state &= ~(RESIZE_OCCURRED | MOVE_OCCURRED);
        state |= RESIZE_DEFERRED | MOVE_DEFERRED;
    }
    super.setBounds (x, y, width, height, flags, defer);
    if (!defer && (state & CANVAS) !is 0) {
        bool wasMoved = (state & MOVE_OCCURRED) !is 0;
        bool wasResized = (state & RESIZE_OCCURRED) !is 0;
        state &= ~(RESIZE_DEFERRED | MOVE_DEFERRED);
        if (wasMoved && !isDisposed ()) sendMove ();
        if (wasResized && !isDisposed ()) sendResize ();
    }
}

override bool setFixedFocus () {
    checkWidget ();
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        if (child.setRadioFocus ()) return true;
    }
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        if (child.setFixedFocus ()) return true;
    }
    return super.setFixedFocus ();
}

override public bool setFocus () {
    checkWidget ();
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        if (child.setRadioFocus ()) return true;
    }
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        if (child.setFocus ()) return true;
    }
    return super.setFocus ();
}

/**
 * Sets the layout which is associated with the receiver to be
 * the argument which may be null.
 *
 * @param layout the receiver's new layout or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setLayout (Layout layout_) {
    checkWidget ();
    this.layout_ = layout_;
}

/**
 * If the argument is <code>true</code>, causes subsequent layout
 * operations in the receiver or any of its children to be ignored.
 * No layout of any kind can occur in the receiver or any of its
 * children until the flag is set to false.
 * Layout operations that occurred while the flag was
 * <code>true</code> are remembered and when the flag is set to
 * <code>false</code>, the layout operations are performed in an
 * optimized manner.  Nested calls to this method are stacked.
 *
 * @param defer the new defer state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #layout(bool)
 * @see #layout(Control[])
 *
 * @since 3.1
 */
public void setLayoutDeferred (bool defer) {
    if (!defer) {
        if (--layoutCount is 0) {
            if ((state & LAYOUT_CHILD) !is 0 || (state & LAYOUT_NEEDED) !is 0) {
                updateLayout (true, true);
            }
        }
    } else {
        layoutCount++;
    }
}
/**
 * Sets the tabbing order for the specified controls to
 * match the order that they occur in the argument list.
 *
 * @param tabList the ordered list of controls representing the tab order or null
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if a widget in the tabList is null or has been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if widget in the tabList is not in the same widget tree</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setTabList (Control [] tabList) {
    checkWidget ();
    if (tabList !is null) {
        for (int i=0; i<tabList.length; i++) {
            Control control = tabList [i];
            if (control is null) error (SWT.ERROR_INVALID_ARGUMENT);
            if (control.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
            if (control.parent !is this) error (SWT.ERROR_INVALID_PARENT);
        }
        Control [] newList = new Control [tabList.length];
        System.arraycopy (tabList, 0, newList, 0, tabList.length);
        tabList = newList;
    }
    this.tabList = tabList;
}

void setResizeChildren (bool resize) {
    if (resize) {
        resizeChildren ();
    } else {
        if (display.resizeCount > Display.RESIZE_LIMIT) {
            return;
        }
        int count = getChildrenCount ();
        if (count > 1 && lpwp is null) {
            lpwp = new WINDOWPOS* [count];
        }
    }
}

override bool setTabGroupFocus () {
    if (isTabItem ()) return setTabItemFocus ();
    bool takeFocus = (style & SWT.NO_FOCUS) is 0;
    if ((state & CANVAS) !is 0) {
        takeFocus = hooksKeys ();
        if ((style & SWT.EMBEDDED) !is 0) takeFocus = true;
    }
    if (takeFocus && setTabItemFocus ()) return true;
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        if (child.isTabItem () && child.setRadioFocus ()) return true;
    }
    for (int i=0; i<children.length; i++) {
        Control child = children [i];
        if (child.isTabItem () && !child.isTabGroup () && child.setTabItemFocus ()) {
            return true;
        }
    }
    return false;
}

String toolTipText (NMTTDISPINFO* hdr) {
    Shell shell = getShell ();
    if ((hdr.uFlags & OS.TTF_IDISHWND) is 0) {
        String string = null;
        ToolTip toolTip = shell.findToolTip (hdr.hdr.idFrom);
        if (toolTip !is null) {
            string = toolTip.message;
            if (string is null || string.length is 0) string = " ";
        }
        return string;
    }
    shell.setToolTipTitle (hdr.hdr.hwndFrom, null, null);
    OS.SendMessage (hdr.hdr.hwndFrom, OS.TTM_SETMAXTIPWIDTH, 0, 0x7FFF);
    Control control = display.getControl ( cast(HANDLE) hdr.hdr.idFrom);
    return control !is null ? control.toolTipText_ : null;
}

override bool translateMnemonic (Event event, Control control) {
    if (super.translateMnemonic (event, control)) return true;
    if (control !is null) {
        Control [] children = _getChildren ();
        for (int i=0; i<children.length; i++) {
            Control child = children [i];
            if (child.translateMnemonic (event, control)) return true;
        }
    }
    return false;
}

override bool translateTraversal (MSG* msg) {
    if ((state & CANVAS) !is 0 ) {
        if ((style & SWT.EMBEDDED) !is 0) return false;
        switch (msg.wParam) {
            case OS.VK_UP:
            case OS.VK_LEFT:
            case OS.VK_DOWN:
            case OS.VK_RIGHT:
            case OS.VK_PRIOR:
            case OS.VK_NEXT:
                auto uiState = OS.SendMessage (msg.hwnd, OS.WM_QUERYUISTATE, 0, 0);
                if ((uiState & OS.UISF_HIDEFOCUS) !is 0) {
                    OS.SendMessage (msg.hwnd, OS.WM_UPDATEUISTATE, OS.MAKEWPARAM (OS.UIS_CLEAR, OS.UISF_HIDEFOCUS), 0);
                }
                break;
            default:
        }
    }
    return super.translateTraversal (msg);
}

override void updateBackgroundColor () {
    super.updateBackgroundColor ();
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        if ((children [i].state & PARENT_BACKGROUND) !is 0) {
            children [i].updateBackgroundColor ();
        }
    }
}

override void updateBackgroundImage () {
    super.updateBackgroundImage ();
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        if ((children [i].state & PARENT_BACKGROUND) !is 0) {
            children [i].updateBackgroundImage ();
        }
    }
}

override void updateBackgroundMode () {
    super.updateBackgroundMode ();
    Control [] children = _getChildren ();
    for (int i = 0; i < children.length; i++) {
        children [i].updateBackgroundMode ();
    }
}

override void updateFont (Font oldFont, Font newFont) {
    super.updateFont (oldFont, newFont);
    Control [] children = _getChildren ();
    for (int i=0; i<children.length; i++) {
        Control control = children [i];
        if (!control.isDisposed ()) {
            control.updateFont (oldFont, newFont);
        }
    }
}

override void updateLayout (bool resize, bool all) {
    Composite parent = findDeferredControl ();
    if (parent !is null) {
        parent.state |= LAYOUT_CHILD;
        return;
    }
    if ((state & LAYOUT_NEEDED) !is 0) {
        bool changed = (state & LAYOUT_CHANGED) !is 0;
        state &= ~(LAYOUT_NEEDED | LAYOUT_CHANGED);
        if (resize) setResizeChildren (false);
        layout_.layout (this, changed);
        if (resize) setResizeChildren (true);
    }
    if (all) {
        state &= ~LAYOUT_CHILD;
        Control [] children = _getChildren ();
        for (int i=0; i<children.length; i++) {
            children [i].updateLayout (resize, all);
        }
    }
}

void updateUIState () {
    HWND hwndShell = getShell ().handle;
    auto uiState = OS.SendMessage (hwndShell, OS.WM_QUERYUISTATE, 0, 0);
    if ((uiState & OS.UISF_HIDEFOCUS) !is 0) {
        OS.SendMessage (hwndShell, OS.WM_CHANGEUISTATE, OS.MAKEWPARAM (OS.UIS_CLEAR, OS.UISF_HIDEFOCUS), 0);
    }
}

override int widgetStyle () {
    /* Force clipping of children by setting WS_CLIPCHILDREN */
    return super.widgetStyle () | OS.WS_CLIPCHILDREN;
}

override LRESULT WM_ERASEBKGND (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_ERASEBKGND (wParam, lParam);
    if (result !is null) return result;
    if ((state & CANVAS) !is 0) {
        /* Return zero to indicate that the background was not erased */
        if ((style & (SWT.NO_BACKGROUND | SWT.TRANSPARENT)) !is 0) {
            return LRESULT.ZERO;
        }
    }
    return result;
}

override LRESULT WM_GETDLGCODE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_GETDLGCODE (wParam, lParam);
    if (result !is null) return result;
    if ((state & CANVAS) !is 0) {
        int flags = 0;
        if (hooksKeys ()) {
            flags |= OS.DLGC_WANTALLKEYS | OS.DLGC_WANTARROWS | OS.DLGC_WANTTAB;
        }
        if ((style & SWT.NO_FOCUS) !is 0) flags |= OS.DLGC_STATIC;
        if (OS.GetWindow (handle, OS.GW_CHILD) !is null) flags |= OS.DLGC_STATIC;
        if (flags !is 0) return new LRESULT (flags);
    }
    return result;
}

override LRESULT WM_GETFONT (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_GETFONT (wParam, lParam);
    if (result !is null) return result;
    auto code = callWindowProc (handle, OS.WM_GETFONT, wParam, lParam);
    if (code !is 0) return new LRESULT (code);
    return new LRESULT (font !is null ? font.handle : defaultFont ());
}

override LRESULT WM_LBUTTONDOWN (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_LBUTTONDOWN (wParam, lParam);
    if (result is LRESULT.ZERO) return result;

    /* Set focus for a canvas with no children */
    if ((state & CANVAS) !is 0) {
        if ((style & SWT.NO_FOCUS) is 0 && hooksKeys ()) {
            if (OS.GetWindow (handle, OS.GW_CHILD) is null) setFocus ();
        }
    }
    return result;
}

override LRESULT WM_NCHITTEST (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_NCHITTEST (wParam, lParam);
    if (result !is null) return result;
    /*
    * Bug in Windows.  For some reason, under circumstances
    * that are not understood, when one scrolled window is
    * embedded in another and the outer window scrolls the
    * inner horizontally by moving the location of the inner
    * one, the vertical scroll bars of the inner window no
    * longer function.  Specifically, WM_NCHITTEST returns
    * HTCLIENT instead of HTVSCROLL.  The fix is to detect
    * the case where the result of WM_NCHITTEST is HTCLIENT
    * and the point is not in the client area, and redraw
    * the trim, which somehow fixes the next WM_NCHITTEST.
    */
    if (!OS.IsWinCE && OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
        if ((state & CANVAS)!is 0) {
            auto code = callWindowProc (handle, OS.WM_NCHITTEST, wParam, lParam);
            if (code is OS.HTCLIENT) {
                RECT rect;
                OS.GetClientRect (handle, &rect);
                POINT pt;
                pt.x = OS.GET_X_LPARAM (lParam);
                pt.y = OS.GET_Y_LPARAM (lParam);
                OS.MapWindowPoints (null, handle, &pt, 1);
                if (!OS.PtInRect (&rect, pt)) {
                    int flags = OS.RDW_FRAME | OS.RDW_INVALIDATE;
                    OS.RedrawWindow (handle, null, null, flags);
                }
            }
            return new LRESULT (code);
        }
    }
    return result;
}

override LRESULT WM_PARENTNOTIFY (WPARAM wParam, LPARAM lParam) {
    if ((state & CANVAS) !is 0 && (style & SWT.EMBEDDED) !is 0) {
        if (OS.LOWORD (wParam) is OS.WM_CREATE) {
            RECT rect;
            OS.GetClientRect (handle, &rect);
            resizeEmbeddedHandle ( cast(HANDLE)lParam, rect.right - rect.left, rect.bottom - rect.top);
        }
    }
    return super.WM_PARENTNOTIFY (wParam, lParam);
}

override LRESULT WM_PAINT (WPARAM wParam, LPARAM lParam) {
    if ((state & CANVAS) is 0 || (state & FOREIGN_HANDLE) !is 0) {
        return super.WM_PAINT (wParam, lParam);
    }

    /* Set the clipping bits */
    int oldBits = 0, newBits = 0;
    static if (!OS.IsWinCE) {
        oldBits = OS.GetWindowLong (handle, OS.GWL_STYLE);
        newBits = oldBits | OS.WS_CLIPSIBLINGS | OS.WS_CLIPCHILDREN;
        if (newBits !is oldBits) OS.SetWindowLong (handle, OS.GWL_STYLE, newBits);
    }

    /* Paint the control and the background */
    PAINTSTRUCT ps;
    if (hooks (SWT.Paint)) {

        /* Use the buffered paint when possible */
        bool bufferedPaint = false;
        if ((style & SWT.DOUBLE_BUFFERED) !is 0) {
            if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
                if ((style & (SWT.NO_MERGE_PAINTS | SWT.RIGHT_TO_LEFT)) is 0) {
                    if ((style & SWT.TRANSPARENT) is 0) bufferedPaint = true;
                }
            }
        }
        if (bufferedPaint) {
            auto hDC = OS.BeginPaint (handle, &ps);
            int width = ps.rcPaint.right - ps.rcPaint.left;
            int height = ps.rcPaint.bottom - ps.rcPaint.top;
            if (width !is 0 && height !is 0) {
                HDC phdc;
                int flags = OS.BPBF_COMPATIBLEBITMAP;
                RECT prcTarget;
                OS.SetRect (&prcTarget, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right, ps.rcPaint.bottom);
                auto hBufferedPaint = OS.BeginBufferedPaint (hDC, &prcTarget, flags, null, &phdc);
                GCData data = new GCData ();
                data.device = display;
                data.foreground = getForegroundPixel ();
                Control control = findBackgroundControl ();
                if (control is null) control = this;
                data.background = control.getBackgroundPixel ();
                data.font = Font.win32_new(display, cast(HANDLE) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0));
                data.uiState = cast(int)/*64bit*/OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
                if ((style & SWT.NO_BACKGROUND) !is 0) {
                    /* This code is intentionally commented because it may be slow to copy bits from the screen */
                    //paintGC.copyArea (image, ps.left, ps.top);
                } else {
                    RECT rect;
                    OS.SetRect (&rect, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right, ps.rcPaint.bottom);
                    drawBackground (phdc, &rect);
                }
                GC gc = GC.win32_new (phdc, data);
                Event event = new Event ();
                event.gc = gc;
                event.x = ps.rcPaint.left;
                event.y = ps.rcPaint.top;
                event.width = width;
                event.height = height;
                sendEvent (SWT.Paint, event);
                if (data.focusDrawn && !isDisposed ()) updateUIState ();
                gc.dispose ();
                OS.EndBufferedPaint (hBufferedPaint, true);
            }
            OS.EndPaint (handle, &ps);
        } else {

            /* Create the paint GC */
            GCData data = new GCData ();
            data.ps = &ps;
            data.hwnd = handle;
            GC gc = GC.win32_new (this, data);

            /* Get the system region for the paint HDC */
            HRGN sysRgn;
            if ((style & (SWT.DOUBLE_BUFFERED | SWT.TRANSPARENT)) !is 0 || (style & SWT.NO_MERGE_PAINTS) !is 0) {
                sysRgn = OS.CreateRectRgn (0, 0, 0, 0);
                if (OS.GetRandomRgn (gc.handle, sysRgn, OS.SYSRGN) is 1) {
                    if (OS.WIN32_VERSION >= OS.VERSION (4, 10)) {
                        if ((OS.GetLayout (gc.handle) & OS.LAYOUT_RTL) !is 0) {
                            int nBytes = OS.GetRegionData (sysRgn, 0, null);
                            int [] lpRgnData = new int [nBytes / 4];
                            OS.GetRegionData (sysRgn, nBytes, cast(RGNDATA*)lpRgnData.ptr);
                            HRGN newSysRgn = OS.ExtCreateRegion ( cast(XFORM*) [-1.0f, 0, 0, 1, 0, 0].ptr, nBytes, cast(RGNDATA*)lpRgnData.ptr);
                            OS.DeleteObject (sysRgn);
                            sysRgn = newSysRgn;
                        }
                    }
                    if (OS.IsWinNT) {
                        POINT pt;
                        OS.MapWindowPoints (null, handle, &pt, 1);
                        OS.OffsetRgn (sysRgn, pt.x, pt.y);
                    }
                }
            }

            /* Send the paint event */
            int width = ps.rcPaint.right - ps.rcPaint.left;
            int height = ps.rcPaint.bottom - ps.rcPaint.top;
            if (width !is 0 && height !is 0) {
                GC paintGC = null;
                Image image = null;
                if ((style & (SWT.DOUBLE_BUFFERED | SWT.TRANSPARENT)) !is 0) {
                    image = new Image (display, width, height);
                    paintGC = gc;
                    gc = new GC (image, paintGC.getStyle() & SWT.RIGHT_TO_LEFT);
                    GCData gcData = gc.getGCData ();
                    gcData.uiState = data.uiState;
                    gc.setForeground (getForeground ());
                    gc.setBackground (getBackground ());
                    gc.setFont (getFont ());
                    if ((style & SWT.TRANSPARENT) !is 0) {
                        OS.BitBlt (gc.handle, 0, 0, width, height, paintGC.handle, ps.rcPaint.left, ps.rcPaint.top, OS.SRCCOPY);
                    }
                    OS.OffsetRgn (sysRgn, -ps.rcPaint.left, -ps.rcPaint.top);
                    OS.SelectClipRgn (gc.handle, sysRgn);
                    OS.OffsetRgn (sysRgn, ps.rcPaint.left, ps.rcPaint.top);
                    OS.SetMetaRgn (gc.handle);
                    OS.SetWindowOrgEx (gc.handle, ps.rcPaint.left, ps.rcPaint.top, null);
                    OS.SetBrushOrgEx (gc.handle, ps.rcPaint.left, ps.rcPaint.top, null);
                    if ((style & (SWT.NO_BACKGROUND | SWT.TRANSPARENT)) !is 0) {
                        /* This code is intentionally commented because it may be slow to copy bits from the screen */
                        //paintGC.copyArea (image, ps.left, ps.top);
                    } else {
                        RECT rect;
                        OS.SetRect (&rect, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right, ps.rcPaint.bottom);
                        drawBackground (gc.handle, &rect);
                    }
                }
                Event event = new Event ();
                event.gc = gc;
                RECT rect;
                if ((style & SWT.NO_MERGE_PAINTS) !is 0 && OS.GetRgnBox (sysRgn, &rect) is OS.COMPLEXREGION) {
                    int nBytes = OS.GetRegionData (sysRgn, 0, null);
                    int [] lpRgnData = new int [nBytes / 4];
                    OS.GetRegionData (sysRgn, nBytes, cast(RGNDATA*)lpRgnData.ptr);
                    int count = lpRgnData [2];
                    for (int i=0; i<count; i++) {
                        int offset = 8 + (i << 2);
                        OS.SetRect (&rect, lpRgnData [offset], lpRgnData [offset + 1], lpRgnData [offset + 2], lpRgnData [offset + 3]);
                        if ((style & (SWT.DOUBLE_BUFFERED | SWT.NO_BACKGROUND | SWT.TRANSPARENT)) is 0) {
                            drawBackground (gc.handle, &rect);
                        }
                        event.x = rect.left;
                        event.y = rect.top;
                        event.width = rect.right - rect.left;
                        event.height = rect.bottom - rect.top;
                        event.count = count - 1 - i;
                        sendEvent (SWT.Paint, event);
                    }
                } else {
                    if ((style & (SWT.DOUBLE_BUFFERED | SWT.NO_BACKGROUND | SWT.TRANSPARENT)) is 0) {
                        OS.SetRect (&rect, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right, ps.rcPaint.bottom);
                        drawBackground (gc.handle, &rect);
                    }
                    event.x = ps.rcPaint.left;
                    event.y = ps.rcPaint.top;
                    event.width = width;
                    event.height = height;
                    sendEvent (SWT.Paint, event);
                }
                // widget could be disposed at this point
                event.gc = null;
                if ((style & (SWT.DOUBLE_BUFFERED | SWT.TRANSPARENT)) !is 0) {
                    if (!gc.isDisposed ()) {
                        GCData gcData = gc.getGCData ();
                        if (gcData.focusDrawn && !isDisposed ()) updateUIState ();
                    }
                    gc.dispose();
                    if (!isDisposed ()) paintGC.drawImage (image, ps.rcPaint.left, ps.rcPaint.top);
                    image.dispose ();
                    gc = paintGC;
                }
            }
            if (sysRgn !is null) OS.DeleteObject (sysRgn);
            if (data.focusDrawn && !isDisposed ()) updateUIState ();

            /* Dispose the paint GC */
            gc.dispose ();
        }
    } else {
        auto hDC = OS.BeginPaint (handle, &ps);
        if ((style & (SWT.NO_BACKGROUND | SWT.TRANSPARENT)) is 0) {
            RECT rect;
            OS.SetRect (&rect, ps.rcPaint.left, ps.rcPaint.top, ps.rcPaint.right, ps.rcPaint.bottom);
            drawBackground (hDC, &rect);
        }
        OS.EndPaint (handle, &ps);
    }

    /* Restore the clipping bits */
    if (!OS.IsWinCE && !isDisposed ()) {
        if (newBits !is oldBits) {
            /*
            * It is possible (but unlikely), that application
            * code could have disposed the widget in the paint
            * event.  If this happens, don't attempt to restore
            * the style.
            */
            if (!isDisposed ()) {
                OS.SetWindowLong (handle, OS.GWL_STYLE, oldBits);
            }
        }
    }
    return LRESULT.ZERO;
}

override LRESULT WM_PRINTCLIENT (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_PRINTCLIENT (wParam, lParam);
    if (result !is null) return result;
    if ((state & CANVAS) !is 0) {
        forceResize ();
        auto nSavedDC = OS.SaveDC (cast(HDC)wParam);
        RECT rect;
        OS.GetClientRect (handle, &rect);
        if ((style & (SWT.NO_BACKGROUND | SWT.TRANSPARENT)) is 0) {
            drawBackground ( cast(HDC)wParam, &rect);
        }
        if (hooks (SWT.Paint) || filters (SWT.Paint)) {
            GCData data = new GCData ();
            data.device = display;
            data.foreground = getForegroundPixel ();
            Control control = findBackgroundControl ();
            if (control is null) control = this;
            data.background = control.getBackgroundPixel ();
            data.font = Font.win32_new(display, cast(HANDLE) OS.SendMessage (handle, OS.WM_GETFONT, 0, 0));
            data.uiState = cast(int)/*64bit*/OS.SendMessage (handle, OS.WM_QUERYUISTATE, 0, 0);
            GC gc = GC.win32_new (cast(HDC)wParam, data);
            Event event = new Event ();
            event.gc = gc;
            event.x = rect.left;
            event.y = rect.top;
            event.width = rect.right - rect.left;
            event.height = rect.bottom - rect.top;
            sendEvent (SWT.Paint, event);
            event.gc = null;
            gc.dispose ();
        }
        OS.RestoreDC (cast(HDC)wParam, nSavedDC);
    }
    return result;
}

override LRESULT WM_SETFONT (WPARAM wParam, LPARAM lParam) {
    if (lParam !is 0) OS.InvalidateRect (handle, null, true);
    return super.WM_SETFONT (wParam, lParam);
}

override LRESULT WM_SIZE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = null;
    if ((state & RESIZE_DEFERRED) !is 0) {
        result = super.WM_SIZE (wParam, lParam);
    } else {
        /* Begin deferred window positioning */
        setResizeChildren (false);

        /* Resize and Layout */
        result = super.WM_SIZE (wParam, lParam);
        /*
        * It is possible (but unlikely), that application
        * code could have disposed the widget in the resize
        * event.  If this happens, end the processing of the
        * Windows message by returning the result of the
        * WM_SIZE message.
        */
        if (isDisposed ()) return result;
        if (layout_ !is null) {
            markLayout (false, false);
            updateLayout (false, false);
        }

        /* End deferred window positioning */
        setResizeChildren (true);
    }

    /* Damage the widget to cause a repaint */
    if (OS.IsWindowVisible (handle)) {
        if ((state & CANVAS) !is 0) {
            if ((style & SWT.NO_REDRAW_RESIZE) is 0) {
                if (hooks (SWT.Paint)) {
                    OS.InvalidateRect (handle, null, true);
                }
            }
        }
        if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
            if (findThemeControl () !is null) redrawChildren ();
        }
    }

    /* Resize the embedded window */
    if ((state & CANVAS) !is 0 && (style & SWT.EMBEDDED) !is 0) {
        resizeEmbeddedHandle (OS.GetWindow (handle, OS.GW_CHILD), OS.LOWORD (lParam), OS.HIWORD (lParam));
    }
    return result;
}

override LRESULT WM_SYSCOLORCHANGE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SYSCOLORCHANGE (wParam, lParam);
    if (result !is null) return result;
    auto hwndChild = OS.GetWindow (handle, OS.GW_CHILD);
    while (hwndChild !is null) {
        OS.SendMessage (hwndChild, OS.WM_SYSCOLORCHANGE, 0, 0);
        hwndChild = OS.GetWindow (hwndChild, OS.GW_HWNDNEXT);
    }
    return result;
}

override LRESULT WM_SYSCOMMAND (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_SYSCOMMAND (wParam, lParam);
    if (result !is null) return result;

    /*
    * Check to see if the command is a system command or
    * a user menu item that was added to the system menu.
    *
    * NOTE: This is undocumented.
    */
    if ((wParam & 0xF000) is 0) return result;

    /*
    * Bug in Windows.  When a vertical or horizontal scroll bar is
    * hidden or shown while the opposite scroll bar is being scrolled
    * by the user (with WM_HSCROLL code SB_LINEDOWN), the scroll bar
    * does not redraw properly.  The fix is to detect this case and
    * redraw the non-client area.
    */
    static if (!OS.IsWinCE) {
        int cmd = wParam & 0xFFF0;
        switch (cmd) {
            case OS.SC_HSCROLL:
            case OS.SC_VSCROLL:
                bool showHBar = horizontalBar !is null && horizontalBar.getVisible ();
                bool showVBar = verticalBar !is null && verticalBar.getVisible ();
                auto code = callWindowProc (handle, OS.WM_SYSCOMMAND, wParam, lParam);
                if ((showHBar !is (horizontalBar !is null && horizontalBar.getVisible ())) ||
                    (showVBar !is (verticalBar !is null && verticalBar.getVisible ()))) {
                        int flags = OS.RDW_FRAME | OS.RDW_INVALIDATE | OS.RDW_UPDATENOW;
                        OS.RedrawWindow (handle, null, null, flags);
                    }
                if (code is 0) return LRESULT.ZERO;
                return new LRESULT (code);
            default:
        }
    }
    /* Return the result */
    return result;
}

override LRESULT WM_UPDATEUISTATE (WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.WM_UPDATEUISTATE (wParam, lParam);
    if (result !is null) return result;
    if ((state & CANVAS) !is 0 && hooks (SWT.Paint)) {
        OS.InvalidateRect (handle, null, true);
    }
    return result;
}

override LRESULT wmNCPaint (HWND hwnd, WPARAM wParam, LPARAM lParam) {
    LRESULT result = super.wmNCPaint (hwnd, wParam, lParam);
    if (result !is null) return result;
    auto borderHandle = borderHandle ();
    if ((state & CANVAS) !is 0 || (hwnd is borderHandle && handle !is borderHandle)) {
        if (OS.COMCTL32_MAJOR >= 6 && OS.IsAppThemed ()) {
            int bits1 = OS.GetWindowLong (hwnd, OS.GWL_EXSTYLE);
            if ((bits1 & OS.WS_EX_CLIENTEDGE) !is 0) {
                .LRESULT code = 0;
                int bits2 = OS.GetWindowLong (hwnd, OS.GWL_STYLE);
                if ((bits2 & (OS.WS_HSCROLL | OS.WS_VSCROLL)) !is 0) {
                    code = callWindowProc (hwnd, OS.WM_NCPAINT, wParam, lParam);
                }
                auto hDC = OS.GetWindowDC (hwnd);
                RECT rect;
                OS.GetWindowRect (hwnd, &rect);
                rect.right -= rect.left;
                rect.bottom -= rect.top;
                rect.left = rect.top = 0;
                int border = OS.GetSystemMetrics (OS.SM_CXEDGE);
                OS.ExcludeClipRect (hDC, border, border, rect.right - border, rect.bottom - border);
                OS.DrawThemeBackground (display.hEditTheme (), hDC, OS.EP_EDITTEXT, OS.ETS_NORMAL, &rect, null);
                OS.ReleaseDC (hwnd, hDC);
                return new LRESULT (code);
            }
        }
    }
    return result;
}

override LRESULT wmNotify (NMHDR* hdr, WPARAM wParam, LPARAM lParam) {
    static if (!OS.IsWinCE) {
        switch (hdr.code) {
            /*
            * Feature in Windows.  When the tool tip control is
            * created, the parent of the tool tip is the shell.
            * If SetParent () is used to reparent the tool bar
            * into a new shell, the tool tip is not reparented
            * and pops up underneath the new shell.  The fix is
            * to make sure the tool tip is a topmost window.
            */
            case OS.TTN_SHOW:
            case OS.TTN_POP: {
                /*
                * Bug in Windows 98 and NT.  Setting the tool tip to be the
                * top most window using HWND_TOPMOST can result in a parent
                * dialog shell being moved behind its parent if the dialog
                * has a sibling that is currently on top.  The fix is to
                * lock the z-order of the active window.
                *
                * Feature in Windows.  Using SetWindowPos() with HWND_NOTOPMOST
                * to clear the topmost state of a window whose parent is already
                * topmost clears the topmost state of the parent.  The fix is to
                * check if the parent is already on top and neither set or clear
                * the topmost status of the tool tip.
                */
                auto hwndParent = hdr.hwndFrom;
                do {
                    hwndParent = OS.GetParent (hwndParent);
                    if (hwndParent is null) break;
                    int bits = OS.GetWindowLong (hwndParent, OS.GWL_EXSTYLE);
                    if ((bits & OS.WS_EX_TOPMOST) !is 0) break;
                } while (true);
                if (hwndParent !is null) break;
                display.lockActiveWindow = true;
                int flags = OS.SWP_NOACTIVATE | OS.SWP_NOMOVE | OS.SWP_NOSIZE;
                HWND hwndInsertAfter = cast(HWND)( hdr.code is OS.TTN_SHOW ? OS.HWND_TOPMOST : OS.HWND_NOTOPMOST);
                SetWindowPos (hdr.hwndFrom, hwndInsertAfter, 0, 0, 0, 0, flags);
                display.lockActiveWindow = false;
                break;
            }
            /*
            * Bug in Windows 98.  For some reason, the tool bar control
            * sends both TTN_GETDISPINFOW and TTN_GETDISPINFOA to get
            * the tool tip text and the tab folder control sends only
            * TTN_GETDISPINFOW.  The fix is to handle only TTN_GETDISPINFOW,
            * even though it should never be sent on Windows 98.
            *
            * NOTE:  Because the size of NMTTDISPINFO differs between
            * Windows 98 and NT, guard against the case where the wrong
            * kind of message occurs by inlining the memory moves and
            * the UNICODE conversion code.
            */
            case OS.TTN_GETDISPINFOA:
            case OS.TTN_GETDISPINFOW: {
                NMTTDISPINFO* lpnmtdi = cast(NMTTDISPINFO*)lParam;
//                 if (hdr.code is OS.TTN_GETDISPINFOA) {
//                     lpnmtdi = new NMTTDISPINFOA ();
//                     OS.MoveMemory (cast(NMTTDISPINFOA)lpnmtdi, lParam, NMTTDISPINFOA.sizeof);
//                 } else {
//                     lpnmtdi = new NMTTDISPINFOW ();
//                     OS.MoveMemory (cast(NMTTDISPINFOW)lpnmtdi, lParam, NMTTDISPINFOW.sizeof);
//                 }
                String string = toolTipText (lpnmtdi);
                if (string !is null) {
                    Shell shell = getShell ();
                    string = Display.withCrLf (string);
                    char [] chars = fixMnemonic (string);

                    /*
                    * Ensure that the orientation of the tool tip matches
                    * the orientation of the control.
                    */
                    Widget widget = null;
                    HWND hwnd = cast(HWND)hdr.idFrom;
                    if ((lpnmtdi.uFlags & OS.TTF_IDISHWND) !is 0) {
                        widget = display.getControl (hwnd);
                    } else {
                        if (hdr.hwndFrom is shell.toolTipHandle || hdr.hwndFrom is shell.balloonTipHandle) {
                            widget = shell.findToolTip (hdr.idFrom);
                        }
                    }
                    if (widget !is null) {
                        if ((widget.getStyle () & SWT.RIGHT_TO_LEFT) !is 0) {
                            lpnmtdi.uFlags |= OS.TTF_RTLREADING;
                        } else {
                            lpnmtdi.uFlags &= ~OS.TTF_RTLREADING;
                        }
                    }

                    if (hdr.code is OS.TTN_GETDISPINFOA) {
                        auto bytes = MBCSsToStr( cast(CHAR[])chars, getCodePage () );
                        //byte [] bytes = new byte [chars.length * 2];
                        //OS.WideCharToMultiByte (getCodePage (), 0, chars.ptr, chars.length, bytes, bytes.length, null, null);
                        shell.setToolTipText (lpnmtdi, bytes);
                        //OS.MoveMemory (lParam, cast(NMTTDISPINFOA)lpnmtdi, NMTTDISPINFOA.sizeof);
                    } else {
                        shell.setToolTipText (lpnmtdi, StrToTCHARs(chars,true));
                        //OS.MoveMemory (lParam, cast(NMTTDISPINFOW)lpnmtdi, NMTTDISPINFOW.sizeof);
                    }
                    return LRESULT.ZERO;
                }
                break;
            }
            default:
        }
    }
    return super.wmNotify (hdr, wParam, lParam);
}

}
