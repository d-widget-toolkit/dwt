/*******************************************************************************
 * Copyright (c) 2000, 2012 IBM Corporation and others.
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
module org.eclipse.swt.internal.Converter;

import java.lang.all;

import core.stdc.config : c_long;
import std.conv : to;
import org.eclipse.swt.internal.gtk.OS : GError, OS;

extern(C) {
    char*     g_utf16_to_utf8     ( wchar  *str,
                    c_long          len,
                    c_long          *items_read,
                    c_long          *items_written,
                    GError          **error);
    wchar* g_utf8_to_utf16     ( char      *str,
                    c_long           len,
                    c_long          *items_read,
                    c_long          *items_written,
                    GError          **error);
}

/**
 * This class implements the conversions between unicode characters
 * and the <em>platform supported</em> representation for characters.
 * <p>
 * Note that, unicode characters which can not be found in the platform
 * encoding will be converted to an arbitrary platform specific character.
 * </p>
 */
public final class Converter {
    public static const char  [] NullByteArray = "\0";
    public static const char  [] EmptyByteArray;
    public static const wchar [] EmptyCharArray;

/**
 * Returns the default code page for the platform where the
 * application is currently running.
 *
 * @return the default code page
 */
deprecated("This method is no longer required and has no replacement")
public static String defaultCodePage () {
    return "UTF8";
}

/**
 * Convert a "C" multibyte UTF-8 string byte array into a Java UTF-16 Wide character array.
 *
 * @param buffer - byte buffer with C bytes representing a string.
 * @return char array representing the string.  Usually used for String construction like: new String(mbcsToWcs(..))
 */
public static wchar [] mbcsToWcs (char [] buffer) {
    c_long items_written;
    wchar* ptr = g_utf8_to_utf16(toStringz(buffer), cast(c_long)buffer.length,
                                 null, &items_written, null);
    if (ptr is null) return cast(wchar[])EmptyCharArray;
    wchar [] chars = ptr[0 .. items_written].dup;
    OS.g_free (ptr);
    return chars;
}

/// Ditto
deprecated("Please use mbcsToWcs(char[]) instead")
public static wchar [] mbcsToWcs (String codePage, char [] buffer) {
    return mbcsToWcs(buffer);
}

/+ // only difference with String vs. String arg, so no diff in org.eclipse.swt
public static char [] wcsToMbcs (String codePage, String str, bool terminate) {
    int length = str.length ();
    wchar [] buffer = new wchar [length];
    string.getChars (0, length, buffer, 0);
    return wcsToMbcs (codePage, buffer, terminate);
}
+/

/**
 * This method takes a 'C' pointer (char *) or  (gchar *), reads characters up to the terminating
 * symbol '\0' and converts it into a Java String.
 *
 * @param cCharPtr - A char * or gchar *. Which will be freed up afterwards.
 * @param freecCharPtr - "true" means free up memory pointed to by cCharPtr.
 *                     CAREFUL! If this string is part of a struct (ex GError), and a specialized
 *                     free function (like g_error_free(..) is called on the whole struct, then you
 *                     should not free up individual struct members with this function,
 *                     as otherwise you can get unpredictable behavior).
 * @return a Java String object.
 */
public static String cCharPtrToJavaString(char* cCharPtr, bool freecCharPtr) {
    int length = OS.strlen(cCharPtr);
    char [] buffer = cCharPtr[0 .. length].dup;
    if (freecCharPtr) {
        OS.g_free (cCharPtr);
    }
    return to!(String)(mbcsToWcs (buffer));
}

/**
 * Convert a Java UTF-16 Wide character array into a C UTF-8 Multibyte byte array.
 *
 * This algorithm stops when it finds the first NULL character. I.e, if your Java String has embedded NULL
 * characters, then the returned string will only go up to the first NULL character.
 *
 * @param chars - a regular Java String
 * @param terminate - if <code>true</code> the byte buffer should be terminated with a null character.
 * @return byte array that can be passed to a native function.
 */
public static char [] wcsToMbcs (wchar [] chars, bool terminate) {
    c_long items_read, items_written;
    /*
    * Note that g_utf16_to_utf8()  stops converting
    * when it finds the first NULL.
    */
    char* ptr = g_utf16_to_utf8 (toString16z(chars), cast(c_long)chars.length,
                                 &items_read, &items_written, null);
    if (ptr is null) {
        return terminate ? cast(char[])NullByteArray : cast(char[])EmptyByteArray;
    }
    char [] bytes = new char [items_written + (terminate ? 1 : 0)];
    bytes[0 .. items_written] = ptr[0 .. items_written];
    if (terminate) {
        bytes[items_written] = '\0';
    }
    OS.g_free (ptr);
    return bytes;
}

deprecated("Please use wcsToMbcs(wchar [], bool) instead")
public static char [] wcsToMbcs (String codePage, wchar [] buffer, bool terminate) {
    return wcsToMbcs(buffer, terminate);
}

/**
 * Convert a Java UTF-16 Wide character into a single C UTF-8 Multibyte character
 * that you can pass to a native function.
 * @param ch - Java UTF-16 wide character.
 * @return C UTF-8 Multibyte character.
 */
public static char wcsToMbcs (wchar ch) {
    int key = ch & 0xFFFF;
    if (key <= 0x7F) return cast(char)ch;
    char [] buffer = wcsToMbcs ([ch], false);
    if (buffer.length == 1) return cast(wchar) buffer[0];
    if (buffer.length == 2) {
        return cast(char) (((buffer [0] & 0xFF) << 8) | (buffer [1] & 0xFF));
    }
    return 0;
}

/**
 * Convert C UTF-8 Multibyte character into a Java UTF-16 Wide character.
 *
 * @param ch - C Multibyte UTF-8 character
 * @return Java UTF-16 Wide character
 */
public static wchar mbcsToWcs (char ch) {
    int key = ch & 0xFFFF;
    char [] buffer;
    if (key <= 0xFF) {
        buffer = new char [1];
        buffer [0] = cast(char)key;
    } else {
        buffer = new char [2];
        buffer [0] = cast(char) ((key >> 8) & 0xFF);
        buffer [1] = cast(char) (key & 0xFF);
    }
    wchar [] result = mbcsToWcs (buffer);
    if (result.length == 0) return 0;
    return result[0];
}

}
