module org.eclipse.swt.internal.mozilla.nsIProgressDialog;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIDownload;
import org.eclipse.swt.internal.mozilla.nsIDOMWindow; 
import org.eclipse.swt.internal.mozilla.nsIObserver;

const char[] NS_IPROGRESSDIALOG_IID_STR = "88a478b3-af65-440a-94dc-ed9b154d2990";

const nsIID NS_IPROGRESSDIALOG_IID= 
  {0x88a478b3, 0xaf65, 0x440a, 
    [ 0x94, 0xdc, 0xed, 0x9b, 0x15, 0x4d, 0x29, 0x90 ]};

interface nsIProgressDialog : nsIDownload {

  static const char[] IID_STR = NS_IPROGRESSDIALOG_IID_STR;
  static const nsIID IID = NS_IPROGRESSDIALOG_IID;

extern(System):
  nsresult Open(nsIDOMWindow aParent);
  nsresult GetCancelDownloadOnClose(PRBool *aCancelDownloadOnClose);
  nsresult SetCancelDownloadOnClose(PRBool aCancelDownloadOnClose);
  nsresult GetDialog(nsIDOMWindow  *aDialog);
  nsresult SetDialog(nsIDOMWindow  aDialog);

}

