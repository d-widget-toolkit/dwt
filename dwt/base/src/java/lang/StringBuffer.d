module java.lang.StringBuffer;

import java.lang.util;
import java.lang.exceptions;
import java.lang.String;

version(Tango){
    static import tango.text.Text;
    static import tango.text.convert.Utf;
} else { // Phobos
    static import std.outbuffer;
    static import std.utf;
}

class StringBuffer : CharSequence {
    version(Tango){
        alias tango.text.Text.Text!(char) TBuf;
    } else { // Phobos
        alias std.outbuffer.OutBuffer TBuf;
    }
    private TBuf buffer;

    public this(){
        buffer = new TBuf();
    }

    public this( int cap ){
        version(Tango){
            buffer = new TBuf(cap);
        } else { // Phobos
            buffer = new TBuf();
            buffer.reserve(cap);
        }
    }

    public this( String content ){
        version(Tango){
            buffer = new TBuf( content );
        } else { // Phobos
            buffer = new TBuf();
            append(content);
        }
    }

    char charAt(int index){
        version(Tango){
            return buffer.slice()[ index ];
        } else { // Phobos
            return buffer.toBytes()[ index ];
        }
    }

    int length(){
        version(Tango){
            return buffer.length();
        } else { // Phobos
            return cast(int)/*64bit*/buffer.offset;
        }
    }

    CharSequence subSequence(int start, int end){
        return new StringCharSequence( substring(start, end) );
    }

    override
    String toString(){
        version(Tango){
            return buffer.slice().dup;
        } else { // Phobos
            return buffer.toString();
        }
    }

    StringBuffer append( in char[] s ){
        version(Tango){
            buffer.append( s );
        } else { // Phobos
            buffer.write( s );
        }
        return this;
    }

    StringBuffer append( in char[] s, int offset, int len ){
        return append( s[ offset .. offset+len ] );
    }

    StringBuffer append( StringBuffer other ){
        return append( other.slice() );
    }

    StringBuffer append( Object obj ){
        return append( obj.toString() );
    }

    StringBuffer append( char c ){
        version(Tango){
            char[1] src = c;
            return append( src );
        } else { // Phobos
            buffer.write(c);
            return this;
        }
    }

    StringBuffer append( wchar c ){
        version(Tango){
            wchar[1] src = c;
            char[1 * 2 + 3] trg; // or Tango will reallocate output to input.length * 2 + 3
            auto arr = tango.text.convert.Utf.toString( src, trg );
            return append( arr );
        } else { // Phobos
            char[4] trg;
            return append( trg[0 .. std.utf.encode(trg, c)] );
        }
    }

    StringBuffer append( dchar c ){
        version(Tango){
            dchar[1] src = c;
            char[1 * 2 + 4] trg; // or Tango will reallocate output to input.length * 2 + 4
            auto arr = tango.text.convert.Utf.toString( src, trg );
            return append( arr );
        } else { // Phobos
            char[4] trg;
            return append( trg[0 .. std.utf.encode(trg, c)] );
        }
    }

    StringBuffer append( bool i ){
        return append( String_valueOf(i) );
    }

    StringBuffer append( int i ){
        return append( String_valueOf(i) );
    }

    StringBuffer append( long i ){
        return append( String_valueOf(i) );
    }

    StringBuffer replace(int start, int end, in char[] str) {
        if(start < 0 || start > length() || start > end)
            throw new StringIndexOutOfBoundsException("start is negative, greater than length(), or greater than end");
        
        version(Tango){
            buffer.select(start, end-start);
            buffer.replace(str);
            buffer.select();
        } else { // Phobos
            if(end >= length()) {
                buffer.offset = start;
                return append(str);
            }
            int strEnd = start + cast(int)/*64bit*/str.length, incr = strEnd - end;
            
            if( incr > 0 ) {
                buffer.spread(end, incr);
            }
            else if( incr < 0 ) {
                auto bytes = buffer.toBytes();
                bytes[ start .. strEnd ] = cast(ubyte[])str;
                foreach (i, b; bytes[ end .. $ ]) {
                    bytes[strEnd + i] = bytes[end + i];
                }
                buffer.offset += incr;
            }
            buffer.toBytes()[ start .. strEnd ] = cast(ubyte[])str;
        }
        return this;
    }

    StringBuffer insert(int offset, in char[] str){
        return replace( offset, offset, str );
    }
    
    StringBuffer insert(int offset, int i){
        return insert( offset, String_valueOf(i) );
    }

    StringBuffer insert(int offset, StringBuffer other){
        return insert( offset, other.slice() );
    }

    void setLength( int newLength ){
        if(newLength < 0)
            throw new IndexOutOfBoundsException("the newLength argument is negative");
        
        version(Tango){
            buffer.truncate( newLength );
        } else { // Phobos
            immutable d = newLength - length();
            if( d > 0 )
                buffer.reserve(d);
            else
                buffer.offset += d;
        }
    }

    String substring( int start, int end ){
        if(start < 0 || end < 0 || end > length() || start > end)
            throw new StringIndexOutOfBoundsException("start or end are negative, if end is greater than length(), or if start is greater than end");
        
        version(Tango){
            return buffer.slice()[ start .. end ].dup;
        } else { // Phobos
            return (cast(char[]) buffer.toBytes()[ start .. end ]).idup;
        }
    }

    void delete_( int start, int end ){
        replace( start, end, "" );
    }
    
    TryConst!(char)[] slice(){
        version(Tango){
            return buffer.slice();
        } else { // Phobos
            return cast(TryConst!(char)[]) buffer.toBytes();
        }
    }
    
    void truncate( int start ){
        setLength( start );
    }
}


