module org.eclipse.swt.internal.mozilla.nsIContextMenuListener;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIDOMEvent; 
import org.eclipse.swt.internal.mozilla.nsIDOMNode; 

const char[] NS_ICONTEXTMENULISTENER_IID_STR = "3478b6b0-3875-11d4-94ef-0020183bf181";

const nsIID NS_ICONTEXTMENULISTENER_IID= 
  {0x3478b6b0, 0x3875, 0x11d4, 
    [ 0x94, 0xef, 0x00, 0x20, 0x18, 0x3b, 0xf1, 0x81 ]};

interface nsIContextMenuListener : nsISupports {

  static const char[] IID_STR = NS_ICONTEXTMENULISTENER_IID_STR;
  static const nsIID IID = NS_ICONTEXTMENULISTENER_IID;

extern(System):
  enum { CONTEXT_NONE = 0U };
  enum { CONTEXT_LINK = 1U };
  enum { CONTEXT_IMAGE = 2U };
  enum { CONTEXT_DOCUMENT = 4U };
  enum { CONTEXT_TEXT = 8U };
  enum { CONTEXT_INPUT = 16U };

  nsresult OnShowContextMenu(PRUint32 aContextFlags, nsIDOMEvent aEvent, nsIDOMNode aNode);
}

