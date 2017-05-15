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
module org.eclipse.swt.widgets.Tracker;

import java.lang.all;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.events.ControlListener;
import org.eclipse.swt.events.KeyListener;
import org.eclipse.swt.graphics.Cursor;
import org.eclipse.swt.graphics.Point;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Widget;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.TypedListener;
import org.eclipse.swt.widgets.Event;

import java.lang.Thread;

/**
 *  Instances of this class implement rubber banding rectangles that are
 *  drawn onto a parent <code>Composite</code> or <code>Display</code>.
 *  These rectangles can be specified to respond to mouse and key events
 *  by either moving or resizing themselves accordingly.  Trackers are
 *  typically used to represent window geometries in a lightweight manner.
 *
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>LEFT, RIGHT, UP, DOWN, RESIZE</dd>
 * <dt><b>Events:</b></dt>
 * <dd>Move, Resize</dd>
 * </dl>
 * <p>
 * Note: Rectangle move behavior is assumed unless RESIZE is specified.
 * </p><p>
 * IMPORTANT: This class is <em>not</em> intended to be subclassed.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#tracker">Tracker snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class Tracker : Widget {
    Composite parent;
    Cursor cursor;
    GdkCursor* lastCursor;
    GdkDrawable* window;
    bool tracking, cancelled, grabbed, stippled;
    Rectangle [] rectangles, proportions;
    Rectangle bounds;
    int cursorOrientation = SWT.NONE;
    int oldX, oldY;

    const static int STEPSIZE_SMALL = 1;
    const static int STEPSIZE_LARGE = 9;

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
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#LEFT
 * @see SWT#RIGHT
 * @see SWT#UP
 * @see SWT#DOWN
 * @see SWT#RESIZE
 * @see Widget#checkSubclass
 * @see Widget#getStyle
 */
public this (Composite parent, int style) {
    super (parent, checkStyle(style));
    this.parent = parent;
}

/**
 * Constructs a new instance of this class given the display
 * to create it on and a style value describing its behavior
 * and appearance.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>SWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>SWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 * </p><p>
 * Note: Currently, null can be passed in for the display argument.
 * This has the effect of creating the tracker on the currently active
 * display if there is one. If there is no current display, the
 * tracker is created on a "default" display. <b>Passing in null as
 * the display argument is not considered to be good coding style,
 * and may not be supported in a future release of SWT.</b>
 * </p>
 *
 * @param display the display to create the tracker on
 * @param style the style of control to construct
 *
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 *
 * @see SWT#LEFT
 * @see SWT#RIGHT
 * @see SWT#UP
 * @see SWT#DOWN
 */
public this (Display display, int style) {
    if (display is null) display = Display.getCurrent ();
    if (display is null) display = Display.getDefault ();
    if (!display.isValidThread ()) {
        error (SWT.ERROR_THREAD_INVALID_ACCESS);
    }
    this.style = checkStyle (style);
    this.display = display;
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
    addListener (SWT.Resize, typedListener);
    addListener (SWT.Move, typedListener);
}

/**
 * Adds the listener to the collection of listeners who will
 * be notified when keys are pressed and released on the system keyboard, by sending
 * it one of the messages defined in the <code>KeyListener</code>
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
 * @see KeyListener
 * @see #removeKeyListener
 */
public void addKeyListener(KeyListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    TypedListener typedListener = new TypedListener (listener);
    addListener(SWT.KeyUp,typedListener);
    addListener(SWT.KeyDown,typedListener);
}

Point adjustMoveCursor () {
    if (bounds is null) return null;
    int newX = bounds.x + bounds.width / 2;
    int newY = bounds.y;

    Point point = display.map (parent, null, newX, newY);
    display.setCursorLocation (point);

    /*
     * The call to XWarpPointer does not always place the pointer on the
     * exact location that is specified, so do a query (below) to get the
     * actual location of the pointer after it has been moved.
     */
    int actualX, actualY, state;
    OS.gdk_window_get_pointer (cast(GdkWindow*)window, &actualX, &actualY, &state);
    return new Point (actualX, actualY);
}

