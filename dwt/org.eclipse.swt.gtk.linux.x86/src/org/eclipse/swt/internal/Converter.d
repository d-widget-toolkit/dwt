/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
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
module org.eclipse.swt.internal.Converter;

import java.lang.all;

extern(C) {
    struct GError{};
    char*     g_utf16_to_utf8     ( wchar  *str,
                    int             len,
                    int             *items_read,
                    int             *items_written,
                    GError          **error);
    wchar* g_utf8_to_utf16     ( char      *str,
                    int              len,
                    int             *items_read,
                    int             *items_written,
                    GError          **error);
    void g_free (void* ptr );
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
public static String defaultCodePage () {
    return "UTF8";
}

public static wchar [] mbcsToWcs (String codePage, char [] buffer) {
    int items_written;
    wchar* ptr = g_utf8_to_utf16 (toStringz(buffer), cast(int)/*64bit*/buffer.length,
                                  null, &items_written, null);
    if (!ptr){
        return cast(wchar[])EmptyCharArray;
    }
    wchar[] chars = ptr[ 0 .. items_written].dup;
    g_free (ptr);
    return chars;
}

/+ // only difference with String vs. String arg, so no diff in org.eclipse.swt
public static char [] wcsToMbcs (String codePage, String str, bool terminate) {
    int length = str.length ();
    wchar [] buffer = new wchar [length];
    string.getChars (0, length, buffer, 0);
    return wcsToMbcs (codePage, buffer, terminate);
}
+/

public static char [] wcsToMbcs (String codePage, wchar [] buffer, bool terminate) {
    int items_read, items_written;
    /*
    * Note that g_utf16_to_utf8()  stops converting
    * when it finds the first NULL.
    */
    char* ptr = g_utf16_to_utf8 (toString16z(buffer), cast(int)/*64bit*/buffer.length,
                                 & items_read, & items_written, null);
    if (!ptr) {
        return terminate ?cast(char[]) NullByteArray : cast(char[])EmptyByteArray;
    }
    char [] bytes = new char [items_written + (terminate ? 1 : 0)];
    bytes[ 0 .. items_written ] = ptr[ 0 .. items_written ];
    if( terminate ){
        bytes[ items_written ] = 0;
    }
    g_free (ptr);
    return bytes;
}

}
