/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <keinfarbton@googlemail.com>
******************************************************************************/
module org.eclipse.swt.internal.c.cairo_xlib;

private import org.eclipse.swt.internal.c.X;

import java.lang.all;

public import org.eclipse.swt.internal.c.cairo_xlib;
public import org.eclipse.swt.internal.c.cairo;
public import org.eclipse.swt.internal.c.Xlib;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

extern(C):

version(DYNLINK){
mixin(gshared!(
"extern (C) c_int function(void *)cairo_xlib_surface_get_height;
extern (C) c_int function(void *)cairo_xlib_surface_get_width;
extern (C) c_int function(void *)cairo_xlib_surface_get_depth;
extern (C) Visual * function(void *)cairo_xlib_surface_get_visual;
extern (C) Screen * function(void *)cairo_xlib_surface_get_screen;
extern (C) Drawable function(void *)cairo_xlib_surface_get_drawable;
extern (C) void * function(void *)cairo_xlib_surface_get_display;
extern (C) void function(void *, Drawable, c_int, c_int)cairo_xlib_surface_set_drawable;
extern (C) void function(void *, c_int, c_int)cairo_xlib_surface_set_size;
extern (C) void * function(Display *, Pixmap, Screen *, c_int, c_int)cairo_xlib_surface_create_for_bitmap;
extern (C) void * function(Display *, Drawable, Visual *, c_int, c_int)cairo_xlib_surface_create;"
));

Symbol[] symbols;
static this () {
    symbols = [
        Symbol("cairo_xlib_surface_get_height",  cast(void**)& cairo_xlib_surface_get_height),
        Symbol("cairo_xlib_surface_get_width",  cast(void**)& cairo_xlib_surface_get_width),
        Symbol("cairo_xlib_surface_get_depth",  cast(void**)& cairo_xlib_surface_get_depth),
        Symbol("cairo_xlib_surface_get_visual",  cast(void**)& cairo_xlib_surface_get_visual),
        Symbol("cairo_xlib_surface_get_screen",  cast(void**)& cairo_xlib_surface_get_screen),
        Symbol("cairo_xlib_surface_get_drawable",  cast(void**)& cairo_xlib_surface_get_drawable),
        Symbol("cairo_xlib_surface_get_display",  cast(void**)& cairo_xlib_surface_get_display),
        Symbol("cairo_xlib_surface_set_drawable",  cast(void**)& cairo_xlib_surface_set_drawable),
        Symbol("cairo_xlib_surface_set_size",  cast(void**)& cairo_xlib_surface_set_size),
        Symbol("cairo_xlib_surface_create_for_bitmap",  cast(void**)& cairo_xlib_surface_create_for_bitmap),
        Symbol("cairo_xlib_surface_create",  cast(void**)& cairo_xlib_surface_create)
    ];
}

} else { // version(DYNLINK)
extern (C) c_int cairo_xlib_surface_get_height(void *);
extern (C) c_int cairo_xlib_surface_get_width(void *);
extern (C) c_int cairo_xlib_surface_get_depth(void *);
extern (C) Visual * cairo_xlib_surface_get_visual(void *);
extern (C) Screen * cairo_xlib_surface_get_screen(void *);
extern (C) Drawable cairo_xlib_surface_get_drawable(void *);
extern (C) void * cairo_xlib_surface_get_display(void *);
extern (C) void cairo_xlib_surface_set_drawable(void *, Drawable, c_int, c_int);
extern (C) void cairo_xlib_surface_set_size(void *, c_int, c_int);
extern (C) void * cairo_xlib_surface_create_for_bitmap(Display *, Pixmap, Screen *, c_int, c_int);
extern (C) void * cairo_xlib_surface_create(Display *, Drawable, Visual *, c_int, c_int);
} // version(DYNLINK)