Point adjustResizeCursor () {
    if (bounds is null) return null;
    int newX, newY;

    if ((cursorOrientation & SWT.LEFT) !is 0) {
        newX = bounds.x;
    } else if ((cursorOrientation & SWT.RIGHT) !is 0) {
        newX = bounds.x + bounds.width;
    } else {
        newX = bounds.x + bounds.width / 2;
    }

    if ((cursorOrientation & SWT.UP) !is 0) {
        newY = bounds.y;
    } else if ((cursorOrientation & SWT.DOWN) !is 0) {
        newY = bounds.y + bounds.height;
    } else {
        newY = bounds.y + bounds.height / 2;
    }

    Point point = display.map (parent, null, newX, newY);
    display.setCursorLocation (point);

    /*
     * The call to XWarpPointer does not always place the pointer on the
     * exact location that is specified, so do a query (below) to get the
     * actual location of the pointer after it has been moved.
     */
    int  actualX, actualY, state;
    OS.gdk_window_get_pointer (window, &actualX, &actualY, &state);
    return new Point (actualX, actualY );
}


/**
 * Stops displaying the tracker rectangles.  Note that this is not considered
 * to be a cancelation by the user.
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void close () {
    checkWidget();
    tracking = false;
}

static int checkStyle (int style) {
    if ((style & (SWT.LEFT | SWT.RIGHT | SWT.UP | SWT.DOWN)) is 0) {
        style |= SWT.LEFT | SWT.RIGHT | SWT.UP | SWT.DOWN;
    }
    return style;
}

Rectangle computeBounds () {
    if (rectangles.length is 0) return null;
    int xMin = rectangles [0].x;
    int yMin = rectangles [0].y;
    int xMax = rectangles [0].x + rectangles [0].width;
    int yMax = rectangles [0].y + rectangles [0].height;

    for (int i = 1; i < rectangles.length; i++) {
        if (rectangles [i].x < xMin) xMin = rectangles [i].x;
        if (rectangles [i].y < yMin) yMin = rectangles [i].y;
        int rectRight = rectangles [i].x + rectangles [i].width;
        if (rectRight > xMax) xMax = rectRight;
        int rectBottom = rectangles [i].y + rectangles [i].height;
        if (rectBottom > yMax) yMax = rectBottom;
    }

    return new Rectangle (xMin, yMin, xMax - xMin, yMax - yMin);
}

Rectangle [] computeProportions (Rectangle [] rects) {
    Rectangle [] result = new Rectangle [rects.length];
    bounds = computeBounds ();
    if (bounds !is null) {
        for (int i = 0; i < rects.length; i++) {
            int x = 0, y = 0, width = 0, height = 0;
            if (bounds.width !is 0) {
                x = (rects [i].x - bounds.x) * 100 / bounds.width;
                width = rects [i].width * 100 / bounds.width;
            } else {
                width = 100;
            }
            if (bounds.height !is 0) {
                y = (rects [i].y - bounds.y) * 100 / bounds.height;
                height = rects [i].height * 100 / bounds.height;
            } else {
                height = 100;
            }
            result [i] = new Rectangle (x, y, width, height);
        }
    }
    return result;
}

void drawRectangles (Rectangle [] rects) {
    auto window = OS.GDK_ROOT_PARENT ();
    if (parent !is null) {
        window = OS.GTK_WIDGET_WINDOW (parent.paintHandle());
    }
    if (window is null) return;
    auto gc = OS.gdk_gc_new (window);
    if (gc is null) return;
    auto colormap = OS.gdk_colormap_get_system ();
    GdkColor color;
    OS.gdk_color_white (colormap, &color);
    OS.gdk_gc_set_foreground (gc, &color);
    OS.gdk_gc_set_subwindow (gc, OS.GDK_INCLUDE_INFERIORS);
    OS.gdk_gc_set_function (gc, OS.GDK_XOR);
    for (int i=0; i<rects.length; i++) {
        Rectangle rect = rects [i];
        int x = rect.x;
        if (parent !is null && (parent.style & SWT.MIRRORED) !is 0) x = parent.getClientWidth () - rect.width - x;
        OS.gdk_draw_rectangle (window, gc, 0, x, rect.y, rect.width, rect.height);
    }
    OS.g_object_unref (gc);
}

/**
 * Returns the bounds that are being drawn, expressed relative to the parent
 * widget.  If the parent is a <code>Display</code> then these are screen
 * coordinates.
 *
 * @return the bounds of the Rectangles being drawn
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public Rectangle [] getRectangles () {
    checkWidget();
    Rectangle [] result = new Rectangle [rectangles.length];
    for (int i = 0; i < rectangles.length; i++) {
        Rectangle current = rectangles [i];
        result [i] = new Rectangle (current.x, current.y, current.width, current.height);
    }
    return result;
}

/**
 * Returns <code>true</code> if the rectangles are drawn with a stippled line, <code>false</code> otherwise.
 *
 * @return the stippled effect of the rectangles
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool getStippled () {
    checkWidget();
    return stippled;
}

bool grab () {
    auto cursor = this.cursor !is null ? this.cursor.handle : null;
    int result = OS.gdk_pointer_grab (window, false, OS.GDK_POINTER_MOTION_MASK | OS.GDK_BUTTON_RELEASE_MASK, window, cursor, OS.GDK_CURRENT_TIME);
    return result is OS.GDK_GRAB_SUCCESS;
}

override int gtk_button_release_event (GtkWidget* widget, GdkEventButton* event) {
    return gtk_mouse (OS.GDK_BUTTON_RELEASE, widget, event);
}

override int gtk_key_press_event (GtkWidget* widget, GdkEventKey* keyEvent) {
    auto result = super.gtk_key_press_event (widget, keyEvent);
    if (result !is 0) return result;
    int stepSize = ((keyEvent.state & OS.GDK_CONTROL_MASK) !is 0) ? STEPSIZE_SMALL : STEPSIZE_LARGE;
    int xChange = 0, yChange = 0;
    switch (keyEvent.keyval) {
        case OS.GDK_Escape:
            cancelled = true;
            goto case OS.GDK_Return;
        case OS.GDK_Return:
            tracking = false;
            break;
        case OS.GDK_Left:
            xChange = -stepSize;
            break;
        case OS.GDK_Right:
            xChange = stepSize;
            break;
        case OS.GDK_Up:
            yChange = -stepSize;
            break;
        case OS.GDK_Down:
            yChange = stepSize;
            break;
        default:
    }
    if (xChange !is 0 || yChange !is 0) {
        Rectangle [] oldRectangles = rectangles;
        Rectangle [] rectsToErase = new Rectangle [rectangles.length];
        for (int i = 0; i < rectangles.length; i++) {
            Rectangle current = rectangles [i];
            rectsToErase [i] = new Rectangle (current.x, current.y, current.width, current.height);
        }
        Event event = new Event ();
        event.x = oldX + xChange;
        event.y = oldY + yChange;
        if (parent !is null && (parent.style & SWT.MIRRORED) !is 0) {
            event.x = parent.getClientWidth () - event.width - event.x;
        }
        if ((style & SWT.RESIZE) !is 0) {
            resizeRectangles (xChange, yChange);
            sendEvent (SWT.Resize, event);
            /*
            * It is possible (but unlikely) that application
            * code could have disposed the widget in the resize
            * event.  If this happens return false to indicate
            * that the tracking has failed.
            */
            if (isDisposed ()) {
                cancelled = true;
                return 1;
            }
            bool draw = false;
            /*
             * It is possible that application code could have
             * changed the rectangles in the resize event.  If this
             * happens then only redraw the tracker if the rectangle
             * values have changed.
             */
            if (rectangles !is oldRectangles) {
                ptrdiff_t length = rectangles.length;
                if (length !is rectsToErase.length) {
                    draw = true;
                } else {
                    for (int i = 0; i < length; i++) {
                        if (rectangles [i] !=/*eq*/ rectsToErase [i]) {
                            draw = true;
                            break;
                        }
                    }
                }
            } else {
                draw = true;
            }
            if (draw) {
                drawRectangles (rectsToErase);
                update ();
                drawRectangles (rectangles);
            }
            Point cursorPos = adjustResizeCursor ();
            if (cursorPos !is null) {
                oldX = cursorPos.x;
                oldY = cursorPos.y;
            }
        } else {
            moveRectangles (xChange, yChange);
            sendEvent (SWT.Move, event);
            /*
            * It is possible (but unlikely) that application
            * code could have disposed the widget in the move
            * event.  If this happens return false to indicate
            * that the tracking has failed.
            */
            if (isDisposed ()) {
                cancelled = true;
                return 1;
            }
            bool draw = false;
            /*
             * It is possible that application code could have
             * changed the rectangles in the move event.  If this
             * happens then only redraw the tracker if the rectangle
             * values have changed.
             */
            if (rectangles !is oldRectangles) {
                ptrdiff_t length = rectangles.length;
                if (length !is rectsToErase.length) {
                    draw = true;
                } else {
                    for (int i = 0; i < length; i++) {
                        if (rectangles [i] !=/*eq*/ rectsToErase [i]) {
                            draw = true;
                            break;
                        }
                    }
                }
            } else {
                draw = true;
            }
            if (draw) {
                drawRectangles (rectsToErase);
                update ();
                drawRectangles (rectangles);
            }
            Point cursorPos = adjustMoveCursor ();
            if (cursorPos !is null) {
                oldX = cursorPos.x;
                oldY = cursorPos.y;
            }
        }
    }
    return result;
}

