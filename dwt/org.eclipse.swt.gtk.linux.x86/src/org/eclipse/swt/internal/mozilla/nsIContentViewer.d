module org.eclipse.swt.internal.mozilla.nsIContentViewer;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIDOMDocument;
import org.eclipse.swt.internal.mozilla.nsISHEntry;

/******************************************************************************

******************************************************************************/

const char[] NS_ICONTENTVIEWER_IID_STR = "6a7ddb40-8a9e-4576-8ad1-71c5641d8780";

const nsIID NS_ICONTENTVIEWER_IID= 
  {0x6a7ddb40, 0x8a9e, 0x4576, 
    [ 0x8a, 0xd1, 0x71, 0xc5, 0x64, 0x1d, 0x87, 0x80 ]};

interface nsIContentViewer : nsISupports {

  static const char[] IID_STR = NS_ICONTENTVIEWER_IID_STR;
  static const nsIID IID = NS_ICONTENTVIEWER_IID;

extern(System):
  nsresult Init(nsIWidget * aParentWidget, nsIDeviceContext * aDeviceContext, nsRect * aBounds);
  nsresult GetContainer(nsISupports  *aContainer);
  nsresult SetContainer(nsISupports  aContainer);
  nsresult LoadStart(nsISupports aDoc);
  nsresult LoadComplete(PRUint32 aStatus);
  nsresult PermitUnload(PRBool *_retval);
  nsresult PageHide(PRBool isUnload);
  nsresult Close(nsISHEntry historyEntry);
  nsresult Destroy();
  nsresult Stop();
  nsresult GetDOMDocument(nsIDOMDocument  *aDOMDocument);
  nsresult SetDOMDocument(nsIDOMDocument  aDOMDocument);
  nsresult GetBounds(nsRect * aBounds);
  nsresult SetBounds(nsRect * aBounds);
  nsresult GetPreviousViewer(nsIContentViewer  *aPreviousViewer);
  nsresult SetPreviousViewer(nsIContentViewer  aPreviousViewer);
  nsresult Move(PRInt32 aX, PRInt32 aY);
  nsresult Show();
  nsresult Hide();
  nsresult GetEnableRendering(PRBool *aEnableRendering);
  nsresult SetEnableRendering(PRBool aEnableRendering);
  nsresult GetSticky(PRBool *aSticky);
  nsresult SetSticky(PRBool aSticky);
  nsresult RequestWindowClose(PRBool *_retval);
  nsresult Open(nsISupports aState);
  nsresult ClearHistoryEntry();

}

/******************************************************************************

******************************************************************************/

const char[] NS_ICONTENTVIEWER_MOZILLA_1_8_BRANCH_IID_STR = "51341ed4-a3bf-4fd5-ae17-5fd3ec59dcab";

const nsIID NS_ICONTENTVIEWER_MOZILLA_1_8_BRANCH_IID= 
  {0x51341ed4, 0xa3bf, 0x4fd5, 
    [ 0xae, 0x17, 0x5f, 0xd3, 0xec, 0x59, 0xdc, 0xab ]};

interface nsIContentViewer_MOZILLA_1_8_BRANCH : nsISupports {

  static const char[] IID_STR = NS_ICONTENTVIEWER_MOZILLA_1_8_BRANCH_IID_STR;
  static const nsIID IID = NS_ICONTENTVIEWER_MOZILLA_1_8_BRANCH_IID;

extern(System):
  nsresult OpenWithEntry(nsISupports aState, nsISHEntry aSHEntry);

}

