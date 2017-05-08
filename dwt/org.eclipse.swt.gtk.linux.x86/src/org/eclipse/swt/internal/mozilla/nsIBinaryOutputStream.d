module org.eclipse.swt.internal.mozilla.nsIBinaryOutputStream;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIOutputStream;

const char[] NS_IBINARYOUTPUTSTREAM_IID_STR = "204ee610-8765-11d3-90cf-0040056a906e";

const nsIID NS_IBINARYOUTPUTSTREAM_IID= 
  {0x204ee610, 0x8765, 0x11d3, 
    [ 0x90, 0xcf, 0x00, 0x40, 0x05, 0x6a, 0x90, 0x6e ]};

interface nsIBinaryOutputStream : nsIOutputStream {

  static const char[] IID_STR = NS_IBINARYOUTPUTSTREAM_IID_STR;
  static const nsIID IID = NS_IBINARYOUTPUTSTREAM_IID;

extern(System):
  nsresult SetOutputStream(nsIOutputStream aOutputStream);
  nsresult WriteBoolean(PRBool aBoolean);
  nsresult Write8(PRUint8 aByte);
  nsresult Write16(PRUint16 a16);
  nsresult Write32(PRUint32 a32);
  nsresult Write64(PRUint64 a64);
  nsresult WriteFloat(float aFloat);
  nsresult WriteDouble(double aDouble);
  nsresult WriteStringZ(char *aString);
  nsresult WriteWStringZ(PRUnichar *aString);
  nsresult WriteUtf8Z(PRUnichar *aString);
  nsresult WriteBytes(char *aString, PRUint32 aLength);
  nsresult WriteByteArray(PRUint8 *aBytes, PRUint32 aLength);

}

