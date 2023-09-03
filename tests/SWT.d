/*******************************************************************************
 * Copyright (c) 2000, 2015 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *     Red Hat Inc. - Bug 462631
 *******************************************************************************/
module tests.SWT;

import std.exception : assertThrown, assertNotThrown;

import java.lang.exceptions;

import org.eclipse.swt.all : SWT, SWTException, SWTError;

@("test_Constructor")
unittest
{
    // Do nothing. Class SWT is not intended to be subclassed.
}

@("test_errorI")
unittest {
    // Test that we throw the expected kinds of errors for the given error types.

    assertThrown!IllegalArgumentException(SWT.error(SWT.ERROR_NULL_ARGUMENT),
        "Did not correctly throw exception for ERROR_NULL_ARGUMENT");

    assertThrown!SWTException(SWT.error(SWT.ERROR_FAILED_EXEC),
        "Did not correctly throw exception ERROR_FAILED_EXEC");

    assertThrown!SWTError(SWT.error(SWT.ERROR_NO_HANDLES),
        "Did not correctly throw exception ERROR_NO_HANDLES");

    assertThrown!SWTError(SWT.error(-1),
        "Did not correctly throw exception for error(-1)");
}

@("test_errorILjava_lang_Throwable")
unittest
{
    // Test that the causing throwable is filled in.
    Exception cause = new RuntimeException("Just for testing");
    bool passed = false;

    try {
        SWT.error(SWT.ERROR_UNSUPPORTED_FORMAT, cause);
    } catch (SWTException ex) {
        passed = ex.throwable == cause;
    } catch (Exception e) { }
    assert(passed, "Did not correctly throw exception for ERROR_UNSUPPORTE_FORMAT");

    passed = false;
    try {
        SWT.error(SWT.ERROR_NOT_IMPLEMENTED, cause);
    } catch (SWTError ex) {
        passed = ex.throwable == cause;
    } catch (Exception e) { }
    assert(passed, "Did not correctly throw exception for ERROR_NOT_IMPLEMENTED");

    passed = false;
    try {
        SWT.error(-1, cause);
    } catch (SWTError ex) {
        passed = ex.throwable == cause;
    } catch (Exception e) { }
    assert(passed, "Did not correctly throw exception for error(-1)");
}

@("test_getMessageLjava_lang_String")
unittest
{
    assertThrown!IllegalArgumentException(SWT.getMessage(null),
        "Did not correctly throw exception with null argument");

    assertNotThrown!Exception(SWT.getMessage("SWT_Yes"),
        "Exception generated for SWT_Yes");

    assert(SWT.getMessage("_NOT_FOUND_IN_PROPERTIES_") == "_NOT_FOUND_IN_PROPERTIES_",
        "Invalid key did not return as itself");
}

@("test_getPlatform")
unittest
{
    // Can't test the list of platforms, since this may change,
    // so just test to see it returns something.
    assert(SWT.getPlatform() !is null, "Returned null platform name");
}

@("test_getVersion")
unittest
{
    import std.stdio : writeln;

    // Test that the version number which is returned is reasonable.
    int ver = SWT.getVersion();
    assert(ver > 0 && ver < 1_000_000, "Unreasonable value returned");
    writeln("SWT.getVersion(): ", ver);
}
