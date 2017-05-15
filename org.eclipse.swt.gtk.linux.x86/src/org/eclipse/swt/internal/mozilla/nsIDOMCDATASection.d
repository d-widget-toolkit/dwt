module org.eclipse.swt.internal.mozilla.nsIDOMCDATASection;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;

import org.eclipse.swt.internal.mozilla.nsIDOMText;

const char[] NS_IDOMCDATASECTION_IID_STR = "a6cf9071-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMCDATASECTION_IID= 
  {0xa6cf9071, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMCDATASection : nsIDOMText {

extern(System):
  static const char[] IID_STR = NS_IDOMCDATASECTION_IID_STR;
  static const nsIID IID = NS_IDOMCDATASECTION_IID;

}

