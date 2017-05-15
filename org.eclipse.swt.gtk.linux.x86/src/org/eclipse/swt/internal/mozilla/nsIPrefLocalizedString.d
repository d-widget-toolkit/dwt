module org.eclipse.swt.internal.mozilla.nsIPrefLocalizedString;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_IPREFLOCALIZEDSTRING_IID_STR = "ae419e24-1dd1-11b2-b39a-d3e5e7073802";

const nsIID NS_IPREFLOCALIZEDSTRING_IID= 
  {0xae419e24, 0x1dd1, 0x11b2, 
    [ 0xb3, 0x9a, 0xd3, 0xe5, 0xe7, 0x07, 0x38, 0x02 ]};

interface nsIPrefLocalizedString : nsISupports {

  static const char[] IID_STR = NS_IPREFLOCALIZEDSTRING_IID_STR;
  static const nsIID IID = NS_IPREFLOCALIZEDSTRING_IID;

extern(System):
  nsresult GetData(PRUnichar * *aData);
  nsresult SetData(PRUnichar * aData);
  nsresult ToString(PRUnichar **_retval);
  nsresult SetDataWithLength(PRUint32 length, PRUnichar *data);

}

