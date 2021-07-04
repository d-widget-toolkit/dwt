module java.lang.exceptions;

import java.lang.util;
import java.lang.String;

public import core.exception : ArrayIndexOutOfBoundsException = RangeError;

/**
 * Thrown when an application tries to load in a class through its string
 * name using:
 *
 * $(UL
 *   $(LI The `forName` method in class `Class`)
 *   $(LI The `findSystemClass` method in class `ClassLoader`)
 *   $(LI The `loadClass` method in class `ClassLoader`)
 * )
 *
 * but not definition for the class with the specified name could be found.
 */
class ClassNotFoundException : Exception {
    /**
     * Constructs a new `ClassNotFoundException` with no detail provided.
     */
    public this() {
        super("null");
    }

    /**
     * Constructs a new `ClassNotFoundException` with the provided detail.
     *
     * Params:
     *   s = The detail message.
     */
    public this(String s) {
        super(s);
    }

    /**
     * Constructs a new `ClassNotFoundException` with the provided detail and
     * optional exception that was raised while loading the class.
     *
     * Params:
     *  s = The detail message.
     *  ex = The exception that was raised while loading the class.
     */
    public this(String s, Exception ex) {
        super(s, ex);
    }
}

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
