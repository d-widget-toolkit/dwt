module org.eclipse.swt.internal.mozilla.nsIProperties;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_IPROPERTIES_IID_STR = "78650582-4e93-4b60-8e85-26ebd3eb14ca";

const nsIID NS_IPROPERTIES_IID= 
  {0x78650582, 0x4e93, 0x4b60, 
    [ 0x8e, 0x85, 0x26, 0xeb, 0xd3, 0xeb, 0x14, 0xca ]};

interface nsIProperties : nsISupports {

  static const char[] IID_STR = NS_IPROPERTIES_IID_STR;
  static const nsIID IID = NS_IPROPERTIES_IID;

extern(System):
  nsresult Get(char *prop, nsIID * iid, void * *result);
  nsresult Set(char *prop, nsISupports value);
  nsresult Has(char *prop, PRBool *_retval);
  nsresult Undefine(char *prop);
  nsresult GetKeys(PRUint32 *count, char ***keys);

}

