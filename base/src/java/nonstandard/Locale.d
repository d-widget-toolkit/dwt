/**
 * Locale.d
 * Information of a locale.
 * Author: knt.roh
 * License: Public Domain
 */
module java.nonstandard.Locale;

import java.lang.String;
import java.lang.util : implMissing;

import core.stdc.string;

version (Windows) {
    import core.sys.windows.windows;
    import std.conv;
    import std.exception;
} else version (Posix) {
    import core.stdc.locale;
} else {
    static assert(0, "unsupported platform (locale)");
}

version (Windows) {
    private bool W_VERSION;
    static this() {
        W_VERSION = GetVersion < 0x80000000;
    }
    private extern (Windows) {
        enum LCID : DWORD {
            /// The default locale for the user or process.
            LOCALE_USER_DEFAULT     = 0x0400,
        }
        enum LCTYPE : DWORD {
            /// ISO639 language name.
            LOCALE_SISO639LANGNAME  = 0x0059,
            /// ISO3166 country name.
            LOCALE_SISO3166CTRYNAME = 0x005A
        }
        /// Retrieves information about a locale specified by identifier.
        /// See_Also: GetLocaleInfo Function (Windows)
        ///           (http://msdn.microsoft.com/en-us/library/dd318101%28VS.85%29.aspx)
        INT GetLocaleInfoW(
            LCID Locale,
            LCTYPE LCType,
            LPWSTR lpLCData,
            INT cchData
        );
        /// ditto
        INT GetLocaleInfoA(
            LCID Locale,
            LCTYPE LCType,
            LPCSTR lpLCData,
            INT cchData
        );
    }
    /// A purpose of this templete is switch of W or A in Windows.
    private String caltureNameImpl(Char, alias GetLocalInfo)() {
        INT len;
        Char[] res;
        Char[] buf;
        len = GetLocalInfo(LCID.LOCALE_USER_DEFAULT,
            LCTYPE.LOCALE_SISO639LANGNAME, null, 0);
        enforce(len, new Exception("LOCALE_SISO639LANGNAME (len)", __FILE__, __LINE__));
        buf.length = len;
        len = GetLocalInfo(LCID.LOCALE_USER_DEFAULT,
            LCTYPE.LOCALE_SISO639LANGNAME, buf.ptr, cast(INT)buf.length);
        enforce(len, new Exception("LOCALE_SISO639LANGNAME", __FILE__, __LINE__));
        res ~= buf[0 .. len - 1];
        res ~= '-';
        len = GetLocalInfo(LCID.LOCALE_USER_DEFAULT,
            LCTYPE.LOCALE_SISO3166CTRYNAME, null, 0);
        enforce(len, new Exception("LOCALE_SISO3166CTRYNAME (len)", __FILE__, __LINE__));
        buf.length = len;
        len = GetLocalInfo(LCID.LOCALE_USER_DEFAULT,
            LCTYPE.LOCALE_SISO3166CTRYNAME, buf.ptr, cast(INT)buf.length);
        enforce(len, new Exception("LOCALE_SISO3166CTRYNAME", __FILE__, __LINE__));
        res ~= buf[0 .. len - 1];
        return to!(String)(res);
    }
}

/// Get a omitted calture name. for example: "en-US"
String caltureName() {
    version (Windows) {
        if (W_VERSION) {
            return caltureNameImpl!(wchar, GetLocaleInfoW)();
        } else {
            return caltureNameImpl!(char, GetLocaleInfoA)();
        }
    } else version (Posix) {
        // Sets all categories of the locale for the process.
        setlocale(LC_ALL, "");

        char* loc = setlocale(LC_MESSAGES, null);

        // C and POSIX aren't valid locales for Java, so fallback to en_US.
        // https://www.oracle.com/java/technologies/javase/jdk8-jre8-suported-locales.html
        if (null is loc || (0 == strcmp(loc, "C")) || (0 == strcmp(loc, "POSIX"))) {
            return "en_US";
        }

        size_t len = strlen(loc);
        return loc[0..len].dup;
    }
}
