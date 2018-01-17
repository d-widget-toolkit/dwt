module java.lang.Integer;

import java.lang.util;
import java.lang.exceptions;
import java.lang.Number;
import java.lang.Class;
import java.lang.Character;
import java.lang.String;

version(Tango){
    static import tango.text.convert.Integer;
} else { // Phobos
    static import std.conv;
    static import std.string;
}


class Integer : Number {

    public static const int MIN_VALUE = 0x80000000;
    public static const int MAX_VALUE = 0x7fffffff;
    public static const int SIZE = 32;
    private int value;

    public this ( void* value ){
        super();
        this.value = cast(int)value;
    }
    public this ( int value ){
        super();
        this.value = value;
    }

    public this ( String s ){
        super();
        this.value = parseInt(s);
    }

    public static String toString( int i, int radix ){
        if(radix < Character.MIN_RADIX || radix > Character.MAX_RADIX)
            radix = 10;
        version(Tango){
            switch( radix ){
                case 10:
                    return tango.text.convert.Integer.toString(i);
                case 16:
                    return tango.text.convert.Integer.toString(i, "x" );
                case 2:
                    return tango.text.convert.Integer.toString(i, "b" );
                case 8:
                    return tango.text.convert.Integer.toString(i, "o" );
                default:
                    implMissingInTango( __FILE__, __LINE__ );
                    return null;
            }
        } else { // Phobos
            return std.conv.to!(String)(i, radix);
        }
    }

    public static String toHexString( int i ){
        return toString(i, 16);
    }

    public static String toOctalString( int i ){
        return toString(i, 8);
    }

    public static String toBinaryString( int i ){
        return toString(i, 2);
    }

    public static String toString( int i ){
        return String_valueOf(i);
    }

    public static int parseInt( String s, int radix ){
        if(radix < Character.MIN_RADIX || radix > Character.MAX_RADIX)
            throw new NumberFormatException("The radix is out of range");
        version(Tango){
            try{
                return tango.text.convert.Integer.toInt( s, radix );
            }
            catch( IllegalArgumentException e ){
                throw new NumberFormatException( e );
            }
        } else { // Phobos
            try{
                immutable res = std.conv.parse!(int)( s, radix );
                if(s.length)
                    throw new NumberFormatException("String has invalid characters: " ~ s);
                return res;
            }
            catch( std.conv.ConvException e ){
                throw new NumberFormatException( e );
            }
        }
    }

    public static int parseInt( String s ){
        return parseInt( s, 10 );
    }

    public static Integer valueOf( String s, int radix ){
        return new Integer( parseInt( s, radix ));
    }

    public static Integer valueOf( String s ){
        return valueOf(parseInt(s));
    }

    public static Integer valueOf( int i ){
        return new Integer(i);
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
        return value;
    }

    override
    public long longValue(){
        return cast(long)value;
    }

    override
    public float floatValue(){
        return cast(float)value;
    }

    override
    public double doubleValue(){
        return cast(double)value;
    }

    public override  hash_t toHash(){
        return value;
    }

    public override String toString(){
        return toString(value);
    }

    private static Class TYPE_;
    public static Class TYPE(){
        if( TYPE_ is null ){
            TYPE_ = Class.fromType!(int);
        }
        return TYPE_;
    }

}
alias Integer ValueWrapperInt;

