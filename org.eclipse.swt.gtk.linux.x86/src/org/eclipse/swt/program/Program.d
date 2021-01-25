/*******************************************************************************
 * Copyright (c) 2000, 2016 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *     alice <stigma@disroot.org>
 *******************************************************************************/
module org.eclipse.swt.program.Program; // @suppress(dscanner.style.phobos_naming_convention)

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.PaletteData;
import org.eclipse.swt.internal.Compatibility;
import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.Library;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Listener;
import java.lang.all;
import java.nonstandard.SharedLib;
import java.util.HashSet;

static import std.string;
static import std.file;
static import std.algorithm;

/**
 * Instances of this class represent programs and
 * their associated file extensions in the operating
 * system.
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#program">Program snippets</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public final class Program {
package:
    String name = ""; //$NON-NLS-1$
    String command;
    String iconPath;
    Display display;

    /* GIO specific
     * true if command expects a URI
     * false if expects a path
     */
    bool gioExpectUri;

    static ptrdiff_t modTime;
    static String[][String] mimeTable;

    static const String PREFIX_HTTP = "http://"; //$NON-NLS-1$
    static const String PREFIX_HTTPS = "https://"; //$NON-NLS-1$

/**
 * Prevents uninitialized instances from being created outside the package.
 */
this() {
}

