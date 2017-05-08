module org.eclipse.swt.internal.mozilla.nsIServiceManager;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;

const char[] NS_ISERVICEMANAGER_IID_STR = "8bb35ed9-e332-462d-9155-4a002ab5c958";
const nsIID NS_ISERVICEMANAGER_IID= 
  {0x8bb35ed9, 0xe332, 0x462d, 
    [ 0x91, 0x55, 0x4a, 0x00, 0x2a, 0xb5, 0xc9, 0x58 ]};

interface nsIServiceManager : nsISupports {

  static const char[] IID_STR = NS_ISERVICEMANAGER_IID_STR;
  static const nsIID IID = NS_ISERVICEMANAGER_IID;

extern(System):
  nsresult GetService(nsCID * aClass, nsIID * aIID, void * *result);
  nsresult GetServiceByContractID(char *aContractID, nsIID * aIID, void * *result);
  nsresult IsServiceInstantiated(nsCID * aClass, nsIID * aIID, PRBool *_retval);
  nsresult IsServiceInstantiatedByContractID(char *aContractID, nsIID * aIID, PRBool *_retval);

}

