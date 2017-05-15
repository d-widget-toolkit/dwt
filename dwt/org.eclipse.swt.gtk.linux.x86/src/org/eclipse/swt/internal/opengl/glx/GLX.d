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
module org.eclipse.swt.internal.opengl.glx.GLX;

import java.lang.all;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

import org.eclipse.swt.internal.Library;
import org.eclipse.swt.internal.Platform;
import org.eclipse.swt.internal.c.X;
import org.eclipse.swt.internal.c.Xutil;
import org.eclipse.swt.internal.c.glx;

public class GLX : Platform {

    /*
    ** Visual Config Attributes (glXGetConfig, glXGetFBConfigAttrib)
    */

    enum {
        GLX_USE_GL              = 1,    /* support GLX rendering */
        GLX_BUFFER_SIZE         = 2,    /* depth of the color buffer */
        GLX_LEVEL               = 3,    /* level in plane stacking */
        GLX_RGBA                = 4,    /* true if RGBA mode */
        GLX_DOUBLEBUFFER        = 5,    /* double buffering supported */
        GLX_STEREO              = 6,    /* stereo buffering supported */
        GLX_AUX_BUFFERS         = 7,    /* number of aux buffers */
        GLX_RED_SIZE            = 8,    /* number of red component bits */
        GLX_GREEN_SIZE          = 9,    /* number of green component bits */
        GLX_BLUE_SIZE           = 10,   /* number of blue component bits */
        GLX_ALPHA_SIZE          = 11,   /* number of alpha component bits */
        GLX_DEPTH_SIZE          = 12,   /* number of depth bits */
        GLX_STENCIL_SIZE        = 13,   /* number of stencil bits */
        GLX_ACCUM_RED_SIZE      = 14,   /* number of red accum bits */
        GLX_ACCUM_GREEN_SIZE    = 15,   /* number of green accum bits */
        GLX_ACCUM_BLUE_SIZE     = 16,   /* number of blue accum bits */
        GLX_ACCUM_ALPHA_SIZE    = 17,   /* number of alpha accum bits */
    /*
    ** FBConfig-specific attributes
    */
        GLX_X_VISUAL_TYPE       = 0x22,
        GLX_CONFIG_CAVEAT       = 0x20, /* Like visual_info VISUAL_CAVEAT_EXT */
        GLX_TRANSPARENT_TYPE    = 0x23,
        GLX_TRANSPARENT_INDEX_VALUE = 0x24,
        GLX_TRANSPARENT_RED_VALUE   = 0x25,
        GLX_TRANSPARENT_GREEN_VALUE = 0x26,
        GLX_TRANSPARENT_BLUE_VALUE  = 0x27,
        GLX_TRANSPARENT_ALPHA_VALUE = 0x28,
        GLX_DRAWABLE_TYPE       = 0x8010,
        GLX_RENDER_TYPE         = 0x8011,
        GLX_X_RENDERABLE        = 0x8012,
        GLX_FBCONFIG_ID         = 0x8013,
        GLX_MAX_PBUFFER_WIDTH   = 0x8016,
        GLX_MAX_PBUFFER_HEIGHT  = 0x8017,
        GLX_MAX_PBUFFER_PIXELS  = 0x8018,
        GLX_VISUAL_ID           = 0x800B,
    
    /*
    ** Error return values from glXGetConfig.  Success is indicated by
    ** a value of 0.
    */
        GLX_BAD_SCREEN      = 1,    /* screen # is bad */
        GLX_BAD_ATTRIBUTE   = 2,    /* attribute to get is bad */
        GLX_NO_EXTENSION    = 3,    /* no glx extension on server */
        GLX_BAD_VISUAL      = 4,    /* visual # not known by GLX */
        GLX_BAD_CONTEXT     = 5,    /* returned only by import_context EXT? */
        GLX_BAD_VALUE       = 6,    /* returned only by glXSwapIntervalSGI? */
        GLX_BAD_ENUM        = 7,    /* unused? */
    
    /* FBConfig attribute values */
    
    /*
    ** Generic "don't care" value for glX ChooseFBConfig attributes (except
    ** GLX_LEVEL)
    */
        GLX_DONT_CARE           = 0xFFFFFFFF,
    
    /* GLX_RENDER_TYPE bits */
        GLX_RGBA_BIT            = 0x00000001,
        GLX_COLOR_INDEX_BIT     = 0x00000002,
    
    /* GLX_DRAWABLE_TYPE bits */
        GLX_WINDOW_BIT          = 0x00000001,
        GLX_PIXMAP_BIT          = 0x00000002,
        GLX_PBUFFER_BIT         = 0x00000004,
    
    /* GLX_CONFIG_CAVEAT attribute values */
        GLX_NONE                = 0x8000,
        GLX_SLOW_CONFIG         = 0x8001,
        GLX_NON_CONFORMANT_CONFIG   = 0x800D,
    
