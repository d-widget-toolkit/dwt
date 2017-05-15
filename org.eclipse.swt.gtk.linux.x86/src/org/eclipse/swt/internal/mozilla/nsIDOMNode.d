module org.eclipse.swt.internal.mozilla.nsIDOMNode;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIDOMNodeList;
import org.eclipse.swt.internal.mozilla.nsIDOMNamedNodeMap;
import org.eclipse.swt.internal.mozilla.nsIDOMDocument;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMNODE_IID_STR = "a6cf907c-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMNODE_IID= 
  {0xa6cf907c, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMNode : nsISupports {

  static const char[] IID_STR = NS_IDOMNODE_IID_STR;
  static const nsIID IID = NS_IDOMNODE_IID;

extern(System):
  enum { ELEMENT_NODE = 1U };
  enum { ATTRIBUTE_NODE = 2U };
  enum { TEXT_NODE = 3U };
  enum { CDATA_SECTION_NODE = 4U };
  enum { ENTITY_REFERENCE_NODE = 5U };
  enum { ENTITY_NODE = 6U };
  enum { PROCESSING_INSTRUCTION_NODE = 7U };
  enum { COMMENT_NODE = 8U };
  enum { DOCUMENT_NODE = 9U };
  enum { DOCUMENT_TYPE_NODE = 10U };
  enum { DOCUMENT_FRAGMENT_NODE = 11U };
  enum { NOTATION_NODE = 12U };

  nsresult GetNodeName(nsAString * aNodeName);
  nsresult GetNodeValue(nsAString * aNodeValue);
  nsresult SetNodeValue(nsAString * aNodeValue);
  nsresult GetNodeType(PRUint16 *aNodeType);
  nsresult GetParentNode(nsIDOMNode  *aParentNode);
  nsresult GetChildNodes(nsIDOMNodeList  *aChildNodes);
  nsresult GetFirstChild(nsIDOMNode  *aFirstChild);
  nsresult GetLastChild(nsIDOMNode  *aLastChild);
  nsresult GetPreviousSibling(nsIDOMNode  *aPreviousSibling);
  nsresult GetNextSibling(nsIDOMNode  *aNextSibling);
  nsresult GetAttributes(nsIDOMNamedNodeMap  *aAttributes);
  nsresult GetOwnerDocument(nsIDOMDocument  *aOwnerDocument);
  nsresult InsertBefore(nsIDOMNode newChild, nsIDOMNode refChild, nsIDOMNode *_retval);
  nsresult ReplaceChild(nsIDOMNode newChild, nsIDOMNode oldChild, nsIDOMNode *_retval);
  nsresult RemoveChild(nsIDOMNode oldChild, nsIDOMNode *_retval);
  nsresult AppendChild(nsIDOMNode newChild, nsIDOMNode *_retval);
  nsresult HasChildNodes(PRBool *_retval);
  nsresult CloneNode(PRBool deep, nsIDOMNode *_retval);
  nsresult Normalize();
  nsresult IsSupported(nsAString * feature, nsAString * version_, PRBool *_retval);
  nsresult GetNamespaceURI(nsAString * aNamespaceURI);
  nsresult GetPrefix(nsAString * aPrefix);
  nsresult SetPrefix(nsAString * aPrefix);
  nsresult GetLocalName(nsAString * aLocalName);
  nsresult HasAttributes(PRBool *_retval);

}

