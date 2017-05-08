module org.eclipse.swt.internal.mozilla.nsISecureBrowserUI;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIDOMWindow;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_ISECUREBROWSERUI_IID_STR = "081e31e0-a144-11d3-8c7c-00609792278c";

const nsIID NS_ISECUREBROWSERUI_IID= 
  {0x081e31e0, 0xa144, 0x11d3, 
    [ 0x8c, 0x7c, 0x00, 0x60, 0x97, 0x92, 0x27, 0x8c ]};

interface nsISecureBrowserUI : nsISupports {

  static const char[] IID_STR = NS_ISECUREBROWSERUI_IID_STR;
  static const nsIID IID = NS_ISECUREBROWSERUI_IID;

extern(System):
  nsresult Init(nsIDOMWindow window);
  nsresult GetState(PRUint32 *aState);
  nsresult GetTooltipText(nsAString * aTooltipText);

}

