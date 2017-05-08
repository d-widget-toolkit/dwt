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
import org.eclipse.swt.internal.win32.OS;
import org.eclipse.swt.widgets.Dialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Display;

import java.lang.all;

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
    String [] fileNames;
    String filterPath = "", fileName = "";
    int filterIndex = 0;
    bool overwrite = false;
    static const String FILTER = "*.*";
    static int BUFFER_SIZE = 1024 * 32;
    mixin(gshared!(`static bool USE_HOOK = true;`));
    mixin(sharedStaticThis!(`{
        /*
        *  Feature in Vista.  When OFN_ENABLEHOOK is set in the
        *  save or open file dialog,  Vista uses the old XP look
        *  and feel.  OFN_ENABLEHOOK is used to grow the file
        *  name buffer in a multi-select file dialog.  The fix
        *  is to only use OFN_ENABLEHOOK when the buffer has
        *  overrun.
        */
        if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION (6, 0)) {
            USE_HOOK = false;
        }
    }`));

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

private static extern(Windows) UINT_PTR OFNHookProc (HWND hdlg, uint uiMsg, WPARAM wParam, LPARAM lParam) {
    switch (uiMsg) {
        case OS.WM_NOTIFY:
            OFNOTIFY* ofn = cast(OFNOTIFY*)lParam;
            //OS.MoveMemory (ofn, lParam, OFNOTIFY.sizeof);
            if (ofn.hdr.code is OS.CDN_SELCHANGE) {
                auto lResult = OS.SendMessage (ofn.hdr.hwndFrom, OS.CDM_GETSPEC, 0, 0);
                if (lResult > 0) {
                    lResult += OS.MAX_PATH;
                    OPENFILENAME* lpofn = ofn.lpOFN;
                    //OS.MoveMemory (lpofn, ofn.lpOFN, OS.OPENFILENAME_sizeof);
                    if (lpofn.nMaxFile < lResult) {
                        auto hHeap = OS.GetProcessHeap ();
                        auto lpstrFile = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, lResult * TCHAR.sizeof);
                        if (lpstrFile !is null) {
                            if (lpofn.lpstrFile !is null) OS.HeapFree (hHeap, 0, lpofn.lpstrFile);
                            lpofn.lpstrFile = lpstrFile;
                            lpofn.nMaxFile = cast(int)/*64bit*/lResult;
                            //OS.MoveMemory (ofn.lpOFN, lpofn, OS.OPENFILENAME_sizeof);
                        }
                    }
              }
          }
          break;
        default:
    }
    return 0;
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
    auto hHeap = OS.GetProcessHeap ();

    /* Get the owner HWND for the dialog */
    HWND hwndOwner = parent.handle;
    auto hwndParent = parent.handle;

    /*
    * Feature in Windows.  There is no API to set the orientation of a
    * file dialog.  It is always inherited from the parent.  The fix is
    * to create a hidden parent and set the orientation in the hidden
    * parent for the dialog to inherit.
    */
    bool enabled = false;
    if (!OS.IsWinCE && OS.WIN32_VERSION >= OS.VERSION(4, 10)) {
        int dialogOrientation = style & (SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT);
        int parentOrientation = parent.style & (SWT.LEFT_TO_RIGHT | SWT.RIGHT_TO_LEFT);
        if (dialogOrientation !is parentOrientation) {
            int exStyle = OS.WS_EX_NOINHERITLAYOUT;
            if (dialogOrientation is SWT.RIGHT_TO_LEFT) exStyle |= OS.WS_EX_LAYOUTRTL;
            hwndOwner = OS.CreateWindowEx (
                exStyle,
                Shell.DialogClass.ptr,
                null,
                0,
                OS.CW_USEDEFAULT, 0, OS.CW_USEDEFAULT, 0,
                hwndParent,
                null,
                OS.GetModuleHandle (null),
                null);
            enabled = OS.IsWindowEnabled (hwndParent) !is 0;
            if (enabled) OS.EnableWindow (hwndParent, false);
        }
    }

    /* Convert the title and copy it into lpstrTitle */
    if (title is null) title = "";
    /* Use the character encoding for the default locale */
    auto buffer3 = StrToTCHARs (0, title, true);
    auto byteCount3 = buffer3.length * TCHAR.sizeof;
    auto lpstrTitle = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount3);
    OS.MoveMemory (lpstrTitle, buffer3.ptr, byteCount3);

    /* Compute filters and copy into lpstrFilter */
    String strFilter = "";
    if (filterNames is null) filterNames = null;
    if (filterExtensions is null) filterExtensions = null;
    for (int i=0; i<filterExtensions.length; i++) {
        String filterName = filterExtensions [i];
        if (i < filterNames.length) filterName = filterNames [i];
        strFilter = strFilter ~ filterName ~ '\0' ~ filterExtensions [i] ~ '\0';
    }
    if (filterExtensions.length is 0) {
        strFilter = strFilter ~ FILTER ~ '\0' ~ FILTER ~ '\0';
    }
    /* Use the character encoding for the default locale */
    auto buffer4 = StrToTCHARs (0, strFilter, true);
    auto byteCount4 = buffer4.length * TCHAR.sizeof;
    auto lpstrFilter = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount4);
    OS.MoveMemory (lpstrFilter, buffer4.ptr, byteCount4);

    /* Convert the fileName and filterName to C strings */
    if (fileName is null) fileName = "";
    /* Use the character encoding for the default locale */
    auto name = StrToTCHARs (0, fileName, true);

    /*
    * Copy the name into lpstrFile and ensure that the
    * last byte is NULL and the buffer does not overrun.
    */
    int nMaxFile = OS.MAX_PATH;
    if ((style & SWT.MULTI) !is 0) nMaxFile = Math.max (nMaxFile, BUFFER_SIZE);
    auto byteCount = nMaxFile * TCHAR.sizeof;
    auto lpstrFile = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
    auto byteCountFile = Math.min (name.length * TCHAR.sizeof, byteCount - TCHAR.sizeof);
    OS.MoveMemory (lpstrFile, name.ptr, byteCountFile);

    /*
    * Copy the path into lpstrInitialDir and ensure that
    * the last byte is NULL and the buffer does not overrun.
    */
    if (filterPath is null) filterPath = "";
    /* Use the character encoding for the default locale */
    auto path = StrToTCHARs (0, filterPath.replace ('/', '\\'), true);
    int byteCount5 = OS.MAX_PATH * TCHAR.sizeof;
    auto lpstrInitialDir = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount5);
    auto byteCountDir = Math.min (path.length * TCHAR.sizeof, byteCount5 - TCHAR.sizeof);
    OS.MoveMemory (lpstrInitialDir, path.ptr, byteCountDir);

    /* Create the file dialog struct */
    OPENFILENAME struct_;
    struct_.lStructSize = OS.OPENFILENAME_sizeof;
    struct_.Flags = OS.OFN_HIDEREADONLY | OS.OFN_NOCHANGEDIR;
    bool save = (style & SWT.SAVE) !is 0;
    if (save && overwrite) struct_.Flags |= OS.OFN_OVERWRITEPROMPT;
    if ((style & SWT.MULTI) !is 0) {
        struct_.Flags |= OS.OFN_ALLOWMULTISELECT | OS.OFN_EXPLORER;
        if (!OS.IsWinCE && USE_HOOK) {
            //callback = new Callback (this, "OFNHookProc", 4); //$NON-NLS-1$
            //int lpfnHook = callback.getAddress ();
            //if (lpfnHook is 0) SWT.error (SWT.ERROR_NO_MORE_CALLBACKS);
            struct_.lCustData = cast(ptrdiff_t)cast(void*) this;
            struct_.lpfnHook = &OFNHookProc;
            struct_.Flags |= OS.OFN_ENABLEHOOK;
        }
    }
    struct_.hwndOwner = hwndOwner;
    struct_.lpstrTitle = lpstrTitle;
    struct_.lpstrFile = lpstrFile;
    struct_.nMaxFile = nMaxFile;
    struct_.lpstrInitialDir = lpstrInitialDir;
    struct_.lpstrFilter = lpstrFilter;
    struct_.nFilterIndex = filterIndex is 0 ? filterIndex : filterIndex + 1;

    /*
    * Set the default extension to an empty string.  If the
    * user fails to type an extension and this extension is
    * empty, Windows uses the current value of the filter
    * extension at the time that the dialog is closed.
    */
    TCHAR* lpstrDefExt;
    if (save) {
        lpstrDefExt = cast(TCHAR*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, TCHAR.sizeof);
        struct_.lpstrDefExt = lpstrDefExt;
    }

    /* Make the parent shell be temporary modal */
    Dialog oldModal = null;
    Display display = parent.getDisplay ();
    if ((style & (SWT.APPLICATION_MODAL | SWT.SYSTEM_MODAL)) !is 0) {
        oldModal = display.getModalDialog ();
        display.setModalDialog (this);
    }

    /*
    * Feature in Windows.  For some reason, the WH_MSGFILTER filter
    * does not run for GetSaveFileName() or GetOpenFileName().  The
    * fix is to allow async messages to run in the WH_FOREGROUNDIDLE
    * hook instead.
    *
    * Bug in Windows 98.  For some reason, when certain operating
    * system calls such as Shell_NotifyIcon(), GetOpenFileName()
    * and GetSaveFileName() are made during the WH_FOREGROUNDIDLE
    * hook, Windows hangs.  The fix is to disallow async messages
    * during WH_FOREGROUNDIDLE.
    */
    bool oldRunMessagesInIdle = display.runMessagesInIdle;
    display.runMessagesInIdle = !OS.IsWin95;
    /*
    * Open the dialog.  If the open fails due to an invalid
    * file name, use an empty file name and open it again.
    */
    bool success = cast(bool)( (save) ? OS.GetSaveFileName (&struct_) : OS.GetOpenFileName (&struct_));
    switch (OS.CommDlgExtendedError ()) {
        case OS.FNERR_INVALIDFILENAME:
            OS.MoveMemory (lpstrFile, StrToTCHARz ( "" ), TCHAR.sizeof);
            success = cast(bool)((save) ? OS.GetSaveFileName (&struct_) : OS.GetOpenFileName (&struct_));
            break;
        case OS.FNERR_BUFFERTOOSMALL:
            USE_HOOK = true;
            break;
        default:
    }
    display.runMessagesInIdle = oldRunMessagesInIdle;

    /* Clear the temporary dialog modal parent */
    if ((style & (SWT.APPLICATION_MODAL | SWT.SYSTEM_MODAL)) !is 0) {
        display.setModalDialog (oldModal);
    }

    /* Dispose the callback and reassign the buffer */
    //if (callback !is null) callback.dispose ();
    lpstrFile = struct_.lpstrFile;

    /* Set the new path, file name and filter */
    fileNames = null;
    String fullPath = null;
    if (success) {

        /* Use the character encoding for the default locale */
        TCHAR[] buffer = NewTCHARs (0, struct_.nMaxFile);
        auto byteCount1 = buffer.length * TCHAR.sizeof;
        OS.MoveMemory (buffer.ptr, lpstrFile, byteCount1);

        /*
        * Bug in WinCE.  For some reason, nFileOffset and nFileExtension
        * are always zero on WinCE HPC. nFileOffset is always zero on
        * WinCE PPC when using GetSaveFileName().  nFileOffset is correctly
        * set on WinCE PPC when using OpenFileName().  The fix is to parse
        * lpstrFile to calculate nFileOffset.
        *
        * Note: WinCE does not support multi-select file dialogs.
        */
        int nFileOffset = struct_.nFileOffset;
        static if (OS.IsWinCE) {
            if (nFileOffset is 0) {
                int index = 0;
                while (index < buffer.length ) {
                    int ch = buffer[index];
                    if (ch is 0) break;
                    if (ch is '\\') nFileOffset = index + 1;
                    index++;
                }
            }
        }
        if (nFileOffset > 0) {

            /* Use the character encoding for the default locale */
            TCHAR[] prefix = NewTCHARs (0, nFileOffset - 1);
            auto byteCount2 = prefix.length * TCHAR.sizeof;
            OS.MoveMemory (prefix.ptr, lpstrFile, byteCount2);
            filterPath = TCHARsToStr( prefix );

            /*
            * Get each file from the buffer.  Files are delimited
            * by a NULL character with 2 NULL characters at the end.
            */
            int count = 0;
            fileNames = new String[]( (style & SWT.MULTI) !is 0 ? 4 : 1 );
            int start = nFileOffset;
            do {
                int end = start;
                while (end < buffer.length && buffer[end] !is 0) end++;
                String string = TCHARsToStr( buffer[ start .. end ] );
                start = end;
                if (count is fileNames.length) {
                    String [] newFileNames = new String[]( fileNames.length + 4 );
                    System.arraycopy (fileNames, 0, newFileNames, 0, fileNames.length);
                    fileNames = newFileNames;
                }
                fileNames [count++] = string;
                if ((style & SWT.MULTI) is 0) break;
                start++;
            } while (start < buffer.length && buffer[start] !is 0);

            if (fileNames.length > 0) fileName = fileNames  [0];
            String separator = "";
            int length_ = cast(int)/*64bit*/filterPath.length;
            if (length_ > 0 && filterPath[length_ - 1] !is '\\') {
                separator = "\\";
            }
            fullPath = filterPath ~ separator ~ fileName;
            if (count < fileNames.length) {
                String [] newFileNames = new String[]( count );
                System.arraycopy (fileNames, 0, newFileNames, 0, count);
                fileNames = newFileNames;
            }
        }
        filterIndex = struct_.nFilterIndex - 1;
    }

    /* Free the memory that was allocated. */
    OS.HeapFree (hHeap, 0, lpstrFile);
    OS.HeapFree (hHeap, 0, lpstrFilter);
    OS.HeapFree (hHeap, 0, lpstrInitialDir);
    OS.HeapFree (hHeap, 0, lpstrTitle);
    if (lpstrDefExt !is null) OS.HeapFree (hHeap, 0, lpstrDefExt);

    /* Destroy the BIDI orientation window */
    if (hwndParent !is hwndOwner) {
        if (enabled) OS.EnableWindow (hwndParent, true);
        OS.SetActiveWindow (hwndParent);
        OS.DestroyWindow (hwndOwner);
    }

    /*
    * This code is intentionally commented.  On some
    * platforms, the owner window is repainted right
    * away when a dialog window exits.  This behavior
    * is currently unspecified.
    */
//  if (hwndOwner !is 0) OS.UpdateWindow (hwndOwner);

    /* Answer the full path or null */
    return fullPath;
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

