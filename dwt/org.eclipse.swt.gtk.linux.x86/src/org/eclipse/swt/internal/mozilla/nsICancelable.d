module org.eclipse.swt.internal.mozilla.nsICancelable;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_ICANCELABLE_IID_STR = "d94ac0a0-bb18-46b8-844e-84159064b0bd";

const nsIID NS_ICANCELABLE_IID= 
  {0xd94ac0a0, 0xbb18, 0x46b8, 
    [ 0x84, 0x4e, 0x84, 0x15, 0x90, 0x64, 0xb0, 0xbd ]};

interface nsICancelable : nsISupports {

  static const char[] IID_STR = NS_ICANCELABLE_IID_STR;
  static const nsIID IID = NS_ICANCELABLE_IID;

extern(System):
  nsresult Cancel(nsresult aReason);
}

