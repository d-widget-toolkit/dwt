/*******************************************************************************
 * Copyright (c) 2003, 2007 IBM Corporation and others.
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
module org.eclipse.swt.browser.FilePicker_1_8;

import java.lang.all;

import org.eclipse.swt.browser.FilePicker;
import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

class FilePicker_1_8 : FilePicker {

extern(D)
String parseAString (nsAString* string) {
    if (string is null) return null;
    return nsAString.toString(string);
}
}
