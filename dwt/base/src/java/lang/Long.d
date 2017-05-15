module java.lang.Long;

import java.lang.util;
import java.lang.exceptions;
import java.lang.Number;
import java.lang.Character;
import java.lang.Class;
import java.lang.String;

version(Tango){
    static import tango.text.convert.Integer;
} else { // Phobos
    static import std.conv;
    static import std.string;
}

class Long : Number {
    public static const long MIN_VALUE = long.min;
    public static const long MAX_VALUE = long.max;
    private long value;
    this( long value ){
        super();
        this.value = value;
    }
    this( String str ){
        super();
        this.value = parseLong(str);
    }
    override
    public byte byteValue(){
        return cast(byte)value;
    }

    override
    public short shortValue(){
        return cast(short)value;
    }

    override
    public int intValue(){
        return cast(int)value;
    }

    override
    public long longValue(){
        return value;
    }

    override
    public float floatValue(){
        return cast(float)value;
    }

    override
    public double doubleValue(){
        return cast(double)value;
    }
    public static long parseLong(String s){
        return parseLong( s, 10 );
    }
    public static long parseLong(String s, int radix){
        if(radix < Character.MIN_RADIX || radix > Character.MAX_RADIX)
            throw new NumberFormatException("The radix is out of range");
        version(Tango){
            try{
                return tango.text.convert.Integer.toLong( s, radix );
            }
            catch( IllegalArgumentException e ){
                throw new NumberFormatException( e );
            }
        } else { // Phobos
            try{
                immutable res = std.conv.parse!(long)( s, radix );
                if(s.length)
                    throw new NumberFormatException("String has invalid characters: " ~ s);
                return res;
            }
            catch( std.conv.ConvException e ){
                throw new NumberFormatException( e );
            }
        }
    }
    public static String toString( long i ){
        return String_valueOf(i);
    }
    private static Class TYPE_;
    public static Class TYPE(){
        if( TYPE_ is null ){
            TYPE_ = Class.fromType!(long);
        }
        return TYPE_;
    }

}
alias Long ValueWrapperLong;

