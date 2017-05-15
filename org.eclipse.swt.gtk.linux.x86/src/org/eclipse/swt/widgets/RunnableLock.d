/*******************************************************************************
 * Copyright (c) 2000, 2007 IBM Corporation and others.
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
module org.eclipse.swt.widgets.RunnableLock;

import java.lang.all;

import java.lang.Thread;
version(Tango){
    import tango.core.sync.Condition;
    import tango.core.sync.Mutex;
} else { // Phobos
    import java.nonstandard.sync.condition;
    import java.nonstandard.sync.mutex;
}

/**
 * Instances of this class are used to ensure that an
 * application cannot interfere with the locking mechanism
 * used to implement asynchronous and synchronous communication
 * between widgets and background threads.
 */

class RunnableLock : Mutex {
    Runnable runnable;
    Thread thread;
    Exception throwable;

    Condition cond;

this (Runnable runnable) {
    this.runnable = runnable;
    this.cond = new Condition(this);
}

bool done () {
    return runnable is null || throwable !is null;
}

void run () {
    if (runnable !is null) runnable.run ();
    runnable = null;
}

void notifyAll(){
    cond.notifyAll();
}
void wait(){
    cond.wait();
}

}
