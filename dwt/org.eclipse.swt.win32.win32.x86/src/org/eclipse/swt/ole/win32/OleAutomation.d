/*******************************************************************************
 * Copyright (c) 2000, 2008 IBM Corporation and others.
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
module org.eclipse.swt.ole.win32.OleAutomation;


import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.COMTYPES;
import org.eclipse.swt.internal.ole.win32.OAIDL;
// import org.eclipse.swt.internal.ole.win32.DISPPARAMS;
// import org.eclipse.swt.internal.ole.win32.EXCEPINFO;
// import org.eclipse.swt.internal.ole.win32.FUNCDESC;
// import org.eclipse.swt.internal.ole.win32.GUID;
// import org.eclipse.swt.internal.ole.win32.IDispatch;
// import org.eclipse.swt.internal.ole.win32.ITypeInfo;
// import org.eclipse.swt.internal.ole.win32.TYPEATTR;
// import org.eclipse.swt.internal.ole.win32.VARDESC;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.ole.win32.OleClientSite;
import org.eclipse.swt.ole.win32.OlePropertyDescription;
import org.eclipse.swt.ole.win32.OleFunctionDescription;
import org.eclipse.swt.ole.win32.OleParameterDescription;
import org.eclipse.swt.ole.win32.Variant;
import org.eclipse.swt.ole.win32.OLE;

import java.lang.all;

version(Tango){
} else { // Phobos
    static import std.algorithm;
}

/**
 * OleAutomation provides a generic mechanism for accessing functionality that is
 * specific to a particular ActiveX Control or OLE Document.
 *
 * <p>The OLE Document or ActiveX Control must support the IDispatch interface in order to provide
 * OleAutomation support. The additional functionality provided by the OLE Object is specified in
 * its IDL file.  The additional methods can either be to get property values (<code>getProperty</code>),
 * to set property values (<code>setProperty</code>) or to invoke a method (<code>invoke</code> or
 * <code>invokeNoReply</code>).  Arguments are passed around in the form of <code>Variant</code>
 * objects.
 *
 * <p>Here is a sample IDL fragment:
 *
 * <pre>
 *  interface IMyControl : IDispatch
 *  {
 *      [propget, id(0)] HRESULT maxFileCount([retval, out] int *c);
 *      [propput, id(0)] HRESULT maxFileCount([in] int c);
 *      [id(1)] HRESULT AddFile([in] BSTR fileName);
 *  };
 * </pre>
 *
 * <p>An example of how to interact with this extended functionality is shown below:
 *
 * <code><pre>
 *  OleAutomation automation = new OleAutomation(myControlSite);
 *
 *  // Look up the ID of the maxFileCount parameter
 *  int[] rgdispid = automation.getIDsOfNames(new String[]{"maxFileCount"});
 *  int maxFileCountID = rgdispid[0];
 *
 *  // Set the property maxFileCount to 100:
 *  if (automation.setProperty(maxFileCountID, new Variant(100))) {
 *      System.out.println("Max File Count was successfully set.");
 *  }
 *
 *  // Get the new value of the maxFileCount parameter:
 *  Variant pVarResult = automation.getProperty(maxFileCountID);
 *  if (pVarResult !is null) {
 *      System.out.println("Max File Count is "+pVarResult.getInt());
 *  }
 *
 *  // Invoke the AddFile method
 *  // Look up the IDs of the AddFile method and its parameter
 *  rgdispid = automation.getIDsOfNames(new String[]{"AddFile", "fileName"});
 *  int dispIdMember = rgdispid[0];
 *  int[] rgdispidNamedArgs = new int[] {rgdispid[1]};
 *
 *  // Convert arguments to Variant objects
 *  Variant[] rgvarg = new Variant[1];
 *  String fileName = "C:\\testfile";
 *  rgvarg[0] = new Variant(fileName);
 *
 *  // Call the method
 *  Variant pVarResult = automation.invoke(dispIdMember, rgvarg, rgdispidNamedArgs);
 *
 *  // Check the return value
 *  if (pVarResult is null || pVarResult.getInt() !is OLE.S_OK){
 *      System.out.println("Failed to add file "+fileName);
 *  }
 *
 *  automation.dispose();
 *
 * </pre></code>
 * 
 * @see <a href="http://www.eclipse.org/swt/snippets/#ole">OLE and ActiveX snippets</a>
 * @see <a href="http://www.eclipse.org/swt/examples.php">SWT Examples: OLEExample, OleWebBrowser</a>
 */
