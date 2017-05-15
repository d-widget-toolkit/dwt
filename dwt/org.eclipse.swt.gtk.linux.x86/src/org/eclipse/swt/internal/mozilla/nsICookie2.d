module org.eclipse.swt.internal.mozilla.nsICookie2;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsICookie;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_ICOOKIE2_IID_STR = "d3493503-7854-46ed-8284-8af54a847efb";

const nsIID NS_ICOOKIE2_IID= 
  {0xd3493503, 0x7854, 0x46ed, 
    [ 0x82, 0x84, 0x8a, 0xf5, 0x4a, 0x84, 0x7e, 0xfb ]};

interface nsICookie2 : nsICookie {

  static const char[] IID_STR = NS_ICOOKIE2_IID_STR;
  static const nsIID IID = NS_ICOOKIE2_IID;

extern(System):
  nsresult GetRawHost(nsACString * aRawHost);
  nsresult GetIsSession(PRBool *aIsSession);
  nsresult GetExpiry(PRInt64 *aExpiry);
}

