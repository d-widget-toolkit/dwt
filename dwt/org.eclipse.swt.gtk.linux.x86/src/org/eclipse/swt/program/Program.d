/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module org.eclipse.swt.program.Program;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.internal.Compatibility;
import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.Library;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import java.lang.all;
import java.nonstandard.SharedLib;

version(Tango){
    static import tango.core.Array;
    static import tango.io.device.File;
    static import tango.io.stream.Lines;
} else { // Phobos
    static import std.string;
    static import std.file;
    static import std.algorithm;
}

version( build ){
    pragma(link, "gnomeui-2" );
}

private extern(C) {
    alias int GnomeIconLookupResultFlags;
    alias int GnomeIconLookupFlags;
    GnomeIconTheme *gnome_icon_theme_new  ();
    char *gnome_icon_lookup      (
                GtkIconTheme *icon_theme,
                void  *thumbnail_factory,
                char  *file_uri,
                char  *custom_icon,
                void  *file_info,
                char  *mime_type,
                GnomeIconLookupFlags        flags,
                GnomeIconLookupResultFlags *result);
    int gnome_vfs_init();
    char* gnome_icon_theme_lookup_icon(GnomeIconTheme *theme,char *icon_name,int size, GnomeIconData **icon_data, int *base_size) ;

    alias void GnomeIconTheme;
    alias void GnomeIconData;

    struct GnomeVFSMimeApplication{
        /*< public > */
        char *id;
        char *name;

        /*< private > */
        char *command;
        int    can_open_multiple_files;
        int    expects_uris;
        GList *supported_uri_schemes;
        int    requires_terminal;

        /* Padded to avoid future breaks in ABI compatibility */
        void * reserved1;

        void * priv;
    }
}

