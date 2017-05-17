module org.eclipse.swt.internal.mozilla.nsIDOMWindowCollection;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIDOMWindow;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMWINDOWCOLLECTION_IID_STR = "a6cf906f-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMWINDOWCOLLECTION_IID= 
  {0xa6cf906f, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMWindowCollection : nsISupports {

  static const char[] IID_STR = NS_IDOMWINDOWCOLLECTION_IID_STR;
  static const nsIID IID = NS_IDOMWINDOWCOLLECTION_IID;

extern(System):
  nsresult GetLength(PRUint32 *aLength);
  nsresult Item(PRUint32 index, nsIDOMWindow *_retval);
  nsresult NamedItem(nsAString * name, nsIDOMWindow *_retval);

}

