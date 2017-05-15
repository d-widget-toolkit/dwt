module org.eclipse.swt.internal.mozilla.nsIWebBrowserChromeFocus;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_IWEBBROWSERCHROMEFOCUS_IID_STR = "d2206418-1dd1-11b2-8e55-acddcd2bcfb8";

const nsIID NS_IWEBBROWSERCHROMEFOCUS_IID= 
  {0xd2206418, 0x1dd1, 0x11b2, 
    [ 0x8e, 0x55, 0xac, 0xdd, 0xcd, 0x2b, 0xcf, 0xb8 ]};

interface nsIWebBrowserChromeFocus : nsISupports {

  static const char[] IID_STR = NS_IWEBBROWSERCHROMEFOCUS_IID_STR;
  static const nsIID IID = NS_IWEBBROWSERCHROMEFOCUS_IID;

extern(System):
  nsresult FocusNextElement();
  nsresult FocusPrevElement();

}