struct GNOME {
    private static extern(C){
        enum {
            GNOME_ICON_LOOKUP_FLAGS_NONE = 0,
            GNOME_ICON_LOOKUP_FLAGS_EMBEDDING_TEXT = 1<<0,
            GNOME_ICON_LOOKUP_FLAGS_SHOW_SMALL_IMAGES_AS_THEMSELVES = 1<<1,
            GNOME_ICON_LOOKUP_FLAGS_ALLOW_SVG_AS_THEMSELVES = 1<<2
        }
        enum {
            GNOME_VFS_MAKE_URI_DIR_NONE = 0,
            GNOME_VFS_MAKE_URI_DIR_HOMEDIR = 1 << 0,
            GNOME_VFS_MAKE_URI_DIR_CURRENT = 1 << 1
        }
        alias int GnomeVFSMakeURIDirs;
        enum {
            GNOME_VFS_OK,
            GNOME_VFS_ERROR_NOT_FOUND,
            GNOME_VFS_ERROR_GENERIC,
            GNOME_VFS_ERROR_INTERNAL,
            GNOME_VFS_ERROR_BAD_PARAMETERS,
            GNOME_VFS_ERROR_NOT_SUPPORTED,
            GNOME_VFS_ERROR_IO,
            GNOME_VFS_ERROR_CORRUPTED_DATA,
            GNOME_VFS_ERROR_WRONG_FORMAT,
            GNOME_VFS_ERROR_BAD_FILE,
            GNOME_VFS_ERROR_TOO_BIG,
            GNOME_VFS_ERROR_NO_SPACE,
            GNOME_VFS_ERROR_READ_ONLY,
            GNOME_VFS_ERROR_INVALID_URI,
            GNOME_VFS_ERROR_NOT_OPEN,
            GNOME_VFS_ERROR_INVALID_OPEN_MODE,
            GNOME_VFS_ERROR_ACCESS_DENIED,
            GNOME_VFS_ERROR_TOO_MANY_OPEN_FILES,
            GNOME_VFS_ERROR_EOF,
            GNOME_VFS_ERROR_NOT_A_DIRECTORY,
            GNOME_VFS_ERROR_IN_PROGRESS,
            GNOME_VFS_ERROR_INTERRUPTED,
            GNOME_VFS_ERROR_FILE_EXISTS,
            GNOME_VFS_ERROR_LOOP,
            GNOME_VFS_ERROR_NOT_PERMITTED,
            GNOME_VFS_ERROR_IS_DIRECTORY,
            GNOME_VFS_ERROR_NO_MEMORY,
            GNOME_VFS_ERROR_HOST_NOT_FOUND,
            GNOME_VFS_ERROR_INVALID_HOST_NAME,
            GNOME_VFS_ERROR_HOST_HAS_NO_ADDRESS,
            GNOME_VFS_ERROR_LOGIN_FAILED,
            GNOME_VFS_ERROR_CANCELLED,
            GNOME_VFS_ERROR_DIRECTORY_BUSY,
            GNOME_VFS_ERROR_DIRECTORY_NOT_EMPTY,
            GNOME_VFS_ERROR_TOO_MANY_LINKS,
            GNOME_VFS_ERROR_READ_ONLY_FILE_SYSTEM,
            GNOME_VFS_ERROR_NOT_SAME_FILE_SYSTEM,
            GNOME_VFS_ERROR_NAME_TOO_LONG,
            GNOME_VFS_ERROR_SERVICE_NOT_AVAILABLE,
            GNOME_VFS_ERROR_SERVICE_OBSOLETE,
            GNOME_VFS_ERROR_PROTOCOL_ERROR,
            GNOME_VFS_ERROR_NO_MASTER_BROWSER,
            GNOME_VFS_ERROR_NO_DEFAULT,
            GNOME_VFS_ERROR_NO_HANDLER,
            GNOME_VFS_ERROR_PARSE,
            GNOME_VFS_ERROR_LAUNCH,
            GNOME_VFS_ERROR_TIMEOUT,
            GNOME_VFS_ERROR_NAMESERVER,
            GNOME_VFS_ERROR_LOCKED,
            GNOME_VFS_ERROR_DEPRECATED_FUNCTION,
            GNOME_VFS_ERROR_INVALID_FILENAME,
            GNOME_VFS_ERROR_NOT_A_SYMBOLIC_LINK,
            GNOME_VFS_NUM_ERRORS
        }
        alias int GnomeVFSResult;

        enum {
            GNOME_VFS_MIME_APPLICATION_ARGUMENT_TYPE_URIS,
            GNOME_VFS_MIME_APPLICATION_ARGUMENT_TYPE_PATHS,
            GNOME_VFS_MIME_APPLICATION_ARGUMENT_TYPE_URIS_FOR_NON_FILES
        }

        alias GtkIconTheme GnomeIconTheme;
        alias .gnome_icon_theme_lookup_icon gnome_icon_theme_lookup_icon;
        alias .gnome_vfs_init gnome_vfs_init;
        alias .gnome_icon_lookup gnome_icon_lookup;
        alias .gnome_icon_theme_new gnome_icon_theme_new;


        GnomeVFSMimeApplication * function ( char *mime_type ) gnome_vfs_mime_get_default_application;
        char* function(char*, int ) gnome_vfs_make_uri_from_input_with_dirs;
        GnomeVFSResult function( GnomeVFSMimeApplication*, GList*) gnome_vfs_mime_application_launch;
        void function(GnomeVFSMimeApplication*) gnome_vfs_mime_application_free;
        GList* function(char*) gnome_vfs_mime_get_extensions_list;
        void function(GList*) gnome_vfs_mime_extensions_list_free;
        void function(GList*) gnome_vfs_mime_registered_mime_type_list_free;
        GnomeVFSResult function(char*) gnome_vfs_url_show;
        char* function(char*) gnome_vfs_make_uri_from_input;
        GList* function() gnome_vfs_get_registered_mime_types;
        char* function(char*) gnome_vfs_mime_type_from_name;
    }
    static Symbol[] symbols;
    static this () {
        symbols = [
            Symbol("gnome_vfs_mime_get_default_application", cast(void**)&gnome_vfs_mime_get_default_application ),
            Symbol("gnome_vfs_make_uri_from_input_with_dirs", cast(void**)&gnome_vfs_make_uri_from_input_with_dirs ),
            Symbol("gnome_vfs_mime_application_launch", cast(void**)&gnome_vfs_mime_application_launch ),
            Symbol("gnome_vfs_mime_application_free", cast(void**)&gnome_vfs_mime_application_free ),
            Symbol("gnome_vfs_url_show", cast(void**)&gnome_vfs_url_show ),
            Symbol("gnome_vfs_make_uri_from_input", cast(void**)&gnome_vfs_make_uri_from_input ),
            Symbol("gnome_vfs_get_registered_mime_types", cast(void**)&gnome_vfs_get_registered_mime_types ),
            Symbol("gnome_vfs_mime_get_extensions_list", cast(void**)&gnome_vfs_mime_get_extensions_list ),
            Symbol("gnome_vfs_mime_extensions_list_free", cast(void**)&gnome_vfs_mime_extensions_list_free ),
            Symbol("gnome_vfs_mime_registered_mime_type_list_free", cast(void**)&gnome_vfs_mime_registered_mime_type_list_free ),
            Symbol("gnome_vfs_mime_type_from_name", cast(void**)&gnome_vfs_mime_type_from_name )
        ];
    }
}

