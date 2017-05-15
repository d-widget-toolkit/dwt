module java.lang.Number;

import java.lang.util;

class Number {
    this(){
    }
    byte byteValue(){
        return cast(byte)intValue();
    }
    abstract  double doubleValue();
    abstract  float floatValue();
    abstract  int intValue();
    abstract  long longValue();
    short shortValue(){
        return cast(short)intValue();
    }
}

