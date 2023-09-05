module java.lang.String;

import java.lang.util;
import java.lang.interfaces;
import java.lang.exceptions;
import java.lang.Class;

static import std.array;
static import std.string;
static import std.conv;
static import std.exception;

alias TryImmutable!(char)[]  String;
alias TryImmutable!(wchar)[] String16;

String new_String( String cont, int offset, int len ){
    return _idup(cont[ offset .. offset+len ]);
}

String new_String( String cont ){
    return _idup(cont);
}

String String_valueOf( bool v ){
    return v ? "true" : "false";
}

String String_valueOf( byte v ){
    return String_valueOf( cast(long) v );
}

String String_valueOf( ubyte v ){
    return String_valueOf( cast(uint) v );
}

String String_valueOf( short v ){
    return String_valueOf( cast(long) v );
}

String String_valueOf( int v ){
    return String_valueOf( cast(long) v );
}

String String_valueOf( uint v ){
    return std.conv.to!(String)(v);
}

String String_valueOf( long v ){
    return std.conv.to!(String)(v);
}

String String_valueOf( float v ){
    return std.conv.to!(String)(v);
}

String String_valueOf( double v ){
    return std.conv.to!(String)(v);
}

String String_valueOf( dchar v ){
    return std.conv.to!(String)(v);
}

String dcharToString( dchar v ){
    return String_valueOf(v);
}

String String_valueOf( char[] v ){
    return _idup(v);
}

String String_valueOf( char[] v, int offset, int len ){
    return _idup(v[ offset .. offset+len ]);
}

String String_valueOf( Object v ){
    return v is null ? "null" : v.toString();
}

String String_valueOf( in wchar[] wstr ){
    return std.conv.to!(String)(wstr);
}

int length( String str ){
    return cast(int)/*64bit*/str.length;
}

/// Extension to String
public String toUpperCase( String str ){
    return cast(String) std.string.toUpper( str );
}

/// Extension to String
public String replaceFirst( String str, String regex, String replacement ){
    implMissing(__FILE__,__LINE__);
    return null;
}

/// Extension to String
public int indexOf( in char[] str, char searched ){
    return cast(int)/*64bit*/std.string.indexOf(str, searched);
}

/// Extension to String
public int indexOf( in char[] str, char searched, int fromIndex ){
    if(fromIndex >= str.length)
        return -1;
    int res = cast(int)/*64bit*/std.string.indexOf(str[fromIndex .. $], searched);
    if (res !is -1) res += fromIndex;
    return res;
}

/// Extension to String
public int indexOf(in char[] str, in char[] sub){
    return indexOf( str, sub, 0 );
}

/// Extension to String
public int indexOf(in char[] str, in char[] sub, int fromIndex){
    if(fromIndex + sub.length > str.length)
        return -1;
    if(!sub.length)
        return fromIndex;
    int res = cast(int)/*64bit*/std.string.indexOf(str[fromIndex .. $], sub);
    if (res !is -1) res += fromIndex;
    return res;
}

/// Extension to String
public int lastIndexOf(in char[] str, char ch){
    return lastIndexOf( str, ch, cast(int)/*64bit*/str.length - 1 );
}

/// Extension to String
public int lastIndexOf(in char[] str, char ch, int fromIndex){
    if(fromIndex >= str.length)
        fromIndex = cast(int)/*64bit*/str.length - 1;
    return cast(int)/*64bit*/std.string.lastIndexOf(str[0 .. fromIndex + 1], ch);
}

/// Extension to String
public int lastIndexOf(in char[] str, in char[] sub ){
    return lastIndexOf( str, sub, cast(int)/*64bit*/(str.length - sub.length) );
}

/// Extension to String
public int lastIndexOf(in char[] str, in char[] sub, int fromIndex){
    int max = cast(int)str.length - cast(int)sub.length;
    if(fromIndex > max)
        fromIndex = max;
    if(!sub.length)
        return fromIndex;
    size_t to = fromIndex + sub.length;
    return cast(int)/*64bit*/std.string.lastIndexOf(str[0 .. to < $ ? to : $], sub);
}

