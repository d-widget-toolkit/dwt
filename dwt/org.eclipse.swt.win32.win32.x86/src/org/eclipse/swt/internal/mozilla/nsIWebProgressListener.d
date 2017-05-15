module org.eclipse.swt.internal.mozilla.nsIWebProgressListener;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIWebProgress;
import org.eclipse.swt.internal.mozilla.nsIRequest; 
import org.eclipse.swt.internal.mozilla.nsIURI; 

const char[] NS_IWEBPROGRESSLISTENER_IID_STR = "570f39d1-efd0-11d3-b093-00a024ffc08c";

const nsIID NS_IWEBPROGRESSLISTENER_IID= 
  {0x570f39d1, 0xefd0, 0x11d3, 
    [ 0xb0, 0x93, 0x00, 0xa0, 0x24, 0xff, 0xc0, 0x8c ]};

interface nsIWebProgressListener : nsISupports {

  static const char[] IID_STR = NS_IWEBPROGRESSLISTENER_IID_STR;
  static const nsIID IID = NS_IWEBPROGRESSLISTENER_IID;

extern(System):
  enum { STATE_START = 1U };
  enum { STATE_REDIRECTING = 2U };
  enum { STATE_TRANSFERRING = 4U };
  enum { STATE_NEGOTIATING = 8U };
  enum { STATE_STOP = 16U };
  enum { STATE_IS_REQUEST = 65536U };
  enum { STATE_IS_DOCUMENT = 131072U };
  enum { STATE_IS_NETWORK = 262144U };
  enum { STATE_IS_WINDOW = 524288U };
  enum { STATE_RESTORING = 16777216U };
  enum { STATE_IS_INSECURE = 4U };
  enum { STATE_IS_BROKEN = 1U };
  enum { STATE_IS_SECURE = 2U };
  enum { STATE_SECURE_HIGH = 262144U };
  enum { STATE_SECURE_MED = 65536U };
  enum { STATE_SECURE_LOW = 131072U };

  nsresult OnStateChange(nsIWebProgress aWebProgress, nsIRequest aRequest, PRUint32 aStateFlags, nsresult aStatus);
  nsresult OnProgressChange(nsIWebProgress aWebProgress, nsIRequest aRequest, PRInt32 aCurSelfProgress, PRInt32 aMaxSelfProgress, PRInt32 aCurTotalProgress, PRInt32 aMaxTotalProgress);
  nsresult OnLocationChange(nsIWebProgress aWebProgress, nsIRequest aRequest, nsIURI aLocation);
  nsresult OnStatusChange(nsIWebProgress aWebProgress, nsIRequest aRequest, nsresult aStatus, PRUnichar *aMessage);
  nsresult OnSecurityChange(nsIWebProgress aWebProgress, nsIRequest aRequest, PRUint32 aState);

}

