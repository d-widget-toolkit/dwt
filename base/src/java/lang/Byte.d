module java.lang.Byte;

import java.lang.util;
import java.lang.exceptions;
import java.lang.Number;
import java.lang.Class;
import java.lang.String;

static import std.conv;

class Byte : Number {
    public static const byte MIN_VALUE = byte.min;
    public static const byte MAX_VALUE = byte.max;
    private byte value;

    public static byte parseByte( String s ){
        try{
            return std.conv.to!(byte)(s);
        }
        catch( std.conv.ConvException e ){
            throw new NumberFormatException( e );
        }
    }
    this( byte value ){
        super();
        this.value = value;
    }

    public static String toString( byte i ){
        return String_valueOf(i);
    }

    private static Class TYPE_;
    public static Class TYPE(){
        if( TYPE_ is null ){
            TYPE_ = Class.fromType!(byte);
        }
        return TYPE_;
    }

    override
    byte byteValue(){ return value; }
    override
    double doubleValue(){ return value; }
    override
    float floatValue(){ return value; }
    override
    int intValue(){ return value; }
    override
    long longValue(){ return value; }
    override
    short shortValue(){ return value; }
}
alias Byte ValueWrapperByte;


