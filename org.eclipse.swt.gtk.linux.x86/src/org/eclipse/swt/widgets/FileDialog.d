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
module org.eclipse.swt.widgets.FileDialog;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Dialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Display;
import java.lang.all;

version(Tango){
    static import tango.io.model.IFile;
} else { // Phobos
    static import std.path;
}

/**
 * Instances of this class allow the user to navigate
 * the file system and select or enter a file name.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>SAVE, OPEN, MULTI</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * Note: Only one of the styles SAVE and OPEN may be specified.
 * </p><p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#filedialog">FileDialog snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample, Dialog tab</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class FileDialog : Dialog {
    String [] filterNames;
    String [] filterExtensions;
    String filterPath = "";
    String fileName = "";
    String[] fileNames;
    String fullPath = "";
    int filterIndex = -1;
    bool overwrite = false;
    GtkWidget* handle;
    version(Tango){
        static const char SEPARATOR = tango.io.model.IFile.FileConst.PathSeparatorChar;
    } else { // Phobos
        static const char SEPARATOR = std.path.dirSeparator[0];
    }
    static const char EXTENSION_SEPARATOR = ';';

/**
 * Constructs a new instance of this class given only its parent.
 *
 * @param parent a shell which will be the parent of the new instance
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
public this (Shell parent) {
    this (parent, SWT.APPLICATION_MODAL);
}
/**
 * Constructs a new instance of this class given its parent
 * and a style value describing its behavior and appearance.
 * <p>
 * The style value is either one of the style constants defined in
 * class <code>SWT</code> which is applicable to instances of this
 * class, or must be built by <em>bitwise OR</em>'ing together
 * (that is, using the <code>int</code> "|" operator) two or more
 * of those <code>SWT</code> style constants. The class description
 * lists the style constants that are applicable to the class.
 * Style bits are also inherited from superclasses.
 * </p>
 *
 * @param parent a shell which will be the parent of the new instance
 * @param style the style of dialog to construct
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_NULL_ARGUMENT - if the parent is null</li>
 * </ul>
 * @exception SWTException <ul>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the parent</li>
 *    <li>ERROR_INVALID_SUBCLASS - if this class is not an allowed subclass</li>
 * </ul>
 */
