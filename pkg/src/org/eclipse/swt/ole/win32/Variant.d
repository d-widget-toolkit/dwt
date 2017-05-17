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
module org.eclipse.swt.ole.win32.Variant;

import org.eclipse.swt.SWT;
import org.eclipse.swt.SWTException;
import org.eclipse.swt.internal.ole.win32.extras;
import org.eclipse.swt.internal.ole.win32.COM;
import org.eclipse.swt.internal.ole.win32.COMTYPES;
import org.eclipse.swt.internal.ole.win32.OAIDL;
import org.eclipse.swt.internal.win32.OS;

import org.eclipse.swt.ole.win32.OleAutomation;
import org.eclipse.swt.ole.win32.OLE;

import java.lang.all;

/**
 *
 * A Variant is a generic OLE mechanism for passing data of different types via a common interface.
 *
 * <p>It is used within the OleAutomation object for getting a property, setting a property or invoking
 * a method on an OLE Control or OLE Document.
 *
 */
public final class Variant {
    /**
    * The size in bytes of a native VARIANT struct.
    */
    /**
     * A variant always takes up 16 bytes, no matter what you
     * store in it. Objects, strings, and arrays are not physically
     * stored in the Variant; in these cases, four bytes of the
     * Variant are used to hold either an object reference, or a
     * pointer to the string or array. The actual data are stored elsewhere.
     */
    //public static final int sizeof = 16;