/**
 * Instances of this class represent programs and
 * their associated file extensions in the operating
 * system.
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#program">Program snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class Program {
    String name;
    String command;
    String iconPath;
    Display display;

    /* Gnome specific
     * true if command expects a URI
     * false if expects a path
     */
    bool gnomeExpectUri;

    static ptrdiff_t cdeShell;

    static const String[] CDE_ICON_EXT = [ ".m.pm"[],   ".l.pm",   ".s.pm",   ".t.pm" ];
    static const String[] CDE_MASK_EXT = [ ".m_m.bm"[], ".l_m.bm", ".s_m.bm", ".t_m.bm" ];
    static const String DESKTOP_DATA = "Program_DESKTOP";
    static const String ICON_THEME_DATA = "Program_GNOME_ICON_THEME";
    static const String PREFIX_HTTP = "http://"; //$NON-NLS-1$
    static const String PREFIX_HTTPS = "https://"; //$NON-NLS-1$
    static const int DESKTOP_UNKNOWN = 0;
    static const int DESKTOP_GNOME = 1;
    static const int DESKTOP_GNOME_24 = 2;
    static const int DESKTOP_CDE = 3;
    static const int PREFERRED_ICON_SIZE = 16;

/**
 * Prevents uninitialized instances from being created outside the package.
 */
this() {
}

/* Determine the desktop for the given display. */
static int getDesktop(Display display) {
    if (display is null) return DESKTOP_UNKNOWN;
    Integer desktopValue = cast(Integer)display.getData(DESKTOP_DATA);
    if (desktopValue !is null) return desktopValue.intValue;
    int desktop = DESKTOP_UNKNOWN;

    /* Get the list of properties on the root window. */
    void* xDisplay = OS.GDK_DISPLAY();
    size_t rootWindow = OS.XDefaultRootWindow(xDisplay);
    int numProp;
    size_t* propList = OS.XListProperties(xDisplay, rootWindow, &numProp);
    size_t[] property = new size_t[numProp];
    if (propList !is null) {
        property[ 0 .. numProp ] = propList[ 0 .. numProp ];
        OS.XFree(propList);
    }

    /*
     * Feature in Linux Desktop. There is currently no official way to
     * determine whether the Gnome window manager or gnome-vfs is
     * available. Earlier versions including Red Hat 9 and Suse 9 provide
     * a documented Gnome specific property on the root window
     * WIN_SUPPORTING_WM_CHECK. This property is no longer supported in newer
     * versions such as Fedora Core 2.
     * The workaround is to simply check that the window manager is a
     * compliant one (property _NET_SUPPORTING_WM_CHECK) and to attempt to load
     * our native library that depends on gnome-vfs.
     */
    if (desktop is DESKTOP_UNKNOWN) {
        String gnomeName = "_NET_SUPPORTING_WM_CHECK";
        ptrdiff_t gnome = OS.XInternAtom(xDisplay, gnomeName.ptr, true);
        if (gnome !is OS.None && (OS.GTK_VERSION >= OS.buildVERSION (2, 2, 0)) && gnome_init()) {
            desktop = DESKTOP_GNOME;
            int icon_theme = cast(int)GNOME.gnome_icon_theme_new();
            display.setData(ICON_THEME_DATA, new Integer(icon_theme));
            display.addListener(SWT.Dispose, new class(display) Listener {
                Display display;
                this( Display display ){ this.display = display; }
                public void handleEvent(Event event) {
                    Integer gnomeIconTheme = cast(Integer)display.getData(ICON_THEME_DATA);
                    if (gnomeIconTheme is null) return;
                    display.setData(ICON_THEME_DATA, null);
                    /*
                     * Note.  gnome_icon_theme_new uses g_object_new to allocate the
                     * data it returns. Use g_object_unref to free the pointer it returns.
                     */
                    if (gnomeIconTheme.intValue !is 0) OS.g_object_unref( cast(void*)gnomeIconTheme.intValue);
                }
            });
            /* Check for libgnomevfs-2 version 2.4 */
            String buffer = "libgnomevfs-2.so.0";
            void delegate (void*) dg = (void*){ desktop = DESKTOP_GNOME_24; };
            SharedLib.tryUseSymbol( "gnome_vfs_url_show", buffer, dg);
            if( desktop is DESKTOP_GNOME_24 ){
                SharedLib.loadLibSymbols( GNOME.symbols, buffer );
            }
        }
    }

// PORTING CDE not supported
/+
    /*
    * On CDE, the atom below may exist without DTWM running. If the atom
    * below is defined, the CDE database exists and the available
    * applications can be queried.
    */
    if (desktop is DESKTOP_UNKNOWN) {
        String cdeName = "_DT_SM_PREFERENCES";
        ptrdiff_t cde = OS.XInternAtom(xDisplay, cdeName.ptr, true);
        for (int index = 0; desktop is DESKTOP_UNKNOWN && index < property.length; index++) {
            if (property[index] is OS.None) continue; /* do not match atoms that do not exist */
            if (property[index] is cde && cde_init(display)) desktop = DESKTOP_CDE;
        }
    }
+/

    display.setData(DESKTOP_DATA, new Integer(desktop));
    return desktop;
}

