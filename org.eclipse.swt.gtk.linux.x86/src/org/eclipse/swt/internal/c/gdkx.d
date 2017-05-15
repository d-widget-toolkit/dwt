/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <keinfarbton@googlemail.com>
******************************************************************************/
module org.eclipse.swt.internal.c.gdkx;

import java.lang.all;
public import org.eclipse.swt.internal.c.pango;
public import org.eclipse.swt.internal.c.cairo;
public import org.eclipse.swt.internal.c.glib_object;
public import org.eclipse.swt.internal.c.gdk;
public import org.eclipse.swt.internal.c.X;
public import org.eclipse.swt.internal.c.Xlib;
public import org.eclipse.swt.internal.c.Xutil;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

extern(C):

alias void function(void *, char *, gint, gint, char * *) _BCD_func__4613;
alias gint function(void *) _BCD_func__4653;
alias gint function(void *, XErrorEvent *) _BCD_func__4654;
alias void function(void *, char *, char *) _BCD_func__4726;
alias gint function(void *, char *, char *) _BCD_func__4727;
alias void function(void *, char *, char *) _BCD_func__4728;
alias void function(void *) _BCD_func__5695;
alias char * function(void *) _BCD_func__5696;
alias gint function(char *, guint, _GError * *, void *) _BCD_func__5702;
alias void function(char *, void *) _BCD_func__5706;
alias void function(_GdkSpan *, void *) _BCD_func__5720;
alias gint function(void *, _GdkEvent *, void *) _BCD_func__5762;
alias void function(_GdkEvent *, void *) _BCD_func__5763;
alias gint function(void *, char *, guint) _BCD_func__6083;
alias gint function(void *, char *, guint) _BCD_func__6084;
alias void function(void *) _BCD_func__6088;
alias void function(void *, gint, gint) _BCD_func__6097;
alias gint function(void *) _BCD_func__1886;
alias gint function(void *, long *, gint) _BCD_func__1888;
alias gint function(void *, char *, guint) _BCD_func__1890;
alias gint function(void *, char *, guint) _BCD_func__1892;
alias gint function(void * *, char *) _BCD_func__6246;
alias gint function(char *, char * * *, guint *) _BCD_func__6247;
alias gint function(void *, char *, char *, char *, char *) _BCD_func__6248;
alias gint function(__gconv_step *, __gconv_step_data *, void *, char *, char * *, char *, char * *, guint *) _BCD_func__6249;
alias void function(__gconv_step *) _BCD_func__6250;
alias gint function(__gconv_step *) _BCD_func__6251;
alias guint function(__gconv_step *, char) _BCD_func__6252;
alias gint function(__gconv_step *, __gconv_step_data *, char * *, char *, char * *, guint *, gint, gint) _BCD_func__6253;
alias gint function(void *, void *, void *) _BCD_func__6405;
alias void * function(void *) _BCD_func__6430;
alias gint function(_PangoAttribute *, void *) _BCD_func__6431;
alias void function(void *, guint, guint, _GInterfaceInfo *) _BCD_func__6533;
alias void function(void *, guint, _GTypeInfo *, _GTypeValueTable *) _BCD_func__6534;
alias void function(void *) _BCD_func__6535;
alias void function(void *, _GObject *, gint) _BCD_func__6683;
alias void function(void *, _GObject *) _BCD_func__6688;
alias void function(_GObject *) _BCD_func__6689;
alias void function(_GObject *, guint, _GValue *, _GParamSpec *) _BCD_func__6690;
alias void function(_GObject *, guint, _GValue *, _GParamSpec *) _BCD_func__6691;
alias gint function(_GSignalInvocationHint *, _GValue *, _GValue *, void *) _BCD_func__6717;
alias gint function(_GSignalInvocationHint *, guint, _GValue *, void *) _BCD_func__6718;
alias void function(_GClosure *, _GValue *, guint, _GValue *, void *, void *) _BCD_func__6719;
alias void function(void *, _GClosure *) _BCD_func__6738;
alias void function() _BCD_func__6739;
alias void function(_GValue *, _GValue *) _BCD_func__6796;
alias void * function(void *) _BCD_func__6824;
alias void function(void *, void *) _BCD_func__6828;
alias gint function(void *, _GTypeClass *) _BCD_func__6829;
alias void function(_GTypeInstance *, void *) _BCD_func__6830;
alias gint function(void *, void *, void *) _BCD_func__6885;
alias gint function(void *, void *, void *) _BCD_func__6900;
alias void function(_GScanner *, char *, gint) _BCD_func__6903;
alias gint function(void *, _GString *, void *) _BCD_func__6975;
alias void function(void *, void *, void *, _GError * *) _BCD_func__6993;
alias gint function(void *, void *, void *, _GError * *) _BCD_func__6994;
alias gint function(char *, char *, void *, _GError * *) _BCD_func__6995;
alias void * function(void *, void *) _BCD_func__7006;
alias void function(_GNode *, void *) _BCD_func__7007;
alias gint function(_GNode *, void *) _BCD_func__7008;
alias void function(char *) _BCD_func__7016;
alias void function(char *, gint, char *, void *) _BCD_func__7018;
alias gint function(_GIOChannel *, gint, void *) _BCD_func__7033;
alias gint function(_GPollFD *, guint, gint) _BCD_func__7085;
alias void function(gint, gint, void *) _BCD_func__7091;
alias gint function(void *) _BCD_func__7092;
alias void function(_GHookList *, _GHook *) _BCD_func__7127;
alias gint function(_GHook *, void *) _BCD_func__7128;
alias void function(_GHook *, void *) _BCD_func__7129;
alias gint function(_GHook *, _GHook *) _BCD_func__7130;
alias void function(guint, void *, void *) _BCD_func__7164;
alias gint function(char *, char *, guint) _BCD_func__7167;
alias char * function(void *) _BCD_func__7168;
alias char * function(char *, void *) _BCD_func__7349;
alias void function(void *, void *, void *) _BCD_func__7350;
alias guint function(void *) _BCD_func__7351;
alias gint function(void *, void *) _BCD_func__7352;
alias gint function(void *, void *, void *) _BCD_func__7353;
alias gint function(void *, void *) _BCD_func__7354;
version(DYNLINK){
mixin(gshared!(
"extern (C) char * function(_GdkFont *)gdk_x11_font_get_name;
extern (C) void * function(_GdkFont *)gdk_x11_font_get_xdisplay;
extern (C) void * function(_GdkFont *)gdk_x11_font_get_xfont;
extern (C) void function(void *, gint, gint)gdk_x11_register_standard_event_type;
extern (C) void function(void *)gdk_x11_display_ungrab;
extern (C) void function(void *)gdk_x11_display_grab;
extern (C) char * function(guint)gdk_x11_get_xatom_name;
extern (C) guint function(char *)gdk_x11_get_xatom_by_name;
extern (C) void * function(guint)gdk_x11_xatom_to_atom;
extern (C) guint function(void *)gdk_x11_atom_to_xatom;
extern (C) char * function(void *, guint)gdk_x11_get_xatom_name_for_display;
extern (C) guint function(void *, char *)gdk_x11_get_xatom_by_name_for_display;
extern (C) void * function(void *, guint)gdk_x11_xatom_to_atom_for_display;
extern (C) guint function(void *, void *)gdk_x11_atom_to_xatom_for_display;
extern (C) void * function(void *)gdk_x11_lookup_xdisplay;
extern (C) void function()gdk_x11_ungrab_server;
extern (C) void function()gdk_x11_grab_server;
extern (C) gint function(void *)gdk_net_wm_supports;
extern (C) void * function(guint)gdk_xid_table_lookup;
extern (C) gint function(void *, void *)gdk_x11_screen_supports_net_wm_hint;
extern (C) void function(void *, char *, ...)gdk_x11_display_broadcast_startup_message;
extern (C) void function(void *, char *, gint)gdk_x11_display_set_cursor_theme;
extern (C) char * function(void *)gdk_x11_display_get_startup_notification_id;
extern (C) guint32 function(void *)gdk_x11_display_get_user_time;
extern (C) guint32 function(_GdkDrawable *)gdk_x11_get_server_time;
extern (C) void * function(void *, guint)gdk_xid_table_lookup_for_display;
extern (C) _GdkColormap * function(_GdkVisual *, guint)gdk_x11_colormap_foreign_new;
extern (C) _GdkVisual * function(guint)gdkx_visual_get;
extern (C) _GdkVisual * function(void *, VisualID)gdk_x11_screen_lookup_visual;
extern (C) gint function()gdk_x11_get_default_screen;
extern (C) void * function()gdk_x11_get_default_xdisplay;
extern (C) guint function()gdk_x11_get_default_root_xwindow;
extern (C) char * function(void *)gdk_x11_screen_get_window_manager_name;
extern (C) void function(_GdkDrawable *)gdk_x11_window_move_to_current_desktop;
extern (C) void function(_GdkDrawable *, guint32)gdk_x11_window_set_user_time;
extern (C) gint function(void *)gdk_x11_screen_get_screen_number;
extern (C) Screen * function(void *)gdk_x11_screen_get_xscreen;
extern (C) void * function(_GdkGC *)gdk_x11_gc_get_xgc;
extern (C) void * function(_GdkGC *)gdk_x11_gc_get_xdisplay;
extern (C) Visual * function(_GdkVisual *)gdk_x11_visual_get_xvisual;
extern (C) void * function(void *)gdk_x11_display_get_xdisplay;
extern (C) guint function(_GdkCursor *)gdk_x11_cursor_get_xcursor;
extern (C) void * function(_GdkCursor *)gdk_x11_cursor_get_xdisplay;
extern (C) guint function(_GdkColormap *)gdk_x11_colormap_get_xcolormap;
extern (C) void * function(_GdkColormap *)gdk_x11_colormap_get_xdisplay;
extern (C) _XImage * function(_GdkImage *)gdk_x11_image_get_ximage;
extern (C) void * function(_GdkImage *)gdk_x11_image_get_xdisplay;
extern (C) guint function(_GdkDrawable *)gdk_x11_drawable_get_xid;
extern (C) void * function(_GdkDrawable *)gdk_x11_drawable_get_xdisplay;
extern (C) extern void * gdk_display;"
));

Symbol[] symbols;
static this () {
    symbols = [
        Symbol("gdk_x11_font_get_name",  cast(void**)& gdk_x11_font_get_name),
        Symbol("gdk_x11_font_get_xdisplay",  cast(void**)& gdk_x11_font_get_xdisplay),
        Symbol("gdk_x11_font_get_xfont",  cast(void**)& gdk_x11_font_get_xfont),
        Symbol("gdk_x11_register_standard_event_type",  cast(void**)& gdk_x11_register_standard_event_type),
        Symbol("gdk_x11_display_ungrab",  cast(void**)& gdk_x11_display_ungrab),
        Symbol("gdk_x11_display_grab",  cast(void**)& gdk_x11_display_grab),
        Symbol("gdk_x11_get_xatom_name",  cast(void**)& gdk_x11_get_xatom_name),
        Symbol("gdk_x11_get_xatom_by_name",  cast(void**)& gdk_x11_get_xatom_by_name),
        Symbol("gdk_x11_xatom_to_atom",  cast(void**)& gdk_x11_xatom_to_atom),
        Symbol("gdk_x11_atom_to_xatom",  cast(void**)& gdk_x11_atom_to_xatom),
        Symbol("gdk_x11_get_xatom_name_for_display",  cast(void**)& gdk_x11_get_xatom_name_for_display),
        Symbol("gdk_x11_get_xatom_by_name_for_display",  cast(void**)& gdk_x11_get_xatom_by_name_for_display),
        Symbol("gdk_x11_xatom_to_atom_for_display",  cast(void**)& gdk_x11_xatom_to_atom_for_display),
        Symbol("gdk_x11_atom_to_xatom_for_display",  cast(void**)& gdk_x11_atom_to_xatom_for_display),
        Symbol("gdk_x11_lookup_xdisplay",  cast(void**)& gdk_x11_lookup_xdisplay),
        Symbol("gdk_x11_ungrab_server",  cast(void**)& gdk_x11_ungrab_server),
        Symbol("gdk_x11_grab_server",  cast(void**)& gdk_x11_grab_server),
        Symbol("gdk_net_wm_supports",  cast(void**)& gdk_net_wm_supports),
        Symbol("gdk_xid_table_lookup",  cast(void**)& gdk_xid_table_lookup),
        Symbol("gdk_x11_screen_supports_net_wm_hint",  cast(void**)& gdk_x11_screen_supports_net_wm_hint),
        Symbol("gdk_x11_display_broadcast_startup_message",  cast(void**)& gdk_x11_display_broadcast_startup_message),
        Symbol("gdk_x11_display_set_cursor_theme",  cast(void**)& gdk_x11_display_set_cursor_theme),
        Symbol("gdk_x11_display_get_startup_notification_id",  cast(void**)& gdk_x11_display_get_startup_notification_id),
        Symbol("gdk_x11_display_get_user_time",  cast(void**)& gdk_x11_display_get_user_time),
        Symbol("gdk_x11_get_server_time",  cast(void**)& gdk_x11_get_server_time),
        Symbol("gdk_xid_table_lookup_for_display",  cast(void**)& gdk_xid_table_lookup_for_display),
        Symbol("gdk_x11_colormap_foreign_new",  cast(void**)& gdk_x11_colormap_foreign_new),
        Symbol("gdkx_visual_get",  cast(void**)& gdkx_visual_get),
        Symbol("gdk_x11_screen_lookup_visual",  cast(void**)& gdk_x11_screen_lookup_visual),
        Symbol("gdk_x11_get_default_screen",  cast(void**)& gdk_x11_get_default_screen),
        Symbol("gdk_x11_get_default_xdisplay",  cast(void**)& gdk_x11_get_default_xdisplay),
        Symbol("gdk_x11_get_default_root_xwindow",  cast(void**)& gdk_x11_get_default_root_xwindow),
        Symbol("gdk_x11_screen_get_window_manager_name",  cast(void**)& gdk_x11_screen_get_window_manager_name),
        Symbol("gdk_x11_window_move_to_current_desktop",  cast(void**)& gdk_x11_window_move_to_current_desktop),
        Symbol("gdk_x11_window_set_user_time",  cast(void**)& gdk_x11_window_set_user_time),
        Symbol("gdk_x11_screen_get_screen_number",  cast(void**)& gdk_x11_screen_get_screen_number),
        Symbol("gdk_x11_screen_get_xscreen",  cast(void**)& gdk_x11_screen_get_xscreen),
        Symbol("gdk_x11_gc_get_xgc",  cast(void**)& gdk_x11_gc_get_xgc),
        Symbol("gdk_x11_gc_get_xdisplay",  cast(void**)& gdk_x11_gc_get_xdisplay),
        Symbol("gdk_x11_visual_get_xvisual",  cast(void**)& gdk_x11_visual_get_xvisual),
        Symbol("gdk_x11_display_get_xdisplay",  cast(void**)& gdk_x11_display_get_xdisplay),
        Symbol("gdk_x11_cursor_get_xcursor",  cast(void**)& gdk_x11_cursor_get_xcursor),
        Symbol("gdk_x11_cursor_get_xdisplay",  cast(void**)& gdk_x11_cursor_get_xdisplay),
        Symbol("gdk_x11_colormap_get_xcolormap",  cast(void**)& gdk_x11_colormap_get_xcolormap),
        Symbol("gdk_x11_colormap_get_xdisplay",  cast(void**)& gdk_x11_colormap_get_xdisplay),
        Symbol("gdk_x11_image_get_ximage",  cast(void**)& gdk_x11_image_get_ximage),
        Symbol("gdk_x11_image_get_xdisplay",  cast(void**)& gdk_x11_image_get_xdisplay),
        Symbol("gdk_x11_drawable_get_xid",  cast(void**)& gdk_x11_drawable_get_xid),
        Symbol("gdk_x11_drawable_get_xdisplay",  cast(void**)& gdk_x11_drawable_get_xdisplay),
        Symbol("gdk_display",  cast(void**)& gdk_display)
    ];
}

} else { // version(DYNLINK)
extern (C) char * gdk_x11_font_get_name(_GdkFont *);
extern (C) void * gdk_x11_font_get_xdisplay(_GdkFont *);
extern (C) void * gdk_x11_font_get_xfont(_GdkFont *);
extern (C) void gdk_x11_register_standard_event_type(void *, gint, gint);
extern (C) void gdk_x11_display_ungrab(void *);
extern (C) void gdk_x11_display_grab(void *);
extern (C) char * gdk_x11_get_xatom_name(guint);
extern (C) guint gdk_x11_get_xatom_by_name(char *);
extern (C) void * gdk_x11_xatom_to_atom(guint);
extern (C) guint gdk_x11_atom_to_xatom(void *);
extern (C) char * gdk_x11_get_xatom_name_for_display(void *, guint);
extern (C) guint gdk_x11_get_xatom_by_name_for_display(void *, char *);
extern (C) void * gdk_x11_xatom_to_atom_for_display(void *, guint);
extern (C) guint gdk_x11_atom_to_xatom_for_display(void *, void *);
extern (C) void * gdk_x11_lookup_xdisplay(void *);
extern (C) void gdk_x11_ungrab_server();
extern (C) void gdk_x11_grab_server();
extern (C) gint gdk_net_wm_supports(void *);
extern (C) void * gdk_xid_table_lookup(guint);
extern (C) gint gdk_x11_screen_supports_net_wm_hint(void *, void *);
extern (C) void gdk_x11_display_broadcast_startup_message(void *, char *, ...);
extern (C) void gdk_x11_display_set_cursor_theme(void *, char *, gint);
extern (C) char * gdk_x11_display_get_startup_notification_id(void *);
extern (C) guint32 gdk_x11_display_get_user_time(void *);
extern (C) guint32 gdk_x11_get_server_time(_GdkDrawable *);
extern (C) void * gdk_xid_table_lookup_for_display(void *, guint);
extern (C) _GdkColormap * gdk_x11_colormap_foreign_new(_GdkVisual *, guint);
extern (C) _GdkVisual * gdkx_visual_get(guint);
extern (C) _GdkVisual * gdk_x11_screen_lookup_visual(void *, VisualID);
extern (C) gint gdk_x11_get_default_screen();
extern (C) void * gdk_x11_get_default_xdisplay();
extern (C) guint gdk_x11_get_default_root_xwindow();
extern (C) char * gdk_x11_screen_get_window_manager_name(void *);
extern (C) void gdk_x11_window_move_to_current_desktop(_GdkDrawable *);
extern (C) void gdk_x11_window_set_user_time(_GdkDrawable *, guint32);
extern (C) gint gdk_x11_screen_get_screen_number(void *);
extern (C) Screen * gdk_x11_screen_get_xscreen(void *);
extern (C) void * gdk_x11_gc_get_xgc(_GdkGC *);
extern (C) void * gdk_x11_gc_get_xdisplay(_GdkGC *);
extern (C) Visual * gdk_x11_visual_get_xvisual(_GdkVisual *);
extern (C) void * gdk_x11_display_get_xdisplay(void *);
extern (C) guint gdk_x11_cursor_get_xcursor(_GdkCursor *);
extern (C) void * gdk_x11_cursor_get_xdisplay(_GdkCursor *);
extern (C) guint gdk_x11_colormap_get_xcolormap(_GdkColormap *);
extern (C) void * gdk_x11_colormap_get_xdisplay(_GdkColormap *);
extern (C) _XImage * gdk_x11_image_get_ximage(_GdkImage *);
extern (C) void * gdk_x11_image_get_xdisplay(_GdkImage *);
extern (C) guint gdk_x11_drawable_get_xid(_GdkDrawable *);
extern (C) void * gdk_x11_drawable_get_xdisplay(_GdkDrawable *);
mixin(gshared!("extern (C) extern void * gdk_display;"));
} // version(DYNLINK)

