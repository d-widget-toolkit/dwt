module org.eclipse.swt.internal.mozilla.nsIDocShellLoadInfo;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIURI; 
import org.eclipse.swt.internal.mozilla.nsIInputStream;
import org.eclipse.swt.internal.mozilla.nsISHEntry;

alias PRInt32 nsDocShellInfoLoadType;

const char[] NS_IDOCSHELLLOADINFO_IID_STR = "4f813a88-7aca-4607-9896-d97270cdf15e";

const nsIID NS_IDOCSHELLLOADINFO_IID= 
  {0x4f813a88, 0x7aca, 0x4607, 
    [ 0x98, 0x96, 0xd9, 0x72, 0x70, 0xcd, 0xf1, 0x5e ]};

interface nsIDocShellLoadInfo : nsISupports {

  static const char[] IID_STR = NS_IDOCSHELLLOADINFO_IID_STR;
  static const nsIID IID = NS_IDOCSHELLLOADINFO_IID;

extern(System):
  nsresult GetReferrer(nsIURI  *aReferrer);
  nsresult SetReferrer(nsIURI  aReferrer);
  nsresult GetOwner(nsISupports  *aOwner);
  nsresult SetOwner(nsISupports  aOwner);
  nsresult GetInheritOwner(PRBool *aInheritOwner);
  nsresult SetInheritOwner(PRBool aInheritOwner);

  enum { loadNormal = 0 };
  enum { loadNormalReplace = 1 };
  enum { loadHistory = 2 };
  enum { loadReloadNormal = 3 };
  enum { loadReloadBypassCache = 4 };
  enum { loadReloadBypassProxy = 5 };
  enum { loadReloadBypassProxyAndCache = 6 };
  enum { loadLink = 7 };
  enum { loadRefresh = 8 };
  enum { loadReloadCharsetChange = 9 };
  enum { loadBypassHistory = 10 };
  enum { loadStopContent = 11 };
  enum { loadStopContentAndReplace = 12 };
  enum { loadNormalExternal = 13 };

  nsresult GetLoadType(nsDocShellInfoLoadType *aLoadType);
  nsresult SetLoadType(nsDocShellInfoLoadType aLoadType);
  nsresult GetSHEntry(nsISHEntry  *aSHEntry);
  nsresult SetSHEntry(nsISHEntry  aSHEntry);
  nsresult GetTarget(PRUnichar * *aTarget);
  nsresult SetTarget(PRUnichar * aTarget);
  nsresult GetPostDataStream(nsIInputStream  *aPostDataStream);
  nsresult SetPostDataStream(nsIInputStream  aPostDataStream);
  nsresult GetHeadersStream(nsIInputStream  *aHeadersStream);
  nsresult SetHeadersStream(nsIInputStream  aHeadersStream);
  nsresult GetSendReferrer(PRBool *aSendReferrer);
  nsresult SetSendReferrer(PRBool aSendReferrer);

}