override int gtk_motion_notify_event (GtkWidget* widget, GdkEventMotion* eventPtr) {
    auto cursor = this.cursor !is null ? this.cursor.handle : null;
    if (cursor !is lastCursor) {
        ungrab ();
        grabbed = grab ();
        lastCursor = cursor;
    }
    return gtk_mouse (OS.GDK_MOTION_NOTIFY, widget, eventPtr);
}

private int gtk_mouse (int eventType, GtkWidget* widget, void* eventPtr) {
    int newX, newY;
    OS.gdk_window_get_pointer (window, &newX, &newY, null);
    if (oldX !is newX || oldY !is newY ) {
        Rectangle [] oldRectangles = rectangles;
        Rectangle [] rectsToErase = new Rectangle [rectangles.length];
        for (int i = 0; i < rectangles.length; i++) {
            Rectangle current = rectangles [i];
            rectsToErase [i] = new Rectangle (current.x, current.y, current.width, current.height);
        }
        Event event = new Event ();
        if (parent is null) {
            event.x = newX ;
            event.y = newY ;
        } else {
            Point screenCoord = display.map (parent, null, newX , newY );
            event.x = screenCoord.x;
            event.y = screenCoord.y;
        }
        if ((style & SWT.RESIZE) !is 0) {
            resizeRectangles (newX  - oldX, newY  - oldY);
            sendEvent (SWT.Resize, event);
            /*
            * It is possible (but unlikely), that application
            * code could have disposed the widget in the resize
            * event.  If this happens, return false to indicate
            * that the tracking has failed.
            */
            if (isDisposed ()) {
                cancelled = true;
                return 1;
            }
            bool draw = false;
            /*
             * It is possible that application code could have
             * changed the rectangles in the resize event.  If this
             * happens then only redraw the tracker if the rectangle
             * values have changed.
             */
            if (rectangles !is oldRectangles) {
                ptrdiff_t length = rectangles.length;
                if (length !is rectsToErase.length) {
                    draw = true;
                } else {
                    for (int i = 0; i < length; i++) {
                        if (rectangles [i] !=/*eq*/ rectsToErase [i]) {
                            draw = true;
                            break;
                        }
                    }
                }
            } else {
                draw = true;
            }
            if (draw) {
                drawRectangles (rectsToErase);
                update ();
                drawRectangles (rectangles);
            }
            Point cursorPos = adjustResizeCursor ();
            if (cursorPos !is null) {
                newX  = cursorPos.x;
                newY  = cursorPos.y;
            }
        } else {
            moveRectangles (newX  - oldX, newY  - oldY);
            sendEvent (SWT.Move, event);
            /*
            * It is possible (but unlikely), that application
            * code could have disposed the widget in the move
            * event.  If this happens, return false to indicate
            * that the tracking has failed.
            */
            if (isDisposed ()) {
                cancelled = true;
                return 1;
            }
            bool draw = false;
            /*
             * It is possible that application code could have
             * changed the rectangles in the move event.  If this
             * happens then only redraw the tracker if the rectangle
             * values have changed.
             */
            if (rectangles !is oldRectangles) {
                ptrdiff_t length = rectangles.length;
                if (length !is rectsToErase.length) {
                    draw = true;
                } else {
                    for (int i = 0; i < length; i++) {
                        if (rectangles [i] !=/*eq*/ rectsToErase [i]) {
                            draw = true;
                            break;
                        }
                    }
                }
            } else {
                draw = true;
            }
            if (draw) {
                drawRectangles (rectsToErase);
                update ();
                drawRectangles (rectangles);
            }
        }
        oldX = newX ;
        oldY = newY ;
    }
    tracking = eventType !is OS.GDK_BUTTON_RELEASE;
    return 0;
}

