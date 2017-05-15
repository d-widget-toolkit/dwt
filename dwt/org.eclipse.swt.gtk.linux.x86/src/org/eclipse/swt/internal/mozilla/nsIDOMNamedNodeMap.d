module org.eclipse.swt.internal.mozilla.nsIDOMNamedNodeMap;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIDOMNode;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

alias PRUint64 DOMTimeStamp;

const char[] NS_IDOMNAMEDNODEMAP_IID_STR = "a6cf907b-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMNAMEDNODEMAP_IID= 
  {0xa6cf907b, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMNamedNodeMap : nsISupports {

  static const char[] IID_STR = NS_IDOMNAMEDNODEMAP_IID_STR;
  static const nsIID IID = NS_IDOMNAMEDNODEMAP_IID;

extern(System):
  nsresult GetNamedItem(nsAString * name, nsIDOMNode *_retval);
  nsresult SetNamedItem(nsIDOMNode arg, nsIDOMNode *_retval);
  nsresult RemoveNamedItem(nsAString * name, nsIDOMNode *_retval);
  nsresult Item(PRUint32 index, nsIDOMNode *_retval);
  nsresult GetLength(PRUint32 *aLength);
  nsresult GetNamedItemNS(nsAString * namespaceURI, nsAString * localName, nsIDOMNode *_retval);
  nsresult SetNamedItemNS(nsIDOMNode arg, nsIDOMNode *_retval);
  nsresult RemoveNamedItemNS(nsAString * namespaceURI, nsAString * localName, nsIDOMNode *_retval);

}

