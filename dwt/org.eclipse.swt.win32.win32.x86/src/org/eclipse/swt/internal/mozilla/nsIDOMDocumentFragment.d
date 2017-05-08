module org.eclipse.swt.internal.mozilla.nsIDOMDocumentFragment;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;

import org.eclipse.swt.internal.mozilla.nsIDOMNode;

const char[] NS_IDOMDOCUMENTFRAGMENT_IID_STR = "a6cf9076-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMDOCUMENTFRAGMENT_IID= 
  {0xa6cf9076, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMDocumentFragment : nsIDOMNode {
  static const char[] IID_STR = NS_IDOMDOCUMENTFRAGMENT_IID_STR;
  static const nsIID IID = NS_IDOMDOCUMENTFRAGMENT_IID;

extern(System):
}

