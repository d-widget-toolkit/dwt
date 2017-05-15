module org.eclipse.swt.internal.mozilla.nsIObjectOutputStream;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIBinaryOutputStream;

const char[] NS_IOBJECTOUTPUTSTREAM_IID_STR = "92c898ac-5fde-4b99-87b3-5d486422094b";

const nsIID NS_IOBJECTOUTPUTSTREAM_IID= 
  {0x92c898ac, 0x5fde, 0x4b99, 
    [ 0x87, 0xb3, 0x5d, 0x48, 0x64, 0x22, 0x09, 0x4b ]};

interface nsIObjectOutputStream : nsIBinaryOutputStream {

  static const char[] IID_STR = NS_IOBJECTOUTPUTSTREAM_IID_STR;
  static const nsIID IID = NS_IOBJECTOUTPUTSTREAM_IID;

extern(System):
  nsresult WriteObject(nsISupports aObject, PRBool aIsStrongRef);
  nsresult WriteSingleRefObject(nsISupports aObject);
  nsresult WriteCompoundObject(nsISupports aObject, nsIID * aIID, PRBool aIsStrongRef);
  nsresult WriteID(nsID * aID);
  char * GetBuffer(PRUint32 aLength, PRUint32 aAlignMask);
  void PutBuffer(char * aBuffer, PRUint32 aLength);

}

