/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D Programming Language:
 *     John Reimer <terminal.node@gmail.com>
 *******************************************************************************/

module org.eclipse.swt.opengl.GLCanvas;

import java.lang.all;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.graphics.Rectangle;

import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.internal.c.glx;
import org.eclipse.swt.internal.c.gdk   : GdkWindowAttr, GdkDrawable;
import org.eclipse.swt.internal.c.Xutil : XVisualInfo;

import org.eclipse.swt.internal.opengl.glx.GLX;

import org.eclipse.swt.widgets.Canvas;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;

import org.eclipse.swt.opengl.GLData;

/**
 * GLCanvas is a widget capable of displaying OpenGL content.
 * 
 * @see GLData
 * @see <a href="http://www.eclipse.org/swt/snippets/#opengl">OpenGL snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 *
 * @since 3.2
 */

public class GLCanvas : Canvas {
    void* context;
    size_t   xWindow;
    GdkDrawable* glWindow;
    XVisualInfo vinfo;
    static const int MAX_ATTRIBUTES = 32;

/**
 * Create a GLCanvas widget using the attributes described in the GLData
 * object provided.
 *
 * @param parent a composite widget
 * @param style the bitwise OR'ing of widget styles
 * @param data the requested attributes of the GLCanvas
 *
 * @exception IllegalArgumentException
 * <ul><li>ERROR_NULL_ARGUMENT when the data is null
 *     <li>ERROR_UNSUPPORTED_DEPTH when the requested attributes cannot be provided</ul> 
 * </ul>
 */
public this (Composite parent, int style, GLData data) {
    super (parent, style);  
    if (data is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    int[MAX_ATTRIBUTES] glxAttrib;
    int pos = 0;
    glxAttrib [pos++] = GLX.GLX_RGBA;
    if (data.doubleBuffer) glxAttrib [pos++] = GLX.GLX_DOUBLEBUFFER;
    if (data.stereo) glxAttrib [pos++] = GLX.GLX_STEREO;
    if (data.redSize > 0) {
        glxAttrib [pos++] = GLX.GLX_RED_SIZE;
        glxAttrib [pos++] = data.redSize;
    }
    if (data.greenSize > 0) {
        glxAttrib [pos++] = GLX.GLX_GREEN_SIZE;
        glxAttrib [pos++] = data.greenSize;
    }
    if (data.blueSize > 0) {
        glxAttrib [pos++] = GLX.GLX_BLUE_SIZE;
        glxAttrib [pos++] = data.blueSize;
    }
    if (data.alphaSize > 0) {
        glxAttrib [pos++] = GLX.GLX_ALPHA_SIZE;
        glxAttrib [pos++] = data.alphaSize;
    }
    if (data.depthSize > 0) {
        glxAttrib [pos++] = GLX.GLX_DEPTH_SIZE;
        glxAttrib [pos++] = data.depthSize;
    }
    if (data.stencilSize > 0) {
        glxAttrib [pos++] = GLX.GLX_STENCIL_SIZE;
        glxAttrib [pos++] = data.stencilSize;
    }
    if (data.accumRedSize > 0) {
        glxAttrib [pos++] = GLX.GLX_ACCUM_RED_SIZE;
        glxAttrib [pos++] = data.accumRedSize;
    }
    if (data.accumGreenSize > 0) {
        glxAttrib [pos++] = GLX.GLX_ACCUM_GREEN_SIZE;
        glxAttrib [pos++] = data.accumGreenSize;
    }
    if (data.accumBlueSize > 0) {
        glxAttrib [pos++] = GLX.GLX_ACCUM_BLUE_SIZE;
        glxAttrib [pos++] = data.accumBlueSize;
    }
    if (data.accumAlphaSize > 0) {
        glxAttrib [pos++] = GLX.GLX_ACCUM_ALPHA_SIZE;
        glxAttrib [pos++] = data.accumAlphaSize;
    }
    if (data.sampleBuffers > 0) {
        glxAttrib [pos++] = GLX.GLX_SAMPLE_BUFFERS;
        glxAttrib [pos++] = data.sampleBuffers;
    }
    if (data.samples > 0) {
        glxAttrib [pos++] = GLX.GLX_SAMPLES;
        glxAttrib [pos++] = data.samples;
    }
    glxAttrib [pos++] = 0;
    OS.gtk_widget_realize (handle);
    auto window = OS.GTK_WIDGET_WINDOW (handle);
    auto xDisplay = OS.gdk_x11_drawable_get_xdisplay (window);
    auto infoPtr = GLX.glXChooseVisual (xDisplay, OS.XDefaultScreen (xDisplay), glxAttrib.ptr);
    if (infoPtr is null) {
        dispose ();
        SWT.error (SWT.ERROR_UNSUPPORTED_DEPTH);
    }

    vinfo = *infoPtr;
    //tango.stdc.string.memmove (vinfo, infoPtr, XVisualInfo.sizeof);
    OS.XFree (infoPtr);
    auto screen = OS.gdk_screen_get_default ();
    auto gdkvisual = OS.gdk_x11_screen_lookup_visual (screen, vinfo.visualid);
    //FIXME- share lists
    //context = GLX.glXCreateContext (xDisplay, info, share is null ? 0 : share.context, true);
    context = GLX.glXCreateContext (xDisplay, &vinfo, null, true);
    if (context is null) 
        SWT.error (SWT.ERROR_NO_HANDLES);
    GdkWindowAttr attrs;
    attrs.width = 1;
    attrs.height = 1;
    attrs.event_mask = OS.GDK_KEY_PRESS_MASK | OS.GDK_KEY_RELEASE_MASK |
        OS.GDK_FOCUS_CHANGE_MASK | OS.GDK_POINTER_MOTION_MASK |
        OS.GDK_BUTTON_PRESS_MASK | OS.GDK_BUTTON_RELEASE_MASK |
        OS.GDK_ENTER_NOTIFY_MASK | OS.GDK_LEAVE_NOTIFY_MASK |
        OS.GDK_EXPOSURE_MASK | OS.GDK_VISIBILITY_NOTIFY_MASK |
        OS.GDK_POINTER_MOTION_HINT_MASK;
    attrs.window_type = OS.GDK_WINDOW_CHILD;
    attrs.visual = gdkvisual;
    glWindow = OS.gdk_window_new (window, &attrs, OS.GDK_WA_VISUAL);
    OS.gdk_window_set_user_data ( glWindow, cast(void*) handle);
    if ((style & SWT.NO_BACKGROUND) !is 0) 
        OS.gdk_window_set_back_pixmap (window, null, false);
    xWindow = OS.gdk_x11_drawable_get_xid ( glWindow );
    OS.gdk_window_show (glWindow);

    Listener listener = new class() Listener {
        public void handleEvent (Event event) {
            switch (event.type) {
            case SWT.Paint:
                /**
                * Bug in MESA.  MESA does some nasty sort of polling to try
                * to ensure that their buffer sizes match the current X state.
                * This state can be updated using glViewport().
                * FIXME: There has to be a better way of doing this.
                */
                int[4] viewport;
                GLX.glGetIntegerv (GLX.GL_VIEWPORT, viewport);
                GLX.glViewport (viewport [0],viewport [1],viewport [2],viewport [3]);
                break;
            case SWT.Resize:
                Rectangle clientArea = getClientArea();
                OS.gdk_window_move (glWindow, clientArea.x, clientArea.y);
                OS.gdk_window_resize (glWindow, clientArea.width, clientArea.height);
                break;
            case SWT.Dispose:
                auto window = OS.GTK_WIDGET_WINDOW (handle);
                auto xDisplay = OS.gdk_x11_drawable_get_xdisplay (window);
                if (context !is null) {
                    if (GLX.glXGetCurrentContext () is context) {
                        GLX.glXMakeCurrent (xDisplay, 0, null);
                    }
                    GLX.glXDestroyContext (xDisplay, context);
                    context = null;
                }
                if (glWindow !is null) {
                    OS.gdk_window_destroy (glWindow);
                    glWindow = null;
                }
                break;
            default: break;
            }
        }
    };
    addListener (SWT.Resize, listener);
    addListener (SWT.Paint, listener);
    addListener (SWT.Dispose, listener);
}

/**
 * Returns a GLData object describing the created context.
 *  
 * @return GLData description of the OpenGL context attributes
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public GLData getGLData () {
    checkWidget ();
    auto window = OS.GTK_WIDGET_WINDOW (handle);
    auto xDisplay = OS.gdk_x11_drawable_get_xdisplay (window);
    GLData data = new GLData ();
    int [1] value;
    GLX.glXGetConfig (xDisplay, &vinfo, GLX.GLX_DOUBLEBUFFER, value);
    data.doubleBuffer = value [0] !is 0;
    GLX.glXGetConfig (xDisplay, &vinfo, GLX.GLX_STEREO, value);
    data.stereo = value [0] !is 0;
    GLX.glXGetConfig (xDisplay, &vinfo, GLX.GLX_RED_SIZE, value);
    data.redSize = value [0];
    GLX.glXGetConfig (xDisplay, &vinfo, GLX.GLX_GREEN_SIZE, value);
    data.greenSize = value [0];
    GLX.glXGetConfig (xDisplay, &vinfo, GLX.GLX_BLUE_SIZE, value);
    data.blueSize = value [0];
    GLX.glXGetConfig (xDisplay, &vinfo, GLX.GLX_ALPHA_SIZE, value);
    data.alphaSize = value [0];
    GLX.glXGetConfig (xDisplay, &vinfo, GLX.GLX_DEPTH_SIZE, value);
    data.depthSize = value [0];
    GLX.glXGetConfig (xDisplay, &vinfo, GLX.GLX_STENCIL_SIZE, value);
    data.stencilSize = value [0];
    GLX.glXGetConfig (xDisplay, &vinfo, GLX.GLX_ACCUM_RED_SIZE, value);
    data.accumRedSize = value [0];
    GLX.glXGetConfig (xDisplay, &vinfo, GLX.GLX_ACCUM_GREEN_SIZE, value);
    data.accumGreenSize = value [0];
    GLX.glXGetConfig (xDisplay, &vinfo, GLX.GLX_ACCUM_BLUE_SIZE, value);
    data.accumBlueSize = value [0];
    GLX.glXGetConfig (xDisplay, &vinfo, GLX.GLX_ACCUM_ALPHA_SIZE, value);
    data.accumAlphaSize = value [0];
    GLX.glXGetConfig (xDisplay, &vinfo, GLX.GLX_SAMPLE_BUFFERS, value);
    data.sampleBuffers = value [0];
    GLX.glXGetConfig (xDisplay, &vinfo, GLX.GLX_SAMPLES, value);
    data.samples = value [0];
    return data;
}

/**
 * Returns a bool indicating whether the receiver's OpenGL context
 * is the current context.
 *  
 * @return true if the receiver holds the current OpenGL context,
 * false otherwise
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public bool isCurrent () {
    checkWidget ();
    return (GLX.glXGetCurrentContext () is context);
}

/**
 * Sets the OpenGL context associated with this GLCanvas to be the
 * current GL context.
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void setCurrent () {
    checkWidget ();
    if (GLX.glXGetCurrentContext () is context) return;
    auto window = OS.GTK_WIDGET_WINDOW (handle);
    auto xDisplay = OS.gdk_x11_drawable_get_xdisplay (window);
    GLX.glXMakeCurrent (xDisplay, xWindow, context);
}

/**
 * Swaps the front and back color buffers.
 * 
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the receiver has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the receiver</li>
 * </ul>
 */
public void swapBuffers () {
    checkWidget ();
    auto window = OS.GTK_WIDGET_WINDOW (handle);
    auto xDisplay = OS.gdk_x11_drawable_get_xdisplay (window);
    GLX.glXSwapBuffers (xDisplay, xWindow);
}
}
