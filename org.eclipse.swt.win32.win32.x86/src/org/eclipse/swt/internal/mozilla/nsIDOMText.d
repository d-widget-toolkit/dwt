module org.eclipse.swt.internal.mozilla.nsIDOMText;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;

import org.eclipse.swt.internal.mozilla.nsIDOMCharacterData;

const char[] NS_IDOMTEXT_IID_STR = "a6cf9082-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMTEXT_IID= 
  {0xa6cf9082, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMText : nsIDOMCharacterData {

  static const char[] IID_STR = NS_IDOMTEXT_IID_STR;
  static const nsIID IID = NS_IDOMTEXT_IID;

extern(System):
  nsresult SplitText(PRUint32 offset, nsIDOMText *_retval);

}

