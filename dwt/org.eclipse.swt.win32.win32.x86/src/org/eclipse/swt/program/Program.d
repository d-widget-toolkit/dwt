/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D Programming language:
 *      Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module org.eclipse.swt.program.Program;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.internal.win32.OS;

import java.lang.all;

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
    String iconName;
    String extension;
    static const String[] ARGUMENTS = ["%1"[], "%l", "%L"]; //$NON-NLS-1$ //$NON-NLS-2$ //$NON-NLS-3$

/**
 * Prevents uninitialized instances from being created outside the package.
 */
this () {
}

static String assocQueryString (int assocStr, StringT key, bool expand) {
    TCHAR[] pszOut = NewTCHARs(0, 1024);
    uint[1] pcchOut;
    pcchOut[0] = cast(uint)/*64bit*/pszOut.length;
    int flags = OS.ASSOCF_NOTRUNCATE | OS.ASSOCF_INIT_IGNOREUNKNOWN;
    int result = OS.AssocQueryString (flags, assocStr, key.ptr, null, pszOut.ptr, pcchOut.ptr);
    if (result is OS.E_POINTER) {
        pszOut = NewTCHARs(0, pcchOut [0]);
        result = OS.AssocQueryString (flags, assocStr, key.ptr, null, pszOut.ptr, pcchOut.ptr);
    }
    if (result is 0) {
        if (!OS.IsWinCE && expand) {
            int length_ = OS.ExpandEnvironmentStrings (pszOut.ptr, null, 0);
            if (length_ !is 0) {
                TCHAR[] lpDst = NewTCHARs (0, length_);
                OS.ExpandEnvironmentStrings (pszOut.ptr, lpDst.ptr, length_);
                return String_valueOf( lpDst[ 0 .. Math.max (0, length_ - 1) ] );
            } else {
                return "";
            }
        } else {
            return String_valueOf( pszOut[ 0 .. Math.max (0, pcchOut [0] - 1)]);
        }
    }
    return null;
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
public static Program findProgram (String extension) {
    // SWT extension: allow null string
    //if (extension is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    if (extension.length is 0) return null;
    if (extension.charAt (0) !is '.') extension = "." ~ extension; //$NON-NLS-1$
    /* Use the character encoding for the default locale */
    StringT key = StrToTCHARs (0, extension, true);
    Program program = null;
    if (OS.IsWinCE) {
        void*[1] phkResult;
        if (OS.RegOpenKeyEx ( cast(void*)OS.HKEY_CLASSES_ROOT, key.ptr, 0, OS.KEY_READ, phkResult.ptr) !is 0) {
            return null;
        }
        uint [1] lpcbData;
        int result = OS.RegQueryValueEx (phkResult [0], null, null, null, null, lpcbData.ptr);
        if (result is 0) {
            TCHAR[] lpData = NewTCHARs (0, lpcbData [0] / TCHAR.sizeof);
            result = OS.RegQueryValueEx (phkResult [0], null, null, null, cast(ubyte*)lpData.ptr, lpcbData.ptr);
            if (result is 0) program = getProgram ( TCHARzToStr( lpData.ptr ), extension);
        }
        OS.RegCloseKey (phkResult [0]);
    } else {
        String command = assocQueryString (OS.ASSOCSTR_COMMAND, key, true);
        if (command !is null) {
            String name = null;
            if (name is null) name = assocQueryString (OS.ASSOCSTR_FRIENDLYDOCNAME, key, false);
            if (name is null) name = assocQueryString (OS.ASSOCSTR_FRIENDLYAPPNAME, key, false);
            if (name is null) name = "";
            String iconName = assocQueryString (OS.ASSOCSTR_DEFAULTICON, key, true);
            if (iconName is null) iconName = "";
            program = new Program ();
            program.name = name;
            program.command = command;
            program.iconName = iconName;
            program.extension = extension;
        }
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
public static String [] getExtensions () {
    String [] extensions = new String [1024];
    /* Use the character encoding for the default locale */
    TCHAR[] lpName = NewTCHARs (0, 1024);
    uint [1] lpcName; lpcName[0] = cast(uint)/*64bit*/lpName.length;
    FILETIME ft;
    int dwIndex = 0, count = 0;
    while (OS.RegEnumKeyEx ( cast(void*)OS.HKEY_CLASSES_ROOT, dwIndex, lpName.ptr, lpcName.ptr, null, null, null, &ft) !is OS.ERROR_NO_MORE_ITEMS) {
        String extension = TCHARsToStr( lpName[0 .. lpcName[0] ]);
        lpcName [0] = cast(uint)/*64bit*/lpName.length;
        if (extension.length > 0 && extension.charAt (0) is '.') {
            if (count is extensions.length) {
                String[] newExtensions = new String[]( extensions.length + 1024 );
                System.arraycopy (extensions, 0, newExtensions, 0, extensions.length);
                extensions = newExtensions;
            }
            extensions [count++] = extension;
        }
        dwIndex++;
    }
    if (count !is extensions.length) {
        String[] newExtension = new String[]( count );
        System.arraycopy (extensions, 0, newExtension, 0, count);
        extensions = newExtension;
    }
    return extensions;
}

static String getKeyValue (String string, bool expand) {
    /* Use the character encoding for the default locale */
    StringT key = StrToTCHARs (0, string, true);
    void* [1] phkResult;
    if (OS.RegOpenKeyEx (cast(void*)OS.HKEY_CLASSES_ROOT, key.ptr, 0, OS.KEY_READ, phkResult.ptr) !is 0) {
        return null;
    }
    String result = null;
    uint [1] lpcbData;
    if (OS.RegQueryValueEx (phkResult [0], null, null, null, null, lpcbData.ptr) is 0) {
        result = "";
        int length_ = lpcbData [0] / TCHAR.sizeof;
        if (length_ !is 0) {
            /* Use the character encoding for the default locale */
            TCHAR[] lpData = NewTCHARs (0, length_);
            if (OS.RegQueryValueEx (phkResult [0], null, null, null, cast(ubyte*)lpData.ptr, lpcbData.ptr) is 0) {
                if (!OS.IsWinCE && expand) {
                    length_ = OS.ExpandEnvironmentStrings (lpData.ptr, null, 0);
                    if (length_ !is 0) {
                        TCHAR[] lpDst = NewTCHARs (0, length_);
                        OS.ExpandEnvironmentStrings (lpData.ptr, lpDst.ptr, length_);
                        result = String_valueOf ( lpDst[0 .. Math.max (0, length_ - 1) ] );
                    }
                } else {
                    length_ = Math.max (0, cast(int)/*64bit*/lpData.length - 1);
                    result = String_valueOf ( lpData[0 .. length_]);
                }
            }
        }
    }
    if (phkResult [0] !is null) OS.RegCloseKey (phkResult [0]);
    return result;
}

static Program getProgram (String key, String extension) {

    /* Name */
    String name = getKeyValue (key, false);
    if (name is null || name.length is 0) {
        name = key;
    }

    /* Command */
    String DEFAULT_COMMAND = "\\shell"; //$NON-NLS-1$
    String defaultCommand = getKeyValue (key ~ DEFAULT_COMMAND, true);
    if (defaultCommand is null || defaultCommand.length is 0) defaultCommand = "open"; //$NON-NLS-1$
    String COMMAND = "\\shell\\" ~ defaultCommand ~ "\\command"; //$NON-NLS-1$
    String command = getKeyValue (key ~ COMMAND, true);
    if (command is null || command.length is 0) return null;

    /* Icon */
    String DEFAULT_ICON = "\\DefaultIcon"; //$NON-NLS-1$
    String iconName = getKeyValue (key ~ DEFAULT_ICON, true);
    if (iconName is null) iconName = ""; //$NON-NLS-1$

    /* Program */
    Program program = new Program ();
    program.name = name;
    program.command = command;
    program.iconName = iconName;
    program.extension = extension;
    return program;
}

/**
 * Answers all available programs in the operating system.  Note
 * that a <code>Display</code> must already exist to guarantee
 * that this method returns an appropriate result.
 *
 * @return an array of programs
 */
public static Program [] getPrograms () {
    Program [] programs = new Program [1024];
    /* Use the character encoding for the default locale */
    TCHAR[] lpName = NewTCHARs (0, 1024);
    uint [1] lpcName; lpcName[0] = cast(uint)/*64bit*/lpName.length;
    FILETIME ft;
    int dwIndex = 0, count = 0;
    while (OS.RegEnumKeyEx (cast(void*)OS.HKEY_CLASSES_ROOT, dwIndex, lpName.ptr, lpcName.ptr, null, null, null, &ft) !is OS.ERROR_NO_MORE_ITEMS) {
        String path = String_valueOf ( lpName[0 .. lpcName [0]]);
        lpcName [0] = cast(uint)/*64bit*/lpName.length ;
        Program program = getProgram (path, null);
        if (program !is null) {
            if (count is programs.length) {
                Program [] newPrograms = new Program [programs.length + 1024];
                System.arraycopy (programs, 0, newPrograms, 0, programs.length);
                programs = newPrograms;
            }
            programs [count++] = program;
        }
        dwIndex++;
    }
    if (count !is programs.length) {
        Program [] newPrograms = new Program [count];
        System.arraycopy (programs, 0, newPrograms, 0, count);
        programs = newPrograms;
    }
    return programs;
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
public static bool launch (String fileName) {
    if (fileName is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);

    /* Use the character encoding for the default locale */
    auto hHeap = OS.GetProcessHeap ();
    StringT buffer = StrToTCHARs (0, fileName, true);
    auto byteCount = buffer.length * TCHAR.sizeof;
    auto lpFile = cast(wchar*) OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
    OS.MoveMemory (lpFile, buffer.ptr, byteCount);
    SHELLEXECUTEINFO info;
    info.cbSize = SHELLEXECUTEINFO.sizeof;
    info.lpFile = lpFile;
    info.nShow = OS.SW_SHOW;
    bool result = cast(bool) OS.ShellExecuteEx (&info);
    if (lpFile !is null) OS.HeapFree (hHeap, 0, lpFile);
    return result;
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
public bool execute (String fileName) {
    if (fileName is null) SWT.error (SWT.ERROR_NULL_ARGUMENT);
    int index = 0;
    bool append = true;
    String prefix = command, suffix = ""; //$NON-NLS-1$
    while (index < ARGUMENTS.length) {
        int i = command.indexOf (ARGUMENTS [index]);
        if (i !is -1) {
            append = false;
            prefix = command.substring (0, i);
            suffix = command.substring (i + cast(int)/*64bit*/ARGUMENTS [index].length , cast(int)/*64bit*/command.length );
            break;
        }
        index++;
    }
    if (append) fileName = " \"" ~ fileName ~ "\"";
    String commandLine = prefix ~ fileName ~ suffix;
    auto hHeap = OS.GetProcessHeap ();
    /* Use the character encoding for the default locale */
    StringT buffer = StrToTCHARs (0, commandLine, true);
    auto byteCount = buffer.length  * TCHAR.sizeof;
    auto lpCommandLine = cast(TCHAR*)OS.HeapAlloc (hHeap, OS.HEAP_ZERO_MEMORY, byteCount);
    OS.MoveMemory (lpCommandLine, buffer.ptr, byteCount);
    STARTUPINFO lpStartupInfo;
    lpStartupInfo.cb = STARTUPINFO.sizeof;
    PROCESS_INFORMATION lpProcessInformation;
    bool success = cast(bool) OS.CreateProcess (null, lpCommandLine, null, null, false, 0, null, null, &lpStartupInfo, &lpProcessInformation);
    if (lpCommandLine !is null) OS.HeapFree (hHeap, 0, lpCommandLine);
    if (lpProcessInformation.hProcess !is null) OS.CloseHandle (lpProcessInformation.hProcess);
    if (lpProcessInformation.hThread !is null) OS.CloseHandle (lpProcessInformation.hThread);
    return success;
}

/**
 * Returns the receiver's image data.  This is the icon
 * that is associated with the receiver in the operating
 * system.
 *
 * @return the image data for the program, may be null
 */
public ImageData getImageData () {
    if (extension !is null) {
        SHFILEINFOW shfi;
        int flags = OS.SHGFI_ICON | OS.SHGFI_SMALLICON | OS.SHGFI_USEFILEATTRIBUTES;
        StringT pszPath = StrToTCHARs (0, extension, true);
        OS.SHGetFileInfo (pszPath.ptr, OS.FILE_ATTRIBUTE_NORMAL, &shfi, SHFILEINFO.sizeof, flags);
        if (shfi.hIcon !is null) {
            Image image = Image.win32_new (null, SWT.ICON, shfi.hIcon);
            ImageData imageData = image.getImageData ();
            image.dispose ();
            return imageData;
        }
    }
    int nIconIndex = 0;
    String fileName = iconName;
    int index = iconName.indexOf (',');
    if (index !is -1) {
        fileName = iconName.substring (0, index);
        String iconIndex = iconName.substring (index + 1, cast(int)/*64bit*/iconName.length ).trim ();
        try {
            nIconIndex = Integer.parseInt (iconIndex);
        } catch (NumberFormatException e) {}
    }
    int length = cast(int)/*64bit*/fileName.length;
    if (length !is 0 && fileName.charAt (0) is '\"') {
        if (fileName.charAt (length - 1) is '\"') {
            fileName = fileName.substring (1, length - 1);
        }
    }
    /* Use the character encoding for the default locale */
    StringT lpszFile = StrToTCHARs (0, fileName, true);
    HICON [1] phiconSmall, phiconLarge;
    OS.ExtractIconEx (lpszFile.ptr, nIconIndex, phiconLarge.ptr, phiconSmall.ptr, 1);
    if (phiconSmall [0] is null) return null;
    Image image = Image.win32_new (null, SWT.ICON, phiconSmall [0]);
    ImageData imageData = image.getImageData ();
    image.dispose ();
    return imageData;
}

/**
 * Returns the receiver's name.  This is as short and
 * descriptive a name as possible for the program.  If
 * the program has no descriptive name, this string may
 * be the executable name, path or empty.
 *
 * @return the name of the program
 */
public String getName () {
    return name;
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
    if ( auto program = cast(Program)other ) {
        return name.equals(program.name) && command.equals(program.command)
            && iconName.equals(program.iconName);
    }
    return false;
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
    return .toHash(name) ^ .toHash(command) ^ .toHash(iconName);
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the program
 */
override
public String toString () {
    return "Program {" ~ name ~ "}"; //$NON-NLS-1$ //$NON-NLS-2$
}

}
