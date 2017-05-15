module org.eclipse.swt.internal.mozilla.nsIWebProgress;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIDOMWindow; 
import org.eclipse.swt.internal.mozilla.nsIWebProgressListener; 

const char[] NS_IWEBPROGRESS_IID_STR = "570f39d0-efd0-11d3-b093-00a024ffc08c";

const nsIID NS_IWEBPROGRESS_IID= 
  {0x570f39d0, 0xefd0, 0x11d3, 
    [ 0xb0, 0x93, 0x00, 0xa0, 0x24, 0xff, 0xc0, 0x8c ]};

interface nsIWebProgress : nsISupports {

  static const char[] IID_STR = NS_IWEBPROGRESS_IID_STR;
  static const nsIID IID = NS_IWEBPROGRESS_IID;

extern(System):
  enum { NOTIFY_STATE_REQUEST = 1U };
  enum { NOTIFY_STATE_DOCUMENT = 2U };
  enum { NOTIFY_STATE_NETWORK = 4U };
  enum { NOTIFY_STATE_WINDOW = 8U };
  enum { NOTIFY_STATE_ALL = 15U };
  enum { NOTIFY_PROGRESS = 16U };
  enum { NOTIFY_STATUS = 32U };
  enum { NOTIFY_SECURITY = 64U };
  enum { NOTIFY_LOCATION = 128U };
  enum { NOTIFY_ALL = 255U };

  nsresult AddProgressListener(nsIWebProgressListener aListener, PRUint32 aNotifyMask);
  nsresult RemoveProgressListener(nsIWebProgressListener aListener);
  nsresult GetDOMWindow(nsIDOMWindow  *aDOMWindow);
  nsresult GetIsLoadingDocument(PRBool *aIsLoadingDocument);

}

