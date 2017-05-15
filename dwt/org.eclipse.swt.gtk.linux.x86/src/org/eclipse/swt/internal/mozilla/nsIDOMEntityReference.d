module org.eclipse.swt.internal.mozilla.nsIDOMEntityReference;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;

import org.eclipse.swt.internal.mozilla.nsIDOMNode;

const char[] NS_IDOMENTITYREFERENCE_IID_STR = "a6cf907a-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMENTITYREFERENCE_IID= 
  {0xa6cf907a, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMEntityReference : nsIDOMNode {

  static const char[] IID_STR = NS_IDOMENTITYREFERENCE_IID_STR;
  static const nsIID IID = NS_IDOMENTITYREFERENCE_IID;

extern(System):
}

