module org.eclipse.swt.internal.mozilla.nsICookie;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

alias PRInt32 nsCookieStatus;
alias PRInt32 nsCookiePolicy;

const char[] NS_ICOOKIE_IID_STR = "e9fcb9a4-d376-458f-b720-e65e7df593bc";

const nsIID NS_ICOOKIE_IID= 
  {0xe9fcb9a4, 0xd376, 0x458f, 
    [ 0xb7, 0x20, 0xe6, 0x5e, 0x7d, 0xf5, 0x93, 0xbc ]};

interface nsICookie : nsISupports {

  static const char[] IID_STR = NS_ICOOKIE_IID_STR;
  static const nsIID IID = NS_ICOOKIE_IID;

extern(System):
  nsresult GetName(nsACString * aName);
  nsresult GetValue(nsACString * aValue);
  nsresult GetIsDomain(PRBool *aIsDomain);
  nsresult GetHost(nsACString * aHost);
  nsresult GetPath(nsACString * aPath);
  nsresult GetIsSecure(PRBool *aIsSecure);
  nsresult GetExpires(PRUint64 *aExpires);

  enum { STATUS_UNKNOWN = 0 };
  enum { STATUS_ACCEPTED = 1 };
  enum { STATUS_DOWNGRADED = 2 };
  enum { STATUS_FLAGGED = 3 };
  enum { STATUS_REJECTED = 4 };

  nsresult GetStatus(nsCookieStatus *aStatus);

  enum { POLICY_UNKNOWN = 0 };
  enum { POLICY_NONE = 1 };
  enum { POLICY_NO_CONSENT = 2 };
  enum { POLICY_IMPLICIT_CONSENT = 3 };
  enum { POLICY_EXPLICIT_CONSENT = 4 };
  enum { POLICY_NO_II = 5 };

  nsresult GetPolicy(nsCookiePolicy *aPolicy);
}

