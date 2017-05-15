module java.math.BigDecimal;

import java.lang.all;
import java.math.BigInteger;

class BigDecimal : Number {
    static int ROUND_CEILING;
    static int ROUND_DOWN;
    static int ROUND_FLOOR;
    static int ROUND_HALF_DOWN;
    static int ROUND_HALF_EVEN;
    static int ROUND_HALF_UP;
    static int ROUND_UNNECESSARY;
    static int ROUND_UP;

    private BigInteger intVal;
    private int scale_;
    private int intCompact;
    private int precision;
    private static const MAX_BIGINT_BITS = 62;

    this(BigInteger val){
        implMissing(__FILE__, __LINE__);
    }
    this(BigInteger unscaledVal, int scale_){
        this.intVal = unscaledVal;
        this.scale_ = scale_;
    }
    this(double val){
        if (double.nan is val || double.infinity is val )
            throw new NumberFormatException("Infinite or NaN");

        // Translate the double into sign, exponent and significand, according
        // to the formulae in JLS, Section 20.10.22.
        long valBits = *cast(long*) & val;
        int sign = ((valBits >> 63)==0 ? 1 : -1);
        int exponent = cast(int) ((valBits >> 52) & 0x7ffL);
        long significand = (exponent==0 ? (valBits & ((1L<<52) - 1)) << 1
                            : (valBits & ((1L<<52) - 1)) | (1L<<52));
        exponent -= 1075;
        // At this point, val == sign * significand * 2**exponent.

        /*
         * Special case zero to supress nonterminating normalization
         * and bogus scale calculation.
         */
        if (significand == 0) {
            intVal = cast(BigInteger) BigInteger.ZERO;
            intCompact = 0;
            precision = 1;
            return;
        }

        // Normalize
        while((significand & 1) == 0) {    //  i.e., significand is even
            significand >>= 1;
            exponent++;
        }

        // Calculate intVal and scale
        intVal = BigInteger.valueOf(sign*significand);
        if (exponent < 0) {
            intVal = intVal.multiply(BigInteger.valueOf(5).pow(-exponent));
            scale_ = -exponent;
        } else if (exponent > 0) {
            intVal = intVal.multiply(BigInteger.valueOf(2).pow(exponent));
        }
        if (intVal.bitLength() <= MAX_BIGINT_BITS) {
            intCompact = cast(int)intVal.longValue();
        }
    }
    this(String val){
        implMissing(__FILE__, __LINE__);
    }
    BigDecimal abs(){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    BigDecimal add(BigDecimal val){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    int compareTo(BigDecimal val){
        implMissing(__FILE__, __LINE__);
        return 0;
    }
    int compareTo(Object o){
        implMissing(__FILE__, __LINE__);
        return 0;
    }
    BigDecimal divide(BigDecimal val, int roundingMode){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    BigDecimal divide(BigDecimal val, int scale_, int roundingMode){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    override
    double doubleValue(){
        implMissing(__FILE__, __LINE__);
        return 0;
    }
    bool equals(Object x){
        implMissing(__FILE__, __LINE__);
        return 0;
    }
    override
    float floatValue(){
        implMissing(__FILE__, __LINE__);
        return 0;
    }
    int hashCode(){
        implMissing(__FILE__, __LINE__);
        return 0;
    }
    override
    int intValue(){
        implMissing(__FILE__, __LINE__);
        return 0;
    }
    override
    long longValue(){
        implMissing(__FILE__, __LINE__);
        return 0;
    }
    BigDecimal max(BigDecimal val){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    BigDecimal min(BigDecimal val){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    BigDecimal movePointLeft(int n){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    BigDecimal movePointRight(int n){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    BigDecimal multiply(BigDecimal val){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    BigDecimal negate(){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    int scale(){
        implMissing(__FILE__, __LINE__);
        return this.scale_;
    }
    BigDecimal setScale(int scale_){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    BigDecimal setScale(int scale_, int roundingMode){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    int signum(){
        implMissing(__FILE__, __LINE__);
        return 0;
    }
    BigDecimal subtract(BigDecimal val){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    BigInteger toBigInteger(){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    override
    String toString(){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    BigInteger unscaledValue(){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    static BigDecimal valueOf(long val){
        implMissing(__FILE__, __LINE__);
        return null;
    }
    static BigDecimal valueOf(long unscaledVal, int scale_){
        implMissing(__FILE__, __LINE__);
        return null;
    }
}

