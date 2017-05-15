module org.eclipse.swt.internal.mozilla.nsIAtom;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

import org.eclipse.swt.internal.mozilla.nsStringAPI;

const char[] NS_IATOM_IID_STR = "3d1b15b0-93b4-11d1-895b-006008911b81";

const nsIID NS_IATOM_IID= 
  {0x3d1b15b0, 0x93b4, 0x11d1, 
    [ 0x89, 0x5b, 0x00, 0x60, 0x08, 0x91, 0x1b, 0x81 ]};

interface nsIAtom : nsISupports {

  static const char[] IID_STR = NS_IATOM_IID_STR;
  static const nsIID IID = NS_IATOM_IID;

extern(System):
  nsresult ToString(nsAString * _retval);
  nsresult ToUTF8String(nsACString * _retval);
  nsresult GetUTF8String(char **aResult);
  nsresult Equals(nsAString * aString, PRBool *_retval);
  nsresult EqualsUTF8(nsACString * aString, PRBool *_retval);

}

