module java.lang.Character;

import java.lang.util;
import java.lang.exceptions;
import java.lang.Class;
import java.lang.String;

version(Tango){
    static import tango.text.Unicode;
    static import tango.text.UnicodeData; //for getUnicodeData
} else { // Phobos
    static import std.utf;
    static import std.conv;
    static import std.uni;
    static import std.string;
}

class Character {
    public static const int MIN_RADIX = 2;
    public static const int MAX_RADIX = 36;
    public static bool isUpperCase( dchar c ){
        version(Tango){
            implMissingInTango( __FILE__, __LINE__);
            return false;
        } else { // Phobos
            return !!std.uni.isUpper(c);
        }
    }
    public static dchar toUpperCase( dchar c ){
        version(Tango){
            dchar[1] src = c;
            dchar[] r = tango.text.Unicode.toUpper( src );
            return r[0];
        } else { // Phobos
            return std.uni.toUpper( c );
        }
    }
    public static String toString( char c ){
        version(Tango){
            implMissingInTango(__FILE__, __LINE__ );
            return null;
        } else { // Phobos
            return std.conv.to!(String)( c );
        }
    }
    public static String toString( wchar c ){
        version(Tango){
            implMissingInTango(__FILE__, __LINE__ );
            return null;
        } else { // Phobos
            return std.conv.to!(String)( c );
        }
    }
    public static String toString( dchar c ){
        version(Tango){
            implMissingInTango(__FILE__, __LINE__ );
            return null;
        } else { // Phobos
            return std.conv.to!(String)( c );
        }
    }
    public static dchar toLowerCase( dchar c ){
        version(Tango){
            dchar[1] src = c;
            dchar[] r = tango.text.Unicode.toLower( src );
            return r[0];
        } else { // Phobos
            return std.uni.toLower( c );
        }
    }
    ///Determines if the specified character is ISO-LATIN-1 white space.
    public static bool isSpace( dchar c ){
        return c == '\t' || c == '\n' || c == '\f' || c == '\r' || c == ' ';
    }
    ///Determines if the specified character is a Unicode space character.
    public static bool isSpaceChar( dchar c ){
        version(Tango){
            return tango.text.Unicode.isWhitespace( c );
        } else { // Phobos
            return std.uni.isWhite(c);
        }
    }
    alias isWhitespace isWhiteSpace;
    ///Determines if the specified character is white space according to Java.
    public static bool isWhitespace( dchar c ){
        // It is a Unicode space character (SPACE_SEPARATOR, LINE_SEPARATOR, or PARAGRAPH_SEPARATOR)
        // but is not also a non-breaking space ('\u00A0', '\u2007', '\u202F').
        return isSpaceChar(c) && c != '\u00A0' && c != '\u2007' && c != '\u202F'
            || c == '\u0009' // It is '\u0009', HORIZONTAL TABULATION.
            || c == '\u000A' // It is '\u000A', LINE FEED.
            || c == '\u000B' // It is '\u000B', VERTICAL TABULATION.
            || c == '\u000C' // It is '\u000C', FORM FEED.
            || c == '\u000D' // It is '\u000D', CARRIAGE RETURN.
            || c == '\u001C' // It is '\u001C', FILE SEPARATOR.
            || c == '\u001D' // It is '\u001D', GROUP SEPARATOR.
            || c == '\u001E' // It is '\u001E', RECORD SEPARATOR.
            || c == '\u001F'; // It is '\u001F', UNIT SEPARATOR. 
    }
    public static bool isDigit( dchar c ){
        version(Tango){
            return tango.text.Unicode.isDigit( c );
        } else { // Phobos
            const dchar[] unicodeNd = [
'\u0030', '\u0031', '\u0032', '\u0033', '\u0034', '\u0035', '\u0036', '\u0037', '\u0038', '\u0039', '\u0660', '\u0661', '\u0662', 
'\u0663', '\u0664', '\u0665', '\u0666', '\u0667', '\u0668', '\u0669', '\u06F0', '\u06F1', '\u06F2', '\u06F3', '\u06F4', '\u06F5', 
'\u06F6', '\u06F7', '\u06F8', '\u06F9', '\u07C0', '\u07C1', '\u07C2', '\u07C3', '\u07C4', '\u07C5', '\u07C6', '\u07C7', '\u07C8', 
'\u07C9', '\u0966', '\u0967', '\u0968', '\u0969', '\u096A', '\u096B', '\u096C', '\u096D', '\u096E', '\u096F', '\u09E6', '\u09E7', 
'\u09E8', '\u09E9', '\u09EA', '\u09EB', '\u09EC', '\u09ED', '\u09EE', '\u09EF', '\u0A66', '\u0A67', '\u0A68', '\u0A69', '\u0A6A', 
'\u0A6B', '\u0A6C', '\u0A6D', '\u0A6E', '\u0A6F', '\u0AE6', '\u0AE7', '\u0AE8', '\u0AE9', '\u0AEA', '\u0AEB', '\u0AEC', '\u0AED', 
'\u0AEE', '\u0AEF', '\u0B66', '\u0B67', '\u0B68', '\u0B69', '\u0B6A', '\u0B6B', '\u0B6C', '\u0B6D', '\u0B6E', '\u0B6F', '\u0BE6', 
'\u0BE7', '\u0BE8', '\u0BE9', '\u0BEA', '\u0BEB', '\u0BEC', '\u0BED', '\u0BEE', '\u0BEF', '\u0C66', '\u0C67', '\u0C68', '\u0C69', 
'\u0C6A', '\u0C6B', '\u0C6C', '\u0C6D', '\u0C6E', '\u0C6F', '\u0CE6', '\u0CE7', '\u0CE8', '\u0CE9', '\u0CEA', '\u0CEB', '\u0CEC', 
'\u0CED', '\u0CEE', '\u0CEF', '\u0D66', '\u0D67', '\u0D68', '\u0D69', '\u0D6A', '\u0D6B', '\u0D6C', '\u0D6D', '\u0D6E', '\u0D6F', 
'\u0E50', '\u0E51', '\u0E52', '\u0E53', '\u0E54', '\u0E55', '\u0E56', '\u0E57', '\u0E58', '\u0E59', '\u0ED0', '\u0ED1', '\u0ED2', 
'\u0ED3', '\u0ED4', '\u0ED5', '\u0ED6', '\u0ED7', '\u0ED8', '\u0ED9', '\u0F20', '\u0F21', '\u0F22', '\u0F23', '\u0F24', '\u0F25', 
'\u0F26', '\u0F27', '\u0F28', '\u0F29', '\u1040', '\u1041', '\u1042', '\u1043', '\u1044', '\u1045', '\u1046', '\u1047', '\u1048', 
'\u1049', '\u1090', '\u1091', '\u1092', '\u1093', '\u1094', '\u1095', '\u1096', '\u1097', '\u1098', '\u1099', '\u17E0', '\u17E1', 
'\u17E2', '\u17E3', '\u17E4', '\u17E5', '\u17E6', '\u17E7', '\u17E8', '\u17E9', '\u1810', '\u1811', '\u1812', '\u1813', '\u1814', 
'\u1815', '\u1816', '\u1817', '\u1818', '\u1819', '\u1946', '\u1947', '\u1948', '\u1949', '\u194A', '\u194B', '\u194C', '\u194D', 
'\u194E', '\u194F', '\u19D0', '\u19D1', '\u19D2', '\u19D3', '\u19D4', '\u19D5', '\u19D6', '\u19D7', '\u19D8', '\u19D9', '\u1A80', 
'\u1A81', '\u1A82', '\u1A83', '\u1A84', '\u1A85', '\u1A86', '\u1A87', '\u1A88', '\u1A89', '\u1A90', '\u1A91', '\u1A92', '\u1A93', 
'\u1A94', '\u1A95', '\u1A96', '\u1A97', '\u1A98', '\u1A99', '\u1B50', '\u1B51', '\u1B52', '\u1B53', '\u1B54', '\u1B55', '\u1B56', 
'\u1B57', '\u1B58', '\u1B59', '\u1BB0', '\u1BB1', '\u1BB2', '\u1BB3', '\u1BB4', '\u1BB5', '\u1BB6', '\u1BB7', '\u1BB8', '\u1BB9', 
'\u1C40', '\u1C41', '\u1C42', '\u1C43', '\u1C44', '\u1C45', '\u1C46', '\u1C47', '\u1C48', '\u1C49', '\u1C50', '\u1C51', '\u1C52', 
'\u1C53', '\u1C54', '\u1C55', '\u1C56', '\u1C57', '\u1C58', '\u1C59', '\uA620', '\uA621', '\uA622', '\uA623', '\uA624', '\uA625', 
'\uA626', '\uA627', '\uA628', '\uA629', '\uA8D0', '\uA8D1', '\uA8D2', '\uA8D3', '\uA8D4', '\uA8D5', '\uA8D6', '\uA8D7', '\uA8D8', 
'\uA8D9', '\uA900', '\uA901', '\uA902', '\uA903', '\uA904', '\uA905', '\uA906', '\uA907', '\uA908', '\uA909', '\uA9D0', '\uA9D1', 
'\uA9D2', '\uA9D3', '\uA9D4', '\uA9D5', '\uA9D6', '\uA9D7', '\uA9D8', '\uA9D9', '\uAA50', '\uAA51', '\uAA52', '\uAA53', '\uAA54', 
'\uAA55', '\uAA56', '\uAA57', '\uAA58', '\uAA59', '\uABF0', '\uABF1', '\uABF2', '\uABF3', '\uABF4', '\uABF5', '\uABF6', '\uABF7', 
'\uABF8', '\uABF9', '\uFF10', '\uFF11', '\uFF12', '\uFF13', '\uFF14', '\uFF15', '\uFF16', '\uFF17', '\uFF18', '\uFF19', '\U000104A0', 
'\U000104A1', '\U000104A2', '\U000104A3', '\U000104A4', '\U000104A5', '\U000104A6', '\U000104A7', '\U000104A8', '\U000104A9', '\U00011066', 
'\U00011067', '\U00011068', '\U00011069', '\U0001106A', '\U0001106B', '\U0001106C', '\U0001106D', '\U0001106E', '\U0001106F', '\U0001D7CE', 
'\U0001D7CF', '\U0001D7D0', '\U0001D7D1', '\U0001D7D2', '\U0001D7D3', '\U0001D7D4', '\U0001D7D5', '\U0001D7D6', '\U0001D7D7', '\U0001D7D8', 
'\U0001D7D9', '\U0001D7DA', '\U0001D7DB', '\U0001D7DC', '\U0001D7DD', '\U0001D7DE', '\U0001D7DF', '\U0001D7E0', '\U0001D7E1', '\U0001D7E2', 
'\U0001D7E3', '\U0001D7E4', '\U0001D7E5', '\U0001D7E6', '\U0001D7E7', '\U0001D7E8', '\U0001D7E9', '\U0001D7EA', '\U0001D7EB', '\U0001D7EC', 
'\U0001D7ED', '\U0001D7EE', '\U0001D7EF', '\U0001D7F0', '\U0001D7F1', '\U0001D7F2', '\U0001D7F3', '\U0001D7F4', '\U0001D7F5', '\U0001D7F6', 
'\U0001D7F7', '\U0001D7F8', '\U0001D7F9', '\U0001D7FA', '\U0001D7FB', '\U0001D7FC', '\U0001D7FD', '\U0001D7FE', '\U0001D7FF'
];
            foreach(dchar Nd; unicodeNd)
                if(Nd == c)
                    return true;
                else if(Nd > c)
                    break;
            return false;
        }
    }
    public static bool isLetter( dchar c ){
        version(Tango){
            return tango.text.Unicode.isLetter(c);
        } else { // Phobos
            return !!std.uni.isAlpha(c);
        }
    }
    public static bool isLetterOrDigit( dchar c ){
        return isDigit(c) || isLetter(c);
    }
    public static bool isUnicodeIdentifierPart(char ch){
        implMissing( __FILE__, __LINE__);
        return false;
    }
    public static bool isUnicodeIdentifierStart(char ch){
        implMissing( __FILE__, __LINE__);
        return false;
    }
    public static bool isIdentifierIgnorable(char ch){
        implMissing( __FILE__, __LINE__);
        return false;
    }
    public static bool isJavaIdentifierPart(char ch){
        implMissing( __FILE__, __LINE__);
        return false;
    }

    this( char c ){
        // must be correct for container storage
        implMissing( __FILE__, __LINE__);
    }

    private static Class TYPE_;
    public static Class TYPE(){
        if( TYPE_ is null ){
            TYPE_ = Class.fromType!(char);
        }
        return TYPE_;
    }

    public dchar charValue(){
        implMissing( __FILE__, __LINE__);
        return ' ';
    }
}

bool CharacterIsDefined( dchar ch ){
    version(Tango){
    	return tango.text.UnicodeData.getUnicodeData(ch) !is null;
    } else { // Phobos
        return std.utf.isValidDchar(ch);
    }
}

dchar CharacterToLower( dchar c ){
    return Character.toLowerCase(c);
}
dchar CharacterToUpper( dchar c ){
    return Character.toUpperCase(c);
}
bool CharacterIsWhitespace( dchar c ){
    return Character.isWhitespace(c);
}
bool CharacterIsDigit( dchar c ){
    return Character.isDigit(c);
}
bool CharacterIsLetter( dchar c ){
    return Character.isLetter(c);
}


