module org.eclipse.swt.internal.mozilla.nsIObjectInputStream;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIBinaryInputStream;

const char[] NS_IOBJECTINPUTSTREAM_IID_STR = "6c248606-4eae-46fa-9df0-ba58502368eb";

const nsIID NS_IOBJECTINPUTSTREAM_IID= 
  {0x6c248606, 0x4eae, 0x46fa, 
    [ 0x9d, 0xf0, 0xba, 0x58, 0x50, 0x23, 0x68, 0xeb ]};

interface nsIObjectInputStream : nsIBinaryInputStream {

  static const char[] IID_STR = NS_IOBJECTINPUTSTREAM_IID_STR;
  static const nsIID IID = NS_IOBJECTINPUTSTREAM_IID;

extern(System):
  nsresult ReadObject(PRBool aIsStrongRef, nsISupports *_retval);
  nsresult ReadID(nsID *aID);
  char * GetBuffer(PRUint32 aLength, PRUint32 aAlignMask);
  void PutBuffer(char * aBuffer, PRUint32 aLength);

}

