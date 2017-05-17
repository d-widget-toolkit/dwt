module org.eclipse.swt.internal.mozilla.nsIEnumerator;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

/******************************************************************************

******************************************************************************/

const char[] NS_IENUMERATOR_IID_STR = "ad385286-cbc4-11d2-8cca-0060b0fc14a3";

const nsIID NS_IENUMERATOR_IID= 
  {0xad385286, 0xcbc4, 0x11d2, 
    [ 0x8c, 0xca, 0x00, 0x60, 0xb0, 0xfc, 0x14, 0xa3 ]};

interface nsIEnumerator : nsISupports {

  static const char[] IID_STR = NS_IENUMERATOR_IID_STR;
  static const nsIID IID = NS_IENUMERATOR_IID;

extern(System):
  nsresult First();
  nsresult Next();
  nsresult CurrentItem(nsISupports *_retval);
  nsresult IsDone();

}

/******************************************************************************

******************************************************************************/

const char[] NS_IBIDIRECTIONALENUMERATOR_IID_STR = "75f158a0-cadd-11d2-8cca-0060b0fc14a3";

const nsIID NS_IBIDIRECTIONALENUMERATOR_IID= 
  {0x75f158a0, 0xcadd, 0x11d2, 
    [ 0x8c, 0xca, 0x00, 0x60, 0xb0, 0xfc, 0x14, 0xa3 ]};

interface nsIBidirectionalEnumerator : nsIEnumerator {

  static const char[] IID_STR = NS_IBIDIRECTIONALENUMERATOR_IID_STR;
  static const nsIID IID = NS_IBIDIRECTIONALENUMERATOR_IID;

extern(System):
  nsresult Last();
  nsresult Prev();

}

