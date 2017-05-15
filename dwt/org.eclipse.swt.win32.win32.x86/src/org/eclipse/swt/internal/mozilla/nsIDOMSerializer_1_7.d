module org.eclipse.swt.internal.mozilla.nsIDOMSerializer_1_7;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIOutputStream;
import org.eclipse.swt.internal.mozilla.nsIDOMNode;
import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_IDOMSERIALIZER_IID_STR = "9fd4ba15-e67c-4c98-b52c-7715f62c9196";

const nsIID NS_IDOMSERIALIZER_IID= 
  {0x9fd4ba15, 0xe67c, 0x4c98, 
    [ 0xb5, 0x2c, 0x77, 0x15, 0xf6, 0x2c, 0x91, 0x96 ]};

interface nsIDOMSerializer_1_7 : nsISupports {

  static const char[] IID_STR = NS_IDOMSERIALIZER_IID_STR;
  static const nsIID IID = NS_IDOMSERIALIZER_IID;

extern(System):
  nsresult SerializeToString(nsIDOMNode root, nsAString * _retval);
  nsresult SerializeToStream(nsIDOMNode root, nsIOutputStream stream, nsACString * charset);

}

