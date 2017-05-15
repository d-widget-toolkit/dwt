module org.eclipse.swt.internal.mozilla.nsIDownload_1_8;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsITransfer;
import org.eclipse.swt.internal.mozilla.nsIURI; 
import org.eclipse.swt.internal.mozilla.nsILocalFile;
import org.eclipse.swt.internal.mozilla.nsIObserver; 
import org.eclipse.swt.internal.mozilla.nsICancelable;
import org.eclipse.swt.internal.mozilla.nsIMIMEInfo; 

const char[] NS_IDOWNLOAD_IID_STR = "9e1fd9f2-9727-4926-85cd-f16c375bba6d";

const nsIID NS_IDOWNLOAD_IID= 
  {0x9e1fd9f2, 0x9727, 0x4926, 
    [ 0x85, 0xcd, 0xf1, 0x6c, 0x37, 0x5b, 0xba, 0x6d ]};

interface nsIDownload_1_8 : nsITransfer {

  static const char[] IID_STR = NS_IDOWNLOAD_IID_STR;
  static const nsIID IID = NS_IDOWNLOAD_IID;

extern(System):
  nsresult GetTargetFile(nsILocalFile  *aTargetFile);
  nsresult GetPercentComplete(PRInt32 *aPercentComplete);
  nsresult GetAmountTransferred(PRUint64 *aAmountTransferred);
  nsresult GetSize(PRUint64 *aSize);
  nsresult GetSource(nsIURI  *aSource);
  nsresult GetTarget(nsIURI  *aTarget);
  nsresult GetCancelable(nsICancelable  *aCancelable);
  nsresult GetDisplayName(PRUnichar * *aDisplayName);
  nsresult GetStartTime(PRInt64 *aStartTime);
  nsresult GetMIMEInfo(nsIMIMEInfo  *aMIMEInfo);

}
