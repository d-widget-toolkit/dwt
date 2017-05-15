module org.eclipse.swt.internal.mozilla.nsIPrefBranch;

import java.lang.all;

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
  nsresult GetPrefType(in char *aPrefName, PRInt32 *_retval);
  nsresult GetBoolPref(in char *aPrefName, PRBool *_retval);
  nsresult SetBoolPref(in char *aPrefName, PRInt32 aValue);
  nsresult GetCharPref(in char *aPrefName, char **_retval);
  nsresult SetCharPref(in char *aPrefName, in char *aValue);
  nsresult GetIntPref(in char *aPrefName, PRInt32 *_retval);
  nsresult SetIntPref(in char *aPrefName, PRInt32 aValue);
  nsresult GetComplexValue(in char *aPrefName, in nsIID * aType, void * *aValue);
  nsresult SetComplexValue(in char *aPrefName, in nsIID * aType, nsISupports aValue);
  nsresult ClearUserPref(in char *aPrefName);
  nsresult LockPref(in char *aPrefName);
  nsresult PrefHasUserValue(in char *aPrefName, PRBool *_retval);
  nsresult PrefIsLocked(in char *aPrefName, PRBool *_retval);
  nsresult UnlockPref(in char *aPrefName);
  nsresult DeleteBranch(in char *aStartingAt);
  nsresult GetChildList(in char *aStartingAt, PRUint32 *aCount, char ***aChildArray);
  nsresult ResetBranch(in char *aStartingAt);

}

