module org.eclipse.swt.internal.mozilla.nsISelection;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIDOMNode;
import org.eclipse.swt.internal.mozilla.nsIDOMRange;

const char[] NS_ISELECTION_IID_STR = "b2c7ed59-8634-4352-9e37-5484c8b6e4e1";

const nsIID NS_ISELECTION_IID= 
  {0xb2c7ed59, 0x8634, 0x4352, 
    [ 0x9e, 0x37, 0x54, 0x84, 0xc8, 0xb6, 0xe4, 0xe1 ]};

interface nsISelection : nsISupports {

  static const char[] IID_STR = NS_ISELECTION_IID_STR;
  static const nsIID IID = NS_ISELECTION_IID;

extern(System):
  nsresult GetAnchorNode(nsIDOMNode  *aAnchorNode);
  nsresult GetAnchorOffset(PRInt32 *aAnchorOffset);
  nsresult GetFocusNode(nsIDOMNode  *aFocusNode);
  nsresult GetFocusOffset(PRInt32 *aFocusOffset);
  nsresult GetIsCollapsed(PRBool *aIsCollapsed);
  nsresult GetRangeCount(PRInt32 *aRangeCount);
  nsresult GetRangeAt(PRInt32 index, nsIDOMRange *_retval);
  nsresult Collapse(nsIDOMNode parentNode, PRInt32 offset);
  nsresult Extend(nsIDOMNode parentNode, PRInt32 offset);
  nsresult CollapseToStart();
  nsresult CollapseToEnd();
  nsresult ContainsNode(nsIDOMNode node, PRBool entirelyContained, PRBool *_retval);
  nsresult SelectAllChildren(nsIDOMNode parentNode);
  nsresult AddRange(nsIDOMRange range);
  nsresult RemoveRange(nsIDOMRange range);
  nsresult RemoveAllRanges();
  nsresult DeleteFromDocument();
  nsresult SelectionLanguageChange(PRBool langRTL);
  nsresult ToString(PRUnichar **_retval);

}

