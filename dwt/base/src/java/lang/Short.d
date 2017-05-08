module java.lang.Short;

import java.lang.util;
import java.lang.exceptions;
import java.lang.Number;
import java.lang.Class;
import java.lang.String;

version(Tango){
    static import tango.text.convert.Integer;
} else { // Phobos
    static import std.conv;
}
class Short : Number {
    public static const short MIN_VALUE = short.min;
    public static const short MAX_VALUE = short.max;
    private short value;
    public static short parseShort( String s ){
        version(Tango){
            try{
                int res = tango.text.convert.Integer.parse( s );
                if( res < short.min || res > short.max ){
                    throw new NumberFormatException( "out of range" );
                }
                return res;
            }
            catch( IllegalArgumentException e ){
                throw new NumberFormatException( e );
            }
        } else { // Phobos
            try{
                return std.conv.to!(short)(s);
            }
            catch( std.conv.ConvException e ){
                throw new NumberFormatException( e );
            }
        }
    }
    this( short value ){
        super();
        this.value = value;
    }

    public static String toString( short i ){
        return String_valueOf(i);
    }

    private static Class TYPE_;
    public static Class TYPE(){
        if( TYPE_ is null ){
            TYPE_ = Class.fromType!(short);
        }
        return TYPE_;
    }

    override
    byte byteValue(){ return cast(byte)value; }
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
alias Short ValueWrapperShort;

