module org.eclipse.swt.internal.mozilla.nsIDOMWindow2;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsIDOMWindow;
import org.eclipse.swt.internal.mozilla.nsIDOMEventTarget;

const char[] NS_IDOMWINDOW2_IID_STR = "65455132-b96a-40ec-adea-52fa22b1028c";

const nsIID NS_IDOMWINDOW2_IID= 
  {0x65455132, 0xb96a, 0x40ec, 
    [ 0xad, 0xea, 0x52, 0xfa, 0x22, 0xb1, 0x02, 0x8c ]};

interface nsIDOMWindow2 : nsIDOMWindow {

  static const char[] IID_STR = NS_IDOMWINDOW2_IID_STR;
  static const nsIID IID = NS_IDOMWINDOW2_IID;

extern(System):
  nsresult GetWindowRoot(nsIDOMEventTarget  *aWindowRoot);

}

