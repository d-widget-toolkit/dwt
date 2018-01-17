module org.eclipse.swt.internal.mozilla.nsISerializable;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsIObjectInputStream; 
import org.eclipse.swt.internal.mozilla.nsIObjectOutputStream;

const char[] NS_ISERIALIZABLE_IID_STR = "91cca981-c26d-44a8-bebe-d9ed4891503a";

const nsIID NS_ISERIALIZABLE_IID= 
  {0x91cca981, 0xc26d, 0x44a8, 
    [ 0xbe, 0xbe, 0xd9, 0xed, 0x48, 0x91, 0x50, 0x3a ]};

interface nsISerializable : nsISupports {

  static const char[] IID_STR = NS_ISERIALIZABLE_IID_STR;
  static const nsIID IID = NS_ISERIALIZABLE_IID;

extern(System):
  nsresult Read(nsIObjectInputStream aInputStream);
  nsresult Write(nsIObjectOutputStream aOutputStream);

}

