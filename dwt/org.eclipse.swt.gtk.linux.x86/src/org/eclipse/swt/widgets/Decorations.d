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
module org.eclipse.swt.widgets.Decorations;

import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.Composite;

import org.eclipse.swt.SWT;
import org.eclipse.swt.internal.gtk.OS;
//import org.eclipse.swt.graphics.;
import org.eclipse.swt.widgets.Canvas;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.Button;
import java.lang.all;

/**
 * Instances of this class provide the appearance and
 * behavior of <code>Shells</code>, but are not top
 * level shells or dialogs. Class <code>Shell</code>
 * shares a significant amount of code with this class,
 * and is a subclass.
 * <p>
 * IMPORTANT: This class was intended to be abstract and
 * should <em>never</em> be referenced or instantiated.
 * Instead, the class <code>Shell</code> should be used.
 * </p>
 * <p>
 * Instances are always displayed in one of the maximized,
 * minimized or normal states:
 * <ul>
 * <li>
 * When an instance is marked as <em>maximized</em>, the
 * window manager will typically resize it to fill the
 * entire visible area of the display, and the instance
 * is usually put in a state where it can not be resized
 * (even if it has style <code>RESIZE</code>) until it is
 * no longer maximized.
 * </li><li>
 * When an instance is in the <em>normal</em> state (neither
 * maximized or minimized), its appearance is controlled by
 * the style constants which were specified when it was created
 * and the restrictions of the window manager (see below).
 * </li><li>
 * When an instance has been marked as <em>minimized</em>,
 * its contents (client area) will usually not be visible,
 * and depending on the window manager, it may be
 * "iconified" (that is, replaced on the desktop by a small
 * simplified representation of itself), relocated to a
 * distinguished area of the screen, or hidden. Combinations
 * of these changes are also possible.
 * </li>
 * </ul>
 * </p>
 * Note: The styles supported by this class must be treated
 * as <em>HINT</em>s, since the window manager for the
 * desktop on which the instance is visible has ultimate
 * control over the appearance and behavior of decorations.
 * For example, some window managers only support resizable
 * windows and will always assume the RESIZE style, even if
 * it is not set.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>BORDER, CLOSE, MIN, MAX, NO_TRIM, RESIZE, TITLE, ON_TOP, TOOL</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * Class <code>SWT</code> provides two "convenience constants"
 * for the most commonly required style combinations:
 * <dl>
 * <dt><code>SHELL_TRIM</code></dt>
 * <dd>
 * the result of combining the constants which are required
 * to produce a typical application top level shell: (that
 * is, <code>CLOSE | TITLE | MIN | MAX | RESIZE</code>)
 * </dd>
 * <dt><code>DIALOG_TRIM</code></dt>
 * <dd>
 * the result of combining the constants which are required
 * to produce a typical application dialog shell: (that
 * is, <code>TITLE | CLOSE | BORDER</code>)
 * </dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see #getMinimized
 * @see #getMaximized
 * @see Shell
 * @see SWT
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Decorations : Canvas {

    alias Canvas.sort sort;

    String text;
    Image image;
    Image [] images;
    bool minimized, maximized;
    Menu menuBar;
    Menu [] menus;
    Control savedFocus;
    Button defaultButton, saveDefault;
    GtkAccelGroup* accelGroup;
    GtkWidget* vboxHandle;

this () {
    /* Do nothing */
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
 * @see SWT#BORDER
 * @see SWT#CLOSE
 * @see SWT#MIN
 * @see SWT#MAX
 * @see SWT#RESIZE
 * @see SWT#TITLE
 * @see SWT#NO_TRIM
 * @see SWT#SHELL_TRIM
 * @see SWT#DIALOG_TRIM
 * @see SWT#ON_TOP
 * @see SWT#TOOL
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle (style));
}

static int checkStyle (int style) {
    if ((style & SWT.NO_TRIM) !is 0) {
        style &= ~(SWT.CLOSE | SWT.TITLE | SWT.MIN | SWT.MAX | SWT.RESIZE | SWT.BORDER);
    }
    if ((style & (SWT.MENU | SWT.MIN | SWT.MAX | SWT.CLOSE)) !is 0) {
        style |= SWT.TITLE;
    }
    return style;
}

override protected void checkSubclass () {
    if (!isValidSubclass ()) error (SWT.ERROR_INVALID_SUBCLASS);
}

