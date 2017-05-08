
module org.eclipse.swt.internal.mozilla.nsIFactory;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_IFACTORY_IID_STR = "00000001-0000-0000-c000-000000000046";

const nsIID NS_IFACTORY_IID= 
  {0x00000001, 0x0000, 0x0000, 
    [ 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46 ]};

interface nsIFactory : nsISupports {

  static const char[] IID_STR = NS_IFACTORY_IID_STR;
  static const nsIID IID = NS_IFACTORY_IID;

extern(System):
  nsresult CreateInstance(nsISupports aOuter, nsIID * iid, void * *result);
  nsresult LockFactory(PRBool lock);
}
