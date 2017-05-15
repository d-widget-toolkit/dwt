module org.eclipse.swt.internal.mozilla.nsIOutputStream;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIInputStream;

typedef nsresult function(nsIOutputStream aOutStream,
	void *aClosure,
	char *aToSegment,
	PRUint32 aFromOffset,
	PRUint32 aCount,
	PRUint32 *aReadCount) nsReadSegmentFun;

const char[] NS_IOUTPUTSTREAM_IID_STR = "0d0acd2a-61b4-11d4-9877-00c04fa0cf4a";

const nsIID NS_IOUTPUTSTREAM_IID= 
  {0x0d0acd2a, 0x61b4, 0x11d4, 
    [ 0x98, 0x77, 0x00, 0xc0, 0x4f, 0xa0, 0xcf, 0x4a ]};

interface nsIOutputStream : nsISupports {

  static const char[] IID_STR = NS_IOUTPUTSTREAM_IID_STR;
  static const nsIID IID = NS_IOUTPUTSTREAM_IID;

extern(System):
  nsresult Close();
  nsresult Flush();
  nsresult Write(char *aBuf, PRUint32 aCount, PRUint32 *_retval);
  nsresult WriteFrom(nsIInputStream aFromStream, PRUint32 aCount, PRUint32 *_retval);
  nsresult WriteSegments(nsReadSegmentFun aReader, void * aClosure, PRUint32 aCount, PRUint32 *_retval);
  nsresult IsNonBlocking(PRBool *_retval);

}

