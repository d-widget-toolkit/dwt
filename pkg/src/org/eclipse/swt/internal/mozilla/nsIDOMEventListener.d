module org.eclipse.swt.internal.mozilla.nsIDOMEventListener;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIDOMEvent;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMEVENTLISTENER_IID_STR = "df31c120-ded6-11d1-bd85-00805f8ae3f4";
const nsIID NS_IDOMEVENTLISTENER_IID= 
  {0xdf31c120, 0xded6, 0x11d1, 
    [ 0xbd, 0x85, 0x00, 0x80, 0x5f, 0x8a, 0xe3, 0xf4 ]};

interface nsIDOMEventListener : nsISupports {

  static const char[] IID_STR = NS_IDOMEVENTLISTENER_IID_STR;
  static const nsIID IID = NS_IDOMEVENTLISTENER_IID;

extern(System):
  nsresult HandleEvent(nsIDOMEvent event);
}

