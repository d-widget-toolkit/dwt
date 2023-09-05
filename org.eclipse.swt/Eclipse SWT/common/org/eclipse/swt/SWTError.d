/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *******************************************************************************/
module org.eclipse.swt.SWTError;

import java.lang.all;

import org.eclipse.swt.SWT;


/**
 * This error is thrown whenever an unrecoverable error
 * occurs internally in SWT. The message text and error code
 * provide a further description of the problem. The exception
 * has a <code>throwable</code> field which holds the underlying
 * throwable that caused the problem (if this information is
 * available (i.e. it may be null)).
 * <p>
 * SWTErrors are thrown when something fails internally which
 * either leaves SWT in an unknown state (eg. the o/s call to
 * remove an item from a list returns an error code) or when SWT
 * is left in a known-to-be-unrecoverable state (eg. it runs out
 * of callback resources). SWTErrors should not occur in typical
 * programs, although "high reliability" applications should
 * still catch them.
 * </p><p>
 * This class also provides support methods used by SWT to match
 * error codes to the appropriate exception class (SWTError,
 * SWTException, or IllegalArgumentException) and to provide
 * human readable strings for SWT error codes.
 * </p>
 *
 * @see SWTException
 * @see SWT#error(int)
 * @see <a href="http://www.eclipse.org/swt/">Sample code and further information</a>
 */

public class SWTError : PlatformException {
    /**
     * The SWT error code, one of SWT.ERROR_*.
     */
    public int code;

    /**
     * The underlying throwable that caused the problem,
     * or null if this information is not available.
     */
    public Throwable throwable( Throwable e ){
        this.next = e;
        return this.next;
    }
    public Throwable throwable(){
        return this.next;
    }

    //static const long serialVersionUID = 3833467327105808433L;

/**
 * Constructs a new instance of this class with its
 * stack trace filled in. The error code is set to an
 * unspecified value.
 */
public this () {
    this (SWT.ERROR_UNSPECIFIED);
}

/**
 * Constructs a new instance of this class with its
 * stack trace and message filled in. The error code is
 * set to an unspecified value.  Specifying <code>null</code>
 * as the message is equivalent to specifying an empty string.
 *
 * @param message the detail message for the exception
 */
public this (String message) {
    this (SWT.ERROR_UNSPECIFIED, message);
}

/**
 * Constructs a new instance of this class with its
 * stack trace and error code filled in.
 *
 * @param code the SWT error code
 */
public this (int code) {
    this (code, SWT.findErrorText (code));
}

/**
 * Constructs a new instance of this class with its
 * stack trace, error code and message filled in.
 * Specifying <code>null</code> as the message is
 * equivalent to specifying an empty string.
 *
 * @param code the SWT error code
 * @param message the detail message for the exception
 */
public this (int code, String message) {
    super (message);
    this.code = code;
}

/**
 * Returns the underlying throwable that caused the problem,
 * or null if this information is not available.
 * <p>
 * NOTE: This method overrides Throwable.getCause() that was
 * added to JDK1.4. It is necessary to override this method
 * in order for inherited printStackTrace() methods to work.
 * </p>
 * @return the underlying throwable
 *
 * @since 3.1
 */
public Throwable getCause() {
    return throwable;
}

/**
 *  Returns the string describing this SWTError object.
 *  <p>
 *  It is combined with the message string of the Throwable
 *  which caused this SWTError (if this information is available).
 *  </p>
 *  @return the error message string of this SWTError object
 */
public String getMessage () {
    if (throwable is null)
        return super.toString();
    return super.toString () ~ " (" ~ throwable.toString () ~ ")"; //$NON-NLS-1$ //$NON-NLS-2$
}

/**
 * Outputs a printable representation of this error's
 * stack trace on the standard error stream.
 * <p>
 * Note: printStackTrace(PrintStream) and printStackTrace(PrintWriter)
 * are not provided in order to maintain compatibility with CLDC.
 * </p>
 */
public void printStackTrace () {
    getDwtLogger().error( __FILE__, __LINE__,  "stacktrace follows (if feature compiled in)" );
    foreach( msg; info ){
        getDwtLogger().error( __FILE__, __LINE__,  "{}", msg );
    }
    if ( throwable !is null) {
        getDwtLogger().error ( __FILE__, __LINE__, "*** Stack trace of contained error ***"); //$NON-NLS-1$
        foreach( msg; throwable.info ){
            getDwtLogger().error( __FILE__, __LINE__,  "{}", msg );
        }
    }
}

}
