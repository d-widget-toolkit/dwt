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
module org.eclipse.swt.internal.LONG;

import java.lang.all;

public class LONG {
    public int value;

    public this (int value) {
        this.value = value;
    }

    override
    public equals_t opEquals (Object object) {
        if (object is this) return true;
        if( auto obj = cast(LONG)object ){
            return obj.value is this.value;
        }
        return false;
    }

    public hash_t hashCode () {
        return cast(hash_t)value;
    }
}

public class LONG_PTR {
    public ptrdiff_t value;

    public this (ptrdiff_t value) {
        this.value = value;
    }

    override
    public equals_t opEquals (Object object) {
        if (object is this) return true;
        if( auto obj = cast(LONG_PTR)object ){
            return obj.value is this.value;
        }
        return false;
    }

    public hash_t hashCode () {
        return cast(hash_t)value;
    }
}
