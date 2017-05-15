module java.text.NumberFormat;

import java.lang.all;
import java.text.Format;
import java.text.FieldPosition;
import java.text.ParsePosition;
import java.util.Locale;
import java.util.Currency;

class NumberFormat : java.text.Format.Format {
    static int FRACTION_FIELD;
    static int INTEGER_FIELD;

    static class Field : java.text.Format.Format.Field {
        static NumberFormat.Field CURRENCY;
        static NumberFormat.Field DECIMAL_SEPARATOR;
        static NumberFormat.Field EXPONENT;
        static NumberFormat.Field EXPONENT_SIGN;
        static NumberFormat.Field EXPONENT_SYMBOL;
        static NumberFormat.Field FRACTION;
        static NumberFormat.Field GROUPING_SEPARATOR;
        static NumberFormat.Field INTEGER;
        static NumberFormat.Field PERCENT;
        static NumberFormat.Field PERMILLE;
        static NumberFormat.Field SIGN;
        protected this(String name){
            implMissing(__FILE__, __LINE__);
            super(name);
        }
        protected  Object readResolve(){
            implMissing(__FILE__, __LINE__);
            return null;
        }

    }

    this(){
        implMissing(__FILE__, __LINE__);
    }

    override
    Object clone(){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    bool equals(Object obj){
        implMissing(__FILE__, __LINE__);
        return false;
    }

    String format(double number){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    abstract  StringBuffer format(double number, StringBuffer toAppendTo, FieldPosition pos){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    String format(long number){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    abstract  StringBuffer format(long number, StringBuffer toAppendTo, FieldPosition pos){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    override
    StringBuffer format(Object number, StringBuffer toAppendTo, FieldPosition pos){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    static Locale[] getAvailableLocales(){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    Currency getCurrency(){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    static NumberFormat getCurrencyInstance(){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    static NumberFormat getCurrencyInstance(Locale inLocale){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    static NumberFormat getInstance(){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    static NumberFormat getInstance(Locale inLocale){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    static NumberFormat getIntegerInstance(){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    static NumberFormat getIntegerInstance(Locale inLocale){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    int getMaximumFractionDigits(){
        implMissing(__FILE__, __LINE__);
        return 0;
    }

    int getMaximumIntegerDigits(){
        implMissing(__FILE__, __LINE__);
        return 0;
    }

    int getMinimumFractionDigits(){
        implMissing(__FILE__, __LINE__);
        return 0;
    }

    int getMinimumIntegerDigits(){
        implMissing(__FILE__, __LINE__);
        return 0;
    }

    static NumberFormat getNumberInstance(){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    static NumberFormat getNumberInstance(Locale inLocale){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    static NumberFormat getPercentInstance(){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    static NumberFormat getPercentInstance(Locale inLocale){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    int hashCode(){
        implMissing(__FILE__, __LINE__);
        return 0;
    }

    bool isGroupingUsed(){
        implMissing(__FILE__, __LINE__);
        return false;
    }

    bool isParseIntegerOnly(){
        implMissing(__FILE__, __LINE__);
        return false;
    }

    Number parse(String source){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    abstract  Number parse(String source, ParsePosition parsePosition){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    override
    Object parseObject(String source, ParsePosition pos){
        implMissing(__FILE__, __LINE__);
        return null;
    }

    void setCurrency(Currency currency){
        implMissing(__FILE__, __LINE__);
    }

    void setGroupingUsed(bool newValue){
        implMissing(__FILE__, __LINE__);
    }

    void setMaximumFractionDigits(int newValue){
        implMissing(__FILE__, __LINE__);
    }

    void setMaximumIntegerDigits(int newValue){
        implMissing(__FILE__, __LINE__);
    }

    void setMinimumFractionDigits(int newValue){
        implMissing(__FILE__, __LINE__);
    }

    void setMinimumIntegerDigits(int newValue){
        implMissing(__FILE__, __LINE__);
    }

    void setParseIntegerOnly(bool value){
        implMissing(__FILE__, __LINE__);
    }

}

