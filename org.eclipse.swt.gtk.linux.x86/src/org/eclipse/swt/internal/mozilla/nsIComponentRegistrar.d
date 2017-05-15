module org.eclipse.swt.internal.mozilla.nsIComponentRegistrar;

import java.lang.all;

import org.eclipse.swt.internal.mozilla.Common;
import org.eclipse.swt.internal.mozilla.nsID;
import org.eclipse.swt.internal.mozilla.nsISupports;
import org.eclipse.swt.internal.mozilla.nsIFile;
import org.eclipse.swt.internal.mozilla.nsIFactory;
import org.eclipse.swt.internal.mozilla.nsISimpleEnumerator;

const char[] NS_ICOMPONENTREGISTRAR_IID_STR = "2417cbfe-65ad-48a6-b4b6-eb84db174392";

const nsIID NS_ICOMPONENTREGISTRAR_IID= 
  {0x2417cbfe, 0x65ad, 0x48a6, 
    [ 0xb4, 0xb6, 0xeb, 0x84, 0xdb, 0x17, 0x43, 0x92 ]};

interface nsIComponentRegistrar : nsISupports {
  static const char[] IID_STR = NS_ICOMPONENTREGISTRAR_IID_STR;
  static const nsIID IID = NS_ICOMPONENTREGISTRAR_IID;

extern(System):
  nsresult AutoRegister(nsIFile aSpec);
  nsresult AutoUnregister(nsIFile aSpec);
  nsresult RegisterFactory(in nsCID * aClass, in char *aClassName, in char *aContractID, nsIFactory aFactory);
  nsresult UnregisterFactory(in nsCID * aClass, nsIFactory aFactory);
  nsresult RegisterFactoryLocation(in nsCID * aClass, in char *aClassName, in char *aContractID, nsIFile aFile, in char *aLoaderStr, in char *aType);
  nsresult UnregisterFactoryLocation(in nsCID * aClass, nsIFile aFile);
  nsresult IsCIDRegistered(in nsCID * aClass, PRBool *_retval);
  nsresult IsContractIDRegistered(in char *aContractID, PRBool *_retval);
  nsresult EnumerateCIDs(nsISimpleEnumerator *_retval);
  nsresult EnumerateContractIDs(nsISimpleEnumerator *_retval);
  nsresult CIDToContractID(nsCID * aClass, char **_retval);
  nsresult ContractIDToCID(in char *aContractID, nsCID * *_retval);
}

