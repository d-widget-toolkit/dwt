module org.eclipse.swt.internal.mozilla.nsIHelperAppLauncherDialog;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIHelperAppLauncher;
import org.eclipse.swt.internal.mozilla.nsILocalFile;

const char[] NS_IHELPERAPPLAUNCHERDIALOG_IID_STR = "d7ebddf0-4c84-11d4-807a-00600811a9c3";

const nsIID NS_IHELPERAPPLAUNCHERDIALOG_IID= 
  { 0xd7ebddf0, 0x4c84, 0x11d4, [ 0x80,0x7a,0x00,0x60,0x08,0x11,0xa9,0xc3 ]};

interface nsIHelperAppLauncherDialog : nsISupports {

  static const char[] IID_STR = NS_IHELPERAPPLAUNCHERDIALOG_IID_STR;
  static const nsIID IID = NS_IHELPERAPPLAUNCHERDIALOG_IID;

  enum { REASON_CANTHANDLE = 0U };
  enum { REASON_SERVERREQUEST = 1U };
  enum { REASON_TYPESNIFFED = 2U };

extern(System):
  nsresult Show(nsIHelperAppLauncher aLauncher, nsISupports aContext, PRUint32 aReason);
  nsresult PromptForSaveToFile(nsIHelperAppLauncher aLauncher, nsISupports aWindowContext, PRUnichar *aDefaultFile, PRUnichar *aSuggestedFileExtension, nsILocalFile *_retval);

}