// PORTING CDE not supported
/+
bool cde_execute(String fileName) {
    /* Use the character encoding for the default locale */
    char* action = toStringz(command);
    char* ptr = cast(char*)OS.g_malloc(fileName.length+1);
    ptr[ 0 .. fileName.length ] = fileName;
    ptr[ fileName.length ] = 0;
    DtActionArg args = new DtActionArg();
    args.argClass = CDE.DtACTION_FILE;
    args.name = ptr;
    long actionID = CDE.DtActionInvoke(cdeShell, action, args, 1, null, null, null, 1, 0, 0);
    OS.g_free(ptr);
    return actionID !is 0;
}

static String cde_getAction(String dataType) {
    String action  = null;
    String actions = cde_getAttribute(dataType, CDE.DtDTS_DA_ACTION_LIST);
    if (actions !is null) {
        int index = actions.indexOf("Open");
        if (index !is -1) {
            action = actions.substring(index, index + 4);
        } else {
            index = actions.indexOf(",");
            action = index !is -1 ? actions.substring(0, index) : actions;
        }
    }
    return action;
}

static String cde_getAttribute(String dataType, String attrName) {
    /* Use the character encoding for the default locale */
    byte[] dataTypeBuf = Converter.wcsToMbcs(null, dataType, true);
    byte[] attrNameBuf = Converter.wcsToMbcs(null, attrName, true);
    byte[] optNameBuf = null;
    ptrdiff_t attrValue = CDE.DtDtsDataTypeToAttributeValue(dataTypeBuf, attrNameBuf, optNameBuf);
    if (attrValue is 0) return null;
    int length = OS.strlen(attrValue);
    byte[] attrValueBuf = new byte[length];
    OS.memmove(attrValueBuf, attrValue, length);
    CDE.DtDtsFreeAttributeValue(attrValue);
    /* Use the character encoding for the default locale */
    return new String(Converter.mbcsToWcs(null, attrValueBuf));
}

static String[][ String ] cde_getDataTypeInfo() {
    String[][ String ] dataTypeInfo;
    int index;
    ptrdiff_t dataTypeList = CDE.DtDtsDataTypeNames();
    if (dataTypeList !is 0) {
        /* For each data type name in the list */
        index = 0;
        ptrdiff_t [] dataType = new ptrdiff_t [1];
        OS.memmove(dataType, dataTypeList + (index++ * 4), 4);
        while (dataType[0] !is 0) {
            int length = OS.strlen(dataType[0]);
            byte[] dataTypeBuf = new byte[length];
            OS.memmove(dataTypeBuf, dataType[0], length);
            /* Use the character encoding for the default locale */
            String dataTypeName = new String(Converter.mbcsToWcs(null, dataTypeBuf));

            /* The data type is valid if it is not an action, and it has an extension and an action. */
            String extension = cde_getExtension(dataTypeName);
            if (!CDE.DtDtsDataTypeIsAction(dataTypeBuf) &&
                extension !is null && cde_getAction(dataTypeName) !is null) {
                String[] exts;
                exts ~= extension;
                dataTypeInfo[ dataTypeName ] = exts;
            }
            OS.memmove(dataType, dataTypeList + (index++ * 4), 4);
        }
        CDE.DtDtsFreeDataTypeNames(dataTypeList);
    }

    return dataTypeInfo;
}

static String cde_getExtension(String dataType) {
    String fileExt = cde_getAttribute(dataType, CDE.DtDTS_DA_NAME_TEMPLATE);
    if (fileExt is null || fileExt.indexOf("%s.") is -1) return null;
    int dot = fileExt.indexOf(".");
    return fileExt.substring(dot);
}

/**
 * CDE - Get Image Data
 *
 * This method returns the image data of the icon associated with
 * the data type. Since CDE supports multiple sizes of icons, several
 * attempts are made to locate an icon of the desired size and format.
 * CDE supports the sizes: tiny, small, medium and large. The best
 * search order is medium, large, small and then tiny. Althoug CDE supports
 * colour and monochrome bitmaps, only colour icons are tried. (The order is
 * defined by the  cdeIconExt and cdeMaskExt arrays above.)
 */
ImageData cde_getImageData() {
    // TODO
    return null;
}

static String cde_getMimeType(String extension) {
    String mimeType = null;
    String[][ String ] mimeInfo = cde_getDataTypeInfo();
    if (mimeInfo is null) return null;
    String[] keys = mimeInfo.keys();
    int keyIdx = 0;
    while (mimeType is null && keyIdx < keys.length ) {
        String type = keys[ keyIdx ];
        String[] mimeExts = mimeInfo[type];
        for (int index = 0; index < mimeExts.length; index++){
            if (extension.equals(mimeExts[index])) {
                mimeType = type;
                break;
            }
        }
        keyIdx++;
    }
    return mimeType;
}

static Program cde_getProgram(Display display, String mimeType) {
    Program program = new Program();
    program.display = display;
    program.name = mimeType;
    program.command = cde_getAction(mimeType);
    program.iconPath = cde_getAttribute(program.name, CDE.DtDTS_DA_ICON);
    return program;
}

