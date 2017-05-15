module org.eclipse.swt.internal.mozilla.nsIStringEnumerator;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsStringAPI;

/******************************************************************************

******************************************************************************/

const char[] NS_ISTRINGENUMERATOR_IID_STR = "50d3ef6c-9380-4f06-9fb2-95488f7d141c";

const nsIID NS_ISTRINGENUMERATOR_IID= 
  {0x50d3ef6c, 0x9380, 0x4f06, 
    [ 0x9f, 0xb2, 0x95, 0x48, 0x8f, 0x7d, 0x14, 0x1c ]};

interface nsIStringEnumerator : nsISupports {

  static const char[] IID_STR = NS_ISTRINGENUMERATOR_IID_STR;
  static const nsIID IID = NS_ISTRINGENUMERATOR_IID;

extern(System):
  nsresult HasMore(PRBool *_retval);
  nsresult GetNext(nsAString * _retval);

}

/******************************************************************************

******************************************************************************/

const char[] NS_IUTF8STRINGENUMERATOR_IID_STR = "9bdf1010-3695-4907-95ed-83d0410ec307";

const nsIID NS_IUTF8STRINGENUMERATOR_IID= 
  {0x9bdf1010, 0x3695, 0x4907, 
    [ 0x95, 0xed, 0x83, 0xd0, 0x41, 0x0e, 0xc3, 0x07 ]};

interface nsIUTF8StringEnumerator : nsISupports {

  static const char[] IID_STR = NS_IUTF8STRINGENUMERATOR_IID_STR;
  static const nsIID IID = NS_IUTF8STRINGENUMERATOR_IID;

extern(System):
  nsresult HasMore(PRBool *_retval);
  nsresult GetNext(nsACString * _retval);

}

