module org.eclipse.swt.internal.mozilla.nsITransfer;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.prtime;

import org.eclipse.swt.internal.mozilla.nsIWebProgressListener2;
import org.eclipse.swt.internal.mozilla.nsIURI;
import org.eclipse.swt.internal.mozilla.nsICancelable;
import org.eclipse.swt.internal.mozilla.nsIMIMEInfo;
import org.eclipse.swt.internal.mozilla.nsILocalFile;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_ITRANSFER_IID_STR = "23c51569-e9a1-4a92-adeb-3723db82ef7c";

const nsIID NS_ITRANSFER_IID= 
  {0x23c51569, 0xe9a1, 0x4a92, 
    [ 0xad, 0xeb, 0x37, 0x23, 0xdb, 0x82, 0xef, 0x7c ]};

interface nsITransfer : nsIWebProgressListener2 {

  static const char[] IID_STR = NS_ITRANSFER_IID_STR;
  static const nsIID IID = NS_ITRANSFER_IID;

extern(System):
  nsresult Init(nsIURI aSource, nsIURI aTarget, nsAString * aDisplayName, nsIMIMEInfo aMIMEInfo, PRTime startTime, nsILocalFile aTempFile, nsICancelable aCancelable);

}

