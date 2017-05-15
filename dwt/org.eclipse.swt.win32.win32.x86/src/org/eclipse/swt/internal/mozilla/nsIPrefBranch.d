module org.eclipse.swt.internal.mozilla.nsIPrefBranch;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_IPREFBRANCH_IID_STR = "56c35506-f14b-11d3-99d3-ddbfac2ccf65";

const nsIID NS_IPREFBRANCH_IID= 
  {0x56c35506, 0xf14b, 0x11d3, 
    [ 0x99, 0xd3, 0xdd, 0xbf, 0xac, 0x2c, 0xcf, 0x65 ]};

interface nsIPrefBranch : nsISupports {

  static const char[] IID_STR = NS_IPREFBRANCH_IID_STR;
  static const nsIID IID = NS_IPREFBRANCH_IID;

  enum { PREF_INVALID = 0 };
  enum { PREF_STRING = 32 };
  enum { PREF_INT = 64 };
  enum { PREF_BOOL = 128 };

extern(System):
  nsresult GetRoot(char * *aRoot);
  nsresult GetPrefType(char *aPrefName, PRInt32 *_retval);
  nsresult GetBoolPref(char *aPrefName, PRBool *_retval);
  nsresult SetBoolPref(char *aPrefName, PRInt32 aValue);
  nsresult GetCharPref(char *aPrefName, char **_retval);
  nsresult SetCharPref(char *aPrefName, char *aValue);
  nsresult GetIntPref(char *aPrefName, PRInt32 *_retval);
  nsresult SetIntPref(char *aPrefName, PRInt32 aValue);
  nsresult GetComplexValue(char *aPrefName, nsIID * aType, void * *aValue);
  nsresult SetComplexValue(char *aPrefName, nsIID * aType, nsISupports aValue);
  nsresult ClearUserPref(char *aPrefName);
  nsresult LockPref(char *aPrefName);
  nsresult PrefHasUserValue(char *aPrefName, PRBool *_retval);
  nsresult PrefIsLocked(char *aPrefName, PRBool *_retval);
  nsresult UnlockPref(char *aPrefName);
  nsresult DeleteBranch(char *aStartingAt);
  nsresult GetChildList(char *aStartingAt, PRUint32 *aCount, char ***aChildArray);
  nsresult ResetBranch(char *aStartingAt);

}