void _setImages (Image [] images) {
    if (images !is null && images.length > 1) {
        Image [] bestImages = new Image [images.length];
        System.arraycopy (images, 0, bestImages, 0, images.length);
        sort (bestImages);
        images = bestImages;
    }
    GList* pixbufs;
    if (images !is null) {
        for (int i = 0; i < images.length; i++) {
            Image image = images [i];
            auto pixbuf = Display.createPixbuf (image);
            pixbufs = OS.g_list_append (pixbufs, pixbuf);
        }
    }
    OS.gtk_window_set_icon_list (cast(GtkWindow*)topHandle (), pixbufs);
    GList* data;
    auto temp = pixbufs;
    while (temp !is null) {
        data = *cast(GList**)temp;
        OS.g_object_unref (data);
        temp = cast(GList*)OS.g_list_next (temp);
    }
    if (pixbufs !is null) OS.g_list_free (pixbufs);
}

void addMenu (Menu menu) {
    if (menus is null) menus = new Menu [4];
    for (int i=0; i<menus.length; i++) {
        if (menus [i] is null) {
            menus [i] = menu;
            return;
        }
    }
    Menu [] newMenus = new Menu [menus.length + 4];
    newMenus [menus.length] = menu;
    System.arraycopy (menus, 0, newMenus, 0, menus.length);
    menus = newMenus;
}

int compare (ImageData data1, ImageData data2) {
    if (data1.width is data2.width && data1.height is data2.height) {
        int transparent1 = data1.getTransparencyType ();
        int transparent2 = data2.getTransparencyType ();
        if (transparent1 is SWT.TRANSPARENCY_ALPHA) return -1;
        if (transparent2 is SWT.TRANSPARENCY_ALPHA) return 1;
        if (transparent1 is SWT.TRANSPARENCY_MASK) return -1;
        if (transparent2 is SWT.TRANSPARENCY_MASK) return 1;
        if (transparent1 is SWT.TRANSPARENCY_PIXEL) return -1;
        if (transparent2 is SWT.TRANSPARENCY_PIXEL) return 1;
        return 0;
    }
    return data1.width > data2.width || data1.height > data2.height ? -1 : 1;
}

override Control computeTabGroup () {
    return this;
}

override Control computeTabRoot () {
    return this;
}

void createAccelGroup () {
    if (accelGroup !is null) return;
    accelGroup = OS.gtk_accel_group_new ();
    if (accelGroup is null) SWT.error (SWT.ERROR_NO_HANDLES);
    //FIXME - what should we do for Decorations
    auto shellHandle = topHandle ();
    OS.gtk_window_add_accel_group (cast(GtkWindow*)shellHandle, accelGroup);
}

override void createWidget (int index) {
    super.createWidget (index);
    text = "";
}

void destroyAccelGroup () {
    if (accelGroup is null) return;
    auto shellHandle = topHandle ();
    OS.gtk_window_remove_accel_group (cast(GtkWindow*)shellHandle, accelGroup);
    //TEMPORARY CODE
//  OS.g_object_unref (accelGroup);
    accelGroup = null;
}

void fixAccelGroup () {
    if (menuBar is null) return;
    destroyAccelGroup ();
    createAccelGroup ();
    menuBar.addAccelerators (accelGroup);
}

void fixDecorations (Decorations newDecorations, Control control, Menu [] menus) {
    if (this is newDecorations) return;
    if (control is savedFocus) savedFocus = null;
    if (control is defaultButton) defaultButton = null;
    if (control is saveDefault) saveDefault = null;
    if (menus is null) return;
    Menu menu = control.menu;
    if (menu !is null) {
        int index = 0;
        while (index <menus.length) {
            if (menus [index] is menu) {
                control.setMenu (null);
                return;
            }
            index++;
        }
        menu.fixMenus (newDecorations);
    }
}

/**
 * Returns the receiver's default button if one had
 * previously been set, otherwise returns null.
 *
 * @return the default button or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setDefaultButton(Button)
 */
public Button getDefaultButton () {
    checkWidget();
    return defaultButton !is null ? defaultButton : saveDefault;
}

/**
 * Returns the receiver's image if it had previously been
 * set using <code>setImage()</code>. The image is typically
 * displayed by the window manager when the instance is
 * marked as iconified, and may also be displayed somewhere
 * in the trim when the instance is in normal or maximized
 * states.
 * <p>
 * Note: This method will return null if called before
 * <code>setImage()</code> is called. It does not provide
 * access to a window manager provided, "default" image
 * even if one exists.
 * </p>
 *
 * @return the image
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Image getImage () {
    checkWidget ();
    return image;
}

/**
 * Returns the receiver's images if they had previously been
 * set using <code>setImages()</code>. Images are typically
 * displayed by the window manager when the instance is
 * marked as iconified, and may also be displayed somewhere
 * in the trim when the instance is in normal or maximized
 * states. Depending where the icon is displayed, the platform
 * chooses the icon with the "best" attributes.  It is expected
 * that the array will contain the same icon rendered at different
 * sizes, with different depth and transparency attributes.
 *
 * <p>
 * Note: This method will return an empty array if called before
 * <code>setImages()</code> is called. It does not provide
 * access to a window manager provided, "default" image
 * even if one exists.
 * </p>
 *
 * @return the images
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public Image [] getImages () {
    checkWidget ();
    if (images is null) return new Image [0];
    Image [] result = new Image [images.length];
    System.arraycopy (images, 0, result, 0, images.length);
    return result;
}

/**
 * Returns <code>true</code> if the receiver is currently
 * maximized, and false otherwise.
 * <p>
 *
 * @return the maximized state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setMaximized
 */
