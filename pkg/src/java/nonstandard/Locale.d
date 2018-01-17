/**
 * Locale.d
 * Information of a locale.
 * Author: knt.roh
 * License: Public Domain
 */
module java.nonstandard.Locale;

import java.lang.String;
import java.lang.util : implMissing;

version(Tango){
    private import tango.text.locale.Core;
} else { // Phobos
    private import std.conv;
    private import std.exception;

    version (Windows) {
        private import core.stdc.string;
        private import core.sys.windows.windows;
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
    } else version (Posix) {
        private import std.process : environment;
        private import std.string : indexOf, replace;
    }
}
/// Get a omitted calture name. for example: "en-US"
String caltureName() {
    version(Tango){
        return Culture.current.name;
    } else { // Phobos
        version (Windows) {
            if (W_VERSION) {
                return caltureNameImpl!(wchar, GetLocaleInfoW)();
            } else {
                return caltureNameImpl!(char, GetLocaleInfoA)();
            }
        } else version (Posix) {
            // LC_ALL is override to settings of all category.
            // This is undefined in almost case.
            String res = .environment.get("LC_ALL", "");
            if (!res || !res.length) {
                // LANG is basic Locale setting.
                // A settings of each category override this. 
                res = .environment.get("LANG", "");
            }
            ptrdiff_t dot = .indexOf(res, '.');
            if (dot != -1) res = res[0 .. dot];
            return .replace(res, "_", "-");
        } else {
            static assert(0);
        }
    }
}
