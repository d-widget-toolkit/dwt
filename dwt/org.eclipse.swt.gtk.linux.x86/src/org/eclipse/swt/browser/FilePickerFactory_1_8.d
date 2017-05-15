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
module org.eclipse.swt.browser.FilePickerFactory_1_8;

import java.lang.all;

import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;
import org.eclipse.swt.browser.FilePickerFactory;
import org.eclipse.swt.browser.FilePicker_1_8;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;


class FilePickerFactory_1_8 : FilePickerFactory {

extern(System)
nsresult CreateInstance (nsISupports aOuter, nsID* iid, void** result) { 
     if (result is null) 
        return XPCOM.NS_ERROR_INVALID_ARG;
    auto picker = new FilePicker_1_8;
    nsresult rv = picker.QueryInterface( iid, result );
    if (XPCOM.NS_FAILED(rv)) {
        *result = null;
        delete picker;
    }
    return rv;
}

}