unittest {
    sizediff_t i;

    i = lastIndexOf("", 'a');
    assert(i == -1);
    i = lastIndexOf("def", 'a');
    assert(i == -1);
    i = lastIndexOf("abba", 'a');
    assert(i == 3);
    i = lastIndexOf("abba", 'a', 0);
    assert(i == 0);
    i = lastIndexOf("abba", 'a', 1);
    assert(i == 0);
    i = lastIndexOf("abba", 'a', 2);
    assert(i == 0);
    i = lastIndexOf("abba", 'a', 3);
    assert(i == 3);
    i = lastIndexOf("abba", 'a', 4);
    assert(i == 3);
    i = lastIndexOf("abba", 'a', 10);
    assert(i == 3);
    i = lastIndexOf("def", 'f');
    assert(i == 2);

    i = lastIndexOf("", "a");
    assert(i == -1);
    i = lastIndexOf("", "");
    assert(i == 0);
    i = lastIndexOf("abcdefcdef", "c");
    assert(i == 6);
    i = lastIndexOf("abcdefcdef", "cd");
    assert(i == 6);
    i = lastIndexOf("abcdefcdef", "cd", 5);
    assert(i == 2);
    i = lastIndexOf("abcdefcdef", "cd", 6);
    assert(i == 6);
    i = lastIndexOf("abcdefcdef", "cd", 7);
    assert(i == 6);
    i = lastIndexOf("abcdefcdef", "cd", 10);
    assert(i == 6);
    i = lastIndexOf("abcdefcdef", "x");
    assert(i == -1);
    i = lastIndexOf("abcdefcdef", "xy");
    assert(i == -1);
    i = lastIndexOf("abcdefcdef", "");
    assert(i == 10);
    i = lastIndexOf("abcdefcdef", "", 9);
    assert(i == 9);
    i = lastIndexOf("abcabc", "abc");
    assert(i == 3);
    i = lastIndexOf("abcabc", "abc", 2);
    assert(i == 0);
    i = lastIndexOf("abcabc", "abc", 3);
    assert(i == 3);
    i = lastIndexOf("abcabc", "abc", 4);
    assert(i == 3);



    i = indexOf("", 'a');
    assert(i == -1);
    i = indexOf("def", 'a');
    assert(i == -1);
    i = indexOf("abba", 'a');
    assert(i == 0);
    i = indexOf("abba", 'a', 0);
    assert(i == 0);
    i = indexOf("abba", 'a', 1);
    assert(i == 3);
    i = indexOf("abba", 'a', 2);
    assert(i == 3);
    i = indexOf("abba", 'a', 3);
    assert(i == 3);
    i = indexOf("abba", 'a', 4);
    assert(i == -1);
    i = indexOf("abba", 'a', 10);
    assert(i == -1);
    i = indexOf("def", 'f');
    assert(i == 2);

    i = indexOf("", "a");
    assert(i == -1);
    i = indexOf("", "");
    assert(i == 0);
    i = indexOf("abcdefcdef", "c");
    assert(i == 2);
    i = indexOf("abcdefcdef", "cd");
    assert(i == 2);
    i = indexOf("abcdefcdef", "cd", 4);
    assert(i == 6);
    i = indexOf("abcdefcdef", "cd", 5);
    assert(i == 6);
    i = indexOf("abcdefcdef", "cd", 6);
    assert(i == 6);
    i = indexOf("abcdefcdef", "cd", 7);
    assert(i == -1);
    i = indexOf("abcdefcdef", "cd", 10);
    assert(i == -1);
    i = indexOf("abcdefcdef", "x");
    assert(i == -1);
    i = indexOf("abcdefcdef", "xy");
    assert(i == -1);
    i = indexOf("abcdefcdef", "");
    assert(i == 0);
    i = indexOf("abcabc", "abc");
    assert(i == 0);
    i = indexOf("abcabc", "abc", 2);
    assert(i == 3);
    i = indexOf("abcabc", "abc", 3);
    assert(i == 3);
    i = indexOf("abcabc", "abc", 4);
    assert(i == -1);
}

/// Extension to String
public String replaceAll( String str, String regex, String replacement ){
    implMissing(__FILE__,__LINE__);
    return null;
}

/// Extension to String
public String replace( String str, char from, char to ){
    char[1] f = from, t = to;
    auto res = std.array.replace(str, f[], t[]);
    return std.exception.assumeUnique(res);
}

/// Extension to String
public String substring( String str, int start ){
    return _idup(str[ start .. $ ]);
}

