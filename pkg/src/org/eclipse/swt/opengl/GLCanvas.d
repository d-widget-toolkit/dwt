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
 *      John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module org.eclipse.swt.opengl.GLCanvas;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.opengl.win32.WGL;
import org.eclipse.swt.internal.win32.OS;
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
    HGLRC context;
    int pixelFormat;

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
    PIXELFORMATDESCRIPTOR pfd;
    pfd.nSize = cast(short) PIXELFORMATDESCRIPTOR.sizeof;
    pfd.nVersion = 1;
    pfd.dwFlags = WGL.PFD_DRAW_TO_WINDOW | WGL.PFD_SUPPORT_OPENGL;
    pfd.dwLayerMask = WGL.PFD_MAIN_PLANE;
    pfd.iPixelType = cast(byte) WGL.PFD_TYPE_RGBA;
    if (data.doubleBuffer) pfd.dwFlags |= WGL.PFD_DOUBLEBUFFER;
    if (data.stereo) pfd.dwFlags |= WGL.PFD_STEREO;
    pfd.cRedBits = cast(byte) data.redSize;
    pfd.cGreenBits = cast(byte) data.greenSize;
    pfd.cBlueBits = cast(byte) data.blueSize;
    pfd.cAlphaBits = cast(byte) data.alphaSize;
    pfd.cDepthBits = cast(byte) data.depthSize;
    pfd.cStencilBits = cast(byte) data.stencilSize;
    pfd.cAccumRedBits = cast(byte) data.accumRedSize;
    pfd.cAccumGreenBits = cast(byte) data.accumGreenSize;
    pfd.cAccumBlueBits = cast(byte) data.accumBlueSize;
    pfd.cAccumAlphaBits = cast(byte) data.accumAlphaSize;
    pfd.cAccumBits = cast(byte) (pfd.cAccumRedBits + pfd.cAccumGreenBits + pfd.cAccumBlueBits + pfd.cAccumAlphaBits);
    
    //FIXME - use wglChoosePixelFormatARB
//  if (data.sampleBuffers > 0) {
//      wglAttrib [pos++] = WGL.WGL_SAMPLE_BUFFERS_ARB;
//      wglAttrib [pos++] = data.sampleBuffers;
//  }
//  if (data.samples > 0) {
//      wglAttrib [pos++] = WGL.WGL_SAMPLES_ARB;
//      wglAttrib [pos++] = data.samples;
//  }

    auto hDC = OS.GetDC (handle);
    pixelFormat = WGL.ChoosePixelFormat (hDC, &pfd);
    if (pixelFormat is 0 || !WGL.SetPixelFormat (hDC, pixelFormat, &pfd)) {
        OS.ReleaseDC (handle, hDC);
        dispose ();
        SWT.error (SWT.ERROR_UNSUPPORTED_DEPTH);
    }
    context = WGL.wglCreateContext (hDC);
    if (context is null) {
        OS.ReleaseDC (handle, hDC);
        SWT.error (SWT.ERROR_NO_HANDLES);
    }
    OS.ReleaseDC (handle, hDC);
    //FIXME- share lists
    //if (share !is null) WGL.wglShareLists (context, share.context);
    
    Listener listener = new class() Listener {
        public void handleEvent (Event event) {
            switch (event.type) {
                case SWT.Dispose:
                    WGL.wglDeleteContext (context);
                    break;
                default:
            }
        }
    };
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
    GLData data = new GLData ();
    PIXELFORMATDESCRIPTOR pfd;
    pfd.nSize = cast(short) PIXELFORMATDESCRIPTOR.sizeof;
    auto hDC = OS.GetDC (handle);
    WGL.DescribePixelFormat (hDC, pixelFormat, PIXELFORMATDESCRIPTOR.sizeof, &pfd);
    OS.ReleaseDC (handle, hDC);
    data.doubleBuffer = (pfd.dwFlags & WGL.PFD_DOUBLEBUFFER) !is 0;
    data.stereo = (pfd.dwFlags & WGL.PFD_STEREO) !is 0;
    data.redSize = pfd.cRedBits;
    data.greenSize = pfd.cGreenBits;
    data.blueSize = pfd.cBlueBits;
    data.alphaSize = pfd.cAlphaBits;
    data.depthSize = pfd.cDepthBits;
    data.stencilSize = pfd.cStencilBits;
    data.accumRedSize = pfd.cAccumRedBits;
    data.accumGreenSize = pfd.cAccumGreenBits;
    data.accumBlueSize = pfd.cAccumBlueBits;
    data.accumAlphaSize = pfd.cAccumAlphaBits;
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
    return (WGL.wglGetCurrentContext is context);
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
    if (WGL.wglGetCurrentContext is context) return;
    auto hDC = OS.GetDC (handle);
    WGL.wglMakeCurrent (hDC, context);
    OS.ReleaseDC (handle, hDC);
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
    auto hDC = OS.GetDC (handle);
    WGL.SwapBuffers (hDC);
    OS.ReleaseDC (handle, hDC);
}
}