static bool cde_init(Display display) {
    try {
        Library.loadLibrary("swt-cde");
    } catch (Throwable e) {
        return false;
    }

    /* Use the character encoding for the default locale */
    CDE.XtToolkitInitialize();
    ptrdiff_t xtContext = CDE.XtCreateApplicationContext ();
    ptrdiff_t xDisplay = OS.GDK_DISPLAY();
    byte[] appName = Converter.wcsToMbcs(null, "CDE", true);
    byte[] appClass = Converter.wcsToMbcs(null, "CDE", true);
    ptrdiff_t [] argc = [0];
    CDE.XtDisplayInitialize(xtContext, xDisplay, appName, appClass, 0, 0, argc, 0);
    ptrdiff_t widgetClass = CDE.topLevelShellWidgetClass ();
    cdeShell = CDE.XtAppCreateShell (appName, appClass, widgetClass, xDisplay, null, 0);
    CDE.XtSetMappedWhenManaged (cdeShell, false);
    CDE.XtResizeWidget (cdeShell, 10, 10, 0);
    CDE.XtRealizeWidget (cdeShell);
    bool initOK = CDE.DtAppInitialize(xtContext, xDisplay, cdeShell, appName, appName);
    if (initOK) CDE.DtDbLoad();
    return initOK;
}
+/

static String[] parseCommand(String cmd) {
    String[] args;
    int sIndex = 0;
    int eIndex;
    while (sIndex < cmd.length) {
        /* Trim initial white space of argument. */
        while (sIndex < cmd.length && Compatibility.isWhitespace(cmd.charAt(sIndex))) {
            sIndex++;
        }
        if (sIndex < cmd.length) {
            /* If the command is a quoted string */
            if (cmd.charAt(sIndex) is '"' || cmd.charAt(sIndex) is '\'') {
                /* Find the terminating quote (or end of line).
                 * This code currently does not handle escaped characters (e.g., " a\"b").
                 */
                eIndex = sIndex + 1;
                while (eIndex < cmd.length && cmd.charAt(eIndex) !is cmd.charAt(sIndex)) eIndex++;
                if (eIndex >= cmd.length) {
                    /* The terminating quote was not found
                     * Add the argument as is with only one initial quote.
                     */
                    args ~= cmd.substring(sIndex, eIndex);
                } else {
                    /* Add the argument, trimming off the quotes. */
                    args ~= cmd.substring(sIndex + 1, eIndex);
                }
                sIndex = eIndex + 1;
            }
            else {
                /* Use white space for the delimiters. */
                eIndex = sIndex;
                while (eIndex < cmd.length && !Compatibility.isWhitespace(cmd.charAt(eIndex))) eIndex++;
                args ~= cmd.substring(sIndex, eIndex);
                sIndex = eIndex + 1;
            }
        }
    }

    String[] strings = new String[args.length];
    for (int index =0; index < args.length; index++) {
        strings[index] = args[index];
    }
    return strings;
}

/**
 * GNOME 2.4 - Execute the program for the given file.
 */
bool gnome_24_execute(String fileName) {
    char* mimeTypeBuffer = toStringz(name);
    auto ptr = GNOME.gnome_vfs_mime_get_default_application(mimeTypeBuffer);
    char* fileNameBuffer = toStringz(fileName);
    char* uri = GNOME.gnome_vfs_make_uri_from_input_with_dirs(fileNameBuffer, GNOME.GNOME_VFS_MAKE_URI_DIR_CURRENT);
    GList* list = OS.g_list_append( null, uri);
    int result = GNOME.gnome_vfs_mime_application_launch(ptr, list);
    GNOME.gnome_vfs_mime_application_free(ptr);
    OS.g_free(uri);
    OS.g_list_free(list);
    return result is GNOME.GNOME_VFS_OK;
}

/**
 * GNOME 2.4 - Launch the default program for the given file.
 */
static bool gnome_24_launch(String fileName) {
    char* fileNameBuffer = toStringz(fileName);
    char* uri = GNOME.gnome_vfs_make_uri_from_input_with_dirs(fileNameBuffer, GNOME.GNOME_VFS_MAKE_URI_DIR_CURRENT);
    int result = GNOME.gnome_vfs_url_show(uri);
    OS.g_free(uri);
    return (result is GNOME.GNOME_VFS_OK);
}

/**
 * GNOME 2.2 - Execute the program for the given file.
 */