    private short type; // OLE.VT_* type
    private bool booleanData;
    private byte    byteData;
    private short   shortData;
    private wchar   charData;
    private int     intData;
    private long    longData;
    private float   floatData = 0;
    private double  doubleData = 0;
    private String  stringData;
    private void*   byRefPtr;
    private IDispatch dispatchData;
    private IUnknown unknownData;

/**
 * Invokes platform specific functionality to copy a variant
 * into operating system memory.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Variant</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param pVarDest destination pointer to a variant
 * @param varSrc source <code>Variant</code>
 *
 * @since 3.3
 */
public static void win32_copy (VARIANT* pVarDest, Variant varSrc) {
    varSrc.getData (pVarDest);
}

/**
 * Invokes platform specific functionality to wrap a variant
 * that was allocated in operating system memory.
 * <p>
 * <b>IMPORTANT:</b> This method is <em>not</em> part of the public
 * API for <code>Variant</code>. It is marked public only so that it
 * can be shared within the packages provided by SWT. It is not
 * available on all platforms, and should never be called from
 * application code.
 * </p>
 *
 * @param pVariant pointer to a variant
 *
 * @return a new <code>Variant</code>
 *
 * @since 3.3
 */
public static Variant win32_new (VARIANT* pVariant) {
    Variant variant = new Variant ();
    variant.setData (pVariant);
    return variant;
}

/**
 * Create an empty Variant object with type VT_EMPTY.
 *
 * @since 2.0
 */
public this(){
    type = COM.VT_EMPTY;
}
/**
 * Create a Variant object which represents a Java float as a VT_R4.
 *
 * @param val the Java float value that this Variant represents
 *
 */
public this(float val) {
    type = COM.VT_R4;
    floatData = val;

}
/**
 * Create a Variant object which represents a Java double as a VT_R8.
 *
 * @param val the Java double value that this Variant represents
 *
 * @since 3.2
 */
public this(double val) {
    type = COM.VT_R8;
    doubleData = val;
}
/**
 * Create a Variant object which represents a Java int as a VT_I4.
 *
 * @param val the Java int value that this Variant represents
 *
 */
public this(int val) {
    type = COM.VT_I4;
    intData = val;
}
public this(uint val) {
    type = COM.VT_I4;
    intData = val;
}
/**
 * Create a Variant object which contains a reference to the data being transferred.
 *
 * <p>When creating a VT_BYREF Variant, you must give the full Variant type
 * including VT_BYREF such as
 *
 * <pre><code>short byRefType = OLE.VT_BSTR | OLE.VT_BYREF</code></pre>.
 *
 * @param ptr a pointer to the data being transferred.
 * @param byRefType the type of the data being transferred such as OLE.VT_BSTR | OLE.VT_BYREF
 *
 */
public this(void* ptr, ushort byRefType) {
    type = byRefType;
    byRefPtr = ptr;
}
/**
 * Create a Variant object which represents an IDispatch interface as a VT_Dispatch.
 *
 * @param automation the OleAutomation object that this Variant represents
 *
 */
public this(OleAutomation automation) {
    type = COM.VT_DISPATCH;
    dispatchData = automation.getAddress();
}
/**
 * Create a Variant object which represents an IDispatch interface as a VT_Dispatch.
 * <p>The caller is expected to have appropriately invoked unknown.AddRef() before creating
 * this Variant.
 *
 * @since 2.0
 *
 * @param idispatch the IDispatch object that this Variant represents
 *
 */
public this(IDispatch idispatch) {
    type = COM.VT_DISPATCH;
    dispatchData = idispatch;
}
/**
 * Create a Variant object which represents an IUnknown interface as a VT_UNKNOWN.
 *
 * <p>The caller is expected to have appropriately invoked unknown.AddRef() before creating
 * this Variant.
 *
 * @param unknown the IUnknown object that this Variant represents
 *
 */
public this(IUnknown unknown) {
    type = COM.VT_UNKNOWN;
    unknownData = unknown;
}
/**
 * Create a Variant object which represents a Java long as a VT_I8.
 *
 * @param val the Java long value that this Variant represents
 *
 * @since 3.2
 */
 public this(long val) {
    type = COM.VT_I8;
    longData = val;
}
/**
 * Create a Variant object which represents a Java String as a VT_BSTR.
 *
 * @param string the Java String value that this Variant represents
 *
 */
public this(String string) {
    type = COM.VT_BSTR;
    stringData = string;
}
/**
 * Create a Variant object which represents a Java short as a VT_I2.
 *
 * @param val the Java short value that this Variant represents
 *
 */
public this(short val) {
    type = COM.VT_I2;
    shortData = val;
}
/**
 * Create a Variant object which represents a Java bool as a VT_BOOL.
 *
 * @param val the Java bool value that this Variant represents
 *
 */
public this(bool val) {
    type = COM.VT_BOOL;
    booleanData = val;
}

/**
 * Calling dispose will release resources associated with this Variant.
 * If the resource is an IDispatch or IUnknown interface, Release will be called.
 * If the resource is a ByRef pointer, nothing is released.
 *
 * @since 2.1
 */
public void dispose() {
    if ((type & COM.VT_BYREF) is COM.VT_BYREF) {
        return;
    }

    switch (type) {
        case COM.VT_DISPATCH :
            dispatchData.Release();
            break;
        case COM.VT_UNKNOWN :
            unknownData.Release();
            break;
        default:
    }

}
/**
 * Returns the OleAutomation object represented by this Variant.
 *
 * <p>If this Variant does not contain an OleAutomation object, an attempt is made to
 * coerce the Variant type into an OleAutomation object.  If this fails, an error is
 * thrown.  Note that OleAutomation objects must be disposed when no longer
 * needed.
 *
 * @return the OleAutomation object represented by this Variant
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant can not be coerced into an OleAutomation object</li>
 * </ul>
 */
public OleAutomation getAutomation() {
    if (type is COM.VT_EMPTY) {
        OLE.error(__FILE__, __LINE__, OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, -1);
    }
    if (type is COM.VT_DISPATCH) {
        return new OleAutomation(dispatchData);
    }
    // try to coerce the value to the desired type
    VARIANT oldPtr, newPtr;
    try {
        getData(&oldPtr);
        HRESULT result = COM.VariantChangeType(&newPtr, &oldPtr, 0, COM.VT_DISPATCH);
        if (result !is COM.S_OK)
            OLE.error(__FILE__, __LINE__, OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, result);
        Variant autoVar = new Variant();
        autoVar.setData(&newPtr);
        return autoVar.getAutomation();
    } finally {
        COM.VariantClear(&oldPtr);
        COM.VariantClear(&newPtr); // Note: This must absolutely be done AFTER the
                                  // OleAutomation object is created as Variant Clear
                                  // will result in a Release being performed on the
                                  // Dispatch object
    }
}
/**
 * Returns the IDispatch object represented by this Variant.
 *
 * <p>If this Variant does not contain an IDispatch object, an attempt is made to
 * coerce the Variant type into an IDIspatch object.  If this fails, an error is
 * thrown.
 *
 * @since 2.0
 *
 * @return the IDispatch object represented by this Variant
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant can not be coerced into an IDispatch object</li>
 * </ul>
 */
public IDispatch getDispatch() {
    if (type is COM.VT_EMPTY) {
        OLE.error(__FILE__, __LINE__, OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, -1);
    }

    if (type is COM.VT_DISPATCH) {
        return dispatchData;
    }
    // try to coerce the value to the desired type
    VARIANT oldPtr, newPtr;
    try {
        getData(&oldPtr);
        HRESULT result = COM.VariantChangeType(&newPtr, &oldPtr, 0, COM.VT_DISPATCH);
        if (result !is COM.S_OK)
            OLE.error(__FILE__, __LINE__, OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, result);
        Variant autoVar = new Variant();
        autoVar.setData(&newPtr);
        return autoVar.getDispatch();
    } finally {
        COM.VariantClear(&oldPtr);
        COM.VariantClear(&newPtr); // Note: This must absolutely be done AFTER the
                                  // OleAutomation object is created as Variant Clear
                                  // will result in a Release being performed on the
                                  // Dispatch object
    }
}
/**
 * Returns the Java bool represented by this Variant.
 *
 * <p>If this Variant does not contain a Java bool, an attempt is made to
 * coerce the Variant type into a Java bool.  If this fails, an error is thrown.
 *
 * @return the Java bool represented by this Variant
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant can not be coerced into a bool</li>
 * </ul>
 *
 */
public bool getBoolean() {
    if (type is COM.VT_EMPTY) {
        OLE.error(__FILE__, __LINE__, OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, -1);
    }
    if (type is COM.VT_BOOL) {
        return booleanData;
    }
    // try to coerce the value to the desired type
    VARIANT oldPtr, newPtr;
    try {
        getData(&oldPtr);
        HRESULT result = COM.VariantChangeType(&newPtr, &oldPtr, 0, COM.VT_BOOL);
        if (result !is COM.S_OK)
            OLE.error(__FILE__, __LINE__, OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, result);
        Variant boolVar = new Variant();
        boolVar.setData(&newPtr);
        return boolVar.getBoolean();
    } finally {
        COM.VariantClear(&oldPtr);
        COM.VariantClear(&newPtr);
    }
}
/**
 * Returns a pointer to the referenced data represented by this Variant.
 *
 * <p>If this Variant does not contain a reference to data, zero is returned.
 *
 * @return a pointer to the referenced data represented by this Variant or 0
 *
 */
public void* getByRef() {
    if (type is COM.VT_EMPTY) {
        OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, -1);
    }
    if ((type & COM.VT_BYREF)is COM.VT_BYREF) {
        return byRefPtr;
    }