void moveRectangles (int xChange, int yChange) {
    if (bounds is null) return;
    if (xChange < 0 && ((style & SWT.LEFT) is 0)) xChange = 0;
    if (xChange > 0 && ((style & SWT.RIGHT) is 0)) xChange = 0;
    if (yChange < 0 && ((style & SWT.UP) is 0)) yChange = 0;
    if (yChange > 0 && ((style & SWT.DOWN) is 0)) yChange = 0;
    if (xChange is 0 && yChange is 0) return;
    if (parent !is null && (parent.style & SWT.MIRRORED) !is 0) xChange *= -1;
    bounds.x += xChange; bounds.y += yChange;
    for (int i = 0; i < rectangles.length; i++) {
        rectangles [i].x += xChange;
        rectangles [i].y += yChange;
    }
}

/**
 * Displays the Tracker rectangles for manipulation by the user.  Returns when
 * the user has either finished manipulating the rectangles or has cancelled the
 * Tracker.
 *
 * @return <code>true</code> if the user did not cancel the Tracker, <code>false</code> otherwise
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool open () {
    checkWidget();
    window = OS.GDK_ROOT_PARENT ();
    if (parent !is null) {
        window = OS.GTK_WIDGET_WINDOW (parent.paintHandle());
    }
    if (window is null) return false;
    cancelled = false;
    tracking = true;
    update ();
    drawRectangles (rectangles);
    int oldX, oldY, state;
    OS.gdk_window_get_pointer (window, &oldX, &oldY, &state);

    /*
    * if exactly one of UP/DOWN is specified as a style then set the cursor
    * orientation accordingly (the same is done for LEFT/RIGHT styles below)
    */
    int vStyle = style & (SWT.UP | SWT.DOWN);
    if (vStyle is SWT.UP || vStyle is SWT.DOWN) {
        cursorOrientation |= vStyle;
    }
    int hStyle = style & (SWT.LEFT | SWT.RIGHT);
    if (hStyle is SWT.LEFT || hStyle is SWT.RIGHT) {
        cursorOrientation |= hStyle;
    }

    int mask = OS.GDK_BUTTON1_MASK | OS.GDK_BUTTON2_MASK | OS.GDK_BUTTON3_MASK;
    bool mouseDown = (state  & mask) !is 0;
    if (!mouseDown) {
        Point cursorPos = null;
        if ((style & SWT.RESIZE) !is 0) {
            cursorPos = adjustResizeCursor ();
        } else {
            cursorPos = adjustMoveCursor ();
        }
        if (cursorPos !is null) {
            oldX  = cursorPos.x;
            oldY  = cursorPos.y;
        }
    }
    this.oldX = oldX ;
    this.oldY = oldY ;

    grabbed = grab ();
    lastCursor = this.cursor !is null ? this.cursor.handle : null;

    /* Tracker behaves like a Dialog with its own OS event loop. */
    GdkEvent* gdkEvent;
    while (tracking) {
        if (parent !is null && parent.isDisposed ()) break;
        GdkEvent* eventPtr;
        while (true) {
            eventPtr = OS.gdk_event_get ();
            if (eventPtr !is null) {
                break;
            } else {
                try { Thread.sleep(50); } catch (Exception ex) {}
            }
        }
        gdkEvent = eventPtr;
        auto widget = OS.gtk_get_event_widget (eventPtr);
        switch (gdkEvent.type) {
            case OS.GDK_MOTION_NOTIFY: gtk_motion_notify_event (widget, cast(GdkEventMotion*)eventPtr); break;
            case OS.GDK_BUTTON_RELEASE: gtk_button_release_event (widget, cast(GdkEventButton*)eventPtr); break;
            case OS.GDK_KEY_PRESS: gtk_key_press_event (widget, cast(GdkEventKey*)eventPtr); break;
            case OS.GDK_KEY_RELEASE: gtk_key_release_event (widget, cast(GdkEventKey*)eventPtr); break;
            case OS.GDK_BUTTON_PRESS:
            case OS.GDK_2BUTTON_PRESS:
            case OS.GDK_3BUTTON_PRESS:
            case OS.GDK_ENTER_NOTIFY:
            case OS.GDK_LEAVE_NOTIFY:
                /* Do not dispatch these */
                break;
            case OS.GDK_EXPOSE:
                update ();
                drawRectangles (rectangles);
                OS.gtk_main_do_event (eventPtr);
                drawRectangles (rectangles);
                break;
            default:
                OS.gtk_main_do_event (eventPtr);
        }
        OS.gdk_event_free (eventPtr);
    }
    if (!isDisposed ()) {
        update ();
        drawRectangles (rectangles);
    }
    ungrab ();
    window = null;
    return !cancelled;
}

