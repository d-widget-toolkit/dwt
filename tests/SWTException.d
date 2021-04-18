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
 * Port to the D Programming Language:
 *     alice <stigma@disroot.org>
 *******************************************************************************/
module tests.SWTException;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.lang.all;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;

/**
 * Automated Test Suite for class org.eclipse.swt.SWTException
 *
 * @see org.eclipse.swt.SWTException
 */

@("test_Constructor")
unittest
{
    assert(
        new SWTException().code == SWT.ERROR_UNSPECIFIED,
        "did not fill in code properly");
}

@("test_ConstructorI")
unittest
{
    assert(
        new SWTException(SWT.ERROR_CANNOT_BE_ZERO).code == SWT.ERROR_CANNOT_BE_ZERO,
        "did not fill in code properly");
}

@("test_ConstructorILjava_lang_String")
unittest
{
    assert(
        new SWTException(SWT.ERROR_CANNOT_BE_ZERO, "An uninteresting message").code ==
            SWT.ERROR_CANNOT_BE_ZERO,
        "did not fill in code properly"
    );
}

@("test_ConstructorLjava_lang_String")
unittest
{
    assert(
        new SWTException("An uninteresting message").code == SWT.ERROR_UNSPECIFIED,
        "did not fill in code properly"
    );
}

@("test_getMessage")
unittest
{
    assert(
        new SWTException(SWT.ERROR_CANNOT_BE_ZERO, "An uninteresting message").getMessage()
            .indexOf("An uninteresting message") >= 0,
        "did not include creation string in result"
    );
}

@("test_printStackTrace")
unittest
{

    // WARNING: this test is not CLDC safe, because it requires java.io.PrintStream

    if (ClassInfo.find("java.io.PrintStream.PrintStream") is null) {
        // ignore test if running on CLDC
        return;
    }

    /*
    DWT: The following tests are commented out since there are a few things missing:
     * System.setErr
     * All PrintStream.__ctor() overloads are "implMissing"
     * SWTException.printStackTrace not using System.err
     * new_String(byte[])

    // test default SWTException

    ByteArrayOutputStream out_ = new ByteArrayOutputStream();
    System.setErr(new PrintStream(out_));
    SWTException error = new SWTException();
    error.printStackTrace();
    assert(out_.size() > 0);
    assert(new_String(out_.toByteArray()).indexOf("test_printStackTrace") != -1);


    // test SWTException with code

    out_ = new ByteArrayOutputStream();
    System.setErr(new PrintStream(out_));
    error = new SWTException(SWT.ERROR_INVALID_ARGUMENT);
    error.printStackTrace();
    assert(out_.size() > 0);
    assert(new_String(out_.toByteArray()).indexOf("test_printStackTrace") != -1);
    */
}