    return null;
}
/**
 * Returns the Java byte represented by this Variant.
 *
 * <p>If this Variant does not contain a Java byte, an attempt is made to
 * coerce the Variant type into a Java byte.  If this fails, an error is thrown.
 *
 * @return the Java byte represented by this Variant
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant can not be coerced into a byte</li>
 * </ul>
 *
 * @since 3.3
 */
public byte getByte() {
    if (type is COM.VT_EMPTY) {
        OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, -1);
    }
    if (type is COM.VT_I1) {
        return byteData;
    }

    // try to coerce the value to the desired type
    VARIANT oldPtr, newPtr;
    try {
        getData(&oldPtr);
        int result = COM.VariantChangeType(&newPtr, &oldPtr, 0, COM.VT_I1);
        if (result !is COM.S_OK)
            OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, result);
        Variant byteVar = new Variant();
        byteVar.setData(&newPtr);
        return byteVar.getByte();
    } finally {
        COM.VariantClear(&oldPtr);
        COM.VariantClear(&newPtr);
    }
}
/**
 * Returns the Java char represented by this Variant.
 *
 * <p>If this Variant does not contain a Java char, an attempt is made to
 * coerce the Variant type into a Java char.  If this fails, an error is thrown.
 *
 * @return the Java char represented by this Variant
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant can not be coerced into a char</li>
 * </ul>
 *
 * @since 3.3
 */