/// Extension to String
public String substring( String str, int start, int end ){
    return _idup(str[ start .. end ]);
}

/// Extension to String
public wchar[] substring( String16 str, int start ){
    return str[ start .. $ ].dup;
}

/// Extension to String
public wchar[] substring( String16 str, int start, int end ){
    return str[ start .. end ].dup;
}

/// Extension to String
public char charAt( String str, int pos ){
    return str[ pos ];
}

/// Extension to String
public void getChars( String src, int srcBegin, int srcEnd, char[] dst, int dstBegin){
    dst[ dstBegin .. dstBegin + srcEnd - srcBegin ] = src[ srcBegin .. srcEnd ];
}

/// Extension to String
public String16 toWCharArray( in char[] str ){
    return std.conv.to!(String16)(str);
}

/// Extension to String
public char[] toCharArray( String str ){
    return cast(char[])str;
}

/// Extension to String
public bool endsWith( String src, String pattern ){
    if( src.length < pattern.length ){
        return false;
    }
    return src[ $-pattern.length .. $ ] == pattern;
}

/// Extension to String
public bool equals( in char[] src, in char[] other ){
    return src == other;
}

/// Extension to String
public bool equalsIgnoreCase( in char[] src, in char[] other ){
    return std.string.icmp(src, other) == 0;
}

/// Extension to String
public int compareToIgnoreCase( in char[] src, in char[] other ){
    return std.string.icmp(src, other);
}

/// Extension to String
public int compareTo( in char[] src, in char[] other ){
    return std.string.cmp(src, other);
}

/// Extension to String
public bool startsWith( String src, String pattern ){
    if( src.length < pattern.length ){
        return false;
    }
    return src[ 0 .. pattern.length ] == pattern;
}

/// Extension to String
public String toLowerCase( String src ){
    return cast(String) std.string.toLower(src);
}

/// Extension to String
mixin(`@safe nothrow public hash_t toHash( String src ){
    // http://docs.oracle.com/javase/7/docs/api/java/lang/String.html#hashCode%28%29
    hash_t hash = 0;
    foreach( i, c; src ){
        hash += c * 31 ^ (src.length - 1 - i);
    }
    return hash;
}`);

public alias toHash String_toHash;

/// Extension to String
public String trim( String str ){
    return std.string.strip( str.idup );
}

/// Extension to String
public String intern( String str ){
    return _idup(str);
}

static import core.stdc.string;

public char* toStringzValidPtr( in char[] s ) {
    auto copy = new char[s.length + 1];
    copy[0..s.length] = s;
    copy[s.length] = 0;
    return copy.ptr;
}

public char* toStringz( in char[] s ) {
    return s is null ? null : toStringzValidPtr(s);
}

public char[] fromStringz( in char* s ){
    return s ? s[0 .. core.stdc.string.strlen(s)].dup : cast(char[])null;
}
/*public string fromStringz( in char* s ){
    return std.conv.to!(string)(s);
}*/

private size_t w_strlen(in wchar* s) {
    size_t res = 0;
    while(*(s+res))
        ++res;
    return res;
}

public wchar* toString16z( in wchar[] s ){
    if(s is null)
        return null;
    auto copy = new wchar[s.length + 1];
    copy[0..s.length] = s;
    copy[s.length] = 0;
    return copy.ptr;
}

//Copy of std.conv.toImpl(T, S)(S s) for C-style strings
public wstring fromString16z( in wchar* s ){
    return s ? s[0 .. w_strlen(s)].idup : cast(wstring)null;
}

static String toHex(uint i){
    return std.conv.to!(String)(i, 16);
}

/++
+ String in java is implementing the interface CharSequence
+/
class StringCharSequence : CharSequence {
    private String str;
    this( String str ){
        this.str = str;
    }
    char charAt(int index){
        return str[index];
    }
    int length(){
        return cast(int)/*64bit*/str.length;
    }
    CharSequence subSequence(int start, int end){
        return new StringCharSequence( str[ start .. end ]);
    }
    override
    String toString(){
        return str;
    }
}

class StringCls {
    private static Class TYPE_;
    public static Class TYPE(){
        if( TYPE_ is null ){
            TYPE_ = Class.fromType!(char[]);
        }
        return TYPE_;
    }

}