public this (Shell parent, int style) {
    super (parent, checkStyle (parent, style));
    checkSubclass ();
}
String computeResultChooserDialog () {
    /* MULTI is only valid if the native dialog's action is Open */
    fullPath = null;
    if ((style & (SWT.SAVE | SWT.MULTI)) is SWT.MULTI) {
        auto list = OS.gtk_file_chooser_get_filenames (handle);
        int listLength = OS.g_slist_length (list);
        fileNames = new String [listLength];
        auto current = list;
        int writePos = 0;
        for (int i = 0; i < listLength; i++) {
            auto name = cast(char*)OS.g_slist_data (current);
            size_t items_written;
            char* utf8Ptr = OS.g_filename_to_utf8 (name, -1, null, &items_written, null);
            OS.g_free (name);
            if (utf8Ptr !is null) {
                fullPath = utf8Ptr[ 0 .. items_written ]._idup();
                int start = fullPath.lastIndexOf( SEPARATOR);
                fileNames [writePos++] = fullPath[ start + 1 .. $ ]._idup();
                OS.g_free (utf8Ptr);
            }
            current = OS.g_slist_next (current);
        }
        if (writePos !is 0 && writePos !is listLength) {
            String [] validFileNames = new String [writePos];
            System.arraycopy (fileNames, 0, validFileNames, 0, writePos);
            fileNames = validFileNames;
        }
        OS.g_slist_free (list);
    } else {
        auto path = OS.gtk_file_chooser_get_filename (handle);
        if (path !is null) {
            size_t items_written;
            auto utf8Ptr = OS.g_filename_to_utf8 (path, -1, null, &items_written, null);
            OS.g_free (path);
            if (utf8Ptr !is null) {
                fullPath = utf8Ptr[ 0 .. items_written ]._idup();
                fileNames = new String [1];
                int start = fullPath.lastIndexOf( SEPARATOR);
                fileNames[0] = fullPath[ start + 1 .. $ ];
                OS.g_free (utf8Ptr);
            }
        }
    }
    filterIndex = -1;
    auto filter = OS.gtk_file_chooser_get_filter (handle);
    if (filter !is null) {
        auto filterNamePtr = OS.gtk_file_filter_get_name (filter);
        if (filterNamePtr !is null) {
            String filterName = fromStringz(filterNamePtr)._idup();
            //OS.g_free (filterNamePtr); //GTK owns this pointer - do not free
            for (int i = 0; i < filterExtensions.length; i++) {
                if (filterNames.length > 0) {
                    if (filterNames[i].equals(filterName)) {
                        filterIndex = i;
                        break;
                    }
                } else {
                    if (filterExtensions[i].equals(filterName)) {
                        filterIndex = i;
                        break;
                    }
                }
            }
        }
    }
    if (fullPath !is null) {
        int separatorIndex = fullPath.lastIndexOf( SEPARATOR);
        fileName = fullPath[separatorIndex + 1 .. $ ];
        filterPath = fullPath[0 .. separatorIndex ];
    }
    return fullPath;
}
String computeResultClassicDialog () {
    filterIndex = -1;
    GtkFileSelection* selection = cast(GtkFileSelection*)handle;
    auto entry = selection.selection_entry;
    auto entryText = OS.gtk_entry_get_text (entry);
    String txt = fromStringz( entryText )._idup();
    if (txt.length is 0) {
        auto fileList = selection.file_list;
        auto listSelection = OS.gtk_tree_view_get_selection (fileList);
        void* model;
        auto selectedList = OS.gtk_tree_selection_get_selected_rows (listSelection, &model);
        if (selectedList is null) return null;
        int listLength = OS.g_list_length (selectedList);
        if (listLength is 0) {
            OS.g_list_free (selectedList);
            return null;
        }
        auto path = OS.g_list_nth_data (selectedList, 0);
        char* ptr;
        GtkTreeIter iter;
        if (OS.gtk_tree_model_get_iter (&model, &iter, path)) {
            OS.gtk_tree_model_get1 (&model, &iter, 0, cast(void**)&ptr);
        }
        for (int i = 0; i < listLength; i++) {
            OS.gtk_tree_path_free (OS.g_list_nth_data (selectedList, i));
        }
        OS.g_list_free (selectedList);
        if (ptr is null) return null;
        OS.gtk_entry_set_text (entry, ptr);
        OS.g_free (ptr);
    }

    auto fileNamePtr = OS.gtk_file_selection_get_filename (handle);
    size_t items_written;
    auto utf8Ptr = OS.g_filename_to_utf8 (fileNamePtr, -1, null, &items_written, null);
    String osAnswer = utf8Ptr[ 0 .. items_written ]._idup();
    OS.g_free (utf8Ptr);

    if (osAnswer.length is 0) return null;
    int separatorIndex = osAnswer.lastIndexOf( SEPARATOR);
    if (separatorIndex+1 is osAnswer.length ) return null;

    String answer = fullPath = osAnswer;
    fileName = fullPath[ separatorIndex+1 .. $ ];
    filterPath = fullPath[ 0 .. separatorIndex ];
    if ((style & SWT.MULTI) is 0) {
        fileNames = [ fileName ];
    } else {
        auto namesPtr = OS.gtk_file_selection_get_selections (handle);
        auto namesPtr1 = namesPtr;
        char* namePtr = namesPtr1[0];
        int length_ = 0;
        while (namePtr !is null) {
            length_++;
            namePtr = namesPtr1[length_];
        }
        fileNames = new String[](length_);
        for (int i = 0; i < length_; i++) {
            utf8Ptr = OS.g_filename_to_utf8 (namesPtr [i], -1, null, &items_written, null);
            String name = utf8Ptr[ 0 .. items_written ]._idup();
            int start = name.lastIndexOf( SEPARATOR);
            fileNames [i] = name[ start + 1 .. $ ]._idup();
            OS.g_free (utf8Ptr);
        }
        OS.g_strfreev (namesPtr);
    }
    return answer;
}
/**
 * Returns the path of the first file that was
 * selected in the dialog relative to the filter path, or an
 * empty string if no such file has been selected.
 *
 * @return the relative path of the file
 */
public String getFileName () {
    return fileName;
}
/**
 * Returns a (possibly empty) array with the paths of all files
 * that were selected in the dialog relative to the filter path.
 *
 * @return the relative paths of the files
 */
public String [] getFileNames () {
    return fileNames;
}
/**
 * Returns the file extensions which the dialog will
 * use to filter the files it shows.
 *
 * @return the file extensions filter
 */
public String [] getFilterExtensions () {
    return filterExtensions;
}
/**
 * Get the 0-based index of the file extension filter
 * which was selected by the user, or -1 if no filter
 * was selected.
 * <p>
 * This is an index into the FilterExtensions array and
 * the FilterNames array.
 * </p>
 *
 * @return index the file extension filter index
 *
 * @see #getFilterExtensions
 * @see #getFilterNames
 *
 * @since 3.4
 */
