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
module org.eclipse.swt.dnd.TextTransfer;

import org.eclipse.swt.internal.Converter;
import org.eclipse.swt.internal.gtk.OS;
import java.lang.all;
import org.eclipse.swt.dnd.ByteArrayTransfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.dnd.DND;


/**
 * The class <code>TextTransfer</code> provides a platform specific mechanism
 * for converting plain text represented as a java <code>String</code>
 * to a platform specific representation of the data and vice versa.
 *
 * <p>An example of a java <code>String</code> containing plain text is shown
 * below:</p>
 *
 * <code><pre>
 *     String textData = "Hello World";
 * </code></pre>
 *
 * @see Transfer
 */
public class TextTransfer : ByteArrayTransfer {

    private static TextTransfer _instance;
    private static const String COMPOUND_TEXT = "COMPOUND_TEXT"; //$NON-NLS-1$
    private static const String UTF8_STRING = "UTF8_STRING"; //$NON-NLS-1$
    private static const String STRING = "STRING"; //$NON-NLS-1$
    private static const int COMPOUND_TEXT_ID;
    private static const int UTF8_STRING_ID;
    private static const int STRING_ID;

static this(){
    COMPOUND_TEXT_ID = registerType(COMPOUND_TEXT);
    UTF8_STRING_ID = registerType(UTF8_STRING);
    STRING_ID = registerType(STRING);
    _instance = new TextTransfer();
}

private this() {}

/**
 * Returns the singleton instance of the TextTransfer class.
 *
 * @return the singleton instance of the TextTransfer class
 */
public static TextTransfer getInstance () {
    return _instance;
}

/**
 * This implementation of <code>javaToNative</code> converts plain text
 * represented by a java <code>String</code> to a platform specific representation.
 *
 * @param object a java <code>String</code> containing text
 * @param transferData an empty <code>TransferData</code> object that will
 *      be filled in on return with the platform specific format of the data
 *
 * @see Transfer#nativeToJava
 */
override public void javaToNative (Object object, TransferData transferData) {
    transferData.result = 0;
    if (!checkText(object) || !isSupportedType(transferData)) {
        DND.error(DND.ERROR_INVALID_DATA);
    }
    String str = stringcast(object);
    char* utf8 = toStringz(str);
    if  (transferData.type is cast(void*) COMPOUND_TEXT_ID) {
        void* encoding;
        int format;
        char* ctext;
        int length;
        bool result = cast(bool) OS.gdk_utf8_to_compound_text(utf8, &encoding, &format, &ctext, &length);
        if (!result) return;
        transferData.type = encoding;
        transferData.format = format;
        transferData.length = length;
        transferData.pValue = ctext;
        transferData.result = 1;
    }
    if (transferData.type is cast(void*)UTF8_STRING_ID) {
        char* pValue = cast(char*)OS.g_malloc(str.length+1);
        if (pValue is  null) return;
        pValue[ 0 .. str.length ] = str;
        pValue[ str.length ] = '\0';
        transferData.type = cast(void*)UTF8_STRING_ID;
        transferData.format = 8;
        transferData.length = cast(int)/*64bit*/str.length;
        transferData.pValue = pValue;
        transferData.result = 1;
    }
    if (transferData.type is cast(void*)STRING_ID) {
        auto string_target = OS.gdk_utf8_to_string_target(utf8);
        if (string_target is  null) return;
        transferData.type = cast(void*)STRING_ID;
        transferData.format = 8;
        transferData.length = OS.strlen(string_target);
        transferData.pValue = string_target;
        transferData.result = 1;
    }
}

/**
 * This implementation of <code>nativeToJava</code> converts a platform specific
 * representation of plain text to a java <code>String</code>.
 *
 * @param transferData the platform specific representation of the data to be converted
 * @return a java <code>String</code> containing text if the conversion was successful; otherwise null
 *
 * @see Transfer#javaToNative
 */
override public Object nativeToJava(TransferData transferData){
    if (!isSupportedType(transferData) ||  transferData.pValue is null) return null;
    char** list;
    ptrdiff_t count = OS.gdk_text_property_to_utf8_list(transferData.type, transferData.format, transferData.pValue, transferData.length, &list);
    if (count is 0) return null;
    String utf8 = fromStringz( list[0] )._idup();
    OS.g_strfreev(list);
    return new ArrayWrapperString( utf8 );
}

override protected int[] getTypeIds() {
    return [UTF8_STRING_ID, COMPOUND_TEXT_ID, STRING_ID];
}

override protected String[] getTypeNames() {
    return [UTF8_STRING, COMPOUND_TEXT, STRING];
}

bool checkText(Object object) {
    if( object is null ) return false;
    ArrayWrapperString astr = cast(ArrayWrapperString)object;
    if( astr is null ) return false;
    return astr.array.length > 0;
}

protected override bool validate(Object object) {
    return checkText(object);
}
}
