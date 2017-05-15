module org.eclipse.swt.internal.mozilla.nsISimpleEnumerator;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_ISIMPLEENUMERATOR_IID_STR = "d1899240-f9d2-11d2-bdd6-000064657374";

const nsIID NS_ISIMPLEENUMERATOR_IID= 
  {0xd1899240, 0xf9d2, 0x11d2, 
    [ 0xbd, 0xd6, 0x00, 0x00, 0x64, 0x65, 0x73, 0x74 ]};

interface nsISimpleEnumerator : nsISupports {

  static const char[] IID_STR = NS_ISIMPLEENUMERATOR_IID_STR;
  static const nsIID IID = NS_ISIMPLEENUMERATOR_IID;

extern(System):
  nsresult HasMoreElements(PRBool *_retval);
  nsresult GetNext(nsISupports *_retval);

}

