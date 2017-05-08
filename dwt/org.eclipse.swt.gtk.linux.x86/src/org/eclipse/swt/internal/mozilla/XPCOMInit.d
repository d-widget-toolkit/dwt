/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is Mozilla Communicator client code, released March 31, 1998.
 *
 * The Initial Developer of the Original Code is
 * Netscape Communications Corporation.
 * Portions created by Netscape are Copyright (C) 1998-1999
 * Netscape Communications Corporation.  All Rights Reserved.
 *
 * Contributor(s):
 *
 * IBM
 * -  Binding to permit interfacing between Mozilla and SWT
 * -  Copyright (C) 2003, 2006 IBM Corp.  All Rights Reserved.
 *
 * Port to the D programming language:
 *      John Reimer <terminal.node@gmail.com>
 *******************************************************************************/
module org.eclipse.swt.internal.mozilla.XPCOMInit;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;

extern(System) {

    struct GREVersionRange {
        TryConst!(char)* lower;
        int         lowerInclusive;
        TryConst!(char)* upper;
        int         upperInclusive;
    }

    struct GREProperty {
        char *property;
        char *value;
    } 
}
  
const int PATH_MAX = 4096;

extern(System):

nsresult GRE_GetGREPathWithProperties(GREVersionRange *versions, PRUint32 versionsLength, GREProperty *properties, PRUint32 propertiesLength, char *buffer, PRUint32 buflen);
nsresult XPCOMGlueStartup(in char* xpcomFile);
nsresult XPCOMGlueShutdown ();
