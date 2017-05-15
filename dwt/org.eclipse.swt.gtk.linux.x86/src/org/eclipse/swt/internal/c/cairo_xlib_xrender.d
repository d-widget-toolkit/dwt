/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <keinfarbton@googlemail.com>
******************************************************************************/
module org.eclipse.swt.internal.c.cairo_xlib_xrender;

import java.lang.all;
public import org.eclipse.swt.internal.c.cairo_xlib_xrender;
public import org.eclipse.swt.internal.c.cairo;
public import org.eclipse.swt.internal.c.Xrender;
private import org.eclipse.swt.internal.c.X;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

extern(C):

version(DYNLINK){
mixin(gshared!(
"extern (C) cairo_surface_t * function(Display *, Drawable, Screen *, XRenderPictFormat *, c_int, c_int)cairo_xlib_surface_create_with_xrender_format;"
));

Symbol[] symbols;
static this () {
    symbols = [
        Symbol("cairo_xlib_surface_create_with_xrender_format",  cast(void**)& cairo_xlib_surface_create_with_xrender_format)
    ];
}

} else { // version(DYNLINK)
extern (C) cairo_surface_t * cairo_xlib_surface_create_with_xrender_format(Display *, Drawable, Screen *, XRenderPictFormat *, c_int, c_int);
} // version(DYNLINK)

