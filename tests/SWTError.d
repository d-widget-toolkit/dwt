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
module tests.SWTError;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.lang.String;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTError;

/**
 * Automated Test Suite for class org.eclipse.swt.SWTError
 *
 * @see org.eclipse.swt.SWTError
 */

 @("test_Constructor")
 unittest
 {
    assert(
        new SWTError().code == SWT.ERROR_UNSPECIFIED,
        "did not fill in code properly");
 }

 @("test_ConstructorI")
 unittest
 {
    assert(
        new SWTError(SWT.ERROR_CANNOT_BE_ZERO).code == SWT.ERROR_CANNOT_BE_ZERO,
        "did not fill in code properly");
 }

 @("test_ConstructorILjava_lang_String")
 unittest
 {
    assert(
        new SWTError(SWT.ERROR_CANNOT_BE_ZERO, "An uninteresting message").code == SWT.ERROR_CANNOT_BE_ZERO,
        "did not fill in code properly");
 }

 @("test_ConstructorLjava_lang_String")
 unittest
 {
    assert(
        new SWTError("An uninteresting message").code == SWT.ERROR_UNSPECIFIED,
        "did not fill in code properly");
 }

 @("test_getMessage")
 unittest
 {
    assert(
        new SWTError(SWT.ERROR_CANNOT_BE_ZERO, "An interesting message").getMessage()
            .indexOf("An interesting message") >= 0,
        "did not include creation string in result");
 }

 @("test_printStackTrace")
 unittest
 {
    // WARNING: this test is not CLDC safe, because it requires java.io.PrintStream

    if (ClassInfo.find("java.io.PrintStream.PrintStream") is null) {
        // ignore test if running on CLDC
        return;
    }

    // test default SWTError

    ByteArrayOutputStream output = new ByteArrayOutputStream();
    import java.lang.util : getDwtLogger;
    getDwtLogger().warn(__FILE__, __LINE__, "Incomplete unit tests");
    /*
    /+
     + Missing: System.setErr
     + Missing: All PrintStream constructor implementations.
     + Missing: SWTError.printStackTrace using System.err
     +
     +/
    System.setErr(new PrintStream(output));
    SWTError error = new SWTError();
    error.printStackTrace();
    assert(output.size() > 0);
    assert(new_String(output.toByteArray()).indexOf("test_printStackTrace") != -1);

    // test SWTError with code
    output = new ByteArrayOutputStream();
    System.setErr(new PrintStream(output));
    error = new SWTError(SWT.ERROR_INVALID_ARGUMENT);
    error.printStackTrace();
    assert(output.size() > 0);
    assert(new_String(output.toByteArray()).indexOf("test_printStackTrace") != -1);
    */
 }