public wchar getChar() {
    if (type is COM.VT_EMPTY) {
        OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, -1);
    }
    if (type is COM.VT_UI2) {
        return charData;
    }

    // try to coerce the value to the desired type
    VARIANT oldPtr, newPtr;
    try {
        getData(&oldPtr);
        int result = COM.VariantChangeType(&newPtr, &oldPtr, 0, COM.VT_UI2);
        if (result !is COM.S_OK)
            OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, result);
        Variant charVar = new Variant();
        charVar.setData(&newPtr);
        return charVar.getChar();
    } finally {
        COM.VariantClear(&oldPtr);
        COM.VariantClear(&newPtr);
    }
}
void getData(VARIANT* pData){
    if (pData is null) OLE.error(OLE.ERROR_OUT_OF_MEMORY);

    COM.VariantInit(pData);

    // set type
    pData.vt = type;
    if ((type & COM.VT_BYREF) is COM.VT_BYREF) {
        COM.MoveMemory((cast(void*)pData), &type, 2);
        COM.MoveMemory((cast(void*)pData) + 8, &byRefPtr, 4);
        return;
    }

    switch (type) {
        case COM.VT_EMPTY :
        case COM.VT_NULL :
            COM.MoveMemory((cast(void*)pData), &type, 2);
            break;
        case COM.VT_BOOL :
            COM.MoveMemory((cast(void*)pData), &type, 2);
            auto v = booleanData ? COM.VARIANT_TRUE : COM.VARIANT_FALSE;
            COM.MoveMemory((cast(void*)pData) + 8, &v, 2);
            break;
        case COM.VT_I1 :
            COM.MoveMemory((cast(void*)pData), &type, 2);
            COM.MoveMemory((cast(void*)pData) + 8, &byteData, 1);
            break;
        case COM.VT_I2 :
            COM.MoveMemory((cast(void*)pData), &type, 2);
            COM.MoveMemory((cast(void*)pData) + 8, &shortData, 2);
            break;
        case COM.VT_UI2 :
            COM.MoveMemory((cast(void*)pData), &type, 2);
            COM.MoveMemory((cast(void*)pData) + 8, &charData, 2);
            break;
        case COM.VT_I4 :
            COM.MoveMemory((cast(void*)pData), &type, 2);
            COM.MoveMemory((cast(void*)pData) + 8, &intData, 4);
            break;
        case COM.VT_I8 :
            COM.MoveMemory((cast(void*)pData), &type, 2);
            COM.MoveMemory((cast(void*)pData) + 8, &longData, 8);
            break;
        case COM.VT_R4 :
            COM.MoveMemory((cast(void*)pData), &type, 2);
            COM.MoveMemory((cast(void*)pData) + 8, &floatData, 4);
            break;
        case COM.VT_R8 :
            COM.MoveMemory((cast(void*)pData), &type, 2);
            COM.MoveMemory((cast(void*)pData) + 8, &doubleData, 8);
            break;
        case COM.VT_DISPATCH :
            dispatchData.AddRef();
            COM.MoveMemory((cast(void*)pData), &type, 2);
            auto v = cast(void*)dispatchData;
            COM.MoveMemory((cast(void*)pData) + 8, &v, 4);
            break;
        case COM.VT_UNKNOWN :
            unknownData.AddRef();
            COM.MoveMemory((cast(void*)pData), &type, 2);
            auto v = cast(void*)dispatchData;
            COM.MoveMemory((cast(void*)pData) + 8, &v, 4);
            break;
        case COM.VT_BSTR :
            COM.MoveMemory((cast(void*)pData), &type, 2);
            StringT data = StrToWCHARs(stringData);
            auto ptr = COM.SysAllocString(data.ptr);
            COM.MoveMemory((cast(void*)pData) + 8, &ptr, 4);
            break;

        default :
            OLE.error(SWT.ERROR_NOT_IMPLEMENTED);
    }
}
/**
 * Returns the Java double represented by this Variant.
 *
 * <p>If this Variant does not contain a Java double, an attempt is made to
 * coerce the Variant type into a Java double.  If this fails, an error is thrown.
 *
 * @return the Java double represented by this Variant
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant can not be coerced into a double</li>
 * </ul>
 *
 * @since 3.2
 */
