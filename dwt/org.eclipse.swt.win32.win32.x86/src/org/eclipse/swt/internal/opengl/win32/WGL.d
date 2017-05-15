/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
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
module org.eclipse.swt.internal.opengl.win32.WGL;

import org.eclipse.swt.internal.Library;
import org.eclipse.swt.internal.Platform;

private import org.eclipse.swt.internal.win32.WINAPI;
static import org.eclipse.swt.internal.opengl.win32.native;
alias org.eclipse.swt.internal.opengl.win32.native OPENGL_NATIVE;
public class WGL : Platform { 

public:
    enum : int {
        WGL_FONT_LINES      = 0,
        WGL_FONT_POLYGONS   = 1,
    
    /* LAYERPLANEDESCRIPTOR flags */
        LPD_DOUBLEBUFFER        = 0x00000001,
        LPD_STEREO              = 0x00000002,
        LPD_SUPPORT_GDI         = 0x00000010,
        LPD_SUPPORT_OPENGL      = 0x00000020,
        LPD_SHARE_DEPTH         = 0x00000040,
        LPD_SHARE_STENCIL       = 0x00000080,
        LPD_SHARE_ACCUM         = 0x00000100,
        LPD_SWAP_EXCHANGE       = 0x00000200,
        LPD_SWAP_COPY           = 0x00000400,
        LPD_TRANSPARENT         = 0x00001000,
    
        LPD_TYPE_RGBA        = 0,
        LPD_TYPE_COLORINDEX  = 1,
    
    /* wglSwapLayerBuffers flags */
        WGL_SWAP_MAIN_PLANE     = 0x00000001,
        WGL_SWAP_OVERLAY1       = 0x00000002,
        WGL_SWAP_OVERLAY2       = 0x00000004,
        WGL_SWAP_OVERLAY3       = 0x00000008,
        WGL_SWAP_OVERLAY4       = 0x00000010,
        WGL_SWAP_OVERLAY5       = 0x00000020,
        WGL_SWAP_OVERLAY6       = 0x00000040,
        WGL_SWAP_OVERLAY7       = 0x00000080,
        WGL_SWAP_OVERLAY8       = 0x00000100,
        WGL_SWAP_OVERLAY9       = 0x00000200,
        WGL_SWAP_OVERLAY10      = 0x00000400,
        WGL_SWAP_OVERLAY11      = 0x00000800,
        WGL_SWAP_OVERLAY12      = 0x00001000,
        WGL_SWAP_OVERLAY13      = 0x00002000,
        WGL_SWAP_OVERLAY14      = 0x00004000,
        WGL_SWAP_OVERLAY15      = 0x00008000,
        WGL_SWAP_UNDERLAY1      = 0x00010000,
        WGL_SWAP_UNDERLAY2      = 0x00020000,
        WGL_SWAP_UNDERLAY3      = 0x00040000,
        WGL_SWAP_UNDERLAY4      = 0x00080000,
        WGL_SWAP_UNDERLAY5      = 0x00100000,
        WGL_SWAP_UNDERLAY6      = 0x00200000,
        WGL_SWAP_UNDERLAY7      = 0x00400000,
        WGL_SWAP_UNDERLAY8      = 0x00800000,
        WGL_SWAP_UNDERLAY9      = 0x01000000,
        WGL_SWAP_UNDERLAY10     = 0x02000000,
        WGL_SWAP_UNDERLAY11     = 0x04000000,
        WGL_SWAP_UNDERLAY12     = 0x08000000,
        WGL_SWAP_UNDERLAY13     = 0x10000000,
        WGL_SWAP_UNDERLAY14     = 0x20000000,
        WGL_SWAP_UNDERLAY15     = 0x40000000,
    
    /* pixel types */
        PFD_TYPE_RGBA        = 0,
        PFD_TYPE_COLORINDEX  = 1,
    
    /* layer types */
        PFD_MAIN_PLANE       = 0,
        PFD_OVERLAY_PLANE    = 1,
        PFD_UNDERLAY_PLANE   = -1,
    
    /* PIXELFORMATDESCRIPTOR flags */
        PFD_DOUBLEBUFFER            = 0x00000001,
        PFD_STEREO                  = 0x00000002,
        PFD_DRAW_TO_WINDOW          = 0x00000004,
        PFD_DRAW_TO_BITMAP          = 0x00000008,
        PFD_SUPPORT_GDI             = 0x00000010,
        PFD_SUPPORT_OPENGL          = 0x00000020,
        PFD_GENERIC_FORMAT          = 0x00000040,
        PFD_NEED_PALETTE            = 0x00000080,
        PFD_NEED_SYSTEM_PALETTE     = 0x00000100,
        PFD_SWAP_EXCHANGE           = 0x00000200,
        PFD_SWAP_COPY               = 0x00000400,
        PFD_SWAP_LAYER_BUFFERS      = 0x00000800,
        PFD_GENERIC_ACCELERATED     = 0x00001000,
        PFD_SUPPORT_DIRECTDRAW      = 0x00002000,
    
    /* PIXELFORMATDESCRIPTOR flags for use in ChoosePixelFormat only */
        PFD_DEPTH_DONTCARE          = 0x20000000,
        PFD_DOUBLEBUFFER_DONTCARE   = 0x40000000,
        PFD_STEREO_DONTCARE         = 0x80000000
    }

    alias OPENGL_NATIVE.ChoosePixelFormat            ChoosePixelFormat;
    alias OPENGL_NATIVE.DescribePixelFormat          DescribePixelFormat;
    alias OPENGL_NATIVE.GetPixelFormat               GetPixelFormat;
    alias OPENGL_NATIVE.SetPixelFormat               SetPixelFormat;
    alias OPENGL_NATIVE.SwapBuffers                  SwapBuffers;
    
    alias OPENGL_NATIVE.wglCopyContext               wglCopyContext;
    alias OPENGL_NATIVE.wglCreateContext             wglCreateContext;
    alias OPENGL_NATIVE.wglCreateLayerContext        wglCreateLayerContext;
    alias OPENGL_NATIVE.wglDeleteContext             wglDeleteContext;
    alias OPENGL_NATIVE.wglGetCurrentContext         wglGetCurrentContext;
    alias OPENGL_NATIVE.wglGetCurrentDC              wglGetCurrentDC;
    alias OPENGL_NATIVE.wglGetProcAddress            wglGetProcAddress;
    alias OPENGL_NATIVE.wglMakeCurrent               wglMakeCurrent;
    alias OPENGL_NATIVE.wglShareLists                wglShareLists;
    alias OPENGL_NATIVE.wglDescribeLayerPlane        wglDescribeLayerPlane;
    alias OPENGL_NATIVE.wglSetLayerPaletteEntries    wglSetLayerPaletteEntries;
    alias OPENGL_NATIVE.wglGetLayerPaletteEntries    wglGetLayerPaletteEntries;
    alias OPENGL_NATIVE.wglRealizeLayerPalette       wglRealizeLayerPalette;
    alias OPENGL_NATIVE.wglSwapLayerBuffers          wglSwapLayerBuffers;
}
