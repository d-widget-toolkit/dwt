module org.eclipse.swt.internal.mozilla.nsIContextMenuListener2;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIDOMEvent;
import org.eclipse.swt.internal.mozilla.nsIDOMNode; 
import org.eclipse.swt.internal.mozilla.imgIContainer;
import org.eclipse.swt.internal.mozilla.nsIURI; 
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_ICONTEXTMENULISTENER2_IID_STR = "7fb719b3-d804-4964-9596-77cf924ee314";

const nsIID NS_ICONTEXTMENULISTENER2_IID= 
  {0x7fb719b3, 0xd804, 0x4964, 
    [ 0x95, 0x96, 0x77, 0xcf, 0x92, 0x4e, 0xe3, 0x14 ]};

interface nsIContextMenuListener2 : nsISupports {

  static const char[] IID_STR = NS_ICONTEXTMENULISTENER2_IID_STR;
  static const nsIID IID = NS_ICONTEXTMENULISTENER2_IID;

  enum { CONTEXT_NONE = 0U };
  enum { CONTEXT_LINK = 1U };
  enum { CONTEXT_IMAGE = 2U };
  enum { CONTEXT_DOCUMENT = 4U };
  enum { CONTEXT_TEXT = 8U };
  enum { CONTEXT_INPUT = 16U };
  enum { CONTEXT_BACKGROUND_IMAGE = 32U };

extern(System):
  nsresult OnShowContextMenu(PRUint32 aContextFlags, nsIContextMenuInfo aUtils);
}

/******************************************************************************

******************************************************************************/

const char[] NS_ICONTEXTMENUINFO_IID_STR = "2f977d56-5485-11d4-87e2-0010a4e75ef2";

const nsIID NS_ICONTEXTMENUINFO_IID= 
  {0x2f977d56, 0x5485, 0x11d4, 
    [ 0x87, 0xe2, 0x00, 0x10, 0xa4, 0xe7, 0x5e, 0xf2 ]};

interface nsIContextMenuInfo : nsISupports {

  static const char[] IID_STR = NS_ICONTEXTMENUINFO_IID_STR;
  static const nsIID IID = NS_ICONTEXTMENUINFO_IID;

extern(System):
  nsresult GetMouseEvent(nsIDOMEvent  *aMouseEvent);
  nsresult GetTargetNode(nsIDOMNode  *aTargetNode);
  nsresult GetAssociatedLink(nsAString * aAssociatedLink);
  nsresult GetImageContainer(imgIContainer  *aImageContainer);
  nsresult GetImageSrc(nsIURI  *aImageSrc);
  nsresult GetBackgroundImageContainer(imgIContainer  *aBackgroundImageContainer);
  nsresult GetBackgroundImageSrc(nsIURI  *aBackgroundImageSrc);
}

