/*******************************************************************************
 * Copyright (c) 2000, 2011 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Frank Benoit <benoit@tionex.de>
 *     alice <stigma@disroot.org>
 *******************************************************************************/
module org.eclipse.swt.internal.Compatibility; // @suppress(dscanner.style.phobos_naming_convention)

import java.lang.all;
import java.io.BufferedInputStream;
import java.io.File;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.text.MessageFormat;
import java.util.MissingResourceException;
import java.util.ResourceBundle;
import java.util.zip.InflaterInputStream;
import java.util.zip.DeflaterOutputStream;

import org.eclipse.swt.SWT;

import std.process;

/**
 * This class is a placeholder for utility methods commonly
 * used on J2SE platforms but not supported on some J2ME
 * profiles.
 * <p>
 * It is part of our effort to provide support for both J2SE
 * and J2ME platforms.
 * </p>
 * <p>
 * IMPORTANT: some of the methods have been modified from their
 * J2SE parents. Refer to the description of each method for
 * specific changes.
 * </p>
 * <ul>
 * <li>Exceptions thrown may differ since J2ME's set of
 * exceptions is a subset of J2SE's one.
 * </li>
 * <li>The range of the mathematic functions is subject to
 * change.
 * </li>
 * </ul>
 */
public final class Compatibility {

/**
 * Returns the PI constant as a double.
 */
deprecated("This constant isn't required any more, use Math.PI")
public static const real PI = Math.PI;

deprecated("This constant isn't required any more, use Math.toRadians")
static const real toRadians = PI / 180;

/**
 * Answers the length of the side adjacent to the given angle
 * of a right triangle. In other words, it returns the integer
 * conversion of length * cos (angle).
 * <p>
 * IMPORTANT: the j2me version has an additional restriction on
 * the argument. length must be between -32767 and 32767 (inclusive).
 * </p>
 *
 * @param angle the angle in degrees
 * @param length the length of the triangle's hypotenuse
 * @return the integer conversion of length * cos (angle)
 */
deprecated("This method isn't required any more, use Math.cos")
public static int cos(int angle, int length) {
    return cast(int)(Math.cos(angle * toRadians) * length);
}

/**
 * Answers the length of the side opposite to the given angle
 * of a right triangle. In other words, it returns the integer
 * conversion of length * sin (angle).
 * <p>
 * IMPORTANT: the j2me version has an additional restriction on
 * the argument. length must be between -32767 and 32767 (inclusive).
 * </p>
 *
 * @param angle the angle in degrees
 * @param length the length of the triangle's hypotenuse
 * @return the integer conversion of length * sin (angle)
 */
deprecated("This method isn't required any more, use Math.sin")
public static int sin(int angle, int length) {
    return cast(int)(Math.sin(angle * toRadians) * length);
}

/**
 * Answers the most negative (i.e. closest to negative infinity)
 * integer value which is greater than or equal to the number obtained by dividing
 * the first argument p by the second argument q.
 *
 * @param p numerator
 * @param q denominator (must be different from zero)
 * @return the ceiling of the rational number p / q.
 */
public static int ceil(int p, int q) {
    return cast(int)Math.ceil(cast(float)p / q);
}

/**
 * Answers whether the indicated file exists or not.
 *
 * @param parent the file's parent directory
 * @param child the file's name
 * @return true if the file exists
 */
public static bool fileExists(String parent, String child) {
    scope f = new File(parent, child);
    return f.exists();
}

/**
 * Answers the most positive (i.e. closest to positive infinity)
 * integer value which is less than the number obtained by dividing
 * the first argument p by the second argument q.
 *
 * @param p numerator
 * @param q denominator (must be different from zero)
 * @return the floor of the rational number p / q.
 */
deprecated("This method isn't required any more, use Math.floor")
public static int floor(int p, int q) {
    return cast(int)Math.floor(cast(double)p / q);
}

/**
 * Answers the result of rounding to the closest integer the number obtained
 * by dividing the first argument p by the second argument q.
 * <p>
 * IMPORTANT: the j2me version has an additional restriction on
 * the arguments. p must be within the range 0 - 32767 (inclusive).
 * q must be within the range 1 - 32767 (inclusive).
 * </p>
 *
 * @param p numerator
 * @param q denominator (must be different from zero)
 * @return the closest integer to the rational number p / q
 */
public static int round(int p, int q) {
    return cast(int)Math.round(cast(float)p / q);
}

/**
 * Returns 2 raised to the power of the argument.
 *
 * @param n an int value between 0 and 30 (inclusive)
 * @return 2 raised to the power of the argument
 *
 * @exception IllegalArgumentException <ul>
 *    <li>ERROR_INVALID_RANGE - if the argument is not between 0 and 30 (inclusive)</li>
 * </ul>
 */
public static int pow2(int n) {
    if (n >= 1 && n <= 30)
        return 2 << (n - 1);
    else if (n != 0) {
        SWT.error(SWT.ERROR_INVALID_RANGE);
    }
    return 1;
}

/**
 * Create an DeflaterOutputStream if such things are supported.
 *
 * @param stream the output stream
 * @return a deflater stream or <code>null</code>
 * @exception IOException
 *
 * @since 3.4
 */
deprecated("Use java.util.zip.DeflaterOutputStream instead")
public static OutputStream newDeflaterOutputStream(OutputStream stream) {
    return new DeflaterOutputStream(stream);
}

/**
 * Open a file if such things are supported.
 *
 * @param filename the name of the file to open
 * @return a stream on the file if it could be opened.
 * @exception IOException
 */
deprecated("Use java.io.FileInputStream instead")
public static InputStream newFileInputStream(String filename) {
    return new FileInputStream(filename);
}

/**
 * Open a file if such things are supported.
 *
 * @param filename the name of the file to open
 * @return a stream on the file if it could be opened.
 * @exception IOException
 */
deprecated("Use java.io.FileOutputStream instead")
public static OutputStream newFileOutputStream(String filename) {
    return new FileOutputStream(filename);
}

/**
 * Create an InflaterInputStream if such things are supported.
 *
 * @param stream the input stream
 * @return a inflater stream or <code>null</code>
 * @exception IOException
 *
 * @since 3.3
 */
deprecated("Use java.util.zip.InflaterInputStream instead")
public static InflaterInputStream newInflaterInputStream(InputStream stream) {
    return new InflaterInputStream(stream);
}

/**
 * Answers whether the character is a letter.
 *
 * @param c the character
 * @return true when the character is a letter
 */
deprecated("This method isn't required any more, use Character.isLetter")
public static bool isLetter(dchar c) {
    return Character.isLetter(c);
}

/**
 * Answers whether the character is a letter or a digit.
 *
 * @param c the character
 * @return true when the character is a letter or a digit
 */
deprecated("This method isn't required any more, use Character.isLetterOrDigit")
public static bool isLetterOrDigit(dchar c) {
    return Character.isLetterOrDigit(c);
}

/**
 * Answers whether the character is a Unicode space character.
 *
 * @param c  the character
 * @return true when the character is a Unicode space character
 */
deprecated("This method isn't required any more, use Character.isSpace")
public static bool isSpaceChar(dchar c) {
    return Character.isSpace(c);
}

/**
 * Answers whether the character is a whitespace character.
 *
 * @param c the character to test
 * @return true if the character is whitespace
 */
deprecated("This method isn't required any more, use Character.isWhitespace")
public static bool isWhitespace(dchar c) {
    return Character.isWhitespace(c);
}

/**
 * Execute prog[0] in a separate platform process if the
 * underlying platform supports this.
 * <p>
 * The new process inherits the environment of the caller.
 * <p>
 *
 * @param prog array containing the program to execute and its arguments
 * @param envp
 *            array of strings, each element of which has environment
 *            variable settings in the format name=value
 * @param workingDir
 *            the working directory of the new process, or null if the new
 *            process should inherit the working directory of the caller
 *
 * @exception ProcessException
 *  if the program cannot be executed
 * @exception	StdioException
 *  on failure to capture output.
 *
 * @since 3.6
 */
public static void exec(String[] prog, String[] envp, String workingDir)
{
    execute(prog[0], null, Config.none, size_t.max, workingDir);
}

/**
 * Execute a program in a separate platform process if the
 * underlying platform support this.
 * <p>
 * The new process inherits the environment of the caller.
 * </p>
 *
 * @param prog the name of the program to execute
 *
 * @exception ProcessException
 *  if the program cannot be executed
 * @exception	StdioException
 *  on failure to capture output.
 */
deprecated("Use exec(String[], String[], String)")
public static void exec(String prog) {
    Compatibility.exec([prog], null, null);
}

/**
 * Execute progArray[0] in a separate platform process if the
 * underlying platform support this.
 * <p>
 * The new process inherits the environment of the caller.
 * <p>
 *
 * @param progArray array containing the program to execute and its arguments
 *
 * @exception ProcessException
 *  if the program cannot be executed
 * @exception	StdioException
 *  on failure to capture output.
 */
deprecated("Use exec(String[], String[], String)")
public static void exec(String[] progArray) {
    Compatibility.exec(progArray, null, null);
}

static const ImportData[] SWTMessagesBundleData = [
    getImportData!( "org.eclipse.swt.internal.SWTMessages.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_ar.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_cs.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_da.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_de.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_el.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_es.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_fi.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_fr.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_hu.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_it.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_iw.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_ja.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_ko.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_nl.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_no.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_pl.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_pt_BR.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_pt.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_ru.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_sv.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_tr.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_zh_HK.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_zh.properties" ),
    getImportData!( "org.eclipse.swt.internal.SWTMessages_zh_TW.properties" )
];

private static ResourceBundle msgs = null;

/**
 * Returns the NLS'ed message for the given argument. This is only being
 * called from SWT.
 *
 * @param key the key to look up
 * @return the message for the given key
 *
 * @see SWT#getMessage(String)
 */
public static String getMessage(String key) {
    String answer = key;

    if (key is null) {
        SWT.error (SWT.ERROR_NULL_ARGUMENT);
    }
    if (msgs is null) {
        try {
            msgs = ResourceBundle.getBundle(SWTMessagesBundleData); //$NON-NLS-1$
        } catch (MissingResourceException ex) {
            answer = key ~ " (no resource bundle)"; //$NON-NLS-1$
        }
    }
    if (msgs !is null) {
        try {
            answer = msgs.getString(key);
        } catch (MissingResourceException ex2) {}
    }
    return answer;
}

public static String getMessage(String key, Object[] args) {
    String answer = key;

    if (key is null || args is null) {
        SWT.error (SWT.ERROR_NULL_ARGUMENT);
    }
    if (msgs is null) {
        try {
            msgs = ResourceBundle.getBundle(SWTMessagesBundleData); //$NON-NLS-1$
        } catch (MissingResourceException ex) {
            answer = key ~ " (no resource bundle)"; //$NON-NLS-1$
        }
    }
    if (msgs !is null) {
        try {
            String frmt = msgs.getString(key);
            switch( args.length ){
            case 0: answer = Format(frmt); break;
            case 1: answer = Format(frmt, args[0]); break;
            case 2: answer = Format(frmt, args[0], args[1]); break;
            case 3: answer = Format(frmt, args[0], args[1], args[2]); break;
            case 4: answer = Format(frmt, args[0], args[1], args[2], args[3]); break;
            case 5: answer = Format(frmt, args[0], args[1], args[2], args[3], args[4]); break;
            default:
                implMissing(__FILE__, __LINE__ );
            }
        } catch (MissingResourceException ex2) {}
    }
    return answer;
}


/**
 * Interrupt the current thread.
 * <p>
 * Note that this is not available on CLDC.
 * </p>
 */
deprecated("This method isn't required any more")
public static void interrupt() {
    //PORTING_FIXME: how to implement??
    //Thread.currentThread().interrupt();
}

/**
 * Compares two instances of class String ignoring the case of the
 * characters and answers if they are equal.
 *
 * @param s1 string
 * @param s2 string
 * @return true if the two instances of class String are equal
 */
deprecated("This method isn't required any more, see java.lang.String.equalsIgnoreCase")
public static bool equalsIgnoreCase(in char[] s1, in char[] s2) {
    return .equalsIgnoreCase(s1, s2);
}

}
