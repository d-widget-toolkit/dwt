module org.eclipse.swt.internal.mozilla.nsIDOMStorage;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsStringAPI;
import org.eclipse.swt.internal.mozilla.nsIDOMStorageItem;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMSTORAGE_IID_STR = "95cc1383-3b62-4b89-aaef-1004a513ef47";

const nsIID NS_IDOMSTORAGE_IID= 
  {0x95cc1383, 0x3b62, 0x4b89, 
    [ 0xaa, 0xef, 0x10, 0x04, 0xa5, 0x13, 0xef, 0x47 ]};

interface nsIDOMStorage : nsISupports {

  static const char[] IID_STR = NS_IDOMSTORAGE_IID_STR;
  static const nsIID IID = NS_IDOMSTORAGE_IID;

extern(System):
  nsresult GetLength(PRUint32 *aLength);
  nsresult Key(PRUint32 index, nsAString * _retval);
  nsresult GetItem(nsAString * key, nsIDOMStorageItem *_retval);
  nsresult SetItem(nsAString * key, nsAString * data);
  nsresult RemoveItem(nsAString * key);

}

