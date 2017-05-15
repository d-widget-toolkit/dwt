module org.eclipse.swt.internal.mozilla.nsIComponentManager;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIFactory;

const char[] NS_ICOMPONENTMANAGER_IID_STR = "a88e5a60-205a-4bb1-94e1-2628daf51eae";

const nsIID NS_ICOMPONENTMANAGER_IID= 
  {0xa88e5a60, 0x205a, 0x4bb1, 
    [ 0x94, 0xe1, 0x26, 0x28, 0xda, 0xf5, 0x1e, 0xae ]};

interface nsIComponentManager : nsISupports {
  static const char[] IID_STR = NS_ICOMPONENTMANAGER_IID_STR;
  static const nsIID IID = NS_ICOMPONENTMANAGER_IID;

extern(System):
  nsresult GetClassObject(nsCID * aClass, nsIID * aIID, void * *result);
  nsresult GetClassObjectByContractID(char *aContractID, nsIID * aIID, void * *result);
  nsresult CreateInstance(nsCID * aClass, nsISupports aDelegate, nsIID * aIID, void * *result);
  nsresult CreateInstanceByContractID(char *aContractID, nsISupports aDelegate, nsIID * aIID, void * *result);
}

