module java.lang.StringBuffer;

import java.lang.util;
import java.lang.exceptions;
import java.lang.String;

static import std.outbuffer;
static import std.utf;

class StringBuffer : CharSequence {
    alias std.outbuffer.OutBuffer TBuf;
    private TBuf buffer;

    public this(){
        buffer = new TBuf();
    }

    public this( int cap ){
        buffer = new TBuf();
        buffer.reserve(cap);
    }

    public this( String content ){
        buffer = new TBuf();
        append(content);
    }

    char charAt(int index){
        return buffer.toBytes()[ index ];
    }

    int length(){
        return cast(int)/*64bit*/buffer.offset;
    }

    CharSequence subSequence(int start, int end){
        return new StringCharSequence( substring(start, end) );
    }

    override
    String toString(){
        return buffer.toString();
    }

    StringBuffer append( in char[] s ){
        buffer.write( s );
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
        buffer.write(c);
        return this;
    }

    StringBuffer append( wchar c ){
        char[4] trg;
        return append( trg[0 .. std.utf.encode(trg, c)] );
    }

    StringBuffer append( dchar c ){
        char[4] trg;
        return append( trg[0 .. std.utf.encode(trg, c)] );
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

        immutable d = newLength - length();
        if( d > 0 )
            buffer.reserve(d);
        else
            buffer.offset += d;
    }

    String substring( int start, int end ){
        if(start < 0 || end < 0 || end > length() || start > end)
            throw new StringIndexOutOfBoundsException("start or end are negative, if end is greater than length(), or if start is greater than end");

        return (cast(char[]) buffer.toBytes()[ start .. end ]).idup;
    }

    void delete_( int start, int end ){
        replace( start, end, "" );
    }
    
    TryConst!(char)[] slice(){
        return cast(TryConst!(char)[]) buffer.toBytes();
    }
    
    void truncate( int start ){
        setLength( start );
    }
}