public double getDouble() {
    if (type is COM.VT_EMPTY) {
        OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, -1);
    }
    if (type is COM.VT_R8) {
        return doubleData;
    }

    // try to coerce the value to the desired type
    VARIANT oldPtr, newPtr;
    try {
        getData(&oldPtr);
        int result = COM.VariantChangeType(&newPtr, &oldPtr, 0, COM.VT_R8);
        if (result !is COM.S_OK)
            OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, result);
        Variant doubleVar = new Variant();
        doubleVar.setData(&newPtr);
        return doubleVar.getDouble();
    } finally {
        COM.VariantClear(&oldPtr);
        COM.VariantClear(&newPtr);
    }
}

/**
 * Returns the Java float represented by this Variant.
 *
 * <p>If this Variant does not contain a Java float, an attempt is made to
 * coerce the Variant type into a Java float.  If this fails, an error is thrown.
 *
 * @return the Java float represented by this Variant
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant can not be coerced into a float</li>
 * </ul>
 */
public float getFloat() {
    if (type is COM.VT_EMPTY) {
        OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, -1);
    }
    if (type is COM.VT_R4) {
        return floatData;
    }

    // try to coerce the value to the desired type
    VARIANT oldPtr, newPtr;
    try {
        getData(&oldPtr);
        int result = COM.VariantChangeType(&newPtr, &oldPtr, 0, COM.VT_R4);
        if (result !is COM.S_OK)
            OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, result);
        Variant floatVar = new Variant();
        floatVar.setData(&newPtr);
        return floatVar.getFloat();
    } finally {
        COM.VariantClear(&oldPtr);
        COM.VariantClear(&newPtr);
    }

}
/**
 * Returns the Java int represented by this Variant.
 *
 * <p>If this Variant does not contain a Java int, an attempt is made to
 * coerce the Variant type into a Java int.  If this fails, an error is thrown.
 *
 * @return the Java int represented by this Variant
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant can not be coerced into a int</li>
 * </ul>
 */
public int getInt() {
    if (type is COM.VT_EMPTY) {
        OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, -1);
    }
    if (type is COM.VT_I4) {
        return intData;
    }

    // try to coerce the value to the desired type
    VARIANT oldPtr, newPtr;
    try {
        getData(&oldPtr);
        int result = COM.VariantChangeType(&newPtr, &oldPtr, 0, COM.VT_I4);
        if (result !is COM.S_OK)
            OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, result);
        Variant intVar = new Variant();
        intVar.setData(&newPtr);
        return intVar.getInt();
    } finally {
        COM.VariantClear(&oldPtr);
        COM.VariantClear(&newPtr);
    }
}
/**
 * Returns the Java long represented by this Variant.
 *
 * <p>If this Variant does not contain a Java long, an attempt is made to
 * coerce the Variant type into a Java long.  If this fails, an error is thrown.
 *
 * @return the Java long represented by this Variant
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant can not be coerced into a long</li>
 * </ul>
 *
 * @since 3.2
 */
public long getLong() {
    if (type is COM.VT_EMPTY) {
        OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, -1);
    }
    if (type is COM.VT_I8) {
        return longData;
    }

    // try to coerce the value to the desired type
    VARIANT oldPtr, newPtr;
    try {
        getData(&oldPtr);
        int result = COM.VariantChangeType(&newPtr, &oldPtr, 0, COM.VT_I8);
        if (result !is COM.S_OK)
            OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, result);
        Variant longVar = new Variant();
        longVar.setData(&newPtr);
        return longVar.getLong();
    } finally {
        COM.VariantClear(&oldPtr);
        COM.VariantClear(&newPtr);
    }
}
/**
 * Returns the Java short represented by this Variant.
 *
 * <p>If this Variant does not contain a Java short, an attempt is made to
 * coerce the Variant type into a Java short.  If this fails, an error is thrown.
 *
 * @return the Java short represented by this Variant
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant can not be coerced into a short</li>
 * </ul>
 */