override void releaseWidget () {
    super.releaseWidget ();
    parent = null;
    rectangles = proportions = null;
    bounds = null;
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
    eventTable.unhook (SWT.Resize, listener);
    eventTable.unhook (SWT.Move, listener);
}

/**
 * Removes the listener from the collection of listeners who will
 * be notified when keys are pressed and released on the system keyboard.
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
 * @see KeyListener
 * @see #addKeyListener
 */
public void removeKeyListener(KeyListener listener) {
    checkWidget();
    if (listener is null) error (SWT.ERROR_NULL_ARGUMENT);
    if (eventTable is null) return;
    eventTable.unhook (SWT.KeyUp, listener);
    eventTable.unhook (SWT.KeyDown, listener);
}

void resizeRectangles (int xChange, int yChange) {
    if (bounds is null) return;
    if (parent !is null && (parent.style & SWT.MIRRORED) !is 0) xChange *= -1;
    /*
    * If the cursor orientation has not been set in the orientation of
    * this change then try to set it here.
    */
    if (xChange < 0 && ((style & SWT.LEFT) !is 0) && ((cursorOrientation & SWT.RIGHT) is 0)) {
        cursorOrientation |= SWT.LEFT;
    }
    if (xChange > 0 && ((style & SWT.RIGHT) !is 0) && ((cursorOrientation & SWT.LEFT) is 0)) {
        cursorOrientation |= SWT.RIGHT;
    }
    if (yChange < 0 && ((style & SWT.UP) !is 0) && ((cursorOrientation & SWT.DOWN) is 0)) {
        cursorOrientation |= SWT.UP;
    }
    if (yChange > 0 && ((style & SWT.DOWN) !is 0) && ((cursorOrientation & SWT.UP) is 0)) {
        cursorOrientation |= SWT.DOWN;
    }

    /*
     * If the bounds will flip about the x or y axis then apply the adjustment
     * up to the axis (ie.- where bounds width/height becomes 0), change the
     * cursor's orientation accordingly, and flip each Rectangle's origin (only
     * necessary for > 1 Rectangles)
     */
    if ((cursorOrientation & SWT.LEFT) !is 0) {
        if (xChange > bounds.width) {
            if ((style & SWT.RIGHT) is 0) return;
            cursorOrientation |= SWT.RIGHT;
            cursorOrientation &= ~SWT.LEFT;
            bounds.x += bounds.width;
            xChange -= bounds.width;
            bounds.width = 0;
            if (proportions.length > 1) {
                for (int i = 0; i < proportions.length; i++) {
                    Rectangle proportion = proportions [i];
                    proportion.x = 100 - proportion.x - proportion.width;
                }
            }
        }
    } else if ((cursorOrientation & SWT.RIGHT) !is 0) {
        if (bounds.width < -xChange) {
            if ((style & SWT.LEFT) is 0) return;
            cursorOrientation |= SWT.LEFT;
            cursorOrientation &= ~SWT.RIGHT;
            xChange += bounds.width;
            bounds.width = 0;
            if (proportions.length > 1) {
                for (int i = 0; i < proportions.length; i++) {
                    Rectangle proportion = proportions [i];
                    proportion.x = 100 - proportion.x - proportion.width;
                }
            }
        }
    }
    if ((cursorOrientation & SWT.UP) !is 0) {
        if (yChange > bounds.height) {
            if ((style & SWT.DOWN) is 0) return;
            cursorOrientation |= SWT.DOWN;
            cursorOrientation &= ~SWT.UP;
            bounds.y += bounds.height;
            yChange -= bounds.height;
            bounds.height = 0;
            if (proportions.length > 1) {
                for (int i = 0; i < proportions.length; i++) {
                    Rectangle proportion = proportions [i];
                    proportion.y = 100 - proportion.y - proportion.height;
                }
            }
        }
    } else if ((cursorOrientation & SWT.DOWN) !is 0) {
        if (bounds.height < -yChange) {
            if ((style & SWT.UP) is 0) return;
            cursorOrientation |= SWT.UP;
            cursorOrientation &= ~SWT.DOWN;
            yChange += bounds.height;
            bounds.height = 0;
            if (proportions.length > 1) {
                for (int i = 0; i < proportions.length; i++) {
                    Rectangle proportion = proportions [i];
                    proportion.y = 100 - proportion.y - proportion.height;
                }
            }
        }
    }

    // apply the bounds adjustment
    if ((cursorOrientation & SWT.LEFT) !is 0) {
        bounds.x += xChange;
        bounds.width -= xChange;
    } else if ((cursorOrientation & SWT.RIGHT) !is 0) {
        bounds.width += xChange;
    }
    if ((cursorOrientation & SWT.UP) !is 0) {
        bounds.y += yChange;
        bounds.height -= yChange;
    } else if ((cursorOrientation & SWT.DOWN) !is 0) {
        bounds.height += yChange;
    }

    Rectangle [] newRects = new Rectangle [rectangles.length];
    for (int i = 0; i < rectangles.length; i++) {
        Rectangle proportion = proportions[i];
        newRects[i] = new Rectangle (
            proportion.x * bounds.width / 100 + bounds.x,
            proportion.y * bounds.height / 100 + bounds.y,
            proportion.width * bounds.width / 100,
            proportion.height * bounds.height / 100);
    }
    rectangles = newRects;
}

