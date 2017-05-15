/*******************************************************************************
 * Copyright (c) 2003, 2004 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *      John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module org.eclipse.swt.browser.ProgressAdapter;

import java.lang.all;

import org.eclipse.swt.browser.ProgressEvent;
import org.eclipse.swt.browser.ProgressListener;

/**
 * This adapter class provides default implementations for the
 * methods described by the {@link ProgressListener} interface.
 * <p>
 * Classes that wish to deal with {@link ProgressEvent}'s can
 * extend this class and override only the methods which they are
 * interested in.
 * </p>
 * 
 * @since 3.0
 */
public abstract class ProgressAdapter : ProgressListener {
 
public void changed(ProgressEvent event) {
}

public void completed(ProgressEvent event) {
}
}
