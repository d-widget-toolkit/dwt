module org.eclipse.swt.internal.mozilla.nsIObserverService;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIObserver;
import org.eclipse.swt.internal.mozilla.nsISimpleEnumerator;

const char[] NS_IOBSERVERSERVICE_IID_STR = "d07f5192-e3d1-11d2-8acd-00105a1b8860";

const nsIID NS_IOBSERVERSERVICE_IID= 
  {0xd07f5192, 0xe3d1, 0x11d2, 
    [ 0x8a, 0xcd, 0x00, 0x10, 0x5a, 0x1b, 0x88, 0x60 ]};

interface nsIObserverService : nsISupports {

  static const char[] IID_STR = NS_IOBSERVERSERVICE_IID_STR;
  static const nsIID IID = NS_IOBSERVERSERVICE_IID;

extern(System):
  nsresult AddObserver(nsIObserver anObserver, char *aTopic, PRBool ownsWeak);
  nsresult RemoveObserver(nsIObserver anObserver, char *aTopic);
  nsresult NotifyObservers(nsISupports aSubject, char *aTopic, PRUnichar *someData);
  nsresult EnumerateObservers(char *aTopic, nsISimpleEnumerator *_retval);

}

