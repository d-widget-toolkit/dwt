module org.eclipse.swt.internal.mozilla.nsIDOMNodeList;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIDOMNode;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMNODELIST_IID_STR = "a6cf907d-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMNODELIST_IID= 
  {0xa6cf907d, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

//extern(System)

interface nsIDOMNodeList : nsISupports {

  static const char[] IID_STR = NS_IDOMNODELIST_IID_STR;
  static const nsIID IID = NS_IDOMNODELIST_IID;

extern(System):
  nsresult Item(PRUint32 index, nsIDOMNode *_retval);
  nsresult GetLength(PRUint32 *aLength);

}