    /* GLX_X_VISUAL_TYPE attribute values */
        GLX_TRUE_COLOR          = 0x8002,
        GLX_DIRECT_COLOR        = 0x8003,
        GLX_PSEUDO_COLOR        = 0x8004,
        GLX_STATIC_COLOR        = 0x8005,
        GLX_GRAY_SCALE          = 0x8006,
        GLX_STATIC_GRAY         = 0x8007,
    
    /* GLX_TRANSPARENT_TYPE attribute values */
    /*     GLX_NONE            0x8000 */
        GLX_TRANSPARENT_RGB     = 0x8008,
        GLX_TRANSPARENT_INDEX   = 0x8009,
    
    /* glXCreateGLXPbuffer attributes */
        GLX_PRESERVED_CONTENTS  = 0x801B,
        GLX_LARGEST_PBUFFER     = 0x801C,
        GLX_PBUFFER_HEIGHT      = 0x8040,   /* New for GLX 1.3 */
        GLX_PBUFFER_WIDTH       = 0x8041,   /* New for GLX 1.3 */
    
    /* glXQueryGLXPBuffer attributes */
        GLX_WIDTH       = 0x801D,
        GLX_HEIGHT      = 0x801E,
        GLX_EVENT_MASK  = 0x801F,
    
    /* glXCreateNewContext render_type attribute values */
        GLX_RGBA_TYPE           = 0x8014,
        GLX_COLOR_INDEX_TYPE    = 0x8015,
    
    /* glXQueryContext attributes */
    /*     GLX_FBCONFIG_ID        0x8013 */
    /*     GLX_RENDER_TYPE        0x8011 */
        GLX_SCREEN          = 0x800C,
    
    /* glXSelectEvent event mask bits */
        GLX_PBUFFER_CLOBBER_MASK    = 0x08000000,
    
    /* GLXPbufferClobberEvent event_type values */
        GLX_DAMAGED         = 0x8020,
        GLX_SAVED           = 0x8021,
    
    /* GLXPbufferClobberEvent draw_type values */
        GLX_WINDOW          = 0x8022,
        GLX_PBUFFER         = 0x8023,
    
    /* GLXPbufferClobberEvent buffer_mask bits */
        GLX_FRONT_LEFT_BUFFER_BIT   = 0x00000001,
        GLX_FRONT_RIGHT_BUFFER_BIT  = 0x00000002,
        GLX_BACK_LEFT_BUFFER_BIT    = 0x00000004,
        GLX_BACK_RIGHT_BUFFER_BIT   = 0x00000008,
        GLX_AUX_BUFFERS_BIT     = 0x00000010,
        GLX_DEPTH_BUFFER_BIT        = 0x00000020,
        GLX_STENCIL_BUFFER_BIT      = 0x00000040,
        GLX_ACCUM_BUFFER_BIT        = 0x00000080,
    
    /*
    ** Extension return values from glXGetConfig.  These are also
    ** accepted as parameter values for glXChooseVisual.
    */
    
        GLX_X_VISUAL_TYPE_EXT = 0x22,   /* visual_info extension type */
        GLX_TRANSPARENT_TYPE_EXT = 0x23,    /* visual_info extension */
        GLX_TRANSPARENT_INDEX_VALUE_EXT = 0x24, /* visual_info extension */
        GLX_TRANSPARENT_RED_VALUE_EXT   = 0x25, /* visual_info extension */
        GLX_TRANSPARENT_GREEN_VALUE_EXT = 0x26, /* visual_info extension */
        GLX_TRANSPARENT_BLUE_VALUE_EXT  = 0x27, /* visual_info extension */
        GLX_TRANSPARENT_ALPHA_VALUE_EXT = 0x28, /* visual_info extension */
    
    /* Property values for visual_type */
        GLX_TRUE_COLOR_EXT  = 0x8002,
        GLX_DIRECT_COLOR_EXT    = 0x8003,
        GLX_PSEUDO_COLOR_EXT    = 0x8004,
        GLX_STATIC_COLOR_EXT    = 0x8005,
        GLX_GRAY_SCALE_EXT  = 0x8006,
        GLX_STATIC_GRAY_EXT = 0x8007,
    
    /* Property values for transparent pixel */
        GLX_NONE_EXT        = 0x8000,
        GLX_TRANSPARENT_RGB_EXT     = 0x8008,
        GLX_TRANSPARENT_INDEX_EXT   = 0x8009,
    
    /* Property values for visual_rating */
        GLX_VISUAL_CAVEAT_EXT       = 0x20,  /* visual_rating extension type */
        GLX_SLOW_VISUAL_EXT     = 0x8001,
        GLX_NON_CONFORMANT_VISUAL_EXT   = 0x800D,
    
    /*
    ** Names for attributes to glXGetClientString.
    */
        GLX_VENDOR      = 0x1,
        GLX_VERSION     = 0x2,
        GLX_EXTENSIONS  = 0x3,
    
    /*
    ** Names for attributes to glXQueryContextInfoEXT.
    */
        GLX_SHARE_CONTEXT_EXT = 0x800A, /* id of share context */
        GLX_VISUAL_ID_EXT = 0x800B, /* id of context's visual */
        GLX_SCREEN_EXT = 0x800C,    /* screen number */
    
