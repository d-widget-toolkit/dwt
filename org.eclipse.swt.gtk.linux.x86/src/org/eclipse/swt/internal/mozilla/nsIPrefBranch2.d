module org.eclipse.swt.internal.mozilla.nsIPrefBranch2;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIPrefBranch;
import org.eclipse.swt.internal.mozilla.nsIObserver; 

const char[] NS_IPREFBRANCH2_IID_STR = "74567534-eb94-4b1c-8f45-389643bfc555";

const nsIID NS_IPREFBRANCH2_IID= 
  {0x74567534, 0xeb94, 0x4b1c, 
    [ 0x8f, 0x45, 0x38, 0x96, 0x43, 0xbf, 0xc5, 0x55 ]};

interface nsIPrefBranch2 : nsIPrefBranch {

  static const char[] IID_STR = NS_IPREFBRANCH2_IID_STR;
  static const nsIID IID = NS_IPREFBRANCH2_IID;

extern(System):
  nsresult AddObserver(char *aDomain, nsIObserver aObserver, PRBool aHoldWeak);
  nsresult RemoveObserver(char *aDomain, nsIObserver aObserver);

}

