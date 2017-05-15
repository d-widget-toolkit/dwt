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
module org.eclipse.swt.widgets.DirectoryDialog;

import java.lang.all;



import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.widgets.Dialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Display;

version(Tango){
    static import tango.io.model.IFile;
} else { // Phobos
    static import std.path;
}

/**
 * Instances of this class allow the user to navigate
 * the file system and select a directory.
 * <dl>
 * <dt><b>Styles:</b></dt>
 * <dd>(none)</dd>
 * <dt><b>Events:</b></dt>
 * <dd>(none)</dd>
 * </dl>
 * <p>
 * IMPORTANT: This class is intended to be subclassed <em>only</em>
 * within the SWT implementation.
 * </p>
 *
 * @see <a href="http://www.eclipse.org/swt/snippets/#directorydialog">DirectoryDialog snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Example: ControlExample, Dialog tab</a>
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */
public class DirectoryDialog : Dialog {
    String message = "", filterPath = "";
    version(Tango){
        static const String SEPARATOR = tango.io.model.IFile.FileConst.PathSeparatorString;
    } else { // Phobos
        static String SEPARATOR = std.path.dirSeparator;
    }

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
/**
 * Returns the path which the dialog will use to filter
 * the directories it shows.
 *
 * @return the filter path
 *
 * @see #setFilterPath
 */
public String getFilterPath () {
    return filterPath;
}
/**
 * Returns the dialog's message, which is a description of
 * the purpose for which it was opened. This message will be
 * visible on the dialog while it is open.
 *
 * @return the message
 */
public String getMessage () {
    return message;
}
/**
 * Makes the dialog visible and brings it to the front
 * of the display.
 *
 * @return a string describing the absolute path of the selected directory,
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
    char* titleBytes = toStringz(title);
    auto shellHandle = parent.topHandle ();
    auto handle = OS.gtk_file_chooser_dialog_new2 (
        titleBytes,
        shellHandle,
        OS.GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER,
        OS.GTK_STOCK_CANCEL (), OS.GTK_RESPONSE_CANCEL,
        OS.GTK_STOCK_OK (), OS.GTK_RESPONSE_OK );
    auto pixbufs = OS.gtk_window_get_icon_list (shellHandle);
    if (pixbufs !is null) {
        OS.gtk_window_set_icon_list (handle, pixbufs);
        OS.g_list_free (pixbufs);
    }
    if (filterPath !is null && filterPath.length > 0) {
        String p;
        /* filename must be a full path */
        if ( filterPath[ 0 .. SEPARATOR.length ] != SEPARATOR ) {
            p ~= SEPARATOR;
            p ~= filterPath;
        }
        else{
            p = filterPath;
        }
        char* buffer = toStringz(p);
        /*
        * Bug in GTK. GtkFileChooser may crash on GTK versions 2.4.10 to 2.6
        * when setting a file name that is not a true canonical path.
        * The fix is to use the canonical path.
        */
        char* ptr = OS.realpath (buffer, null);
        if (ptr !is null) {
            OS.gtk_file_chooser_set_current_folder (handle, ptr);
            OS.g_free (ptr);
        }
    }
    if (message.length > 0) {
        char* buffer = toStringz(message);
        auto box = OS.gtk_hbox_new (false, 0);
        if (box is null) error (SWT.ERROR_NO_HANDLES);
        auto label = OS.gtk_label_new (buffer);
        if (label is null) error (SWT.ERROR_NO_HANDLES);
        OS.gtk_container_add (box, label);
        OS.gtk_widget_show (label);
        OS.gtk_label_set_line_wrap (label, true);
        OS.gtk_label_set_justify (label, OS.GTK_JUSTIFY_CENTER);
        OS.gtk_file_chooser_set_extra_widget (handle, box);
    }
    String answer = null;
    Display display = parent !is null ? parent.getDisplay (): Display.getCurrent ();
    display.addIdleProc ();
    Dialog oldModal = null;
    if (OS.gtk_window_get_modal (handle)) {
        oldModal = display.getModalDialog ();
        display.setModalDialog (this);
    }
    int signalId = 0;
    ptrdiff_t hookId = 0;
    CallbackData emissionData;
    emissionData.display = display;
    emissionData.data = handle;
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        signalId = OS.g_signal_lookup (OS.map.ptr, OS.GTK_TYPE_WIDGET());
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
        auto path = OS.gtk_file_chooser_get_filename (handle);
        if (path !is null) {
            size_t items_written;
            auto utf8Ptr = OS.g_filename_to_utf8 (path, -1, null, &items_written, null);
            OS.g_free (path);
            if (utf8Ptr !is null) {
                answer = utf8Ptr[ 0 .. items_written ]._idup();
                filterPath = answer;
                OS.g_free (utf8Ptr);
            }
        }
    }
    display.removeIdleProc ();
    OS.gtk_widget_destroy (handle);
    return answer;
}
String openClassicDialog () {
    char* titleBytes = toStringz(title);
    auto handle = OS.gtk_file_selection_new (titleBytes);
    if (parent !is null) {
        auto shellHandle = parent.topHandle ();
        OS.gtk_window_set_transient_for (handle, shellHandle);
        auto pixbufs = OS.gtk_window_get_icon_list (shellHandle);
        if (pixbufs !is null) {
            OS.gtk_window_set_icon_list (handle, pixbufs);
            OS.g_list_free (pixbufs);
        }
    }
    String answer = null;
    if (filterPath !is null) {
        String path = filterPath;
        if (path.length > 0 && path[ $-1 .. $ ] != SEPARATOR ) {
            path ~= SEPARATOR;
        }
        char* fileNamePtr = OS.g_filename_from_utf8 (toStringz(path), -1, null, null, null);
        OS.gtk_file_selection_set_filename (handle, fileNamePtr);
        OS.g_free (fileNamePtr);
    }
    GtkFileSelection* selection = cast(GtkFileSelection*)handle;
    OS.gtk_file_selection_hide_fileop_buttons (handle);
    auto fileListParent = OS.gtk_widget_get_parent (selection.file_list);
    OS.gtk_widget_hide (selection.file_list);
    OS.gtk_widget_hide (fileListParent);
    if (message.length > 0) {
        auto labelHandle = OS.gtk_label_new (toStringz(message));
        OS.gtk_label_set_line_wrap (labelHandle, true);
        OS.gtk_misc_set_alignment (labelHandle, 0.0f, 0.0f);
        OS.gtk_container_add (selection.main_vbox, labelHandle);
        OS.gtk_box_set_child_packing (
            selection.main_vbox, labelHandle, false, false, 0, OS.GTK_PACK_START);
        OS.gtk_widget_show (labelHandle);
    }
    Display display = parent !is null ? parent.getDisplay (): Display.getCurrent ();
    display.addIdleProc ();
    Dialog oldModal = null;
    if (OS.gtk_window_get_modal (handle)) {
        oldModal = display.getModalDialog ();
        display.setModalDialog (this);
    }
    int signalId = 0;
    ptrdiff_t hookId = 0;
    CallbackData emissionData;
    emissionData.display = display;
    emissionData.data = handle;
    if ((style & SWT.RIGHT_TO_LEFT) !is 0) {
        signalId = OS.g_signal_lookup (OS.map.ptr, OS.GTK_TYPE_WIDGET());
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
        char* fileNamePtr = OS.gtk_file_selection_get_filename (handle);
        size_t items_written;
        char* utf8Ptr = OS.g_filename_to_utf8 (fileNamePtr, -1, null, &items_written, null);
        if (utf8Ptr !is null) {
            String osAnswer = utf8Ptr[ 0 .. items_written ]._idup();
            if (osAnswer.length !is 0) {
                /* remove trailing separator, unless root directory */
                if ( osAnswer != SEPARATOR && osAnswer[ $-1 .. $ ] == SEPARATOR ) {
                    osAnswer = osAnswer[ 0 .. $ - 1 ];
                }
                answer = filterPath = osAnswer._idup();
            }
            OS.g_free (utf8Ptr);
        }
    }
    display.removeIdleProc ();
    OS.gtk_widget_destroy (handle);
    return answer;
}
/**
 * Sets the path that the dialog will use to filter
 * the directories it shows to the argument, which may
 * be null. If the string is null, then the operating
 * system's default filter path will be used.
 * <p>
 * Note that the path string is platform dependent.
 * For convenience, either '/' or '\' can be used
 * as a path separator.
 * </p>
 *
 * @param string the filter path
 */
public void setFilterPath (String string) {
    filterPath = string._idup();
}
/**
 * Sets the dialog's message, which is a description of
 * the purpose for which it was opened. This message will be
 * visible on the dialog while it is open.
 *
 * @param string the message
 *
 */
public void setMessage (String string) {
    // SWT extension: allow null for zero length string
    //if (string is null) error (SWT.ERROR_NULL_ARGUMENT);
    message = string._idup();
}
}