public bool getMaximized () {
    checkWidget();
    return maximized;
}

/**
 * Returns the receiver's menu bar if one had previously
 * been set, otherwise returns null.
 *
 * @return the menu bar or null
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Menu getMenuBar () {
    checkWidget();
    return menuBar;
}

/**
 * Returns <code>true</code> if the receiver is currently
 * minimized, and false otherwise.
 * <p>
 *
 * @return the minimized state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setMinimized
 */
public bool getMinimized () {
    checkWidget();
    return minimized;
}

override String getNameText () {
    return getText ();
}

/**
 * Returns the receiver's text, which is the string that the
 * window manager will typically display as the receiver's
 * <em>title</em>. If the text has not previously been set,
 * returns an empty string.
 *
 * @return the text
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public String getText () {
    checkWidget();
    return text;
}

override public bool isReparentable () {
    checkWidget ();
    return false;
}

override bool isTabGroup () {
    return true;
}

override bool isTabItem () {
    return false;
}

override Decorations menuShell () {
    return this;
}

void removeMenu (Menu menu) {
    if (menus is null) return;
    for (int i=0; i<menus.length; i++) {
        if (menus [i] is menu) {
            menus [i] = null;
            return;
        }
    }
}

override void releaseChildren (bool destroy) {
    if (menuBar !is null) {
        menuBar.release (false);
        menuBar = null;
    }
    super.releaseChildren (destroy);
    if (menus !is null) {
        for (int i=0; i<menus.length; i++) {
            Menu menu = menus [i];
            if (menu !is null && !menu.isDisposed ()) {
                menu.dispose ();
            }
        }
        menus = null;
    }
}

override void releaseHandle () {
    super.releaseHandle ();
    vboxHandle = null;
}

override void releaseWidget () {
    super.releaseWidget ();
    image = null;
    images = null;
    savedFocus = null;
    defaultButton = saveDefault = null;
}

bool restoreFocus () {
    if (savedFocus !is null && savedFocus.isDisposed ()) savedFocus = null;
    bool restored = savedFocus !is null && savedFocus.setFocus ();
    savedFocus = null;
    /*
    * This code is intentionally commented.  When no widget
    * has been given focus, some platforms give focus to the
    * default button.  Motif doesn't do this.
    */
//  if (restored) return true;
//  if (defaultButton !is null && !defaultButton.isDisposed ()) {
//      if (defaultButton.setFocus ()) return true;
//  }
//  return false;
    return restored;
}

/**
 * If the argument is not null, sets the receiver's default
 * button to the argument, and if the argument is null, sets
 * the receiver's default button to the first button which
 * was set as the receiver's default button (called the
 * <em>saved default button</em>). If no default button had
 * previously been set, or the saved default button was
 * disposed, the receiver's default button will be set to
 * null.
 * <p>
 * The default button is the button that is selected when
 * the receiver is active and the user presses ENTER.
 * </p>
 *
 * @param button the new default button
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the button has been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if the control is not in the same widget tree</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setDefaultButton (Button button) {
    checkWidget();
    GtkWidget* buttonHandle;
    if (button !is null) {
        if (button.isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
        if (button.menuShell () !is this) error (SWT.ERROR_INVALID_PARENT);
        buttonHandle = button.handle;
    }
    saveDefault = defaultButton = button;
    OS.gtk_window_set_default (cast(GtkWindow*)topHandle (), buttonHandle);
}

/**
 * Sets the receiver's image to the argument, which may
 * be null. The image is typically displayed by the window
 * manager when the instance is marked as iconified, and
 * may also be displayed somewhere in the trim when the
 * instance is in normal or maximized states.
 *
 * @param image the new image (or null)
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the image has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setImage (Image image) {
    checkWidget ();
    this.image = image;
    _setImages (image !is null ? [image] : null);
}

/**
 * Sets the receiver's images to the argument, which may
 * be an empty array. Images are typically displayed by the
 * window manager when the instance is marked as iconified,
 * and may also be displayed somewhere in the trim when the
 * instance is in normal or maximized states. Depending where
 * the icon is displayed, the platform chooses the icon with
 * the "best" attributes. It is expected that the array will
 * contain the same icon rendered at different sizes, with
 * different depth and transparency attributes.
 *
 * @param images the new image array
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if one of the images is null or has been disposed</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @since 3.0
 */
