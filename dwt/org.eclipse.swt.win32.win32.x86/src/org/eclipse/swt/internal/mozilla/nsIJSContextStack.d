module org.eclipse.swt.internal.mozilla.nsIJSContextStack;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

/******************************************************************************

******************************************************************************/

const char[] NS_IJSCONTEXTSTACK_IID_STR = "c67d8270-3189-11d3-9885-006008962422";

const nsIID NS_IJSCONTEXTSTACK_IID= 
  {0xc67d8270, 0x3189, 0x11d3, 
    [ 0x98, 0x85, 0x00, 0x60, 0x08, 0x96, 0x24, 0x22 ]};

interface nsIJSContextStack : nsISupports {

  static const char[] IID_STR = NS_IJSCONTEXTSTACK_IID_STR;
  static const nsIID IID = NS_IJSCONTEXTSTACK_IID;

extern(System):
  nsresult GetCount(PRInt32 *aCount);
  nsresult Peek(JSContext * *_retval);
  nsresult Pop(JSContext * *_retval);
  nsresult Push(JSContext * cx);

}

/******************************************************************************

******************************************************************************/

const char[] NS_IJSCONTEXTSTACKITERATOR_IID_STR = "c7e6b7aa-fc12-4ca7-b140-98c38b698961";

const nsIID NS_IJSCONTEXTSTACKITERATOR_IID= 
  {0xc7e6b7aa, 0xfc12, 0x4ca7, 
    [ 0xb1, 0x40, 0x98, 0xc3, 0x8b, 0x69, 0x89, 0x61 ]};

interface nsIJSContextStackIterator : nsISupports {

  static const char[] IID_STR = NS_IJSCONTEXTSTACKITERATOR_IID_STR;
  static const nsIID IID = NS_IJSCONTEXTSTACKITERATOR_IID;

extern(System):
  nsresult Reset(nsIJSContextStack stack);
  nsresult Done(PRBool *_retval);
  nsresult Prev(JSContext * *_retval);

}

/******************************************************************************

******************************************************************************/

const char[] NS_ITHREADJSCONTEXTSTACK_IID_STR = "a1339ae0-05c1-11d4-8f92-0010a4e73d9a";

const nsIID NS_ITHREADJSCONTEXTSTACK_IID= 
  {0xa1339ae0, 0x05c1, 0x11d4, 
    [ 0x8f, 0x92, 0x00, 0x10, 0xa4, 0xe7, 0x3d, 0x9a ]};

interface nsIThreadJSContextStack : nsIJSContextStack {

  static const char[] IID_STR = NS_ITHREADJSCONTEXTSTACK_IID_STR;
  static const nsIID IID = NS_ITHREADJSCONTEXTSTACK_IID;

extern(System):
  nsresult GetSafeJSContext(JSContext * *aSafeJSContext);
  nsresult SetSafeJSContext(JSContext * aSafeJSContext);

}

