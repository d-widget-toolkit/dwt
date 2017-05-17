module org.eclipse.swt.internal.mozilla.nsIProgressDialog_1_8;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIDownload;
import org.eclipse.swt.internal.mozilla.nsIDOMWindow; 
import org.eclipse.swt.internal.mozilla.nsIObserver;
import org.eclipse.swt.internal.mozilla.nsIDownload_1_8;

const char[] NS_IPROGRESSDIALOG_IID_STR = "20e790a2-76c6-462d-851a-22ab6cbbe48b";

const nsIID NS_IPROGRESSDIALOG_IID= 
  {0x20e790a2, 0x76c6, 0x462d, 
    [ 0x85, 0x1a, 0x22, 0xab, 0x6c, 0xbb, 0xe4, 0x8b ]};

interface nsIProgressDialog_1_8 : nsIDownload_1_8 {

  static const char[] IID_STR = NS_IPROGRESSDIALOG_IID_STR;
  static const nsIID IID = NS_IPROGRESSDIALOG_IID;

extern(System):
  nsresult Open(nsIDOMWindow aParent);
  nsresult GetCancelDownloadOnClose(PRBool *aCancelDownloadOnClose);
  nsresult SetCancelDownloadOnClose(PRBool aCancelDownloadOnClose);
  nsresult GetObserver(nsIObserver  *aObserver);
  nsresult SetObserver(nsIObserver  aObserver);
  nsresult GetDialog(nsIDOMWindow  *aDialog);
  nsresult SetDialog(nsIDOMWindow  aDialog);

}

