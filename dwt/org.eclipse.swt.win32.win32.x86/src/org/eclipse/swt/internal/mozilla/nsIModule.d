module org.eclipse.swt.internal.mozilla.nsIModule;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIFile; 
import org.eclipse.swt.internal.mozilla.nsIComponentManager;

const char[] NS_IMODULE_IID_STR = "7392d032-5371-11d3-994e-00805fd26fee";

const nsIID NS_IMODULE_IID= 
  {0x7392d032, 0x5371, 0x11d3, 
    [ 0x99, 0x4e, 0x00, 0x80, 0x5f, 0xd2, 0x6f, 0xee ]};

interface nsIModule : nsISupports {
  static const char[] IID_STR = NS_IMODULE_IID_STR;
  static const nsIID IID = NS_IMODULE_IID;

extern(System):
  nsresult GetClassObject(nsIComponentManager aCompMgr, nsCID * aClass, nsIID * aIID, void * *aResult);
  nsresult RegisterSelf(nsIComponentManager aCompMgr, nsIFile aLocation, char *aLoaderStr, char *aType);
  nsresult UnregisterSelf(nsIComponentManager aCompMgr, nsIFile aLocation, char *aLoaderStr);
  nsresult CanUnload(nsIComponentManager aCompMgr, PRBool *_retval);
}

