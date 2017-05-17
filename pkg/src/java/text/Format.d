module java.text.Format;

import java.lang.all;
import java.text.FieldPosition;
import java.text.AttributedCharacterIterator;
import java.text.ParsePosition;

class Format {
    static class Field{
        protected this( String name ){
            implMissing(__FILE__, __LINE__);
        }
    }
    this(){
        implMissing(__FILE__, __LINE__);
    }
    Object clone(){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    String format(Object obj){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    abstract  StringBuffer format(Object obj, StringBuffer toAppendTo, FieldPosition pos);
    AttributedCharacterIterator formatToCharacterIterator(Object obj){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    Object parseObject(String source){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    abstract  Object parseObject(String source, ParsePosition pos);

}