public void setImages (Image [] images) {
    checkWidget ();
    // SWT extension: allow null for zero length string
    //if (images is null) error (SWT.ERROR_INVALID_ARGUMENT);
    for (int i = 0; i < images.length; i++) {
        if (images [i] is null || images [i].isDisposed ()) error (SWT.ERROR_INVALID_ARGUMENT);
    }
    this.images = images;
    _setImages (images);
}

/**
 * Sets the maximized state of the receiver.
 * If the argument is <code>true</code> causes the receiver
 * to switch to the maximized state, and if the argument is
 * <code>false</code> and the receiver was previously maximized,
 * causes the receiver to switch back to either the minimized
 * or normal states.
 * <p>
 * Note: The result of intermixing calls to <code>setMaximized(true)</code>
 * and <code>setMinimized(true)</code> will vary by platform. Typically,
 * the behavior will match the platform user's expectations, but not
 * always. This should be avoided if possible.
 * </p>
 *
 * @param maximized the new maximized state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setMinimized
 */
public void setMaximized (bool maximized) {
    checkWidget();
    this.maximized = maximized;
}

/**
 * Sets the receiver's menu bar to the argument, which
 * may be null.
 *
 * @param menu the new menu bar
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_ARGUMENT - if the menu has been disposed</li>
 *    <li>ERROR_INVALID_PARENT - if the menu is not in the same widget tree</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setMenuBar (Menu menu) {
    checkWidget();
    if (menuBar is menu) return;
    if (menu !is null) {
        if ((menu.style & SWT.BAR) is 0) error (SWT.ERROR_MENU_NOT_BAR);
        if (menu.parent !is this) error (SWT.ERROR_INVALID_PARENT);
    }
    menuBar = menu;
}

/**
 * Sets the minimized stated of the receiver.
 * If the argument is <code>true</code> causes the receiver
 * to switch to the minimized state, and if the argument is
 * <code>false</code> and the receiver was previously minimized,
 * causes the receiver to switch back to either the maximized
 * or normal states.
 * <p>
 * Note: The result of intermixing calls to <code>setMaximized(true)</code>
 * and <code>setMinimized(true)</code> will vary by platform. Typically,
 * the behavior will match the platform user's expectations, but not
 * always. This should be avoided if possible.
 * </p>
 *
 * @param minimized the new maximized state
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 *
 * @see #setMaximized
 */
public void setMinimized (bool minimized) {
    checkWidget();
    this.minimized = minimized;
}

void setSavedFocus (Control control) {
    if (this is control) return;
    savedFocus = control;
}

/**
 * Sets the receiver's text, which is the string that the
 * window manager will typically display as the receiver's
 * <em>title</em>, to the argument, which must not be null.
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
    text = string;
}

void sort (Image [] images) {
    /* Shell Sort from K&R, pg 108 */
    ptrdiff_t length = images.length;
    if (length <= 1) return;
    ImageData [] datas = new ImageData [length];
    for (int i = 0; i < length; i++) {
        datas [i] = images [i].getImageData ();
    }
    for (ptrdiff_t gap=length/2; gap>0; gap/=2) {
        for (ptrdiff_t i=gap; i<length; i++) {
            for (ptrdiff_t j=i-gap; j>=0; j-=gap) {
                if (compare (datas [j], datas [j + gap]) >= 0) {
                    Image swap = images [j];
                    images [j] = images [j + gap];
                    images [j + gap] = swap;
                    ImageData swapData = datas [j];
                    datas [j] = datas [j + gap];
                    datas [j + gap] = swapData;
                }
            }
        }
    }
}

override bool traverseItem (bool next) {
    return false;
}

override bool traverseReturn () {
    Button button = defaultButton !is null ? defaultButton: saveDefault;
    if (button is null || button.isDisposed ()) return false;
    /*
    * Bug in GTK.  When a default button that is disabled is
    * activated using the Enter key, GTK GP's.  The fix is to
    * detect this case and stop GTK from processing the Enter
    * key.
    */
    if (!button.isVisible () || !button.isEnabled ()) return true;
    auto shellHandle = _getShell ().topHandle ();
    return cast(bool)OS.gtk_window_activate_default (cast(GtkWindow*)shellHandle);
}

}
