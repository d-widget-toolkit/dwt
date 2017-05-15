module org.eclipse.swt.internal.mozilla.nsIHelperAppLauncher_1_9;

private import org.eclipse.swt.internal.mozilla.Common;
private import org.eclipse.swt.internal.mozilla.nsID;
private import org.eclipse.swt.internal.mozilla.nsICancelable;
private import org.eclipse.swt.internal.mozilla.nsIURI;
private import org.eclipse.swt.internal.mozilla.nsIMIMEInfo;
private import org.eclipse.swt.internal.mozilla.nsIFile;
private import org.eclipse.swt.internal.mozilla.nsIWebProgressListener2;
private import org.eclipse.swt.internal.mozilla.nsStringAPI;
private import org.eclipse.swt.internal.mozilla.prtime;

const char[] NS_IHELPERAPPLAUNCHER_1_9_IID_STR = "cc75c21a-0a79-4f68-90e1-563253d0c555";

const nsIID NS_IHELPERAPPLAUNCHER_1_9_IID= 
  {0xcc75c21a, 0x0a79, 0x4f68, 
    [ 0x90, 0xe1, 0x56, 0x32, 0x53, 0xd0, 0xc5, 0x55 ]};

interface nsIHelperAppLauncher_1_9 : nsICancelable {

  static const char[] IID_STR = NS_IHELPERAPPLAUNCHER_1_9_IID_STR;
  static const nsIID IID = NS_IHELPERAPPLAUNCHER_1_9_IID;

extern(System):
  nsresult GetMIMEInfo(nsIMIMEInfo  *aMIMEInfo);
  nsresult GetSource(nsIURI *aSource);
  nsresult GetSuggestedFileName(nsAString * aSuggestedFileName);
  nsresult SaveToDisk(nsIFile aNewFileLocation, PRBool aRememberThisPreference);
  nsresult LaunchWithApplication(nsIFile aApplication, PRBool aRememberThisPreference);
  nsresult SetWebProgressListener(nsIWebProgressListener2 aWebProgressListener);
  nsresult CloseProgressWindow();
  nsresult GetTargetFile(nsIFile *aTargetFile);
  nsresult GetTargetFileIsExecutable(PRBool* aTargetFileIsExecutable);
  nsresult GetTimeDownloadStarted(PRTime *aTimeDownloadStarted);
}
