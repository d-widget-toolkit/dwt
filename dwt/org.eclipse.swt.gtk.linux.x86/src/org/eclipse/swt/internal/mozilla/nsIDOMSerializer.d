module org.eclipse.swt.internal.mozilla.nsIDOMSerializer;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIOutputStream;
import org.eclipse.swt.internal.mozilla.nsIDOMNode;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_IDOMSERIALIZER_IID_STR = "a6cf9123-15b3-11d2-932e-00805f8add32";

const nsIID NS_IDOMSERIALIZER_IID= 
  {0xa6cf9123, 0x15b3, 0x11d2, 
    [ 0x93, 0x2e, 0x00, 0x80, 0x5f, 0x8a, 0xdd, 0x32 ]};

interface nsIDOMSerializer : nsISupports {

  static const char[] IID_STR = NS_IDOMSERIALIZER_IID_STR;
  static const nsIID IID = NS_IDOMSERIALIZER_IID;

extern(System):

  nsresult SerializeToString(nsIDOMNode root, PRUnichar ** _retval);
  nsresult SerializeToStream(nsIDOMNode root, nsIOutputStream stream, char* charset);

}

