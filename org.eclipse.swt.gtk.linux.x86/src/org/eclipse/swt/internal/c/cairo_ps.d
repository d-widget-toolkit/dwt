/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <benoit@tionex.de>
******************************************************************************/
module org.eclipse.swt.internal.c.cairo_ps;

private import org.eclipse.swt.internal.c.X;

import java.lang.all;
public import org.eclipse.swt.internal.c.glib_object;
public import org.eclipse.swt.internal.c.cairo;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

alias cairo_status_t function(void *, char *, c_uint) _BCD_func__879;
version(DYNLINK){
mixin(gshared!(
"extern (C) void function(void *)cairo_ps_surface_dsc_begin_page_setup;
extern (C) void function(void *)cairo_ps_surface_dsc_begin_setup;
extern (C) void function(void *, char *)cairo_ps_surface_dsc_comment;
extern (C) void function(void *, double, double)cairo_ps_surface_set_size;
extern (C) void * function(_BCD_func__879, void *, double, double)cairo_ps_surface_create_for_stream;
extern (C) void * function(char *, double, double)cairo_ps_surface_create;"
));

Symbol[] symbols;
static this () {
    symbols = [
        Symbol("cairo_ps_surface_dsc_begin_page_setup",  cast(void**)& cairo_ps_surface_dsc_begin_page_setup),
        Symbol("cairo_ps_surface_dsc_begin_setup",  cast(void**)& cairo_ps_surface_dsc_begin_setup),
        Symbol("cairo_ps_surface_dsc_comment",  cast(void**)& cairo_ps_surface_dsc_comment),
        Symbol("cairo_ps_surface_set_size",  cast(void**)& cairo_ps_surface_set_size),
        Symbol("cairo_ps_surface_create_for_stream",  cast(void**)& cairo_ps_surface_create_for_stream),
        Symbol("cairo_ps_surface_create",  cast(void**)& cairo_ps_surface_create)
    ];
}

} else { // version(DYNLINK)
extern (C) void cairo_ps_surface_dsc_begin_page_setup(void *);
extern (C) void cairo_ps_surface_dsc_begin_setup(void *);
extern (C) void cairo_ps_surface_dsc_comment(void *, char *);
extern (C) void cairo_ps_surface_set_size(void *, double, double);
extern (C) void * cairo_ps_surface_create_for_stream(_BCD_func__879, void *, double, double);
extern (C) void * cairo_ps_surface_create(char *, double, double);
} // version(DYNLINK)