public short getShort() {
    if (type is COM.VT_EMPTY) {
        OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, -1);
    }
    if (type is COM.VT_I2) {
        return shortData;
    }

    // try to coerce the value to the desired type
    VARIANT oldPtr, newPtr;
    try {
        getData(&oldPtr);
        int result = COM.VariantChangeType(&newPtr, &oldPtr, 0, COM.VT_I2);
        if (result !is COM.S_OK)
            OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, result);
        Variant shortVar = new Variant();
        shortVar.setData(&newPtr);
        return shortVar.getShort();
    } finally {
        COM.VariantClear(&oldPtr);
        COM.VariantClear(&newPtr);
    }

}
/**
 * Returns the Java String represented by this Variant.
 *
 * <p>If this Variant does not contain a Java String, an attempt is made to
 * coerce the Variant type into a Java String.  If this fails, an error is thrown.
 *
 * @return the Java String represented by this Variant
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant can not be coerced into a String</li>
 * </ul>
 */
public String getString() {
    if (type is COM.VT_EMPTY) {
        OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, -1);
    }
    if (type is COM.VT_BSTR) {
        return stringData;
    }

    // try to coerce the value to the desired type
    VARIANT oldPtr, newPtr;
    try {
        getData(&oldPtr);
        int result = COM.VariantChangeType(&newPtr, &oldPtr, 0, COM.VT_BSTR);
        if (result !is COM.S_OK)
            OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, result);

        Variant stringVar = new Variant();
        stringVar.setData(&newPtr);
        return stringVar.getString();

    } finally {
        COM.VariantClear(&oldPtr);
        COM.VariantClear(&newPtr);
    }
}
/**
 * Returns the type of the variant type.  This will be an OLE.VT_* value or
 * a bitwise combination of OLE.VT_* values as in the case of
 * OLE.VT_BSTR | OLE.VT_BYREF.
 *
 * @return the type of the variant data
 *
 * @since 2.0
 */
public short getType() {
    return type;
}
/**
 * Returns the IUnknown object represented by this Variant.
 *
 * <p>If this Variant does not contain an IUnknown object, an attempt is made to
 * coerce the Variant type into an IUnknown object.  If this fails, an error is
 * thrown.
 *
 * @return the IUnknown object represented by this Variant
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant can not be coerced into
 *          an IUnknown object</li>
 * </ul>
 */
public IUnknown getUnknown() {
    if (type is COM.VT_EMPTY) {
        OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, -1);
    }
    if (type is COM.VT_UNKNOWN) {
        return unknownData;
    }

    // try to coerce the value to the desired type
    VARIANT oldPtr, newPtr;
    try {
        getData(&oldPtr);
        int result = COM.VariantChangeType(&newPtr, &oldPtr, 0, COM.VT_UNKNOWN);
        if (result !is COM.S_OK)
            OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE, result);
        Variant unknownVar = new Variant();
        unknownVar.setData(&newPtr);
        return unknownVar.getUnknown();
    } finally {
        COM.VariantClear(&oldPtr);
        COM.VariantClear(&newPtr); // Note: This must absolutely be done AFTER the
                                  // IUnknown object is created as Variant Clear
                                  // will result in a Release being performed on the
                                  // Dispatch object
    }
}
/**
 * Update the by reference value of this variant with a new bool value.
 *
 * @param val the new bool value
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant is not
 *          a (VT_BYREF | VT_BOOL) object</li>
 * </ul>
 *
 * @since 2.1
 */
