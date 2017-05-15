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
module org.eclipse.swt.browser.InputStream;

import java.lang.all;

import XPCOM = org.eclipse.swt.internal.mozilla.XPCOM;

import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIInputStream;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.Common;

class InputStream : nsIInputStream {
    //XPCOMObject inputStream;
    int refCount = 0;

    byte[] buffer;
    int index = 0;
    
this (byte[] buffer) {
    this.buffer = buffer;
    index = 0;
}

extern(System)
nsrefcnt AddRef () {
    refCount++;
    return refCount;
}

extern(System)
nsresult QueryInterface (in nsID* riid, void** ppvObject) {
    if (riid is null || ppvObject is null) return XPCOM.NS_ERROR_NO_INTERFACE;
    //nsID guid = new nsID ();
    //XPCOM.memmove (guid, riid, nsID.sizeof);
    
    if (*riid == nsISupports.IID) {
        *ppvObject = cast(void*)cast(nsISupports)this;
        AddRef ();
        return XPCOM.NS_OK;
    }
    if (*riid == nsIInputStream.IID) {
        *ppvObject = cast(void*)cast(nsIInputStream)this;
        AddRef ();
        return XPCOM.NS_OK;
    }   
    *ppvObject = null;
    return XPCOM.NS_ERROR_NO_INTERFACE;
}

extern(System)
nsrefcnt Release () {
    refCount--;
    //if (refCount is 0) disposeCOMInterfaces ();
    return refCount;
}

/* nsIInputStream implementation */

extern(System)
nsresult Close () {
    buffer = null;
    index = 0;
    return XPCOM.NS_OK;
}

extern(System)
nsresult Available (PRUint32* _retval) {
    PRUint32 available = buffer is null ? 0 : buffer.length - index;
    *_retval = available;
    //XPCOM.memmove (_retval, new int[] {available}, 4);
    return XPCOM.NS_OK;
}

extern(System)
nsresult Read(byte* aBuf, PRUint32 aCount, PRUint32* _retval) {
    int max = Math.min (aCount, buffer is null ? 0 : buffer.length - index);
    if (aBuf is null)
        assert(0);
    if (max > 0) {
        //byte[] src = new byte[max];
        //System.arraycopy (buffer, index, src, 0, max);
        //XPCOM.memmove (aBuf, src, max);
        aBuf[0..max] = buffer[index..$];
        index += max;
    }
    *_retval = max;
    return XPCOM.NS_OK;
}

extern(System)
nsresult ReadSegments (nsWriteSegmentFun aWriter, void* aClosure, PRUint32 aCount, PRUint32* _retval) {
    int max = Math.min (aCount, buffer is null ? 0 : buffer.length - index);
    PRUint32 cnt = max;
    while (cnt > 0) {
        PRUint32 aWriteCount;
        nsresult rc = aWriter (cast(nsIInputStream)this, aClosure, buffer.ptr, index, cnt, &aWriteCount);
        if (rc !is XPCOM.NS_OK) break;
        index += aWriteCount;
        cnt -= aWriteCount;
    }
    //XPCOM.memmove (_retval, new int[] {max - cnt}, 4);
    *_retval = (max - cnt);
    return XPCOM.NS_OK;
}

extern(System)
nsresult IsNonBlocking (PRBool* _retval) {
    /* blocking */
    *_retval = 0;
    return XPCOM.NS_OK;
}       
}
