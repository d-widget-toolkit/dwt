module org.eclipse.swt.internal.mozilla.nsIDOMEventGroup;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMEVENTGROUP_IID_STR = "33347bee-6620-4841-8152-36091ae80c7e";

const nsIID NS_IDOMEVENTGROUP_IID= 
  {0x33347bee, 0x6620, 0x4841, 
    [ 0x81, 0x52, 0x36, 0x09, 0x1a, 0xe8, 0x0c, 0x7e ]};

interface nsIDOMEventGroup : nsISupports {

  static const char[] IID_STR = NS_IDOMEVENTGROUP_IID_STR;
  static const nsIID IID = NS_IDOMEVENTGROUP_IID;

extern(System):
  nsresult IsSameEventGroup(nsIDOMEventGroup other, PRBool *_retval);

}

