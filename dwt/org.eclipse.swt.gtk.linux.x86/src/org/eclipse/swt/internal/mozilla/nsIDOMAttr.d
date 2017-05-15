module org.eclipse.swt.internal.mozilla.nsIDOMAttr;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIDOMNode;
import org.eclipse.swt.internal.mozilla.nsIDOMElement;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_IDOMATTR_IID_STR = "a6cf9070-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMATTR_IID= 
  {0xa6cf9070, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMAttr : nsIDOMNode {

  static const char[] IID_STR = NS_IDOMATTR_IID_STR;
  static const nsIID IID = NS_IDOMATTR_IID;

extern(System):
  nsresult GetName(nsAString * aName);
  nsresult GetSpecified(PRBool *aSpecified);
  nsresult GetValue(nsAString * aValue);
  nsresult SetValue(nsAString * aValue);
  nsresult GetOwnerElement(nsIDOMElement  *aOwnerElement);

}

