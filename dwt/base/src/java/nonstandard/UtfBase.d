/** 
 * Stuff for working with narrow strings.
 * This module shouldn't be imported directly.
 * Use SafeUtf/UnsafeUtf modules instead.
 * 
 * Authors: Denis Shelomovskij <verylonglogin.reg@gmail.com>
 */
module java.nonstandard.UtfBase;

package const UtfBaseText = `
# line 11 "java\nonstandard\UtfBase.d"
import java.lang.util;

version(Tango){
    static import tango.text.convert.Utf;
} else { // Phobos
    static import std.utf;
    static import std.conv;
}

///The Universal Character Set (UCS), defined by the International Standard ISO/IEC 10646
/*typedef*/alias ptrdiff_t UCSindex;
alias UCSindex UCSshift;

static if(UTFTypeCheck) {
    ///UTF-16 (16-bit Unicode Transformation Format)
    /*struct UTF16index {
        ptrdiff_t internalValue;
        alias internalValue val;
        
        private static UTF16index opCall(ptrdiff_t _val) {
            UTF16index t = { _val };
            return t;
        }
        
        void opAddAssign(in UTF16shift di) {
            val += di;
        }
        
        void opSubAssign(in UTF16shift di) {
            val -= di;
        }
        
mixin(constFuncs!("
        UTF16index opAdd(in UTF16shift di) {
            return UTF16index(val + di);
        }
        
        UTF16index opSub(in UTF16shift di) {
            return UTF16index(val - di);
        }
        
        version(Windows) {
            UTF16index opAdd(in ptrdiff_t di) {
                return UTF16index(val + di);
            }
            
            UTF16index opSub(in ptrdiff_t di) {
                return UTF16index(val - di);
            }
        }
        
        int opCmp(in UTF16index i2) {
            return cast(int)(val - i2.val);
        }
"));
    }*/
    alias ptrdiff_t UTF16index;
    alias ptrdiff_t UTF16shift;

    ///UTF-8 (UCS Transformation Format — 8-bit)
    //typedef ptrdiff_t UTF8index;
    //alias UTF8index UTF8shift;
    struct UTF8index {
        ptrdiff_t internalValue;
        alias internalValue val;
        
        private static UTF8index opCall(ptrdiff_t _val) {
            UTF8index t = { _val };
            return t;
        }
        
        void opAddAssign(in UTF8shift di) {
            val += di.val;
        }
        
        void opSubAssign(in UTF8shift di) {
            val -= di.val;
        }
        
mixin(constFuncs!("
        UTF8index opAdd(in UTF8shift di) {
            return UTF8index(val + di.val);
        }
        
        UTF8index opSub(in UTF8shift di) {
            return UTF8index(val - di.val);
        }
        
        UTF8shift opSub(in UTF8index di) {
            return UTF8shift(val - di.val);
        }
        
        int opCmp(in UTF8index i2) {
            return cast(int)(val - i2.val);
        }
"));
    }
    
    private UTF8index newUTF8index(ptrdiff_t i) {
        return UTF8index(i);
    }
    
    private ptrdiff_t val(T)(T i) {
        static if(is(T : UTF16index))
            return cast(ptrdiff_t) i;
        else
            return i.val;
    }
    
    private void dec(ref UTF8index i) {
        --i.val;
    }
    
    struct UTF8shift {
        ptrdiff_t internalValue;
        alias internalValue val;
        
        private static UTF8shift opCall(ptrdiff_t _val) {
            UTF8shift t = { _val };
            return t;
        }
        
        void opAddAssign(in UTF8shift di) {
            val += di.val;
        }
        
        void opSubAssign(in UTF8shift di) {
            val -= di.val;
        }
        
mixin(constFuncs!("
        UTF8shift opAdd(in UTF8shift di) {
            return UTF8shift(val + di.val);
        }
        
        UTF8shift opSub(in UTF8shift di) {
            return UTF8shift(val - di.val);
        }
        
        int opCmp(in UTF8shift di2) {
            return cast(int)(val - di2.val);
        }
"));
    }
    

    UTF8index asUTF8index(ptrdiff_t i) {
        return UTF8index(i);
    }

    UTF8shift asUTF8shift(int i) {
        return UTF8shift(i);
    }
} else {
    alias ptrdiff_t UTF16index;
    alias ptrdiff_t UTF16shift;
    
    alias ptrdiff_t UTF8index;
    alias ptrdiff_t UTF8shift;
    
    private ptrdiff_t val(ptrdiff_t i) {
        return i;
    }
    
    private void dec(ref UTF8index i) {
        --i;
    }
}

char charByteAt(in char[] s, in UTF8index i) {
    return s[val(i)];
}

UTF8index preFirstIndex(in char[] s) {
    return cast(UTF8index) -1;
}

UTF8index firstIndex(in char[] s) {
    return cast(UTF8index) 0;
}

UTF8index endIndex(in char[] s) {
    return cast(UTF8index) cast(int)/*64bit*/s.length;
}

UTF8index beforeEndIndex(in char[] s) {
    return s.offsetBefore(s.endIndex());
}


//These variables aren't in TLS so it can be used only for writing
mixin(gshared!("
private UCSindex UCSdummyShift;
private UTF8shift UTF8dummyShift;
private UTF16shift UTF16dummyShift;
"));

private const ubyte[256] p_UTF8stride =
[
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
    0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
    0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
    0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
    3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
    4,4,4,4,4,4,4,4,5,5,5,5,6,6,0xFF,0xFF,
];

private String toUTF8infoString(in char[] s, UTF8index i) {
    return Format("i = {}, s[i] = {}, s = {}", val(i), cast(ubyte)s.charByteAt(i), cast(ubyte[])s);
}

class UTF8Exception : Exception {
    this( String msg, in char[] s, UTF8index i){
        super( Format("{}:\n{}", msg, toUTF8infoString(s, i)));
    }
}

bool isUTF8sequenceStart( in char[] s, in UTF8index i ) {
    return p_UTF8stride[s.charByteAt(i)] != 0xFF;
}

void validateUTF8index( in char[] s, in UTF8index i ) {
    if(i != s.endIndex() && !s.isUTF8sequenceStart(i))
        throw new UTF8Exception("Not a start of an UTF-8 sequence", s, i);
}

UTF8shift UTF8strideAt( in char[] s, in UTF8index i ) {
    s.validateUTF8index(i);
    version(Tango) {
        return cast(UTF8shift)p_UTF8stride[s.charByteAt(i)];
    } else { // Phobos
        return cast(UTF8shift)std.utf.stride( s, val(i) );
    }
}

UTF16shift UTF16strideAt( in wchar[] s, in UTF16index i ) {
    //s.validateUTF16index(i);
    version(Tango) {
        uint u = s[val(i)];
        return cast(UTF16shift)(1 + (u >= 0xD800 && u <= 0xDBFF));
    } else { // Phobos
        return cast(UTF16shift)std.utf.stride( s, val(i) );
    }
}

UCSindex UCScount( in char[] s ){
    version(Tango){
        scope dchar[] buf = new dchar[]( s.length );
        uint ate;
        dchar[] res = tango.text.convert.Utf.toString32( s, buf, &ate );
        assert( ate is s.length );
        return res.length;
    } else { // Phobos
        return cast(UCSindex)/*64bit*/std.utf.count(s);
    }
}

UTF8shift toUTF8shift( in char[] s, in UTF8index i, in UCSshift dn ) {
    s.validateUTF8index(i);
    UTF8index j = i;
    UCSshift tdn = dn;
    if(tdn > 0) {
        do {
            j += s.UTF8strideAt(j);
            if(j > s.endIndex()) {
                throw new UTF8Exception(Format("toUTF8shift (dn = {}): No end of the UTF-8 sequence", dn), s, i);
            }
        } while(--tdn);
    } else if(tdn < 0) {
        do {
            if(!val(j)) {
                if(tdn == -1) {
                    j = s.preFirstIndex();
                    break;
                } else {
                    throw new UTF8Exception(Format("toUTF8shift (dn = {}): Can only go down to -1, not {}", dn, tdn), s, i);
                }
            }
            int l = 0;
            do {
                if(!val(j)) {
                    throw new UTF8Exception(Format("toUTF8shift (dn = {}): No start of the UTF-8 sequence before", dn), s, i);
                }
                ++l;
                dec(j);
            } while(!s.isUTF8sequenceStart(j));
            l -= val(s.UTF8strideAt(j));
            if(l > 0) {
                throw new UTF8Exception(Format("toUTF8shift (dn = {}): Overlong UTF-8 sequence before", dn), s, i);
            } else if(l < 0) {
                throw new UTF8Exception(Format("toUTF8shift (dn = {}): Too short UTF-8 sequence before", dn), s, i);
            }
        } while(++tdn);
    }
    return j - i;
}

UTF8index offsetBefore( in char[] s, in UTF8index i ) {
   return i + s.toUTF8shift(i, -1);
}

UTF8index offsetAfter( in char[] s, in UTF8index i ) {
   return i + s.toUTF8shift(i, 1);
}

/**
If the index is in a midle of an UTF-8 byte sequence, it
will return the position of the first byte of this sequence.
*/
void adjustUTF8index( in char[] s, ref UTF8index i ){
    if(i == s.endIndex() || s.isUTF8sequenceStart(i))
        return;
    
    int l = 0;
    alias i res;
    do {
        if(!val(res))
            throw new UTF8Exception("adjustUTF8index: No start of the UTF-8 sequence", s, i);
        ++l;
        dec(res);
    } while(!s.isUTF8sequenceStart(res));
    l -= val(s.UTF8strideAt(i));
    if(l > 0)
        throw new UTF8Exception("adjustUTF8index: Overlong UTF-8 sequence", s, i);
}

UTF8index takeIndexArg(String F = __FILE__, uint L = __LINE__)(String s, int i_arg, String location) {
    UTF8index res = cast(UTF8index) i_arg;
    if(i_arg > 0 && i_arg < s.length) {
        auto t = res;
        s.adjustUTF8index(res);
        if(t != res)
            getDwtLogger().warn(F, L, Format("Fixed invalid UTF-8 index at {}:\nnew i = {}, {}", location, val(res), toUTF8infoString(s, t)));
    }
    return res;
}

dchar dcharAt( in char[] s, in UTF8index i, out UTF8shift stride = UTF8dummyShift ) {
    s.validateUTF8index(i);
    auto str = s[val(i) .. $];
    version(Tango){
        dchar[1] buf;
        uint ate;
        dchar[] res = tango.text.convert.Utf.toString32( str, buf, &ate );
        assert( ate > 0 && res.length is 1 );
        stride = cast(UTF8shift)ate;
        return res[0];
    } else { // Phobos
        size_t ate = 0;
        dchar res = std.utf.decode(str, ate);
        stride = cast(UTF8shift)cast(int)/*64bit*/ate;
        return res;
    }
}

dchar dcharAt( in wchar[] s, in UTF16index i, out UTF16shift stride = UTF16dummyShift ) {
    //s.validateUTF16index(i);
    auto str = s[val(i) .. $];
    version(Tango){
        dchar[1] buf;
        uint ate;
        dchar[] res = tango.text.convert.Utf.toString32( str, buf, &ate );
        assert( ate > 0 && res.length is 1 );
        stride = cast(UTF16shift)ate;
        if( ate is 0 || res.length is 0 ){
            getDwtLogger().trace( __FILE__, __LINE__, "str.length={} str={:X2}", str.length, cast(ubyte[])str );
        }
        return res[0];
    } else { // Phobos
        size_t ate = 0;
        dchar res = std.utf.decode(str, ate);
        stride = cast(UTF16shift)ate;
        return res;
    }
}

dchar dcharBefore( in char[] s, in UTF8index i ) {
   return s.dcharAt(s.offsetBefore(i));
}

dchar dcharAfter( in char[] s, in UTF8index i ) {
    return s.dcharAt(i + s.toUTF8shift(i, 1));
}

///Get that String, that contains the next codepoint of a String.
String dcharAsStringAt( in char[] s, in UTF8index i, out UTF8shift stride = UTF8dummyShift ) {
    s.validateUTF8index(i);
    auto str = s[val(i) .. $];
    uint ate;
    version(Tango){
        dchar[1] buf;
        dchar[] res = tango.text.convert.Utf.toString32( str, buf, &ate );
    } else { // Phobos
        ate = std.utf.stride( str, 0 );
    }
    stride = cast(UTF8shift)ate;
    return str[ 0 .. ate ]._idup();
}

`;