bool gnome_execute(String fileName) {
    if (gnomeExpectUri) {
        /* Convert the given path into a URL */
        char* fileNameBuffer = toStringz(fileName);
        char* uri = GNOME.gnome_vfs_make_uri_from_input(fileNameBuffer);
        if (uri !is null) {
            fileName = fromStringz( uri )._idup();
            OS.g_free(uri);
        }
    }

    /* Parse the command into its individual arguments. */
    String[] args = parseCommand(command);
    int fileArg = -1;
    int index;
    for (index = 0; index < args.length; index++) {
        int j = args[index].indexOf("%f");
        if (j !is -1) {
            String value = args[index];
            fileArg = index;
            args[index] = value.substring(0, j) ~ fileName ~ value.substring(j + 2);
        }
    }

    /* If a file name was given but the command did not have "%f" */
    if ((fileName.length > 0) && (fileArg < 0)) {
        String[] newArgs = new String[args.length + 1];
        for (index = 0; index < args.length; index++) newArgs[index] = args[index];
        newArgs[args.length] = fileName;
        args = newArgs;
    }

    /* Execute the command. */
    try {
        Compatibility.exec(args);
    } catch (IOException e) {
        return false;
    }
    return true;
}

/**
 * GNOME - Get Image Data
 *
 */
ImageData gnome_getImageData() {
    if (iconPath is null) return null;
    try {
        return new ImageData(iconPath);
    } catch (Exception e) {}
    return null;
}

/++
 + SWT Extension
 + This is a temporary workaround until SWT will get the real implementation.
 +/
static String[][ String ] gnome24_getMimeInfo() {
    version(Tango){
        scope file = new tango.io.device.File.File("/usr/share/mime/globs");
        scope it = new tango.io.stream.Lines.Lines!(char)( file );
    } else { // Phobos
        scope it = std.string.splitLines( cast(String)std.file.read("/usr/share/mime/globs"));
    }
    // process file one line at a time
    String[][ String ] mimeInfo;
    foreach (line; it ){
        int colon = line.indexOf(':');
        if( colon is line.length ){
            continue;
        }
        if( line.length < colon+3 || line[colon+1 .. colon+3 ] != "*." ){
            continue;
        }
        String mimeType = line[0..colon]._idup();
        String ext      = line[colon+3 .. $]._idup();
        if( auto exts = mimeType in mimeInfo ){
            mimeInfo[ mimeType ] = *exts ~ ext;
        }
        else{
            mimeInfo[ mimeType ] = [ ext ];
        }
    }
    return mimeInfo;
}
/**
 * GNOME - Get mime types
 *
 * Obtain the registered mime type information and
 * return it in a map. The key of each entry
 * in the map is the mime type name. The value is
 * a vector of the associated file extensions.
 */
static String[][ String ] gnome_getMimeInfo() {
    String[][ String ] mimeInfo;
    GList* mimeList = GNOME.gnome_vfs_get_registered_mime_types();
    GList* mimeElement = mimeList;
    while (mimeElement !is null) {
        auto mimePtr = cast(char*) OS.g_list_data(mimeElement);
        String mimeTypeBuffer = fromStringz(mimePtr)._idup();
        String mimeType = mimeTypeBuffer;//new String(Converter.mbcsToWcs(null, mimeTypeBuffer));
        GList* extensionList = GNOME.gnome_vfs_mime_get_extensions_list(mimePtr);
        if (extensionList !is null) {
            String[] extensions;
            GList* extensionElement = extensionList;
            while (extensionElement !is null) {
                char* extensionPtr = cast(char*) OS.g_list_data(extensionElement);
                String extensionBuffer = fromStringz(extensionPtr)._idup();
                String extension = extensionBuffer;
                extension = '.' ~ extension;
                extensions ~= extension;
                extensionElement = OS.g_list_next(extensionElement);
            }
            GNOME.gnome_vfs_mime_extensions_list_free(extensionList);
            if (extensions.length > 0) mimeInfo[ mimeType ] = extensions;
        }
        mimeElement = OS.g_list_next(mimeElement);
    }
    if (mimeList !is null) GNOME.gnome_vfs_mime_registered_mime_type_list_free(mimeList);
    return mimeInfo;
}

static String gnome_getMimeType(String extension) {
    String mimeType = null;
    String fileName = "swt" ~ extension;
    char* extensionBuffer = toStringz(fileName);
    char* typeName = GNOME.gnome_vfs_mime_type_from_name(extensionBuffer);
    if (typeName !is null) {
        mimeType = fromStringz(typeName)._idup();
    }
    return mimeType;
}

