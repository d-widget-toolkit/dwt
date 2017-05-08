module org.eclipse.swt.internal.mozilla.nsIWebBrowserChrome;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIWebBrowser; 

const char[] NS_IWEBBROWSERCHROME_IID_STR = "ba434c60-9d52-11d3-afb0-00a024ffc08c";

const nsIID NS_IWEBBROWSERCHROME_IID= 
  {0xba434c60, 0x9d52, 0x11d3, 
    [ 0xaf, 0xb0, 0x00, 0xa0, 0x24, 0xff, 0xc0, 0x8c ]};

interface nsIWebBrowserChrome : nsISupports {

  static const char[] IID_STR = NS_IWEBBROWSERCHROME_IID_STR;
  static const nsIID IID = NS_IWEBBROWSERCHROME_IID;

extern(System):
  enum { STATUS_SCRIPT = 1U };
  enum { STATUS_SCRIPT_DEFAULT = 2U };
  enum { STATUS_LINK = 3U };

  nsresult SetStatus(PRUint32 statusType, PRUnichar *status);
  nsresult GetWebBrowser(nsIWebBrowser  *aWebBrowser);
  nsresult SetWebBrowser(nsIWebBrowser  aWebBrowser);

  enum { CHROME_DEFAULT = 1U };
  enum { CHROME_WINDOW_BORDERS = 2U };
  enum { CHROME_WINDOW_CLOSE = 4U };
  enum { CHROME_WINDOW_RESIZE = 8U };
  enum { CHROME_MENUBAR = 16U };
  enum { CHROME_TOOLBAR = 32U };
  enum { CHROME_LOCATIONBAR = 64U };
  enum { CHROME_STATUSBAR = 128U };
  enum { CHROME_PERSONAL_TOOLBAR = 256U };
  enum { CHROME_SCROLLBARS = 512U };
  enum { CHROME_TITLEBAR = 1024U };
  enum { CHROME_EXTRA = 2048U };
  enum { CHROME_WITH_SIZE = 4096U };
  enum { CHROME_WITH_POSITION = 8192U };
  enum { CHROME_WINDOW_MIN = 16384U };
  enum { CHROME_WINDOW_POPUP = 32768U };
  enum { CHROME_WINDOW_RAISED = 33554432U };
  enum { CHROME_WINDOW_LOWERED = 67108864U };
  enum { CHROME_CENTER_SCREEN = 134217728U };
  enum { CHROME_DEPENDENT = 268435456U };
  enum { CHROME_MODAL = 536870912U };
  enum { CHROME_OPENAS_DIALOG = 1073741824U };
  enum { CHROME_OPENAS_CHROME = 2147483648U };
  enum { CHROME_ALL = 4094U };

  nsresult GetChromeFlags(PRUint32 *aChromeFlags);
  nsresult SetChromeFlags(PRUint32 aChromeFlags);
  nsresult DestroyBrowserWindow();
  nsresult SizeBrowserTo(PRInt32 aCX, PRInt32 aCY);
  nsresult ShowAsModal();
  nsresult IsWindowModal(PRBool *_retval);
  nsresult ExitModalEventLoop(nsresult aStatus);

}

