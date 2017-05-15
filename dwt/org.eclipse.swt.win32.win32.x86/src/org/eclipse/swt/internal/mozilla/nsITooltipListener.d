module org.eclipse.swt.internal.mozilla.nsITooltipListener;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_ITOOLTIPLISTENER_IID_STR = "44b78386-1dd2-11b2-9ad2-e4eee2ca1916";

const nsIID NS_ITOOLTIPLISTENER_IID= 
  {0x44b78386, 0x1dd2, 0x11b2, 
    [ 0x9a, 0xd2, 0xe4, 0xee, 0xe2, 0xca, 0x19, 0x16 ]};

interface nsITooltipListener : nsISupports {

  static const char[] IID_STR = NS_ITOOLTIPLISTENER_IID_STR;
  static const nsIID IID = NS_ITOOLTIPLISTENER_IID;

extern(System):
  nsresult OnShowTooltip(PRInt32 aXCoords, PRInt32 aYCoords, PRUnichar *aTipText);
  nsresult OnHideTooltip();

}