public int getFilterIndex () {
    return filterIndex;
}
/**
 * Returns the names that describe the filter extensions
 * which the dialog will use to filter the files it shows.
 *
 * @return the list of filter names
 */
public String [] getFilterNames () {
    return filterNames;
}
/**
 * Returns the directory path that the dialog will use, or an empty
 * string if this is not set.  File names in this path will appear
 * in the dialog, filtered according to the filter extensions.
 *
 * @return the directory path string
 *
 * @see #setFilterExtensions
 */
public String getFilterPath () {
    return filterPath;
}
/**
 * Returns the flag that the dialog will use to
 * determine whether to prompt the user for file
 * overwrite if the selected file already exists.
 *
 * @return true if the dialog will prompt for file overwrite, false otherwise
 *
 * @since 3.4
 */
public bool getOverwrite () {
    return overwrite;
}
/**
 * Makes the dialog visible and brings it to the front
 * of the display.
 *
 * @return a string describing the absolute path of the first selected file,
 *         or null if the dialog was cancelled or an error occurred
 *
 * @exception SWTException <ul>
 *    <li>ERROR_WIDGET_DISPOSED - if the dialog has been disposed</li>
 *    <li>ERROR_THREAD_INVALID_ACCESS - if not called from the thread that created the dialog</li>
 * </ul>
 */
