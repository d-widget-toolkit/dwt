/*******************************************************************************
 * Copyright (c) 2000, 2004 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * Port to the D programming language:
 *     Enzo Petrelli
 *******************************************************************************/
module org.eclipse.swt.snippets.Snippet81;

/*
 * OLE and ActiveX example snippet: browse the typelibinfo for a program id (win32 only)
 * NOTE: This snippet uses internal SWT packages that are
 * subject to change without notice.
 *
 * For a list of all SWT example snippets see
 * http://www.eclipse.org/swt/snippets/
 */

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Shell;

import java.lang.all;             // String
import org.eclipse.swt.internal.ole.win32.OAIDL;
import org.eclipse.swt.ole.win32.OLE;
import org.eclipse.swt.ole.win32.OleAutomation;
import org.eclipse.swt.ole.win32.OleControlSite;
import org.eclipse.swt.ole.win32.OleFrame;
import org.eclipse.swt.ole.win32.OleFunctionDescription;
import org.eclipse.swt.ole.win32.OlePropertyDescription;

version(Tango){
    import tango.io.Stdout;
    import tango.io.stream.Format;
    import tango.text.convert.Format;
} else { // Phobos
    import std.stdio;
    import std.string;
    class FormatOutput(T) {
        alias writefln formatln;
    }
}

int main() {
    int iRes = 0;

    String progID = "Shell.Explorer";
    //String progID = "Excel.Application";

    Display oDisplay = new Display();
    Shell oShell = new Shell(oDisplay);

    OleFrame frame = new OleFrame(oShell, SWT.NONE);
    OleControlSite oOleSite = null;
    OleAutomation oOleAutoObj = null;
    try {
        oOleSite = new OleControlSite(frame, SWT.NONE, progID); 
    }
    catch (Exception oExc) {
        version(Tango){
            Stdout.formatln("Exception {} creating OleControlSite on type library for {}", oExc.toString(), progID);
        } else { // Phobos
            writefln("Exception %s creating OleControlSite on type library for %s", oExc.toString(), progID);
        }
        return 1;
    }
    try {
        oOleAutoObj = new OleAutomation(oOleSite);
    }
    catch (Exception oExc) {
        version(Tango){
            Stdout.formatln("Exception {}  OleAutomation on type library for {}", oExc.toString(), progID);
        } else { // Phobos
            writefln("Exception %s  OleAutomation on type library for %s", oExc.toString(), progID);
        }
        return 1;
    }

    version(Tango){
        Stdout.formatln("TypeLibrary for: '{}'", progID);
        printTypeInfo(oOleAutoObj, Stdout);
    } else {
        writefln("TypeLibrary for: '%s'", progID);
        printTypeInfo(oOleAutoObj, new FormatOutput!(char));
    }

    oShell.dispose();
    oDisplay.dispose();
    return iRes;
}

void printTypeInfo(OleAutomation oOleAutoObj, FormatOutput!(char) oOut)
{
    org.eclipse.swt.internal.ole.win32.OAIDL.TYPEATTR * pTypeAttr = oOleAutoObj.getTypeInfoAttributes();
    if (pTypeAttr !is null) {
        if (pTypeAttr.cFuncs > 0) {
            oOut.formatln("Functions :");
            for (int iIdx = 0; iIdx < pTypeAttr.cFuncs; ++iIdx) {
                OleFunctionDescription oData = oOleAutoObj.getFunctionDescription(iIdx);
                String sArgList = "";
                int iFirstOptionalArgIndex = oData.args.length - oData.optionalArgCount;
                for (int iArg = 0; iArg < oData.args.length; ++iArg) {
                    sArgList ~= "[";
                    if (iArg >= iFirstOptionalArgIndex){
                        sArgList ~= "optional, ";
                    }
                    sArgList ~= getDirection(oData.args[iArg].flags) ~ "] " ~
                        getTypeName(oData.args[iArg].type) ~ " " ~
                        oData.args[iArg].name
                        ;
                    if (iArg < oData.args.length - 1){
                        sArgList ~= ", ";
                    }
                }
                version(Tango){
                    oOut.formatln("{} (id = {} (0x{:X8}))", getInvokeKind(oData.invokeKind), oData.id, oData.id);
                    oOut.formatln("\tSignature  : {} {}({})", getTypeName(oData.returnType), oData.name, sArgList);
                    oOut.formatln("\tDescription: {}", oData.documentation);
                    oOut.formatln("\tHelp File  : {}", oData.helpFile);
                    oOut.formatln("");
                } else { // Phobos
                    oOut.formatln("%s (id = %s (0x%8X))", getInvokeKind(oData.invokeKind), oData.id, oData.id);
                    oOut.formatln("\tSignature  : %s %s(%s)", getTypeName(oData.returnType), oData.name, sArgList);
                    oOut.formatln("\tDescription: %s", oData.documentation);
                    oOut.formatln("\tHelp File  : %s", oData.helpFile);
                    oOut.formatln("");
                }
            }
        }

        if (pTypeAttr.cVars > 0) {
            version(Tango){
                oOut.formatln("\n\nVariables :");
                for (int iIdx = 0; iIdx < pTypeAttr.cVars; ++iIdx) {
                    OlePropertyDescription oData = oOleAutoObj.getPropertyDescription(iIdx);
                    oOut.formatln("PROPERTY (id = {} (0x{:X8})", oData.id, oData.id);
                    oOut.formatln("\tName : {}", oData.name);
                    oOut.formatln("\tType : {}", getTypeName(oData.type));
                    oOut.formatln("");
                }
            } else { // Phobos
                oOut.formatln("\n\nVariables :");
                for (int iIdx = 0; iIdx < pTypeAttr.cVars; ++iIdx) {
                    OlePropertyDescription oData = oOleAutoObj.getPropertyDescription(iIdx);
                    oOut.formatln("PROPERTY (id = %s (0x%8X)", oData.id, oData.id);
                    oOut.formatln("\tName : %s", oData.name);
                    oOut.formatln("\tType : %s", getTypeName(oData.type));
                    oOut.formatln("");
                }
            }
        }
    }
}

