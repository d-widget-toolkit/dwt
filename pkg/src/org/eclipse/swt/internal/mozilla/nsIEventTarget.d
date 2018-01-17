module org.eclipse.swt.internal.mozilla.nsIEventTarget;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsID;

const char[] NS_IEVENTTARGET_IID_STR = "ea99ad5b-cc67-4efb-97c9-2ef620a59f2a";

const nsIID NS_IEVENTTARGET_IID= 
  {0xea99ad5b, 0xcc67, 0x4efb, 
    [ 0x97, 0xc9, 0x2e, 0xf6, 0x20, 0xa5, 0x9f, 0x2a ]};

interface nsIEventTarget : nsISupports {

  static const char[] IID_STR = NS_IEVENTTARGET_IID_STR;
  static const nsIID IID = NS_IEVENTTARGET_IID;

extern(System):
  nsresult PostEvent(PLEvent * aEvent);
  nsresult IsOnCurrentThread(PRBool *_retval);
}