    /*
    * GLX 1.4 
    */
        GLX_SAMPLE_BUFFERS = 100000,
        GLX_SAMPLES = 100001,

    /*
    * GL bits 
    */
        GL_VIEWPORT = 0x0BA2
    }

    static this() {
        org.eclipse.swt.internal.c.glx.loadLib();
    }
    
    static void glGetIntegerv( GLenum pname, GLint[] params ) 
    {
        lock.lock();
        scope(exit) lock.unlock();
        return dwt_glGetIntegerv (pname, params.ptr );
    }

    static void glViewport( GLint x, GLint y, GLsizei width, GLsizei height ) 
    {
        lock.lock();
        scope(exit) lock.unlock();
        return dwt_glViewport( x, y, width, height );
    }

    static XVisualInfo* glXChooseVisual( void* dpy, GLint screen, GLint* attribList ) 
    {
        lock.lock();
        scope(exit) lock.unlock();
        return dwt_glXChooseVisual( dpy, screen, attribList );
    }

    static void glXCopyContext( void* dpy, void* src, void* dst, GLulong mask ) 
    {
        lock.lock();
        scope(exit) lock.unlock();
        dwt_glXCopyContext(dpy, src, dst, mask);
    }

    static void* glXCreateContext( void* dpy, XVisualInfo* vis, void* shareList, Bool direct ) 
    {
        lock.lock();
        scope(exit) lock.unlock();        
        return dwt_glXCreateContext(dpy, vis, shareList, direct);
    }

    final GLXPixmap glXCreateGLXPixmap( void* dpy, XVisualInfo* vis , Pixmap pixmap ) 
    {
        lock.lock();
        scope(exit) lock.unlock();
        return dwt_glXCreateGLXPixmap(dpy, vis, pixmap);
    }

    static void glXDestroyContext( void* dpy, void* ctx ) 
    {
        lock.lock();
        scope(exit) lock.unlock();
        dwt_glXDestroyContext(dpy, ctx);
    }

    static void glXDestroyGLXPixmap( void* dpy, GLXPixmap pix ) 
    {
        lock.lock();
        scope(exit) lock.unlock();
        dwt_glXDestroyGLXPixmap(dpy, pix);
    }

    static char* glXGetClientString( void* dpy, GLint name ) 
    {
        lock.lock();
        scope(exit) lock.unlock();
        return dwt_glXGetClientString(dpy, name);
    }

    static GLint glXGetConfig( void* dpy, XVisualInfo* vis, GLint attrib, GLint[] value ) 
    {
        lock.lock();
        scope(exit) lock.unlock();
        return dwt_glXGetConfig(dpy, vis, attrib, value.ptr);
    }

    static void* glXGetCurrentContext() 
    {
        lock.lock();
        scope(exit) lock.unlock();
        return dwt_glXGetCurrentContext();
    }

    static GLXDrawable glXGetCurrentDrawable() 
    {
        lock.lock();
        scope(exit) lock.unlock();
        return dwt_glXGetCurrentDrawable();
    }

    static Bool glXIsDirect( void* dpy, void* ctx ) 
    {
        lock.lock();
        scope(exit) lock.unlock();    
        return dwt_glXIsDirect(dpy, ctx);
    }

    static Bool glXMakeCurrent( void* dpy, GLXDrawable drawable, void* ctx) 
    {
        lock.lock();
        scope(exit) lock.unlock();
        return dwt_glXMakeCurrent(dpy, drawable, ctx);
    }

    static Bool glXQueryExtension( void* dpy, GLint[] errorBase, GLint[] eventBase) 
    {
        lock.lock();
        scope(exit) lock.unlock(); 
        return dwt_glXQueryExtension(dpy, errorBase.ptr, eventBase.ptr);
    }

    static char* glXQueryExtensionsString( void* dpy, GLint screen) 
    {
        lock.lock();
        scope(exit) lock.unlock();
        return dwt_glXQueryExtensionsString(dpy, screen);
    }

    static char* glXQueryServerString( void* dpy, GLint screen, GLint name ) 
    {
        lock.lock();
        scope(exit) lock.unlock();
        return dwt_glXQueryServerString(dpy, screen, name);
    }

    static Bool glXQueryVersion( void* dpy, GLint[] major, GLint[] minor ) 
    {
        lock.lock();
        scope(exit) lock.unlock();
        return dwt_glXQueryVersion(dpy, major.ptr, minor.ptr);
    }

    static void glXSwapBuffers( void* dpy, GLXDrawable drawable ) 
    {
        lock.lock();
        scope(exit) lock.unlock();
        dwt_glXSwapBuffers(dpy, drawable);
    }

    static void glXWaitGL() 
    {
        lock.lock();
        scope(exit) lock.unlock();
        dwt_glXWaitGL();
    }

    static void glXWaitX() 
    {
        lock.lock();
        scope(exit) lock.unlock();
        dwt_glXWaitX();
    }
}