static String[] parseCommand(String cmd) {
    String[] args;
    int sIndex = 0;
    int eIndex;
    while (sIndex < cmd.length) {
        /* Trim initial white space of argument. */
        while (sIndex < cmd.length && Character.isWhitespace(cmd.charAt(sIndex))) {
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
                while (eIndex < cmd.length && !Character.isWhitespace(cmd.charAt(eIndex))) eIndex++;
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
 * Finds the program that is associated with an extension.
 * The extension may or may not begin with a '.'.  Note that
 * a <code>Display</code> must already exist to guarantee that
 * this method returns an appropriate result.
 *
 * @param extension the program extension
 * @return the program or <code>null</code>
 *
 * @exception IllegalArgumentException <ul>
 *		<li>ERROR_NULL_ARGUMENT when extension is null</li>
 *	</ul>
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
    String mimeType = gio_getMimeType(extension);
    if (mimeType is null) return null;
    return gio_getProgram(display, mimeType);
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

/**
 * Returns the receiver's image data.  This is the icon
 * that is associated with the receiver in the operating
 * system.
 *
 * @return the image data for the program, may be null
 */
public ImageData getImageData() {
    if (iconPath is null) return null;
    ImageData data = null;
    GtkIconTheme* icon_theme = OS.gtk_icon_theme_get_default();
    char* icon = toStringz(iconPath);
    GIcon* gicon = OS.g_icon_new_for_string(icon, null);
    if (gicon !is null) {
        GtkIconInfo* gicon_info = OS.gtk_icon_theme_lookup_by_gicon(icon_theme, gicon, 16, 0);
        if (gicon_info !is null) {
            GdkPixbuf* pixbuf = OS.gtk_icon_info_load_icon(gicon_info, null);
            if (pixbuf !is null) {
                int stride = OS.gdk_pixbuf_get_rowstride(pixbuf);
                char* pixels = OS.gdk_pixbuf_get_pixels(pixbuf);
                int height = OS.gdk_pixbuf_get_height(pixbuf);
                int width = OS.gdk_pixbuf_get_width(pixbuf);
                bool hasAlpha = cast(bool)OS.gdk_pixbuf_get_has_alpha(pixbuf);
                byte[] srcData = new byte[stride * height];
                OS.memmove(cast(void*)srcData, pixels, srcData.length);
                OS.g_object_unref(pixbuf);
                if (hasAlpha) {
                    PaletteData palette = new PaletteData(0xFF000000, 0xFF0000, 0xFF00);
                    data = new ImageData(width, height, 32, palette, 4, srcData);
                    data.bytesPerLine = stride;
                    int s = 3, a = 0;
                    byte[] alphaData = new byte[width * height];
                    for (int y = 0; y < height; y++) {
                        for (int x = 0; x < width; x++) {
                            alphaData[a++] = srcData[s];
                            srcData[s] = 0;
                            s += 4;
                        }
                    }
                    data.alphaData = alphaData;
                } else {
                    PaletteData palette = new PaletteData(0xFF0000, 0xFF00, 0xFF);
                    data = new ImageData(width, height, 24, palette, 4, srcData);
                    data.bytesPerLine = stride;
                }
            }
            if (OS.GTK_VERSION >= OS.buildVERSION(3, 8, 0)) {
                OS.g_object_unref(gicon_info);
            } else {
                OS.gtk_icon_info_free(gicon_info);
            }
        }
        OS.g_object_unref(gicon);
    }
    return data;
}

    static String[][String] gio_getMimeInfo() {
        import std.stdio : File;
        /*
        * The file 'globs' contain the file extensions associated to the
        * mime-types.  Each line that has to be parsed corresponds to a
        * different extension of a mime-type.  The template of such line is -
        * application/pdf:*.pdf
        */
        String path = "/usr/share/mime/globs";
        ptrdiff_t lastModified = 0;
        try {
            lastModified = std.file.timeLastModified(path).second * 1000;
        } catch (Exception e) {
            // ignore and reparse the file
        }
        if (modTime !is 0 && modTime is lastModified) {
            return mimeTable;
        } else {
            File f = File(path, "r");
            try {
                // mimeTable = new HashMap<>(); // assocArrays don't need initializing
                modTime = lastModified;
                foreach (String line; f.byLineCopy) {
                    int separatorIndex = line.indexOf(':');
                    if (separatorIndex > 0) {
                        String[] mimeTypes;
                        String mimeType = line.substring(0, separatorIndex);
                        String extensionFormat = line.substring(separatorIndex + 1);
                        int extensionIndex = extensionFormat.indexOf(".");
                        if (extensionIndex > 0) {
                            String extension = extensionFormat.substring(extensionIndex);
                            if (extension in mimeTable) {
                                /*
                                * If mimeType already exists, it is required to
                                * update the existing key (mime-type) with the
                                * new extension.
                                */
                                String[] value = mimeTable[extension];
                                mimeTypes ~= value;
                            }
                            mimeTypes ~= mimeType;
                            mimeTable[extension] = mimeTypes;
                        }
                    }
                }
                return mimeTable;
            } catch (Exception e) {
            }
        }
        return null;
    }

static String gio_getMimeType(String extension) {
    String mimeType = null;
    String[][String] h = gio_getMimeInfo();
    if (h !is null && (extension in h)) {
        String[] mimeTypes = h[extension];
        mimeType = mimeTypes[0];
    }
    return mimeType;
}

static Program gio_getProgram(Display display, String mimeType) {
    Program program = null;
    char* mimeTypeBuffer = toStringz(mimeType);
    GAppInfo* application = OS.g_app_info_get_default_for_type(mimeTypeBuffer, false);
    if (application !is null) {
        program = gio_getProgram(display, application);
    }
    return program;
}

static Program gio_getProgram(Display display, GAppInfo* application) {
    Program program = new Program();
    program.display = display;
    int length;
    String buffer;
    char* applicationName = OS.g_app_info_get_name(application);
    if (applicationName !is null) {
        length = OS.strlen(applicationName);
        if (length > 0) {
            buffer = fromStringz(applicationName).idup;
            program.name = buffer;
        }
    }
    char* applicationCommand = OS.g_app_info_get_executable(application);
    if (applicationCommand !is null) {
        length = OS.strlen(applicationCommand);
        if (length > 0) {
            buffer = fromStringz(applicationCommand).idup;
            program.command = buffer;
        }
    }
    program.gioExpectUri = cast(bool)OS.g_app_info_supports_uris(application);
    GIcon* icon = OS.g_app_info_get_icon(application);
    if (icon !is null) {
        char* icon_name = OS.g_icon_to_string(icon);
        if (icon_name !is null) {
            length = OS.strlen(icon_name);
            if (length > 0) {
                buffer = fromStringz(icon_name).idup;
                program.iconPath = buffer;
            }
            OS.g_free(icon_name);
        }
        OS.g_object_unref(icon);
    }
    return program.command !is null ? program : null;
}

/*
 * API: When support for multiple displays is added, this method will
 *      become public and the original method above can be deprecated.
 */
static Program[] getPrograms(Display display) {
    GList* applicationList = OS.g_app_info_get_all();
    GList* list = applicationList;
    Program program;
    HashSet programs = new HashSet();
    while (list !is null) {
        void* application = OS.g_list_data(list);
        if (application !is null) {
            // TODO: Should the list be filtered or not?
            // if (OS.g_app_info_should_show(application)) {
                program = gio_getProgram(display, cast(GAppInfo*)application);
                if (program !is null) programs.add(program);
            // }
        }
        list = OS.g_list_next(list);
    }
    if (applicationList !is null) OS.g_list_free(applicationList);
    return cast(Program[])programs.toArray();
}

static bool isExecutable(String fileName) {
    char* fileNameBuffer = toStringz(fileName);
    if (OS.g_file_test(fileNameBuffer, OS.G_FILE_TEST_IS_DIR)) return false;
    if (!OS.g_file_test(fileNameBuffer, OS.G_FILE_TEST_IS_EXECUTABLE)) return false;
    GFile* file = OS.g_file_new_for_path(fileNameBuffer);
    bool result = false;
    if (file !is null) {
        char* buffer = toStringz("*");
        GFileInfo* fileInfo = OS.g_file_query_info(file, buffer, 0, null, null);
        if (fileInfo !is null) {
            char* contentType = OS.g_file_info_get_content_type(fileInfo);
            if (contentType !is null) {
                char* exeType = toStringz("application/x-executable");
                result = cast(bool)OS.g_content_type_is_a(contentType, exeType);
                if (!result) {
                    char* shellType = toStringz("application/x-shellscript");
                    result = cast(bool)OS.g_content_type_equals(contentType, shellType);
                }
            }
            OS.g_object_unref(fileInfo);
        }
        OS.g_object_unref(file);
    }
    return result;
}

/**
 * GIO - Launch the default program for the given file.
 */
static bool gio_launch(String fileName) {
    bool result = false;
    char* fileNameBuffer = toStringz(fileName);
    GFile* file = OS.g_file_new_for_commandline_arg(fileNameBuffer);
    if (file !is null) {
        char* uri = OS.g_file_get_uri(file);
        if (uri !is null) {
            result = cast(bool)OS.g_app_info_launch_default_for_uri(uri, null, null);
            OS.g_free(uri);
        }
        OS.g_object_unref(file);
    }
    return result;
}

/**
 * GIO - Execute the program for the given file.
 */
bool gio_execute(String fileName) {
    bool result = false;
    char* commandBuffer = toStringz(command);
    char* nameBuffer = toStringz(name);
    GAppInfo* application = OS.g_app_info_create_from_commandline(commandBuffer, nameBuffer,
        gioExpectUri ? OS.G_APP_INFO_CREATE_SUPPORTS_URIS : OS.G_APP_INFO_CREATE_NONE, null);
    if (application !is null) {
        char* fileNameBuffer = toStringz(fileName);
        GFile* file = null;
        if (fileName.length > 0) {
            if (OS.g_app_info_supports_uris(application)) {
                file = OS.g_file_new_for_uri(fileNameBuffer);
            } else {
                file = OS.g_file_new_for_path(fileNameBuffer);
            }
        }
        GList* list = null;
        if (file !is null) list = OS.g_list_append(null, file);
        result = cast(bool)OS.g_app_info_launch(application, list, null, null);
        if (list !is null) {
            OS.g_list_free(list);
            OS.g_object_unref(file);
        }
        OS.g_object_unref(application);
    }
    return result;
}

/**
 * Answer all program extensions in the operating system.  Note
 * that a <code>Display</code> must already exist to guarantee
 * that this method returns an appropriate result.
 *
 * @return an array of extensions
 */
public static String[] getExtensions() {
    String[][String] mimeInfo = gio_getMimeInfo();
    if (mimeInfo is null) return new String[0];
    /* Create a unique set of the file extensions */
    String[] extensions = mimeInfo.keys();
    /* Return the list of extensions */
    return extensions;
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
    return launch(Display.getCurrent(), fileName, null);
}

/**
 * Launches the operating system executable associated with the file or
 * URL (http:// or https://).  If the file is an executable then the
 * executable is launched. The program is launched with the specified
 * working directory only when the <code>workingDir</code> exists and
 * <code>fileName</code> is an executable.
 * Note that a <code>Display</code> must already exist to guarantee
 * that this method returns an appropriate result.
 *
 * @param fileName the file name or program name or URL (http:// or https://)
 * @param workingDir the name of the working directory or null
 * @return <code>true</code> if the file is launched, otherwise <code>false</code>
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT when fileName is null</li>
 * </ul>
 *
 * @since 3.6
 */
public static bool launch(String fileName, String workingDir) {
    return launch(Display.getCurrent(), fileName, workingDir);
}

/*
 * API: When support for multiple displays is added, this method will
 *      become public and the original method above can be deprecated.
 */
static bool launch (Display display, String fileName, String workingDir) {
    if (fileName is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    if (workingDir !is null && isExecutable(fileName)) {
        try {
            Compatibility.exec([fileName], null, workingDir);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    if (gio_launch(fileName)) return true;
    int index = fileName.lastIndexOf('.');
    if (index != -1) {
        String extension = fileName.substring(index);
        Program program = Program.findProgram(display, extension);
        if (program !is null && program.execute(fileName)) return true;
    }
    String lowercaseName = fileName.toLowerCase();
    if (lowercaseName.startsWith(PREFIX_HTTP) || lowercaseName.startsWith(PREFIX_HTTPS)) {
        Program program = Program.findProgram(display, ".html"); // $NON-NLS-1$
        if (program is null) {
            program = Program.findProgram(display, ".htm"); // $NON-NLS-1$
        }
        if (program !is null && program.execute(fileName)) return true;
    }
    /* If the above launch attemps didn't launch the file, then try with exec() */
    try {
        Compatibility.exec([fileName], null, workingDir);
        return true;
    } catch (Exception e) {
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
public override equals_t opEquals(Object other) const {
    if (this is other) return true;
    if (!(cast(Program)other)) return false;
    Program program = cast(Program)other;
    return (display is program.display) && (name == program.name) && (command == program.command) &&
        (gioExpectUri == program.gioExpectUri);
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
    return gio_execute(fileName);
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
override public hash_t toHash() @trusted nothrow const {
    return name.toHash() ^ command.toHash();
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the program
 */
override
public String toString() const {
    return Format( "Program {{{}}", name );
}
}