static Program gnome_getProgram(Display display, String mimeType) {
    Program program = null;
    char* mimeTypeBuffer = toStringz(mimeType);
    GnomeVFSMimeApplication* ptr = GNOME.gnome_vfs_mime_get_default_application(mimeTypeBuffer);
    if (ptr !is null) {
        program = new Program();
        program.display = display;
        program.name = mimeType;
        GnomeVFSMimeApplication* application = ptr;
        String buffer = fromStringz(application.command)._idup();
        program.command = buffer;
        program.gnomeExpectUri = application.expects_uris is GNOME.GNOME_VFS_MIME_APPLICATION_ARGUMENT_TYPE_URIS;

        buffer = (fromStringz( application.id) ~ '\0')._idup();
        Integer gnomeIconTheme = cast(Integer)display.getData(ICON_THEME_DATA);
        char* icon_name = GNOME.gnome_icon_lookup( cast(GtkIconTheme*) gnomeIconTheme.intValue, null, null, cast(char*)buffer.ptr, null, mimeTypeBuffer,
                GNOME.GNOME_ICON_LOOKUP_FLAGS_NONE, null);
        char* path = null;
        if (icon_name !is null) path = GNOME.gnome_icon_theme_lookup_icon(cast(GtkIconTheme*)gnomeIconTheme.intValue, icon_name, PREFERRED_ICON_SIZE, null, null);
        if (path !is null) {
            program.iconPath = fromStringz( path)._idup();
            OS.g_free(path);
        }
        if (icon_name !is null) OS.g_free(icon_name);
        GNOME.gnome_vfs_mime_application_free(ptr);
    }
    return program;
}

static bool gnome_init() {
    return cast(bool) GNOME.gnome_vfs_init();
}

/**
 * Finds the program that is associated with an extension.
 * The extension may or may not begin with a '.'.  Note that
 * a <code>Display</code> must already exist to guarantee that
 * this method returns an appropriate result.
 *
 * @param extension the program extension
 * @return the program or <code>null</code>
 *
 */
public static Program findProgram(String extension) {
    return findProgram(Display.getCurrent(), extension);
}

/*
 *  API: When support for multiple displays is added, this method will
 *       become public and the original method above can be deprecated.
 */
static Program findProgram(Display display, String extension) {
    // SWT extension: allow null for zero length string
    //if (extension is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    if (extension.length is 0) return null;
    if (extension.charAt(0) !is '.') extension = "." ~ extension;
    int desktop = getDesktop(display);
    String mimeType = null;
    switch (desktop) {
        case DESKTOP_GNOME_24:
        case DESKTOP_GNOME: mimeType = gnome_getMimeType(extension); break;
        //case DESKTOP_CDE: mimeType = cde_getMimeType(extension); break;
        default:
    }
    if (mimeType is null) return null;
    Program program = null;
    switch (desktop) {
        case DESKTOP_GNOME_24:
        case DESKTOP_GNOME: program = gnome_getProgram(display, mimeType); break;
        //case DESKTOP_CDE: program = cde_getProgram(display, mimeType); break;
        default:
    }
    return program;
}

/**
 * Answer all program extensions in the operating system.  Note
 * that a <code>Display</code> must already exist to guarantee
 * that this method returns an appropriate result.
 *
 * @return an array of extensions
 */
public static String[] getExtensions() {
    return getExtensions(Display.getCurrent());
}

/*
 *  API: When support for multiple displays is added, this method will
 *       become public and the original method above can be deprecated.
 */
static String[] getExtensions(Display display) {
    int desktop = getDesktop(display);
    String[][ String ] mimeInfo = null;
    switch (desktop) {
        case DESKTOP_GNOME_24: mimeInfo = gnome24_getMimeInfo(); break;
        case DESKTOP_GNOME: mimeInfo = gnome_getMimeInfo(); break;
        //case DESKTOP_CDE: mimeInfo = cde_getDataTypeInfo(); break;
        default:
    }
    if (mimeInfo is null) return null;

    /* Create a unique set of the file extensions. */
    String[] extensions;
    String[] keys = mimeInfo.keys;
    int keyIdx = 0;
    while ( keyIdx < keys.length ) {
        String mimeType = keys[ keyIdx ];
        String[] mimeExts = mimeInfo[mimeType];
        for (int index = 0; index < mimeExts.length; index++){
            version(Tango){
                bool contains = cast(bool)tango.core.Array.contains(extensions, mimeExts[index]);
            } else { // Phobos
                bool contains = std.algorithm.canFind(extensions, mimeExts[index]);
            }
            if (!contains) {
                extensions ~= mimeExts[index];
            }
        }
        keyIdx++;
    }

    /* Return the list of extensions. */
    String[] extStrings = new String[]( extensions.length );
    for (int index = 0; index < extensions.length; index++) {
        extStrings[index] = extensions[index];
    }
    return extStrings;
}

/**
 * Answers all available programs in the operating system.  Note
 * that a <code>Display</code> must already exist to guarantee
 * that this method returns an appropriate result.
 *
 * @return an array of programs
 */
public static Program[] getPrograms() {
    return getPrograms(Display.getCurrent());
}

/*
 *  API: When support for multiple displays is added, this method will
 *       become public and the original method above can be deprecated.
 */
