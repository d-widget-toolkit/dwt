module org.eclipse.swt.internal.mozilla.nsIWebNavigation;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIDOMDocument;
import org.eclipse.swt.internal.mozilla.nsIInputStream;
import org.eclipse.swt.internal.mozilla.nsISHistory; 
import org.eclipse.swt.internal.mozilla.nsIURI; 

const char[] NS_IWEBNAVIGATION_IID_STR = "f5d9e7b0-d930-11d3-b057-00a024ffc08c";

const nsIID NS_IWEBNAVIGATION_IID= 
  {0xf5d9e7b0, 0xd930, 0x11d3, 
    [ 0xb0, 0x57, 0x00, 0xa0, 0x24, 0xff, 0xc0, 0x8c ]};

interface nsIWebNavigation : nsISupports {

  static const char[] IID_STR = NS_IWEBNAVIGATION_IID_STR;
  static const nsIID IID = NS_IWEBNAVIGATION_IID;

extern(System):
  nsresult GetCanGoBack(PRBool *aCanGoBack);
  nsresult GetCanGoForward(PRBool *aCanGoForward);
  nsresult GoBack();
  nsresult GoForward();
  nsresult GotoIndex(PRInt32 index);

  enum { LOAD_FLAGS_MASK = 65535U };
  enum { LOAD_FLAGS_NONE = 0U };
  enum { LOAD_FLAGS_IS_REFRESH = 16U };
  enum { LOAD_FLAGS_IS_LINK = 32U };
  enum { LOAD_FLAGS_BYPASS_HISTORY = 64U };
  enum { LOAD_FLAGS_REPLACE_HISTORY = 128U };
  enum { LOAD_FLAGS_BYPASS_CACHE = 256U };
  enum { LOAD_FLAGS_BYPASS_PROXY = 512U };
  enum { LOAD_FLAGS_CHARSET_CHANGE = 1024U };
  enum { LOAD_FLAGS_STOP_CONTENT = 2048U };
  enum { LOAD_FLAGS_FROM_EXTERNAL = 4096U };
  enum { LOAD_FLAGS_ALLOW_THIRD_PARTY_FIXUP = 8192U };
  enum { LOAD_FLAGS_FIRST_LOAD = 16384U };

  nsresult LoadURI(PRUnichar *aURI, PRUint32 aLoadFlags, nsIURI aReferrer, nsIInputStream aPostData, nsIInputStream aHeaders);
  nsresult Reload(PRUint32 aReloadFlags);

  enum { STOP_NETWORK = 1U };
  enum { STOP_CONTENT = 2U };
  enum { STOP_ALL = 3U };

  nsresult Stop(PRUint32 aStopFlags);
  nsresult GetDocument(nsIDOMDocument  *aDocument);
  nsresult GetCurrentURI(nsIURI  *aCurrentURI);
  nsresult GetReferringURI(nsIURI  *aReferringURI);
  nsresult GetSessionHistory(nsISHistory  *aSessionHistory);
  nsresult SetSessionHistory(nsISHistory  aSessionHistory);

}

