/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <keinfarbton@googlemail.com>
******************************************************************************/
module org.eclipse.swt.internal.c.glx;

private import org.eclipse.swt.internal.c.X;

import java.lang.all;

public import org.eclipse.swt.internal.c.Xutil;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

version=DYNLINK;

version(DYNLINK){
    import java.nonstandard.SharedLib;
}

void loadLib(){
    version(DYNLINK){
        SharedLib.loadLibSymbols( symbols, "libGL.so" );
    }
}

extern(C):

alias c_int GLint;
alias c_uint GLuint;
alias c_long GLlong;
alias c_ulong GLulong;
alias GLint Bool;
alias GLint GLsizei;
alias GLuint GLenum;
alias __GLXEvent GLXEvent;
alias XID GLXDrawable;
alias void * GLXFBConfig;
alias void * GLXContext;
alias XID GLXFBConfigID;
alias XID GLXWindow;
alias XID GLXPbuffer;
alias XID GLXPixmap;
alias XID GLXContextID;
alias void function() _BCD_func__2197;
union __GLXEvent {
GLXPbufferClobberEvent glxpbufferclobber;
GLlong [24] pad;
}
struct GLXPbufferClobberEvent {
GLint event_type;
GLint draw_type;
GLulong serial;
Bool send_event;
void * display;
GLXDrawable drawable;
GLuint buffer_mask;
GLuint aux_buffer;
GLint x;
GLint y;
GLint width;
GLint height;
GLint count;
}