public void setByRef(bool val) {
    if ((type & COM.VT_BYREF) is 0 || (type & COM.VT_BOOL) is 0) {
        OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE);
    }
    auto v = val ? COM.VARIANT_TRUE : COM.VARIANT_FALSE;
    COM.MoveMemory(byRefPtr, &v, 2);
}
/**
 * Update the by reference value of this variant with a new float value.
 *
 * @param val the new float value
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant is not
 *          a (VT_BYREF | VT_R4) object</li>
 * </ul>
 *
 * @since 2.1
 */
public void setByRef(float val) {
    if ((type & COM.VT_BYREF) is 0 || (type & COM.VT_R4) is 0) {
        OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE);
    }
    COM.MoveMemory(byRefPtr, &val, 4);
}
/**
 * Update the by reference value of this variant with a new integer value.
 *
 * @param val the new integer value
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant is not a (VT_BYREF | VT_I4) object</li>
 * </ul>
 *
 * @since 2.1
 */
public void setByRef(int val) {
    if ((type & COM.VT_BYREF) is 0 || (type & COM.VT_I4) is 0) {
        OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE);
    }
    COM.MoveMemory(byRefPtr, &val, 4);
}
/**
 * Update the by reference value of this variant with a new short value.
 *
 * @param val the new short value
 *
 * @exception SWTException <ul>
 *     <li>ERROR_CANNOT_CHANGE_VARIANT_TYPE when type of Variant is not a (VT_BYREF | VT_I2) object
 * </ul>
 *
 * @since 2.1
 */
public void setByRef(short val) {
    if ((type & COM.VT_BYREF) is 0 || (type & COM.VT_I2) is 0) {
        OLE.error(OLE.ERROR_CANNOT_CHANGE_VARIANT_TYPE);
    }
    COM.MoveMemory(byRefPtr, &val, 2);
}

void setData(VARIANT* pData){
    if (pData is null) OLE.error(OLE.ERROR_INVALID_ARGUMENT);

    short[1] dataType ;
    COM.MoveMemory(dataType.ptr, (cast(void*)pData), 2);
    type = dataType[0];

    if ((type & COM.VT_BYREF) is COM.VT_BYREF) {
        void*[1] newByRefPtr;
        OS.MoveMemory(newByRefPtr.ptr, (cast(void*)pData) + 8, 4);
        byRefPtr = newByRefPtr[0];
        return;
    }

    switch (type) {
        case COM.VT_EMPTY :
        case COM.VT_NULL :
            break;
        case COM.VT_BOOL :
            short[1] newBooleanData;
            COM.MoveMemory(newBooleanData.ptr, (cast(void*)pData) + 8, 2);
            booleanData = (newBooleanData[0] !is COM.VARIANT_FALSE);
            break;
        case COM.VT_I1 :
            byte[1] newByteData;
            COM.MoveMemory(newByteData.ptr, (cast(void*)pData) + 8, 1);
            byteData = newByteData[0];
            break;
        case COM.VT_I2 :
            short[1] newShortData;
            COM.MoveMemory(newShortData.ptr, (cast(void*)pData) + 8, 2);
            shortData = newShortData[0];
            break;
        case COM.VT_UI2 :
            wchar[1] newCharData;
            COM.MoveMemory(newCharData.ptr, (cast(void*)pData) + 8, 2);
            charData = newCharData[0];
            break;
        case COM.VT_I4 :
            int[1] newIntData;
            OS.MoveMemory(newIntData.ptr, (cast(void*)pData) + 8, 4);
            intData = newIntData[0];
            break;
        case COM.VT_I8 :
            long[1] newLongData;
            OS.MoveMemory(newLongData.ptr, (cast(void*)pData) + 8, 8);
            longData = newLongData[0];
            break;
        case COM.VT_R4 :
            float[1] newFloatData;
            COM.MoveMemory(newFloatData.ptr, (cast(void*)pData) + 8, 4);
            floatData = newFloatData[0];
            break;
        case COM.VT_R8 :
            double[1] newDoubleData;
            COM.MoveMemory(newDoubleData.ptr, (cast(void*)pData) + 8, 8);
            doubleData = newDoubleData[0];
            break;
        case COM.VT_DISPATCH : {
            IDispatch[1] ppvObject;
            OS.MoveMemory(ppvObject.ptr, (cast(void*)pData) + 8, 4);
            if (ppvObject[0] is null) {
                type = COM.VT_EMPTY;
                break;
            }
            dispatchData = ppvObject[0];
            dispatchData.AddRef();
            break;
        }
        case COM.VT_UNKNOWN : {
            IUnknown[1] ppvObject;
            OS.MoveMemory(ppvObject.ptr, (cast(void*)pData) + 8, 4);
            if (ppvObject[0] is null) {
                type = COM.VT_EMPTY;
                break;
            }
            unknownData = ppvObject[0];
            unknownData.AddRef();
            break;
        }
        case COM.VT_BSTR :
            // get the address of the memory in which the string resides
            wchar*[1] hMem;
            OS.MoveMemory(hMem.ptr, (cast(void*)pData) + 8, 4);
            if (hMem[0] is null) {
                type = COM.VT_EMPTY;
                break;
            }
            // Get the size of the string from the OS - the size is expressed in number
            // of bytes - each unicode character is 2 bytes.
            int size = COM.SysStringByteLen(hMem[0]);
            if (size > 0){
                // get the unicode character array from the global memory and create a String
                wchar[] buffer = new wchar[(size + 1) /2]; // add one to avoid rounding errors
                COM.MoveMemory(buffer.ptr, hMem[0], size);
                stringData = WCHARsToStr( buffer );
            } else {
                stringData = ""; //$NON-NLS-1$
            }
            break;

        default :
            // try coercing it into one of the known forms
            auto newPData = cast(VARIANT*) OS.GlobalAlloc(OS.GMEM_FIXED | OS.GMEM_ZEROINIT, VARIANT.sizeof);
            if (COM.VariantChangeType(newPData, pData, 0, COM.VT_R4) is COM.S_OK) {
                setData(newPData);
            } else if (COM.VariantChangeType(newPData, pData, 0, COM.VT_I4) is COM.S_OK) {
                setData(newPData);
            } else if (COM.VariantChangeType(newPData, pData, 0, COM.VT_BSTR) is COM.S_OK) {
                setData(newPData);
            }
            COM.VariantClear(newPData);
            OS.GlobalFree(newPData);
            break;
    }
}

