module org.eclipse.swt.internal.mozilla.nsIDebug;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_IDEBUG_IID_STR = "3bf0c3d7-3bd9-4cf2-a971-33572c503e1e";

const nsIID NS_IDEBUG_IID= 
  {0x3bf0c3d7, 0x3bd9, 0x4cf2, 
    [ 0xa9, 0x71, 0x33, 0x57, 0x2c, 0x50, 0x3e, 0x1e ]};

interface nsIDebug : nsISupports {
  static const char[] IID_STR = NS_IDEBUG_IID_STR;
  static const nsIID IID = NS_IDEBUG_IID;

extern(System):
  nsresult Assertion(char *aStr, char *aExpr, char *aFile, PRInt32 aLine);
  nsresult Warning(char *aStr, char *aFile, PRInt32 aLine);
  nsresult Break(char *aFile, PRInt32 aLine);
  nsresult Abort(char *aFile, PRInt32 aLine);
}

