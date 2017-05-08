module org.eclipse.swt.internal.mozilla.nsIEmbeddingSiteWindow;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_IEMBEDDINGSITEWINDOW_IID_STR = "3e5432cd-9568-4bd1-8cbe-d50aba110743";

const nsIID NS_IEMBEDDINGSITEWINDOW_IID= 
  {0x3e5432cd, 0x9568, 0x4bd1, 
    [ 0x8c, 0xbe, 0xd5, 0x0a, 0xba, 0x11, 0x07, 0x43 ]};

interface nsIEmbeddingSiteWindow : nsISupports {

  static const char[] IID_STR = NS_IEMBEDDINGSITEWINDOW_IID_STR;
  static const nsIID IID = NS_IEMBEDDINGSITEWINDOW_IID;

  enum { DIM_FLAGS_POSITION = 1U };
  enum { DIM_FLAGS_SIZE_INNER = 2U };
  enum { DIM_FLAGS_SIZE_OUTER = 4U };

extern(System):
  nsresult SetDimensions(PRUint32 flags, PRInt32 x, PRInt32 y, PRInt32 cx, PRInt32 cy);
  nsresult GetDimensions(PRUint32 flags, PRInt32 *x, PRInt32 *y, PRInt32 *cx, PRInt32 *cy);
  nsresult SetFocus();
  nsresult GetVisibility(PRBool *aVisibility);
  nsresult SetVisibility(PRBool aVisibility);
  nsresult GetTitle(PRUnichar * *aTitle);
  nsresult SetTitle(PRUnichar * aTitle);
  nsresult GetSiteWindow(void * *aSiteWindow);

}

