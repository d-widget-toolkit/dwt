module org.eclipse.swt.internal.mozilla.nsIDOMRange;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIDOMNode;
import org.eclipse.swt.internal.mozilla.nsIDOMDocumentFragment;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_IDOMRANGE_IID_STR = "a6cf90ce-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMRANGE_IID= 
  {0xa6cf90ce, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMRange : nsISupports {

  static const char[] IID_STR = NS_IDOMRANGE_IID_STR;
  static const nsIID IID = NS_IDOMRANGE_IID;

extern(System):
  nsresult GetStartContainer(nsIDOMNode  *aStartContainer);
  nsresult GetStartOffset(PRInt32 *aStartOffset);
  nsresult GetEndContainer(nsIDOMNode  *aEndContainer);
  nsresult GetEndOffset(PRInt32 *aEndOffset);
  nsresult GetCollapsed(PRBool *aCollapsed);
  nsresult GetCommonAncestorContainer(nsIDOMNode  *aCommonAncestorContainer);
  nsresult SetStart(nsIDOMNode refNode, PRInt32 offset);
  nsresult SetEnd(nsIDOMNode refNode, PRInt32 offset);
  nsresult SetStartBefore(nsIDOMNode refNode);
  nsresult SetStartAfter(nsIDOMNode refNode);
  nsresult SetEndBefore(nsIDOMNode refNode);
  nsresult SetEndAfter(nsIDOMNode refNode);
  nsresult Collapse(PRBool toStart);
  nsresult SelectNode(nsIDOMNode refNode);
  nsresult SelectNodeContents(nsIDOMNode refNode);

  enum { START_TO_START = 0U };
  enum { START_TO_END = 1U };
  enum { END_TO_END = 2U };
  enum { END_TO_START = 3U };

  nsresult CompareBoundaryPoints(PRUint16 how, nsIDOMRange sourceRange, PRInt16 *_retval);
  nsresult DeleteContents();
  nsresult ExtractContents(nsIDOMDocumentFragment *_retval);
  nsresult CloneContents(nsIDOMDocumentFragment *_retval);
  nsresult InsertNode(nsIDOMNode newNode);
  nsresult SurroundContents(nsIDOMNode newParent);
  nsresult CloneRange(nsIDOMRange *_retval);
  nsresult ToString(nsAString * _retval);
  nsresult Detach();

}