version(DYNLINK){
mixin(gshared!(
"extern (C) void function(GLenum, GLint*) dwt_glGetIntegerv;
extern (C) void function(GLint,GLint,GLsizei,GLsizei) dwt_glViewport;

extern (C) GLint function(GLint)dwt_glXSwapIntervalSGI;
extern (C) _BCD_func__2197 function(char *)dwt_glXGetProcAddressARB;
extern (C) Bool function(void *, GLXDrawable, void *)dwt_glXMakeCurrent;
extern (C) void * function(void *, XVisualInfo *, void *, Bool)dwt_glXCreateContext;
extern (C) void function(void *, GLXPixmap)dwt_glXDestroyGLXPixmap;
extern (C) GLXPixmap function(void *, XVisualInfo *, Pixmap)dwt_glXCreateGLXPixmap;
extern (C) XVisualInfo * function(void *, GLint, GLint *)dwt_glXChooseVisual;
extern (C) GLint function(void *, XVisualInfo *, GLint, GLint *)dwt_glXGetConfig;
extern (C) void function(Font, GLint, GLint, GLint)dwt_glXUseXFont;
extern (C) void function(void *, GLXDrawable)dwt_glXSwapBuffers;
extern (C) void function()dwt_glXWaitX;
extern (C) void function()dwt_glXWaitGL;
extern (C) void function(void *, GLXDrawable, GLulong *)dwt_glXGetSelectedEvent;
extern (C) void function(void *, GLXDrawable, GLulong)dwt_glXSelectEvent;
extern (C) GLint function(void *, void *, GLint, GLint *)dwt_glXQueryContext;
extern (C) void * function()dwt_glXGetCurrentDisplay;
extern (C) GLXDrawable function()dwt_glXGetCurrentReadDrawable;
extern (C) GLXDrawable function()dwt_glXGetCurrentDrawable;
extern (C) void * function()dwt_glXGetCurrentContext;
extern (C) void function(void *, void *, void *, GLulong)dwt_glXCopyContext;
extern (C) Bool function(void *, GLXDrawable, GLXDrawable, void *)dwt_glXMakeContextCurrent;
extern (C) void function(void *, void *)dwt_glXDestroyContext;
extern (C) Bool function(void *, void *)dwt_glXIsDirect;
extern (C) void * function(void *, void *, GLint, void *, Bool)dwt_glXCreateNewContext;
extern (C) void function(void *, GLXDrawable, GLint, GLuint *)dwt_glXQueryDrawable;
extern (C) void function(void *, GLXPbuffer)dwt_glXDestroyPbuffer;
extern (C) GLXPbuffer function(void *, void *, const GLint *)dwt_glXCreatePbuffer;
extern (C) void function(void *, GLXPixmap)dwt_glXDestroyPixmap;
extern (C) GLXPixmap function(void *, void *, Pixmap, const GLint *)dwt_glXCreatePixmap;
extern (C) void function(void *, GLXWindow)dwt_glXDestroyWindow;
extern (C) GLXWindow function(void *, void *, Window, const GLint *)dwt_glXCreateWindow;
extern (C) XVisualInfo * function(void *, void *)dwt_glXGetVisualFromFBConfig;
extern (C) GLint function(void *, void *, GLint, GLint *)dwt_glXGetFBConfigAttrib;
extern (C) void * * function(void *, GLint, const GLint *, GLint *)dwt_glXChooseFBConfig;
extern (C) void * * function(void *, GLint, GLint *)dwt_glXGetFBConfigs;
extern (C) char * function(void *, GLint, GLint)dwt_glXQueryServerString;
extern (C) char * function(void *, GLint)dwt_glXGetClientString;
extern (C) char * function(void *, GLint)dwt_glXQueryExtensionsString;
extern (C) Bool function(void *, GLint *, GLint *)dwt_glXQueryVersion;
extern (C) Bool function(void *, GLint *, GLint *)dwt_glXQueryExtension;"
));

Symbol[] symbols;
static this () {
    symbols = [
        Symbol("glGetIntegerv", cast(void**)& dwt_glGetIntegerv),
        Symbol("glViewport", cast(void**)& dwt_glViewport),
        Symbol("glXSwapIntervalSGI",  cast(void**)& dwt_glXSwapIntervalSGI),
        Symbol("glXGetProcAddressARB",  cast(void**)& dwt_glXGetProcAddressARB),
        Symbol("glXMakeCurrent",  cast(void**)& dwt_glXMakeCurrent),
        Symbol("glXCreateContext",  cast(void**)& dwt_glXCreateContext),
        Symbol("glXDestroyGLXPixmap",  cast(void**)& dwt_glXDestroyGLXPixmap),
        Symbol("glXCreateGLXPixmap",  cast(void**)& dwt_glXCreateGLXPixmap),
        Symbol("glXChooseVisual",  cast(void**)& dwt_glXChooseVisual),
        Symbol("glXGetConfig",  cast(void**)& dwt_glXGetConfig),
        Symbol("glXUseXFont",  cast(void**)& dwt_glXUseXFont),
        Symbol("glXSwapBuffers",  cast(void**)& dwt_glXSwapBuffers),
        Symbol("glXWaitX",  cast(void**)& dwt_glXWaitX),
        Symbol("glXWaitGL",  cast(void**)& dwt_glXWaitGL),
        Symbol("glXGetSelectedEvent",  cast(void**)& dwt_glXGetSelectedEvent),
        Symbol("glXSelectEvent",  cast(void**)& dwt_glXSelectEvent),
        Symbol("glXQueryContext",  cast(void**)& dwt_glXQueryContext),
        Symbol("glXGetCurrentDisplay",  cast(void**)& dwt_glXGetCurrentDisplay),
        Symbol("glXGetCurrentReadDrawable",  cast(void**)& dwt_glXGetCurrentReadDrawable),
        Symbol("glXGetCurrentDrawable",  cast(void**)& dwt_glXGetCurrentDrawable),
        Symbol("glXGetCurrentContext",  cast(void**)& dwt_glXGetCurrentContext),
        Symbol("glXCopyContext",  cast(void**)& dwt_glXCopyContext),
        Symbol("glXMakeContextCurrent",  cast(void**)& dwt_glXMakeContextCurrent),
        Symbol("glXDestroyContext",  cast(void**)& dwt_glXDestroyContext),
        Symbol("glXIsDirect",  cast(void**)& dwt_glXIsDirect),
        Symbol("glXCreateNewContext",  cast(void**)& dwt_glXCreateNewContext),
        Symbol("glXQueryDrawable",  cast(void**)& dwt_glXQueryDrawable),
        Symbol("glXDestroyPbuffer",  cast(void**)& dwt_glXDestroyPbuffer),
        Symbol("glXCreatePbuffer",  cast(void**)& dwt_glXCreatePbuffer),
        Symbol("glXDestroyPixmap",  cast(void**)& dwt_glXDestroyPixmap),
        Symbol("glXCreatePixmap",  cast(void**)& dwt_glXCreatePixmap),
        Symbol("glXDestroyWindow",  cast(void**)& dwt_glXDestroyWindow),
        Symbol("glXCreateWindow",  cast(void**)& dwt_glXCreateWindow),
        Symbol("glXGetVisualFromFBConfig",  cast(void**)& dwt_glXGetVisualFromFBConfig),
        Symbol("glXGetFBConfigAttrib",  cast(void**)& dwt_glXGetFBConfigAttrib),
        Symbol("glXChooseFBConfig",  cast(void**)& dwt_glXChooseFBConfig),
        Symbol("glXGetFBConfigs",  cast(void**)& dwt_glXGetFBConfigs),
        Symbol("glXQueryServerString",  cast(void**)& dwt_glXQueryServerString),
        Symbol("glXGetClientString",  cast(void**)& dwt_glXGetClientString),
        Symbol("glXQueryExtensionsString",  cast(void**)& dwt_glXQueryExtensionsString),
        Symbol("glXQueryVersion",  cast(void**)& dwt_glXQueryVersion),
        Symbol("glXQueryExtension",  cast(void**)& dwt_glXQueryExtension)
    ];
}

} else { // version(DYNLINK)
extern (C) GLint glXSwapIntervalSGI(GLint);
extern (C) _BCD_func__2197 glXGetProcAddressARB(char *);
extern (C) Bool glXMakeCurrent(void *, GLXDrawable, void *);
extern (C) void * glXCreateContext(void *, XVisualInfo *, void *, Bool);
extern (C) void glXDestroyGLXPixmap(void *, GLXPixmap);
extern (C) GLXPixmap glXCreateGLXPixmap(void *, XVisualInfo *, Pixmap);
extern (C) XVisualInfo * glXChooseVisual(void *, GLint, GLint *);
extern (C) GLint glXGetConfig(void *, XVisualInfo *, GLint, GLint *);
extern (C) void glXUseXFont(Font, GLint, GLint, GLint);
extern (C) void glXSwapBuffers(void *, GLXDrawable);
extern (C) void glXWaitX();
extern (C) void glXWaitGL();
extern (C) void glXGetSelectedEvent(void *, GLXDrawable, GLulong *);
extern (C) void glXSelectEvent(void *, GLXDrawable, GLulong);
extern (C) GLint glXQueryContext(void *, void *, GLint, GLint *);
extern (C) void * glXGetCurrentDisplay();
extern (C) GLXDrawable glXGetCurrentReadDrawable();
extern (C) GLXDrawable glXGetCurrentDrawable();
extern (C) void * glXGetCurrentContext();
extern (C) void glXCopyContext(void *, void *, void *, GLulong);
extern (C) Bool glXMakeContextCurrent(void *, GLXDrawable, GLXDrawable, void *);
extern (C) void glXDestroyContext(void *, void *);
extern (C) Bool glXIsDirect(void *, void *);
extern (C) void * glXCreateNewContext(void *, void *, GLint, void *, Bool);
extern (C) void glXQueryDrawable(void *, GLXDrawable, GLint, GLuint *);
extern (C) void glXDestroyPbuffer(void *, GLXPbuffer);
extern (C) GLXPbuffer glXCreatePbuffer(void *, void *, const GLint *);
extern (C) void glXDestroyPixmap(void *, GLXPixmap);
extern (C) GLXPixmap glXCreatePixmap(void *, void *, Pixmap, const GLint *);
extern (C) void glXDestroyWindow(void *, GLXWindow);
extern (C) GLXWindow glXCreateWindow(void *, void *, Window, const GLint *);
extern (C) XVisualInfo * glXGetVisualFromFBConfig(void *, void *);
extern (C) GLint glXGetFBConfigAttrib(void *, void *, GLint, GLint *);
extern (C) void * * glXChooseFBConfig(void *, GLint, const GLint *, GLint *);
extern (C) void * * glXGetFBConfigs(void *, GLint, GLint *);
extern (C) char * glXQueryServerString(void *, GLint, GLint);
extern (C) char * glXGetClientString(void *, GLint);
extern (C) char * glXQueryExtensionsString(void *, GLint);
extern (C) Bool glXQueryVersion(void *, GLint *, GLint *);
extern (C) Bool glXQueryExtension(void *, GLint *, GLint *);
} // version(DYNLINK)

