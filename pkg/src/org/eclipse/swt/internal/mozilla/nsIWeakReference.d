module org.eclipse.swt.internal.mozilla.nsIWeakReference;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

/******************************************************************************

******************************************************************************/

const char[] NS_IWEAKREFERENCE_IID_STR = "9188bc85-f92e-11d2-81ef-0060083a0bcf";

const nsIID NS_IWEAKREFERENCE_IID= 
  {0x9188bc85, 0xf92e, 0x11d2, 
    [ 0x81, 0xef, 0x00, 0x60, 0x08, 0x3a, 0x0b, 0xcf ]};

interface nsIWeakReference : nsISupports {

  static const char[] IID_STR = NS_IWEAKREFERENCE_IID_STR;
  static const nsIID IID = NS_IWEAKREFERENCE_IID;

extern(System):
  nsresult QueryReferent(nsIID * uuid, void * *result);

}

/******************************************************************************

******************************************************************************/

const char[] NS_ISUPPORTSWEAKREFERENCE_IID_STR = "9188bc86-f92e-11d2-81ef-0060083a0bcf";

const nsIID NS_ISUPPORTSWEAKREFERENCE_IID= 
  {0x9188bc86, 0xf92e, 0x11d2, 
    [ 0x81, 0xef, 0x00, 0x60, 0x08, 0x3a, 0x0b, 0xcf ]};

interface nsISupportsWeakReference : nsISupports {

  static const char[] IID_STR = NS_ISUPPORTSWEAKREFERENCE_IID_STR;
  static const nsIID IID = NS_ISUPPORTSWEAKREFERENCE_IID;

extern(System):
  nsresult GetWeakReference(nsIWeakReference *_retval);

}

