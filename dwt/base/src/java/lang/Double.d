module java.lang.Double;

import java.lang.util;
import java.lang.exceptions;
import java.lang.Number;
import java.lang.Class;
import java.lang.String;

version(Tango){
    static import tango.text.convert.Float;
} else { // Phobos
    static import std.conv;
}

class Double : Number {
    public static double POSITIVE_INFINITY = double.infinity;
    public static double NEGATIVE_INFINITY = -double.infinity;
    public static double MAX_VALUE = double.max;
    public static double MIN_VALUE = double.min_normal;
    private double value = 0;
    this( double value ){
        super();
        this.value = value;
    }
    this( String str ){
        super();
        this.value = parseDouble(str);
    }
    public static String toString( double value ){
        return String_valueOf(value);
    }
    public static double parseDouble(String s){
        version(Tango){
            try{
                return tango.text.convert.Float.toFloat( s );
            }
            catch( IllegalArgumentException e ){
                throw new NumberFormatException( e );
            }
        } else { // Phobos
            try{
                return std.conv.to!(double)(s);
            }
            catch( std.conv.ConvException e ){
                throw new NumberFormatException( e );
            }
        }
    }

    private static Class TYPE_;
    public static Class TYPE(){
        if( TYPE_ is null ){
            TYPE_ = Class.fromType!(double);
        }
        return TYPE_;
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
}


