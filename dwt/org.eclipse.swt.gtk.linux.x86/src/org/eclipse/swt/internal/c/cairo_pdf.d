/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <benoit@tionex.de>
******************************************************************************/
module org.eclipse.swt.internal.c.cairo_pdf;

private import org.eclipse.swt.internal.c.X;

import java.lang.all;
public import org.eclipse.swt.internal.c.glib_object;
public import org.eclipse.swt.internal.c.cairo;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

alias cairo_status_t function(void *, char *, c_uint) _BCD_func__480;
alias void function(void *) _BCD_func__484;
version(DYNLINK){
mixin(gshared!(
"extern (C) void function(void *, double, double)cairo_pdf_surface_set_size;
extern (C) void * function(_BCD_func__480, void *, double, double)cairo_pdf_surface_create_for_stream;
extern (C) void * function(char *, double, double)cairo_pdf_surface_create;"
));

Symbol[] symbols;
static this () {
    symbols = [
        Symbol("cairo_pdf_surface_set_size",  cast(void**)& cairo_pdf_surface_set_size),
        Symbol("cairo_pdf_surface_create_for_stream",  cast(void**)& cairo_pdf_surface_create_for_stream),
        Symbol("cairo_pdf_surface_create",  cast(void**)& cairo_pdf_surface_create)
    ];
}

} else { // version(DYNLINK)
extern (C) void cairo_pdf_surface_set_size(void *, double, double);
extern (C) void * cairo_pdf_surface_create_for_stream(_BCD_func__480, void *, double, double);
extern (C) void * cairo_pdf_surface_create(char *, double, double);
} // version(DYNLINK)