String getTypeName(int iType) {
    int iBase = iType & ~OLE.VT_BYREF;
    String sDsc = null;
    switch (iBase) {
        case OLE.VT_BOOL :          sDsc = "boolean"; break;
        case OLE.VT_R4 :            sDsc = "float"; break;
        case OLE.VT_R8 :            sDsc = "double"; break;
        case OLE.VT_I4 :            sDsc = "int"; break;
        case OLE.VT_DISPATCH :      sDsc = "IDispatch"; break;
        case OLE.VT_UNKNOWN :       sDsc = "IUnknown"; break;
        case OLE.VT_I2 :            sDsc = "short"; break;
        case OLE.VT_BSTR :          sDsc = "String"; break;
        case OLE.VT_VARIANT :       sDsc = "Variant"; break;
        case OLE.VT_CY :            sDsc = "Currency"; break;
        case OLE.VT_DATE :          sDsc = "Date"; break;
        case OLE.VT_UI1 :           sDsc = "unsigned char"; break;
        case OLE.VT_UI4 :           sDsc = "unsigned int"; break;
        case OLE.VT_USERDEFINED :   sDsc = "UserDefined"; break;
        case OLE.VT_HRESULT :       sDsc = "HRESULT"; break;
        case OLE.VT_VOID :          sDsc = "void"; break;
        case OLE.VT_UI2 :           sDsc = "unsigned short"; break;
        case OLE.VT_UINT :          sDsc = "unsigned int"; break;
        case OLE.VT_PTR :           sDsc = "void *"; break;
        default: break;
    }
    if (sDsc !is null) {
        if ((iType & OLE.VT_BYREF) == OLE.VT_BYREF){
            return sDsc ~ " *";
        }
        return sDsc;
    }
    version(Tango){
        return Format("unknown {} (0x{:X4})", iType, iType);
    } else { // Phobos
        return format("unknown %s (0x%4X)", iType, iType);
    }
}

String getDirection(int bDirection) {
    String sDirString = "";
    bool bComma = false;
    if ((bDirection & OLE.IDLFLAG_FIN) != 0) {
        sDirString ~= "in";
        bComma = true;
    }
    if ((bDirection & OLE.IDLFLAG_FOUT) != 0) {
        if (bComma) sDirString ~= ", ";
        sDirString ~= "out";
        bComma = true;
    }
    if ((bDirection & OLE.IDLFLAG_FLCID) != 0) {
        if (bComma) sDirString ~= ", ";
        sDirString ~= "lcid";
        bComma = true;
    }
    if ((bDirection & OLE.IDLFLAG_FRETVAL) != 0) {
        if (bComma) sDirString ~= ", "; 
        sDirString ~= "retval";
    }
    return sDirString;
}

String getInvokeKind(int iInvKind) {
    switch (iInvKind) {
        case OLE.INVOKE_FUNC : return "METHOD";
        case OLE.INVOKE_PROPERTYGET : return "PROPERTY GET";
        case OLE.INVOKE_PROPERTYPUT : return "PROPERTY PUT";
        case OLE.INVOKE_PROPERTYPUTREF : return "PROPERTY PUT BY REF";
        default: break;
    }
    version(Tango){
        return Format("unknown {}", iInvKind);
    } else { // Phobos
        return format("unknown %s", iInvKind);
    }
}


