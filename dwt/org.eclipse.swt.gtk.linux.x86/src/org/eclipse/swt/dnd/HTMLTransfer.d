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
module org.eclipse.swt.dnd.HTMLTransfer;

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
 * The class <code>HTMLTransfer</code> provides a platform specific mechanism
 * for converting text in HTML format represented as a java <code>String</code>
 * to a platform specific representation of the data and vice versa.
 *
 * <p>An example of a java <code>String</code> containing HTML text is shown
 * below:</p>
 *
 * <code><pre>
 *     String htmlData = "<p>This is a paragraph of text.</p>";
 * </code></pre>
 *
 * @see Transfer
 */
public class HTMLTransfer : ByteArrayTransfer {

    private static HTMLTransfer _instance;
    private static const String TEXT_HTML = "text/html"; //$NON-NLS-1$
    private static const int TEXT_HTML_ID;
    private static const String TEXT_HTML2 = "TEXT/HTML"; //$NON-NLS-1$
    private static const int TEXT_HTML2_ID;

static this(){
    _instance = new HTMLTransfer();
    TEXT_HTML_ID = registerType(TEXT_HTML);
    TEXT_HTML2_ID = registerType(TEXT_HTML2);
}

private this() {}

/**
 * Returns the singleton instance of the HTMLTransfer class.
 *
 * @return the singleton instance of the HTMLTransfer class
 */
public static HTMLTransfer getInstance () {
    return _instance;
}

/**
 * This implementation of <code>javaToNative</code> converts HTML-formatted text
 * represented by a java <code>String</code> to a platform specific representation.
 *
 * @param object a java <code>String</code> containing HTML text
 * @param transferData an empty <code>TransferData</code> object that will
 *      be filled in on return with the platform specific format of the data
 * 
 * @see Transfer#nativeToJava
 */
public override void javaToNative (Object object, TransferData transferData){
    transferData.result = 0;
    if (!checkHTML(object) || !isSupportedType(transferData)) {
        DND.error(DND.ERROR_INVALID_DATA);
    }
    String str = stringcast(object);
    char* pValue = cast(char*)OS.g_malloc(str.length);
    if (pValue is null) return;
    pValue[0 .. str.length ] = str;
    transferData.length = cast(int)/*64bit*/str.length;
    transferData.format = 8;
    transferData.pValue = pValue;
    transferData.result = 1;
}

/**
 * This implementation of <code>nativeToJava</code> converts a platform specific
 * representation of HTML text to a java <code>String</code>.
 *
 * @param transferData the platform specific representation of the data to be converted
 * @return a java <code>String</code> containing HTML text if the conversion was successful;
 *      otherwise null
 * 
 * @see Transfer#javaToNative
 */
public override Object nativeToJava(TransferData transferData){
    if ( !isSupportedType(transferData) ||  transferData.pValue is null ) return null;
    /* Ensure byteCount is a multiple of 2 bytes */
    auto size = (transferData.format * transferData.length / 8) / 2 * 2;
    if (size <= 0) return null;
    String chars = transferData.pValue[ 0 .. size ]._idup();
    auto end = chars.indexOf('\0');
    return new ArrayWrapperString( (end is -1 )? chars : chars[ 0 .. end ] );
}
protected override int[] getTypeIds() {
    return [TEXT_HTML_ID, TEXT_HTML2_ID];
}

protected override String[] getTypeNames() {
    return [TEXT_HTML, TEXT_HTML2];
}

bool checkHTML(Object object) {
    if( object is null ) return false;
    auto arr = cast(ArrayWrapperString)object;
    if( arr is null ) return false;
    if( arr.array.length is 0 ) return false;
    return true;
}

protected override bool validate(Object object) {
    return checkHTML(object);
}
}
