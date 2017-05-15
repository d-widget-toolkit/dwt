module org.eclipse.swt.internal.mozilla.nsIDOMStorageItem;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsStringAPI;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMSTORAGEITEM_IID_STR = "0cc37c78-4c5f-48e1-adfc-7480b8fe9dc4";

const nsIID NS_IDOMSTORAGEITEM_IID= 
  {0x0cc37c78, 0x4c5f, 0x48e1, 
    [ 0xad, 0xfc, 0x74, 0x80, 0xb8, 0xfe, 0x9d, 0xc4 ]};

interface nsIDOMStorageItem : nsISupports {

  static const char[] IID_STR = NS_IDOMSTORAGEITEM_IID_STR;
  static const nsIID IID = NS_IDOMSTORAGEITEM_IID;

extern(System):
  nsresult GetSecure(PRBool *aSecure);
  nsresult SetSecure(PRBool aSecure);
  nsresult GetValue(nsAString * aValue);
  nsresult SetValue(nsAString * aValue);

}

