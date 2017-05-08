module org.eclipse.swt.internal.mozilla.nsIHelperAppLauncher;

import java.lang.all;

private import org.eclipse.swt.internal.mozilla.Common;
private import org.eclipse.swt.internal.mozilla.nsID;
private import org.eclipse.swt.internal.mozilla.nsISupports;
private import org.eclipse.swt.internal.mozilla.nsIURI;
private import org.eclipse.swt.internal.mozilla.nsIMIMEInfo;
private import org.eclipse.swt.internal.mozilla.nsIFile;
private import org.eclipse.swt.internal.mozilla.nsIWebProgressListener;
private import org.eclipse.swt.internal.mozilla.nsStringAPI;
private import org.eclipse.swt.internal.mozilla.prtime;

const char[] NS_IHELPERAPPLAUNCHER_IID_STR = "9503d0fe-4c9d-11d4-98d0-001083010e9b";

const nsIID NS_IHELPERAPPLAUNCHER_IID= 
  {0x9503d0fe, 0x4c9d, 0x11d4, 
    [ 0x98, 0xd0, 0x00, 0x10, 0x83, 0x01, 0x0e, 0x9b ]};

interface nsIHelperAppLauncher : nsISupports {

  static const char[] IID_STR = NS_IHELPERAPPLAUNCHER_IID_STR;
  static const nsIID IID = NS_IHELPERAPPLAUNCHER_IID;

extern(System):
  nsresult GetMIMEInfo(nsIMIMEInfo  *aMIMEInfo);
  nsresult GetSource(nsIURI  *aSource);
  nsresult GetSuggestedFileName(nsAString * aSuggestedFileName);
  nsresult SaveToDisk(nsIFile aNewFileLocation, PRBool aRememberThisPreference);
  nsresult LaunchWithApplication(nsIFile aApplication, PRBool aRememberThisPreference);
  nsresult Cancel();
  nsresult SetWebProgressListener(nsIWebProgressListener aWebProgressListener);
  nsresult CloseProgressWindow();
  nsresult GetDownloadInfo( nsIURI* aSourceUrl, PRTime* aTimeDownloadStarted, nsIFile* result);

}