/**
 * Returns a string containing a concise, human-readable
 * description of the receiver.
 *
 * @return a string representation of the Variant
 */
override
public String toString () {
    switch (type) {
        case COM.VT_BOOL :
            return "VT_BOOL{"~String_valueOf(booleanData)~"}";
        case COM.VT_I1 :
            return "VT_I1{"~String_valueOf(byteData)~"}";
        case COM.VT_I2 :
            return "VT_I2{"~String_valueOf(shortData)~"}";
        case COM.VT_UI2 :
            return "VT_UI2{"~ dcharToString(charData) ~"}";
        case COM.VT_I4 :
            return "VT_I4{"~String_valueOf(intData)~"}";
        case COM.VT_I8 :
            return "VT_I8{"~String_valueOf(longData)~"}";
        case COM.VT_R4 :
            return "VT_R4{"~String_valueOf(floatData)~"}";
        case COM.VT_R8 :
            return "VT_R8{"~String_valueOf(doubleData)~"}";
        case COM.VT_BSTR :
            return "VT_BSTR{"~stringData~"}";
        case COM.VT_DISPATCH :
            return Format("VT_DISPATCH{{0x{:X}}", cast(void*) (dispatchData is null ? null : dispatchData));
        case COM.VT_UNKNOWN :
            return Format("VT_UNKNOWN{{0x{:X}}", cast(void*) (unknownData is null ? null : unknownData));
        case COM.VT_EMPTY :
            return "VT_EMPTY";
        case COM.VT_NULL :
            return "VT_NULL";
        default:
     }
    if ((type & COM.VT_BYREF) !is 0) {
        return Format("VT_BYREF|{}{{{}}",(type & ~COM.VT_BYREF), byRefPtr );
    }
    return "Unsupported Type "~String_valueOf(type);
}
}
