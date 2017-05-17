module org.eclipse.swt.internal.mozilla.nsIInputStream;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

typedef nsresult function(nsIInputStream aInStream,
	void *aClosure,
	byte *aFromSegment,
	PRUint32 aToOffset,
	PRUint32 aCount,
	PRUint32 *aWriteCount) nsWriteSegmentFun;

const char[] NS_IINPUTSTREAM_IID_STR = "fa9c7f6c-61b3-11d4-9877-00c04fa0cf4a";

const nsIID NS_IINPUTSTREAM_IID= 
  {0xfa9c7f6c, 0x61b3, 0x11d4, 
    [ 0x98, 0x77, 0x00, 0xc0, 0x4f, 0xa0, 0xcf, 0x4a ]};

interface nsIInputStream : nsISupports {

  static const char[] IID_STR = NS_IINPUTSTREAM_IID_STR;
  static const nsIID IID = NS_IINPUTSTREAM_IID;

extern(System):
  nsresult Close();
  nsresult Available(PRUint32 *_retval);
  nsresult Read(byte * aBuf, PRUint32 aCount, PRUint32 *_retval);
  nsresult ReadSegments(nsWriteSegmentFun aWriter, void * aClosure, PRUint32 aCount, PRUint32 *_retval);
  nsresult IsNonBlocking(PRBool *_retval);

}

