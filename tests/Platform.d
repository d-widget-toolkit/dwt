/*******************************************************************************
 * Copyright (c) 2000, 2016 IBM Corporation and others.
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
module tests.Platform;

import java.lang.util.HashSet;

import org.eclipse.swt.SWT;
import org.eclipse.swt.program.Program;
import org.eclipse.swt.widgets.Display;

@("test_equalsLjava_lang_Object")
unittest
{
    Display.getDefault();
    String[] extensions = Program.getExtensions();
    // No assertion here because the doc does not guarantee a non-null result
    if (extensions !is null) {
        for (int i = 0; i < extensions.length; i++) {
            Program program = Program.findProgram(extensions[i]);
            if (program !is null) {
                assert(program == program);
            }
        }
    }
}

@("test_executeLjava_lang_String")
unittest
{
    import std.exception : assertThrown;

    // This test is incomplete because a true test of execute would open
    // an application that cannot be programmatically closed.

    Display.getDefault();

    Program[] programs = Program.getPrograms();
    if (programs !is null && programs.length > 0) {
        // Cannot test empty string argument because it may launch something
        // bool result = programs[0].execute("");
        // assert(result is false);

        assertThrown!IllegalArgumentException(programs[0].execute(null));
    }
}

@("test_findProgramLjava_lang_String")
unittest
{
    import std.exception : assertThrown;

    Display.getDefault();
    String[] extensions = Program.getExtensions();
    // No assertion here because the doc does not guarantee a non-null result.
    if (extensions !is null) {
        for (int i = 0; i < extensions.length; i++) {
            Program.findProgram(extensions[i]);
            // No assertion here because a null result is allowed
        }
    }

    // SWT Extension: allows null for Program.findProgram()
    // assertThrown!IllegalArgumentException(Program.findProgram(null));
}

@("test_getExtensions")
unittest
{
    Display.getDefault();
    String[] extensions = Program.getExtensions();
    // No assertion here because the doc does not guarantee a non-null result
    if (extensions !is null) {
        for (int i = 0; i < extensions.length; i++) {
            assert(extensions[i] !is null);
        }
    }
}

@("test_getImageData")
unittest
{
    Display.getDefault();
    String[] extensions = Program.getExtensions();
    // No assertion here because the doc does not guarantee a non-null result.
    if (extensions !is null) {
        for (int i = 0; i < extensions.length; i++) {
            Program program = Program.findProgram(extensions[i]);
            if (program !is null) {
                program.getImageData();
                // Nothing to do
            }
        }
    }
}

@("test_getName")
unittest
{
    Display.getDefault();
    String[] extensions = Program.getExtensions();
    // No assertion here because the doc does not guarantee a non-null result
    if (extensions !is null) {
        for (int i = 0; i < extensions.length; i++) {
            Program program = Program.findProgram(extensions[i]);
            if (program !is null) {
                String name = program.getName();
                assert(name !is null, "Program has null name");
            }
        }
    }
}

@("test_getPrograms")
unittest
{
    Display.getDefault();
    Program[] programs = Program.getPrograms();

    // The result is not well-documented, but it should
    // be non-null and contain no null and no duplicated entries.

    assert(programs !is null);

    HashSet lookup = new HashSet();
    foreach (program; programs) {
        // test non-null entry
        assert(program !is null);

        // test if the list contains same objects multiple times
        if (lookup.contains(program)) {
            assert(false, "Duplicated list entry for " ~ program.toString());
        }
        else {
            lookup.add(program);
        }
    }
}

@("test_launchLjava_lang_String")
unittest
{
    import std.exception : assertThrown;

    // This test is incomplete because a true test of launch would open
    // an application that cannot be programmatically closed.

    // Cannot test empty string argument because it may launch something.

    // test null argument

    Display.getDefault();
    assertThrown!IllegalArgumentException(Program.launch(null));
}

@("test_toString")
unittest
{
    Display.getDefault();
    String[] extensions = Program.getExtensions();
    // No assertion here because the doc does not guarantee a non-null result
    if (extensions !is null) {
        for (int i = 0; i < extensions.length; i++) {
            Program program = Program.findProgram(extensions[i]);
            if (program !is null) {
                String string_ = program.toString();
                assert(string_ !is null, "toString returned null");
            }
        }
    }
}