public String open () {
    bool useChooserDialog = OS.GTK_VERSION >= OS.buildVERSION (2, 4, 10);
    if (useChooserDialog) {
        return openChooserDialog ();
    } else {
        return openClassicDialog ();
    }
}
String openChooserDialog () {
    char* titleBytes = toStringz( title );
    int action = (style & SWT.SAVE) !is 0 ?
        OS.GTK_FILE_CHOOSER_ACTION_SAVE :
        OS.GTK_FILE_CHOOSER_ACTION_OPEN;
    auto shellHandle = parent.topHandle ();
    handle = OS.gtk_file_chooser_dialog_new2 (
        titleBytes,
        shellHandle,
        action,
        OS.GTK_STOCK_CANCEL (), OS.GTK_RESPONSE_CANCEL,
        OS.GTK_STOCK_OK (), OS.GTK_RESPONSE_OK);
    auto pixbufs = OS.gtk_window_get_icon_list (shellHandle);
    if (pixbufs !is null) {
        OS.gtk_window_set_icon_list (handle, pixbufs);
        OS.g_list_free (pixbufs);
    }
    presetChooserDialog ();
    Display display = parent !is null ? parent.getDisplay (): Display.getCurrent ();
    display.addIdleProc ();
    String answer = null;
    Dialog oldModal = null;
    if (OS.gtk_window_get_modal (handle)) {
        oldModal = display.getModalDialog ();
        display.setModalDialog (this);
    }
    int signalId = 0;
    ptrdiff_t hookId = 0;
    CallbackData emissionData;
    emissionData.display = display;
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        signalId = OS.g_signal_lookup (OS.map.ptr, OS.GTK_TYPE_WIDGET());
        emissionData.data = handle;
        hookId = OS.g_signal_add_emission_hook (signalId, 0, &Display.emissionFunc, &emissionData, null);
    }
    int response = OS.gtk_dialog_run (handle);
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        OS.g_signal_remove_emission_hook (signalId, hookId);
    }
    if (OS.gtk_window_get_modal (handle)) {
        display.setModalDialog (oldModal);
    }
    if (response is OS.GTK_RESPONSE_OK) {
        answer = computeResultChooserDialog ();
    }
    display.removeIdleProc ();
    OS.gtk_widget_destroy (handle);
    return answer;
}
String openClassicDialog () {
    char* titleBytes = toStringz( title );
    handle = OS.gtk_file_selection_new (titleBytes);
    if (parent !is null) {
        auto shellHandle = parent.topHandle ();
        OS.gtk_window_set_transient_for (handle, shellHandle);
        auto pixbufs = OS.gtk_window_get_icon_list (shellHandle);
        if (pixbufs !is null) {
            OS.gtk_window_set_icon_list (handle, pixbufs);
            OS.g_list_free (pixbufs);
        }
    }
    presetClassicDialog ();
    Display display = parent !is null ? parent.getDisplay (): Display.getCurrent ();
    display.addIdleProc ();
    String answer = null;
    Dialog oldModal = null;
    if (OS.gtk_window_get_modal (handle)) {
        oldModal = display.getModalDialog ();
        display.setModalDialog (this);
    }
    int signalId = 0;
    ptrdiff_t hookId = 0;
    CallbackData emissionData;
    emissionData.display = display;
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        signalId = OS.g_signal_lookup (OS.map.ptr, OS.GTK_TYPE_WIDGET());
        emissionData.data = handle;
        hookId = OS.g_signal_add_emission_hook (signalId, 0, &Display.emissionFunc, &emissionData, null);
    }
    int response = OS.gtk_dialog_run (handle);
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        OS.g_signal_remove_emission_hook (signalId, hookId);
    }
    if (OS.gtk_window_get_modal (handle)) {
        display.setModalDialog (oldModal);
    }
    if (response is OS.GTK_RESPONSE_OK) {
        answer = computeResultClassicDialog ();
    }
    display.removeIdleProc ();
    OS.gtk_widget_destroy (handle);
    return answer;
}
void presetChooserDialog () {
    /* MULTI is only valid if the native dialog's action is Open */
    if ((style & (SWT.SAVE | SWT.MULTI)) is SWT.MULTI) {
        OS.gtk_file_chooser_set_select_multiple (handle, true);
    }
    if (filterPath is null) filterPath = "";
    if (fileName is null) fileName = "";
    if (filterPath.length > 0) {
        StringBuffer stringBuffer = new StringBuffer();
        /* filename must be a full path */
        if (filterPath[0] !is SEPARATOR) {
            stringBuffer.append (SEPARATOR);
        }
        stringBuffer.append (filterPath);
        if (fileName.length > 0 && (style & SWT.SAVE) is 0) {
            if (filterPath[filterPath.length - 1 ] !is SEPARATOR) {
                stringBuffer.append (SEPARATOR);
            }
            stringBuffer.append (fileName);
        char* buffer = toStringz( stringBuffer.toString ());
            /*
            * Bug in GTK. GtkFileChooser may crash on GTK versions 2.4.10 to 2.6
            * when setting a file name that is not a true canonical path.
            * The fix is to use the canonical path.
            */
        auto ptr = OS.realpath (buffer, null);
        if (ptr !is null) {
                OS.gtk_file_chooser_set_filename (handle, ptr);
                OS.g_free (ptr);
            }
        } else {
            char* buffer = toStringz( stringBuffer.toString () );
            /*
            * Bug in GTK. GtkFileChooser may crash on GTK versions 2.4.10 to 2.6
            * when setting a file name that is not a true canonical path.
            * The fix is to use the canonical path.
            */
            auto ptr = OS.realpath (buffer, null);
            if (ptr !is null) {
                OS.gtk_file_chooser_set_current_folder (handle, ptr);
                OS.g_free (ptr);
            }
        }
    } else {
        if (fileName.length > 0) {
            if (fileName[0] is SEPARATOR) {
                char* buffer = toStringz(fileName);

                /*
                * Bug in GTK. GtkFileChooser may crash on GTK versions 2.4.10 to 2.6
                * when setting a file name that is not a true canonical path.
                * The fix is to use the canonical path.
                */
                auto ptr = OS.realpath (buffer, null);
                if (ptr !is null) {
                    OS.gtk_file_chooser_set_filename (handle, ptr);
                    OS.g_free (ptr);
                }
            }
        }
    }
    if ((style & SWT.SAVE) !is 0 && fileName.length > 0) {
        char* buffer = toStringz(fileName);
        OS.gtk_file_chooser_set_current_name (handle, buffer);
    }
    if ((style & SWT.SAVE) !is 0) {
        if (OS.GTK_VERSION >= OS.buildVERSION (2, 8, 0)) {
            OS.gtk_file_chooser_set_do_overwrite_confirmation (handle, overwrite);
        }
    }

    /* Set the extension filters */
    if (filterNames is null) filterNames = null;
    if (filterExtensions is null) filterExtensions = null;
    GtkFileFilter* initialFilter = null;
    for (int i = 0; i < filterExtensions.length; i++) {
        if (filterExtensions [i] !is null) {
            auto filter = OS.gtk_file_filter_new ();
            if (filterNames.length > i && filterNames [i] !is null) {
                char* name = toStringz(filterNames [i]);
                OS.gtk_file_filter_set_name (filter, name);
            } else {
                char* name = toStringz(filterExtensions [i]);
                OS.gtk_file_filter_set_name (filter, name);
            }
            int start = 0;
            int index = filterExtensions [i].indexOf( EXTENSION_SEPARATOR );
            while (index !is -1 ) {
                String current = filterExtensions [i][ start .. index ];
                char* filterString = toStringz(current);
                OS.gtk_file_filter_add_pattern (filter, filterString);
                start = index + 1;
                index = filterExtensions [i].indexOf( EXTENSION_SEPARATOR, start);
            }
            String current = filterExtensions [i][ start .. $ ];
            char* filterString = toStringz(current);
            OS.gtk_file_filter_add_pattern (filter, filterString);
            OS.gtk_file_chooser_add_filter (handle, filter);
            if (i is filterIndex) {
                initialFilter = filter;
            }
        }
    }
    if (initialFilter !is null) {
        OS.gtk_file_chooser_set_filter(handle, initialFilter);
    }
    fullPath = null;
    fileNames = null;
}
void presetClassicDialog () {
    OS.gtk_file_selection_set_select_multiple(handle, (style & SWT.MULTI) !is 0);

    /* Calculate the fully-specified file name and convert to bytes */
    StringBuffer stringBuffer = new StringBuffer();
    if (filterPath is null) {
        filterPath = "";
    } else {
        if (filterPath.length > 0) {
            stringBuffer.append (filterPath);
            if (filterPath[filterPath.length - 1] !is SEPARATOR) {
                stringBuffer.append (SEPARATOR);
            }
        }
    }
    if (fileName is null) {
        fileName = "";
    } else {
        stringBuffer.append (fileName);
    }
    fullPath = stringBuffer.toString ();
    auto fileNamePtr = OS.g_filename_from_utf8 (toStringz( fullPath ), -1, null, null, null);
    OS.gtk_file_selection_set_filename (handle, fileNamePtr);
    OS.g_free (fileNamePtr);

    if (filterNames is null) filterNames = null;
    if (filterExtensions is null) filterExtensions = null;
    fullPath = null;
    fileNames = null;
}
/**
 * Set the initial filename which the dialog will
 * select by default when opened to the argument,
 * which may be null.  The name will be prefixed with
 * the filter path when one is supplied.
 *
 * @param string the file name
 */
