module org.eclipse.swt.internal.mozilla.nsISHistoryListener;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIURI;

const char[] NS_ISHISTORYLISTENER_IID_STR = "3b07f591-e8e1-11d4-9882-00c04fa02f40";

const nsIID NS_ISHISTORYLISTENER_IID= 
  {0x3b07f591, 0xe8e1, 0x11d4, 
    [ 0x98, 0x82, 0x00, 0xc0, 0x4f, 0xa0, 0x2f, 0x40 ]};

interface nsISHistoryListener : nsISupports {

  static const char[] IID_STR = NS_ISHISTORYLISTENER_IID_STR;
  static const nsIID IID = NS_ISHISTORYLISTENER_IID;

extern(System):
  nsresult OnHistoryNewEntry(nsIURI aNewURI);
  nsresult OnHistoryGoBack(nsIURI aBackURI, PRBool *_retval);
  nsresult OnHistoryGoForward(nsIURI aForwardURI, PRBool *_retval);
  nsresult OnHistoryReload(nsIURI aReloadURI, PRUint32 aReloadFlags, PRBool *_retval);
  nsresult OnHistoryGotoIndex(PRInt32 aIndex, nsIURI aGotoURI, PRBool *_retval);
  nsresult OnHistoryPurge(PRInt32 aNumEntries, PRBool *_retval);

}

