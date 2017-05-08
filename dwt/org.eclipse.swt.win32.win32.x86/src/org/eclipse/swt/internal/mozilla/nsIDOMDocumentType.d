module org.eclipse.swt.internal.mozilla.nsIDOMDocumentType;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;

import org.eclipse.swt.internal.mozilla.nsIDOMNode;
import org.eclipse.swt.internal.mozilla.nsIDOMNamedNodeMap;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_IDOMDOCUMENTTYPE_IID_STR = "a6cf9077-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMDOCUMENTTYPE_IID= 
  {0xa6cf9077, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMDocumentType : nsIDOMNode {

  static const char[] IID_STR = NS_IDOMDOCUMENTTYPE_IID_STR;
  static const nsIID IID = NS_IDOMDOCUMENTTYPE_IID;

extern(System):
  nsresult GetName(nsAString * aName);
  nsresult GetEntities(nsIDOMNamedNodeMap  *aEntities);
  nsresult GetNotations(nsIDOMNamedNodeMap  *aNotations);
  nsresult GetPublicId(nsAString * aPublicId);
  nsresult GetSystemId(nsAString * aSystemId);
  nsresult GetInternalSubset(nsAString * aInternalSubset);

}

