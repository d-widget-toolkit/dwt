module java.lang.exceptions;

import java.lang.util;
import java.lang.String;

public import core.exception : ArrayIndexOutOfBoundsException = RangeError;

class PlatformException : Exception {
    this( String e = null ){
        super(e);
    }
}

class IllegalArgumentException : Exception {
    this( String e = null ){
        super(e);
    }
}

class IOException : Exception {
    this( String e = null ){
        super(e);
    }
}

class NoSuchElementException : Exception {
    this( String e = null ){
        super(e);
    }
}

class UnicodeException : Exception {
    this( String msg, int idx){
        super( "" );
    }
}

class InternalError : Exception {
    this( String file, long line, String e = null ){
        super(e);
    }
}

class ArithmeticException : Exception {
    this( String e = null ){
        super(e);
    }
}

class ClassCastException : Exception {
    this( String e = null ){
        super(e);
    }
}

class IllegalStateException : Exception {
    this( String e = null ){
        super(e);
    }
    this( Exception e ){
        super(e.toString);
    }
}

class NoSuchMethodException : Exception {
    this( String e = null){
        super(e);
    }
}

class IllegalAccessException : Exception {
    this( String e = null){
        super(e);
    }
}

class SecurityException : Exception {
    this( String e = null){
        super(e);
    }
}

class IndexOutOfBoundsException : Exception {
    this( String e = null){
        super(e);
    }
}

class StringIndexOutOfBoundsException : IndexOutOfBoundsException {
    this( String e = null){
        super(e);
    }
}

class InterruptedException : Exception {
    this( String e = null ){
        super(e);
    }
    this( Exception e ){
        super(e.toString);
    }
}

class NullPointerException : Exception {
    this( String e = null ){
        super(e);
    }
    this( Exception e ){
        super(e.toString);
    }
}

class NumberFormatException : IllegalArgumentException {
    this( String e ){
        super(e);
    }
    this( Exception e ){
        super(e.toString);
    }
    public String getMessage(){
        return msg;
    }
}

class RuntimeException : Exception {
    this( String file, long line, String msg = null){
        super( msg, file, cast(size_t) line );
    }
    this( String e = null){
        super(e);
    }
    this( Exception e ){
        super(e.toString);
        next = e;
    }
    public String getMessage(){
        return msg;
    }
    public Throwable getCause() {
        return next; // D2 has next of type Throwable
    }
}

class UnsupportedOperationException : RuntimeException {
    this( String e = null){
        super(e);
    }
    this( Exception e ){
        super(e.toString);
    }
}

/// Extension to the D Exception
String ExceptionGetLocalizedMessage( Exception e ){
    return e.msg;
}

void ExceptionPrintStackTrace( Exception e ){
    Throwable exception = e;
    while( exception !is null ){
        getDwtLogger().error( exception.file, exception.line, "Exception in {}({}): {}", exception.file, exception.line, exception.msg );
        if( exception.info !is null ){
            foreach( line, file; exception.info ){
                getDwtLogger().error( exception.file, exception.line, "trc {} {}", file, line );
            }
        }
        exception = exception.next;
    }
}

void PrintStackTrace( int deepth = 100, String prefix = "trc" ){
    auto e = new Exception( null );
    int idx = 0;
    const start = 3;
    foreach( line, file; e.info ){
        if( idx >= start && idx < start+deepth ) {
            getDwtLogger().trace( __FILE__, __LINE__, "{} {}: {}", prefix, file, line );
        }
        idx++;
    }
}
