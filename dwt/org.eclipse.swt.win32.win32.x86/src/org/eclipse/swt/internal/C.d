/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
module org.eclipse.swt.internal.C;

import org.eclipse.swt.internal.Platform;

version(Tango){
    static import tango.stdc.string;
} else { // Phobos
    static import core.stdc.string;
}

public class C : Platform {
    version(Tango){
        alias tango.stdc.string.memmove MoveMemory;
    } else { // Phobos
        alias core.stdc.string.memmove MoveMemory;
    }
//public static final native void free (ptrdiff_t ptr);
//public static final native ptrdiff_t getenv (byte[] wcsToMbcs);
//public static final native ptrdiff_t malloc (ptrdiff_t size);
}
