module org.eclipse.swt.internal.mozilla.prlink;
/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
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
 * The Original Code is the Netscape Portable Runtime (NSPR).
 *
 * The Initial Developer of the Original Code is
 * Netscape Communications Corporation.
 * Portions created by the Initial Developer are Copyright (C) 1998-2000
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** */

import org.eclipse.swt.internal.mozilla.Common;

struct PRStaticLinkTable
{
    char *name;
    void  function()fp;
}

extern (System):

PRStatus  PR_SetLibraryPath(char *path);

char *  PR_GetLibraryPath();
char *  PR_GetLibraryName(char *dir, char *lib);
void    PR_FreeLibraryName(char *mem);

alias void PRLibrary;

PRLibrary * PR_LoadLibrary(char *name);

enum PRLibSpecType
{
    PR_LibSpec_Pathname,
    PR_LibSpec_MacNamedFragment,
    PR_LibSpec_MacIndexedFragment,
}

alias void FSSpec;

struct _N3
{
    FSSpec *fsspec;
    char *name;
}

struct _N4
{
    FSSpec *fsspec;
    PRUint32 index;
}

union _N2
{
    char *pathname;
    struct _N3
    {
        FSSpec *fsspec;
        char *name;
    }
    _N3 mac_named_fragment;
    struct _N4
    {
        FSSpec *fsspec;
        PRUint32 index;
    }
    _N4 mac_indexed_fragment;
}

struct PRLibSpec
{
    int type;
    union _N2
    {
        char *pathname;
        struct _N3
        {
            FSSpec *fsspec;
            char *name;
        }
        _N3 mac_named_fragment;
        struct _N4
        {
            FSSpec *fsspec;
            PRUint32 index;
        }
        _N4 mac_indexed_fragment;
    }
    _N2 value;
}

const PR_LD_LAZY = 0x1;
const PR_LD_NOW = 0x2;
const PR_LD_GLOBAL = 0x4;
const PR_LD_LOCAL = 0x8;

PRLibrary * PR_LoadLibraryWithFlags(PRLibSpec libSpec, PRIntn flags);
PRStatus    PR_UnloadLibrary(PRLibrary *lib);
void *      PR_FindSymbol(PRLibrary *lib, char *name);

alias void  function()PRFuncPtr;

PRFuncPtr   PR_FindFunctionSymbol(PRLibrary *lib, char *name);
void *      PR_FindSymbolAndLibrary(char *name, PRLibrary **lib);
PRFuncPtr   PR_FindFunctionSymbolAndLibrary(char *name, PRLibrary **lib);
PRLibrary * PR_LoadStaticLibrary(char *name, PRStaticLinkTable *table);
char *      PR_GetLibraryFilePathname(char *name, PRFuncPtr addr);
