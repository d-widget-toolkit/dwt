module org.eclipse.swt.internal.mozilla.nsIDOMEventTarget;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIDOMEvent;
import org.eclipse.swt.internal.mozilla.nsIDOMEventListener;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMEVENTTARGET_IID_STR = "1c773b30-d1cf-11d2-bd95-00805f8ae3f4";

const nsIID NS_IDOMEVENTTARGET_IID= 
  {0x1c773b30, 0xd1cf, 0x11d2, 
    [ 0xbd, 0x95, 0x00, 0x80, 0x5f, 0x8a, 0xe3, 0xf4 ]};

//extern(System)

interface nsIDOMEventTarget : nsISupports {

  static const char[] IID_STR = NS_IDOMEVENTTARGET_IID_STR;
  static const nsIID IID = NS_IDOMEVENTTARGET_IID;

extern(System):
  nsresult AddEventListener(nsAString * type, nsIDOMEventListener listener, PRBool useCapture);
  nsresult RemoveEventListener(nsAString * type, nsIDOMEventListener listener, PRBool useCapture);
  nsresult DispatchEvent(nsIDOMEvent evt, PRBool *_retval);

}

