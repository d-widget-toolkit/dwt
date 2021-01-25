module org.eclipse.swt.internal.c.gio_2_0;

import java.nonstandard.SharedLib;

import org.eclipse.swt.internal.c.glib_object;

/* Types */
extern(C)
{
    struct GAppInfo; /* dummy typedef in C */
    struct GAppLaunchContextPrivate;
    struct GCancellablePrivate;
    struct GFile; /* dummy typedef in C */
    struct GFileInfo;
    struct GIcon; /* dummy typedef in C */

    struct _GAppLaunchContext
    {
        GObject parent_instance;
        /*< private >*/
        GAppLaunchContextPrivate* priv;
    }
    alias GAppLaunchContext = _GAppLaunchContext;

    struct _GCancellable
    {
        GObject parent_instance;
        /*< private >*/
        GCancellablePrivate* priv;
    }
    alias GCancellable = _GCancellable;

}

version (DYNLINK) {
    @nogc nothrow extern(C) {
        alias DGIOg_app_info_create_from_commandline = GAppInfo* function(char*, char*, int, GError**);
        alias DGIOg_app_info_get_default_for_type = GAppInfo* function(char*, gboolean);
        alias DGIOg_app_info_get_all = GList* function();
        alias DGIOg_app_info_get_executable = char* function(GAppInfo*);
        alias DGIOg_app_info_get_icon = GIcon* function(GAppInfo*);
        alias DGIOg_app_info_get_name = char* function(GAppInfo*);
        alias DGIOg_app_info_launch = gboolean function(GAppInfo*, GList*, GAppLaunchContext*, GError**);
        alias DGIOg_app_info_launch_default_for_uri = gboolean function(char*, GAppLaunchContext*, GError**);
        alias DGIOg_app_info_supports_uris = gboolean function(GAppInfo*);

        alias DGIOg_content_type_equals = gboolean function(char*, char*);
        alias DGIOg_content_type_is_a = gboolean function(char*, char*);

        alias DGIOg_file_get_uri = char* function(GFile*);
        alias DGIOg_file_new_for_commandline_arg = GFile* function(char*);
        alias DGIOg_file_new_for_path = GFile* function(char*);
        alias DGIOg_file_new_for_uri = GFile* function(char*);
        alias DGIOg_file_query_info = GFileInfo* function(GFile*, char*, int, GCancellable*, GError**);

        alias DGIOg_file_info_get_content_type = char* function(GFileInfo*);

        alias DGIOg_icon_new_for_string = GIcon* function(char*, GError**);
        alias DGIOg_icon_to_string = char* function(GIcon*);
    }

    __gshared {
        DGIOg_app_info_create_from_commandline g_app_info_create_from_commandline;
        DGIOg_app_info_get_default_for_type g_app_info_get_default_for_type;
        DGIOg_app_info_get_all g_app_info_get_all;
        DGIOg_app_info_get_executable g_app_info_get_executable;
        DGIOg_app_info_get_icon g_app_info_get_icon;
        DGIOg_app_info_get_name g_app_info_get_name;
        DGIOg_app_info_launch g_app_info_launch;
        DGIOg_app_info_launch_default_for_uri g_app_info_launch_default_for_uri;
        DGIOg_app_info_supports_uris g_app_info_supports_uris;

        DGIOg_content_type_equals g_content_type_equals;
        DGIOg_content_type_is_a g_content_type_is_a;

        DGIOg_file_get_uri g_file_get_uri;
        DGIOg_file_new_for_commandline_arg g_file_new_for_commandline_arg;
        DGIOg_file_new_for_path g_file_new_for_path;
        DGIOg_file_new_for_uri g_file_new_for_uri;
        DGIOg_file_query_info g_file_query_info;

        DGIOg_file_info_get_content_type g_file_info_get_content_type;

        DGIOg_icon_new_for_string g_icon_new_for_string;
        DGIOg_icon_to_string g_icon_to_string;
    }

    private Symbol[] symbols;
    static this() {
        symbols = [
            Symbol("g_app_info_create_from_commandline", cast(void**)&g_app_info_create_from_commandline),
            Symbol("g_app_info_get_default_for_type", cast(void**)&g_app_info_get_default_for_type),
            Symbol("g_app_info_get_all", cast(void**)&g_app_info_get_all),
            Symbol("g_app_info_get_executable", cast(void**)&g_app_info_get_executable),
            Symbol("g_app_info_get_icon", cast(void**)&g_app_info_get_icon),
            Symbol("g_app_info_get_name", cast(void**)&g_app_info_get_name),
            Symbol("g_app_info_launch", cast(void**)&g_app_info_launch),
            Symbol("g_app_info_launch_default_for_uri", cast(void**)&g_app_info_launch_default_for_uri),
            Symbol("g_app_info_supports_uris", cast(void**)&g_app_info_supports_uris),

            Symbol("g_file_get_uri", cast(void**)&g_file_get_uri),
            Symbol("g_file_new_for_commandline_arg", cast(void**)&g_file_new_for_commandline_arg),
            Symbol("g_file_new_for_path", cast(void**)&g_file_new_for_path),
            Symbol("g_file_new_for_uri", cast(void**)&g_file_new_for_uri),
            Symbol("g_file_query_info", cast(void**)&g_file_query_info),

            Symbol("g_file_info_get_content_type", cast(void**)&g_file_info_get_content_type),

            Symbol("g_icon_new_for_string", cast(void**)&g_icon_new_for_string),
            Symbol("g_icon_to_string", cast(void**)&g_icon_to_string),
        ];
    }
} else { /* !DYNLINK */
    extern(C) GAppInfo* g_app_info_create_from_commandline(char*, char*, int, GError**);
    extern(C) GAppInfo* g_app_info_get_default_for_type(char*, gboolean);
    extern(C) GList* g_app_info_get_all();
    extern(C) char* g_app_info_get_executable(GAppInfo*);
    extern(C) GIcon* g_app_info_get_icon(GAppInfo*);
    extern(C) char* g_app_info_get_name(GAppInfo*);
    extern(C) gboolean g_app_info_launch(GAppInfo*, GList*, GAppLaunchContext*, GError*);
    extern(C) gboolean g_app_info_launch_default_for_uri(char*, GAppLaunchContext*, GError**);
    extern(C) gboolean g_app_info_supports_uris(GAppInfo*);

    extern(C) gboolean g_content_type_equals(char*, char*);
    extern(C) gboolean g_content_type_is_a(char*, char*);

    extern(C) char* g_file_get_uri(GFile*);
    extern(C) GFile* g_file_new_for_commandline_arg(char*);
    extern(C) GFile* g_file_new_for_path(char*);
    extern(C) GFile* g_file_new_for_uri(char*);
    extern(C) GFileInfo* g_file_query_info(GFile*, char*, int, GCancellable*, GError**);

    extern(C) char* g_file_info_get_content_type(GFileInfo*);

    extern(C) GIcon* g_icon_new_for_string(char*, GError**);
    extern(C) char* g_icon_to_string(GIcon*);
}
