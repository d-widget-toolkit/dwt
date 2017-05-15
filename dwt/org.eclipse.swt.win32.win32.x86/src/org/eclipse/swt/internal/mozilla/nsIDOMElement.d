module org.eclipse.swt.internal.mozilla.nsIDOMElement;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;

import org.eclipse.swt.internal.mozilla.nsIDOMNode;
import org.eclipse.swt.internal.mozilla.nsIDOMNodeList;
import org.eclipse.swt.internal.mozilla.nsIDOMAttr;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_IDOMELEMENT_IID_STR = "a6cf9078-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMELEMENT_IID= 
  {0xa6cf9078, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMElement : nsIDOMNode {

  static const char[] IID_STR = NS_IDOMELEMENT_IID_STR;
  static const nsIID IID = NS_IDOMELEMENT_IID;

extern(System):
  nsresult GetTagName(nsAString * aTagName);
  nsresult GetAttribute(nsAString * name, nsAString * _retval);
  nsresult SetAttribute(nsAString * name, nsAString * value);
  nsresult RemoveAttribute(nsAString * name);
  nsresult GetAttributeNode(nsAString * name, nsIDOMAttr *_retval);
  nsresult SetAttributeNode(nsIDOMAttr newAttr, nsIDOMAttr *_retval);
  nsresult RemoveAttributeNode(nsIDOMAttr oldAttr, nsIDOMAttr *_retval);
  nsresult GetElementsByTagName(nsAString * name, nsIDOMNodeList *_retval);
  nsresult GetAttributeNS(nsAString * namespaceURI, nsAString * localName, nsAString * _retval);
  nsresult SetAttributeNS(nsAString * namespaceURI, nsAString * qualifiedName, nsAString * value);
  nsresult RemoveAttributeNS(nsAString * namespaceURI, nsAString * localName);
  nsresult GetAttributeNodeNS(nsAString * namespaceURI, nsAString * localName, nsIDOMAttr *_retval);
  nsresult SetAttributeNodeNS(nsIDOMAttr newAttr, nsIDOMAttr *_retval);
  nsresult GetElementsByTagNameNS(nsAString * namespaceURI, nsAString * localName, nsIDOMNodeList *_retval);
  nsresult HasAttribute(nsAString * name, PRBool *_retval);
  nsresult HasAttributeNS(nsAString * namespaceURI, nsAString * localName, PRBool *_retval);

}

