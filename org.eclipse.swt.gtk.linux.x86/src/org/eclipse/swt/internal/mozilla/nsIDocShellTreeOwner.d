module org.eclipse.swt.internal.mozilla.nsIDocShellTreeOwner;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIDocShellTreeItem;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

/******************************************************************************

******************************************************************************/

const char[] NS_IDOCSHELLTREEOWNER_IID_STR = "9e508466-5ebb-4618-abfa-9ad47bed0b2e";

const nsIID NS_IDOCSHELLTREEOWNER_IID= 
  {0x9e508466, 0x5ebb, 0x4618, 
    [ 0xab, 0xfa, 0x9a, 0xd4, 0x7b, 0xed, 0x0b, 0x2e ]};

interface nsIDocShellTreeOwner : nsISupports {

  static const char[] IID_STR = NS_IDOCSHELLTREEOWNER_IID_STR;
  static const nsIID IID = NS_IDOCSHELLTREEOWNER_IID;

extern(System):
  nsresult FindItemWithName(PRUnichar *name, nsIDocShellTreeItem aRequestor, nsIDocShellTreeItem aOriginalRequestor, nsIDocShellTreeItem *_retval);
  nsresult ContentShellAdded(nsIDocShellTreeItem aContentShell, PRBool aPrimary, PRUnichar *aID);
  nsresult GetPrimaryContentShell(nsIDocShellTreeItem  *aPrimaryContentShell);
  nsresult SizeShellTo(nsIDocShellTreeItem shell, PRInt32 cx, PRInt32 cy);
  nsresult SetPersistence(PRBool aPersistPosition, PRBool aPersistSize, PRBool aPersistSizeMode);
  nsresult GetPersistence(PRBool *aPersistPosition, PRBool *aPersistSize, PRBool *aPersistSizeMode);

}

/******************************************************************************

******************************************************************************/

const char[] NS_IDOCSHELLTREEOWNER_MOZILLA_1_8_BRANCH_IID_STR = "3c2a6927-e923-4ea8-bbda-a335c768ce4e";

const nsIID NS_IDOCSHELLTREEOWNER_MOZILLA_1_8_BRANCH_IID= 
  {0x3c2a6927, 0xe923, 0x4ea8, 
    [ 0xbb, 0xda, 0xa3, 0x35, 0xc7, 0x68, 0xce, 0x4e ]};

interface nsIDocShellTreeOwner_MOZILLA_1_8_BRANCH : nsIDocShellTreeOwner {

  static const char[] IID_STR = NS_IDOCSHELLTREEOWNER_MOZILLA_1_8_BRANCH_IID_STR;
  static const nsIID IID = NS_IDOCSHELLTREEOWNER_MOZILLA_1_8_BRANCH_IID;

extern(System):
  nsresult ContentShellAdded2(nsIDocShellTreeItem aContentShell, PRBool aPrimary, PRBool aTargetable, nsAString * aID);
  nsresult ContentShellRemoved(nsIDocShellTreeItem aContentShell);

}

