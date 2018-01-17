module java.lang.Float;

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

class Float : Number {

    public static float POSITIVE_INFINITY = float.infinity;
    public static float NEGATIVE_INFINITY = -float.infinity;
    public static float NaN = float.nan;
    public static float MAX_VALUE = 3.4028235e+38f;
    public static float MIN_VALUE = float.min_normal; //1.4e-45f
    public static int SIZE = 32;
    private float value = 0;

    this( float value ){
        super();
        this.value = value;
    }
    this( String str ){
        super();
        this.value = parseFloat(str);
    }
    public static String toString( float value ){
        return String_valueOf(value);
    }
    public static float parseFloat( String s ){
        version(Tango){
            try{
                return tango.text.convert.Float.toFloat( s );
            }
            catch( IllegalArgumentException e ){
                throw new NumberFormatException( e );
            }
        } else { // Phobos
            try{
                return std.conv.to!(float)(s);
            }
            catch( std.conv.ConvException e ){
                throw new NumberFormatException( e );
            }
        }
    }

    private static Class TYPE_;
    public static Class TYPE(){
        if( TYPE_ is null ){
            TYPE_ = Class.fromType!(float);
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


