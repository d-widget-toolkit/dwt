module org.eclipse.swt.internal.mozilla.nsIDOMCharacterData;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;

import org.eclipse.swt.internal.mozilla.nsIDOMNode;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_IDOMCHARACTERDATA_IID_STR = "a6cf9072-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMCHARACTERDATA_IID= 
  {0xa6cf9072, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMCharacterData : nsIDOMNode {

  static const char[] IID_STR = NS_IDOMCHARACTERDATA_IID_STR;
  static const nsIID IID = NS_IDOMCHARACTERDATA_IID;

extern(System):
  nsresult GetData(nsAString * aData);
  nsresult SetData(nsAString * aData);
  nsresult GetLength(PRUint32 *aLength);
  nsresult SubstringData(PRUint32 offset, PRUint32 count, nsAString * _retval);
  nsresult AppendData(nsAString * arg);
  nsresult InsertData(PRUint32 offset, nsAString * arg);
  nsresult DeleteData(PRUint32 offset, PRUint32 count);
  nsresult ReplaceData(PRUint32 offset, PRUint32 count, nsAString * arg);

}