public final class OleAutomation {
    private IDispatch objIDispatch;
    private String exceptionDescription;
    private ITypeInfo objITypeInfo;

this(IDispatch idispatch) {
    if (idispatch is null) OLE.error(OLE.ERROR_INVALID_INTERFACE_ADDRESS);
    objIDispatch = idispatch;
    objIDispatch.AddRef();

    int result = objIDispatch.GetTypeInfo(0, COM.LOCALE_USER_DEFAULT, &objITypeInfo);
    if (result is OLE.S_OK) {
        objITypeInfo.AddRef();
    }
}
/**
 * Creates an OleAutomation object for the specified client.
 *
 * @param clientSite the site for the OLE Document or ActiveX Control whose additional functionality
 *        you need to access
 *
 * @exception IllegalArgumentException <ul>
 *      <li>ERROR_INVALID_INTERFACE_ADDRESS when called with an invalid client site
 *  </ul>
 */
 public this(OleClientSite clientSite) {
    if (clientSite is null) OLE.error(OLE.ERROR_INVALID_INTERFACE_ADDRESS);
    objIDispatch = clientSite.getAutomationObject();

    auto result = objIDispatch.GetTypeInfo(0, COM.LOCALE_USER_DEFAULT, &objITypeInfo);
    if (result is OLE.S_OK) {
        objITypeInfo.AddRef();
    }
 }
/**
 * Disposes the automation object.
 * <p>
 * This method releases the IDispatch interface on the OLE Document or ActiveX Control.
 * Do not use the OleAutomation object after it has been disposed.
 */
public void dispose() {

    if (objIDispatch !is null){
        objIDispatch.Release();
    }
    objIDispatch = null;

    if (objITypeInfo !is null){
        objITypeInfo.Release();
    }
    objITypeInfo = null;

}
IDispatch getAddress() {
    return objIDispatch;
}
/**
 * Returns the fully qualified name of the Help file for the given member ID.
 * 
 * @param dispId the member ID whose Help file is being retrieved.
 * @return a string representing the fully qualified name of a Help 
 * file or null.
 */
public String getHelpFile(int dispId) {
    if (objITypeInfo is null) return null;
    BSTR file;
    HRESULT rc = objITypeInfo.GetDocumentation(dispId, null, null, null, &file );
    if (rc is OLE.S_OK) {
        String str = WCHARzToStr( file, -1 );
        COM.SysFreeString(file);
        return str;
    }
    return null;
}
/**
 * Returns the documentation string for the given member ID.
 * 
 * @param dispId the member ID in which the documentation is being retrieved.
 * @return the documentation string if it exists; otherwise return null.
 */
public String getDocumentation(int dispId) {
    if (objITypeInfo is null) return null;
    BSTR doc;
    HRESULT rc = objITypeInfo.GetDocumentation(dispId, null, &doc, null, null );
    if (rc == OLE.S_OK) {
        String s = WCHARzToStr(doc, -1);
        COM.SysFreeString(doc);
        return s;
    }
    return null;
}
/**
 * Returns the property description of a variable at the given index.
 * 
 * @param index the index of a variable whose property is being retrieved.
 * @return an OlePropertyDescription for a variable at the given index.
 */
public OlePropertyDescription getPropertyDescription(int index) {
    if (objITypeInfo is null) return null;
    VARDESC* vardesc;
    HRESULT rc = objITypeInfo.GetVarDesc(index, &vardesc);
    if (rc != OLE.S_OK) return null;
//  VARDESC* vardesc = new VARDESC();
//  COM.MoveMemory(vardesc, ppVarDesc[0], VARDESC.sizeof);

    OlePropertyDescription data = new OlePropertyDescription();
    data.id = vardesc.memid;
    data.name = getName(vardesc.memid);
    data.type = vardesc.elemdescVar.tdesc.vt;
    if (data.type == OLE.VT_PTR) {
//      short[] vt = new short[1];
//      COM.MoveMemory(vt, vardesc.elemdescVar.tdesc_union + 4, 2);
        // TODO:
        data.type = vardesc.elemdescVar.tdesc.vt;
    }
    data.flags = vardesc.wVarFlags;
    data.kind = vardesc.varkind;
    data.description = getDocumentation(vardesc.memid);
    data.helpFile = getHelpFile(vardesc.memid);

    objITypeInfo.ReleaseVarDesc(vardesc);
    return data;
}
/**
 * Returns the description of a function at the given index.
 * 
 * @param index the index of a function whose property is being retrieved.
 * @return an OleFunctionDescription for a function at the given index.
 */
public OleFunctionDescription getFunctionDescription(int index) {
    if (objITypeInfo is null) return null;
    FUNCDESC* funcdesc;
    HRESULT rc = objITypeInfo.GetFuncDesc(index, &funcdesc);
    if (rc != OLE.S_OK) return null;

    OleFunctionDescription data = new OleFunctionDescription();

    data.id = funcdesc.memid;
    data.optionalArgCount = funcdesc.cParamsOpt;
    data.invokeKind = funcdesc.invkind;
    data.funcKind = funcdesc.funckind;
    data.flags = funcdesc.wFuncFlags;
    data.callingConvention = funcdesc.callconv;
    data.documentation = getDocumentation(funcdesc.memid);
    data.helpFile = getHelpFile(funcdesc.memid);

    String[] names = getNames(funcdesc.memid, funcdesc.cParams + 1);
    if (names.length > 0) {
        data.name = names[0];
    }
    data.args = new OleParameterDescription[funcdesc.cParams];
    for (int i = 0; i < data.args.length; i++) {
        data.args[i] = new OleParameterDescription();
        if (names.length > i + 1) {
            data.args[i].name = names[i + 1];
        }
        short[1] vt;
        COM.MoveMemory(vt.ptr, (cast(void*)funcdesc.lprgelemdescParam) + i * 16 + 4, 2);
        if (vt[0] is OLE.VT_PTR) {
            int[1] pTypedesc;
            COM.MoveMemory(pTypedesc.ptr, (cast(void*)funcdesc.lprgelemdescParam) + i * 16, 4);
            short[1] vt2;
            COM.MoveMemory(vt2.ptr, pTypedesc[0] + 4, 2);
            vt[0] = cast(short)(vt2[0] | COM.VT_BYREF);
        }
        data.args[i].type = vt[0];
        short[1] wParamFlags;
        COM.MoveMemory(wParamFlags.ptr, (cast(void*)funcdesc.lprgelemdescParam) + i * 16 + 12, 2);
        data.args[i].flags = wParamFlags[0];
    }

    data.returnType = funcdesc.elemdescFunc.tdesc.vt;
    if (data.returnType is OLE.VT_PTR) {
        ushort[1] vt;
        COM.MoveMemory(vt.ptr, funcdesc.elemdescFunc.tdesc.u.lpadesc, 2);
        data.returnType = vt[0];
    }

    objITypeInfo.ReleaseFuncDesc(funcdesc);
    return data;
}
/**
 * Returns the type info of the current object referenced by the automation.
 * The type info contains information about the object such as the function descriptions,
 * the member descriptions and attributes of the type.
 * 
 * @return the type info of the receiver
 */
public TYPEATTR* getTypeInfoAttributes() {
    if (objITypeInfo is null) return null;
    TYPEATTR* ppTypeAttr;
    HRESULT rc = objITypeInfo.GetTypeAttr(&ppTypeAttr);
    if (rc !is OLE.S_OK) return null;
    TYPEATTR* typeattr = new TYPEATTR();
    COM.MoveMemory(typeattr, ppTypeAttr, TYPEATTR.sizeof);
    objITypeInfo.ReleaseTypeAttr(ppTypeAttr);
    return typeattr;
}
/**
 * Returns the name of the given member ID.
 * 
 * @param dispId the member ID in which the name is being retrieved.
 * @return the name if it exists; otherwise return null.
 */
public String getName(int dispId) {
    if (objITypeInfo is null) return null;
    BSTR name;
    HRESULT rc = objITypeInfo.GetDocumentation(dispId, &name, null, null, null );
    if (rc == OLE.S_OK) {
        String s = WCHARzToStr(name, -1);
        COM.SysFreeString(name);
        return s;
    }
    return null;
}
/**
 * Returns the name of a function and parameter names for the specified function ID.
 * 
 * @param dispId the function ID in which the name and parameters are being retrieved.
 * @param maxSize the maximum number of names to retrieve.
 * @return an array of name containing the function name and the parameter names
 */
public String[] getNames(int dispId, int maxSize) {
    if (objITypeInfo is null) return new String[0];
    BSTR[] names = new BSTR[maxSize];
    uint count;
    HRESULT rc = objITypeInfo.GetNames(dispId, names.ptr, maxSize, &count);
    if (rc == OLE.S_OK) {
        String[] newNames = new String[count];
        for(int i=0; i<count; ++i){
            newNames[i] = WCHARzToStr(names[i], -1);
            COM.SysFreeString(names[i]);
        }
        return newNames;
    }
    return null;
}
/**
 * Returns the positive integer values (IDs) that are associated with the specified names by the
 * IDispatch implementor.  If you are trying to get the names of the parameters in a method, the first
 * String in the names array must be the name of the method followed by the names of the parameters.
 *
 * @param names an array of names for which you require the identifiers
 *
 * @return positive integer values that are associated with the specified names in the same
 *         order as the names where provided; or null if the names are unknown
 */
public int[] getIDsOfNames(String[] names) {

    int count = cast(int)/*64bit*/names.length;
    LPCWSTR[] wcNames = new LPCWSTR[count];
    for(int i=0; i<count; ++i){
        wcNames[i] = StrToWCHARz(names[i]);
    }
    int[] rgdispid = new int[count];
    // TODO: NULL GUID ??
    GUID id;
    HRESULT result = objIDispatch.GetIDsOfNames(&id, wcNames.ptr, count, COM.LOCALE_USER_DEFAULT, rgdispid.ptr);
    if (result != COM.S_OK) return null;

    return rgdispid;
}
/**
 * Returns a description of the last error encountered.
 *
 * @return a description of the last error encountered
 */
public String getLastError() {

    return exceptionDescription;

}
/**
 * Returns the value of the property specified by the dispIdMember.
 *
 * @param dispIdMember the ID of the property as specified by the IDL of the ActiveX Control; the
 *        value for the ID can be obtained using OleAutomation.getIDsOfNames
 *
 * @return the value of the property specified by the dispIdMember or null
 */
public Variant getProperty(int dispIdMember) {
    Variant pVarResult = new Variant();
    HRESULT result = invoke(dispIdMember, COM.DISPATCH_PROPERTYGET, null, null, pVarResult);
    return (result is OLE.S_OK) ? pVarResult : null;
}
/**
 * Returns the value of the property specified by the dispIdMember.
 *
 * @param dispIdMember the ID of the property as specified by the IDL of the ActiveX Control; the
 *        value for the ID can be obtained using OleAutomation.getIDsOfNames
 *
 * @param rgvarg an array of arguments for the method.  All arguments are considered to be
 *        read only unless the Variant is a By Reference Variant type.
 *
 * @return the value of the property specified by the dispIdMember or null
 *
 * @since 2.0
 */
public Variant getProperty(int dispIdMember, Variant[] rgvarg) {
    Variant pVarResult = new Variant();
    HRESULT result = invoke(dispIdMember, COM.DISPATCH_PROPERTYGET, rgvarg, null, pVarResult);
    return (result is OLE.S_OK) ? pVarResult : null;

}
/**
 * Returns the value of the property specified by the dispIdMember.
 *
 * @param dispIdMember the ID of the property as specified by the IDL of the ActiveX Control; the
 *        value for the ID can be obtained using OleAutomation.getIDsOfNames
 *
 * @param rgvarg an array of arguments for the method.  All arguments are considered to be
 *        read only unless the Variant is a By Reference Variant type.
 *
 * @param rgdispidNamedArgs an array of identifiers for the arguments specified in rgvarg; the
 *        parameter IDs must be in the same order as their corresponding values;
 *        all arguments must have an identifier - identifiers can be obtained using
 *        OleAutomation.getIDsOfNames
 *
 * @return the value of the property specified by the dispIdMember or null
 *
 * @since 2.0
 */
public Variant getProperty(int dispIdMember, Variant[] rgvarg, int[] rgdispidNamedArgs) {
    Variant pVarResult = new Variant();
    HRESULT result = invoke(dispIdMember, COM.DISPATCH_PROPERTYGET, rgvarg, rgdispidNamedArgs, pVarResult);
    return (result is OLE.S_OK) ? pVarResult : null;
}

/**
 * Invokes a method on the OLE Object; the method has no parameters.
 *
 * @param dispIdMember the ID of the method as specified by the IDL of the ActiveX Control; the
 *        value for the ID can be obtained using OleAutomation.getIDsOfNames
 *
 * @return the result of the method or null if the method failed to give result information
 */
public Variant invoke(int dispIdMember) {
    Variant pVarResult = new Variant();
    HRESULT result = invoke(dispIdMember, COM.DISPATCH_METHOD, null, null, pVarResult);
    return (result is COM.S_OK) ? pVarResult : null;
}
/**
 * Invokes a method on the OLE Object; the method has no optional parameters.
 *
 * @param dispIdMember the ID of the method as specified by the IDL of the ActiveX Control; the
 *        value for the ID can be obtained using OleAutomation.getIDsOfNames
 *
 * @param rgvarg an array of arguments for the method.  All arguments are considered to be
 *        read only unless the Variant is a By Reference Variant type.
 *
 * @return the result of the method or null if the method failed to give result information
 */
public Variant invoke(int dispIdMember, Variant[] rgvarg) {
    Variant pVarResult = new Variant();
    HRESULT result = invoke(dispIdMember, COM.DISPATCH_METHOD, rgvarg, null, pVarResult);
    return (result is COM.S_OK) ? pVarResult : null;
}
/**
 * Invokes a method on the OLE Object; the method has optional parameters.  It is not
 * necessary to specify all the optional parameters, only include the parameters for which
 * you are providing values.
 *
 * @param dispIdMember the ID of the method as specified by the IDL of the ActiveX Control; the
 *        value for the ID can be obtained using OleAutomation.getIDsOfNames
 *
 * @param rgvarg an array of arguments for the method.  All arguments are considered to be
 *        read only unless the Variant is a By Reference Variant type.
 *
 * @param rgdispidNamedArgs an array of identifiers for the arguments specified in rgvarg; the
 *        parameter IDs must be in the same order as their corresponding values;
 *        all arguments must have an identifier - identifiers can be obtained using
 *        OleAutomation.getIDsOfNames
 *
 * @return the result of the method or null if the method failed to give result information
 */
public Variant invoke(int dispIdMember, Variant[] rgvarg, int[] rgdispidNamedArgs) {
    Variant pVarResult = new Variant();
    HRESULT result = invoke(dispIdMember, COM.DISPATCH_METHOD, rgvarg, rgdispidNamedArgs, pVarResult);
    return (result is COM.S_OK) ? pVarResult : null;
}
private int invoke(int dispIdMember, ushort wFlags, Variant[] rgvarg, int[] rgdispidNamedArgs, Variant pVarResult) {
    assert(objIDispatch);

    // get the IDispatch interface for the control
    if (objIDispatch is null) return COM.E_FAIL;

    // create a DISPPARAMS structure for the input parameters
    DISPPARAMS pDispParams;

    // store arguments in rgvarg
    if (rgvarg !is null && rgvarg.length > 0) {
        VARIANT[] tempArgs = new VARIANT[rgvarg.length];
        for (int i = 0; i < rgvarg.length ; ++i) {
            rgvarg[i].getData(&tempArgs[i]);
        }
        // the reverse sequency
        version(Tango){
            tempArgs.reverse;
        } else { // Phobos
            std.algorithm.reverse(tempArgs);
        }
        pDispParams.cArgs = cast(int)/*64bit*/tempArgs.length;
        pDispParams.rgvarg = tempArgs.ptr;
    }

    // if arguments have ids, store the ids in rgdispidNamedArgs
    if (rgdispidNamedArgs !is null && rgdispidNamedArgs.length > 0) {
        DISPID[] tempArgs = rgdispidNamedArgs.dup;
        // the reverse sequency
        version(Tango){
            tempArgs.reverse;
        } else { // Phobos
            std.algorithm.reverse(tempArgs);
        }
        pDispParams.cNamedArgs = cast(int)/*64bit*/tempArgs.length;
        pDispParams.rgdispidNamedArgs = tempArgs.ptr;
    }

    // invoke the method
    EXCEPINFO excepInfo;
    uint pArgErr;
    VARIANT* pVarResultAddress = null;
    if (pVarResult !is null)
        pVarResultAddress = new VARIANT();

    GUID id;    // IID_NULL
    /*
         HRESULT Invoke(
                [in] DISPID dispIdMember,
                [in] REFIID riid,
                [in] LCID lcid,
                [in] WORD wFlags,
                [in, out] DISPPARAMS * pDispParams,
                [out] VARIANT * pVarResult,
                [out] EXCEPINFO * pExcepInfo,
                [out] UINT * puArgErr
            );
     */
    HRESULT result = objIDispatch.Invoke(dispIdMember, &id, COM.LOCALE_USER_DEFAULT, wFlags, &pDispParams, pVarResultAddress, &excepInfo, &pArgErr);

    if (pVarResultAddress !is null){
        pVarResult.setData(pVarResultAddress);
        COM.VariantClear(pVarResultAddress);
    }

    // free the Dispparams resources
    if (pDispParams.rgvarg !is null) {
        for (int i = 0, length = cast(int)/*64bit*/rgvarg.length; i < length; i++){
            COM.VariantClear(&pDispParams.rgvarg[i]);
        }
        pDispParams.rgvarg = null;
    }
    pDispParams.rgdispidNamedArgs = null;

    // save error string and cleanup EXCEPINFO
    manageExcepinfo(result, &excepInfo);

    return result;
}
/**
 * Invokes a method on the OLE Object; the method has no parameters.  In the early days of OLE,
 * the IDispatch interface was not well defined and some applications (mainly Word) did not support
 * a return value.  For these applications, call this method instead of calling
 * <code>public void invoke(int dispIdMember)</code>.
 *
 * @param dispIdMember the ID of the method as specified by the IDL of the ActiveX Control; the
 *        value for the ID can be obtained using OleAutomation.getIDsOfNames
 *
 * @exception org.eclipse.swt.SWTException <ul>
 *      <li>ERROR_ACTION_NOT_PERFORMED when method invocation fails
 *  </ul>
 */
public void invokeNoReply(int dispIdMember) {
    HRESULT result = invoke(dispIdMember, COM.DISPATCH_METHOD, null, null, null);
    if (result !is COM.S_OK)
        OLE.error(__FILE__, __LINE__, OLE.ERROR_ACTION_NOT_PERFORMED, result);
}
/**
 * Invokes a method on the OLE Object; the method has no optional parameters.  In the early days of OLE,
 * the IDispatch interface was not well defined and some applications (mainly Word) did not support
 * a return value.  For these applications, call this method instead of calling
 * <code>public void invoke(int dispIdMember, Variant[] rgvarg)</code>.
 *
 * @param dispIdMember the ID of the method as specified by the IDL of the ActiveX Control; the
 *        value for the ID can be obtained using OleAutomation.getIDsOfNames
 *
 * @param rgvarg an array of arguments for the method.  All arguments are considered to be
 *        read only unless the Variant is a By Reference Variant type.
 *
 * @exception org.eclipse.swt.SWTException <ul>
 *      <li>ERROR_ACTION_NOT_PERFORMED when method invocation fails
 *  </ul>
 */
public void invokeNoReply(int dispIdMember, Variant[] rgvarg) {
    int result = invoke(dispIdMember, COM.DISPATCH_METHOD, rgvarg, null, null);
    if (result !is COM.S_OK)
        OLE.error(__FILE__, __LINE__, OLE.ERROR_ACTION_NOT_PERFORMED, result);
}
/**
 * Invokes a method on the OLE Object; the method has optional parameters.  It is not
 * necessary to specify all the optional parameters, only include the parameters for which
 * you are providing values.  In the early days of OLE, the IDispatch interface was not well
 * defined and some applications (mainly Word) did not support a return value.  For these
 * applications, call this method instead of calling
 * <code>public void invoke(int dispIdMember, Variant[] rgvarg, int[] rgdispidNamedArgs)</code>.
 *
 * @param dispIdMember the ID of the method as specified by the IDL of the ActiveX Control; the
 *        value for the ID can be obtained using OleAutomation.getIDsOfNames
 *
 * @param rgvarg an array of arguments for the method.  All arguments are considered to be
 *        read only unless the Variant is a By Reference Variant type.
 *
 * @param rgdispidNamedArgs an array of identifiers for the arguments specified in rgvarg; the
 *        parameter IDs must be in the same order as their corresponding values;
 *        all arguments must have an identifier - identifiers can be obtained using
 *        OleAutomation.getIDsOfNames
 *
 * @exception org.eclipse.swt.SWTException <ul>
 *      <li>ERROR_ACTION_NOT_PERFORMED when method invocation fails
 *  </ul>
 */
public void invokeNoReply(int dispIdMember, Variant[] rgvarg, int[] rgdispidNamedArgs) {
    HRESULT result = invoke(dispIdMember, COM.DISPATCH_METHOD, rgvarg, rgdispidNamedArgs, null);
    if (result !is COM.S_OK)
        OLE.error(__FILE__, __LINE__, OLE.ERROR_ACTION_NOT_PERFORMED, result);
}
private void manageExcepinfo(int hResult, EXCEPINFO* excepInfo) {

    if (hResult is COM.S_OK){
        exceptionDescription = "No Error"; //$NON-NLS-1$
        return;
    }

    // extract exception info
    if (hResult is COM.DISP_E_EXCEPTION) {
        if (excepInfo.bstrDescription !is null){
            exceptionDescription = WCHARzToStr(excepInfo.bstrDescription);
        } else {
            exceptionDescription = ("OLE Automation Error Exception "); //$NON-NLS-1$
            if (excepInfo.wCode != 0){
                exceptionDescription ~= "code = ";
                exceptionDescription ~= cast(int)(excepInfo.wCode); //$NON-NLS-1$
            } else if (excepInfo.scode != 0){
                exceptionDescription ~= "code = ";
                exceptionDescription ~= (excepInfo.scode); //$NON-NLS-1$
            }
        }
    } else {
        exceptionDescription = ("OLE Automation Error HResult : ") ~ toHex(hResult); //$NON-NLS-1$
    }

    // cleanup EXCEPINFO struct
    if (excepInfo.bstrDescription !is null)
        COM.SysFreeString(excepInfo.bstrDescription);
    if (excepInfo.bstrHelpFile !is null)
        COM.SysFreeString(excepInfo.bstrHelpFile);
    if (excepInfo.bstrSource !is null)
        COM.SysFreeString(excepInfo.bstrSource);
}
/**
 * Sets the property specified by the dispIdMember to a new value.
 *
 * @param dispIdMember the ID of the property as specified by the IDL of the ActiveX Control; the
 *                     value for the ID can be obtained using OleAutomation.getIDsOfNames
 * @param rgvarg the new value of the property
 *
 * @return true if the operation was successful
 */
public bool setProperty(int dispIdMember, Variant rgvarg) {

    Variant[] rgvarg2 = new Variant[1];
    rgvarg2[0] = rgvarg;
    int[] rgdispidNamedArgs;
    rgdispidNamedArgs ~= COM.DISPID_PROPERTYPUT;
    ushort dwFlags = COM.DISPATCH_PROPERTYPUT;
    if ((rgvarg.getType() & COM.VT_BYREF) == COM.VT_BYREF)
        dwFlags = COM.DISPATCH_PROPERTYPUTREF;
    Variant pVarResult = new Variant();
    HRESULT result = invoke(dispIdMember, dwFlags, rgvarg2, rgdispidNamedArgs, pVarResult);
    return (result == COM.S_OK);
}
/**
 * Sets the property specified by the dispIdMember to a new value.
 *
 * @param dispIdMember the ID of the property as specified by the IDL of the ActiveX Control; the
 *                     value for the ID can be obtained using OleAutomation.getIDsOfNames
 * @param rgvarg an array of arguments for the method.  All arguments are considered to be
 *                     read only unless the Variant is a By Reference Variant type.
 *
 * @return true if the operation was successful
 *
 * @since 2.0
 */
public bool setProperty(int dispIdMember, Variant[] rgvarg) {
    int[] rgdispidNamedArgs;
    rgdispidNamedArgs ~= COM.DISPID_PROPERTYPUT;
    ushort dwFlags = COM.DISPATCH_PROPERTYPUT;
    for (int i = 0; i < rgvarg.length; i++) {
        if ((rgvarg[i].getType() & COM.VT_BYREF) == COM.VT_BYREF)
        dwFlags = COM.DISPATCH_PROPERTYPUTREF;
    }
    Variant pVarResult = new Variant();
    HRESULT result = invoke(dispIdMember, dwFlags, rgvarg, rgdispidNamedArgs, pVarResult);
    return (result == COM.S_OK);
}
}