static Program[] getPrograms(Display display) {
    int desktop = getDesktop(display);
    String[][ String ] mimeInfo = null;
    switch (desktop) {
        case DESKTOP_GNOME_24: break;
        case DESKTOP_GNOME: mimeInfo = gnome_getMimeInfo(); break;
        //case DESKTOP_CDE: mimeInfo = cde_getDataTypeInfo(); break;
        default:
    }
    if (mimeInfo is null) return new Program[0];
    Program[] programs;
    String[] keys = mimeInfo.keys;
    int keyIdx = 0;
    while ( keyIdx < keys.length ) {
        String mimeType = keys[ keyIdx ];
        Program program = null;
        switch (desktop) {
            case DESKTOP_GNOME: program = gnome_getProgram(display, mimeType); break;
            //case DESKTOP_CDE: program = cde_getProgram(display, mimeType); break;
            default:
        }
        if (program !is null) programs ~= program;
        keyIdx++;
    }
    Program[] programList = new Program[programs.length];
    for (int index = 0; index < programList.length; index++) {
        programList[index] = programs[index];
    }
    return programList;
}

/**
 * Launches the operating system executable associated with the file or
 * URL (http:// or https://).  If the file is an executable then the
 * executable is launched.  Note that a <code>Display</code> must already
 * exist to guarantee that this method returns an appropriate result.
 *
 * @param fileName the file or program name or URL (http:// or https://)
 * @return <code>true</code> if the file is launched, otherwise <code>false</code>
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT when fileName is null</li>
 * </ul>
 */
public static bool launch(String fileName) {
    return launch(Display.getCurrent(), fileName);
}

/*
 *  API: When support for multiple displays is added, this method will
 *       become public and the original method above can be deprecated.
 */
static bool launch (Display display, String fileName) {
    if (fileName is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    switch (getDesktop (display)) {
        case DESKTOP_GNOME_24:
            if (gnome_24_launch (fileName)) return true;
            goto default;
        default:
            int index = fileName.lastIndexOf ('.');
            if (index !is -1) {
                String extension = fileName.substring (index);
                Program program = Program.findProgram (display, extension);
                if (program !is null && program.execute (fileName)) return true;
            }
            String lowercaseName = fileName.toLowerCase ();
            if (lowercaseName.startsWith (PREFIX_HTTP) || lowercaseName.startsWith (PREFIX_HTTPS)) {
                Program program = Program.findProgram (display, ".html"); //$NON-NLS-1$
                if (program is null) {
                    program = Program.findProgram (display, ".htm"); //$NON-NLS-1$
                }
                if (program !is null && program.execute (fileName)) return true;
            }
            break;
    }
    try {
        Compatibility.exec (fileName);
        return true;
    } catch (IOException e) {
        return false;
    }
}

/**
 * Compares the argument to the receiver, and returns true
 * if they represent the <em>same</em> object using a class
 * specific comparison.
 *
 * @param other the object to compare with this object
 * @return <code>true</code> if the object is the same as this object and <code>false</code> otherwise
 *
 * @see #hashCode()
 */
public override equals_t opEquals(Object other) {
    if (this is other) return true;
    if (!(cast(Program)other)) return false;
    Program program = cast(Program)other;
    return display is program.display && name.equals(program.name) && command.equals(program.command);
}

/**
 * Executes the program with the file as the single argument
 * in the operating system.  It is the responsibility of the
 * programmer to ensure that the file contains valid data for
 * this program.
 *
 * @param fileName the file or program name
 * @return <code>true</code> if the file is launched, otherwise <code>false</code>
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT when fileName is null</li>
 * </ul>
 */
public bool execute(String fileName) {
    if (fileName is null) SWT.error(SWT.ERROR_NULL_ARGUMENT);
    int desktop = getDesktop(display);
    switch (desktop) {
        case DESKTOP_GNOME_24: return gnome_24_execute(fileName);
        case DESKTOP_GNOME: return gnome_execute(fileName);
        //case DESKTOP_CDE: return cde_execute(fileName);
        default:
    }
    return false;
}

/**
 * Returns the receiver's image data.  This is the icon
 * that is associated with the receiver in the operating
 * system.
 *
 * @return the image data for the program, may be null
 */
public ImageData getImageData() {
    switch (getDesktop(display)) {
        case DESKTOP_GNOME_24:
        case DESKTOP_GNOME: return gnome_getImageData();
        //case DESKTOP_CDE: return cde_getImageData();
        default:
    }
    return null;
}

/**
 * Returns the receiver's name.  This is as short and
 * descriptive a name as possible for the program.  If
 * the program has no descriptive name, this string may
 * be the executable name, path or empty.
 *
 * @return the name of the program
 */
public String getName() {
    return name;
}

/**
 * Returns an integer hash code for the receiver. Any two
 * objects that return <code>true</code> when passed to
 * <code>equals</code> must return the same value for this
 * method.
 *
 * @return the receiver's hash
 *
 * @see #equals(Object)
 */
public override hash_t toHash() {
    return .toHash(name) ^ .toHash(command) ^ display.toHash();
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the program
 */
override
public String toString() {
    return Format( "Program {{{}}", name );
}
}
