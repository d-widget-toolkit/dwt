module org.eclipse.swt.internal.mozilla.nsIDOMBarProp;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMBARPROP_IID_STR = "9eb2c150-1d56-11d3-8221-0060083a0bcf";

const nsIID NS_IDOMBARPROP_IID= 
  {0x9eb2c150, 0x1d56, 0x11d3, 
    [ 0x82, 0x21, 0x00, 0x60, 0x08, 0x3a, 0x0b, 0xcf ]};

interface nsIDOMBarProp : nsISupports {

  static const char[] IID_STR = NS_IDOMBARPROP_IID_STR;
  static const nsIID IID = NS_IDOMBARPROP_IID;

extern(System):
  nsresult GetVisible(PRBool *aVisible);
  nsresult SetVisible(PRBool aVisible);

}

