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
module org.eclipse.swt.dnd.RTFTransfer;

import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.gtk.OS;
import org.eclipse.swt.dnd.ByteArrayTransfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.dnd.DND;

import java.lang.all;
version(Tango){
static import tango.text.Util;
} else { // Phobos
}

/**
 * The class <code>RTFTransfer</code> provides a platform specific mechanism
 * for converting text in RTF format represented as a java <code>String</code>
 * to a platform specific representation of the data and vice versa.
 *
 * <p>An example of a java <code>String</code> containing RTF text is shown
 * below:</p>
 *
 * <code><pre>
 *     String rtfData = "{\\rtf1{\\colortbl;\\red255\\green0\\blue0;}\\uc1\\b\\i Hello World}";
 * </code></pre>
 *
 * @see Transfer
 */
public class RTFTransfer : ByteArrayTransfer {

    private static RTFTransfer _instance;
    private static const String TEXT_RTF = "text/rtf"; //$NON-NLS-1$
    private static const int TEXT_RTF_ID;
    private static const String TEXT_RTF2 = "TEXT/RTF"; //$NON-NLS-1$
    private static const int TEXT_RTF2_ID;
    private static const String APPLICATION_RTF = "application/rtf"; //$NON-NLS-1$
    private static const int APPLICATION_RTF_ID;

static this(){
    TEXT_RTF_ID = registerType(TEXT_RTF);
    TEXT_RTF2_ID = registerType(TEXT_RTF2);
    APPLICATION_RTF_ID = registerType(APPLICATION_RTF);
    _instance = new RTFTransfer();
}

private this() {}

/**
 * Returns the singleton instance of the RTFTransfer class.
 *
 * @return the singleton instance of the RTFTransfer class
 */
public static RTFTransfer getInstance () {
    return _instance;
}

/**
 * This implementation of <code>javaToNative</code> converts RTF-formatted text
 * represented by a java <code>String</code> to a platform specific representation.
 *
 * @param object a java <code>String</code> containing RTF text
 * @param transferData an empty <code>TransferData</code> object that will
 *      be filled in on return with the platform specific format of the data
 *
 * @see Transfer#nativeToJava
 */
public override void javaToNative (Object object, TransferData transferData){
    transferData.result = 0;
    if (!checkRTF(object) || !isSupportedType(transferData)) {
        DND.error(DND.ERROR_INVALID_DATA);
    }
    String str = stringcast(object);
    char* pValue = cast(char*)OS.g_malloc(str.length + 1);
    if (pValue is null) return;
    pValue[ 0 .. str.length ] = str;
    pValue[ str.length ] = '\0';
    transferData.length = cast(int)/*64bit*/str.length;
    transferData.format = 8;
    transferData.pValue = pValue;
    transferData.result = 1;
}

/**
 * This implementation of <code>nativeToJava</code> converts a platform specific
 * representation of RTF text to a java <code>String</code>.
 *
 * @param transferData the platform specific representation of the data to be converted
 * @return a java <code>String</code> containing RTF text if the conversion was successful;
 *      otherwise null
 *
 * @see Transfer#javaToNative
 */
public override Object nativeToJava(TransferData transferData){
    if ( !isSupportedType(transferData) ||  transferData.pValue is null ) return null;
    auto size = transferData.format * transferData.length / 8;
    if (size is 0) return null;
    char [] chars = transferData.pValue[ 0 .. size];
    auto end = chars.indexOf( '\0' );
    return new ArrayWrapperString( (end is -1)? chars.dup : chars[ 0 .. end ].dup );
}

protected override int[] getTypeIds() {
    return [TEXT_RTF_ID, TEXT_RTF2_ID, APPLICATION_RTF_ID];
}

protected override String[] getTypeNames() {
    return [TEXT_RTF, TEXT_RTF2, APPLICATION_RTF];
}

bool checkRTF(Object object) {
    if( object is null ) return false;
    ArrayWrapperString astr = cast(ArrayWrapperString)object;
    if( astr is null ) return false;
    return astr.array.length > 0;
}

protected override bool validate(Object object) {
    return checkRTF(object);
}
}