/**
 * Sets the <code>Cursor</code> of the Tracker.  If this cursor is <code>null</code>
 * then the cursor reverts to the default.
 *
 * @param newCursor the new <code>Cursor</code> to display
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setCursor (Cursor value) {
    checkWidget ();
    cursor = value;
}

/**
 * Specifies the rectangles that should be drawn, expressed relative to the parent
 * widget.  If the parent is a Display then these are screen coordinates.
 *
 * @param rectangles the bounds of the rectangles to be drawn
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the set of rectangles contains a null rectangle</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setRectangles (Rectangle [] rectangles) {
    checkWidget();
    // SWT extension: allow null for zero length string
    //if (rectangles is null) error (SWT.ERROR_NULL_ARGUMENT);
    ptrdiff_t length = rectangles.length;
    this.rectangles = new Rectangle [length];
    for (int i = 0; i < length; i++) {
        Rectangle current = rectangles [i];
        if (current is null) error (SWT.ERROR_NULL_ARGUMENT);
        this.rectangles [i] = new Rectangle (current.x, current.y, current.width, current.height);
    }
    proportions = computeProportions (rectangles);
}

/**
 * Changes the appearance of the line used to draw the rectangles.
 *
 * @param stippled <code>true</code> if rectangle should appear stippled
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setStippled (bool stippled) {
    checkWidget();
    this.stippled = stippled;
}

void ungrab () {
    if (grabbed) OS.gdk_pointer_ungrab (OS.GDK_CURRENT_TIME);
}

void update () {
    if (parent !is null) {
        if (parent.isDisposed ()) return;
        parent.getShell ().update ();
    } else {
        display.update ();
    }
}

}
