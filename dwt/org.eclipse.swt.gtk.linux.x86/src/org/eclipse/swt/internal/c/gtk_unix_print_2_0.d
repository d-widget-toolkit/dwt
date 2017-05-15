/******************************************************************************
    Based on the generated files from the BCD tool
    modified by: Frank Benoit <keinfarbton@googlemail.com>
******************************************************************************/
module org.eclipse.swt.internal.c.gtk_unix_print_2_0;

import java.lang.all;

version(Tango){
    import tango.stdc.stdint;
} else { // Phobos
    import std.stdint;
}

// FIXME: If enable this line, Occurs Segfault
//        on Linux Mint Xfce 17.1 (64-bit)
//version=DYNLINK;

version(DYNLINK){
    import java.nonstandard.SharedLib;
}

void loadLib(){
    version(DYNLINK){
        SharedLib.loadLibSymbols(symbols, "libgtk-x11-2.0.so");
    }
}

extern(C):

public import org.eclipse.swt.internal.c.atk;
public import org.eclipse.swt.internal.c.cairo;
public import org.eclipse.swt.internal.c.pango;
public import org.eclipse.swt.internal.c.gdk;
public import org.eclipse.swt.internal.c.gtk;
public import org.eclipse.swt.internal.c.glib_object;

alias void GtkPrintUnixDialogPrivate;
alias _GtkPrintUnixDialogClass GtkPrintUnixDialogClass;
alias void function() _BCD_func__5891;
alias _GtkPrintUnixDialog GtkPrintUnixDialog;
alias _GtkPrintJob GtkPrintJob;
alias void function(_GtkPrintJob *, void *, _GError *) _BCD_func__5238;
alias _BCD_func__5238 GtkPrintJobCompleteFunc;
alias void GtkPrintJobPrivate;
alias _GtkPrintJobClass GtkPrintJobClass;
alias void function(_GtkPrintJob *) _BCD_func__8505;
alias _GtkPrinter GtkPrinter;
alias gint function(_GtkPrinter *, void *) _BCD_func__5323;
alias _BCD_func__5323 GtkPrinterFunc;
alias void GtkPrintBackend;
alias void GtkPrinterPrivate;
alias _GtkPrinterClass GtkPrinterClass;
alias void function(_GtkPrinter *, gint) _BCD_func__8525;
enum GtkPrintCapabilities {
GTK_PRINT_CAPABILITY_PAGE_SET=1,
GTK_PRINT_CAPABILITY_COPIES=2,
GTK_PRINT_CAPABILITY_COLLATE=4,
GTK_PRINT_CAPABILITY_REVERSE=8,
GTK_PRINT_CAPABILITY_SCALE=16,
GTK_PRINT_CAPABILITY_GENERATE_PDF=32,
GTK_PRINT_CAPABILITY_GENERATE_PS=64,
GTK_PRINT_CAPABILITY_PREVIEW=128,
GTK_PRINT_CAPABILITY_NUMBER_UP=256,
}
alias void GtkPageSetupUnixDialogPrivate;
alias _GtkPageSetupUnixDialogClass GtkPageSetupUnixDialogClass;
alias _GtkPageSetupUnixDialog GtkPageSetupUnixDialog;
alias void function(void *) _BCD_func__5893;
alias void function(void *, void *) _BCD_func__5263;
alias gint function(_GtkWidget *, _GdkEventKey *, void *) _BCD_func__5322;
alias void function(char *, char *, void *) _BCD_func__5364;
alias void function(_GtkWindow *, guint, gint, gint, void *) _BCD_func__5383;
alias void function(_GtkWidget *, void *) _BCD_func__5476;
alias void function(_AtkObject *, _AtkPropertyValues *) _BCD_func__5620;
alias gint function(void *) _BCD_func__5621;
alias gint function(_GParamSpec *, _GString *, _GValue *) _BCD_func__5727;
alias void function(_GClosure *, _GValue *, guint, _GValue *, void *, void *) _BCD_func__5880;
alias void function(_GtkObject *, void *, guint, _GtkArg *) _BCD_func__5892;
alias void function(_GTypeInstance *, void *) _BCD_func__5904;
alias gint function(_GtkAccelKey *, _GClosure *, void *) _BCD_func__5915;
alias gint function(_GtkAccelGroup *, _GObject *, guint, gint) _BCD_func__5916;
alias void function(_GdkSpan *, void *) _BCD_func__6036;
alias gint function(void *, _GdkEvent *, void *) _BCD_func__6205;
alias void function(_GdkEvent *, void *) _BCD_func__6206;
alias void function(void *, _PangoAttrShape *, gint, void *) _BCD_func__6460;
alias void function(void *) _BCD_func__6477;
alias char * function(void *) _BCD_func__6478;
alias gint function(char *, guint, _GError * *, void *) _BCD_func__6485;
alias void function(char *, void *) _BCD_func__6488;
alias void function(void *, gint, gint) _BCD_func__6500;
alias gint function(void *) _BCD_func__2322;
alias gint function(void *, long *, gint) _BCD_func__2324;
alias gint function(void *, char *, guint) _BCD_func__2326;
alias gint function(void *, char *, guint) _BCD_func__2328;
alias gint function(void * *, char *) _BCD_func__6666;
alias gint function(char *, char * * *, guint *) _BCD_func__6667;
alias gint function(void *, char *, char *, char *, char *) _BCD_func__6668;
alias gint function(__gconv_step *, __gconv_step_data *, void *, char *, char * *, char *, char * *, guint *) _BCD_func__6669;
alias void function(__gconv_step *) _BCD_func__6670;
alias gint function(__gconv_step *) _BCD_func__6671;
alias guint function(__gconv_step *, char) _BCD_func__6672;
alias gint function(__gconv_step *, __gconv_step_data *, char * *, char *, char * *, guint *, gint, gint) _BCD_func__6673;
alias gint function(void *, void *, void *) _BCD_func__6822;
alias void * function(void *) _BCD_func__6846;
alias gint function(_PangoAttribute *, void *) _BCD_func__6847;
alias void function(void *, guint, guint, _GInterfaceInfo *) _BCD_func__6949;
alias void function(void *, guint, _GTypeInfo *, _GTypeValueTable *) _BCD_func__6950;
alias void function(void *) _BCD_func__6951;
alias void function(void *, _GObject *, gint) _BCD_func__7096;
alias void function(void *, _GObject *) _BCD_func__7098;
alias void function(_GObject *) _BCD_func__7099;
alias void function(_GObject *, guint, _GValue *, _GParamSpec *) _BCD_func__7100;
alias void function(_GObject *, guint, _GValue *, _GParamSpec *) _BCD_func__7101;
alias gint function(_GSignalInvocationHint *, _GValue *, _GValue *, void *) _BCD_func__7126;
alias gint function(_GSignalInvocationHint *, guint, _GValue *, void *) _BCD_func__7127;
alias void function(void *, _GClosure *) _BCD_func__7146;
alias void function(_GValue *, _GValue *) _BCD_func__7203;
alias void * function(void *) _BCD_func__7221;
alias void function(void *, void *) _BCD_func__7225;
alias gint function(void *, _GTypeClass *) _BCD_func__7226;
alias gint function(void *, void *, void *) _BCD_func__7274;
alias gint function(void *, void *, void *) _BCD_func__7288;
alias void function(_GScanner *, char *, gint) _BCD_func__7290;
alias gint function(void *, _GString *, void *) _BCD_func__7362;
alias void function(void *, void *, void *, _GError * *) _BCD_func__7379;
alias gint function(void *, void *, void *, _GError * *) _BCD_func__7380;
alias gint function(char *, char *, void *, _GError * *) _BCD_func__7381;
alias void * function(void *, void *) _BCD_func__7392;
alias void function(_GNode *, void *) _BCD_func__7393;
alias gint function(_GNode *, void *) _BCD_func__7394;
alias void function(char *) _BCD_func__7402;
alias void function(char *, gint, char *, void *) _BCD_func__7404;
alias gint function(_GIOChannel *, gint, void *) _BCD_func__7418;
alias gint function(_GPollFD *, guint, gint) _BCD_func__7468;
alias void function(gint, gint, void *) _BCD_func__7474;
alias void function(_GHookList *, _GHook *) _BCD_func__7505;
alias gint function(_GHook *, void *) _BCD_func__7506;
alias void function(_GHook *, void *) _BCD_func__7507;
alias gint function(_GHook *, _GHook *) _BCD_func__7508;
alias void function(guint, void *, void *) _BCD_func__7542;
alias gint function(char *, char *, guint) _BCD_func__7545;
alias char * function(void *) _BCD_func__7546;
alias char * function(char *, void *) _BCD_func__7731;
alias void function(void *, void *, void *) _BCD_func__7732;
alias guint function(void *) _BCD_func__7733;
alias gint function(void *, void *) _BCD_func__7734;
alias gint function(void *, void *, void *) _BCD_func__7735;
alias gint function(void *, void *) _BCD_func__7736;
alias gint function(void *, char *, guint) _BCD_func__7807;
alias gint function(void *, char *, guint) _BCD_func__7808;
struct _GtkPrintUnixDialogClass {
_GtkDialogClass parent_class;
_BCD_func__5891 _gtk_reserved1;
_BCD_func__5891 _gtk_reserved2;
_BCD_func__5891 _gtk_reserved3;
_BCD_func__5891 _gtk_reserved4;
_BCD_func__5891 _gtk_reserved5;
_BCD_func__5891 _gtk_reserved6;
_BCD_func__5891 _gtk_reserved7;
}
struct _GtkPrintUnixDialog {
_GtkDialog parent_instance;
void * priv;
}
struct _GtkPrintJobClass {
_GObjectClass parent_class;
_BCD_func__8505 status_changed;
_BCD_func__5891 _gtk_reserved1;
_BCD_func__5891 _gtk_reserved2;
_BCD_func__5891 _gtk_reserved3;
_BCD_func__5891 _gtk_reserved4;
_BCD_func__5891 _gtk_reserved5;
_BCD_func__5891 _gtk_reserved6;
_BCD_func__5891 _gtk_reserved7;
}
struct _GtkPrintJob {
_GObject parent_instance;
void * priv;
gint print_pages;
_GtkPageRange * page_ranges;
gint num_page_ranges;
gint page_set;
gint num_copies;
double scale;
guint bitfield0;
}
struct _GtkPrinterClass {
_GObjectClass parent_class;
_BCD_func__8525 details_acquired;
_BCD_func__5891 _gtk_reserved1;
_BCD_func__5891 _gtk_reserved2;
_BCD_func__5891 _gtk_reserved3;
_BCD_func__5891 _gtk_reserved4;
_BCD_func__5891 _gtk_reserved5;
_BCD_func__5891 _gtk_reserved6;
_BCD_func__5891 _gtk_reserved7;
}
struct _GtkPrinter {
_GObject parent_instance;
void * priv;
}
struct _GtkPageSetupUnixDialogClass {
_GtkDialogClass parent_class;
_BCD_func__5891 _gtk_reserved1;
_BCD_func__5891 _gtk_reserved2;
_BCD_func__5891 _gtk_reserved3;
_BCD_func__5891 _gtk_reserved4;
_BCD_func__5891 _gtk_reserved5;
_BCD_func__5891 _gtk_reserved6;
_BCD_func__5891 _gtk_reserved7;
}
struct _GtkPageSetupUnixDialog {
_GtkDialog parent_instance;
void * priv;
}
version(DYNLINK){
mixin(gshared!(
"alias extern (C) void function(_GtkPrintUnixDialog *, gint) TGTKgtk_print_unix_dialog_set_manual_capabilities; extern(D) TGTKgtk_print_unix_dialog_set_manual_capabilities gtk_print_unix_dialog_set_manual_capabilities;
alias extern (C) void function(_GtkPrintUnixDialog *, _GtkWidget *, _GtkWidget *) TGTKgtk_print_unix_dialog_add_custom_tab; extern(D) TGTKgtk_print_unix_dialog_add_custom_tab gtk_print_unix_dialog_add_custom_tab;
alias extern (C) _GtkPrinter * function(_GtkPrintUnixDialog *) TGTKgtk_print_unix_dialog_get_selected_printer; extern(D) TGTKgtk_print_unix_dialog_get_selected_printer gtk_print_unix_dialog_get_selected_printer;
alias extern (C) void * function(_GtkPrintUnixDialog *) TGTKgtk_print_unix_dialog_get_settings; extern(D) TGTKgtk_print_unix_dialog_get_settings gtk_print_unix_dialog_get_settings;
alias extern (C) void function(_GtkPrintUnixDialog *, void *) TGTKgtk_print_unix_dialog_set_settings; extern(D) TGTKgtk_print_unix_dialog_set_settings gtk_print_unix_dialog_set_settings;
alias extern (C) gint function(_GtkPrintUnixDialog *) TGTKgtk_print_unix_dialog_get_current_page; extern(D) TGTKgtk_print_unix_dialog_get_current_page gtk_print_unix_dialog_get_current_page;
alias extern (C) void function(_GtkPrintUnixDialog *, gint) TGTKgtk_print_unix_dialog_set_current_page; extern(D) TGTKgtk_print_unix_dialog_set_current_page gtk_print_unix_dialog_set_current_page;
alias extern (C) void * function(_GtkPrintUnixDialog *) TGTKgtk_print_unix_dialog_get_page_setup; extern(D) TGTKgtk_print_unix_dialog_get_page_setup gtk_print_unix_dialog_get_page_setup;
alias extern (C) void function(_GtkPrintUnixDialog *, void *) TGTKgtk_print_unix_dialog_set_page_setup; extern(D) TGTKgtk_print_unix_dialog_set_page_setup gtk_print_unix_dialog_set_page_setup;
alias extern (C) _GtkWidget * function(char *, _GtkWindow *) TGTKgtk_print_unix_dialog_new; extern(D) TGTKgtk_print_unix_dialog_new gtk_print_unix_dialog_new;
alias extern (C) GType function() TGTKgtk_print_unix_dialog_get_type; extern(D) TGTKgtk_print_unix_dialog_get_type gtk_print_unix_dialog_get_type;
alias extern (C) void function(_GtkPrintJob *, _BCD_func__5238, void *, _BCD_func__5893) TGTKgtk_print_job_send; extern(D) TGTKgtk_print_job_send gtk_print_job_send;
alias extern (C) gint function(_GtkPrintJob *) TGTKgtk_print_job_get_track_print_status; extern(D) TGTKgtk_print_job_get_track_print_status gtk_print_job_get_track_print_status;
alias extern (C) void function(_GtkPrintJob *, gint) TGTKgtk_print_job_set_track_print_status; extern(D) TGTKgtk_print_job_set_track_print_status gtk_print_job_set_track_print_status;
alias extern (C) void * function(_GtkPrintJob *, _GError * *) TGTKgtk_print_job_get_surface; extern(D) TGTKgtk_print_job_get_surface gtk_print_job_get_surface;
alias extern (C) gint function(_GtkPrintJob *, char *, _GError * *) TGTKgtk_print_job_set_source_file; extern(D) TGTKgtk_print_job_set_source_file gtk_print_job_set_source_file;
alias extern (C) gint function(_GtkPrintJob *) TGTKgtk_print_job_get_status; extern(D) TGTKgtk_print_job_get_status gtk_print_job_get_status;
alias extern (C) char * function(_GtkPrintJob *) TGTKgtk_print_job_get_title; extern(D) TGTKgtk_print_job_get_title gtk_print_job_get_title;
alias extern (C) _GtkPrinter * function(_GtkPrintJob *) TGTKgtk_print_job_get_printer; extern(D) TGTKgtk_print_job_get_printer gtk_print_job_get_printer;
alias extern (C) void * function(_GtkPrintJob *) TGTKgtk_print_job_get_settings; extern(D) TGTKgtk_print_job_get_settings gtk_print_job_get_settings;
alias extern (C) _GtkPrintJob * function(char *, _GtkPrinter *, void *, void *) TGTKgtk_print_job_new; extern(D) TGTKgtk_print_job_new gtk_print_job_new;
alias extern (C) GType function() TGTKgtk_print_job_get_type; extern(D) TGTKgtk_print_job_get_type gtk_print_job_get_type;
alias extern (C) void function(_BCD_func__5323, void *, _BCD_func__5893, gint) TGTKgtk_enumerate_printers; extern(D) TGTKgtk_enumerate_printers gtk_enumerate_printers;
alias extern (C) gint function(_GtkPrinter *) TGTKgtk_printer_get_capabilities; extern(D) TGTKgtk_printer_get_capabilities gtk_printer_get_capabilities;
alias extern (C) void function(_GtkPrinter *) TGTKgtk_printer_request_details; extern(D) TGTKgtk_printer_request_details gtk_printer_request_details;
alias extern (C) gint function(_GtkPrinter *) TGTKgtk_printer_has_details; extern(D) TGTKgtk_printer_has_details gtk_printer_has_details;
alias extern (C) gint function(_GtkPrinter *, _GtkPrinter *) TGTKgtk_printer_compare; extern(D) TGTKgtk_printer_compare gtk_printer_compare;
alias extern (C) _GList * function(_GtkPrinter *) TGTKgtk_printer_list_papers; extern(D) TGTKgtk_printer_list_papers gtk_printer_list_papers;
alias extern (C) gint function(_GtkPrinter *) TGTKgtk_printer_accepts_ps; extern(D) TGTKgtk_printer_accepts_ps gtk_printer_accepts_ps;
alias extern (C) gint function(_GtkPrinter *) TGTKgtk_printer_accepts_pdf; extern(D) TGTKgtk_printer_accepts_pdf gtk_printer_accepts_pdf;
alias extern (C) gint function(_GtkPrinter *) TGTKgtk_printer_is_default; extern(D) TGTKgtk_printer_is_default gtk_printer_is_default;
alias extern (C) gint function(_GtkPrinter *) TGTKgtk_printer_is_virtual; extern(D) TGTKgtk_printer_is_virtual gtk_printer_is_virtual;
alias extern (C) gint function(_GtkPrinter *) TGTKgtk_printer_is_active; extern(D) TGTKgtk_printer_is_active gtk_printer_is_active;
alias extern (C) gint function(_GtkPrinter *) TGTKgtk_printer_get_job_count; extern(D) TGTKgtk_printer_get_job_count gtk_printer_get_job_count;
alias extern (C) char * function(_GtkPrinter *) TGTKgtk_printer_get_icon_name; extern(D) TGTKgtk_printer_get_icon_name gtk_printer_get_icon_name;
alias extern (C) char * function(_GtkPrinter *) TGTKgtk_printer_get_location; extern(D) TGTKgtk_printer_get_location gtk_printer_get_location;
alias extern (C) char * function(_GtkPrinter *) TGTKgtk_printer_get_description; extern(D) TGTKgtk_printer_get_description gtk_printer_get_description;
alias extern (C) char * function(_GtkPrinter *) TGTKgtk_printer_get_state_message; extern(D) TGTKgtk_printer_get_state_message gtk_printer_get_state_message;
alias extern (C) char * function(_GtkPrinter *) TGTKgtk_printer_get_name; extern(D) TGTKgtk_printer_get_name gtk_printer_get_name;
alias extern (C) void * function(_GtkPrinter *) TGTKgtk_printer_get_backend; extern(D) TGTKgtk_printer_get_backend gtk_printer_get_backend;
alias extern (C) _GtkPrinter * function(char *, void *, gint) TGTKgtk_printer_new; extern(D) TGTKgtk_printer_new gtk_printer_new;
alias extern (C) GType function() TGTKgtk_printer_get_type; extern(D) TGTKgtk_printer_get_type gtk_printer_get_type;
alias extern (C) GType function() TGTKgtk_print_capabilities_get_type; extern(D) TGTKgtk_print_capabilities_get_type gtk_print_capabilities_get_type;
alias extern (C) void * function(_GtkPageSetupUnixDialog *) TGTKgtk_page_setup_unix_dialog_get_print_settings; extern(D) TGTKgtk_page_setup_unix_dialog_get_print_settings gtk_page_setup_unix_dialog_get_print_settings;
alias extern (C) void function(_GtkPageSetupUnixDialog *, void *) TGTKgtk_page_setup_unix_dialog_set_print_settings; extern(D) TGTKgtk_page_setup_unix_dialog_set_print_settings gtk_page_setup_unix_dialog_set_print_settings;
alias extern (C) void * function(_GtkPageSetupUnixDialog *) TGTKgtk_page_setup_unix_dialog_get_page_setup; extern(D) TGTKgtk_page_setup_unix_dialog_get_page_setup gtk_page_setup_unix_dialog_get_page_setup;
alias extern (C) void function(_GtkPageSetupUnixDialog *, void *) TGTKgtk_page_setup_unix_dialog_set_page_setup; extern(D) TGTKgtk_page_setup_unix_dialog_set_page_setup gtk_page_setup_unix_dialog_set_page_setup;
alias extern (C) _GtkWidget * function(char *, _GtkWindow *) TGTKgtk_page_setup_unix_dialog_new; extern(D) TGTKgtk_page_setup_unix_dialog_new gtk_page_setup_unix_dialog_new;
alias extern (C) GType function() TGTKgtk_page_setup_unix_dialog_get_type; extern(D) TGTKgtk_page_setup_unix_dialog_get_type gtk_page_setup_unix_dialog_get_type;"
));

extern(D) Symbol[] symbols;
extern(D) static this ()
{
    symbols = [
        Symbol("gtk_print_unix_dialog_set_manual_capabilities",  cast(void**)& gtk_print_unix_dialog_set_manual_capabilities),
        Symbol("gtk_print_unix_dialog_add_custom_tab",  cast(void**)& gtk_print_unix_dialog_add_custom_tab),
        Symbol("gtk_print_unix_dialog_get_selected_printer",  cast(void**)& gtk_print_unix_dialog_get_selected_printer),
        Symbol("gtk_print_unix_dialog_get_settings",  cast(void**)& gtk_print_unix_dialog_get_settings),
        Symbol("gtk_print_unix_dialog_set_settings",  cast(void**)& gtk_print_unix_dialog_set_settings),
        Symbol("gtk_print_unix_dialog_get_current_page",  cast(void**)& gtk_print_unix_dialog_get_current_page),
        Symbol("gtk_print_unix_dialog_set_current_page",  cast(void**)& gtk_print_unix_dialog_set_current_page),
        Symbol("gtk_print_unix_dialog_get_page_setup",  cast(void**)& gtk_print_unix_dialog_get_page_setup),
        Symbol("gtk_print_unix_dialog_set_page_setup",  cast(void**)& gtk_print_unix_dialog_set_page_setup),
        Symbol("gtk_print_unix_dialog_new",  cast(void**)& gtk_print_unix_dialog_new),
        Symbol("gtk_print_unix_dialog_get_type",  cast(void**)& gtk_print_unix_dialog_get_type),
        Symbol("gtk_print_job_send",  cast(void**)& gtk_print_job_send),
        Symbol("gtk_print_job_get_track_print_status",  cast(void**)& gtk_print_job_get_track_print_status),
        Symbol("gtk_print_job_set_track_print_status",  cast(void**)& gtk_print_job_set_track_print_status),
        Symbol("gtk_print_job_get_surface",  cast(void**)& gtk_print_job_get_surface),
        Symbol("gtk_print_job_set_source_file",  cast(void**)& gtk_print_job_set_source_file),
        Symbol("gtk_print_job_get_status",  cast(void**)& gtk_print_job_get_status),
        Symbol("gtk_print_job_get_title",  cast(void**)& gtk_print_job_get_title),
        Symbol("gtk_print_job_get_printer",  cast(void**)& gtk_print_job_get_printer),
        Symbol("gtk_print_job_get_settings",  cast(void**)& gtk_print_job_get_settings),
        Symbol("gtk_print_job_new",  cast(void**)& gtk_print_job_new),
        Symbol("gtk_print_job_get_type",  cast(void**)& gtk_print_job_get_type),
        Symbol("gtk_enumerate_printers",  cast(void**)& gtk_enumerate_printers),
        Symbol("gtk_printer_get_capabilities",  cast(void**)& gtk_printer_get_capabilities),
        Symbol("gtk_printer_request_details",  cast(void**)& gtk_printer_request_details),
        Symbol("gtk_printer_has_details",  cast(void**)& gtk_printer_has_details),
        Symbol("gtk_printer_compare",  cast(void**)& gtk_printer_compare),
        Symbol("gtk_printer_list_papers",  cast(void**)& gtk_printer_list_papers),
        Symbol("gtk_printer_accepts_ps",  cast(void**)& gtk_printer_accepts_ps),
        Symbol("gtk_printer_accepts_pdf",  cast(void**)& gtk_printer_accepts_pdf),
        Symbol("gtk_printer_is_default",  cast(void**)& gtk_printer_is_default),
        Symbol("gtk_printer_is_virtual",  cast(void**)& gtk_printer_is_virtual),
        Symbol("gtk_printer_is_active",  cast(void**)& gtk_printer_is_active),
        Symbol("gtk_printer_get_job_count",  cast(void**)& gtk_printer_get_job_count),
        Symbol("gtk_printer_get_icon_name",  cast(void**)& gtk_printer_get_icon_name),
        Symbol("gtk_printer_get_location",  cast(void**)& gtk_printer_get_location),
        Symbol("gtk_printer_get_description",  cast(void**)& gtk_printer_get_description),
        Symbol("gtk_printer_get_state_message",  cast(void**)& gtk_printer_get_state_message),
        Symbol("gtk_printer_get_name",  cast(void**)& gtk_printer_get_name),
        Symbol("gtk_printer_get_backend",  cast(void**)& gtk_printer_get_backend),
        Symbol("gtk_printer_new",  cast(void**)& gtk_printer_new),
        Symbol("gtk_printer_get_type",  cast(void**)& gtk_printer_get_type),
        Symbol("gtk_print_capabilities_get_type",  cast(void**)& gtk_print_capabilities_get_type),
        Symbol("gtk_page_setup_unix_dialog_get_print_settings",  cast(void**)& gtk_page_setup_unix_dialog_get_print_settings),
        Symbol("gtk_page_setup_unix_dialog_set_print_settings",  cast(void**)& gtk_page_setup_unix_dialog_set_print_settings),
        Symbol("gtk_page_setup_unix_dialog_get_page_setup",  cast(void**)& gtk_page_setup_unix_dialog_get_page_setup),
        Symbol("gtk_page_setup_unix_dialog_set_page_setup",  cast(void**)& gtk_page_setup_unix_dialog_set_page_setup),
        Symbol("gtk_page_setup_unix_dialog_new",  cast(void**)& gtk_page_setup_unix_dialog_new),
        Symbol("gtk_page_setup_unix_dialog_get_type",  cast(void**)& gtk_page_setup_unix_dialog_get_type)
    ];
}

} else { // version(DYNLINK)
extern (C) void gtk_print_unix_dialog_set_manual_capabilities(_GtkPrintUnixDialog *, gint);
extern (C) void gtk_print_unix_dialog_add_custom_tab(_GtkPrintUnixDialog *, _GtkWidget *, _GtkWidget *);
extern (C) _GtkPrinter * gtk_print_unix_dialog_get_selected_printer(_GtkPrintUnixDialog *);
extern (C) void * gtk_print_unix_dialog_get_settings(_GtkPrintUnixDialog *);
extern (C) void gtk_print_unix_dialog_set_settings(_GtkPrintUnixDialog *, void *);
extern (C) gint gtk_print_unix_dialog_get_current_page(_GtkPrintUnixDialog *);
extern (C) void gtk_print_unix_dialog_set_current_page(_GtkPrintUnixDialog *, gint);
extern (C) void * gtk_print_unix_dialog_get_page_setup(_GtkPrintUnixDialog *);
extern (C) void gtk_print_unix_dialog_set_page_setup(_GtkPrintUnixDialog *, void *);
extern (C) _GtkWidget * gtk_print_unix_dialog_new(char *, _GtkWindow *);
extern (C) GType gtk_print_unix_dialog_get_type();
extern (C) void gtk_print_job_send(_GtkPrintJob *, _BCD_func__5238, void *, _BCD_func__5893);
extern (C) gint gtk_print_job_get_track_print_status(_GtkPrintJob *);
extern (C) void gtk_print_job_set_track_print_status(_GtkPrintJob *, gint);
extern (C) void * gtk_print_job_get_surface(_GtkPrintJob *, _GError * *);
extern (C) gint gtk_print_job_set_source_file(_GtkPrintJob *, char *, _GError * *);
extern (C) gint gtk_print_job_get_status(_GtkPrintJob *);
extern (C) char * gtk_print_job_get_title(_GtkPrintJob *);
extern (C) _GtkPrinter * gtk_print_job_get_printer(_GtkPrintJob *);
extern (C) void * gtk_print_job_get_settings(_GtkPrintJob *);
extern (C) _GtkPrintJob * gtk_print_job_new(char *, _GtkPrinter *, void *, void *);
extern (C) GType gtk_print_job_get_type();
extern (C) void gtk_enumerate_printers(_BCD_func__5323, void *, _BCD_func__5893, gint);
extern (C) gint gtk_printer_get_capabilities(_GtkPrinter *);
extern (C) void gtk_printer_request_details(_GtkPrinter *);
extern (C) gint gtk_printer_has_details(_GtkPrinter *);
extern (C) gint gtk_printer_compare(_GtkPrinter *, _GtkPrinter *);
extern (C) _GList * gtk_printer_list_papers(_GtkPrinter *);
extern (C) gint gtk_printer_accepts_ps(_GtkPrinter *);
extern (C) gint gtk_printer_accepts_pdf(_GtkPrinter *);
extern (C) gint gtk_printer_is_default(_GtkPrinter *);
extern (C) gint gtk_printer_is_virtual(_GtkPrinter *);
extern (C) gint gtk_printer_is_active(_GtkPrinter *);
extern (C) gint gtk_printer_get_job_count(_GtkPrinter *);
extern (C) char * gtk_printer_get_icon_name(_GtkPrinter *);
extern (C) char * gtk_printer_get_location(_GtkPrinter *);
extern (C) char * gtk_printer_get_description(_GtkPrinter *);
extern (C) char * gtk_printer_get_state_message(_GtkPrinter *);
extern (C) char * gtk_printer_get_name(_GtkPrinter *);
extern (C) void * gtk_printer_get_backend(_GtkPrinter *);
extern (C) _GtkPrinter * gtk_printer_new(char *, void *, gint);
extern (C) GType gtk_printer_get_type();
extern (C) GType gtk_print_capabilities_get_type();
extern (C) void * gtk_page_setup_unix_dialog_get_print_settings(_GtkPageSetupUnixDialog *);
extern (C) void gtk_page_setup_unix_dialog_set_print_settings(_GtkPageSetupUnixDialog *, void *);
extern (C) void * gtk_page_setup_unix_dialog_get_page_setup(_GtkPageSetupUnixDialog *);
extern (C) void gtk_page_setup_unix_dialog_set_page_setup(_GtkPageSetupUnixDialog *, void *);
extern (C) _GtkWidget * gtk_page_setup_unix_dialog_new(char *, _GtkWindow *);
extern (C) GType gtk_page_setup_unix_dialog_get_type();
} // version(DYNLINK)

