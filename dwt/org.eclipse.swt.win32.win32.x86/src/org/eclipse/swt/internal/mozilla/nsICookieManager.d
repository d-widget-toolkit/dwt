module org.eclipse.swt.internal.mozilla.nsICookieManager;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsISimpleEnumerator;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_ICOOKIEMANAGER_IID_STR = "aaab6710-0f2c-11d5-a53b-0010a401eb10";

const nsIID NS_ICOOKIEMANAGER_IID= 
  {0xaaab6710, 0x0f2c, 0x11d5, 
    [ 0xa5, 0x3b, 0x00, 0x10, 0xa4, 0x01, 0xeb, 0x10 ]};

interface nsICookieManager : nsISupports {

  static const char[] IID_STR = NS_ICOOKIEMANAGER_IID_STR;
  static const nsIID IID = NS_ICOOKIEMANAGER_IID;

extern(System):
  nsresult RemoveAll();
  nsresult GetEnumerator(nsISimpleEnumerator  *aEnumerator);
  nsresult Remove(nsACString * aDomain, nsACString * aName, nsACString * aPath, PRBool aBlocked);

}

