/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <keinfarbton@googlemail.com>
******************************************************************************/
module org.eclipse.swt.internal.c.pangocairo;

import java.lang.all;

public import org.eclipse.swt.internal.c.cairo;
public import org.eclipse.swt.internal.c.pango;
public import org.eclipse.swt.internal.c.glib_object;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

extern(C):

alias void function(void *, _PangoAttrShape *, gint, void *) _BCD_func__2844;
alias _BCD_func__2844 PangoCairoShapeRendererFunc;
alias void PangoCairoFontMap;
alias void PangoCairoFont;
alias void function(void *) _BCD_func__2912;
alias gint function(void *, char *, guint) _BCD_func__2907;
alias gint function(void *, char *, guint) _BCD_func__2908;
alias void * function(void *) _BCD_func__3005;
alias gint function(_PangoAttribute *, void *) _BCD_func__3006;
alias gint function(void *, void *, void *) _BCD_func__3062;
alias void function(void *, guint, guint, _GInterfaceInfo *) _BCD_func__3114;
alias void function(void *, guint, _GTypeInfo *, _GTypeValueTable *) _BCD_func__3115;
alias void function(void *) _BCD_func__3116;
alias void function(void *, _GObject *, gint) _BCD_func__3264;
alias void function(void *, _GObject *) _BCD_func__3269;
alias void function(_GObject *) _BCD_func__3270;
alias void function(_GObject *, guint, _GValue *, _GParamSpec *) _BCD_func__3271;
alias void function(_GObject *, guint, _GValue *, _GParamSpec *) _BCD_func__3272;
alias gint function(_GSignalInvocationHint *, _GValue *, _GValue *, void *) _BCD_func__3298;
alias gint function(_GSignalInvocationHint *, guint, _GValue *, void *) _BCD_func__3299;
alias void function(_GClosure *, _GValue *, guint, _GValue *, void *, void *) _BCD_func__3300;
alias void function(void *, _GClosure *) _BCD_func__3319;
alias void function() _BCD_func__3320;
alias void function(_GValue *, _GValue *) _BCD_func__3377;
alias void * function(void *) _BCD_func__3405;
alias void function(void *, void *) _BCD_func__3409;
alias gint function(void *, _GTypeClass *) _BCD_func__3410;
alias void function(_GTypeInstance *, void *) _BCD_func__3411;
alias gint function(void *, void *, void *) _BCD_func__3467;
alias gint function(void *, void *, void *) _BCD_func__3483;
alias void function(_GScanner *, char *, gint) _BCD_func__3486;
alias gint function(void *, _GString *, void *) _BCD_func__3559;
alias void function(void *, void *, void *, _GError * *) _BCD_func__3577;
alias gint function(void *, void *, void *, _GError * *) _BCD_func__3578;
alias gint function(char *, char *, void *, _GError * *) _BCD_func__3579;
alias void * function(void *, void *) _BCD_func__3590;
alias void function(_GNode *, void *) _BCD_func__3591;
alias gint function(_GNode *, void *) _BCD_func__3592;
alias void function(char *) _BCD_func__3600;
alias void function(char *, gint, char *, void *) _BCD_func__3602;
alias gint function(_GIOChannel *, gint, void *) _BCD_func__3620;
alias gint function(_GPollFD *, guint, gint) _BCD_func__3672;
alias void function(gint, gint, void *) _BCD_func__3678;
alias gint function(void *) _BCD_func__3679;
alias void function(_GHookList *, _GHook *) _BCD_func__3714;
alias gint function(_GHook *, void *) _BCD_func__3715;
alias void function(_GHook *, void *) _BCD_func__3716;
alias gint function(_GHook *, _GHook *) _BCD_func__3717;
alias void function(guint, void *, void *) _BCD_func__3751;
alias gint function(char *, char *, guint) _BCD_func__3754;
alias char * function(void *) _BCD_func__3755;
alias char * function(char *, void *) _BCD_func__3946;
alias void function(void *, void *, void *) _BCD_func__3947;
alias guint function(void *) _BCD_func__3948;
alias gint function(void *, void *) _BCD_func__3949;
alias gint function(void *, void *, void *) _BCD_func__3950;
alias gint function(void *, void *) _BCD_func__3951;
version(DYNLINK){
mixin(gshared!(
"extern (C) void function(void *, double, double, double, double)pango_cairo_error_underline_path;
extern (C) void function(void *, void *)pango_cairo_layout_path;
extern (C) void function(void *, _PangoLayoutLine *)pango_cairo_layout_line_path;
extern (C) void function(void *, void *, _PangoGlyphString *)pango_cairo_glyph_string_path;
extern (C) void function(void *, double, double, double, double)pango_cairo_show_error_underline;
extern (C) void function(void *, void *)pango_cairo_show_layout;
extern (C) void function(void *, _PangoLayoutLine *)pango_cairo_show_layout_line;
extern (C) void function(void *, void *, _PangoGlyphString *)pango_cairo_show_glyph_string;
extern (C) void function(void *, void *)pango_cairo_update_layout;
extern (C) void * function(void *)pango_cairo_create_layout;
extern (C) _BCD_func__2844 function(void *, void * *)pango_cairo_context_get_shape_renderer;
extern (C) void function(void *, _BCD_func__2844, void *, _BCD_func__2912)pango_cairo_context_set_shape_renderer;
extern (C) double function(void *)pango_cairo_context_get_resolution;
extern (C) void function(void *, double)pango_cairo_context_set_resolution;
extern (C) void * function(void *)pango_cairo_context_get_font_options;
extern (C) void function(void *, void *)pango_cairo_context_set_font_options;
extern (C) void function(void *, void *)pango_cairo_update_context;
extern (C) void * function(void *)pango_cairo_font_get_scaled_font;
extern (C) GType function()pango_cairo_font_get_type;
extern (C) void * function(void *)pango_cairo_font_map_create_context;
extern (C) double function(void *)pango_cairo_font_map_get_resolution;
extern (C) void function(void *, double)pango_cairo_font_map_set_resolution;
extern (C) gint function(void *)pango_cairo_font_map_get_font_type;
extern (C) void * function()pango_cairo_font_map_get_default;
extern (C) void * function(gint)pango_cairo_font_map_new_for_font_type;
extern (C) void * function()pango_cairo_font_map_new;
extern (C) GType function()pango_cairo_font_map_get_type;"
));

Symbol[] symbols;
static this () {
    symbols = [
        Symbol("pango_cairo_error_underline_path",  cast(void**)& pango_cairo_error_underline_path),
        Symbol("pango_cairo_layout_path",  cast(void**)& pango_cairo_layout_path),
        Symbol("pango_cairo_layout_line_path",  cast(void**)& pango_cairo_layout_line_path),
        Symbol("pango_cairo_glyph_string_path",  cast(void**)& pango_cairo_glyph_string_path),
        Symbol("pango_cairo_show_error_underline",  cast(void**)& pango_cairo_show_error_underline),
        Symbol("pango_cairo_show_layout",  cast(void**)& pango_cairo_show_layout),
        Symbol("pango_cairo_show_layout_line",  cast(void**)& pango_cairo_show_layout_line),
        Symbol("pango_cairo_show_glyph_string",  cast(void**)& pango_cairo_show_glyph_string),
        Symbol("pango_cairo_update_layout",  cast(void**)& pango_cairo_update_layout),
        Symbol("pango_cairo_create_layout",  cast(void**)& pango_cairo_create_layout),
        Symbol("pango_cairo_context_get_shape_renderer",  cast(void**)& pango_cairo_context_get_shape_renderer),
        Symbol("pango_cairo_context_set_shape_renderer",  cast(void**)& pango_cairo_context_set_shape_renderer),
        Symbol("pango_cairo_context_get_resolution",  cast(void**)& pango_cairo_context_get_resolution),
        Symbol("pango_cairo_context_set_resolution",  cast(void**)& pango_cairo_context_set_resolution),
        Symbol("pango_cairo_context_get_font_options",  cast(void**)& pango_cairo_context_get_font_options),
        Symbol("pango_cairo_context_set_font_options",  cast(void**)& pango_cairo_context_set_font_options),
        Symbol("pango_cairo_update_context",  cast(void**)& pango_cairo_update_context),
        Symbol("pango_cairo_font_get_scaled_font",  cast(void**)& pango_cairo_font_get_scaled_font),
        Symbol("pango_cairo_font_get_type",  cast(void**)& pango_cairo_font_get_type),
        Symbol("pango_cairo_font_map_create_context",  cast(void**)& pango_cairo_font_map_create_context),
        Symbol("pango_cairo_font_map_get_resolution",  cast(void**)& pango_cairo_font_map_get_resolution),
        Symbol("pango_cairo_font_map_set_resolution",  cast(void**)& pango_cairo_font_map_set_resolution),
        Symbol("pango_cairo_font_map_get_font_type",  cast(void**)& pango_cairo_font_map_get_font_type),
        Symbol("pango_cairo_font_map_get_default",  cast(void**)& pango_cairo_font_map_get_default),
        Symbol("pango_cairo_font_map_new_for_font_type",  cast(void**)& pango_cairo_font_map_new_for_font_type),
        Symbol("pango_cairo_font_map_new",  cast(void**)& pango_cairo_font_map_new),
        Symbol("pango_cairo_font_map_get_type",  cast(void**)& pango_cairo_font_map_get_type)
    ];
}

} else { // version(DYNLINK)
extern (C) void pango_cairo_error_underline_path(void *, double, double, double, double);
extern (C) void pango_cairo_layout_path(void *, void *);
extern (C) void pango_cairo_layout_line_path(void *, _PangoLayoutLine *);
extern (C) void pango_cairo_glyph_string_path(void *, void *, _PangoGlyphString *);
extern (C) void pango_cairo_show_error_underline(void *, double, double, double, double);
extern (C) void pango_cairo_show_layout(void *, void *);
extern (C) void pango_cairo_show_layout_line(void *, _PangoLayoutLine *);
extern (C) void pango_cairo_show_glyph_string(void *, void *, _PangoGlyphString *);
extern (C) void pango_cairo_update_layout(void *, void *);
extern (C) void * pango_cairo_create_layout(void *);
extern (C) _BCD_func__2844 pango_cairo_context_get_shape_renderer(void *, void * *);
extern (C) void pango_cairo_context_set_shape_renderer(void *, _BCD_func__2844, void *, _BCD_func__2912);
extern (C) double pango_cairo_context_get_resolution(void *);
extern (C) void pango_cairo_context_set_resolution(void *, double);
extern (C) void * pango_cairo_context_get_font_options(void *);
extern (C) void pango_cairo_context_set_font_options(void *, void *);
extern (C) void pango_cairo_update_context(void *, void *);
extern (C) void * pango_cairo_font_get_scaled_font(void *);
extern (C) GType pango_cairo_font_get_type();
extern (C) void * pango_cairo_font_map_create_context(void *);
extern (C) double pango_cairo_font_map_get_resolution(void *);
extern (C) void pango_cairo_font_map_set_resolution(void *, double);
extern (C) gint pango_cairo_font_map_get_font_type(void *);
extern (C) void * pango_cairo_font_map_get_default();
extern (C) void * pango_cairo_font_map_new_for_font_type(gint);
extern (C) void * pango_cairo_font_map_new();
extern (C) GType pango_cairo_font_map_get_type();
} // version(DYNLINK)

