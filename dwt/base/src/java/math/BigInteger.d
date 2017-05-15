module java.math.BigInteger;

import java.lang.all;
import java.util.Random;
version(Tango){
    import tango.math.BigInt;
} else { // Phobos
    import std.bigint;
}

class BigInteger : Number {

    static const BigInteger ZERO;
    static const BigInteger ONE;
     
    private BigInt bi;

    static this(){
        ZERO = new BigInteger("0");
        ONE  = new BigInteger("1");
    }

    this(byte[] val){
        implMissing(__FILE__, __LINE__ );
    }
    this(int signum, byte[] magnitude){
        implMissing(__FILE__, __LINE__ );
    }
    this(int bitLength, int certainty, Random rnd){
        implMissing(__FILE__, __LINE__ );
    }
    this(int numBits, Random rnd){
        implMissing(__FILE__, __LINE__ );
    }
    this(String val){
        bi = BigInt( val );
    }
    this(String val, int radix){
        getDwtLogger.error( __FILE__, __LINE__, "this({}, {})", val, radix );
        if( radix is 10 ){
            bi = BigInt( val );
        }
        else if( radix is 16 ){
            bi = BigInt( "0x" ~ val );
        }
        else {
            implMissing(__FILE__, __LINE__ );
        }
    }
    private this( BigInt v ){
        bi = v;
    }
    private this( BigInteger v ){
        bi = v.bi;
    }
    private this( long v ){
        getDwtLogger.error( __FILE__, __LINE__, "this({})", v );
        bi = BigInt(v);
    }
    BigInteger abs(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger add(BigInteger val){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger and(BigInteger val){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger andNot(BigInteger val){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    int bitCount(){
        implMissing(__FILE__, __LINE__ );
        return 0;
    }
    int bitLength(){
        getDwtLogger.error( __FILE__, __LINE__, "bitLength()" );
        //implMissing(__FILE__, __LINE__ );
        return 0;
    }
    BigInteger clearBit(int n){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    int compareTo(BigInteger val){
        implMissing(__FILE__, __LINE__ );
        return 0;
    }
    int compareTo(Object o){
        implMissing(__FILE__, __LINE__ );
        return 0;
    }
    BigInteger divide(BigInteger val){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger[] divideAndRemainder(BigInteger val){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    override
    double doubleValue(){
        implMissing(__FILE__, __LINE__ );
        return 0;
    }
    bool equals(Object x){
        implMissing(__FILE__, __LINE__ );
        return 0;
    }
    BigInteger flipBit(int n){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    override
    float floatValue(){
        implMissing(__FILE__, __LINE__ );
        return 0;
    }
    BigInteger gcd(BigInteger val){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    int getLowestSetBit(){
        implMissing(__FILE__, __LINE__ );
        return 0;
    }
    int hashCode(){
        implMissing(__FILE__, __LINE__ );
        return 0;
    }
    override
    int intValue(){
        implMissing(__FILE__, __LINE__ );
        return 0;
    }
    bool isProbablePrime(int certainty){
        implMissing(__FILE__, __LINE__ );
        return 0;
    }
    override
    long longValue(){
        version(Tango){
            getDwtLogger.error( __FILE__, __LINE__, "{}", bi.toHex );
            long res = 0;
            auto txt = bi.toHex;
            bool sign = false;
            if( txt[0] is '-' ){
                sign = true;
                txt = txt[1 .. $];
            }
            int nibbles = 0;
            foreach( uint idx, char c; txt ){
                if( c is '_' ) continue;
                void addNibble( int v ){
                    res <<= 4;
                    res |= v;
                    nibbles++;
                }
                if( c >= '0' && c <= '9' ) {
                    addNibble( c - '0' );
                }
                else if( c >= 'a' && c <= 'f' ) {
                    addNibble( c - 'a' + 10 );
                }
                else if( c >= 'A' && c <= 'F' ) {
                    addNibble( c - 'A' + 10 );
                }
                else{
                    getDwtLogger.error( __FILE__, __LINE__, "unknown char {} @{}", c, idx );
                }
            }
            if( nibbles > 16 ){
                getDwtLogger.error( __FILE__, __LINE__, "too much nibbles {}", nibbles );
            }
            return res;
        } else { // Phobos
            return bi.toLong();
        }
    }
    BigInteger max(BigInteger val){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger min(BigInteger val){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger mod(BigInteger m){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger modInverse(BigInteger m){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger modPow(BigInteger exponent, BigInteger m){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger multiply(BigInteger val){
        auto res = new BigInteger(this);
        res.bi *= val.bi;
        return res;
    }
    BigInteger negate(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger not(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger or(BigInteger val){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger pow(int exponent){
        if( exponent < 0 ){
            throw new ArithmeticException("Negative exponent");
        }
        version(Tango){
            if( bi.isZero() ){
                return exponent is 0 ? ONE : this;
            }
        } else { // Phobos
            if( bi == 0 ){
                return exponent is 0 ? cast(BigInteger)ONE : this;
            }
        }
        auto a = bi;
        while(exponent>0){
            a *= bi;
            exponent--;
        }
        return new BigInteger(a);
    }
    static BigInteger probablePrime(int bitLength, Random rnd){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger remainder(BigInteger val){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger setBit(int n){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger shiftLeft(int n){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    BigInteger shiftRight(int n){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    int signum(){
        version(Tango) {
            if( bi.isZero() ) return 0;
            if( bi.isNegative() ) return -1;
        } else { // Phobos
            if( bi == 0 ) return 0;
            if( bi < 0 ) return -1;
        }
        return 1;
    }
    BigInteger subtract(BigInteger val){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    bool testBit(int n){
        implMissing(__FILE__, __LINE__ );
        return 0;
    }
    byte[] toByteArray(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    override
    String toString(){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    String toString(int radix){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
    static BigInteger valueOf(long val){
        auto res = new BigInteger(val);
        return res;
    }
    BigInteger xor(BigInteger val){
        implMissing(__FILE__, __LINE__ );
        return null;
    }
 
}