public void setFileName (String string) {
    fileName = string;
}
/**
 * Set the file extensions which the dialog will
 * use to filter the files it shows to the argument,
 * which may be null.
 * <p>
 * The strings are platform specific. For example, on
 * some platforms, an extension filter string is typically
 * of the form "*.extension", where "*.*" matches all files.
 * For filters with multiple extensions, use semicolon as
 * a separator, e.g. "*.jpg;*.png".
 * </p>
 *
 * @param extensions the file extension filter
 *
 * @see #setFilterNames to specify the user-friendly
 * names corresponding to the extensions
 */
public void setFilterExtensions (String [] extensions) {
    filterExtensions = extensions;
}
/**
 * Set the 0-based index of the file extension filter
 * which the dialog will use initially to filter the files
 * it shows to the argument.
 * <p>
 * This is an index into the FilterExtensions array and
 * the FilterNames array.
 * </p>
 *
 * @param index the file extension filter index
 *
 * @see #setFilterExtensions
 * @see #setFilterNames
 *
 * @since 3.4
 */
public void setFilterIndex (int index) {
    filterIndex = index;
}
/**
 * Sets the names that describe the filter extensions
 * which the dialog will use to filter the files it shows
 * to the argument, which may be null.
 * <p>
 * Each name is a user-friendly short description shown for
 * its corresponding filter. The <code>names</code> array must
 * be the same length as the <code>extensions</code> array.
 * </p>
 *
 * @param names the list of filter names, or null for no filter names
 *
 * @see #setFilterExtensions
 */
public void setFilterNames (String [] names) {
    filterNames = names;
}
/**
 * Sets the directory path that the dialog will use
 * to the argument, which may be null. File names in this
 * path will appear in the dialog, filtered according
 * to the filter extensions. If the string is null,
 * then the operating system's default filter path
 * will be used.
 * <p>
 * Note that the path string is platform dependent.
 * For convenience, either '/' or '\' can be used
 * as a path separator.
 * </p>
 *
 * @param string the directory path
 *
 * @see #setFilterExtensions
 */
public void setFilterPath (String string) {
    filterPath = string;
}

/**
 * Sets the flag that the dialog will use to
 * determine whether to prompt the user for file
 * overwrite if the selected file already exists.
 *
 * @param overwrite true if the dialog will prompt for file overwrite, false otherwise
 *
 * @since 3.4
 */
public void setOverwrite (bool overwrite) {
    this.overwrite = overwrite;
}
}
