module org.eclipse.swt.internal.mozilla.nsIWindowCreator;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIWebBrowserChrome;

const char[] NS_IWINDOWCREATOR_IID_STR = "30465632-a777-44cc-90f9-8145475ef999";

const nsIID NS_IWINDOWCREATOR_IID= 
  {0x30465632, 0xa777, 0x44cc, 
    [ 0x90, 0xf9, 0x81, 0x45, 0x47, 0x5e, 0xf9, 0x99 ]};

interface nsIWindowCreator : nsISupports {

  static const char[] IID_STR = NS_IWINDOWCREATOR_IID_STR;
  static const nsIID IID = NS_IWINDOWCREATOR_IID;

extern(System):
  nsresult CreateChromeWindow(nsIWebBrowserChrome parent, PRUint32 chromeFlags, nsIWebBrowserChrome *_retval);

}

