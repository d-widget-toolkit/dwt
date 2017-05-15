module org.eclipse.swt.internal.mozilla.nsIHelperAppLauncherDialog_1_9;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIHelperAppLauncher_1_9;
import org.eclipse.swt.internal.mozilla.nsILocalFile;

const char[] NS_IHELPERAPPLAUNCHERDIALOG_1_9_IID_STR = "f3704fdc-8ae6-4eba-a3c3-f02958ac0649";

const nsIID NS_IHELPERAPPLAUNCHERDIALOG_1_9_IID= 
  { 0xf3704fdc, 0x8ae6, 0x4eba, [ 0xa3,0xc3,0xf0,0x29,0x58,0xac,0x06,0x49 ]};
  
interface nsIHelperAppLauncherDialog_1_9 : nsISupports {

  static const char[] IID_STR = NS_IHELPERAPPLAUNCHERDIALOG_1_9_IID_STR;
  static const nsIID IID = NS_IHELPERAPPLAUNCHERDIALOG_1_9_IID;

  enum { REASON_CANTHANDLE = 0U };
  enum { REASON_SERVERREQUEST = 1U };
  enum { REASON_TYPESNIFFED = 2U };

extern(System):
  nsresult Show(nsIHelperAppLauncher_1_9 aLauncher, nsISupports aContext, PRUint32 aReason);
  nsresult PromptForSaveToFile(nsIHelperAppLauncher_1_9 aLauncher, nsISupports aWindowContext, PRUnichar *aDefaultFile, PRUnichar *aSuggestedFileExtension, PRBool aForcePrompt, nsILocalFile *_retval);

}

