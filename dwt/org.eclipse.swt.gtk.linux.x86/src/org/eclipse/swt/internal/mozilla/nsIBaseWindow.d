module org.eclipse.swt.internal.mozilla.nsIBaseWindow;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

alias void * nativeWindow;

const char[] NS_IBASEWINDOW_IID_STR = "046bc8a0-8015-11d3-af70-00a024ffc08c";

const nsIID NS_IBASEWINDOW_IID= 
  {0x046bc8a0, 0x8015, 0x11d3, 
    [ 0xaf, 0x70, 0x00, 0xa0, 0x24, 0xff, 0xc0, 0x8c ]};

interface nsIBaseWindow : nsISupports {

  static const char[] IID_STR = NS_IBASEWINDOW_IID_STR;
  static const nsIID IID = NS_IBASEWINDOW_IID;

extern(System):
  nsresult InitWindow(nativeWindow parentNativeWindow, nsIWidget * parentWidget, PRInt32 x, PRInt32 y, PRInt32 cx, PRInt32 cy);
  nsresult Create();
  nsresult Destroy();
  nsresult SetPosition(PRInt32 x, PRInt32 y);
  nsresult GetPosition(PRInt32 *x, PRInt32 *y);
  nsresult SetSize(PRInt32 cx, PRInt32 cy, PRBool fRepaint);
  nsresult GetSize(PRInt32 *cx, PRInt32 *cy);
  nsresult SetPositionAndSize(PRInt32 x, PRInt32 y, PRInt32 cx, PRInt32 cy, PRBool fRepaint);
  nsresult GetPositionAndSize(PRInt32 *x, PRInt32 *y, PRInt32 *cx, PRInt32 *cy);
  nsresult Repaint(PRBool force);
  nsresult GetParentWidget(nsIWidget * *aParentWidget);
  nsresult SetParentWidget(nsIWidget * aParentWidget);
  nsresult GetParentNativeWindow(nativeWindow *aParentNativeWindow);
  nsresult SetParentNativeWindow(nativeWindow aParentNativeWindow);
  nsresult GetVisibility(PRBool *aVisibility);
  nsresult SetVisibility(PRBool aVisibility);
  nsresult GetEnabled(PRBool *aEnabled);
  nsresult SetEnabled(PRBool aEnabled);
  nsresult GetBlurSuppression(PRBool *aBlurSuppression);
  nsresult SetBlurSuppression(PRBool aBlurSuppression);
  nsresult GetMainWidget(nsIWidget * *aMainWidget);
  nsresult SetFocus();
  nsresult GetTitle(PRUnichar * *aTitle);
  nsresult SetTitle(PRUnichar * aTitle);

}

